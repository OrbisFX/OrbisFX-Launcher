#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\SunsetFilter.fx"
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
#line 22 "C:\Program Files\GShade\gshade-shaders\Shaders\SunsetFilter.fx"
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
#line 23 "C:\Program Files\GShade\gshade-shaders\Shaders\SunsetFilter.fx"
#line 28
uniform float3 ColorA
<
ui_type = "color";
ui_label = "Colour (A)";
ui_category = "Colors";
> = float3(1f, 0f, 0f);
#line 35
uniform float3 ColorB
<
ui_type = "color";
ui_label = "Colour (B)";
ui_type = "color";
ui_category = "Colors";
> = float3(0f, 0f, 0f);
#line 43
uniform bool Flip
<
ui_label = "Color flip";
ui_category = "Colors";
> = false;
#line 49
uniform int Axis
<
ui_type = "slider";
ui_units = "°";
ui_label = "Angle";
ui_min = -180; ui_max = 180;
ui_category = "Controls";
> = -7;
#line 58
uniform float Scale
<
ui_type = "slider";
ui_label = "Gradient sharpness";
ui_min = 0.5; ui_max = 1f; ui_step = 0.005;
ui_category = "Controls";
> = 1f;
#line 66
uniform float Offset
<
ui_type = "slider";
ui_label = "Position";
ui_min = 0f; ui_max = 0.5;
ui_category = "Controls";
> = 0f;
#line 79
float Overlay(float Layer)
{
float Min = min(Layer, 0.5);
float Max = max(Layer, 0.5);
return 2f*(Min*Min+2f*Max-Max*Max)-1.5;
}
#line 87
float3 Screen(float3 LayerA, float3 LayerB)
{ return 1f-(1f-LayerA)*(1f-LayerB); }
#line 94
void SunsetFilterPS(
float4 vpos      : SV_Position,
float2 UvCoord   : TEXCOORD,
out float3 Image : SV_Target
)
{
#line 101
Image = GammaConvert::to_linear(tex2D(ReShade::BackBuffer, UvCoord).rgb);
#line 103
float2 UvCoordAspect = UvCoord;
UvCoordAspect.y += (1920 * (1.0 / 1018))*0.5-0.5;
UvCoordAspect.y /= (1920 * (1.0 / 1018));
#line 107
UvCoordAspect = UvCoordAspect*2f-1f;
UvCoordAspect *= Scale;
#line 111
float Angle = radians(-Axis);
float2 TiltVector = float2(sin(Angle), cos(Angle));
#line 115
float BlendMask = dot(TiltVector, UvCoordAspect)+Offset;
BlendMask = Overlay(BlendMask*0.5+0.5); 
#line 119
Image = Screen(
Image.rgb,
lerp(
GammaConvert::to_linear(ColorA),
GammaConvert::to_linear(ColorB),
Flip ? 1f-BlendMask : BlendMask
));
#line 127
Image = GammaConvert::to_display(Image);
}
#line 134
technique SunsetFilter
<
ui_label = "Sunset Filter";
ui_tooltip =
"This effect © 2018-2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY-SA 4.0";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = SunsetFilterPS;
}
}

