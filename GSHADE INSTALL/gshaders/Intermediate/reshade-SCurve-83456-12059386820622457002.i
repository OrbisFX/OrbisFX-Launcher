#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\SCurve.fx"
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
#line 33 "C:\Program Files\GShade\gshade-shaders\Shaders\SCurve.fx"
#line 38
uniform float fCurve <
ui_label = "Curve";
ui_type = "slider";
ui_min = 1.0;
ui_max = 3.0;
ui_step = 0.001;
> = 1.0;
#line 46
uniform float4 f4Offsets <
ui_label = "Offsets";
ui_tooltip = "{ Low Color, High Color, Both, Unused }";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
ui_step = 0.001;
> = float4(0.0, 0.0, 0.0, 0.0);
#line 55
float4 PS_SCurve(
const float4 pos : SV_POSITION,
const float2 uv : TEXCOORD
) : SV_TARGET {
float3 col = tex2D(ReShade::BackBuffer, uv).rgb;
const float lum = max(col.r, max(col.g, col.b));
#line 64
const float3 low = pow(abs(col), fCurve) + f4Offsets.x;
const float3 high = pow(abs(col), 1.0 / fCurve) + f4Offsets.y;
#line 67
col.r = lerp(low.r, high.r, col.r + f4Offsets.z);
col.g = lerp(low.g, high.g, col.g + f4Offsets.z);
col.b = lerp(low.b, high.b, col.b + f4Offsets.z);
#line 74
return float4(col, 1.0);
#line 76
}
#line 78
technique SCurve {
pass {
VertexShader = PostProcessVS;
PixelShader = PS_SCurve;
}
}

