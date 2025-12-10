#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FakeHDR.fx"
#line 33
uniform float fHDRPower <
ui_type = "slider";
ui_min = 0.0; ui_max = 8.0;
ui_label = "Power";
> = 1.30;
uniform float fradius1 <
ui_type = "slider";
ui_min = 0.0; ui_max = 8.0;
ui_label = "Radius 1";
> = 0.793;
uniform float fradius2 <
ui_type = "slider";
ui_min = 0.0; ui_max = 8.0;
ui_label = "Radius 2";
ui_tooltip = "Raising this seems to make the effect stronger and also brighter.";
> = 0.87;
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
#line 51 "C:\Program Files\GShade\gshade-shaders\Shaders\FakeHDR.fx"
#line 57
float3 fHDRPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 62
const float2 rad1 = fradius1 * float2((1.0 / 1920), (1.0 / 1018));
const float2 rad2 = fradius2 * float2((1.0 / 1920), (1.0 / 1018));
#line 66
const float3 bloom_sum1  = (
tex2D(ReShade::BackBuffer, texcoord + float2( 1.5, -1.5) * rad1).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2(-1.5, -1.5) * rad1).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2( 1.5,  1.5) * rad1).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2(-1.5,  1.5) * rad1).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2( 0.0, -2.5) * rad1).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2( 0.0,  2.5) * rad1).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2(-2.5,  0.0) * rad1).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2( 2.5,  0.0) * rad1).rgb
) * 0.005;
#line 78
const float3 bloom_sum2  = (
tex2D(ReShade::BackBuffer, texcoord + float2( 1.5, -1.5) * rad2).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2(-1.5, -1.5) * rad2).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2( 1.5,  1.5) * rad2).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2(-1.5,  1.5) * rad2).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2( 0.0, -2.5) * rad2).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2( 0.0,  2.5) * rad2).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2(-2.5,  0.0) * rad2).rgb +
tex2D(ReShade::BackBuffer, texcoord + float2( 2.5,  0.0) * rad2).rgb
) * 0.01;
#line 89
const float3 HDR = (color + (bloom_sum2 - bloom_sum1)) * (fradius2 - fradius1);
#line 95
return saturate(pow(abs(HDR + color), abs(fHDRPower)) + HDR); 
#line 97
}
#line 99
technique FakeHDR
{
pass
{
VertexShader = PostProcessVS;
PixelShader = fHDRPass;
}
}

