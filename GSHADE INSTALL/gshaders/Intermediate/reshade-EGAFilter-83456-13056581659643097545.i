#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\EGAFilter.fx"
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
#line 2 "C:\Program Files\GShade\gshade-shaders\Shaders\EGAFilter.fx"
#line 19
sampler2D SourcePointSampler
{
Texture = ReShade::BackBufferTex;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
AddressU = CLAMP;
AddressV = CLAMP;
};
#line 29
float3 nearest_rgbi (float3 original) {
#line 31
float3 rgbi_palette[16] = {
float3(0.0,     0.0,     0.0),
float3(0.0,     0.0,     0.66667),
float3(0.0,     0.66667, 0.0),
float3(0.0,     0.66667, 0.66667),
float3(0.66667, 0.0,     0.0),
float3(0.66667, 0.0,     0.66667),
float3(0.66667, 0.33333, 0.0),
float3(0.66667, 0.66667, 0.66667),
float3(0.33333, 0.33333, 0.33333),
float3(0.33333, 0.33333, 1.0),
float3(0.33333, 1.0,     0.33333),
float3(0.33333, 1.0,     1.0),
float3(1.0,     0.33333, 0.33333),
float3(1.0,     0.33333, 1.0),
float3(1.0,     1.0,     0.33333),
float3(1.0,     1.0,     1.0),
};
#line 50
float dst;
float min_dst = 2.0;
int idx = 0;
for (int i=0; i<16; i++) {
dst = distance(original, rgbi_palette[i]);
if (dst < min_dst) {
min_dst = dst;
idx = i;
}
}
return rgbi_palette[idx];
}
#line 63
float4 PS_EGA(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float3 fragcolor = tex2D(SourcePointSampler, texcoord).rgb;
#line 70
return float4(nearest_rgbi(fragcolor*1.0), 1.0);
#line 72
}
#line 74
technique EGAfilter
{
pass EGAfilterPass
{
VertexShader = PostProcessVS;
PixelShader = PS_EGA;
}
}

