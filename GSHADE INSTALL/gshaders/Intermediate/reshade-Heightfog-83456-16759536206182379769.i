// M_2PI=6.283185
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Heightfog.fx"
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
#line 49 "C:\Program Files\GShade\gshade-shaders\Shaders\Heightfog.fx"
#line 50
namespace Heightfog
{
#line 57
uniform float3 FogColor <
ui_category = "General";
ui_label = "Fog color";
ui_type = "color";
> = float3(0.8, 0.8, 0.8);
#line 63
uniform float FogDensity <
ui_category = "General";
ui_type = "slider";
ui_label = "Fog density";
ui_min = 0.000; ui_max=1.000;
ui_step = 0.001;
ui_tooltip = "Controls how thick the fog is at its thickest point";
> = 1.0;
#line 72
uniform float OveralFogDensityMax <
ui_type = "drag";
ui_label = "Overall fog density maximum";
ui_min = 0.0; ui_max=1.0;
ui_step = 0.01;
ui_category = "General";
> = 1.0;
#line 80
uniform float FogStart <
ui_category = "General";
ui_label = "Fog start";
ui_type = "slider";
ui_min = 0.0; ui_max=1.000;
ui_tooltip = "Controls where the fog starts, relative to the camera";
ui_step = 0.001;
> = 0;
#line 89
uniform float FogCurve <
ui_category = "General";
ui_type = "slider";
ui_label = "Fog curve";
ui_min = 0.001; ui_max=1000.00;
ui_tooltip = "Controls how quickly the fog gets thicker";
ui_step = 0.1;
> = 25;
#line 98
uniform float FoV <
ui_category = "General";
ui_type = "slider";
ui_label = "FoV (degrees)";
ui_tooltip = "The Field of View of the scene, for being able to correctly place the fog in the scene";
ui_min = 10; ui_max=140;
ui_step = 0.1;
> = 60;
#line 107
uniform float2 PlaneOrientation <
ui_category = "General";
ui_type = "slider";
ui_label = "Fog plane orientation";
ui_tooltip = "Rotates the fog plane to match the scene.\nFirst value is roll, second value is up/down";
ui_min = -2; ui_max=2;
ui_step = 0.001;
> = float2(1.751, -0.464);
#line 116
uniform float PlaneZ <
ui_category = "General";
ui_type = "slider";
ui_label = "Fog plane Z";
ui_tooltip = "Moves the fog plane up/down. Negative values are moving the plane downwards";
ui_min = -2; ui_max=2;
ui_step = 0.001;
> = -0.001;
#line 125
uniform bool EvenlyDistributeFog <
ui_category = "General";
ui_label = "Fog is evenly distributed";
ui_tooltip = "If checked it'll evenly distribute fog so fog close by is as thick as further away.";
> = false;
#line 131
uniform bool MovingFog <
ui_label = "Moving fog";
ui_tooltip = "Controls whether the fog clouds are static or moving across the plane";
ui_category = "Cloud configuration";
> = false;
#line 137
uniform float MovementSpeed <
ui_type = "slider";
ui_label = "Cloud movement speed";
ui_tooltip = "Configures the speed the clouds move. 0.0 is no movement, 1.0 is max speed";
ui_min = 0; ui_max=1;
ui_step = 0.01;
ui_category = "Cloud configuration";
> = 0.4;
#line 146
uniform float FogCloudScaleMax <
ui_type = "drag";
ui_label = "Cloud scale (Max)";
ui_tooltip = "Configures the cloud size of the fog, used for max values";
ui_min = 0.0; ui_max=20;
ui_step = 0.01;
ui_category = "Cloud configuration";
> = 1.0;
#line 155
uniform float FogCloudScaleVertical <
ui_type = "slider";
ui_label = "Cloud scale (vertical)";
ui_tooltip = "Configures the cloud size of the fog, vertically";
ui_min = 0.0; ui_max=20;
ui_step = 0.01;
ui_category = "Cloud configuration";
> = 1.0;
#line 164
uniform float FogCloudScaleHorizontal <
ui_type = "slider";
ui_label = "Cloud scale (horizotal)";
ui_tooltip = "Configures the cloud size of the fog, horizontally";
ui_min = 0.0; ui_max=10;
ui_step = 0.01;
ui_category = "Cloud configuration";
> = 1.0;
#line 173
uniform float FogCloudFactor <
ui_type = "slider";
ui_label = "Cloud factor";
ui_tooltip = "Configures the amount of cloud forming in the fog.\n1.0 means full clouds, 0.0 means no clouds";
ui_min = 0; ui_max=1;
ui_step = 0.01;
ui_category = "Cloud configuration";
> = 1.0;
#line 182
uniform float2 FogCloudOffset <
ui_type = "slider";
ui_label = "Cloud offset";
ui_tooltip = "Configures the offset in the cloud texture of the fog.\nUse this instead of Moving fog to control the cloud position";
ui_min = 0.0; ui_max=1;
ui_step = 0.01;
ui_category = "Cloud configuration";
> = float2(0.0, 0.0);
#line 191
uniform float2 FogMaxOffset <
ui_type = "drag";
ui_label = "Max offsets";
ui_tooltip = "Configures the offset in the cloud texture of the fog.\nUse this instead of Moving fog to control the cloud position";
ui_min = 0.0; ui_max=1;
ui_step = 0.01;
ui_category = "Cloud configuration";
> = float2(0.0, 0.0);
#line 200
uniform bool UseFilterCircle <
ui_category = "Filter circle edge filtering";
ui_tooltip = "Controls whether the edge filter is active or not";
> = false;
uniform bool FocusPointViewFilterCircleOnMouseDown <
ui_category = "Filter circle edge filtering";
ui_label = "Show filter circle on mouse down";
ui_tooltip = "If checked, an overlay is shown with the current filter circle.\Red means no fog will be present,\ntransparent means fog will be present";
> = false;
uniform float2 FilterCircleCenterPoint <
ui_category = "Filter circle edge filtering";
ui_label = "Center point";
ui_type = "drag";
ui_step = 0.001;
ui_min = 0.000; ui_max = 1.000;
ui_tooltip = "The X and Y coordinates of the filter circle center\n0,0 is the upper left corner, and 0.5, 0.5 is at the center of the screen.";
> = float2(0.5, 0.5);
uniform float FilterCircleRadius <
ui_category = "Filter circle edge filtering";
ui_label = "Radius";
ui_type = "drag";
ui_min = 0.000; ui_max = 2.000;
ui_step = 0.001;
ui_tooltip = "The radius of the filter circle.\nAll points outside this circle are not or only partially fogged";
> = 0.1;
uniform float2 FilterCircleDeformFactors <
ui_category = "Filter circle edge filtering";
ui_label = "Deform factors";
ui_type = "drag";
ui_min = 0.000; ui_max = 2.000;
ui_step = 0.001;
ui_tooltip = "The radius factors for width and height of the filter circle.\n1.0 means no deformation, another value means deformation in that direction";
> = float2(1.0, 1.0);
uniform float FilterCircleRotationFactor <
ui_category = "Filter circle edge filtering";
ui_label = "Rotation factor";
ui_type = "drag";
ui_min = 0.000; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "The rotation factor of the filter circle";
> = 0.0;
uniform float FilterCircleFeather <
ui_category = "Filter circle edge filtering";
ui_label = "Feather";
ui_type = "drag";
ui_min = 0.000; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "The feather area within the filter circle.\n1.0 means the whole inner area is feathered,\n0.0 means no feather area.";
> = 0.1;
#line 275
uniform float timer < source = "timer"; >; 
uniform bool LeftMouseDown < source = "mousebutton"; keycode = 0; toggle = false; >;
#line 290
texture texFogNoise				< source = "fognoise.jpg"; > { Width = 512; Height = 512; Format = RGBA8; };
texture texFilterCircle { Width = 1920; Height = 1018; Format = R16F; };
#line 293
sampler SamplerFogNoise				{ Texture = texFogNoise; AddressU = WRAP; AddressV = WRAP; AddressW = WRAP;};
sampler samplerFilterCircle { Texture = texFilterCircle; };
#line 296
struct VSPIXELINFO
{
float4 vpos : SV_Position;
float2 texCoords : TEXCOORD0;
float2x2 rotationMatrix: TEXCOORD6;
float2 centerDisplacementDelta: TEXCOORD8;
float featherRadius: TEXCOORD9;
};
#line 311
float3 uvToProj(float2 uv, float z)
{
#line 314
const float3 uvtoprojADD = float3(-tan(radians(FoV) * 0.5).xx, 1.0) * float2(1.0, 1920 * (1.0 / 1018)).yxx;
const float3 uvtoprojMUL = float3(-2.0 * uvtoprojADD.xy, 0.0);
#line 317
return (uv.xyx * uvtoprojMUL + uvtoprojADD) * z;
}
#line 322
float planeIntersect(float3 ro, float3 rd, float4 p)
{
return -(dot(ro,p.xyz)+p.w)/dot(rd,p.xyz);
}
#line 333
VSPIXELINFO VS_PixelInfo(in uint id : SV_VertexID)
{
VSPIXELINFO pixelInfo;
#line 337
pixelInfo.texCoords.x = (id == 2) ? 2.0 : 0.0;
pixelInfo.texCoords.y = (id == 1) ? 2.0 : 0.0;
pixelInfo.vpos = float4(pixelInfo.texCoords * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 341
float2 sincosFactor = float2(0,0);
sincos(6.28318530717958 * FilterCircleRotationFactor, sincosFactor.x, sincosFactor.y);
pixelInfo.rotationMatrix = float2x2(sincosFactor.y, sincosFactor.x, -sincosFactor.x, sincosFactor.y);
#line 345
pixelInfo.centerDisplacementDelta = FilterCircleCenterPoint - float2(0.5, 0.5);
pixelInfo.featherRadius = FilterCircleRadius - (FilterCircleRadius * FilterCircleFeather);
return pixelInfo;
}
#line 356
void PS_FogIt(VSPIXELINFO pixelInfo, out float4 fragment : SV_Target0)
{
float4 originalFragment = tex2D(ReShade::BackBuffer, pixelInfo.texCoords);
float depth = lerp(1.0, 1000.0, ReShade::GetLinearizedDepth(pixelInfo.texCoords))/1000.0;
float phi = PlaneOrientation.x * 6.283185; 
float theta = PlaneOrientation.y * 3.1415927;
#line 363
float3 planeNormal;
planeNormal.x = cos(phi)*sin(theta);
planeNormal.y = sin(phi)*sin(theta);
planeNormal.z = cos(theta);
planeNormal = normalize(planeNormal); 
#line 369
float4 iqplane = float4(planeNormal, PlaneZ);	
float3 scenePosition = uvToProj(pixelInfo.texCoords, depth);
float sceneDistance = length(scenePosition); 
float3 rayDirection = scenePosition / sceneDistance; 
#line 375
float distanceToIntersect = planeIntersect(0, rayDirection, iqplane); 
float speedFactor = 100000.0 * (1-(MovementSpeed-0.01));
float fogTextureValueHorizontally = tex2D(SamplerFogNoise, (pixelInfo.texCoords + FogCloudOffset) * FogCloudScaleHorizontal + (MovingFog ? frac(timer / speedFactor) : 0.0)).r;
float fogTextureValueVertically = tex2D(SamplerFogNoise, (pixelInfo.texCoords + FogCloudOffset) * FogCloudScaleVertical + (MovingFog ? frac(timer / speedFactor) : 0.0)).r;
float fogMaxValue = tex2D(SamplerFogNoise, (pixelInfo.texCoords + FogMaxOffset) * FogCloudScaleMax + (MovingFog ? frac(timer / speedFactor) : 0.0)).r;
#line 381
distanceToIntersect = distanceToIntersect < 0 ? 10000000 : distanceToIntersect; 
distanceToIntersect *= lerp(1.0, fogTextureValueVertically, FogCloudFactor);
float distanceTraveled = (depth - distanceToIntersect);
distanceTraveled = saturate(distanceTraveled-saturate(0.5 * (FogStart - distanceToIntersect)));
distanceTraveled = EvenlyDistributeFog ? distanceTraveled / 50.0f : (distanceTraveled * distanceTraveled);
distanceTraveled *= fogMaxValue;
float filterCircleValue = UseFilterCircle ? tex2Dlod(samplerFilterCircle, float4(pixelInfo.texCoords, 0, 0)).r : 0.0f;
float lerpFactor = saturate(distanceTraveled * 10.0 * FogCurve * FogDensity * lerp(1.0, fogTextureValueHorizontally, FogCloudFactor)) * OveralFogDensityMax * saturate(1-filterCircleValue);
fragment.rgb = sceneDistance < distanceToIntersect ? originalFragment.rgb
: lerp(originalFragment.rgb, FogColor.rgb, lerpFactor);
fragment.a = 1.0;
#line 393
if(FocusPointViewFilterCircleOnMouseDown && LeftMouseDown)
{
fragment.rgb = lerp(fragment.rgb, float3(1.0f, 0.0f, 0.0f), filterCircleValue * 0.7f);
}
}
#line 401
void PS_CreateFilterCircle(VSPIXELINFO pixelInfo, out float4 fragment : SV_Target0)
{
fragment = 0.0f;
#line 407
float2 texcoordCenterNormalized = mul(((pixelInfo.texCoords-pixelInfo.centerDisplacementDelta) - 0.5), pixelInfo.rotationMatrix) * FilterCircleDeformFactors;
float2 focusPointCenterNormalized = (FilterCircleCenterPoint-pixelInfo.centerDisplacementDelta) - 0.5;
float texcoordDistance = distance(texcoordCenterNormalized, focusPointCenterNormalized);
#line 412
if(texcoordDistance < pixelInfo.featherRadius)
{
#line 415
fragment = 0.0f;
}
else
{
if(texcoordDistance > FilterCircleRadius)
{
#line 422
fragment = 1.0f;
}
else
{
#line 427
float featherbandWidth = FilterCircleRadius - pixelInfo.featherRadius;
fragment = lerp(0.0f, 1.0f, (texcoordDistance - pixelInfo.featherRadius) / (featherbandWidth + (featherbandWidth==0)));
}
}
}
#line 433
technique HeightFog
#line 435
< ui_tooltip = "Height Fog "
"1.0.5"
"\n===========================================\n\n"
"Height Fog shader to introduce a volumetric fog plane into a 3D scene,\n"
"Height Fog was written by Marty McFly and Otis_Inf"; >
#line 441
{
pass CreateFilterCircle { VertexShader = VS_PixelInfo; PixelShader = PS_CreateFilterCircle; RenderTarget = texFilterCircle; }
pass ApplyFog { VertexShader = VS_PixelInfo; PixelShader = PS_FogIt; }
}
}

