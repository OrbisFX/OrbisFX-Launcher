//! OrbisFX Launcher - Main library entry point
//!
//! This crate is organized into modules for better incremental compilation:
//! - `models`: Data structures and types
//! - `utils`: Helper functions
//! - `commands`: Tauri command handlers (further split by functionality)
//! - `supabase`: Supabase client for rating operations
//! - `discord_auth`: Discord OAuth authentication
//! - `image_compress`: Image compression utilities
//! - `community`: Community preset operations
//!
//! Changes to one module won't trigger recompilation of others,
//! significantly improving development iteration speed.

pub mod models;
pub mod utils;
pub mod commands;
pub mod supabase;
pub mod discord_auth;
pub mod image_compress;
pub mod community;

// Re-export commands for use in the invoke_handler
use commands::game::{validate_path, install_gshade, uninstall_gshade, launch_game, toggle_gshade};
use commands::settings::{save_settings, load_settings};
use commands::presets::{fetch_presets, refresh_presets_cache, download_preset, get_installed_presets, delete_preset, activate_preset, import_local_preset, export_preset, toggle_favorite, cache_github_image, clear_image_cache, update_preset_version, update_preset_name};
use commands::updates::{check_for_updates, download_update, install_update_and_restart};
use commands::hotkeys::get_gshade_hotkeys;
use commands::screenshots::{list_screenshots, toggle_screenshot_favorite, open_screenshots_folder, reveal_screenshot_in_folder, delete_screenshot, get_screenshot_presets};
use commands::ratings::{rate_preset, get_preset_ratings, get_my_ratings, get_my_preset_rating, get_device_id};
use commands::community::{
    discord_get_auth_url, discord_auth_callback, discord_get_current_user, discord_logout,
    compress_image_for_submission, get_preset_file_hash, validate_preset_for_submission,
    discord_start_oauth_server, discord_get_auth_url_with_port, discord_check_oauth_code,
    discord_clear_oauth_code, discord_complete_oauth, fetch_community_presets, fetch_trending_presets, submit_community_preset, download_community_preset
};
use commands::moderation::{
    check_moderator_status, get_pending_presets, get_moderation_stats, approve_preset, reject_preset,
    get_preset_for_moderation, delete_community_preset, get_my_uploads, delete_my_preset, update_my_preset,
    get_user_profile
};

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
            install_gshade,
            uninstall_gshade,
            save_settings,
            load_settings,
            launch_game,
            toggle_gshade,
            fetch_presets,
            refresh_presets_cache,
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
            cache_github_image,
            clear_image_cache,
            update_preset_version,
            update_preset_name,
            get_gshade_hotkeys,
            list_screenshots,
            toggle_screenshot_favorite,
            open_screenshots_folder,
            reveal_screenshot_in_folder,
            delete_screenshot,
            get_screenshot_presets,
            // Rating commands
            rate_preset,
            get_preset_ratings,
            get_my_ratings,
            get_my_preset_rating,
            get_device_id,
            // Community commands
            discord_get_auth_url,
            discord_auth_callback,
            discord_get_current_user,
            discord_logout,
            compress_image_for_submission,
            get_preset_file_hash,
            validate_preset_for_submission,
            discord_start_oauth_server,
            discord_get_auth_url_with_port,
            discord_check_oauth_code,
            discord_clear_oauth_code,
            discord_complete_oauth,
            fetch_community_presets,
            fetch_trending_presets,
            submit_community_preset,
            download_community_preset,
            // Moderation commands
            check_moderator_status,
            get_pending_presets,
            get_moderation_stats,
            approve_preset,
            reject_preset,
            get_preset_for_moderation,
            delete_community_preset,
            get_my_uploads,
            delete_my_preset,
            update_my_preset,
            // Profile commands
            get_user_profile
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
