//! Community preset commands
//!
//! Handles Discord auth, preset submission, and community preset browsing.

use serde::{Deserialize, Serialize};
use crate::discord_auth::{self, DiscordUser};
use crate::image_compress::{self, CompressionOptions};
use crate::community;
use crate::models::{InstalledPreset, PresetSource};
use crate::utils::{load_installed_presets_list, save_installed_presets_list, chrono_lite_now};

// ============== Response Types ==============

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthResponse {
    pub user: Option<UserInfo>,
    pub is_authenticated: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserInfo {
    pub id: String,
    pub username: String,
    pub discriminator: String,
    pub avatar_url: String,
    pub banner_url: Option<String>,
    pub banner_color: Option<String>,
    pub accent_color: Option<u32>,
    pub display_name: String,
}

impl From<DiscordUser> for UserInfo {
    fn from(user: DiscordUser) -> Self {
        Self {
            avatar_url: user.avatar_url(),
            banner_url: user.banner_url(),
            banner_color: user.banner_color.clone(),
            accent_color: user.accent_color,
            display_name: user.display_name().to_string(),
            id: user.id,
            username: user.username,
            discriminator: user.discriminator,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ImageCompressionResult {
    pub full_image_base64: String,
    pub thumbnail_base64: String,
    pub width: u32,
    pub height: u32,
    pub thumb_width: u32,
    pub thumb_height: u32,
    pub full_size_bytes: usize,
    pub thumb_size_bytes: usize,
}

// ============== OAuth Server Commands ==============

/// Start local OAuth callback server and return port
#[tauri::command]
pub fn discord_start_oauth_server() -> Result<u16, String> {
    discord_auth::start_oauth_server()
}

/// Get OAuth URL with the callback port
#[tauri::command]
pub fn discord_get_auth_url_with_port(port: u16) -> String {
    discord_auth::get_auth_url_with_port(port)
}

/// Check if OAuth code has been received
#[tauri::command]
pub fn discord_check_oauth_code() -> Option<String> {
    discord_auth::get_oauth_code()
}

/// Clear any pending OAuth code (for cancellation)
#[tauri::command]
pub fn discord_clear_oauth_code() {
    discord_auth::clear_oauth_code();
}

/// Complete OAuth flow after receiving code
#[tauri::command]
pub async fn discord_complete_oauth(code: String, port: u16) -> Result<AuthResponse, String> {
    // Clear the stored code
    discord_auth::clear_oauth_code();

    // Exchange code for tokens
    let tokens = discord_auth::exchange_code_with_port(&code, port).await?;
    let user = discord_auth::get_user(&tokens.access_token).await?;

    // Create or update user profile in Supabase so profile viewing works
    let avatar_hash = user.avatar.as_deref();
    if let Err(e) = community::get_or_create_profile(&user.id, &user.username, avatar_hash).await {
        log::warn!("Failed to sync user profile to Supabase: {}", e);
        // Don't fail the login - profile sync is optional
    }

    Ok(AuthResponse {
        user: Some(UserInfo::from(user)),
        is_authenticated: true,
    })
}

// ============== Auth Commands ==============

/// Get Discord OAuth URL for authentication (legacy - uses fixed redirect)
#[tauri::command]
pub fn discord_get_auth_url() -> String {
    discord_auth::get_auth_url()
}

/// Exchange Discord auth code for user info
#[tauri::command]
pub async fn discord_auth_callback(code: String) -> Result<AuthResponse, String> {
    let tokens = discord_auth::exchange_code(&code).await?;
    let user = discord_auth::get_user(&tokens.access_token).await?;

    // Create or update user profile in Supabase
    let avatar_hash = user.avatar.as_deref();
    if let Err(e) = community::get_or_create_profile(&user.id, &user.username, avatar_hash).await {
        log::warn!("Failed to sync user profile to Supabase: {}", e);
    }

    Ok(AuthResponse {
        user: Some(UserInfo::from(user)),
        is_authenticated: true,
    })
}

/// Get current authenticated user (if any)
#[tauri::command]
pub async fn discord_get_current_user() -> AuthResponse {
    match discord_auth::get_current_user().await {
        Some(user) => AuthResponse {
            user: Some(UserInfo::from(user)),
            is_authenticated: true,
        },
        None => AuthResponse {
            user: None,
            is_authenticated: false,
        },
    }
}

/// Logout from Discord
#[tauri::command]
pub fn discord_logout() {
    discord_auth::logout();
}

// ============== Image Compression Commands ==============

/// Allowed directories for image/preset file access
fn get_allowed_file_dirs() -> Vec<std::path::PathBuf> {
    let mut dirs = Vec::new();

    // Allow pictures directory
    if let Some(d) = dirs::picture_dir() {
        dirs.push(d);
    }
    // Allow downloads directory
    if let Some(d) = dirs::download_dir() {
        dirs.push(d);
    }
    // Allow documents directory
    if let Some(d) = dirs::document_dir() {
        dirs.push(d);
    }
    // Allow desktop
    if let Some(d) = dirs::desktop_dir() {
        dirs.push(d);
    }
    // Allow home directory as fallback
    if let Some(d) = dirs::home_dir() {
        dirs.push(d);
    }

    dirs
}

/// Validate that a path is within allowed user directories
fn validate_user_file_path(path: &std::path::Path) -> Result<std::path::PathBuf, String> {
    let canonical = path.canonicalize()
        .map_err(|e| format!("Invalid path '{}': {}", path.display(), e))?;

    for allowed_dir in get_allowed_file_dirs() {
        if let Ok(canonical_allowed) = allowed_dir.canonicalize() {
            if canonical.starts_with(&canonical_allowed) {
                return Ok(canonical);
            }
        }
    }

    Err(format!(
        "Path '{}' is outside allowed directories (Pictures, Downloads, Documents, Desktop)",
        path.display()
    ))
}

/// Compress an image for submission
/// Security: Validates path is within allowed user directories
#[tauri::command]
pub fn compress_image_for_submission(image_path: String) -> Result<ImageCompressionResult, String> {
    let path = std::path::Path::new(&image_path);

    // Validate path is within allowed directories
    validate_user_file_path(path)?;

    let options = CompressionOptions::default();
    let result = image_compress::compress_image_file(&image_path, Some(options))?;

    Ok(ImageCompressionResult {
        full_image_base64: base64::Engine::encode(
            &base64::engine::general_purpose::STANDARD,
            &result.full_image
        ),
        thumbnail_base64: base64::Engine::encode(
            &base64::engine::general_purpose::STANDARD,
            &result.thumbnail
        ),
        width: result.width,
        height: result.height,
        thumb_width: result.thumb_width,
        thumb_height: result.thumb_height,
        full_size_bytes: result.full_image.len(),
        thumb_size_bytes: result.thumbnail.len(),
    })
}

/// Get hash of a preset file for integrity verification
/// Security: Validates path is within allowed user directories
#[tauri::command]
pub fn get_preset_file_hash(file_path: String) -> Result<String, String> {
    let path = std::path::Path::new(&file_path);

    // Validate path is within allowed directories
    validate_user_file_path(path)?;

    let content = std::fs::read(&file_path)
        .map_err(|e| format!("Failed to read file: {}", e))?;
    Ok(image_compress::sha256_hash(&content))
}

// ============== Preset Validation ==============

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PresetValidation {
    pub is_valid: bool,
    pub name: Option<String>,
    pub errors: Vec<String>,
    pub file_size: u64,
    pub file_hash: String,
}

/// Validate a preset file before submission
/// Security: Validates path is within allowed user directories
#[tauri::command]
pub fn validate_preset_for_submission(file_path: String) -> Result<PresetValidation, String> {
    use std::path::Path;

    let path = Path::new(&file_path);

    // Validate path is within allowed directories (prevent path traversal)
    if let Err(e) = validate_user_file_path(path) {
        log::warn!("[Security] Path traversal attempt in validate_preset: {}", e);
        return Ok(PresetValidation {
            is_valid: false,
            name: None,
            errors: vec!["Invalid file path".to_string()],
            file_size: 0,
            file_hash: String::new(),
        });
    }

    let mut errors = Vec::new();

    // Check file exists
    if !path.exists() {
        return Ok(PresetValidation {
            is_valid: false,
            name: None,
            errors: vec!["File does not exist".to_string()],
            file_size: 0,
            file_hash: String::new(),
        });
    }

    // Check extension
    let ext = path.extension()
        .and_then(|e| e.to_str())
        .unwrap_or("")
        .to_lowercase();

    if ext != "ini" && ext != "fx" {
        errors.push(format!("Invalid extension: .{} (expected .ini or .fx)", ext));
    }

    // Read file
    let content = std::fs::read(&file_path)
        .map_err(|e| format!("Failed to read file: {}", e))?;

    let file_size = content.len() as u64;

    // Check file size (max 1MB)
    if file_size > 1_000_000 {
        errors.push(format!("File too large: {} bytes (max 1MB)", file_size));
    }

    // Check if valid UTF-8
    let text = match String::from_utf8(content.clone()) {
        Ok(t) => t,
        Err(_) => {
            errors.push("File is not valid UTF-8 text".to_string());
            String::new()
        }
    };

    // Basic security checks
    let suspicious_patterns = ["http://", "https://", "ftp://", "cmd ", "powershell", "exec("];
    for pattern in suspicious_patterns {
        if text.to_lowercase().contains(pattern) {
            errors.push(format!("Suspicious content detected: {}", pattern));
        }
    }

    // Get name from filename
    let name = path.file_stem()
        .and_then(|n| n.to_str())
        .map(|s| s.to_string());

    let file_hash = image_compress::sha256_hash(&content);

    Ok(PresetValidation {
        is_valid: errors.is_empty(),
        name,
        errors,
        file_size,
        file_hash,
    })
}

// ============== Community Preset Commands ==============

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommunityPresetInfo {
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
    pub images: Vec<CommunityPresetImageInfo>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommunityPresetImageInfo {
    pub id: String,
    pub image_type: String,
    pub pair_index: Option<i32>,
    pub full_image_url: String,
    pub thumbnail_url: Option<String>,
}

impl From<community::CommunityPreset> for CommunityPresetInfo {
    fn from(p: community::CommunityPreset) -> Self {
        Self {
            id: p.id,
            slug: p.slug,
            name: p.name,
            description: p.description,
            long_description: p.long_description,
            category: p.category,
            version: p.version,
            author_name: p.author_name,
            author_discord_id: p.author_discord_id,
            author_avatar: p.author_avatar,
            thumbnail_url: p.thumbnail_url,
            preset_file_url: p.preset_file_url,
            download_count: p.download_count,
            status: p.status,
            created_at: p.created_at,
            images: p.images.into_iter().map(|i| CommunityPresetImageInfo {
                id: i.id,
                image_type: i.image_type,
                pair_index: i.pair_index,
                full_image_url: i.full_image_url,
                thumbnail_url: i.thumbnail_url,
            }).collect(),
        }
    }
}

/// Fetch community presets with pagination and filtering
#[tauri::command]
pub async fn fetch_community_presets(
    page: u32,
    per_page: u32,
    category: Option<String>,
    search: Option<String>,
) -> Result<Vec<CommunityPresetInfo>, String> {
    let presets = community::fetch_community_presets(
        page,
        per_page,
        category.as_deref(),
        search.as_deref(),
    ).await?;

    Ok(presets.into_iter().map(CommunityPresetInfo::from).collect())
}

/// Fetch trending community presets (sorted by download count)
#[tauri::command]
pub async fn fetch_trending_presets(limit: u32) -> Result<Vec<CommunityPresetInfo>, String> {
    let presets = community::fetch_trending_presets(limit).await?;
    Ok(presets.into_iter().map(CommunityPresetInfo::from).collect())
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubmitPresetRequest {
    pub name: String,
    pub description: String,
    pub long_description: Option<String>,
    pub category: String,
    pub based_on_preset_name: Option<String>,
    pub preset_file_path: String,
    pub image_paths: Vec<SubmitImageInfo>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubmitImageInfo {
    pub local_path: String,
    pub image_type: String,
    pub pair_index: Option<i32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubmitPresetResult {
    pub success: bool,
    pub preset_id: Option<String>,
    pub slug: Option<String>,
    pub message: String,
}

/// Submit a preset to the community
#[tauri::command]
pub async fn submit_community_preset(request: SubmitPresetRequest) -> Result<SubmitPresetResult, String> {
    // Get current user
    let user = discord_auth::get_current_user().await
        .ok_or_else(|| "Not logged in with Discord".to_string())?;

    let submission = community::SubmissionRequest {
        name: request.name,
        description: request.description,
        long_description: request.long_description,
        category: request.category,
        based_on_preset_name: request.based_on_preset_name,
        preset_file_path: request.preset_file_path,
        images: request.image_paths.into_iter().map(|i| community::SubmissionImage {
            local_path: i.local_path,
            image_type: i.image_type,
            pair_index: i.pair_index,
        }).collect(),
    };

    let result = community::submit_preset(
        &user.id,
        &user.username,
        user.avatar.as_deref(),
        submission,
    ).await?;

    Ok(SubmitPresetResult {
        success: result.success,
        preset_id: result.preset_id,
        slug: result.slug,
        message: result.message,
    })
}

/// Download a community preset
#[tauri::command]
pub async fn download_community_preset(
    preset_id: String,
    preset_url: String,
    destination_path: String,
    preset_name: String,
    preset_version: Option<String>,
) -> Result<(), String> {
    log::info!("Downloading community preset {} from {} to {}", preset_id, preset_url, destination_path);

    // Increment download count
    let _ = community::increment_download_count(&preset_id).await;

    // Download the file
    let response = reqwest::get(&preset_url).await
        .map_err(|e| format!("Download failed: {}", e))?;

    if !response.status().is_success() {
        return Err(format!("Failed to download preset file: HTTP {}", response.status()));
    }

    let content = response.bytes().await
        .map_err(|e| format!("Failed to read response: {}", e))?;

    // Ensure parent directory exists
    let path = std::path::Path::new(&destination_path);
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)
            .map_err(|e| format!("Failed to create directory: {}", e))?;
    }

    std::fs::write(&destination_path, &content)
        .map_err(|e| format!("Failed to save file: {}", e))?;

    // Get the filename from the destination path
    let filename = path.file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("community-preset.ini")
        .to_string();

    // Preserve favorite status from existing preset if reinstalling
    let existing_presets = load_installed_presets_list();
    let existing_favorite = existing_presets.iter()
        .find(|p| p.id == preset_id)
        .map(|p| p.is_favorite)
        .unwrap_or(false);

    // Create installed preset entry with source info
    let installed = InstalledPreset {
        id: preset_id.clone(),
        name: preset_name,
        version: preset_version.unwrap_or_else(|| "1.0.0".to_string()),
        filename: format!("reshade-presets\\{}", filename),
        installed_at: chrono_lite_now(),
        is_active: true,
        is_favorite: existing_favorite,
        is_local: false,
        source_path: Some(preset_url.clone()),
        source: PresetSource::Community,
        source_id: Some(preset_id.clone()),
    };

    // Add to installed presets list
    let mut installed_presets = load_installed_presets_list();
    // Remove any existing preset with the same ID
    installed_presets.retain(|p| p.id != preset_id);
    // Deactivate all other presets
    for p in &mut installed_presets {
        p.is_active = false;
    }
    installed_presets.push(installed);
    save_installed_presets_list(&installed_presets);

    log::info!("Successfully downloaded and registered preset to {}", destination_path);
    Ok(())
}
