// ASPECT_RATIO_USE_TEXTURE=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\AspectRatio.fx"
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
#line 41 "C:\Program Files\GShade\gshade-shaders\Shaders\AspectRatio.fx"
#line 46
uniform float A
<
ui_type = "slider";
ui_label = "Correct proportions";
ui_category = "Aspect ratio";
ui_min = -1f; ui_max = 1f;
> = 0f;
#line 54
uniform float Zoom
<
ui_type = "slider";
ui_units = "x";
ui_label = "Scale image to borders";
ui_category = "Aspect ratio";
> = 1f;
#line 62
uniform float4 Color
<
ui_type = "color";
ui_label = "Background color";
ui_category = "Borders";
> = float4(0.027, 0.027, 0.027, 0.17);
#line 87
float3 AspectRatioPS(
float4 pixelPos : SV_Position,
float2 texCoord : TEXCOORD
) : SV_Target
{
#line 93
float2 aspectCoord = texCoord-0.5;
#line 96
float deformation = abs(A)+1f;
float scaling = abs(A)*Zoom+1f;
#line 100
float Mask, pixelScale;
if (A<0f)
{
#line 104
aspectCoord.x *= deformation;
#line 106
aspectCoord /= scaling;
#line 108
Mask = 0.5-abs(aspectCoord.x);
pixelScale = 1920*scaling/deformation;
#line 111
Mask = saturate(Mask*pixelScale+0.5);
}
else if (A>0f)
{
#line 116
aspectCoord.y *= deformation;
#line 118
aspectCoord /= scaling;
#line 120
Mask = 0.5-abs(aspectCoord.y);
pixelScale = 1018*scaling/deformation;
#line 123
Mask = saturate(Mask*pixelScale+0.5);
}
else 
return tex2Dfetch(ReShade::BackBuffer, uint2(pixelPos.xy)).rgb;
#line 129
aspectCoord += 0.5;
#line 141
return lerp(Color.rgb, tex2D(ReShade::BackBuffer, aspectCoord).rgb, Mask);
}
#line 148
technique AspectRatioPS
<
ui_label = "Aspect Ratio";
ui_tooltip =
"Correct image aspect ratio.\n"
"\n"
"This effect © 2019-2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY 4.0";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = AspectRatioPS;
}
}

