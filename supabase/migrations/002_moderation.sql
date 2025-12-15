-- OrbisFX Moderation System
-- Run this in Supabase SQL Editor AFTER 001_community_presets.sql

-- Function to check if a user is a moderator (by Discord ID)
CREATE OR REPLACE FUNCTION is_moderator(discord_user_id TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_profiles 
    WHERE discord_id = discord_user_id 
    AND is_moderator = TRUE 
    AND is_banned = FALSE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RLS Policies for moderators
DROP POLICY IF EXISTS "Moderators can view all presets" ON community_presets;
DROP POLICY IF EXISTS "Moderators can update preset status" ON community_presets;
DROP POLICY IF EXISTS "Moderators can view all preset images" ON community_preset_images;

CREATE POLICY "Moderators can view all presets" ON community_presets
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM user_profiles WHERE discord_id = current_setting('app.discord_id', true) AND is_moderator = TRUE)
  );

CREATE POLICY "Moderators can update preset status" ON community_presets
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM user_profiles WHERE discord_id = current_setting('app.discord_id', true) AND is_moderator = TRUE)
  );

CREATE POLICY "Moderators can view all preset images" ON community_preset_images
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM user_profiles WHERE discord_id = current_setting('app.discord_id', true) AND is_moderator = TRUE)
  );

-- Authors can view images from their own presets
CREATE POLICY "Authors can view images from own presets" ON community_preset_images
  FOR SELECT USING (
    preset_id IN (
      SELECT id FROM community_presets WHERE author_id IN (
        SELECT id FROM user_profiles WHERE discord_id = current_setting('app.discord_id', true)
      )
    )
  );

-- Moderation Actions Table for audit trail
CREATE TABLE IF NOT EXISTS moderation_actions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  preset_id UUID REFERENCES community_presets(id) ON DELETE SET NULL,
  moderator_id UUID REFERENCES user_profiles(id) NOT NULL,
  action VARCHAR(50) NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_moderation_actions_preset ON moderation_actions(preset_id);
ALTER TABLE moderation_actions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Moderators can view moderation actions" ON moderation_actions;
DROP POLICY IF EXISTS "Moderators can create moderation actions" ON moderation_actions;

CREATE POLICY "Moderators can view moderation actions" ON moderation_actions
  FOR SELECT USING (EXISTS (SELECT 1 FROM user_profiles WHERE discord_id = current_setting('app.discord_id', true) AND is_moderator = TRUE));

CREATE POLICY "Moderators can create moderation actions" ON moderation_actions
  FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM user_profiles WHERE discord_id = current_setting('app.discord_id', true) AND is_moderator = TRUE));

-- Secure function to approve a preset
CREATE OR REPLACE FUNCTION approve_preset(p_preset_id UUID, p_moderator_discord_id TEXT)
RETURNS JSON AS $$
DECLARE
  v_mod_id UUID;
  v_rows_updated INT;
BEGIN
  -- Check moderator status
  SELECT id INTO v_mod_id FROM user_profiles
  WHERE discord_id = p_moderator_discord_id
  AND is_moderator = TRUE
  AND is_banned = FALSE;

  IF v_mod_id IS NULL THEN
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

  -- Log the action
  INSERT INTO moderation_actions (preset_id, moderator_id, action)
  VALUES (p_preset_id, v_mod_id, 'approved');

  RETURN json_build_object('success', true, 'rows_updated', v_rows_updated);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Secure function to reject a preset
CREATE OR REPLACE FUNCTION reject_preset(p_preset_id UUID, p_moderator_discord_id TEXT, p_reason TEXT DEFAULT NULL)
RETURNS JSON AS $$
DECLARE
  v_mod_id UUID;
  v_rows_updated INT;
BEGIN
  -- Check moderator status
  SELECT id INTO v_mod_id FROM user_profiles
  WHERE discord_id = p_moderator_discord_id
  AND is_moderator = TRUE
  AND is_banned = FALSE;

  IF v_mod_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Not authorized as moderator');
  END IF;

  -- Update preset status
  UPDATE community_presets
  SET status = 'rejected', rejection_reason = p_reason, updated_at = NOW()
  WHERE id = p_preset_id;

  GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

  IF v_rows_updated = 0 THEN
    RETURN json_build_object('success', false, 'error', 'Preset not found');
  END IF;

  -- Log the action
  INSERT INTO moderation_actions (preset_id, moderator_id, action, reason)
  VALUES (p_preset_id, v_mod_id, 'rejected', p_reason);

  RETURN json_build_object('success', true, 'rows_updated', v_rows_updated);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get moderation statistics
