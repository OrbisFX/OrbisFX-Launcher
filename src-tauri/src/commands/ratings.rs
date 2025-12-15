//! Preset rating Tauri commands
//!
//! Handles rating presets and fetching rating data from Supabase.

use crate::supabase;

/// Submit or update a rating for a preset
/// 
/// # Arguments
/// * `preset_id` - The unique identifier of the preset
/// * `rating` - Rating value from 1 to 5
#[tauri::command]
pub async fn rate_preset(preset_id: String, rating: i32) -> serde_json::Value {
    // Validate rating range
    if !(1..=5).contains(&rating) {
        return serde_json::json!({
            "success": false,
            "error": "Rating must be between 1 and 5"
        });
    }
    
    match supabase::upsert_rating(&preset_id, rating).await {
        Ok(()) => {
            log::info!("Successfully rated preset {} with {} stars", preset_id, rating);
            serde_json::json!({
                "success": true,
                "message": "Rating submitted successfully"
            })
        }
        Err(e) => {
            log::error!("Failed to rate preset {}: {}", preset_id, e);
            serde_json::json!({
                "success": false,
                "error": e
            })
        }
    }
}

/// Get all rating summaries for presets
/// 
/// Returns average ratings and total counts for all rated presets
#[tauri::command]
pub async fn get_preset_ratings() -> serde_json::Value {
    match supabase::get_all_rating_summaries().await {
        Ok(summaries) => {
            serde_json::json!({
                "success": true,
                "ratings": summaries
            })
        }
        Err(e) => {
            log::error!("Failed to fetch rating summaries: {}", e);
            serde_json::json!({
                "success": false,
                "error": e,
                "ratings": []
            })
        }
    }
}

/// Get the current user's ratings for all presets they've rated
#[tauri::command]
pub async fn get_my_ratings() -> serde_json::Value {
    match supabase::get_user_ratings().await {
        Ok(ratings) => {
            let ratings_map: std::collections::HashMap<String, i32> = ratings.into_iter().collect();
            serde_json::json!({
                "success": true,
                "ratings": ratings_map
            })
        }
        Err(e) => {
            log::error!("Failed to fetch user ratings: {}", e);
            serde_json::json!({
                "success": false,
                "error": e,
                "ratings": {}
            })
        }
    }
}

/// Get the current user's rating for a specific preset
#[tauri::command]
pub async fn get_my_preset_rating(preset_id: String) -> serde_json::Value {
    match supabase::get_user_rating(&preset_id).await {
        Ok(rating) => {
            serde_json::json!({
                "success": true,
                "rating": rating
            })
        }
        Err(e) => {
            log::error!("Failed to fetch user rating for {}: {}", preset_id, e);
            serde_json::json!({
                "success": false,
                "error": e,
                "rating": null
            })
        }
    }
}

/// Get the current device ID (for debugging)
#[tauri::command]
pub fn get_device_id() -> serde_json::Value {
    let device_id = supabase::get_device_id();
    serde_json::json!({
        "success": true,
        "device_id": device_id
    })
}

