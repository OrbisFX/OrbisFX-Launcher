// NORMAL_MAP_HEIGHT=1024
// NORMAL_MAP_TEXTURE="NormalMap.png"
// NORMAL_MAP_WIDTH=1024
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\NormalMap.fx"
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
#line 4 "C:\Program Files\GShade\gshade-shaders\Shaders\NormalMap.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXShadersMath.fxh"
#line 5 "C:\Program Files\GShade\gshade-shaders\Shaders\NormalMap.fx"
#line 24
namespace FXShaders
{
#line 29
static const float2 NormalResolution = float2(1024, 1024);
static const float2 NormalPixelSize = 1.0 / NormalResolution;
static const float NormalAspectRatio = NormalResolution.x * NormalPixelSize.y;
static const float TranslationScale = 1.0;
static const float RotationScale = 0.2;
#line 35
static const int AddressMode_Repeat = 0;
static const int AddressMode_Clip = 1;
static const int AddressMode_Stretch = 2;
#line 39
static const float DistortionAmountScale = 100.0;
#line 45
uniform int _WipWarn < ui_text = "This effect is currently a work in progress and as such some " "aspects may change in the future and some features may still be " "missing or incomplete.\n"; ui_label = " "; ui_type = "radio"; >;
#line 47
uniform float DistortionAmount
<
ui_label = "Distortion Amount";
ui_tooltip =
"Determines the amount of distortion to apply to the image based on "
"normal map texture.\n"
"\nDefault: 1.0";
ui_type = "slider";
ui_min = -3.0;
ui_max = 3.0;
> = 1.0;
#line 59
uniform float TextureScale
<
ui_label = "Texture Scale";
ui_tooltip =
"Scales the normal map texture on the screen.\n"
"\nDefault: 6.0";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
> = 6.0;
#line 70
uniform float ZScale
<
ui_label = "Z Scale";
ui_tooltip =
"Determines how much the Z axis of the normal map affects the "
"distortion.\n"
"\nDefault: 1.0";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
#line 82
uniform float2 Translation
<
ui_label = "Translation Speed";
ui_tooltip =
"Speed at which the normal map is moved.\n"
"\nDefault: 0.0 0.0";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
#line 93
uniform float Rotation
<
ui_label = "Rotation Speed";
ui_tooltip =
"Speed at which the normal map is spinned.\n"
"\nDefault: 0.0";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
#line 104
uniform int AddressMode
<
ui_label = "Texture Address Mode";
ui_tooltip =
"Determines how out of bounds coordinates of the normal map texture"
"are rendered.\n"
"\nDefault: Repeat";
ui_type = "combo";
ui_items = "Repeat\0Clip\0Stretch\0";
> = AddressMode_Repeat;
#line 115
uniform float Timer <source = "timer";>;
#line 121
texture BackBufferTex : COLOR;
#line 123
sampler BackBuffer
{
Texture = BackBufferTex;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;
};
#line 131
texture NormalTex <source = "NormalMap.png";>
{
Width = NormalResolution.x;
Height = NormalResolution.y;
};
#line 137
sampler NormalRepeat
{
Texture = NormalTex;
AddressU = REPEAT;
AddressV = REPEAT;
};
#line 144
sampler NormalClip
{
Texture = NormalTex;
AddressU = BORDER;
AddressV = BORDER;
};
#line 151
sampler NormalStretch
{
Texture = NormalTex;
};
#line 160
float2 CorrectAspect(float2 uv)
{
#line 163
uv = CorrectAspectRatio(uv, NormalAspectRatio, 1.0);
#line 166
return CorrectAspectRatio(
uv,
NormalAspectRatio,
GetAspectRatio());
}
#line 172
float2 ApplyScale(float2 uv)
{
#line 175
return ScaleCoord(uv, TextureScale);
}
#line 178
float2 ApplyRotation(float2 uv)
{
#line 182
uv *= NormalResolution;
uv = RotatePoint(
uv,
Rotation * Timer * RotationScale,
NormalResolution * 0.5);
return uv * NormalPixelSize;
}
#line 190
float2 ApplyTranslation(float2 uv)
{
return uv + (float2(-Translation.x, Translation.y) * Timer * TranslationScale) * NormalPixelSize;
}
#line 195
float2 ApplyTransformations(float2 uv)
{
uv = CorrectAspect(uv);
uv = ApplyScale(uv);
uv = ApplyRotation(uv);
#line 201
return ApplyTranslation(uv);
}
#line 204
float2 ReadNormalTexture(float2 uv)
{
uv = ApplyTransformations(uv);
#line 216
float4 normal = 0.0;
#line 218
if (AddressMode == AddressMode_Repeat)
normal = tex2D(NormalRepeat, uv);
else if (AddressMode == AddressMode_Clip)
normal = tex2D(NormalClip, uv);
else if (AddressMode == AddressMode_Stretch)
normal = tex2D(NormalStretch, uv);
#line 225
normal.xyz *= normal.a;
normal = normal * 2.0 - 1.0;
normal.xy *= lerp(1.0, normal.z, ZScale);
#line 229
return normal.xy;
}
#line 236
float4 MainPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
const float2 normal = ReadNormalTexture(uv);
const float amount = DistortionAmount * DistortionAmountScale;
const float2 ps = GetPixelSize() * amount;
uv += normal.xy * ps;
#line 243
return tex2D(BackBuffer, uv);
}
#line 250
technique NormalMap
<
ui_tooltip = "FXShaders - Distorts the image using a normal map texture.";
>
{
pass
{
VertexShader = ScreenVS;
PixelShader = MainPS;
}
}
#line 264
} 

