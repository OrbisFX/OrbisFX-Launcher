#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\pkd_Backdrop.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\pkd_Backdrop.fx"
#line 31
namespace pkd {
#line 33
namespace Backdrop {
#line 35
uniform float2 CFG_CHROMAEX_ORIGIN <
ui_category = "Position";
ui_label = "Origin Point";
ui_type = "slider";
ui_step = 0.001;
ui_min = 0.000; ui_max = 1.000;
ui_tooltip = "The X and Y coordinates of the origin point where the divider is based.";
> = float2(0.5, 0.5);
#line 44
uniform float CFG_CHROMAEX_ROTATION <
ui_category = "Position";
ui_label = "Rotation Angle";
ui_type = "slider";
ui_step = 1;
ui_min = 0; ui_max = 360;
ui_tooltip = "What angle should the divider be rotated around the origin point?";
> = 90;
#line 53
uniform float CFG_CHROMAEX_FOREGROUND_LIMIT <
ui_type = "slider";
ui_tooltip = "How far back should the 'foreground' extend?";
ui_label = "Foreground Depth";
ui_min = 0; ui_max = 1.0; ui_step = 0.01;
> = 0.8;
#line 60
uniform float3 CFG_CHROMAEX_COLOR1 <
ui_type = "color";
ui_label = "Color 1";
ui_category = "Color Settings";
> = float3(0.0, 0.0, 0.0);
#line 66
uniform float3 CFG_CHROMAEX_COLOR2 <
ui_type = "color";
ui_label = "Color 2";
ui_category = "Color Settings";
> = float3(1.0, 1.0, 1.0);
#line 72
uniform bool CFG_CHROMAEX_SMOOTH_DIVIDER <
ui_label = "Antialias Divider";
ui_category = "Color Settings";
> = true;
#line 77
float4 GetPosValues(float2 pos)
{
return float4(tex2D(ReShade::BackBuffer, pos).rgb, ReShade::GetLinearizedDepth(pos));
}
#line 82
float3 PS_ChromaEx(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target {
if (ReShade::GetLinearizedDepth(texcoord) < CFG_CHROMAEX_FOREGROUND_LIMIT) {
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
#line 87
const float s = sin(radians(CFG_CHROMAEX_ROTATION));
const float c = cos(radians(CFG_CHROMAEX_ROTATION));
#line 90
const float2 tempCoord = texcoord - CFG_CHROMAEX_ORIGIN;
const float2 rotated = float2(tempCoord.x * c - tempCoord.y * s, tempCoord.x * s + tempCoord.y * c) + CFG_CHROMAEX_ORIGIN;
#line 93
if (CFG_CHROMAEX_SMOOTH_DIVIDER) {
const float2 borderSize = ReShade::GetPixelSize() * 0.5;
if ((rotated.x >= 0.5 - borderSize.x) && (rotated.x <= 0.5 + borderSize.x)) {
return lerp(CFG_CHROMAEX_COLOR1, CFG_CHROMAEX_COLOR2, (rotated.x - (0.5 - borderSize.x)) / (borderSize.x * 2));
}
}
#line 100
if (rotated.x <= 0.5) {
return CFG_CHROMAEX_COLOR1;
}
else {
return CFG_CHROMAEX_COLOR2;
}
}
#line 108
technique pkd_Backdrop
{
pass Backdrop {
VertexShader = PostProcessVS;
PixelShader = PS_ChromaEx;
}
}
}
#line 117
}

