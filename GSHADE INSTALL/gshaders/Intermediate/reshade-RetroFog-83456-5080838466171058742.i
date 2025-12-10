#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\RetroFog.fx"
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
#line 27 "C:\Program Files\GShade\gshade-shaders\Shaders\RetroFog.fx"
#line 38
uniform float fOpacity <
ui_label = "Opacity";
ui_type  = "slider";
ui_min   = 0.0;
ui_max   = 1.0;
ui_step  = 0.001;
> = 1.0;
#line 46
uniform float3 f3Color <
ui_label   = "Fog Color";
ui_tooltip = "Unused if automatic color is enabled.";
ui_type    = "color";
> = float3(0.0, 0.0, 0.0);
#line 52
uniform bool bDithering <
ui_label = "Dithering";
ui_tooltip = "Enable a retro dithering pattern, making the fog pixelated like in old games such as Doom.";
> = false;
#line 57
uniform float fQuantize <
ui_label   = "Quantize";
ui_tooltip = "Use to simulate lack of colors: 8.0 for 8bits, 16.0 for 16bits etc.\n"
"Set to 0.0 to disable quantization.\n"
"Only enabled if dithering is enabled as well.";
ui_type    = "slider";
ui_min     = 0.0;
ui_max     = 255.0;
ui_step    = 1.0;
> = 255.0;
#line 68
uniform float2 f2Curve <
ui_label   = "Fog Curve";
ui_tooltip = "Controls the contrast of fog using start/end values for determining the range.";
ui_type    = "slider";
ui_min     = 0.0;
ui_max     = 1.0;
ui_step    = 0.001;
> = float2(0.0, 1.0);
#line 77
uniform float fStart <
ui_label   = "Fog Start";
ui_tooltip = "Distance at which the fog center is away from the camera.";
ui_type    = "slider";
ui_min     = 0.0;
ui_max     = 1.0;
ui_step    = 0.001;
> = 0.0;
#line 86
uniform bool bCurved <
ui_label = "Curved";
ui_tooltip = "If enabled the fog will curve around the start position, otherwise it'll be completely linear and ignore side distance.";
> = true;
#line 93
sampler2D sRetroFog_BackBuffer {
Texture = ReShade::BackBufferTex;
SRGBTexture = true;
};
#line 100
float get_fog(float2 uv) {
float depth = ReShade::GetLinearizedDepth(uv);
#line 103
if (bCurved) {
depth = distance(
float2(((uv.x - 0.5) * depth * 2.0 + 0.5), depth),
float2(0.5, fStart - 0.45)
);
} else {
depth = distance(depth, fStart - 0.45);
}
#line 112
return smoothstep(f2Curve.x, f2Curve.y, depth);
}
#line 116
int get_bayer(int2 i) {
static const int bayer[8 * 8] = {
0, 48, 12, 60,  3, 51, 15, 63,
32, 16, 44, 28, 35, 19, 47, 31,
8, 56,  4, 52, 11, 59,  7, 55,
40, 24, 36, 20, 43, 27, 39, 23,
2, 50, 14, 62,  1, 49, 13, 61,
34, 18, 46, 30, 33, 17, 45, 29,
10, 58,  6, 54,  9, 57,  5, 53,
42, 26, 38, 22, 41, 25, 37, 21
};
return bayer[i.x + 8 * i.y];
}
#line 131
float dither(float x, float2 uv) {
x *= fOpacity;
#line 134
if (fQuantize > 0.0)
x = round(x * fQuantize) / fQuantize;
#line 137
const float2 index = float2(uv * float2(1920, 1018)) % 8;
float limit;
if (index.x < 8)
limit = float(get_bayer(index) + 1) / 64.0;
else
limit = 0.0;
#line 144
if (x < limit)
return 0.0;
else
return 1.0;
}
#line 150
float3 get_scene_color(float2 uv) {
static const int point_count = 8;
static const float2 points[point_count] = {
float2(0.0, 0.0),
float2(0.0, 0.5),
float2(0.0, 1.0),
float2(0.5, 0.0),
#line 158
float2(0.5, 1.0),
float2(1.0, 0.0),
float2(1.0, 0.5),
float2(1.0, 1.0)
};
#line 164
float3 color = tex2Dlod(sRetroFog_BackBuffer, float4(points[0], 0.0, 0.0)).rgb;
[loop]
for (int i = 1; i < point_count; ++i)
color += tex2Dlod(sRetroFog_BackBuffer, float4(points[i], 0.0, 0.0)).rgb;
#line 169
return color / point_count;
}
#line 174
void PS_RetroFog(
float4 position  : SV_POSITION,
float2 uv        : TEXCOORD,
out float4 color : SV_TARGET
) {
color = tex2D(sRetroFog_BackBuffer, uv);
float fog = get_fog(uv);
#line 182
if (bDithering)
fog = dither(fog, uv);
else
fog *= fOpacity;
#line 187
const float3 fog_color = f3Color;
#line 189
color.rgb = lerp(color.rgb, fog_color, fog);
}
#line 194
technique RetroFog {
pass {
VertexShader = PostProcessVS;
PixelShader  = PS_RetroFog;
SRGBWriteEnable = true;
}
}

