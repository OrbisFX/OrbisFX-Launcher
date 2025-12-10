#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Vibrance.fx"
#line 43
uniform float Vibrance <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_tooltip = "Intelligently saturates (or desaturates if you use negative values) the pixels depending on their original saturation.";
> = 0.15;
#line 49
uniform float3 VibranceRGBBalance <
ui_type = "slider";
ui_min = 0.0; ui_max = 10.0;
ui_label = "RGB Balance";
ui_tooltip = "A per channel multiplier to the Vibrance strength so you can give more boost to certain colors over others.\nThis is handy if you are colorblind and less sensitive to a specific color.\nYou can then boost that color more than the others.";
> = float3(1.0, 1.0, 1.0);
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
#line 65 "C:\Program Files\GShade\gshade-shaders\Shaders\Vibrance.fx"
#line 70
float3 VibrancePass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 74
const float luma = dot(float3(0.212656, 0.715158, 0.072186), color);
#line 77
const float3 coeffVibrance = float3(VibranceRGBBalance * Vibrance);
#line 83
return lerp(luma, color, 1.0 + (coeffVibrance * (1.0 - (sign(coeffVibrance) * (max(color.r, max(color.g, color.b)) - min(color.r, min(color.g, color.b)))))));
#line 85
}
#line 87
technique Vibrance
{
pass
{
VertexShader = PostProcessVS;
PixelShader = VibrancePass;
}
}

