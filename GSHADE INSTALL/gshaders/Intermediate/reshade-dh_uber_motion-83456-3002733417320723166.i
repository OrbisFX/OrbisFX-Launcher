#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_uber_motion.fx"
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
#line 15 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_uber_motion.fx"
#line 28
texture texMotionVectors { Width = 1920; Height = 1018; Format = RG16F; };
sampler sTexMotionVectorsSampler { Texture = texMotionVectors; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
#line 31
namespace DH_UBER_MOTION_020 {
#line 36
texture halfMotionTex { Width = 1920>>1; Height = 1018>>1; Format = RG16F; };
sampler halfMotionSampler { Texture = halfMotionTex; };
#line 40
texture colorTex { Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 6;  };
sampler colorSampler { Texture = colorTex; MinLOD = 0.0f; MaxLOD = 5.0f;};
#line 43
texture previousColorTex { Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 6;  };
sampler previousColorSampler { Texture = previousColorTex; MinLOD = 0.0f; MaxLOD = 5.0f;};
#line 47
texture depthTex { Width = 1920; Height = 1018; Format = R16F; };
sampler depthSampler { Texture = depthTex; };
#line 50
texture previousDepthTex { Width = 1920; Height = 1018; Format = R16F; };
sampler previousDepthSampler { Texture = previousDepthTex; };
#line 55
uniform int iMotionRadius <
ui_type = "slider";
ui_category = "Motion Detection";
ui_label = "Radius";
ui_min = 1; ui_max = 8;
ui_step = 1;
ui_tooltip = "Define the max distance of motion detection.\n"
"Lower=better performance, less precise detection in fast motion\n"
"Higher=better motion detection, less performance\n"
"/!\\ HAS A BIG INPACT ON PERFORMANCES";
> = 4;
#line 67
uniform bool bUnjitterDepth <
ui_category = "Motion Detection";
ui_label = "Unjitter Depth";
ui_tooltip = "Improve motion detection in case of upscaling (TAA/DLSS/FSR)";
> = true;
#line 87
float getDepth(float2 coords) {
return tex2Dlod(depthSampler,float4((coords).xy,0,0)).x;
}
#line 91
float3 getFirst(sampler sourceSampler, float2 coords) {
return tex2Dlod(sourceSampler,float4((coords).xy,0,0)).rgb;
}
#line 95
float3 getSecond(sampler sourceSampler, float2 coords) {
return tex2Dlod(sourceSampler,float4(((coords-ReShade::GetPixelSize()*8)).xy,0,2.5)).rgb;
}
#line 99
float motionDistance(float2 refCoords, float3 refColor,float3 refAltColor,float refDepth, float2 currentCoords) {
float currentDepth = tex2Dlod(previousDepthSampler,float4((currentCoords).xy,0,0)).x;
float diffDepth = abs(refDepth-currentDepth);
#line 103
float3 currentColor = getFirst(previousColorSampler,currentCoords);
float3 currentAltColor = getSecond(previousColorSampler,currentCoords);
#line 106
float3 diffColor = abs(currentColor-refColor);
float3 diffAltColor = abs(currentAltColor-refAltColor);
#line 109
float dist = distance(refCoords,currentCoords)*0.5;
dist += max(max(diffColor.x,diffColor.y),diffColor.z);
dist += max(max(diffAltColor.x,diffAltColor.y),diffAltColor.z);
dist *= 0.01+diffDepth;
#line 114
return dist;
}
#line 117
void PS_MotionPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float2 outMotion : SV_Target0) {
#line 119
float2 refCoords = coords;
#line 121
float2 pixelSize = ReShade::GetPixelSize();
float3 refColor = getFirst(colorSampler,coords);
float3 refAltColor = getSecond(colorSampler,coords);
float refDepth = getDepth(coords);
#line 126
int2 delta = 0;
float deltaStep = 1;
#line 129
float2 currentCoords = refCoords;
float dist = motionDistance(coords,refColor,refAltColor,refDepth,currentCoords);
#line 132
float bestDist = dist;
#line 134
float2 bestMotion = currentCoords;
#line 136
[loop]
#line 138
for(int radius=iMotionRadius;radius>=1;radius--) {
deltaStep = 4*radius;
[loop]
for(int dx=0;dx<=radius;dx++) {
#line 143
delta.x = dx;
delta.y = radius-dx;
#line 146
currentCoords = refCoords+pixelSize*delta*deltaStep;
dist = motionDistance(coords,refColor,refAltColor,refDepth,currentCoords);
if(dist<bestDist) {
bestDist = dist;
bestMotion = currentCoords;
}
#line 153
if(dx!=0) {
delta.x = -dx;
#line 156
currentCoords = refCoords+pixelSize*delta*deltaStep;
dist = motionDistance(coords,refColor,refAltColor,refDepth,currentCoords);
if(dist<bestDist) {
bestDist = dist;
bestMotion = currentCoords;
}
}
#line 164
if(delta.y!=0) {
delta.x = dx;
delta.y = -(delta.y);
#line 168
currentCoords = refCoords+pixelSize*delta*deltaStep;
dist = motionDistance(coords,refColor,refAltColor,refDepth,currentCoords);
if(dist<bestDist) {
bestDist = dist;
bestMotion = currentCoords;
}
}
#line 176
if(dx!=0) {
delta.x = -dx;
#line 179
currentCoords = refCoords+pixelSize*delta*deltaStep;
dist = motionDistance(coords,refColor,refAltColor,refDepth,currentCoords);
if(dist<bestDist) {
bestDist = dist;
bestMotion = currentCoords;
}
}
}
}
#line 189
outMotion = bestMotion-coords;
}
#line 192
float2 offsetCoords(float2 coords,float dx,float dy) {
return coords+float2(dx,dy);
}
#line 196
float2 offsetCoordsPixels(float2 coords,float dx,float dy) {
return coords+float2(dx,dy)*ReShade::GetPixelSize()*2;
}
#line 200
void PS_InputPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0, out float4 outDepth : SV_Target1) {
outColor = tex2Dlod(ReShade::BackBuffer,float4(coords,0,0));
float depth = ReShade::GetLinearizedDepth(coords);
if(bUnjitterDepth) {
float2 previousCoords = coords + tex2Dlod(sTexMotionVectorsSampler,float4((coords).xy,0,0)).xy;
float previousDepth = tex2Dlod(previousDepthSampler,float4((previousCoords).xy,0,0)).x;
depth = lerp(previousDepth,depth,0.333);
}
outDepth = float4(depth,0,0,1);
}
#line 211
void PS_SavePass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0, out float4 outDepth : SV_Target1, out float2 outMotion : SV_Target2) {
outColor = tex2Dlod(colorSampler,float4((coords).xy,0,0));
outDepth = tex2Dlod(depthSampler,float4((coords).xy,0,0));
outMotion = tex2Dlod(halfMotionSampler,float4((coords).xy,0,0)).xy;
}
#line 220
technique DH_UBER_MOTION_020 <
ui_label = "DH_UBER_Motion 0.2.0";
ui_tooltip =
"_____________ DH_UBER_Motion _____________\n"
"\n"
"         version 0.2.0 by AlucardDH\n"
"\n"
"_____________________________________________";
> {
pass {
VertexShader = PostProcessVS;
PixelShader = PS_InputPass;
RenderTarget = colorTex;
RenderTarget1 = depthTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_MotionPass;
RenderTarget = halfMotionTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_SavePass;
RenderTarget = previousColorTex;
RenderTarget1 = previousDepthTex;
RenderTarget2 = texMotionVectors;
}
}
}

