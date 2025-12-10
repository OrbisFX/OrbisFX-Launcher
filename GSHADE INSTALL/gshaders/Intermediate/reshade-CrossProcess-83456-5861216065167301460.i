#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\CrossProcess.fx"
#line 6
uniform float CrossContrast <
ui_type = "slider";
ui_min = 0.50; ui_max = 2.0;
ui_tooltip = "Contrast";
> = 1.0;
uniform float CrossSaturation <
ui_type = "slider";
ui_min = 0.50; ui_max = 2.00;
ui_tooltip = "Saturation";
> = 1.0;
uniform float CrossBrightness <
ui_type = "slider";
ui_min = -1.000; ui_max = 1.000;
ui_tooltip = "Brightness";
> = 0.0;
uniform float CrossAmount <
ui_type = "slider";
ui_min = 0.05; ui_max = 1.50;
ui_tooltip = "Cross Amount";
> = 0.50;
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
#line 29 "C:\Program Files\GShade\gshade-shaders\Shaders\CrossProcess.fx"
#line 34
float3 CrossPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float2 CrossMatrix [3] = {
float2 (1.03, 0.04),
float2 (1.09, 0.01),
float2 (0.78, 0.13),
};
#line 43
float3 image1 = color.rgb;
float3 image2 = color.rgb;
const float gray = dot(float3(0.5,0.5,0.5), image1);
image1 = lerp (gray, image1,CrossSaturation);
image1 = lerp (0.35, image1,CrossContrast);
image1 +=CrossBrightness;
image2.r = image1.r * CrossMatrix[0].x + CrossMatrix[0].y;
image2.g = image1.g * CrossMatrix[1].x + CrossMatrix[1].y;
image2.b = image1.b * CrossMatrix[2].x + CrossMatrix[2].y;
#line 57
return lerp(image1, image2, CrossAmount);
#line 59
}
#line 62
technique Cross
{
pass
{
VertexShader = PostProcessVS;
PixelShader = CrossPass;
}
}

