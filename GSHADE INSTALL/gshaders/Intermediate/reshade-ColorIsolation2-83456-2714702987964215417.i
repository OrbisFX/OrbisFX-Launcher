#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorIsolation2.fx"
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
#line 41 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorIsolation2.fx"
#line 49
uniform float fUITargetHueTwo <
ui_type = "slider";
ui_category = "Setup";
ui_label = "Target Hue";
ui_tooltip = "Set the desired hue.\nEnable \"Show Debug Overlay\" for visualization.";
ui_min = 0.0; ui_max = 360.0; ui_step = 0.5;
> = 0.0;
#line 57
uniform int cUIWindowFunctionTwo <
ui_type = "combo";
ui_category = "Setup";
ui_label = "Window Function";
ui_items = "Gauss\0Triangle\0";
> = 0;
#line 64
uniform float fUIOverlapTwo <
ui_type = "slider";
ui_category = "Setup";
ui_label = "Hue Overlap";
ui_tooltip = "Changes the width of the curve\nto include less or more colors in relation\nto the target hue.\n";
ui_min = 0.001; ui_max = 2.0;
ui_step = 0.001;
> = 0.3;
#line 73
uniform float fUIWindowHeightTwo <
ui_type = "slider";
ui_category = "Setup";
ui_label = "Curve Steepness";
ui_min = 0.0; ui_max = 10.0;
ui_step = 0.01;
> = 1.0;
#line 81
uniform int iUITypeTwo <
ui_type = "combo";
ui_category = "Setup";
ui_label = "Isolate / Reject Hue";
ui_items = "Isolate\0Reject\0";
> = 0;
#line 88
uniform bool bUIShowDiffTwo <
ui_category = "Debug";
ui_label = "Show Hue Difference";
> = false;
#line 93
uniform bool bUIShowDebugOverlayTwo <
ui_label = "Show Debug Overlay";
ui_category = "Debug";
> = false;
#line 98
uniform float2 fUIOverlayPosTwo <
ui_type = "slider";
ui_category = "Debug";
ui_label = "Overlay: Position";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
> = float2(0.0, 0.0);
#line 106
uniform int2 iUIOverlaySizeTwo <
ui_type = "slider";
ui_category = "Debug";
ui_label = "Overlay: Size";
ui_tooltip = "x: width\nz: height";
ui_min = 50; ui_max = 1920;
ui_step = 1;
> = int2(600, 100);
#line 115
uniform float fUIOverlayOpacityTwo <
ui_type = "slider";
ui_category = "Debug";
ui_label = "Overlay Opacity";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
> = 1.0;
#line 125
float3 RGBtoHSVTwo(float3 c) {
const float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
#line 128
float4 p;
if (c.g < c.b)
p = float4(c.bg, K.wz);
else
p = float4(c.gb, K.xy);
#line 134
float4 q;
if (c.r < p.x)
q = float4(p.xyw, c.r);
else
q = float4(c.r, p.yzx);
#line 140
const float d = q.x - min(q.w, q.y);
const float e = 1.0e-10;
return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
#line 145
float3 HSVtoRGBTwo(float3 c) {
const float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
const float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}
#line 151
float MapTwo(float value, float2 span_old, float2 span_new) {
float span_old_diff;
if (abs(span_old.y - span_old.x) < 1e-6)
span_old_diff = 1e-6;
else
span_old_diff = span_old.y - span_old.x;
return lerp(span_new.x, span_new.y, (clamp(value, span_old.x, span_old.y)-span_old.x)/(span_old_diff));
}
#line 163
float CalculateValueTwo(float x, float height, float offset, float overlap) {
float retVal;
#line 167
if(cUIWindowFunctionTwo == 0) {
#line 169
overlap /= 5.0;
retVal = saturate((height * exp(-((x-1.0 - offset) * (x-1.0 - offset)) / (2 * overlap * overlap))) + (height * exp(-((x - offset) * (x - offset)) / (2 * overlap * overlap))) + (height * exp(-((x+1.0 - offset) * (x+1.0 - offset)) / (2 * overlap * overlap))));
}
else {
retVal = saturate(saturate(height * ((2 / overlap) * ((overlap / 2) - abs(x-1.0 - offset)))) + saturate(height * ((2 / overlap) * ((overlap / 2) - abs(x - offset)))) + saturate(height * ((2 / overlap) * ((overlap / 2) - abs(x+1.0 - offset)))));
}
#line 176
if(iUITypeTwo == 1)
return 1.0 - retVal;
#line 179
return retVal;
}
#line 182
float3 DrawDebugOverlayTwo(float3 background, float3 param, float2 pos, int2 size, float opacity, int2 vpos, float2 texcoord) {
float x, y, value, luma;
float3 overlay, hsvStrip;
#line 186
const float2 overlayPos = pos * (float2(1920, 1018) - size);
#line 188
if(all(vpos.xy >= overlayPos) && all(vpos.xy < overlayPos + size))
{
x = MapTwo(texcoord.x, float2(overlayPos.x, overlayPos.x + size.x) / 1920, float2(0.0, 1.0));
y = MapTwo(texcoord.y, float2(overlayPos.y, overlayPos.y + size.y) / 1018, float2(0.0, 1.0));
hsvStrip = HSVtoRGBTwo(float3(x, 1.0, 1.0));
luma = dot(hsvStrip, float3(0.2126, 0.7151, 0.0721));
value = CalculateValueTwo(x, param.z, param.x, 1.0 - param.y);
overlay = lerp(luma.rrr, hsvStrip, value);
overlay = lerp(overlay, 0.0.rrr, exp(-size.y * length(float2(x, 1.0 - y) - float2(x, value))));
background = lerp(background, overlay, opacity);
}
#line 200
return background;
}
#line 203
float3 ColorIsolationTwoPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float3 luma = dot(color, float3(0.2126, 0.7151, 0.0721)).rrr;
const float3 param = float3(fUITargetHueTwo / 360.0, fUIOverlapTwo, fUIWindowHeightTwo);
const float value = CalculateValueTwo(RGBtoHSVTwo(color).x, param.z, param.x, 1.0 - param.y);
float3 retVal = lerp(luma, color, value);
#line 210
if(bUIShowDiffTwo)
retVal = value.rrr;
#line 213
if(bUIShowDebugOverlayTwo)
{
retVal = DrawDebugOverlayTwo(retVal, param, fUIOverlayPosTwo, iUIOverlaySizeTwo, fUIOverlayOpacityTwo, vpos.xy, texcoord);
}
#line 221
return retVal;
#line 223
}
#line 225
technique ColorIsolation2 {
pass {
VertexShader = PostProcessVS;
PixelShader = ColorIsolationTwoPS;
#line 230
}
}

