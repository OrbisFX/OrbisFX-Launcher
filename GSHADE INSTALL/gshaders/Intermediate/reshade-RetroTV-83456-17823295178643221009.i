#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\RetroTV.fx"
#line 8
texture target0
{
Width = 1920;
Height = 1018;
MipLevels = 1;
Format = RGBA32F;
};
sampler samplerTarget0 { Texture = target0; };
#line 17
texture target1
{
Width = 1920;
Height = 1018;
MipLevels = 1;
Format = RGBA32F;
};
sampler samplerTarget1 { Texture = target1; };
#line 26
texture pixel_mask < source = "pixelmask_960x480.png"; >
{
Width = 960;
Height = 480;
MipLevels = 1;
};
sampler sampler_pixel_mask { Texture = pixel_mask; AddressU = REPEAT; AddressV = REPEAT; MinFilter = POINT; MagFilter = POINT;};
#line 34
texture tv_border < source = "TV_Border.png"; >
{
Width = 1280;
Height = 720;
MipLevels = 1;
#line 40
};
sampler sampler_tv_border { Texture = tv_border; };
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
#line 44 "C:\Program Files\GShade\gshade-shaders\Shaders\RetroTV.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\RetroTV.fxh"
#line 3
uniform int2 display_size <
ui_type = "input";
ui_label = "Display Size";
ui_tooltip = "The virtual screen size in pixels";
> = int2(320, 240);
#line 9
uniform float2 pixel_mask_scale <
ui_type = "input";
ui_label = "Pixel Mask Scale";
ui_tooltip = "Number of times to repeat pixel mask image";
> = float2(160, 90);
#line 15
uniform float rf_noise <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_label = "RF Noise";
ui_tooltip = "Apply noise to signal when in RF mode";
> = 0.1;
#line 23
uniform float luma_sharpen <
ui_type = "slider";
ui_min = 0.0;
ui_max = 4.0;
ui_label = "Luma Sharpen";
ui_tooltip = "Apply sharpen filter to luma signal";
> = 1.0;
#line 31
uniform bool EnableTVCurvature <
ui_label = "Enable TV Curvature";
ui_tooltip = "Enables a CRT Curvature effect";
> = true;
#line 36
uniform float tv_curvature <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "TV Curvature";
ui_tooltip = "Apply CRT style curve to screen";
> = 0.5;
#line 44
uniform int3 colorbits <
ui_type = "slider";
ui_min = 2;
ui_max = 8;
ui_label = "Color Bits";
ui_tooltip = "Bits per color channel";
> = int3( 8, 8, 8 );
#line 52
uniform bool EnableRollingFlicker <
ui_label = "Enable Rolling Flicker";
ui_tooltip = "Enables a Flicker effect to simulate mismatch between TV and Camera VSync";
> = true;
#line 57
uniform float fRollingFlicker_Factor <
ui_label = "Rolling Flicker Factor";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.25;
#line 64
uniform float fRollingFlicker_VSyncTime <
ui_label = "Rolling Flicker V Sync Time";
ui_type = "slider";
ui_min = -20.0;
ui_max = 20.0;
> = 1.0;
#line 71
uniform bool EnablePixelMask <
ui_label = "Enable Pixel Mask";
ui_tooltip = "Enables a CRT-Like Pixel-Mask";
> = true;
#line 76
uniform float pixelMaskBrightness <
ui_type = "slider";
ui_min = 1.0;
ui_max = 2.0;
ui_label = "Pixel Mask Brightness";
ui__tooltip = "Brightness of the Pixel Mask";
> = 1.5;
#line 84
uniform bool EnableBurstCountAnimation <
ui_label = "Enable Burst Counter";
ui_tooltip = "Enables an animated burst counter from the NTSC Signal";
> = true;
#line 89
uniform float framecount < source = "framecount"; >;
#line 110
uniform float fTimer <source="timer";>;
#line 112
static const float3x3 rgb2yiq = float3x3(
0.299, 0.587, 0.114,
0.596, -0.275, -0.321,
0.221, -0.523, 0.311
);
#line 118
static const float3x3 yiq2rgb = float3x3(
1.0, 0.956, 0.621,
1.0, -0.272, -0.647,
1.0, -1.106, 1.703
);
#line 128
float fmod(float a, float b) {
const float c = frac(abs(a / b)) * abs(b);
if (a < 0)
return -c;
else
return c;
}
#line 136
float wrap(float f, float f_min, float f_max) {
if (f < f_min)
return f_max - fmod(f_min - f, f_max - f_min);
else
return f_min + fmod(f - f_min, f_max - f_min);
}
#line 143
float rand(float3 myVector)
{
return frac(sin(dot(myVector, float3(12.9898, 78.233, 45.5432))) * 43758.5453);
}
#line 148
float3 quantize_rgb( float3 rgb )
{
float3 q = float3(
1 << colorbits.r,
1 << colorbits.g,
1 << colorbits.b
);
#line 156
rgb *= q;
rgb = floor( rgb );
rgb /= q;
#line 160
return rgb;
}
#line 167
void RetroTV_VS(uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0, out float2 pix_no : TEXCOORD1, out float2 mask_uv : TEXCOORD2)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 174
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 179
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 181
pix_no = texcoord * display_size * float2( 4.0, 1.0 );
mask_uv = texcoord * pixel_mask_scale;
}
#line 190
void RollingFlicker(inout float3 col, float2 uv) {
float t = fTimer * fRollingFlicker_VSyncTime * 0.001;
float y = fmod(-t, 1.0);
float rolling_flicker = uv.y + y;
rolling_flicker = wrap(rolling_flicker, 0.0, 1.0);
col *= lerp(1.0, rolling_flicker, fRollingFlicker_Factor);
}
#line 199
float4 RFEncodePS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float2 pix_no : TEXCOORD1, float2 mask_uv : TEXCOORD2) : SV_Target
{
float3 rgb = tex2D(samplerTarget0, texcoord).rgb;
rgb = quantize_rgb( rgb );
#line 204
float3 yiq = mul( rgb2yiq, rgb );
#line 206
float chroma_phase = (3.1415926535897932 * 0.66667) * (pix_no.y + 0.0);
#line 208
if (EnableBurstCountAnimation){
chroma_phase = (3.1415926535897932 * 0.66667) * (pix_no.y + framecount);
}
#line 212
float mod_phase = chroma_phase + pix_no.x * (3.1415926535897932 / 3.0);
#line 214
float i_mod = cos(mod_phase);
float q_mod = sin(mod_phase);
#line 217
yiq.y *= i_mod * 1.5;
yiq.z *= q_mod * 1.5;
#line 220
float3 signal = dot(yiq, float3(1.0, 1.0, 1.0));
#line 222
float rmod = 1.0 - (sin(texcoord.x * 320) * 0.05);
float noise = (rand(float3(texcoord, (framecount%60) * 0.16)) * rmod * 2 - 1) * rf_noise;
signal += noise;
#line 226
float3 out_color = signal.xxx * float3(1.0, i_mod * (2.0 * 1.0 / 1.5), q_mod * (2.0 * 1.0 / 1.5));
return float4( out_color, 1.0 );
}
#line 231
float4 SVideoEncodePS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float2 pix_no : TEXCOORD1, float2 mask_uv : TEXCOORD2) : SV_Target
{
float3 rgb = tex2D(samplerTarget0, texcoord).rgb;
rgb = quantize_rgb( rgb );
#line 236
float3 yiq = mul( rgb2yiq, rgb );
#line 238
float chroma_phase = (3.1415926535897932 * 0.66667) * (pix_no.y + 0.0);
#line 240
if (EnableBurstCountAnimation){
chroma_phase = (3.1415926535897932 * 0.66667) * (pix_no.y + framecount);
}
float mod_phase = chroma_phase + pix_no.x * (3.1415926535897932 / 3.0);
#line 245
float i_mod = cos(mod_phase);
float q_mod = sin(mod_phase);
#line 248
yiq.y *= i_mod * 1.5;
yiq.z *= q_mod * 1.5;
#line 251
float signal = dot(yiq, float3(1.0, 1.0, 1.0));
#line 253
float3 out_color = float3( yiq.x, signal, signal ) * float3(1.0, i_mod * (2.0 * 1.0 / 1.5), q_mod * (2.0 * 1.0 / 1.5));
return float4( out_color, 1.0 );
}
#line 258
float4 CompositeEncodePS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float2 pix_no : TEXCOORD1, float2 mask_uv : TEXCOORD2) : SV_Target
{
float3 rgb = tex2D(samplerTarget0, texcoord).rgb;
rgb = quantize_rgb( rgb );
#line 263
float3 yiq = mul( rgb2yiq, rgb );
#line 265
float chroma_phase = (3.1415926535897932 * 0.66667) * (pix_no.y + 0.0);
#line 267
if (EnableBurstCountAnimation){
chroma_phase = (3.1415926535897932 * 0.66667) * (pix_no.y + framecount);
}
#line 271
float mod_phase = chroma_phase + pix_no.x * (3.1415926535897932 / 3.0);
#line 273
float i_mod = cos(mod_phase);
float q_mod = sin(mod_phase);
#line 276
yiq.y *= i_mod * 1.5;
yiq.z *= q_mod * 1.5;
#line 279
float signal = dot(yiq, float3(1.0, 1.0, 1.0));
#line 281
float3 out_color = signal.xxx * float3(1.0, i_mod * (2.0 * 1.0 / 1.5), q_mod * (2.0 * 1.0 / 1.5));
return float4( out_color, 1.0 );
}
#line 286
float4 RFDecodePS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float2 pix_no : TEXCOORD1, float2 mask_uv : TEXCOORD2) : SV_Target
{
float _LumaFilter[9] =
{
-0.0020, -0.0009, 0.0038, 0.0178, 0.0445,
0.0817, 0.1214, 0.1519, 0.1634
};
#line 294
float _ChromaFilter[9] =
{
0.0046, 0.0082, 0.0182, 0.0353, 0.0501,
0.0832, 0.1062, 0.1222, 0.1280
};
#line 300
float2 one_x = float2( 1.0 / 1280, 0.0 );
float3 signal = float3( 0.0, 0.0, 0.0 );
#line 303
for (int idx = 0; idx < 8; idx++)
{
float offset = float(idx);
#line 307
float4 sums = tex2D(samplerTarget1, texcoord + ( ( offset - 8.0 ) * one_x * 1.5 )) +
tex2D(samplerTarget1, texcoord + ( ( 8.0 - offset ) * one_x * 1.5 ));
#line 310
signal += sums.xyz * float3(_LumaFilter[idx], _ChromaFilter[idx], _ChromaFilter[idx]);
}
signal += tex2D(samplerTarget1, texcoord).xyz *
float3(_LumaFilter[8], _ChromaFilter[8], _ChromaFilter[8]);
#line 315
return float4( signal, 1.0 );
}
#line 319
float4 CompositeDecodePS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float2 pix_no : TEXCOORD1, float2 mask_uv : TEXCOORD2) : SV_Target
{
float _LumaFilter[9] =
{
-0.0020, -0.0009, 0.0038, 0.0178, 0.0445,
0.0817, 0.1214, 0.1519, 0.1634
};
#line 327
float _ChromaFilter[9] =
{
0.0046, 0.0082, 0.0182, 0.0353, 0.0501,
0.0832, 0.1062, 0.1222, 0.1280
};
#line 333
float2 one_x = float2( 1.0 / 1280, 0.0 );
float3 signal = float3( 0.0, 0.0, 0.0 );
#line 336
for (int idx = 0; idx < 8; idx++)
{
float offset = float(idx);
#line 340
float4 sums = tex2D(samplerTarget1, texcoord + ( ( offset - 8.0 ) * one_x )) +
tex2D(samplerTarget1, texcoord + ( ( 8.0 - offset ) * one_x ));
#line 343
signal += sums.xyz * float3(_LumaFilter[idx], _ChromaFilter[idx], _ChromaFilter[idx]);
}
signal += tex2D(samplerTarget1, texcoord).xyz *
float3(_LumaFilter[8], _ChromaFilter[8], _ChromaFilter[8]);
#line 348
return float4( signal, 1.0 );
}
#line 352
float4 SVideoDecodePS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float2 pix_no : TEXCOORD1, float2 mask_uv : TEXCOORD2) : SV_Target
{
float _LumaFilter[9] =
{
-0.0020, -0.0009, 0.0038, 0.0178, 0.0445,
0.0817, 0.1214, 0.1519, 0.1634
};
#line 360
float _ChromaFilter[9] =
{
0.0046, 0.0082, 0.0182, 0.0353, 0.0501,
0.0832, 0.1062, 0.1222, 0.1280
};
#line 366
float2 one_x = float2( 1.0 / 1280, 0.0 );
float3 signal = float3( 0.0, 0.0, 0.0 );
#line 369
for (int idx = 0; idx < 8; idx++)
{
float offset = float(idx);
#line 373
float3 sums = tex2D(samplerTarget1, texcoord + ( ( offset - 8.0 ) * one_x )).xyz +
tex2D(samplerTarget1, texcoord + ( ( 8.0 - offset ) * one_x )).xyz;
#line 376
signal += sums * float3(0.0, _ChromaFilter[idx], _ChromaFilter[idx]);
}
signal += tex2D(samplerTarget1, texcoord).xyz *
float3(1.0, _ChromaFilter[8], _ChromaFilter[8]);
#line 381
return float4( signal, 1.0 );
}
#line 384
float4 CompositeFinalPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float2 pix_no : TEXCOORD1, float2 mask_uv : TEXCOORD2) : SV_Target
{
float2 one_x = float2( 1.0 / 1280, 0.0 ) * 2.0;
#line 388
float3 yiq = tex2D(samplerTarget0, texcoord).xyz;
float3 yiq2 = tex2D(samplerTarget0, texcoord + one_x).xyz;
float3 yiq3 = tex2D(samplerTarget0, texcoord - one_x).xyz;
#line 394
yiq.x += (yiq.x * luma_sharpen * 2) + (yiq2.x * -1 * luma_sharpen) + (yiq3.x * -1 * luma_sharpen);
#line 396
float3 rgb = mul( yiq2rgb, yiq );
#line 399
if (EnableRollingFlicker){
RollingFlicker(rgb, texcoord);
}
#line 404
if (EnablePixelMask) {
rgb *= tex2D( sampler_pixel_mask, mask_uv ).rgb * pixelMaskBrightness;
}
#line 408
if (EnableTVCurvature) {
rgb *= tex2D( sampler_tv_border, texcoord ).rgb;
}
#line 412
return float4( rgb, 1.0 );
}
#line 416
float4 VGAFinalPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float2 pix_no : TEXCOORD1, float2 mask_uv : TEXCOORD2) : SV_Target {
float3 rgb = tex2D(ReShade::BackBuffer, texcoord).rgb;
rgb = quantize_rgb( rgb );
#line 421
if (EnableRollingFlicker){
RollingFlicker(rgb, texcoord);
}
#line 426
if (EnablePixelMask) {
rgb *= tex2D( sampler_pixel_mask, mask_uv ).rgb * pixelMaskBrightness;
}
#line 431
if (EnableTVCurvature) {
rgb *= tex2D( sampler_tv_border, texcoord ).rgb;
}
#line 435
return float4(rgb.x, rgb.y, rgb.z, 1.0) * ( 1.0 - float4( 0.02, 0.02, 0.02, 0.0 ) ) + float4( 0.02, 0.02, 0.02, 0.0 );
}
#line 438
float4 SVideoFinalPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float2 pix_no : TEXCOORD1, float2 mask_uv : TEXCOORD2) : SV_Target
{
float3 yiq = tex2D(samplerTarget0, texcoord).xyz;
float3 rgb = mul( yiq2rgb, yiq );
#line 444
if (EnableRollingFlicker){
RollingFlicker(rgb, texcoord);
}
#line 449
if (EnablePixelMask) {
rgb *= tex2D( sampler_pixel_mask, mask_uv ).rgb * pixelMaskBrightness;
}
#line 453
if (EnableTVCurvature) {
rgb *= tex2D( sampler_tv_border, texcoord ).rgb;
}
#line 457
return float4( rgb, 1.0 );
}
#line 460
float4 TVCurvaturePS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
if (EnableTVCurvature) {
float2 coords = texcoord;
coords = ( coords - 0.5 ) * 2.0;
#line 466
const float2 intensity = float2( tv_curvature, tv_curvature ) * 0.1;
#line 468
float2 realCoordOffs;
realCoordOffs.x = (coords.y * coords.y) * intensity.y * (coords.x);
realCoordOffs.y = (coords.x * coords.x) * intensity.x * (coords.y);
#line 472
const float2 uv = texcoord + realCoordOffs;
#line 477
return tex2D(samplerTarget1, uv);
#line 479
} else {
#line 484
return tex2D(samplerTarget1, texcoord);
#line 486
}
}
#line 48 "C:\Program Files\GShade\gshade-shaders\Shaders\RetroTV.fx"
#line 50
float4 BlitCopyScreenPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
return tex2D(ReShade::BackBuffer, texcoord).rgba;
}
#line 56
float4 BlitCopyTargetPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
return tex2D(samplerTarget1, texcoord).rgba;
}
#line 62
technique Composite
{
#line 65
pass p0
{
RenderTarget = target0;
#line 69
VertexShader = PostProcessVS;
PixelShader = BlitCopyScreenPS;
}
#line 74
pass p1
{
RenderTarget = target1;
#line 78
VertexShader = RetroTV_VS;
PixelShader = CompositeEncodePS;
}
#line 83
pass p2
{
RenderTarget = target0;
#line 87
VertexShader = RetroTV_VS;
PixelShader = CompositeDecodePS;
}
#line 92
pass p3
{
RenderTarget = target1;
#line 96
VertexShader = RetroTV_VS;
PixelShader = CompositeFinalPS;
}
#line 101
pass p4
{
VertexShader = PostProcessVS;
PixelShader = TVCurvaturePS;
}
}
#line 109
technique RF
{
#line 112
pass p0
{
RenderTarget = target0;
#line 116
VertexShader = PostProcessVS;
PixelShader = BlitCopyScreenPS;
}
#line 121
pass p1
{
RenderTarget = target1;
#line 125
VertexShader = RetroTV_VS;
PixelShader = RFEncodePS;
}
#line 130
pass p2
{
RenderTarget = target0;
#line 134
VertexShader = RetroTV_VS;
PixelShader = RFDecodePS;
}
#line 139
pass p3
{
RenderTarget = target1;
#line 143
VertexShader = RetroTV_VS;
PixelShader = CompositeFinalPS;
}
#line 148
pass p4
{
VertexShader = PostProcessVS;
PixelShader = TVCurvaturePS;
}
}
#line 156
technique SVideo
{
#line 159
pass p0
{
RenderTarget = target0;
#line 163
VertexShader = PostProcessVS;
PixelShader = BlitCopyScreenPS;
}
#line 168
pass p1
{
RenderTarget = target1;
#line 172
VertexShader = RetroTV_VS;
PixelShader = SVideoEncodePS;
}
#line 177
pass p2
{
RenderTarget = target0;
#line 181
VertexShader = RetroTV_VS;
PixelShader = SVideoDecodePS;
}
#line 186
pass p3
{
RenderTarget = target1;
#line 190
VertexShader = RetroTV_VS;
PixelShader = SVideoFinalPS;
}
#line 195
pass p4
{
VertexShader = PostProcessVS;
PixelShader = TVCurvaturePS;
}
}
#line 202
technique VGA
{
#line 205
pass p1
{
RenderTarget = target1;
#line 209
VertexShader = RetroTV_VS;
PixelShader = VGAFinalPS;
}
#line 213
pass p2
{
VertexShader = PostProcessVS;
PixelShader = TVCurvaturePS;
}
}

