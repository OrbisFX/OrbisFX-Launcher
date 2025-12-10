// ADAPTIVE_TONEMAPPER_SMALL_TEX_MIPLEVELS=9
// ADAPTIVE_TONEMAPPER_SMALL_TEX_SIZE=256
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\AdaptiveTonemapper.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ACES.fxh"
#line 15
static const float3x3 ACESInputMat = float3x3
(
0.59719, 0.35458, 0.04823,
0.07600, 0.90834, 0.01566,
0.02840, 0.13383, 0.83777
);
#line 23
static const float3x3 ACESOutputMat = float3x3
(
1.60475, -0.53108, -0.07367,
-0.10208,  1.10813, -0.00605,
-0.00327, -0.07276,  1.07602
);
#line 30
float3 RRTAndODTFit(float3 v)
{
const float3 a = v * (v + 0.0245786f) - 0.000090537f;
const float3 b = v * (0.983729f * v + 0.4329510f) + 0.238081f;
return a / b;
}
#line 37
float3 ACESFitted(float3 color)
{
color = mul(ACESInputMat, color);
#line 42
color = RRTAndODTFit(color);
#line 44
color = mul(ACESOutputMat, color);
#line 47
color = saturate(color);
#line 49
return color;
}
#line 35 "C:\Program Files\GShade\gshade-shaders\Shaders\AdaptiveTonemapper.fx"
#line 53
static const int2 AdaptResolution = 256;
static const int AdaptMipLevels = 9;
#line 56
static const float3 LumaWeights = float3(0.299, 0.587, 0.114);
#line 58
static const int TonemapOperator_Reinhard = 0;
static const int TonemapOperator_Filmic = 1;
static const int TonemapOperator_ACES = 2;
#line 66
uniform int TonemapOperator
<
ui_type = "combo";
ui_label = "Operator";
ui_tooltip =
"Determines the formula used for tonemapping the image.\n"
"\nDefault: ACES (Unreal Engine 4)";
ui_items = "Reinhard\0Filmic (Uncharted 2)\0ACES (Unreal Engine 4)\0";
> = 2;
#line 76
uniform float Amount
<
ui_type = "slider";
ui_tooltip =
"Interpolation between the original color and after tonemapping.\n"
"\nDefault: 1.0";
ui_category = "Tonemapping";
ui_min = 0.0;
ui_max = 2.0;
> = 1.0;
#line 87
uniform float Exposure
<
ui_type = "slider";
ui_tooltip =
"Determines the brightness/camera exposure of the image.\n"
"Measured in f-stops, thus:\n"
"  |Dark|     |Neutral|   |Bright|\n"
"  ... -2.0 -1.0 0.0 +1.0 +2.0 ...\n"
"\nDefault: 0.0";
ui_category = "Tonemapping";
ui_min = -6.0;
ui_max = 6.0;
> = 0.0;
#line 101
uniform bool FixWhitePoint
<
ui_label = "Fix White Point";
ui_tooltip =
"Apply brightness correction after tonemapping.\n"
"\nDefault: On";
ui_category = "Tonemapping";
> = true;
#line 110
uniform float2 AdaptRange
<
ui_type = "drag";
ui_label = "Range";
ui_tooltip =
"The minimum and maximum values that adaptation can use.\n"
"Increasing the first value will limit how brighter the image can "
"become.\n"
"Decreasing the second value will limit how darker the image can "
"become.\n"
"The first value should always be less or equal to the second.\n"
"\nDefault: 0.0 1.0";
ui_category = "Adaptation";
ui_min = 0.001;
ui_max = 1.0;
ui_step = 0.001;
> = float2(0.0, 1.0);
#line 128
uniform float AdaptTime
<
ui_type = "drag";
ui_label = "Time";
ui_tooltip =
"The time in seconds that adaptation takes to occur.\n"
"Setting it to 0.0 makes it instantaneous.\n"
"\nDefault: 1.0";
ui_category = "Adaptation";
ui_min = 0.0;
ui_max = 3.0;
ui_step = 0.01;
> = 1.0;
#line 142
uniform float AdaptSensitivity
<
ui_type = "drag";
ui_label = "Sensititvity";
ui_tooltip =
"Determines how sensitive adaptation is to bright lights, making it "
"less linear.\n"
"Essentially acts as a multiplier.\n"
"\nDefault: 1.0";
ui_category = "Adaptation";
ui_min = 0.0;
ui_max = 3.0;
ui_step = 0.01;
> = 1.0;
#line 157
uniform int AdaptPrecision
<
ui_type = "slider";
ui_label = "Precision";
ui_tooltip =
"The amount of precision used when determining the overrall brightness "
"around the screen center point.\n"
"At 0, the entire scene is accounted for in the process.\n"
"The maximum value may vary depending on the amount of LODs available "
"for a given adaptation texture size, but it always results in only "
"the absolute center of the screen being considered for adaptation.\n"
"\nDefault: 0";
ui_category = "Adaptation";
ui_min = 0;
ui_max = AdaptMipLevels;
> = 0;
#line 174
uniform float2 AdaptFocalPoint
<
ui_type = "drag";
ui_label = "Focal Point";
ui_tooltip =
"Determines a point in the screen that adaptation will be centered "
"around.\n"
"Doesn't really matter when Precision is set to 0, but otherwise "
"can help focus on things that are not necessarily in the center of "
"the screen, like the ground.\n"
"The first value controls the horizontal position, from left to "
"right.\n"
"The second value controls the vertical position, from top to "
"bottom.\n"
"Set both to 0.5 for the absolute screen center point.\n"
"\nDefault: 0.5 0.5";
ui_category = "Adaptation";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.5;
#line 196
uniform float FrameTime <source = "frametime";>;
#line 202
texture BackBufferTex : COLOR;
#line 204
sampler BackBuffer_Point
{
Texture = BackBufferTex;
SRGBTexture = true;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
};
#line 213
sampler BackBuffer_Linear
{
Texture = BackBufferTex;
SRGBTexture = true;
};
#line 219
texture SmallTex
{
Width = AdaptResolution.x;
Height = AdaptResolution.y;
Format = R32F;
MipLevels = AdaptMipLevels;
};
sampler Small
{
Texture = SmallTex;
};
#line 231
texture LastAdaptTex
{
Format = R32F;
};
sampler LastAdapt
{
Texture = LastAdaptTex;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
};
#line 247
float get_adapt()
{
return tex2Dlod(
Small,
float4(AdaptFocalPoint, 0, AdaptMipLevels - AdaptPrecision)).x;
}
#line 254
float3 reinhard(float3 color)
{
return color / (1.0 + color);
}
#line 259
float3 uncharted2_tonemap(float3 col, float exposure) {
static const float A = 0.15; 
static const float B = 0.50; 
static const float C = 0.10; 
static const float D = 0.20; 
static const float E = 0.02; 
static const float F = 0.30; 
static const float W = 11.2; 
#line 268
col *= exposure;
#line 270
col = ((col * (A * col + C * B) + D * E) / (col * (A * col + B) + D * F)) - E / F;
static const float white = 1.0 / (((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F);
col *= white;
return col;
}
#line 276
float3 tonemap(float3 color, float exposure)
{
switch (TonemapOperator)
{
default:
return 0.0;
case TonemapOperator_Reinhard:
return reinhard(color * exposure);
case TonemapOperator_Filmic:
return uncharted2_tonemap(color, exposure);
case TonemapOperator_ACES:
return ACESFitted(color * exposure);
}
}
#line 295
void PostProcessVS(
uint id : SV_VERTEXID,
out float4 p : SV_POSITION,
out float2 uv : TEXCOORD)
{
uv.x = (id == 2) ? 2.0 : 0.0;
uv.y = (id == 1) ? 2.0 : 0.0;
p = float4(uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 305
float4 GetSmallPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
float adapt = dot(tex2D(BackBuffer_Linear, uv).rgb, LumaWeights);
adapt *= AdaptSensitivity;
#line 310
const float last = tex2Dfetch(LastAdapt, 0).x;
#line 312
if (AdaptTime > 0.0)
adapt = lerp(last, adapt, saturate((FrameTime * 0.001) / AdaptTime));
#line 315
return adapt;
}
#line 318
float4 SaveAdaptPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
return get_adapt();
}
#line 323
void MainVS(
uint id : SV_VERTEXID,
out float4 p : SV_POSITION,
out float2 uv : TEXCOORD0,
out float inv_white : TEXCOORD1,
out float exposure : TEXCOORD2)
{
PostProcessVS(id, p, uv);
exposure = exp2(Exposure);
#line 333
float adapt = get_adapt();
adapt = clamp(adapt, AdaptRange.x, AdaptRange.y);
exposure /= adapt;
#line 337
inv_white = FixWhitePoint
? rcp(tonemap(1.0, exposure).x)
: 1.0;
}
#line 342
float4 MainPS(
float4 p : SV_POSITION,
float2 uv : TEXCOORD0,
float inv_white : TEXCOORD1,
float exposure : TEXCOORD2) : SV_TARGET
{
float4 color = tex2D(BackBuffer_Point, uv);
color.rgb = lerp(
color.rgb,
tonemap(color.rgb, exposure) * inv_white,
Amount);
#line 354
return color;
}
#line 361
technique AdaptiveTonemapper
{
pass GetSmall
{
VertexShader = PostProcessVS;
PixelShader = GetSmallPS;
RenderTarget = SmallTex;
}
pass SaveAdapt
{
VertexShader = PostProcessVS;
PixelShader = SaveAdaptPS;
RenderTarget = LastAdaptTex;
}
pass Main
{
VertexShader = MainVS;
PixelShader = MainPS;
SRGBWriteEnable = true;
}
}

