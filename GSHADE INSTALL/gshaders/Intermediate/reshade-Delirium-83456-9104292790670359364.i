#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Delirium.fx"
#line 13
uniform uint DeliriumIntensity <
ui_type = "drag";
ui_min = 1; ui_max = 100;
ui_step = 1;
ui_tooltip = "Delirium Intensity.";
> = 1;
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
#line 22 "C:\Program Files\GShade\gshade-shaders\Shaders\Delirium.fx"
#line 26
uniform float timer < source = "timer"; > ;
#line 28
namespace Delirium {
#line 40
void delirium(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target)
{
#line 44
float offset = sin(timer/500+texcoord.x*3.1415927*4); 
offset = offset*((-(texcoord.y-0.5))*(texcoord.y-0.5)+0.25)/6; 
float offset2 = sin((timer+500)/750+texcoord.x*3.1415927*4); 
offset2 = offset2*((-(texcoord.y-0.5))*(texcoord.y-0.5)+0.25)/4; 
float2 new_point = float2(texcoord.x, saturate(texcoord.y+offset));
float2 new_point_fade = float2(texcoord.x, saturate(texcoord.y+offset2));
fragment = tex2D(ReShade::BackBuffer, new_point);
float4 fragment_2 = tex2D(ReShade::BackBuffer, new_point_fade);
if(fragment_2.r+fragment_2.g+fragment_2.b < fragment.r+fragment.g+fragment.b)
{
fragment = 0.85*fragment+0.15*fragment_2;
}
#line 58
float eye_offset = 1-saturate(sin(timer/555) +sin(0.25*timer/555)-0.65);
fragment *= eye_offset;
}
technique Delirium
{
pass Delirium { VertexShader = PostProcessVS; PixelShader = delirium; }
}
}

