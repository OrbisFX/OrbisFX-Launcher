#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ChromaSubSampling.fx"
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
#line 8 "C:\Program Files\GShade\gshade-shaders\Shaders\ChromaSubSampling.fx"
#line 9
uniform int chromaSubType <
ui_label = "Type";
ui_type  = "combo";
ui_items = " 4:2:2\0 4:2:0\0 4:1:1\0 idk how to name this one\0";
> = 0;
#line 15
uniform bool showChroma <
ui_label = "Show Only Chroma";
> = false;
#line 19
texture chromaSubTex { Width = 1920; Height = 1018; Format = RGBA8; };
sampler chromaSubSamp { Texture = chromaSubTex; };
#line 22
float3 chromaSubSetup(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
if(chromaSubType == 0)
{
if(pos.x % 2 <= 1)
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
}
else if(chromaSubType == 1)
{
if(pos.x % 2 <= 1 && pos.y % 2 <= 1)
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
}
else if(chromaSubType == 2)
{
if(pos.x % 4 <= 1)
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
}
else
{
if(pos.x % 3 <= 1 && pos.y % 3 <= 1)
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
}
#line 53
return 0;
}
#line 56
float3 chromaSubSampling(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float luma = (tex2D(ReShade::BackBuffer, texcoord).r + tex2D(ReShade::BackBuffer, texcoord).g + tex2D(ReShade::BackBuffer, texcoord).b) / 3;
float3 color = tex2D(chromaSubSamp, texcoord).rgb;
#line 61
if(chromaSubType == 0)
{
color += tex2D(chromaSubSamp, float2(texcoord.x + (1.0 / 1920), texcoord.y)).rgb;
}
else if(chromaSubType == 1)
{
color += tex2D(chromaSubSamp, float2(texcoord.x + (1.0 / 1920), texcoord.y)).rgb;
color += tex2D(chromaSubSamp, float2(texcoord.x, texcoord.y + (1.0 / 1018))).rgb;
color += tex2D(chromaSubSamp, float2(texcoord.x + (1.0 / 1920), texcoord.y + (1.0 / 1018))).rgb;
}
else if(chromaSubType == 2)
{
color += tex2D(chromaSubSamp, float2(texcoord.x + (1.0 / 1920), texcoord.y)).rgb;
color += tex2D(chromaSubSamp, float2(texcoord.x + (1.0 / 1920) * 2, texcoord.y)).rgb;
color += tex2D(chromaSubSamp, float2(texcoord.x + (1.0 / 1920) * 3, texcoord.y)).rgb;
}
else
{
color += tex2D(chromaSubSamp, float2(texcoord.x + (1.0 / 1920), texcoord.y)).rgb;
color += tex2D(chromaSubSamp, float2(texcoord.x - (1.0 / 1920), texcoord.y)).rgb;
color += tex2D(chromaSubSamp, float2(texcoord.x, texcoord.y + (1.0 / 1018))).rgb;
color += tex2D(chromaSubSamp, float2(texcoord.x, texcoord.y - (1.0 / 1018))).rgb;
color += tex2D(chromaSubSamp, float2(texcoord.x + (1.0 / 1920), texcoord.y + (1.0 / 1018))).rgb;
color += tex2D(chromaSubSamp, float2(texcoord.x - (1.0 / 1920), texcoord.y - (1.0 / 1018))).rgb;
color += tex2D(chromaSubSamp, float2(texcoord.x + (1.0 / 1920), texcoord.y - (1.0 / 1018))).rgb;
color += tex2D(chromaSubSamp, float2(texcoord.x - (1.0 / 1920), texcoord.y + (1.0 / 1018))).rgb;
}
#line 89
float lumaSubSampling = (color.r + color.g + color.b) / 3;
#line 91
color -= lumaSubSampling;
#line 93
if(showChroma)
{
return color;
}
else
{
return color + luma;
}
}
#line 103
technique ChromaSubSampling
{
pass pass0
{
VertexShader = PostProcessVS;
PixelShader = chromaSubSetup;
RenderTarget = chromaSubTex;
}
pass pass1
{
VertexShader = PostProcessVS;
PixelShader = chromaSubSampling;
}
}

