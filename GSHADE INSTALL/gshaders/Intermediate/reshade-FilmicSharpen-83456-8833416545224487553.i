// ITU_REC=709
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicSharpen.fx"
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
#line 28 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicSharpen.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorConversion.fxh"
#line 52
namespace ColorConvert
{
#line 67
static const float3x3 YCbCrMtx =
float3x3(
float3(0.2126, 1f-0.2126-0.0722, 0.0722), 
float3(-0.5*0.2126/(1f-0.0722), -0.5*(1f-0.2126-0.0722)/(1f-0.0722), 0.5), 
float3(0.5, -0.5*(1f-0.2126-0.0722)/(1f-0.2126), -0.5*0.0722/(1f-0.2126))  
);
#line 75
static const float3x3 RGBMtx =
float3x3(
float3(1f, 0f, 2f-2f*0.2126), 
float3(1f, -0.0722/(1f-0.2126-0.0722)*(2f-2f*0.0722), -0.2126/(1f-0.2126-0.0722)*(2f-2f*0.2126)), 
float3(1f, 2f-2f*0.0722, 0f) 
);
#line 86
float3 RGB_to_YCbCr(float3 color)  
{ return mul(YCbCrMtx, color);}
float  RGB_to_Luma(float3 color)   
{ return dot(YCbCrMtx[0], color);}
float2 RGB_to_Chroma(float3 color) 
{ return float2(dot(YCbCrMtx[1], color), dot(YCbCrMtx[2], color));}
#line 93
float3 YCbCr_to_RGB(float3 color)  
{ return mul(RGBMtx, color);}
}
#line 29 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicSharpen.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\BlueNoiseDither.fxh"
#line 54
namespace BlueNoise
{
#line 59
texture BlueNoiseTex
<
source = "j_bluenoise.png";
pooled = true;
>
{
Width = 64u;
Height = 64u;
Format = RGBA8;
};
#line 70
sampler BlueNoiseTexSmp
{
Texture = BlueNoiseTex;
#line 74
AddressU = REPEAT;
AddressV = REPEAT;
};
#line 87
float dither(float gradient, uint2 pixelPos)
{
#line 90
float noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u).r;
#line 92
gradient = ceil(mad(255u, gradient, -noise)); 
#line 94
return gradient/255u;
}
float3 dither(float3 color, uint2 pixelPos)
{
#line 99
float3 noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u).rgb;
#line 101
color = ceil(mad(255u, color, -noise)); 
#line 103
return color/255u;
}
float4 dither(float4 color, uint2 pixelPos)
{
#line 108
float4 noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u);
#line 110
color = ceil(mad(255u, color, -noise)); 
#line 112
return color/255u;
}
}
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicSharpen.fx"
#line 35
uniform uint Strength
<
ui_type = "slider";
ui_label = "Strength";
ui_min = 1u; ui_max = 64u;
> = 32u;
#line 42
uniform float Offset
<
ui_type = "slider";
ui_units = " pixel";
ui_label = "Radius";
ui_tooltip = "High-pass cross offset in pixels";
ui_min = 0.05; ui_max = 0.25; ui_step = 0.01;
> = 0.1;
#line 51
uniform bool UseMask
<
ui_type = "input";
ui_label = "Sharpen only center";
ui_tooltip = "Sharpen only in center of the image";
> = false;
#line 58
uniform float Clamp
<
ui_type = "slider";
ui_label = "Clamping highlights";
ui_min = 0.5; ui_max = 1.0; ui_step = 0.1;
ui_category = "Additional settings";
ui_category_closed = true;
> = 0.6;
#line 67
uniform bool Preview
<
ui_type = "input";
ui_label = "Preview sharpen layer";
ui_tooltip = "Preview sharpen layer and mask for adjustment.\n"
"If you don't see red strokes,\n"
"try changing Preprocessor Definitions in the Settings tab.";
ui_category = "Debug View";
ui_category_closed = true;
> = false;
#line 83
float Overlay(float LayerA, float LayerB)
{
float MinA = min(LayerA, 0.5);
float MinB = min(LayerB, 0.5);
float MaxA = max(LayerA, 0.5);
float MaxB = max(LayerB, 0.5);
return 2f*((MinA*MinB+MaxA)+(MaxB-MaxA*MaxB))-1.5;
}
#line 97
void FilmicSharpenPS(
float4 pixelPos  : SV_Position,
float2 UvCoord   : TEXCOORD,
out float3 color : SV_Target
)
{
#line 104
color = tex2D(ReShade::BackBuffer, UvCoord).rgb;
#line 107
float Mask;
if (UseMask)
{
#line 111
float2 viewCoord = UvCoord*2f-1f;
#line 113
viewCoord.y *= 1018*(1.0 / 1920);
#line 115
Mask = Strength-min(dot(viewCoord, viewCoord), 1f)*Strength;
}
else Mask = Strength;
#line 120
float2 Pixel = float2((1.0 / 1920), (1.0 / 1018))*Offset;
#line 123
float2 NorSouWesEst[4] = {
float2(UvCoord.x, UvCoord.y+Pixel.y),
float2(UvCoord.x, UvCoord.y-Pixel.y),
float2(UvCoord.x+Pixel.x, UvCoord.y),
float2(UvCoord.x-Pixel.x, UvCoord.y)
};
#line 131
float HighPass = 0f;
[unroll] for(uint i=0u; i<4u; i++)
HighPass += ColorConvert::RGB_to_Luma(tex2D(ReShade::BackBuffer, NorSouWesEst[i]).rgb);
#line 135
HighPass = 0.5-0.5*(HighPass*0.25-ColorConvert::RGB_to_Luma(color));
#line 138
HighPass = lerp(0.5, HighPass, Mask);
#line 141
HighPass = Clamp!=1f? clamp(HighPass, 1f-Clamp, Clamp) : HighPass;
#line 144
if (Preview) color = HighPass;
else
{
[unroll] for(uint i=0u; i<3u; i++)
#line 149
color[i] = Overlay(color[i], HighPass);
}
#line 153
color = BlueNoise::dither(color, uint2(pixelPos.xy));
}
#line 160
technique FilmicSharpen
<
ui_label = "Filmic Sharpen";
ui_tooltip =
"This effect © 2018-2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY-SA 4.0";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = FilmicSharpenPS;
}
}

