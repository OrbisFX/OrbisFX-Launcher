//! Update check and download Tauri commands

use std::fs;
use std::path::Path;
use std::process::Command;

const GITHUB_LAUNCHER_API_RELEASES_URL: &str = "https://api.github.com/repos/OrbisFX/OrbisFX-Launcher/releases/latest";

#[tauri::command]
pub async fn check_for_updates() -> serde_json::Value {
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
pub async fn download_update(download_url: String) -> serde_json::Value {
    if download_url.is_empty() {
        return serde_json::json!({
            "success": false,
            "error": "No download URL provided"
        });
    }

    let downloads_dir = match dirs::download_dir() {
        Some(dir) => dir,
        None => return serde_json::json!({
            "success": false,
            "error": "Could not determine downloads folder"
        })
    };

    let filename = download_url
        .split('/')
        .last()
        .unwrap_or("OrbisFX-Launcher-update.exe");

    let dest_path = downloads_dir.join(filename);

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

#[tauri::command]
pub async fn install_update_and_restart(update_path: String, app_handle: tauri::AppHandle) -> serde_json::Value {
    let path = Path::new(&update_path);

    if !path.exists() {
        return serde_json::json!({
            "success": false,
            "error": "Update file not found"
        });
    }

    let extension = path.extension()
        .and_then(|e| e.to_str())
        .unwrap_or("");

    if extension.to_lowercase() != "exe" && extension.to_lowercase() != "msi" {
        return serde_json::json!({
            "success": false,
            "error": "Update file is not a valid installer (.exe or .msi)"
        });
    }

    #[cfg(target_os = "windows")]
    {
        match Command::new(&update_path).spawn() {
            Ok(_) => {
                std::thread::sleep(std::time::Duration::from_millis(500));
                app_handle.exit(0);
                serde_json::json!({
                    "success": true,
                    "message": "Update installer launched, application will now close"
                })
            }
            Err(e) => serde_json::json!({
                "success": false,
                "error": format!("Failed to launch installer: {}", e)
            })
        }
    }

    #[cfg(not(target_os = "windows"))]
    {
        serde_json::json!({
            "success": false,
            "error": "Auto-update restart is only supported on Windows"
        })
    }
}

