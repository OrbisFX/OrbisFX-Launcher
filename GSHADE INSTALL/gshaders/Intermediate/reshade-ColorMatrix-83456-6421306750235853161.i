#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorMatrix.fx"
#line 33
uniform float3 ColorMatrix_Red <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Matrix Red";
ui_tooltip = "How much of a red, green and blue tint the new red value should contain. Should sum to 1.0 if you don't wish to change the brightness.";
> = float3(0.817, 0.183, 0.000);
uniform float3 ColorMatrix_Green <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Matrix Green";
ui_tooltip = "How much of a red, green and blue tint the new green value should contain. Should sum to 1.0 if you don't wish to change the brightness.";
> = float3(0.333, 0.667, 0.000);
uniform float3 ColorMatrix_Blue <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Matrix Blue";
ui_tooltip = "How much of a red, green and blue tint the new blue value should contain. Should sum to 1.0 if you don't wish to change the brightness.";
> = float3(0.000, 0.125, 0.875);
#line 52
uniform float Strength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
> = 1.0;
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
#line 58 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorMatrix.fx"
#line 63
float3 ColorMatrixPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 67
const float3x3 ColorMatrix = float3x3(ColorMatrix_Red, ColorMatrix_Green, ColorMatrix_Blue);
#line 73
return saturate(lerp(color, mul(ColorMatrix, color), Strength));
#line 75
}
#line 77
technique ColorMatrix
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ColorMatrixPass;
}
}

