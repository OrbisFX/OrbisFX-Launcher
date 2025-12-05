use std::path::{Path, PathBuf};
use std::fs;
use std::io::Write;
use std::process::Command;
use include_dir::{include_dir, Dir};
use serde::{Deserialize, Serialize};

// Embed the entire RESHADE INSTALL folder into the binary at compile time
static RESHADE_FILES: Dir = include_dir!("$CARGO_MANIFEST_DIR/../RESHADE INSTALL");

// GitHub repository for presets - now using per-preset folder structure
const GITHUB_PRESET_BASE_URL: &str = "https://raw.githubusercontent.com/OrbisFX/presets/main";
const GITHUB_PRESET_INDEX_URL: &str = "https://raw.githubusercontent.com/OrbisFX/presets/main/index.json";
const GITHUB_API_CONTENTS_URL: &str = "https://api.github.com/repos/OrbisFX/presets/contents";

// GitHub repository for launcher updates
const GITHUB_LAUNCHER_API_RELEASES_URL: &str = "https://api.github.com/repos/OrbisFX/OrbisFX-Launcher/releases/latest";

// ============== Data Structures ==============

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct AppSettings {
    pub hytale_path: Option<String>,
    pub reshade_enabled: bool,
    pub last_preset: Option<String>,
}

impl Default for AppSettings {
    fn default() -> Self {
        Self {
            hytale_path: None,
            reshade_enabled: true,
            last_preset: None,
        }
    }
}

// Per-preset manifest structure (each preset has its own manifest.json)
// ID and filename are inferred from folder name and .ini file, not from manifest
#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct PresetManifest {
    pub name: String,
    pub author: String,
    pub description: String,
    pub version: String,
    pub category: String,
    #[serde(default)]
    pub long_description: Option<String>,  // Optional longer description for detail view
    #[serde(default)]
    pub features: Option<Vec<String>>,  // Optional list of features/effects
}

// GitHub API response for directory listing
#[derive(Deserialize, Debug)]
struct GitHubFileEntry {
    name: String,
    #[serde(rename = "type")]
    file_type: String,
}

// Full preset info with computed URLs
#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Preset {
    pub id: String,
    pub name: String,
    pub author: String,
    pub description: String,
    pub thumbnail: String,
    pub download_url: String,
    pub version: String,
    pub category: String,
    pub filename: String,  // The actual .ini filename
    pub images: Vec<String>,  // Gallery images (auto-detected .png/.jpg files)
    #[serde(default)]
    pub long_description: Option<String>,
    #[serde(default)]
    pub features: Option<Vec<String>>,
}

// Index file that lists all available presets
#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct PresetIndex {
    pub version: String,
    pub presets: Vec<String>,  // List of preset folder names
}

// Response structure for the frontend
#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct PresetsResponse {
    pub version: String,
    pub presets: Vec<Preset>,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct InstalledPreset {
    pub id: String,
    pub name: String,
    pub version: String,
    pub filename: String,  // The actual .ini filename stored in game directory
    pub installed_at: String,
    pub is_active: bool,
    #[serde(default)]
    pub is_favorite: bool,
    #[serde(default)]
    pub is_local: bool,  // True if imported locally, false if from community
    #[serde(default)]
    pub source_path: Option<String>,  // Original path for local imports
}

// ============== Helper Functions ==============

fn get_config_dir() -> PathBuf {
    let config_dir = dirs::config_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join("OrbisFX");
    fs::create_dir_all(&config_dir).ok();
    config_dir
}

fn get_settings_path() -> PathBuf {
    get_config_dir().join("settings.json")
}

fn get_installed_presets_path() -> PathBuf {
    get_config_dir().join("installed_presets.json")
}

// ============== Tauri Commands ==============

#[tauri::command]
fn validate_path(hytale_dir: String) -> serde_json::Value {
    let exe_path = Path::new(&hytale_dir).join("Hytale.exe");
    let exists = exe_path.exists();

    // Check for runtime - it's installed if EITHER the .dll OR .dll.disabled exists
    let dll_path = Path::new(&hytale_dir).join("opengl32.dll");
    let disabled_path = Path::new(&hytale_dir).join("opengl32.dll.disabled");
    let runtime_installed = dll_path.exists() || disabled_path.exists();
    let runtime_enabled = dll_path.exists() && !disabled_path.exists();

    serde_json::json!({
        "is_valid": exists,
        "hytale_path": if exists { Some(hytale_dir) } else { None },
        "hytale_version": if exists { Some("unknown") } else { None },
        "reshade_installed": runtime_installed,
        "reshade_enabled": runtime_enabled
    })
}

