#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Interlacing.fx"
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
#line 8 "C:\Program Files\GShade\gshade-shaders\Shaders\Interlacing.fx"
#line 9
uniform int lineHeight <
ui_type = "slider";
ui_min = 1; ui_max = 100;
ui_label = "Line height";
ui_tooltip = "Most of the time you'll want this at 1";
> = 1;
#line 16
uniform bool lineCheck <
ui_label = "Line check";
> = false;
#line 20
uniform float framecount < source = "framecount"; >;
#line 22
texture currentTex { Width = 1920; Height = 1018; };
sampler currentSamp { Texture = currentTex; };
#line 25
texture previousTex { Width = 1920; Height = 1018; };
sampler previousSamp { Texture = previousTex; };
#line 28
float3 currentFrame(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
#line 33
float3 interlacing(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
if(lineCheck == true)
{
if(pos.y % (lineHeight * 2) <= lineHeight)
{
return 0;
}
else
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
}
else
{
if(framecount / 2.0 <= 0.0)
{
if(pos.y % (lineHeight * 2) <= lineHeight)
{
return tex2D(previousSamp, texcoord).rgb;
}
else
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
}
else
{
if((pos.y + lineHeight) % (lineHeight * 2) <= lineHeight)
{
return tex2D(previousSamp, texcoord).rgb;
}
else
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
}
}
}
#line 73
float3 previousFrame(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
return tex2D(currentSamp, texcoord).rgb;
}
#line 78
technique Interlacing
{
pass pass0
{
VertexShader = PostProcessVS;
PixelShader = currentFrame;
RenderTarget = currentTex;
}
#line 87
pass pass1
{
VertexShader = PostProcessVS;
PixelShader = interlacing;
}
#line 93
pass pass2
{
VertexShader = PostProcessVS;
PixelShader = previousFrame;
RenderTarget = previousTex;
}
}

