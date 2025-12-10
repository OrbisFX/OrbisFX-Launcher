// NEO_BLOOM_DITHERING=0
// NEO_BLOOM_DEPTH=1
// NEO_BLOOM_GHOSTING=1
// NEO_BLOOM_LENS_DIRT_ASPECT_RATIO_CORRECTION=1
// NEO_BLOOM_LENS_DIRT_TEXTURE_WIDTH=1280
// NEO_BLOOM_GHOSTING_DOWN_SCALE=(NEO_BLOOM_DOWN_SCALE / 4.0)
// NEO_BLOOM_LENS_DIRT_TEXTURE_NAME="SharedBloom_Dirt.png"
// NEO_BLOOM_DEBUG=0
// NEO_BLOOM_ADAPT=1
// NEO_BLOOM_BLUR_SAMPLES=27
// NEO_BLOOM_DOWN_SCALE=2
// NEO_BLOOM_DEPTH_ANTI_FLICKER=0
// NEO_BLOOM_TEXTURE_MIP_LEVELS=11
// NEO_BLOOM_LENS_DIRT=1
// NEO_BLOOM_TEXTURE_SIZE=1024
// NEO_BLOOM_LENS_DIRT_TEXTURE_HEIGHT=720
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\NeoBloom.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\NeoBloom.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorLab.fxh"
#line 13
namespace FXShaders { namespace ColorLab
{
#line 16
static const float Gamma = 2.2;
static const float GammaInv = 1.0 / Gamma;
#line 19
static const float L_k = 903.3;
static const float L_e = 0.008856;
#line 22
static const float WhitePoint = 1.0;
#line 24
static const float3x3 RGBToXYZ_sRGB = float3x3(
0.4124564, 0.3575761, 0.1804375,
0.2126729, 0.7151522, 0.0721750,
0.0193339, 0.1191920, 0.9503041);
#line 29
static const float3x3 XYZToRGB_sRGB = float3x3(
3.2404542, -1.5371385, -0.4985314,
-0.9692660,  1.8760108,  0.0415560,
0.0556434, -0.2040259,  1.0572252);
#line 34
float3 gamma_to_linear(float3 c, float g)
{
return pow(abs(c), g);
}
#line 39
float3 gamma_to_linear(float3 c)
{
return gamma_to_linear(c, Gamma);
}
#line 44
float3 linear_to_gamma(float3 c, float g)
{
return pow(abs(c), rcp(g));
}
#line 49
float3 linear_to_gamma(float3 c)
{
return pow(abs(c), GammaInv);
}
#line 54
float3 srgb_to_linear(float3 c)
{
return (c < 0.04045)
? c / 12.92
: pow(abs((c + 0.055) / 1.055), 2.4);
}
#line 61
float3 linear_to_srgb(float3 c)
{
return (c < 0.0031308)
? 12.92 * c
: 1.055 * pow(abs(c), rcp(2.4)) - 0.055;
}
#line 68
float3 l_to_linear(float3 c)
{
return (c < 0.08)
? (100 * c) / L_k
: pow(abs((c + 0.16) / 1.16), 3.0);
}
#line 75
float3 linear_to_l(float3 c)
{
return (c < L_e)
? (c * L_k) / 100.0
: 1.16 * pow(abs(c), rcp(3.0)) - 0.16;
}
#line 82
float3 rgb_to_xyz(float3 c)
{
return mul(RGBToXYZ_sRGB, c);
}
#line 87
float3 xyz_to_rgb(float3 c)
{
return mul(XYZToRGB_sRGB, c);
}
#line 92
float3 xyz_to_lab(float3 c, float w)
{
c /= w;
#line 96
c = (c > L_e)
? pow(abs(c), rcp(3.0))
: (L_k * c + 16.0) / 116.0;
#line 100
float3 lab;
lab.x = 116.0 * c.y - 16.0;
lab.y = 500.0 * (c.x - c.y);
lab.z = 200.0 * (c.y - c.z);
#line 105
return lab;
}
#line 108
float3 xyz_to_lab(float3 c)
{
return xyz_to_lab(c, WhitePoint);
}
#line 113
float3 lab_to_xyz(float3 lab, float w)
{
float3 c;
c.y = (lab.x + 16.0) / 116.0;
c.x = lab.y / 500.0 + c.y;
c.z = c.y - lab.z / 200.0;
#line 120
float f3 = c.x * c.x * c.x;
if (f3 > L_e)
c.x = f3;
else
c.x = (116.0 * c.x - 16.0) / L_k;
#line 126
if (lab.x > L_k * L_e)
c.y = pow(abs((lab.x + 16.0) / 116.0), 3.0);
else
c.y = lab.x / L_k;
#line 131
f3 = c.z * c.z * c.z;
if (f3 > L_e)
c.z = f3;
else
c.z = (116.0 * c.z - 16.0) / L_k;
#line 137
c *= w;
return c;
}
#line 141
float3 lab_to_xyz(float3 lab)
{
return lab_to_xyz(lab, WhitePoint);
}
#line 146
float3 rgb_to_lab(float3 c, float w)
{
return xyz_to_lab(rgb_to_xyz(c), w);
}
#line 151
float3 rgb_to_lab(float3 c)
{
return rgb_to_lab(c, WhitePoint);
}
#line 156
float3 lab_to_rgb(float3 c, float w)
{
return xyz_to_rgb(lab_to_xyz(c, w));
}
#line 161
float3 lab_to_rgb(float3 c)
{
return lab_to_rgb(c, WhitePoint);
}
#line 166
}}
#line 35 "C:\Program Files\GShade\gshade-shaders\Shaders\NeoBloom.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersBlending.fxh"
#line 33
namespace FXShaders
{
#line 44
float3 BlendScreen(float3 a, float3 b, float w)
{
return 1.0 - (1.0 - a) * (1.0 - b * w);
}
#line 57
float3 BlendOverlay(float3 a, float3 b, float w)
{
float3 color;
if (a.x < 0.5 || a.y < 0.5 || a.z < 0.5)
color = 2.0 * a * b;
else
color = 1.0 - 2.0 * (1.0 - a) * (1.0 - b);
#line 65
return lerp(a, color, w);
}
#line 76
float3 BlendSoftLight(float3 a, float3 b, float w)
{
return lerp(a, (1.0 - 2.0 * b) * (a * a) + 2.0 * b * a, w);
}
#line 89
float3 BlendHardLight(float3 a, float3 b, float w)
{
float3 color;
if (a.x > 0.5 || a.y > 0.5 || a.z > 0.5)
color = 2.0 * a * b;
else
color = 1.0 - 2.0 * (1.0 - a) * (1.0 - b);
#line 97
return lerp(a, color, w);
}
#line 100
}
#line 36 "C:\Program Files\GShade\gshade-shaders\Shaders\NeoBloom.fx"
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
#line 37 "C:\Program Files\GShade\gshade-shaders\Shaders\NeoBloom.fx"
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
#line 38 "C:\Program Files\GShade\gshade-shaders\Shaders\NeoBloom.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersDithering.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersCommon.fxh"
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersDithering.fxh"
#line 35
namespace FXShaders { namespace Dithering
{
#line 38
namespace Ordered16
{
static const int Width = 4;
#line 42
static const int Pattern[Width * Width] =
{
0, 8, 2, 10,
12, 4, 14, 6,
3, 11, 1, 9,
15, 7, 13, 5
};
#line 50
float3 Apply(float3 color, float2 uv, float amount)
{
const int2 pos = (uv * GetResolution()) % Width;
#line 54
return color * (1.0 + ((Pattern[pos.x * Width + pos.y] / (Width * Width)) * 2.0 - 1.0) * amount);
}
}
#line 58
}} 
#line 39 "C:\Program Files\GShade\gshade-shaders\Shaders\NeoBloom.fx"
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
#line 40 "C:\Program Files\GShade\gshade-shaders\Shaders\NeoBloom.fx"
#line 118
namespace FXShaders
{
#line 123
struct BlendPassParams
{
float4 p : SV_POSITION;
float2 uv : TEXCOORD0;
#line 129
float2 lens_uv : TEXCOORD1;
#line 131
};
#line 138
static const int BloomCount = 5;
static const float4 BloomLevels[] =
{
float4(0.0, 0.5, 0.5, 1),
float4(0.5, 0.0, 0.25, 2),
float4(0.75, 0.875, 0.125, 3),
float4(0.875, 0.0, 0.0625, 5),
float4(0.0, 0.0, 0.03, 7)
#line 147
};
static const int MaxBloomLevel = BloomCount - 1;
#line 150
static const int BlurSamples = 27;
#line 152
static const float2 PixelScale = 1.0;
#line 154
static const float2 DirtResolution = float2(
1280,
720);
static const float2 DirtPixelSize = 1.0 / DirtResolution;
static const float DirtAspectRatio = DirtResolution.x * DirtPixelSize.y;
static const float DirtAspectRatioInv = 1.0 / DirtAspectRatio;
#line 161
static const int DebugOption_None = 0;
static const int DebugOption_OnlyBloom = 1;
static const int DebugOptions_TextureAtlas = 2;
static const int DebugOption_Adaptation = 3;
#line 167
static const int DebugOption_DepthRange = 4;
#line 172
static const int AdaptMode_FinalImage = 0;
static const int AdaptMode_OnlyBloom = 1;
#line 175
static const int BloomBlendMode_Mix = 0;
static const int BloomBlendMode_Addition = 1;
static const int BloomBlendMode_Screen = 2;
#line 393
uniform int _Help < ui_text =
"NeoBloom has many options and may be difficult to setup or may look "
"bad at first, but it's designed to be very flexible to adapt to many "
"different cases.\n"
"Make sure to take a look at the preprocessor definitions at the "
"bottom!\n"
"For more specific descriptions, move the mouse cursor over the name "
"of the option you need help with.\n"
"\n"
"Here's a general description of the features:\n"
"\n"
"  Bloom:\n"
"    Basic options for controlling the look of bloom itself.\n"
"\n"
"  Adaptation:\n"
"    Used to dynamically increase or reduce the image brightness "
"depending on the scene, giving an HDR look.\n"
"    Looking at a bright object, like a lamp, would cause the image to "
"darken; lookinng at a dark spot, like a cave, would cause the "
"image to brighten.\n"
"\n"
"  Blending:\n"
"    Used to control how the different bloom textures are blended, "
"each representing a different level-of-detail.\n"
"    Can be used to simulate an old mid-2000s bloom, ambient light "
"etc.\n"
"\n"
"  Ghosting:\n"
"    Smoothens the bloom between frames, causing a \"motion blur\" or "
"\"trails\" effect.\n"
"\n"
"  Depth:\n"
"    Used to increase or decrease the brightness of parts of the image "
"depending on depth.\n"
"    Can be used for effects like brightening the sky.\n"
"    An optional anti-flicker feature is available to help with games "
"with depth flickering problems, which can cause bloom to flicker as "
"well with the depth feature enabled.\n"
"\n"
"  HDR:\n"
"    Options for controlling the high dynamic range simulation.\n"
"    Useful for simulating a more foggy bloom, like an old soap opera, "
"a high-contrast sunny look etc.\n"
"\n"
"  Blur:\n"
"    Options for controlling the blurring effect used to generate the "
"bloom textures.\n"
"    Mostly can be left untouched.\n"
"\n"
"  Debug:\n"
"    Enables testing options, like viewing the bloom texture alone, "
"before mixing with the image.\n"
#line 237
; ui_category = "Help"; ui_category_closed = true; ui_label = " "; ui_type = "radio"; >;
#line 239
uniform float uIntensity <
ui_label = "Intensity";
ui_tooltip =
"Determines how much bloom is added to the image. For HDR games you'd "
"generally want to keep this low-ish, otherwise everything might look "
"too bright.\n"
"\nDefault: 1.0";
ui_category = "Bloom";
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
ui_step = 0.001;
> = 1.0;
#line 253
uniform float uSaturation <
ui_label = "Saturation";
ui_tooltip =
"Saturation of the bloom texture.\n"
"\nDefault: 1.0";
ui_category = "Bloom";
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
> = 1.0;
#line 264
uniform float3 ColorFilter
<
ui_label = "Color Filter";
ui_tooltip =
"Color multiplied to the bloom, filtering it.\n"
"Set to full white (255, 255, 255) to disable it.\n"
"\nDefault: 255 255 255";
ui_category = "Bloom";
ui_type = "color";
> = float3(1.0, 1.0, 1.0);
#line 275
uniform int BloomBlendMode
<
ui_label = "Blend Mode";
ui_tooltip =
"Determines the formula used to blend bloom with the scene color.\n"
"Certain blend modes may not play well with other options.\n"
"As a fallback, addition always works.\n"
"\nDefault: Mix";
ui_category = "Bloom";
ui_type = "combo";
ui_items = "Mix\0Addition\0Screen\0";
> = 1;
#line 290
uniform float uLensDirtAmount <
ui_text =
"Set NEO_BLOOM_DIRT to 0 to disable this feature to reduce resource "
"usage.";
ui_label = "Amount";
ui_tooltip =
"Determines how much lens dirt is added to the bloom texture.\n"
"\nDefault: 0.0";
ui_category = "Lens Dirt";
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
> = 0.0;
#line 310
uniform int AdaptMode
<
ui_text =
"Set NEO_BLOOM_ADAPT to 0 to disable this feature to reduce resource "
"usage.";
ui_label = "Mode";
ui_tooltip =
"Select different modes of how adaptation is applied.\n"
"  Final Image:\n"
"    Apply adaptation to the image after it was mixed with bloom.\n"
"  Bloom Only:\n"
"    Apply adaptation only to bloom, before mixing with the image.\n"
"\nDefault: Final Image";
ui_category = "Adaptation";
ui_type = "combo";
ui_items = "Final Image\0Bloom Only\0";
> = 0;
#line 328
uniform float uAdaptAmount <
ui_label = "Amount";
ui_tooltip =
"How much adaptation affects the image brightness.\n"
"\bDefault: 1.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
> = 1.0;
#line 339
uniform float uAdaptSensitivity <
ui_label = "Sensitivity";
ui_tooltip =
"How sensitive is the adaptation towards bright spots?\n"
"\nDefault: 1.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
> = 1.0;
#line 350
uniform float uAdaptExposure <
ui_label = "Exposure";
ui_tooltip =
"Determines the general brightness that the effect should adapt "
"towards.\n"
"This is measured in f-numbers, thus 0 is the base exposure, <0 will "
"be darker and >0 brighter.\n"
"\nDefault: 0.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = -3.0;
ui_max = 3.0;
> = 0.0;
#line 364
uniform bool uAdaptUseLimits <
ui_label = "Use Limits";
ui_tooltip =
"Should the adaptation be limited to the minimum and maximum values "
"specified below?\n"
"\nDefault: On";
ui_category = "Adaptation";
> = true;
#line 373
uniform float2 uAdaptLimits <
ui_label = "Limits";
ui_tooltip =
"The minimum and maximum values that adaptation can achieve.\n"
"Increasing the minimum value will lessen how bright the image can "
"become in dark scenes.\n"
"Decreasing the maximum value will lessen how dark the image can "
"become in bright scenes.\n"
"\nDefault: 0.0 1.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = float2(0.0, 1.0);
#line 389
uniform float uAdaptTime <
ui_label = "Time";
ui_tooltip =
"The time it takes for the effect to adapt.\n"
"\nDefault: 1.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = 0.02;
ui_max = 3.0;
> = 1.0;
#line 400
uniform float uAdaptPrecision <
ui_label = "Precision";
ui_tooltip =
"How precise adaptation will be towards the center of the image.\n"
"This means that 0.0 will yield an adaptation of the overall image "
"brightness, while higher values will focus more and more towards the "
"center pixels.\n"
"\nDefault: 0.0";
ui_category = "Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 11;
ui_step = 1.0;
> = 0.0;
#line 415
uniform int uAdaptFormula <
ui_label = "Formula";
ui_tooltip =
"Which formula to use when extracting brightness information from "
"color.\n"
"\nDefault: Luma (Linear)";
ui_category = "Adaptation";
ui_type = "combo";
ui_items = "Average\0Luminance\0Luma (Gamma)\0Luma (Linear)";
> = 3;
#line 430
uniform float uMean <
ui_label = "Mean";
ui_tooltip =
"Acts as a bias between all the bloom textures/sizes. What this means "
"is that lower values will yield more detail bloom, while the opposite "
"will yield big highlights.\n"
"The more variance is specified, the less effective this setting is, "
"so if you want to have very fine detail bloom reduce both "
"parameters.\n"
"\nDefault: 0.0";
ui_category = "Blending";
ui_type = "slider";
ui_min = 0.0;
ui_max = BloomCount;
#line 445
> = 0.0;
#line 447
uniform float uVariance <
ui_label = "Variance";
ui_tooltip =
"Determines the 'variety'/'contrast' in bloom textures/sizes. This "
"means a low variance will yield more of the bloom size specified by "
"the mean; that is to say that having a low variance and mean will "
"yield more fine-detail bloom.\n"
"A high variance will diminish the effect of the mean, since it'll "
"cause all the bloom textures to blend more equally.\n"
"A low variance and high mean would yield an effect similar to "
"an 'ambient light', with big blooms of light, but few details.\n"
"\nDefault: 1.0";
ui_category = "Blending";
ui_type = "slider";
ui_min = 1.0;
ui_max = BloomCount;
#line 464
> = BloomCount;
#line 470
uniform float uGhostingAmount <
ui_text =
"Set NEO_BLOOM_GHOSTING to 0 if you don't use this feature to reduce "
"resource usage.";
ui_label = "Amount";
ui_tooltip =
"Amount of ghosting applied.\n"
"\nDefault: 0.0";
ui_category = "Ghosting";
ui_type = "slider";
ui_min = 0.0;
ui_max = 0.999;
> = 0.0;
#line 488
uniform float3 DepthMultiplier
<
ui_text =
"Set NEO_BLOOM_DEPTH to 0 if you don't use this feature to reduce "
"resource usage.";
ui_label = "Multiplier";
ui_tooltip =
"Defines the multipliers that will be applied to each range in depth.\n"
" - The first value defines the multiplier for near depth.\n"
" - The second value defines the multiplier for middle depth.\n"
" - The third value defines the multiplier for far depth.\n"
"\nDefault: 1.0 1.0 1.0";
ui_category = "Depth";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.01;
> = float3(1.0, 1.0, 1.0);
#line 507
uniform float2 DepthRange
<
ui_label = "Range";
ui_tooltip =
"Defines the depth range for thee depth multiplier.\n"
" - The first value defines the start of the middle depth."
" - The second value defines the end of the middle depth and the start "
"of the far depth."
"\nDefault: 0.0 1.0";
ui_category = "Depth";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = float2(0.0, 1.0);
#line 523
uniform float DepthSmoothness
<
ui_label = "Smoothness";
ui_tooltip =
"Amount of smoothness in the transition between depth ranges.\n"
"\nDefault: 1.0";
ui_category = "Depth";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 557
uniform float uMaxBrightness <
ui_label  = "Max Brightness";
ui_tooltip =
"tl;dr: HDR contrast.\n"
"\nDetermines the maximum brightness a pixel can achieve from being "
"'reverse-tonemapped', that is to say, when the effect attempts to "
"extract HDR information from the image.\n"
"In practice, the difference between a value of 100 and one of 1000 "
"would be in how bright/bloomy/big a white pixel could become, like "
"the sun or the headlights of a car.\n"
"Lower values can also work for making a more 'balanced' bloom, where "
"there are less harsh highlights and the entire scene is equally "
"foggy, like an old TV show or with dirty lenses.\n"
"\nDefault: 100.0";
ui_category = "HDR";
ui_type = "slider";
ui_min = 1.0;
ui_max = 1000.0;
ui_step = 1.0;
> = 100.0;
#line 578
uniform bool uNormalizeBrightness <
ui_label = "Normalize Brightness";
ui_tooltip =
"Whether to normalize the bloom brightness when blending with the "
"image.\n"
"Without it, the bloom may have very harsh bright spots.\n"
"\nDefault: On";
ui_category = "HDR";
> = true;
#line 588
uniform bool MagicMode
<
ui_label = "Magic Mode";
ui_tooltip =
"When enabled, simulates the look of MagicBloom.\n"
"This is an experimental option and may be inconsistent with other "
"parameters.\n"
"\nDefault: Off";
ui_category = "HDR";
> = false;
#line 601
uniform float uSigma <
ui_label = "Sigma";
ui_tooltip =
"Amount of blurriness. Values too high will break the blur.\n"
"Recommended values are between 2 and 4.\n"
"\nDefault: 2.0";
ui_category = "Blur";
ui_type = "slider";
ui_min = 1.0;
ui_max = 10.0;
ui_step = 0.01;
> = 4.0;
#line 614
uniform float uPadding <
ui_label = "Padding";
ui_tooltip =
"Specifies additional padding around the bloom textures in the "
"internal texture atlas, which is used during the blurring process.\n"
"The reason for this is to reduce the loss of bloom brightness around "
"the screen edges, due to the way the blurring works.\n"
"\n"
"If desired, it can be set to zero to purposefully reduce the "
"amount of bloom around the edges.\n"
"It may be necessary to increase this parameter when increasing the "
"blur sigma, samples and/or bloom down scale.\n"
"\n"
"Due to the way it works, it's recommended to keep the value as low "
"as necessary, since it'll cause the blurring process to work in a "
"\"lower\" resolution.\n"
"\n"
"If you're still confused about this parameter, try viewing the "
"texture atlas with debug mode and watch what happens when it is "
"increased.\n"
"\nDefault: 0.1";
ui_category = "Blur";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.001;
> = 0.1;
#line 712
uniform float FrameTime <source = "frametime";>;
#line 720
sampler BackBuffer
{
Texture = ReShade::BackBufferTex;
SRGBTexture = true;
};
#line 726
texture NeoBloom_DownSample <pooled="true";>
{
Width = 1024;
Height = 1024;
Format = RGBA16F;
MipLevels = 11;
};
sampler DownSample
{
Texture = NeoBloom_DownSample;
};
#line 738
texture NeoBloom_AtlasA <pooled="true";>
{
Width = 1920 / 2;
Height = 1018 / 2;
Format = RGBA16F;
};
sampler AtlasA
{
Texture = NeoBloom_AtlasA;
AddressU = BORDER;
AddressV = BORDER;
};
#line 751
texture NeoBloom_AtlasB <pooled="true";>
{
Width = 1920 / 2;
Height = 1018 / 2;
Format = RGBA16F;
};
sampler AtlasB
{
Texture = NeoBloom_AtlasB;
AddressU = BORDER;
AddressV = BORDER;
};
#line 766
texture NeoBloom_Adapt <pooled="true";>
{
Format = R16F;
};
sampler Adapt
{
Texture = NeoBloom_Adapt;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
};
#line 778
texture NeoBloom_LastAdapt
{
Format = R16F;
};
sampler LastAdapt
{
Texture = NeoBloom_LastAdapt;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
};
#line 794
texture NeoBloom_LensDirt
<
source = "SharedBloom_Dirt.png";
>
{
Width = 1280;
Height = 720;
};
sampler LensDirt
{
Texture = NeoBloom_LensDirt;
};
#line 811
texture NeoBloom_Last
{
Width = 1920 / (2 / 4.0);
Height = 1018 / (2 / 4.0);
#line 819
Format = R8;
#line 821
};
sampler Last
{
Texture = NeoBloom_Last;
};
#line 829
texture NeoBloom_Depth
{
Width = 1920;
Height = 1018;
Format = R8;
};
sampler Depth
{
Texture = NeoBloom_Depth;
};
#line 848
float3 blend_bloom(float3 color, float3 bloom)
{
float w;
if (uNormalizeBrightness)
w = uIntensity / uMaxBrightness;
else
w = uIntensity;
#line 856
switch (BloomBlendMode)
{
default:
return 0.0;
case BloomBlendMode_Mix:
return lerp(color, bloom, log2(w + 1.0));
case BloomBlendMode_Addition:
return color + bloom * w * 3.0;
case BloomBlendMode_Screen:
return BlendScreen(color, bloom, w);
}
}
#line 869
float3 inv_tonemap_bloom(float3 color)
{
if (MagicMode)
return pow(abs(color), uMaxBrightness * 0.01);
#line 874
return Tonemap::Reinhard::InverseOldLum(color, 1.0 / uMaxBrightness);
}
#line 877
float3 inv_tonemap(float3 color)
{
if (MagicMode)
return color;
#line 882
return Tonemap::Reinhard::InverseOld(color, 1.0 / uMaxBrightness);
}
#line 885
float3 tonemap(float3 color)
{
if (MagicMode)
return color;
#line 890
return Tonemap::Reinhard::Apply(color);
}
#line 916
float4 DownSamplePS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
float4 color = tex2D(BackBuffer, uv);
color.rgb = saturate(ApplySaturation(color.rgb, uSaturation));
color.rgb *= ColorFilter;
color.rgb = inv_tonemap_bloom(color.rgb);
#line 927
const float3 depth = ReShade::GetLinearizedDepth(uv);
#line 930
const float is_near = smoothstep(
depth.x - DepthSmoothness.x,
depth.x + DepthSmoothness.x,
DepthRange.x);
#line 935
const float is_far = smoothstep(
DepthRange.y - DepthSmoothness.x,
DepthRange.y + DepthSmoothness.x, depth.x);
#line 939
const float is_middle = (1.0 - is_near) * (1.0 - is_far);
#line 941
color.rgb *= lerp(1.0, DepthMultiplier.x, is_near);
color.rgb *= lerp(1.0, DepthMultiplier.y, is_middle);
color.rgb *= lerp(1.0, DepthMultiplier.z, is_far);
#line 946
return color;
}
#line 949
float4 SplitPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
float4 color = 0.0;
#line 953
[unroll]
for (int i = 0; i < BloomCount; ++i)
{
float4 rect = BloomLevels[i];
float2 rect_uv = ScaleCoord(uv - rect.xy, 1.0 / rect.z, 0.0);
float inbounds =
step(0.0, rect_uv.x) * step(rect_uv.x, 1.0) *
step(0.0, rect_uv.y) * step(rect_uv.y, 1.0);
#line 962
rect_uv = ScaleCoord(rect_uv, 1.0 + uPadding * (i + 1), 0.5);
#line 964
float4 pixel = tex2Dlod(DownSample, float4(rect_uv, 0, rect.w));
pixel.rgb *= inbounds;
pixel.a = inbounds;
#line 968
color += pixel;
}
#line 971
return color;
}
#line 974
float4 BlurXPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
return GaussianBlur1D(AtlasA, uv, PixelScale * float2((1.0 / 1920), 0.0) * 2, uSigma, BlurSamples);
}
#line 979
float4 BlurYPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
return GaussianBlur1D(AtlasB, uv, PixelScale * float2(0.0, (1.0 / 1018)) * 2, uSigma, BlurSamples);
}
#line 986
float4 CalcAdaptPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
float3 color = tex2Dlod(
DownSample,
float4(0.5, 0.5, 0.0, 11 - uAdaptPrecision)
).rgb;
color = tonemap(color);
#line 994
float gs;
switch (uAdaptFormula)
{
case 0:
gs = dot(color, 0.333);
break;
case 1:
gs = max(color.r, max(color.g, color.b));
break;
case 2:
gs = GetLumaGamma(color);
break;
case 3:
gs = GetLumaLinear(color);
break;
}
#line 1011
gs *= uAdaptSensitivity;
#line 1013
if (uAdaptUseLimits)
gs = clamp(gs, uAdaptLimits.x, uAdaptLimits.y);
gs = lerp(tex2D(LastAdapt, 0.0).r, gs, saturate((FrameTime * 0.001) / max(uAdaptTime, 0.001)));
#line 1017
return float4(gs, 0.0, 0.0, 1.0);
}
#line 1020
float4 SaveAdaptPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
return tex2D(Adapt, 0.0);
}
#line 1027
float4 JoinBloomsPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
float4 bloom = 0.0;
float accum = 0.0;
#line 1032
[unroll]
for (int i = 0; i < BloomCount; ++i)
{
float4 rect = BloomLevels[i];
float2 rect_uv = ScaleCoord(uv, 1.0 / (1.0 + uPadding * (i + 1)), 0.5);
rect_uv = ScaleCoord(rect_uv + rect.xy / rect.z, rect.z, 0.0);
#line 1039
float weight = NormalDistribution(i, uMean, uVariance);
bloom += tex2D(AtlasA, rect_uv) * weight;
accum += weight;
}
bloom /= accum;
#line 1046
bloom.rgb = lerp(bloom.rgb, tex2D(Last, uv).rgb, uGhostingAmount);
#line 1049
return bloom;
}
#line 1054
float4 SaveLastBloomPS(
float4 p : SV_POSITION,
float2 uv : TEXCOORD
) : SV_TARGET
{
float4 color = float4(0.0, 0.0, 0.0, 1.0);
#line 1066
color.rgb = tex2D(AtlasB, uv).rgb;
#line 1069
return color;
}
#line 1078
BlendPassParams BlendVS(uint id : SV_VERTEXID)
{
BlendPassParams p;
#line 1082
PostProcessVS(id, p.p, p.uv);
#line 1085
float ar = 1920 * (1.0 / 1018);
float ar_inv = 1018 * (1.0 / 1920);
float is_horizontal = step(ar, DirtAspectRatio);
float ratio = lerp(
DirtAspectRatio * ar_inv,
ar * DirtAspectRatioInv,
is_horizontal);
#line 1093
p.lens_uv = ScaleCoord(p.uv, float2(1.0, ratio), 0.5);
#line 1096
return p;
}
#line 1099
float4 BlendPS(BlendPassParams p) : SV_TARGET
{
float2 uv = p.uv;
#line 1103
float4 color = tex2D(BackBuffer, uv);
color.rgb = inv_tonemap(color.rgb);
#line 1107
float4 bloom = tex2D(AtlasB, uv);
#line 1120
bloom.rgb = mad(tex2D(LensDirt, p.lens_uv).rgb, bloom.rgb * uLensDirtAmount, bloom.rgb);
#line 1195
const float exposure = lerp(1.0, exp(uAdaptExposure) / max(tex2D(Adapt, 0.0).r, 0.001), uAdaptAmount);
#line 1197
if (MagicMode)
{
bloom.rgb = Tonemap::Uncharted2Filmic::Apply(
bloom.rgb * exposure * 0.1);
}
#line 1203
switch (AdaptMode)
{
case AdaptMode_FinalImage:
color = blend_bloom(color.rgb, bloom.rgb);
color.rgb *= exposure;
break;
case AdaptMode_OnlyBloom:
bloom.rgb *= exposure;
color = blend_bloom(color.rgb, bloom.rgb);
break;
}
#line 1221
if (!MagicMode)
color.rgb = tonemap(color.rgb);
#line 1227
return color;
#line 1229
}
#line 1235
technique NeoBloom
{
#line 1246
pass DownSample
{
VertexShader = PostProcessVS;
PixelShader = DownSamplePS;
RenderTarget = NeoBloom_DownSample;
}
pass Split
{
VertexShader = PostProcessVS;
PixelShader = SplitPS;
RenderTarget = NeoBloom_AtlasA;
}
pass BlurX
{
VertexShader = PostProcessVS;
PixelShader = BlurXPS;
RenderTarget = NeoBloom_AtlasB;
}
pass BlurY
{
VertexShader = PostProcessVS;
PixelShader = BlurYPS;
RenderTarget = NeoBloom_AtlasA;
}
#line 1272
pass CalcAdapt
{
VertexShader = PostProcessVS;
PixelShader = CalcAdaptPS;
RenderTarget = NeoBloom_Adapt;
}
pass SaveAdapt
{
VertexShader = PostProcessVS;
PixelShader = SaveAdaptPS;
RenderTarget = NeoBloom_LastAdapt;
}
#line 1287
pass JoinBlooms
{
VertexShader = PostProcessVS;
PixelShader = JoinBloomsPS;
RenderTarget = NeoBloom_AtlasB;
}
pass SaveLastBloom
{
VertexShader = PostProcessVS;
PixelShader = SaveLastBloomPS;
RenderTarget = NeoBloom_Last;
}
#line 1301
pass Blend
{
VertexShader = BlendVS;
PixelShader = BlendPS;
SRGBWriteEnable = true;
}
}
#line 1311
}

