#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ExtendedLevels.fx"
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
#line 82 "C:\Program Files\GShade\gshade-shaders\Shaders\ExtendedLevels.fx"
#line 87
static const float PI = 3.141592653589793238462643383279f;
#line 93
uniform bool EnableLevels <
ui_tooltip = "Enable or Disable Levels for TV <> PC or custome color range";
> = true;
#line 97
uniform float3 InputBlackPoint <
ui_type = "color";
ui_tooltip = "The black point is the new black - literally. Everything darker than this will become completely black.";
> = float3(16/255.0f, 18/255.0f, 20/255.0f);
#line 102
uniform float3 InputWhitePoint <
ui_type = "color";
ui_tooltip = "The new white point. Everything brighter than this becomes completely white";
> = float3(233/255.0f, 222/255.0f, 211/255.0f);
#line 107
uniform float3 InputGamma <
ui_type = "slider";
ui_min = 0.001f; ui_max = 10.00f; step = 0.001f;
ui_label = "RGB Gamma";
ui_tooltip = "Adjust midtones for Red, Green and Blue.";
> = float3(1.00f,1.00f,1.00f);
#line 114
uniform float3 OutputBlackPoint <
ui_type = "color";
ui_tooltip = "The black point is the new black - literally. Everything darker than this will become completely black.";
> = float3(0/255.0f, 0/255.0f, 0/255.0f);
#line 119
uniform float3 OutputWhitePoint <
ui_type = "color";
ui_tooltip = "The new white point. Everything brighter than this becomes completely white";
> = float3(255/255.0f, 255/255.0f, 255/255.0f);
#line 140
uniform float3 ColorRangeShift <
ui_type = "color";
ui_tooltip = "Some games like Watch Dogs 2 has color range 16-235 downshifted to 0-219, so this option was added to upshift color range before expanding it. RGB value entered here will be just added to default color value. Negative values impossible at the moment in game, but can be added, in shader if downshifting needed. 0 disables shifting.";
> = float3(0/255.0f, 0/255.0f, 0/255.0f);
#line 145
uniform int ColorRangeShiftSwitch <
ui_type = "slider";
ui_min = -1; ui_max = 1;
ui_tooltip = "Workaround for lack of negative color values in Reshade UI: -1 to downshift, 1 to upshift, 0 to disable";
> = 0;
#line 169
uniform bool ACEScurve <
ui_tooltip = "Enable or Disable ACES for improved contrast and luminance";
> = false;
#line 173
uniform int3 ACESLuminancePercentage <
ui_type = "slider";
ui_min = 75; ui_max = 175; step = 1;
ui_tooltip = "Percentage of ACES Luminance. Can be used to avoid some color clipping.";
> = int3(100,100,100);
#line 180
uniform bool HighlightClipping <
ui_tooltip = "Colors between the two points will stretched, which increases contrast, but details above and below the points are lost (this is called clipping).\n0 Highlight the pixels that clip. Red = Some details are lost in the highlights, Yellow = All details are lost in the highlights, Blue = Some details are lost in the shadows, Cyan = All details are lost in the shadows.";
> = false;
#line 188
float3 ACESFilmRec2020( float3 x )
{
x = x * ACESLuminancePercentage * 0.005f; 
return ( x * ( 15.8f * x + 2.12f ) ) / ( x * ( 1.2f * x + 5.92f ) + 1.9f );
}
#line 226
float3 InputLevels(float3 color, float3 inputwhitepoint, float3 inputblackpoint)
{
return color = (color - inputblackpoint)/(inputwhitepoint - inputblackpoint);
#line 230
}
#line 233
float3  Outputlevels(float3 color, float3 outputwhitepoint, float3 outputblackpoint)
{
return color * (outputwhitepoint - outputblackpoint) + outputblackpoint;
}
#line 239
float  InputLevel(float color, float inputwhitepoint, float inputblackpoint)
{
return (color - inputblackpoint)/(inputwhitepoint - inputblackpoint);
}
#line 245
float  Outputlevel(float color, float outputwhitepoint, float outputblackpoint)
{
return color * (outputwhitepoint - outputblackpoint) + outputblackpoint;
}
#line 253
float3 LevelsPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 InputColor = tex2D(ReShade::BackBuffer, texcoord).rgb;
float3 OutputColor = InputColor;
#line 307
if (EnableLevels == true)
{
OutputColor = pow(abs(((InputColor + (ColorRangeShift * ColorRangeShiftSwitch)) - InputBlackPoint)/(InputWhitePoint - InputBlackPoint)), InputGamma) * (OutputWhitePoint - OutputBlackPoint) + OutputBlackPoint;
} else {
OutputColor = InputColor;
}
#line 314
if (ACEScurve == true)
{
OutputColor = ACESFilmRec2020(OutputColor);
}
#line 319
if (HighlightClipping == true)
{
float3 ClippedColor;
#line 324
if (any(OutputColor > saturate(OutputColor)))
ClippedColor = float3(1.0, 1.0, 0.0);
else
ClippedColor = OutputColor;
#line 330
if (any(OutputColor > saturate(OutputColor)))
ClippedColor = float3(1.0, 0.0, 0.0);
else
ClippedColor = OutputColor;
#line 336
if (any(OutputColor < saturate(OutputColor)))
ClippedColor = float3(0.0, 1.0, 1.0);
else
ClippedColor = OutputColor;
#line 342
if (any(OutputColor < saturate(OutputColor)))
ClippedColor = float3(0.0, 0.0, 1.0);
else
ClippedColor = OutputColor;
#line 347
OutputColor = ClippedColor;
}
#line 353
return OutputColor;
#line 355
}
#line 357
technique ExtendedLevels
{
pass
{
VertexShader = PostProcessVS;
PixelShader = LevelsPass;
}
}

