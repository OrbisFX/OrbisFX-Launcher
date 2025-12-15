-- Migration 007: Security Fixes
-- This migration addresses security vulnerabilities identified in the audit:
-- 1. Fix Discord ID spoofing - use header auth exclusively
-- 2. Fix TOCTOU race condition with SELECT FOR UPDATE
-- 3. Fix rate limit race condition with atomic operation
-- 4. Add input validation (length, category, version comparison)
-- 5. Fix COALESCE empty string bug with NULLIF
-- 6. Check rows_updated for success

-- ============================================================
-- SECTION 1: Fix Rate Limit Race Condition
-- ============================================================

-- Replace check_rate_limit with atomic version
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

  -- ATOMIC: Insert or increment in single operation, return the new count
  INSERT INTO rate_limits (identifier, action_type, window_start, request_count)
  VALUES (p_identifier, p_action_type, v_window_start, 1)
  ON CONFLICT (identifier, action_type, window_start)
  DO UPDATE SET request_count = rate_limits.request_count + 1
  RETURNING request_count INTO v_current_count;

  -- Check if we're within the limit (count includes this request)
  RETURN v_current_count <= p_max_requests;
END;
$$;

-- ============================================================
-- SECTION 2: Fix get_my_uploads - Use Header Auth
-- ============================================================

-- Drop old function signature and create new one that uses header auth
DROP FUNCTION IF EXISTS get_my_uploads(TEXT);

CREATE OR REPLACE FUNCTION get_my_uploads()
RETURNS JSON AS $$
DECLARE
  v_discord_id TEXT;
  v_user_id UUID;
  v_base_url TEXT := 'https://xvnfgmgfthniadpwrxjw.supabase.co';
