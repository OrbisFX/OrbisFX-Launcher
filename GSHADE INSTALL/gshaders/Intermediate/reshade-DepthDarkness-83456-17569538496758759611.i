#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\DepthDarkness.fx"
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
#line 41 "C:\Program Files\GShade\gshade-shaders\Shaders\DepthDarkness.fx"
#line 42
namespace DepthDarkness
{
#line 55
uniform float FocusPlane <
ui_label= "Focus plane";
ui_type = "drag";
ui_min = 0.001; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "The depth of the plane where the blur starts, related to the camera";
> = 0.010;
uniform float FocusRange <
ui_label= "Focus range";
ui_type = "drag";
ui_min = 0.001; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "The range around the focus plane that's more or less not blurred.\n1.0 is the FocusPlaneMaxRange.";
> = 0.001;
uniform float FocusPlaneMaxRange <
ui_label= "Focus plane max range";
ui_type = "drag";
ui_min = 10; ui_max = 300;
ui_step = 1;
ui_tooltip = "The max range Focus Plane for when Focus Plane is 1.0.\n1000 is the horizon.";
> = 50;
uniform float3 DarknessColor <
ui_label = "Darkness color";
ui_type= "color";
> = float3(0.0, 0.0, 0.0);
uniform float BlendFactor <
ui_label="Blend factor";
ui_type = "drag";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "How strong the effect is applied to the original image. 1.0 is 100%, 0.0 is 0%.";
ui_step = 0.01;
> = 1.000;
#line 121
void PS_ApplyDarkness(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target0)
{
float colorDepth = ReShade::GetLinearizedDepth(texcoord);
float focusRangeStart = (FocusPlane * FocusPlaneMaxRange) / 1000.0f;
float focusRangeToUse = ((FocusRange * FocusPlaneMaxRange) / 10000.0f);
float focusRangeEnd = focusRangeStart + focusRangeToUse;
float4 color = tex2Dlod(ReShade::BackBuffer, float4(texcoord, 0.0f, 0.0f));
#line 129
float3 fragmentPreBlend = colorDepth < focusRangeStart ? color.rgb : lerp(color.rgb, DarknessColor, saturate(1-((focusRangeEnd-colorDepth) / focusRangeToUse)));
fragment = float4(lerp(color.rgb, fragmentPreBlend.rgb, BlendFactor), 1.0f);
}
#line 133
technique DepthDarkness
#line 135
< ui_tooltip = "Depth Darkness "
"v1.0"
"\n===========================================\n\n"
"Super-simple shader to apply a darkness at a depth\n"
"with a softness edge\n\n"
"By Frans 'Otis_Inf' Bouma and is part of OtisFX\n"
"https://fransbouma.com | https://github.com/FransBouma/OtisFX"; >
#line 143
{
pass ApplyDarkness { VertexShader = PostProcessVS; PixelShader = PS_ApplyDarkness; }
}
}

