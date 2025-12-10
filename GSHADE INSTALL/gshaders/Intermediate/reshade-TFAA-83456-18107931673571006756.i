#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\TFAA.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 57
namespace ReShade
{
float GetAspectRatio() { return 1280 * (1.0 / 720); }
float2 GetPixelSize() { return float2((1.0 / 1280), (1.0 / 720)); }
float2 GetScreenSize() { return float2(1280, 720); }
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
#line 10 "C:\Program Files\GShade\gshade-shaders\Shaders\TFAA.fx"
#line 16
uniform float frametime < source = "frametime"; >;
#line 26
uniform float UI_TEMPORAL_FILTER_STRENGTH <
ui_type    = "slider";
ui_min     = 0.0;
ui_max     = 1.0;
ui_step    = 0.01;
ui_label   = "Temporal Filter Strength";
ui_category= "Temporal Filter";
ui_tooltip = "";
> = 0.5;
#line 39
uniform float UI_POST_SHARPEN <
ui_type    = "slider";
ui_min     = 0.0;
ui_max     = 1.0;
ui_step    = 0.01;
ui_label   = "Adaptive Sharpening";
ui_category= "Temporal Filter";
ui_tooltip = "";
> = 0.5;
#line 73
texture texDepthIn : DEPTH;
sampler smpDepthIn {
Texture = texDepthIn;
MipFilter = Linear;
MinFilter = Linear;
MagFilter = Linear;
};
#line 82
texture texInCur : COLOR;
sampler smpInCur {
Texture   = texInCur;
AddressU  = Clamp;
AddressV  = Clamp;
MipFilter = Linear;
MinFilter = Linear;
MagFilter = Linear;
};
#line 93
texture texInCurBackup < pooled = true; > {
Width   = 1280;
Height  = 720;
Format  = RGBA8;
};
#line 99
sampler smpInCurBackup {
Texture   = texInCurBackup;
AddressU  = Clamp;
AddressV  = Clamp;
MipFilter = Linear;
MinFilter = Linear;
MagFilter = Linear;
};
#line 109
texture texExpColor < pooled = true; > {
Width   = 1280;
Height  = 720;
Format  = RGBA16F;
};
#line 115
sampler smpExpColor {
Texture   = texExpColor;
AddressU  = Clamp;
AddressV  = Clamp;
MipFilter = Linear;
MinFilter = Linear;
MagFilter = Linear;
};
#line 125
texture texExpColorBackup < pooled = true; > {
Width   = 1280;
Height  = 720;
Format  = RGBA16F;
};
#line 131
sampler smpExpColorBackup {
Texture   = texExpColorBackup;
AddressU  = Clamp;
AddressV  = Clamp;
MipFilter = Linear;
MinFilter = Linear;
MagFilter = Linear;
};
#line 141
texture texDepthBackup < pooled = true; > {
Width   = 1280;
Height  = 720;
Format  = R16f;
};
#line 147
sampler smpDepthBackup {
Texture   = texDepthBackup;
AddressU  = Clamp;
AddressV  = Clamp;
MipFilter = Point;
MinFilter = Point;
MagFilter = Point;
};
#line 168
float4 tex2Dlod(sampler s, float2 uv, float mip)
{
return tex2Dlod(s, float4(uv, 0, mip));
}
#line 179
float3 cvtRgb2YCbCr(float3 rgb)
{
float y  = 0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b;
float cb = (rgb.b - y) * 0.565;
float cr = (rgb.r - y) * 0.713;
#line 185
return float3(y, cb, cr);
}
#line 194
float3 cvtYCbCr2Rgb(float3 YCbCr)
{
return float3(
YCbCr.x + 1.403 * YCbCr.z,
YCbCr.x - 0.344 * YCbCr.y - 0.714 * YCbCr.z,
YCbCr.x + 1.770 * YCbCr.y
);
}
#line 211
float3 cvtRgb2whatever(float3 rgb)
{
return cvtRgb2YCbCr(rgb);
}
#line 237
float3 cvtWhatever2Rgb(float3 whatever)
{
return cvtYCbCr2Rgb(whatever);
}
#line 264
float4 bicubic_5(sampler source, float2 texcoord)
{
#line 267
float2 texsize = tex2Dsize(source);
#line 270
float2 UV = texcoord * texsize;
#line 273
float2 tc = floor(UV - 0.5) + 0.5;
#line 276
float2 f = UV - tc;
#line 279
float2 f2 = f * f;
float2 f3 = f2 * f;
#line 283
float2 w0 = f2 - 0.5 * (f3 + f);
float2 w1 = 1.5 * f3 - 2.5 * f2 + 1.0;
float2 w3 = 0.5 * (f3 - f2);
float2 w12 = 1.0 - w0 - w3;
#line 289
float4 ws[3];
ws[0].xy = w0;
ws[1].xy = w12;
ws[2].xy = w3;
#line 295
ws[0].zw = tc - 1.0;
ws[1].zw = tc + 1.0 - w1 / w12;
ws[2].zw = tc + 2.0;
#line 300
ws[0].zw /= texsize;
ws[1].zw /= texsize;
ws[2].zw /= texsize;
#line 305
float4 ret;
ret  = tex2Dlod(source, float2(ws[1].z, ws[0].w), 0) * ws[1].x * ws[0].y;
ret += tex2Dlod(source, float2(ws[0].z, ws[1].w), 0) * ws[0].x * ws[1].y;
ret += tex2Dlod(source, float2(ws[1].z, ws[1].w), 0) * ws[1].x * ws[1].y;
ret += tex2Dlod(source, float2(ws[2].z, ws[1].w), 0) * ws[2].x * ws[1].y;
ret += tex2Dlod(source, float2(ws[1].z, ws[2].w), 0) * ws[1].x * ws[2].y;
#line 313
float normfact = 1.0 / (1.0 - (f.x - f2.x) * (f.y - f2.y) * 0.25);
return max(0, ret * normfact);
}
#line 326
float4 sampleHistory(sampler2D historySampler, float2 texcoord)
{
return bicubic_5(historySampler, texcoord);
}
#line 340
float getDepth(float2 texcoord)
{
#line 343
float depth = tex2Dlod(smpDepthIn, texcoord, 0).x;
#line 351
const float N = 1.0;
#line 353
float factor = 1000.0 * 0.1;
#line 356
depth /= factor - depth * (factor - N);
#line 358
return depth;
}
#line 366
namespace Deferred
{
#line 370
texture MotionVectorsTex {
Width  = 1280;
Height = 720;
Format = RG16F;
};
sampler sMotionVectorsTex {
Texture = MotionVectorsTex;
};
#line 385
float2 get_motion(float2 uv)
{
return tex2Dlod(sMotionVectorsTex, uv, 0).xy;
}
}
#line 406
float4 PassSaveCur(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target0
{
#line 409
float depthOnly = getDepth(texcoord);
#line 412
return float4(tex2Dlod(smpInCur, texcoord, 0).rgb, depthOnly);
}
#line 427
float4 PassTemporalFilter(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 430
float4 sampleCur = tex2Dlod(smpInCurBackup, texcoord, 0);
float4 cvtColorCur = float4(cvtRgb2whatever(sampleCur.rgb), sampleCur.a);
#line 433
static const int samples = 9;
#line 436
static const float2 nOffsets[samples] = {
float2(-0.7,-0.7), float2(0, 1),  float2(0.7, 0.7),
float2(-1, 0),     float2(0, 0),  float2(1, 0),
float2(-0.7, 0.7), float2(0, -1), float2(0.7, 0.7)
};
#line 444
int closestDepthIndex = 4;
#line 447
float4 minimumCvt = 2;
float4 maximumCvt = -1;
#line 451
for (int i = 0; i < samples; i++)
{
float4 rgba = tex2Dlod(smpInCurBackup, texcoord + (nOffsets[i] * ReShade::GetPixelSize()), 0);
float4 cvt = float4(cvtRgb2whatever(rgba.rgb), rgba.a);
#line 456
if (rgba.a < minimumCvt.a)
closestDepthIndex = i;
#line 459
minimumCvt = min(minimumCvt, cvt);
maximumCvt = max(maximumCvt, cvt);
}
#line 464
float2 motion = Deferred::get_motion(texcoord + (nOffsets[closestDepthIndex] * ReShade::GetPixelSize()));
#line 467
float2 lastSamplePos = texcoord + motion;
#line 470
float4 sampleExp = saturate(sampleHistory(smpExpColorBackup, lastSamplePos));
float lastDepth = tex2Dlod(smpDepthBackup, lastSamplePos, 0).r;
#line 475
float localContrast= saturate(pow(length(maximumCvt.rgb - minimumCvt.rgb), 0.75));
float speed        = length(motion.xy);
float speedFactor  = 1.0 - pow(saturate(speed * 50), 0.75);
#line 480
float depthDelta = saturate(minimumCvt.a - lastDepth);
depthDelta = saturate(pow(depthDelta, 4) - 0.0000001);
float depthMask = 1.0 - (depthDelta * 10000000);
#line 485
float weight = lerp(0.5, 0.99, pow(UI_TEMPORAL_FILTER_STRENGTH, 0.5));
weight = clamp(weight * speedFactor * saturate(localContrast + 0.75) * depthMask, 0.0, 0.99);
#line 489
const static float correctionFactor = 2;
#line 492
float4 blendedColor = saturate(pow(lerp(pow(sampleCur, correctionFactor), pow(sampleExp, correctionFactor), weight), (1.0 / correctionFactor)));
#line 495
blendedColor = float4(cvtRgb2whatever(blendedColor.rgb), blendedColor.a);
#line 498
blendedColor = float4(clamp(blendedColor.rgb, minimumCvt.rgb, maximumCvt.rgb), blendedColor.a);
#line 501
blendedColor = float4(cvtWhatever2Rgb(blendedColor.rgb), blendedColor.a);
#line 504
float sharp = saturate(UI_POST_SHARPEN * UI_TEMPORAL_FILTER_STRENGTH * pow(speed * 2048, 0.5) * localContrast * depthMask);
#line 508
float3 return_value = blendedColor.rgb;
#line 525
return float4(return_value, sharp);
}
#line 539
void PassSavePost(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 lastExpOut : SV_Target0, out float depthOnly : SV_Target1)
{
#line 542
lastExpOut = tex2Dlod(smpExpColor, texcoord, 0);
#line 545
depthOnly = getDepth(texcoord);
}
#line 557
float4 PassSharp(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{
#line 560
float4 center     = tex2Dlod(smpExpColor, texcoord, 0);
float4 top        = tex2Dlod(smpExpColor, texcoord + (float2(0, -1) * ReShade::GetPixelSize()), 0);
float4 bottom     = tex2Dlod(smpExpColor, texcoord + (float2(0,  1) * ReShade::GetPixelSize()), 0);
float4 left       = tex2Dlod(smpExpColor, texcoord + (float2(-1, 0) * ReShade::GetPixelSize()), 0);
float4 right      = tex2Dlod(smpExpColor, texcoord + (float2(1,  0) * ReShade::GetPixelSize()), 0);
#line 567
float4 maxBox = max(top, max(bottom, max(left, max(right, center))));
float4 minBox = min(top, min(bottom, min(left, min(right, center))));
#line 571
float contrast = 0.8;
float sharpAmount = saturate(maxBox.a * 10);
#line 575
float4 crossWeight = -rcp(rsqrt(saturate(min(minBox, 1.0 - maxBox) * rcp(maxBox))) * (-3.0 * contrast + 8.0));
#line 578
float4 rcpWeight = rcp(4.0 * crossWeight + 1.0);
#line 581
float4 crossSumm = top + bottom + left + right;
#line 584
return lerp(center, saturate((crossSumm * crossWeight + center) * rcpWeight), sharpAmount);
#line 586
}
#line 602
technique TFAA
<
ui_label = "TFAA";
ui_tooltip = "- Temporal Filter Anti-Aliasing -\nTemporal component of TAA to be used with (after) spatial anti-aliasing techniques.\nRequires motion vectors to be available (LAUNCHPAD.fx).";
>
{
pass PassSavePre
{
VertexShader   = PostProcessVS;
PixelShader    = PassSaveCur;
RenderTarget   = texInCurBackup;
}
#line 615
pass PassTemporalFilter
{
VertexShader   = PostProcessVS;
PixelShader    = PassTemporalFilter;
RenderTarget   = texExpColor;
}
#line 622
pass PassSavePost
{
VertexShader   = PostProcessVS;
PixelShader    = PassSavePost;
RenderTarget0  = texExpColorBackup;
RenderTarget1  = texDepthBackup;
}
#line 630
pass PassShow
{
VertexShader   = PostProcessVS;
PixelShader    = PassSharp;
}
}

