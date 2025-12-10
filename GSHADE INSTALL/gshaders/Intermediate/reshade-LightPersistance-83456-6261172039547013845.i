#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\LightPersistance.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 57
namespace ReShade
{
float GetAspectRatio() { return 1280 * (1.0 / 720); }
float2 GetPixelSize() { return float2((1.0 / 1280), (1.0 / 720)); }
float2 GetScreenSize() { return float2(1280, 720); }
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
#line 8 "C:\Program Files\GShade\gshade-shaders\Shaders\LightPersistance.fx"
#line 9
uniform float persistance <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Persistance";
> = 0.1;
#line 15
texture LPt { Width = 1280; Height = 720; Format = RGBA16F; };
sampler LPs { Texture = LPt; };
#line 18
float3 lightPersistance(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
return max(tex2D(LPs, texcoord).rgb, tex2D(ReShade::BackBuffer, texcoord).rgb);
}
#line 23
float3 previousFrame(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
if(persistance == 0.0)
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
else
{
return (tex2D(ReShade::BackBuffer, texcoord).rgb / (1 + persistance)) - 0.002;
}
}
#line 35
technique LightPersistance
{
pass pass0
{
VertexShader = PostProcessVS;
PixelShader = lightPersistance;
}
#line 43
pass pass1
{
VertexShader = PostProcessVS;
PixelShader = previousFrame;
RenderTarget = LPt;
}
}

