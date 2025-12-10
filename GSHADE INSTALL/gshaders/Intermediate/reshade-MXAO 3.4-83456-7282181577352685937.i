// MXAO_ENABLE_BACKFACE=1
// MXAO_ENABLE_IL=0
// MXAO_MIPLEVEL_IL=2
// MXAO_MIPLEVEL_AO=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MXAO 3.4.fx"
#line 34
uniform float fMXAOAmbientOcclusionAmount <
ui_type = "slider";
ui_min = 0.00; ui_max = 12.00;
ui_label = "Ambient Occlusion Amount";
ui_tooltip = "Linearly increases AO intensity. Can cause pitch black clipping if set too high.";
> = 2.00;
#line 41
uniform float fMXAOSampleRadius <
ui_type = "slider";
ui_min = 1.00; ui_max = 8.00;
ui_label = "Sample Radius";
ui_tooltip = "Sample radius of GI, higher means more large-scale occlusion with less fine-scale details.";
> = 2.50;
#line 48
uniform float iMXAOSampleCount <
ui_type = "slider";
ui_min = 8.0; ui_max = 255.0;
ui_step = 1.0;
ui_label = "Sample Count";
ui_tooltip = "Amount of MXAO samples. Higher means more accurate and less noisy AO at the cost of fps.";
> = 24;
#line 56
uniform float iMXAOBayerDitherLevel <
ui_type = "slider";
ui_min = 2; ui_max = 8;
ui_label = "Dither Size";
ui_tooltip = "Factor of 'random' rotation pattern size.\nHigher means less distinctive haloing but noisier AO.\nSet Blur Steps to 0 to see effect better.";
> = 3;
#line 63
uniform float fMXAONormalBias <
ui_type = "slider";
ui_min = 0.0; ui_max = 0.8;
ui_label = "Normal Bias";
ui_tooltip = "Normals bias to reduce self-occlusion of surfaces that have a low angle to each other.";
> = 0.2;
#line 70
uniform bool bMXAOSmoothNormalsEnable <
ui_label = "Enable Smoothed Normals";
ui_tooltip = "Enable smoothed normals. WIP.";
> = false;
#line 75
uniform float fMXAOBlurSharpness <
ui_type = "slider";
ui_min = 0.00; ui_max = 5.00;
ui_label = "Blur Sharpness";
ui_tooltip = "AO sharpness, higher means sharper geometry edges but noisier AO, less means smoother AO but blurry in the distance.";
> = 2.00;
#line 82
uniform float fMXAOBlurSteps <
ui_type = "slider";
ui_min = 0; ui_max = 5;
ui_label = "Blur Steps";
ui_tooltip = "Offset count for AO bilateral blur filter. Higher means smoother but also blurrier AO.";
> = 2;
#line 89
uniform bool bMXAODebugViewEnable <
ui_label = "Enable Debug View";
ui_tooltip = "Enables raw AO/IL output for debugging and tuning purposes.";
> = false;
#line 94
uniform float fMXAOFadeoutStart <
ui_type = "slider";
ui_label = "Fade Out Start";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Fadeout start.";
> = 0.2;
#line 101
uniform float fMXAOFadeoutEnd <
ui_type = "slider";
ui_label = "Fade Out End";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Fadeout end.";
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
#line 113 "C:\Program Files\GShade\gshade-shaders\Shaders\MXAO 3.4.fx"
#line 116
texture2D texColorBypass 	{ Width = 1920; 			  Height = 1018; 			    Format = RGBA8; MipLevels = 5+2;};
texture2D texDistance 		{ Width = 1920; 			  Height = 1018;  			    Format = R16F;  MipLevels = 5+0;};
texture2D texSurfaceNormal	{ Width = 1920;                           Height = 1018; 		            Format = RGBA8; MipLevels = 5+2;};
sampler2D SamplerColorBypass	{	Texture = texColorBypass;	};
sampler2D SamplerDistance	{	Texture = texDistance;		};
sampler2D SamplerSurfaceNormal	{	Texture = texSurfaceNormal;	};
#line 129
float GetLinearDepth(float2 coords)
{
return ReShade::GetLinearizedDepth(coords);
}
#line 140
float3 GetPosition(float2 coords)
{
return float3(coords.xy*2.0-1.0,1.0)*GetLinearDepth(coords.xy)*1000.0;
}
#line 147
float3 GetPositionLOD(float2 coords, int mipLevel)
{
return float3(coords.xy*2.0-1.0,1.0)*tex2Dlod(SamplerDistance, float4(coords.xy,0,mipLevel)).x;
}
#line 156
float3 GetNormalFromDepth(float2 coords)
{
const float3 offs = float3(float2((1.0 / 1920), (1.0 / 1018)).xy,0);
#line 160
const float3 f 	 =       GetPosition(coords.xy);
float3 d_dx1 	 = - f + GetPosition(coords.xy + offs.xz);
const float3 d_dx2 	 =   f - GetPosition(coords.xy - offs.xz);
float3 d_dy1 	 = - f + GetPosition(coords.xy + offs.zy);
const float3 d_dy2 	 =   f - GetPosition(coords.xy - offs.zy);
#line 166
d_dx1 = lerp(d_dx1, d_dx2, abs(d_dx1.z) > abs(d_dx2.z));
d_dy1 = lerp(d_dy1, d_dy2, abs(d_dy1.z) > abs(d_dy2.z));
#line 169
return normalize(cross(d_dy1,d_dx1));
}
#line 176
float3 GetSmoothedNormals(float2 texcoord, float3 ScreenSpaceNormals, float3 ScreenSpacePosition)
{
float4 blurnormal = 0.0;
[loop]
for(float x = -3; x <= 3; x++)
{
[loop]
for(float y = -3; y <= 3; y++)
{
const float2 offsetcoord 	= texcoord.xy + float2(x,y) * float2((1.0 / 1920), (1.0 / 1018)).xy * 3.5;
const float3 samplenormal 	= normalize(tex2Dlod(SamplerSurfaceNormal,float4(offsetcoord,0,2)).xyz * 2.0 - 1.0);
const float3 sampleposition	= GetPositionLOD(offsetcoord.xy,2);
float weight 		= saturate(1.0 - distance(ScreenSpacePosition.xyz,sampleposition.xyz)*1.2);
weight 		       *= smoothstep(0.5,1.0,dot(samplenormal,ScreenSpaceNormals));
blurnormal.xyz += samplenormal * weight;
blurnormal.w += weight;
}
}
#line 195
return normalize(blurnormal.xyz / (0.0001 + blurnormal.w) + ScreenSpaceNormals*0.05);
}
#line 202
float4 GetBlurFactors(float2 coords)
{
return float4(tex2Dlod(SamplerSurfaceNormal, float4(coords.xy,0,0)).xyz*2.0-1.0,tex2Dlod(SamplerDistance, float4(coords.xy,0,0)).x);
}
#line 213
float GetBlurWeight(float4 tempKey, float4 centerKey, float surfacealignment)
{
const float depthdiff = abs(tempKey.w-centerKey.w);
const float normaldiff = 1.0-saturate(dot(normalize(tempKey.xyz),normalize(centerKey.xyz)));
#line 218
const float depthweight = saturate(rcp(fMXAOBlurSharpness*depthdiff*5.0*surfacealignment));
const float normalweight = saturate(rcp(fMXAOBlurSharpness*normaldiff*10.0));
#line 221
return min(normalweight,depthweight);
}
#line 231
float4 GetBlurredAO( float2 texcoord, sampler inputsampler, float2 axis, int nSteps)
{
float4 tempsample;
float4 centerkey   , tempkey;
float  centerweight, tempweight;
float surfacealignment;
float4 blurcoord = 0.0;
float AO         = 0.0;
#line 240
tempsample 	 = tex2D(inputsampler,texcoord.xy);
centerkey 	 = float4(tempsample.xyz*2-1,tex2Dlod(SamplerDistance,float4(texcoord.xy,0,0)).x);
centerweight     = 0.5;
AO               = tempsample.w * 0.5;
surfacealignment = saturate(-dot(centerkey.xyz,normalize(float3(texcoord.xy*2.0-1.0,1.0)*centerkey.w)));
#line 246
[loop]
for(int orientation=-1;orientation<=1; orientation+=2)
{
[loop]
for(float iStep = 1.0; iStep <= nSteps; iStep++)
{
blurcoord.xy 	= (2.0 * iStep - 0.5) * orientation * axis * float2((1.0 / 1920), (1.0 / 1018)).xy + texcoord.xy;
tempsample = tex2Dlod(inputsampler, blurcoord);
tempkey    = float4(tempsample.xyz*2-1,tex2Dlod(SamplerDistance,blurcoord).x);
tempweight = GetBlurWeight(tempkey, centerkey, surfacealignment);
AO += tempsample.w * tempweight;
centerweight   += tempweight;
}
}
#line 261
return float4(centerkey.xyz*0.5+0.5, AO / centerweight);
}
#line 266
float4 GetBlurredAOIL( float2 texcoord, sampler inputsampler, float2 axis, int nSteps)
{
float4 tempsample;
float4 centerkey   , tempkey;
float  centerweight, tempweight;
float surfacealignment;
float4 blurcoord = 0.0;
float4 AO_IL         = 0.0;
#line 275
tempsample 	 = tex2D(inputsampler,texcoord.xy);
centerkey 	 = float4(tex2Dlod(SamplerSurfaceNormal,float4(texcoord.xy,0,0)).xyz*2-1,tex2Dlod(SamplerDistance,float4(texcoord.xy,0,0)).x);
centerweight     = 0.5;
AO_IL            = tempsample * 0.5;
surfacealignment = saturate(-dot(centerkey.xyz,normalize(float3(texcoord.xy*2.0-1.0,1.0)*centerkey.w)));
#line 281
[loop]
for(int orientation=-1;orientation<=1; orientation+=2)
{
[loop]
for(float iStep = 1.0; iStep <= nSteps; iStep++)
{
blurcoord.xy 	= (2.0 * iStep - 0.5) * orientation * axis * float2((1.0 / 1920), (1.0 / 1018)).xy + texcoord.xy;
tempsample = tex2Dlod(inputsampler, blurcoord);
tempkey    = float4(tex2Dlod(SamplerSurfaceNormal,blurcoord).xyz*2-1,tex2Dlod(SamplerDistance,blurcoord).x);
tempweight = GetBlurWeight(tempkey, centerkey, surfacealignment);
AO_IL += tempsample * tempweight;
centerweight   += tempweight;
}
}
#line 296
return float4(AO_IL / centerweight);
}
#line 311
float GetBayerFromCoordLevel(float2 pixelpos, int maxLevel)
{
float finalBayer = 0.0;
#line 315
for(float i = 1-maxLevel; i<= 0; i++)
{
const float bayerSize = exp2(i);
const float2 bayerCoord = floor(pixelpos * bayerSize) % 2.0;
const float bayer = 2.0 * bayerCoord.x - 4.0 * bayerCoord.x * bayerCoord.y + 3.0 * bayerCoord.y;
finalBayer += exp2(2.0*(i+maxLevel))* bayer;
}
#line 323
const float finalDivisor = 4.0 * exp2(2.0 * maxLevel)- 4.0;
#line 325
return finalBayer/ finalDivisor + 1.0/exp2(2.0 * maxLevel);
}
#line 341
float4 GetMXAO(float2 texcoord, float3 normal, float3 position, float nSamples, float2 currentVector, float mipFactor, float fNegInvR2, float radiusJitter, float sampleRadius)
{
float4 AO_IL = 0.0;
float2 currentOffset;
#line 346
[loop]
for(int iSample=0; iSample < nSamples; iSample++)
{
currentVector = mul(currentVector.xy, float2x2(0.575,0.81815,-0.81815,0.575));
currentOffset = texcoord.xy + currentVector.xy * float2(1.0,(1920 * (1.0 / 1018))) * (iSample + radiusJitter);
#line 352
const float mipLevel = saturate(log2(mipFactor*iSample)*0.2 - 0.6) * 5.0;
#line 354
const float3 occlVec 		= -position + GetPositionLOD(currentOffset.xy, mipLevel);
const float  occlDistanceRcp 	= rsqrt(dot(occlVec,occlVec));
const float  occlAngle 	= dot(occlVec, normal)*occlDistanceRcp;
#line 358
const float fAO = saturate(1.0 + fNegInvR2/occlDistanceRcp)  * saturate(occlAngle - fMXAONormalBias);
#line 370
AO_IL.w += fAO;
#line 372
}
#line 374
return saturate(AO_IL/(0.4*(1.0-fMXAONormalBias)*nSamples*sqrt(sampleRadius)));
}
#line 383
void PS_AO_Pre(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target0, out float4 depth : SV_Target1, out float4 normal : SV_Target2)
{
color 		= tex2D(ReShade::BackBuffer, texcoord.xy);
depth 		= GetLinearDepth(texcoord.xy)*1000.0;
normal.xyz 	= GetNormalFromDepth(texcoord.xy).xyz * 0.5 + 0.5;
normal.w	= GetBayerFromCoordLevel(vpos.xy,iMXAOBayerDitherLevel);
}
#line 391
void PS_AO_Gen(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 res : SV_Target0)
{
const float4 normalSample = tex2D(SamplerSurfaceNormal, texcoord.xy);
#line 395
float3 ScreenSpaceNormals = normalSample.xyz * 2.0 - 1.0;
float3 ScreenSpacePosition = GetPositionLOD(texcoord.xy, 0);
#line 398
if(bMXAOSmoothNormalsEnable)
{
ScreenSpaceNormals = GetSmoothedNormals(texcoord, ScreenSpaceNormals, ScreenSpacePosition);
}
#line 403
const float scenedepth = ScreenSpacePosition.z / 1000.0;
ScreenSpacePosition += ScreenSpaceNormals * scenedepth;
#line 406
const float SampleRadiusScaled  = 0.2*fMXAOSampleRadius*fMXAOSampleRadius / (iMXAOSampleCount * ScreenSpacePosition.z);
const float mipFactor = SampleRadiusScaled * 3200.0;
#line 409
float2 currentVector;
sincos(2.0*3.14159274*normalSample.w, currentVector.y, currentVector.x);
const float fNegInvR2 = -1.0/(fMXAOSampleRadius*fMXAOSampleRadius);
currentVector *= SampleRadiusScaled;
#line 414
res = GetMXAO(texcoord,
ScreenSpaceNormals,
ScreenSpacePosition,
iMXAOSampleCount,
currentVector,
mipFactor,
fNegInvR2,
normalSample.w,
fMXAOSampleRadius);
#line 424
res = sqrt(abs(res));
#line 427
res.xyz = normalSample.xyz;
#line 429
}
#line 435
void PS_AO_Blur1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 res : SV_Target0)
{
#line 440
res = GetBlurredAO(texcoord.xy, ReShade::BackBuffer, float2(1.0,0.0), fMXAOBlurSteps);
#line 442
}
#line 448
void PS_AO_Blur2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 res : SV_Target0)
{
#line 454
float4 MXAOFFXIV = GetBlurredAO(texcoord.xy, ReShade::BackBuffer, float2(0.0,1.0), fMXAOBlurSteps);
MXAOFFXIV.xyz = 0;
MXAOFFXIV.w = pow(saturate(MXAOFFXIV.w),2.0);
#line 459
const float scenedepth = GetLinearDepth(texcoord.xy);
float4 color = saturate(tex2D(SamplerColorBypass, texcoord.xy));
const float colorgray = dot(color.xyz,float3(0.299,0.587,0.114));
#line 464
MXAOFFXIV.w    = 1.0-pow(1.0-MXAOFFXIV.w, fMXAOAmbientOcclusionAmount*4.0);
#line 466
if (!bMXAODebugViewEnable)
MXAOFFXIV = lerp(MXAOFFXIV, 0.0, pow(colorgray,2.0));
#line 469
MXAOFFXIV.w    = lerp(MXAOFFXIV.w, 0.0,smoothstep(max(fMXAOFadeoutStart, 0.0001), max(fMXAOFadeoutEnd, 0.0001), max(scenedepth, 0.0001)));
MXAOFFXIV.xyz  = lerp(MXAOFFXIV.xyz,0.0,smoothstep(max(fMXAOFadeoutStart, 0.0001)*0.5, max(fMXAOFadeoutEnd, 0.0001)*0.5, max(scenedepth, 0.0001)));
#line 472
float3 GI = MXAOFFXIV.w - MXAOFFXIV.xyz;
GI = saturate(1-GI);
color.xyz *= GI;
#line 476
if(bMXAODebugViewEnable) 
{
if (0 != 0)
color.xyz = GI*0.5;
else
color.xyz = GI;
}
#line 484
res = color;
}
#line 491
technique MXAOFFXIV
{
pass P0
{
VertexShader = PostProcessVS;
PixelShader  = PS_AO_Pre;
RenderTarget0 = texColorBypass;
RenderTarget1 = texDistance;
RenderTarget2 = texSurfaceNormal;
}
pass P1
{
VertexShader = PostProcessVS;
PixelShader  = PS_AO_Gen;
#line 506
}
pass P2_0
{
VertexShader = PostProcessVS;
PixelShader  = PS_AO_Blur1;
#line 512
}
pass P2_1
{
VertexShader = PostProcessVS;
PixelShader  = PS_AO_Blur2;
#line 518
}
}

