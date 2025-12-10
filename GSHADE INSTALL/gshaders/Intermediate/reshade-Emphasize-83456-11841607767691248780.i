#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Emphasize.fx"
#line 33
uniform float FocusDepth <
ui_type = "slider";
ui_min = 0.000; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "Manual focus depth of the point which has the focus. Range from 0.0, which means camera is the focus plane, till 1.0 which means the horizon is focus plane.";
> = 0.026;
uniform float FocusRangeDepth <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "The depth of the range around the manual focus depth which should be emphasized. Outside this range, de-emphasizing takes place";
> = 0.001;
uniform float FocusEdgeDepth <
ui_type = "slider";
ui_min = 0.000; ui_max = 1.000;
ui_tooltip = "The depth of the edge of the focus range. Range from 0.00, which means no depth, so at the edge of the focus range, the effect kicks in at full force,\ntill 1.00, which means the effect is smoothly applied over the range focusRangeEdge-horizon.";
ui_step = 0.001;
> = 0.050;
uniform bool Spherical <
ui_tooltip = "Enables Emphasize in a sphere around the focus-point instead of a 2D plane";
> = false;
uniform int Sphere_FieldOfView <
ui_type = "slider";
ui_min = 1; ui_max = 180;
ui_tooltip = "Specifies the estimated Field of View you are currently playing with. Range from 1, which means 1 Degree, till 180 which means 180 Degree (half the scene).\nNormal games tend to use values between 60 and 90.";
> = 75;
uniform float Sphere_FocusHorizontal <
ui_type = "slider";
ui_min = 0; ui_max = 1;
ui_tooltip = "Specifies the location of the focuspoint on the horizontal axis. Range from 0, which means left screen border, till 1 which means right screen border.";
> = 0.5;
uniform float Sphere_FocusVertical <
ui_type = "slider";
ui_min = 0; ui_max = 1;
ui_tooltip = "Specifies the location of the focuspoint on the vertical axis. Range from 0, which means upper screen border, till 1 which means bottom screen border.";
> = 0.5;
uniform float3 BlendColor <
ui_type = "color";
ui_tooltip = "Specifies the blend color to blend with the greyscale. in (Red, Green, Blue). Use dark colors to darken further away objects";
> = float3(0.0, 0.0, 0.0);
uniform float BlendFactor <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Specifies the factor BlendColor is blended. Range from 0.0, which means full greyscale, till 1.0 which means full blend of the BlendColor";
> = 0.0;
uniform float EffectFactor <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Specifies the factor the desaturation is applied. Range from 0.0, which means the effect is off (normal image), till 1.0 which means the desaturated parts are\nfull greyscale (or color blending if that's enabled)";
> = 0.9;
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
#line 85 "C:\Program Files\GShade\gshade-shaders\Shaders\Emphasize.fx"
#line 94
float CalculateDepthDiffCoC(float2 texcoord : TEXCOORD)
{
const float scenedepth = ReShade::GetLinearizedDepth(texcoord);
const float scenefocus =  FocusDepth;
const float desaturateFullRange = FocusRangeDepth+FocusEdgeDepth;
float depthdiff;
#line 101
if(Spherical == true)
{
texcoord.x = (texcoord.x-Sphere_FocusHorizontal)*1920;
texcoord.y = (texcoord.y-Sphere_FocusVertical)*1018;
const float degreePerPixel = Sphere_FieldOfView*(1.0 / 1920);
const float fovDifference = sqrt((texcoord.x*texcoord.x)+(texcoord.y*texcoord.y))*degreePerPixel;
depthdiff = sqrt((scenedepth*scenedepth)+(scenefocus*scenefocus)-(2*scenedepth*scenefocus*cos(fovDifference*(2*3.1415927/360))));
}
else
{
depthdiff = abs(scenedepth-scenefocus);
}
#line 114
if (depthdiff > desaturateFullRange)
return saturate(1.0);
else
return saturate(smoothstep(0, desaturateFullRange, depthdiff));
}
#line 120
void PS_Otis_EMZ_Desaturate(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 outFragment : SV_Target)
{
const float depthDiffCoC = CalculateDepthDiffCoC(texcoord.xy);
const float4 colFragment = tex2D(ReShade::BackBuffer, texcoord);
const float greyscaleAverage = (colFragment.x + colFragment.y + colFragment.z) / 3.0;
float4 desColor = float4(greyscaleAverage, greyscaleAverage, greyscaleAverage, depthDiffCoC);
desColor = lerp(desColor, float4(BlendColor, depthDiffCoC), BlendFactor);
outFragment = lerp(colFragment, desColor, saturate(depthDiffCoC * EffectFactor));
#line 132
}
#line 134
technique Emphasize
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Otis_EMZ_Desaturate;
}
}

