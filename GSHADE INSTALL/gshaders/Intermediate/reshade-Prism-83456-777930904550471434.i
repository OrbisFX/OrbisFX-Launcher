#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Prism.fx"
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
#line 54 "C:\Program Files\GShade\gshade-shaders\Shaders\Prism.fx"
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
#line 55 "C:\Program Files\GShade\gshade-shaders\Shaders\Prism.fx"
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
#line 56 "C:\Program Files\GShade\gshade-shaders\Shaders\Prism.fx"
#line 61
uniform float4 K
<
ui_type = "drag";
ui_min = -0.1; ui_max =  0.1;
ui_label = "Radial 'k' coefficients";
ui_tooltip = "Radial distortion coefficients k1, k2, k3, k4.";
ui_category = "Chromatic aberration";
> = float4(0.016, 0f, 0f, 0f);
#line 70
uniform float AchromatAmount
<
ui_type = "slider";
ui_min = 0f; ui_max =  1f;
ui_label = "Achromat amount";
ui_tooltip = "Achromat strength factor.";
ui_category = "Chromatic aberration";
> = 0f;
#line 81
uniform uint ChromaticSamplesLimit
<
ui_type = "slider";
ui_min = 6u; ui_max = 128u; ui_step = 2u;
ui_label = "Samples limit";
ui_tooltip =
"Sample count is generated automatically per pixel, based on visible distortion amount.\n"
"This option limits maximum sample (steps) count allowed for color fringing.\n"
"Only even numbers are accepted, odd numbers will be clamped.";
ui_category = "Performance";
ui_category_closed = true;
> = 64u;
#line 101
float3 Spectrum(float hue)
{
float3 hueColor;
hue *= 4f; 
hueColor.rg = hue-float2(1f, 2f);
hueColor.rg = saturate(1.5-abs(hueColor.rg));
hueColor.r += saturate(hue-3.5);
hueColor.b = 1f-hueColor.r;
return hueColor;
}
#line 117
sampler BackBuffer
{
Texture = ReShade::BackBufferTex;
#line 121
AddressU = MIRROR;
AddressV = MIRROR;
};
#line 130
void ChromaticAberrationVS(
in  uint   id        : SV_VertexID,
out float4 position  : SV_Position,
out float2 viewCoord : TEXCOORD
)
{
#line 137
const float2 vertexPos[3] =
{
float2(-1f, 1f), 
float2(-1f,-3f), 
float2( 3f, 1f)  
};
#line 144
viewCoord.x =  vertexPos[id].x;
viewCoord.y = -vertexPos[id].y;
#line 147
viewCoord *= normalize(float2(1280, 720));
#line 149
position = float4(vertexPos[id], 0f, 1f);
}
#line 153
void ChromaticAberrationPS(
float4 pixelPos  : SV_Position,
float2 viewCoord : TEXCOORD,
out float3 color : SV_Target
)
{
#line 160
float4 pow_radius;
pow_radius[0] = dot(viewCoord, viewCoord); 
pow_radius[1] = pow_radius[0]*pow_radius[0]; 
pow_radius[2] = pow_radius[1]*pow_radius[0]; 
pow_radius[3] = pow_radius[2]*pow_radius[0]; 
#line 166
float2 distortion = viewCoord*(rcp(1f+dot(K, pow_radius))-1f)/normalize(float2(1280, 720))*0.5; 
#line 168
viewCoord = pixelPos.xy*float2((1.0 / 1280), (1.0 / 720));
#line 170
uint evenSampleCount = min(ChromaticSamplesLimit-ChromaticSamplesLimit%2u, 128u); 
#line 172
uint totalPixelOffset = uint(ceil(length(distortion*float2(1280, 720))));
#line 174
evenSampleCount = clamp(totalPixelOffset+totalPixelOffset%2u, 4u, evenSampleCount);
#line 177
color = 0f; 
for (uint i=0u; i<evenSampleCount; i++)
{
float progress = i/float(evenSampleCount-1u)-0.5;
progress = lerp(progress, 0.5-abs(progress), AchromatAmount);
color +=
#line 184
GammaConvert::to_linear(
tex2Dlod(
BackBuffer, 
float4(
progress 
*distortion 
+viewCoord, 
0f, 0f)).rgb
)
*Spectrum(i/float(evenSampleCount)); 
}
#line 196
color *= 2f/evenSampleCount;
color = GammaConvert::to_display(color); 
color = BlueNoise::dither(color, uint2(pixelPos.xy)); 
}
#line 205
technique ChromaticAberration
<
ui_label = "Chromatic Aberration";
ui_tooltip =
"Chromatic aberration color split at the screen borders.\n"
"\n"
"	· Dynamic minimal sample count per pixel.\n"
"	· Accurate color split.\n"
"	· Driven by lens distortion Brown-Conrady division model.\n"
"\n"
"This effect © 2018-2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY-NC-ND 3.0 +\n"
"for additional permissions see the source code.";
>
{
pass ChromaticColorSplit
{
VertexShader = ChromaticAberrationVS;
PixelShader  = ChromaticAberrationPS;
}
}

