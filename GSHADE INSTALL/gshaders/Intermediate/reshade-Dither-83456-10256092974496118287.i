// DITHER_NOQUANTIZATION=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Dither.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\Dither.fx"
#line 41
uniform float fDithering <
ui_label = "Dithering";
ui_type  = "slider";
ui_min   = 0.0;
ui_max   = 1.0;
ui_step  = 0.001;
> = 0.5;
#line 49
uniform float fQuantization <
ui_label   = "Quantization";
ui_tooltip = "Use to simulate lack of colors: 8.0 for 8bits, 16.0 for 16bits etc.\n"
"Set to 0.0 to disable quantization.\n"
"Only enabled if dithering is enabled as well.";
ui_type    = "slider";
ui_min     = 0.0;
ui_max     = 255.0;
ui_step    = 1.0;
> = 0.0;
#line 61
uniform int iDitherMode <
ui_label = "Dither Mode";
ui_type  = "combo";
ui_items = "Add\0Multiply\0";
> = 0;
#line 69
sampler2D sRetroFog_BackBuffer {
Texture = ReShade::BackBufferTex;
SRGBTexture = true;
};
#line 77
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
#line 92
float2 fmod(float2 a, float2 b) {
const float2 c = frac(abs(a / b)) * abs(b);
if (a.r < 0 && a.g < 0)
return -c;
else
return c;
}
#line 101
float dither(float x, float2 uv) {
#line 104
const float2 index = fmod(uv * float2(1920, 1018), 8.0);
const float limit  = (float(get_bayer(int2(index)) + 1) / 64.0) * step(index.x, 8.0);
#line 113
return step(limit, x);
}
#line 116
float get_luma_linear(float3 color) {
return dot(color, float3(0.2126, 0.7152, 0.0722));
}
#line 120
float rand(float2 uv, float t) {
const float seed = dot(uv, float2(12.9898, 78.233));
return frac(sin(seed) * 43758.5453 + t);
}
#line 127
void PS_Dither(
float4 position  : SV_POSITION,
float2 uv        : TEXCOORD,
out float4 color : SV_TARGET
) {
color = tex2D(sRetroFog_BackBuffer, uv);
#line 134
if (fQuantization > 0.0)
color = round(color * fQuantization) / fQuantization;
#line 137
const float luma = get_luma_linear(color.rgb);
const float pattern = dither(luma, uv);
#line 140
if (iDitherMode == 0) 
color.rgb += color.rgb * pattern * fDithering;
else                  
color.rgb *= lerp(1.0, pattern, fDithering);
}
#line 148
technique Dither {
pass {
VertexShader = PostProcessVS;
PixelShader  = PS_Dither;
SRGBWriteEnable = true;
}
}