CREATE OR REPLACE FUNCTION get_moderation_stats(p_moderator_discord_id TEXT)
RETURNS JSON AS $$
DECLARE v_pending INT; v_approved INT; v_rejected INT;
BEGIN
  IF NOT is_moderator(p_moderator_discord_id) THEN RETURN json_build_object('success', false, 'error', 'Not authorized'); END IF;
  SELECT COUNT(*) INTO v_pending FROM community_presets WHERE status = 'pending';
  SELECT COUNT(*) INTO v_approved FROM community_presets WHERE status = 'approved';
  SELECT COUNT(*) INTO v_rejected FROM community_presets WHERE status = 'rejected';
  RETURN json_build_object('success', true, 'pending', v_pending, 'approved', v_approved, 'rejected', v_rejected);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get pending presets for moderation
CREATE OR REPLACE FUNCTION get_pending_presets(p_moderator_discord_id TEXT)
RETURNS JSON AS $$
BEGIN
  IF NOT is_moderator(p_moderator_discord_id) THEN 
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get a single preset with full details for moderation
CREATE OR REPLACE FUNCTION get_preset_for_moderation(p_preset_id UUID, p_moderator_discord_id TEXT)
RETURNS JSON AS $$
DECLARE
  v_preset_data JSON;
BEGIN
  IF NOT is_moderator(p_moderator_discord_id) THEN
    RETURN json_build_object('success', false, 'error', 'Not authorized');
  END IF;

  -- Build the preset data with images
  SELECT json_build_object(
    'id', cp.id,
    'slug', cp.slug,
    'name', cp.name,
    'description', cp.description,
    'long_description', cp.long_description,
    'category', cp.category,
    'version', cp.version,
    'status', cp.status,
    'preset_file_path', cp.preset_file_path,
    'preset_file_hash', cp.preset_file_hash,
    'thumbnail_path', cp.thumbnail_path,
    'created_at', cp.created_at,
    'updated_at', cp.updated_at,
    'based_on_preset_name', cp.based_on_preset_name,
    'rejection_reason', cp.rejection_reason,
    'author_name', up.discord_username,
    'author_discord_id', up.discord_id,
    'author_avatar', up.discord_avatar_hash,
    'images', COALESCE((
      SELECT json_agg(
        json_build_object(
          'id', img.id,
          'image_type', img.image_type,
          'pair_index', img.pair_index,
          'full_image_path', img.full_image_path,
          'thumbnail_path', img.thumbnail_path,
          'display_order', COALESCE(img.display_order, 0)
        ) ORDER BY COALESCE(img.display_order, 0) ASC, img.pair_index ASC NULLS LAST
      )
      FROM community_preset_images img
      WHERE img.preset_id = cp.id
    ), '[]'::json)
  ) INTO v_preset_data
  FROM community_presets cp
  JOIN user_profiles up ON cp.author_id = up.id
  WHERE cp.id = p_preset_id;

  IF v_preset_data IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Preset not found');
  END IF;

  RETURN json_build_object('success', true, 'preset', v_preset_data);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Function to delete a preset (moderator only)
CREATE OR REPLACE FUNCTION delete_preset(p_preset_id UUID, p_moderator_discord_id TEXT, p_reason TEXT DEFAULT NULL)
RETURNS JSON AS $$
DECLARE
  v_mod_id UUID;
  v_rows_deleted INT;
