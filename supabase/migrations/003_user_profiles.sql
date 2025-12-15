-- User profile viewing function
-- Returns user info, stats, and approved presets for a given Discord ID

CREATE OR REPLACE FUNCTION get_user_profile(p_discord_id TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSON;
    v_user_info JSON;
    v_stats JSON;
    v_presets JSON;
    v_user_id UUID;
    v_base_url TEXT := 'https://xvnfgmgfthniadpwrxjw.supabase.co';
BEGIN
    -- Get user UUID from discord_id
    SELECT id INTO v_user_id
    FROM user_profiles
    WHERE discord_id = p_discord_id;

    -- If user not found, return error
    IF v_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found'
        );
    END IF;

    -- Get user info from user_profiles table
    -- Map column names to expected frontend format
    SELECT json_build_object(
        'id', discord_id,
        'username', discord_username,
        'discriminator', COALESCE(discord_discriminator, '0'),
        'avatar_url', CASE
            WHEN discord_avatar_hash IS NOT NULL THEN
                'https://cdn.discordapp.com/avatars/' || discord_id || '/' || discord_avatar_hash || '.png'
            ELSE NULL
        END,
        'banner_url', NULL,
        'banner_color', NULL,
        'accent_color', NULL,
        'display_name', discord_username
    )
    INTO v_user_info
    FROM user_profiles
    WHERE id = v_user_id;

    -- Get user stats
    SELECT json_build_object(
        'total_uploads', COUNT(*),
        'approved_count', COUNT(*) FILTER (WHERE cp.status = 'approved'),
        'pending_count', COUNT(*) FILTER (WHERE cp.status = 'pending'),
        'rejected_count', COUNT(*) FILTER (WHERE cp.status = 'rejected'),
        'total_downloads', COALESCE(SUM(cp.download_count), 0)
    )
    INTO v_stats
    FROM community_presets cp
    WHERE cp.author_id = v_user_id;

    -- Get approved presets with images
    SELECT json_agg(
        json_build_object(
            'id', cp.id,
            'slug', cp.slug,
            'name', cp.name,
            'description', cp.description,
            'long_description', cp.long_description,
            'category', cp.category,
            'version', cp.version,
            'thumbnail_url', CASE
                WHEN cp.thumbnail_path IS NOT NULL THEN
                    v_base_url || '/storage/v1/object/public/community-images/' || cp.thumbnail_path
                ELSE (
                    SELECT v_base_url || '/storage/v1/object/public/community-images/' ||
                           COALESCE(cpi.thumbnail_path, cpi.full_image_path)
                    FROM community_preset_images cpi
                    WHERE cpi.preset_id = cp.id
                    ORDER BY cpi.created_at ASC
                    LIMIT 1
                )
            END,
            'preset_file_url', v_base_url || '/storage/v1/object/public/community-presets/' || cp.preset_file_path,
            'download_count', cp.download_count,
            'created_at', cp.created_at,
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
    INTO v_presets
    FROM community_presets cp
    WHERE cp.author_id = v_user_id
      AND cp.status = 'approved';

    -- Build final result
    v_result := json_build_object(
        'success', true,
        'user', v_user_info,
        'stats', v_stats,
        'presets', COALESCE(v_presets, '[]'::json)
    );

    RETURN v_result;
END;
$$;

