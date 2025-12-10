// BESSEL_BLOOM_USE_RGBA16F=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\Bessel_Bloom.fx"
#line 73
static const float4 coefficients = float4(1, 1.5, -0.8333333, 0.1666667);
namespace Bessel_Bloom
{
texture BackBuffer:COLOR;
texture Blur0{Width = 1920; Height = 1018; Format = RGB10A2;};
texture Blur1{Width = 1920; Height = 1018; Format = RGB10A2;};
#line 80
sampler sBackBuffer{Texture = BackBuffer;};
sampler sBlur0{Texture = Blur0;};
sampler sBlur1{Texture = Blur1;};
#line 85
storage wBlur0{Texture = Blur0;};
storage wBlur1{Texture = Blur1;};
#line 89
uniform float Intensity<
ui_type = "slider";
ui_label = "Intensity";
ui_tooltip = "How strong the effect is.";
ui_min = 0; ui_max = 2;
ui_step = 0.001;
> = 1;
#line 97
uniform float K<
ui_type = "slider";
ui_label = "Radius";
ui_tooltip = "This changes the radius of the effect, and should be\n"
"used in combination with the Performance dropdown.";
ui_min = 64; ui_max = 128;
ui_step = 0.001;
> = 128;
#line 106
uniform float Saturation<
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "How strong the effect is.";
ui_min = 0; ui_max = 2;
ui_step = 0.001;
> = 1;
#line 114
uniform float Threshold<
ui_type = "slider";
ui_label = "Threshold";
ui_tooltip = "Brightness threshold for contributing to the bloom.";
ui_min = 0; ui_max = 1;
ui_step = 0.001;
> = 0.7;
#line 122
uniform float SoftKnee<
ui_type = "slider";
ui_label = "Soft Knee";
ui_tooltip = "A tuning to make the transition between the threshold smoother,\n"
"0 corresponds to a hard threshold while a value of 1 corresponds\n"
"to a soft threshold.";
ui_min = 0; ui_max = 1;
ui_step = 0.001;
> = 0.5;
#line 132
uniform float Gamma<
ui_type = "slider";
ui_label = "Gamma";
ui_min = 1; ui_max = 4;
ui_step = 0.1;
> = 2.2;
#line 139
uniform int Performance<
ui_type = "combo";
ui_label = "Performance";
ui_items = "Very Low\0Low\0Medium\0High\0";
ui_tooltip = "Has an impact on the radius of the effect, going down to low\n"
"will make the max radius half the size it is on medium,\n"
"and going to high will make it twice the size it is on medium.";
> = 2;
#line 148
uniform bool Debug<
ui_label = "Show Bloom";
> = 0;
#line 153
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 160
float4 PackColors(float3 color)
{
#line 166
float4 output;
output.rgb = color.rgb;
float3 outputRcp = rcp(output.rgb);
float minRCP = min(min(outputRcp.r, outputRcp.g), outputRcp.b);
output.a = (minRCP > 8) ? (3/3) :
(minRCP > 4) ? (2/3) :
(minRCP > 2) ? (1/3) : 0;
output.rgb *= exp2(output.a * 3);
return output;
#line 176
}
#line 178
float3 UnpackColors(float4 color)
{
#line 183
return color.rgb * exp2(-(3 * color.a));
#line 185
}
#line 187
void PrefilterPS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD, out float4 output : SV_TARGET0)
{
float3 color = tex2D(sBackBuffer, texcoord).rgb;
color = pow(abs(color), Gamma);
float brightness = max(max(color.r, color.g), color.b);
float knee = Threshold * SoftKnee + 1e-5f;
float3 curve = float3(Threshold - knee, knee * 2, 0.25f / knee);
float rq = clamp(brightness - curve.x, 0, curve.y);
rq = curve.z * rq * rq;
output.rgb = color * (max(rq, brightness - Threshold) / max(brightness, 1e-5));
output.rgb *= rcp(1-Threshold);
output = PackColors(output.rgb);
#line 200
}
#line 202
void HorizontalForwardFilter(uint3 id, int filterWidth, float k)
{
float2 coord = float2(id.x * 256, id.y) + 0.5;
float4 curr[3];
float4 prev[3];
#line 208
float denominator = k * k + 3 * k + 3;
float3 currWeights = float3(3, 6, 3) / denominator;
float2 prevWeights = float2(-6 + 2*k*k, -k*k + 3 * k - 3) / denominator;
prev[0] = UnpackColors(tex2Dfetch(sBlur1, clamp(float2(coord.x - filterWidth, coord.y), 0, float2(1920, 1018) - 1))).xyzx;
float brightness = max(max(prev[0].r, prev[0].g), prev[0].b);
prev[1] = prev[0].yyyy;
prev[2] = prev[0].zzzz;
prev[0] = prev[0].xxxx;
curr[0] = prev[0];
curr[1] = prev[1];
curr[2] = prev[2];
#line 220
for(int i = -filterWidth + 1; i < 256; i++)
{
float2 sampleCoord = clamp(float2(coord.x + i, coord.y), 0, float2(1920, 1018) - 1);
float3 newSample = UnpackColors(tex2Dfetch(sBlur1, sampleCoord));
[unroll]
for(int j = 0; j < 3; j++)
{
curr[j] = float4(newSample[j], curr[j].xyz);
prev[j] = float4(dot(curr[j].xyz, currWeights) + dot(prev[j].xy, prevWeights), prev[j].xyz);
}
if(i >= 0)
{
tex2Dstore(wBlur0, int2(coord.x + i, coord.y), PackColors(float3(prev[0].x, prev[1].x, prev[2].x)));
}
}
}
#line 237
void HorizontalBackwardFilter(uint3 id, int filterWidth, float k)
{
float2 coord = float2(id.x * 256 + 256, id.y) + 0.5;
float4 curr[3];
float4 prev[3];
float denominator = k * k + 3 * k + 3;
float3 currWeights = float3(3, 6, 3) / denominator;
float2 prevWeights = float2(-6 + 2*k*k, -k*k + 3 * k - 3) / denominator;
prev[0] = UnpackColors(tex2Dfetch(sBlur0, clamp(float2(coord.x + filterWidth, coord.y), 0, float2(1920, 1018) - 1))).xyzx;
prev[1] = prev[0].yyyy;
prev[2] = prev[0].zzzz;
prev[0] = prev[0].xxxx;
curr[0] = prev[0];
curr[1] = prev[1];
curr[2] = prev[2];
#line 254
for(int i = filterWidth - 1; i > -256; i--)
{
float2 sampleCoord = clamp(float2(coord.x + i, coord.y), 0, float2(1920, 1018) - 1);
float3 newSample = UnpackColors(tex2Dfetch(sBlur0, sampleCoord));
[unroll]
for(int j = 0; j < 3; j++)
{
curr[j] = float4(newSample[j], curr[j].xyz);
prev[j] = float4(dot(curr[j].xyz, currWeights) + dot(prev[j].xy, prevWeights), prev[j].xyz);
}
if(i <= 0)
{
#line 267
barrier();
tex2Dstore(wBlur1, int2(coord.x + i, coord.y), PackColors(float3(prev[0].x, prev[1].x, prev[2].x)));
}
}
}
#line 273
void VerticalForwardFilter(uint3 id, int filterWidth, float k)
{
float2 coord = float2(id.x, id.y * 256) + 0.5;
float4 curr[3];
float4 prev[3];
float denominator = k * k + 3 * k + 3;
float3 currWeights = float3(3, 6, 3) / denominator;
float2 prevWeights = float2(-6 + 2*k*k, -k*k + 3 * k - 3) / denominator;
#line 282
prev[0] = UnpackColors(tex2Dfetch(sBlur1, clamp(float2(coord.x, coord.y - filterWidth), 0, float2(1920, 1018) - 1))).xyzx;
prev[1] = prev[0].yyyy;
prev[2] = prev[0].zzzz;
prev[0] = prev[0].xxxx;
curr[0] = prev[0];
curr[1] = prev[1];
curr[2] = prev[2];
#line 290
for(int i = -filterWidth + 1; i < 256; i++)
{
float2 sampleCoord = clamp(float2(coord.x, coord.y + i), 0, float2(1920, 1018) - 1);
float3 newSample = UnpackColors(tex2Dfetch(sBlur1, sampleCoord));
[unroll]
for(int j = 0; j < 3; j++)
{
curr[j] = float4(newSample[j], curr[j].xyz);
prev[j] = float4(dot(curr[j].xyz, currWeights) + dot(prev[j].xy, prevWeights), prev[j].xyz);
}
if(i >= 0)
{
tex2Dstore(wBlur0, int2(coord.x, coord.y + i), PackColors(float3(prev[0].x, prev[1].x, prev[2].x)));
}
}
}
#line 307
void VerticalBackwardFilter(uint3 id, int filterWidth, float k)
{
float2 coord = float2(id.x, id.y * 256 + 256) + 0.5;
float4 curr[3];
float4 prev[3];
float denominator = k * k + 3 * k + 3;
float3 currWeights = float3(3, 6, 3) / denominator;
float2 prevWeights = float2(-6 + 2*k*k, -k*k + 3 * k - 3) / denominator;
#line 316
prev[0] = UnpackColors(tex2Dfetch(sBlur0, clamp(float2(coord.x, coord.y + filterWidth), 0, float2(1920, 1018) - 1))).xyzx;
prev[1] = prev[0].yyyy;
prev[2] = prev[0].zzzz;
prev[0] = prev[0].xxxx;
curr[0] = prev[0];
curr[1] = prev[1];
curr[2] = prev[2];
#line 325
for(int i = filterWidth - 1; i > -256; i--)
{
float2 sampleCoord = clamp(float2(coord.x, coord.y + i), 0, float2(1920, 1018) - 1);
float3 newSample = UnpackColors(tex2Dfetch(sBlur0, sampleCoord));
[unroll]
for(int j = 0; j < 3; j++)
{
curr[j] = float4(newSample[j], curr[j].xyz);
prev[j] = float4(dot(curr[j].xyz, currWeights) + dot(prev[j].xy, prevWeights), prev[j].xyz);
}
if(i <= 0)
{
tex2Dstore(wBlur1, int2(coord.x, coord.y + i), PackColors(float3(prev[0].x, prev[1].x, prev[2].x)));
}
}
}
#line 342
void HorizontalFilterCS0(uint3 id : SV_DispatchThreadID)
{
switch(Performance)
{
case 0:
HorizontalForwardFilter(id, 256/4, K/4);
break;
case 1:
HorizontalForwardFilter(id, 256/2, K/2);
break;
case 3:
HorizontalForwardFilter(id, 256 * 2, K * 2);
break;
default:
HorizontalForwardFilter(id, 256, K);
break;
}
}
#line 361
void HorizontalFilterCS1(uint3 id : SV_DispatchThreadID)
{
switch(Performance)
{
case 0:
HorizontalBackwardFilter(id, 256/4, K/4);
break;
case 1:
HorizontalBackwardFilter(id, 256/2, K/2);
break;
case 3:
HorizontalBackwardFilter(id, 256 * 2, K * 2);
break;
default:
HorizontalBackwardFilter(id, 256, K);
break;
}
}
#line 380
void VerticalFilterCS0(uint3 id : SV_DispatchThreadID)
{
switch(Performance)
{
case 0:
VerticalForwardFilter(id, 256/4, K/4);
break;
case 1:
VerticalForwardFilter(id, 256/2, K/2);
break;
case 3:
VerticalForwardFilter(id, 256 * 2, K * 2);
break;
default:
VerticalForwardFilter(id, 256, K);
break;
}
}
#line 399
void VerticalFilterCS1(uint3 id : SV_DispatchThreadID)
{
switch(Performance)
{
case 0:
VerticalBackwardFilter(id, 256/4, K/4);
break;
case 1:
VerticalBackwardFilter(id, 256/2, K/2);
break;
case 3:
VerticalBackwardFilter(id, 256 * 2, K * 2);
break;
default:
VerticalBackwardFilter(id, 256, K);
break;
}
}
#line 418
void OutputPS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD, out float4 output : SV_TARGET0)
{
float3 color = tex2D(sBackBuffer, texcoord).rgb;
float3 bloom = UnpackColors(tex2D(sBlur1, texcoord));
float greyComponent = dot(bloom, 0.33333);
bloom = lerp(greyComponent, bloom, Saturation);
#line 425
output.a = 1;
output.rgb = pow(abs(pow(abs(color), Gamma) + bloom * Intensity * (1-Threshold)), rcp(Gamma));
if(Debug)
{
output.rgb = pow(abs(bloom * Intensity * (1-Threshold)), rcp(Gamma));
}
#line 435
}
#line 437
technique Bessel_Bloom< ui_tooltip = "Instead of using the typical Gaussian filter used by bloom, an approximate is implemented instead\n"
"using a 2nd order Bessel IIR filter.\n\n"
"Part of Insane Shaders\n"
"By: Lord Of Lunacy";>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PrefilterPS;
RenderTarget = Blur1;
}
#line 449
pass
{
ComputeShader = HorizontalFilterCS0<uint2(1, 64).x, uint2(1, 64).y>;
DispatchSizeX = uint2(uint(((1920) + (256) - 1) / (256)), uint(((1018) + (64) - 1) / (64))).x;
DispatchSizeY = uint2(uint(((1920) + (256) - 1) / (256)), uint(((1018) + (64) - 1) / (64))).y;
}
#line 456
pass
{
ComputeShader = HorizontalFilterCS1<uint2(1, 64).x, uint2(1, 64).y>;
DispatchSizeX = uint2(uint(((1920) + (256) - 1) / (256)), uint(((1018) + (64) - 1) / (64))).x;
DispatchSizeY = uint2(uint(((1920) + (256) - 1) / (256)), uint(((1018) + (64) - 1) / (64))).y;
}
#line 463
pass
{
ComputeShader = VerticalFilterCS0<uint2(64, 1).x, uint2(64, 1).y>;
DispatchSizeX = uint2(uint(((1920) + (64) - 1) / (64)), uint(((1018) + (256) - 1) / (256))).x;
DispatchSizeY = uint2(uint(((1920) + (64) - 1) / (64)), uint(((1018) + (256) - 1) / (256))).y;
}
#line 470
pass
{
ComputeShader = VerticalFilterCS1<uint2(64, 1).x, uint2(64, 1).y>;
DispatchSizeX = uint2(uint(((1920) + (64) - 1) / (64)), uint(((1018) + (256) - 1) / (256))).x;
DispatchSizeY = uint2(uint(((1920) + (64) - 1) / (64)), uint(((1018) + (256) - 1) / (256))).y;
}
#line 477
pass
{
VertexShader = PostProcessVS;
PixelShader = OutputPS;
}
}
}

