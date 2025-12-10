//! Preset management Tauri commands

use std::fs;
use std::path::Path;

use crate::models::{GitHubFileEntry, InstalledPreset, Preset, PresetIndex, PresetManifest, PresetsResponse};
use crate::utils::{chrono_lite_now, load_installed_presets_list, save_installed_presets_list, update_gshade_preset_path};

// GitHub repository URLs
const GITHUB_PRESET_BASE_URL: &str = "https://raw.githubusercontent.com/OrbisFX/presets/main";
const GITHUB_PRESET_INDEX_URL: &str = "https://raw.githubusercontent.com/OrbisFX/presets/main/index.json";
const GITHUB_API_CONTENTS_URL: &str = "https://api.github.com/repos/OrbisFX/presets/contents";

/// Result of scanning a preset folder for files
struct PresetFolderInfo {
    ini_file: Option<String>,
    images: Vec<String>,
    vanilla_image: Option<String>,
    toggled_image: Option<String>,
    thumbnail: Option<String>,
}

/// Fetch folder contents and extract .ini filename, image files, and comparison images
async fn fetch_preset_folder_info(client: &reqwest::Client, preset_id: &str) -> PresetFolderInfo {
    let contents_url = format!("{}/{}", GITHUB_API_CONTENTS_URL, preset_id);

    let response = match client
        .get(&contents_url)
        .header("User-Agent", "OrbisFX-Launcher")
        .send()
        .await {
            Ok(r) => r,
            Err(_) => return PresetFolderInfo {
                ini_file: None,
                images: vec![],
                vanilla_image: None,
                toggled_image: None,
                thumbnail: None,
            }
        };

    if !response.status().is_success() {
        log::warn!("GitHub API returned status {} for {}", response.status(), preset_id);
        return PresetFolderInfo {
            ini_file: None,
            images: vec![],
            vanilla_image: None,
            toggled_image: None,
            thumbnail: None,
        };
    }

    let files: Vec<GitHubFileEntry> = match response.json().await {
        Ok(f) => f,
        Err(_) => return PresetFolderInfo {
            ini_file: None,
            images: vec![],
            vanilla_image: None,
            toggled_image: None,
            thumbnail: None,
        }
    };

    let ini_file = files.iter()
        .find(|f| f.file_type == "file" && f.name.ends_with(".ini") && !f.name.starts_with('.'))
        .map(|f| f.name.clone());

    // Check for comparison images (case-insensitive)
    let vanilla_image = files.iter()
        .find(|f| f.file_type == "file" && f.name.to_lowercase() == "vanilla.png")
        .map(|f| format!("{}/{}/{}", GITHUB_PRESET_BASE_URL, preset_id, f.name));

    let toggled_image = files.iter()
        .find(|f| f.file_type == "file" && f.name.to_lowercase() == "toggled.png")
        .map(|f| format!("{}/{}/{}", GITHUB_PRESET_BASE_URL, preset_id, f.name));

    // Check for thumbnail (case-insensitive), fallback to toggled_image
    let thumbnail = files.iter()
        .find(|f| f.file_type == "file" && f.name.to_lowercase() == "thumbnail.png")
        .map(|f| format!("{}/{}/{}", GITHUB_PRESET_BASE_URL, preset_id, f.name))
        .or_else(|| toggled_image.clone());

    // Filter out comparison images from the general images list
    let images: Vec<String> = files.iter()
        .filter(|f| {
            f.file_type == "file"
            && !f.name.starts_with('.')
            && f.name.to_lowercase() != "thumbnail.png"
            && f.name.to_lowercase() != "vanilla.png"
            && f.name.to_lowercase() != "toggled.png"
            && (f.name.ends_with(".png") || f.name.ends_with(".jpg")
                || f.name.ends_with(".jpeg") || f.name.ends_with(".webp"))
        })
        .map(|f| format!("{}/{}/{}", GITHUB_PRESET_BASE_URL, preset_id, f.name))
        .collect();

    PresetFolderInfo {
        ini_file,
        images,
        vanilla_image,
        toggled_image,
        thumbnail,
    }
}

