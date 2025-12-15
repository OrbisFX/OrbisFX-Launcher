-- Migration: Add version and changelog support to update_my_preset
-- This migration updates the update_my_preset function to handle version updates

-- Drop and recreate the function with version/changelog parameters
CREATE OR REPLACE FUNCTION update_my_preset(
  p_preset_id UUID,
  p_discord_id TEXT,
  p_name TEXT DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_long_description TEXT DEFAULT NULL,
  p_category TEXT DEFAULT NULL,
  p_version TEXT DEFAULT NULL,
  p_changelog TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  v_user_id UUID;
  v_old_status TEXT;
  v_old_version TEXT;
  v_rows_updated INT;
BEGIN
  -- Get user profile ID
  SELECT id INTO v_user_id FROM user_profiles WHERE discord_id = p_discord_id;

  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'User not found');
  END IF;

  -- Get current status and version
  SELECT status, version INTO v_old_status, v_old_version 
  FROM community_presets
  WHERE id = p_preset_id AND author_id = v_user_id;

  IF v_old_status IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Preset not found or you do not own it');
  END IF;

  -- Validate version format if provided (basic semantic version check)
  IF p_version IS NOT NULL AND p_version !~ '^[0-9]+\.[0-9]+\.[0-9]+$' THEN
    RETURN json_build_object('success', false, 'error', 'Invalid version format. Use semantic versioning (e.g., 1.0.0)');
  END IF;

  -- Update the preset fields that are provided
  UPDATE community_presets
  SET
    name = COALESCE(p_name, name),
    description = COALESCE(p_description, description),
    long_description = COALESCE(p_long_description, long_description),
    category = COALESCE(p_category, category),
    version = COALESCE(p_version, version),
    changelog = COALESCE(p_changelog, changelog),
    status = 'pending',
    rejection_reason = NULL,
    updated_at = NOW()
  WHERE id = p_preset_id AND author_id = v_user_id;

  GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

  RETURN json_build_object(
    'success', true,
    'rows_updated', v_rows_updated,
    'was_approved', v_old_status = 'approved',
    'old_version', v_old_version,
    'new_version', COALESCE(p_version, v_old_version)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add changelog column to community_presets if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'community_presets' AND column_name = 'changelog'
  ) THEN
    ALTER TABLE community_presets ADD COLUMN changelog TEXT;
  END IF;
END $$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION update_my_preset(UUID, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT) TO anon, authenticated;

