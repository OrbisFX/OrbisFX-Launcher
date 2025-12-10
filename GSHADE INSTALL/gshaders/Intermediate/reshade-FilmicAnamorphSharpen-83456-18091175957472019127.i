// ITU_REC=709
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicAnamorphSharpen.fx"
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
#line 23 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicAnamorphSharpen.fx"
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
#line 24 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicAnamorphSharpen.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\LinearGammaWorkflow.fxh"
#line 39
namespace GammaConvert
{
#line 54
float  to_display(float  g) { return ((g)<=0.0031308? (g)*12.92 : exp(log(g)/2.4)*1.055-0.055); }
float2 to_display(float2 g) { return ((g)<=0.0031308? (g)*12.92 : exp(log(g)/2.4)*1.055-0.055); }
float3 to_display(float3 g) { return ((g)<=0.0031308? (g)*12.92 : exp(log(g)/2.4)*1.055-0.055); }
float4 to_display(float4 g) { return ((g)<=0.0031308? (g)*12.92 : exp(log(g)/2.4)*1.055-0.055); }
#line 59
float  to_linear( float  g) { return ((g)<=0.04049936? (g)/12.92 : exp(log((g+0.055)/1.055)*2.4)); }
float2 to_linear( float2 g) { return ((g)<=0.04049936? (g)/12.92 : exp(log((g+0.055)/1.055)*2.4)); }
float3 to_linear( float3 g) { return ((g)<=0.04049936? (g)/12.92 : exp(log((g+0.055)/1.055)*2.4)); }
float4 to_linear( float4 g) { return ((g)<=0.04049936? (g)/12.92 : exp(log((g+0.055)/1.055)*2.4)); }
}
#line 25 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicAnamorphSharpen.fx"
#line 30
uniform float Strength
<
ui_type = "slider";
ui_label = "Strength";
ui_min = 0.0; ui_max = 100.0; ui_step = 0.01;
> = 60.0;
#line 37
uniform float Offset
<
ui_type = "slider";
ui_units = " pixel";
ui_label = "Radius";
ui_tooltip = "High-pass cross offset in pixels";
ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 0.1;
#line 46
uniform float Clamp
<
ui_type = "slider";
ui_label = "Clamping";
ui_min = 0.5; ui_max = 1.0; ui_step = 0.001;
> = 0.65;
#line 53
uniform bool UseMask
<
ui_type = "input";
ui_label = "Sharpen only center";
ui_tooltip = "Sharpen only in center of the image";
> = false;
#line 60
uniform bool DepthMask
<
ui_type = "input";
ui_label = "Enable depth rim masking";
ui_tooltip = "Depth high-pass mask switch";
ui_category = "Depth mask";
ui_category_closed = true;
> = false;
#line 69
uniform int DepthMaskContrast
<
ui_type = "drag";
ui_label = "Edges mask strength";
ui_tooltip = "Depth high-pass mask amount";
ui_category = "Depth mask";
ui_min = 0; ui_max = 2000; ui_step = 1;
> = 128;
#line 78
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
#line 94
sampler BackBuffer
{
Texture = ReShade::BackBufferTex;
AddressU = MIRROR;
AddressV = MIRROR;
};
#line 106
float Overlay(float LayerA, float LayerB)
{
float MinA = min(LayerA, 0.5);
float MinB = min(LayerB, 0.5);
float MaxA = max(LayerA, 0.5);
float MaxB = max(LayerB, 0.5);
return 2f*(MinA*MinB+MaxA+MaxB-MaxA*MaxB)-1.5;
}
#line 116
float Overlay(float LayerAB)
{
float MinAB = min(LayerAB, 0.5);
float MaxAB = max(LayerAB, 0.5);
return 2f*(MinAB*MinAB+MaxAB+MaxAB-MaxAB*MaxAB)-1.5;
}
#line 128
float3 FilmicAnamorphSharpenPS(
float4 pos     : SV_Position,
float2 UvCoord : TEXCOORD
) : SV_Target
{
#line 134
float3 Source = GammaConvert::to_linear(tex2D(BackBuffer, UvCoord).rgb);
#line 137
float Mask;
if (UseMask)
{
#line 141
Mask = 1f-length(UvCoord*2f-1f);
Mask = Overlay(Mask) * Strength;
#line 144
if (Mask<=0) return GammaConvert::to_display(Source);
}
else Mask = Strength;
#line 149
float2 Pixel = float2((1.0 / 1920), (1.0 / 1018));
#line 151
if (DepthMask)
{
#line 160
float2 PixelOffset = Pixel * Offset;
float2 DepthPixel = PixelOffset + Pixel;
Pixel = PixelOffset;
#line 165
float SourceDepth = ReShade::GetLinearizedDepth(UvCoord);
#line 167
float2 NorSouWesEst[4] = {
float2(UvCoord.x, UvCoord.y + Pixel.y),
float2(UvCoord.x, UvCoord.y - Pixel.y),
float2(UvCoord.x + Pixel.x, UvCoord.y),
float2(UvCoord.x - Pixel.x, UvCoord.y)
};
#line 174
float2 DepthNorSouWesEst[4] = {
float2(UvCoord.x, UvCoord.y + DepthPixel.y),
float2(UvCoord.x, UvCoord.y - DepthPixel.y),
float2(UvCoord.x + DepthPixel.x, UvCoord.y),
float2(UvCoord.x - DepthPixel.x, UvCoord.y)
};
#line 183
float HighPassColor = 0f, DepthMask = 0f;
#line 185
[unroll]for(int s=0; s<4; s++)
{
HighPassColor +=
ColorConvert::RGB_to_Luma(
GammaConvert::to_linear(
tex2D(BackBuffer, NorSouWesEst[s]).rgb
));
DepthMask +=
ReShade::GetLinearizedDepth(NorSouWesEst[s])
+ReShade::GetLinearizedDepth(DepthNorSouWesEst[s]);
}
#line 197
HighPassColor = 0.5-0.5*(HighPassColor*0.25-ColorConvert::RGB_to_Luma(Source));
#line 199
DepthMask = 1f-DepthMask*0.125+SourceDepth;
DepthMask = min(1f, DepthMask)+1f-max(1f, DepthMask);
DepthMask = saturate(DepthMaskContrast*DepthMask+1f-DepthMaskContrast);
#line 204
HighPassColor = lerp(0.5, HighPassColor, Mask*DepthMask);
#line 218
HighPassColor = Clamp!=1f ? clamp(HighPassColor, 1f-Clamp, Clamp ) : HighPassColor;
#line 220
float3 Sharpen = float3(
Overlay(Source.r, HighPassColor),
Overlay(Source.g, HighPassColor),
Overlay(Source.b, HighPassColor)
);
#line 226
if(Preview) 
{
float PreviewChannel = lerp(HighPassColor, HighPassColor*DepthMask, 0.5);
return
GammaConvert::to_display(float3(
1f-DepthMask * (1f-HighPassColor),
PreviewChannel,
PreviewChannel
));
}
#line 237
return GammaConvert::to_display(Sharpen);
}
else
{
Pixel *= Offset;
#line 243
float2 NorSouWesEst[4] = {
float2(UvCoord.x, UvCoord.y + Pixel.y),
float2(UvCoord.x, UvCoord.y - Pixel.y),
float2(UvCoord.x + Pixel.x, UvCoord.y),
float2(UvCoord.x - Pixel.x, UvCoord.y)
};
#line 251
float HighPassColor = 0f;
[unroll] for(uint s=0u; s<4u; s++)
HighPassColor +=
ColorConvert::RGB_to_Luma(
GammaConvert::to_linear(
tex2D(BackBuffer, NorSouWesEst[s]).rgb
));
#line 262
HighPassColor = 0.5-0.5*(HighPassColor*0.25-ColorConvert::RGB_to_Luma(Source));
#line 265
HighPassColor = lerp(0.5, HighPassColor, Mask);
#line 279
HighPassColor = Clamp!=1f ? clamp(HighPassColor, 1f-Clamp, Clamp) : HighPassColor;
#line 281
float3 Sharpen = float3(
Overlay(Source.r, HighPassColor),
Overlay(Source.g, HighPassColor),
Overlay(Source.b, HighPassColor)
);
#line 287
return GammaConvert::to_display(
Preview 
? HighPassColor
: Sharpen
);
}
}
#line 299
technique FilmicAnamorphSharpen
<
ui_label = "Filmic Anamorphic Sharpen";
ui_tooltip =
"This effect © 2018-2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY-SA 4.0";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = FilmicAnamorphSharpenPS;
}
}

