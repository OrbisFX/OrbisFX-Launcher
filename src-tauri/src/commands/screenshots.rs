//! Screenshot gallery Tauri commands

use std::fs;
use std::path::Path;

use crate::models::Screenshot;
use crate::utils::{get_config_dir, validate_path_within_dir};

// ============== Screenshot Favorites Storage ==============

fn get_screenshot_favorites_path() -> std::path::PathBuf {
    get_config_dir().join("screenshot_favorites.json")
}

fn load_screenshot_favorites() -> Vec<String> {
    let path = get_screenshot_favorites_path();
    if path.exists() {
        fs::read_to_string(&path)
            .ok()
            .and_then(|s| serde_json::from_str(&s).ok())
            .unwrap_or_default()
    } else {
        Vec::new()
    }
}

fn save_screenshot_favorites(favorites: &[String]) {
    let path = get_screenshot_favorites_path();
    if let Ok(json) = serde_json::to_string_pretty(favorites) {
        let _ = fs::write(&path, json);
    }
}

// ============== Screenshot Commands ==============

/// List all screenshots from the Hytale screenshots folder
#[tauri::command]
pub fn list_screenshots(hytale_path: String) -> serde_json::Value {
    let screenshots_dir = Path::new(&hytale_path).join("screenshots");
    
    if !screenshots_dir.exists() {
        return serde_json::json!({
            "success": true,
            "screenshots": [],
            "message": "Screenshots folder does not exist"
        });
    }

    let favorites = load_screenshot_favorites();
    let mut screenshots: Vec<Screenshot> = Vec::new();

    if let Ok(entries) = fs::read_dir(&screenshots_dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_file() {
                if let Some(ext) = path.extension() {
                    let ext_lower = ext.to_string_lossy().to_lowercase();
                    if ext_lower == "png" || ext_lower == "jpg" || ext_lower == "jpeg" {
                        if let Some(filename) = path.file_name() {
                            let filename_str = filename.to_string_lossy().to_string();
                            let id = path.file_stem()
                                .map(|s| s.to_string_lossy().to_string())
                                .unwrap_or_else(|| filename_str.clone());
                            
                            // Parse preset name from filename
                            // GShade format: "Hytale 2024-01-15 12-30-45 PresetName.png"
                            let preset_name = parse_preset_name_from_filename(&filename_str);
                            
                            // Get file metadata for timestamp and size
                            let (timestamp, file_size) = if let Ok(metadata) = entry.metadata() {
                                let ts = metadata.modified()
                                    .ok()
                                    .and_then(|t| t.duration_since(std::time::UNIX_EPOCH).ok())
                                    .map(|d| d.as_secs().to_string())
                                    .unwrap_or_else(|| "0".to_string());
                                (ts, metadata.len())
                            } else {
                                ("0".to_string(), 0)
                            };

                            let is_favorite = favorites.contains(&id);

                            screenshots.push(Screenshot {
                                id: id.clone(),
                                filename: filename_str,
                                path: path.to_string_lossy().to_string(),
                                preset_name,
                                timestamp,
                                is_favorite,
                                file_size,
                            });
                        }
                    }
                }
            }
        }
    }

    // Sort by timestamp descending (newest first)
    screenshots.sort_by(|a, b| b.timestamp.cmp(&a.timestamp));

    serde_json::json!({
        "success": true,
        "screenshots": screenshots
    })
}

/// Parse preset name from GShade screenshot filename
fn parse_preset_name_from_filename(filename: &str) -> Option<String> {
    // GShade format: "Hytale YYYY-MM-DD HH-MM-SS PresetName.png"
    // or just "Hytale YYYY-MM-DD HH-MM-SS.png" if no preset
    let name_without_ext = filename.rsplit('.').last().unwrap_or(filename);
    let name_without_ext = filename.strip_suffix(".png")
        .or_else(|| filename.strip_suffix(".jpg"))
        .or_else(|| filename.strip_suffix(".jpeg"))
        .or_else(|| filename.strip_suffix(".PNG"))
        .or_else(|| filename.strip_suffix(".JPG"))
        .or_else(|| filename.strip_suffix(".JPEG"))
        .unwrap_or(name_without_ext);
    
    // Try to find the pattern: "Hytale YYYY-MM-DD HH-MM-SS"
    // After that pattern, anything remaining is the preset name
    let parts: Vec<&str> = name_without_ext.splitn(4, ' ').collect();
    if parts.len() >= 4 && parts[0] == "Hytale" {
        // parts[1] = date, parts[2] = time, parts[3] = preset name (if any)
        let preset = parts[3].trim();
        if !preset.is_empty() {
            return Some(preset.to_string());
        }
    }
    None
}

/// Toggle favorite status for a screenshot
#[tauri::command]
pub fn toggle_screenshot_favorite(screenshot_id: String) -> serde_json::Value {
    let mut favorites = load_screenshot_favorites();

    let is_now_favorite = if favorites.contains(&screenshot_id) {
        favorites.retain(|id| id != &screenshot_id);
        false
    } else {
        favorites.push(screenshot_id.clone());
        true
    };

    save_screenshot_favorites(&favorites);

    serde_json::json!({
        "success": true,
        "is_favorite": is_now_favorite
    })
}

