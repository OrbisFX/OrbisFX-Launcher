#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MC_Tonemap.fx"
#line 25
uniform float Contrast <
ui_type = "slider";
ui_min = 1.0; ui_max = 16.0; ui_step = 0.01;
ui_tooltip = "Increases contrast in the middle of the visible brightness range at the expense of shadows and highlights.";
ui_label = "Contrast";
> = 1.0;
#line 32
uniform float Compression <
ui_type = "slider";
ui_min = 0.001; ui_max = 16.0; ui_step = 0.01;
ui_tooltip = "Compress highlights";
ui_label = "Compression";
> = 0.00001;
#line 39
uniform float BlackLevel <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0; ui_step = 0.0025;
ui_tooltip = "Subtract this value from final result to compensate for monitor's diffuse reflection";
ui_label = "Black Level";
> = 0.0;
#line 46
uniform bool DeGamma <
ui_label = "DeGamma";
ui_tooltip = "Assume that colors are stored in gamma space";
> = false;
#line 51
uniform float Exposure <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0; ui_step = 0.025;
ui_tooltip = "Exposure";
ui_label = "Exposure";
> = 1.0;
#line 58
uniform float SaturationLuma <
ui_type = "slider";
ui_min = 0.0; ui_max = 8.0; ui_step = 0.1;
ui_tooltip = "Saturation (luma)";
ui_label = "Use compression based on luma instead of per-color (increases saturation, gives cartoony look)";
> = 0.0;
#line 65
uniform float Saturation <
ui_type = "slider";
ui_min = 0.0; ui_max = 4.0; ui_step = 0.1;
ui_tooltip = "Saturation";
> = 1.0;
#line 71
uniform int LumaCoefs <
ui_type = "combo";
ui_label = "Luma coefficients for saturation calculation";
ui_items = "Equal (0.33,0.33,0.33)\0Rod cell (0.0,0.59,0.41)\0sRGB (0.2126, 0.7152, 0.0722)\0";
> = 2;
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
#line 78 "C:\Program Files\GShade\gshade-shaders\Shaders\MC_Tonemap.fx"
#line 83
float3 MadCakeToneMapPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 luma;
switch(LumaCoefs)
{
case 0:
luma = float3(0.33, 0.33, 0.33);
break;
case 1:
luma = float3(0.0, 0.59, 0.41);
break;
default:
luma = float3(0.2126, 0.7152, 0.0722);
break;
}
#line 99
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 101
if (DeGamma)
{
color.rgb = pow(max(color.rgb, 0.0), 0.45454545);
}
#line 106
color = color * Exposure;
#line 108
const float r = 1.0 / Compression;
const float a_mid = pow(0.5, Contrast - (Contrast - 1.0) * 0.5);
const float r_fix = - (a_mid * r) / (-1.0 + a_mid - r + 2 * a_mid * r);
#line 112
color.rgb = max(color.rgb, 0); 
float4 color2 = float4(color.rgb, dot(color.rgb, luma));
color.r = pow(color.r, Contrast - (Contrast - 1.0) * color.r) * (r_fix + 1.0) / (color.r + r_fix);
color.g = pow(color.g, Contrast - (Contrast - 1.0) * color.g) * (r_fix + 1.0) / (color.g + r_fix);
color.b = pow(color.b, Contrast - (Contrast - 1.0) * color.b) * (r_fix + 1.0) / (color.b + r_fix);
color2.rgb = pow(color2.rgb, Contrast - (Contrast - 1.0) * color2.w) * (r_fix + 1.0) / (color2.w + r_fix);
#line 119
color += (color2.rgb - color) * SaturationLuma;
color += (dot(color, luma) - color) * (1.0 - Saturation);
#line 122
color.rgb = color.rgb - BlackLevel;
if (DeGamma)
{
color.rgb = pow(max(color.rgb, 0.0), 2.2);
}
#line 131
return color;
#line 133
}
#line 135
technique MC_ToneMap
{
pass
{
VertexShader = PostProcessVS;
PixelShader = MadCakeToneMapPass;
}
}

