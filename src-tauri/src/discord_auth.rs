//! Discord OAuth2 authentication module
//!
//! Handles Discord OAuth flow for community preset submissions.
//! Security: Client secret is kept server-side in Supabase Edge Functions.

use once_cell::sync::Lazy;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::fs;
use std::io::{Read, Write};
use std::net::TcpListener;
use std::sync::RwLock;

#[cfg(target_os = "windows")]
use windows::core::Free;

use crate::utils::get_config_dir;
use crate::supabase::CONFIG as SUPABASE_CONFIG;

// ============== Configuration ==============

struct DiscordConfig {
    client_id: String,
    // NOTE: client_secret is now kept server-side only (Supabase Edge Function)
}

impl DiscordConfig {
    fn load() -> Self {
        // Load from .env file for client_id only
        let dev_env_path = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(".env");
        if dev_env_path.exists() {
            dotenv::from_path(&dev_env_path).ok();
        }

        Self {
            client_id: std::env::var("DISCORD_CLIENT_ID")
                .unwrap_or_default(),
        }
    }
}

static DISCORD_CONFIG: Lazy<DiscordConfig> = Lazy::new(DiscordConfig::load);
static HTTP_CLIENT: Lazy<Client> = Lazy::new(Client::new);

// OAuth state for CSRF protection
static OAUTH_STATE: Lazy<RwLock<Option<String>>> = Lazy::new(|| RwLock::new(None));

/// Generate a cryptographically secure random state string for CSRF protection
fn generate_oauth_state() -> String {
    use rand::Rng;
    let mut rng = rand::rng();
    let random_bytes: [u8; 32] = rng.random();
    base64::Engine::encode(&base64::engine::general_purpose::URL_SAFE_NO_PAD, &random_bytes)
}

/// Store the OAuth state for verification
fn set_oauth_state(state: &str) {
    if let Ok(mut guard) = OAUTH_STATE.write() {
        *guard = Some(state.to_string());
    }
}

/// Verify and consume the OAuth state (single-use)
fn verify_oauth_state(state: &str) -> bool {
    if let Ok(mut guard) = OAUTH_STATE.write() {
        if guard.as_ref() == Some(&state.to_string()) {
            *guard = None; // Consume the state
            return true;
        }
    }
    false
}

// Cached auth state
static AUTH_STATE: Lazy<RwLock<Option<DiscordUser>>> = Lazy::new(|| RwLock::new(None));