/// Recursively extract embedded directory to filesystem
fn extract_dir(dir: &Dir, dest: &Path) -> std::io::Result<()> {
    fs::create_dir_all(dest)?;

    // Extract all files in this directory
    for file in dir.files() {
        let file_path = dest.join(file.path().file_name().unwrap());
        let mut output = fs::File::create(&file_path)?;
        output.write_all(file.contents())?;
    }

    // Recursively extract subdirectories
    for subdir in dir.dirs() {
        let subdir_name = subdir.path().file_name().unwrap();
        let subdir_dest = dest.join(subdir_name);
        extract_dir(subdir, &subdir_dest)?;
    }

    Ok(())
}

#[tauri::command]
fn install_reshade(hytale_dir: String, _preset_name: Option<String>) -> serde_json::Value {
    use std::io;

    let exe_path = Path::new(&hytale_dir).join("Hytale.exe");
    if !exe_path.exists() {
        return serde_json::json!({
            "success": false,
            "message": "Hytale.exe not found",
            "path": None::<String>
        });
    }

    let result = (|| -> io::Result<()> {
        let target_path = Path::new(&hytale_dir);

        // Extract all embedded files to target directory
        for file in RESHADE_FILES.files() {
            let file_name = file.path().file_name().unwrap();
            let dest_path = target_path.join(file_name);
            let mut output = fs::File::create(&dest_path)?;
            output.write_all(file.contents())?;
        }

        // Extract subdirectories (like reshade-shaders)
        for subdir in RESHADE_FILES.dirs() {
            let subdir_name = subdir.path().file_name().unwrap();
            let subdir_dest = target_path.join(subdir_name);
            extract_dir(subdir, &subdir_dest)?;
        }

        Ok(())
    })();

    if result.is_ok() {
        serde_json::json!({
            "success": true,
            "message": format!("ReShade installed successfully to {}", hytale_dir),
            "path": hytale_dir
        })
    } else {
        serde_json::json!({
            "success": false,
            "message": format!("Installation failed: {:?}", result.err()),
            "path": None::<String>
        })
    }
}

#[tauri::command]
fn uninstall_reshade(hytale_dir: String) -> serde_json::Value {
    let exe_path = Path::new(&hytale_dir).join("Hytale.exe");
    if !exe_path.exists() {
        return serde_json::json!({
            "success": false,
            "message": "Hytale.exe not found"
        });
    }

    let files_to_remove = vec![
        Path::new(&hytale_dir).join("opengl32.dll"),
        Path::new(&hytale_dir).join("opengl32.dll.disabled"),
        Path::new(&hytale_dir).join("ReShade.ini"),
        Path::new(&hytale_dir).join("ReShadePreset.ini"),
    ];

    for file in files_to_remove {
        let _ = fs::remove_file(&file);
    }

    let reshade_path = Path::new(&hytale_dir).join("reshade-shaders");
    let _ = fs::remove_dir_all(&reshade_path);

    serde_json::json!({
        "success": true,
        "message": format!("ReShade uninstalled successfully from {}", hytale_dir)
    })
}

// ============== Settings Commands ==============

#[tauri::command]
fn save_settings(settings: AppSettings) -> serde_json::Value {
    let settings_path = get_settings_path();
    match serde_json::to_string_pretty(&settings) {
        Ok(json) => {
            match fs::write(&settings_path, json) {
                Ok(_) => serde_json::json!({"success": true}),
                Err(e) => serde_json::json!({"success": false, "error": e.to_string()})
            }
        }
        Err(e) => serde_json::json!({"success": false, "error": e.to_string()})
    }
}

#[tauri::command]
fn load_settings() -> serde_json::Value {
    let settings_path = get_settings_path();
    if settings_path.exists() {
        match fs::read_to_string(&settings_path) {
            Ok(json) => {
                match serde_json::from_str::<AppSettings>(&json) {
                    Ok(settings) => serde_json::json!({"success": true, "settings": settings}),
                    Err(_) => serde_json::json!({"success": true, "settings": AppSettings::default()})
                }
            }
            Err(_) => serde_json::json!({"success": true, "settings": AppSettings::default()})
        }
    } else {
        serde_json::json!({"success": true, "settings": AppSettings::default()})
    }
}

