//! GShade hotkey reading Tauri commands

use std::fs;
use std::path::Path;

use crate::models::GShadeHotkeys;
use crate::utils::parse_gshade_key;

#[tauri::command]
pub fn get_gshade_hotkeys(hytale_dir: String) -> serde_json::Value {
    let gshade_ini_path = Path::new(&hytale_dir).join("GShade.ini");

    if !gshade_ini_path.exists() {
        return serde_json::json!({
            "success": false,
            "error": "GShade.ini not found"
        });
    }

    let content = match fs::read_to_string(&gshade_ini_path) {
        Ok(c) => c,
        Err(e) => return serde_json::json!({
            "success": false,
            "error": format!("Failed to read GShade.ini: {}", e)
        })
    };

    let mut hotkeys = GShadeHotkeys {
        key_effects: "None".to_string(),
        key_overlay: "None".to_string(),
        key_screenshot: "None".to_string(),
        key_next_preset: "None".to_string(),
        key_prev_preset: "None".to_string(),
    };

    for line in content.lines() {
        let line = line.trim();
        if line.starts_with("KeyEffects=") {
            hotkeys.key_effects = parse_gshade_key(&line[11..]);
        } else if line.starts_with("KeyOverlay=") {
            hotkeys.key_overlay = parse_gshade_key(&line[11..]);
        } else if line.starts_with("KeyScreenshot=") {
            hotkeys.key_screenshot = parse_gshade_key(&line[14..]);
        } else if line.starts_with("KeyNextPreset=") {
            hotkeys.key_next_preset = parse_gshade_key(&line[14..]);
        } else if line.starts_with("KeyPreviousPreset=") {
            hotkeys.key_prev_preset = parse_gshade_key(&line[18..]);
        }
    }

    serde_json::json!({
        "success": true,
        "hotkeys": hotkeys
    })
}

