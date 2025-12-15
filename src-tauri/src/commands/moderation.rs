//! Moderation commands for community preset management

use crate::supabase::{CONFIG, secure_post, get_current_discord_id};

/// Helper to get authenticated Discord ID or return error
fn get_authenticated_discord_id() -> Result<String, serde_json::Value> {
    get_current_discord_id().ok_or_else(|| {
        serde_json::json!({ "success": false, "error": "Not authenticated. Please log in with Discord." })
    })
}

/// Helper to validate UUID format
fn validate_uuid(id: &str) -> Result<(), serde_json::Value> {
    uuid::Uuid::parse_str(id).map_err(|_| {
        serde_json::json!({ "success": false, "error": "Invalid preset ID format" })
    })?;
    Ok(())
}

/// Check if the current user is a moderator
#[tauri::command]
pub async fn check_moderator_status(discord_id: String) -> serde_json::Value {
    let url = format!(
        "{}/rest/v1/rpc/is_moderator",
        CONFIG.url
    );

    let body = serde_json::json!({
        "discord_user_id": discord_id
    });

    match secure_post(&url)
        .json(&body)
        .send()
        .await
    {
        Ok(response) => {
            if response.status().is_success() {
                match response.json::<bool>().await {
                    Ok(is_mod) => serde_json::json!({ "success": true, "is_moderator": is_mod }),
                    Err(_) => serde_json::json!({ "success": true, "is_moderator": false })
                }
            } else {
                serde_json::json!({ "success": false, "is_moderator": false, "error": "Failed to check status" })
            }
        }
        Err(e) => serde_json::json!({ "success": false, "is_moderator": false, "error": e.to_string() })
    }
}

/// Get pending presets for moderation
#[tauri::command]
pub async fn get_pending_presets(discord_id: String) -> serde_json::Value {
    // Set Discord ID in header for secure validation
    crate::supabase::set_current_discord_id(Some(discord_id.clone()));

    let url = format!(
        "{}/rest/v1/rpc/get_pending_presets",
        CONFIG.url
    );

    let body = serde_json::json!({
        "p_moderator_discord_id": discord_id
    });

    match secure_post(&url)
        .json(&body)
        .send()
        .await
    {
        Ok(response) => {
            if response.status().is_success() {
                match response.json::<serde_json::Value>().await {
                    Ok(result) => result,
                    Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
                }
            } else {
                let text = response.text().await.unwrap_or_default();
                serde_json::json!({ "success": false, "error": text })
            }
        }
        Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
    }
}

/// Get moderation statistics
#[tauri::command]
pub async fn get_moderation_stats(discord_id: String) -> serde_json::Value {
    crate::supabase::set_current_discord_id(Some(discord_id.clone()));

    let url = format!(
        "{}/rest/v1/rpc/get_moderation_stats",
        CONFIG.url
    );

    let body = serde_json::json!({
        "p_moderator_discord_id": discord_id
    });

    match secure_post(&url)
        .json(&body)
        .send()
        .await
    {
        Ok(response) => {
            if response.status().is_success() {
                match response.json::<serde_json::Value>().await {
                    Ok(result) => result,
                    Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
                }
            } else {
                let text = response.text().await.unwrap_or_default();
                serde_json::json!({ "success": false, "error": text })
            }
        }
        Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
    }
}

/// Approve a preset
#[tauri::command]
pub async fn approve_preset(preset_id: String, discord_id: String) -> serde_json::Value {
    // Validate preset_id format
    if let Err(e) = validate_uuid(&preset_id) {
        return e;
    }
    crate::supabase::set_current_discord_id(Some(discord_id.clone()));

    let url = format!("{}/rest/v1/rpc/approve_preset", CONFIG.url);

    let body = serde_json::json!({
        "p_preset_id": preset_id,
        "p_moderator_discord_id": discord_id
    });

    match secure_post(&url)
        .json(&body)
        .send()
        .await
    {
        Ok(response) => {
            if response.status().is_success() {
                match response.json::<serde_json::Value>().await {
                    Ok(result) => result,
                    Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
                }
            } else {
                let text = response.text().await.unwrap_or_default();
                serde_json::json!({ "success": false, "error": text })
            }
        }
        Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
    }
}

