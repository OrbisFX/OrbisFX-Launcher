// MAGIC_LENS_DOWNSCALE=4
// MAGIC_LENS_BLUR_SAMPLES=9
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\LiquidLens.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersAspectRatio.fxh"
#line 38
namespace FXShaders { namespace AspectRatio
{
#line 41
namespace ScaleType
{
static const int Cover = 0;
static const int Fit = 1;
static const int Stretch = 2;
}
#line 48
float2 CoverScale(float2 uv)
{
if (1920 > 1018)
return float2(1.0, 1018 * (1.0 / 1920));
else
return float2(1920 * (1.0 / 1018), 1.0);
}
#line 56
float2 FitScale(float2 uv)
{
if (1920 > 1018)
return float2(1920 * (1.0 / 1018), 1.0);
else
return float2(1.0, 1018 * (1.0 / 1920));
}
#line 64
float2 ApplyScale(int type, float2 uv)
{
switch (type)
{
case ScaleType::Cover:
return CoverScale(uv);
case ScaleType::Fit:
return FitScale(uv);
#line 73
default:
return uv;
}
}
#line 78
}} 
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\LiquidLens.fx"
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
#line 33 "C:\Program Files\GShade\gshade-shaders\Shaders\LiquidLens.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\LiquidLens.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersMath.fxh"
#line 35 "C:\Program Files\GShade\gshade-shaders\Shaders\LiquidLens.fx"
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
#line 36 "C:\Program Files\GShade\gshade-shaders\Shaders\LiquidLens.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersTransform.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersAspectRatio.fxh"
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersTransform.fxh"
#line 35
namespace FXShaders { namespace Transform
{
#line 38
float2 FisheyeLens(
int aspectRatioScaleType,
float2 uv,
float amount,
float zoom)
{
uv = uv * 2.0 - 1.0;
#line 46
const float2 fishUv = uv * AspectRatio::ApplyScale(aspectRatioScaleType, uv);
#line 48
uv = ((uv * lerp(1.0, sqrt(1.0 - fishUv.x * fishUv.x - fishUv.y * fishUv.y) * zoom, amount)) + 1.0) * 0.5;
#line 50
return uv;
}
#line 53
}
}
#line 37 "C:\Program Files\GShade\gshade-shaders\Shaders\LiquidLens.fx"
#line 46
namespace FXShaders { namespace LiquidLens
{
#line 49
static const int BlurSamples = 9;
static const int Downscale = 4;
static const float BaseFlareDownscale = 4.0;
#line 53
uniform int _WipWarn < ui_text = "This effect is currently a work in progress and as such some " "aspects may change in the future and some features may still be " "missing or incomplete.\n"; ui_label = " "; ui_type = "radio"; >;
#line 55
uniform float Brightness
<
ui_category = "Appearance";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.1;
#line 63
uniform float Saturation
<
ui_category = "Appearance";
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
> = 0.7;
#line 71
uniform float Threshold
<
ui_category = "Appearance";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.95;
#line 79
uniform int Tonemapper
<
ui_category = "Appearance";
ui_type = "combo";
ui_items = "Reinhard\0" "Uncharted 2 Filmic\0" "BakingLab ACES\0" "Narkowicz ACES\0" "Unreal3\0" "Lottes\0";
> = Tonemap::Type::BakingLabACES;
#line 86
uniform float BlurSize
<
ui_category = "Gaussian Blur";
ui_label = "Size";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
#line 95
uniform float BlurSigma
<
ui_category = "Gaussian Blur";
ui_label = "Sigma";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.5;
#line 104
uniform float FisheyeAmount
<
ui_category = "Fisheye Lens";
ui_category_closed = true;
ui_label = "Amount";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = -0.1;
#line 114
uniform float FisheyeZoom
<
ui_category = "Fisheye Lens";
ui_category_closed = true;
ui_label = "Zoom";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 1.0;
#line 124
uniform int FisheyeScaleType
<
ui_category = "Fisheye Lens";
ui_text = "Aspect Ratio Scaling";
ui_label = " ";
ui_type = "radio";
ui_items = "Cover\0" "Fit\0" "Stretch\0";
> = AspectRatio::ScaleType::Cover;
#line 133
uniform float TintAmount
<
ui_category = "Flares";
ui_category_closed = true;
ui_label = "Tinting Amount";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
#line 151
uniform float4 Tint1 < ui_category = "Flares"; ui_label = "Tint " "1"; ui_type = "color"; > = float4(1.0, 0.0, 0.0, 1.0);
uniform float4 Tint2 < ui_category = "Flares"; ui_label = "Tint " "2"; ui_type = "color"; > = float4(1.0, 0.5, 0.0, 1.0);
uniform float4 Tint3 < ui_category = "Flares"; ui_label = "Tint " "3"; ui_type = "color"; > = float4(1.0, 1.0, 0.0, 1.0);
uniform float4 Tint4 < ui_category = "Flares"; ui_label = "Tint " "4"; ui_type = "color"; > = float4(0.0, 1.0, 0.0, 1.0);
uniform float4 Tint5 < ui_category = "Flares"; ui_label = "Tint " "5"; ui_type = "color"; > = float4(0.0, 1.0, 1.0, 1.0);
uniform float4 Tint6 < ui_category = "Flares"; ui_label = "Tint " "6"; ui_type = "color"; > = float4(0.0, 0.0, 1.0, 1.0);
uniform float4 Tint7 < ui_category = "Flares"; ui_label = "Tint " "7"; ui_type = "color"; > = float4(1.0, 0.0, 1.0, 1.0);
#line 171
uniform float Scale1 < ui_category = "Flares"; ui_label = "Scale " "1"; ui_type = "slider"; ui_min = -1.0; ui_max = 1.0; > = 0.01;
uniform float Scale2 < ui_category = "Flares"; ui_label = "Scale " "2"; ui_type = "slider"; ui_min = -1.0; ui_max = 1.0; > = 0.02;
uniform float Scale3 < ui_category = "Flares"; ui_label = "Scale " "3"; ui_type = "slider"; ui_min = -1.0; ui_max = 1.0; > = 0.03;
uniform float Scale4 < ui_category = "Flares"; ui_label = "Scale " "4"; ui_type = "slider"; ui_min = -1.0; ui_max = 1.0; > = 0.04;
uniform float Scale5 < ui_category = "Flares"; ui_label = "Scale " "5"; ui_type = "slider"; ui_min = -1.0; ui_max = 1.0; > = 0.05;
uniform float Scale6 < ui_category = "Flares"; ui_label = "Scale " "6"; ui_type = "slider"; ui_min = -1.0; ui_max = 1.0; > = 0.06;
uniform float Scale7 < ui_category = "Flares"; ui_label = "Scale " "7"; ui_type = "slider"; ui_min = -1.0; ui_max = 1.0; > = 0.07;
#line 181
uniform bool ShowLens
<
ui_category = "Debug";
ui_category_closed = true;
ui_label = "Show Lens Flare Texture";
> = false;
#line 188
texture BackBufferTex : COLOR;
#line 190
sampler BackBuffer
{
Texture = BackBufferTex;
SRGBTexture = true;
AddressU = BORDER;
AddressV = BORDER;
};
#line 198
texture LensATex
{
Width = 1920 / Downscale;
Height = 1018 / Downscale;
Format = RGBA16F;
};
#line 205
sampler LensA
{
Texture = LensATex;
AddressU = BORDER;
AddressV = BORDER;
};
#line 212
texture LensBTex
{
Width = 1920 / Downscale;
Height = 1018 / Downscale;
Format = RGBA16F;
};
#line 219
sampler LensB
{
Texture = LensBTex;
AddressU = BORDER;
AddressV = BORDER;
};
#line 226
float4 PreparePS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
uv = ScaleCoord(1.0 - uv, BaseFlareDownscale);
float4 color = tex2D(BackBuffer, uv);
color.rgb = Tonemap::Inverse(Tonemapper, color.rgb);
#line 232
color.rgb = ApplySaturation(color.rgb, Saturation);
color.rgb *= color.rgb >= Tonemap::Inverse(Tonemapper, Threshold).x;
color.rgb *= Brightness;
#line 236
return color;
}
#line 239
float4 Blur(sampler sp, float2 uv, float2 dir)
{
dir *= BlurSize * Downscale;
float sigma = sqrt(BlurSamples) * BlurSigma;
return GaussianBlur1D(sp, uv, dir, sigma, BlurSamples);
}
#line 246
float4 BlurXPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
return Blur(LensA, uv, float2((1.0 / 1920), 0));
}
#line 251
float4 BlurYPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
return Blur(LensB, uv, float2(0, (1.0 / 1018)));
}
#line 256
float4 BlendPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
float4 color = tex2D(BackBuffer, uv);
color.rgb = Tonemap::Inverse(Tonemapper, color.rgb);
#line 261
uv = Transform::FisheyeLens(FisheyeScaleType, uv, FisheyeAmount * 10.0, FisheyeZoom * 3.0);
#line 268
float4 lens =
(tex2D(LensA, ScaleCoord(uv, Scale1 * BaseFlareDownscale)) * float4(lerp(1.0, Tint1.rgb * Tint1.a, TintAmount), 1.0)) +
(tex2D(LensA, ScaleCoord(uv, Scale2 * BaseFlareDownscale)) * float4(lerp(1.0, Tint2.rgb * Tint2.a, TintAmount), 1.0)) +
(tex2D(LensA, ScaleCoord(uv, Scale3 * BaseFlareDownscale)) * float4(lerp(1.0, Tint3.rgb * Tint3.a, TintAmount), 1.0)) +
(tex2D(LensA, ScaleCoord(uv, Scale4 * BaseFlareDownscale)) * float4(lerp(1.0, Tint4.rgb * Tint4.a, TintAmount), 1.0)) +
(tex2D(LensA, ScaleCoord(uv, Scale5 * BaseFlareDownscale)) * float4(lerp(1.0, Tint5.rgb * Tint5.a, TintAmount), 1.0)) +
(tex2D(LensA, ScaleCoord(uv, Scale6 * BaseFlareDownscale)) * float4(lerp(1.0, Tint6.rgb * Tint6.a, TintAmount), 1.0)) +
(tex2D(LensA, ScaleCoord(uv, Scale7 * BaseFlareDownscale)) * float4(lerp(1.0, Tint7.rgb * Tint7.a, TintAmount), 1.0));
lens /= 7;
#line 281
color.rgb = ShowLens
? lens.rgb
: color.rgb + lens.rgb;
#line 285
color.rgb = Tonemap::Apply(Tonemapper, color.rgb);
#line 287
return color;
}
#line 290
technique LiquidLens
{
pass Prepare
{
VertexShader = ScreenVS;
PixelShader = PreparePS;
RenderTarget = LensATex;
}
pass BlurX
{
VertexShader = ScreenVS;
PixelShader = BlurXPS;
RenderTarget = LensBTex;
}
pass BlurY
{
VertexShader = ScreenVS;
PixelShader = BlurYPS;
RenderTarget = LensATex;
}
pass Blend
{
VertexShader = ScreenVS;
PixelShader = BlendPS;
SRGBWriteEnable = true;
}
}
#line 318
}} 

