#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\WatchDogs.fx"
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
#line 16 "C:\Program Files\GShade\gshade-shaders\Shaders\WatchDogs.fx"
#line 21
uniform float LinearWhite <
ui_label = "Tonemap - Curve";
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
ui_step = 0.01;
> = 1.25;
uniform float LinearColor <
ui_label = "Tonemap - Whiteness";
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
ui_step = 0.01;
> = 1.25;
#line 34
float3 ColorFilmicToneMappingPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float4 x = tex2D(ReShade::BackBuffer, texcoord);
#line 38
const float3 A = float3(0.55f, 0.50f, 0.45f);	
const float3 B = float3(0.30f, 0.27f, 0.22f);	
const float3 C = float3(0.10f, 0.10f, 0.10f);	
const float3 D = float3(0.10f, 0.07f, 0.03f);	
const float3 E = float3(0.01f, 0.01f, 0.01f);	
const float3 F = float3(0.30f, 0.30f, 0.30f);	
const float3 W = float3(2.80f, 2.90f, 3.10f);	
const float3 F_linearWhite = ((W*(A*W+C*B)+D*E)/(W*(A*W+B)+D*F))-(E/F);
const float3 F_linearColor = ((x.xyz*(A*x.xyz+C*B)+D*E)/(x.xyz*(A*x.xyz+B)+D*F))-(E/F);
#line 54
return pow(saturate(F_linearColor * LinearColor / F_linearWhite),LinearWhite);
#line 56
}
#line 59
technique WatchDogsTonemapping
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ColorFilmicToneMappingPass;
}
}

