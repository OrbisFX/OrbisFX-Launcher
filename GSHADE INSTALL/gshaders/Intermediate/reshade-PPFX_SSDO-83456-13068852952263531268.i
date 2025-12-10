// qSSDOFilterPrecision=RGBA16
// pSSDOFilterScale=1.0
// pSSDOLOD=1.0
// pSSDOSamplePrecision=RGBA16F
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PPFX_SSDO.fx"
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
#line 12 "C:\Program Files\GShade\gshade-shaders\Shaders\PPFX_SSDO.fx"
#line 34
uniform float pSSDOIntensity <
ui_label = "SSDO Intensity";
ui_tooltip = "The intensity curve applied to the effect. High values may produce banding when used along with RGBA8 FilterPrecision.\nAs increasing the precision to RGBA16F will heavily affect performance, rather combine Intensity and Amount if you want high visibility.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 20.0;
ui_step = 0.001;
> = 1.5;
#line 43
uniform float pSSDOAmount <
ui_label = "SSDO Amount";
ui_tooltip = "A multiplier applied to occlusion/lighting factors when they are calculated. High values increase the effect's visibilty but may expose artifacts and noise.";
ui_type = "slider";
ui_min = 0.01;
ui_max = 10.0;
ui_step = 0.01;
> = 1.5;
#line 52
uniform float pSSDOMax <
ui_label = "Max SSDO";
ui_tooltip = "A limiter to the maximum SSDO effect. Can help to prevent artifacts in very dark areas.";
ui_type = "slider";
ui_min = 0.01;
ui_max = 1.0;
ui_step = 0.01;
> = 1.0;
#line 61
uniform float pSSDOBounceMultiplier <
ui_label = "SSDO Indirect Bounce Color Multiplier";
ui_tooltip = "SSDO includes an indirect bounce of light which means that colors of objects may interact with each other. This value controls the effects' visibility.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.8;
#line 70
uniform float pSSDOBounceSaturation <
ui_label = "SSDO Indirect Bounce Color Saturation";
ui_tooltip = "High values may look strange.";
ui_type = "slider";
ui_min = 0.1;
ui_max = 2.0;
ui_step = 0.01;
> = 1.0;
#line 79
uniform int pSSDOSampleAmount <
ui_label = "SSDO Sample Count";
ui_tooltip = "The amount of samples taken to accumulate SSDO. Affects quality, reduces noise and almost linearly affects performance. Current high-end systems should max out at ~32 samples at Full HD to reach desirable framerates.";
ui_type = "slider";
ui_min = 1;
ui_max = 256;
ui_step = 1;
> = 10;
#line 88
uniform float pSSDOSampleRange <
ui_label = "SSDO Sample Range";
ui_tooltip = "Maximum distance for occluders to occlude geometry. High values reduce cache coherence, lead to cache misses and thus decrease performance so keep this below ~150.\nYou may prevent this performance drop by increasing Source LOD.";
ui_type = "slider";
ui_min = 4.0;
ui_max = 1000.0;
ui_step = 0.1;
> = 70.0;
#line 97
uniform int pSSDOSourceLOD <
ui_label = "SSDO Source LOD";
ui_tooltip = "The Mipmap-level of the source texture used to calculate the occlusion/indirect light. 0 = full resolution, 1 = half-axis resolution, 2 = quarter-axis resolution etc.\nCombined with high SampleRange-values, this may improve performance with a slight loss of quality.";
ui_type = "slider";
ui_min = 0;
ui_max = 3;
ui_step = 1;
> = 2;
#line 106
uniform int pSSDOBounceLOD <
ui_label = "SSDO Indirect Bounce LOD";
ui_tooltip = "The Mipmap-level of the color texture used to calculate the light bounces. 0 = full resolution, 1 = half-axis resolution, 2 = quarter-axis resolution etc.\nCombined with high SampleRange-values, this may improve performance with a slight loss of quality.";
ui_type = "slider";
ui_min = 0;
ui_max = 3;
ui_step = 1;
> = 3;
#line 115
uniform float pSSDOFilterRadius <
ui_label = "Filter Radius";
ui_tooltip = "The blur radius that is used to filter out the noise the technique produces. Don't push this too high, everything between 8 - 24 is recommended (depending from Sample Count, Sample Range, Intensity, Amount and Max SSDO).";
ui_type = "slider";
ui_min = 2.0;
ui_max = 100.0;
ui_step = 1.0;
> = 8.0;
#line 124
uniform float pSSDOAngleThreshold <
ui_label = "SSDO Angle Threshold";
ui_tooltip = "Defines the minimum angle for points to contribute when occlusion is computed. This is similar to the depth-bias parameter in other Ambient Occlusion Shaders.";
ui_type = "slider";
ui_min = 0.01;
ui_max = 0.5;
ui_step = 0.01;
> = 0.125;
#line 133
uniform float pSSDOFadeStart <
ui_label = "SSDO Draw Distance: Fade Start";
ui_tooltip = "The distance from which the effect starts decreasing. Use this slider combined with the Fade-End slider to create a smooth fade-out of the effect.";
ui_type = "slider";
ui_min = 0.1;
ui_max = 0.95;
ui_step = 0.01;
> = 0.9;
#line 142
uniform float pSSDOFadeEnd <
ui_label = "SSDO Draw Distance: Fade End";
ui_tooltip = "This value defines the distance from which the effect will be cut off. Use this slider combined with the Fade-Start slider to create a smooth fade-out of the effect.";
ui_type = "slider";
ui_min = 0.15;
ui_max = 1.0;
ui_step = 0.01;
> = 0.95;
#line 151
uniform int pSSDODebugMode <
ui_label = "SSDO Debug View";
ui_type = "combo";
ui_items = "Debug-mode off\0Outputs the filtered SSDO component\0Shows you the raw, noisy SSDO right after scattering the occlusion/lighting\0";
> = 0;
#line 162
texture texColorLOD { Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 4; };
texture texGameDepth : DEPTH;
#line 166
texture texViewSpace < pooled = true; >
{
Width = 1920;
Height = 1018;
Format = RGBA16F;
MipLevels = 4;
};
texture texSSDOA
{
Width = 1920*1.0;
Height = 1018*1.0;
Format = RGBA16;
};
texture texSSDOB
{
Width = 1920*1.0;
Height = 1018*1.0;
Format = RGBA16;
};
texture texSSDOC < pooled = true; >
{
Width = 1920*1.0;
Height = 1018*1.0;
Format = RGBA16;
};
#line 193
texture texSSDONoise < source = "ssdonoise.png"; >
{
Width = 4;
Height = 4;
Format = R8;
#line 199
};
#line 206
sampler SamplerColorLOD
{
Texture = texColorLOD;
SRGBTexture = true;
};
#line 212
sampler2D SamplerDepth
{
Texture = texGameDepth;
};
#line 218
sampler SamplerViewSpace
{
Texture = texViewSpace;
};
sampler SamplerSSDOA
{
Texture = texSSDOA;
};
sampler SamplerSSDOB
{
Texture = texSSDOB;
};
sampler SamplerSSDOC
{
Texture = texSSDOC;
};
#line 236
sampler SamplerSSDONoise
{
Texture = texSSDONoise;
MipFilter = POINT;
MinFilter = POINT;
MagFilter = POINT;
};
#line 248
static const float2 pxSize = float2((1.0 / 1920),(1.0 / 1018));
static const float3 lumaCoeff = float3(0.2126f,0.7152f,0.0722f);
#line 257
struct VS_OUTPUT_POST
{
float4 vpos : SV_Position;
float2 txcoord : TEXCOORD0;
};
#line 263
struct VS_INPUT_POST
{
uint id : SV_VertexID;
};
#line 272
float linearDepth(float2 txCoords)
{
return ReShade::GetLinearizedDepth(txCoords);
}
#line 277
float4 viewSpace(float2 txCoords)
{
const float2 offsetS = float2(0.0,1.0)*pxSize;
const float2 offsetE = float2(1.0,0.0)*pxSize;
const float depth = linearDepth(txCoords);
const float depthS = linearDepth(txCoords+offsetS);
const float depthE = linearDepth(txCoords+offsetE);
#line 285
const float3 vsNormal = cross(float3((-offsetS)*depth,depth-depthS),float3(offsetE*depth,depth-depthE));
return float4(normalize(vsNormal),depth);
}
#line 298
float4 FX_SSDOScatter( float2 txCoords )
{
const float	sourceAxisDiv = pow(2.0,pSSDOSourceLOD);
const float2	texelSize = pxSize.xy*pow(2.0,pSSDOSourceLOD).xx;
const float4	vsOrig = tex2D(SamplerViewSpace,txCoords);
float3	ssdo = 0.0;
#line 305
const float	randomDir = tex2Dlod(SamplerSSDONoise,float4(frac(txCoords*float2((1920*1.0)/4.0,(1018*1.0)/4.0)), 0.0, 0.0)).x;
const float2	stepSize = (pSSDOSampleRange/(pSSDOSampleAmount*sourceAxisDiv))*texelSize;
#line 308
for (float offs=1.0;offs<=pSSDOSampleAmount;offs++)
{
float2 fetchDir = normalize(frac(float2(randomDir*811.139795*offs,randomDir*297.719157*offs))*2.0-1.0);
fetchDir *= sign(dot(normalize(float3(fetchDir.x,-fetchDir.y,1.0)),vsOrig.xyz)); 
const float2 fetchCoords = txCoords+fetchDir*stepSize*offs*max(0.75,offs/pSSDOSampleAmount);
const float4 vsFetch = tex2Dlod(SamplerViewSpace,float4(fetchCoords,0,pSSDOSourceLOD));
#line 315
float3 albedoFetch = tex2Dlod(SamplerColorLOD,float4(fetchCoords,0,pSSDOBounceLOD)).xyz;
albedoFetch = pow(max(albedoFetch, 1e-5),pSSDOBounceSaturation);
albedoFetch = normalize(albedoFetch);
albedoFetch *= pSSDOBounceMultiplier;
albedoFetch = 1.0-albedoFetch;
#line 321
float3 dirVec = float3(fetchCoords.x-txCoords.x,txCoords.y-fetchCoords.y,vsOrig.w-vsFetch.w);
dirVec.xy *= vsOrig.w;
const float3 dirVecN = normalize(dirVec);
float visibility = step(pSSDOAngleThreshold,dot(dirVecN,vsOrig.xyz)); 
visibility *= sign(saturate(abs(length(vsOrig.xyz-vsFetch.xyz))-0.01)); 
float distFade = saturate((pSSDOSampleRange*(pxSize.y/1.0))-length(dirVec))/(pSSDOSampleRange*(pxSize.y/1.0)); 
ssdo += albedoFetch * visibility * distFade * distFade * pSSDOAmount;
}
ssdo = min(pSSDOMax,ssdo/pSSDOSampleAmount);
#line 331
return float4(saturate(1.0-ssdo*smoothstep(pSSDOFadeEnd,pSSDOFadeStart,vsOrig.w)),vsOrig.w);
}
#line 335
float4 FX_BlurBilatH( float2 txCoords, float radius )
{
const float	texelSize = pxSize.x/1.0;
float4	pxInput = tex2D(SamplerSSDOB,txCoords);
pxInput.xyz *= 0.5;
float	sampleSum = 0.5;
#line 342
[loop]
for (float hOffs=1.5; hOffs<radius; hOffs+=2.0)
{
const float weight = 1.0;
float2 fetchCoords = txCoords;
fetchCoords.x += texelSize * hOffs;
float4 fetch = tex2Dlod(SamplerSSDOB, float4(fetchCoords, 0.0, 0.0));
float contribFact = saturate(sign((pSSDOSampleRange*(pxSize.y/1.0))*0.1-abs(pxInput.w-fetch.w))) * weight;
pxInput.xyz+=fetch.xyz * contribFact;
sampleSum += contribFact;
fetchCoords = txCoords;
fetchCoords.x -= texelSize * hOffs;
fetch = tex2Dlod(SamplerSSDOB, float4(fetchCoords, 0.0, 0.0));
contribFact = saturate(sign((pSSDOSampleRange*(pxSize.y/1.0))*0.1-abs(pxInput.w-fetch.w))) * weight;
pxInput.xyz+=fetch.xyz * contribFact;
sampleSum += contribFact;
}
pxInput.xyz /= sampleSum;
#line 361
return pxInput;
}
#line 365
float3 FX_BlurBilatV( float2 txCoords, float radius )
{
const float	texelSize = pxSize.y/1.0;
float4	pxInput = tex2D(SamplerSSDOC,txCoords);
pxInput.xyz *= 0.5;
float	sampleSum = 0.5;
#line 372
[loop]
for (float vOffs=1.5; vOffs<radius; vOffs+=2.0)
{
const float weight = 1.0;
float2 fetchCoords = txCoords;
fetchCoords.y += texelSize * vOffs;
float4 fetch = tex2Dlod(SamplerSSDOC, float4(fetchCoords, 0.0, 0.0));
float contribFact = saturate(sign((pSSDOSampleRange*(pxSize.y/1.0))*0.1-abs(pxInput.w-fetch.w))) * weight;
pxInput.xyz+=fetch.xyz * contribFact;
sampleSum += contribFact;
fetchCoords = txCoords;
fetchCoords.y -= texelSize * vOffs;
fetch = tex2Dlod(SamplerSSDOC, float4(fetchCoords, 0.0, 0.0));
contribFact = saturate(sign((pSSDOSampleRange*(pxSize.y/1.0))*0.1-abs(pxInput.w-fetch.w))) * weight;
pxInput.xyz+=fetch.xyz * contribFact;
sampleSum += contribFact;
}
pxInput /= sampleSum;
#line 391
return pxInput.xyz;
}
#line 398
VS_OUTPUT_POST VS_PostProcess(VS_INPUT_POST IN)
{
VS_OUTPUT_POST OUT;
#line 402
if (IN.id == 2)
OUT.txcoord.x = 2.0;
else
OUT.txcoord.x = 0.0;
#line 407
if (IN.id == 1)
OUT.txcoord.y = 2.0;
else
OUT.txcoord.y = 0.0;
#line 412
OUT.vpos = float4(OUT.txcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
return OUT;
}
#line 421
float4 PS_SetOriginal(VS_OUTPUT_POST IN) : COLOR
{
return tex2D(ReShade::BackBuffer,IN.txcoord.xy);
}
#line 427
float4 PS_SSDOViewSpace(VS_OUTPUT_POST IN) : COLOR
{
return viewSpace(IN.txcoord.xy);
}
#line 432
float4 PS_SSDOScatter(VS_OUTPUT_POST IN) : COLOR
{
return FX_SSDOScatter(IN.txcoord.xy);
}
#line 437
float4 PS_SSDOBlurScale(VS_OUTPUT_POST IN) : COLOR
{
return tex2D(SamplerSSDOA,IN.txcoord.xy);
}
#line 442
float4 PS_SSDOBlurH(VS_OUTPUT_POST IN) : COLOR
{
return FX_BlurBilatH(IN.txcoord.xy,pSSDOFilterRadius/1.0);
}
#line 447
float4 PS_SSDOBlurV(VS_OUTPUT_POST IN) : COLOR
{
return float4(FX_BlurBilatV(IN.txcoord.xy,pSSDOFilterRadius/1.0).xyz,1.0);
}
#line 452
float4 PS_SSDOMix(VS_OUTPUT_POST IN) : COLOR
{
float3 ssdo = pow(abs(tex2D(SamplerSSDOB,IN.txcoord.xy).xyz),pSSDOIntensity.xxx);
#line 456
if (pSSDODebugMode == 1)
return float4(pow(ssdo,2.2),1.0);
else if (pSSDODebugMode == 2)
return float4(pow(abs(tex2D(SamplerSSDOA,IN.txcoord.xy).xyz),2.2),1.0);
else
return float4(ssdo * tex2D(SamplerColorLOD, IN.txcoord.xy).xyz, 1.0);
}
#line 468
technique PPFXSSDO < ui_label = "PPFX SSDO"; ui_tooltip = "Screen Space Directional Occlusion | Ambient Occlusion simulates diffuse shadows/self-shadowing of geometry.\nIndirect Lighting brightens objects that are exposed to a certain 'light source' you may specify in the parameters below.\nThis approach takes directional information into account and simulates indirect light bounces, approximating global illumination."; >
{
pass setOriginal
{
VertexShader = VS_PostProcess;
PixelShader = PS_SetOriginal;
RenderTarget0 = texColorLOD;
#line 476
}
#line 478
pass ssdoViewSpace
{
VertexShader = VS_PostProcess;
PixelShader = PS_SSDOViewSpace;
RenderTarget0 = texViewSpace;
}
#line 485
pass ssdoScatter
{
VertexShader = VS_PostProcess;
PixelShader = PS_SSDOScatter;
RenderTarget0 = texSSDOA;
}
#line 492
pass ssdoBlurScale
{
VertexShader = VS_PostProcess;
PixelShader = PS_SSDOBlurScale;
RenderTarget0 = texSSDOB;
}
#line 499
pass ssdoBlurH
{
VertexShader = VS_PostProcess;
PixelShader = PS_SSDOBlurH;
RenderTarget0 = texSSDOC;
}
#line 506
pass ssdoBlurV
{
VertexShader = VS_PostProcess;
PixelShader = PS_SSDOBlurV;
RenderTarget0 = texSSDOB;
}
#line 513
pass ssdoMix
{
VertexShader = VS_PostProcess;
PixelShader = PS_SSDOMix;
SRGBWriteEnable = true;
}
}

