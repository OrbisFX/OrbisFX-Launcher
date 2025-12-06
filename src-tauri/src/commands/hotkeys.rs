//! ReShade hotkey reading Tauri commands

use std::fs;
use std::path::Path;

use crate::models::ReShadeHotkeys;
use crate::utils::parse_reshade_key;

#[tauri::command]
pub fn get_reshade_hotkeys(hytale_dir: String) -> serde_json::Value {
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

