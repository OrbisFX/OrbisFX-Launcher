//! Settings-related Tauri commands

use std::fs;

use crate::models::AppSettings;
use crate::utils::{get_settings_path};

#[tauri::command]
pub fn save_settings(settings: AppSettings) -> serde_json::Value {
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
pub fn load_settings() -> serde_json::Value {
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

