// ITU_REC=709
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\SimpleGrain.fx"
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
#line 22 "C:\Program Files\GShade\gshade-shaders\Shaders\SimpleGrain.fx"
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
#line 23 "C:\Program Files\GShade\gshade-shaders\Shaders\SimpleGrain.fx"
#line 28
uniform float Intensity
<
ui_type = "slider";
ui_label = "Noise intensity";
ui_min = 0f; ui_max = 1f; ui_step = 0.002;
> = 0.4;
#line 35
uniform int Framerate
<
ui_type = "slider";
ui_label = "Noise framerate";
ui_tooltip = "Zero will match in-game framerate";
ui_step = 1;
ui_min = 0; ui_max = 120;
> = 12;
#line 48
uniform float Timer < source = "timer"; >;
uniform int FrameCount < source = "framecount"; >;
#line 56
float Overlay(float LayerA, float LayerB)
{
float MinA = min(LayerA, 0.5);
float MinB = min(LayerB, 0.5);
float MaxA = max(LayerA, 0.5);
float MaxB = max(LayerB, 0.5);
return 2*(MinA*MinB+MaxA+MaxB-MaxA*MaxB)-1.5;
}
#line 66
float SimpleNoise(float p)
{ return frac(sin(dot(p, float2(12.9898, 78.233)))*43758.5453); }
#line 74
void SimpleGrainPS(
float4 vois      : SV_Position,
float2 TexCoord  : TEXCOORD,
out float3 Image : SV_Target
)
{
#line 81
Image = tex2D(ReShade::BackBuffer, TexCoord).rgb;
#line 83
const float GoldenAB = sqrt(5f)*0.5+0.5;
float Mask = pow(
abs(1f-ColorConvert::RGB_to_Luma(Image)),
GoldenAB
);
#line 89
float Seed = Framerate == 0
? FrameCount
: floor(Timer*0.001*Framerate);
#line 94
Seed %= 10000;
#line 96
const float GoldenABh = sqrt(5f)*0.25+0.25;
float Noise = saturate(SimpleNoise(Seed*TexCoord.x*TexCoord.y)*GoldenABh);
Noise = lerp(0.5, Noise, Intensity*0.1*Mask);
#line 100
Image.rgb = float3(
Overlay(Image.r, Noise),
Overlay(Image.g, Noise),
Overlay(Image.b, Noise)
);
}
#line 111
technique SimpleGrain
<
ui_label = "Simple Grain";
ui_tooltip =
"This effect © 2018-2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY-SA 4.0";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = SimpleGrainPS;
}
}