#[tauri::command]
pub async fn fetch_presets() -> serde_json::Value {
    let client = reqwest::Client::new();

    let index_response = match reqwest::get(GITHUB_PRESET_INDEX_URL).await {
        Ok(r) => r,
        Err(e) => return serde_json::json!({
            "success": false,
            "error": format!("Failed to fetch preset index: {}", e)
        })
    };

    let index: PresetIndex = match index_response.json().await {
        Ok(i) => i,
        Err(e) => return serde_json::json!({
            "success": false,
            "error": format!("Failed to parse preset index: {}", e)
        })
    };

    log::info!("Found {} presets in index", index.presets.len());

    let mut presets: Vec<Preset> = Vec::new();

    for preset_id in &index.presets {
        let manifest_url = format!("{}/{}/manifest.json", GITHUB_PRESET_BASE_URL, preset_id);
        log::info!("Fetching manifest from: {}", manifest_url);

        match reqwest::get(&manifest_url).await {
            Ok(response) => {
                if !response.status().is_success() {
                    log::warn!("Failed to fetch manifest for {}: status {}", preset_id, response.status());
                    continue;
                }

                match response.json::<PresetManifest>().await {
                    Ok(manifest) => {
                        let folder_info = fetch_preset_folder_info(&client, preset_id).await;
                        let filename = folder_info.ini_file.unwrap_or_else(|| format!("{}.ini", preset_id));

                        log::info!("Preset {} using filename: {}, found {} images, has_comparison: {}",
                            preset_id, filename, folder_info.images.len(),
                            folder_info.vanilla_image.is_some() && folder_info.toggled_image.is_some());

                        // Use detected thumbnail, fallback to toggled image, then hardcoded path
                        let thumbnail_url = folder_info.thumbnail
                            .unwrap_or_else(|| format!("{}/{}/thumbnail.png", GITHUB_PRESET_BASE_URL, preset_id));

                        let preset = Preset {
                            id: preset_id.clone(),
                            name: manifest.name,
                            author: manifest.author,
                            description: manifest.description,
                            thumbnail: thumbnail_url,
                            download_url: format!("{}/{}/{}", GITHUB_PRESET_BASE_URL, preset_id, filename),
                            version: manifest.version,
                            category: manifest.category,
                            filename,
                            images: folder_info.images,
                            long_description: manifest.long_description,
                            features: manifest.features,
                            vanilla_image: folder_info.vanilla_image,
                            toggled_image: folder_info.toggled_image,
                        };
                        presets.push(preset);
                    }
                    Err(e) => {
                        log::warn!("Failed to parse manifest for {}: {}", preset_id, e);
                    }
                }
            }
            Err(e) => {
                log::warn!("Failed to fetch manifest for {}: {}", preset_id, e);
            }
        }
    }

    log::info!("Returning {} presets", presets.len());

    serde_json::json!({
        "success": true,
        "manifest": PresetsResponse {
            version: index.version,
            presets
        }
    })
}

#[tauri::command]
pub async fn download_preset(preset: Preset, hytale_dir: String) -> serde_json::Value {
    let response = match reqwest::get(&preset.download_url).await {
        Ok(r) => r,
        Err(e) => return serde_json::json!({
            "success": false,
            "error": format!("Failed to download preset: {}", e)
        })
    };

    let bytes = match response.bytes().await {
        Ok(b) => b,
        Err(e) => return serde_json::json!({
            "success": false,
            "error": format!("Failed to read preset data: {}", e)
        })
    };

    let preset_path = Path::new(&hytale_dir).join(&preset.filename);
    if let Err(e) = fs::write(&preset_path, &bytes) {
        return serde_json::json!({
            "success": false,
            "error": format!("Failed to save preset: {}", e)
        });
    }

    if let Err(e) = update_gshade_preset_path(&hytale_dir, &preset.filename) {
        log::warn!("Failed to update GShade.ini: {}", e);
    }

    let installed = InstalledPreset {
        id: preset.id.clone(),
        name: preset.name.clone(),
        version: preset.version.clone(),
        filename: preset.filename.clone(),
        installed_at: chrono_lite_now(),
        is_active: true,
        is_favorite: false,
        is_local: false,
        source_path: None,
    };

    let mut installed_presets = load_installed_presets_list();
    installed_presets.retain(|p| p.id != preset.id);
    for p in &mut installed_presets {
        p.is_active = false;
    }
    installed_presets.push(installed);
    save_installed_presets_list(&installed_presets);

    serde_json::json!({
        "success": true,
        "message": format!("Preset '{}' installed successfully", preset.name)
    })
}

#[tauri::command]
pub fn get_installed_presets() -> serde_json::Value {
    let presets = load_installed_presets_list();
    serde_json::json!({
        "success": true,
        "presets": presets
    })
}

