-- ============================================================
-- OrbisFX Launcher - User Profile Creation Fix
-- ============================================================
-- This migration fixes the RLS policy issue that prevents new user 
-- profiles from being created during Discord OAuth.
-- 
-- The issue: user_profiles has RLS enabled but no INSERT policy,
-- causing error 42501 when trying to create new profiles.
--
-- Solution: Create a SECURITY DEFINER function that bypasses RLS
-- to safely create/update user profiles with proper validation.
-- ============================================================

-- ============================================================
-- SECTION 1: Secure Profile Creation Function
-- ============================================================

-- Create or update user profile securely
-- This function runs with definer privileges to bypass RLS
-- while still validating input data
CREATE OR REPLACE FUNCTION get_or_create_user_profile(
  p_discord_id TEXT,
  p_discord_username TEXT,
  p_discord_avatar_hash TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_existing_profile RECORD;
  v_result JSON;
BEGIN
  -- Validate Discord ID format (snowflake: 17-19 digit number)
  IF p_discord_id IS NULL OR NOT (p_discord_id ~ '^[0-9]{17,19}$') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Invalid Discord ID format'
    );
  END IF;

  -- Validate username
  IF p_discord_username IS NULL OR LENGTH(p_discord_username) < 1 OR LENGTH(p_discord_username) > 255 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Invalid username'
    );
  END IF;

  -- Check for existing profile
  SELECT id, discord_username, discord_avatar_hash
  INTO v_existing_profile
  FROM user_profiles
  WHERE discord_id = p_discord_id;

  IF v_existing_profile.id IS NOT NULL THEN
    -- Update existing profile if username or avatar changed
    IF v_existing_profile.discord_username != p_discord_username 
       OR COALESCE(v_existing_profile.discord_avatar_hash, '') != COALESCE(p_discord_avatar_hash, '') THEN
      UPDATE user_profiles
      SET 
        discord_username = p_discord_username,
        discord_avatar_hash = p_discord_avatar_hash,
        updated_at = NOW()
      WHERE id = v_existing_profile.id;
    END IF;

    -- Return existing profile
    SELECT json_build_object(
      'success', true,
      'action', 'existing',
      'profile', json_build_object(
        'id', id,
        'discord_id', discord_id,
        'discord_username', discord_username,
        'discord_avatar_hash', discord_avatar_hash,
        'is_trusted', is_trusted,
        'total_submissions', total_submissions,
        'approved_submissions', approved_submissions
      )
    ) INTO v_result
    FROM user_profiles
    WHERE id = v_existing_profile.id;

    RETURN v_result;
  END IF;

  -- Create new profile
  INSERT INTO user_profiles (
    discord_id,
    discord_username,
    discord_avatar_hash
  ) VALUES (
    p_discord_id,
    p_discord_username,
    p_discord_avatar_hash
  )
  RETURNING id INTO v_user_id;

  -- Return new profile
  SELECT json_build_object(
    'success', true,
    'action', 'created',
    'profile', json_build_object(
      'id', id,
      'discord_id', discord_id,
      'discord_username', discord_username,
      'discord_avatar_hash', discord_avatar_hash,
      'is_trusted', is_trusted,
      'total_submissions', total_submissions,
      'approved_submissions', approved_submissions
    )
  ) INTO v_result
  FROM user_profiles
  WHERE id = v_user_id;

  RETURN v_result;

EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', 'Failed to create profile: ' || SQLERRM
  );
END;
$$;

-- ============================================================
-- SECTION 2: Grant Permissions
-- ============================================================

-- Allow anon and authenticated users to call this function
GRANT EXECUTE ON FUNCTION get_or_create_user_profile(TEXT, TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION get_or_create_user_profile(TEXT, TEXT, TEXT) TO authenticated;

-- ============================================================
-- SECTION 3: Add RLS Policy for Profile Reads
-- ============================================================

-- Allow public to read all user profiles
-- Profile info (username, avatar) is not sensitive and needed for displaying
-- preset author information. Using a simple policy avoids circular dependency
-- with community_presets policies that reference user_profiles.
DROP POLICY IF EXISTS "Users can read own profile" ON user_profiles;
DROP POLICY IF EXISTS "Public can read author profiles" ON user_profiles;
DROP POLICY IF EXISTS "Public can read profiles" ON user_profiles;

CREATE POLICY "Public can read profiles" ON user_profiles
  FOR SELECT USING (true);

