#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\HotsamplingHelper.fx"
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
#line 44 "C:\Program Files\GShade\gshade-shaders\Shaders\HotsamplingHelper.fx"
#line 45
uniform float2 fUIOverlayPos <
ui_type = "slider";
ui_label = "Overlay Position";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = float2(0.5, 0.5);
#line 52
uniform float fUIOverlayScale <
ui_type = "slider";
ui_label = "Overlay Scale";
ui_min = 0.1; ui_max = 1.0;
ui_step = 0.001;
> = 0.2;
#line 59
float3 HotsamplingHelperPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
#line 61
const float2 overlayPos = fUIOverlayPos * (1.0 - fUIOverlayScale) * float2(1920, 1018);
#line 63
if(all(vpos.xy >= overlayPos) && all(vpos.xy < overlayPos + float2(1920, 1018) * fUIOverlayScale))
{
texcoord = frac((texcoord - overlayPos / float2(1920, 1018)) / fUIOverlayScale);
}
#line 68
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
#line 71
technique HotsamplingHelper {
pass {
VertexShader = PostProcessVS;
PixelShader = HotsamplingHelperPS;
#line 76
}
}

