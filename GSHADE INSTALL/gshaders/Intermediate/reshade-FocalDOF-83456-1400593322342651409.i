// FOCAL_DOF_USE_SRGB=0
// FOCAL_DOF_USE_TEX2D_IN_VS=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FocalDOF.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\FocalDOF.fx"
#line 47
uniform float DofScale
<
ui_type = "slider";
ui_label = "Scale";
ui_tooltip =
"If this is empty, nag @luluco250 in the ReShade Discord channel.\n"
"\nDefault: 3.0";
ui_category = "Appearance";
ui_min = 1.0;
ui_max = 10.0;
ui_step = 0.001;
> = 3.0;
#line 60
uniform float FocusTime
<
ui_type = "slider";
ui_label = "Time";
ui_tooltip =
"If this is empty, nag @luluco250 in the ReShade Discord channel.\n"
"\nDefault: 350.0";
ui_category = "Focus";
ui_min = 0.0;
ui_max = 2000.0;
ui_step = 10.0;
> = 350.0;
#line 73
uniform float2 FocusPoint
<
ui_type = "slider";
ui_label = "Point";
ui_tooltip =
"If this is empty, nag @luluco250 in the ReShade Discord channel.\n"
"\nDefault: 0.5 0.5";
ui_category = "Focus";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = float2(0.5, 0.5);
#line 86
uniform float FrameTime <source = "frametime";>;
#line 104
texture FocalDOF_Focus { Format = R32F; };
sampler Focus { Texture = FocalDOF_Focus; };
#line 107
texture FocalDOF_LastFocus { Format = R32F; };
sampler LastFocus { Texture = FocalDOF_LastFocus; };
#line 114
void GetFocusVS(
uint id : SV_VERTEXID,
out float4 p : SV_POSITION,
out float2 uv : TEXCOORD0,
out float focus : TEXCOORD1)
{
PostProcessVS(id, p, uv);
#line 125
focus = 0.0;
#line 127
}
#line 129
void ReadFocusVS(
uint id : SV_VERTEXID,
out float4 p : SV_POSITION,
out float2 uv : TEXCOORD0,
out float focus : TEXCOORD1)
{
PostProcessVS(id, p, uv);
#line 140
focus = 0.0;
#line 142
}
#line 144
float4 GetFocusPS(
float4 p : SV_POSITION,
float2 uv : TEXCOORD0,
float focus : TEXCOORD1) : SV_TARGET
{
#line 150
return saturate(lerp(tex2Dfetch(LastFocus, float2(0, 0), 0).x, ReShade::GetLinearizedDepth(FocusPoint), FrameTime / FocusTime));
#line 154
}
#line 156
float4 SaveFocusPS(
float4 p : SV_POSITION,
float2 uv : TEXCOORD0,
float focus : TEXCOORD1) : SV_TARGET
{
#line 162
return tex2Dfetch(Focus, float2(0, 0), 0).x;
#line 166
}
#line 168
float4 MainPS(
float4 p : SV_POSITION,
float2 uv : TEXCOORD0,
float focus : TEXCOORD1) : SV_TARGET
{
#line 176
static const float2 offsets[] =
{
float2(0.0, 1.0),
float2(0.75, 0.75),
float2(1.0, 0.0),
float2(0.75, -0.75),
float2(0.0, -1.0),
float2(-0.75, -0.75),
float2(-1.0, 0.0),
float2(-0.75, 0.75)
};
#line 188
float4 color = exp( tex2D(ReShade::BackBuffer, uv + ReShade::GetPixelSize() * 0.0 * (abs(ReShade::GetLinearizedDepth(uv) - focus) * DofScale)));
#line 190
[unroll]
for (int i = 0; i < 8; ++i)
color += exp( tex2D(ReShade::BackBuffer, uv + ReShade::GetPixelSize() * offsets[i] * (abs(ReShade::GetLinearizedDepth(uv) - focus) * DofScale)));
color /= 9;
#line 197
return log(color);
}
#line 204
technique FocalDOF
{
pass GetFocus
{
VertexShader = GetFocusVS;
PixelShader = GetFocusPS;
RenderTarget = FocalDOF_Focus;
}
pass SaveFocus
{
VertexShader = ReadFocusVS;
PixelShader = SaveFocusPS;
RenderTarget = FocalDOF_LastFocus;
}
pass Main
{
VertexShader = ReadFocusVS;
PixelShader = MainPS;
#line 226
}
}