/// Open the screenshots folder in file explorer
#[tauri::command]
pub fn open_screenshots_folder(hytale_path: String) -> serde_json::Value {
    let screenshots_dir = Path::new(&hytale_path).join("screenshots");

    if !screenshots_dir.exists() {
        // Try to create it
        if let Err(e) = fs::create_dir_all(&screenshots_dir) {
            return serde_json::json!({
                "success": false,
                "error": format!("Failed to create screenshots folder: {}", e)
            });
        }
    }

    #[cfg(target_os = "windows")]
    {
        let _ = std::process::Command::new("explorer")
            .arg(&screenshots_dir)
            .spawn();
    }

    #[cfg(target_os = "macos")]
    {
        let _ = std::process::Command::new("open")
            .arg(&screenshots_dir)
            .spawn();
    }

    #[cfg(target_os = "linux")]
    {
        let _ = std::process::Command::new("xdg-open")
            .arg(&screenshots_dir)
            .spawn();
    }

    serde_json::json!({
        "success": true
    })
}

/// Open a specific screenshot's containing folder and select it
/// Security: Validates path is within a safe directory to prevent path traversal
#[tauri::command]
pub fn reveal_screenshot_in_folder(screenshot_path: String, hytale_path: String) -> serde_json::Value {
    let path = Path::new(&screenshot_path);
    let screenshots_dir = Path::new(&hytale_path).join("screenshots");

    // Validate path is within screenshots directory (prevent path traversal)
    if let Err(e) = validate_path_within_dir(path, &screenshots_dir) {
        log::warn!("[Security] Path traversal attempt in reveal_screenshot: {}", e);
        return serde_json::json!({
            "success": false,
            "error": "Invalid screenshot path"
        });
    }

    if !path.exists() {
        return serde_json::json!({
            "success": false,
            "error": "Screenshot file not found"
        });
    }

    #[cfg(target_os = "windows")]
    {
        let _ = std::process::Command::new("explorer")
            .args(["/select,", &screenshot_path])
            .spawn();
    }

    #[cfg(target_os = "macos")]
    {
        let _ = std::process::Command::new("open")
            .args(["-R", &screenshot_path])
            .spawn();
    }

    #[cfg(target_os = "linux")]
    {
        // Linux doesn't have a standard way to select a file, so just open the folder
        if let Some(parent) = path.parent() {
            let _ = std::process::Command::new("xdg-open")
                .arg(parent)
                .spawn();
        }
    }

    serde_json::json!({
        "success": true
    })
}

/// Delete a screenshot
/// Security: Validates path is within screenshots directory to prevent arbitrary file deletion
#[tauri::command]
pub fn delete_screenshot(screenshot_path: String, hytale_path: String) -> serde_json::Value {
    let path = Path::new(&screenshot_path);
    let screenshots_dir = Path::new(&hytale_path).join("screenshots");

    // Validate path is within screenshots directory (prevent path traversal)
    if let Err(e) = validate_path_within_dir(path, &screenshots_dir) {
        log::warn!("[Security] Path traversal attempt in delete_screenshot: {}", e);
        return serde_json::json!({
            "success": false,
            "error": "Invalid screenshot path"
        });
    }

    if !path.exists() {
        return serde_json::json!({
            "success": false,
            "error": "Screenshot file not found"
        });
    }

    match fs::remove_file(path) {
        Ok(_) => {
            // Also remove from favorites if it was favorited
            if let Some(stem) = path.file_stem() {
                let id = stem.to_string_lossy().to_string();
                let mut favorites = load_screenshot_favorites();
                favorites.retain(|fav_id| fav_id != &id);
                save_screenshot_favorites(&favorites);
            }
            serde_json::json!({
                "success": true
            })
        }
        Err(e) => serde_json::json!({
            "success": false,
            "error": format!("Failed to delete screenshot: {}", e)
        })
    }
}

/// Get unique preset names from all screenshots (for filtering)
#[tauri::command]
pub fn get_screenshot_presets(hytale_path: String) -> serde_json::Value {
    let screenshots_dir = Path::new(&hytale_path).join("screenshots");

    if !screenshots_dir.exists() {
        return serde_json::json!({
            "success": true,
            "presets": []
        });
    }

    let mut preset_names: Vec<String> = Vec::new();

    if let Ok(entries) = fs::read_dir(&screenshots_dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_file() {
                if let Some(filename) = path.file_name() {
                    let filename_str = filename.to_string_lossy().to_string();
                    if let Some(preset) = parse_preset_name_from_filename(&filename_str) {
                        if !preset_names.contains(&preset) {
                            preset_names.push(preset);
                        }
                    }
                }
            }
        }
    }

    preset_names.sort();

    serde_json::json!({
        "success": true,
        "presets": preset_names
    })
}

