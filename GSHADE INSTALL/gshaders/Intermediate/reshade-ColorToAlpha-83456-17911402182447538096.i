#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorToAlpha.fx"
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
#line 27 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorToAlpha.fx"
#line 28
uniform float3 fColor <
ui_label = "Color To Replace";
ui_type = "color";
> = float3(1.0, 1.0, 1.0);
#line 33
uniform float fBlending <
ui_label = "Opacity";
ui_tooltip = "If this setting is above 0.0 (fully transparent), you will only be able to see its impact in screenshots.\n\nA value of 0.5 is 50\% transparent.";
ui_type = "slider";
> = 0.0;
#line 39
float4 ColorToAlphaPS(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float4 back = tex2D(ReShade::BackBuffer, texcoord);
#line 43
if (back.r == fColor.r && back.g == fColor.g && back.b == fColor.b)
{
if (fBlending == 0.0)
{
return float4(0.0, 0.0, 0.0, 0.0);
}
#line 50
return float4(back.rgb, fBlending);
}
else
return back;
}
#line 56
technique ColorToAlpha
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ColorToAlphaPS;
}
}

