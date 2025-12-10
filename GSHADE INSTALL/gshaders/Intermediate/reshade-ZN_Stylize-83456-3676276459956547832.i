#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ZN_Stylize.fx"
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
#line 9 "C:\Program Files\GShade\gshade-shaders\Shaders\ZN_Stylize.fx"
#line 10
texture ditherTex < source = "ZNbluenoise512.png"; > { Width = 512; Height = 512; Format = RGBA8; };
sampler	ditherSam 	{ Texture = ditherTex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
#line 14
uniform float Pixel_Size <
ui_type = "slider";
ui_tooltip = "Pixelates the image";
ui_label = "Pixel Size";
ui_min = 0.0;
ui_max = 16.0;
ui_step = 1.0;
> = 3.0;
#line 23
uniform float Dither_Strength <
ui_type = "slider";
ui_tooltip = "Introduces noise to reduce color banding";
ui_label = "Dither Intensity";
ui_min = 0.0;
ui_max = 1.0;
> = 0.05;
#line 31
uniform float Contrast <
ui_type = "slider";
ui_min = 0.01;
ui_max = 3.0;
> = 0.85;
#line 37
uniform float Pre_Boost <
ui_type = "slider";
ui_tooltip = "Boost brightness before color adjustments";
ui_label = "Pre-Boost";
ui_min = 0.0;
ui_max = 3.0;
> = 0.55;
#line 45
uniform float ToneGrade_Blend <
ui_type = "slider";
ui_tooltip = "Blends between a lightly tonemapped and color graded input";
ui_label = "Color Grading";
ui_min = 0.0;
ui_max = 1.0;
> = 0.6;
#line 53
uniform float Color_Quantize <
ui_type = "slider";
ui_tooltip = "Reduces color depth to introduce banding.";
ui_label = "Color Quantization";
ui_min = 1.0;
ui_max = 255.0;
ui_step = 1.0;
> = 32;
#line 62
uniform float Bright_Scoop <
ui_type = "slider";
ui_tooltip = "Increases contrast for brighter colors to prevent an overly bright image.";
ui_label = "Bright Scoop";
ui_min = 0.0;
ui_max = 30.0;
> = 3.0;
#line 72
float3 ACESFilm(float3 x)
{
float a = 2.51f;
float b = 0.03f;
float c = 2.43f;
float d = 0.59f;
float e = 0.14f;
return saturate((x*(a*x+b))/(x*(c*x+d)+e));
}
#line 84
float3 ZN_Stylize_FXmain(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float2 uv = float2(1920, 1018);
#line 88
float2 CCV = 1.0 / Pixel_Size * uv;
float3 ditherQuant = tex2D(ditherSam, ((texcoord * uv / (512 * Pixel_Size)) - floor(texcoord * uv / (512 * Pixel_Size)))).rgb;	
float3 TexQuant = tex2D(ReShade::BackBuffer, 0.5 / uv +floor((texcoord * CCV)) / CCV).rgb;
float3 input = tex2D(ReShade::BackBuffer, 0.5 / uv + floor((texcoord * CCV)) / CCV).rgb; 
#line 94
input = pow(max(input, 0.0), 2.2) * Pre_Boost;
#line 98
float3 blend = pow(max(input, 0.0), Contrast * (1.0 / 2.2));
blend.r = ((pow(max(blend.r, 0.0), Bright_Scoop) / 1.77) + 1.0) * (0.8 * pow(max(sin (2.04* blend.r), 0.0), 1.9) );
blend.g = ((pow(max(blend.g, 0.0), Bright_Scoop) / 1.77) + 1.0) * (0.8 * pow(max(sin (2.02* blend.g), 0.0), 2.0) );
blend.b = ((pow(max(blend.b, 0.0), Bright_Scoop) / 1.77) + 1.0) * (0.8 * pow(max(sin (2.02* blend.b), 0.0), 1.9) );
#line 104
input = ACESFilm(input);
#line 107
input = pow(input, 1.0 / 2.2);
#line 110
input = lerp(input, blend, ToneGrade_Blend);
#line 113
input = pow(max((1 - Dither_Strength) * input - Dither_Strength * ditherQuant, 0.0), Contrast);
#line 116
input = round((input) * Color_Quantize) / Color_Quantize;
#line 118
return input;
}
#line 121
technique ZN_Stylize
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ZN_Stylize_FXmain;
}
}

