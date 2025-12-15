//! Image compression utilities for community preset submissions
//!
//! Compresses images to high-quality JPEG format optimized for web display.
//! Uses balanced compression settings that maintain visual quality while
//! keeping file sizes reasonable for fast loading.

use image::{DynamicImage, GenericImageView, imageops::FilterType};
use std::io::Cursor;
use std::path::Path;

// ============== Configuration ==============

/// JPEG quality for full-size images (0-100)
/// 88% provides excellent visual quality with good compression
pub const DEFAULT_FULL_QUALITY: u8 = 88;

/// JPEG quality for thumbnails (0-100)
/// 85% ensures thumbnails remain sharp and clear
pub const DEFAULT_THUMB_QUALITY: u8 = 85;

/// Maximum width for full-size images in pixels
/// Images larger than this will be resized down to reduce file size
pub const DEFAULT_FULL_MAX_WIDTH: u32 = 1920;

/// Maximum width for thumbnails in pixels
/// 480px provides crisp thumbnails on modern high-DPI displays
pub const DEFAULT_THUMB_WIDTH: u32 = 480;

/// Maximum allowed image file size before compression (10MB)
pub const MAX_INPUT_SIZE: u64 = 10_000_000;

// ============== Data Models ==============

#[derive(Debug, Clone)]
pub struct CompressionResult {
    /// Compressed full-size image as JPEG bytes
    pub full_image: Vec<u8>,
    /// Compressed thumbnail as JPEG bytes
    pub thumbnail: Vec<u8>,
    /// Original image width
    pub width: u32,
    /// Original image height
    pub height: u32,
    /// Thumbnail width
    pub thumb_width: u32,
    /// Thumbnail height
    pub thumb_height: u32,
}

#[derive(Debug, Clone)]
pub struct CompressionOptions {
    /// JPEG quality for full-size image (0-100)
    pub full_quality: u8,
    /// JPEG quality for thumbnail (0-100)
    pub thumb_quality: u8,
    /// Maximum width for full-size image (larger images will be resized)
    pub full_max_width: u32,
    /// Maximum width for thumbnail
    pub thumb_max_width: u32,
}

impl Default for CompressionOptions {
    fn default() -> Self {
        Self {
            full_quality: DEFAULT_FULL_QUALITY,
            thumb_quality: DEFAULT_THUMB_QUALITY,
            full_max_width: DEFAULT_FULL_MAX_WIDTH,
            thumb_max_width: DEFAULT_THUMB_WIDTH,
        }
    }
}

// ============== Compression Functions ==============

/// Compress an image from a file path
pub fn compress_image_file(
    image_path: &str,
    options: Option<CompressionOptions>,
) -> Result<CompressionResult, String> {
    let path = Path::new(image_path);
    
    // Check file size
    let metadata = std::fs::metadata(path)
        .map_err(|e| format!("Cannot read file: {}", e))?;
    
    if metadata.len() > MAX_INPUT_SIZE {
        return Err(format!(
            "Image too large: {} bytes (max {} bytes)",
            metadata.len(),
            MAX_INPUT_SIZE
        ));
    }
    
    // Load image
    let img = image::open(path)
        .map_err(|e| format!("Failed to open image: {}", e))?;
    
    compress_image(img, options)
}

/// Compress an image from raw bytes
pub fn compress_image_bytes(
    bytes: &[u8],
    options: Option<CompressionOptions>,
) -> Result<CompressionResult, String> {
    if bytes.len() as u64 > MAX_INPUT_SIZE {
        return Err(format!(
            "Image too large: {} bytes (max {} bytes)",
            bytes.len(),
            MAX_INPUT_SIZE
        ));
    }
    
    let img = image::load_from_memory(bytes)
        .map_err(|e| format!("Failed to load image: {}", e))?;
    
    compress_image(img, options)
}

/// Compress a DynamicImage
fn compress_image(
    img: DynamicImage,
    options: Option<CompressionOptions>,
) -> Result<CompressionResult, String> {
    let opts = options.unwrap_or_default();
    let (orig_width, orig_height) = img.dimensions();
    let aspect = orig_height as f32 / orig_width as f32;

    // Resize full image if it exceeds max width (keeps file sizes reasonable)
    let (full_img, full_width, full_height) = if orig_width > opts.full_max_width {
        let new_width = opts.full_max_width;
        let new_height = (new_width as f32 * aspect) as u32;
        let resized = img.resize(new_width, new_height, FilterType::Lanczos3);
        (resized, new_width, new_height)
    } else {
        (img.clone(), orig_width, orig_height)
    };

    // Compress full image to high-quality JPEG
    let full_image = encode_jpeg(&full_img, opts.full_quality)?;

    // Calculate thumbnail dimensions maintaining aspect ratio
    let thumb_width = orig_width.min(opts.thumb_max_width);
    let thumb_height = (thumb_width as f32 * aspect) as u32;

    // Generate thumbnail with high-quality resampling
    let thumbnail_img = img.resize(thumb_width, thumb_height, FilterType::Lanczos3);
    let thumbnail = encode_jpeg(&thumbnail_img, opts.thumb_quality)?;

    Ok(CompressionResult {
        full_image,
        thumbnail,
        width: full_width,
        height: full_height,
        thumb_width,
        thumb_height,
    })
}

/// Encode image as JPEG with specified quality
fn encode_jpeg(img: &DynamicImage, quality: u8) -> Result<Vec<u8>, String> {
    let mut buffer = Cursor::new(Vec::new());
    
    // Convert to RGB8 for JPEG encoding (no alpha channel)
    let rgb_img = img.to_rgb8();
    
    let encoder = image::codecs::jpeg::JpegEncoder::new_with_quality(&mut buffer, quality);
    
    rgb_img.write_with_encoder(encoder)
        .map_err(|e| format!("JPEG encoding failed: {}", e))?;
    
    Ok(buffer.into_inner())
}

// ============== Hash Utilities ==============

/// Calculate SHA256 hash of bytes
pub fn sha256_hash(data: &[u8]) -> String {
    use sha2::{Sha256, Digest};
    let mut hasher = Sha256::new();
    hasher.update(data);
    let result = hasher.finalize();
    hex_encode(&result)
}

/// Convert bytes to hex string
fn hex_encode(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{:02x}", b)).collect()
}

