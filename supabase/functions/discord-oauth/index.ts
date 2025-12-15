// Discord OAuth Token Exchange Edge Function
// This function keeps the client_secret server-side, never exposing it to clients

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const DISCORD_CLIENT_ID = Deno.env.get('DISCORD_CLIENT_ID')!
const DISCORD_CLIENT_SECRET = Deno.env.get('DISCORD_CLIENT_SECRET')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-device-id, x-discord-id, x-client-version',
}

interface TokenRequest {
  code: string
  redirect_uri: string
  state?: string
}

interface RefreshRequest {
  refresh_token: string
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const url = new URL(req.url)
    const action = url.pathname.split('/').pop()

    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const body = await req.json()

    if (action === 'exchange') {
      // Exchange authorization code for tokens
      return await exchangeCode(body as TokenRequest)
    } else if (action === 'refresh') {
      // Refresh access token
      return await refreshToken(body as RefreshRequest)
    } else {
      return new Response(
        JSON.stringify({ error: 'Unknown action' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
  } catch (error) {
    console.error('Discord OAuth error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

async function exchangeCode(request: TokenRequest): Promise<Response> {
  if (!request.code || !request.redirect_uri) {
    return new Response(
      JSON.stringify({ error: 'Missing code or redirect_uri' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const params = new URLSearchParams({
    client_id: DISCORD_CLIENT_ID,
    client_secret: DISCORD_CLIENT_SECRET,
    grant_type: 'authorization_code',
    code: request.code,
    redirect_uri: request.redirect_uri,
  })

  const response = await fetch('https://discord.com/api/oauth2/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: params.toString(),
  })

  if (!response.ok) {
    const errorText = await response.text()
    console.error('Discord token exchange failed:', errorText)
    return new Response(
      JSON.stringify({ error: 'Token exchange failed', details: errorText }),
      { status: response.status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const tokens = await response.json()
  
  // Calculate absolute expiry time
  const expiresAt = Math.floor(Date.now() / 1000) + tokens.expires_in

  return new Response(
    JSON.stringify({
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      expires_at: expiresAt,
      token_type: tokens.token_type,
    }),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

async function refreshToken(request: RefreshRequest): Promise<Response> {
  if (!request.refresh_token) {
    return new Response(
      JSON.stringify({ error: 'Missing refresh_token' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const params = new URLSearchParams({
    client_id: DISCORD_CLIENT_ID,
    client_secret: DISCORD_CLIENT_SECRET,
    grant_type: 'refresh_token',
    refresh_token: request.refresh_token,
  })

  const response = await fetch('https://discord.com/api/oauth2/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: params.toString(),
  })

  if (!response.ok) {
    const errorText = await response.text()
    console.error('Discord token refresh failed:', errorText)
    return new Response(
      JSON.stringify({ error: 'Token refresh failed', details: errorText }),
      { status: response.status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const tokens = await response.json()
  const expiresAt = Math.floor(Date.now() / 1000) + tokens.expires_in

  return new Response(
    JSON.stringify({
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      expires_at: expiresAt,
      token_type: tokens.token_type,
    }),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