/// Reject a preset with a reason
#[tauri::command]
pub async fn reject_preset(preset_id: String, discord_id: String, reason: Option<String>) -> serde_json::Value {
    // Validate preset_id format
    if let Err(e) = validate_uuid(&preset_id) {
        return e;
    }
    crate::supabase::set_current_discord_id(Some(discord_id.clone()));

    let url = format!("{}/rest/v1/rpc/reject_preset", CONFIG.url);

    let body = serde_json::json!({
        "p_preset_id": preset_id,
        "p_moderator_discord_id": discord_id,
        "p_reason": reason
    });

    match secure_post(&url)
        .json(&body)
        .send()
        .await
    {
        Ok(response) => {
            if response.status().is_success() {
                match response.json::<serde_json::Value>().await {
                    Ok(result) => result,
                    Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
                }
            } else {
                let text = response.text().await.unwrap_or_default();
                serde_json::json!({ "success": false, "error": text })
            }
        }
        Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
    }
}

/// Get a single preset's full details for moderation
#[tauri::command]
pub async fn get_preset_for_moderation(preset_id: String, discord_id: String) -> serde_json::Value {
    // Validate preset_id format
    if let Err(e) = validate_uuid(&preset_id) {
        return e;
    }
    crate::supabase::set_current_discord_id(Some(discord_id.clone()));

    let url = format!("{}/rest/v1/rpc/get_preset_for_moderation", CONFIG.url);

    let body = serde_json::json!({
        "p_preset_id": preset_id,
        "p_moderator_discord_id": discord_id
    });

    match secure_post(&url)
        .json(&body)
        .send()
        .await
    {
        Ok(response) => {
            if response.status().is_success() {
                match response.json::<serde_json::Value>().await {
                    Ok(result) => result,
                    Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
                }
            } else {
                let text = response.text().await.unwrap_or_default();
                serde_json::json!({ "success": false, "error": text })
            }
        }
        Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
    }
}

/// Delete a community preset (moderator only)
#[tauri::command]
pub async fn delete_community_preset(preset_id: String, discord_id: String, reason: Option<String>) -> serde_json::Value {
    // Validate preset_id format
    if let Err(e) = validate_uuid(&preset_id) {
        return e;
    }
    crate::supabase::set_current_discord_id(Some(discord_id.clone()));

    let url = format!("{}/rest/v1/rpc/delete_preset", CONFIG.url);

    let body = serde_json::json!({
        "p_preset_id": preset_id,
        "p_moderator_discord_id": discord_id,
        "p_reason": reason
    });

    match secure_post(&url)
        .json(&body)
        .send()
        .await
    {
        Ok(response) => {
            if response.status().is_success() {
                match response.json::<serde_json::Value>().await {
                    Ok(result) => result,
                    Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
                }
            } else {
                let text = response.text().await.unwrap_or_default();
                serde_json::json!({ "success": false, "error": text })
            }
        }
        Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
    }
}

/// Get user's own uploaded presets
/// Uses stored authenticated Discord ID - no client parameter needed
#[tauri::command]
pub async fn get_my_uploads() -> serde_json::Value {
    // Verify user is authenticated (discord_id is sent via X-Discord-Id header by secure_post)
    let _discord_id = match get_authenticated_discord_id() {
        Ok(id) => id,
        Err(e) => return e,
    };

    let url = format!("{}/rest/v1/rpc/get_my_uploads", CONFIG.url);

    // Note: The database function uses X-Discord-Id header for auth
    let body = serde_json::json!({});

    match secure_post(&url)
        .json(&body)
        .send()
        .await
    {
        Ok(response) => {
            if response.status().is_success() {
                match response.json::<serde_json::Value>().await {
                    Ok(result) => result,
                    Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
                }
            } else {
                let text = response.text().await.unwrap_or_default();
                serde_json::json!({ "success": false, "error": text })
            }
        }
        Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
    }
}

