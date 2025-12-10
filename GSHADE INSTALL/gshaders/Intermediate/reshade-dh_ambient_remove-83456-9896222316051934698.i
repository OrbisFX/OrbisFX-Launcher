#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_ambient_remove.fx"
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
#line 16 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_ambient_remove.fx"
#line 39
namespace DH_Ambient_Remove {
#line 43
texture ambientTex { Width = 1; Height = 1; Format = RGBA16F; };
sampler ambientSampler { Texture = ambientTex; };
#line 46
texture previousAmbientTex { Width = 1; Height = 1; Format = RGBA16F; };
sampler previousAmbientSampler { Texture = previousAmbientTex; };
#line 50
uniform int framecount < source = "framecount"; >;
uniform int random < source = "random"; min = 0; max = 1024; >;
#line 56
uniform int iDebug <
ui_category = "Debug";
ui_type = "combo";
ui_label = "Display";
ui_items = "Output\0Ambient Color\0";
ui_tooltip = "Debug the intermediate steps of the shader";
> = 0;
#line 65
uniform bool bRemoveAmbientAuto <
ui_category = "Remove ambient light";
ui_label = "Auto ambient color";
> = true;
#line 70
uniform float3 cSourceAmbientLightColor <
ui_type = "color";
ui_category = "Remove ambient light";
ui_label = "Source Ambient light color";
> = float3(31.0,44.0,42.0)/255.0;
#line 76
uniform float fSourceAmbientIntensity <
ui_type = "slider";
ui_category = "Remove ambient light";
ui_label = "Strength";
ui_min = 0; ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 85
uniform bool bRemoveAmbientPreserveBrightness <
ui_category = "Remove ambient light";
ui_label = "Preserve brighthness";
> = false;
#line 91
uniform bool bAddAmbient <
ui_category = "Add ambient light";
ui_label = "Add Ambient light";
> = false;
#line 96
uniform float3 cTargetAmbientLightColor <
ui_type = "color";
ui_category = "Add ambient light";
ui_label = "Target Ambient light color";
> = float3(13.0,13.0,13.0)/255.0;
#line 104
uniform bool bIgnoreSky <
ui_category = "Sky";
ui_label = "Ignore sky";
> = false;
#line 109
uniform float fSkyDepth <
ui_type = "slider";
ui_category = "Sky";
ui_label = "Sky Depth";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
ui_tooltip = "Define where the sky starts to prevent if to be affected by the shader";
> = 0.999;
#line 121
float safePow(float value, float power) {
return pow(abs(value),power);
}
#line 126
float3 RGBtoHSV(float3 c) {
float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
#line 131
float d = q.x - min(q.w, q.y);
float e = 1.0e-10;
return float3(float(abs(q.z + (q.w - q.y) / (6.0 * d + e))), d / (q.x + e), q.x);
}
#line 136
float3 HSVtoRGB(float3 c) {
float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
#line 142
float frameRand() {
return float(random)/1024;
}
#line 147
void PS_SavePreviousPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outAmbient : SV_Target0) {
outAmbient = tex2Dlod(ambientSampler,float4((float2(0.5,0.5)).xy,0,0));
}
#line 151
void PS_AmbientPass(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outAmbient : SV_Target0) {
if(!bRemoveAmbientAuto) discard;
#line 154
float3 previous = tex2Dlod(previousAmbientSampler,float4((float2(0.5,0.5)).xy,0,0)).rgb;
float3 result = previous;
float b = max(max((result).x,(result).y),(result).z);
bool first = false;
if(b==0) {
result = 1.0;
first = true;
}
if(framecount%60==0) {
result = 1.0;
}
#line 166
float bestB = b;
#line 170
float2 currentCoords = 0;
float2 bestCoords = float2(0.5,0.5);
float2 rand = frameRand()-0.5;
#line 174
float2 size = int2(1920,1018);
float stepSize = 1920/16.0;
float2 numSteps = size/(stepSize+1);
#line 180
for(int it=0;it<=4 && stepSize>=1;it++) {
float2 stepDim = stepSize/int2(1920,1018);
#line 183
for(currentCoords.x=bestCoords.x-stepDim.x*(numSteps.x/2);currentCoords.x<=bestCoords.x+stepDim.x*(numSteps.x/2);currentCoords.x+=stepDim.x) {
for(currentCoords.y=bestCoords.y-stepDim.y*(numSteps.y/2);currentCoords.y<=bestCoords.y+stepDim.y*(numSteps.y/2);currentCoords.y+=stepDim.y) {
float3 color = tex2Dlod(ReShade::BackBuffer,float4((currentCoords+rand*stepDim).xy,0,0)).rgb;
b = max(max((color).x,(color).y),(color).z);
if(b>0.1 && b<bestB) {
result = min(result,color);
bestB = b;
}
}
}
size = stepSize;
numSteps = 8;
stepSize = size.x/8;
}
#line 198
float opacity = b==1 ? 0 : (0.01+(max(max((result).x,(result).y),(result).z)-min(min((result).x,(result).y),(result).z)))*0.5;
outAmbient = float4(result,first ? 1 : opacity);
#line 201
}
#line 203
float3 getRemovedAmbiantColor() {
if(bRemoveAmbientAuto) {
float3 color = tex2Dlod(ambientSampler,float4((float2(0.5,0.5)).xy,0,0)).rgb;
color += max(max((color).x,(color).y),(color).z);
return color;
} else {
return cSourceAmbientLightColor;
}
}
#line 213
float3 filterAmbiantLight(float3 sourceColor) {
float3 color = sourceColor;
float3 colorHSV = RGBtoHSV(color);
float3 ral = getRemovedAmbiantColor();
float3 removedTint = ral - min(min(ral.x,ral.y),ral.z);
float3 sourceTint = color - min(min(color.x,color.y),color.z);
#line 220
float hueDist = max(max(abs(removedTint-sourceTint).x,abs(removedTint-sourceTint).y),abs(removedTint-sourceTint).z);
#line 222
float removal = saturate(1.0-hueDist*saturate(colorHSV.y+colorHSV.z));
color -= removedTint*removal;
color = saturate(color);
#line 226
if(bRemoveAmbientPreserveBrightness) {
float sB = max(max((sourceColor).x,(sourceColor).y),(sourceColor).z);
float nB = max(max((color).x,(color).y),(color).z);
#line 230
color += sB-nB;
}
#line 233
color = lerp(sourceColor,color,fSourceAmbientIntensity);
#line 235
if(bAddAmbient) {
float b = max(max((color).x,(color).y),(color).z);
color = saturate(color+pow(1.0-b,4.0)*cTargetAmbientLightColor);
}
#line 240
return color;
}
#line 244
void PS_Filter(in float4 position : SV_Position, in float2 coords : TEXCOORD, out float4 outColor : SV_Target) {
if(iDebug==0) {
float depth = ReShade::GetLinearizedDepth(coords);
float4 color = tex2Dlod(ReShade::BackBuffer,float4((coords).xy,0,0));
#line 249
bool filter = true;
if(bIgnoreSky) {
float depth = ReShade::GetLinearizedDepth(coords);
filter = depth<=fSkyDepth;
}
#line 255
if(filter) {
color.rgb = filterAmbiantLight(color.rgb);
}
#line 259
outColor = color;
} else if(iDebug==1) {
outColor = float4(getRemovedAmbiantColor(),1.0);
} else {
outColor = float4(0.0,0.0,0.0,1.0);
}
}
#line 269
technique DH_Ambient_Remove <
ui_label = "DH_Ambient_Remove 0.2.0";
ui_tooltip =
"_____________ DH_Ambient_Remove _____________\n"
"\n"
"         version 0.2.0 by AlucardDH\n"
"\n"
"_____________________________________________";
> {
pass {
VertexShader = PostProcessVS;
PixelShader = PS_SavePreviousPass;
RenderTarget = previousAmbientTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_AmbientPass;
RenderTarget = ambientTex;
#line 288
ClearRenderTargets = false;
#line 290
BlendEnable = true;
BlendOp = ADD;
SrcBlend = SRCALPHA;
SrcBlendAlpha = ONE;
DestBlend = INVSRCALPHA;
DestBlendAlpha = ONE;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_Filter;
}
}
}