#[tauri::command]
pub fn delete_preset(preset_id: String, hytale_dir: String) -> serde_json::Value {
    let presets = load_installed_presets_list();

    let preset_to_delete = presets.iter().find(|p| p.id == preset_id);

    if let Some(preset) = preset_to_delete {
        let preset_file_path = Path::new(&hytale_dir).join(&preset.filename);
        if preset_file_path.exists() {
            let _ = fs::remove_file(&preset_file_path);
        }

        let updated_presets: Vec<InstalledPreset> = presets.into_iter()
            .filter(|p| p.id != preset_id)
            .collect();

        save_installed_presets_list(&updated_presets);
        serde_json::json!({"success": true})
    } else {
        serde_json::json!({"success": false, "error": "Preset not found"})
    }
}

#[tauri::command]
pub fn activate_preset(preset_id: String, hytale_dir: String) -> serde_json::Value {
    let mut presets = load_installed_presets_list();
    let mut found_filename: Option<String> = None;

    for p in &mut presets {
        if p.id == preset_id {
            p.is_active = true;
            found_filename = Some(p.filename.clone());
        } else {
            p.is_active = false;
        }
    }

    if let Some(filename) = found_filename {
        if let Err(e) = update_gshade_preset_path(&hytale_dir, &filename) {
            return serde_json::json!({
                "success": false,
                "error": format!("Failed to update GShade.ini: {}", e)
            });
        }

        save_installed_presets_list(&presets);
        serde_json::json!({"success": true})
    } else {
        serde_json::json!({"success": false, "error": "Preset not found"})
    }
}

#[tauri::command]
pub fn import_local_preset(source_path: String, hytale_dir: String, preset_name: String) -> serde_json::Value {
    let source = Path::new(&source_path);

    if !source.exists() {
        return serde_json::json!({
            "success": false,
            "error": "Source file not found"
        });
    }

    let filename = source.file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("imported-preset.ini")
        .to_string();

    let dest_path = Path::new(&hytale_dir).join(&filename);
    if let Err(e) = fs::copy(&source, &dest_path) {
        return serde_json::json!({
            "success": false,
            "error": format!("Failed to copy preset: {}", e)
        });
    }

    let id = filename.trim_end_matches(".ini").to_string();

    if let Err(e) = update_gshade_preset_path(&hytale_dir, &filename) {
        log::warn!("Failed to update GShade.ini: {}", e);
    }

    let installed = InstalledPreset {
        id: id.clone(),
        name: if preset_name.is_empty() { id.clone() } else { preset_name },
        version: "1.0.0".to_string(),
        filename: filename.clone(),
        installed_at: chrono_lite_now(),
        is_active: true,
        is_favorite: false,
        is_local: true,
        source_path: Some(source_path),
    };

    let mut installed_presets = load_installed_presets_list();
    installed_presets.retain(|p| p.id != id);
    for p in &mut installed_presets {
        p.is_active = false;
    }
    installed_presets.push(installed.clone());
    save_installed_presets_list(&installed_presets);

    serde_json::json!({
        "success": true,
        "preset": installed
    })
}

#[tauri::command]
pub fn export_preset(preset_id: String, hytale_dir: String, dest_path: String) -> serde_json::Value {
    let presets = load_installed_presets_list();

    let preset = match presets.iter().find(|p| p.id == preset_id) {
        Some(p) => p,
        None => return serde_json::json!({
            "success": false,
            "error": "Preset not found"
        })
    };

    let source_path = Path::new(&hytale_dir).join(&preset.filename);
    let dest = Path::new(&dest_path);

    if !source_path.exists() {
        return serde_json::json!({
            "success": false,
            "error": "Preset file not found in game directory"
        });
    }

    if let Err(e) = fs::copy(&source_path, &dest) {
        return serde_json::json!({
            "success": false,
            "error": format!("Failed to export preset: {}", e)
        });
    }

    serde_json::json!({
        "success": true,
        "message": format!("Preset exported to {}", dest_path)
    })
}

#[tauri::command]
pub fn toggle_favorite(preset_id: String) -> serde_json::Value {
    let mut presets = load_installed_presets_list();
    let mut found = false;
    let mut new_state = false;

    for p in &mut presets {
        if p.id == preset_id {
            p.is_favorite = !p.is_favorite;
            new_state = p.is_favorite;
            found = true;
            break;
        }
    }

    if found {
        save_installed_presets_list(&presets);
        serde_json::json!({
            "success": true,
            "is_favorite": new_state
        })
    } else {
        serde_json::json!({
            "success": false,
            "error": "Preset not found"
        })
    }
}

/// Cache duration in seconds (60 seconds as requested)
const CACHE_DURATION_SECS: u64 = 60;

/// Get the cache directory for preset images
fn get_image_cache_dir() -> Option<std::path::PathBuf> {
    dirs::cache_dir().map(|p| p.join("orbisfx-launcher").join("preset-images"))
}

