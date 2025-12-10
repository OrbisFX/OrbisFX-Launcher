// TRACKING_RAYS_SAMPLES=13
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\TrackingRays.fx"
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
#line 4 "C:\Program Files\GShade\gshade-shaders\Shaders\TrackingRays.fx"
#line 19
namespace FXShaders
{
#line 24
static const int Samples = 13;
static const int TrackPass0Size = 16;
#line 31
uniform int _WipWarn < ui_text = "This effect is currently a work in progress and as such some " "aspects may change in the future and some features may still be " "missing or incomplete.\n"; ui_label = " "; ui_type = "radio"; >;
#line 33
uniform float Intensity
<
ui_label = "Intensity";
ui_tooltip = "Default: 1.0";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.05;
> = 1.0;
#line 43
uniform float Curve
<
ui_label = "Curve";
ui_tooltip = "Default: 3.0";
ui_type = "slider";
ui_min = 1.0;
ui_max = 5.0;
ui_step = 0.1;
> = 3.0;
#line 53
uniform float Scale
<
ui_label = "Scale";
ui_tooltip = "Default: 10.0";
ui_type = "slider";
ui_min = 1.0;
ui_max = 10.0;
ui_step = 0.1;
> = 10.0;
#line 63
uniform float Delay
<
ui_label = "Delay";
ui_tooltip = "Default: 1.0";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.1;
> = 1.0;
#line 73
uniform float MergeTolerance
<
ui_label = "Merge Tolerance";
ui_tooltip = "Default: 0.1";
ui_type = "slider";
ui_min = 0.0;
ui_max = 0.3;
ui_step = 0.01;
> = 0.1;
#line 83
uniform float FrameTime <source = "frametime";>;
#line 89
texture BackBufferTex : COLOR;
#line 91
sampler BackBuffer
{
Texture = BackBufferTex;
SRGBTexture = true;
};
#line 97
texture CoarseTex
{
Width = TrackPass0Size;
Height = TrackPass0Size;
Format = R8;
};
#line 104
sampler Coarse
{
Texture = CoarseTex;
};
#line 109
texture PivotTex
{
Format = RG16F;
};
#line 114
sampler Pivot
{
Texture = PivotTex;
};
#line 119
texture LastPivotTex
{
Format = RG16F;
};
#line 124
sampler LastPivot
{
Texture = LastPivotTex;
};
#line 133
float4 ZoomBlur(sampler sp, float2 uv, float2 pivot, float scale, int samples)
{
float4 color = tex2D(sp, uv);
#line 138
[unroll]
for (int i = 1; i < samples; ++i)
{
uv = ScaleCoord(uv, rcp(scale), pivot);
#line 143
float4 pixel = tex2D(sp, uv);
color += pixel;
#line 146
}
#line 148
color /= samples;
#line 151
return color;
}
#line 158
float4 GetCoarsePS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
return tex2D(BackBuffer, uv);
}
#line 163
float4 TrackPass0PS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
float2 pivot = 0.5;
float bright = 0.0;
#line 168
[unroll]
for (int x = 0; x < TrackPass0Size; ++x)
{
[unroll]
for (int y = 0; y < TrackPass0Size; ++y)
{
float2 pos = float2(x, y) / TrackPass0Size;
float pixel = tex2D(Coarse, pos).x;
#line 177
if (abs(pixel - bright) < MergeTolerance)
{
bright = (bright + pixel) * 0.5;
pivot = (pivot + pos) * 0.5;
}
else if (pixel > bright)
{
pivot = pos;
bright = pixel;
}
}
}
#line 190
if (Delay > 0.0)
{
pivot = lerp(tex2Dfetch(LastPivot, 0).xy, pivot, saturate((FrameTime * 0.001) / Delay));
}
#line 195
return float4(pivot, 0.0, 1.0);
}
#line 198
float4 SavePivotPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
return tex2Dfetch(Pivot, 0);
}
#line 203
float4 MainPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
float4 color = tex2D(BackBuffer, uv);
#line 207
float4 rays = ZoomBlur(BackBuffer, uv, tex2Dfetch(Pivot, 0).xy, 1.0 + (Scale - 1.0) / Samples * 0.1, Samples);
rays.rgb = pow(abs(rays.rgb), Curve);
#line 214
return 1.0 - (1.0 - color) * (1.0 - rays * Intensity);
#line 216
}
#line 222
technique TrackingRays
<
ui_tooltip =
"FXShaders - Experimental sun rays effect that tracks brightness in "
"the image.";
>
{
pass GetCoarse
{
VertexShader = ScreenVS;
PixelShader = GetCoarsePS;
RenderTarget = CoarseTex;
}
pass TrackPass0
{
VertexShader = ScreenVS;
PixelShader = TrackPass0PS;
RenderTarget = PivotTex;
}
pass SavePivot
{
VertexShader = ScreenVS;
PixelShader = SavePivotPS;
RenderTarget = LastPivotTex;
}
pass Main
{
VertexShader = ScreenVS;
PixelShader = MainPS;
SRGBWriteEnable = true;
}
}
#line 257
} 

