// pBloomPrecision=RGBA16
// pBloomDownsampling=4
// PPFXBloomDirtTex="DirtA.png"
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PPFX_Bloom.fx"
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
#line 12 "C:\Program Files\GShade\gshade-shaders\Shaders\PPFX_Bloom.fx"
#line 26
uniform bool pEnableHDR <
ui_category = "HDR & Tonemap";
ui_label = "Enable HDR & Tonemap";
ui_tooltip = "As brightness-increasing effects like bloom will push colors above the maximum brightness of standard displays and thus oversaturate colors and lead to ugly white 'patches' in bright areas, the colors have to be 'remapped' into the displays range.\nSeveral techniques exist for that, actually it's a whole scientific field. Configurable of course.";
> = 0;
#line 33
uniform int pTonemapMode <
ui_category = "HDR & Tonemap";
ui_label = "Tonemap Mode";
ui_tooltip = "Choose a tonemapping algorithm fitting your personal taste.";
ui_type = "combo";
ui_items="Linear, recommended for really low bloomIntensity-values\0Square\0Log10-logarithmic + exposure correction)\0";
> = 0;
#line 41
uniform float pTonemapCurve <
ui_category = "HDR & Tonemap";
ui_label = "Tonemap Curve";
ui_tooltip = "How 'aggressive' bright colors are compressed. High values may darken the shadows and mid-tones while preserving details in bright regions (almost-bright skies, for instance).";
ui_type = "slider";
ui_min = 1.0;
ui_max = 100.0;
ui_step = 0.5;
> = 3.0;
#line 51
uniform float pTonemapExposure <
ui_category = "HDR & Tonemap";
ui_label = "Tonemap Exposure Adjustment";
ui_tooltip = "Every pixel is multiplied by this value before being tonemapped. You can use this as a brightness control or to specify a mid-gray value for Tonemap Contrast.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 10.0;
ui_step = 0.001;
> = 1.2;
#line 61
uniform float pTonemapContrast <
ui_category = "HDR & Tonemap";
ui_label = "Tonemap Contrast Intensity";
ui_tooltip = "Pixels darker than 1 are darkened, pixels above are exposed by this option. Combine with higher (2 - 7) tonemapExposure-values to create get a desirable look.";
ui_type = "slider";
ui_min = 0.1;
ui_max = 10.0;
ui_step = 0.001;
> = 1.020;
#line 71
uniform float pTonemapSaturateBlacks <
ui_category = "HDR & Tonemap";
ui_label = "Tonemap Black Saturation";
ui_tooltip = "Some tonemapping algorithms may desaturate your shadows - this option corrects this issue. Dont's use too high values, it is purposed to be a subtle correction.";
ui_type = "slider";
ui_min = 0.01;
ui_max = 1.0;
ui_step = 0.001;
> = 0.0;
#line 90
uniform float pBloomRadius <
ui_category = "Bloom";
ui_label = "Bloom Sample Radius";
ui_tooltip = "Maximum distance within pixels affect each other - directly affects performance: Combine with pBloomDownsampling to increase your effective radius while keeping a high framerate.";
ui_type = "slider";
ui_min = 2.0;
ui_max = 250.0;
ui_step = 1.0;
> = 64.0;
#line 100
uniform float pBloomIntensity <
ui_category = "Bloom";
ui_label = "Bloom Overall-Intensity";
ui_tooltip = "The bloom's exposure, I strongly suggest combining this with a tonemap if you choose a high value here.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.2;
> = 0.5;
#line 110
uniform int pBloomBlendMode <
ui_category = "Bloom";
ui_label = "Bloom Blend Mode";
ui_tooltip = "Controls how the bloom is mixed with the original frame.";
ui_type = "combo";
ui_items="Additive (recommended with tonemaps)\0Lighten (great for night scenes)\0Cover (for configuring/debugging)\0";
> = 0;
#line 118
uniform float pBloomThreshold <
ui_category = "Bloom";
ui_label = "Bloom Threshold";
ui_tooltip = "Pixels darker than this value won't cast bloom.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.4;
#line 128
uniform float pBloomCurve <
ui_category = "Bloom";
ui_label = "Bloom Curve";
ui_tooltip = "The effect's gamma curve - the higher, the more will bloom be damped in dark areas - and vice versa.";
ui_type = "slider";
ui_min = 0.1;
ui_max = 4.0;
ui_step = 0.01;
> = 1.5;
#line 138
uniform float pBloomSaturation <
ui_category = "Bloom";
ui_label = "Bloom Saturation";
ui_tooltip = "The effect's color saturation. 0 means white, uncolored bloom, 1.500-3.000 yields a vibrant effect while everything above should make your eyes bleed.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.001;
> = 2.0;
#line 149
uniform bool pEnableLensdirt <
ui_category = "Lensdirt";
ui_label = "Enable Lensdirt";
ui_tooltip = "Simulates a dirty lens. This effect was introduced in Battlefield 3 back in 2011 and since then was used by many further gamestudios.\nIf enabled, the bloom texture will be used for brightness check, thus scaling the intensity with the local luma instead of the current pixels' one.";
> = 0;
#line 155
uniform float pLensdirtIntensity <
ui_category = "Lensdirt";
ui_label = "Lensdirt Intensity";
ui_tooltip = "The dirt texture's maximum intensity.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.01;
> = 1.0;
#line 165
uniform float pLensdirtCurve <
ui_category = "Lensdirt";
ui_label = "Lensdirt Curve";
ui_tooltip = "The curve which the dirt texture's intensity scales with - try higher values to limit visibility solely to bright/almost-white scenes.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.1;
> = 1.2;
#line 180
texture2D texColor : COLOR;
texture texColorHDRA { Width = 1280; Height = 720; Format = RGBA16F; };
texture texColorHDRB < pooled = true; > { Width = 1280; Height = 720; Format = RGBA16F; };
#line 185
texture texBloomA
{
Width = 1280/4;
Height = 720/4;
#line 190
Format = RGBA16;
};
texture texBloomB < pooled = true; >
{
Width = 1280/4;
Height = 720/4;
Format = RGBA16;
};
#line 200
texture texBDirt < source = "DirtA.png"; >
{
Width = 1920;
Height = 1080;
};
#line 211
sampler2D SamplerColor
{
Texture = texColor;
AddressU = BORDER;
AddressV = BORDER;
MinFilter = LINEAR;
MagFilter = LINEAR;
#line 219
SRGBTexture = TRUE;
#line 221
};
#line 223
sampler SamplerColorHDRA
{
Texture = texColorHDRA;
AddressU = BORDER;
AddressV = BORDER;
MinFilter = LINEAR;
MagFilter = LINEAR;
};
#line 232
sampler SamplerColorHDRB
{
Texture = texColorHDRB;
AddressU = BORDER;
AddressV = BORDER;
MinFilter = LINEAR;
MagFilter = LINEAR;
};
#line 242
sampler SamplerBloomA
{
Texture = texBloomA;
};
sampler SamplerBloomB
{
Texture = texBloomB;
};
#line 252
sampler SamplerDirt
{
Texture = texBDirt;
SRGBTexture = TRUE;
};
#line 262
static const float2 pxSize = float2((1.0 / 1280),(1.0 / 720));
static const float3 lumaCoeff = float3(0.2126f,0.7152f,0.0722f);
#line 269
struct VS_OUTPUT_POST
{
float4 vpos : SV_Position;
float2 txcoord : TEXCOORD0;
};
#line 275
struct VS_INPUT_POST
{
uint id : SV_VertexID;
};
#line 284
float3 threshold(float3 pxInput, float colThreshold)
{
return pxInput*saturate(sign(max(pxInput.x,max(pxInput.y,pxInput.z))-colThreshold));
}
#line 296
float3 FX_BlurH( float3 pxInput, sampler source, float2 txCoords, float radius, float downsampling )
{
const float	texelSize = pxSize.x*downsampling;
float2	fetchCoords = txCoords;
float	weight;
const float	weightDiv = 1.0+5.0/radius;
float	sampleSum = 0.5;
#line 304
pxInput+=tex2D(source,txCoords).xyz*0.5;
#line 306
[loop]
for (float hOffs=1.5; hOffs<radius; hOffs+=2.0)
{
weight = 1.0/pow(abs(weightDiv),hOffs*hOffs/radius);
fetchCoords = txCoords;
fetchCoords.x += texelSize * hOffs;
pxInput+=tex2Dlod(source, float4(fetchCoords, 0.0, 0.0)).xyz * weight;
fetchCoords = txCoords;
fetchCoords.x -= texelSize * hOffs;
pxInput+=tex2Dlod(source, float4(fetchCoords, 0.0, 0.0)).xyz * weight;
sampleSum += 2.0 * weight;
}
pxInput /= sampleSum;
#line 320
return pxInput;
}
#line 324
float3 FX_BlurV( float3 pxInput, sampler source, float2 txCoords, float radius, float downsampling )
{
const float	texelSize = pxSize.y*downsampling;
float2	fetchCoords = txCoords;
float	weight;
const float	weightDiv = 1.0+5.0/radius;
float	sampleSum = 0.5;
#line 332
pxInput+=tex2D(source,txCoords).xyz*0.5;
#line 334
[loop]
for (float vOffs=1.5; vOffs<radius; vOffs+=2.0)
{
weight = 1.0/pow(abs(weightDiv),vOffs*vOffs/radius);
fetchCoords = txCoords;
fetchCoords.y += texelSize * vOffs;
pxInput+=tex2Dlod(source, float4(fetchCoords, 0.0, 0.0)).xyz * weight;
fetchCoords = txCoords;
fetchCoords.y -= texelSize * vOffs;
pxInput+=tex2Dlod(source, float4(fetchCoords, 0.0, 0.0)).xyz * weight;
sampleSum += 2.0 * weight;
}
pxInput /= sampleSum;
#line 348
return pxInput;
}
#line 354
float4 FX_BloomMix( float3 pxInput, float2 txCoords )
{
float3 blurTexture = tex2D(SamplerBloomA,txCoords).xyz;
#line 358
if (pEnableLensdirt)
pxInput += tex2D(SamplerDirt, txCoords).xyz*pow(dot(abs(blurTexture),lumaCoeff),pLensdirtCurve)*pLensdirtIntensity;
blurTexture = pow(abs(blurTexture),pBloomCurve);
blurTexture = lerp(dot(blurTexture.xyz,lumaCoeff.xyz),blurTexture,pBloomSaturation);
blurTexture /= max(1.0,max(blurTexture.x,max(blurTexture.y,blurTexture.z)));
if (pBloomBlendMode == 0)
{
pxInput = pxInput+blurTexture*pBloomIntensity;
return float4(pxInput,1.0+pBloomIntensity);
}
else if (pBloomBlendMode == 1)
{
pxInput = max(pxInput,blurTexture*pBloomIntensity);
return float4(pxInput,max(1.0,pBloomIntensity));
}
else
{
pxInput = blurTexture;
return float4(pxInput,pBloomIntensity);
}
}
#line 381
float3 FX_Tonemap( float3 pxInput, float whitePoint )
{
pxInput = pow(abs(pxInput*pTonemapExposure),pTonemapContrast);
whitePoint = pow(abs(whitePoint*pTonemapExposure),pTonemapContrast);
#line 386
if (pTonemapMode == 1)
return saturate(pxInput.xyz/(whitePoint*pTonemapCurve));
else if (pTonemapMode == 2)
return saturate(lerp(pxInput,pow(abs(pxInput.xyz/whitePoint),whitePoint-pxInput),dot(pxInput/whitePoint,lumaCoeff)));
else
{
const float exposureDiv = log10(whitePoint+1.0)/log10(whitePoint+1.0+pTonemapCurve);
pxInput.xyz = (log10(pxInput+1.0)/log10(pxInput+1.0+pTonemapCurve))/exposureDiv;
return saturate(lerp(pow(abs(pxInput.xyz), 1.0 + pTonemapSaturateBlacks), pxInput.xyz, sqrt( pxInput.xyz ) ) );
}
}
#line 402
VS_OUTPUT_POST VS_PostProcess(VS_INPUT_POST IN)
{
VS_OUTPUT_POST OUT;
#line 406
if (IN.id == 2)
OUT.txcoord.x = 2.0;
else
OUT.txcoord.x = 0.0;
#line 411
if (IN.id == 1)
OUT.txcoord.y = 2.0;
else
OUT.txcoord.y = 0.0;
#line 416
OUT.vpos = float4(OUT.txcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
return OUT;
}
#line 425
float4 PS_SetOriginal(VS_OUTPUT_POST IN) : COLOR
{
if (pEnableHDR == 0)
return tex2D(ReShade::BackBuffer,IN.txcoord.xy);
else
return float4(tex2D(SamplerColor,IN.txcoord.xy).xyz,1.0);
}
#line 434
float4 PS_BloomThreshold(VS_OUTPUT_POST IN) : COLOR
{
return float4(threshold(tex2D(SamplerColorHDRA,IN.txcoord.xy).xyz,pBloomThreshold),1.0);
}
#line 439
float4 PS_BloomH_RadA(VS_OUTPUT_POST IN) : COLOR
{
return float4(FX_BlurH(0.0,SamplerBloomA,IN.txcoord.xy,pBloomRadius,4),1.0);
}
#line 444
float4 PS_BloomV_RadA(VS_OUTPUT_POST IN) : COLOR
{
return float4(FX_BlurV(0.0,SamplerBloomB,IN.txcoord.xy,pBloomRadius,4),1.0);
}
#line 449
float4 PS_BloomMix(VS_OUTPUT_POST IN) : COLOR
{
return FX_BloomMix(tex2D(SamplerColorHDRA,IN.txcoord.xy).xyz,IN.txcoord.xy);
}
#line 455
float4 PS_LightFX(VS_OUTPUT_POST IN) : COLOR
{
const float2 pxCoord = IN.txcoord.xy;
float4 res = tex2D(SamplerColorHDRB,pxCoord);
#line 460
if (pEnableHDR == 1)
res.xyz = FX_Tonemap(res.xyz,res.w);
#line 463
return res;
}
#line 466
float4 PS_ColorFX(VS_OUTPUT_POST IN) : COLOR
{
const float2 pxCoord = IN.txcoord.xy;
const float4 res = tex2D(SamplerColorHDRA,pxCoord);
#line 471
return float4(res.xyz,1.0);
}
#line 474
float4 PS_ImageFX(VS_OUTPUT_POST IN) : COLOR
{
const float2 pxCoord = IN.txcoord.xy;
const float4 res = tex2D(SamplerColorHDRB,pxCoord);
#line 482
return float4(res.xyz, 1.0);
#line 484
}
#line 490
technique PPFXBloom < ui_label = "PPFX Bloom"; ui_tooltip = "Bloom | This effect lets bright pixels bleed their light into their surroundings. It is fast, highly customizable and fits to many games."; >
{
pass setOriginal
{
VertexShader = VS_PostProcess;
PixelShader = PS_SetOriginal;
RenderTarget0 = texColorHDRA;
}
pass bloomThresh
{
VertexShader = VS_PostProcess;
PixelShader = PS_BloomThreshold;
RenderTarget0 = texBloomA;
}
#line 505
pass bloomH_RadA
{
VertexShader = VS_PostProcess;
PixelShader = PS_BloomH_RadA;
RenderTarget0 = texBloomB;
}
#line 512
pass bloomV_RadA
{
VertexShader = VS_PostProcess;
PixelShader = PS_BloomV_RadA;
RenderTarget0 = texBloomA;
}
#line 519
pass bloomMix
{
VertexShader = VS_PostProcess;
PixelShader = PS_BloomMix;
RenderTarget0 = texColorHDRB;
}
pass lightFX
{
VertexShader = VS_PostProcess;
PixelShader = PS_LightFX;
RenderTarget0 = texColorHDRA;
}
pass colorFX
{
VertexShader = VS_PostProcess;
PixelShader = PS_ColorFX;
RenderTarget0 = texColorHDRB;
}
#line 538
pass imageFX
{
VertexShader = VS_PostProcess;
PixelShader = PS_ImageFX;
}
}

