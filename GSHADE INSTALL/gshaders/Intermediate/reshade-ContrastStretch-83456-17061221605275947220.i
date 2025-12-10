// CONTRAST_LUT_SIZE=1
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ContrastStretch.fx"
#line 66
namespace Contrast
{
texture BackBuffer : COLOR;
texture Histogram {Width = 1024; Height = 1; Format = R32f;};
texture PrefixSums {Width = 1024; Height = 1; Format = RG32f;};
#line 72
sampler sBackBuffer {Texture = BackBuffer;};
sampler sHistogram {Texture = Histogram;};
sampler sPrefixSums {Texture = PrefixSums;};
#line 78
texture HistogramRows {Width = 1024; Height = uint((int(uint(uint2((1280 / 4), (720 / 4)).x * uint2((1280 / 4), (720 / 4)).y) + 128 - 1) / int(128))); Format = R8;};
#line 80
sampler sHistogramRows {Texture = HistogramRows;};
#line 83
texture Variances {Width = 3; Height = 1; Format = R32f;};
texture CSHistogramLUT {Width = 1024; Height = 1; Format = R32f;};
#line 86
sampler sVariances {Texture = Variances;};
sampler sHistogramLUT {Texture = CSHistogramLUT;};
#line 99
uniform float Minimum<
ui_type = "slider";
ui_label = "Minimum";
ui_category = "Thresholds";
ui_min = 0; ui_max = 1;
> = 0;
#line 106
uniform float DarkThreshold<
ui_type = "slider";
ui_label = "Dark Threshold";
ui_category = "Thresholds";
ui_min = 0; ui_max = 1;
> = 0.333;
#line 113
uniform float LightThreshold<
ui_type = "slider";
ui_label = "LightThreshold";
ui_category = "Thresholds";
ui_min = 0; ui_max = 1;
> = 0.667;
#line 120
uniform float Maximum<
ui_type = "slider";
ui_label = "Maximum";
ui_category = "Thresholds";
ui_min = 0; ui_max = 1;
> = 1;
#line 127
uniform float MaxVariance<
ui_type = "slider";
ui_label = "Maximum Curve Value";
ui_tooltip = "Value that the weighting curves return to 0 at.";
ui_category = "Maximum Curve Value";
ui_min = 0.15; ui_max = 1;
> = 1;
#line 135
uniform float DarkPeak<
ui_type = "slider";
ui_label = "Dark Blending Curve";
ui_category = "Dark Settings";
ui_min = 0; ui_max = 1;
> = 0.5;
#line 142
uniform float DarkMax<
ui_type = "slider";
ui_label = "Dark Maximum Blending";
ui_category = "Dark Settings";
ui_min = 0; ui_max = 1;
> = 0.45;
#line 149
uniform float MidPeak<
ui_type = "slider";
ui_label = "Mid Blending Curve";
ui_category = "Mid Settings";
ui_min = 0; ui_max = 1;
> = 0.55;
#line 156
uniform float MidMax<
ui_type = "slider";
ui_label = "Mid Maximum Blending";
ui_category = "Mid Settings";
ui_min = 0; ui_max = 1;
> = 0.45;
#line 163
uniform float LightPeak<
ui_type = "slider";
ui_label = "Light Blending Curve";
ui_category = "Light Settings";
ui_min = 0; ui_max = 1;
> = 0.45;
#line 170
uniform float LightMax<
ui_type = "slider";
ui_label = "Light Maximum Blending";
ui_category = "Light Settings";
ui_min = 0; ui_max = 1;
> = 0.3;
#line 177
uniform uint Debug<
ui_type = "combo";
ui_label = "Debug";
ui_category = "Debug Views";
ui_items = "None \0Histogram \0Dark Curve Input \0Mid Curve Input \0Light Curve Input \0";
> = 0;
#line 184
float WeightingCurve(float peak, float variance, float maximumBlending)
{
variance = clamp(variance, 0, MaxVariance);
if(variance <= peak)
{
return lerp(0, maximumBlending, abs(variance) / peak);
}
else
{
return lerp(maximumBlending, 0, abs(variance - peak) / (MaxVariance - peak));
}
}
#line 280
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 288
void HistogramVS(in uint id : SV_VertexID, out float4 pos : SV_Position)
{
float2 coord = floor(float2(id % uint2((1280 / 4), (720 / 4)).x, id / uint2((1280 / 4), (720 / 4)).x)) * 4 + 0.5;
float luma = (round(dot(tex2Dfetch(sBackBuffer, coord).rgb, float3(0.299, 0.587, 0.114)) * (1024 - 1)) + 0.5) / float(1024);
#line 293
pos.x = luma * 2 - 1;
pos.y = (floor(id / 128) + 0.5) / float(uint((int(uint(uint2((1280 / 4), (720 / 4)).x * uint2((1280 / 4), (720 / 4)).y) + 128 - 1) / int(128)))) * 2 - 1;
pos.z = 0;
pos.w = 1;
}
#line 299
void HistogramMergeVS(in uint id : SV_VertexID, out float4 pos : SV_Position, out float2 sum : TEXCOORD)
{
float2 coord = floor(float2(id % 1024, id / 1024));
coord.y = coord.y * 8 + 0.5;
sum = 0;
#line 305
[unroll]
for(int i = 0; i < 8; i += 2)
{
sum += tex2Dfetch(sHistogramRows, coord).xx * 512;
}
if(sum.x < 1)
{
pos.x = 2;
}
else
{
pos.x = ((coord.x + 0.5) / float(1024)) * 2 - 1;
}
pos.yz = 0;
pos.w = 1;
}
#line 323
void PrefixSumsVS(in uint id : SV_VertexID, out float4 pos : SV_Position, out float2 prefixes : TEXCOORD)
{
uint bin = id / 2;
float2 coord;
coord.x = (id % 2 == 0) ? bin : (1024);
coord.y = 0;
pos.x = ((coord.x + 0.5) / float(1024)) * 2 - 1;
pos.yz = 0;
pos.w = 1;
prefixes = tex2Dfetch(sHistogram, float2(bin, 0)).xx;
prefixes.y *= bin;
}
#line 336
void VariancesVS(in uint id : SV_VertexID, out float4 pos : SV_Position, out float2 partialVariance : TEXCOORD)
{
uint bin = id;
pos.yz = 0;
pos.w = 1;
uint2 thresholds = round(float2(DarkThreshold, LightThreshold) * (1024 - 1));
if(bin <= thresholds.x)
{
float2 sums = tex2Dfetch(sPrefixSums, float2(thresholds.x, 0)).xy;
float mean = sums.y / sums.x;
float localSum = tex2Dfetch(sHistogram, float2(bin, 0)).x;
partialVariance = ((abs(bin - mean)) / float(thresholds.x - 1)) * (localSum / sums.x);
pos.x = -0.66666666666;
}
else if(bin <= thresholds.y)
{
float2 sums = tex2Dfetch(sPrefixSums, float2(thresholds.y, 0)).xy;
float2 previousSums = tex2Dfetch(sPrefixSums, float2(thresholds.x, 0)).xy;
sums -= previousSums;
float mean = sums.y / sums.x;
float localSum = tex2Dfetch(sHistogram, float2(bin, 0)).x;
partialVariance = ((abs(float(bin) - mean)) / float(thresholds.y - thresholds.x)) * (localSum / sums.x);
pos.x = 0;
}
else
{
float2 sums = tex2Dfetch(sPrefixSums, float2(1024 - 1, 0)).xy;
float2 previousSums = tex2Dfetch(sPrefixSums, float2(thresholds.y, 0)).xy;
sums -= previousSums;
float mean = sums.y / sums.x;
float localSum = tex2Dfetch(sHistogram, float2(bin, 0)).x;
partialVariance = ((abs(float(bin) - mean)) / float(1024 - thresholds.y)) * (localSum / sums.x);
pos.x = 0.66666666666;
}
#line 371
}
void HistogramPS(float4 pos : SV_Position, out float add : SV_Target0)
{
add = 0.00390625; 
}
#line 377
void PrefixSumsPS(float4 pos : SV_Position, float2 prefixes : TEXCOORD, out float2 output : SV_Target0)
{
output = prefixes;
}
#line 382
void TexcoordXPS(float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float output : SV_Target0)
{
output = texcoord.x;
}
#line 387
void LUTGenerationPS(float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float LUT : SV_Target0)
{
float2 coord = float2(round(texcoord.x * float(1024 - 1)), 0);
float prefixSum = tex2Dfetch(sPrefixSums, coord).x;
uint2 thresholds = round(float2(DarkThreshold, LightThreshold) * (1024 - 1));
if(coord.x <= thresholds.x)
{
if(prefixSum > 0)
{
LUT = (prefixSum / tex2Dfetch(sPrefixSums, float2(thresholds.x, 0)).x);
LUT = LUT * (DarkThreshold - Minimum) + Minimum;
float alpha = WeightingCurve(DarkPeak, tex2Dfetch(sVariances, float2(0, 0)).x, DarkMax);
LUT = lerp(texcoord.x, LUT, alpha);
}
else
{
LUT = texcoord.x * (DarkThreshold - Minimum) + Minimum;
}
}
else if(coord.x <= thresholds.y)
{
float previousSum = tex2Dfetch(sPrefixSums, float2(thresholds.x, 0)).x;
prefixSum -= previousSum;
float denominator = tex2Dfetch(sPrefixSums, float2(thresholds.y, 0)).x - previousSum;
if(denominator < 1)
{
LUT = texcoord.x * (LightThreshold - DarkThreshold) + DarkThreshold;
}
else
{
LUT = prefixSum / denominator;
LUT = LUT * (LightThreshold - DarkThreshold) + DarkThreshold;
float alpha = WeightingCurve(MidPeak, tex2Dfetch(sVariances, float2(1, 0)).x, MidMax);
LUT = lerp(texcoord.x, LUT, alpha);
}
}
else
{
float previousSum = tex2Dfetch(sPrefixSums, float2(thresholds.y, 0)).x;
prefixSum -= previousSum;
float denominator = tex2Dfetch(sPrefixSums, float2(1024 - 1, 0)).x - previousSum;
if(denominator < 1)
{
LUT = texcoord.x * (Maximum - LightThreshold) + LightThreshold;
}
else
{
LUT = prefixSum / denominator;
LUT = LUT * (Maximum - LightThreshold) + LightThreshold;
float alpha = WeightingCurve(LightPeak, tex2Dfetch(sVariances, float2(2, 0)).x, LightMax);
LUT = lerp(texcoord.x, LUT, alpha);
}
}
}
#line 442
void OutputPS(float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float3 color : SV_Target0)
{
color = tex2D(sBackBuffer, texcoord).rgb;
float yOld = dot(color, float3(0.299, 0.587, 0.114));
float y = tex2D(sHistogramLUT, float2(yOld, 0.5)).x;
#line 448
float cb = -0.168736 * color.r - 0.331264 * color.g + 0.500000 * color.b;
float cr = +0.500000 * color.r - 0.418688 * color.g - 0.081312 * color.b;
#line 451
color = float3(
y + 1.402 * cr,
y - 0.344136 * cb - 0.714136 * cr,
y + 1.772 * cb);
#line 456
if(Debug == 1)
{
texcoord = float2(3 * texcoord.x - 2, 1 - texcoord.y);
uint2 coord = uint2(round(texcoord * float2((1024 - 1), 720 * (65536 / (1024 * 4 * 0.5 * 4)))));
if(texcoord.x >= 0)
{
uint histogramBin = tex2D(sHistogram, float2(texcoord.x, 0.5)).x;
if(coord.y <= histogramBin)
{
color = lerp(color, 1 - color, 0.7);
}
}
}
else if(Debug == 2)
{
texcoord = float2(1 - texcoord.x, texcoord.y * (float(720) / float(1280)));
if(all(texcoord <= 0.125))
{
color = tex2Dfetch(sVariances, float2(0, 0)).xxx;
}
}
else if(Debug == 3)
{
texcoord = float2(1 - texcoord.x, texcoord.y * (float(720) / float(1280)));
if(all(texcoord <= 0.125))
{
color = tex2Dfetch(sVariances, float2(1, 0)).xxx;
}
}
else if(Debug == 4)
{
texcoord = float2(1 - texcoord.x, texcoord.y * (float(720) / float(1280)));
if(all(texcoord <= 0.125))
{
color = tex2Dfetch(sVariances, float2(2, 0)).xxx;
}
}
}
#line 495
technique ContrastStretch<ui_tooltip = "A histogram based contrast stretching shader that adaptively adjusts the contrast of the image\n"
"based on its contents.\n\n"
"Part of Insane Shaders \n"
"By: Lord Of Lunacy\n\n"
"CONTRAST_LUT_SIZES correspond as follows: \n"
"0 for 256 \n1 for 1024 (default) \n2 for 2048 \n3 for 4096";>
{
#line 517
pass Histogram
{
VertexShader = HistogramVS;
PixelShader = HistogramPS;
RenderTarget0 = HistogramRows;
PrimitiveTopology = POINTLIST;
VertexCount = uint(uint2((1280 / 4), (720 / 4)).x * uint2((1280 / 4), (720 / 4)).y);
ClearRenderTargets = true;
BlendEnable = true;
BlendOp = ADD;
SrcBlend = ONE;
DestBlend = ONE;
}
#line 531
pass HistogramMerge
{
VertexShader = HistogramMergeVS;
PixelShader = TexcoordXPS;
RenderTarget0 = Histogram;
PrimitiveTopology = POINTLIST;
VertexCount = (int(1024 * uint((int(uint(uint2((1280 / 4), (720 / 4)).x * uint2((1280 / 4), (720 / 4)).y) + 128 - 1) / int(128))) + 8 - 1) / int(8));
ClearRenderTargets = true;
BlendEnable = true;
BlendOp = ADD;
SrcBlend = ONE;
DestBlend = ONE;
}
#line 546
pass PrefixSums
{
VertexShader = PrefixSumsVS;
PixelShader = PrefixSumsPS;
RenderTarget0 = PrefixSums;
PrimitiveTopology = LINELIST;
VertexCount = 1024 * 2;
ClearRenderTargets = true;
BlendEnable = true;
BlendOp = ADD;
SrcBlend = ONE;
DestBlend = ONE;
}
#line 560
pass Variances
{
VertexShader = VariancesVS;
PixelShader = TexcoordXPS;
RenderTarget0 = Variances;
PrimitiveTopology = POINTLIST;
VertexCount = 1024;
ClearRenderTargets = true;
BlendEnable = true;
BlendOp = ADD;
SrcBlend = ONE;
DestBlend = ONE;
}
#line 574
pass LUTGeneration
{
VertexShader = PostProcessVS;
PixelShader = LUTGenerationPS;
RenderTarget0 = CSHistogramLUT;
}
#line 581
pass Output
{
VertexShader = PostProcessVS;
PixelShader = OutputPS;
}
}
}

