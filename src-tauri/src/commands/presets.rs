//! Preset management Tauri commands

use std::fs;
use std::path::Path;

use crate::models::{GitHubFileEntry, InstalledPreset, Preset, PresetIndex, PresetManifest, PresetsResponse};
use crate::utils::{chrono_lite_now, load_installed_presets_list, save_installed_presets_list, update_reshade_preset_path};

// GitHub repository URLs
const GITHUB_PRESET_BASE_URL: &str = "https://raw.githubusercontent.com/OrbisFX/presets/main";
const GITHUB_PRESET_INDEX_URL: &str = "https://raw.githubusercontent.com/OrbisFX/presets/main/index.json";
const GITHUB_API_CONTENTS_URL: &str = "https://api.github.com/repos/OrbisFX/presets/contents";

/// Fetch folder contents and extract .ini filename and image files
async fn fetch_preset_folder_info(client: &reqwest::Client, preset_id: &str) -> (Option<String>, Vec<String>) {
    let contents_url = format!("{}/{}", GITHUB_API_CONTENTS_URL, preset_id);

    let response = match client
        .get(&contents_url)
        .header("User-Agent", "OrbisFX-Launcher")
        .send()
        .await {
            Ok(r) => r,
            Err(_) => return (None, vec![])
        };

    if !response.status().is_success() {
        log::warn!("GitHub API returned status {} for {}", response.status(), preset_id);
        return (None, vec![]);
    }

    let files: Vec<GitHubFileEntry> = match response.json().await {
        Ok(f) => f,
        Err(_) => return (None, vec![])
    };

    let ini_file = files.iter()
        .find(|f| f.file_type == "file" && f.name.ends_with(".ini") && !f.name.starts_with('.'))
        .map(|f| f.name.clone());

    let images: Vec<String> = files.iter()
        .filter(|f| {
            f.file_type == "file"
            && !f.name.starts_with('.')
            && f.name != "thumbnail.png"
            && (f.name.ends_with(".png") || f.name.ends_with(".jpg")
                || f.name.ends_with(".jpeg") || f.name.ends_with(".webp"))
        })
        .map(|f| format!("{}/{}/{}", GITHUB_PRESET_BASE_URL, preset_id, f.name))
        .collect();

    (ini_file, images)
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
                        let (ini_file, images) = fetch_preset_folder_info(&client, preset_id).await;
                        let filename = ini_file.unwrap_or_else(|| format!("{}.ini", preset_id));

                        log::info!("Preset {} using filename: {}, found {} images", preset_id, filename, images.len());

                        let preset = Preset {
                            id: preset_id.clone(),
                            name: manifest.name,
                            author: manifest.author,
                            description: manifest.description,
                            thumbnail: format!("{}/{}/thumbnail.png", GITHUB_PRESET_BASE_URL, preset_id),
                            download_url: format!("{}/{}/{}", GITHUB_PRESET_BASE_URL, preset_id, filename),
                            version: manifest.version,
                            category: manifest.category,
                            filename,
                            images,
                            long_description: manifest.long_description,
                            features: manifest.features,
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

    if let Err(e) = update_reshade_preset_path(&hytale_dir, &preset.filename) {
        log::warn!("Failed to update ReShade.ini: {}", e);
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
        if let Err(e) = update_reshade_preset_path(&hytale_dir, &filename) {
            return serde_json::json!({
                "success": false,
                "error": format!("Failed to update ReShade.ini: {}", e)
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

    if let Err(e) = update_reshade_preset_path(&hytale_dir, &filename) {
        log::warn!("Failed to update ReShade.ini: {}", e);
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

