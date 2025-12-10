#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FluoroDuoTone.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Reshade.fxh"
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
#line 41 "C:\Program Files\GShade\gshade-shaders\Shaders\FluoroDuoTone.fx"
#line 42
namespace FluoroDuoTone
{
uniform float3 Layer1ShadowColor <
ui_category = "Layer 1";
ui_label= "Shadow color";
ui_type = "color";
ui_min = 0.0; ui_max = 1.0;
> = float3(0.0, 0.0, 0.4);
#line 51
uniform float3 Layer1HighlightColor <
ui_category = "Layer 1";
ui_label= "Highlight color";
ui_type = "color";
ui_min = 0.0; ui_max = 1.0;
> = float3(1.0, 1.0, 0.4);
#line 58
uniform float Layer1Opacity <
ui_category = "Layer 1";
ui_label= "Opacity";
ui_type = "drag";
ui_min = 0.0; ui_max = 1.0;
> = 1.0;
#line 65
uniform float3 Layer2ShadowColor <
ui_category = "Layer 2";
ui_label= "Shadow color";
ui_type = "color";
ui_min = 0.0; ui_max = 1.0;
> = float3(0.4, 0.0, 0.0);
#line 72
uniform float3 Layer2HighlightColor <
ui_category = "Layer 2";
ui_label= "Highlight color";
ui_type = "color";
ui_min = 0.0; ui_max = 1.0;
> = float3(0.0, 0.5, 1.0);
#line 79
uniform float Layer2Opacity <
ui_category = "Layer 2";
ui_label= "Opacity";
ui_type = "drag";
ui_min = 0.0; ui_max = 1.0;
> = 0.2;
#line 86
uniform float PatternOpacity <
ui_category = "Pattern";
ui_label= "Opacity";
ui_type = "drag";
ui_min = 0.0; ui_max = 1.0;
> = 0.2;
#line 93
uniform float PatternDotSize <
ui_category = "Pattern";
ui_label= "Dot size (in pixels)";
ui_type = "drag";
ui_min = 1.0; ui_max = 100.0;
ui_step = 0.1;
> = 2.0;
#line 101
void PS_DoDuoTone(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 fragment : SV_Target)
{
fragment = 0.0;
const float3 currentFragment = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float luma = dot(currentFragment, float3(0.3, 0.59, 0.11));
#line 107
const float3 layer1Color = lerp(Layer1ShadowColor, Layer1HighlightColor, luma);
const float3 layer2Color = lerp(Layer2ShadowColor, Layer2HighlightColor, luma);
fragment.rgb = lerp(currentFragment, layer1Color, Layer1Opacity);
fragment.rgb = lerp(fragment.rgb, layer2Color, Layer2Opacity);
#line 113
const float2 pixelCoords = ((texcoord / ReShade::GetPixelSize()) / (PatternDotSize * ReShade::GetAspectRatio())) % 2;
if(pixelCoords.x <= 1.0 || pixelCoords.y <= 1.0)
{
const float3 ditheredFragment = lerp(fragment.rgb, float3(0,0,0), 1-luma);
fragment.rgb = lerp(fragment.rgb, ditheredFragment, PatternOpacity);
}
}
#line 121
technique FluoroDuoTone
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_DoDuoTone;
}
}
}

