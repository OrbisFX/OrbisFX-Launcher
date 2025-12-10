#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ColShift.fx"
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
#line 9 "C:\Program Files\GShade\gshade-shaders\Shaders\ColShift.fx"
#line 14
uniform float HardRedCutoff <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Hard Red Cutoff";
> = float(0.85);
#line 20
uniform float SoftRedCutoff <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Soft Red Cutoff";
> = float(0.6);
#line 26
uniform float HardGreenCutoff <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Hard Green Cutoff";
> = float(0.6);
#line 32
uniform float SoftGreenCutoff <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Soft Green Cutoff";
> = float(0.85);
#line 38
uniform float BlueCutoff <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Blue Cutoff";
> = float(0.3);
#line 44
uniform bool Yellow <
ui_type = "checkbox";
ui_label = "Yellow instead of Green";
> = false;
#line 50
float3 ColShiftPass(float4 position: SV_Position, float2 texcoord: TexCoord): SV_Target
{
const float3 input = tex2D(ReShade::BackBuffer, texcoord).rgb;
if (input.r >= HardRedCutoff && input.g <= HardGreenCutoff && input.b <= BlueCutoff)
{
if (Yellow)
return input.rrb;
else
return input.grb;
}
#line 61
if (input.r >= SoftRedCutoff && input.g <= SoftGreenCutoff && input.b <= BlueCutoff)
{
const float alphaR = (input.r - SoftRedCutoff) / (HardRedCutoff - SoftRedCutoff);
if (Yellow)
return lerp(input.rgb, input.rrb, alphaR);
else
return lerp(input.rgb, input.grb, alphaR);
}
#line 73
return input;
#line 75
}
#line 77
technique ColShift
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ColShiftPass;
}
}