/// Delete user's own preset
/// Uses stored authenticated Discord ID - validates ownership server-side via X-Discord-Id header
#[tauri::command]
pub async fn delete_my_preset(preset_id: String) -> serde_json::Value {
    // Validate inputs
    if let Err(e) = validate_uuid(&preset_id) {
        return e;
    }
    let _discord_id = match get_authenticated_discord_id() {
        Ok(id) => id,
        Err(e) => return e,
    };

    let url = format!("{}/rest/v1/rpc/delete_my_preset", CONFIG.url);

    // Database function uses X-Discord-Id header for auth (added by secure_post)
    let body = serde_json::json!({
        "p_preset_id": preset_id
    });

    match secure_post(&url)
        .json(&body)
        .send()
        .await
    {
        Ok(response) => {
            if response.status().is_success() {
                match response.json::<serde_json::Value>().await {
                    Ok(result) => result,
                    Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
                }
            } else {
                let text = response.text().await.unwrap_or_default();
                serde_json::json!({ "success": false, "error": text })
            }
        }
        Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
    }
}

/// Update user's own preset (puts it back to pending for re-approval)
/// Uses stored authenticated Discord ID - validates ownership server-side via X-Discord-Id header
#[tauri::command]
pub async fn update_my_preset(
    preset_id: String,
    name: Option<String>,
    description: Option<String>,
    long_description: Option<String>,
    category: Option<String>,
    version: Option<String>,
    changelog: Option<String>,
) -> serde_json::Value {
    // Validate inputs
    if let Err(e) = validate_uuid(&preset_id) {
        return e;
    }
    let _discord_id = match get_authenticated_discord_id() {
        Ok(id) => id,
        Err(e) => return e,
    };

    // Validate category if provided
    const VALID_CATEGORIES: &[&str] = &["Realistic", "Vibrant", "Cinematic", "Fantasy", "Minimal", "Vintage", "Other"];
    if let Some(ref cat) = category {
        if !VALID_CATEGORIES.contains(&cat.as_str()) {
            return serde_json::json!({ "success": false, "error": "Invalid category" });
        }
    }

    // Validate version format if provided
    if let Some(ref ver) = version {
        let version_regex = regex::Regex::new(r"^[0-9]+\.[0-9]+\.[0-9]+$").unwrap();
        if !version_regex.is_match(ver) {
            return serde_json::json!({ "success": false, "error": "Invalid version format. Use X.Y.Z" });
        }
    }

    let url = format!("{}/rest/v1/rpc/update_my_preset", CONFIG.url);

    // Database function uses X-Discord-Id header for auth (added by secure_post)
    // Trim string inputs to prevent whitespace-only values
    let body = serde_json::json!({
        "p_preset_id": preset_id,
        "p_name": name.map(|s| s.trim().to_string()).filter(|s| !s.is_empty()),
        "p_description": description.map(|s| s.trim().to_string()).filter(|s| !s.is_empty()),
        "p_long_description": long_description.map(|s| s.trim().to_string()).filter(|s| !s.is_empty()),
        "p_category": category,
        "p_version": version,
        "p_changelog": changelog.map(|s| s.trim().to_string()).filter(|s| !s.is_empty())
    });

    match secure_post(&url)
        .json(&body)
        .send()
        .await
    {
        Ok(response) => {
            if response.status().is_success() {
                match response.json::<serde_json::Value>().await {
                    Ok(result) => result,
                    Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
                }
            } else {
                let text = response.text().await.unwrap_or_default();
                serde_json::json!({ "success": false, "error": text })
            }
        }
        Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
    }
}

/// Get a user's public profile (their approved presets and stats)
#[tauri::command]
pub async fn get_user_profile(discord_id: String) -> serde_json::Value {
    let url = format!("{}/rest/v1/rpc/get_user_profile", CONFIG.url);

    let body = serde_json::json!({
        "p_discord_id": discord_id
    });

    match secure_post(&url)
        .json(&body)
        .send()
        .await
    {
        Ok(response) => {
            let status = response.status();
            if status.is_success() {
                match response.json::<serde_json::Value>().await {
                    Ok(result) => result,
                    Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
                }
            } else {
                let text = response.text().await.unwrap_or_default();
                serde_json::json!({ "success": false, "error": text })
            }
        }
        Err(e) => serde_json::json!({ "success": false, "error": e.to_string() })
    }
}

