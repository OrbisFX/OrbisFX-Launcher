#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Splitscreen.fx"
#line 58
uniform int splitscreen_mode <
ui_type = "combo";
ui_label = "Mode";
ui_tooltip = "Choose a mode";
#line 63
ui_items =
"Vertical 50/50 split\0"
"Vertical 25/50/25 split\0"
"Angled 50/50 split\0"
"Angled 25/50/25 split\0"
"Horizontal 50/50 split\0"
"Horizontal 25/50/25 split\0"
"Diagonal split\0"
;
> = 0;
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
#line 79 "C:\Program Files\GShade\gshade-shaders\Shaders\Splitscreen.fx"
#line 85
texture Before { Width = 1920; Height = 1018; };
sampler Before_sampler { Texture = Before; };
#line 93
float4 PS_Before(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return tex2D(ReShade::BackBuffer, texcoord);
}
#line 98
float4 PS_After(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color;
#line 103
[branch] if (splitscreen_mode == 0)
color = (texcoord.x < 0.5 ) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
#line 107
[branch] if (splitscreen_mode == 1)
{
#line 110
float dist = abs(texcoord.x - 0.5);
#line 113
dist = saturate(dist - 0.25);
#line 115
color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
}
#line 119
[branch] if (splitscreen_mode == 2)
{
#line 122
float dist = ((texcoord.x - 3.0/8.0) + (texcoord.y * 0.25));
#line 125
dist = saturate(dist - 0.25);
#line 127
color = dist ? tex2D(ReShade::BackBuffer, texcoord) : tex2D(Before_sampler, texcoord);
}
#line 131
[branch] if (splitscreen_mode == 3)
{
#line 134
float dist = ((texcoord.x - 3.0/8.0) + (texcoord.y * 0.25));
#line 136
dist = abs(dist - 0.25);
#line 139
dist = saturate(dist - 0.25);
#line 141
color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
}
#line 145
[branch] if (splitscreen_mode == 4)
color =  (texcoord.y < 0.5) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
#line 149
[branch] if (splitscreen_mode == 5)
{
#line 152
float dist = abs(texcoord.y - 0.5);
#line 155
dist = saturate(dist - 0.25);
#line 157
color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
}
#line 161
[branch] if (splitscreen_mode == 6)
{
#line 164
float dist = (texcoord.x + texcoord.y);
#line 169
color = (dist < 1.0) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
}
#line 172
return color;
}
#line 180
technique Before
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Before;
RenderTarget = Before;
}
}
#line 190
technique After
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_After;
}
}

