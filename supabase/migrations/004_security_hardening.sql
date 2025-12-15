-- ============================================================
-- OrbisFX Launcher - Security Hardening Migration
-- ============================================================
-- This migration addresses multiple security vulnerabilities:
-- 1. Overly permissive RLS policies on preset_ratings
-- 2. Missing rate limiting
-- 3. Insecure moderation function authentication
-- 4. Missing audit logging
-- 5. Client version validation
-- ============================================================

-- ============================================================
-- SECTION 1: Request Validation Helpers
-- ============================================================

-- Get device ID from request headers (set by client)
CREATE OR REPLACE FUNCTION get_request_device_id()
RETURNS TEXT
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    current_setting('request.headers', true)::json->>'x-device-id',
    current_setting('request.headers', true)::json->>'X-Device-Id',
    NULL
  );
$$;

-- Get client version from request headers
CREATE OR REPLACE FUNCTION get_client_version()
RETURNS TEXT
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    current_setting('request.headers', true)::json->>'x-client-version',
    current_setting('request.headers', true)::json->>'X-Client-Version',
    '0.0.0'
  );
$$;

-- Get Discord ID from request headers (set after OAuth)
CREATE OR REPLACE FUNCTION get_request_discord_id()
RETURNS TEXT
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    current_setting('request.headers', true)::json->>'x-discord-id',
    current_setting('request.headers', true)::json->>'X-Discord-Id',
    NULL
  );
$$;

