#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorInversion.fx"
#line 26
uniform int nInversionSelector <
ui_type = "combo";
ui_items = "All\0Red\0Green\0Blue\0Red & Green\0Red & Blue\0Green & Blue\0None\0";
ui_label = "The color(s) to invert.";
> = 0;
#line 32
uniform float nInversionRed <
ui_type = "slider";
ui_label = "Red";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 40
uniform float nInversionGreen <
ui_type = "slider";
ui_label = "Green";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 48
uniform float nInversionBlue <
ui_type = "slider";
ui_label = "Blue";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
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
#line 57 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorInversion.fx"
#line 62
float3 SV_ColorInversion(float4 pos : SV_Position, float2 col : TEXCOORD) : SV_TARGET
{
float3 inversion = tex2D(ReShade::BackBuffer, col).rgb;
#line 66
inversion.r = inversion.r * nInversionRed;
inversion.g = inversion.g * nInversionGreen;
inversion.b = inversion.b * nInversionBlue;
#line 70
if (nInversionSelector == 0)
{
inversion.r = 1.0f - inversion.r;
inversion.g = 1.0f - inversion.g;
inversion.b = 1.0f - inversion.b;
}
else if (nInversionSelector == 1)
{
inversion.r = 1.0f - inversion.r;
}
else if (nInversionSelector == 2)
{
inversion.g = 1.0f - inversion.g;
}
else if (nInversionSelector == 3)
{
inversion.b = 1.0f - inversion.b;
}
else if (nInversionSelector == 4)
{
inversion.r = 1.0f - inversion.r;
inversion.g = 1.0f - inversion.g;
}
else if (nInversionSelector == 5)
{
inversion.r = 1.0f - inversion.r;
inversion.b = 1.0f - inversion.b;
}
else if (nInversionSelector == 6)
{
inversion.g = 1.0f - inversion.g;
inversion.b = 1.0f - inversion.b;
}
#line 107
return inversion;
#line 109
}
#line 111
technique ColorInversion
{
pass
{
VertexShader = PostProcessVS;
PixelShader = SV_ColorInversion;
}
}

