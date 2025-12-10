//! Utility functions for the OrbisFX Launcher
//!
//! Contains helper functions for file operations, config paths, etc.

use std::fs;
use std::path::PathBuf;

use crate::models::InstalledPreset;

// ============== Config Paths ==============

pub fn get_config_dir() -> PathBuf {
    let config_dir = dirs::config_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join("OrbisFX");
    fs::create_dir_all(&config_dir).ok();
    config_dir
}

pub fn get_settings_path() -> PathBuf {
    get_config_dir().join("settings.json")
}

pub fn get_installed_presets_path() -> PathBuf {
    get_config_dir().join("installed_presets.json")
}

// ============== Preset Management ==============

pub fn load_installed_presets_list() -> Vec<InstalledPreset> {
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

pub fn save_installed_presets_list(presets: &[InstalledPreset]) {
    let path = get_installed_presets_path();
    if let Ok(json) = serde_json::to_string_pretty(presets) {
        let _ = fs::write(&path, json);
    }
}

// ============== Time Utils ==============

pub fn chrono_lite_now() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let duration = SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default();
    format!("{}", duration.as_secs())
}

// ============== GShade Config Utils ==============

pub fn update_gshade_preset_path(hytale_dir: &str, preset_filename: &str) -> Result<(), String> {
    use std::path::Path;

    let gshade_ini_path = Path::new(hytale_dir).join("GShade.ini");

    if !gshade_ini_path.exists() {
        return Err("GShade.ini not found".to_string());
    }

    let content = fs::read_to_string(&gshade_ini_path)
        .map_err(|e| format!("Failed to read GShade.ini: {}", e))?;

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

    fs::write(&gshade_ini_path, new_content)
        .map_err(|e| format!("Failed to write GShade.ini: {}", e))?;

    Ok(())
}

// ============== Hotkey Parsing ==============

pub fn parse_gshade_key(key_value: &str) -> String {
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

