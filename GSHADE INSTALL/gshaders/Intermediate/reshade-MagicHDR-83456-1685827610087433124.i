// MAGIC_HDR_SRGB_OUTPUT=1
// MAGIC_HDR_SRGB_INPUT=1
// MAGIC_HDR_DOWNSAMPLE=4
// MAGIC_HDR_BLUR_SAMPLES=13
// MAGIC_HDR_ENABLE_ADAPTATION=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MagicHDR.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersAPI.fxh"
#line 4 "C:\Program Files\GShade\gshade-shaders\Shaders\MagicHDR.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersCanvas.fxh"
#line 39
namespace FXShaders
{
#line 50
void FillRect(inout float4 color, float2 coord, float4 rect, float4 fillColor)
{
if (
coord.x >= rect.x && coord.x <= rect.z &&
coord.y >= rect.y && coord.y <= rect.w)
{
color = fillColor;
}
}
#line 66
float4 ConvertToRect(float2 pos, float2 size)
{
return mad(float2(-0.5, 0.5).xxyy, size.xyxy, pos.xyxy);
}
#line 84
bool AABBCollision(float4 a, float4 b)
{
return
a.x < b.z && b.x < a.z &&
a.y < b.w && b.y < a.w;
}
#line 91
}
#line 5 "C:\Program Files\GShade\gshade-shaders\Shaders\MagicHDR.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersCommon.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersMath.fxh"
#line 33
namespace FXShaders
{
#line 98
static const float Pi = 3.14159;
#line 103
static const float DegreesToRadians = Pi / 180.0;
#line 108
static const float RadiansToDegrees = 180.0 / Pi;
#line 117
float2 GetOffsetByAngleDistance(float2 pos, float angle, float distance)
{
float2 cosSin;
sincos(angle, cosSin.y, cosSin.x);
#line 122
return mad(distance, cosSin, pos);
}
#line 132
float2 GetDirectionFromAngleMagnitude(float angle, float magnitude)
{
return GetOffsetByAngleDistance(0.0, angle, magnitude);
}
#line 144
float2 ClampMagnitude(float2 v, float2 minMax) {
if (v.x == 0.0 && v.y == 0.0)
{
return 0.0;
}
else
{
const float mag = length(v);
if (mag < minMax.x)
return 0.0;
else
return (v / mag) * min(mag, minMax.y);
}
}
#line 166
float2 RotatePoint(float2 uv, float angle, float2 pivot)
{
float2 sc;
sincos(DegreesToRadians * angle, sc.x, sc.y);
#line 171
uv -= pivot;
uv = uv.x * sc.yx + float2(-uv.y, uv.y) * sc;
uv += pivot;
#line 175
return uv;
}
#line 178
}
#line 40 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersCommon.fxh"
#line 41
namespace FXShaders
{
#line 48
static const float FloatEpsilon = 0.001;
#line 155
float2 GetResolution()
{
return float2(1920, 1018);
}
#line 163
float2 GetPixelSize()
{
return float2((1.0 / 1920), (1.0 / 1018));
}
#line 171
float GetAspectRatio()
{
return 1920 * (1.0 / 1018);
}
#line 179
float4 GetScreenParams()
{
return float4(GetResolution(), GetPixelSize());
}
#line 195
float2 ScaleCoord(float2 uv, float2 scale, float2 pivot)
{
return (uv - pivot) * scale + pivot;
}
#line 208
float2 ScaleCoord(float2 uv, float2 scale)
{
return ScaleCoord(uv, scale, 0.5);
}
#line 218
float GetLumaGamma(float3 color)
{
return dot(color, float3(0.299, 0.587, 0.114));
}
#line 229
float GetLumaLinear(float3 color)
{
return dot(color, float3(0.2126, 0.7152, 0.0722));
}
#line 242
float3 checkered_pattern(float2 uv, float size, float color_a, float color_b)
{
const float cSize = 32.0;
const float3 cColorA = pow(0.15, 2.2);
const float3 cColorB = pow(0.5, 2.2);
#line 248
uv *= GetResolution();
uv %= cSize;
#line 251
const float half_size = cSize * 0.5;
const float checkered = step(uv.x, half_size) == step(uv.y, half_size);
return (cColorA * checkered) + (cColorB * (1.0 - checkered));
}
#line 262
float3 checkered_pattern(float2 uv)
{
const float Size = 32.0;
const float ColorA = pow(0.15, 2.2);
const float ColorB = pow(0.5, 2.2);
#line 268
return checkered_pattern(uv, Size, ColorA, ColorB);
}
#line 281
float3 ApplySaturation(float3 color, float amount)
{
const float gray = GetLumaLinear(color);
return gray + (color - gray) * amount;
}
#line 292
float GetRandom(float2 uv)
{
#line 297
const float A = 23.2345;
const float B = 84.1234;
const float C = 56758.9482;
#line 301
return frac(sin(dot(uv, float2(A, B))) * C);
}
#line 311
void ScreenVS(
uint id : SV_VERTEXID,
out float4 pos : SV_POSITION,
out float2 uv : TEXCOORD)
{
if (id == 2)
uv.x = 2.0;
else
uv.x = 0.0;
#line 321
if (id == 1)
uv.y = 2.0;
else
uv.y = 0.0;
#line 326
pos = float4(uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 337
float2 CorrectAspectRatio(float2 uv, float a, float b)
{
if (a > b)
{
#line 343
return ScaleCoord(uv, float2(1.0 / a, 1.0));
}
else
{
#line 349
return ScaleCoord(uv, float2(1.0, 1.0 / b));
}
}
#line 353
} 
#line 6 "C:\Program Files\GShade\gshade-shaders\Shaders\MagicHDR.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersConvolution.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersMath.fxh"
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersConvolution.fxh"
#line 35
namespace FXShaders
{
#line 48
float NormalDistribution(float x, float u, float o)
{
o *= o;
#line 52
const float b = ((x - u) * (x - u)) / 2.0 * o;
#line 54
return (1.0 / sqrt(2.0 * Pi * o)) * exp(-(b));
}
#line 65
float Gaussian1D(float x, float o)
{
o *= o;
const float b = (x * x) / (2.0 * o);
return  (1.0 / sqrt(2.0 * Pi * o)) * exp(-b);
}
#line 81
float Gaussian1DFast(float x, float o)
{
#line 85
return exp(-(x * x) / (2.0 * o * o));
}
#line 96
float Gaussian2D(float2 i, float o)
{
o *= o;
const float b = (i.x * i.x + i.y * i.y) / (2.0 * o);
return (1.0 / (2.0 * Pi * o)) * exp(-b);
}
#line 116
float4 GaussianBlur1D(
sampler sp,
float2 uv,
float2 dir,
float sigma,
int samples)
{
const float halfSamples = (samples - 1) * 0.5;
#line 125
float4 color = 0.0;
float accum = 0.0;
#line 128
uv -= halfSamples * dir;
#line 130
[unroll]
for (int i = 0; i < samples; ++i)
{
float weight = Gaussian1DFast(i - halfSamples, sigma);
#line 135
color += tex2D(sp, uv) * weight;
accum += weight;
#line 138
uv += dir;
}
#line 141
return color / accum;
}
#line 157
float4 GaussianBlur2D(
sampler sp,
float2 uv,
float2 scale,
float sigma,
int2 samples)
{
const float2 halfSamples = samples * 0.5;
#line 166
float4 color = 0.0;
float accum = 0.0;
#line 169
uv -= halfSamples * scale;
#line 171
[unroll]
for (int x = 0; x < samples.x; ++x)
{
float initX = uv.x;
#line 176
[unroll]
for (int y = 0; y < samples.y; ++y)
{
float2 pos = float2(x, y);
float weight = Gaussian2D(abs(pos - halfSamples), sigma);
#line 182
color += tex2D(sp, uv) * weight;
accum += weight;
#line 185
uv.x += scale.x;
}
#line 188
uv.x = initX;
uv.y += scale.y;
}
#line 192
return color / accum;
}
#line 195
float4 LinearBlur1D(sampler sp, float2 uv, float2 dir, int samples)
{
const float halfSamples = (samples - 1) * 0.5;
uv -= halfSamples * dir;
#line 200
float4 color = 0.0;
#line 202
[unroll]
for (int i = 0; i < samples; ++i)
{
color += tex2D(sp, uv);
uv += dir;
}
#line 209
return color / samples;
}
#line 212
float4 MaxBlur1D(sampler sp, float2 uv, float2 dir, int samples)
{
const float halfSamples = (samples - 1) * 0.5;
uv -= halfSamples * dir;
#line 217
float4 color = 0.0;
#line 219
[unroll]
for (int i = 0; i < samples; ++i)
{
color = max(color, tex2D(sp, uv));
uv += dir;
}
#line 226
return color;
}
#line 229
float4 SharpBlur1D(sampler sp, float2 uv, float2 dir, int samples, float sharpness)
{
static const float halfSamples = (samples - 1) * 0.5;
static const float weight = 1.0 / samples;
#line 234
uv -= halfSamples * dir;
#line 236
float4 color = 0.0;
#line 238
[unroll]
for (int i = 0; i < samples; ++i)
{
float4 pixel = tex2D(sp, uv);
color = lerp(color + pixel * weight, max(color, pixel), sharpness);
uv += dir;
}
#line 246
return color;
}
#line 249
} 
#line 7 "C:\Program Files\GShade\gshade-shaders\Shaders\MagicHDR.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersMath.fxh"
#line 8 "C:\Program Files\GShade\gshade-shaders\Shaders\MagicHDR.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersTonemap.fxh"
#line 41
namespace FXShaders { namespace Tonemap
{
#line 44
namespace Type
{
static const int Reinhard = 0;
static const int Uncharted2Filmic = 1;
static const int BakingLabACES = 2;
static const int NarkowiczACES = 3;
static const int Unreal3 = 4;
static const int Lottes = 5;
}
#line 54
namespace Reinhard
{
#line 61
float3 Apply(float3 color)
{
return color / (1.0 + color);
}
#line 71
float3 Inverse(float3 color)
{
return -(color / min(color - 1.0, -0.1));
}
#line 85
float3 InverseOld(float3 color, float w)
{
return color / max(1.0 - color, w);
}
#line 99
float3 InverseOldLum(float3 color, float w)
{
const float lum = max(color.r, max(color.g, color.b));
return color * (lum / max(1.0 - lum, w));
}
}
#line 106
namespace Uncharted2Filmic
{
#line 109
static const float A = 0.15;
#line 112
static const float B = 0.50;
#line 115
static const float C = 0.10;
#line 118
static const float D = 0.20;
#line 121
static const float E = 0.02;
#line 124
static const float F = 0.30;
#line 126
float3 Apply(float3 color)
{
return (
(color * (A * color + C * B) + D * E) /
(color * (A * color + B) + D * F)
) - E / F;
}
#line 134
float3 Inverse(float3 color)
{
return abs(
((B * C * F - B * E - B * F * color) -
sqrt(
pow(abs(-B * C * F + B * E + B * F * color), 2.0) -
4.0 * D * (F * F) * color * (A * E + A * F * color - A * F))) /
(2.0 * A * (E + F * color - F)));
}
}
#line 145
namespace BakingLabACES
{
#line 148
static const float3x3 ACESInputMat = float3x3
(
0.59719, 0.35458, 0.04823,
0.07600, 0.90834, 0.01566,
0.02840, 0.13383, 0.83777
);
#line 156
static const float3x3 ACESOutputMat = float3x3
(
1.60475, -0.53108, -0.07367,
-0.10208,  1.10813, -0.00605,
-0.00327, -0.07276,  1.07602
);
#line 163
float3 RRTAndODTFit(float3 v)
{
return (v * (v + 0.0245786f) - 0.000090537f) / (v * (0.983729f * v + 0.4329510f) + 0.238081f);
}
#line 168
float3 ACESFitted(float3 color)
{
color = mul(ACESInputMat, color);
#line 173
color = RRTAndODTFit(color);
#line 175
color = mul(ACESOutputMat, color);
#line 178
color = saturate(color);
#line 180
return color;
}
#line 183
static const float A = 0.0245786;
static const float B = 0.000090537;
static const float C = 0.983729;
static const float D = 0.4329510;
static const float E = 0.238081;
#line 189
float3 Apply(float3 color)
{
return saturate(
(color * (color + A) - B) /
(color * (C * color + D) + E));
}
#line 196
float3 Inverse(float3 color)
{
return abs(
((A - D * color) -
sqrt(
pow(abs(D * color - A), 2.0) -
4.0 * (C * color - 1.0) * (B + E * color))) /
(2.0 * (C * color - 1.0)));
}
}
#line 207
namespace Lottes
{
float3 Apply(float3 color)
{
return color * rcp(max(color.r, max(color.g, color.b)) + 1.0);
}
#line 214
float3 Inverse(float3 color)
{
return color * rcp(max(1.0 - max(color.r, max(color.g, color.b)), 0.1));
}
}
#line 220
namespace NarkowiczACES
{
static const float A = 2.51;
static const float B = 0.03;
static const float C = 2.43;
static const float D = 0.59;
static const float E = 0.14;
#line 228
float3 Apply(float3 color)
{
return saturate(
(color * (A * color + B)) / (color * (C * color + D) + E));
}
#line 234
float3 Inverse(float3 color)
{
return
((D * color - B) +
sqrt(
4.0 * A * E * color + B * B -
2.0 * B * D * color -
4.0 * C * E * color * color +
D * D * color * color)) /
(2.0 * (A - C * color));
}
}
#line 247
namespace Unreal3
{
float3 Apply(float3 color)
{
return color / (color + 0.155) * 1.019;
}
#line 254
float3 Inverse(float3 color)
{
return (color * -0.155) / (max(color, 0.01) - 1.019);
}
}
#line 260
float3 Apply(int type, float3 color)
{
switch (type)
{
default:
case Type::Reinhard:
return Reinhard::Apply(color);
case Type::Uncharted2Filmic:
return Uncharted2Filmic::Apply(color);
case Type::BakingLabACES:
return BakingLabACES::Apply(color);
case Type::NarkowiczACES:
return NarkowiczACES::Apply(color);
case Type::Unreal3:
return Unreal3::Apply(color);
case Type::Lottes:
return Lottes::Apply(color);
}
}
#line 280
float3 Inverse(int type, float3 color)
{
switch (type)
{
default:
case Type::Reinhard:
return Reinhard::Inverse(color);
case Type::Uncharted2Filmic:
return Uncharted2Filmic::Inverse(color);
case Type::BakingLabACES:
return BakingLabACES::Inverse(color);
case Type::NarkowiczACES:
return NarkowiczACES::Inverse(color);
case Type::Unreal3:
return Unreal3::Inverse(color);
case Type::Lottes:
return Lottes::Inverse(color);
}
}
#line 300
}} 
#line 9 "C:\Program Files\GShade\gshade-shaders\Shaders\MagicHDR.fx"
#line 48
namespace FXShaders
{
#line 53
static const int2 DownsampleAmount = 4;
#line 55
static const int BlurSamples = 13;
#line 57
static const float2 AdaptFocusPointDebugSize = 10.0;
#line 59
static const int
InvTonemap_Reinhard = 0,
InvTonemap_Lottes = 1,
InvTonemap_Unreal3 = 2,
InvTonemap_NarkowiczACES = 3,
InvTonemap_Uncharted2Filmic = 4,
InvTonemap_BakingLabACES = 5;
#line 67
static const int
Tonemap_Reinhard = 0,
Tonemap_Lottes = 1,
Tonemap_Unreal3 = 2,
Tonemap_NarkowiczACES = 3,
Tonemap_Uncharted2Filmic = 4,
Tonemap_BakingLabACES = 5;
#line 79
uniform int _WipWarn < ui_text = "This effect is currently a work in progress and as such some " "aspects may change in the future and some features may still be " "missing or incomplete.\n"; ui_label = " "; ui_type = "radio"; >;
#line 81
uniform int _Credits < ui_text = "This effect was made by Lucas Melo (luluco250).\n" "Updates may be available at https://github.com/luluco250/FXShaders\n" "Any issues, suggestions or requests can also be filed there."; ui_category = "Credits"; ui_category_closed = true; ui_label = " "; ui_type = "radio"; >;
#line 187
uniform int _Help < ui_text =
"This effect allows you to add both bloom and tonemapping, drastically "
"changing the mood of the image.\n"
"\n"
"Care should be taken to select an appropriate inverse tonemapper that can "
"accurately extract HDR information from the original image.\n"
"HDR10 users should also take care to select a tonemapper that's "
"compatible with what the HDR monitor is expecting from the LDR output of "
"the game, which *is* tonemapped too.\n"
"\n"
"Available preprocessor directives:\n"
"\n"
"MAGIC_HDR_BLUR_SAMPLES:\n"
"  Determines how many pixels are sampled during each blur pass for the "
"bloom effect.\n"
"  This value directly influences the Blur Size, so the more samples the "
"bigger the blur size can be.\n"
"  Setting MAGIC_HDR_DOWNSAMPLE above 1x will also increase the blur size "
"to compensate for the lower resolution. This effect may be desirable, "
"however.\n"
"\n"
"MAGIC_HDR_DOWNSAMPLE:\n"
"  Serves to divide the resolution of the textures used for processing the "
"bloom effect.\n"
"  Leave at 1x for maximum detail, 2x or 4x should still be fine.\n"
"  Values too high may introduce flickering.\n"
#line 109
; ui_category = "Help"; ui_category_closed = true; ui_label = " "; ui_type = "radio"; >;
#line 111
uniform float InputExposure
<
ui_category = "Tonemapping";
ui_label = "Input Exposure";
ui_tooltip =
"Approximate exposure of the original image.\n"
"This value is measured in f-stops.\n"
"\nDefault: 1.0";
ui_type = "slider";
ui_min = -3.0;
ui_max = 3.0;
> = 0.0;
#line 124
uniform float Exposure
<
ui_category = "Tonemapping";
ui_label = "Output Exposure";
ui_tooltip =
"Exposure applied at the end of the effect.\n"
"This value is measured in f-stops.\n"
"\nDefault: 1.0";
ui_type = "slider";
ui_min = -3.0;
ui_max = 3.0;
> = 0.0;
#line 137
uniform int InvTonemap
<
ui_category = "Tonemapping";
ui_label = "Inverse Tonemapper";
ui_tooltip =
"The inverse tonemapping operator used to obtain HDR information.\n"
"\nDefault: Reinhard";
ui_type = "combo";
ui_items =
"Reinhard\0Lottes\0Unreal 3\0Narkowicz ACES\0Uncharted 2 Filmic\0Baking Lab ACES\0";
> = InvTonemap_Reinhard;
#line 149
uniform int Tonemap
<
ui_category = "Tonemapping";
ui_label = "Output Tonemapper";
ui_tooltip =
"The tonemapping operator applied at the end of the effect.\n"
"\nDefault: Baking Lab ACES";
ui_type = "combo";
ui_items =
"Reinhard\0Lottes\0Unreal 3\0Narkowicz ACES\0Uncharted 2 Filmic\0Baking Lab ACES\0";
> = Tonemap_BakingLabACES;
#line 161
uniform float BloomAmount
<
ui_category = "Bloom";
ui_category_closed = true;
ui_label = "Amount";
ui_tooltip =
"The amount of bloom to apply to the image.\n"
"\nDefault: 0.3";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.3;
#line 174
uniform float BloomBrightness
<
ui_category = "Bloom";
ui_label = "Brightness";
ui_tooltip =
"This value is used to multiply the bloom texture brightness.\n"
"This is different from the amount in it directly affects the "
"brightness, rather than acting as a percentage of blending between "
"the HDR color and the bloom color.\n"
"\nDefault: 3.0";
ui_type = "slider";
ui_min = 1.0;
ui_max = 5.0;
> = 3.0;
#line 189
uniform float BloomSaturation
<
ui_category = "Bloom";
ui_label = "Saturation";
ui_tooltip =
"Determines the saturation of bloom.\n"
"\nDefault: 1.0";
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
> = 1.0;
#line 201
uniform float BlurSize
<
ui_category = "Bloom - Advanced";
ui_category_closed = true;
ui_label = "Blur Size";
ui_tooltip =
"The size of the gaussian blur applied to create the bloom effect.\n"
"This value is directly influenced by the values of "
"MAGIC_HDR_BLUR_SAMPLES and MAGIC_HDR_DOWNSAMPLE.\n"
"\nDefault: 0.5";
ui_type = "slider";
ui_min = 0.01;
ui_max = 1.0;
> = 0.5;
#line 216
uniform float BlendingAmount
<
ui_category = "Bloom - Advanced";
ui_label = "Blending Amount";
ui_tooltip =
"How much to blend the various bloom textures used internally.\n"
"Reducing this value will make the bloom more uniform, with less "
"variation.\n"
"\nDefault: 0.5";
ui_type = "slider";
ui_min = 0.1;
ui_max = 1.0;
> = 0.5;
#line 230
uniform float BlendingBase
<
ui_category = "Bloom - Advanced";
ui_label = "Blending Base";
ui_tooltip =
"Determines the base bloom size when blending.\n"
"It's more effective with a lower Blending Amount.\n"
"\nDefault: 0.8";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.8;
#line 327
uniform bool ShowBloom
<
ui_category = "Debug";
ui_category_closed = true;
ui_label = "Show Bloom";
ui_tooltip =
"Displays the bloom texture.\n"
"\nDefault: Off";
> = false;
#line 354
texture ColorTex : COLOR;
#line 356
sampler Color
{
Texture = ColorTex;
#line 361
SRGBTexture = true;
#line 363
};
#line 380
texture TempTex <pooled = true;> { Width = 1920 / DownsampleAmount.x / 1; Height = 1018 / DownsampleAmount.y / 1; Format = RGBA16F; MipLevels = 1; }; sampler Temp { Texture = TempTex; };
#line 383
texture Bloom0Tex <pooled = true;> { Width = 1920 / DownsampleAmount.x / 1; Height = 1018 / DownsampleAmount.y / 1; Format = RGBA16F; MipLevels = 1; }; sampler Bloom0 { Texture = Bloom0Tex; };
texture Bloom1Tex <pooled = true;> { Width = 1920 / DownsampleAmount.x / 2; Height = 1018 / DownsampleAmount.y / 2; Format = RGBA16F; MipLevels = 1; }; sampler Bloom1 { Texture = Bloom1Tex; };
texture Bloom2Tex <pooled = true;> { Width = 1920 / DownsampleAmount.x / 4; Height = 1018 / DownsampleAmount.y / 4; Format = RGBA16F; MipLevels = 1; }; sampler Bloom2 { Texture = Bloom2Tex; };
texture Bloom3Tex <pooled = true;> { Width = 1920 / DownsampleAmount.x / 8; Height = 1018 / DownsampleAmount.y / 8; Format = RGBA16F; MipLevels = 1; }; sampler Bloom3 { Texture = Bloom3Tex; };
texture Bloom4Tex <pooled = true;> { Width = 1920 / DownsampleAmount.x / 16; Height = 1018 / DownsampleAmount.y / 16; Format = RGBA16F; MipLevels = 1; }; sampler Bloom4 { Texture = Bloom4Tex; };
texture Bloom5Tex <pooled = true;> { Width = 1920 / DownsampleAmount.x / 32; Height = 1018 / DownsampleAmount.y / 32; Format = RGBA16F; MipLevels = 1; }; sampler Bloom5 { Texture = Bloom5Tex; };
#line 416
texture Bloom6Tex <pooled = true;> { Width = 1920 / DownsampleAmount.x / 64; Height = 1018 / DownsampleAmount.y / 64; Format = RGBA16F; MipLevels = 1; }; sampler Bloom6 { Texture = Bloom6Tex; };
#line 448
float3 ApplyInverseTonemap(float3 color, float2 uv)
{
switch (InvTonemap)
{
default:
color = Tonemap::Reinhard::Inverse(color);
break;
case InvTonemap_Lottes:
color = Tonemap::Lottes::Inverse(color);
break;
case InvTonemap_Unreal3:
color = Tonemap::Unreal3::Inverse(color);
break;
case InvTonemap_NarkowiczACES:
color = Tonemap::NarkowiczACES::Inverse(color);
break;
case InvTonemap_Uncharted2Filmic:
color = Tonemap::Uncharted2Filmic::Inverse(color);
break;
case InvTonemap_BakingLabACES:
color = Tonemap::BakingLabACES::Inverse(color);
break;
}
#line 472
color /= exp(InputExposure);
#line 474
return color;
}
#line 477
float3 ApplyTonemap(float3 color, float2 uv)
{
#line 482
const float exposure = exp(Exposure);
#line 485
switch (Tonemap)
{
case Tonemap_Reinhard:
return Tonemap::Reinhard::Apply(color * exposure);
case Tonemap_Lottes:
return Tonemap::Lottes::Apply(color * exposure);
case Tonemap_Unreal3:
return Tonemap::Unreal3::Apply(color * exposure);
case Tonemap_NarkowiczACES:
return Tonemap::NarkowiczACES::Apply(color * exposure);
case Tonemap_Uncharted2Filmic:
return Tonemap::Uncharted2Filmic::Apply(color * exposure);
default:
return Tonemap::BakingLabACES::Apply(color * exposure);
}
}
#line 502
float4 Blur(sampler sp, float2 uv, float2 dir)
{
float4 color = GaussianBlur1D(
sp,
uv,
dir * GetPixelSize() * DownsampleAmount,
sqrt(BlurSamples) * BlurSize,
BlurSamples);
#line 511
return color;
}
#line 527
float4 InverseTonemapPS(
float4 p : SV_POSITION,
float2 uv : TEXCOORD) : SV_TARGET
{
float4 color = tex2D(Color, uv);
#line 533
float saturation;
if (BloomSaturation > 1.0)
saturation = pow(abs(BloomSaturation), 2.0);
else
saturation = BloomSaturation;
#line 539
color.rgb = saturate(ApplySaturation(color.rgb, saturation));
#line 541
color.rgb = ApplyInverseTonemap(color.rgb, uv);
#line 544
color.rgb *= exp(BloomBrightness);
#line 546
return color;
}
#line 564
float4 Blur0PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Bloom0, uv, float2(1, 0.0)); } float4 Blur1PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Temp, uv, float2(0.0, 1)); }
float4 Blur2PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Bloom0, uv, float2(2, 0.0)); } float4 Blur3PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Temp, uv, float2(0.0, 2)); }
float4 Blur4PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Bloom1, uv, float2(4, 0.0)); } float4 Blur5PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Temp, uv, float2(0.0, 4)); }
float4 Blur6PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Bloom2, uv, float2(8, 0.0)); } float4 Blur7PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Temp, uv, float2(0.0, 8)); }
float4 Blur8PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Bloom3, uv, float2(16, 0.0)); } float4 Blur9PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Temp, uv, float2(0.0, 16)); }
float4 Blur10PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Bloom4, uv, float2(32, 0.0)); } float4 Blur11PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Temp, uv, float2(0.0, 32)); }
float4 Blur12PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Bloom5, uv, float2(64, 0.0)); } float4 Blur13PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(Temp, uv, float2(0.0, 64)); }
#line 615
float4 TonemapPS(
float4 p : SV_POSITION,
float2 uv : TEXCOORD) : SV_TARGET
{
#line 641
float4 color = tex2D(Color, uv);
color.rgb = ApplyInverseTonemap(color.rgb, uv);
#line 644
const float mean = BlendingBase * 7;
const float variance = BlendingAmount * 7;
#line 647
const float4 bloom = (
tex2D(Bloom0, uv) * NormalDistribution(1, mean, variance) +
tex2D(Bloom1, uv) * NormalDistribution(2, mean, variance) +
tex2D(Bloom2, uv) * NormalDistribution(3, mean, variance) +
tex2D(Bloom3, uv) * NormalDistribution(4, mean, variance) +
tex2D(Bloom4, uv) * NormalDistribution(5, mean, variance) +
tex2D(Bloom5, uv) * NormalDistribution(6, mean, variance) +
tex2D(Bloom6, uv) * NormalDistribution(7, mean, variance)
) / 7;
#line 657
if (ShowBloom)
color.rgb = bloom.rgb;
else
color.rgb = lerp(color.rgb, bloom.rgb, log10(BloomAmount + 1.0));
#line 662
color.rgb = ApplyTonemap(color.rgb, uv);
#line 667
return color;
#line 669
}
#line 675
technique MagicHDR <ui_tooltip = "FXShaders - Bloom and tonemapping effect.";>
{
pass InverseTonemap
{
VertexShader = ScreenVS;
PixelShader = InverseTonemapPS;
RenderTarget = Bloom0Tex;
}
#line 698
pass Blur0 { VertexShader = ScreenVS; PixelShader = Blur0PS; RenderTarget = TempTex; } pass Blur1 { VertexShader = ScreenVS; PixelShader = Blur1PS; RenderTarget = Bloom0Tex; }
pass Blur2 { VertexShader = ScreenVS; PixelShader = Blur2PS; RenderTarget = TempTex; } pass Blur3 { VertexShader = ScreenVS; PixelShader = Blur3PS; RenderTarget = Bloom1Tex; }
pass Blur4 { VertexShader = ScreenVS; PixelShader = Blur4PS; RenderTarget = TempTex; } pass Blur5 { VertexShader = ScreenVS; PixelShader = Blur5PS; RenderTarget = Bloom2Tex; }
pass Blur6 { VertexShader = ScreenVS; PixelShader = Blur6PS; RenderTarget = TempTex; } pass Blur7 { VertexShader = ScreenVS; PixelShader = Blur7PS; RenderTarget = Bloom3Tex; }
pass Blur8 { VertexShader = ScreenVS; PixelShader = Blur8PS; RenderTarget = TempTex; } pass Blur9 { VertexShader = ScreenVS; PixelShader = Blur9PS; RenderTarget = Bloom4Tex; }
pass Blur10 { VertexShader = ScreenVS; PixelShader = Blur10PS; RenderTarget = TempTex; } pass Blur11 { VertexShader = ScreenVS; PixelShader = Blur11PS; RenderTarget = Bloom5Tex; }
pass Blur12 { VertexShader = ScreenVS; PixelShader = Blur12PS; RenderTarget = TempTex; } pass Blur13 { VertexShader = ScreenVS; PixelShader = Blur13PS; RenderTarget = Bloom6Tex; }
#line 721
pass Tonemap
{
VertexShader = ScreenVS;
PixelShader = TonemapPS;
#line 727
SRGBWriteEnable = true;
#line 729
}
}
#line 734
} 

