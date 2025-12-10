#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Color_Balance.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 57
namespace ReShade
{
float GetAspectRatio() { return 1920 * (1.0 / 1018); }
float2 GetPixelSize() { return float2((1.0 / 1920), (1.0 / 1018)); }
float2 GetScreenSize() { return float2(1920, 1018); }
#line 67
texture BackBufferTex : COLOR;
texture DepthBufferTex : DEPTH;
#line 70
sampler BackBuffer { Texture = BackBufferTex; };
sampler DepthBuffer { Texture = DepthBufferTex; };
#line 74
float GetLinearizedDepth(float2 texcoord)
{
#line 82
texcoord.x /= 1;
texcoord.y /= 1;
#line 86
 
texcoord.x -= 0 / 2.000000001;
#line 92
texcoord.y += 0 / 2.000000001;
#line 94
float depth = tex2Dlod(DepthBuffer, float4(texcoord, 0, 0)).x * 1;
#line 103
const float N = 1.0;
depth /= 1000.0 - depth * (1000.0 - N);
#line 106
return depth;
}
}
#line 112
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 119
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 124
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Color_Balance.fx"
#line 31
namespace pd80_colorbalance
{
#line 36
uniform bool preserve_luma <
ui_label = "Preserve Luminosity";
ui_tooltip = "Preserve Luminosity";
ui_category = "Color Balance";
> = true;
uniform int separation_mode <
ui_label = "Luma Separation Mode";
ui_tooltip = "Luma Separation Mode";
ui_category = "Color Balance";
ui_type = "combo";
ui_items = "Harsh Separation\0Smooth Separation\0";
> = 0;
uniform float s_RedShift <
ui_label = "Cyan <--> Red";
ui_tooltip = "Shadows: Cyan <--> Red";
ui_category = "Shadows";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float s_GreenShift <
ui_label = "Magenta <--> Green";
ui_tooltip = "Shadows: Magenta <--> Green";
ui_category = "Shadows";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float s_BlueShift <
ui_label = "Yellow <--> Blue";
ui_tooltip = "Shadows: Yellow <--> Blue";
ui_category = "Shadows";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float m_RedShift <
ui_label = "Cyan <--> Red";
ui_tooltip = "Midtones: Cyan <--> Red";
ui_category = "Midtones";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float m_GreenShift <
ui_label = "Magenta <--> Green";
ui_tooltip = "Midtones: Magenta <--> Green";
ui_category = "Midtones";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float m_BlueShift <
ui_label = "Yellow <--> Blue";
ui_tooltip = "Midtones: Yellow <--> Blue";
ui_category = "Midtones";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float h_RedShift <
ui_label = "Cyan <--> Red";
ui_tooltip = "Highlights: Cyan <--> Red";
ui_category = "Highlights";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float h_GreenShift <
ui_label = "Magenta <--> Green";
ui_tooltip = "Highlights: Magenta <--> Green";
ui_category = "Highlights";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float h_BlueShift <
ui_label = "Yellow <--> Blue";
ui_tooltip = "Highlights: Yellow <--> Blue";
ui_category = "Highlights";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
#line 130
float3 curve( float3 x )
{
return x * x * ( 3.0f - 2.0f * x );
}
#line 135
float3 ColorBalance( float3 c, float3 shadows, float3 midtones, float3 highlights )
{
#line 138
float luma = dot( c.xyz, float3( 0.333333f, 0.333334f, 0.333333f ));
#line 141
float3 dist_s; float3 dist_h;
#line 143
switch( separation_mode )
{
#line 156
case 0:
{
dist_s.xyz  = curve( max( 1.0f - c.xyz * 2.0f, 0.0f ));
dist_h.xyz  = curve( max(( c.xyz - 0.5f ) * 2.0f, 0.0f ));
} break;
#line 174
case 1:
{
dist_s.xyz  = pow( 1.0f - c.xyz, 4.0f );
dist_h.xyz  = pow( c.xyz, 4.0f );
} break;
}
#line 183
float3 s_rgb = 1.0f;
float3 m_rgb = 1.0f;
float3 h_rgb = 1.0f;
#line 187
if( preserve_luma )
{
s_rgb    = shadows > 0.0f     ? float3( 1.0 - float3( 0.299, 0.587, 0.114 )) * shadows      : float3( dot( float3( 1.0 - float3( 0.299, 0.587, 0.114 )).yz, 0.5 ), dot( float3( 1.0 - float3( 0.299, 0.587, 0.114 )).xz, 0.5 ), dot( float3( 1.0 - float3( 0.299, 0.587, 0.114 )).xy, 0.5 )) * abs( shadows );
m_rgb    = midtones > 0.0f    ? float3( 1.0 - float3( 0.299, 0.587, 0.114 )) * midtones     : float3( dot( float3( 1.0 - float3( 0.299, 0.587, 0.114 )).yz, 0.5 ), dot( float3( 1.0 - float3( 0.299, 0.587, 0.114 )).xz, 0.5 ), dot( float3( 1.0 - float3( 0.299, 0.587, 0.114 )).xy, 0.5 )) * abs( midtones );
h_rgb    = highlights > 0.0f  ? float3( 1.0 - float3( 0.299, 0.587, 0.114 )) * highlights   : float3( dot( float3( 1.0 - float3( 0.299, 0.587, 0.114 )).yz, 0.5 ), dot( float3( 1.0 - float3( 0.299, 0.587, 0.114 )).xz, 0.5 ), dot( float3( 1.0 - float3( 0.299, 0.587, 0.114 )).xy, 0.5 )) * abs( highlights );
}
float3 mids  = saturate( 1.0f - dist_s.xyz - dist_h.xyz );
float3 highs = dist_h.xyz * ( highlights.xyz * h_rgb.xyz * ( 1.0f - luma ));
float3 newc  = c.xyz * ( dist_s.xyz * shadows.xyz * s_rgb.xyz + mids.xyz * midtones.xyz * m_rgb.xyz ) * ( 1.0f - c.xyz ) + highs.xyz;
return saturate( c.xyz + newc.xyz );
}
#line 200
float4 PS_ColorBalance(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color      = tex2D( ReShade::BackBuffer, texcoord );
color.xyz         = saturate( color.xyz );
color.xyz         = ColorBalance( color.xyz, float3( s_RedShift, s_GreenShift, s_BlueShift ),
float3( m_RedShift, m_GreenShift, m_BlueShift ),
float3( h_RedShift, h_GreenShift, h_BlueShift ));
return float4( color.xyz, 1.0f );
}
#line 211
technique prod80_04_ColorBalance
{
pass prod80_pass0
{
VertexShader   = PostProcessVS;
PixelShader    = PS_ColorBalance;
}
}
}

