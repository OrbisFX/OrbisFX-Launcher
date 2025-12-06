//! OrbisFX Launcher - Main library entry point
//!
//! This crate is organized into modules for better incremental compilation:
//! - `models`: Data structures and types
//! - `utils`: Helper functions
//! - `commands`: Tauri command handlers (further split by functionality)
//!
//! Changes to one module won't trigger recompilation of others,
//! significantly improving development iteration speed.

pub mod models;
pub mod utils;
pub mod commands;

// Re-export commands for use in the invoke_handler
use commands::game::{validate_path, install_reshade, uninstall_reshade, launch_game, toggle_reshade};
use commands::settings::{save_settings, load_settings};
use commands::presets::{fetch_presets, download_preset, get_installed_presets, delete_preset, activate_preset, import_local_preset, export_preset, toggle_favorite};
use commands::updates::{check_for_updates, download_update, install_update_and_restart};
use commands::hotkeys::get_reshade_hotkeys;

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
            install_update_and_restart,
            import_local_preset,
            export_preset,
            toggle_favorite,
            get_reshade_hotkeys
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
