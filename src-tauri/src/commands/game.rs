//! Game-related Tauri commands (validation, launch, GShade management)

use std::fs;
use std::io::Write;
use std::path::Path;
use std::process::Command;

use include_dir::{include_dir, Dir};

// Embed the entire GSHADE INSTALL folder into the binary at compile time
static GSHADE_FILES: Dir = include_dir!("$CARGO_MANIFEST_DIR/../GSHADE INSTALL");

/// Recursively extract embedded directory to filesystem
fn extract_dir(dir: &Dir, dest: &Path) -> std::io::Result<()> {
    fs::create_dir_all(dest)?;

    for file in dir.files() {
        let file_path = dest.join(file.path().file_name().unwrap());
        let mut output = fs::File::create(&file_path)?;
        output.write_all(file.contents())?;
    }

    for subdir in dir.dirs() {
        let subdir_name = subdir.path().file_name().unwrap();
        let subdir_dest = dest.join(subdir_name);
        extract_dir(subdir, &subdir_dest)?;
    }

    Ok(())
}

#[tauri::command]
pub fn validate_path(hytale_dir: String) -> serde_json::Value {
    let exe_path = Path::new(&hytale_dir).join("Hytale.exe");
    let exists = exe_path.exists();

    let dll_path = Path::new(&hytale_dir).join("opengl32.dll");
    let disabled_path = Path::new(&hytale_dir).join("opengl32.dll.disabled");
    let runtime_installed = dll_path.exists() || disabled_path.exists();
    let runtime_enabled = dll_path.exists() && !disabled_path.exists();

    serde_json::json!({
        "is_valid": exists,
        "hytale_path": if exists { Some(hytale_dir) } else { None },
        "hytale_version": if exists { Some("unknown") } else { None },
        "gshade_installed": runtime_installed,
        "gshade_enabled": runtime_enabled
    })
}

#[tauri::command]
pub fn install_gshade(hytale_dir: String, _preset_name: Option<String>) -> serde_json::Value {
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

        for file in GSHADE_FILES.files() {
            let file_name = file.path().file_name().unwrap();
            let dest_path = target_path.join(file_name);
            let mut output = fs::File::create(&dest_path)?;
            output.write_all(file.contents())?;
        }

        for subdir in GSHADE_FILES.dirs() {
            let subdir_name = subdir.path().file_name().unwrap();
            let subdir_dest = target_path.join(subdir_name);
            extract_dir(subdir, &subdir_dest)?;
        }

        Ok(())
    })();

    if result.is_ok() {
        serde_json::json!({
            "success": true,
            "message": format!("GShade installed successfully to {}", hytale_dir),
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
pub fn uninstall_gshade(hytale_dir: String) -> serde_json::Value {
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
        Path::new(&hytale_dir).join("GShade.ini"),
        Path::new(&hytale_dir).join("GShadePreset.ini"),
    ];

    for file in files_to_remove {
        let _ = fs::remove_file(&file);
    }

    // Remove all GShade directories
    let dirs_to_remove = vec![
        Path::new(&hytale_dir).join("gshaders"),
        Path::new(&hytale_dir).join("gshade-addons"),
        Path::new(&hytale_dir).join("gshade-presets"),
    ];

    for dir in dirs_to_remove {
        let _ = fs::remove_dir_all(&dir);
    }

    serde_json::json!({
        "success": true,
        "message": format!("GShade uninstalled successfully from {}", hytale_dir)
    })
}

#[tauri::command]
pub fn launch_game(hytale_dir: String) -> serde_json::Value {
    let exe_path = Path::new(&hytale_dir).join("Hytale.exe");
    if !exe_path.exists() {
        return serde_json::json!({
            "success": false,
            "message": "Hytale.exe not found"
        });
    }

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

#[tauri::command]
pub fn toggle_gshade(hytale_dir: String, enabled: bool) -> serde_json::Value {
    let dll_path = Path::new(&hytale_dir).join("opengl32.dll");
    let disabled_path = Path::new(&hytale_dir).join("opengl32.dll.disabled");

    if enabled {
        if disabled_path.exists() {
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
        if dll_path.exists() {
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

