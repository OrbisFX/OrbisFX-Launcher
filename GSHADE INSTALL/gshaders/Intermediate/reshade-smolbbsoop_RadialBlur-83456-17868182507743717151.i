#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\smolbbsoop_RadialBlur.fx"
#line 31
uniform float2 BlurCenter <
ui_type = "slider";
ui_label = "Center of Image";
ui_category = "Blur Adjustments";
ui_min = 0.0;
ui_max = 1.0;
> = float2(0.5, 0.5);
#line 39
uniform float BlurStrength <
ui_type = "slider";
ui_label = "Intensity";
ui_category = "Blur Adjustments";
ui_min = 0.0;
ui_max = 1.0;
> = 0.75;
#line 47
uniform float Falloff <
ui_type = "slider";
ui_label = "Falloff Distance";
ui_category = "Blur Adjustments";
ui_min = 0.0;
ui_max = 1.0;
> = 0.6;
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
#line 60 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\smolbbsoop_RadialBlur.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\smolbbsoop_Global.fxh"
#line 44
float3 sRGBToLinear(float3 x)
{
if (x.r < 0.04045)
return x / 12.92;
else
return pow(max((x + 0.055) / 1.055, 0.0), 2.4);
}
#line 53
float3 LinearTosRGB(float3 x)
{
if (x.r < 0.0031308)
return 12.92 * x;
else
return 1.055 * pow(max(x, 0.0), 1.0 / 2.4) - 0.055;
}
#line 61 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\smolbbsoop_RadialBlur.fx"
#line 62
sampler BackBuffer { Texture = ReShade::BackBufferTex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = CLAMP; AddressV = CLAMP; AddressW = CLAMP; };
#line 70
float2 Rotate(float2 uv, float2 pivot, float angle)
{
const float s = sin(angle);
const float c = cos(angle);
#line 75
uv -= pivot;
const float2 rotatedUV = float2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
return rotatedUV + pivot;
}
#line 84
float4 RadialBlur(float2 texCoords, float2 center, float strength, int quality, float falloff, float taperStrength)
{
float4 Colour = float4(0.0, 0.0, 0.0, 1.0);
#line 89
const float aspectRatio = float2(1920, 1018).x / float2(1920, 1018).y;
const float2 adjustedCoords = float2(texCoords.x, texCoords.y / aspectRatio);
const float2 adjustedCenter = float2(center.x, center.y / aspectRatio);
#line 93
const float distance = length(adjustedCoords - adjustedCenter);
const float falloffFactor = pow(max(distance, 0.0), falloff);
#line 96
const float taperBase = 1.0 - taperStrength;
const float taperCompensation = lerp(2.0, 1.0, taperStrength);
#line 99
for (int i = 0; i < quality; i++)
{
float angle = (0.1 + float(i) * 0.5) * strength * falloffFactor;
float taperWeight = taperBase + taperStrength * (1.0 - abs(float(i) / quality));
#line 108
float2 rotatedCoords = Rotate(adjustedCoords, adjustedCenter, angle);
rotatedCoords.y *= aspectRatio;
#line 111
float3 sampleColour;
#line 114
sampleColour = sRGBToLinear(tex2D(ReShade::BackBuffer, rotatedCoords).rgb);
#line 121
Colour.rgb += sampleColour * taperWeight;
#line 127
rotatedCoords = Rotate(adjustedCoords, adjustedCenter, -angle);
rotatedCoords.y *= aspectRatio;
#line 131
sampleColour = sRGBToLinear(tex2D(ReShade::BackBuffer, rotatedCoords).rgb);
#line 138
Colour.rgb += sampleColour * taperWeight;
}
#line 142
Colour.rgb /= (quality * taperCompensation);
#line 145
Colour.rgb = LinearTosRGB(Colour.rgb);
#line 152
return Colour;
}
#line 159
float4 ApplyBlur(float4 pos : SV_Position, float2 texCoords : TexCoord) : SV_Target
{
#line 163
const float TaperStrength = 1.0;
#line 166
const float adjustedBlurStrength = clamp(lerp(0.0, 0.02, BlurStrength), 0.0, 0.02);
const float adjustedFalloff = clamp(lerp(1.0, 5.0, Falloff), 1.0, 5.0);
#line 171
float dynamicQuality = lerp(5, 100, (adjustedBlurStrength * 50)) * (1.0 / max(adjustedFalloff, 0.001));
dynamicQuality = clamp(dynamicQuality, 5.0, 300);
#line 174
return RadialBlur(texCoords, BlurCenter, adjustedBlurStrength, dynamicQuality, adjustedFalloff, TaperStrength);
}
#line 181
technique RadialBlur < ui_label = "Symmetrical Radial Blur"; ui_tooltip = "An unoptimised and lazily made radial blur shader that warps the edges of the frame in a radial pattern"; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader  = ApplyBlur;
}
}

