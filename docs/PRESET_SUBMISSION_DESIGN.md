# OrbisFX Preset Submission System - Technical Design

## Overview

This document outlines the technical design for the community preset submission feature, integrating with the existing screenshot gallery and local preset management.

## Key Design Decisions

### 1. Screenshot Selection (Simplified Approach)
Instead of a complex file-watching wizard, users select from their **existing screenshot gallery**:
- Reuses the existing gallery UI and data loading
- Users browse their already-captured screenshots
- Select "before" (vanilla) and "after" (with preset) images
- More practical for users who already have good screenshots

### 2. Image Compression
Automatic compression before upload to minimize storage:
- **JPEG compression** at 80% quality for full images
- **Separate thumbnails** at 300px width, 70% quality
- Target: Stay within Supabase's free 1GB tier

### 3. Preset File Selection
Users select from their **installed local presets**:
- Browse presets from the "My Presets" tab
- Option to indicate if based on official preset (attribution)
- Validates preset file format before submission

---

## Storage Estimates

### Per-Preset Storage Breakdown

| Asset | Original Size | Compressed Size |
|-------|--------------|-----------------|
| Before screenshot (1920x1080) | ~3-5 MB | ~150-250 KB |
| After screenshot (1920x1080) | ~3-5 MB | ~150-250 KB |
| Thumbnail (300px width) | N/A | ~20-40 KB |
| Preset file (.ini) | ~20-100 KB | ~20-100 KB |
| **Total per preset** | ~6-10 MB | **~400-600 KB** |

### Capacity with 1GB Storage

| Scenario | Images/Preset | Storage/Preset | Total Presets |
|----------|---------------|----------------|---------------|
| Minimum (1 comparison) | 2 + thumb | ~400 KB | **~2,500** |
| Average (2 comparisons) | 4 + thumb | ~600 KB | **~1,600** |
| Maximum (5 images) | 5 + thumb | ~800 KB | **~1,200** |

**Recommendation**: Limit to 5 images per preset maximum.

---

## Database Schema

```sql
-- User profiles (linked to Discord OAuth)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  discord_id VARCHAR(255) UNIQUE NOT NULL,
  discord_username VARCHAR(255) NOT NULL,
  discord_discriminator VARCHAR(10),
  discord_avatar_hash VARCHAR(255),
  
  -- Reputation & status
  reputation_score INTEGER DEFAULT 0,
  is_trusted BOOLEAN DEFAULT FALSE,
  is_banned BOOLEAN DEFAULT FALSE,
  is_moderator BOOLEAN DEFAULT FALSE,
  
  -- Stats
  total_submissions INTEGER DEFAULT 0,
  approved_submissions INTEGER DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Community preset submissions
CREATE TABLE community_presets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug VARCHAR(255) UNIQUE NOT NULL,  -- URL-friendly identifier
  author_id UUID REFERENCES user_profiles(id) NOT NULL,
  
  -- Basic metadata
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  long_description TEXT,
  category VARCHAR(100) NOT NULL,
  version VARCHAR(50) DEFAULT '1.0.0',
  
  -- Attribution
  based_on_preset_id VARCHAR(255),  -- Official preset ID if modified
  based_on_preset_name VARCHAR(255),
  
  -- Files (Supabase Storage paths)
  preset_file_path TEXT NOT NULL,
  preset_file_hash VARCHAR(64),  -- SHA256 for integrity
  thumbnail_path TEXT,
  
  -- Status workflow
  status VARCHAR(50) DEFAULT 'pending_review',
  -- Values: draft, pending_review, approved, rejected, reported, archived
  
  rejection_reason TEXT,
  report_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  published_at TIMESTAMPTZ,
  
  -- Search optimization
  search_vector TSVECTOR
);

-- Preset images (before/after comparisons, showcase)
CREATE TABLE community_preset_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  preset_id UUID REFERENCES community_presets(id) ON DELETE CASCADE,
  
  -- Image type and pairing
  image_type VARCHAR(50) NOT NULL,  -- 'before', 'after', 'showcase'
  pair_index INTEGER,  -- Groups before/after pairs (1, 2, 3...)
  
  -- Storage paths
  full_image_path TEXT NOT NULL,
  thumbnail_path TEXT,
  
  -- Metadata
  original_filename VARCHAR(255),
  file_size_bytes INTEGER,
  width INTEGER,
  height INTEGER,
  
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Preset features/tags
CREATE TABLE community_preset_features (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  preset_id UUID REFERENCES community_presets(id) ON DELETE CASCADE,
  feature TEXT NOT NULL
);

-- Community reports
CREATE TABLE community_preset_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  preset_id UUID REFERENCES community_presets(id) ON DELETE CASCADE,
  reporter_id UUID REFERENCES user_profiles(id),
  
  reason VARCHAR(100) NOT NULL,  -- spam, inappropriate, malicious, broken, other
  details TEXT,
  
  status VARCHAR(50) DEFAULT 'pending',  -- pending, reviewed, dismissed
  reviewed_by UUID REFERENCES user_profiles(id),
  reviewed_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(preset_id, reporter_id)
);

-- Indexes
CREATE INDEX idx_community_presets_status ON community_presets(status);
CREATE INDEX idx_community_presets_author ON community_presets(author_id);
CREATE INDEX idx_community_presets_category ON community_presets(category);
CREATE INDEX idx_community_presets_search ON community_presets USING GIN(search_vector);
CREATE INDEX idx_preset_images_preset ON community_preset_images(preset_id);

-- Full-text search trigger
CREATE OR REPLACE FUNCTION update_preset_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('english', COALESCE(NEW.name, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(NEW.category, '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER preset_search_update
BEFORE INSERT OR UPDATE ON community_presets
FOR EACH ROW EXECUTE FUNCTION update_preset_search_vector();
```