BEGIN
  -- Get Discord ID from header (set after OAuth)
  v_discord_id := get_request_discord_id();

  IF v_discord_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Authentication required');
  END IF;

  -- Get user profile ID
  SELECT id INTO v_user_id FROM user_profiles WHERE discord_id = v_discord_id;

  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'User not found');
  END IF;

  RETURN json_build_object(
    'success', true,
    'presets', (
      SELECT COALESCE(json_agg(
        json_build_object(
          'id', cp.id,
          'slug', cp.slug,
          'name', cp.name,
          'description', cp.description,
          'long_description', cp.long_description,
          'category', cp.category,
          'status', cp.status,
          'version', cp.version,
          'changelog', cp.changelog,
          'thumbnail_url', CASE
            WHEN cp.thumbnail_path IS NOT NULL THEN
              v_base_url || '/storage/v1/object/public/community-images/' || cp.thumbnail_path
            ELSE NULL
          END,
          'preset_file_url', v_base_url || '/storage/v1/object/public/community-presets/' || cp.preset_file_path,
          'rejection_reason', cp.rejection_reason,
          'download_count', cp.download_count,
          'created_at', cp.created_at,
          'updated_at', cp.updated_at,
          'published_at', cp.published_at,
          'images', (
            SELECT COALESCE(json_agg(
              json_build_object(
                'id', cpi.id,
                'image_type', cpi.image_type,
                'pair_index', cpi.pair_index,
                'full_image_url', v_base_url || '/storage/v1/object/public/community-images/' || cpi.full_image_path,
                'thumbnail_url', CASE
                  WHEN cpi.thumbnail_path IS NOT NULL THEN
                    v_base_url || '/storage/v1/object/public/community-images/' || cpi.thumbnail_path
                  ELSE NULL
                END
              )
              ORDER BY cpi.pair_index NULLS LAST, cpi.created_at
            ), '[]'::json)
            FROM community_preset_images cpi
            WHERE cpi.preset_id = cp.id
          )
        )
        ORDER BY cp.created_at DESC
      ), '[]'::json)
      FROM community_presets cp
      WHERE cp.author_id = v_user_id
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute
GRANT EXECUTE ON FUNCTION get_my_uploads() TO anon, authenticated;

-- ============================================================
-- SECTION 3: Fix delete_my_preset - Use Header Auth
-- ============================================================

-- Drop old function signature and create new one
DROP FUNCTION IF EXISTS delete_my_preset(UUID, TEXT);

CREATE OR REPLACE FUNCTION delete_my_preset(p_preset_id UUID)
RETURNS JSON AS $$
DECLARE
  v_discord_id TEXT;
  v_user_id UUID;
  v_rows_deleted INT;
BEGIN
  -- Get Discord ID from header
  v_discord_id := get_request_discord_id();

  IF v_discord_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Authentication required');
  END IF;

  -- Get user profile ID
  SELECT id INTO v_user_id FROM user_profiles WHERE discord_id = v_discord_id;

  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'User not found');
  END IF;

  -- Delete only if the user owns the preset
  DELETE FROM community_presets
  WHERE id = p_preset_id AND author_id = v_user_id;

  GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;

  IF v_rows_deleted = 0 THEN
    RETURN json_build_object('success', false, 'error', 'Preset not found or you do not own it');
  END IF;

  RETURN json_build_object('success', true, 'rows_deleted', v_rows_deleted);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute
GRANT EXECUTE ON FUNCTION delete_my_preset(UUID) TO anon, authenticated;

-- ============================================================
-- SECTION 4: Fix update_my_preset - Header Auth, TOCTOU, Validation
-- ============================================================

-- Valid categories constant (for validation)
-- Note: Validated in Rust as well, this is defense in depth

-- Drop old function signatures
DROP FUNCTION IF EXISTS update_my_preset(UUID, TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS update_my_preset(UUID, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION update_my_preset(
  p_preset_id UUID,
  p_name TEXT DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_long_description TEXT DEFAULT NULL,
  p_category TEXT DEFAULT NULL,
  p_version TEXT DEFAULT NULL,
  p_changelog TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  v_discord_id TEXT;
  v_user_id UUID;
  v_old_status TEXT;
  v_old_version TEXT;
  v_rows_updated INT;
  v_valid_categories TEXT[] := ARRAY['Realistic', 'Vibrant', 'Cinematic', 'Fantasy', 'Minimal', 'Vintage', 'Other'];
BEGIN
  -- Get Discord ID from header (SECURITY: no client-supplied discord_id parameter)
  v_discord_id := get_request_discord_id();

  IF v_discord_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Authentication required');
  END IF;

  -- Get user profile ID
  SELECT id INTO v_user_id FROM user_profiles WHERE discord_id = v_discord_id;

  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'User not found');
  END IF;

  -- ===== INPUT VALIDATION =====

  -- Validate name length
  IF p_name IS NOT NULL AND LENGTH(p_name) > 255 THEN
    RETURN json_build_object('success', false, 'error', 'Name must be 255 characters or less');
  END IF;

  -- Validate description length
  IF p_description IS NOT NULL AND LENGTH(p_description) > 2000 THEN
    RETURN json_build_object('success', false, 'error', 'Description must be 2000 characters or less');
  END IF;

  -- Validate long_description length
  IF p_long_description IS NOT NULL AND LENGTH(p_long_description) > 10000 THEN
    RETURN json_build_object('success', false, 'error', 'Long description must be 10000 characters or less');
  END IF;

  -- Validate category
  IF p_category IS NOT NULL AND NOT p_category = ANY(v_valid_categories) THEN
    RETURN json_build_object('success', false, 'error', 'Invalid category');
  END IF;

  -- Validate version format
  IF p_version IS NOT NULL AND p_version !~ '^[0-9]+\.[0-9]+\.[0-9]+$' THEN
    RETURN json_build_object('success', false, 'error', 'Invalid version format. Use semantic versioning (e.g., 1.0.0)');
  END IF;

  -- Validate version parts are reasonable (prevent overflow)
  IF p_version IS NOT NULL THEN
    DECLARE
      v_parts TEXT[];
    BEGIN
      v_parts := regexp_split_to_array(p_version, '\.');
      IF v_parts[1]::INTEGER > 9999 OR v_parts[2]::INTEGER > 9999 OR v_parts[3]::INTEGER > 9999 THEN
        RETURN json_build_object('success', false, 'error', 'Version numbers must be less than 10000');
      END IF;
    END;
  END IF;

  -- Validate changelog length
  IF p_changelog IS NOT NULL AND LENGTH(p_changelog) > 5000 THEN
    RETURN json_build_object('success', false, 'error', 'Changelog must be 5000 characters or less');
  END IF;

  -- ===== FIX TOCTOU: Use SELECT FOR UPDATE to lock the row =====
  SELECT status, COALESCE(version, '1.0.0') INTO v_old_status, v_old_version
  FROM community_presets
  WHERE id = p_preset_id AND author_id = v_user_id
  FOR UPDATE;

  IF v_old_status IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Preset not found or you do not own it');
  END IF;

  -- ===== Validate version is increasing (prevent downgrade) =====
  IF p_version IS NOT NULL AND compare_versions(p_version, v_old_version) <= 0 THEN
    RETURN json_build_object('success', false, 'error',
      'New version must be greater than current version ' || v_old_version);
  END IF;

  -- ===== Update with NULLIF to handle empty strings =====
  UPDATE community_presets
  SET
    name = COALESCE(NULLIF(TRIM(p_name), ''), name),
    description = COALESCE(NULLIF(TRIM(p_description), ''), description),
    long_description = COALESCE(NULLIF(TRIM(p_long_description), ''), long_description),
    category = COALESCE(p_category, category),
    version = COALESCE(p_version, version),
    changelog = COALESCE(NULLIF(TRIM(p_changelog), ''), changelog),
    status = 'pending',
    rejection_reason = NULL,
    updated_at = NOW()
  WHERE id = p_preset_id AND author_id = v_user_id;

  GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

  -- ===== Check rows_updated for success =====
  IF v_rows_updated = 0 THEN
    RETURN json_build_object('success', false, 'error', 'Update failed - preset may have been modified');
  END IF;

  RETURN json_build_object(
    'success', true,
    'rows_updated', v_rows_updated,
    'was_approved', v_old_status = 'approved',
    'old_version', v_old_version,
    'new_version', COALESCE(p_version, v_old_version)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute
GRANT EXECUTE ON FUNCTION update_my_preset(UUID, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT) TO anon, authenticated;

-- ============================================================
-- SECTION 5: Add audit log cleanup job (scheduled via pg_cron)
-- ============================================================

-- Function to clean up old audit logs (call via pg_cron)
CREATE OR REPLACE FUNCTION cleanup_old_audit_logs(p_retention_days INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
  v_deleted INTEGER;
BEGIN
  DELETE FROM audit_log
  WHERE created_at < NOW() - (p_retention_days || ' days')::INTERVAL;

  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  RETURN v_deleted;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- SECTION 6: Add foreign key constraint for orphan prevention
-- ============================================================

-- Ensure presets are deleted when author is deleted (prevent orphans)
DO $$
BEGIN
  -- Drop existing constraint if it exists
  ALTER TABLE community_presets DROP CONSTRAINT IF EXISTS community_presets_author_id_fkey;

  -- Add constraint with CASCADE delete
  ALTER TABLE community_presets
    ADD CONSTRAINT community_presets_author_id_fkey
    FOREIGN KEY (author_id) REFERENCES user_profiles(id) ON DELETE CASCADE;
EXCEPTION
  WHEN undefined_table THEN
    RAISE NOTICE 'Table does not exist yet, skipping constraint';
END $$;
