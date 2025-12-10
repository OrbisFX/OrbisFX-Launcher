//! Data structures and models for the OrbisFX Launcher
//! 
//! Separating models into their own module improves incremental compilation
//! since changes to command implementations won't require recompiling models.

use serde::{Deserialize, Serialize};

// ============== App Settings ==============

/// Theme options for the launcher UI
#[derive(Serialize, Deserialize, Clone, Debug, Default, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum ThemePreference {
    #[default]
    System,
    Light,
    Dark,
    Oled,
}

/// Layout options for list views
#[derive(Serialize, Deserialize, Clone, Debug, Default, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum LayoutPreference {
    Rows,
    #[default]
    Grid,
    Gallery,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct AppSettings {
    pub hytale_path: Option<String>,
    pub gshade_enabled: bool,
    pub last_preset: Option<String>,
    #[serde(default)]
    pub tutorial_completed: bool,
    /// UI theme preference
    #[serde(default)]
    pub theme: ThemePreference,
    /// Layout preference for presets library page
    #[serde(default)]
    pub presets_layout: LayoutPreference,
    /// Layout preference for screenshot gallery page
    #[serde(default)]
    pub gallery_layout: LayoutPreference,
}

impl Default for AppSettings {
    fn default() -> Self {
        Self {
            hytale_path: None,
            gshade_enabled: true,
            last_preset: None,
            tutorial_completed: false,
            theme: ThemePreference::default(),
            presets_layout: LayoutPreference::default(),
            gallery_layout: LayoutPreference::default(),
        }
    }
}

// ============== Preset Structures ==============

/// Per-preset manifest structure (each preset has its own manifest.json)
/// ID and filename are inferred from folder name and .ini file, not from manifest
#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct PresetManifest {
    pub name: String,
    pub author: String,
    pub description: String,
    pub version: String,
    pub category: String,
    #[serde(default)]
    pub long_description: Option<String>,
    #[serde(default)]
    pub features: Option<Vec<String>>,
}

/// GitHub API response for directory listing
#[derive(Deserialize, Debug)]
pub struct GitHubFileEntry {
    pub name: String,
    #[serde(rename = "type")]
    pub file_type: String,
}

/// Full preset info with computed URLs
#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Preset {
    pub id: String,
    pub name: String,
    pub author: String,
    pub description: String,
    pub thumbnail: String,
    pub download_url: String,
    pub version: String,
    pub category: String,
    pub filename: String,
    pub images: Vec<String>,
    #[serde(default)]
    pub long_description: Option<String>,
    #[serde(default)]
    pub features: Option<Vec<String>>,
    /// Vanilla (before) comparison image URL
    #[serde(default)]
    pub vanilla_image: Option<String>,
    /// Toggled (after) comparison image URL
    #[serde(default)]
    pub toggled_image: Option<String>,
}

/// Index file that lists all available presets
#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct PresetIndex {
    pub version: String,
    pub presets: Vec<String>,
}

/// Response structure for the frontend
#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct PresetsResponse {
    pub version: String,
    pub presets: Vec<Preset>,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct InstalledPreset {
    pub id: String,
    pub name: String,
    pub version: String,
    pub filename: String,
    pub installed_at: String,
    pub is_active: bool,
    #[serde(default)]
    pub is_favorite: bool,
    #[serde(default)]
    pub is_local: bool,
    #[serde(default)]
    pub source_path: Option<String>,
}

// ============== GShade Hotkeys ==============

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct GShadeHotkeys {
    pub key_effects: String,
    pub key_overlay: String,
    pub key_screenshot: String,
    pub key_next_preset: String,
    pub key_prev_preset: String,
}

// ============== Screenshot Gallery ==============

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Screenshot {
    /// Unique identifier (filename without extension)
    pub id: String,
    /// Full filename
    pub filename: String,
    /// Full path to the screenshot file
    pub path: String,
    /// Preset name extracted from filename (if available)
    pub preset_name: Option<String>,
    /// Timestamp extracted from filename or file metadata
    pub timestamp: String,
    /// Whether this screenshot is favorited
    #[serde(default)]
    pub is_favorite: bool,
    /// File size in bytes
    pub file_size: u64,
}

