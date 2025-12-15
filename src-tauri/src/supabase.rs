//! Supabase client for rating operations
//!
//! Handles all communication with Supabase for preset ratings.

use once_cell::sync::Lazy;
use reqwest::{Client, RequestBuilder};
use serde::{Deserialize, Serialize};
use std::fs;
use std::sync::RwLock;

use crate::utils::get_config_dir;

// ============== Configuration ==============

/// Application version (compiled from tauri.conf.json)
pub const APP_VERSION: &str = env!("CARGO_PKG_VERSION");

/// Supabase configuration loaded from environment
pub struct SupabaseConfig {
    pub url: String,
    pub anon_key: String,
}

impl SupabaseConfig {
    fn load() -> Self {
        // Try to load from .env file first
        let env_path = std::env::current_exe()
            .ok()
            .and_then(|p| p.parent().map(|p| p.to_path_buf()))
            .unwrap_or_default()
            .join(".env");

        // Also try the src-tauri directory during development
        let dev_env_path = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(".env");

        if dev_env_path.exists() {
            dotenv::from_path(&dev_env_path).ok();
        } else if env_path.exists() {
            dotenv::from_path(&env_path).ok();
        }

        const DEFAULT_URL: &str = "https://xvnfgmgfthniadpwrxjw.supabase.co";
        const DEFAULT_KEY: &str = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2bmZnbWdmdGhuaWFkcHdyeGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU0MjIyNjksImV4cCI6MjA4MDk5ODI2OX0.hwSSKzsUQcfRb6zMuQCGyb2uSDZm1IFkCzPlX9pdqr8";

        // Use env var if set and non-empty, otherwise use default
        Self {
            url: std::env::var("SUPABASE_URL")
                .ok()
                .filter(|s| !s.is_empty())
                .unwrap_or_else(|| DEFAULT_URL.to_string()),
            anon_key: std::env::var("SUPABASE_ANON_KEY")
                .ok()
                .filter(|s| !s.is_empty())
                .unwrap_or_else(|| DEFAULT_KEY.to_string()),
        }
    }
}

pub static CONFIG: Lazy<SupabaseConfig> = Lazy::new(SupabaseConfig::load);
static HTTP_CLIENT: Lazy<Client> = Lazy::new(Client::new);

/// Cached Discord ID for authenticated user
static CURRENT_DISCORD_ID: Lazy<RwLock<Option<String>>> = Lazy::new(|| RwLock::new(None));

/// Set the current Discord user ID (called after OAuth)
pub fn set_current_discord_id(discord_id: Option<String>) {
    if let Ok(mut guard) = CURRENT_DISCORD_ID.write() {
        *guard = discord_id;
    }
}

/// Get the current Discord user ID
pub fn get_current_discord_id() -> Option<String> {
    CURRENT_DISCORD_ID.read().ok().and_then(|guard| guard.clone())
}

// ============== Security Headers ==============

/// Add security headers to a request builder
/// These headers are used by Supabase RLS policies for authentication
pub fn add_security_headers(builder: RequestBuilder) -> RequestBuilder {
    let device_id = get_device_id();
    let discord_id = get_current_discord_id();

    let mut b = builder
        .header("apikey", &CONFIG.anon_key)
        .header("Authorization", format!("Bearer {}", CONFIG.anon_key))
        .header("X-Device-Id", &device_id)
        .header("X-Client-Version", APP_VERSION);

    // Add Discord ID if user is authenticated
    if let Some(did) = discord_id {
        b = b.header("X-Discord-Id", did);
    }

    b
}

/// Create a GET request with security headers
pub fn secure_get(url: &str) -> RequestBuilder {
    add_security_headers(HTTP_CLIENT.get(url))
}

/// Create a POST request with security headers
pub fn secure_post(url: &str) -> RequestBuilder {
    add_security_headers(HTTP_CLIENT.post(url))
        .header("Content-Type", "application/json")
}

// ============== Device ID Management ==============

/// Cached device ID to avoid repeated file reads
static DEVICE_ID: Lazy<RwLock<Option<String>>> = Lazy::new(|| RwLock::new(None));

/// Get or create a unique device ID for this installation
pub fn get_device_id() -> String {
    // Check cache first
    if let Some(id) = DEVICE_ID.read().ok().and_then(|guard| guard.clone()) {
        return id;
    }
    
    let id_path = get_config_dir().join("device_id");
    
    let id = if id_path.exists() {
        fs::read_to_string(&id_path).unwrap_or_else(|_| generate_device_id())
    } else {
        let new_id = generate_device_id();
        let _ = fs::write(&id_path, &new_id);
        new_id
    };
    
    // Cache the ID
    if let Ok(mut guard) = DEVICE_ID.write() {
        *guard = Some(id.clone());
    }
    
    id
}

/// Generate a new unique device ID
fn generate_device_id() -> String {
    uuid::Uuid::new_v4().to_string()
}

