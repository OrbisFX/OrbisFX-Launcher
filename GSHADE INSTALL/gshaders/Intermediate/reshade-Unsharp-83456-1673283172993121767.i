// UNSHARP_BLUR_SAMPLES=21
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Unsharp.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\Unsharp.fx"
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
return float2(1280, 720);
}
#line 163
float2 GetPixelSize()
{
return float2((1.0 / 1280), (1.0 / 720));
}
#line 171
float GetAspectRatio()
{
return 1280 * (1.0 / 720);
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
#line 33 "C:\Program Files\GShade\gshade-shaders\Shaders\Unsharp.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\Unsharp.fx"
#line 43
namespace FXShaders
{
#line 46
static const int BlurSamples = 21;
#line 48
uniform float Amount
<
ui_category = "Appearance";
ui_label = "Amount";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
#line 57
uniform float BlurScale
<
ui_category = "Appearance";
ui_label = "Blur Scale";
ui_type = "slider";
ui_min = 0.01;
ui_max = 1.0;
> = 1.0;
#line 66
texture ColorTex : COLOR;
#line 68
sampler ColorSRGB
{
Texture = ColorTex;
#line 72
};
#line 74
sampler ColorLinear
{
Texture = ColorTex;
};
#line 79
texture OriginalTex
{
Width = 1280;
Height = 720;
#line 87
};
#line 89
sampler Original
{
Texture = OriginalTex;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
};
#line 97
float4 Blur(sampler tex, float2 uv, float2 dir)
{
float4 color = GaussianBlur1D(
tex,
uv,
dir * GetPixelSize() * 3.0,
sqrt(BlurSamples) * BlurScale,
BlurSamples
);
#line 108
return color + abs(GetRandom(uv) - 0.5) * FloatEpsilon * 25.0;
}
#line 111
float4 CopyOriginalPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
return tex2D(ColorSRGB, uv);
}
#line 124
float4 Blur0PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(ColorSRGB, uv, float2(1.0, 0.0)); };
#line 126
float4 Blur1PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(ColorLinear, uv, float2(0.0, 4.0)); };
#line 128
float4 Blur2PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(ColorLinear, uv, float2(4.0, 0.0)); };
#line 130
float4 Blur3PS( float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return Blur(ColorLinear, uv, float2(0.0, 1.0)); };
#line 132
float4 BlendPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
#line 141
const float4 color = tex2D(Original, uv);
#line 143
return float4(BlendOverlay(color.rgb, GetLumaGamma(1.0 - tex2D(ColorLinear, uv).rgb) * 0.75, Amount), color.a);
#line 145
}
#line 147
technique Unsharp
{
pass CopyOriginal
{
VertexShader = ScreenVS;
PixelShader = CopyOriginalPS;
RenderTarget = OriginalTex;
}
pass Blur0
{
VertexShader = ScreenVS;
PixelShader = Blur0PS;
}
pass Blur1
{
VertexShader = ScreenVS;
PixelShader = Blur1PS;
}
pass Blur2
{
VertexShader = ScreenVS;
PixelShader = Blur2PS;
}
pass Blur3
{
VertexShader = ScreenVS;
PixelShader = Blur3PS;
}
pass Blend
{
VertexShader = ScreenVS;
PixelShader = BlendPS;
#line 180
}
}
#line 183
}

