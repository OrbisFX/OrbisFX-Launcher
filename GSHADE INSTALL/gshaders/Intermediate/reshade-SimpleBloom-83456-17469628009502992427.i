#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\SimpleBloom.fx"
#line 16
uniform float BlurMultiplier <
ui_type = "slider";
ui_label = "Radius";
ui_min = 1; ui_max = 16; ui_step = 0.01;
> = 1.23;
#line 22
uniform float2 Blend <
ui_type = "slider";
ui_min = 0; ui_max = 1; ui_step = 0.001;
> = float2(0.0, 0.8);
#line 27
uniform bool Debug <
> = false;
#line 31
texture SimpleBloomTarget
{
#line 34
Width = 1920 * 0.25;
Height = 1018 * 0.25;
Format = RGBA8;
};
#line 47
sampler SimpleBloomSampler { Texture = SimpleBloomTarget; };
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
#line 54 "C:\Program Files\GShade\gshade-shaders\Shaders\SimpleBloom.fx"
#line 59
void BloomHorizontalPass(float4 vpos : SV_Position, float2 UvCoord : TEXCOORD,
out float3 Target : SV_Target)
{
const float Weight[11] =
{
0.082607,
0.080977,
0.076276,
0.069041,
0.060049,
0.050187,
0.040306,
0.031105,
0.023066,
0.016436,
0.011254
};
#line 77
Target.rgb = tex2D(ReShade::BackBuffer, UvCoord).rgb;
const float UvOffset = float2((1.0 / 1920), (1.0 / 1018)).x * BlurMultiplier;
Target.rgb *= Weight[0];
for (int i = 1; i < 11; i++)
{
float SampleOffset = i * UvOffset;
Target.rgb +=
max(
Target.rgb,
max(
tex2Dlod(ReShade::BackBuffer, float4(UvCoord.xy + float2(SampleOffset, 0), 0, 0)).rgb
, tex2Dlod(ReShade::BackBuffer, float4(UvCoord.xy - float2(SampleOffset, 0), 0, 0)).rgb
)
) * Weight[i];
}
}
#line 94
void SimpleBloomPS(float4 vpos : SV_Position, float2 UvCoord : TEXCOORD,
out float3 Image : SV_Target)
{
const float Weight[11] =
{
0.082607,
0.080977,
0.076276,
0.069041,
0.060049,
0.050187,
0.040306,
0.031105,
0.023066,
0.016436,
0.011254
};
#line 112
float3 Target = tex2D(SimpleBloomSampler, UvCoord).rgb;
#line 114
const float UvOffset = float2((1.0 / 1920), (1.0 / 1018)).y * BlurMultiplier;
Target.rgb *= Weight[0];
for (int i = 1; i < 11; i++)
{
float SampleOffset = i * UvOffset;
Target.rgb +=
max(
Target.rgb,
max(
tex2Dlod(SimpleBloomSampler, float4(UvCoord.xy + float2(0, SampleOffset), 0, 0)).rgb
, tex2Dlod(SimpleBloomSampler, float4(UvCoord.xy - float2(0, SampleOffset), 0, 0)).rgb
)
) * Weight[i];
}
#line 129
Image = tex2D(ReShade::BackBuffer, UvCoord).rgb;
#line 132
Target = max(Target - Image, Blend.x) - Blend.x;
Target /= 1 - min(0.999, Blend.x);
#line 136
Target *= Blend.y;
#line 138
Image = 1 - (1 - Image) * (1 - Target); 
#line 140
if (Debug)
Image = Target;
#line 146
}
#line 152
technique SimpleBloom < ui_label = "Simple Bloom"; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader = BloomHorizontalPass;
RenderTarget = SimpleBloomTarget;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = SimpleBloomPS;
}
}

