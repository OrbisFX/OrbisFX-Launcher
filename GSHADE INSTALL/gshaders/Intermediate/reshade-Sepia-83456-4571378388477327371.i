#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Sepia.fx"
#line 37
uniform float3 Tint <
ui_type = "color";
> = float3(0.55, 0.43, 0.42);
#line 41
uniform float Strength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Adjust the strength of the effect.";
> = 0.58;
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
#line 48 "C:\Program Files\GShade\gshade-shaders\Shaders\Sepia.fx"
#line 53
float3 TintPass(float4 vois : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
#line 61
const float3 col = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 63
return lerp(col, col * Tint * 2.55, Strength);
#line 65
}
#line 67
technique Tint
{
pass
{
VertexShader = PostProcessVS;
PixelShader = TintPass;
}
}

