#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ZN_WF.fx"
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
#line 9 "C:\Program Files\GShade\gshade-shaders\Shaders\ZN_WF.fx"
#line 12
uniform float FRAME_BOOST <
ui_type = "slider";
ui_min = 0.0;
ui_max = 30.0;
ui_label = "Sensitivity";
ui_tooltip = "Enhances small details in the wireframe";
> = 10.0;
#line 20
uniform float3 FRAME_COLOR <
ui_label = "Wireframe Color";
ui_type = "color";
> = float3(0.2, 1.0, 0.0);
#line 25
uniform bool OVERLAY_MODE <
ui_label = "Overlay Frame";
ui_tooltip = "Overlays outline on top of the image";
> = 0;
#line 30
uniform bool FAST_AFN <
ui_label = "Normals speed mode";
ui_tooltip = "Uses less accurate normal approximations to speed up performance";
> = 0;
#line 35
uniform bool FAST_AFS <
ui_label = "Sample speed mode";
ui_tooltip = "Uses less accurate sampling approximations to speed up performance";
> = 0;
#line 41
texture WFNormalTex {Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 3;};
#line 44
sampler NormalSam { Texture = WFNormalTex;};
#line 47
float eyeDis(float2 xy, float2 pw)
{
return ReShade::GetLinearizedDepth(xy);
}
#line 53
float4 NormalBuffer(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 output;
#line 58
float FarPlane = 1000.0;
float2 aspectPos= float2(1920, 1018);
float2 PW = 0;
PW.y *= aspectPos.x / aspectPos.y;
float2 uvd = float2(1920, 1018);
float vc = eyeDis(texcoord, PW);
#line 65
if(FAST_AFN)
{
float vx = vc - eyeDis(texcoord + float2(1, 0) / uvd, PW);
float vy = vc - eyeDis(texcoord + float2(0, 1) / uvd, PW);
output = 0.5 + 0.5 * normalize(float3(vx, vy, vc / FarPlane));
}
else
{
#line 78
float vx;
float vxl = vc - eyeDis(texcoord + float2(-1, 0) / uvd, PW);
float vxl2 = vc - eyeDis(texcoord + float2(-2, 0) / uvd, PW);
float exlC = lerp(vxl2, vxl, 2.0);
#line 83
float vxr = vc - eyeDis(texcoord + float2(1, 0) / uvd, PW);
float vxr2 = vc - eyeDis(texcoord + float2(2, 0) / uvd, PW);
float exrC = lerp(vxr2, vxr, 2.0);
#line 87
if(abs(exlC - vc) > abs(exrC - vc)) {vx = -vxl;}
else {vx = vxr;}
#line 90
float vy;
float vyl = vc - eyeDis(texcoord + float2(0, -1) / uvd, PW);
float vyl2 = vc - eyeDis(texcoord + float2(0, -2) / uvd, PW);
float eylC = lerp(vyl2, vyl, 2.0);
#line 95
float vyr = vc - eyeDis(texcoord + float2(0, 1) / uvd, PW);
float vyr2 = vc - eyeDis(texcoord + float2(0, 2) / uvd, PW);
float eyrC = lerp(vyr2, vyr, 2.0);
#line 99
if(abs(eylC - vc) > abs(eyrC - vc)) {vy = -vyl;}
else {vy = vyr;}
#line 102
output = float3(0.5 + 0.5 * normalize(float3(vx, vy, vc / FarPlane)));
}
return float4(output, 1.0);
}
#line 107
float WireFrame(float2 xy)
{
float output;
if(FAST_AFS)
{
float3 norA = tex2D(NormalSam, xy).xyz;
float3 norB = tex2Dlod(NormalSam, float4(xy, 0, 1)).xyz;
norA = abs(norA - norB);
output = (norA.r + norA.g + norA.b) / 3.0;
}
else
{
#line 120
float2 res = float2(1920, 1018);
#line 122
float3 norA = tex2D(NormalSam, xy).xyz;
float3 norB;
for(int i = 0; i < 2; i++){
for(int ii = 0; ii < 2; ii++)
{
#line 128
float2 p = 0.66667 * float2(i - 0.5, ii - 0.5) / res;
norB += tex2D(NormalSam, xy + p).xyz;
#line 131
}}
norB /= 4.0;
float3 diff = abs(norA - norB);
output = (diff.r + diff.g + diff.b) / 3.0;
}
return output;
}
#line 142
float3 ZN_WF_FX(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float2 bxy = float2(1920, 1018);
float3 input = tex2D(ReShade::BackBuffer, texcoord).rgb;
float bri = saturate(FRAME_BOOST * WireFrame(texcoord));
if(OVERLAY_MODE == 1){
input = lerp(input, bri * FRAME_COLOR, bri);
}
else {return bri * FRAME_COLOR;}
#line 152
return input;
}
#line 155
technique ZN_WireFrame
{
pass
{
VertexShader = PostProcessVS;
PixelShader = NormalBuffer;
RenderTarget = WFNormalTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = ZN_WF_FX;
}
}

