#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MeshEdges.fx"
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
#line 39 "C:\Program Files\GShade\gshade-shaders\Shaders\MeshEdges.fx"
#line 40
uniform int iUIBackground <
ui_type = "combo";
ui_label = "Background Type";
ui_items = "Backbuffer\0Color\0";
> = 1;
#line 46
uniform float3 fUIColorBackground <
ui_type = "color";
ui_label = "Color Background";
> = float3(1.0, 1.0, 1.0);
#line 51
uniform float3 fUIColorLines <
ui_type = "color";
ui_label = "Color Lines";
> = float3(0.0, 0.0, 0.0);
#line 56
uniform float fUIStrength <
ui_type = "slider";
ui_label = "Strength";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
> = 1.0;
#line 68
float3 MeshEdges_PS(float4 vpos:SV_Position, float2 texcoord:TexCoord):SV_Target {
const float3 backbuffer = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float4 pix = float4(float2((1.0 / 1920), (1.0 / 1018)), -float2((1.0 / 1920), (1.0 / 1018)));
#line 73
float c = ReShade::GetLinearizedDepth(texcoord);
#line 75
float4 depthEven = float4(  ReShade::GetLinearizedDepth(texcoord + float2(0.0, pix.w)),
ReShade::GetLinearizedDepth(texcoord + float2(0.0, pix.y)),
ReShade::GetLinearizedDepth(texcoord + float2(pix.x, 0.0)),
ReShade::GetLinearizedDepth(texcoord + float2(pix.z, 0.0))   );
#line 80
float4 depthOdd  = float4(  ReShade::GetLinearizedDepth(texcoord + float2(pix.x, pix.w)),
ReShade::GetLinearizedDepth(texcoord + float2(pix.z, pix.y)),
ReShade::GetLinearizedDepth(texcoord + float2(pix.x, pix.y)),
ReShade::GetLinearizedDepth(texcoord + float2(pix.z, pix.w)) );
#line 86
const float2 mind = float2(min(depthEven.x, min(depthEven.y, min(depthEven.z, depthEven.w))), min(depthOdd.x, min(depthOdd.y, min(depthOdd.z, depthOdd.w))));
const float2 maxd = float2(max(depthEven.x, max(depthEven.y, max(depthEven.z, depthEven.w))), max(depthOdd.x, max(depthOdd.y, max(depthOdd.z, depthOdd.w))));
const float span = max(maxd.x, maxd.y) - min(mind.x, mind.y) + 0.00001;
c /= span;
depthEven /= span;
depthOdd /= span;
#line 93
const float4 diffsEven = abs(depthEven - c);
const float4 diffsOdd = abs(depthOdd - c);
#line 96
const float2 retVal = float2( max(abs(diffsEven.x - diffsEven.y), abs(diffsEven.z - diffsEven.w)),
max(abs(diffsOdd.x - diffsOdd.y), abs(diffsOdd.z - diffsOdd.w))     );
#line 99
const float lineWeight = max(retVal.x, retVal.y);
#line 101
if (iUIBackground == 0)
return lerp(backbuffer, fUIColorLines, lineWeight * fUIStrength);
else
return lerp(fUIColorBackground, fUIColorLines, lineWeight * fUIStrength);
}
#line 107
technique MeshEdges {
pass {
VertexShader = PostProcessVS;
PixelShader = MeshEdges_PS;
#line 112
}
}

