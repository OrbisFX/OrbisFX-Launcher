#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Technicolor2.fx"
#line 32
uniform float3 ColorStrength <
ui_type = "color";
ui_tooltip = "Higher means darker and more intense colors.";
> = float3(0.2, 0.2, 0.2);
#line 37
uniform float Brightness <
ui_type = "slider";
ui_min = 0.5; ui_max = 1.5;
ui_tooltip = "Higher means brighter image.";
> = 1.0;
uniform float Saturation <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.5;
ui_tooltip = "Additional saturation control since this effect tends to oversaturate the image.";
> = 1.0;
#line 48
uniform float Strength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Adjust the strength of the effect.";
> = 1.0;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 57
namespace ReShade
{
float GetAspectRatio() { return 1280 * (1.0 / 720); }
float2 GetPixelSize() { return float2((1.0 / 1280), (1.0 / 720)); }
float2 GetScreenSize() { return float2(1280, 720); }
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
#line 55 "C:\Program Files\GShade\gshade-shaders\Shaders\Technicolor2.fx"
#line 60
float3 TechnicolorPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 color = saturate(tex2D(ReShade::BackBuffer, texcoord).rgb);
#line 64
float3 temp = 1.0 - color;
float3 target = temp.grg;
float3 target2 = temp.bbr;
float3 temp2 = color * target;
temp2 *= target2;
#line 70
temp = temp2 * ColorStrength;
temp2 *= Brightness;
#line 73
target = temp.grg;
target2 = temp.bbr;
#line 76
temp = color - target;
temp += temp2;
temp2 = temp - target2;
#line 80
color = lerp(color, temp2, Strength);
#line 86
return lerp(dot(color, 0.333), color, Saturation);
#line 88
}
#line 90
technique Technicolor2
{
pass
{
VertexShader = PostProcessVS;
PixelShader = TechnicolorPass;
}
}

