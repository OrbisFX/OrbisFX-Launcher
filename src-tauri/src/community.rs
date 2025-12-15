//! Community presets module
//!
//! Handles Supabase storage uploads and community preset operations.

use once_cell::sync::Lazy;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::sync::RwLock;

// Use shared Supabase config and security helpers
use crate::supabase::{CONFIG, secure_get, secure_post, add_security_headers};

static HTTP_CLIENT: Lazy<Client> = Lazy::new(Client::new);

// Cache for user's Supabase profile ID
static USER_PROFILE_ID: Lazy<RwLock<Option<String>>> = Lazy::new(|| RwLock::new(None));

// ============== Data Models ==============

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommunityPreset {
    pub id: String,
    pub slug: String,
    pub name: String,
    pub description: String,
    pub long_description: Option<String>,
    pub category: String,
    pub version: String,
    pub author_name: String,
    pub author_discord_id: String,
    pub author_avatar: Option<String>,
    pub thumbnail_url: Option<String>,
    pub preset_file_url: String,
    pub download_count: i32,
    pub status: String,
    pub created_at: String,
    pub images: Vec<CommunityPresetImage>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommunityPresetImage {
    pub id: String,
    pub image_type: String,
    pub pair_index: Option<i32>,
    pub full_image_url: String,
    pub thumbnail_url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserProfile {
    pub id: String,
    pub discord_id: String,
    pub discord_username: String,
    pub discord_avatar_hash: Option<String>,
    pub is_trusted: bool,
    pub total_submissions: i32,
    pub approved_submissions: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UploadResult {
    pub path: String,
    pub public_url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubmissionRequest {
    pub name: String,
    pub description: String,
    pub long_description: Option<String>,
    pub category: String,
    pub based_on_preset_name: Option<String>,
    pub preset_file_path: String,
    pub images: Vec<SubmissionImage>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubmissionImage {
    pub local_path: String,
    pub image_type: String,  // "before", "after", "showcase"
    pub pair_index: Option<i32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubmissionResult {
    pub success: bool,
    pub preset_id: Option<String>,
    pub slug: Option<String>,
    pub message: String,
}

// ============== User Profile Operations ==============

/// Get or create user profile in Supabase using secure RPC function
/// This uses a SECURITY DEFINER function on the server to bypass RLS
/// while still validating input data securely.
pub async fn get_or_create_profile(
    discord_id: &str,
    discord_username: &str,
    discord_avatar: Option<&str>,
) -> Result<UserProfile, String> {
    // Use the secure RPC function to create/get profile
    // This bypasses RLS safely on the server side
    let url = format!("{}/rest/v1/rpc/get_or_create_user_profile", CONFIG.url);

    let body = serde_json::json!({
        "p_discord_id": discord_id,
        "p_discord_username": discord_username,
        "p_discord_avatar_hash": discord_avatar,
    });

    let response = secure_post(&url)
        .json(&body)
        .send()
        .await
        .map_err(|e| format!("Network error: {}", e))?;

    if !response.status().is_success() {
        let status = response.status();
        let text = response.text().await.unwrap_or_default();
        return Err(format!("API error {}: {}", status, text));
    }

    let result: serde_json::Value = response.json().await
        .map_err(|e| format!("Parse error: {}", e))?;

    // Check if the RPC function returned success
    if !result.get("success").and_then(|v| v.as_bool()).unwrap_or(false) {
        let error = result.get("error").and_then(|v| v.as_str()).unwrap_or("Unknown error");
        return Err(format!("Failed to create profile: {}", error));
    }

    // Extract the profile from the response
    let profile_json = result.get("profile")
        .ok_or_else(|| "No profile in response".to_string())?;

    let profile = UserProfile {
        id: profile_json.get("id")
            .and_then(|v| v.as_str())
            .ok_or_else(|| "Missing profile id".to_string())?
            .to_string(),
        discord_id: profile_json.get("discord_id")
            .and_then(|v| v.as_str())
            .ok_or_else(|| "Missing discord_id".to_string())?
            .to_string(),
        discord_username: profile_json.get("discord_username")
            .and_then(|v| v.as_str())
            .ok_or_else(|| "Missing discord_username".to_string())?
            .to_string(),
        discord_avatar_hash: profile_json.get("discord_avatar_hash")
            .and_then(|v| v.as_str())
            .map(|s| s.to_string()),
        is_trusted: profile_json.get("is_trusted")
            .and_then(|v| v.as_bool())
            .unwrap_or(false),
        total_submissions: profile_json.get("total_submissions")
            .and_then(|v| v.as_i64())
            .unwrap_or(0) as i32,
        approved_submissions: profile_json.get("approved_submissions")
            .and_then(|v| v.as_i64())
            .unwrap_or(0) as i32,
    };

    // Cache the profile ID
    if let Ok(mut guard) = USER_PROFILE_ID.write() {
        *guard = Some(profile.id.clone());
    }

    Ok(profile)
}

// ============== Storage Operations ==============

/// Upload a file to Supabase Storage
pub async fn upload_to_storage(
    bucket: &str,
    path: &str,
    data: Vec<u8>,
    content_type: &str,
) -> Result<UploadResult, String> {
    let url = format!(
        "{}/storage/v1/object/{}/{}",
        CONFIG.url, bucket, path
    );

    // Use add_security_headers for storage uploads (custom content-type needed)
    let response = add_security_headers(HTTP_CLIENT.post(&url))
        .header("Content-Type", content_type)
        .header("x-upsert", "true")
        .body(data)
        .send()
        .await
        .map_err(|e| format!("Upload failed: {}", e))?;

    if !response.status().is_success() {
        let text = response.text().await.unwrap_or_default();
        return Err(format!("Storage upload failed: {}", text));
    }

    let public_url = format!(
        "{}/storage/v1/object/public/{}/{}",
        CONFIG.url, bucket, path
    );

    Ok(UploadResult {
        path: path.to_string(),
        public_url,
    })
}

// ============== Community Preset Operations ==============

/// Fetch approved community presets
pub async fn fetch_community_presets(
    page: u32,
    per_page: u32,
    category: Option<&str>,
    search: Option<&str>,
) -> Result<Vec<CommunityPreset>, String> {
    let offset = (page.saturating_sub(1)) * per_page;

    let mut url = format!(
        "{}/rest/v1/community_presets?status=eq.approved&select=*,user_profiles(discord_id,discord_username,discord_avatar_hash),community_preset_images(*)&order=created_at.desc&limit={}&offset={}",
        CONFIG.url, per_page, offset
    );

    if let Some(cat) = category {
        if !cat.is_empty() && cat != "All" {
            url.push_str(&format!("&category=eq.{}", cat));
        }
    }

    if let Some(q) = search {
        if !q.is_empty() {
            url.push_str(&format!("&or=(name.ilike.*{}*,description.ilike.*{}*)", q, q));
        }
    }

    log::debug!("[Community] Fetching presets from: {}", url);

    let response = secure_get(&url)
        .send()
        .await
        .map_err(|e| format!("Network error: {}", e))?;

    log::debug!("[Community] Response status: {}", response.status());

    if !response.status().is_success() {
        let text = response.text().await.unwrap_or_default();
        log::warn!("[Community] Error response: {}", text);
        return Ok(vec![]);
    }

    // Parse the nested response
    let text = response.text().await.unwrap_or_default();
    // Note: Don't log raw response data in production (security)
    #[cfg(debug_assertions)]
    log::trace!("[Community] Raw response length: {} chars", text.len());

    let data: Vec<serde_json::Value> = serde_json::from_str(&text).unwrap_or_default();
    log::debug!("[Community] Parsed {} presets from response", data.len());

    let presets: Vec<CommunityPreset> = data.into_iter().filter_map(|v| {
        let preset_name = v.get("name").and_then(|n| n.as_str()).unwrap_or("unknown");
        log::trace!("[Community] Processing preset: {}", preset_name);

        let user = v.get("user_profiles");
        if user.is_none() || user.unwrap().is_null() {
            log::debug!("[Community] SKIP '{}': user_profiles is null", preset_name);
            return None;
        }
        let user = user.unwrap();

        // Images are optional - default to empty array if null
        let images_raw = v.get("community_preset_images")
            .and_then(|i| if i.is_null() { None } else { i.as_array() });

        let images: Vec<CommunityPresetImage> = images_raw.map(|arr| {
            arr.iter().filter_map(|img| {
                Some(CommunityPresetImage {
                    id: img.get("id")?.as_str()?.to_string(),
                    image_type: img.get("image_type")?.as_str()?.to_string(),
                    pair_index: img.get("pair_index").and_then(|v| v.as_i64()).map(|v| v as i32),
                    full_image_url: format!("{}/storage/v1/object/public/community-images/{}",
                        CONFIG.url, img.get("full_image_path")?.as_str()?),
                    thumbnail_url: img.get("thumbnail_path").and_then(|v| v.as_str()).map(|p|
                        format!("{}/storage/v1/object/public/community-images/{}", CONFIG.url, p)),
                })
            }).collect()
        }).unwrap_or_default();

        Some(CommunityPreset {
            id: v.get("id")?.as_str()?.to_string(),
            slug: v.get("slug")?.as_str()?.to_string(),
            name: v.get("name")?.as_str()?.to_string(),
            description: v.get("description")?.as_str()?.to_string(),
            long_description: v.get("long_description").and_then(|v| v.as_str()).map(|s| s.to_string()),
            category: v.get("category")?.as_str()?.to_string(),
            version: v.get("version").and_then(|v| v.as_str()).unwrap_or("1.0.0").to_string(),
            author_name: user.get("discord_username")?.as_str()?.to_string(),
            author_discord_id: user.get("discord_id")?.as_str()?.to_string(),
            author_avatar: user.get("discord_avatar_hash").and_then(|v| v.as_str()).map(|s| s.to_string()),
            thumbnail_url: v.get("thumbnail_path").and_then(|v| v.as_str()).map(|p|
                format!("{}/storage/v1/object/public/community-images/{}", CONFIG.url, p)),
            preset_file_url: format!("{}/storage/v1/object/public/community-presets/{}",
                CONFIG.url, v.get("preset_file_path")?.as_str()?),
            download_count: v.get("download_count").and_then(|v| v.as_i64()).unwrap_or(0) as i32,
            status: v.get("status")?.as_str()?.to_string(),
            created_at: v.get("created_at")?.as_str()?.to_string(),
            images,
        })
    }).collect();

    log::debug!("[Community] Successfully parsed {} presets", presets.len());

    Ok(presets)
}

/// Fetch trending community presets (sorted by download count)
pub async fn fetch_trending_presets(limit: u32) -> Result<Vec<CommunityPreset>, String> {
    let url = format!(
        "{}/rest/v1/community_presets?status=eq.approved&select=*,user_profiles(discord_id,discord_username,discord_avatar_hash),community_preset_images(*)&order=download_count.desc&limit={}",
        CONFIG.url, limit
    );

    log::debug!("[Community] Fetching trending presets from: {}", url);

    let response = secure_get(&url)
        .send()
        .await
        .map_err(|e| format!("Network error: {}", e))?;

    if !response.status().is_success() {
        let text = response.text().await.unwrap_or_default();
        log::warn!("[Community] Error fetching trending: {}", text);
        return Ok(vec![]);
    }

    let text = response.text().await.unwrap_or_default();
    let data: Vec<serde_json::Value> = serde_json::from_str(&text).unwrap_or_default();
    log::debug!("[Community] Parsed {} trending presets from response", data.len());

    let presets: Vec<CommunityPreset> = data.into_iter().filter_map(|v| {
        let preset_name = v.get("name").and_then(|n| n.as_str()).unwrap_or("unknown");

        let user = v.get("user_profiles");
        if user.is_none() || user.unwrap().is_null() {
            log::debug!("[Community] SKIP trending '{}': user_profiles is null", preset_name);
            return None;
        }
        let user = user.unwrap();

        // Images are optional - default to empty array if null
        let images_raw = v.get("community_preset_images")
            .and_then(|i| if i.is_null() { None } else { i.as_array() });

        let images: Vec<CommunityPresetImage> = images_raw.map(|arr| {
            arr.iter().filter_map(|img| {
                Some(CommunityPresetImage {
                    id: img.get("id")?.as_str()?.to_string(),
                    image_type: img.get("image_type")?.as_str()?.to_string(),
                    pair_index: img.get("pair_index").and_then(|v| v.as_i64()).map(|v| v as i32),
                    full_image_url: format!("{}/storage/v1/object/public/community-images/{}",
                        CONFIG.url, img.get("full_image_path")?.as_str()?),
                    thumbnail_url: img.get("thumbnail_path").and_then(|v| v.as_str()).map(|p|
                        format!("{}/storage/v1/object/public/community-images/{}", CONFIG.url, p)),
                })
            }).collect()
        }).unwrap_or_default();

        Some(CommunityPreset {
            id: v.get("id")?.as_str()?.to_string(),
            slug: v.get("slug")?.as_str()?.to_string(),
            name: v.get("name")?.as_str()?.to_string(),
            description: v.get("description")?.as_str()?.to_string(),
            long_description: v.get("long_description").and_then(|v| v.as_str()).map(|s| s.to_string()),
            category: v.get("category")?.as_str()?.to_string(),
            version: v.get("version").and_then(|v| v.as_str()).unwrap_or("1.0.0").to_string(),
            author_name: user.get("discord_username")?.as_str()?.to_string(),
            author_discord_id: user.get("discord_id")?.as_str()?.to_string(),
            author_avatar: user.get("discord_avatar_hash").and_then(|v| v.as_str()).map(|s| s.to_string()),
            thumbnail_url: v.get("thumbnail_path").and_then(|v| v.as_str()).map(|p|
                format!("{}/storage/v1/object/public/community-images/{}", CONFIG.url, p)),
            preset_file_url: format!("{}/storage/v1/object/public/community-presets/{}",
                CONFIG.url, v.get("preset_file_path")?.as_str()?),
            download_count: v.get("download_count").and_then(|v| v.as_i64()).unwrap_or(0) as i32,
            status: v.get("status")?.as_str()?.to_string(),
            created_at: v.get("created_at")?.as_str()?.to_string(),
            images,
        })
    }).collect();

    log::debug!("[Community] Successfully parsed {} trending presets", presets.len());
    Ok(presets)
}

/// Generate a URL-safe slug from a name
pub fn generate_slug(name: &str) -> String {
    let slug: String = name
        .to_lowercase()
        .chars()
        .map(|c| if c.is_alphanumeric() { c } else { '-' })
        .collect();

    // Remove consecutive dashes and trim
    let mut result = String::new();
    let mut last_was_dash = false;
    for c in slug.chars() {
        if c == '-' {
            if !last_was_dash && !result.is_empty() {
                result.push(c);
                last_was_dash = true;
            }
        } else {
            result.push(c);
            last_was_dash = false;
        }
    }

    // Add unique suffix
    let suffix = &uuid::Uuid::new_v4().to_string()[..8];
    format!("{}-{}", result.trim_end_matches('-'), suffix)
}

/// Submit a new community preset
pub async fn submit_preset(
    discord_id: &str,
    discord_username: &str,
    discord_avatar: Option<&str>,
    request: SubmissionRequest,
) -> Result<SubmissionResult, String> {
    // 1. Get or create user profile
    let profile = get_or_create_profile(discord_id, discord_username, discord_avatar).await?;

    // 2. Generate unique slug
    let slug = generate_slug(&request.name);

    // 3. Read and upload preset file
    let preset_data = std::fs::read(&request.preset_file_path)
        .map_err(|e| format!("Failed to read preset file: {}", e))?;

    let preset_path = format!("{}/{}.ini", profile.id, slug);
    let preset_upload = upload_to_storage(
        "community-presets",
        &preset_path,
        preset_data,
        "text/plain",
    ).await?;

    // 4. Upload images and collect paths
    let mut uploaded_images: Vec<(String, String, Option<i32>, String, Option<String>)> = vec![];

    for img in &request.images {
        // Read image
        let img_data = std::fs::read(&img.local_path)
            .map_err(|e| format!("Failed to read image: {}", e))?;

        // Use image compression - get both full and thumbnail
        let compression_result = crate::image_compress::compress_image_bytes(&img_data, None)
            .map_err(|e| format!("Failed to compress image: {}", e))?;

        let img_filename = std::path::Path::new(&img.local_path)
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or("image.jpg");

        let img_path = format!("{}/{}/{}", profile.id, slug, img_filename);
        let img_upload = upload_to_storage(
            "community-images",
            &img_path,
            compression_result.full_image,
            "image/jpeg",
        ).await?;

        // Upload thumbnail
        let thumb_path = format!("{}/{}/thumb_{}", profile.id, slug, img_filename);
        let thumbnail_path = match upload_to_storage(
            "community-images",
            &thumb_path,
            compression_result.thumbnail,
            "image/jpeg",
        ).await {
            Ok(upload) => Some(upload.path),
            Err(_) => None,
        };

        uploaded_images.push((
            uuid::Uuid::new_v4().to_string(),
            img.image_type.clone(),
            img.pair_index,
            img_upload.path,
            thumbnail_path,
        ));
    }

    // 5. Create preset record in database using secure RPC function
    // Use the first image's thumbnail as the preset thumbnail (or fall back to full image)
    let preset_thumbnail_path = uploaded_images.first()
        .and_then(|(_, _, _, full_path, thumb_path)| {
            // Prefer thumbnail, fall back to full image path
            thumb_path.clone().or_else(|| Some(full_path.clone()))
        });

    // Use the secure RPC function that handles auth via X-Discord-Id header
    let rpc_body = serde_json::json!({
        "p_name": request.name,
        "p_description": request.description,
        "p_category": request.category,
        "p_preset_file_path": preset_upload.path,
        "p_thumbnail_path": preset_thumbnail_path,
        "p_long_description": request.long_description,
        "p_based_on_preset_id": serde_json::Value::Null,
        "p_based_on_preset_name": request.based_on_preset_name,
    });

    let url = format!("{}/rest/v1/rpc/submit_community_preset_secure", CONFIG.url);
    let response = secure_post(&url)
        .json(&rpc_body)
        .send()
        .await
        .map_err(|e| format!("Failed to create preset: {}", e))?;

    if !response.status().is_success() {
        let text = response.text().await.unwrap_or_default();
        return Err(format!("Failed to submit preset: {}", text));
    }

    let result: serde_json::Value = response.json().await
        .map_err(|e| format!("Parse error: {}", e))?;

    // Check if the RPC function returned success
    let success = result.get("success").and_then(|v| v.as_bool()).unwrap_or(false);
    if !success {
        let error = result.get("error").and_then(|v| v.as_str()).unwrap_or("Unknown error");
        return Err(format!("Submission failed: {}", error));
    }

    let preset_id = result.get("preset_id")
        .and_then(|id| id.as_str())
        .ok_or_else(|| "No preset ID returned".to_string())?
        .to_string();

    let slug = result.get("slug")
        .and_then(|s| s.as_str())
        .unwrap_or(&slug)
        .to_string();

    // 6. Create image records (track failures)
    let mut image_errors: Vec<String> = Vec::new();
    for (_, image_type, pair_index, full_path, thumb_path) in &uploaded_images {
        let img_body = serde_json::json!({
            "preset_id": preset_id,
            "image_type": image_type,
            "pair_index": pair_index,
            "full_image_path": full_path,
            "thumbnail_path": thumb_path,
        });

        let url = format!("{}/rest/v1/community_preset_images", CONFIG.url);
        match secure_post(&url)
            .json(&img_body)
            .send()
            .await
        {
            Ok(response) => {
                if !response.status().is_success() {
                    let text = response.text().await.unwrap_or_default();
                    log::warn!("[Community] Failed to save image record for {}: {}", image_type, text);
                    image_errors.push(format!("{} image", image_type));
                }
            }
            Err(e) => {
                log::warn!("[Community] Failed to save image record for {}: {}", image_type, e);
                image_errors.push(format!("{} image", image_type));
            }
        }
    }

    // Build success message with any warnings
    let message = if image_errors.is_empty() {
        "Preset submitted successfully! It will be reviewed by moderators.".to_string()
    } else {
        format!(
            "Preset submitted but some images may not have saved properly: {}. It will be reviewed by moderators.",
            image_errors.join(", ")
        )
    };

    Ok(SubmissionResult {
        success: true,
        preset_id: Some(preset_id),
        slug: Some(slug),
        message,
    })
}

/// Increment download count for a preset
pub async fn increment_download_count(preset_id: &str) -> Result<(), String> {
    let url = format!("{}/rest/v1/rpc/increment_download_count", CONFIG.url);

    let body = serde_json::json!({
        "preset_id": preset_id
    });

    secure_post(&url)
        .json(&body)
        .send()
        .await
        .map_err(|e| format!("Failed to increment: {}", e))?;

    Ok(())
}

