#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\PSXDither.fx"
#line 4
uniform bool useDither <
ui_label = "Use Dithering";
ui_tooltip = "Leave unchecked to disable dithering and only truncate raw color input.";
> = false;
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
#line 10 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\PSXDither.fx"
#line 12
static const float4x4 psx_dither_table = float4x4
(
0.0,     8.0,     2.0,    10.0,
12.0,     4.0,    14.0,     6.0,
3.0,    11.0,     1.0,     9.0,
15.0,     7.0,    13.0,     5.0
);
#line 22
float3 DitherCrunch(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float3 col = tex2D(ReShade::BackBuffer, texcoord).rgb * 255.0; 
if(useDither)
{
const float dither = psx_dither_table[uint(texcoord.x) % 4][uint(texcoord.y) % 4];
col += (dither / 2.0 - 4.0); 
}
col = lerp((uint3(col) & 0xf8), 0xf8, step(0xf8, col));
#line 33
return col / 255.0; 
}
#line 43
technique PSXDither
{
pass ps1
{
VertexShader = PostProcessVS;
PixelShader = DitherCrunch;
}
}

