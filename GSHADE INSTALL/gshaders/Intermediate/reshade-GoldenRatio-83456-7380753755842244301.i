#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\GoldenRatio.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\GoldenRatio.fx"
#line 35
namespace GoldenRatio
{
#line 42
uniform float Opacity <
ui_category = "General";
ui_label= "Opacity";
ui_type = "drag";
ui_min = 0.000; ui_max = 1.0;
ui_step = 0.001;
ui_tooltip = "Opacity of overlay. 0 is invisible, 1 is opaque lines.";
> = 0.3;
#line 51
uniform bool ResizeMode <
ui_category = "General";
ui_label = "Resize mode";
ui_tooltip = "Resize mode: 0 is clamp to screen (so resizing of overlay, no golden ratio by definition),\n1: resize to either full with or full height while keeping aspect ratio: golden ratio by definition in lined area.";
> = true;
#line 62
texture		texSpirals <source= "GoldenSpirals.png"; > { Width = 1748; Height = 1080; MipLevels = 1; Format = RGBA8; };
#line 64
sampler	samplerSpirals
{
Texture = texSpirals;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;
AddressU = Clamp;
AddressV = Clamp;
};
#line 74
void PS_RenderSpirals(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 outFragment : SV_Target0)
{
float4 colFragment = tex2D(ReShade::BackBuffer, texcoord);
float phiValue = ((1.0 + sqrt(5.0))/2.0);
float idealWidth = 1018 * phiValue;
float idealHeight = 1920 / phiValue;
float4 sourceCoordFactor = float4(1.0, 1.0, 1.0, 1.0);
#line 82
if(ResizeMode)
{
if(ReShade::GetAspectRatio() < phiValue)
{
#line 87
sourceCoordFactor = float4(1.0, 1018/idealHeight, 1.0, idealHeight/1018);
}
else
{
#line 92
sourceCoordFactor = float4(1920/idealWidth, 1.0, idealWidth/1920, 1.0);
}
}
#line 96
float4 spiralFragment = tex2D(samplerSpirals, float2((texcoord.x * sourceCoordFactor.x) - ((1.0-sourceCoordFactor.z)/2.0),
(texcoord.y * sourceCoordFactor.y) - ((1.0-sourceCoordFactor.w)/2.0)));
outFragment = saturate(colFragment + (spiralFragment * Opacity));
}
#line 101
technique GoldenRatio
{
pass Render
{
VertexShader = PostProcessVS;
PixelShader = PS_RenderSpirals;
}
}
}