BEGIN
  -- Check moderator status
  SELECT id INTO v_mod_id FROM user_profiles
  WHERE discord_id = p_moderator_discord_id
  AND is_moderator = TRUE
  AND is_banned = FALSE;

  IF v_mod_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Not authorized as moderator');
  END IF;

  -- Log the action before deleting
  INSERT INTO moderation_actions (preset_id, moderator_id, action, reason)
  VALUES (p_preset_id, v_mod_id, 'deleted', p_reason);

  -- Delete the preset (cascade will handle images)
  DELETE FROM community_presets WHERE id = p_preset_id;

  GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;

  IF v_rows_deleted = 0 THEN
    RETURN json_build_object('success', false, 'error', 'Preset not found');
  END IF;

  RETURN json_build_object('success', true, 'rows_deleted', v_rows_deleted);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user's own uploaded presets
CREATE OR REPLACE FUNCTION get_my_uploads(p_discord_id TEXT)
RETURNS JSON AS $$
DECLARE
  v_user_id UUID;
  v_base_url TEXT := 'https://xvnfgmgfthniadpwrxjw.supabase.co';
BEGIN
  -- Get user profile ID
  SELECT id INTO v_user_id FROM user_profiles WHERE discord_id = p_discord_id;

  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'User not found');
  END IF;

  RETURN json_build_object(
    'success', true,
    'presets', (
      SELECT json_agg(
        json_build_object(
          'id', cp.id,
          'slug', cp.slug,
          'name', cp.name,
          'description', cp.description,
          'long_description', cp.long_description,
          'category', cp.category,
          'status', cp.status,
          'version', cp.version,
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
      )
      FROM community_presets cp
      WHERE cp.author_id = v_user_id
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function for a user to delete their own preset
CREATE OR REPLACE FUNCTION delete_my_preset(p_preset_id UUID, p_discord_id TEXT)
RETURNS JSON AS $$
DECLARE
  v_user_id UUID;
  v_rows_deleted INT;
BEGIN
  -- Get user profile ID
  SELECT id INTO v_user_id FROM user_profiles WHERE discord_id = p_discord_id;

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

-- Function for a user to update their own preset (puts it back to pending)
CREATE OR REPLACE FUNCTION update_my_preset(
  p_preset_id UUID,
  p_discord_id TEXT,
  p_name TEXT DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_long_description TEXT DEFAULT NULL,
  p_category TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  v_user_id UUID;
  v_old_status TEXT;
  v_rows_updated INT;
BEGIN
  -- Get user profile ID
  SELECT id INTO v_user_id FROM user_profiles WHERE discord_id = p_discord_id;

  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'User not found');
  END IF;

  -- Get current status
  SELECT status INTO v_old_status FROM community_presets
  WHERE id = p_preset_id AND author_id = v_user_id;

  IF v_old_status IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Preset not found or you do not own it');
  END IF;

  -- Update the preset fields that are provided
  UPDATE community_presets
  SET
    name = COALESCE(p_name, name),
    description = COALESCE(p_description, description),
    long_description = COALESCE(p_long_description, long_description),
    category = COALESCE(p_category, category),
    status = 'pending',
    rejection_reason = NULL,
    updated_at = NOW()
  WHERE id = p_preset_id AND author_id = v_user_id;

  GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

  RETURN json_build_object(
    'success', true,
    'rows_updated', v_rows_updated,
    'was_approved', v_old_status = 'approved'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============== Initial Moderator Setup ==============
-- To add yourself as a moderator, run:
-- UPDATE user_profiles SET is_moderator = TRUE WHERE discord_id = 'YOUR_DISCORD_USER_ID';

-- ============== Data Migration ==============
-- Standardize status values (convert old 'pending_review' to 'pending')
UPDATE community_presets SET status = 'pending' WHERE status = 'pending_review';

-- ============== DEBUG Function ==============
-- Function to check if images exist for a preset
CREATE OR REPLACE FUNCTION debug_preset_images(p_preset_id UUID)
RETURNS JSON AS $$
BEGIN
  RETURN json_build_object(
    'preset_id', p_preset_id,
    'image_count', (SELECT COUNT(*) FROM community_preset_images WHERE preset_id = p_preset_id),
    'images_sample', (
      SELECT json_agg(json_build_object(
        'id', img.id,
        'image_type', img.image_type,
        'full_image_path', img.full_image_path,
        'display_order', img.display_order
      ))
      FROM community_preset_images img
      WHERE preset_id = p_preset_id
      LIMIT 5
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

