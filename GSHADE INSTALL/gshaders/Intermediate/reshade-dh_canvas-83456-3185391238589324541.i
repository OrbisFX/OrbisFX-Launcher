#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_canvas.fx"
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
#line 9 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_canvas.fx"
#line 18
namespace DH_Canvas_020 {
#line 22
texture canvasPBRTex < source = "dh_canvas2.png" ; > { Width = 1600; Height = 1600; MipLevels = 1; Format = RGBA8; };
sampler canvasPBRSampler { Texture = canvasPBRTex; AddressU=REPEAT;AddressV=REPEAT;AddressW=REPEAT;};
#line 25
texture canvasNormalTex { Width = 1920; Height = 1018; };
sampler canvasNormalSampler { Texture = canvasNormalTex; };
#line 29
uniform int framecount < source = "framecount"; >;
#line 33
uniform float fCanvasHeight <
ui_category = "Canvas";
ui_label = "Height";
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_step = 0.01;
> = 0.5;
#line 42
uniform float2 fCanvasScale <
ui_category = "Canvas";
ui_label = "Scale XY";
ui_type = "slider";
ui_min = 0.01;
ui_max = 2.0;
ui_step = 0.01;
> = float2(0.7,0.5);
#line 53
uniform int iLightType <
ui_category = "Light";
ui_type = "combo";
ui_label = "Light type";
ui_items = "Point\0Horizontal bar\0";
> = 0;
#line 60
uniform float2 fLightPositionXY <
ui_category = "Light";
ui_label = "Position X,Y";
ui_type = "slider";
ui_min = -1.0;
ui_max = 2.0;
ui_step = 0.001;
> = float2(0.5,-0.15);
#line 69
uniform float fLightPositionZ <
ui_category = "Light";
ui_label = "Position Z";
ui_type = "slider";
ui_min = 0.0;
ui_max = 16.0;
ui_step = 0.001;
> = 7.0;
#line 78
uniform float3 cLightColor <
ui_category = "Light";
ui_label = "Color";
ui_type = "color";
ui_min = 0;
ui_max = 1.0;
ui_step = 0.001;
> = float3(1,1,1);
#line 87
uniform float fLightMinBrightness <
ui_category = "Light";
ui_label = "Min brightness";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.2;
#line 96
uniform bool bUseGreenAsReflexivity <
ui_category = "Reflection";
ui_label = "Use green channel as reflexivity";
> = true;
#line 101
uniform float fLightReflexion <
ui_category = "Reflection";
ui_label = "Intensity";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.2;
#line 110
uniform bool bBlueAsAmbientOcclusion <
ui_category = "Ambient Occlusion";
ui_label = "Use blue channel as AO";
> = true;
#line 115
uniform float fAmbientOcclusion <
ui_category = "Ambient Occlusion";
ui_label = "Intensity";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.2;
#line 128
float4 getPBR(float2 coords) {
return tex2D(canvasPBRSampler,(coords/fCanvasScale)*float2(int2(1920,1018))/int2(1600,1600));
}
#line 132
float3 getWorldPosition(float2 coords) {
float4 pbr = getPBR(coords);
float depth = (1.0-pbr.x)*fCanvasHeight;
return float3(coords*int2(1920,1018),depth);
}
#line 138
float4 computeNormal(float3 wpCenter,float3 wpNorth,float3 wpEast) {
return float4(normalize(cross(wpCenter - wpNorth, wpCenter - wpEast)),1.0);
}
#line 142
float4 computeNormal(float2 coords) {
float3 offset = float3(ReShade::GetPixelSize(),0);
float3 posCenter = getWorldPosition(coords);
float3 posNorth  = getWorldPosition(coords - offset.zy);
float3 posEast   = getWorldPosition(coords + offset.xz);
#line 148
return (computeNormal(posCenter,posNorth,posEast)+1.0)*0.5;
}
#line 151
float3 getNormal(float2 coords) {
return tex2Dlod(canvasNormalSampler,float4((coords).xy,0,0)).xyz*2.0-1.0;
}
#line 157
void PS_Normal(in float4 position : SV_Position, in float2 coords : TEXCOORD, out float4 outPixel : SV_Target) {
outPixel = computeNormal(coords);
}
#line 161
void PS_result(in float4 position : SV_Position, in float2 coords : TEXCOORD, out float4 outPixel : SV_Target) {
float4 color = tex2D(ReShade::BackBuffer,coords);
float3 pbr = getPBR(coords).rgb;
#line 165
float3 wp = getWorldPosition(coords);
float3 normal = getNormal(coords);
#line 168
float3 lightPosition;
#line 170
if(iLightType==0) { 
lightPosition = float3(fLightPositionXY*int2(1920,1018),-fLightPositionZ*100);
} else if(iLightType==1) { 
lightPosition = float3(float2(coords.x,fLightPositionXY.y)*int2(1920,1018),-fLightPositionZ*100);
} else if(iLightType==2) { 
lightPosition = float3(fLightPositionXY*int2(1920,1018),-fLightPositionZ*100);
}
#line 181
float3 lightVector = normalize(wp - lightPosition);
float direction = dot(lightVector,normal);
#line 184
float3 coef = saturate(direction);
#line 188
if(bBlueAsAmbientOcclusion) {
coef *= lerp(1,pbr.b*cLightColor,fAmbientOcclusion);
}
#line 192
coef = max(coef,fLightMinBrightness);
#line 194
float3 result = saturate(color.rgb*coef);
#line 196
if(fLightReflexion>0) {
float3 reflected = reflect(lightVector,normal);
float directionReflection = dot(reflected,float3(0,0,-1));
if(bUseGreenAsReflexivity) {
directionReflection *= pbr.g;
}
result = saturate(result + cLightColor*fLightReflexion*saturate(directionReflection));
}
#line 205
outPixel = float4(result,1.0);
}
#line 210
technique DH_Canvas < ui_label = "DH_Canvas 0.2.0"; > {
pass {
VertexShader = PostProcessVS;
PixelShader = PS_Normal;
RenderTarget = canvasNormalTex;
}
pass {
VertexShader = PostProcessVS;
PixelShader = PS_result;
}
}
#line 222
}

