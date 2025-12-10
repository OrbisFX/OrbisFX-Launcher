#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_undither.fx"
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
#line 16 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_undither.fx"
#line 19
namespace DH {
#line 23
uniform int iPS <
ui_label = "Pixel size";
ui_type = "slider";
ui_min = 1;
ui_max = 4;
ui_step = 1;
> = 1;
#line 31
uniform int iRadius <
ui_label = "Radius";
ui_type = "slider";
ui_min = 1;
ui_max = 10;
ui_step = 1;
> = 3;
#line 39
uniform bool bKeepHue <
ui_label = "Keep source hue";
> = false;
#line 43
uniform float fHueMaxDistance <
ui_label = "Hue Max Distance";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.01;
> = 0.2;
#line 51
uniform float fSatMaxDistance <
ui_label = "Sat Max Distance";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.01;
> = 0.35;
#line 59
uniform float fLumMaxDistance <
ui_label = "Lum Max Distance";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.01;
> = 0.20;
#line 74
float RGBCVtoHUE(in float3 RGB, in float C, in float V) {
float3 Delta = (V - RGB) / C;
Delta.rgb -= Delta.brg;
Delta.rgb += float3(2,4,6);
Delta.brg = step(V, RGB) * Delta.brg;
float H;
H = max(Delta.r, max(Delta.g, Delta.b));
return frac(H / 6);
}
#line 84
float3 RGBtoHSL(in float3 RGB) {
float3 HSL = 0;
float U, V;
U = -min(RGB.r, min(RGB.g, RGB.b));
V = max(RGB.r, max(RGB.g, RGB.b));
HSL.z = ((V - U) * 0.5);
float C = V + U;
if (C != 0)
{
HSL.x = RGBCVtoHUE(RGB, C, V);
HSL.y = C / (1 - abs(2 * HSL.z - 1));
}
return HSL;
}
#line 99
float3 HUEtoRGB(in float H)
{
float R = abs(H * 6 - 3) - 1;
float G = 2 - abs(H * 6 - 2);
float B = 2 - abs(H * 6 - 4);
return saturate(float3(R,G,B));
}
#line 107
float3 HSLtoRGB(in float3 HSL)
{
float3 RGB = HUEtoRGB(HSL.x);
float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
return (RGB - 0.5) * C + HSL.z;
}
#line 114
float hueDistance(float3 hsl1,float3 hsl2) {
float minH;
float maxH;
if(hsl1.x==hsl2.x) {
return 0;
}
if(hsl1.x<hsl2.x) {
minH = hsl1.x;
maxH = hsl2.x;
} else {
minH = hsl1.x;
maxH = hsl2.x;
}
#line 128
return 2*min(maxH-minH,1+minH-maxH);
}
#line 134
void PS_undither(in float4 position : SV_Position, in float2 coords : TEXCOORD, out float4 outPixel : SV_Target)
{
float3 rgb = tex2Dlod(ReShade::BackBuffer,float4(coords,0,0)).rgb;
float3 hsl = RGBtoHSL(rgb);
#line 139
float maxDist = iRadius*iRadius;
float2 pixelSize = ReShade::GetPixelSize();
#line 142
float2 minCoords = saturate(coords-iRadius*pixelSize);
float2 maxCoords = saturate(coords+iRadius*pixelSize);
#line 145
float2 currentCoords;
#line 148
float3 sumRgb;
float sumWeight;
#line 151
for(currentCoords.x=minCoords.x;currentCoords.x<=maxCoords.x;currentCoords.x+=pixelSize.x) {
for(currentCoords.y=minCoords.y;currentCoords.y<=maxCoords.y;currentCoords.y+=pixelSize.y) {
int2 delta = (currentCoords-coords)/pixelSize;
float posDist = dot(delta,delta);
#line 156
if(posDist>maxDist) {
continue;
}
#line 161
float3 currentRgb = tex2Dlod(ReShade::BackBuffer,float4(currentCoords,0,0)).xyz;
float3 currentHsl = RGBtoHSL(currentRgb);
#line 164
float satDist = abs(hsl.y-currentHsl.y);
if(satDist>fSatMaxDistance) {
continue;
}
#line 169
float lumDist = abs(hsl.z-currentHsl.z);
if(lumDist>fLumMaxDistance) {
continue;
}
#line 174
float hueDist = hueDistance(hsl,currentHsl);
if(hueDist>fHueMaxDistance) {
continue;
}
#line 179
float weight = (1-hueDist)+(1-satDist)+(1-lumDist)+(1+maxDist-posDist)/(maxDist+1);
#line 181
sumWeight += weight;
sumRgb += weight*currentRgb;
}
}
#line 186
float3 resultRgb = sumRgb/sumWeight;
if(bKeepHue) {
float3 resultHsl = RGBtoHSL(resultRgb);
resultHsl.x = hsl.x;
resultRgb = HSLtoRGB(resultHsl);
}
outPixel = float4(resultRgb,1.0);
}
#line 198
technique DH_undither <
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_undither;
}
#line 207
}
#line 209
}

