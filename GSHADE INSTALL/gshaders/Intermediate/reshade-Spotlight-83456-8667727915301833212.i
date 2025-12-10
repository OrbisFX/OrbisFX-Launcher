// SPOTLIGHT_QUANTITY=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Spotlight.fx"
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
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\Spotlight.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Spotlight.fxh"
#line 30
sampler2D sColor {
Texture = ReShade::BackBufferTex;
SRGBTexture = true;
MinFilter = POINT;
MagFilter = POINT;
};
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\Spotlight.fx"
#line 33
uniform int Spotlight_Quantity <
ui_type = "combo";
ui_label = "Number of Spotlights";
ui_tooltip = "The number of Spotlight techniques to generate. Enabling too many of these in a DirectX 9 game or on lower end hardware is a very, very bad idea.";
ui_items =  "1\0"
"2\0"
"3\0"
"4\0"
"5\0"
"6\0"
"7\0"
"8\0"
"9\0"
"10\0"
"11\0"
"12\0"
"13\0"
"14\0"
"15\0"
"16\0"
"17\0"
"18\0"
"19\0"
"20\0";
ui_bind = "SPOTLIGHT_QUANTITY";
> = 0;
#line 64
uniform float uXCenter < ui_category = "Spotlight 1"; ui_category_closed = true; ui_label = "X Position"; ui_type = "slider"; ui_min = -1.0; ui_max = 1.0; ui_tooltip = "X coordinate of beam center. Axes start from upper left screen corner."; > = 0; uniform float uYCenter < ui_category = "Spotlight 1"; ui_label = "Y Position"; ui_type = "slider"; ui_min = -1.0; ui_max = 1.0; ui_tooltip = "Y coordinate of beam center. Axes start from upper left screen corner."; > = 0; uniform float uBrightness < ui_category = "Spotlight 1"; ui_label = "Brightness"; ui_tooltip = "Spotlight halo brightness.\n" "\nDefault: 10.0"; ui_type = "slider"; ui_min = 0.0; ui_max = 100.0; ui_step = 0.01; > = 10.0; uniform float uSize < ui_category = "Spotlight 1"; ui_label = "Size"; ui_tooltip = "Spotlight halo size in pixels.\n" "\nDefault: 420.0"; ui_type = "slider"; ui_min = 10.0; ui_max = 1000.0; ui_step = 1.0; > = 420.0; uniform float3 uColor < ui_category = "Spotlight 1"; ui_label = "Color"; ui_tooltip = "Spotlight halo color.\n" "\nDefault: R:255 G:230 B:200"; ui_type = "color"; > = float3(255, 230, 200) / 255.0; uniform bool uInvertDepthCutoff < ui_category = "Spotlight 1"; ui_label = "Invert Depth Cutoff"; > = 0; uniform float uDepthCutoff < ui_category = "Spotlight 1"; ui_label = "Depth Cutoff"; ui_tooltip = "The distance at which the spotlight is visible.\n" "Only works if the game has depth buffer access."; ui_type = "slider"; ui_min = 0.0; ui_max = 1.0; > = 0.97; uniform float uDistance < ui_category = "Spotlight 1"; ui_label = "Distance"; ui_tooltip = "The distance that the spotlight can illuminate.\n" "Only works if the game has depth buffer access.\n" "\nDefault: 0.1"; ui_type = "slider"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = 0.1; uniform bool uBlendFix < ui_category = "Spotlight 1"; ui_label = "Toggle Blend Fix"; ui_tooltip = "Enable to use the original blending mode."; > = 0; uniform bool uToggleTexture < ui_category = "Spotlight 1"; ui_label = "Toggle Texture"; ui_tooltip = "Enable or disable the spotlight texture."; > = 1; uniform bool uToggleDepth < ui_category = "Spotlight 1"; ui_label = "Toggle Depth"; ui_tooltip = "Enable or disable depth."; > = 1; uniform bool uToggleDepthCutoff < ui_category = "Spotlight 1"; ui_label = "Toggle Depth Cutoff"; ui_tooltip = "Enable or disable depth cutoff."; > = 0; float4 PS_Spotlight(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { const float depth = uInvertDepthCutoff ? ReShade::GetLinearizedDepth(uv).r : 1 - ReShade::GetLinearizedDepth(uv).r; if (!uToggleDepthCutoff || depth < uDepthCutoff) { const float2 res = float2(1920, 1018); const float2 coord = res * (uv - float2(uXCenter, -uYCenter)); const float halo = distance(coord, res * 0.5); float spotlight = uSize - min(halo, uSize); spotlight /= uSize; if (uToggleTexture == 0) { float defects = sin(spotlight * 30.0) * 0.5 + 0.5; defects = lerp(defects, 1.0, spotlight * 2.0); static const float contrast = 0.125; defects = 0.5 * (1.0 - contrast) + defects * contrast; spotlight *= defects * 4.0; } else { spotlight *= 2.0; } if (uToggleDepth == 1) { const float sdepth = pow(max(1.0 - ReShade::GetLinearizedDepth(uv), 0.0), 1.0 / uDistance); spotlight *= sdepth; } float3 colored_spotlight = spotlight * uColor; colored_spotlight *= colored_spotlight * colored_spotlight; const float3 result = 1.0 + colored_spotlight * uBrightness; float3 color = tex2D(sColor, uv).rgb; color *= result; if (!uBlendFix) color = max(color, (result - 1.0) * 0.001); return float4(color, 1.0); } else { discard; } } technique Spotlight { pass { VertexShader = PostProcessVS; PixelShader = PS_Spotlight; SRGBWriteEnable = true; } }

