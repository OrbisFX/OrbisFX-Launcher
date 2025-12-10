#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\LocalContrast.fx"
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
#line 14 "C:\Program Files\GShade\gshade-shaders\Shaders\LocalContrast.fx"
#line 28
uniform bool CorrectGamma <
ui_label = "Perform gamma correction";
ui_tootlip = "Applies S-curve to the corrected luma channel";
> = true;
#line 33
uniform int ContrastLimit <
ui_type = "slider";
ui_label = "Contrast limit";
ui_min = 0; ui_max = 63;
> = 40;
#line 45
texture LocalContrastMapBuffer
{
Width = 1920/8;
Height = 1018/8;
Format = RG8;
#line 52
};
sampler LocalContrastMap { Texture = LocalContrastMapBuffer; };
#line 56
sampler BackBuffer { Texture = ReShade::BackBufferTex; };
#line 63
static const float3x3 ToYUV709 =
float3x3(
float3(0.2126, 0.7152, 0.0722),
float3(-0.09991, -0.33609, 0.436),
float3(0.615, -0.55861, -0.05639)
);
#line 70
static const float3x3 ToYUV601 =
float3x3(
float3(0.299, 0.587, 0.114),
float3(-0.14713, -0.28886, 0.436),
float3(0.615, -0.51499, -0.10001)
);
#line 77
static const float3x3 ToRGB709 =
float3x3(
float3(1, 0, 1.28033),
float3(1, -0.21482, -0.38059),
float3(1, 2.12798, 0)
);
#line 84
static const float3x3 ToRGB601 =
float3x3(
float3(1, 0, 1.13983),
float3(1, -0.39465, -0.58060),
float3(1, 2.03211, 0)
);
#line 94
float weight(float gradient)
{
float bottom = min(gradient, 0.5);
float top = max(gradient, 0.5);
return 2.0 *(bottom*bottom +top +top -top*top) -1.5;
}
#line 101
float getContrastLimit()
{ return 1.0-ContrastLimit/127.0; }
#line 110
void GetLocalHistogramPS(
float4 pos : SV_Position,
float2 texcoord : TEXCOORD,
out float2 histogramStats : SV_Target 
){
#line 116
histogramStats.s = 1.0; 
histogramStats.t = 0.0; 
float histogramMean = 0.0; 
#line 120
const int halfBlock = 8/2;
for (int y=-halfBlock; y<halfBlock; y++)
for (int x=-halfBlock; x<halfBlock; x++)
{
#line 125
float luma = dot(ToYUV709[0], tex2D(BackBuffer, float2((1.0 / 1920), (1.0 / 1018))*float2(x, y)+texcoord).rgb);
#line 127
histogramStats.s = min(luma, histogramStats.s); 
histogramStats.t = max(luma, histogramStats.t); 
histogramMean += luma; 
}
histogramMean /= 8*8;
#line 133
const float contrastLimit = getContrastLimit();
histogramStats.s = min(histogramStats.s, max(0.0, histogramMean-contrastLimit));
histogramStats.t = max(histogramStats.t, min(1.0, histogramMean+contrastLimit));
}
#line 140
void LocalConstrastPS(
float4 pos : SV_Position,
float2 texcoord : TEXCOORD,
out float3 result : SV_Target
){
#line 146
result = mul(ToYUV709, tex2D(BackBuffer, texcoord).rgb);
#line 148
const float2 localContrast = tex2D(LocalContrastMap, texcoord).st;
#line 150
result.s = (result.s-localContrast.s)/(localContrast.t-localContrast.s);
#line 152
if (CorrectGamma)
{
float s_curve = 2.0-getContrastLimit()*2.0;
s_curve *= s_curve*s_curve; 
result.s = lerp(result.s, weight(result.s), s_curve);
}
#line 159
result = mul(ToRGB709, result);
#line 164
}
#line 171
technique LocalContrast <
ui_label = "Local Contrast";
ui_tooltip =
"CLAHE (contrast-limited adaptive histogram normalization)\n"
"\n"
"To change block size, edit global preprocessor definition:\n"
"\tLC_BLOCK\tdefault is 8"; >
{
pass Local_Histogram
{
VertexShader = PostProcessVS;
PixelShader = GetLocalHistogramPS;
RenderTarget = LocalContrastMapBuffer;
}
pass Historgram_Normalization
{
VertexShader = PostProcessVS;
PixelShader = LocalConstrastPS;
}
}

