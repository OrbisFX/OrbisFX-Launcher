#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\GrainSpread.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\GrainSpread.fx"
#line 33
uniform float Opacity
<
ui_type = "slider";
ui_label = "Opacity";
ui_tooltip = "Default: 0.5";
ui_min = 0.0;
ui_max = 1.0;
> = 0.5;
#line 42
uniform float Spread
<
ui_type = "slider";
ui_label = "Spread";
ui_tooltip = "Default: 0.5";
ui_min = 0.0;
ui_max = 500.0;
> = 1.0;
#line 51
uniform float Speed
<
ui_type = "slider";
ui_label = "Speed";
ui_tooltip = "Default: 1.0";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
#line 60
uniform float GlobalGrain
<
ui_type = "slider";
ui_label = "Global Grain";
ui_tooltip = "Default: 0.5";
ui_min = 0.0;
ui_max = 1.0;
> = 0.5;
#line 69
uniform int BlendMode
<
ui_type = "combo";
ui_label = "Blend Mode";
ui_items = "Mix\0Addition\0Screen\0Lighten-Only\0";
> = 0;
#line 76
uniform float Timer <source = "timer";>;
#line 78
float rand(float2 uv, float t) {
return frac(sin(dot(uv, float2(1225.6548, 321.8942))) * 4251.4865 + t);
}
#line 82
float4 MainPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
const float t = Timer * 0.001 * Speed;
const float2 scale = Spread;
float2 offset = float2(rand(uv, t), rand(uv.yx, t));
offset = min(max(offset * scale - scale * 0.5, 7), -8);
#line 89
float3 grain = tex2D(ReShade::BackBuffer, uv, int2(offset)).rgb;
grain *= log10(Spread * 0.5 - distance(uv, uv + offset * ReShade::GetPixelSize()));
grain *= lerp(1.0, rand(uv + uv.yx, t), GlobalGrain);
#line 94
float3 color = tex2D(ReShade::BackBuffer, uv).rgb;
#line 96
switch (BlendMode)
{
case 0: 
color = lerp(color, max(color, grain), Opacity);
break;
case 1: 
color += grain * Opacity;
break;
case 2: 
color = 1.0 - (1.0 - color) * (1.0 - grain * Opacity);
break;
case 3: 
color = max(color, grain * Opacity);
break;
}
#line 112
return float4(color, 1.0);
}
#line 115
technique GrainSpread
{
pass MainPS
{
VertexShader = PostProcessVS;
PixelShader = MainPS;
}
}