// ============== Data Models ==============

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct PresetRating {
    pub id: Option<String>,
    pub preset_id: String,
    pub user_id: String,
    pub rating: i32,
    pub created_at: Option<String>,
    pub updated_at: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct PresetRatingSummary {
    pub preset_id: String,
    pub average_rating: f64,
    pub total_ratings: i32,
}

// ============== API Operations ==============

/// Submit or update a rating for a preset using the secure RPC function
pub async fn upsert_rating(preset_id: &str, rating: i32) -> Result<(), String> {
    // Use the new secure RPC function which validates device ID from headers
    let url = format!("{}/rest/v1/rpc/submit_rating_secure", CONFIG.url);

    let body = serde_json::json!({
        "p_preset_id": preset_id,
        "p_rating": rating
    });

    let response = secure_post(&url)
        .json(&body)
        .send()
        .await
        .map_err(|e| format!("Network error: {}", e))?;

    if response.status().is_success() {
        let result: serde_json::Value = response.json().await.unwrap_or_default();
        if result.get("success").and_then(|v| v.as_bool()).unwrap_or(false) {
            Ok(())
        } else {
            let error = result.get("error").and_then(|v| v.as_str()).unwrap_or("Unknown error");
            Err(error.to_string())
        }
    } else {
        let status = response.status();
        let text = response.text().await.unwrap_or_default();
        Err(format!("API error {}: {}", status, text))
    }
}

/// Get all rating summaries for presets
pub async fn get_all_rating_summaries() -> Result<Vec<PresetRatingSummary>, String> {
    let url = format!("{}/rest/v1/preset_rating_summaries?select=*", CONFIG.url);

    let response = secure_get(&url)
        .send()
        .await
        .map_err(|e| format!("Network error: {}", e))?;

    if response.status().is_success() {
        response
            .json::<Vec<PresetRatingSummary>>()
            .await
            .map_err(|e| format!("Parse error: {}", e))
    } else {
        Ok(vec![]) // Return empty on error
    }
}

/// Get the current user's rating for a specific preset
pub async fn get_user_rating(preset_id: &str) -> Result<Option<i32>, String> {
    let device_id = get_device_id();
    let url = format!(
        "{}/rest/v1/preset_ratings?preset_id=eq.{}&user_id=eq.{}&select=rating",
        CONFIG.url, preset_id, device_id
    );

    let response = secure_get(&url)
        .send()
        .await
        .map_err(|e| format!("Network error: {}", e))?;

    if response.status().is_success() {
        let ratings: Vec<serde_json::Value> = response
            .json()
            .await
            .map_err(|e| format!("Parse error: {}", e))?;

        Ok(ratings.first().and_then(|r| r["rating"].as_i64()).map(|r| r as i32))
    } else {
        Ok(None)
    }
}

/// Get all ratings by the current user
pub async fn get_user_ratings() -> Result<Vec<(String, i32)>, String> {
    let device_id = get_device_id();
    let url = format!(
        "{}/rest/v1/preset_ratings?user_id=eq.{}&select=preset_id,rating",
        CONFIG.url, device_id
    );

    let response = secure_get(&url)
        .send()
        .await
        .map_err(|e| format!("Network error: {}", e))?;

    if response.status().is_success() {
        let ratings: Vec<serde_json::Value> = response
            .json()
            .await
            .map_err(|e| format!("Parse error: {}", e))?;

        Ok(ratings
            .iter()
            .filter_map(|r| {
                let preset_id = r["preset_id"].as_str()?.to_string();
                let rating = r["rating"].as_i64()? as i32;
                Some((preset_id, rating))
            })
            .collect())
    } else {
        Ok(vec![])
    }
}

/// Check client version with the server
pub async fn check_client_version() -> Result<serde_json::Value, String> {
    let url = format!("{}/rest/v1/rpc/check_client_version", CONFIG.url);

    let response = secure_post(&url)
        .json(&serde_json::json!({}))
        .send()
        .await
        .map_err(|e| format!("Network error: {}", e))?;

    if response.status().is_success() {
        response.json().await.map_err(|e| format!("Parse error: {}", e))
    } else {
        Ok(serde_json::json!({"allowed": true})) // Fail open for backward compat
    }
}

// ============== Helpers ==============

fn chrono_now_iso() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let duration = SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default();
    let secs = duration.as_secs();
    // Simple ISO 8601 format
    format!("1970-01-01T00:00:00Z").replace("1970-01-01T00:00:00Z", 
        &format!("{}", chrono_from_unix(secs)))
}

fn chrono_from_unix(secs: u64) -> String {
    // Convert unix timestamp to ISO 8601
    let days = secs / 86400;
    let remaining = secs % 86400;
    let hours = remaining / 3600;
    let minutes = (remaining % 3600) / 60;
    let seconds = remaining % 60;
    
    // Approximate date calculation (not perfect but good enough for timestamps)
    let mut year = 1970u64;
    let mut remaining_days = days;
    
    loop {
        let days_in_year = if is_leap_year(year) { 366 } else { 365 };
        if remaining_days < days_in_year {
            break;
        }
        remaining_days -= days_in_year;
        year += 1;
    }
    
    let months = [31, if is_leap_year(year) { 29 } else { 28 }, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    let mut month = 1u64;
    for days_in_month in months {
        if remaining_days < days_in_month {
            break;
        }
        remaining_days -= days_in_month;
        month += 1;
    }
    let day = remaining_days + 1;
    
    format!("{:04}-{:02}-{:02}T{:02}:{:02}:{:02}Z", year, month, day, hours, minutes, seconds)
}

fn is_leap_year(year: u64) -> bool {
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
}