---

## Supabase Storage Structure

```
orbisfx-community/
├── presets/
│   └── {preset_slug}/
│       └── preset.ini
├── images/
│   └── {preset_slug}/
│       ├── thumbnail.jpg          (300px, compressed)
│       ├── before_1.jpg           (full, compressed)
│       ├── after_1.jpg            (full, compressed)
│       ├── before_1_thumb.jpg     (300px thumbnail)
│       ├── after_1_thumb.jpg      (300px thumbnail)
│       └── showcase_1.jpg         (optional extra images)
└── avatars/
    └── {user_id}.jpg              (Discord avatar cache)
```

---

## Image Compression Implementation

### Rust Crate: `image`

```toml
# Cargo.toml
[dependencies]
image = { version = "0.25", default-features = false, features = ["jpeg", "png"] }
```

### Compression Function

```rust
use image::{DynamicImage, ImageFormat, imageops::FilterType};
use std::io::Cursor;

pub struct CompressionResult {
    pub full_image: Vec<u8>,
    pub thumbnail: Vec<u8>,
    pub width: u32,
    pub height: u32,
}

pub fn compress_image(
    image_path: &str,
    jpeg_quality: u8,      // 80 for full, 70 for thumbnails
    thumb_max_width: u32,  // 300px
) -> Result<CompressionResult, String> {
    // Load image
    let img = image::open(image_path)
        .map_err(|e| format!("Failed to open image: {}", e))?;
    
    let (width, height) = img.dimensions();
    
    // Compress full image to JPEG
    let mut full_buffer = Cursor::new(Vec::new());
    img.write_to(&mut full_buffer, ImageFormat::Jpeg)
        .map_err(|e| format!("Failed to encode image: {}", e))?;
    
    // For better quality control, re-encode with specific quality
    let full_image = encode_jpeg(&img, jpeg_quality)?;
    
    // Generate thumbnail
    let thumb_height = (height as f32 * (thumb_max_width as f32 / width as f32)) as u32;
    let thumbnail_img = img.resize(thumb_max_width, thumb_height, FilterType::Lanczos3);
    let thumbnail = encode_jpeg(&thumbnail_img, jpeg_quality.saturating_sub(10))?;
    
    Ok(CompressionResult {
        full_image,
        thumbnail,
        width,
        height,
    })
}

fn encode_jpeg(img: &DynamicImage, quality: u8) -> Result<Vec<u8>, String> {
    let mut buffer = Cursor::new(Vec::new());
    let encoder = image::codecs::jpeg::JpegEncoder::new_with_quality(&mut buffer, quality);
    img.write_with_encoder(encoder)
        .map_err(|e| format!("JPEG encoding failed: {}", e))?;
    Ok(buffer.into_inner())
}
```

---

## UI Flow

### Submission Wizard Steps

