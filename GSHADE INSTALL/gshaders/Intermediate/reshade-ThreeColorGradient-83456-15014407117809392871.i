#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ThreeColorGradient.fx"
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
#line 8 "C:\Program Files\GShade\gshade-shaders\Shaders\ThreeColorGradient.fx"
#line 9
uniform float3 color1 <
ui_type = "color";
> = float3(0.0, 1.0, 1.0);
#line 13
uniform float3 color2 <
ui_type = "color";
> = float3(1.0, 0.0, 1.0);
#line 17
uniform float3 color3 <
ui_type = "color";
> = float3(1.0, 1.0, 0.0);
#line 21
uniform int gradSharp <
ui_type = "slider";
ui_label = "Gradient sharpness";
ui_min = 1; ui_max = 100;
> = 10;
#line 27
uniform float angle <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
> = 0.0;
#line 32
uniform float position <
ui_type = "slider";
ui_min = 1.0; ui_max = 4.0;
> = 1.0;
#line 37
uniform int blendType <
ui_label = "Blend type";
ui_type  = "combo";
ui_items = "None\0 Add\0 Multiply\0 50/50\0";
> = 1;
#line 43
float3 threeColorGradient(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float angleMask = lerp(texcoord.x, texcoord.y, angle) / position,
gradientMask = pow(max((angleMask * (1.0 - angleMask)) * 4.0, 0.0), gradSharp);
#line 48
float3 gradientColor;
#line 50
if(angleMask < 0.5)
{
gradientColor = (1.0 - gradientMask) * color1;
}
else
{
gradientColor = (1.0 - gradientMask) * color3;
}
#line 59
if(blendType == 0)
{
return gradientColor + gradientMask * color2;
}
else if(blendType == 1)
{
return tex2D(ReShade::BackBuffer, texcoord).rgb + (gradientColor + gradientMask * color2);
}
else if(blendType == 2)
{
return tex2D(ReShade::BackBuffer, texcoord).rgb * (gradientColor + gradientMask * color2);
}
else
{
return (tex2D(ReShade::BackBuffer, texcoord).rgb + (gradientColor + gradientMask * color2)) / 2;
}
}
#line 77
technique ThreeColorGradient
{
pass pass0
{
VertexShader = PostProcessVS;
PixelShader = threeColorGradient;
}
}

