#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Vignette.fx"
#line 34
uniform int Type <
ui_type = "combo";
ui_items = "Original\0New\0TV style\0Untitled 1\0Untitled 2\0Untitled 3\0Untitled 4\0";
> = 0;
uniform float Ratio <
ui_type = "slider";
ui_min = 0.15; ui_max = 6.0;
ui_tooltip = "Sets a width to height ratio. 1.00 (1/1) is perfectly round, while 1.60 (16/10) is 60 % wider than it's high.";
> = 1.0;
uniform float Radius <
ui_type = "slider";
ui_min = -1.0; ui_max = 3.0;
ui_tooltip = "lower values = stronger radial effect from center";
> = 2.0;
uniform float Amount <
ui_type = "slider";
ui_min = -2.0; ui_max = 1.0;
ui_tooltip = "Strength of black. -2.00 = Max Black, 1.00 = Max White.";
> = -1.0;
uniform int Slope <
ui_type = "slider";
ui_min = 2; ui_max = 16;
ui_tooltip = "How far away from the center the change should start to really grow strong (odd numbers cause a larger fps drop than even numbers).";
> = 2;
uniform float2 Center <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Center of effect for 'Original' vignette type. 'New' and 'TV style' do not obey this setting.";
> = float2(0.5, 0.5);
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
#line 65 "C:\Program Files\GShade\gshade-shaders\Shaders\Vignette.fx"
#line 69
float4 VignettePass(float4 vpos : SV_Position, float2 tex : TexCoord) : SV_Target
{
float4 color = tex2D(ReShade::BackBuffer, tex);
#line 73
if (Type == 0)
{
#line 76
float2 distance_xy = tex - Center;
#line 79
distance_xy *= float2(((1.0 / 1018) / (1.0 / 1920)), Ratio);
#line 82
distance_xy /= Radius;
const float distance = dot(distance_xy, distance_xy);
#line 86
color.rgb *= (1.0 + pow(distance, Slope * 0.5) * Amount); 
}
#line 89
if (Type == 1) 
{
tex = -tex * tex + tex;
color.rgb = saturate((((1.0 / 1018) / (1.0 / 1920))*((1.0 / 1018) / (1.0 / 1920)) * Ratio * tex.x + tex.y) * 4.0) * color.rgb;
}
#line 95
if (Type == 2) 
{
tex = -tex * tex + tex;
color.rgb = saturate(tex.x * tex.y * 100.0) * color.rgb;
}
#line 101
if (Type == 3)
{
tex = abs(tex - 0.5);
float tc = dot(float4(-tex.x, -tex.x, tex.x, tex.y), float4(tex.y, tex.y, 1.0, 1.0)); 
#line 106
tc = saturate(tc - 0.495);
color.rgb *= (pow((1.0 - tc * 200), 4) + 0.25); 
}
#line 110
if (Type == 4)
{
tex = abs(tex - 0.5);
float tc = dot(float4(-tex.x, -tex.x, tex.x, tex.y), float4(tex.y, tex.y, 1.0, 1.0)); 
#line 115
tc = saturate(tc - 0.495) - 0.0002;
color.rgb *= (pow((1.0 - tc * 200), 4) + 0.0); 
}
#line 119
if (Type == 5) 
{
tex = abs(tex - 0.5);
float tc = tex.x * (-2.0 * tex.y + 1.0) + tex.y; 
#line 124
tc = saturate(tc - 0.495);
color.rgb *= (pow((-tc * 200 + 1.0), 4) + 0.25); 
#line 127
}
#line 129
if (Type == 6) 
{
#line 132
const float tex_xy = dot(float4(tex, tex), float4(-tex, 1.0, 1.0)); 
color.rgb = saturate(tex_xy * 4.0) * color.rgb;
}
#line 138
return color;
#line 140
}
#line 142
technique Vignette
{
pass
{
VertexShader = PostProcessVS;
PixelShader = VignettePass;
}
}

