#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Clipboard.fx"
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
#line 10 "C:\Program Files\GShade\gshade-shaders\Shaders\Clipboard.fx"
#line 15
texture Clipboard_Texture
{
Width = 1920;
Height = 1018;
Format = RGBA8;
};
#line 26
sampler Sampler
{
Texture = Clipboard_Texture;
};
#line 35
uniform float BlendIntensity <
ui_label = "Alpha blending level";
ui_type = "drag";
ui_min = 0.001; ui_max = 1000.0;
ui_step = 0.001;
> = 1.0;
#line 46
void PS_Copy(float4 pos : SV_Position, float2 texCoord : TEXCOORD, out float4 frontColor : SV_Target)
{
frontColor = tex2D(ReShade::BackBuffer, texCoord);
}
#line 51
void PS_Paste(float4 pos : SV_Position, float2 texCoord : TEXCOORD, out float4 frontColor : SV_Target)
{
const float4 backColor = tex2D(ReShade::BackBuffer, texCoord);
#line 55
frontColor = tex2D(Sampler, texCoord);
frontColor = lerp(backColor, frontColor, min(1.0, frontColor.a * BlendIntensity));
}
#line 63
technique Copy
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Copy;
RenderTarget = Clipboard_Texture;
}
}
#line 73
technique Paste
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Paste;
}
}

