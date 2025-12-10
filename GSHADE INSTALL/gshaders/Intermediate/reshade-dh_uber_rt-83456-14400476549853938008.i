// USE_VORT_MOTION=0
// USE_MARTY_LAUNCHPAD_MOTION=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_uber_rt.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Reshade.fxh"
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
#line 16 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_uber_rt.fx"
#line 102
texture texMotionVectors { Width = 1920; Height = 1018; Format = RG16F; };
sampler sTexMotionVectorsSampler { Texture = texMotionVectors; MagFilter=POINT;MinFilter=POINT;MipFilter= POINT;AddressU=Clamp;AddressV=Clamp;AddressW=Clamp; };
#line 107
namespace DH_UBER_RT_0206 {
#line 117
texture ambientTex { Width = 1; Height = 1; Format = RGBA16F; };
sampler ambientSampler { Texture = ambientTex; };
#line 120
texture previousAmbientTex { Width = 1; Height = 1; Format = RGBA16F; };
sampler previousAmbientSampler { Texture = previousAmbientTex; };
#line 124
texture previousDepthTex { Width = 1920; Height = 1018; Format = RG32F; MipLevels = 6;  };
sampler previousDepthSampler { Texture = previousDepthTex; MinLOD = 0.0f; MaxLOD = 5.0f; };
#line 127
texture motionMaskTex { Width = 1920; Height = 1018; Format = R8; };
sampler motionMaskSampler { Texture = motionMaskTex; };
#line 130
texture depthTex { Width = 1920; Height = 1018; Format = R32F; MipLevels = 6;  };
sampler depthSampler { Texture = depthTex; MinLOD = 0.0f; MaxLOD = 5.0f; };
#line 134
texture previousRTFTex { Width = 1920; Height = 1018; Format = RGBA8; };
sampler previousRTFSampler { Texture = previousRTFTex; };
texture RTFTex { Width = 1920; Height = 1018; Format = RGBA8; };
sampler RTFSampler { Texture = RTFTex; MagFilter=POINT;MinFilter=POINT;MipFilter= POINT;AddressU=REPEAT;AddressV=REPEAT;AddressW=REPEAT;};
#line 139
texture bestRayTex { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler bestRaySampler { Texture = bestRayTex; MagFilter=POINT;MinFilter=POINT;MipFilter= POINT;AddressU=Clamp;AddressV=Clamp;AddressW=Clamp; };
#line 142
texture bestRayFillTex { Width = 1920/1; Height = 1018/1; Format = RGBA16F; };
sampler bestRayFillSampler { Texture = bestRayFillTex; MagFilter=POINT;MinFilter=POINT;MipFilter= POINT;AddressU=Clamp;AddressV=Clamp;AddressW=Clamp;};
#line 153
texture normalTex { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler normalSampler { Texture = normalTex; MagFilter=POINT;MinFilter=POINT;MipFilter= POINT;AddressU=Clamp;AddressV=Clamp;AddressW=Clamp;};
#line 156
texture resultTex { Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 6;  };
sampler resultSampler { Texture = resultTex; MinLOD = 0.0f; MaxLOD = 5.0f;};
#line 160
texture rayColorTex { Width = 1920; Height = 1018; Format = RGBA8; };
sampler rayColorSampler { Texture = rayColorTex; };
#line 163
texture giPassTex { Width = 1920; Height = 1018; Format = RGBA8; };
sampler giPassSampler { Texture = giPassTex; MagFilter=POINT;MinFilter=POINT;MipFilter= POINT;AddressU=REPEAT;AddressV=REPEAT;AddressW=REPEAT;};
#line 166
texture giPass2Tex { Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 6;  };
sampler giPass2Sampler { Texture = giPass2Tex; MinLOD = 0.0f; MaxLOD = 5.0f; MagFilter=POINT;MinFilter=POINT;MipFilter= POINT;AddressU=REPEAT;AddressV=REPEAT;AddressW=REPEAT;};
#line 169
texture giSmoothPassTex { Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 6;  };
sampler giSmoothPassSampler { Texture = giSmoothPassTex; MinLOD = 0.0f; MaxLOD = 5.0f; };
#line 172
texture giSmooth2PassTex { Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 6;  };
sampler giSmooth2PassSampler { Texture = giSmooth2PassTex; MinLOD = 0.0f; MaxLOD = 5.0f; };
#line 175
texture giAccuTex { Width = 1920; Height = 1018; Format = RGBA8;};
sampler giAccuSampler { Texture = giAccuTex;};
#line 178
texture giPreviousAccuTex { Width = 1920; Height = 1018; Format = RGBA8;  MipLevels = 6;};
sampler giPreviousAccuSampler { Texture = giPreviousAccuTex; MinLOD = 0.0f; MaxLOD = 5.0f;};
#line 181
texture reinhardTex { Width = 1; Height = 1; Format = RGBA16F; };
sampler reinhardSampler { Texture = reinhardTex; };
#line 185
texture ssrPassTex { Width = 1920; Height = 1018; Format = RGBA8;  MipLevels = 6;  };
sampler ssrPassSampler { Texture = ssrPassTex; MinLOD = 0.0f; MaxLOD = 5.0f;};
#line 188
texture ssrAccuTex { Width = 1920; Height = 1018; Format = RGBA8;  MipLevels = 6; };
sampler ssrAccuSampler { Texture = ssrAccuTex; MinLOD = 0.0f; MaxLOD = 5.0f; };
#line 191
texture ssrPreviousAccuTex { Width = 1920; Height = 1018; Format = RGBA8; };
sampler ssrPreviousAccuSampler { Texture = ssrPreviousAccuTex;};
#line 196
struct RTOUT {
float3 wp;
float status;
float4 drtf;
float dist;
};
#line 205
uniform int framecount < source = "framecount"; >;
uniform int random < source = "random"; min = 0; max = 512; >;
#line 263
uniform int iDebug <
ui_category = "Debug";
ui_type = "combo";
ui_label = "Display";
ui_items = "Output\0GI\0AO\0SSR\0Roughness\0Depth\0Normal\0Sky\0Motion\0Ambient light\0Thickness\0";
ui_tooltip = "Debug the different components of the shader";
> = 0;
uniform int iDebugPass <
ui_category= "Debug";
ui_type = "combo";
ui_label = "GI/AO/SSR pass";
ui_items = "New rays\0Resample\0Spatial denoising\0Temporal denoising\0Merging\0";
ui_tooltip = "GI/AO/SSR only: Debug the intermediate steps of the shader";
> = 3;
#line 280
uniform bool bSkyAt0 <
ui_category = "Game specific hacks";
ui_label = "Sky at Depth=0 (SWTOR)";
> = false;
#line 285
uniform bool bDepthMulti5 <
ui_category = "Game specific hacks";
ui_label = "Depth multiplier=5 (Skyrim SE, Other DX9>11 games)";
> = false;
#line 291
uniform float fSkyDepth <
ui_type = "slider";
ui_category = "Common";
ui_label = "Sky Depth";
ui_min = 0.00; ui_max = 1.00;
ui_step = 0.001;
ui_tooltip = "Define where the sky starts to prevent if to be affected by the shader";
> = 0.999;
#line 300
uniform float fWeaponDepth <
ui_type = "slider";
ui_category = "Common";
ui_label = "Weapon Depth";
ui_min = 0.00; ui_max = 1.00;
ui_step = 0.001;
ui_tooltip = "Define where the weapon ends to prevent it to affect the SSR";
> = 0.001;
#line 309
uniform float fNormalRoughness <
ui_type = "slider";
ui_category = "Common";
ui_label = "Normal roughness";
ui_min = 0.000; ui_max = 1.0;
ui_step = 0.001;
ui_tooltip = "";
> = 0.1;
#line 319
uniform int iRoughnessRadius <
ui_type = "slider";
ui_category = "Common";
ui_label = "Roughness Radius";
ui_min = 1; ui_max = 4;
ui_step = 2;
ui_tooltip = "Define the max distance of roughness computation.\n"
"/!\\ HAS A BIG INPACT ON PERFORMANCES";
> = 2;
#line 329
uniform int iRTPrecision <
ui_type = "slider";
ui_category = "Common";
ui_label = "RT Precision";
ui_min = 1; ui_max = 3;
ui_step = 1;
ui_tooltip = "/!\\ HAS A BIG INPACT ON PERFORMANCES";
> = 1;
#line 338
uniform bool bSmoothNormals <
ui_category = "Common";
ui_label = "Smooth Normals";
> = false;
#line 346
uniform bool bRemoveAmbient <
ui_category = "Ambient light";
ui_label = "Remove Source Ambient light";
> = true;
#line 351
uniform float fSourceAmbientIntensity <
ui_type = "slider";
ui_category = "Ambient light";
ui_label = "Strength";
ui_min = 0; ui_max = 1.0;
ui_step = 0.001;
> = 0.75;
#line 359
uniform float fRemoveAmbientAutoAntiFlicker <
ui_type = "slider";
ui_category = "Remove ambient light";
ui_label = "Compromise flicker/reactvity";
ui_min = 0; ui_max = 1.0;
ui_step = 0.001;
> = 0.5;
#line 369
uniform float fGIRenderScale <
ui_category="GI/AO: 1st Pass (New rays)";
ui_label = "GI Render scale";
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.333;
#line 378
uniform int iRTMaxRays <
ui_type = "slider";
ui_category = "GI/AO: 1st Pass (New rays)";
ui_label = "Max rays...";
ui_min = 1; ui_max = 6;
ui_step = 1;
ui_tooltip = "Maximum number of rays from 1 pixel if the first miss\n"
"Lower=Darker image, better performance\n"
"Higher=Less noise, brighter image\n"
"/!\\ HAS A BIG INPACT ON PERFORMANCES";
> = 2;
#line 393
uniform float fGIAvoidThin <
ui_type = "slider";
ui_category = "GI/AO: 1st Pass (New rays)";
ui_label = "Avoid thin objects: max thickness";
ui_tooltip = "Reduce detection of grass or fences";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.750;
#line 403
uniform int iHudBorderProtectionRadius <
ui_type = "slider";
ui_category = "GI/AO: 1st Pass (New rays)";
ui_label = "Avoid HUD: Radius";
ui_tooltip = "Reduce chances of detecting large lights from the HUD. Disable if you're using REST or if HUD is hidden";
ui_min = 1; ui_max = 256;
ui_step = 1;
> = 180;
#line 412
uniform float fHudBorderProtectionStrength <
ui_type = "slider";
ui_category = "GI/AO: 1st Pass (New rays)";
ui_label = "Avoid HUD: Strength";
ui_tooltip = "Reduce chances of detecting large lights from the HUD. Disable if you're using REST or if HUD is hidden";
ui_min = 0.0; ui_max = 16.0;
ui_step = 0.01;
> = 16;
#line 423
uniform int iMemRadius <
ui_type = "slider";
ui_category = "GI/AO: 2nd Pass (Resample)";
ui_label = "Memory radius";
ui_min = 0; ui_max = 3;
ui_step = 1;
> = 2;
#line 436
uniform int iSmoothSamples <
ui_type = "slider";
ui_category = "GI/AO: 3rd pass (Denoising)";
ui_label = "Spatial: Samples";
ui_min = 1; ui_max = 64;
ui_step = 1;
ui_tooltip = "Define the number of denoising samples.\n"
"Higher:less noise, less performances\n"
"/!\\ HAS A BIG INPACT ON PERFORMANCES";
#line 448
> = 5;
#line 451
uniform int iSmoothRadius <
ui_type = "slider";
ui_category = "GI/AO: 3rd pass (Denoising)";
ui_label = "Spatial: Radius";
ui_min = 0; ui_max = 16;
ui_step = 1;
ui_tooltip = "Define the max distance of smoothing.\n";
> = 8;
#line 460
uniform int iGIFrameAccu <
ui_type = "slider";
ui_category = "GI/AO: 3rd pass (Denoising)";
ui_label = "GI Temporal accumulation";
ui_min = 1; ui_max = 32;
ui_step = 1;
ui_tooltip = "Define the number of accumulated frames over time.\n"
"Lower=less ghosting in motion, more noise\n"
"Higher=more ghosting in motion, less noise\n"
"/!\\ If motion detection is disable, decrease this to 3 except if you have a very high fps";
#line 473
> = 16;
#line 476
uniform int iAOFrameAccu <
ui_type = "slider";
ui_category = "GI/AO: 3rd pass (Denoising)";
ui_label = "AO Temporal accumulation";
ui_min = 1; ui_max = 16;
ui_step = 1;
ui_tooltip = "Define the number of accumulated frames over time.\n"
"Lower=less ghosting in motion, more noise\n"
"Higher=more ghosting in motion, less noise\n"
"/!\\ If motion detection is disable, decrease this to 3 except if you have a very high fps";
> = 10;
#line 488
uniform float fGIRayColorMinBrightness <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "GI Ray min brightness";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.0;
#line 496
uniform int iGIRayColorMode <
ui_type = "combo";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "GI Ray brightness mode";
ui_items = "Crop\0Smoothstep\0Linear\0Gamma\0";
#line 504
> = 1;
#line 507
uniform float fGIDistanceAttenuation <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "Distance attenuation";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.350;
#line 516
uniform float fSkyColor <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "Sky color";
ui_min = 0; ui_max = 1.0;
ui_step = 0.01;
ui_tooltip = "Define how much the sky can brighten the scene";
> = 0.4;
#line 525
uniform float fSaturationBoost <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "Saturation boost";
ui_min = 0; ui_max = 1.0;
ui_step = 0.01;
> = 0.1;
#line 533
uniform float fGIDarkAmplify <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "Dark color compensation";
ui_min = 0; ui_max = 1.0;
ui_step = 0.01;
ui_tooltip = "Brighten dark colors, useful in dark corners";
> = 0.1;
#line 542
uniform float fGIBounce <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "Bounce intensity";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
ui_tooltip = "Define if GI bounces in following frames";
> = 0.34;
#line 551
uniform float fGIHueBiais <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "Hue Biais";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
ui_tooltip = "Define how much base color can take GI hue.";
> = 0.5;
#line 560
uniform float fGILightMerging <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "In Light intensity";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
ui_tooltip = "Define how much bright areas are affected by GI.";
> = 0.10;
uniform float fGIDarkMerging <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "In Dark intensity";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
ui_tooltip = "Define how much dark areas are affected by GI.";
> = 0.5;
#line 577
uniform float fGIFinalMerging <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "General intensity";
ui_min = 0; ui_max = 2.0;
ui_step = 0.01;
ui_tooltip = "Define how much the whole image is affected by GI.";
> = 1.0;
#line 586
uniform float fGIOverbrightToWhite <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "Overbright to white";
ui_min = 0.0; ui_max = 5.0;
ui_step = 0.001;
> = 0.2;
#line 594
uniform bool bRreinhardFinalMerging <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "Reinhard Tonemap";
ui_tooltip = "Improve details in dark and bright areas.";
> = true;
#line 601
uniform float fRreinhardStrength <
ui_type = "slider";
ui_category = "GI: 4th Pass (Merging)";
ui_label = "Reinhard Tonemap strength";
ui_min = 0; ui_max = 1.0;
ui_step = 0.01;
ui_tooltip = "Improve details in dark and bright areas.";
> = 0.5;
#line 612
uniform float fAOBoostFromGI <
ui_type = "slider";
ui_category = "AO: 4th Pass (Merging)";
ui_label = "Boost from GI";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.5;
#line 620
uniform float fAOMultiplier <
ui_type = "slider";
ui_category = "AO: 4th Pass (Merging)";
ui_label = "Multiplier";
ui_min = 0.0; ui_max = 5;
ui_step = 0.01;
ui_tooltip = "Define the intensity of AO";
> = 0.9;
#line 629
uniform int iAODistance <
ui_type = "slider";
ui_category = "AO: 4th Pass (Merging)";
ui_label = "Distance";
ui_min = 0; ui_max = 1920;
ui_step = 1;
> = 1920/6;
#line 637
uniform float fAOPow <
ui_type = "slider";
ui_category = "AO: 4th Pass (Merging)";
ui_label = "Pow";
ui_min = 0.001; ui_max = 2.0;
ui_step = 0.001;
ui_tooltip = "Define the intensity of the gradient of AO";
> = 1.0;
#line 646
uniform float fAOLightProtect <
ui_type = "slider";
ui_category = "AO: 4th Pass (Merging)";
ui_label = "Light protection";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
ui_tooltip = "Protection of bright areas to avoid washed out highlights";
> = 0.5;
#line 655
uniform float fAODarkProtect <
ui_type = "slider";
ui_category = "AO: 4th Pass (Merging)";
ui_label = "Dark protection";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
ui_tooltip = "Protection of dark areas to avoid totally black and unplayable parts";
> = 0.15;
#line 664
uniform float fAoProtectGi <
ui_type = "slider";
ui_category = "AO: 4th Pass (Merging)";
ui_label = "GI protection";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.05;
#line 675
uniform bool bSSR <
ui_category = "SSR";
ui_label = "Enable SSR";
ui_tooltip = "Toggle SSR";
> = false;
#line 681
uniform float fSSRRenderScale <
ui_category="SSR";
ui_label = "SSR Render scale";
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.5;
#line 689
uniform int iSSRFrameAccu <
ui_type = "slider";
ui_category = "SSR";
ui_label = "SSR Temporal accumulation";
ui_min = 1; ui_max = 16;
ui_step = 1;
ui_tooltip = "Define the number of accumulated frames over time.\n"
"Lower=less ghosting in motion, more noise\n"
"Higher=more ghosting in motion, less noise\n"
"/!\\ If motion detection is disable, decrease this to 3 except if you have a very high fps";
#line 702
> = 10;
#line 705
uniform int iSSRCorrectionMode <
ui_type = "combo";
ui_category = "SSR";
ui_label = "Geometry correction mode";
ui_items = "No correction\0FOV\0";
ui_tooltip = "Try modifying this value is the relfection seems wrong";
> = 1;
#line 713
uniform float fSSRCorrectionStrength <
ui_type = "slider";
ui_category = "SSR";
ui_label = "Geometry correction strength";
ui_min = -1; ui_max = 1;
ui_step = 0.001;
ui_tooltip = "Try modifying this value is the relfection seems wrong";
> = 0;
#line 722
uniform float fSSRMergingRoughness <
ui_type = "slider";
ui_category = "SSR";
ui_label = "Roughness reflexivity";
ui_min = 0.000; ui_max = 1.0;
ui_step = 0.001;
ui_tooltip = "Define how much the roughness decrease reflection intensity";
> = 0.5;
#line 731
uniform float fSSRMergingOrientation <
ui_type = "slider";
ui_category = "SSR";
ui_label = "Orientation reflexivity";
ui_min = 0.000; ui_max = 1.0;
ui_step = 0.001;
ui_tooltip = "Higher value make the wall less reflective than the floor";
> = 0.5;
#line 740
uniform float fSSRMerging <
ui_type = "slider";
ui_category = "SSR";
ui_label = "SSR Intensity";
ui_min = 0; ui_max = 1.0;
ui_step = 0.001;
ui_tooltip = "Define this intensity of the Screan Space Reflection.";
> = 0.5;
#line 751
uniform float fDistanceFading <
ui_type = "slider";
ui_category = "Fianl Merging";
ui_label = "Distance fading";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
ui_tooltip = "Distance from where the effect is less applied.";
> = 0.9;
#line 761
uniform float fBaseColor <
ui_type = "slider";
ui_category = "Fianl Merging";
ui_label = "Base color";
ui_min = 0.0; ui_max = 2.0;
ui_step = 0.01;
ui_tooltip = "Simple multiplier for the base image.";
> = 1.0;
#line 770
uniform bool bBaseAlternative <
ui_category = "Fianl Merging";
ui_label = "Base color alternative method";
> = false;
#line 775
uniform int iBlackLevel <
ui_type = "slider";
ui_category = "Fianl Merging";
ui_label = "Black level ";
ui_min = 0; ui_max = 255;
ui_step = 1;
> = 0;
#line 783
uniform int iWhiteLevel <
ui_type = "slider";
ui_category = "Fianl Merging";
ui_label = "White level";
ui_min = 0; ui_max = 255;
ui_step = 1;
> = 255;
#line 793
uniform bool bDebugLight <
ui_type = "color";
ui_category = "Debug Light";
ui_label = "Enable";
> = false;
#line 799
uniform bool bDebugLightOnly <
ui_type = "color";
ui_category = "Debug Light";
ui_label = "No scene light";
> = true;
#line 805
uniform float3 fDebugLightColor <
ui_type = "color";
ui_category = "Debug Light";
ui_label = "Color";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = float3(1.0,0,0);
#line 813
uniform float3 fDebugLightPosition <
ui_type = "slider";
ui_category = "Debug Light";
ui_label = "XYZ Position";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = float3(0.5,0.5,0.05);
#line 821
uniform int iDebugLightSize <
ui_type = "slider";
ui_category = "Debug Light";
ui_label = "Source Size";
ui_min = 1; ui_max = 100;
ui_step = 1;
> = 2;
#line 829
uniform bool bDebugLightZAtDepth <
ui_type = "color";
ui_category = "Debug Light";
ui_label = "Z at screen depth";
> = true;
#line 839
bool isScaledProcessed(float2 coords) {
return coords.x>=0 && coords.y>0 && coords.x<=fGIRenderScale && coords.y<=fGIRenderScale;
}
#line 843
float2 upCoords(float2 coords) {
float2 result = coords/fGIRenderScale;
#line 846
int steps = ceil(1.0/fGIRenderScale);
int count = steps*steps;
int index = random%count;
int2 delta = int2(index/steps,index%steps)-steps/2;
result += delta*ReShade::GetPixelSize();
#line 852
return result;
}
#line 855
float2 upCoordsSSR(float2 coords) {
float2 result = coords/fSSRRenderScale;
#line 858
int steps = ceil(1.0/fSSRRenderScale);
int count = steps*steps;
int index = random%count;
int2 delta = int2(index/steps,index%steps)-steps/2;
result += delta*ReShade::GetPixelSize();
#line 864
return result;
}
#line 868
float safePow(float value, float power) {
return pow(abs(value),power);
}
#line 872
float3 safePow(float3 value, float power) {
return pow(abs(value),power);
}
#line 878
float3 RGBtoHSV(float3 c) {
float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
#line 883
float d = q.x - min(q.w, q.y);
float e = 1.0e-10;
return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
#line 888
float3 HSVtoRGB(float3 c) {
float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
#line 894
float hueDistance(float a,float b) {
return min(abs(a-b),1.0-abs(a-b));
}
#line 898
float getPureness(float3 rgb) {
return max(max(rgb.x,rgb.y),rgb.z)-min(min(rgb.x,rgb.y),rgb.z);
}
#line 902
float getBrightness(float3 rgb) {
return max(max(rgb.x,rgb.y),rgb.z);
}
#line 906
float3 RGBtoOKL(float3 rgb) {
#line 909
float3 r = rgb <= 0.04045 ? rgb / 12.92 : pow((rgb + 0.055) / 1.055, 2.4);
#line 912
r = mul(float3x3(
0.4122214708, 0.5363325363, 0.0514459929,
0.2119034982, 0.6806995451, 0.1073969566,
0.0883024619, 0.2817188376, 0.6299787005
), r);
#line 919
r = pow(r, 1.0 / 3.0);
#line 922
r = mul(float3x3(
0.2104542553, 0.7936177850, -0.0040720468,
1.9779984951, -2.4285922050, 0.4505937099,
0.0259040371, 0.7827717662, -0.8086757660
), r);
#line 928
return r;
}
#line 931
float3 OKLtoRGB(float3 oklab) {
#line 933
float3 r = mul(float3x3(
1.0, 0.3963377774, 0.2158037573,
1.0, -0.1055613458, -0.0638541728,
1.0, -0.0894841775, -1.2914855480
), oklab);
#line 940
r = r * r * r;
#line 943
r = mul(float3x3(
4.0767416621, -3.3077115913, 0.2309699292,
-1.2684380046, 2.6097574011, -0.3413193965,
-0.0041960863, -0.7034186147, 1.7076147010
), r);
#line 950
r = r <= 0.0031308 ? r * 12.92 : 1.055 * pow(r, 1.0 / 2.4) - 0.055;
#line 952
return r;
}
#line 958
float getDepthMultiplier() {
return bDepthMulti5 ? 5 : 1;
}
#line 962
float getSkyDepth() {
return fSkyDepth*getDepthMultiplier();
}
#line 966
float isSky(float depth) {
return bSkyAt0 ? depth==0 : depth>getSkyDepth();
}
#line 970
float3 getNormal(float2 coords) {
float3 normal = -(tex2Dlod(normalSampler,float4(coords,0,0)).xyz-0.5)*2;
return normalize(normal);
}
#line 975
float2 getDepth(float2 coords) {
float2 d = ReShade::GetLinearizedDepth(coords);
#line 978
if(d.x<fWeaponDepth)  {
d *= 1000.0*0.005*getDepthMultiplier();
d.y = 1;
} else {
d *= getDepthMultiplier();
d.y = 0;
}
return d;
}
#line 989
float4 getRTF(float2 coords) {
return tex2Dlod(RTFSampler,float4((coords).xy,0,0));
}
#line 993
float4 getDRTF(float2 coords) {
#line 995
float4 drtf = getDepth(coords).x;
drtf.yzw = getRTF(coords).xyz;
if(fNormalRoughness>0 && !isSky(drtf.x)) {
drtf.x += drtf.x*drtf.y*fNormalRoughness*0.05;
}
drtf.z = (0.01+drtf.z)*drtf.x*320;
drtf.z *= (0.25+drtf.x);
#line 1003
return drtf;
}
#line 1006
bool inScreen(float3 coords) {
return coords.x>=0.0 && coords.x<=1.0
&& coords.y>=0.0 && coords.y<=1.0
&& coords.z>=0.0 && coords.z<=getDepthMultiplier();
}
#line 1012
bool inScreen(float2 coords) {
return coords.x>=0.0 && coords.x<=1.0
&& coords.y>=0.0 && coords.y<=1.0;
}
#line 1017
float3 fovCorrectedBufferSize() {
float3 result = int3(1920,1018,1000.0);
if(iSSRCorrectionMode==1) result.xy *= 1.0+fSSRCorrectionStrength;
return result;
}
#line 1023
float3 getWorldPositionForNormal(float2 coords,bool ignoreRoughness) {
float depth = getDepth(coords).x;
if(!ignoreRoughness && fNormalRoughness>0 && !isSky(depth)) {
float roughness = getRTF(coords).x;
if(bSmoothNormals) roughness *= 1.5;
depth /= getDepthMultiplier();
depth += depth*roughness*fNormalRoughness*0.05;
depth *= getDepthMultiplier();
}
#line 1033
float3 result = float3((coords-0.5)*depth,depth);
result *= fovCorrectedBufferSize();
return result;
}
#line 1038
float3 getWorldPosition(float2 coords,float depth) {
float3 result = float3((coords-0.5)*depth,depth);
#line 1041
result *= fovCorrectedBufferSize();
return result;
}
#line 1045
float3 getScreenPosition(float3 wp) {
float3 result = wp/fovCorrectedBufferSize();
result.xy /= result.z;
return float3(result.xy+0.5,result.z);
}
#line 1057
float2 nextRand(float2 rand) {
return  frac(abs(rand+3.14159265359)*3.14159265359);
}
float3 nextRand(float3 rand) {
return frac(abs(rand+3.14159265359)*3.14159265359);
}
#line 1065
int getPixelIndex(float2 coords,int2 size) {
int2 pxCoords = coords*size;
return pxCoords.x+pxCoords.y*size.x+random;
}
#line 1070
float randomValue(inout uint seed) {
seed = seed * 747796405 + 2891336453;
uint result = ((seed>>((seed>>28)+4))^seed)*277803737;
result = (result>>22)^result;
return result/4294967295.0;
}
#line 1078
float2 randomCouple(float2 coords) {
#line 1087
uint seed = getPixelIndex(coords,int2(1920,1018));
#line 1089
float2 v = 0;
v.x = randomValue(seed);
v.y = randomValue(seed);
return v;
#line 1094
}
#line 1098
float3 randomTriple(float2 coords,in out uint seed) {
float3 v = 0;
v.x = randomValue(seed);
v.y = randomValue(seed);
v.z = randomValue(seed);
return v;
}
#line 1107
float3 randomTriple(float2 coords) {
#line 1116
uint seed = getPixelIndex(coords,int2(1920,1018));
return randomTriple(coords,seed);
#line 1119
}
#line 1121
float4 getRayColor(float2 coords) {
return tex2Dlod(rayColorSampler,float4((coords).xy,0,0));
}
#line 1127
float2 getPreviousCoords(float2 coords) {
#line 1135
float2 mv = tex2Dlod(sTexMotionVectorsSampler,float4((coords).xy,0,0)).xy;
return coords+mv;
#line 1138
}
#line 1140
float roughnessPass(float2 coords,float refDepth) {
#line 1142
float3 refColor = saturate(tex2Dlod(ReShade::BackBuffer,float4((coords).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
#line 1144
float roughness = 0.0;
float ws = 0;
#line 1147
float3 previousX = refColor;
float3 previousY = refColor;
#line 1150
[loop]
for(int d = 1;d<=iRoughnessRadius;d++) {
float w = 1.0/safePow(d,0.5);
#line 1154
float3 color = saturate(tex2Dlod(ReShade::BackBuffer,float4((float2(coords.x+ReShade::GetPixelSize().x*d,coords.y)).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
float3 diff = abs(previousX-color);
roughness += max(max(diff.x,diff.y),diff.z)*w;
ws += w;
previousX = color;
#line 1160
color = saturate(tex2Dlod(ReShade::BackBuffer,float4((float2(coords.x,coords.y+ReShade::GetPixelSize().y*d)).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
diff = abs(previousY-color);
roughness += max(max(diff.x,diff.y),diff.z)*w;
ws += w;
previousY = color;
}
#line 1167
previousX = refColor;
previousY = refColor;
#line 1170
[loop]
for(int d = 1;d<=iRoughnessRadius;d++) {
float w = 1.0/safePow(d,0.5);
#line 1174
float3 color = saturate(tex2Dlod(ReShade::BackBuffer,float4((float2(coords.x-ReShade::GetPixelSize().x*d,coords.y)).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
float3 diff = abs(previousX-color);
roughness += max(max(diff.x,diff.y),diff.z)*w;
ws += w;
previousX = color;
#line 1180
color = saturate(tex2Dlod(ReShade::BackBuffer,float4((float2(coords.x,coords.y-ReShade::GetPixelSize().y*d)).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
diff = abs(previousY-color);
roughness += max(max(diff.x,diff.y),diff.z)*w;
ws += w;
previousY = color;
}
#line 1188
roughness *= 4.0/iRoughnessRadius;
#line 1190
float refB = getBrightness(refColor);
roughness *= safePow(refB,0.5);
roughness *= safePow(1.0-refB,2.0);
#line 1194
roughness *= 0.5+refDepth*2;
#line 1196
return roughness;
}
#line 1199
float thicknessPass(float2 coords, float refDepth,out float sky) {
#line 1201
if(isSky(refDepth)) {
sky = 0;
return 1000;
}
#line 1206
int iThicknessRadius = 4;
#line 1208
float2 thickness = 0;
float previousXdepth = refDepth;
float previousYdepth = refDepth;
float depthLimit = refDepth*0.015;
float depth;
float2 currentCoords;
#line 1215
float2 orientation = normalize(randomCouple(coords)-0.5);
#line 1217
bool validPos = true;
bool validNeg = true;
sky = 1.0;
#line 1221
[loop]
for(int d=1;d<=iThicknessRadius;d++) {
float2 step = orientation*ReShade::GetPixelSize()*d;
#line 1225
if(validPos) {
currentCoords = coords+step;
depth = getDepth(currentCoords).x;
if(isSky(depth)) {
sky = min(sky,float(d)/iThicknessRadius);
}
if(depth-previousXdepth<=depthLimit) {
thickness.x = d;
previousXdepth = depth;
} else {
validPos = false;
}
}
#line 1239
if(validNeg) {
currentCoords = coords-step;
depth = getDepth(currentCoords).x;
if(isSky(depth)) {
sky = min(sky,float(d)/iThicknessRadius);
}
if(depth-previousYdepth<=depthLimit) {
thickness.y = d;
previousYdepth = depth;
} else {
validNeg = false;
}
}
}
#line 1254
thickness /= iThicknessRadius;
#line 1257
return (thickness.x+thickness.y)*0.5;
}
#line 1260
float distanceHue(float refHue, float hue) {
if(refHue<hue) {
return min(hue-refHue,refHue+1.0-hue);
} else {
return min(refHue-hue,hue+1.0-refHue);
}
}
#line 1268
float scoreLight(float3 rgb,float3 hsv) {
return hsv.y * hsv.z;
}
#line 1272
void PS_RTFS_save(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outRTFS : SV_Target0) {
outRTFS = tex2Dlod(RTFSampler,float4((coords).xy,0,0));
}
#line 1276
void PS_MotionMask  (float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outMask : SV_Target0) {
float2 previousCoords = getPreviousCoords(coords);
#line 1279
float2 depth = getDepth(coords);
float2 previousDepth = tex2Dlod(previousDepthSampler,float4((previousCoords).xy,0,0)).xy;
float2 previousDepth2 = tex2Dlod(previousDepthSampler,float4((coords).xy,0,0)).xy;
#line 1283
float mask = 0;
if(depth.x>previousDepth.x+0.1*depth.x) mask = 1;
if(depth.x>previousDepth2.x+0.1*depth.x) mask = 1;
outMask = float4(mask,0,0,1);
}
#line 1289
void PS_RTFS(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outRTFS : SV_Target0) {
float depth = getDepth(coords).x;
#line 1292
float2 previousCoords = getPreviousCoords(coords);
#line 1294
float4 RTFS;
RTFS.x = roughnessPass(coords,depth);
RTFS.y = thicknessPass(coords,depth,RTFS.a);
#line 1298
float4 previousRTFS = tex2Dlod(previousRTFSampler,float4((previousCoords).xy,0,0));
RTFS.y = lerp(previousRTFS.y,RTFS.y,0.33);
RTFS.a = min(RTFS.a,0.1+previousRTFS.a);
#line 1302
RTFS.z = 1;
#line 1304
outRTFS = RTFS;
}
#line 1308
void PS_SavePreviousAmbientPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outAmbient : SV_Target0) {
outAmbient = tex2Dlod(ambientSampler,float4((float2(0.5,0.5)).xy,0,0));
}
#line 1314
void PS_AmbientPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outAmbient : SV_Target0) {
#line 1316
float4 previous = tex2Dlod(previousAmbientSampler,float4((float2(0.5,0.5)).xy,0,0));
bool first = false;
if(previous.a<=2.0/255.0) {
previous = 1;
first = true;
}
#line 1323
float b = max(max(previous.rgb.x,previous.rgb.y),previous.rgb.z);
#line 1326
float3 result = 1.0;
float bestB = max(max(previous.rgb.x,previous.rgb.y),previous.rgb.z);
#line 1329
float2 currentCoords = 0;
float2 bestCoords = float2(0.5,0.5);
#line 1332
float2 size = int2(1920,1018);
float stepSize = 1920/16.0;
float2 numSteps = size/(stepSize+1);
#line 1336
float avgBrightness = 0;
int count = 0;
#line 1339
float2 rand = randomCouple(coords);
[loop]
for(int it=0;it<=4 && stepSize>=1;it++) {
float2 stepDim = stepSize/int2(1920,1018);
[loop]
for(currentCoords.x=bestCoords.x-stepDim.x*(numSteps.x/2);currentCoords.x<=bestCoords.x+stepDim.x*(numSteps.x/2);currentCoords.x+=stepDim.x) {
[loop]
for(currentCoords.y=bestCoords.y-stepDim.y*(numSteps.y/2);currentCoords.y<=bestCoords.y+stepDim.y*(numSteps.y/2);currentCoords.y+=stepDim.y) {
float2 c = currentCoords+rand*stepDim;
float3 color = saturate(tex2Dlod(ReShade::BackBuffer,float4((c).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
b = max(max(color.x,color.y),color.z);
avgBrightness += b;
if(b>0.1 && b<bestB) {
#line 1353
bestCoords = c;
result = min(result,color);
bestB = b;
}
count += 1;
}
}
size = stepSize;
numSteps = 8;
stepSize = size.x/numSteps.x;
}
#line 1365
result = first ? result : min(previous.rgb,result);
avgBrightness /= count;
outAmbient = lerp(previous,float4(result,avgBrightness),max(fRemoveAmbientAutoAntiFlicker,0.1)*3.0/60.0);
}
#line 1370
float3 getRemovedAmbiantColor() {
if(bRemoveAmbient) {
float3 color = tex2Dlod(ambientSampler,float4((float2(0.5,0.5)).xy,0,0)).rgb;
color += color.x;
return color;
} else {
return 0;
}
}
#line 1380
float getAverageBrightness() {
return tex2Dlod(ambientSampler,float4((float2(0.5,0.5)).xy,0,0)).a;
}
#line 1384
float3 filterAmbiantLight(float3 sourceColor) {
float3 color = sourceColor;
if(bRemoveAmbient) {
float3 colorHSV = RGBtoHSV(color);
float3 removed = getRemovedAmbiantColor();
float3 removedHSV = RGBtoHSV(removed);
float3 removedTint = removed - min(min(removed.x,removed.y),removed.z);
float3 sourceTint = color - min(min(color.x,color.y),color.z);
#line 1393
float hueDist = max(max(abs(removedTint-sourceTint).x,abs(removedTint-sourceTint).y),abs(removedTint-sourceTint).z);
#line 1395
float removal = saturate(1.0-hueDist*saturate(colorHSV.y+colorHSV.z));
color -= removed*(1.0-hueDist)*fSourceAmbientIntensity*0.333*(1.0-colorHSV.z);
color = saturate(color);
}
return color;
}
#line 1420
float4 mulByA(float4 v) {
v.rgb *= v.a;
return v;
}
#line 1426
float4 computeNormal(float3 wpCenter,float3 wpNorth,float3 wpEast) {
return float4(normalize(cross(wpCenter - wpNorth, wpCenter - wpEast)),1.0);
}
#line 1430
float4 computeNormal(float2 coords,float3 offset,bool ignoreRoughness,bool reverse) {
float3 posCenter = getWorldPositionForNormal(coords,ignoreRoughness);
float3 posNorth  = getWorldPositionForNormal(coords - (reverse?-1:1)*offset.zy,ignoreRoughness);
float3 posEast   = getWorldPositionForNormal(coords + (reverse?-1:1)*offset.xz,ignoreRoughness);
#line 1435
float4 r = computeNormal(posCenter,posNorth,posEast);
float mD = max(abs(posCenter.z-posNorth.z),abs(posCenter.z-posEast.z));
if(mD>16) r.a = 0;
return r;
}
#line 1442
void PS_NormalPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outNormal : SV_Target0, out float4 outDepth : SV_Target1) {
#line 1444
float3 offset = float3(ReShade::GetPixelSize(), 0.0);
#line 1446
float4 normal = computeNormal(coords,offset,false,false);
if(normal.a==0) {
normal = computeNormal(coords,offset,false,true);
}
#line 1451
if(bSmoothNormals) {
float3 offset2 = offset * 7.5*(1.0-getDepth(coords).x);
float4 normalTop = computeNormal(coords-offset2.zy,offset,true,false);
float4 normalBottom = computeNormal(coords+offset2.zy,offset,true,false);
float4 normalLeft = computeNormal(coords-offset2.xz,offset,true,false);
float4 normalRight = computeNormal(coords+offset2.xz,offset,true,false);
#line 1458
normalTop.a *= smoothstep(1,0,distance(normal.xyz,normalTop.xyz)*1.5)*2;
normalBottom.a *= smoothstep(1,0,distance(normal.xyz,normalBottom.xyz)*1.5)*2;
normalLeft.a *= smoothstep(1,0,distance(normal.xyz,normalLeft.xyz)*1.5)*2;
normalRight.a *= smoothstep(1,0,distance(normal.xyz,normalRight.xyz)*1.5)*2;
#line 1463
float4 normal2 =
mulByA(normal)
+mulByA(normalTop)
+mulByA(normalBottom)
+mulByA(normalLeft)
+mulByA(normalRight)
;
if(normal2.a>0) {
normal2.xyz /= normal2.a;
normal.xyz = normalize(normal2.xyz);
}
#line 1475
}
#line 1477
outNormal = float4(normal.xyz/2.0+0.5,1.0);
outDepth = getDepth(coords);
#line 1480
}
#line 1483
float3 rampColor(float3 color) {
float3 okl = RGBtoOKL(color);
float b = okl.x;
float originalB = b;
#line 1488
if(iGIRayColorMode==1) { 
b *= smoothstep(fGIRayColorMinBrightness,1.0,b);
} else if(iGIRayColorMode==2) { 
b *= saturate(b-fGIRayColorMinBrightness)/(1.0-fGIRayColorMinBrightness);
} else if(iGIRayColorMode==3) { 
b *= safePow(saturate(b-fGIRayColorMinBrightness)/(1.0-fGIRayColorMinBrightness),2.2);
}
#line 1496
okl.x = originalB>0 ? okl.x * b / originalB : 0;
return OKLtoRGB(okl);
}
#line 1500
void PS_RayColorPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0) {
#line 1504
float hueLimit = 0.1;
#line 1506
float2 previousCoords = getPreviousCoords(coords);
#line 1508
float3 refColor = saturate(tex2Dlod(ReShade::BackBuffer,float4((coords).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
if(fGIBounce>0.0) {
refColor = lerp(refColor,tex2Dlod(resultSampler,float4((previousCoords).xy,0,0)).rgb,fGIBounce);
}
#line 1513
float depth = getDepth(coords).x;
if(isSky(depth)) {
outColor = float4(refColor*fSkyColor,1);
return;
}
#line 1519
float3 refHSV = RGBtoHSV(refColor);
#line 1521
int lod = 1;
float3 tempHSV = refHSV;
while((1.0-tempHSV.y)*tempHSV.z>0.7 && lod<=5) {
tempHSV = RGBtoHSV(tex2Dlod(resultSampler,float4((previousCoords).xy,0,lod)).rgb);
#line 1529
lod ++;
}
refHSV.x = tempHSV.x;
refHSV.yz = max(refHSV.yz,tempHSV.yz);
refColor = HSVtoRGB(refHSV);
#line 1536
if(bRemoveAmbient) {
refColor = filterAmbiantLight(refColor);
refHSV = RGBtoHSV(refColor);
}
#line 1541
if(fSaturationBoost>0 && refHSV.z*refHSV.y>0.1) {
refHSV.y = lerp(refHSV.y,saturate(refHSV.y+fSaturationBoost),refHSV.y);
refColor = HSVtoRGB(refHSV);
}
#line 1546
if(fGIBounce>0.0) {
float3 previousColor = tex2Dlod(giAccuSampler,float4((previousCoords).xy,0,0)).rgb;
float b = getBrightness(refColor);
refColor = saturate(refColor+previousColor*fGIBounce*(1.0-b)*(0.5+b));
}
#line 1552
float3 result = rampColor(refColor);
#line 1554
if(fGIDarkAmplify>0) {
float3 okl = RGBtoOKL(result);
float avgB = getAverageBrightness();
okl.x = saturate(okl.x+fGIDarkAmplify*(1.0-okl.x));
result = OKLtoRGB(okl);
}
#line 1561
if(getBrightness(result)<fGIRayColorMinBrightness) {
result = 0;
}
#line 1565
outColor = float4(result,1.0);
#line 1567
}
#line 1569
bool isSaturated(float2 coords) {
return coords.x>=0 && coords.x<=1 && coords.y>=0 && coords.y<=1;
}
#line 1617
int crossing(float deltaZbefore, float deltaZ) {
if(deltaZ<=0 && deltaZbefore>0) return -1;
if(deltaZ>=0 && deltaZbefore<0) return 1;
return  0;
}
#line 1623
bool hit(float3 currentWp, float3 screenWp, float4 drtf,float3 behindWp) {
if(fGIAvoidThin>0 && drtf.z<drtf.x*100*fGIAvoidThin) return false;
if(currentWp.z>=screenWp.z) {
if(currentWp.z<=behindWp.z+distance(screenWp,behindWp)*2.0) return true;
if(currentWp.z<=screenWp.z+2*abs(behindWp.z-screenWp.z)) return true;
if(currentWp.z<=screenWp.z+drtf.z*saturate(drtf.x*2)) return true;
}
return false;
}
#line 1634
float3 getDebugLightWp() {
return getWorldPosition(fDebugLightPosition.xy,bDebugLightZAtDepth ? getDepth(fDebugLightPosition.xy).x*0.99 : fDebugLightPosition.z);
}
#line 1639
RTOUT traceGI(inout float2 rand, float3 refWp,float3 incrementVector) {
#line 1641
RTOUT result;
result.status =  -1.0;
#line 1644
float3 currentWp = refWp;
#line 1646
incrementVector = normalize(incrementVector)*(0.05+abs(rand.x)*0.05);
#line 1648
currentWp += incrementVector;
float3 screenCoords = getScreenPosition(currentWp);
result.drtf = getDRTF(screenCoords.xy);
float3 screenWp = getWorldPosition(screenCoords.xy,result.drtf.x);
#line 1654
if(hit(currentWp, screenWp, result.drtf,0)) {
result.wp = screenWp;
result.status =  -2.0;
return result;
}
#line 1662
float3 refVector = normalize(incrementVector);
incrementVector = refVector;
#line 1665
int stepBehind = 0;
bool behind = false;
float3 behindWp = 0;
float3 previousScreenWp = refWp;
#line 1670
int step = -1;
incrementVector *= 0.1;
#line 1673
float maxDist = sqrt(1920*1920+1018*1018);
int maxSteps = 16*(iRTPrecision>1?32:1);
#line 1676
result.dist = 0;
#line 1678
while(step<maxSteps*2 && result.dist<maxDist) {
step++;
if(step>maxSteps) incrementVector *= 1.05;
#line 1682
result.dist += length(incrementVector);
currentWp += incrementVector;
screenCoords = getScreenPosition(currentWp);
#line 1686
if(!inScreen(screenCoords)) break;
#line 1688
result.drtf = getDRTF(screenCoords.xy);
screenWp = getWorldPosition(screenCoords.xy,result.drtf.x);
bool previousBehind = behind;
behind = currentWp.z>screenWp.z;
#line 1693
if(behind) {
stepBehind++;
if(stepBehind==1) {
behindWp = screenWp;
}
}
#line 1700
if(isSky(result.drtf.x)) {
result.status =  -0.5;
result.wp = currentWp;
}
#line 1705
bool isHit = hit(currentWp, screenWp, result.drtf,behindWp);
#line 1707
if(isHit) {
bool isHitBehind = stepBehind>1 || (currentWp.z>=screenWp.z+50 && result.drtf.z>=50);
result.status = isHitBehind ? 0.5 :  1.0;
result.wp = result.status==0.5 ? behindWp : currentWp;
return result;
}
#line 1715
if(iRTPrecision==1) {
rand = nextRand(rand);
float l = 1.00+result.drtf.x+rand.y;
incrementVector *= l;
} else
#line 1721
if(step<=maxSteps) {
float2 nextWp = float2(
refVector.x>0 ? ceil(currentWp.x+1) : floor(currentWp.x-1),
refVector.y>0 ? ceil(currentWp.y+1) : floor(currentWp.y-1)
);
#line 1727
float2 dist = abs(nextWp.xy-currentWp.xy);
#line 1730
float minDist = min(dist.x, dist.y);
incrementVector = refVector*max(iRTPrecision<3?pow(float(step)/maxSteps,2)*1000:0,minDist*(1.0+result.drtf.x*2.5));
}
#line 1735
if(!behind) {
stepBehind = 0;
}
#line 1739
previousScreenWp = screenWp;
#line 1741
}
#line 1743
return result;
}
#line 1746
RTOUT traceGItarget(inout float2 rand, float3 refWp,float3 incrementVector,float3 targetWp) {
#line 1748
RTOUT result;
result.status =  -1.0;
#line 1751
float3 currentWp = refWp;
#line 1753
incrementVector = normalize(incrementVector)*(0.05+abs(rand.x)*0.05);
#line 1755
currentWp += incrementVector;
float3 screenCoords = getScreenPosition(currentWp);
result.drtf = getDRTF(screenCoords.xy);
float3 screenWp = getWorldPosition(screenCoords.xy,result.drtf.x);
#line 1761
if(hit(currentWp, screenWp, result.drtf,0)) {
result.wp = screenWp;
result.status =  -2.0;
return result;
}
#line 1769
float3 refVector = normalize(incrementVector);
incrementVector = refVector;
#line 1772
int stepBehind = 0;
bool behind = false;
float3 behindWp = 0;
float3 previousScreenWp = refWp;
#line 1777
int step = -1;
incrementVector *= 0.1;
#line 1780
float maxDist = distance(currentWp,targetWp);
int maxSteps = 16*(iRTPrecision>1?32:1);
#line 1783
result.dist = 0;
#line 1785
while(step<maxSteps*2 && result.dist<maxDist) {
step++;
if(step>maxSteps) incrementVector *= 1.05;
#line 1789
result.dist += length(incrementVector);
currentWp += incrementVector;
screenCoords = getScreenPosition(currentWp);
#line 1793
if(!inScreen(screenCoords)) break;
#line 1795
result.drtf = getDRTF(screenCoords.xy);
screenWp = getWorldPosition(screenCoords.xy,result.drtf.x);
bool previousBehind = behind;
behind = currentWp.z>screenWp.z;
#line 1800
if(behind) {
stepBehind++;
if(stepBehind==1) {
behindWp = screenWp;
}
}
#line 1807
if(isSky(result.drtf.x)) {
result.status =  -0.5;
result.wp = currentWp;
}
#line 1812
bool isHit = hit(currentWp, screenWp, result.drtf,behindWp);
#line 1814
if(isHit) {
bool isHitBehind = stepBehind>1 || (currentWp.z>=screenWp.z+50 && result.drtf.z>=50);
result.status = isHitBehind ? 0.5 : (result.dist>=maxDist-2 ? 2.0 : 1.0);
result.wp = result.status==0.5 ? behindWp : currentWp;
return result;
}
#line 1822
if(iRTPrecision==1) {
rand = nextRand(rand);
float l = 1.00+result.drtf.x+rand.y;
incrementVector *= l;
} else
#line 1828
if(step<=maxSteps) {
float2 nextWp = float2(
refVector.x>0 ? ceil(currentWp.x+1) : floor(currentWp.x-1),
refVector.y>0 ? ceil(currentWp.y+1) : floor(currentWp.y-1)
);
#line 1834
float2 dist = abs(nextWp.xy-currentWp.xy);
#line 1837
float minDist = min(dist.x, dist.y);
incrementVector = refVector*max(iRTPrecision<3?pow(float(step)/maxSteps,2)*1000:0,minDist*(1.0+result.drtf.x*2.5));
}
#line 1842
if(!behind) {
stepBehind = 0;
}
#line 1846
previousScreenWp = screenWp;
#line 1848
}
#line 1850
result.status = 2.0;
result.wp = targetWp;
#line 1853
return result;
}
#line 1858
float weightLight(float3 color) {
#line 1860
float3 hsv = RGBtoHSV(color);
return (1+hsv.y)*hsv.z*0.5;
#line 1865
}
#line 1867
void handleHit(
in bool doTargetLight, in float3 targetColor, in RTOUT hitPosition,
inout float3 sky, inout float4 bestRay, inout float sumAO, inout int hits, inout float3 mergedGiColor,
inout float missRays
) {
if(hitPosition.status <=  -1.0) {
return;
}
#line 1876
float3 screenCoords = getScreenPosition(hitPosition.wp);
#line 1878
if(!inScreen(screenCoords.xy)) {
return;
}
#line 1883
if(hitPosition.status== -0.5 || isSky(screenCoords.z)) {
float3 giColor = doTargetLight ? targetColor.rgb : getRayColor(screenCoords.xy).rgb;
float b = getBrightness(giColor);
sky = max(sky,giColor.rgb);
#line 1888
hits++;
sumAO+=1;
#line 1891
return;
}
#line 1895
float4 DRTF = getDRTF(screenCoords.xy);
if((hitPosition.dist>0 || doTargetLight) && (fGIAvoidThin==0 || DRTF.z>DRTF.x*100*fGIAvoidThin)) {
float ao = 2.0*hitPosition.dist/(iAODistance*screenCoords.z*getDepthMultiplier());
sumAO += saturate(ao);
hits+=1.0;
}
#line 1902
if(hitPosition.status==0.5) {
#line 1904
if(doTargetLight) {
float3 giColor = getRayColor(screenCoords.xy).rgb;
#line 1907
float hitB = getBrightness(giColor.rgb);
float targetB = getBrightness(targetColor.rgb);
if(hitB<targetB && targetB>0.3) {
missRays += targetB*2;
}
hitB = weightLight(giColor.rgb);
if(hitB>bestRay.a) {
bestRay = float4(screenCoords,hitB);
}
giColor = 0;
}
return;
#line 1920
}
#line 1923
float3 giColor;
if(doTargetLight) {
if(hitPosition.status==2.0) {
giColor = targetColor.rgb;
#line 1928
}
#line 1930
else if(!bDebugLight || !bDebugLightOnly) {
#line 1934
giColor = getRayColor(screenCoords.xy).rgb;
#line 1936
float hitB = getBrightness(giColor.rgb);
float targetB = getBrightness(targetColor.rgb);
if(hitB<targetB && targetB>0.3) {
missRays += targetB*2;
}
hitB = weightLight(giColor.rgb);
if(hitB>bestRay.a) {
bestRay = float4(screenCoords,hitB);
}
}
} else {
giColor = getRayColor(screenCoords.xy).rgb;
}
float b = weightLight(giColor.rgb);
if(b>=bestRay.a && !doTargetLight) {
bestRay = float4(screenCoords,b);
}
#line 1955
if(doTargetLight) {
#line 1957
giColor.rgb = RGBtoOKL(giColor.rgb);
giColor.x /= max(1.0,pow(fGIDistanceAttenuation,8.0)*30*hitPosition.dist);
giColor.rgb = OKLtoRGB(giColor.rgb);
#line 1963
}
#line 1965
mergedGiColor.rgb = max(mergedGiColor.rgb,giColor.rgb);
#line 1967
}
#line 1969
void PS_GILightPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outGI : SV_Target0, out float4 outBestRay : SV_Target1) {
#line 1971
if(!isScaledProcessed(coords)) {
outGI = float4(0,0,0,1);
outBestRay = float4(0,0,0,1);
return;
}
#line 1977
coords = upCoords(coords);
#line 1979
float depth = getDepth(coords).x;
if(isSky(depth)) {
outGI = float4(0,0,0,1);
outBestRay = float4(coords,depth,fSkyColor);
return;
}
#line 1987
float3 refWp = getWorldPosition(coords,depth);
float3 refNormal = getNormal(coords);
#line 1990
float4 bestRay = 0;
#line 1992
float3 sky = 0.0;
float3 mergedGiColor = 0.0;
#line 1995
float sumAO = 0;
float hits = 0;
float missRays = 0;
#line 2002
uint seed = getPixelIndex(coords,int2(1920,1018));
float3 rand = randomTriple(coords,seed);
#line 2009
if(bDebugLight) {
float3 targetWp = getDebugLightWp() + rand*iDebugLightSize*0.9;
float3 lightVector = normalize(targetWp-refWp);
float3 targetColor = fDebugLightColor;
#line 2014
RTOUT hitPosition = traceGItarget(rand.xy,refWp,lightVector,targetWp);
if(hitPosition.status!= -2.0) {
handleHit(
true, targetColor,hitPosition,
sky, bestRay, sumAO, hits, mergedGiColor,
missRays
);
}
#line 2023
if(bDebugLightOnly) {
outBestRay = bestRay;
outGI = float4(max(mergedGiColor,sky),hits>0 ? saturate(sumAO/hits) : 1.0);
return;
}
}
#line 2032
int maxRays = iRTMaxRays;
#line 2034
[loop]
for(int rays=0;rays<maxRays;rays++) {
#line 2037
rand = nextRand(rand);
rand = normalize(rand-0.5);
#line 2040
float3 lightVector = rand;
lightVector += cross(rand,refNormal);
lightVector += refNormal;
#line 2044
RTOUT hitPosition = traceGI(rand.xy,refWp,lightVector);
#line 2046
if(hitPosition.status== -2.0) {
continue;
}
#line 2051
handleHit(
false, 0,hitPosition,
sky, bestRay, sumAO, hits, mergedGiColor,
missRays
);
#line 2057
}
#line 2060
outBestRay = bestRay;
outGI = float4(max(mergedGiColor,sky),hits>0 ? saturate(sumAO/hits) : 1.0);
}
#line 2065
float getBorderProximity(float2 coords) {
float2 borderDists = min(coords,1.0-coords)*int2(1920,1018);
float borderDist = min(borderDists.x,borderDists.y);
return borderDist<=iHudBorderProtectionRadius ? float(iHudBorderProtectionRadius-borderDist)/iHudBorderProtectionRadius : 0;
}
#line 2072
void PS_GIFill(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outBestRay : SV_Target) {
#line 2074
if(!isScaledProcessed(coords)) {
outBestRay = float4(0,0,0,1);
return;
}
#line 2079
float2 pixelSize = ReShade::GetPixelSize();
float4 bestRay = tex2Dlod(bestRaySampler,float4((coords).xy,0,0));
#line 2085
uint seed = getPixelIndex(coords,int2(1920,1018));
float3 rand = randomTriple(coords,seed);
#line 2089
int2 delta;
int2 res = floor(int2(1920,1018)/1);
int maxDist = 4;
[loop]
for(delta.x=-maxDist;delta.x<=maxDist;delta.x+=1) {
[loop]
for(delta.y=-maxDist;delta.y<=maxDist;delta.y+=1) {
float d = length(delta);
if(d>maxDist) continue;
#line 2099
float2 currentCoords = coords + delta*pixelSize*d;
rand = nextRand(rand);
currentCoords += (rand.xy-0.5)*0.1*fGIRenderScale*d;
if(!isScaledProcessed(currentCoords)) continue;
#line 2104
float4 ray = tex2Dlod(bestRaySampler,float4((currentCoords).xy,0,0));
if(ray.a>=bestRay.a) {
bestRay = ray;
}
}
}
#line 2111
outBestRay = bestRay;
#line 2113
}
#line 2115
void PS_GILightPass2(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outGI : SV_Target0) {
#line 2117
if(!isScaledProcessed(coords)) {
outGI = float4(0,0,0,1);
return;
}
coords = upCoords(coords);
#line 2123
float depth = getDepth(coords).x;
if(isSky(depth)) {
outGI = float4(0,0,0,1);
return;
}
#line 2131
float3 refWp = getWorldPosition(coords,depth);
float3 refNormal = getNormal(coords);
#line 2134
float3 mergedGiColor = 0;
#line 2136
float hits = 0;
float sumAO = 0;
#line 2139
float3 sky = 0.0;
float4 bestRay;
#line 2142
float missRays = 0;
#line 2148
uint seed = getPixelIndex(coords,int2(1920,1018));
float3 rand = randomTriple(coords,seed);
#line 2151
float2 pixelSize = ReShade::GetPixelSize();
#line 2154
if(!(bDebugLight && bDebugLightOnly)) {
#line 2157
bestRay = tex2Dlod(bestRayFillSampler,float4((coords*fGIRenderScale).xy,0,0));
bestRay.a = 0;
#line 2160
float3 targetCoords = bestRay.xyz;
#line 2162
targetCoords.xy +=  2*pixelSize*rand.yz;
targetCoords.z = getDepth(targetCoords.xy).x;
#line 2166
targetCoords.z = getDepth(targetCoords.xy).x;
#line 2168
float3 targetWp = getWorldPosition(targetCoords.xy,targetCoords.z);
targetWp += rand*8*fHudBorderProtectionStrength*getBorderProximity(targetCoords.xy);
float3 lightVector = normalize(targetWp-refWp);
#line 2172
float d = dot(refNormal,lightVector);
if(d>0) {
RTOUT hitPosition = traceGItarget(rand.xy,refWp,lightVector,targetWp);
if(hitPosition.status!= -2.0) {
float3 targetColor = getRayColor(targetCoords.xy).rgb;
handleHit(
true, targetColor, hitPosition,
sky, bestRay, sumAO, hits, mergedGiColor,
missRays
);
}
} else {
hits++;
}
#line 2190
float2 step = 1.0/(1+iMemRadius);
step.y *= float(1920)/1018;
#line 2193
float2 searchCoords = 0;
#line 2195
float currentIndex = 0;
#line 2197
[loop]
for(searchCoords.y=step.y*0.5;searchCoords.y<=1.0-step.y*0.5;searchCoords.y+=step.y) {
[loop]
for(searchCoords.x=step.x*0.5;searchCoords.x<=1.0-step.x*0.5;searchCoords.x+=step.x) {
#line 2202
rand = nextRand(rand);
#line 2204
float2 currentCoords = searchCoords+step*rand.xy;
#line 2206
if(!inScreen(currentCoords)) continue;
#line 2208
currentCoords = tex2Dlod(bestRayFillSampler,float4((currentCoords*fGIRenderScale).xy,0,0)).xy;
#line 2210
float3 targetCoords = float3(currentCoords,getDepth(currentCoords).x);
#line 2212
float3 targetWp = getWorldPosition(targetCoords.xy,targetCoords.z);
#line 2214
float3 lightVector = normalize(targetWp-refWp);
#line 2216
{
float d = dot(refNormal,lightVector);
if(d<0) {
hits++;
continue;
}
float3 targetNormal = getNormal(targetCoords.xy);
if(!isSky(targetCoords.z) && length(targetNormal+lightVector)>1.4) {
continue;
}
}
#line 2228
RTOUT hitPosition = traceGItarget(rand.xy,refWp,lightVector,targetWp);
if(hitPosition.status!= -2.0) {
float3 targetColor = getRayColor(targetCoords.xy).rgb;
#line 2232
handleHit(
true, targetColor, hitPosition,
sky, bestRay, sumAO, hits, mergedGiColor,
missRays
);
}
#line 2241
}
#line 2244
}
#line 2246
}
#line 2250
float4 firstPassFrame = tex2Dlod(giPassSampler,float4((coords*fGIRenderScale).xy,0,0));
mergedGiColor.rgb = max(mergedGiColor.rgb,firstPassFrame.rgb);
float firstAO = firstPassFrame.a;
#line 2254
sumAO += firstAO*iRTMaxRays;
hits += iRTMaxRays;
float ao = hits>0 ? sumAO/hits : 1;
#line 2259
if(missRays>0) {
ao /= missRays;
}
#line 2263
mergedGiColor.rgb = max(mergedGiColor.rgb,sky);
#line 2265
float3 fpOKL = RGBtoOKL(firstPassFrame.rgb);
float r = 1.0-smoothstep(0,1,fpOKL.x);
mergedGiColor.rgb = saturate(mergedGiColor.rgb*r+firstPassFrame.rgb);
#line 2270
outGI = float4(mergedGiColor.rgb,ao);
#line 2273
}
#line 2276
float3 computeSSR(float2 coords,float brightness) {
float4 ssr = tex2Dlod(ssrAccuSampler,float4((coords).xy,0,1));
#line 2279
float roughness = getRTF(coords).x;
#line 2281
float rCoef = lerp(1.0,saturate(1.0-roughness*10),fSSRMergingRoughness);
#line 2283
float coef = fSSRMerging*(1.0-brightness)*rCoef;
#line 2285
if(fSSRMergingOrientation>0) {
float3 normal = getNormal(coords);
float3 preferedOrientation = normalize(float3(0,-1,-0.5));
float oCoef = saturate(dot(normal,preferedOrientation));
coef *= (1.0-fSSRMergingOrientation)+lerp(1,oCoef,fSSRMergingOrientation)*fSSRMergingOrientation;
}
#line 2292
return ssr.rgb*coef;
#line 2294
}
#line 2296
RTOUT traceSSR(inout float2 rand, float3 refWp,float3 incrementVector) {
#line 2298
RTOUT result;
result.status =  -1.0;
#line 2301
float3 currentWp = refWp;
#line 2303
incrementVector = normalize(incrementVector)*0.1;
#line 2305
currentWp += incrementVector;
float3 screenCoords = getScreenPosition(currentWp);
#line 2308
result.drtf = getDRTF(screenCoords.xy);
float3 screenWp = getWorldPosition(screenCoords.xy,result.drtf.x);
#line 2311
bool isHit = hit(currentWp, screenWp, result.drtf,0);
#line 2313
if(isHit) {
float3 hitNormal = getNormal(screenCoords.xy);
incrementVector = reflect(incrementVector,hitNormal);
isHit = false;
}
#line 2319
float3 refVector = normalize(incrementVector);
incrementVector = refVector;
#line 2322
int stepBehind = 0;
bool behind = false;
float3 behindWp = 0;
#line 2326
float3 beforeBehind = 0;
float3 previousWp = refWp;
#line 2330
int step = -1;
incrementVector *= 0.1;
#line 2333
float maxDist = sqrt(1920*1920+1018*1018);
int maxSteps = 256;
#line 2336
float dist = 0;
#line 2338
while(step<maxSteps*2 && dist<maxDist) {
step++;
if(step>maxSteps) incrementVector *= 1.05;
#line 2342
dist += length(incrementVector);
currentWp += incrementVector;
screenCoords = getScreenPosition(currentWp);
#line 2346
if(!inScreen(screenCoords)) break;
#line 2349
result.drtf = getDRTF(screenCoords.xy);
screenWp = getWorldPosition(screenCoords.xy,result.drtf.x);
behind = currentWp.z>screenWp.z;
#line 2353
if(behind) {
stepBehind++;
if(stepBehind==1) {
behindWp = screenWp;
#line 2358
beforeBehind = previousWp;
#line 2360
}
}
#line 2363
if(isSky(result.drtf.x)) {
result.status =  -0.5;
result.wp = currentWp;
}
#line 2368
isHit = hit(currentWp, screenWp, result.drtf,behindWp);
bool isHitBehind = isHit && (stepBehind>1 || (currentWp.z>=screenWp.z+50 && result.drtf.z>=50));
#line 2371
if(isHit) {
result.status = isHitBehind ? 0.5 : 1.0;
#line 2374
result.wp = result.status==0.5 ? beforeBehind : currentWp;
#line 2378
if(result.drtf.y>=0.1) result.status = 1.0;
return result;
}
#line 2383
if(iRTPrecision==1) {
rand = nextRand(rand);
if(step<=maxSteps) {
incrementVector = refVector*(1.0+rand.x);
}
} else
#line 2390
if(step<=maxSteps) {
float2 nextWp = float2(
refVector.x>0 ? ceil(currentWp.x+1) : floor(currentWp.x-1),
refVector.y>0 ? ceil(currentWp.y+1) : floor(currentWp.y-1)
);
#line 2396
float2 dist = abs(nextWp.xy-currentWp.xy);
#line 2399
float minDist = min(dist.x, dist.y);
incrementVector = refVector*max(0.01,minDist*(1.0+result.drtf.x*2.5));
}
#line 2404
if(!behind) {
stepBehind = 0;
}
#line 2409
previousWp = currentWp;
#line 2411
}
#line 2413
if(incrementVector.z>0 && inScreen(getScreenPosition(currentWp).xy)) {
result.status = 1.0;
result.wp = currentWp;
}
#line 2418
return result;
}
#line 2421
void PS_SSRLightPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0) {
if(!bSSR || fSSRMerging==0.0) {
outColor = 0.0;
return;
}
#line 2427
if(coords.x>fSSRRenderScale || coords.y>fSSRRenderScale) {
outColor = float4(0,0,0,1);
return;
}
#line 2433
coords = upCoordsSSR(coords);
#line 2435
int subWidth = min(4,ceil(1.0/fSSRRenderScale));
int subMax = subWidth*subWidth;
int subCoordsIndex = framecount%subMax;
int2 delta = 0;
#line 2440
float2 depth = getDepth(coords);
#line 2442
if(isSky(depth.x)) {
outColor = 0.0;
} else {
#line 2446
float4 result = 0;
#line 2448
float3 targetWp = getWorldPosition(coords,depth.x);
float3 targetNormal = getNormal(coords);
#line 2451
float3 lightVector = normalize(reflect(targetWp,targetNormal));
#line 2453
float2 rand = (coords*3.14159265359)%1;
RTOUT hitPosition = traceSSR(rand,targetWp,lightVector);
#line 2456
float3 screenPosition = getScreenPosition(hitPosition.wp.xyz);
#line 2458
if(hitPosition.status>0.5) {
float2 previousCoords = getPreviousCoords(screenPosition.xy);
float3 hitNormal = getNormal(screenPosition.xy);
if(distance(hitNormal,targetNormal)>=0.2) {
result = float4(tex2Dlod(resultSampler,float4((previousCoords).xy,0,0)).rgb,1);
}
}
#line 2466
outColor = result;
}
#line 2470
}
#line 2475
float gaussian(float x, float sigma) {
return exp(-(x * x) / (2.0 * sigma * sigma));
}
#line 2479
float calculateDepthWeight(float centerDepth, float sampleDepth, float sigma) {
float diff = abs(centerDepth - sampleDepth);
return gaussian(diff, sigma);
}
#line 2487
void smoothWeight(
float dist,
float2 refDepth, float motionMask, float3 refNormal, float4 refColor, float avgB,
sampler sourceGISampler,float2 currentCoords,float2 currentScaledCoords,
inout int maxSamples, inout float2 weightSum, inout float4 giAo, inout float3 previousResultGI,
bool firstPass
) {
float2 depth = getDepth(currentScaledCoords);
if(isSky(depth.x)) {
#line 2499
depth = tex2Dlod(previousDepthSampler,float4((currentScaledCoords).xy,0,0)).x;
if(isSky(depth.x)) {
return;
}
#line 2504
}
#line 2506
if(depth.y != refDepth.y) {
return;
}
#line 2511
float2 weight = 1.0;
#line 2513
float nw = 0;
#line 2515
float d;
#line 2517
if(motionMask<1) {
float3 normal = getNormal(currentScaledCoords);
d = dot(normal,refNormal);
nw = saturate(d);
nw = pow(nw,3.0/fGIRenderScale);
weight.x *= nw;
weight.y *= saturate(d);
} else {
nw = 1;
}
#line 2529
if(motionMask<1) {
float diffDepth = abs(depth.x - refDepth.x);
weight *= max(0.001,1.0-100*diffDepth*saturate(1.0-refDepth*2.0));
}
#line 2535
if(weight.x>0) {
float4 curGiAo = tex2Dlod(sourceGISampler,float4((currentCoords).xy,0,0));
#line 2538
{
float diffC = max(max(abs(curGiAo.rgb-refColor.rgb).x,abs(curGiAo.rgb-refColor.rgb).y),abs(curGiAo.rgb-refColor.rgb).z);
weight.x *= 1.01-diffC;
}
#line 2544
curGiAo.rgb = RGBtoOKL(curGiAo.rgb);
#line 2547
weight.x *= avgB+pow(curGiAo.x*2,2);
#line 2549
giAo.rgb += curGiAo.rgb*weight.x;
giAo.a += curGiAo.a*weight.y;
}
#line 2553
weightSum += weight;
#line 2555
float3 result = giAo.rgb/weightSum.x;
if(abs(result.x-previousResultGI.x)>0.05) {
maxSamples = min(maxSamples+1,iSmoothSamples*2);
}
previousResultGI = result;
#line 2561
}
#line 2563
void smoothAccu(
float motionMask, float2 refDepth, float3 refWp,
inout float4 giAo, inout float2 weightSum,
float2 previousCoords, float4 previousAccu,
bool firstPass
) {
if(!firstPass && motionMask<1) {
float2 depth = tex2Dlod(previousDepthSampler,float4((previousCoords).xy,0,0)).xy;
float4 curGiAo = previousAccu;
curGiAo.rgb = RGBtoOKL(curGiAo.rgb);
curGiAo.x *= 0.95;
#line 2576
float2 weight = 1.0;
#line 2578
{
float diffDepth = abs(depth.x - refDepth.x);
weight *= max(0.001,1.0-100*diffDepth*saturate(1.0-refDepth*2.0));
}
#line 2583
if(depth.y != refDepth.y) {
weight = 0;
}
#line 2587
if(weight.x>0) {
weight.x *= pow(curGiAo.x,0.25);
weight.x *= iGIFrameAccu*0.5;
#line 2593
float3 wp = getWorldPosition(previousCoords,depth.x);
float d = distance(refWp,wp);
if(d>iAODistance*0.5) weight.y = 0;
#line 2599
float diffL = abs(curGiAo.x-(giAo.rgb/ weightSum.x).x);
weight.x *= (1.0-diffL);
#line 2603
giAo.rgb += curGiAo.rgb*weight.x;
giAo.a += curGiAo.a*weight.y;
#line 2607
}
#line 2609
weightSum += weight;
#line 2611
giAo.rgb /= weightSum.x;
giAo.rgb = OKLtoRGB(giAo.rgb);
#line 2614
} else if(weightSum.x>0) {
giAo.rgb /= weightSum.x;
giAo.rgb = OKLtoRGB(giAo.rgb);
} else {
giAo.rgb = 0;
}
#line 2621
if(weightSum.y>0) {
giAo.a /= weightSum.y;
giAo.a = lerp(giAo.a,previousAccu.a,0.5);
} else {
giAo.a = 1.0;
}
#line 2628
}
#line 2630
void smoothPass1(
sampler sourceGISampler,
float2 coords, out float4 outGI
) {
#line 2635
if(!isScaledProcessed(coords)) {
outGI = float4(0,0,0,1);
return;
}
#line 2640
float2 scaledCoords = upCoords(coords);
#line 2642
float2 refDepth = getDepth(scaledCoords);
#line 2645
if(isSky(refDepth.x)) {
outGI = float4(saturate(tex2Dlod(ReShade::BackBuffer,float4((scaledCoords).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb,1);
return;
}
#line 2650
float2 previousCoords = getPreviousCoords(scaledCoords);
float4 previousAccu = tex2Dlod(giPreviousAccuSampler,float4((previousCoords).xy,0,0));
#line 2653
float3 refNormal = getNormal(scaledCoords);
float3 refWp = getWorldPosition(scaledCoords,refDepth.x);
#line 2656
float2 weightSum;
#line 2658
float4 giAo = 0.0;
#line 2660
float2 currentCoords;
float avgB = getAverageBrightness();
#line 2665
float maxSamples = iSmoothSamples;
float3 previousResultGI = previousAccu.rgb;
#line 2668
float radius = 6;
#line 2673
uint seed = getPixelIndex(coords,int2(1920,1018));
float3 rand = randomTriple(coords,seed);
#line 2676
float motionMask = tex2Dlod(motionMaskSampler,float4((coords).xy,0,0)).x;
#line 2678
float2 delta;
[loop]
for(delta.x=-2;delta.x<=2;delta.x+=1) {
[loop]
for(delta.y=-1;delta.y<=1;delta.y+=1) {
#line 2684
float dist = length(delta);
#line 2686
currentCoords = coords+delta*ReShade::GetPixelSize().xy;
#line 2688
if(!isScaledProcessed(currentCoords)) continue;
#line 2690
float2 currentScaledCoords = upCoords(currentCoords);
#line 2692
smoothWeight(
dist,
refDepth, motionMask, refNormal, previousAccu, avgB,
sourceGISampler,currentCoords,currentScaledCoords,
maxSamples, weightSum, giAo, previousResultGI,
true
);
}
}
#line 2704
float angle = rand.x*2*3.14159265359;
#line 2706
[loop]
for(float s=15;s<maxSamples;s+=1.0) {
angle += 3.14159265359/4.0;
#line 2710
float dist = 1+5*(s/maxSamples);
currentCoords = coords+float2(cos(angle),sin(angle))*ReShade::GetPixelSize().xy*dist;
#line 2713
if(!isScaledProcessed(currentCoords)) continue;
#line 2715
float2 currentScaledCoords = upCoords(currentCoords);
#line 2717
smoothWeight(
dist,
refDepth, motionMask, refNormal, previousAccu, avgB,
sourceGISampler,currentCoords,currentScaledCoords,
maxSamples, weightSum, giAo, previousResultGI,
true
);
#line 2725
}
#line 2727
smoothAccu(
motionMask, refDepth, refWp,
giAo, weightSum,
previousCoords, previousAccu,
true
);
#line 2734
outGI = saturate(giAo);
}
#line 2737
void smoothPass2(
sampler sourceGISampler,
float2 coords, out float4 outGI
) {
#line 2742
float2 refDepth = getDepth(coords);
#line 2744
if(isSky(refDepth.x)) {
outGI = float4(saturate(tex2Dlod(ReShade::BackBuffer,float4((coords).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb,1);
return;
}
#line 2750
float2 downscaledCoords = coords*fGIRenderScale;
float2 previousCoords = getPreviousCoords(coords);
float4 previousAccu = tex2Dlod(giPreviousAccuSampler,float4((previousCoords).xy,0,0));
#line 2754
float3 refNormal = getNormal(coords);
float3 refWp = getWorldPosition(coords,refDepth.x);
#line 2757
float2 weightSum;
#line 2759
float4 giAo = 0.0;
#line 2761
float2 currentCoords;
float avgB = getAverageBrightness();
#line 2766
float maxSamples = iSmoothSamples;
float3 previousResultGI = previousAccu.rgb;
#line 2769
float radius = iSmoothRadius;
float4 bestRay = tex2Dlod(bestRaySampler,float4((downscaledCoords).xy,0,0));
float3 bestRayWp = getWorldPosition(bestRay.xy,bestRay.z);
float dist = distance(refWp,bestRayWp);
radius += (dist*0.35);
#line 2778
uint seed = getPixelIndex(coords,int2(1920,1018));
float3 rand = randomTriple(coords,seed);
#line 2781
float angle = rand.x*2*3.14159265359;
float motionMask = tex2Dlod(motionMaskSampler,float4((coords).xy,0,0)).x;
#line 2786
[loop]
for(float s=0;s<maxSamples;s+=1.0) {
if(s>0) {
angle += 3.14159265359/4.0+rand.x;
}
#line 2792
float dist = (radius)*pow(s/maxSamples,2);
currentCoords = downscaledCoords+float2(cos(angle),sin(angle))*ReShade::GetPixelSize().xy*dist;
#line 2795
if(!isScaledProcessed(currentCoords)) continue;
#line 2797
float2 currentScaledCoords = upCoords(currentCoords);
#line 2799
smoothWeight(
dist,
refDepth, motionMask, refNormal, previousAccu, avgB,
sourceGISampler,currentCoords,currentScaledCoords,
maxSamples, weightSum, giAo, previousResultGI,
false
);
#line 2807
}
#line 2809
smoothAccu(
motionMask, refDepth, refWp,
giAo, weightSum,
previousCoords, previousAccu,
false
);
#line 2816
outGI = saturate(giAo);
}
#line 2819
void PS_SmoothPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outGI : SV_Target0) {
smoothPass1(giPass2Sampler,coords,outGI);
}
#line 2823
void PS_Smooth2Pass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outGI : SV_Target0) {
smoothPass2(giSmoothPassSampler,coords,outGI);
}
#line 2827
float3 oklLerp(float3 a,float3 b, float3 r) {
return OKLtoRGB(lerp(RGBtoOKL(saturate(a)),RGBtoOKL(saturate(b)),r));
}
#line 2832
void PS_AccuPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outGI : SV_Target0, out float4 outSSR : SV_Target1) {
#line 2834
float4 giAO = tex2Dlod(giSmooth2PassSampler,float4((coords).xy,0,0));
if(max(max(giAO.rgb.x,giAO.rgb.y),giAO.rgb.z)<0.1) {
giAO = tex2Dlod(giSmooth2PassSampler,float4((coords).xy,0,2.0));
}
#line 2841
float motionMask = tex2Dlod(motionMaskSampler,float4((coords).xy,0,0)).x;
if(motionMask>0) {
giAO = tex2Dlod(giSmooth2PassSampler,float4((coords).xy,0,3));
outGI = giAO;
outSSR = bSSR ? tex2Dlod(ssrPassSampler,float4((coords*fSSRRenderScale).xy,0,0)) : 0;
return;
}
#line 2849
float2 previousCoords = getPreviousCoords(coords);
float motionDist = 1+distance(coords*int2(1920,1018),previousCoords*int2(1920,1018));
float centerDist = distance(0.5*int2(1920,1018),previousCoords*int2(1920,1018));
motionDist *= (1+centerDist*50.0/1920);
#line 2854
float2 op = 1.0/float2(iGIFrameAccu,iAOFrameAccu);
op = lerp(op,1,saturate(motionDist/256));
op = saturate(op);
#line 2858
float4 previousColorMoved = tex2Dlod(giPreviousAccuSampler,float4((previousCoords).xy,0,0));
#line 2860
float diff = max(max(abs(previousColorMoved.rgb-giAO.rgb).x,abs(previousColorMoved.rgb-giAO.rgb).y),abs(previousColorMoved.rgb-giAO.rgb).z);
if(diff>0.2) op.x = saturate(op.x*(2+(diff-0.2)/0.8));
giAO.rgb = oklLerp(previousColorMoved.rgb,giAO.rgb,op.x);
giAO.a = lerp(previousColorMoved.a,giAO.a,op.y);
#line 2866
outGI = giAO;
#line 2868
if(bSSR) {
#line 2870
float4 ssr = tex2Dlod(ssrPassSampler,float4((coords*fSSRRenderScale).xy,0,0));
float b = getBrightness(ssr.rgb);
if(b<0.1) {
ssr = tex2Dlod(ssrPassSampler,float4((coords*fSSRRenderScale).xy,0,2+3*b/0.1));
}
#line 2876
float4 previousSSRm = tex2Dlod(ssrPreviousAccuSampler,float4((previousCoords).xy,0,0));
float4 previousSSR = tex2Dlod(ssrPreviousAccuSampler,float4((coords).xy,0,0));
previousSSRm = lerp(previousSSRm,previousSSR,0.5);
#line 2880
float op = ssr.a/iSSRFrameAccu;
float2 refDepth = getDepth(coords);
op = max(0.33/iSSRFrameAccu,op*saturate(1.0-refDepth.x*3));
#line 2884
op = lerp(op,1,saturate(motionDist/256));
op = saturate(op);
if(max(max(previousSSRm.x,previousSSRm.y),previousSSRm.z)<0.01) op = 1;
#line 2888
ssr.rgb = oklLerp(
previousSSRm.rgb,
ssr.rgb,
op
);
#line 2895
outSSR = ssr;
} else {
outSSR = 0;
}
#line 2900
}
#line 2903
float smoothPow(float x,float p) {
return smoothstep(0,1,pow(x,p));
}
#line 2908
float computeAo(float ao,float colorBrightness, float giBrightness, float avgB) {
#line 2911
if(fAOBoostFromGI>0) {
#line 2913
ao -= fAOBoostFromGI*pow(1.0-giBrightness,2);
}
ao = 1.0-saturate((1.0-ao)*fAOMultiplier);
#line 2917
ao = (safePow(ao,fAOPow));
#line 2921
float inDark = max(0.1,pow(avgB,0.25));
ao += (1.0-colorBrightness)*(1.0-colorBrightness)*fAODarkProtect;
ao += pow(colorBrightness,2)*fAOLightProtect;
#line 2925
ao = saturate(ao);
ao = 1.0-saturate((1.0-ao)*fAOMultiplier);
#line 2928
ao += pow(giBrightness,2.0)*fAoProtectGi*4.0;
#line 2930
ao += saturate((1.0-colorBrightness)*fAODarkProtect/inDark);
#line 2932
return saturate(ao);
}
#line 2937
float3 compureResult(
in float2 coords,
in float depth,
in float3 refColor,
in float4 giAo,
in bool reinhardFirstPass
) {
#line 2945
float3 color = refColor;
#line 2947
float originalColorBrightness = max(max(color.x,color.y),color.z);
#line 2949
if(bRemoveAmbient) {
color = filterAmbiantLight(color);
}
#line 2954
float3 gi = giAo.rgb;
#line 2956
float3 giHSV = RGBtoHSV(gi);
float3 colorHSV = RGBtoHSV(color);
#line 2959
float colorBrightness = getBrightness(color);
#line 2962
float3 result = color*(bBaseAlternative?1.0:fBaseColor);
#line 2967
float avgB = getAverageBrightness();
#line 2969
result += originalColorBrightness*gi*fGIDarkMerging*(1.0-pow(originalColorBrightness,0.2));
#line 2972
if(fGIHueBiais>0) {
float3 resultHSV = RGBtoHSV(saturate(result));
float3 biaised = resultHSV;
biaised.x = giHSV.x;
biaised = HSVtoRGB(biaised);
float r = giHSV.y*giHSV.z*(1.0-resultHSV.y)*max(pow((resultHSV.z-0.75)*2,4),pow((resultHSV.z-0.25)*2,4))*fGIHueBiais;
#line 2979
result = lerp(result,biaised,saturate(r));
}
#line 2982
result += pow(result,0.25)*gi*saturate(1.0-avgB)*fGIDarkMerging*(1.0-originalColorBrightness);
result = lerp(result,(1.0-fGILightMerging)*result + fGILightMerging*gi*result,saturate(originalColorBrightness*giHSV.z*4*fGILightMerging));
#line 2987
if(!reinhardFirstPass && fGIOverbrightToWhite>0) {
float b = max(max(result.x,result.y),result.z);
if(b>1) {
result += (b-1)*fGIOverbrightToWhite;
}
}
#line 2995
if(bRreinhardFinalMerging && !reinhardFirstPass) {
float2 mMW = tex2Dlod(reinhardSampler,float4((float2(0.5,0.5)).xy,0,0)).xy;
float3 rResult = result*(1+result/(mMW.y*mMW.y))/(1+result);
result = oklLerp(result,rResult,fRreinhardStrength);
}
#line 3001
return reinhardFirstPass ? result : oklLerp(refColor,saturate(result),getRTF(coords).a);
#line 3003
}
#line 3006
void PS_ReinhardPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outReinhard : SV_Target0) {
if(!bRreinhardFinalMerging) discard;
float2 minMaxW = 0;
#line 3010
float2 currentCoords = 0;
#line 3012
float2 pixelSize = ReShade::GetPixelSize();
float2 stepSize = (int2(1920,1018)/8.0)*pixelSize;
#line 3015
float2 rand = randomCouple(coords);
[loop]
for(currentCoords.x=stepSize.x*0.5;currentCoords.x<=1.0-stepSize.x*0.5;currentCoords.x+=stepSize.x) {
[loop]
for(currentCoords.y=stepSize.y*0.5;currentCoords.y<=1.0-stepSize.y*0.5;currentCoords.y+=stepSize.y) {
rand = nextRand(rand);
float2 c = currentCoords+(rand-0.5)*stepSize;
#line 3023
float depth = getDepth(c).x;
float3 refColor = saturate(tex2Dlod(ReShade::BackBuffer,float4((c).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
#line 3026
float4 giAo = tex2Dlod(giAccuSampler,float4((c).xy,0,0));
#line 3028
float3 result = compureResult(c,depth,refColor,giAo,true);
float b = getBrightness(result);
minMaxW.x = min(minMaxW.x,b);
minMaxW.y = max(minMaxW.y,b);
}
}
#line 3035
outReinhard = float4(minMaxW,1.0,1.0/64.0);
}
#line 3038
void PS_UpdateResult(in float4 position : SV_Position, in float2 coords : TEXCOORD,
out float4 outResult : SV_Target,
out float4 outGiAccu : SV_Target1,
out float4 outSsrAccu : SV_Target2
#line 3043
,out float4 outDepth : SV_Target3
#line 3045
) {
float2 depth = getDepth(coords);
float3 refColor = saturate(tex2Dlod(ReShade::BackBuffer,float4((coords).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
#line 3049
float4 giAo = tex2Dlod(giAccuSampler,float4((coords).xy,0,0));
#line 3051
outGiAccu = giAo;
outSsrAccu = bSSR ? tex2Dlod(ssrAccuSampler,float4((coords).xy,0,0)) : 0;
#line 3054
outDepth = depth;
#line 3057
outResult = float4(compureResult(coords,depth.x,refColor,giAo,false),1.0);
}
#line 3062
void PS_DisplayResult(in float4 position : SV_Position, in float2 coords : TEXCOORD, out float4 outPixel : SV_Target0)
{
float3 result = 0;
#line 3067
if(bDebugLight) {
if(distance(coords,fDebugLightPosition.xy)<2*ReShade::GetPixelSize().x) {
float colorBrightness = getBrightness(result);
outPixel = float4(fDebugLightColor,1);
return;
}
}
#line 3077
if(iDebug==0) {
result = tex2Dlod(resultSampler,float4((coords).xy,0,0)).rgb;
#line 3081
float avgB = getAverageBrightness();
float resultB = getBrightness(result);
float4 giAo = tex2Dlod(giAccuSampler,float4((coords).xy,0,0));
float giBrightness = getBrightness(giAo.rgb);
float ao = giAo.a;
ao = computeAo(ao,resultB,giBrightness,avgB);
result *= ao;
#line 3090
if(bSSR && fSSRMerging>0.0) {
float colorBrightness = getBrightness(result);
float3 ssr = computeSSR(coords,colorBrightness);
result += ssr;
}
#line 3097
result = (result-iBlackLevel/255.0)/((iWhiteLevel-iBlackLevel)/255.0);
#line 3100
float depth = getDepth(coords).x;
if(fDistanceFading<1.0 && depth>fDistanceFading*getDepthMultiplier()) {
float3 color = saturate(tex2Dlod(ReShade::BackBuffer,float4((coords).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
#line 3104
float diff = depth/getDepthMultiplier()-fDistanceFading;
float max = 1.0-fDistanceFading;
float ratio = diff/max;
result = result*(1.0-ratio)+color*ratio;
}
#line 3110
result = saturate(result);
#line 3112
} else if(iDebug==1) {
float4 passColor;
if(false) {
if(iDebugPass==0) passColor =  tex2Dlod(giPass2Sampler,float4((coords*fGIRenderScale).xy,0,0));
if(iDebugPass==1) passColor =  tex2Dlod(giSmoothPassSampler,float4((coords*fGIRenderScale).xy,0,0));
#line 3118
} else {
if(iDebugPass==0) passColor =  tex2Dlod(giPassSampler,float4((coords*fGIRenderScale).xy,0,0));
if(iDebugPass==1) passColor =  tex2Dlod(giPass2Sampler,float4((coords*fGIRenderScale).xy,0,0));
}
if(iDebugPass==2) passColor =  tex2Dlod(giSmooth2PassSampler,float4((coords).xy,0,0));
if(iDebugPass>=3) passColor =  tex2Dlod(giAccuSampler,float4((coords).xy,0,0));
#line 3125
result = passColor.rgb;
if(iDebugPass==4) {
float3 gi = result;
float3 refColor = saturate(tex2Dlod(ReShade::BackBuffer,float4((coords).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
float3 color = refColor;
#line 3131
if(bRemoveAmbient) {
color = filterAmbiantLight(color);
}
#line 3135
float colorBrightness = getBrightness(color);
float3 colorHSV = RGBtoHSV(color);
#line 3138
float3 giHSV = RGBtoHSV(gi);
#line 3140
float3 tintedColor = colorHSV;
tintedColor.xy = gi.xy;
tintedColor = HSVtoRGB(tintedColor);
#line 3144
float avgB = getAverageBrightness();
#line 3146
result = color;
#line 3148
if(fGIHueBiais>0 && giHSV.y>0 && giHSV.z>0) {
float3 c = gi;
c *= colorBrightness/giHSV.z;
result = lerp(result,c,saturate(fGIHueBiais*4*giHSV.y*(1.0-giHSV.z)));
}
#line 3154
float3 addedGi = gi*color*
saturate(
(pow(1.0-colorBrightness,2)-pow(1.0-colorBrightness,4))*2*fGIDarkMerging
-(pow(colorBrightness,2)-pow(colorBrightness,4))*(1.0-fGILightMerging)
)*fGIFinalMerging;
#line 3160
result += addedGi;
#line 3162
result = saturate(0.5+result-color);
}
#line 3166
} else if(iDebug==2) {
#line 3168
float4 passColor;
if(iDebugPass==0) passColor =  tex2Dlod(giPassSampler,float4((coords*fGIRenderScale).xy,0,0));
if(iDebugPass==0) passColor =  tex2Dlod(giPass2Sampler,float4((coords*fGIRenderScale).xy,0,0));
if(iDebugPass==1) passColor =  tex2Dlod(giPass2Sampler,float4((coords*fGIRenderScale).xy,0,0));
if(iDebugPass==1) passColor =  tex2Dlod(giSmoothPassSampler,float4((coords*fGIRenderScale).xy,0,0));
if(iDebugPass==2) passColor =  tex2Dlod(giSmooth2PassSampler,float4((coords).xy,0,0));
if(iDebugPass>=3) passColor =  tex2Dlod(giAccuSampler,float4((coords).xy,0,0));
#line 3176
float ao = passColor.a;
#line 3179
if(iDebugPass==3) {
float giBrightness = getBrightness(passColor.rgb);
if(fAOBoostFromGI>0) {
#line 3183
ao -= fAOBoostFromGI*pow(1.0-giBrightness,2);
}
ao = 1.0-saturate((1.0-ao)*fAOMultiplier);
ao += pow(giBrightness,2.0)*fAoProtectGi*4.0;
#line 3188
} else if(iDebugPass==4) {
float giBrightness = getBrightness(passColor.rgb);
#line 3191
float3 color = saturate(tex2Dlod(ReShade::BackBuffer,float4((coords).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
if(bRemoveAmbient) {
color = filterAmbiantLight(color);
}
float colorBrightness = getBrightness(color);
#line 3197
float avgB = getAverageBrightness();
ao = computeAo(ao,colorBrightness,giBrightness,avgB);
}
result = ao;
#line 3202
} else if(iDebug==3) {
float4 passColor;
if(iDebugPass==0) passColor =  tex2Dlod(ssrPassSampler,float4((coords*fSSRRenderScale).xy,0,0));
if(iDebugPass==1) passColor =  tex2Dlod(ssrPassSampler,float4((coords*fSSRRenderScale).xy,0,0));
if(iDebugPass==2) passColor =  tex2Dlod(ssrPassSampler,float4((coords*fSSRRenderScale).xy,0,0));
if(iDebugPass>=3) passColor =  tex2Dlod(ssrAccuSampler,float4((coords).xy,0,1));
#line 3209
if(iDebugPass==4) {
float3 color = tex2Dlod(resultSampler,float4((coords).xy,0,0)).rgb;
float colorBrightness = getBrightness(color);
passColor = computeSSR(coords,colorBrightness);
}
result = passColor.rgb;
#line 3216
} else if(iDebug==4) {
float3 RTF = tex2Dlod(RTFSampler,float4((coords).xy,0,0)).xyz;
#line 3219
result = RTF.x;
#line 3221
} else if(iDebug==5) {
float depth = getDepth(coords).x;
result = depth;
if(depth<fWeaponDepth*getDepthMultiplier()) {
result = float3(1,0,0);
}
else if(depth==1) {
result = float3(0,1,0);
}
#line 3231
} else if(iDebug==6) {
result = tex2Dlod(normalSampler,float4((coords).xy,0,0)).rgb;
#line 3234
} else if(iDebug==7) {
float depth = getDepth(coords).x;
result = isSky(depth)?1.0:0.0;
#line 3240
} else if(iDebug==8) {
float2  motion = getPreviousCoords(coords);
motion = 0.5+(motion-coords)*25;
result = float3(motion,0.5);
#line 3246
} else if(iDebug==9) {
#line 3248
if(coords.y>0.95) {
if(coords.x<0.5) {
result = getRemovedAmbiantColor();
} else {
result = getAverageBrightness();
}
} else {
result = saturate(tex2Dlod(ReShade::BackBuffer,float4((coords).xy,0,0))*(bBaseAlternative?fBaseColor:1)).rgb;
}
#line 3258
} else if(iDebug==10) {
float4 drtf = getDRTF(coords);
float4 rtfs = tex2Dlod(RTFSampler,float4((coords).xy,0,0));
if(iDebugPass==0) result =  rtfs.x;
if(iDebugPass==1) result =  rtfs.y;
if(iDebugPass==2) result =  rtfs.z;
if(iDebugPass>=3) result =  rtfs.a;
if(iDebugPass==4) result = drtf.z*0.004;
#line 3267
result = drtf.z*0.004;
#line 3269
float4 brs = tex2Dlod(bestRayFillSampler,float4((coords*fGIRenderScale).xy,0,0));
result = brs.a>0 ? getRayColor(brs.xy).rgb : 0;
#line 3272
}
#line 3274
outPixel = float4(result,1.0);
}
#line 3280
technique DH_UBER_RT <
ui_label = "DH_UBER_RT 0.20.6";
ui_tooltip =
"_____________ DH_UBER_RT _____________\n"
"\n"
" ver 0.20.6 (2025-03-04)  by AlucardDH\n"
#line 3289
"\n"
"______________________________________";
> {
#line 3293
pass {
VertexShader = PostProcessVS;
PixelShader = PS_SavePreviousAmbientPass;
RenderTarget = previousAmbientTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_AmbientPass;
RenderTarget = ambientTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_MotionMask;
RenderTarget = motionMaskTex;
}
#line 3311
pass {
VertexShader = PostProcessVS;
PixelShader = PS_RTFS_save;
RenderTarget = previousRTFTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_RTFS;
RenderTarget = RTFTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_NormalPass;
RenderTarget = normalTex;
RenderTarget1 = depthTex;
}
#line 3330
pass {
VertexShader = PostProcessVS;
PixelShader = PS_RayColorPass;
RenderTarget = rayColorTex;
}
#line 3358
pass {
VertexShader = PostProcessVS;
PixelShader = PS_GILightPass;
RenderTarget = giPassTex;
RenderTarget1 = bestRayTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_GIFill;
RenderTarget = bestRayFillTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_GILightPass2;
RenderTarget = giPass2Tex;
}
#line 3376
pass {
VertexShader = PostProcessVS;
PixelShader = PS_SSRLightPass;
RenderTarget = ssrPassTex;
}
#line 3383
pass {
VertexShader = PostProcessVS;
PixelShader = PS_SmoothPass;
RenderTarget = giSmoothPassTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_Smooth2Pass;
RenderTarget = giSmooth2PassTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_AccuPass;
RenderTarget = giAccuTex;
RenderTarget1 = ssrAccuTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_ReinhardPass;
RenderTarget = reinhardTex;
#line 3404
ClearRenderTargets = false;
#line 3406
BlendEnable = true;
BlendOp = ADD;
SrcBlend = SRCALPHA;
SrcBlendAlpha = ONE;
DestBlend = INVSRCALPHA;
DestBlendAlpha = ONE;
}
#line 3416
pass {
VertexShader = PostProcessVS;
PixelShader = PS_UpdateResult;
RenderTarget = resultTex;
RenderTarget1 = giPreviousAccuTex;
RenderTarget2 = ssrPreviousAccuTex;
#line 3423
RenderTarget3 = previousDepthTex;
#line 3425
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_DisplayResult;
}
}
}

