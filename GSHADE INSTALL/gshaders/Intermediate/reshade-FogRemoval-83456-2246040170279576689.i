// FOGREMOVALDEBUG=0
// FOGREMOVALMAXPERCENTILE=0.95
// FOGREMOVALCORRECTCOLOR=1
// FOGREMOVALPRESERVEDETAIL=1
// FOGREMOVALUSEDEPTH=0
// FOGREMOVALSENSITIVITYBOUNDSY=0.75
// FOGREMOVALSENSITIVITYBOUNDSX=0.2
// FOGREMOVALMEDIANBOUNDSY=0.8
// FOGREMOVALMEDIANBOUNDSX=0.2
// FOGREMOVALREMOVALCAP=0.35
// FOGREMOVALDEPTHCURVE=0.0
// FOGREMOVALSTRENGTH=0.950
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FogRemoval.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\FogRemoval.fx"
#line 37
uniform float STRENGTH<
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Strength";
ui_tooltip = "Setting strength to high is known to cause bright regions to turn black before reintroduction.";
ui_bind = "FOGREMOVALSTRENGTH";
> = 0.950;
#line 50
uniform float DEPTHCURVE<
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Depth Curve";
ui_bind = "FOGREMOVALDEPTHCURVE";
> = 0.0;
#line 62
uniform float REMOVALCAP<
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Fog Removal Cap";
ui_tooltip = "Prevents fog removal from trying to extract more details than can actually be removed, \n"
"also helps preserve textures or lighting that may be detected as fog.";
ui_bind = "FOGREMOVALREMOVALCAP";
> = 0.35;
#line 76
uniform float MEDIANBOUNDSX<
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Average Light Level (Day)";
ui_tooltip = "This number should correspond to the average amount of light during the day.";
ui_bind = "FOGREMOVALMEDIANBOUNDSX";
> = 0.2;
#line 89
uniform float MEDIANBOUNDSY<
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Average Light Level (Night)";
ui_tooltip = "This number should correspond to the average amount of light at night.";
ui_bind = "FOGREMOVALMEDIANBOUNDSY";
> = 0.8;
#line 102
uniform float SENSITIVITYBOUNDSX<
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Fog Sensitivity (Day)";
ui_tooltip = "This number adjusts how sensitive the shader is to fog, a lower number means that \n"
"it will detect more fog in the scene, but will also be more vulnerable to false positives.\n"
"A higher number means that it will detect less fog in the scene but will also be more \n"
"likely to fail at detecting fog.";
ui_bind = "FOGREMOVALSENSITIVITYBOUNDSX";
> = 0.2;
#line 118
uniform float SENSITIVITYBOUNDSY<
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Fog Sensitivity (Night)";
ui_tooltip = "This number adjusts how sensitive the shader is to fog, a lower number means that \n"
"it will detect more fog in the scene, but will also be more vulnerable to false positives.\n"
"A higher number means that it will detect less fog in the scene but will also be more \n"
"likely to fail at detecting fog.";
ui_bind = "FOGREMOVALSENSITIVITYBOUNDSY";
> = 0.75;
#line 134
uniform bool USEDEPTH<
ui_label = "Ignore the sky";
ui_tooltip = "Useful for shaders such as RTGI that rely on skycolor";
ui_bind = "FOGREMOVALUSEDEPTH";
> = 0;
#line 145
uniform bool PRESERVEDETAIL<
ui_label = "Preserve Detail";
ui_category = "Fog Removal";
ui_tooltip = "Preserves finer details at the cost of some haloing and some performance.";
ui_bind = "FOGREMOVALPRESERVEDETAIL";
> = 1;
#line 157
uniform bool CORRECTCOLOR<
ui_category = "Color Correction";
ui_label = "Apply color correction";
ui_tooltip = "Helps with detecting fog that is not neutral in color. \n\n"
"Note: This setting is not always needed or may sometimes \n"
"      hinder fog removal.";
ui_bind = "FOGREMOVALCORRECTCOLOR";
> = 1;
#line 171
uniform float MAXPERCENTILE<
ui_type = "slider";
ui_label = "Color Correction Percentile";
ui_category = "Color Correction";
ui_min = 0.0; ui_max = 0.999;
ui_tooltip = "This percentile is the one used when finding the max RGB values for color correction, \n"
"having this set high may cause issues with things like UI elements, and image stability.";
ui_bind = "FOGREMOVALMAXPERCENTILE";
> = 0.95;
#line 186
uniform int DEBUG<
ui_type = "combo";
ui_category = "Debug";
ui_label = "Debug";
ui_items = "None \0Color Correction \0Transmission Map \0Fog Removed \0";
ui_bind = "FOGREMOVALDEBUG";
> = 0;
#line 200
texture ColorCorrected {Width = 1920; Height = 1018; Format = RGBA16F;};
sampler sColorCorrected {Texture = ColorCorrected;};
texture fTransmission {Width = 1920; Height = 1018; Format = R8;};
sampler sTransmission {Texture = fTransmission;};
texture FogRemovalHistogram {Width = 256; Height = 12; Format = R32F;};
sampler sFogRemovalHistogram {Texture = FogRemovalHistogram;};
texture HistogramInfo {Width = 1; Height = 1; Format = RGBA8;};
sampler sHistogramInfo {Texture = HistogramInfo;};
texture FogRemoved {Width = 1920; Height = 1018; Format = RGBA16F;};
sampler sFogRemoved {Texture = FogRemoved;};
texture TruncatedPrecision {Width = 1920; Height = 1018; Format = RGBA16F;};
sampler sTruncatedPrecision {Texture = TruncatedPrecision;};
#line 215
void HistogramVS(uint id : SV_VERTEXID, out float4 pos : SV_POSITION)
{
const uint iteration = (id % 4);
const int2 texturePos = int2((uint(id / 4) % (1920 / 15)) * 15, (uint(id / 4) / (1920 / 15)) * 15);
float color;
float y;
#line 222
switch (iteration)
{
case 0:
color = dot(tex2Dfetch(ReShade::BackBuffer, texturePos, 0).rgb, float3(0.33333333, 0.33333333, 0.33333333));
y = 0.75;
break;
case 1:
color = tex2Dfetch(ReShade::BackBuffer, texturePos, 0).r;
y = 0.25;
break;
case 2:
color = tex2Dfetch(ReShade::BackBuffer, texturePos, 0).g;
y = -0.25;
break;
case 3:
color = tex2Dfetch(ReShade::BackBuffer, texturePos, 0).b;
y = -0.75;
break;
}
#line 242
color = (color * 255 + 0.5) / 256;
pos = float4(color * 2 - 1, y, 0, 1);
}
#line 248
void HistogramPS(float4 pos : SV_POSITION, out float col : SV_TARGET )
{
col = 1.0;
}
#line 253
void HistogramInfoPS(float4 pos : SV_Position, out float4 output : SV_Target0)
{
const int fifty = abs(0.5 * ((1018 / 15) * (1920 / 15)));
const int usedMax = abs(0.95 * ((1018 / 15) * (1920 / 15)));
int4 sum = ((1018 / 15) * (1920 / 15));
output = 255.0;
int i = 255;
while((sum.r <= ((1018 / 15) * (1920 / 15)) || sum.g <= ((1018 / 15) * (1920 / 15)) || sum.b <= ((1018 / 15) * (1920 / 15)) || sum.a <= ((1018 / 15) * (1920 / 15))) && i >= 0)
{
#line 263
sum.r -= tex2Dfetch(sFogRemovalHistogram, int2(i, 4), 0).r;
sum.g -= tex2Dfetch(sFogRemovalHistogram, int2(i, 7), 0).r;
sum.b -= tex2Dfetch(sFogRemovalHistogram, int2(i, 10), 0).r;
if (sum.r < usedMax)
{
sum.r = 2 * ((1018 / 15) * (1920 / 15));
output.r = i;
}
if (sum.g < usedMax)
{
sum.g = 2 * ((1018 / 15) * (1920 / 15));
output.g = i;
}
if (sum.b < usedMax)
{
sum.b = 2 * ((1018 / 15) * (1920 / 15));
output.b = i;
}
#line 284
sum.a -= tex2Dfetch(sFogRemovalHistogram, int2(i, 1), 0).r;
if (sum.a < fifty)
{
sum.a =  2 * ((1018 / 15) * (1920 / 15));
output.a = i;
}
i--;
}
output = output / 255.0;
output.rgb = dot(0.33333333, output.rgb) / output.rgb;
}
#line 296
void ColorCorrectedPS(float4 pos: SV_Position, float2 texcoord : TexCoord, out float4 colorCorrected : SV_Target0)
{
#line 299
colorCorrected = float4(tex2D(ReShade::BackBuffer, texcoord).rgb * tex2Dfetch(sHistogramInfo, float2(0, 0), 0).rgb, 1);
#line 303
}
#line 305
void TransmissionPS(float4 pos: SV_Position, float2 texcoord : TexCoord, out float transmission : SV_Target0)
{
const float depth = ReShade::GetLinearizedDepth(texcoord);
#line 317
float3 color = tex2D(sColorCorrected, texcoord).rgb;
const float value = max(max(color.r, color.g), color.b);
const float minimum = min(min(color.r, color.g), color.b);
float darkChannel = minimum;
#line 323
float2 pixSize = tex2Dsize(sColorCorrected, 0);
pixSize.x = 1 / pixSize.x;
pixSize.y = 1 / pixSize.y;
float depthContrast = 0;
#line 328
[unroll]for(int i = -2; i <= 2; i++)
{
float depthSum = 0;
[unroll]for(int j = -2; j <= 2; j++)
{
color = tex2D(sColorCorrected, texcoord, int2(i, j)).rgb;
darkChannel = min(min(color.r, color.g), min(color.b, darkChannel));
float2 matrixCoord;
matrixCoord.x = texcoord.x + pixSize.x * i;
matrixCoord.y = texcoord.y + pixSize.y * j;
float depthSubtract = depth - ReShade::GetLinearizedDepth(matrixCoord);
depthSum += depthSubtract * depthSubtract;
}
depthContrast = max(depthContrast, depthSum);
}
depthContrast = sqrt(0.2 * depthContrast);
darkChannel = lerp(darkChannel, minimum, saturate(2 * depthContrast));
#line 347
const float v = (clamp(tex2Dfetch(sHistogramInfo, int2(0, 0), 0).a, 0.2, 0.8) - 0.2) * ((0.2 - 0.75) / (0.2 - 0.8)) + 0.2;
transmission = clamp(saturate((darkChannel / (1 - (value - ((value - minimum) / (value))))) - v * (darkChannel + darkChannel)) * (1 - v), 0, 0.35) * saturate((pow(depth, 100*0.0)) * 0.950);
}
#line 351
void FogRemovalPS(float4 pos: SV_Position, float2 texcoord : TexCoord, out float4 output : SV_Target0)
{
const float transmission = tex2D(sTransmission, texcoord).r;
output.rgb = (tex2D(sColorCorrected, texcoord).rgb - transmission) / max(((1 - transmission)), 0.01);
#line 356
output.rgb /= tex2Dfetch(sHistogramInfo, float2(0, 0), 0).rgb;
#line 359
output = float4(output.rgb, 1);
#line 366
}
#line 368
void WriteFogRemovedPS(float4 pos: SV_Position, float2 texcoord : TexCoord, out float3 output : SV_Target0)
{
output = tex2D(sFogRemoved, texcoord).rgb;
}
#line 373
void TruncatedPrecisionPS(float4 pos: SV_Position, float2 texcoord : TexCoord, out float4 output : SV_Target0)
{
output = float4((tex2D(sFogRemoved, texcoord).rgb - tex2D(ReShade::BackBuffer, texcoord).rgb), 1);
}
#line 378
void FogReintroductionPS(float4 pos : SV_Position, float2 texcoord : TexCoord, out float3 output : SV_Target0)
{
#line 384
const float transmission = tex2D(sTransmission, texcoord).r;
float3 original = tex2D(ReShade::BackBuffer, texcoord).rgb + tex2D(sTruncatedPrecision, texcoord).rgb;
#line 388
original *= tex2Dfetch(sHistogramInfo, float2(0, 0), 0).rgb;
#line 391
output = original * max(((1 - transmission)), 0.01) + transmission;
#line 394
output /= tex2Dfetch(sHistogramInfo, float2(0, 0), 0).rgb;
#line 400
}
#line 404
technique FogRemoval
{
pass Histogram
{
PixelShader = HistogramPS;
VertexShader = HistogramVS;
PrimitiveTopology = POINTLIST;
VertexCount = ((1018 / 15) * (1920 / 15)) * 4;
RenderTarget0 = FogRemovalHistogram;
ClearRenderTargets = true;
BlendEnable = true;
SrcBlend = ONE;
DestBlend = ONE;
BlendOp = ADD;
}
#line 420
pass HistogramInfo
{
VertexShader = PostProcessVS;
PixelShader = HistogramInfoPS;
RenderTarget0 = HistogramInfo;
ClearRenderTargets = true;
}
#line 428
pass ColorCorrected
{
VertexShader = PostProcessVS;
PixelShader = ColorCorrectedPS;
RenderTarget0 = ColorCorrected;
}
#line 435
pass Transmission
{
VertexShader = PostProcessVS;
PixelShader = TransmissionPS;
RenderTarget0 = fTransmission;
}
#line 442
pass FogRemoval
{
VertexShader = PostProcessVS;
PixelShader = FogRemovalPS;
RenderTarget0 = FogRemoved;
}
#line 449
pass FogRemoved
{
VertexShader = PostProcessVS;
PixelShader = WriteFogRemovedPS;
}
#line 455
pass TruncatedPrecision
{
VertexShader = PostProcessVS;
PixelShader = TruncatedPrecisionPS;
RenderTarget0 = TruncatedPrecision;
}
}
#line 463
technique FogReintroduction <ui_tooltip = "Place this after the shaders you want to be rendered without fog";>
{
pass Reintroduction
{
VertexShader = PostProcessVS;
PixelShader = FogReintroductionPS;
}
}

