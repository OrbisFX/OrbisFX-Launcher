#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Pirate_Bloom.fx"
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
#line 3 "C:\Program Files\GShade\gshade-shaders\Shaders\Pirate_Bloom.fx"
#line 14
uniform float BLOOM_THRESHOLD <
ui_label = "Bloom - Threshold";
ui_tooltip = "Bloom will only affect pixels above this value.";
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
> = 0.5;
uniform float BLOOM_STRENGTH <
ui_label = "Bloom - Strength";
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
> = 0.5;
uniform float BLOOM_RADIUS <
ui_label = "Bloom - Radius";
ui_tooltip = "Pixel Radius per tap.";
ui_type = "slider";
ui_min = 1.0; ui_max = 10.0;
> = 5.0;
uniform float BLOOM_SATURATION <
ui_label = "Bloom - Saturation";
ui_tooltip = "Controls the saturation of the bloom. 1.0 = no change.";
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
> = 1.0;
uniform int BLOOM_BLEND <
ui_label = "Bloom - Blending mode";
ui_type = "combo";
ui_items = "Add\0Add - No Clip\0Screen\0Soft Light\0Color Dodge\0";
> = 1;
uniform bool BLOOM_DEBUG <
ui_label = "Bloom - Debug";
ui_tooltip = "Shows only the bloom effect.";
> = false;
#line 47
texture		TexBloomH { Width = 1920*0.25; Height = 1018*0.25; Format = RGBA8;};
texture		TexBloomV { Width = 1920*0.25; Height = 1018*0.25; Format = RGBA8;};
sampler2D	SamplerBloomH { Texture = TexBloomH; MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR; AddressU = Clamp; AddressV = Clamp;};
sampler2D	SamplerBloomV { Texture = TexBloomV; MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR; AddressU = Clamp; AddressV = Clamp;};
#line 52
float3 BlendScreen(float3 a, float3 b) {
return 1 - ((1 - a) * (1 - b));
}
float3 BlendSoftLight(float3 a, float3 b) {
return (1 - 2 * b) * (a * a) + 2 * b * a;
}
float3 BlendColorDodge(float3 a, float3 b) {
return a / (1 - b);
}
float4 GaussBlurFirstPass(float2 coords : TEXCOORD) : COLOR {
float4 ret = max(tex2D(ReShade::BackBuffer, coords) - BLOOM_THRESHOLD, 0.0);
#line 64
for(int i=1; i < 12; i++)
{
ret += max(tex2D(ReShade::BackBuffer, coords + float2(i * float2((1.0 / 1920), (1.0 / 1018)).x * BLOOM_RADIUS, 0.0)) - BLOOM_THRESHOLD, 0.0);
ret += max(tex2D(ReShade::BackBuffer, coords - float2(i * float2((1.0 / 1920), (1.0 / 1018)).x * BLOOM_RADIUS, 0.0)) - BLOOM_THRESHOLD, 0.0);
}
#line 70
return ret / (1.0 - BLOOM_THRESHOLD) / ((12 * 2) - 1);
}
#line 73
float4 GaussBlurH(float2 coords : TEXCOORD) : COLOR {
float4 ret = tex2D(SamplerBloomV, coords);
#line 76
for(int i=1; i < 12; i++)
{
ret += tex2D(SamplerBloomV, coords + float2(i * float2((1.0 / 1920), (1.0 / 1018)).x * BLOOM_RADIUS, 0.0));
ret += tex2D(SamplerBloomV, coords - float2(i * float2((1.0 / 1920), (1.0 / 1018)).x * BLOOM_RADIUS, 0.0));
}
#line 82
return ret / ((12 * 2) - 1);
}
#line 85
float4 GaussBlurV(float2 coords : TEXCOORD) : COLOR {
float4 ret = tex2D(SamplerBloomH, coords);
#line 88
for(int i=1; i < 12; i++)
{
ret += tex2D(SamplerBloomH, coords + float2(0.0, i * float2((1.0 / 1920), (1.0 / 1018)).y * BLOOM_RADIUS));
ret += tex2D(SamplerBloomH, coords - float2(0.0, i * float2((1.0 / 1920), (1.0 / 1018)).y * BLOOM_RADIUS));
}
#line 94
return ret / ((12 * 2) - 1);
}
#line 97
float4 PS_BloomFirstPass(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : COLOR
{
return GaussBlurFirstPass(texcoord);
}
#line 102
float4 PS_BloomH(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : COLOR
{
return GaussBlurH(texcoord);
}
#line 107
float4 PS_BloomV(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : COLOR
{
return GaussBlurV(texcoord);
}
#line 112
float4 PS_Combine(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : COLOR
{
float4 ret = tex2D(ReShade::BackBuffer, texcoord);
float4 bloom = tex2D(SamplerBloomV, texcoord);
bloom.rgb = lerp(dot(bloom.rgb, float3(0.2126, 0.7152, 0.0722)), bloom.rgb, BLOOM_SATURATION) * BLOOM_STRENGTH;
#line 118
if (BLOOM_DEBUG) return bloom;
#line 120
if (BLOOM_BLEND == 0) 
ret.rgb += bloom.rgb;
else if (BLOOM_BLEND == 1) 
ret.rgb += bloom.rgb * saturate(1.0 - ret.rgb);
else if (BLOOM_BLEND == 2) 
ret.rgb = BlendScreen(ret.rgb, bloom.rgb);
else if (BLOOM_BLEND == 3) 
ret.rgb = BlendSoftLight(ret.rgb, bloom.rgb);
else if (BLOOM_BLEND == 4) 
ret.rgb = BlendColorDodge(ret.rgb, bloom.rgb);
#line 134
return ret;
#line 136
}
#line 140
technique Pirate_Bloom
{
pass BloomH
{
VertexShader = PostProcessVS;
PixelShader  = PS_BloomFirstPass;
RenderTarget = TexBloomH;
}
pass BloomV
{
VertexShader = PostProcessVS;
PixelShader  = PS_BloomV;
RenderTarget = TexBloomV;
}
#line 155
pass BloomH2
{
VertexShader = PostProcessVS;
PixelShader  = PS_BloomH;
RenderTarget = TexBloomH;
}
pass BloomV2
{
VertexShader = PostProcessVS;
PixelShader  = PS_BloomV;
RenderTarget = TexBloomV;
}
#line 196
pass Combine
{
VertexShader = PostProcessVS;
PixelShader  = PS_Combine;
}
}