// ============== Game Launch Commands ==============

#[tauri::command]
fn launch_game(hytale_dir: String) -> serde_json::Value {
    let exe_path = Path::new(&hytale_dir).join("Hytale.exe");
    if !exe_path.exists() {
        return serde_json::json!({
            "success": false,
            "message": "Hytale.exe not found"
        });
    }

    // Use the full path as a string and spawn via cmd to handle paths with spaces
    let exe_path_str = exe_path.to_string_lossy().to_string();

    #[cfg(target_os = "windows")]
    {
        match Command::new("cmd")
            .args(["/C", "start", "", &exe_path_str])
            .current_dir(&hytale_dir)
            .spawn()
        {
            Ok(_) => serde_json::json!({
                "success": true,
                "message": "Game launched successfully"
            }),
            Err(e) => serde_json::json!({
                "success": false,
                "message": format!("Failed to launch game: {}", e)
            })
        }
    }

    #[cfg(not(target_os = "windows"))]
    {
        match Command::new(&exe_path)
            .current_dir(&hytale_dir)
            .spawn()
        {
            Ok(_) => serde_json::json!({
                "success": true,
                "message": "Game launched successfully"
            }),
            Err(e) => serde_json::json!({
                "success": false,
                "message": format!("Failed to launch game: {}", e)
            })
        }
    }
}

// ============== Runtime Toggle Commands ==============

#[tauri::command]
fn toggle_reshade(hytale_dir: String, enabled: bool) -> serde_json::Value {
    let dll_path = Path::new(&hytale_dir).join("opengl32.dll");
    let disabled_path = Path::new(&hytale_dir).join("opengl32.dll.disabled");

    if enabled {
        // Enable runtime: rename .disabled back to .dll
        if disabled_path.exists() {
            // Remove existing dll if somehow both exist
            if dll_path.exists() {
                let _ = fs::remove_file(&dll_path);
            }
            match fs::rename(&disabled_path, &dll_path) {
                Ok(_) => serde_json::json!({"success": true, "enabled": true}),
                Err(e) => serde_json::json!({"success": false, "error": format!("Failed to enable: {}", e)})
            }
        } else if dll_path.exists() {
            serde_json::json!({"success": true, "enabled": true, "message": "Already enabled"})
        } else {
            serde_json::json!({"success": false, "error": "Runtime not installed"})
        }
    } else {
        // Disable runtime: rename .dll to .disabled
        if dll_path.exists() {
            // Remove existing disabled file if somehow both exist
            if disabled_path.exists() {
                let _ = fs::remove_file(&disabled_path);
            }
            match fs::rename(&dll_path, &disabled_path) {
                Ok(_) => serde_json::json!({"success": true, "enabled": false}),
                Err(e) => serde_json::json!({"success": false, "error": format!("Failed to disable: {}", e)})
            }
        } else if disabled_path.exists() {
            serde_json::json!({"success": true, "enabled": false, "message": "Already disabled"})
        } else {
            serde_json::json!({"success": false, "error": "Runtime not installed"})
        }
    }
}