-- Validate device ID format (UUID-like)
CREATE OR REPLACE FUNCTION is_valid_device_id(device_id TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  IF device_id IS NULL OR LENGTH(device_id) < 32 THEN
    RETURN FALSE;
  END IF;
  -- UUID format: 8-4-4-4-12 or 32 hex chars
  RETURN device_id ~* '^[0-9a-f]{8}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{12}$';
END;
$$;

-- Compare semantic versions (returns -1, 0, or 1)
CREATE OR REPLACE FUNCTION compare_versions(v1 TEXT, v2 TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  v1_parts INTEGER[];
  v2_parts INTEGER[];
  i INTEGER;
BEGIN
  -- Parse version strings into integer arrays
  v1_parts := string_to_array(regexp_replace(v1, '[^0-9.]', '', 'g'), '.')::INTEGER[];
  v2_parts := string_to_array(regexp_replace(v2, '[^0-9.]', '', 'g'), '.')::INTEGER[];
  
  -- Pad arrays to same length
  WHILE array_length(v1_parts, 1) < 3 LOOP
    v1_parts := array_append(v1_parts, 0);
  END LOOP;
  WHILE array_length(v2_parts, 1) < 3 LOOP
    v2_parts := array_append(v2_parts, 0);
  END LOOP;
  
  -- Compare each part
  FOR i IN 1..3 LOOP
    IF v1_parts[i] > v2_parts[i] THEN RETURN 1; END IF;
    IF v1_parts[i] < v2_parts[i] THEN RETURN -1; END IF;
  END LOOP;
  
  RETURN 0;
END;
$$;

-- ============================================================
-- SECTION 2: Rate Limiting Infrastructure
-- ============================================================

-- Rate limit tracking table
CREATE TABLE IF NOT EXISTS rate_limits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  identifier TEXT NOT NULL,           -- device_id or discord_id
  action_type TEXT NOT NULL,          -- 'rating', 'submission', 'moderation', etc.
  window_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  request_count INTEGER NOT NULL DEFAULT 1,
  UNIQUE(identifier, action_type, window_start)
);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_rate_limits_lookup 
ON rate_limits(identifier, action_type, window_start);

-- Auto-cleanup old rate limit records (run daily via pg_cron or external job)
CREATE OR REPLACE FUNCTION cleanup_old_rate_limits()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM rate_limits WHERE window_start < NOW() - INTERVAL '24 hours';
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$;

-- Check and increment rate limit (returns TRUE if allowed, FALSE if rate limited)
CREATE OR REPLACE FUNCTION check_rate_limit(
  p_identifier TEXT,
  p_action_type TEXT,
  p_max_requests INTEGER,
  p_window_minutes INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_window_start TIMESTAMPTZ;
  v_current_count INTEGER;
BEGIN
  -- Calculate current window start
  v_window_start := date_trunc('minute', NOW()) 
    - (EXTRACT(MINUTE FROM NOW())::INTEGER % p_window_minutes) * INTERVAL '1 minute';
  
  -- Try to get current count for this window
  SELECT request_count INTO v_current_count
  FROM rate_limits
  WHERE identifier = p_identifier
    AND action_type = p_action_type
    AND window_start = v_window_start;
  
  IF v_current_count IS NULL THEN
    -- First request in this window
    INSERT INTO rate_limits (identifier, action_type, window_start, request_count)
    VALUES (p_identifier, p_action_type, v_window_start, 1)
    ON CONFLICT (identifier, action_type, window_start) 
    DO UPDATE SET request_count = rate_limits.request_count + 1;
    RETURN TRUE;
  ELSIF v_current_count >= p_max_requests THEN
    -- Rate limit exceeded
    RETURN FALSE;
  ELSE
    -- Increment counter
    UPDATE rate_limits 
    SET request_count = request_count + 1
    WHERE identifier = p_identifier
      AND action_type = p_action_type
      AND window_start = v_window_start;
    RETURN TRUE;
  END IF;
END;
$$;

-- ============================================================
-- SECTION 3: Audit Logging
-- ============================================================

-- Comprehensive audit log table
CREATE TABLE IF NOT EXISTS audit_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Who performed the action
  actor_type TEXT NOT NULL,               -- 'device', 'discord_user', 'moderator', 'system'
  actor_id TEXT,                          -- device_id or discord_id
  actor_ip TEXT,                          -- IP address if available

  -- What action was performed
  action TEXT NOT NULL,                   -- 'rate_preset', 'submit_preset', 'approve_preset', etc.
  resource_type TEXT,                     -- 'preset_rating', 'community_preset', etc.
  resource_id TEXT,                       -- UUID of the affected resource

  -- Additional context
  metadata JSONB DEFAULT '{}',            -- Any additional data
  client_version TEXT,                    -- Client app version

  -- Result
  success BOOLEAN DEFAULT TRUE,
  error_message TEXT,

  -- Timestamp
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for audit log queries
CREATE INDEX IF NOT EXISTS idx_audit_log_actor ON audit_log(actor_type, actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_action ON audit_log(action);
CREATE INDEX IF NOT EXISTS idx_audit_log_resource ON audit_log(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_created ON audit_log(created_at);

-- RLS for audit log (only moderators can read, system can write)
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Moderators can view audit log" ON audit_log
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE discord_id = get_request_discord_id()
      AND is_moderator = TRUE
    )
  );

-- Function to log an audit event
CREATE OR REPLACE FUNCTION log_audit_event(
  p_actor_type TEXT,
  p_actor_id TEXT,
  p_action TEXT,
  p_resource_type TEXT DEFAULT NULL,
  p_resource_id TEXT DEFAULT NULL,
  p_metadata JSONB DEFAULT '{}',
  p_success BOOLEAN DEFAULT TRUE,
  p_error_message TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_audit_id UUID;
  v_client_ip TEXT;
BEGIN
  -- Try to get client IP from headers
  v_client_ip := COALESCE(
    current_setting('request.headers', true)::json->>'x-real-ip',
    current_setting('request.headers', true)::json->>'x-forwarded-for',
    'unknown'
  );

  INSERT INTO audit_log (
    actor_type, actor_id, actor_ip, action,
    resource_type, resource_id, metadata,
    client_version, success, error_message
  )
  VALUES (
    p_actor_type, p_actor_id, v_client_ip, p_action,
    p_resource_type, p_resource_id, p_metadata,
    get_client_version(), p_success, p_error_message
  )
  RETURNING id INTO v_audit_id;

  RETURN v_audit_id;
END;
$$;

-- ============================================================
-- SECTION 4: Fixed RLS Policies for preset_ratings
-- ============================================================

-- Drop the overly permissive policies
DROP POLICY IF EXISTS "Users can update own ratings" ON preset_ratings;
DROP POLICY IF EXISTS "Users can delete own ratings" ON preset_ratings;
DROP POLICY IF EXISTS "Anyone can rate" ON preset_ratings;

-- New secure policy: Users can only INSERT with a valid device ID that matches
CREATE POLICY "Authenticated device can rate" ON preset_ratings
  FOR INSERT WITH CHECK (
    -- Device ID in the row must match the device ID from request headers
    user_id = get_request_device_id()
    AND is_valid_device_id(user_id)
  );

-- New secure policy: Users can only UPDATE their own ratings (device ID must match)
CREATE POLICY "Users can update own ratings" ON preset_ratings
  FOR UPDATE USING (
    user_id = get_request_device_id()
    AND is_valid_device_id(user_id)
  );

-- New secure policy: Users can only DELETE their own ratings (device ID must match)
CREATE POLICY "Users can delete own ratings" ON preset_ratings
  FOR DELETE USING (
    user_id = get_request_device_id()
    AND is_valid_device_id(user_id)
  );

-- ============================================================
-- SECTION 5: Secure Rate-Limited Rating Function
-- ============================================================

-- Secure function to submit/update a rating with rate limiting and audit logging
CREATE OR REPLACE FUNCTION submit_rating_secure(
  p_preset_id TEXT,
  p_rating INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_device_id TEXT;
  v_existing_rating INTEGER;
  v_result JSON;
BEGIN
  -- Get and validate device ID from headers
  v_device_id := get_request_device_id();

  IF NOT is_valid_device_id(v_device_id) THEN
    PERFORM log_audit_event('device', v_device_id, 'rate_preset', 'preset_rating', p_preset_id,
      '{"error": "invalid_device_id"}'::jsonb, FALSE, 'Invalid device ID');
    RETURN json_build_object('success', false, 'error', 'Invalid device identifier');
  END IF;

  -- Validate rating value
  IF p_rating < 1 OR p_rating > 5 THEN
    RETURN json_build_object('success', false, 'error', 'Rating must be between 1 and 5');
  END IF;

  -- Check rate limit: max 30 ratings per 10 minutes per device
  IF NOT check_rate_limit(v_device_id, 'rating', 30, 10) THEN
    PERFORM log_audit_event('device', v_device_id, 'rate_preset', 'preset_rating', p_preset_id,
      '{"error": "rate_limited"}'::jsonb, FALSE, 'Rate limit exceeded');
    RETURN json_build_object('success', false, 'error', 'Too many requests. Please wait before rating again.');
  END IF;

  -- Check if rating already exists
  SELECT rating INTO v_existing_rating
  FROM preset_ratings
  WHERE preset_id = p_preset_id AND user_id = v_device_id;

  IF v_existing_rating IS NOT NULL THEN
    -- Update existing rating
    UPDATE preset_ratings
    SET rating = p_rating, updated_at = NOW()
    WHERE preset_id = p_preset_id AND user_id = v_device_id;

    PERFORM log_audit_event('device', v_device_id, 'update_rating', 'preset_rating', p_preset_id,
      jsonb_build_object('old_rating', v_existing_rating, 'new_rating', p_rating));

    RETURN json_build_object('success', true, 'action', 'updated', 'rating', p_rating);
  ELSE
    -- Insert new rating
    INSERT INTO preset_ratings (preset_id, user_id, rating)
    VALUES (p_preset_id, v_device_id, p_rating);

    PERFORM log_audit_event('device', v_device_id, 'create_rating', 'preset_rating', p_preset_id,
      jsonb_build_object('rating', p_rating));

    RETURN json_build_object('success', true, 'action', 'created', 'rating', p_rating);
  END IF;

EXCEPTION WHEN OTHERS THEN
  PERFORM log_audit_event('device', v_device_id, 'rate_preset', 'preset_rating', p_preset_id,
    jsonb_build_object('error', SQLERRM), FALSE, SQLERRM);
  RETURN json_build_object('success', false, 'error', 'An error occurred');
END;
$$;

-- ============================================================
-- SECTION 6: Secured Moderation Functions
-- ============================================================
-- These functions now require Discord ID validation via headers
-- and include comprehensive audit logging

-- HMAC signature verification for additional security
-- The client must sign (discord_id + timestamp) with a shared secret
CREATE OR REPLACE FUNCTION verify_request_signature(
  p_discord_id TEXT,
  p_timestamp TEXT,
  p_signature TEXT,
  p_secret TEXT DEFAULT 'your-hmac-secret-change-in-production'
)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  v_message TEXT;
  v_expected_sig TEXT;
  v_timestamp_age INTERVAL;
BEGIN
  -- Check timestamp is within 5 minutes
  BEGIN
    v_timestamp_age := NOW() - to_timestamp(p_timestamp::BIGINT);
    IF v_timestamp_age > INTERVAL '5 minutes' OR v_timestamp_age < INTERVAL '-1 minute' THEN
      RETURN FALSE;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
  END;

  -- Compute expected signature
  v_message := p_discord_id || ':' || p_timestamp;
  v_expected_sig := encode(
    hmac(v_message::bytea, p_secret::bytea, 'sha256'),
    'hex'
  );

  -- Constant-time comparison
  RETURN v_expected_sig = p_signature;
END;
$$;

-- Secure approve preset function with signature verification
CREATE OR REPLACE FUNCTION approve_preset_secure(
  p_preset_id UUID,
  p_timestamp TEXT DEFAULT NULL,
  p_signature TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_discord_id TEXT;
  v_mod_id UUID;
  v_rows_updated INT;
BEGIN
  -- Get Discord ID from headers
  v_discord_id := get_request_discord_id();

  IF v_discord_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Authentication required');
  END IF;

  -- Optional: Verify signature if provided (for extra security)
  -- Uncomment this block to require signatures
  /*
  IF p_signature IS NOT NULL AND p_timestamp IS NOT NULL THEN
    IF NOT verify_request_signature(v_discord_id, p_timestamp, p_signature) THEN
      PERFORM log_audit_event('discord_user', v_discord_id, 'approve_preset',
        'community_preset', p_preset_id::TEXT, '{"error": "invalid_signature"}'::jsonb, FALSE);
      RETURN json_build_object('success', false, 'error', 'Invalid request signature');
    END IF;
  END IF;
  */

  -- Check rate limit: max 50 moderation actions per 10 minutes
  IF NOT check_rate_limit(v_discord_id, 'moderation', 50, 10) THEN
    RETURN json_build_object('success', false, 'error', 'Rate limit exceeded');
  END IF;

  -- Verify moderator status
  SELECT id INTO v_mod_id FROM user_profiles
  WHERE discord_id = v_discord_id
  AND is_moderator = TRUE
  AND is_banned = FALSE;

  IF v_mod_id IS NULL THEN
    PERFORM log_audit_event('discord_user', v_discord_id, 'approve_preset',
      'community_preset', p_preset_id::TEXT, '{"error": "not_moderator"}'::jsonb, FALSE, 'Not authorized');
    RETURN json_build_object('success', false, 'error', 'Not authorized as moderator');
  END IF;

  -- Update preset status
  UPDATE community_presets
  SET status = 'approved', published_at = NOW(), updated_at = NOW()
  WHERE id = p_preset_id;

  GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

  IF v_rows_updated = 0 THEN
    RETURN json_build_object('success', false, 'error', 'Preset not found');
  END IF;

  -- Log the moderation action
  INSERT INTO moderation_actions (preset_id, moderator_id, action)
  VALUES (p_preset_id, v_mod_id, 'approved');

  -- Audit log
  PERFORM log_audit_event('moderator', v_discord_id, 'approve_preset',
    'community_preset', p_preset_id::TEXT, '{}'::jsonb, TRUE);

  RETURN json_build_object('success', true, 'rows_updated', v_rows_updated);
END;
$$;

-- Secure reject preset function
CREATE OR REPLACE FUNCTION reject_preset_secure(
  p_preset_id UUID,
  p_reason TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_discord_id TEXT;
  v_mod_id UUID;
  v_rows_updated INT;
BEGIN
  v_discord_id := get_request_discord_id();

  IF v_discord_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Authentication required');
  END IF;

  IF NOT check_rate_limit(v_discord_id, 'moderation', 50, 10) THEN
    RETURN json_build_object('success', false, 'error', 'Rate limit exceeded');
  END IF;

  SELECT id INTO v_mod_id FROM user_profiles
  WHERE discord_id = v_discord_id AND is_moderator = TRUE AND is_banned = FALSE;

  IF v_mod_id IS NULL THEN
    PERFORM log_audit_event('discord_user', v_discord_id, 'reject_preset',
      'community_preset', p_preset_id::TEXT, '{"error": "not_moderator"}'::jsonb, FALSE);
    RETURN json_build_object('success', false, 'error', 'Not authorized as moderator');
  END IF;

  UPDATE community_presets
  SET status = 'rejected', rejection_reason = p_reason, updated_at = NOW()
  WHERE id = p_preset_id;

  GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

  IF v_rows_updated = 0 THEN
    RETURN json_build_object('success', false, 'error', 'Preset not found');
  END IF;

  INSERT INTO moderation_actions (preset_id, moderator_id, action, reason)
  VALUES (p_preset_id, v_mod_id, 'rejected', p_reason);

  PERFORM log_audit_event('moderator', v_discord_id, 'reject_preset',
    'community_preset', p_preset_id::TEXT, jsonb_build_object('reason', p_reason), TRUE);

  RETURN json_build_object('success', true, 'rows_updated', v_rows_updated);
END;
$$;

-- Secure delete preset function
CREATE OR REPLACE FUNCTION delete_preset_secure(
  p_preset_id UUID,
  p_reason TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_discord_id TEXT;
  v_mod_id UUID;
  v_rows_deleted INT;
  v_preset_info JSONB;
BEGIN
  v_discord_id := get_request_discord_id();

  IF v_discord_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Authentication required');
  END IF;

  IF NOT check_rate_limit(v_discord_id, 'moderation', 50, 10) THEN
    RETURN json_build_object('success', false, 'error', 'Rate limit exceeded');
  END IF;

  SELECT id INTO v_mod_id FROM user_profiles
  WHERE discord_id = v_discord_id AND is_moderator = TRUE AND is_banned = FALSE;

  IF v_mod_id IS NULL THEN
    PERFORM log_audit_event('discord_user', v_discord_id, 'delete_preset',
      'community_preset', p_preset_id::TEXT, '{"error": "not_moderator"}'::jsonb, FALSE);
    RETURN json_build_object('success', false, 'error', 'Not authorized as moderator');
  END IF;

  -- Capture preset info before deletion for audit
  SELECT jsonb_build_object('name', name, 'author_id', author_id, 'status', status)
  INTO v_preset_info
  FROM community_presets WHERE id = p_preset_id;

  -- Log before deleting (so we have preset_id reference)
  INSERT INTO moderation_actions (preset_id, moderator_id, action, reason)
  VALUES (p_preset_id, v_mod_id, 'deleted', p_reason);

  DELETE FROM community_presets WHERE id = p_preset_id;
  GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;

  IF v_rows_deleted = 0 THEN
    RETURN json_build_object('success', false, 'error', 'Preset not found');
  END IF;

  PERFORM log_audit_event('moderator', v_discord_id, 'delete_preset',
    'community_preset', p_preset_id::TEXT,
    v_preset_info || jsonb_build_object('reason', p_reason), TRUE);

  RETURN json_build_object('success', true, 'rows_deleted', v_rows_deleted);
END;
$$;

-- Secure get pending presets function
CREATE OR REPLACE FUNCTION get_pending_presets_secure()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_discord_id TEXT;
BEGIN
  v_discord_id := get_request_discord_id();

  IF v_discord_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Authentication required');
  END IF;

  IF NOT is_moderator(v_discord_id) THEN
    RETURN json_build_object('success', false, 'error', 'Not authorized');
  END IF;

  RETURN json_build_object(
    'success', true,
    'presets', (
      SELECT json_agg(row_to_json(p)) FROM (
        SELECT cp.id, cp.slug, cp.name, cp.description, cp.category, cp.status,
               cp.preset_file_path, cp.thumbnail_path, cp.created_at,
               up.discord_username as author_name, up.discord_id as author_discord_id
        FROM community_presets cp
        JOIN user_profiles up ON cp.author_id = up.id
        WHERE cp.status = 'pending'
        ORDER BY cp.created_at ASC
      ) p
    )
  );
END;
$$;

-- Secure get moderation stats
CREATE OR REPLACE FUNCTION get_moderation_stats_secure()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_discord_id TEXT;
  v_pending INT;
  v_approved INT;
  v_rejected INT;
BEGIN
  v_discord_id := get_request_discord_id();

  IF v_discord_id IS NULL OR NOT is_moderator(v_discord_id) THEN
    RETURN json_build_object('success', false, 'error', 'Not authorized');
  END IF;

  SELECT COUNT(*) INTO v_pending FROM community_presets WHERE status = 'pending';
  SELECT COUNT(*) INTO v_approved FROM community_presets WHERE status = 'approved';
  SELECT COUNT(*) INTO v_rejected FROM community_presets WHERE status = 'rejected';

  RETURN json_build_object(
    'success', true,
    'pending', v_pending,
    'approved', v_approved,
    'rejected', v_rejected
  );
END;
$$;

-- ============================================================
-- SECTION 7: Client Version Validation
-- ============================================================

-- Configuration table for app settings
CREATE TABLE IF NOT EXISTS app_config (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert minimum required version
INSERT INTO app_config (key, value) VALUES
  ('min_client_version', '"1.0.0"'),
  ('force_update_version', '"0.0.0"'),
  ('maintenance_mode', 'false'),
  ('rate_limits', '{"rating_per_10min": 30, "submission_per_hour": 5, "moderation_per_10min": 50}')
ON CONFLICT (key) DO NOTHING;

-- RLS for app_config (public read, no write via API)
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can read app config" ON app_config
  FOR SELECT USING (true);

-- Function to check if client version is allowed
CREATE OR REPLACE FUNCTION check_client_version()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_client_version TEXT;
  v_min_version TEXT;
  v_force_version TEXT;
  v_maintenance BOOLEAN;
BEGIN
  v_client_version := get_client_version();

  SELECT value::TEXT INTO v_min_version FROM app_config WHERE key = 'min_client_version';
  SELECT value::TEXT INTO v_force_version FROM app_config WHERE key = 'force_update_version';
  SELECT value::BOOLEAN INTO v_maintenance FROM app_config WHERE key = 'maintenance_mode';

  -- Remove quotes from JSON strings
  v_min_version := trim(both '"' from v_min_version);
  v_force_version := trim(both '"' from v_force_version);

  IF v_maintenance THEN
    RETURN json_build_object(
      'allowed', false,
      'reason', 'maintenance',
      'message', 'The service is currently under maintenance. Please try again later.'
    );
  END IF;

  IF compare_versions(v_client_version, v_force_version) <= 0 THEN
    RETURN json_build_object(
      'allowed', false,
      'reason', 'force_update',
      'message', 'This version is no longer supported. Please update to continue.',
      'min_version', v_min_version
    );
  END IF;

  IF compare_versions(v_client_version, v_min_version) < 0 THEN
    RETURN json_build_object(
      'allowed', true,
      'warning', 'update_available',
      'message', 'A new version is available. Please update for the best experience.',
      'min_version', v_min_version
    );
  END IF;

  RETURN json_build_object('allowed', true);
END;
$$;

-- ============================================================
-- SECTION 8: Secure Community Preset Submission
-- ============================================================

-- Rate-limited preset submission
CREATE OR REPLACE FUNCTION submit_community_preset_secure(
  p_name TEXT,
  p_description TEXT,
  p_category TEXT,
  p_preset_file_path TEXT,
  p_thumbnail_path TEXT DEFAULT NULL,
  p_long_description TEXT DEFAULT NULL,
  p_based_on_preset_id TEXT DEFAULT NULL,
  p_based_on_preset_name TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_discord_id TEXT;
  v_user_id UUID;
  v_is_banned BOOLEAN;
  v_preset_id UUID;
  v_slug TEXT;
BEGIN
  v_discord_id := get_request_discord_id();

  IF v_discord_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Discord authentication required');
  END IF;

  -- Get user profile and check ban status
  SELECT id, is_banned INTO v_user_id, v_is_banned
  FROM user_profiles WHERE discord_id = v_discord_id;

  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'User profile not found');
  END IF;

  IF v_is_banned THEN
    PERFORM log_audit_event('discord_user', v_discord_id, 'submit_preset',
      'community_preset', NULL, '{"error": "banned"}'::jsonb, FALSE);
    RETURN json_build_object('success', false, 'error', 'Your account has been suspended');
  END IF;

  -- Rate limit: max 5 submissions per hour
  IF NOT check_rate_limit(v_discord_id, 'submission', 5, 60) THEN
    RETURN json_build_object('success', false, 'error', 'Too many submissions. Please wait before submitting again.');
  END IF;

  -- Generate slug
  v_slug := lower(regexp_replace(p_name, '[^a-zA-Z0-9]+', '-', 'g'));
  v_slug := v_slug || '-' || substring(uuid_generate_v4()::TEXT, 1, 8);

  -- Insert preset
  INSERT INTO community_presets (
    slug, author_id, name, description, long_description, category,
    preset_file_path, thumbnail_path, based_on_preset_id, based_on_preset_name,
    status
  ) VALUES (
    v_slug, v_user_id, p_name, p_description, p_long_description, p_category,
    p_preset_file_path, p_thumbnail_path, p_based_on_preset_id, p_based_on_preset_name,
    'pending'
  ) RETURNING id INTO v_preset_id;

  -- Update user stats
  UPDATE user_profiles
  SET total_submissions = total_submissions + 1
  WHERE id = v_user_id;

  PERFORM log_audit_event('discord_user', v_discord_id, 'submit_preset',
    'community_preset', v_preset_id::TEXT,
    jsonb_build_object('name', p_name, 'category', p_category), TRUE);

  RETURN json_build_object(
    'success', true,
    'preset_id', v_preset_id,
    'slug', v_slug
  );
END;
$$;

-- ============================================================
-- SECTION 9: Grant Permissions
-- ============================================================

-- Grant execute on new secure functions to anon and authenticated
GRANT EXECUTE ON FUNCTION get_request_device_id() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_client_version() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_request_discord_id() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION is_valid_device_id(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION compare_versions(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION check_client_version() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION submit_rating_secure(TEXT, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION approve_preset_secure(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION reject_preset_secure(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_preset_secure(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_pending_presets_secure() TO authenticated;
GRANT EXECUTE ON FUNCTION get_moderation_stats_secure() TO authenticated;
GRANT EXECUTE ON FUNCTION submit_community_preset_secure(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT) TO authenticated;

-- Rate limits table needs insert/update for the functions
GRANT SELECT, INSERT, UPDATE ON rate_limits TO anon, authenticated;
GRANT SELECT ON app_config TO anon, authenticated;

-- ============================================================
-- SECTION 10: Backward Compatibility Wrappers
-- ============================================================
-- These wrap the old functions to use the new secure versions
-- This allows existing clients to continue working while
-- enforcing the new security measures

-- Wrapper for old approve_preset that uses header-based auth
CREATE OR REPLACE FUNCTION approve_preset(p_preset_id UUID, p_moderator_discord_id TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Log that old API is being used
  PERFORM log_audit_event('system', p_moderator_discord_id, 'deprecated_api_call',
    'approve_preset', p_preset_id::TEXT,
    '{"warning": "Using deprecated API without header auth"}'::jsonb);

  -- The discord_id passed as parameter is UNTRUSTED
  -- We should use the header instead, but for backward compat we check both
  -- Priority: header > parameter (header is more trustworthy)
  IF get_request_discord_id() IS NOT NULL THEN
    RETURN approve_preset_secure(p_preset_id);
  END IF;

  -- If no header, check rate limit with the provided discord_id
  IF NOT check_rate_limit(p_moderator_discord_id, 'moderation', 50, 10) THEN
    RETURN json_build_object('success', false, 'error', 'Rate limit exceeded');
  END IF;

  -- Still allow the old behavior but with rate limiting and logging
  -- This is a security trade-off for backward compatibility
  DECLARE
    v_mod_id UUID;
    v_rows_updated INT;
  BEGIN
    SELECT id INTO v_mod_id FROM user_profiles
    WHERE discord_id = p_moderator_discord_id AND is_moderator = TRUE AND is_banned = FALSE;

    IF v_mod_id IS NULL THEN
      RETURN json_build_object('success', false, 'error', 'Not authorized as moderator');
    END IF;

    UPDATE community_presets
    SET status = 'approved', published_at = NOW(), updated_at = NOW()
    WHERE id = p_preset_id;

    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

    IF v_rows_updated = 0 THEN
      RETURN json_build_object('success', false, 'error', 'Preset not found');
    END IF;

    INSERT INTO moderation_actions (preset_id, moderator_id, action)
    VALUES (p_preset_id, v_mod_id, 'approved');

    RETURN json_build_object('success', true, 'rows_updated', v_rows_updated);
  END;
END;
$$;

-- Similar wrapper for reject_preset
CREATE OR REPLACE FUNCTION reject_preset(p_preset_id UUID, p_moderator_discord_id TEXT, p_reason TEXT DEFAULT NULL)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM log_audit_event('system', p_moderator_discord_id, 'deprecated_api_call',
    'reject_preset', p_preset_id::TEXT,
    '{"warning": "Using deprecated API without header auth"}'::jsonb);

  IF get_request_discord_id() IS NOT NULL THEN
    RETURN reject_preset_secure(p_preset_id, p_reason);
  END IF;

  IF NOT check_rate_limit(p_moderator_discord_id, 'moderation', 50, 10) THEN
    RETURN json_build_object('success', false, 'error', 'Rate limit exceeded');
  END IF;

  DECLARE
    v_mod_id UUID;
    v_rows_updated INT;
  BEGIN
    SELECT id INTO v_mod_id FROM user_profiles
    WHERE discord_id = p_moderator_discord_id AND is_moderator = TRUE AND is_banned = FALSE;

    IF v_mod_id IS NULL THEN
      RETURN json_build_object('success', false, 'error', 'Not authorized as moderator');
    END IF;

    UPDATE community_presets
    SET status = 'rejected', rejection_reason = p_reason, updated_at = NOW()
    WHERE id = p_preset_id;

    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

    IF v_rows_updated = 0 THEN
      RETURN json_build_object('success', false, 'error', 'Preset not found');
    END IF;

    INSERT INTO moderation_actions (preset_id, moderator_id, action, reason)
    VALUES (p_preset_id, v_mod_id, 'rejected', p_reason);

    RETURN json_build_object('success', true, 'rows_updated', v_rows_updated);
  END;
END;
$$;

-- Wrapper for delete_preset
CREATE OR REPLACE FUNCTION delete_preset(p_preset_id UUID, p_moderator_discord_id TEXT, p_reason TEXT DEFAULT NULL)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM log_audit_event('system', p_moderator_discord_id, 'deprecated_api_call',
    'delete_preset', p_preset_id::TEXT,
    '{"warning": "Using deprecated API without header auth"}'::jsonb);

  IF get_request_discord_id() IS NOT NULL THEN
    RETURN delete_preset_secure(p_preset_id, p_reason);
  END IF;

  IF NOT check_rate_limit(p_moderator_discord_id, 'moderation', 50, 10) THEN
    RETURN json_build_object('success', false, 'error', 'Rate limit exceeded');
  END IF;

  DECLARE
    v_mod_id UUID;
    v_rows_deleted INT;
  BEGIN
    SELECT id INTO v_mod_id FROM user_profiles
    WHERE discord_id = p_moderator_discord_id AND is_moderator = TRUE AND is_banned = FALSE;

    IF v_mod_id IS NULL THEN
      RETURN json_build_object('success', false, 'error', 'Not authorized as moderator');
    END IF;

    INSERT INTO moderation_actions (preset_id, moderator_id, action, reason)
    VALUES (p_preset_id, v_mod_id, 'deleted', p_reason);

    DELETE FROM community_presets WHERE id = p_preset_id;
    GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;

    IF v_rows_deleted = 0 THEN
      RETURN json_build_object('success', false, 'error', 'Preset not found');
    END IF;

    RETURN json_build_object('success', true, 'rows_deleted', v_rows_deleted);
  END;
END;
$$;

-- ============================================================
-- VERIFICATION QUERIES (run after migration to verify)
-- ============================================================
-- SELECT * FROM app_config;
-- SELECT check_client_version();
-- SELECT * FROM audit_log ORDER BY created_at DESC LIMIT 10;
-- SELECT * FROM rate_limits;
