#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\SSAO.fx"
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
#line 24 "C:\Program Files\GShade\gshade-shaders\Shaders\SSAO.fx"
#line 38
uniform float AO_TEXSCALE <
ui_label = "Scale";
ui_category = "Global Parameters";
ui_tooltip = "Scale of AO resolution, 1.0 means fullscreen. Lower resolution means less pixels to process and more performance but also less quality.";
ui_type = "slider";
ui_min = 0.25;
ui_max = 1.0;
ui_step = 0.01;
> = 1.0;
#line 48
uniform float AO_SHARPNESS <
ui_label = "Sharpness";
ui_category = "Global Parameters";
ui_type = "slider";
ui_min = 0.05;
ui_max = 2.0;
ui_step = 0.01;
> = 0.70;
#line 57
uniform bool AO_SHARPNESS_DETECT <
ui_label = "Sharpness Detection";
ui_category = "Global Parameters";
ui_tooltip = "AO must not blur over object edges. Off : edge detection by depth (old) On : edge detection by normal (new). 2 is better but produces some black outlines.";
> = 1;
#line 63
uniform int AO_BLUR_STEPS <
ui_label = "Blur Steps";
ui_category = "Global Parameters";
ui_tooltip = "Offset count for AO smoothening. Higher means more smooth AO but also blurrier AO.";
ui_type = "slider";
ui_min = 5;
ui_max = 15;
ui_step = 1;
> = 11;
#line 73
uniform int AO_DEBUG <
ui_label = "Debug";
ui_type = "combo";
ui_items = "Debug Off\0Ambient Occlusion Debug\0Global Illumination Debug\0";
ui_category = "Global Parameters";
ui_tooltip = "AO must not blur over object edges. Off : edge detection by depth (old) On : edge detection by normal (new). 2 is better but produces some black outlines.";
> = 0;
#line 81
uniform bool AO_LUMINANCE_CONSIDERATION <
ui_label = "Luminance Consideration";
ui_category = "Global Parameters";
> = 1;
#line 86
uniform float AO_LUMINANCE_LOWER <
ui_label = "Luminance Lower";
ui_category = "Global Parameters";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.3;
#line 95
uniform float AO_LUMINANCE_UPPER <
ui_label = "Luminance Upper";
ui_category = "Global Parameters";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.6;
#line 104
uniform float AO_FADE_START <
ui_label = "Fade Start";
ui_category = "Global Parameters";
ui_tooltip = "Distance from camera where AO starts to fade out. 0.0 means camera itself, 1.0 means infinite distance.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.4;
#line 114
uniform float AO_FADE_END <
ui_label = "Fade End";
ui_category = "Global Parameters";
ui_tooltip = "Distance from camera where AO fades out completely. 0.0 means camera itself, 1.0 means infinite distance.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.6;
#line 124
uniform int iSSAOSamples <
ui_label = "SSAO Samples";
ui_category = "SSAO Settings";
ui_tooltip = "Amount of samples. Don't set too high or shader compilation time goes through the roof.";
ui_type = "slider";
ui_min = 16;
ui_max = 128;
ui_step = 8;
> = 16;
#line 134
uniform bool iSSAOSmartSampling <
ui_label = "SSAO Smart Sampling";
ui_category = "SSAO Settings";
> = 0;
#line 139
uniform float fSSAOSamplingRange <
ui_label = "SSAO Sampling Range";
ui_category = "SSAO Settings";
ui_tooltip = "SSAO sampling range. High range values might need more samples so raise both.";
ui_type = "slider";
ui_min = 10.0;
ui_max = 50.0;
ui_step = 0.1;
> = 50.0;
#line 149
uniform float fSSAODarkeningAmount <
ui_label = "SSAO Darkening Amount";
ui_category = "SSAO Settings";
ui_tooltip = "Amount of SSAO corner darkening.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 5.0;
ui_step = 0.001;
> = 1.5;
#line 159
uniform float fSSAOBrighteningAmount <
ui_label = "SSAO Brightening Amount";
ui_category = "SSAO Settings";
ui_tooltip = "Amount of SSAO edge brightening.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 5.0;
ui_step = 0.001;
> = 1.0;
#line 169
uniform int iRayAOSamples <
ui_label = "RayAO Samples";
ui_category = "Raymarch AO Settings";
ui_tooltip = "Amount of sample \"rays\" Higher means more accurate AO but also less performance.";
ui_type = "slider";
ui_min = 10;
ui_max = 78;
ui_step = 1;
> = 24;
#line 179
uniform float fRayAOSamplingRange <
ui_label = "RayAO Sampling Range";
ui_category = "Raymarch AO Settings";
ui_tooltip = "Range of AO sampling. Higher values ignore small geometry details and shadow more globally.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 0.025;
ui_step = 0.001;
> = 0.001;
#line 189
uniform float fRayAOMaxDepth <
ui_label = "RayAO Max Depth";
ui_category = "Raymarch AO Settings";
ui_tooltip = "Factor to avoid far objects to occlude close objects just because they are besides each other on screen.";
ui_type = "slider";
ui_min = 0.01;
ui_max = 0.02;
ui_step = 0.001;
> = 0.02;
#line 199
uniform float fRayAOMinDepth  <
ui_label = "RayAO Min Depth";
ui_category = "Raymarch AO Settings";
ui_tooltip = "Minimum depth difference cutoff to prevent (almost) flat surfaces to occlude themselves.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 0.02;
ui_step = 0.001;
> = 0.001;
#line 209
uniform float fRayAOPower  <
ui_label = "RayAO Power";
ui_category = "Raymarch AO Settings";
ui_tooltip = "Amount of darkening.";
ui_type = "slider";
ui_min = 0.2;
ui_max = 5.0;
ui_step = 0.001;
> = 2.0;
#line 219
uniform int iHBAOSamples <
ui_label = "HBAO Samples";
ui_category = "HBAO Settings";
ui_tooltip = "Amount of samples. Higher means more accurate AO but also less performance.";
ui_type = "slider";
ui_min = 7;
ui_max = 36;
ui_step = 1;
> = 9;
#line 229
uniform float fHBAOSamplingRange  <
ui_label = "HBAO Sampling Range";
ui_category = "HBAO Settings";
ui_tooltip = "Range of HBAO sampling. Higher values ignore small geometry details and shadow more globally.";
ui_type = "slider";
ui_min = 0.5;
ui_max = 5.0;
ui_step = 0.001;
> = 2.6;
#line 239
uniform float fHBAOAmount  <
ui_label = "HBAO Amount";
ui_category = "HBAO Settings";
ui_tooltip = "Amount of HBAO shadowing.";
ui_type = "slider";
ui_min = 1.0;
ui_max = 10.0;
ui_step = 0.001;
> = 3.0;
#line 249
uniform float fHBAOClamp  <
ui_label = "HBAO Clamp";
ui_category = "HBAO Settings";
ui_tooltip = "Clamps HBAO power. 0.0 means full power, 1.0 means no HBAO.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.1;
#line 259
uniform float fHBAOAttenuation  <
ui_label = "HBAO Attenuation";
ui_category = "HBAO Settings";
ui_tooltip = "Affects the HBAO range, prevents shadowing of very far objects which are close in screen space.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 0.2;
ui_step = 0.001;
> = 0.02;
#line 269
uniform int iSSGISamples <
ui_label = "SSGI Samples";
ui_category = "SSGI Settings";
ui_tooltip = "Amount of SSGI sampling iterations, higher means better GI but less performance.";
ui_type = "slider";
ui_min = 5;
ui_max = 24;
ui_step = 1;
> = 9;
#line 279
uniform float fSSGISamplingRange <
ui_label = "SSGI Sampling Range";
ui_category = "SSGI Settings";
ui_tooltip = "Radius of SSGI sampling.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 80.0;
ui_step = 0.001;
> = 0.4;
#line 289
uniform float fSSGIIlluminationMult <
ui_label = "SSGI Illumination Multiplier";
ui_category = "SSGI Settings";
ui_tooltip = "Multiplier of SSGI illumination (color bouncing/reflection).";
ui_type = "slider";
ui_min = 1.0;
ui_max = 8.0;
ui_step = 0.001;
> = 4.5;
#line 299
uniform float fSSGIOcclusionMult <
ui_label = "SSGI Occlusion Multiplier";
ui_category = "SSGI Settings";
ui_tooltip = "Multiplier of SSGI occlusion.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.001;
> = 0.8;
#line 309
uniform float fSSGIModelThickness <
ui_label = "SSGI Model Thickness";
ui_category = "SSGI Settings";
ui_tooltip = "Amount of unit spaces the algorithm assumes the model's thickness. Lower if scene only contains small objects.";
ui_type = "slider";
ui_min = 0.5;
ui_max = 100.0;
ui_step = 0.001;
> = 10.0;
#line 319
uniform float fSSGISaturation <
ui_label = "SSGI Saturation";
ui_category = "SSGI Settings";
ui_tooltip = "Saturation of bounced/reflected colors.";
ui_type = "slider";
ui_min = 0.2;
ui_max = 2.0;
ui_step = 0.001;
> = 1.8;
#line 329
uniform float iSAOSamples <
ui_label = "SAO Samples";
ui_category = "SAO Settings";
ui_tooltip = "Amount of SAO Samples. Maximum of 96 is defined by formula.";
ui_type = "slider";
ui_min = 10.0;
ui_max = 96.0;
ui_step = 1.0;
> = 18.0;
#line 339
uniform float fSAOIntensity <
ui_label = "SAO Intensity";
ui_category = "SAO Settings";
ui_tooltip = "Linearly multiplies AO intensity.";
ui_type = "slider";
ui_min = 1.0;
ui_max = 10.0;
ui_step = 0.001;
> = 6.0;
#line 349
uniform float fSAOClamp <
ui_label = "SAO Clamp";
ui_category = "SAO Settings";
ui_tooltip = "Higher values shift AO more into black. Useful for light gray AO caused by high SAO radius.";
ui_type = "slider";
ui_min = 1.0;
ui_max = 10.0;
ui_step = 0.001;
> = 2.5;
#line 359
uniform float fSAORadius <
ui_label = "SAO Radius";
ui_category = "SAO Settings";
ui_tooltip = "SAO sampling radius. Higher values also lower AO intensity extremely because of Alchemy's extremely terrible falloff formula.";
ui_type = "slider";
ui_min = 1.0;
ui_max = 10.0;
ui_step = 0.001;
> = 2.3;
#line 369
uniform float fSAOBias <
ui_label = "SAO Bias";
ui_category = "SAO Settings";
ui_tooltip = "Minimal surface angle for AO consideration. Useful to prevent self-occlusion of flat surfaces caused by floating point inaccuracies.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 0.5;
ui_step = 0.001;
> = 0.2;
#line 382
texture2D texSSAONoise < source = "mcnoise.png"; > {Width = 1920;Height = 1018;Format = RGBA8;};
#line 384
texture texOcclusion1 { Width = 1920; Height = 1018;  Format = RGBA16F;};
texture texOcclusion2 { Width = 1920; Height = 1018;  Format = RGBA16F;};
#line 387
texture2D texHDR3 	{ Width = 1920; Height = 1018; Format = RGBA8;};
#line 390
sampler2D SamplerSSAONoise
{
Texture = texSSAONoise;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;
AddressU = Wrap;
AddressV = Wrap;
};
#line 400
sampler2D SamplerOcclusion1
{
Texture = texOcclusion1;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;
AddressU = Clamp;
AddressV = Clamp;
};
#line 410
sampler2D SamplerOcclusion2
{
Texture = texOcclusion2;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;
AddressU = Clamp;
AddressV = Clamp;
};
#line 420
sampler2D SamplerHDR3
{
Texture = texHDR3;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;
AddressU = Clamp;
AddressV = Clamp;
};
#line 433
float3 GetNormalFromDepth(float fDepth, float2 vTexcoord) {
#line 435
const float2 offset1 = float2(0.0,0.001);
const float2 offset2 = float2(0.001,0.0);
#line 438
const float depth1 = ReShade::GetLinearizedDepth(vTexcoord + offset1).x;
const float depth2 = ReShade::GetLinearizedDepth(vTexcoord + offset2).x;
#line 441
const float3 p1 = float3(offset1, depth1 - fDepth);
const float3 p2 = float3(offset2, depth2 - fDepth);
#line 444
float3 normal = cross(p1, p2);
normal.z = -normal.z;
#line 447
return normalize(normal);
}
#line 450
float GetRandom(float2 co){
return frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
}
#line 454
float3 GetRandomVector(float2 vTexCoord) {
return 2 * normalize(float3(GetRandom(vTexCoord - 0.5f),
GetRandom(vTexCoord + 0.5f),
GetRandom(vTexCoord))) - 1;
}
#line 463
void PS_AO_SSAO(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 Occlusion1R : SV_Target0)
{
texcoord.xy /= AO_TEXSCALE;
if(texcoord.x > 1.0 || texcoord.y > 1.0) discard;
#line 469
const float fSceneDepthP 	= ReShade::GetLinearizedDepth(texcoord.xy).x;
#line 471
float blurkey;
if( AO_SHARPNESS_DETECT == 0)
blurkey = fSceneDepthP;
else
blurkey = dot(GetNormalFromDepth(fSceneDepthP, texcoord.xy).xyz,0.333)*0.1;
#line 477
if(fSceneDepthP > min(0.9999,AO_FADE_END)) Occlusion1R = float4(0.5,0.5,0.5,blurkey);
else {
float offsetScale = fSSAOSamplingRange/10000;
const float fSSAODepthClip = 10000000.0;
#line 482
const float3 vRotation = tex2Dlod(SamplerSSAONoise, float4(texcoord.xy, 0, 0)).rgb - 0.5f;
#line 484
float3x3 matRotate;
#line 486
const float hao = 1.0f / (1.0f + vRotation.z);
#line 488
matRotate._m00 =  hao * vRotation.y * vRotation.y + vRotation.z;
matRotate._m01 = -hao * vRotation.y * vRotation.x;
matRotate._m02 = -vRotation.x;
matRotate._m10 = -hao * vRotation.y * vRotation.x;
matRotate._m11 =  hao * vRotation.x * vRotation.x + vRotation.z;
matRotate._m12 = -vRotation.y;
matRotate._m20 =  vRotation.x;
matRotate._m21 =  vRotation.y;
matRotate._m22 =  vRotation.z;
#line 498
float fOffsetScaleStep = 1.0f + 2.4f / iSSAOSamples;
float fAccessibility = 0;
#line 501
float Sample_Scaled = iSSAOSamples;
#line 503
if(iSSAOSmartSampling == 1)
{
if(fSceneDepthP > 0.5) Sample_Scaled=max(8,round(Sample_Scaled*0.5));
if(fSceneDepthP > 0.8) Sample_Scaled=max(8,round(Sample_Scaled*0.5));
}
#line 509
const float fAtten = 5000.0/fSSAOSamplingRange/(1.0+fSceneDepthP*10.0);
#line 511
[loop]
for (int i = 0 ; i < (Sample_Scaled / 8) ; i++)
for (int x = -1 ; x <= 1 ; x += 2)
for (int y = -1 ; y <= 1 ; y += 2)
for (int z = -1 ; z <= 1 ; z += 2) {
#line 517
const float3 vOffset = normalize(float3(x, y, z)) * (offsetScale *= fOffsetScaleStep);
#line 519
const float3 vRotatedOffset = mul(vOffset, matRotate);
#line 522
float3 vSamplePos = float3(texcoord.xy, fSceneDepthP);
#line 525
vSamplePos += float3(vRotatedOffset.xy, vRotatedOffset.z * fSceneDepthP);
#line 528
float fSceneDepthS = ReShade::GetLinearizedDepth(vSamplePos.xy).x;
#line 531
if (fSceneDepthS >= fSSAODepthClip)
fAccessibility += 1.0f;
else {
#line 535
const float fDepthDist = abs(fSceneDepthP - fSceneDepthS);
const float fRangeIsInvalid = saturate(fDepthDist*fAtten);
fAccessibility += lerp(fSceneDepthS > vSamplePos.z, 0.5f, fRangeIsInvalid);
}
}
#line 542
fAccessibility = fAccessibility / Sample_Scaled;
#line 544
Occlusion1R = float4(fAccessibility.xxx,blurkey);
}
}
#line 548
void PS_AO_RayAO(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 Occlusion1R : SV_Target0)
{
texcoord.xy /= AO_TEXSCALE;
if(texcoord.x > 1.0 || texcoord.y > 1.0) discard;
#line 553
const float3	avOffsets [78] =
{
float3(0.2196607,0.9032637,0.2254677),
float3(0.05916681,0.2201506,-0.1430302),
float3(-0.4152246,0.1320857,0.7036734),
float3(-0.3790807,0.1454145,0.100605),
float3(0.3149606,-0.1294581,0.7044517),
float3(-0.1108412,0.2162839,0.1336278),
float3(0.658012,-0.4395972,-0.2919373),
float3(0.5377914,0.3112189,0.426864),
float3(-0.2752537,0.07625949,-0.1273409),
float3(-0.1915639,-0.4973421,-0.3129629),
float3(-0.2634767,0.5277923,-0.1107446),
float3(0.8242752,0.02434147,0.06049098),
float3(0.06262707,-0.2128643,-0.03671562),
float3(-0.1795662,-0.3543862,0.07924347),
float3(0.06039629,0.24629,0.4501176),
float3(-0.7786345,-0.3814852,-0.2391262),
float3(0.2792919,0.2487278,-0.05185341),
float3(0.1841383,0.1696993,-0.8936281),
float3(-0.3479781,0.4725766,-0.719685),
float3(-0.1365018,-0.2513416,0.470937),
float3(0.1280388,-0.563242,0.3419276),
float3(-0.4800232,-0.1899473,0.2398808),
float3(0.6389147,0.1191014,-0.5271206),
float3(0.1932822,-0.3692099,-0.6060588),
float3(-0.3465451,-0.1654651,-0.6746758),
float3(0.2448421,-0.1610962,0.13289366),
float3(0.2448421,0.9032637,0.24254677),
float3(0.2196607,0.2201506,-0.18430302),
float3(0.05916681,0.1320857,0.70036734),
float3(-0.4152246,0.1454145,0.1800605),
float3(-0.3790807,-0.1294581,0.78044517),
float3(0.3149606,0.2162839,0.17336278),
float3(-0.1108412,-0.4395972,-0.269619373),
float3(0.658012,0.3112189,0.4267864),
float3(0.5377914,0.07625949,-0.12773409),
float3(-0.2752537,-0.4973421,-0.31629629),
float3(-0.1915639,0.5277923,-0.17107446),
float3(-0.2634767,0.02434147,0.086049098),
float3(0.8242752,-0.2128643,-0.083671562),
float3(0.06262707,-0.3543862,0.007924347),
float3(-0.1795662,0.24629,0.44501176),
float3(0.06039629,-0.3814852,-0.248391262),
float3(-0.7786345,0.2487278,-0.065185341),
float3(0.2792919,0.1696993,-0.84936281),
float3(0.1841383,0.4725766,-0.7419685),
float3(-0.3479781,-0.2513416,0.670937),
float3(-0.1365018,-0.563242,0.36419276),
float3(0.1280388,-0.1899473,0.23948808),
float3(-0.4800232,0.1191014,-0.5271206),
float3(0.6389147,-0.3692099,-0.5060588),
float3(0.1932822,-0.1654651,-0.62746758),
float3(-0.3465451,-0.1610962,0.4289366),
float3(0.2448421,-0.1610962,0.2254677),
float3(0.2196607,0.9032637,-0.1430302),
float3(0.05916681,0.2201506,0.7036734),
float3(-0.4152246,0.1320857,0.100605),
float3(-0.3790807,0.3454145,0.7044517),
float3(0.3149606,-0.4294581,0.1336278),
float3(-0.1108412,0.3162839,-0.2919373),
float3(0.658012,-0.2395972,0.426864),
float3(0.5377914,0.33112189,-0.1273409),
float3(-0.2752537,0.47625949,-0.3129629),
float3(-0.1915639,-0.3973421,-0.1107446),
float3(-0.2634767,0.2277923,0.06049098),
float3(0.8242752,-0.3434147,-0.03671562),
float3(0.06262707,-0.4128643,0.07924347),
float3(-0.1795662,-0.3543862,0.4501176),
float3(0.06039629,0.24629,-0.2391262),
float3(-0.7786345,-0.3814852,-0.05185341),
float3(0.2792919,0.4487278,-0.8936281),
float3(0.1841383,0.3696993,-0.719685),
float3(-0.3479781,0.2725766,0.470937),
float3(-0.1365018,-0.5513416,0.3419276),
float3(0.1280388,-0.163242,0.2398808),
float3(-0.4800232,-0.3899473,-0.5271206),
float3(0.6389147,0.3191014,-0.6060588),
float3(0.1932822,-0.1692099,-0.6746758),
float3(-0.3465451,-0.2654651,0.1289366)
};
#line 635
float2 vOutSum;
float3 vRandom, vReflRay, vViewNormal;
float fCurrDepth, fSampleDepth, fDepthDelta, fAO;
fCurrDepth  = ReShade::GetLinearizedDepth(texcoord.xy).x;
#line 640
float blurkey;
if( AO_SHARPNESS_DETECT == 0)
blurkey = fCurrDepth;
else
blurkey = dot(GetNormalFromDepth(fCurrDepth, texcoord.xy).xyz,0.333)*0.1;
#line 646
if(fCurrDepth>min(0.9999,AO_FADE_END)) Occlusion1R = float4(1.0,1.0,1.0,blurkey);
else {
vViewNormal = GetNormalFromDepth(fCurrDepth, texcoord.xy);
vRandom 	= GetRandomVector(texcoord);
fAO = 0;
for(int s = 0; s < iRayAOSamples; s++) {
vReflRay = reflect(avOffsets[s], vRandom);
#line 654
float fFlip = sign(dot(vViewNormal,vReflRay));
vReflRay   *= fFlip;
#line 657
const float sD = fCurrDepth - (vReflRay.z * fRayAOSamplingRange);
fSampleDepth = ReShade::GetLinearizedDepth(saturate(texcoord + (fRayAOSamplingRange * vReflRay.xy / fCurrDepth))).x;
fDepthDelta = saturate(sD - fSampleDepth);
#line 661
fDepthDelta *= 1-smoothstep(0,fRayAOMaxDepth,fDepthDelta);
#line 663
if ( fDepthDelta > fRayAOMinDepth && fDepthDelta < fRayAOMaxDepth)
fAO += pow(1 - fDepthDelta, 2.5);
}
vOutSum.x = saturate(1 - (fAO / (float)iRayAOSamples) + fRayAOSamplingRange);
Occlusion1R = float4(vOutSum.xxx,blurkey);
}
}
#line 672
float3 GetEyePosition(in float2 uv, in float eye_z) {
uv = (uv * float2(2.0, -2.0) - float2(1.0, -1.0));
const float3 pos = float3(uv * float2(tan(0.5f*radians(75)) / (float)(1.0 / 1018) * (float)(1.0 / 1920), tan(0.5f*radians(75))) * eye_z, eye_z);
return pos;
}
#line 678
float2 GetRandom2_10(in float2 uv) {
const float noiseX = (frac(sin(dot(uv, float2(12.9898,78.233) * 2.0)) * 43758.5453));
const float noiseY = sqrt(1 - noiseX * noiseX);
return float2(noiseX, noiseY);
}
#line 684
void PS_AO_HBAO(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 Occlusion1R : SV_Target0)
{
texcoord.xy /= AO_TEXSCALE;
if(texcoord.x > 1.0 || texcoord.y > 1.0) discard;
#line 689
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
#line 691
float blurkey;
if( AO_SHARPNESS_DETECT == 0)
blurkey = depth;
else
blurkey = dot(GetNormalFromDepth(depth, texcoord.xy).xyz,0.333)*0.1;
#line 697
if(depth > min(0.9999,AO_FADE_END)) Occlusion1R = float4(1.0,1.0,1.0,blurkey);
else {
const float2 sample_offset[8] =
{
float2(1, 0),
float2(0.7071f, 0.7071f),
float2(0, 1),
float2(-0.7071f, 0.7071f),
float2(-1, 0),
float2(-0.7071f, -0.7071f),
float2(0, -1),
float2(0.7071f, -0.7071f)
};
#line 711
const float3 pos = GetEyePosition(texcoord.xy, depth);
const float3 dx = ddx(pos);
const float3 dy = ddy(pos);
const float3 norm = normalize(cross(dx,dy));
#line 716
float sample_depth=0;
float3 sample_pos=0;
#line 719
float ao=0;
float s=0.0;
#line 722
const float2 rand_vec = GetRandom2_10(texcoord.xy);
const float2 sample_vec_divisor = float2(tan(0.5f*radians(75)) / (float)(1.0 / 1018) * (float)(1.0 / 1920), tan(0.5f*radians(75)))*depth/(fHBAOSamplingRange*float2((1.0 / 1920), (1.0 / 1018)));
const float2 sample_center = texcoord.xy;
#line 726
for (int i = 0; i < 8; i++)
{
float theta,temp_theta,temp_ao,curr_ao = 0;
float3 occlusion_vector = 0.0;
#line 731
float2 sample_vec = reflect(sample_offset[i], rand_vec);
sample_vec /= sample_vec_divisor;
const float2 sample_coords = (sample_vec*float2(1,(float)1920/(float)1018))/iHBAOSamples;
#line 735
for (int k = 1; k <= iHBAOSamples; k++)
{
sample_depth = ReShade::GetLinearizedDepth(sample_center + sample_coords*(k-0.5*(float(i)%2))).x;
sample_pos = GetEyePosition(sample_center + sample_coords*(k-0.5*(float(i)%2)), sample_depth);
occlusion_vector = sample_pos - pos;
temp_theta = dot( norm, normalize(occlusion_vector) );
#line 742
if (temp_theta > theta)
{
theta = temp_theta;
temp_ao = 1-sqrt(1 - theta*theta );
ao += (1/ (1 + fHBAOAttenuation * pow(length(occlusion_vector)/fHBAOSamplingRange*5000,2)) )*(temp_ao-curr_ao);
curr_ao = temp_ao;
}
}
s += 1;
}
#line 753
ao /= max(0.00001,s);
ao = 1.0-ao*fHBAOAmount;
ao = clamp(ao,fHBAOClamp,1);
#line 757
Occlusion1R = float4(ao.xxx, blurkey);
}
#line 760
}
#line 762
float3 GetSAO_CSPosition(float2 S, float z)
{
#line 767
const float nearZ = 0.1; float farZ = 100.0; float vFOV = 68.0;
const float4x4 matProjection = float4x4(
1.0f / (((1.0 / 1018)/(1.0 / 1920)) * tan(vFOV / 2.0f)),  0.0f,                     0.0f,                   0.0f,
0.0f,                                1.0f / tan(vFOV / 2.0f),  0.0f,                   0.0f,
0.0f,                                0.0f,                     farZ / (farZ - nearZ),         1.0f,
0.0f,                                0.0f,                     (farZ * nearZ) / (nearZ - farZ),  0.0f
);
#line 775
float4 projInfo;
projInfo.x = -2.0f / ((float)1920 * matProjection._11);
projInfo.y = -2.0f / ((float)1018 * matProjection._22),
projInfo.z = ((1.0f - matProjection._13) / matProjection._11) + projInfo.x * 0.5f;
projInfo.w = ((1.0f + matProjection._23) / matProjection._22) + projInfo.y * 0.5f;
return float3(( (S.xy * float2(1920,1018)) * projInfo.xy + projInfo.zw) * z, z);
}
#line 783
float2 GetSAO_TapLocation(int sampleNumber, float spinAngle, out float ssR)
{
#line 786
const uint ROTATIONS [98] = { 1, 1, 2, 3, 2, 5, 2, 3, 2,
3, 3, 5, 5, 3, 4, 7, 5, 5, 7,
9, 8, 5, 5, 7, 7, 7, 8, 5, 8,
11, 12, 7, 10, 13, 8, 11, 8, 7, 14,
11, 11, 13, 12, 13, 19, 17, 13, 11, 18,
19, 11, 11, 14, 17, 21, 15, 16, 17, 18,
13, 17, 11, 17, 19, 18, 25, 18, 19, 19,
29, 21, 19, 27, 31, 29, 21, 18, 17, 29,
31, 31, 23, 18, 25, 26, 25, 23, 19, 34,
19, 27, 21, 25, 39, 29, 17, 21, 27 };
#line 797
const int SAOSamples = iSAOSamples;
const uint NUM_SPIRAL_TURNS = ROTATIONS[SAOSamples-1];
#line 801
const float alpha = float(sampleNumber + 0.5) * (1.0 / iSAOSamples);
const float angle = alpha * (NUM_SPIRAL_TURNS * 6.28) + spinAngle;
#line 804
ssR = alpha;
float sin_v, cos_v;
sincos(angle, sin_v, cos_v);
return float2(cos_v, sin_v);
}
#line 810
float GetSAO_CurveDepth(float depth)
{
return 202.0 / (-99.0 * depth + 101.0);
}
#line 815
float3 GetSAO_Position(float2 ssPosition)
{
float3 Position;
Position.z = GetSAO_CurveDepth(ReShade::GetLinearizedDepth(ssPosition.xy).x);
Position = GetSAO_CSPosition(ssPosition, Position.z);
return Position;
}
#line 823
float3 GetSAO_OffsetPosition(float2 ssC, float2 unitOffset, float ssR)
{
const float2 ssP = ssR*unitOffset + ssC;
float3 P;
P.z = GetSAO_CurveDepth(ReShade::GetLinearizedDepth(ssP.xy).x);
P = GetSAO_CSPosition(ssP, P.z);
return P;
}
#line 832
float GetSAO_SampleAO(in float2 ssC, in float3 C, in float3 n_C, in float ssDiskRadius, in int tapIndex, in float randomPatternRotationAngle)
{
float ssR;
const float2 unitOffset = GetSAO_TapLocation(tapIndex, randomPatternRotationAngle, ssR);
ssR *= ssDiskRadius;
const float3 Q = GetSAO_OffsetPosition(ssC, unitOffset, ssR);
const float3 v = Q - C;
#line 840
const float vv = dot(v, v);
const float vn = dot(v, n_C);
#line 843
const float f = max(1.0 - vv * (1.0 / fSAORadius), 0.0);
return f * max((vn - fSAOBias) * rsqrt( vv), 0.0);
}
#line 847
void PS_AO_SAO(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 Occlusion1R : SV_Target0)
{
texcoord.xy /= AO_TEXSCALE;
if(texcoord.x > 1.0 || texcoord.y > 1.0) discard;
#line 852
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
#line 854
float blurkey;
if( AO_SHARPNESS_DETECT == 0)
blurkey = depth;
else
blurkey = dot(GetNormalFromDepth(depth, texcoord.xy).xyz,0.333)*0.1;
#line 860
if(depth > min(0.9999,AO_FADE_END)) Occlusion1R = float4(1.0,1.0,1.0,blurkey);
else {
const float3 ssPosition = GetSAO_Position(texcoord.xy);
const float rotAngle = frac(sin(texcoord.xy.x + texcoord.xy.y * 543.31) *  493013.0) * 10.0;
#line 865
const float3 ssNormals = normalize(cross(normalize(ddy(ssPosition)), normalize(ddx(ssPosition))));
const float ssDiskRadius = fSAORadius / max(ssPosition.z,0.1f);
#line 868
float sum = 0.0;
#line 870
[loop]
for (int i = 0; i < iSAOSamples; ++i)
{
sum += GetSAO_SampleAO(texcoord.xy, ssPosition, ssNormals, ssDiskRadius, i, rotAngle);
}
#line 876
sum /= pow(fSAORadius,6.0);
#line 878
float A = pow(saturate(1.0 - sqrt(sum * (3.0 / iSAOSamples))), fSAOIntensity);
#line 880
A = (pow(A, 0.2) + 1.2 * A*A*A*A) / 2.2;
const float ao = lerp(1.0, A, fSAOClamp);
#line 883
Occlusion1R = float4(ao.xxx,blurkey);
}
}
#line 887
void PS_AO_AOBlurV(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 Occlusion2R : SV_Target0)
{
#line 891
texcoord.xy *= AO_TEXSCALE;
float  sum,totalweight=0;
float4 base = tex2D(SamplerOcclusion1, texcoord.xy), temp=0;
#line 895
[loop]
for (int r = -AO_BLUR_STEPS; r <= AO_BLUR_STEPS; ++r)
{
const float2 axis = float2(0.0, 1.0);
temp = tex2Dlod(SamplerOcclusion1, float4(texcoord.xy + axis * float2((1.0 / 1920), (1.0 / 1018)) * r, 0.0, 0.0));
float weight = AO_BLUR_STEPS-abs(r);
weight *= saturate(1.0 - (1000.0 * AO_SHARPNESS) * abs(temp.w - base.w));
sum += temp.x * weight;
totalweight += weight;
}
#line 906
Occlusion2R = float4(sum / (totalweight+0.0001),0,0,base.w);
}
#line 909
void PS_AO_AOBlurH(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 Occlusion1R : SV_Target0)
{
float  sum,totalweight=0;
float4 base = tex2D(SamplerOcclusion2, texcoord.xy), temp=0;
#line 914
[loop]
for (int r = -AO_BLUR_STEPS; r <= AO_BLUR_STEPS; ++r)
{
const float2 axis = float2(1.0, 0.0);
temp = tex2Dlod(SamplerOcclusion2, float4(texcoord.xy + axis * float2((1.0 / 1920), (1.0 / 1018)) * r, 0.0, 0.0));
float weight = AO_BLUR_STEPS-abs(r);
weight *= saturate(1.0 - (1000.0 * AO_SHARPNESS) * abs(temp.w - base.w));
sum += temp.x * weight;
totalweight += weight;
}
#line 925
Occlusion1R = float4(sum / (totalweight+0.0001),0,0,base.w);
}
#line 928
float4 PS_AO_AOCombine(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 931
float4 color = tex2D(SamplerHDR3, texcoord.xy);
float ao = tex2D(SamplerOcclusion1, texcoord.xy).x;
#line 934
if ( AO_DEBUG == 1)
{
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
ao = lerp(ao,1.0,smoothstep(AO_FADE_START,AO_FADE_END,depth));
return ao;
}
else
{
if(AO_LUMINANCE_CONSIDERATION == 1)
{
const float origlum = dot(color.xyz, 0.333);
const float aomult = smoothstep(AO_LUMINANCE_LOWER, AO_LUMINANCE_UPPER, origlum);
ao = lerp(ao, 1.0, aomult);
}
#line 949
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
ao = lerp(ao,1.0,smoothstep(AO_FADE_START,AO_FADE_END,depth));
#line 952
color.xyz *= ao;
return color;
}
}
#line 957
float4 PS_SSAO_AOCombine(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 960
float4 color = tex2D(SamplerHDR3, texcoord.xy);
float ao = tex2D(SamplerOcclusion1, texcoord.xy).x;
#line 963
ao -= 0.5;
if(ao < 0) ao *= fSSAODarkeningAmount;
if(ao > 0) ao *= fSSAOBrighteningAmount;
ao = 2 * saturate(ao+0.5);
#line 968
if( AO_DEBUG == 1)
{
ao *= 0.75;
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
ao = lerp(ao,1.0,smoothstep(AO_FADE_START,AO_FADE_END,depth));
return ao;
}
else
{
if(AO_LUMINANCE_CONSIDERATION == 1)
{
const float origlum = dot(color.xyz, 0.333);
const float aomult = smoothstep(AO_LUMINANCE_LOWER, AO_LUMINANCE_UPPER, origlum);
ao = lerp(ao, 1.0, aomult);
}
#line 984
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
ao = lerp(ao,1.0,smoothstep(AO_FADE_START,AO_FADE_END,depth));
#line 987
color.xyz *= ao;
return color;
}
}
#line 992
float4 PS_RayAO_AOCombine(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 995
float4 color = tex2D(SamplerHDR3, texcoord.xy);
float ao = tex2D(SamplerOcclusion1, texcoord.xy).x;
#line 998
ao = pow(abs(ao), fRayAOPower);
#line 1000
if( AO_DEBUG == 1)
{
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
ao = lerp(ao,1.0,smoothstep(AO_FADE_START,AO_FADE_END,depth));
return ao;
}
else
{
if(AO_LUMINANCE_CONSIDERATION == 1)
{
const float origlum = dot(color.xyz, 0.333);
const float aomult = smoothstep(AO_LUMINANCE_LOWER, AO_LUMINANCE_UPPER, origlum);
ao = lerp(ao, 1.0, aomult);
}
#line 1015
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
ao = lerp(ao,1.0,smoothstep(AO_FADE_START,AO_FADE_END,depth));
#line 1018
color.xyz *= ao;
return color;
}
}
#line 1023
void PS_AO_SSGI(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 Occlusion1R : SV_Target0)
{
texcoord.xy /= AO_TEXSCALE;
if(texcoord.x > 1.0 || texcoord.y > 1.0) discard;
#line 1028
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
#line 1030
if(depth > 0.9999) Occlusion1R = float4(0.0,0.0,0.0,1.0);
else {
float giClamp = 0.0;
#line 1034
const float2 sample_offset[24] =
{
float2(-0.1376476f,  0.2842022f ),float2(-0.626618f ,  0.4594115f ),
float2(-0.8903138f, -0.05865424f),float2( 0.2871419f,  0.8511679f ),
float2(-0.1525251f, -0.3870117f ),float2( 0.6978705f, -0.2176773f ),
float2( 0.7343006f,  0.3774331f ),float2( 0.1408805f, -0.88915f   ),
float2(-0.6642616f, -0.543601f  ),float2(-0.324815f, -0.093939f   ),
float2(-0.1208579f , 0.9152063f ),float2(-0.4528152f, -0.9659424f ),
float2(-0.6059740f,  0.7719080f ),float2(-0.6886246f, -0.5380305f ),
float2( 0.5380307f, -0.2176773f ),float2( 0.7343006f,  0.9999345f ),
float2(-0.9976073f, -0.7969264f ),float2(-0.5775355f,  0.2842022f ),
float2(-0.626618f ,  0.9115176f ),float2(-0.29818942f, -0.0865424f),
float2( 0.9161239f,  0.8511679f ),float2(-0.1525251f, -0.07103951f ),
float2( 0.7022788f, -0.823825f ),float2(0.60250657f,  0.64525909f )
};
#line 1050
const float sample_radius[24] =
{
0.5162497,0.2443335,
0.1014819,0.1574599,
0.6538922,0.5637644,
0.6347278,0.2467654,
0.5642318,0.0035689,
0.6384532,0.3956547,
0.7049623,0.3482861,
0.7484038,0.2304858,
0.0043161,0.5423726,
0.5025704,0.4066662,
0.2654198,0.8865175,
0.9505567,0.9936577
};
#line 1066
const float3 pos = GetEyePosition(texcoord.xy, depth);
const float3 dx = ddx(pos);
const float3 dy = ddy(pos);
float3 norm = normalize(cross(dx, dy));
norm.y *= -1;
#line 1072
float sample_depth;
#line 1074
float4 gi = float4(0, 0, 0, 0);
float is = 0, as = 0;
#line 1077
const float rangeZ = 5000;
#line 1079
const float2 rand_vec = GetRandom2_10(texcoord.xy);
const float2 rand_vec2 = GetRandom2_10(-texcoord.xy);
const float2 sample_vec_divisor = float2(tan(0.5f*radians(75)) / (float)(1.0 / 1018) * (float)(1.0 / 1920), tan(0.5f*radians(75))) * depth / (fSSGISamplingRange * float2((1.0 / 1920), (1.0 / 1018)).xy);
const float2 sample_center = texcoord.xy + norm.xy / sample_vec_divisor * float2(1, ((1.0 / 1018)/(1.0 / 1920)));
const float ii_sample_center_depth = depth * rangeZ + norm.z * fSSGISamplingRange * 20;
const float ao_sample_center_depth = depth * rangeZ + norm.z * fSSGISamplingRange * 5;
#line 1086
[fastopt]
for (int i = 0; i < iSSGISamples; i++) {
const float2 sample_vec = reflect(sample_offset[i], rand_vec) / sample_vec_divisor;
const float2 sample_coords = sample_center + sample_vec *  float2(1, ((1.0 / 1018)/(1.0 / 1920)));
const float  sample_depth = rangeZ * ReShade::GetLinearizedDepth(sample_coords.xy).x;
#line 1092
const float ii_curr_sample_radius = sample_radius[i] * fSSGISamplingRange * 20;
const float ao_curr_sample_radius = sample_radius[i] * fSSGISamplingRange * 5;
#line 1095
gi.a += clamp(0, ao_sample_center_depth + ao_curr_sample_radius - sample_depth, 2 * ao_curr_sample_radius);
gi.a -= clamp(0, ao_sample_center_depth + ao_curr_sample_radius - sample_depth - fSSGIModelThickness, 2 * ao_curr_sample_radius);
#line 1098
if ((sample_depth < ii_sample_center_depth + ii_curr_sample_radius) &&
(sample_depth > ii_sample_center_depth - ii_curr_sample_radius)) {
const float3 sample_pos = GetEyePosition(sample_coords, sample_depth);
const float3 unit_vector = normalize(pos - sample_pos);
gi.rgb += tex2Dlod(SamplerHDR3, float4(sample_coords,0,0)).rgb;
}
#line 1105
is += 1.0f;
as += 2.0f * ao_curr_sample_radius;
}
#line 1109
gi.rgb /= is * 5.0f;
gi.a   /= as;
#line 1112
gi.rgb = 0.0 + gi.rgb * fSSGIIlluminationMult;
gi.a   = 1.0 - gi.a   * fSSGIOcclusionMult;
#line 1115
gi.rgb = lerp(dot(gi.rgb, 0.333), gi.rgb, fSSGISaturation);
#line 1117
Occlusion1R = gi;
}
}
#line 1122
void PS_AO_GIBlurV(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 Occlusion2R : SV_Target0)
{
texcoord.xy *= AO_TEXSCALE;
float4 sum=0;
float totalweight=0;
float4 base = tex2D(SamplerOcclusion1, texcoord.xy), temp = 0;
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
float blurkey;
if( AO_SHARPNESS_DETECT == 0)
blurkey = depth;
else
blurkey = dot(GetNormalFromDepth(depth, texcoord.xy).xyz,0.333)*0.1;
#line 1135
[loop]
for (int r = -AO_BLUR_STEPS; r <= AO_BLUR_STEPS; ++r)
{
const float2 axis = float2(0, 1);
temp = tex2Dlod(SamplerOcclusion1, float4(texcoord.xy + axis * float2((1.0 / 1920), (1.0 / 1018)) * r, 0.0, 0.0));
const float tempdepth = ReShade::GetLinearizedDepth(texcoord + axis * float2((1.0 / 1920), (1.0 / 1018)) * r).x;
float tempkey;
if( AO_SHARPNESS_DETECT == 0)
tempkey = tempdepth;
else
tempkey = dot(GetNormalFromDepth(tempdepth, texcoord.xy + axis * float2((1.0 / 1920), (1.0 / 1018)) * r).xyz,0.333)*0.1;
#line 1147
float weight = AO_BLUR_STEPS-abs(r);
weight *= saturate(1.0 - (1000.0 * AO_SHARPNESS) * abs(tempkey - blurkey));
sum += temp * weight;
totalweight += weight;
}
#line 1153
Occlusion2R = sum / (totalweight+0.0001);
}
#line 1156
void PS_AO_GIBlurH(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 Occlusion1R : SV_Target0)
{
float4 sum=0;
float totalweight=0;
float4 base = tex2D(SamplerOcclusion2, texcoord.xy), temp = 0;
#line 1162
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
float blurkey;
if( AO_SHARPNESS_DETECT == 0)
blurkey = depth;
else
blurkey = dot(GetNormalFromDepth(depth, texcoord.xy).xyz,0.333)*0.1;
#line 1169
[loop]
for (int r = -AO_BLUR_STEPS; r <= AO_BLUR_STEPS; ++r)
{
const float2 axis = float2(1, 0);
temp = tex2Dlod(SamplerOcclusion2, float4(texcoord.xy + axis * float2((1.0 / 1920), (1.0 / 1018)) * r, 0.0, 0.0));
const float tempdepth = ReShade::GetLinearizedDepth(texcoord + axis * float2((1.0 / 1920), (1.0 / 1018)) * r).x;
float tempkey;
if( AO_SHARPNESS_DETECT == 0)
tempkey = tempdepth;
else
tempkey = dot(GetNormalFromDepth(tempdepth, texcoord.xy + axis * float2((1.0 / 1920), (1.0 / 1018)) * r).xyz,0.333)*0.1;
#line 1181
float weight = AO_BLUR_STEPS-abs(r);
weight *= saturate(1.0 - (1000.0 * AO_SHARPNESS) * abs(tempkey - blurkey));
sum += temp * weight;
totalweight += weight;
}
#line 1187
Occlusion1R = sum / (totalweight+0.0001);
}
#line 1190
float4 PS_AO_GICombine(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 1193
float4 color = tex2D(SamplerHDR3, texcoord.xy);
float4 gi = tex2D(SamplerOcclusion1, texcoord.xy);
#line 1196
if( AO_DEBUG == 1)
return gi.wwww; 
else if ( AO_DEBUG == 2)
return gi.xyzz; 
else
{
if(AO_LUMINANCE_CONSIDERATION == 1)
{
const float origlum = dot(color.xyz, 0.333);
const float aomult = smoothstep(AO_LUMINANCE_LOWER, AO_LUMINANCE_UPPER, origlum);
gi.w = lerp(gi.w, 1.0, aomult);
gi.xyz = lerp(gi.xyz,0.0, aomult);
}
#line 1210
const float depth = ReShade::GetLinearizedDepth(texcoord.xy).x;
gi.xyz = lerp(gi.xyz,0.0,smoothstep(AO_FADE_START,AO_FADE_END,depth));
gi.w = lerp(gi.w,1.0,smoothstep(AO_FADE_START,AO_FADE_END,depth));
#line 1214
color.xyz = (color.xyz+gi.xyz)*gi.w;
return color;
}
}
#line 1219
void PS_Init(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdrT : SV_Target0)
{
hdrT = tex2D(ReShade::BackBuffer, texcoord.xy);
}
#line 1224
technique SSAO
{
pass Init_HDR1						
{							
VertexShader = PostProcessVS;			
PixelShader = PS_Init;
RenderTarget = texHDR3;
}
#line 1233
pass AO_SSAO
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_SSAO;
RenderTarget = texOcclusion1;
}
#line 1240
pass AO_AOBlurV
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOBlurV;
RenderTarget = texOcclusion2;
}
#line 1247
pass AO_AOBlurH
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOBlurH;
RenderTarget = texOcclusion1;
}
#line 1254
pass AO_AOCombine
{
VertexShader = PostProcessVS;
PixelShader = PS_SSAO_AOCombine;
}
}
#line 1262
technique RayAO
{
pass Init_HDR1						
{							
VertexShader = PostProcessVS;			
PixelShader = PS_Init;
RenderTarget = texHDR3;
}
#line 1271
pass AO_RayAO
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_RayAO;
RenderTarget = texOcclusion1;
}
#line 1278
pass AO_AOBlurV
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOBlurV;
RenderTarget = texOcclusion2;
}
#line 1285
pass AO_AOBlurH
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOBlurH;
RenderTarget = texOcclusion1;
}
#line 1292
pass AO_AOCombine
{
VertexShader = PostProcessVS;
PixelShader = PS_RayAO_AOCombine;
}
}
#line 1300
technique HBAO
{
pass Init_HDR1						
{							
VertexShader = PostProcessVS;			
PixelShader = PS_Init;
RenderTarget = texHDR3;
}
#line 1309
pass AO_HBAO
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_HBAO;
RenderTarget = texOcclusion1;
}
#line 1316
pass AO_AOBlurV
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOBlurV;
RenderTarget = texOcclusion2;
}
#line 1323
pass AO_AOBlurH
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOBlurH;
RenderTarget = texOcclusion1;
}
#line 1330
pass AO_AOCombine
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOCombine;
}
}
#line 1338
technique SSGI
{
pass Init_HDR1						
{							
VertexShader = PostProcessVS;			
PixelShader = PS_Init;
RenderTarget = texHDR3;
}
#line 1347
pass AO_AOBlurV
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOBlurV;
RenderTarget = texOcclusion2;
}
#line 1354
pass AO_AOBlurH
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOBlurH;
RenderTarget = texOcclusion1;
}
#line 1361
pass AO_AOCombine
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOCombine;
}
#line 1367
pass AO_SSGI
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_SSGI;
RenderTarget = texOcclusion1;
}
#line 1374
pass AO_GIBlurV
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_GIBlurV;
RenderTarget = texOcclusion2;
}
#line 1381
pass AO_GIBlurH
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_GIBlurH;
RenderTarget = texOcclusion1;
}
#line 1388
pass AO_GICombine
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_GICombine;
}
}
#line 1396
technique AO_SAO
{
pass Init_HDR1						
{							
VertexShader = PostProcessVS;			
PixelShader = PS_Init;
RenderTarget = texHDR3;
}
#line 1405
pass AO_HBAO
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_SAO;
RenderTarget = texOcclusion1;
}
pass AO_AOBlurV
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOBlurV;
RenderTarget = texOcclusion2;
}
#line 1418
pass AO_AOBlurH
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOBlurH;
RenderTarget = texOcclusion1;
}
#line 1425
pass AO_AOCombine
{
VertexShader = PostProcessVS;
PixelShader = PS_AO_AOCombine;
}
}

