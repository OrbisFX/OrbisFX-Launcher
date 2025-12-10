// ITU_REC=709
// CONTRAST_SHARPEN_RADIUS=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ContrastSharpening.fx"
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
#line 50 "C:\Program Files\GShade\gshade-shaders\Shaders\ContrastSharpening.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorConversion.fxh"
#line 52
namespace ColorConvert
{
#line 67
static const float3x3 YCbCrMtx =
float3x3(
float3(0.2126, 1f-0.2126-0.0722, 0.0722), 
float3(-0.5*0.2126/(1f-0.0722), -0.5*(1f-0.2126-0.0722)/(1f-0.0722), 0.5), 
float3(0.5, -0.5*(1f-0.2126-0.0722)/(1f-0.2126), -0.5*0.0722/(1f-0.2126))  
);
#line 75
static const float3x3 RGBMtx =
float3x3(
float3(1f, 0f, 2f-2f*0.2126), 
float3(1f, -0.0722/(1f-0.2126-0.0722)*(2f-2f*0.0722), -0.2126/(1f-0.2126-0.0722)*(2f-2f*0.2126)), 
float3(1f, 2f-2f*0.0722, 0f) 
);
#line 86
float3 RGB_to_YCbCr(float3 color)  
{ return mul(YCbCrMtx, color);}
float  RGB_to_Luma(float3 color)   
{ return dot(YCbCrMtx[0], color);}
float2 RGB_to_Chroma(float3 color) 
{ return float2(dot(YCbCrMtx[1], color), dot(YCbCrMtx[2], color));}
#line 93
float3 YCbCr_to_RGB(float3 color)  
{ return mul(RGBMtx, color);}
}
#line 51 "C:\Program Files\GShade\gshade-shaders\Shaders\ContrastSharpening.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\BlueNoiseDither.fxh"
#line 54
namespace BlueNoise
{
#line 59
texture BlueNoiseTex
<
source = "j_bluenoise.png";
pooled = true;
>
{
Width = 64u;
Height = 64u;
Format = RGBA8;
};
#line 70
sampler BlueNoiseTexSmp
{
Texture = BlueNoiseTex;
#line 74
AddressU = REPEAT;
AddressV = REPEAT;
};
#line 87
float dither(float gradient, uint2 pixelPos)
{
#line 90
float noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u).r;
#line 92
gradient = ceil(mad(255u, gradient, -noise)); 
#line 94
return gradient/255u;
}
float3 dither(float3 color, uint2 pixelPos)
{
#line 99
float3 noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u).rgb;
#line 101
color = ceil(mad(255u, color, -noise)); 
#line 103
return color/255u;
}
float4 dither(float4 color, uint2 pixelPos)
{
#line 108
float4 noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u);
#line 110
color = ceil(mad(255u, color, -noise)); 
#line 112
return color/255u;
}
}
#line 52 "C:\Program Files\GShade\gshade-shaders\Shaders\ContrastSharpening.fx"
#line 58
uniform uint SharpenRadius
<
ui_type = "slider";
ui_label = "sharpening radius";
ui_tooltip =
"Sharpening sampling radius in pixels,\n"
"with Gaussian falloff.\n"
"This setting directly affects performance.";
ui_min = 2u; ui_max = 32u;
ui_category = "sharpening settings";
> = 16u;
#line 71
uniform float SharpenAmount
<
ui_type = "slider";
ui_label = "sharpening amount";
ui_tooltip =
"High-pass layer multiplier.\n"
"Values higher than 1.0 may increase noise.";
ui_min = 0f; ui_max = 2f;
ui_step = 0.01;
ui_category = "sharpening settings";
> = 1f;
#line 83
uniform uint BlendingMode
<
ui_type = "radio";
ui_label = "sharpening mode";
ui_tooltip = "Blending mode for the high-pass layer.";
ui_items =
"hard light\0"
"overlay\0";
ui_category = "sharpening settings";
> = 0u;
#line 94
uniform float ContrastAmount
<
ui_type = "slider";
ui_label = "contrast amount";
ui_tooltip =
"Contrast limiting threshold.\n"
"Lower values remove 'halos'.";
ui_min = 0.01; ui_max = 1f;
ui_step = 0.01;
ui_category = "additional settings";
ui_category_closed = true;
> = 0.16;
#line 107
uniform bool DitheringEnabled
<
ui_type = "input";
ui_label = "remove banding";
ui_tooltip =
"Applies invisible dithering effect, to\n"
"increase perceivable image bit-depth.";
ui_category = "additional settings";
> = true;
#line 122
texture ContrastSharpenTarget
{
Width  = 1920;
Height = 1018;
#line 127
Format = R8;
};
sampler ContrastSharpenSampler
{ Texture = ContrastSharpenTarget; };
#line 140
float bellWeight(float position)
{
#line 143
const float deviation = log(rcp(256u)); 
#line 145
return exp(position*position*deviation); 
}
#line 150
float overlay(float baseLayer, float blendLayer)
{
baseLayer *= 2f;
return mad(mad(
-min(baseLayer, 1f), blendLayer, 1f), 
max(baseLayer, 1f)-2f,               
1f);
}
#line 164
void ContrastSharpenVS(
in  uint   vertexId  : SV_VertexID,
out float4 vertexPos : SV_Position
)
{
#line 170
const float2 vertexPosList[3] =
{
float2(-1f, 1f), 
float2(-1f,-3f), 
float2( 3f, 1f)  
};
#line 177
vertexPos.xy = vertexPosList[vertexId];
vertexPos.zw = float2(0f, 1f); 
}
#line 182
void ContrastSharpenPassHorizontalPS(
in  float4  pixCoord : SV_Position,
out float luminosity : SV_Target
)
{
#line 188
uint2 texelPos = uint2(pixCoord.xy);
#line 190
luminosity = ColorConvert::RGB_to_Luma(tex2Dfetch(ReShade::BackBuffer, texelPos).rgb);
#line 192
float cumilativeLuminosity = 0f, cumulativeWeight = 0f;
#line 198
for (uint yPos=0u; yPos<=SharpenRadius*2u; yPos++)
{
#line 201
float sampleLuminosity = ColorConvert::RGB_to_Luma(
tex2Dfetch(ReShade::BackBuffer, uint2(
texelPos.x,
#line 205
clamp(int(texelPos.y+yPos)-SharpenRadius, 0, int(1018)-1)
)).rgb
);
#line 209
const float stepSize = rcp(SharpenRadius);
#line 213
 
float sampleWeight =
#line 216
bellWeight(mad(yPos, stepSize, -1f));
float sampleContrastWeight = saturate(abs(sampleLuminosity-luminosity)/ContrastAmount); 
sampleContrastWeight = bellWeight(sampleContrastWeight); 
#line 220
sampleContrastWeight *=
#line 223
 
sampleWeight;
#line 226
cumilativeLuminosity += sampleLuminosity*sampleContrastWeight;
cumulativeWeight += sampleContrastWeight;
}
#line 230
luminosity = cumilativeLuminosity/cumulativeWeight;
#line 233
if (DitheringEnabled)
luminosity = BlueNoise::dither(luminosity, uint2(pixCoord.xy));
}
#line 238
void ContrastSharpenPassVerticalPS(
in  float4 pixCoord : SV_Position,
out float3    color : SV_Target
)
{
#line 244
uint2 texelPos = uint2(pixCoord.xy);
#line 246
color = ColorConvert::RGB_to_YCbCr(tex2Dfetch(ReShade::BackBuffer, texelPos).rgb);
#line 248
float cumilativeLuminosity = 0f, cumulativeWeight = 0f;
#line 254
for (uint xPos=0u; xPos<=SharpenRadius*2u; xPos++)
{
#line 257
float sampleLuminosity = tex2Dfetch(ContrastSharpenSampler, uint2(
#line 259
clamp(int(texelPos.x+xPos)-SharpenRadius, 0, int(1920)-1),
texelPos.y
)).r;
#line 263
const float stepSize = rcp(SharpenRadius);
#line 267
 
float sampleWeight =
#line 270
bellWeight(mad(xPos, stepSize, -1f)); 
float sampleContrastWeight = saturate(abs(sampleLuminosity-color.x)/ContrastAmount); 
sampleContrastWeight = bellWeight(sampleContrastWeight); 
#line 274
sampleContrastWeight *=
#line 277
 
sampleWeight;
#line 280
cumilativeLuminosity += sampleLuminosity*sampleContrastWeight;
cumulativeWeight += sampleContrastWeight;
}
#line 284
cumilativeLuminosity /= cumulativeWeight;
#line 286
float highPass = mad(color.x-cumilativeLuminosity, SharpenAmount*0.5, 0.5);
#line 288
switch (BlendingMode)
{
case 1: 
color.x = overlay(color.x, highPass);
break;
default: 
color.x = overlay(highPass, color.x);
break;
}
#line 298
color = saturate(ColorConvert::YCbCr_to_RGB(color)); 
#line 301
if (DitheringEnabled)
color = BlueNoise::dither(color, uint2(pixCoord.xy));
}
#line 309
technique ContrastSharpen
<
ui_label = "Contrast Limited Sharpening";
ui_tooltip =
"Contrast Limited Sharpening effect.\n"
"\n"
"Increases local contrast without enhancing\n"
"already sharp edges.\n"
"\n"
"	· dynamic or fixed per-pixel sampling.\n"
"	· removes 'halo' effect.\n"
"	· removes 'banding' effect.\n"
"\n"
"This effect © 2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY-NC-ND 3.0 +\n"
"for additional permissions see the source code.";
>
{
pass GaussianContrastBlurHorizontal
{
RenderTarget = ContrastSharpenTarget;
#line 331
VertexShader = ContrastSharpenVS;
PixelShader  = ContrastSharpenPassHorizontalPS;
}
pass GaussianContrastBlurVerticalAndSharpening
{
VertexShader = ContrastSharpenVS;
PixelShader  = ContrastSharpenPassVerticalPS;
}
}

