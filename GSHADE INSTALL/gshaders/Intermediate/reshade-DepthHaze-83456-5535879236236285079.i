#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\DepthHaze.fx"
#line 38
uniform float EffectStrength <
ui_type = "slider";
ui_min = 0.0; ui_max=1.0;
ui_tooltip = "The strength of the effect. Range from 0.0, which means no effect, till 1.0 which means pixels are 100% blurred based on depth.";
> = 0.9;
uniform float3 FogColor <
ui_type= "color";
ui_tooltip = "Color of the fog, in (red , green, blue)";
> = float3(0.8,0.8,0.8);
uniform float FogStart <
ui_type = "slider";
ui_min = 0.0; ui_max=1.0;
ui_tooltip = "Start of the fog. 0.0 is at the camera, 1.0 is at the horizon, 0.5 is halfway towards the horizon. Before this point no fog will appear.";
> = 0.2;
uniform float FogFactor <
ui_type = "slider";
ui_min = 0.0; ui_max=1.0;
ui_tooltip = "The amount of fog added to the scene. 0.0 is no fog, 1.0 is the strongest fog possible.";
> = 0.2;
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
#line 59 "C:\Program Files\GShade\gshade-shaders\Shaders\DepthHaze.fx"
#line 63
texture   Otis_FragmentBuffer1 	{ Width = 1920; Height = 1018; Format = RGBA8;};
texture   Otis_FragmentBuffer2 	< pooled = true; > { Width = 1920; Height = 1018; Format = RGBA8;};
#line 69
sampler2D Otis_SamplerFragmentBuffer2 { Texture = Otis_FragmentBuffer2; };
sampler2D Otis_SamplerFragmentBuffer1 {	Texture = Otis_FragmentBuffer1; };
#line 75
float CalculateWeight(float distanceFromSource, float sourceDepth, float neighborDepth)
{
return (1.0 - abs(sourceDepth - neighborDepth)) * (1/distanceFromSource) * neighborDepth;
}
#line 80
void PS_Otis_DEH_BlockBlurHorizontal(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD, out float4 outFragment : SV_Target0)
{
float4 color = tex2D(ReShade::BackBuffer, texcoord);
const float colorDepth = ReShade::GetLinearizedDepth(texcoord).r;
float n = 1.0f;
#line 86
[loop]
for(float i = 1; i < 5; ++i)
{
float2 sourceCoords = texcoord + float2(i * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0);
float weight = CalculateWeight(i, colorDepth, ReShade::GetLinearizedDepth(sourceCoords).r);
color += (tex2D(ReShade::BackBuffer, sourceCoords) * weight);
n+=weight;
#line 94
sourceCoords = texcoord - float2(i * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0);
weight = CalculateWeight(i, colorDepth, ReShade::GetLinearizedDepth(sourceCoords).r);
color += (tex2D(ReShade::BackBuffer, sourceCoords) * weight);
n+=weight;
}
outFragment = color/n;
}
#line 102
void PS_Otis_DEH_BlockBlurVertical(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD, out float4 outFragment : SV_Target0)
{
float4 color = tex2D(Otis_SamplerFragmentBuffer1, texcoord);
const float colorDepth = ReShade::GetLinearizedDepth(texcoord).r;
float n=1.0f;
#line 108
[loop]
for(float j = 1; j < 5; ++j)
{
float2 sourceCoords = texcoord + float2(0.0, j * float2((1.0 / 1920), (1.0 / 1018)).y);
float weight = CalculateWeight(j, colorDepth, ReShade::GetLinearizedDepth(sourceCoords).r);
color += (tex2D(Otis_SamplerFragmentBuffer1, sourceCoords) * weight);
n+=weight;
#line 116
sourceCoords = texcoord - float2(0.0, j * float2((1.0 / 1920), (1.0 / 1018)).y);
weight = CalculateWeight(j, colorDepth, ReShade::GetLinearizedDepth(sourceCoords).r);
color += (tex2D(Otis_SamplerFragmentBuffer1, sourceCoords) * weight);
n+=weight;
}
outFragment = color/n;
}
#line 124
void PS_Otis_DEH_BlendBlurWithNormalBuffer(float4 vpos: SV_Position, float2 texcoord: TEXCOORD, out float4 fragment: SV_Target0)
{
const float depth = ReShade::GetLinearizedDepth(texcoord).r;
const float4 blendedFragment = lerp(tex2D(ReShade::BackBuffer, texcoord), tex2D(Otis_SamplerFragmentBuffer2, texcoord), clamp(depth  * EffectStrength, 0.0, 1.0));
float yFactor;
if (texcoord.y > 0.5)
yFactor = clamp(1-((texcoord.y-0.5)*2.0), 0, 1);
else
yFactor = clamp(texcoord.y * 2.0, 0, 1);
fragment = lerp(blendedFragment, float4(FogColor, blendedFragment.r), clamp((depth-FogStart) * yFactor * FogFactor, 0.0, 1.0));
}
#line 136
technique DepthHaze
{
#line 140
pass Otis_DEH_Pass0
{
VertexShader = PostProcessVS;
PixelShader = PS_Otis_DEH_BlockBlurHorizontal;
RenderTarget = Otis_FragmentBuffer1;
}
#line 147
pass Otis_DEH_Pass1
{
VertexShader = PostProcessVS;
PixelShader = PS_Otis_DEH_BlockBlurVertical;
RenderTarget = Otis_FragmentBuffer2;
}
#line 154
pass Otis_DEH_Pass2
{
VertexShader = PostProcessVS;
PixelShader = PS_Otis_DEH_BlendBlurWithNormalBuffer;
}
}

