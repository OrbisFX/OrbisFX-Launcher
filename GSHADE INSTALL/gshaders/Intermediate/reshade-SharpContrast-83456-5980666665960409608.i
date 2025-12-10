// SHARP_CONTRAST_COMPUTE=0
// SHARP_CONTRAST_SIZE=7
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\SharpContrast.fx"
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
#line 24 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\SharpContrast.fx"
#line 75
static const float PI = 3.1415926536;
static const float GAUSSIAN_WEIGHTS[5] = {0.095766,	0.303053,	0.20236,	0.303053,	0.095766};
static const float GAUSSIAN_OFFSETS[5] = {-3.2979345488, -1.40919905099, 0, 1.40919905099, 3.2979345488};
#line 80
namespace SharpContrast
{
texture BackBuffer : COLOR;
texture Luma<pooled = true;>{Width = 1920; Height = 1018; Format = R8;};
texture Temp<pooled = true;>{Width = 1920; Height = 1018; Format = R8;};
#line 87
sampler sBackBuffer{Texture = BackBuffer;};
sampler sLuma {Texture = Luma;};
sampler sTemp {Texture = Temp;};
#line 91
storage wLuma {Texture = Luma;};
storage wTemp {Texture = Temp;};
#line 94
uniform float SharpenStrength<
ui_type = "slider";
ui_label = "Strength";
ui_tooltip = "Strength of the sharpen.";
ui_min = 0; ui_max = 2;
ui_step = 0.001;
> = 0.667;
#line 102
uniform float EdgeBias<
ui_type = "slider";
ui_label = "Edge Contrast";
ui_tooltip = "Changes how much contrast and coarseness there is near edges.";
ui_min = 0; ui_max = 1;
ui_step = 0.001;
> = 1;
#line 110
uniform float EdgeFloor<
ui_type = "slider";
ui_label = "Edge Floor";
ui_tooltip = "Amount of sharpening allowed on edges.";
ui_min = 0; ui_max = 1;
ui_step = 0.001;
> = 0;
#line 118
uniform bool GammaCorrect<
ui_label = "Use Linear Color Gamut";
ui_tooltip = "Changes whether the sharpen is applied on a linear\n"
"or standard color gamut.";
> = true;
#line 124
uniform bool EnableDepth<
ui_category = "Depth Settings";
ui_label = "Enable Depth Settings";
ui_tooltip = "This setting must be enabled to be able to adjust the Depth Curve \n"
"or enable the Mask Sky option.";
> = false;
#line 131
uniform float DepthCurve<
ui_type = "slider";
ui_label = "Depth Curve";
ui_category = "Depth Settings";
ui_tooltip = "Adjusts how the sharpen fades with depth, lower values mean a shorter fadeout distance.";
ui_min = 0; ui_max = 1;
ui_step = 0.001;
> = 1;
#line 140
uniform bool MaskSky<
ui_category = "Depth Settings";
ui_label = "Mask Sky";
ui_tooltip = "This setting prevents the sky from having the sharpen applied.";
> = true;
#line 147
uniform int Debug<
ui_type = "combo";
ui_items = "None\0Masking\0Sharpen\0";
ui_label = "Debug View";
ui_category = "Debug";
ui_tooltip = "Masking: Shows the regions where the sharpen is having its application limited.\n"
"Sharpen: Shows the sharpen that's being applied to the image.";
> = 0;
void LumaPS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD, out float output : SV_TARGET0)
{
output = dot(tex2Dfetch(sBackBuffer, texcoord * float2(1920, 1018)).rgb, float3(0.299, 0.587, 0.114));
}
#line 347
void OutputPS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD, out float4 output : SV_TARGET0)
{
float2 coord = texcoord * float2(1920, 1018);
float sharpnessMultiplier = max(1023 * pow(( 2 * EdgeBias / 3) + 0.333333, 4), 1e-10);
float sum[7];
float squaredSum[7];
float sampleCount[7];
float maximum = 0;
float minimum = sharpnessMultiplier;
float center;
[unroll]
for(int i = -(7/2); i <= (7/2); i++)
{
[unroll]
for(int j = -(7/2); j <= (7/2); j++)
{
[flatten]
if(all(int2(i, j) == 0))
{
#line 367
float luma = tex2Dfetch(sLuma, coord).r;
if(GammaCorrect)
{
luma *= luma;
}
center = luma;
luma *= sharpnessMultiplier;
maximum = max(maximum, luma);
minimum = min(minimum, luma);
[unroll]
for(int i = 0; i < 7; i++)
{
sum[i] += luma;
squaredSum[i] += luma * luma;
sampleCount[i]++;
}
}
else
{
float angle = atan2(float(j), float(i)) + PI;
uint sector = float((angle * 7) / (PI * 2)) % 7;
float luma = tex2Dfetch(sLuma, coord + float2(i, j)).r;
if(GammaCorrect)
{
luma *= luma;
}
luma *= sharpnessMultiplier;
float centerDistance = length(float2(i, j));
maximum = max(maximum, luma * rcp((centerDistance)));
minimum = min(minimum, luma * (centerDistance));
sum[sector] += luma;
squaredSum[sector] += luma * luma;
sampleCount[sector]++;
}
}
}
#line 404
float edgeMultiplier = (max((1-(maximum - minimum) * rcp(maximum)), 1e-5));
edgeMultiplier = edgeMultiplier * (1 - EdgeFloor) + EdgeFloor;
#line 407
float weightedSum = 0;
float weightSum = 0;
uint count = 0;
[unroll]
for(int i = 0; i < 7; i++)
{
float sumSquared = sum[i] * sum[i];
float mean = sum[i] / sampleCount[i];
float variance = (squaredSum[i] - ((sumSquared) / sampleCount[i]));
variance /= sampleCount[i];
#line 418
float weight = max( variance, 1e-5);
weight *= weight;
weight *= weight;
weight = rcp(1 + weight);
#line 423
weightedSum += mean * weight;
weightSum += weight;
}
#line 427
float kuwahara = ((weightedSum) / weightSum) / sharpnessMultiplier;
#line 429
kuwahara = center + (center - kuwahara) * SharpenStrength * edgeMultiplier * 1.5;
if(GammaCorrect) kuwahara = sqrt(kuwahara);
#line 432
if(Debug == 1) kuwahara = edgeMultiplier;
#line 434
float3 color = tex2Dfetch(sBackBuffer, coord).rgb;
float cb = dot(color, float3(-0.168736, -0.331264, 0.5));
float cr = dot(color, float3(0.5, -0.418688, -0.081312));
float luma = dot(color, float3(0.299, 0.587, 0.114));
#line 440
output.r = dot(float2(kuwahara, cr), float2(1, 1.402));
output.g = dot(float3(kuwahara, cb, cr), float3(1, -0.344135, -0.714136));
output.b = dot(float2(kuwahara, cb), float2(1, 1.772));
output.a = 1;
#line 445
float depthCurve = 1;
if(EnableDepth)
{
float depth = ReShade::GetLinearizedDepth(texcoord);
depthCurve = lerp(0, 1, 1/max(exp(depth * (1 - DepthCurve) * 3), 0.0001));
if(MaskSky && depth > 0.999) depthCurve = 0;
output = lerp(color.rgbr, output, depthCurve);
}
#line 454
if(Debug == 1) output = kuwahara * depthCurve;
else if(Debug == 2)
{
output = (kuwahara - luma) + 0.5;
}
}
#line 461
technique SharpContrast< ui_tooltip =     "SharpContrast is a sharpen that takes into acount a wider screen area,\n"
"than most sharpen shaders, while also attempting to avoid crossing contrast boundries, \n"
"giving it a unique look.\n\n"
"Part of Insane Shaders\n"
"By: Lord of Lunacy\n\n"
"SHARP_CONTRAST_COMPUTE: Allows you to chose to disable or enable\n"
"\t\t the compute shader mode in supported APIs.\n"
"SHARP_CONTRAST_SIZE: Changes the size of the filter being used.\n"
"\t\t Set lower for more performance.\n"
"SHARP_CONTRAST_FASTER_COMPILE: Set to 0 for a slight performance increase,\n"
"\t\t at the expense of a longer compile time. (Compute Only)";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = LumaPS;
RenderTarget = Luma;
}
#line 489
pass
{
VertexShader = PostProcessVS;
PixelShader = OutputPS;
}
}
#line 496
}

