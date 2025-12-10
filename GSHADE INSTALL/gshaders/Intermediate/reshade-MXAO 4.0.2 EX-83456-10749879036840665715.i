// MXAO_SMOOTHNORMALS=1
// MXAO_ENABLE_IL=0
// MXAO_TWO_LAYER=1
// MXAO_MIPLEVEL_IL=2
// MXAO_MIPLEVEL_AO=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MXAO 4.0.2 EX.fx"
#line 42
uniform int MXAO_GLOBAL_SAMPLE_QUALITY_PRESET <
ui_type = "combo";
ui_label = "Sample Quality";
ui_items = "Very Low (4)\0Low (8)\0Medium (16)\0High (24)\0Very High (32)\0Ultra (64)\0Maximum (255)\0";
ui_tooltip = "Global quality control, main performance knob. Higher radii might require higher quality.";
> = 2;
#line 49
uniform float MXAO_SAMPLE_RADIUS <
ui_type = "slider";
ui_min = 0.5; ui_max = 20.0;
ui_label = "Sample Radius";
ui_tooltip = "Sample radius of MXAO, higher means more large-scale occlusion with less fine-scale details.";
> = 2.5;
#line 56
uniform float MXAO_SAMPLE_NORMAL_BIAS <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_label = "Normal Bias";
ui_tooltip = "Occlusion Cone bias to reduce self-occlusion of surfaces that have a low angle to each other.";
> = 0.2;
#line 63
uniform float MXAO_GLOBAL_RENDER_SCALE <
ui_type = "slider";
ui_label = "Render Size Scale";
ui_min = 0.50; ui_max = 1.00;
ui_tooltip = "Factor of MXAO resolution, lower values greatly reduce performance overhead but decrease quality.\n1.0 = MXAO is computed in original resolution\n0.5 = MXAO is computed in 1/2 width 1/2 height of original resolution\n...";
> = 1.0;
#line 70
uniform float MXAO_SSAO_AMOUNT <
ui_type = "slider";
ui_min = 0.00; ui_max = 6.00;
ui_label = "Ambient Occlusion Amount";
ui_tooltip = "Intensity of AO effect. Can cause pitch black clipping if set too high.";
> = 1.00;
#line 108
uniform float MXAO_SAMPLE_RADIUS_SECONDARY <
ui_type = "slider";
ui_min = 0.1; ui_max = 2.00;
ui_label = "Fine AO Scale";
ui_tooltip = "Multiplier of Sample Radius for fine geometry. A setting of 0.5 scans the geometry at half the radius of the main AO.";
> = 0.2;
#line 115
uniform float MXAO_AMOUNT_FINE <
ui_type = "slider";
ui_min = 0.00; ui_max = 2.00;
ui_label = "Fine AO intensity multiplier";
ui_tooltip = "Intensity of small scale AO / IL.";
> = 1.0;
#line 122
uniform float MXAO_AMOUNT_COARSE <
ui_type = "slider";
ui_min = 0.00; ui_max = 2.00;
ui_label = "Coarse AO intensity multiplier";
ui_tooltip = "Intensity of large scale AO / IL.";
> = 1.0;
#line 130
uniform float MXAO_GAMMA <
ui_type = "slider";
ui_min = 1.00; ui_max = 3.00;
ui_label = "AO Gamma";
ui_tooltip = "Exponent for the AO result. ( pow(<AO>, gamma) )";
> = 1.00;
#line 137
uniform int MXAO_DEBUG_VIEW_ENABLE <
ui_type = "combo";
ui_label = "Enable Debug View";
ui_items = "None\0AO/IL channel\0Culling Mask\0";
ui_tooltip = "Different debug outputs";
> = 0;
#line 144
uniform int MXAO_BLEND_TYPE <
ui_type = "combo";
ui_items = "MXAO 2.0\0MXAO 3.0\0MXAO 4.0\0Beats Me What This Does - Marot\0";
ui_label = "Blending Mode";
ui_tooltip = "Different blending modes for merging AO/IL with original color.\0Blending mode 0 matches formula of MXAO 2.0 and older.";
> = 0;
#line 151
uniform float MXAO_FADE_DEPTH_START <
ui_type = "slider";
ui_label = "Fade Out Start";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Distance where MXAO starts to fade out. 0.0 = camera, 1.0 = sky. Must be less than Fade Out End.";
> = 0.05;
#line 158
uniform float MXAO_FADE_DEPTH_END <
ui_type = "slider";
ui_label = "Fade Out End";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Distance where MXAO completely fades out. 0.0 = camera, 1.0 = sky. Must be greater than Fade Out Start.";
> = 0.4;
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
#line 170 "C:\Program Files\GShade\gshade-shaders\Shaders\MXAO 4.0.2 EX.fx"
#line 171
texture2D MXAO_ColorTex 	{ Width = 1920;   Height = 1018;   Format = RGBA8; MipLevels = 3+2;};
texture2D MXAO_DepthTex 	{ Width = 1920;   Height = 1018;   Format = R16F;  MipLevels = 3+0;};
texture2D MXAO_NormalTex	{ Width = 1920;   Height = 1018;   Format = RGBA8; MipLevels = 3+2;};
texture2D MXAO_CullingTex	{ Width = 1920/8; Height = 1018/8; Format = R8; };
#line 176
sampler2D sMXAO_ColorTex	{ Texture = MXAO_ColorTex;	};
sampler2D sMXAO_DepthTex	{ Texture = MXAO_DepthTex;	};
sampler2D sMXAO_NormalTex	{ Texture = MXAO_NormalTex;	};
sampler2D sMXAO_CullingTex	{ Texture = MXAO_CullingTex;	};
#line 185
struct MXAO_VSOUT
{
float4              position    : SV_Position;
float2              texcoord    : TEXCOORD0;
float2              scaledcoord : TEXCOORD1;
float   	    samples     : TEXCOORD2;
float3              uvtoviewADD : TEXCOORD4;
float3              uvtoviewMUL : TEXCOORD5;
};
#line 195
MXAO_VSOUT VS_MXAO(in uint id : SV_VertexID)
{
MXAO_VSOUT MXAO;
#line 199
if (id == 2)
MXAO.texcoord.x = 2.0;
else
MXAO.texcoord.x = 0.0;
#line 204
if (id == 1)
MXAO.texcoord.y = 2.0;
else
MXAO.texcoord.y = 0.0;
#line 209
MXAO.scaledcoord.xy = MXAO.texcoord.xy / MXAO_GLOBAL_RENDER_SCALE;
MXAO.position = float4(MXAO.texcoord.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 212
MXAO.samples   = 8;
#line 214
if(     MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 0) { MXAO.samples = 4;     }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 1) { MXAO.samples = 8;     }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 2) { MXAO.samples = 16;    }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 3) { MXAO.samples = 24;    }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 4) { MXAO.samples = 32;    }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 5) { MXAO.samples = 64;    }
else if(MXAO_GLOBAL_SAMPLE_QUALITY_PRESET == 6) { MXAO.samples = 255;   }
#line 222
MXAO.uvtoviewADD = float3(-1.0,-1.0,1.0);
MXAO.uvtoviewMUL = float3(2.0,2.0,0.0);
#line 231
return MXAO;
}
#line 238
float GetLinearDepth(in float2 coords)
{
return ReShade::GetLinearizedDepth(coords);
}
#line 245
float3 GetPosition(in float2 coords, in MXAO_VSOUT MXAO)
{
return (coords.xyx * MXAO.uvtoviewMUL + MXAO.uvtoviewADD) * GetLinearDepth(coords.xy) * 1000.0;
}
#line 252
float3 GetPositionLOD(in float2 coords, in MXAO_VSOUT MXAO, in int mipLevel)
{
return (coords.xyx * MXAO.uvtoviewMUL + MXAO.uvtoviewADD) * tex2Dlod(sMXAO_DepthTex, float4(coords.xy,0,mipLevel)).x;
}
#line 259
void GetBlurWeight(in float4 tempKey, in float4 centerKey, in float surfacealignment, inout float weight)
{
const float depthdiff = abs(tempKey.w - centerKey.w);
const float normaldiff = saturate(1.0 - dot(tempKey.xyz,centerKey.xyz));
#line 264
weight = saturate(0.15 / surfacealignment - depthdiff) * saturate(0.65 - normaldiff);
weight = saturate(weight * 4.0) * 2.0;
}
#line 270
void GetBlurKeyAndSample(in float2 texcoord, in float inputscale, in sampler inputsampler, inout float4 tempsample, inout float4 key)
{
const float4 lodcoord = float4(texcoord.xy,0,0);
tempsample = tex2Dlod(inputsampler,lodcoord * inputscale);
key = float4(tex2Dlod(sMXAO_NormalTex,lodcoord).xyz*2-1, tex2Dlod(sMXAO_DepthTex,lodcoord).x);
}
#line 279
float4 BlurFilter(in MXAO_VSOUT MXAO, in sampler inputsampler, in float inputscale, in float radius, in int blursteps)
{
float4 tempsample;
float4 centerkey, tempkey;
float  centerweight = 1.0, tempweight;
float4 blurcoord = 0.0;
#line 286
GetBlurKeyAndSample(MXAO.texcoord.xy,inputscale,inputsampler,tempsample,centerkey);
float surfacealignment = saturate(-dot(centerkey.xyz,normalize(float3(MXAO.texcoord.xy*2.0-1.0,1.0)*centerkey.w)));
#line 295
float4 blurSum = tempsample.w;
const float2 blurOffsets[8] = {float2(1.5,0.5),float2(-1.5,-0.5),float2(-0.5,1.5),float2(0.5,-1.5),float2(1.5,2.5),float2(-1.5,-2.5),float2(-2.5,1.5),float2(2.5,-1.5)};
#line 298
[loop]
for(int iStep = 0; iStep < blursteps; iStep++)
{
const float2 sampleCoord = MXAO.texcoord.xy + blurOffsets[iStep] * float2((1.0 / 1920), (1.0 / 1018)) * radius / inputscale;
#line 303
GetBlurKeyAndSample(sampleCoord, inputscale, inputsampler, tempsample, tempkey);
GetBlurWeight(tempkey, centerkey, surfacealignment, tempweight);
#line 306
blurSum += tempsample.w * tempweight;
centerweight  += tempweight;
}
#line 310
blurSum.w /= centerweight;
#line 313
blurSum.xyz = centerkey.xyz*0.5+0.5;
#line 316
return blurSum;
}
#line 321
void SetupAOParameters(in MXAO_VSOUT MXAO, in float3 P, in float layerID, out float scaledRadius, out float falloffFactor)
{
scaledRadius  = 0.25 * MXAO_SAMPLE_RADIUS / (MXAO.samples * (P.z + 2.0));
falloffFactor = -1.0/(MXAO_SAMPLE_RADIUS * MXAO_SAMPLE_RADIUS);
#line 327
scaledRadius  *= lerp(1.0,MXAO_SAMPLE_RADIUS_SECONDARY,layerID);
falloffFactor *= lerp(1.0,1.0/(MXAO_SAMPLE_RADIUS_SECONDARY*MXAO_SAMPLE_RADIUS_SECONDARY),layerID);
#line 330
}
#line 334
void TesselateNormals(inout float3 N, in float3 P, in MXAO_VSOUT MXAO)
{
const float2 searchRadiusScaled = 0.018 / P.z * float2(1.0,(1920 * (1.0 / 1018)));
float3 likelyFace[4] = {N,N,N,N};
#line 339
[unroll]
for(int iDirection=0; iDirection < 4; iDirection++)
{
float2 cdir;
sincos(6.28318548 * 0.25 * iDirection,cdir.y,cdir.x);
for(int i=1; i<=5; i++)
{
const float cSearchRadius = exp2(i);
const float2 cOffset = MXAO.scaledcoord.xy + cdir * cSearchRadius * searchRadiusScaled;
#line 349
const float3 cN = tex2Dlod(sMXAO_NormalTex,float4(cOffset,0,0)).xyz * 2.0 - 1.0;
const float3 cP = GetPositionLOD(cOffset.xy,MXAO,0);
#line 352
const float3 cDelta = cP - P;
const float validWeightDistance = saturate(1.0 - dot(cDelta,cDelta) * 20.0 / cSearchRadius);
const float Angle = dot(N.xyz,cN.xyz);
const float validWeightAngle = smoothstep(0.3,0.98,Angle) * smoothstep(1.0,0.98,Angle); 
#line 357
const float validWeight = saturate(3.0 * validWeightDistance * validWeightAngle / cSearchRadius);
#line 359
likelyFace[iDirection] = lerp(likelyFace[iDirection],cN.xyz, validWeight);
}
}
#line 363
N = normalize(likelyFace[0] + likelyFace[1] + likelyFace[2] + likelyFace[3]);
}
#line 368
bool GetCullingMask(in MXAO_VSOUT MXAO)
{
const float4 cOffsets = float4(float2((1.0 / 1920), (1.0 / 1018)),-float2((1.0 / 1920), (1.0 / 1018))) * 8;
float cullingArea = tex2D(sMXAO_CullingTex, MXAO.scaledcoord.xy + cOffsets.xy).x;
cullingArea      += tex2D(sMXAO_CullingTex, MXAO.scaledcoord.xy + cOffsets.zy).x;
cullingArea      += tex2D(sMXAO_CullingTex, MXAO.scaledcoord.xy + cOffsets.xw).x;
cullingArea      += tex2D(sMXAO_CullingTex, MXAO.scaledcoord.xy + cOffsets.zw).x;
return cullingArea  > 0.000001;
}
#line 380
float3 RGBtoHSV(in float3 RGB){
float3 HSV = 0;
HSV.z = max(RGB.r, max(RGB.g, RGB.b));
const float M = min(RGB.r, min(RGB.g, RGB.b));
const float C = HSV.z - M;
if (C != 0){
const float4 RGB0 = float4(RGB, 0);
float4 Delta = (HSV.z - RGB0) / C;
Delta.rgb -= Delta.brg;
Delta.rgb += float3(2,4,6);
Delta.brg = step(HSV.z, RGB) * Delta.brg;
HSV.x = max(Delta.r, max(Delta.g, Delta.b));
HSV.x = frac(HSV.x / 6);
HSV.y = 1 / Delta.w;
}
return HSV;
}
#line 402
void PS_InputBufferSetup(in MXAO_VSOUT MXAO, out float4 color : SV_Target0, out float4 depth : SV_Target1, out float4 normal : SV_Target2)
{
const float3 offs = float3(float2((1.0 / 1920), (1.0 / 1018)),0);
#line 406
const float3 f 	 =       GetPosition(MXAO.texcoord.xy, MXAO);
float3 gradx1 	 = - f + GetPosition(MXAO.texcoord.xy + offs.xz, MXAO);
const float3 gradx2 	 =   f - GetPosition(MXAO.texcoord.xy - offs.xz, MXAO);
float3 grady1 	 = - f + GetPosition(MXAO.texcoord.xy + offs.zy, MXAO);
const float3 grady2 	 =   f - GetPosition(MXAO.texcoord.xy - offs.zy, MXAO);
#line 412
gradx1 = lerp(gradx1, gradx2, abs(gradx1.z) > abs(gradx2.z));
grady1 = lerp(grady1, grady2, abs(grady1.z) > abs(grady2.z));
#line 415
normal          = float4(normalize(cross(grady1,gradx1)) * 0.5 + 0.5,0.0);
color 		= tex2D(ReShade::BackBuffer, MXAO.texcoord.xy);
depth 		= GetLinearDepth(MXAO.texcoord.xy)*1000.0;
}
#line 422
void PS_Culling(in MXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
color = 0.0;
MXAO.scaledcoord.xy = MXAO.texcoord.xy;
MXAO.samples = clamp(MXAO.samples, 8, 32);
#line 428
float3 P             = GetPositionLOD(MXAO.scaledcoord.xy, MXAO, 0);
float3 N             = tex2D(sMXAO_NormalTex, MXAO.scaledcoord.xy).xyz * 2.0 - 1.0;
#line 431
P += N * P.z / 1000.0;
#line 433
float scaledRadius;
float falloffFactor;
SetupAOParameters(MXAO, P, 0, scaledRadius, falloffFactor);
#line 437
float randStep = dot(floor(MXAO.position.xy % 4 + 0.1),int2(1,4)) + 1;
randStep *= 0.0625;
#line 440
float2 sampleUV, Dir;
sincos(38.39941 * randStep, Dir.x, Dir.y);
#line 443
Dir *= scaledRadius;
#line 445
for(int iSample=0; iSample < MXAO.samples; iSample++)
{
sampleUV = MXAO.scaledcoord.xy + Dir.xy * float2(1.0, (1920 * (1.0 / 1018))) * (iSample + randStep);
Dir.xy = mul(Dir.xy, float2x2(0.76465,-0.64444,0.64444,0.76465));
#line 450
const float sampleMIP = saturate(scaledRadius * iSample * 20.0) * 3.0;
#line 452
const float3 V 		= -P + GetPositionLOD(sampleUV, MXAO, sampleMIP + 0);
const float  VdotV            = dot(V, V);
const float  VdotN            = dot(V, N) * rsqrt(VdotV);
#line 456
const float fAO = saturate(1.0 + falloffFactor * VdotV) * saturate(VdotN - MXAO_SAMPLE_NORMAL_BIAS * 0.5);
color.w += fAO;
}
#line 460
color = color.w;
}
#line 465
void PS_StencilSetup(in MXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
if(    GetLinearDepth(MXAO.scaledcoord.xy) >= MXAO_FADE_DEPTH_END
|| 0.25 * 0.5 * MXAO_SAMPLE_RADIUS / (tex2D(sMXAO_DepthTex,MXAO.scaledcoord.xy).x + 2.0) * 1018 < 1.0
|| MXAO.scaledcoord.x > 1.0
|| MXAO.scaledcoord.y > 1.0
#line 472
|| !GetCullingMask(MXAO)
#line 474
) discard;
#line 476
color = 1.0;
}
#line 481
void PS_AmbientObscurance(in MXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
color = 0.0;
#line 485
float3 P             = GetPositionLOD(MXAO.scaledcoord.xy, MXAO, 0);
float3 N             = tex2D(sMXAO_NormalTex, MXAO.scaledcoord.xy).xyz * 2.0 - 1.0;
const float  layerID       = (MXAO.position.x + MXAO.position.y) % 2.0;
#line 490
TesselateNormals(N, P, MXAO);
#line 493
P += N * P.z / 1000.0;
#line 495
float scaledRadius;
float falloffFactor;
SetupAOParameters(MXAO, P, layerID, scaledRadius, falloffFactor);
#line 499
float randStep = dot(floor(MXAO.position.xy % 4 + 0.1),int2(1,4)) + 1;
randStep *= 0.0625;
#line 502
float2 sampleUV, Dir;
sincos(38.39941 * randStep, Dir.x, Dir.y);
#line 505
Dir *= scaledRadius;
#line 507
[loop]
for(int iSample=0; iSample < MXAO.samples; iSample++)
{
sampleUV = MXAO.scaledcoord.xy + Dir.xy * float2(1.0, (1920 * (1.0 / 1018))) * (iSample + randStep);
Dir.xy = mul(Dir.xy, float2x2(0.76465,-0.64444,0.64444,0.76465));
#line 513
const float sampleMIP = saturate(scaledRadius * iSample * 20.0) * 3.0;
#line 515
const float3 V 		= -P + GetPositionLOD(sampleUV, MXAO, sampleMIP + 0);
const float  VdotV            = dot(V, V);
const float  VdotN            = dot(V, N) * rsqrt(VdotV);
#line 519
const float fAO = saturate(1.0 + falloffFactor * VdotV) * saturate(VdotN - MXAO_SAMPLE_NORMAL_BIAS);
#line 531
color.w += fAO;
#line 533
}
#line 535
color = saturate(color/((1.0-MXAO_SAMPLE_NORMAL_BIAS)*MXAO.samples));
color = sqrt(color); 
#line 539
color = pow(color,1.0 / lerp(MXAO_AMOUNT_COARSE, MXAO_AMOUNT_FINE, layerID));
#line 545
color.w = pow(color.w, MXAO_GAMMA) * MXAO_GAMMA;
}
#line 550
void PS_BlurX(in MXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
color = BlurFilter(MXAO, ReShade::BackBuffer, MXAO_GLOBAL_RENDER_SCALE, 1.0, 8);
}
#line 555
void PS_BlurYandCombine(MXAO_VSOUT MXAO, out float4 color : SV_Target0)
{
float4 aoil = BlurFilter(MXAO, ReShade::BackBuffer, 1.0, 0.75/MXAO_GLOBAL_RENDER_SCALE, 4);
aoil *= aoil; 
#line 560
color                   = tex2D(sMXAO_ColorTex, MXAO.texcoord.xy);
#line 562
const float scenedepth        = GetLinearDepth(MXAO.texcoord.xy);
const float3 lumcoeff         = float3(0.2126, 0.7152, 0.0722);
const float colorgray         = dot(color.rgb,lumcoeff);
const float blendfact         = 1.0 - colorgray;
#line 570
aoil.xyz = 0.0;
#line 573
aoil.w  = 1.0-pow(abs(1.0-aoil.w), MXAO_SSAO_AMOUNT*4.0);
aoil    = lerp(aoil,0.0,smoothstep(MXAO_FADE_DEPTH_START, MXAO_FADE_DEPTH_END, scenedepth * float4(2.0,2.0,2.0,1.0)));
#line 576
if(MXAO_BLEND_TYPE == 0)
{
color.rgb -= (aoil.www - aoil.xyz) * blendfact * color.rgb;
}
else if(MXAO_BLEND_TYPE == 1)
{
color.rgb = color.rgb * saturate(1.0 - aoil.www * blendfact * 1.2) + aoil.xyz * blendfact * colorgray * 2.0;
}
else if(MXAO_BLEND_TYPE == 2)
{
const float colordiff = saturate(2.0 * distance(normalize(color.rgb + 1e-6),normalize(aoil.rgb + 1e-6)));
color.rgb = color.rgb + aoil.rgb * lerp(color.rgb, dot(color.rgb, 0.3333), colordiff) * blendfact * blendfact * 4.0;
color.rgb = color.rgb * (1.0 - aoil.www * (1.0 - dot(color.rgb, lumcoeff)));
}
else if(MXAO_BLEND_TYPE == 3)
{
color.rgb = pow(abs(color.rgb),2.2);
color.rgb -= (aoil.www - aoil.xyz) * color.rgb;
color.rgb = pow(abs(color.rgb),1.0/2.2);
}
#line 597
color.rgb = saturate(color.rgb);
#line 599
if(MXAO_DEBUG_VIEW_ENABLE == 1) 
{
color.rgb = saturate(1.0 - aoil.www + aoil.xyz);
if (0 != 0)
color.rgb *= 0.5;
else
color.rgb *= 1.0;
}
else if(MXAO_DEBUG_VIEW_ENABLE == 2)
{
color.rgb = GetCullingMask(MXAO);
}
#line 612
color.a = 1.0;
}
#line 619
technique MXAO
{
#line 622
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_InputBufferSetup;
RenderTarget0 = MXAO_ColorTex;
RenderTarget1 = MXAO_DepthTex;
RenderTarget2 = MXAO_NormalTex;
}
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_Culling;
RenderTarget = MXAO_CullingTex;
}
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_StencilSetup;
#line 641
ClearRenderTargets = true;
StencilEnable = true;
StencilPass = REPLACE;
StencilRef = 1;
}
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_AmbientObscurance;
#line 651
ClearRenderTargets = true;
StencilEnable = true;
StencilPass = KEEP;
StencilFunc = EQUAL;
StencilRef = 1;
}
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_BlurX;
#line 662
}
pass
{
VertexShader = VS_MXAO;
PixelShader  = PS_BlurYandCombine;
#line 668
}
}