// ============== Data Models ==============

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiscordUser {
    pub id: String,
    pub username: String,
    pub discriminator: String,
    pub avatar: Option<String>,
    pub banner: Option<String>,
    pub banner_color: Option<String>,
    pub accent_color: Option<u32>,
    pub email: Option<String>,
    pub global_name: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthTokens {
    pub access_token: String,
    pub refresh_token: String,
    pub expires_at: u64,
}

/// Response from our Edge Function (different from Discord's raw response)
#[derive(Debug, Serialize, Deserialize)]
struct EdgeFunctionTokenResponse {
    access_token: String,
    refresh_token: String,
    expires_at: u64,
    token_type: String,
}

// ============== Auth Flow ==============

/// Generate Discord OAuth URL for user to authenticate (includes CSRF state)
pub fn get_auth_url_with_redirect(redirect_uri: &str) -> String {
    let config = &*DISCORD_CONFIG;
    let state = generate_oauth_state();
    set_oauth_state(&state);

    format!(
        "https://discord.com/api/oauth2/authorize?client_id={}&redirect_uri={}&response_type=code&scope=identify&state={}",
        config.client_id,
        urlencoding::encode(redirect_uri),
        urlencoding::encode(&state)
    )
}

/// Legacy function for backward compatibility (deprecated)
#[deprecated(note = "Use get_auth_url_with_redirect instead")]
pub fn get_auth_url() -> String {
    // Use the fixed callback port
    let redirect_uri = format!("http://localhost:{}/callback", OAUTH_CALLBACK_PORT);
    get_auth_url_with_redirect(&redirect_uri)
}

/// Exchange authorization code for tokens via Supabase Edge Function
/// This keeps the client_secret server-side for security
pub async fn exchange_code_secure(code: &str, redirect_uri: &str, state: Option<&str>) -> Result<AuthTokens, String> {
    // Verify CSRF state if provided
    if let Some(s) = state {
        if !verify_oauth_state(s) {
            log::warn!("[OAuth] CSRF state verification failed");
            return Err("Invalid OAuth state - possible CSRF attack".to_string());
        }
    }

    let url = format!("{}/functions/v1/discord-oauth/exchange", SUPABASE_CONFIG.url);

    let body = serde_json::json!({
        "code": code,
        "redirect_uri": redirect_uri,
    });

    let response = HTTP_CLIENT
        .post(&url)
        .header("apikey", &SUPABASE_CONFIG.anon_key)
        .header("Authorization", format!("Bearer {}", SUPABASE_CONFIG.anon_key))
        .header("Content-Type", "application/json")
        .json(&body)
        .send()
        .await
        .map_err(|e| format!("Network error: {}", e))?;

    if !response.status().is_success() {
        let text = response.text().await.unwrap_or_default();
        return Err(format!("Token exchange failed: {}", text));
    }

    let token_resp: EdgeFunctionTokenResponse = response
        .json()
        .await
        .map_err(|e| format!("Parse error: {}", e))?;

    let tokens = AuthTokens {
        access_token: token_resp.access_token,
        refresh_token: token_resp.refresh_token,
        expires_at: token_resp.expires_at,
    };

    // Save tokens securely
    save_tokens(&tokens)?;

    Ok(tokens)
}

/// Legacy exchange function - now uses secure Edge Function
#[deprecated(note = "Use exchange_code_secure instead")]
pub async fn exchange_code(code: &str) -> Result<AuthTokens, String> {
    let redirect_uri = format!("http://localhost:{}/callback", OAUTH_CALLBACK_PORT);
    exchange_code_secure(code, &redirect_uri, None).await
}

/// Get current Discord user info
pub async fn get_user(access_token: &str) -> Result<DiscordUser, String> {
    let response = HTTP_CLIENT
        .get("https://discord.com/api/users/@me")
        .header("Authorization", format!("Bearer {}", access_token))
        .send()
        .await
        .map_err(|e| format!("Network error: {}", e))?;
    
    if !response.status().is_success() {
        return Err("Failed to get user info".to_string());
    }
    
    let user: DiscordUser = response
        .json()
        .await
        .map_err(|e| format!("Parse error: {}", e))?;

    // Cache user
    if let Ok(mut guard) = AUTH_STATE.write() {
        *guard = Some(user.clone());
    }

    // Set Discord ID for secure Supabase requests
    crate::supabase::set_current_discord_id(Some(user.id.clone()));

    Ok(user)
}

/// Get cached user or try to restore from saved tokens
pub async fn get_current_user() -> Option<DiscordUser> {
    // Check cache first
    if let Some(user) = AUTH_STATE.read().ok().and_then(|g| g.clone()) {
        return Some(user);
    }
    
    // Try to restore from saved tokens
    if let Some(tokens) = load_tokens() {
        // Check if expired
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs();
        
        if tokens.expires_at > now {
            if let Ok(user) = get_user(&tokens.access_token).await {
                return Some(user);
            }
        }
    }
    
    None
}

/// Logout - clear cached user and tokens
pub fn logout() {
    if let Ok(mut guard) = AUTH_STATE.write() {
        *guard = None;
    }
    // Clear Discord ID from Supabase security headers
    crate::supabase::set_current_discord_id(None);
    // Remove both legacy and encrypted token files
    let _ = fs::remove_file(get_config_dir().join("discord_auth.json"));
    let _ = fs::remove_file(get_config_dir().join("discord_auth.enc"));
}

// ============== Token Persistence (Windows DPAPI Encrypted) ==============

/// Encrypt data using Windows DPAPI (CryptProtectData)
/// Falls back to no encryption on non-Windows platforms
#[cfg(target_os = "windows")]
fn encrypt_data(data: &[u8]) -> Result<Vec<u8>, String> {
    use windows::Win32::Security::Cryptography::{
        CryptProtectData, CRYPT_INTEGER_BLOB, CRYPTPROTECT_LOCAL_MACHINE,
    };
    use windows::core::PCWSTR;

    let mut data_in = CRYPT_INTEGER_BLOB {
        cbData: data.len() as u32,
        pbData: data.as_ptr() as *mut u8,
    };

    let mut data_out = CRYPT_INTEGER_BLOB {
        cbData: 0,
        pbData: std::ptr::null_mut(),
    };

    // Optional entropy for additional protection
    let entropy_str = "orbisfx-discord-tokens-v2";
    let entropy_bytes = entropy_str.as_bytes();
    let mut entropy = CRYPT_INTEGER_BLOB {
        cbData: entropy_bytes.len() as u32,
        pbData: entropy_bytes.as_ptr() as *mut u8,
    };

    unsafe {
        let result = CryptProtectData(
            &mut data_in,
            PCWSTR::null(),
            Some(&mut entropy),
            None,
            None,
            CRYPTPROTECT_LOCAL_MACHINE,
            &mut data_out,
        );

        if result.is_err() {
            return Err("DPAPI encryption failed".to_string());
        }

        if data_out.pbData.is_null() {
            return Err("DPAPI returned null pointer".to_string());
        }

        let encrypted = std::slice::from_raw_parts(data_out.pbData, data_out.cbData as usize).to_vec();

        // Free the memory allocated by CryptProtectData using HLOCAL's free method
        let mut hlocal = windows::Win32::Foundation::HLOCAL(data_out.pbData as *mut _);
        let _ = hlocal.free();

        Ok(encrypted)
    }
}

/// Decrypt data using Windows DPAPI (CryptUnprotectData)
#[cfg(target_os = "windows")]
fn decrypt_data(data: &[u8]) -> Result<Vec<u8>, String> {
    use windows::Win32::Security::Cryptography::{
        CryptUnprotectData, CRYPT_INTEGER_BLOB, CRYPTPROTECT_LOCAL_MACHINE,
    };

    let mut data_in = CRYPT_INTEGER_BLOB {
        cbData: data.len() as u32,
        pbData: data.as_ptr() as *mut u8,
    };

    let mut data_out = CRYPT_INTEGER_BLOB {
        cbData: 0,
        pbData: std::ptr::null_mut(),
    };

    let entropy_str = "orbisfx-discord-tokens-v2";
    let entropy_bytes = entropy_str.as_bytes();
    let mut entropy = CRYPT_INTEGER_BLOB {
        cbData: entropy_bytes.len() as u32,
        pbData: entropy_bytes.as_ptr() as *mut u8,
    };

    unsafe {
        use windows::core::PWSTR;
        let mut description_ptr: PWSTR = PWSTR::null();

        let result = CryptUnprotectData(
            &mut data_in,
            Some(&mut description_ptr),
            Some(&mut entropy),
            None,
            None,
            CRYPTPROTECT_LOCAL_MACHINE,
            &mut data_out,
        );

        if result.is_err() {
            return Err("DPAPI decryption failed".to_string());
        }

        if data_out.pbData.is_null() {
            return Err("DPAPI returned null pointer".to_string());
        }

        let decrypted = std::slice::from_raw_parts(data_out.pbData, data_out.cbData as usize).to_vec();

        // Free the memory allocated by CryptUnprotectData using HLOCAL's free method
        let mut hlocal = windows::Win32::Foundation::HLOCAL(data_out.pbData as *mut _);
        let _ = hlocal.free();

        Ok(decrypted)
    }
}

/// Fallback for non-Windows platforms (not secure, but maintains compatibility)
#[cfg(not(target_os = "windows"))]
fn encrypt_data(data: &[u8]) -> Result<Vec<u8>, String> {
    log::warn!("DPAPI not available on this platform - tokens stored without encryption");
    Ok(data.to_vec())
}

#[cfg(not(target_os = "windows"))]
fn decrypt_data(data: &[u8]) -> Result<Vec<u8>, String> {
    Ok(data.to_vec())
}

fn save_tokens(tokens: &AuthTokens) -> Result<(), String> {
    let path = get_config_dir().join("discord_auth.dpapi");
    let json = serde_json::to_string(tokens).map_err(|e| e.to_string())?;
    let encrypted = encrypt_data(json.as_bytes())?;
    let encoded = base64::Engine::encode(&base64::engine::general_purpose::STANDARD, &encrypted);
    fs::write(&path, encoded).map_err(|e| e.to_string())?;

    // Remove old files (plaintext and legacy XOR encrypted)
    let _ = fs::remove_file(get_config_dir().join("discord_auth.json"));
    let _ = fs::remove_file(get_config_dir().join("discord_auth.enc"));

    log::info!("[Auth] Tokens saved with DPAPI encryption");
    Ok(())
}

fn load_tokens() -> Option<AuthTokens> {
    // Try DPAPI encrypted file first (new format)
    let dpapi_path = get_config_dir().join("discord_auth.dpapi");
    if let Ok(encoded) = fs::read_to_string(&dpapi_path) {
        if let Ok(encrypted) = base64::Engine::decode(&base64::engine::general_purpose::STANDARD, encoded.trim()) {
            if let Ok(decrypted) = decrypt_data(&encrypted) {
                if let Ok(json) = String::from_utf8(decrypted) {
                    if let Ok(tokens) = serde_json::from_str(&json) {
                        return Some(tokens);
                    }
                }
            }
        }
    }

    // Try legacy XOR encrypted file and migrate
    let legacy_enc_path = get_config_dir().join("discord_auth.enc");
    if let Ok(encoded) = fs::read_to_string(&legacy_enc_path) {
        if let Ok(encrypted) = base64::Engine::decode(&base64::engine::general_purpose::STANDARD, encoded.trim()) {
            // Legacy XOR decryption (inline for migration only)
            let key = legacy_get_encryption_key();
            let decrypted: Vec<u8> = encrypted.iter().enumerate().map(|(i, b)| b ^ key[i % key.len()]).collect();
            if let Ok(json) = String::from_utf8(decrypted) {
                if let Ok(tokens) = serde_json::from_str::<AuthTokens>(&json) {
                    log::info!("[Auth] Migrating tokens from legacy XOR to DPAPI encryption");
                    let _ = save_tokens(&tokens);
                    return Some(tokens);
                }
            }
        }
    }

    // Fall back to legacy plaintext file and migrate
    let old_path = get_config_dir().join("discord_auth.json");
    if let Ok(json) = fs::read_to_string(&old_path) {
        if let Ok(tokens) = serde_json::from_str::<AuthTokens>(&json) {
            log::info!("[Auth] Migrating tokens from plaintext to DPAPI encryption");
            let _ = save_tokens(&tokens);
            return Some(tokens);
        }
    }

    None
}

/// Legacy encryption key derivation (for migration only)
fn legacy_get_encryption_key() -> [u8; 32] {
    use sha2::{Sha256, Digest};
    let device_id = crate::supabase::get_device_id();
    let mut hasher = Sha256::new();
    hasher.update(device_id.as_bytes());
    hasher.update(b"orbisfx-discord-tokens-v1");
    let result = hasher.finalize();
    let mut key = [0u8; 32];
    key.copy_from_slice(&result[..32]);
    key
}

// ============== Avatar & Banner URL ==============

impl DiscordUser {
    pub fn avatar_url(&self) -> String {
        match &self.avatar {
            Some(hash) => format!(
                "https://cdn.discordapp.com/avatars/{}/{}.png?size=128",
                self.id, hash
            ),
            None => {
                let default_index: u64 = self.discriminator.parse().unwrap_or(0) % 5;
                format!("https://cdn.discordapp.com/embed/avatars/{}.png", default_index)
            }
        }
    }

    pub fn banner_url(&self) -> Option<String> {
        self.banner.as_ref().map(|hash| {
            // Check if it's an animated banner (starts with "a_")
            let extension = if hash.starts_with("a_") { "gif" } else { "png" };
            format!(
                "https://cdn.discordapp.com/banners/{}/{}.{}?size=600",
                self.id, hash, extension
            )
        })
    }

    pub fn display_name(&self) -> &str {
        self.global_name.as_deref().unwrap_or(&self.username)
    }
}

// URL encoding helper
mod urlencoding {
    pub fn encode(s: &str) -> String {
        let mut result = String::new();
        for c in s.chars() {
            match c {
                'A'..='Z' | 'a'..='z' | '0'..='9' | '-' | '_' | '.' | '~' => result.push(c),
                _ => {
                    for b in c.to_string().as_bytes() {
                        result.push_str(&format!("%{:02X}", b));
                    }
                }
            }
        }
        result
    }
}

// ============== Local OAuth Callback Server ==============

/// Result of the OAuth flow
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OAuthResult {
    pub success: bool,
    pub user: Option<DiscordUser>,
    pub error: Option<String>,
}

/// Fixed OAuth callback port (must match Discord app redirect URI)
const OAUTH_CALLBACK_PORT: u16 = 39849;

/// Start OAuth flow with local callback server
/// Returns the port number the server is listening on
pub fn start_oauth_server() -> Result<u16, String> {
    // Use a fixed port that matches the Discord app redirect URI
    let listener = TcpListener::bind(format!("127.0.0.1:{}", OAUTH_CALLBACK_PORT))
        .map_err(|e| format!("Failed to bind to port {}: {}", OAUTH_CALLBACK_PORT, e))?;

    let port = OAUTH_CALLBACK_PORT;

    // Store the port for later use
    OAUTH_PORT.store(port as i32, std::sync::atomic::Ordering::SeqCst);

    log::info!("[OAuth] Started callback server on port {}", port);

    // Spawn a thread to handle the callback
    std::thread::spawn(move || {
        handle_oauth_callback(listener);
    });

    Ok(port)
}

static OAUTH_PORT: std::sync::atomic::AtomicI32 = std::sync::atomic::AtomicI32::new(0);
static OAUTH_CODE: Lazy<RwLock<Option<String>>> = Lazy::new(|| RwLock::new(None));

fn handle_oauth_callback(listener: TcpListener) {
    // Set a timeout so we don't block forever
    listener.set_nonblocking(false).ok();

    log::info!("[OAuth] Waiting for callback connection...");

    // Wait for incoming connection (with timeout via OS settings)
    match listener.accept() {
        Ok((mut stream, addr)) => {
            log::info!("[OAuth] Connection from: {}", addr);
            let mut buffer = [0; 4096];
            match stream.read(&mut buffer) {
                Ok(n) => {
                    let request = String::from_utf8_lossy(&buffer[..n]);
                    log::info!("[OAuth] Received request: {} bytes", n);

                    // Parse the code from the request
                    if let Some(code) = extract_code_from_request(&request) {
                        log::info!("[OAuth] Extracted code: {}...", &code[..std::cmp::min(10, code.len())]);
                        // Store the code
                        if let Ok(mut guard) = OAUTH_CODE.write() {
                            *guard = Some(code.clone());
                            log::info!("[OAuth] Code stored successfully");
                        } else {
                            log::error!("[OAuth] Failed to acquire write lock for code");
                        }

                        // Send success response
                        let html = r#"<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>OrbisFX - Login Successful</title>
    <style>
        body {
            font-family: system-ui, -apple-system, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            padding: 40px;
            background: rgba(255,255,255,0.1);
            border-radius: 16px;
            backdrop-filter: blur(10px);
        }
        .success-icon {
            width: 64px;
            height: 64px;
            margin: 0 auto 20px;
            color: #22c55e;
        }
        h1 { margin-bottom: 10px; }
        p { opacity: 0.8; }
    </style>
</head>
<body>
    <div class="container">
        <svg class="success-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <path d="m9 12 2 2 4-4"></path>
        </svg>
        <h1>Login Successful!</h1>
        <p>You can close this window and return to OrbisFX Launcher.</p>
    </div>
</body>
</html>"#;

                        let response = format!(
                            "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
                            html.len(),
                            html
                        );
                        let _ = stream.write_all(response.as_bytes());
                    } else {
                        log::warn!("[OAuth] No code found in request");
                        // Send error response
                        let response = "HTTP/1.1 400 Bad Request\r\nContent-Type: text/plain\r\n\r\nNo authorization code received";
                        let _ = stream.write_all(response.as_bytes());
                    }
                }
                Err(e) => {
                    log::error!("[OAuth] Failed to read from stream: {}", e);
                }
            }
        }
        Err(e) => {
            log::error!("[OAuth] Failed to accept connection: {}", e);
        }
    }
}

/// OAuth callback parameters extracted from request
struct OAuthCallbackParams {
    code: Option<String>,
    state: Option<String>,
}

fn extract_code_from_request(request: &str) -> Option<String> {
    extract_oauth_params(request).code
}

fn extract_oauth_params(request: &str) -> OAuthCallbackParams {
    let mut params = OAuthCallbackParams {
        code: None,
        state: None,
    };

    // Parse GET request for code and state parameters
    let first_line = match request.lines().next() {
        Some(line) => line,
        None => return params,
    };
    let path = match first_line.split_whitespace().nth(1) {
        Some(p) => p,
        None => return params,
    };

    // Look for query parameters
    if let Some(query_start) = path.find('?') {
        let query = &path[query_start + 1..];
        for param in query.split('&') {
            if let Some(code) = param.strip_prefix("code=") {
                params.code = Some(code.to_string());
            } else if let Some(state) = param.strip_prefix("state=") {
                params.state = Some(state.to_string());
            }
        }
    }

    params
}

/// Get the OAuth code if received
pub fn get_oauth_code() -> Option<String> {
    OAUTH_CODE.read().ok().and_then(|g| g.clone())
}

/// Clear the stored OAuth code
pub fn clear_oauth_code() {
    if let Ok(mut guard) = OAUTH_CODE.write() {
        *guard = None;
    }
}

/// Get auth URL with dynamic port (includes CSRF state)
pub fn get_auth_url_with_port(port: u16) -> String {
    let redirect_uri = format!("http://localhost:{}/callback", port);
    get_auth_url_with_redirect(&redirect_uri)
}

/// Exchange code using dynamic redirect URI (via secure Edge Function)
pub async fn exchange_code_with_port(code: &str, port: u16) -> Result<AuthTokens, String> {
    let redirect_uri = format!("http://localhost:{}/callback", port);
    // Note: state verification happens in the callback handler
    exchange_code_secure(code, &redirect_uri, None).await
}

/// Refresh access token via Edge Function
pub async fn refresh_access_token(refresh_token: &str) -> Result<AuthTokens, String> {
    let url = format!("{}/functions/v1/discord-oauth/refresh", SUPABASE_CONFIG.url);

    let body = serde_json::json!({
        "refresh_token": refresh_token,
    });

    let response = HTTP_CLIENT
        .post(&url)
        .header("apikey", &SUPABASE_CONFIG.anon_key)
        .header("Authorization", format!("Bearer {}", SUPABASE_CONFIG.anon_key))
        .header("Content-Type", "application/json")
        .json(&body)
        .send()
        .await
        .map_err(|e| format!("Network error: {}", e))?;

    if !response.status().is_success() {
        let text = response.text().await.unwrap_or_default();
        return Err(format!("Token refresh failed: {}", text));
    }

    let token_resp: EdgeFunctionTokenResponse = response
        .json()
        .await
        .map_err(|e| format!("Parse error: {}", e))?;

    let tokens = AuthTokens {
        access_token: token_resp.access_token,
        refresh_token: token_resp.refresh_token,
        expires_at: token_resp.expires_at,
    };

    // Save refreshed tokens
    save_tokens(&tokens)?;

    Ok(tokens)
}