/// Check if a cached file is still valid (less than CACHE_DURATION_SECS old)
fn is_cache_valid(path: &std::path::Path) -> bool {
    if let Ok(metadata) = std::fs::metadata(path) {
        if let Ok(modified) = metadata.modified() {
            if let Ok(elapsed) = modified.elapsed() {
                return elapsed.as_secs() < CACHE_DURATION_SECS;
            }
        }
    }
    false
}

/// Generate a safe filename from a URL
fn url_to_cache_filename(url: &str) -> String {
    use std::collections::hash_map::DefaultHasher;
    use std::hash::{Hash, Hasher};

    let mut hasher = DefaultHasher::new();
    url.hash(&mut hasher);
    let hash = hasher.finish();

    // Extract extension from URL
    let extension = url.rsplit('.').next()
        .filter(|ext| ["png", "jpg", "jpeg", "webp", "gif"].contains(&ext.to_lowercase().as_str()))
        .unwrap_or("png");

    format!("{:x}.{}", hash, extension)
}

/// Cache an image from a GitHub URL and return the local file path
#[tauri::command]
pub async fn cache_github_image(url: String) -> serde_json::Value {
    // Validate URL is from GitHub
    if !url.starts_with("https://raw.githubusercontent.com/") {
        return serde_json::json!({
            "success": false,
            "error": "Invalid URL: must be from raw.githubusercontent.com",
            "original_url": url
        });
    }

    let cache_dir = match get_image_cache_dir() {
        Some(dir) => dir,
        None => return serde_json::json!({
            "success": false,
            "error": "Could not determine cache directory",
            "original_url": url
        })
    };

    // Ensure cache directory exists
    if let Err(e) = std::fs::create_dir_all(&cache_dir) {
        return serde_json::json!({
            "success": false,
            "error": format!("Failed to create cache directory: {}", e),
            "original_url": url
        });
    }

    let filename = url_to_cache_filename(&url);
    let cache_path = cache_dir.join(&filename);

    // Check if we have a valid cached version
    if cache_path.exists() && is_cache_valid(&cache_path) {
        return serde_json::json!({
            "success": true,
            "cached_path": cache_path.to_string_lossy(),
            "from_cache": true
        });
    }

    // Download the image
    let response = match reqwest::get(&url).await {
        Ok(r) => r,
        Err(e) => {
            // If download fails but we have a stale cache, use it
            if cache_path.exists() {
                return serde_json::json!({
                    "success": true,
                    "cached_path": cache_path.to_string_lossy(),
                    "from_cache": true,
                    "stale": true
                });
            }
            return serde_json::json!({
                "success": false,
                "error": format!("Failed to download image: {}", e),
                "original_url": url
            });
        }
    };

    if !response.status().is_success() {
        // If download fails but we have a stale cache, use it
        if cache_path.exists() {
            return serde_json::json!({
                "success": true,
                "cached_path": cache_path.to_string_lossy(),
                "from_cache": true,
                "stale": true
            });
        }
        return serde_json::json!({
            "success": false,
            "error": format!("HTTP error: {}", response.status()),
            "original_url": url
        });
    }

    let bytes = match response.bytes().await {
        Ok(b) => b,
        Err(e) => {
            if cache_path.exists() {
                return serde_json::json!({
                    "success": true,
                    "cached_path": cache_path.to_string_lossy(),
                    "from_cache": true,
                    "stale": true
                });
            }
            return serde_json::json!({
                "success": false,
                "error": format!("Failed to read image data: {}", e),
                "original_url": url
            });
        }
    };

    // Save to cache
    if let Err(e) = std::fs::write(&cache_path, &bytes) {
        return serde_json::json!({
            "success": false,
            "error": format!("Failed to save to cache: {}", e),
            "original_url": url
        });
    }

    serde_json::json!({
        "success": true,
        "cached_path": cache_path.to_string_lossy(),
        "from_cache": false
    })
}

/// Clear the image cache (useful for debugging or freeing space)
#[tauri::command]
pub fn clear_image_cache() -> serde_json::Value {
    let cache_dir = match get_image_cache_dir() {
        Some(dir) => dir,
        None => return serde_json::json!({
            "success": false,
            "error": "Could not determine cache directory"
        })
    };

    if !cache_dir.exists() {
        return serde_json::json!({
            "success": true,
            "message": "Cache directory does not exist"
        });
    }

    match std::fs::remove_dir_all(&cache_dir) {
        Ok(_) => serde_json::json!({
            "success": true,
            "message": "Cache cleared successfully"
        }),
        Err(e) => serde_json::json!({
            "success": false,
            "error": format!("Failed to clear cache: {}", e)
        })
    }
}
