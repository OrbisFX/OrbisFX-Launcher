#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Levels.fx"
#line 46
uniform int BlackPoint <
ui_type = "slider";
ui_min = 0; ui_max = 255;
ui_label = "Black Point";
ui_tooltip = "The black point is the new black - literally. Everything darker than this will become completely black.";
> = 16;
#line 53
uniform int WhitePoint <
ui_type = "slider";
ui_min = 0; ui_max = 255;
ui_label = "White Point";
ui_tooltip = "The new white point. Everything brighter than this becomes completely white";
> = 235;
#line 60
uniform bool HighlightClipping <
ui_label = "Highlight clipping pixels";
ui_tooltip = "Colors between the two points will stretched, which increases contrast, but details above and below the points are lost (this is called clipping).\n"
"This setting marks the pixels that clip.\n"
"Red: Some detail is lost in the highlights\n"
"Yellow: All detail is lost in the highlights\n"
"Blue: Some detail is lost in the shadows\n"
"Cyan: All detail is lost in the shadows.";
> = false;
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
#line 71 "C:\Program Files\GShade\gshade-shaders\Shaders\Levels.fx"
#line 76
float3 LevelsPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float black_point_float = BlackPoint / 255.0;
#line 80
float white_point_float;
#line 82
if (WhitePoint == BlackPoint)
white_point_float = (255.0 / 0.00025);
else
white_point_float = 255.0 / (WhitePoint - BlackPoint);
#line 87
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
color = color * white_point_float - (black_point_float *  white_point_float);
#line 90
if (HighlightClipping)
{
float3 clipped_colors;
#line 95
if (any(color > saturate(color)))
clipped_colors = float3(1.0, 0.0, 0.0);
else
clipped_colors = color;
#line 101
if (all(color > saturate(color)))
clipped_colors = float3(1.0, 1.0, 0.0);
#line 105
if (any(color < saturate(color)))
clipped_colors = float3(0.0, 0.0, 1.0);
#line 109
if (all(color < saturate(color)))
clipped_colors = float3(0.0, 1.0, 1.0);
#line 112
color = clipped_colors;
}
#line 118
return color;
#line 120
}
#line 122
technique Levels
{
pass
{
VertexShader = PostProcessVS;
PixelShader = LevelsPass;
}
}

