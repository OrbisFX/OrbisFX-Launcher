// ASPECT_RATIO_MAX=25
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\AspectRatioComposition.fx"
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
#line 38 "C:\Program Files\GShade\gshade-shaders\Shaders\AspectRatioComposition.fx"
#line 58
uniform int2 iUIAspectRatio <
ui_type = "slider";
ui_label = "Aspect Ratio";
ui_tooltip = "To control aspect ratio with a float\nadd 'ASPECT_RATIO_FLOAT' to preprocessor.\nOptional: 'ASPECT_RATIO_MAX=xyz'";
ui_min = 0; ui_max = 25;
> = int2(16, 9);
#line 66
uniform int iUIGridType <
ui_type = "combo";
ui_label = "Grid Type";
ui_items = "Off\0Fractions\0Golden Ratio\0";
> = 0;
#line 72
uniform int iUIGridFractions <
ui_type = "slider";
ui_label = "Fractions";
ui_tooltip = "Set 'Grid Type' to 'Fractions'";
ui_min = 1; ui_max = 5;
> = 3;
#line 79
uniform float4 UIGridColor <
ui_type = "color";
ui_label = "Grid Color";
> = float4(0.0, 0.0, 0.0, 1.0);
#line 88
float3 DrawGrid(float3 backbuffer, float3 gridColor, float aspectRatio, float fraction, float4 vpos)
{
float borderSize;
float fractionWidth;
#line 93
float3 retVal = backbuffer;
#line 95
if(aspectRatio < (1920 * (1.0 / 1018)))
{
borderSize = (1920 - 1018 * aspectRatio) / 2.0;
fractionWidth = (1920 - 2 * borderSize) / fraction;
#line 100
if(vpos.x < borderSize || vpos.x > (1920 - borderSize))
retVal = gridColor;
#line 103
if((vpos.y % (1018 / fraction)) < 1)
retVal = gridColor;
#line 106
if(((vpos.x - borderSize) % fractionWidth) < 1)
retVal = gridColor;
}
else
{
borderSize = (1018 - 1920 / aspectRatio) / 2.0;
fractionWidth = (1018 - 2 * borderSize) / fraction;
#line 114
if(vpos.y < borderSize || vpos.y > (1018 - borderSize))
retVal = gridColor;
#line 117
if((vpos.x % (1920 / fraction)) < 1)
retVal = gridColor;
#line 120
if(((vpos.y - borderSize) % fractionWidth) < 1)
retVal = gridColor;
#line 123
}
#line 125
if(vpos.x <= 1 || vpos.x >= 1920-1 || vpos.y <= 1 || vpos.y >= 1018-1)
retVal = gridColor;
#line 128
return retVal;
}
#line 135
float3 AspectRatioComposition_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
float3 retVal = color;
#line 140
float userAspectRatio;
#line 145
userAspectRatio = (float)iUIAspectRatio.x / (float)iUIAspectRatio.y;
#line 148
if(iUIGridType == 1)
retVal = DrawGrid(color, UIGridColor.rgb, userAspectRatio, iUIGridFractions, vpos);
else if(iUIGridType == 2)
{
retVal = DrawGrid(color, UIGridColor.rgb, userAspectRatio, 1.6180339887, vpos);
retVal = DrawGrid(retVal, UIGridColor.rgb, userAspectRatio, 1.6180339887, float4(1920, 1018, 0, 0) - vpos);
}
#line 156
return lerp(color, retVal, UIGridColor.w);
}
#line 159
technique AspectRatioComposition
{
pass
{
VertexShader = PostProcessVS;
PixelShader = AspectRatioComposition_PS;
}
}