```
┌─────────────────────────────────────────────────────────────────┐
│                    SUBMIT YOUR PRESET                           │
│                                                                  │
│  ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐          │
│  │  1   │───│  2   │───│  3   │───│  4   │───│  5   │          │
│  │Login │   │Preset│   │ Info │   │Images│   │Review│          │
│  └──────┘   └──────┘   └──────┘   └──────┘   └──────┘          │
└─────────────────────────────────────────────────────────────────┘
```

#### Step 1: Discord Login
- "Sign in with Discord" button
- Shows username/avatar when authenticated
- Skip if already logged in

#### Step 2: Select Preset File
- Shows list of installed presets from "My Presets"
- Indicates if preset is local or from official repo
- Checkbox: "This is based on: [Official Preset Name]"

#### Step 3: Preset Information
- Name (required, pre-filled from preset)
- Description (required)
- Long description (optional)
- Category dropdown
- Features/tags (multi-select)

#### Step 4: Select Screenshots
- Opens modified screenshot gallery in "selection mode"
- User picks 1-5 images
- For before/after: select 2 images, assign as pair
- Preview with before/after slider

#### Step 5: Review & Submit
- Full preview of how preset will appear
- Accept terms checkbox
- Submit button
- Shows status (pending review / auto-approved)

---

## API Commands (Tauri)

```rust
// Authentication
#[tauri::command]
async fn discord_auth_start() -> Result<String, String>;

#[tauri::command]
async fn discord_auth_callback(code: String) -> Result<UserProfile, String>;

#[tauri::command]
async fn get_current_user() -> Result<Option<UserProfile>, String>;

#[tauri::command]
async fn logout() -> Result<(), String>;

// Preset submission
#[tauri::command]
async fn get_submittable_presets(hytale_dir: String) -> Result<Vec<SubmittablePreset>, String>;

#[tauri::command]
async fn validate_preset_file(file_path: String) -> Result<PresetValidation, String>;

#[tauri::command]
async fn compress_and_upload_image(
    image_path: String, 
    preset_slug: String,
    image_type: String,
    pair_index: Option<i32>
) -> Result<ImageUploadResult, String>;

#[tauri::command]
async fn submit_community_preset(submission: PresetSubmission) -> Result<SubmissionResult, String>;

// Community presets (read)
#[tauri::command]
async fn get_community_presets(
    page: u32,
    per_page: u32,
    category: Option<String>,
    search: Option<String>,
    sort: String
) -> Result<PaginatedPresets, String>;

// User's submissions
#[tauri::command]
async fn get_my_submissions() -> Result<Vec<CommunityPreset>, String>;

#[tauri::command]
async fn update_my_submission(preset_id: String, updates: PresetUpdate) -> Result<(), String>;

#[tauri::command]
async fn delete_my_submission(preset_id: String) -> Result<(), String>;

// Moderation
#[tauri::command]
async fn report_preset(preset_id: String, reason: String, details: Option<String>) -> Result<(), String>;
```

---

## Security Measures

### 1. Rate Limiting
```rust
const MAX_SUBMISSIONS_PER_DAY: u32 = 3;
const MAX_PENDING_SUBMISSIONS: u32 = 5;
const MAX_IMAGES_PER_PRESET: u32 = 5;
const MAX_IMAGE_SIZE_BYTES: u64 = 10_000_000; // 10MB before compression
```

### 2. File Validation
- Only allow `.ini` and `.fx` extensions
- Check file is valid UTF-8 text
- Scan for suspicious patterns (URLs, shell commands)
- Limit file size to 1MB

### 3. Content Moderation
- New users: submissions require manual approval
- Trusted users (3+ approved): auto-publish
- Community reports: auto-hide at 3+ reports
- Ban system linked to Discord account

---

## Implementation Priority

### Phase 1: Core Infrastructure
1. [ ] Add `image` crate for compression
2. [ ] Create Supabase tables (run SQL)
3. [ ] Implement Discord OAuth flow
4. [ ] Create image compression utilities

### Phase 2: Submission Flow
5. [ ] "Submit Preset" button and wizard modal
6. [ ] Preset file selection from installed presets
7. [ ] Screenshot selection mode in gallery
8. [ ] Form for metadata entry

### Phase 3: Community Tab
9. [ ] "Community Presets" tab in Presets page
10. [ ] Fetch and display community presets
11. [ ] Install community presets
12. [ ] "My Submissions" management view

### Phase 4: Moderation
13. [ ] Report system
14. [ ] Admin review dashboard
15. [ ] Trusted user auto-approval