// ============== Preset Commands ==============

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

    // Find the .ini file
    let ini_file = files.iter()
        .find(|f| f.file_type == "file" && f.name.ends_with(".ini") && !f.name.starts_with('.'))
        .map(|f| f.name.clone());

    // Find all image files (png, jpg, jpeg, webp) excluding thumbnail
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
async fn fetch_presets() -> serde_json::Value {
    let client = reqwest::Client::new();

    // Step 1: Fetch the index file to get list of preset folders
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

    // Step 2: Fetch each preset's manifest.json and detect .ini filename
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
                        // Auto-detect the .ini filename and images from the folder
                        let (ini_file, images) = fetch_preset_folder_info(&client, preset_id).await;
                        let filename = ini_file.unwrap_or_else(|| format!("{}.ini", preset_id));

                        log::info!("Preset {} using filename: {}, found {} images", preset_id, filename, images.len());

                        // Build full URLs for thumbnail and download
                        // ID is the folder name, not from manifest
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

/// Update the PresetPath in ReShade.ini to point to a specific preset file
fn update_reshade_preset_path(hytale_dir: &str, preset_filename: &str) -> Result<(), String> {
    let reshade_ini_path = Path::new(hytale_dir).join("ReShade.ini");

    if !reshade_ini_path.exists() {
        return Err("ReShade.ini not found".to_string());
    }

    let content = fs::read_to_string(&reshade_ini_path)
        .map_err(|e| format!("Failed to read ReShade.ini: {}", e))?;

    // Update the PresetPath line
    let new_content: String = content
        .lines()
        .map(|line| {
            if line.trim().starts_with("PresetPath=") {
                format!("PresetPath=.\\{}", preset_filename)
            } else {
                line.to_string()
            }
        })
        .collect::<Vec<_>>()
        .join("\n");

    fs::write(&reshade_ini_path, new_content)
        .map_err(|e| format!("Failed to write ReShade.ini: {}", e))?;

    Ok(())
}

#[tauri::command]
async fn download_preset(preset: Preset, hytale_dir: String) -> serde_json::Value {
    // Download preset file from URL
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

    // Save preset to Hytale directory with its original filename
    let preset_path = Path::new(&hytale_dir).join(&preset.filename);
    if let Err(e) = fs::write(&preset_path, &bytes) {
        return serde_json::json!({
            "success": false,
            "error": format!("Failed to save preset: {}", e)
        });
    }

    // Update ReShade.ini to use this preset
    if let Err(e) = update_reshade_preset_path(&hytale_dir, &preset.filename) {
        log::warn!("Failed to update ReShade.ini: {}", e);
        // Continue anyway - preset is downloaded
    }

    // Track installed preset
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

    // Load existing installed presets and add/update this one
    let mut installed_presets = load_installed_presets_list();
    installed_presets.retain(|p| p.id != preset.id);
    // Set all others to inactive
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

fn chrono_lite_now() -> String {
    // Simple timestamp without chrono dependency
    use std::time::{SystemTime, UNIX_EPOCH};
    let duration = SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default();
    format!("{}", duration.as_secs())
}

fn load_installed_presets_list() -> Vec<InstalledPreset> {
    let path = get_installed_presets_path();
    if path.exists() {
        fs::read_to_string(&path)
            .ok()
            .and_then(|s| serde_json::from_str(&s).ok())
            .unwrap_or_default()
    } else {
        Vec::new()
    }
}

fn save_installed_presets_list(presets: &[InstalledPreset]) {
    let path = get_installed_presets_path();
    if let Ok(json) = serde_json::to_string_pretty(presets) {
        let _ = fs::write(&path, json);
    }
}

#[tauri::command]
fn get_installed_presets() -> serde_json::Value {
    let presets = load_installed_presets_list();
    serde_json::json!({
        "success": true,
        "presets": presets
    })
}

#[tauri::command]
fn delete_preset(preset_id: String, hytale_dir: String) -> serde_json::Value {
    let presets = load_installed_presets_list();

    // Find the preset to get its filename
    let preset_to_delete = presets.iter().find(|p| p.id == preset_id);

    if let Some(preset) = preset_to_delete {
        // Delete the actual preset file from the game directory
        let preset_file_path = Path::new(&hytale_dir).join(&preset.filename);
        if preset_file_path.exists() {
            let _ = fs::remove_file(&preset_file_path);
        }

        // Remove from installed list
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
fn activate_preset(preset_id: String, hytale_dir: String) -> serde_json::Value {
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
        // Update ReShade.ini to use this preset
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

// ============== Update Check Commands ==============

#[tauri::command]
async fn check_for_updates() -> serde_json::Value {
    let current_version = env!("CARGO_PKG_VERSION");

    let client = reqwest::Client::new();
    let response = match client
        .get(GITHUB_LAUNCHER_API_RELEASES_URL)
        .header("User-Agent", "OrbisFX-Launcher")
        .send()
        .await
    {
        Ok(r) => r,
        Err(e) => return serde_json::json!({
            "success": false,
            "error": format!("Failed to check for updates: {}", e)
        })
    };

    match response.json::<serde_json::Value>().await {
        Ok(release) => {
            let latest_version = release["tag_name"]
                .as_str()
                .unwrap_or("unknown")
                .trim_start_matches('v');

            // Find the .exe download URL from assets
            let download_url = release["assets"]
                .as_array()
                .and_then(|assets| {
                    assets.iter().find(|asset| {
                        asset["name"].as_str()
                            .map(|n| n.ends_with(".exe"))
                            .unwrap_or(false)
                    })
                })
                .and_then(|asset| asset["browser_download_url"].as_str())
                .unwrap_or("");

            let update_available = latest_version != current_version && latest_version != "unknown";

            serde_json::json!({
                "success": true,
                "current_version": current_version,
                "latest_version": latest_version,
                "update_available": update_available,
                "release_url": release["html_url"].as_str().unwrap_or(""),
                "download_url": download_url
            })
        }
        Err(e) => serde_json::json!({
            "success": false,
            "error": format!("Failed to parse release info: {}", e)
        })
    }
}

#[tauri::command]
async fn download_update(download_url: String) -> serde_json::Value {
    if download_url.is_empty() {
        return serde_json::json!({
            "success": false,
            "error": "No download URL provided"
        });
    }

    // Get the downloads folder path
    let downloads_dir = match dirs::download_dir() {
        Some(dir) => dir,
        None => return serde_json::json!({
            "success": false,
            "error": "Could not determine downloads folder"
        })
    };

    // Extract filename from URL
    let filename = download_url
        .split('/')
        .last()
        .unwrap_or("OrbisFX-Launcher-update.exe");

    let dest_path = downloads_dir.join(filename);

    // Download the file
    let client = reqwest::Client::new();
    let response = match client
        .get(&download_url)
        .header("User-Agent", "OrbisFX-Launcher")
        .send()
        .await
    {
        Ok(r) => r,
        Err(e) => return serde_json::json!({
            "success": false,
            "error": format!("Failed to download update: {}", e)
        })
    };

    let bytes = match response.bytes().await {
        Ok(b) => b,
        Err(e) => return serde_json::json!({
            "success": false,
            "error": format!("Failed to read update data: {}", e)
        })
    };

    // Save the file
    if let Err(e) = fs::write(&dest_path, &bytes) {
        return serde_json::json!({
            "success": false,
            "error": format!("Failed to save update: {}", e)
        });
    }

    serde_json::json!({
        "success": true,
        "path": dest_path.to_string_lossy().to_string(),
        "message": format!("Update downloaded to {}", dest_path.display())
    })
}

// ============== Import/Export Commands ==============

#[tauri::command]
fn import_local_preset(source_path: String, hytale_dir: String, preset_name: String) -> serde_json::Value {
    let source = Path::new(&source_path);

    if !source.exists() {
        return serde_json::json!({
            "success": false,
            "error": "Source file not found"
        });
    }

    // Get filename from source path
    let filename = source.file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("imported-preset.ini")
        .to_string();

    // Copy file to game directory
    let dest_path = Path::new(&hytale_dir).join(&filename);
    if let Err(e) = fs::copy(&source, &dest_path) {
        return serde_json::json!({
            "success": false,
            "error": format!("Failed to copy preset: {}", e)
        });
    }

    // Generate unique ID from filename
    let id = filename.trim_end_matches(".ini").to_string();

    // Update ReShade.ini to use this preset
    if let Err(e) = update_reshade_preset_path(&hytale_dir, &filename) {
        log::warn!("Failed to update ReShade.ini: {}", e);
    }

    // Track installed preset
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

    // Load existing and add new
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
fn export_preset(preset_id: String, hytale_dir: String, dest_path: String) -> serde_json::Value {
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

// ============== Favorites Commands ==============

#[tauri::command]
fn toggle_favorite(preset_id: String) -> serde_json::Value {
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

// ============== Hotkey Commands ==============

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ReShadeHotkeys {
    pub key_effects: String,      // Toggle effects
    pub key_overlay: String,      // Toggle overlay
    pub key_screenshot: String,   // Take screenshot
    pub key_next_preset: String,  // Next preset
    pub key_prev_preset: String,  // Previous preset
}

fn parse_reshade_key(key_value: &str) -> String {
    // ReShade stores keys as "keycode,ctrl,shift,alt"
    // e.g., "36,0,0,0" = Home key, no modifiers
    let parts: Vec<&str> = key_value.split(',').collect();
    if parts.is_empty() || parts[0] == "0" {
        return "None".to_string();
    }

    let keycode: u32 = parts[0].parse().unwrap_or(0);
    let ctrl = parts.get(1).map(|&s| s == "1").unwrap_or(false);
    let shift = parts.get(2).map(|&s| s == "1").unwrap_or(false);
    let alt = parts.get(3).map(|&s| s == "1").unwrap_or(false);

    let key_name = match keycode {
        8 => "Backspace", 9 => "Tab", 13 => "Enter", 19 => "Pause",
        20 => "CapsLock", 27 => "Escape", 32 => "Space",
        33 => "PageUp", 34 => "PageDown", 35 => "End", 36 => "Home",
        37 => "Left", 38 => "Up", 39 => "Right", 40 => "Down",
        44 => "PrintScreen", 45 => "Insert", 46 => "Delete",
        48..=57 => return format_key_with_mods((keycode - 48).to_string().as_str(), ctrl, shift, alt),
        65..=90 => return format_key_with_mods(&((keycode - 65 + 65) as u8 as char).to_string(), ctrl, shift, alt),
        96..=105 => return format_key_with_mods(&format!("Num{}", keycode - 96), ctrl, shift, alt),
        106 => "Num*", 107 => "Num+", 109 => "Num-", 110 => "Num.", 111 => "Num/",
        112..=123 => return format_key_with_mods(&format!("F{}", keycode - 111), ctrl, shift, alt),
        144 => "NumLock", 145 => "ScrollLock",
        186 => ";", 187 => "=", 188 => ",", 189 => "-", 190 => ".", 191 => "/", 192 => "`",
        219 => "[", 220 => "\\", 221 => "]", 222 => "'",
        _ => return format!("Key{}", keycode),
    };

    format_key_with_mods(key_name, ctrl, shift, alt)
}

fn format_key_with_mods(key: &str, ctrl: bool, shift: bool, alt: bool) -> String {
    let mut result = String::new();
    if ctrl { result.push_str("Ctrl+"); }
    if shift { result.push_str("Shift+"); }
    if alt { result.push_str("Alt+"); }
    result.push_str(key);
    result
}

#[tauri::command]
fn get_reshade_hotkeys(hytale_dir: String) -> serde_json::Value {
    let reshade_ini_path = Path::new(&hytale_dir).join("ReShade.ini");

    if !reshade_ini_path.exists() {
        return serde_json::json!({
            "success": false,
            "error": "ReShade.ini not found"
        });
    }

    let content = match fs::read_to_string(&reshade_ini_path) {
        Ok(c) => c,
        Err(e) => return serde_json::json!({
            "success": false,
            "error": format!("Failed to read ReShade.ini: {}", e)
        })
    };

    let mut hotkeys = ReShadeHotkeys {
        key_effects: "None".to_string(),
        key_overlay: "None".to_string(),
        key_screenshot: "None".to_string(),
        key_next_preset: "None".to_string(),
        key_prev_preset: "None".to_string(),
    };

    for line in content.lines() {
        let line = line.trim();
        if line.starts_with("KeyEffects=") {
            hotkeys.key_effects = parse_reshade_key(&line[11..]);
        } else if line.starts_with("KeyOverlay=") {
            hotkeys.key_overlay = parse_reshade_key(&line[11..]);
        } else if line.starts_with("KeyScreenshot=") {
            hotkeys.key_screenshot = parse_reshade_key(&line[14..]);
        } else if line.starts_with("KeyNextPreset=") {
            hotkeys.key_next_preset = parse_reshade_key(&line[14..]);
        } else if line.starts_with("KeyPreviousPreset=") {
            hotkeys.key_prev_preset = parse_reshade_key(&line[18..]);
        }
    }

    serde_json::json!({
        "success": true,
        "hotkeys": hotkeys
    })
}

// ============== App Entry Point ==============

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_process::init())
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_http::init())
        .plugin(tauri_plugin_fs::init())
        .setup(|app| {
            if cfg!(debug_assertions) {
                app.handle().plugin(
                    tauri_plugin_log::Builder::default()
                        .level(log::LevelFilter::Info)
                        .build(),
                )?;
            }
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            validate_path,
            install_reshade,
            uninstall_reshade,
            save_settings,
            load_settings,
            launch_game,
            toggle_reshade,
            fetch_presets,
            download_preset,
            get_installed_presets,
            delete_preset,
            activate_preset,
            check_for_updates,
            download_update,
            import_local_preset,
            export_preset,
            toggle_favorite,
            get_reshade_hotkeys
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}