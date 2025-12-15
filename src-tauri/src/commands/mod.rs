//! Tauri command handlers organized by functionality
//!
//! Splitting commands into submodules improves incremental compilation:
//! - Changes to preset commands won't recompile settings commands
//! - Changes to game commands won't recompile update commands
//! - etc.

pub mod game;
pub mod presets;
pub mod settings;
pub mod updates;
pub mod hotkeys;
pub mod screenshots;
pub mod ratings;
pub mod community;
pub mod moderation;

// Re-export all commands for easy access
pub use game::*;
pub use presets::*;
pub use settings::*;
pub use updates::*;
pub use hotkeys::*;
pub use screenshots::*;
pub use ratings::*;
pub use community::*;
pub use moderation::*;

