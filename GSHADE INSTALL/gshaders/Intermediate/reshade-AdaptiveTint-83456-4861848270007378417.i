// STATS_MIPLEVEL=7.0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\AdaptiveTint.fx"
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
#line 39 "C:\Program Files\GShade\gshade-shaders\Shaders\AdaptiveTint.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Dao_Stats.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 38 "C:\Program Files\GShade\gshade-shaders\Shaders\Dao_Stats.fxh"
#line 43
namespace Stats {
texture2D shared_texStats { Width = 1920; Height = 1018; Format = RGBA8; MipLevels =  7.0; };
sampler2D shared_SamplerStats { Texture = shared_texStats; };
float3 OriginalBackBuffer(float2 texcoord) { return tex2D(shared_SamplerStats, texcoord).rgb; }
#line 48
texture2D shared_texStatsAvgColor { Format = RGBA8; };
sampler2D shared_SamplerStatsAvgColor { Texture = shared_texStatsAvgColor; };
float3 AverageColor() { return tex2Dfetch(shared_SamplerStatsAvgColor, int2(0, 0), 0).rgb; }
#line 52
texture2D shared_texStatsAvgLuma { Format = R16F; };
sampler2D shared_SamplerStatsAvgLuma { Texture = shared_texStatsAvgLuma; };
float AverageLuma() { return tex2Dfetch(shared_SamplerStatsAvgLuma, int2(0, 0), 0).r; }
#line 56
texture2D shared_texStatsAvgColorTemp { Format = R16F; };
sampler2D shared_SamplerStatsAvgColorTemp { Texture = shared_texStatsAvgColorTemp; };
float AverageColorTemp() { return tex2Dfetch(shared_SamplerStatsAvgColorTemp, int2(0, 0), 0).r; }
}
#line 40 "C:\Program Files\GShade\gshade-shaders\Shaders\AdaptiveTint.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Dao_Tools.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 38 "C:\Program Files\GShade\gshade-shaders\Shaders\Dao_Tools.fxh"
#line 115
struct sctpoint {
float3 color;
float2 coord;
};
#line 121
float3 ConvReturn(float3 X, float3 Y, int MulDotXYAddMax) {
float3 ret = float3(1.0, 0.0, 1.0);
#line 124
if(MulDotXYAddMax == 0)
ret = X * Y;
else if(MulDotXYAddMax == 1)
ret = dot(X,Y);
else if(MulDotXYAddMax == 2)
ret = X;
else if(MulDotXYAddMax == 3)
ret = Y;
else if(MulDotXYAddMax == 4)
ret = X + Y;
else if(MulDotXYAddMax == 5)
ret = max(X, Y);
return ret;
}
#line 140
namespace Tools {
#line 142
namespace Types {
#line 144
sctpoint Point(float3 color, float2 coord) {
sctpoint p;
p.color = color;
p.coord = coord;
return p;
}
#line 151
}
#line 153
namespace Color {
#line 155
float3 RGBtoYIQ(float3 color) {
static const float3x3 YIQ = float3x3( 	0.299, 0.587, 0.144,
0.596, -0.274, -0.322,
0.211, -0.523, 0.312  );
return mul(YIQ, color);
}
#line 162
float3 YIQtoRGB(float3 yiq) {
static const float3x3 RGB = float3x3( 	1.0, 0.956, 0.621,
1.0, -0.272, -0.647,
1.0, -1.106, 1.703  );
return saturate(mul(RGB, yiq));
}
#line 169
float4 RGBtoCMYK(float3 color) {
float3 CMY;
float K;
K = 1.0 - max(color.r, max(color.g, color.b));
CMY = (1.0 - color - K) / (1.0 - K);
return float4(CMY, K);
}
#line 177
float3 CMYKtoRGB(float4 cmyk) {
return (1.0.xxx - cmyk.xyz) * (1.0 - cmyk.w);
}
#line 183
float3 RGBtoHSV(float3 c) {
float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
#line 186
float4 p;
if (c.g < c.b)
p = float4(c.bg, K.wz);
else
p = float4(c.gb, K.xy);
#line 192
float4 q;
if (c.r < p.x)
q = float4(p.xyw, c.r);
else
q = float4(c.r, p.yzx);
#line 198
float d = q.x - min(q.w, q.y);
float e = 1.0e-10;
return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
#line 203
float3 HSVtoRGB(float3 c) {
float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}
#line 209
float GetSaturation(float3 color) {
float maxVal = max(color.r, max(color.g, color.b));
float minVal = min(color.r, min(color.g, color.b));
return maxVal - minVal;
}
#line 217
float3 LayerMerge(float3 mask, float3 image, int mode) {
float3 E = float3(1.0, 0.0, 1.0);
#line 220
if(mode == 0)
E = mask;
else if(mode == 1)
E = image * mask;
else if(mode == 2)
E = image / (mask + 0.00001);
else if(mode == 3 || mode == 8) {
E = 1.0 - (1.0 - image) * (1.0 - mask);
if(mode == 8)
E = image * ((1.0 - image) * mask + E);
}
else if(mode == 4)
if (max(image.r, max(image.g, image.b)) < 0.5)
E = lerp(2*image*mask, 1.0 - 2.0 * (1.0 - image) * (1.0 - mask), 0.0);
else
E = lerp(2*image*mask, 1.0 - 2.0 * (1.0 - image) * (1.0 - mask), 1.0);
else if(mode == 5)
E =  image / (1.00001 - mask);
else if(mode == 6)
E = 1.0 - (1.0 - image) / (mask + 0.00001);
else if(mode == 7)
if (max(image.r, max(image.g, image.b)) > 0.5)
E = lerp(
2*image*mask,
1.0 - 2.0 * (1.0 - image) * (1.0 - mask),
0.0
);
else
E = lerp(
2*image*mask,
1.0 - 2.0 * (1.0 - image) * (1.0 - mask),
1.0
);
else if(mode == 9)
E = image - mask + 0.5;
else if(mode == 10)
E = image + mask - 0.5;
else if(mode == 11)
E = abs(image - mask);
else if(mode == 12)
E = image + mask;
else if(mode == 13)
E = image - mask;
else if(mode == 14)
E = min(image, mask);
else if(mode == 15)
E = max(image, mask);
else if(mode == 16)
if (max(mask.r, max(mask.g, mask.b)) <= 0.5)
E = lerp(
max(1.0 - ((1.0 - image) / ((2.0 * mask) + 1e-9)), 0.0),
min(image / (2 * (1.0 - mask) + 1e-9), 1.0),
0.0
);
else
E = lerp(
max(1.0 - ((1.0 - image) / ((2.0 * mask) + 1e-9)), 0.0),
min(image / (2 * (1.0 - mask) + 1e-9), 1.0),
1.0
);
#line 281
return saturate(E);
}
#line 284
}
#line 286
namespace Convolution {
#line 288
float3 ThreeByThree(sampler s, int2 vpos, float kernel[9], float divisor) {
float3 acc;
#line 291
[unroll]
for(int m = 0; m < 3; m++) {
[unroll]
for(int n = 0; n < 3; n++) {
acc += kernel[n + (m*3)] * tex2Dfetch(s, int2( (vpos.x - 1 + n), (vpos.y - 1 + m)), 0).rgb;
}
}
#line 299
return acc / divisor;
}
#line 302
float3 ConvReturn(float3 X, float3 Y, int MulDotXYAddMax) {
float3 ret = float3(1.0, 0.0, 1.0);
#line 305
if(MulDotXYAddMax == 0)
ret = X * Y;
else if(MulDotXYAddMax == 1)
ret = dot(X,Y);
else if(MulDotXYAddMax == 2)
ret = X;
else if(MulDotXYAddMax == 3)
ret = Y;
else if(MulDotXYAddMax == 4)
ret = X + Y;
else if(MulDotXYAddMax == 5)
ret = max(X, Y);
return saturate(ret);
}
#line 320
float3 Edges(sampler s, int2 vpos, int kernel, int type) {
static const float Prewitt_X[9] = { -1.0,  0.0, 1.0,
-1.0,  0.0, 1.0,
-1.0,  0.0, 1.0	 };
#line 325
static const float Prewitt_Y[9] = { 1.0,  1.0,  1.0,
0.0,  0.0,  0.0,
-1.0, -1.0, -1.0  };
#line 329
static const float Prewitt_X_M[9] = { 1.0,  0.0, -1.0,
1.0,  0.0, -1.0,
1.0,  0.0, -1.0	 };
#line 333
static const float Prewitt_Y_M[9] = { -1.0,  -1.0,  -1.0,
0.0,  0.0,  0.0,
1.0, 1.0, 1.0  };
#line 337
static const float Sobel_X[9] = { 	1.0,  0.0, -1.0,
2.0,  0.0, -2.0,
1.0,  0.0, -1.0	 };
#line 341
static const float Sobel_Y[9] = { 	1.0,  2.0,  1.0,
0.0,  0.0,  0.0,
-1.0, -2.0, -1.0	 };
#line 345
static const float Sobel_X_M[9] = { 	-1.0,  0.0, 1.0,
-2.0,  0.0, 2.0,
-1.0,  0.0, 1.0	 };
#line 349
static const float Sobel_Y_M[9] = {   -1.0, -2.0, -1.0,
0.0,  0.0,  0.0,
1.0,  2.0,  1.0	 };
#line 353
static const float Scharr_X[9] = { 	 3.0,  0.0,  -3.0,
10.0,  0.0, -10.0,
3.0,  0.0,  -3.0  };
#line 357
static const float Scharr_Y[9] = { 	3.0,  10.0,   3.0,
0.0,   0.0,   0.0,
-3.0, -10.0,  -3.0  };
#line 361
static const float Scharr_X_M[9] = { 	 -3.0,  0.0,  3.0,
-10.0,  0.0, 10.0,
-3.0,  0.0,  3.0  };
#line 365
static const float Scharr_Y_M[9] = { 	-3.0,  -10.0,   -3.0,
0.0,   0.0,   0.0,
3.0, 10.0,  3.0  };
#line 369
float3 retValX, retValXM;
float3 retValY, retValYM;
#line 372
if(kernel == 0) {
retValX = Convolution::ThreeByThree(s, vpos, Prewitt_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Prewitt_Y, 1.0);
}
if(kernel == 1) {
retValX = Convolution::ThreeByThree(s, vpos, Prewitt_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Prewitt_Y, 1.0);
retValXM = Convolution::ThreeByThree(s, vpos, Prewitt_X_M, 1.0);
retValYM = Convolution::ThreeByThree(s, vpos, Prewitt_Y_M, 1.0);
retValX = max(retValX, retValXM);
retValY = max(retValY, retValYM);
}
if(kernel == 2) {
retValX = Convolution::ThreeByThree(s, vpos, Sobel_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Sobel_Y, 1.0);
}
if(kernel == 3) {
retValX = Convolution::ThreeByThree(s, vpos, Sobel_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Sobel_Y, 1.0);
retValXM = Convolution::ThreeByThree(s, vpos, Sobel_X_M, 1.0);
retValYM = Convolution::ThreeByThree(s, vpos, Sobel_Y_M, 1.0);
retValX = max(retValX, retValXM);
retValY = max(retValY, retValYM);
}
if(kernel == 4) {
retValX = Convolution::ThreeByThree(s, vpos, Scharr_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Scharr_Y, 1.0);
}
if(kernel == 5) {
retValX = Convolution::ThreeByThree(s, vpos, Scharr_X, 1.0);
retValY = Convolution::ThreeByThree(s, vpos, Scharr_Y, 1.0);
retValXM = Convolution::ThreeByThree(s, vpos, Scharr_X_M, 1.0);
retValYM = Convolution::ThreeByThree(s, vpos, Scharr_Y_M, 1.0);
retValX = max(retValX, retValXM);
retValY = max(retValY, retValYM);
}
#line 409
return Convolution::ConvReturn(retValX, retValY, type);
}
#line 412
float3 SimpleBlur(sampler s, int2 vpos, int size) {
float3 acc;
#line 415
size = clamp(size, 3, 14);
[unroll]
for(int m = 0; m < size; m++) {
[unroll]
for(int n = 0; n < size; n++) {
acc += tex2Dfetch(s, int2( (vpos.x - size / 3 + n), (vpos.y - size / 3 + m)), 0).rgb;
}
}
#line 424
return acc / (size * size);
}
}
#line 428
namespace Draw {
#line 430
float aastep(float threshold, float value)
{
float afwidth = length(float2(ddx(value), ddy(value)));
return smoothstep(threshold - afwidth, threshold + afwidth, value);
}
#line 436
float3 Point2(float3 texcolor, float3 pointcolor, float2 pointcoord, float2 texcoord, float power) {
return lerp(texcolor, pointcolor, saturate(exp(-power * length(texcoord - pointcoord))));
}
#line 440
float3 PointEXP(float3 texcolor, sctpoint p, float2 texcoord, float power) {
return lerp(texcolor, p.color, saturate(exp(-power * length(texcoord - p.coord))));
}
#line 444
float3 PointAASTEP(float3 texcolor, sctpoint p, float2 texcoord, float power) {
return lerp(p.color, texcolor, aastep(power, length(texcoord - p.coord)));
}
#line 448
float3 OverlaySampler(float3 image, sampler overlay, float scale, float2 texcoord, int2 offset, float opacity) {
float3 retVal;
float3 col = image;
float fac = 0.0;
#line 453
float2 coord_pix = float2(1920, 1018) * texcoord;
float2 overlay_size = (float2)tex2Dsize(overlay, 0) * scale;
float2 border_min = (float2)offset;
float2 border_max = border_min + overlay_size + 1;
#line 458
if( coord_pix.x <= border_max.x &&
coord_pix.y <= border_max.y &&
coord_pix.x >= border_min.x &&
coord_pix.y >= border_min.y   ) {
fac = opacity;
float2 coord_overlay = (coord_pix - border_min) / overlay_size;
col = tex2D(overlay, coord_overlay).rgb;
}
#line 467
return lerp(image, col, fac);
}
#line 470
}
#line 472
namespace Functions {
#line 474
float Map(float value, float2 span_old, float2 span_new) {
float span_old_diff;
if (abs(span_old.y - span_old.x) < 1e-6)
span_old_diff = 1e-6;
else
span_old_diff = span_old.y - span_old.x;
return lerp(span_new.x, span_new.y, (clamp(value, span_old.x, span_old.y)-span_old.x)/(span_old_diff));
}
#line 483
float Level(float value, float black, float white) {
value = clamp(value, black, white);
return Map(value, float2(black, white), float2(0.0, 1.0));
}
#line 488
float Posterize(float x, int numLevels, float continuity, float slope, int type) {
float stepheight = 1.0 / numLevels;
float stepnum = floor(x * numLevels);
float frc = frac(x * numLevels);
float step1 = floor(frc) * stepheight;
float step2;
#line 495
if(type == 1)
step2 = smoothstep(0.0, 1.0, frc) * stepheight;
else if(type == 2)
step2 = (1.0 / (1.0 + exp(-slope*(frc - 0.5)))) * stepheight;
else
step2 = frc * stepheight;
#line 502
return lerp(step1, step2, continuity) + stepheight * stepnum;
}
#line 505
float DiffEdges(sampler s, float2 texcoord)
{
float valC = dot(tex2D(s, texcoord).rgb, float3(0.2126, 0.7151, 0.0721));
float valN = dot(tex2D(s, texcoord + float2(0.0, -float2((1.0 / 1920), (1.0 / 1018)).y)).rgb, float3(0.2126, 0.7151, 0.0721));
float valNE = dot(tex2D(s, texcoord + float2(float2((1.0 / 1920), (1.0 / 1018)).x, -float2((1.0 / 1920), (1.0 / 1018)).y)).rgb, float3(0.2126, 0.7151, 0.0721));
float valE = dot(tex2D(s, texcoord + float2(float2((1.0 / 1920), (1.0 / 1018)).x, 0.0)).rgb, float3(0.2126, 0.7151, 0.0721));
float valSE = dot(tex2D(s, texcoord + float2(float2((1.0 / 1920), (1.0 / 1018)).x, float2((1.0 / 1920), (1.0 / 1018)).y)).rgb, float3(0.2126, 0.7151, 0.0721));
float valS = dot(tex2D(s, texcoord + float2(0.0, float2((1.0 / 1920), (1.0 / 1018)).y)).rgb, float3(0.2126, 0.7151, 0.0721));
float valSW = dot(tex2D(s, texcoord + float2(-float2((1.0 / 1920), (1.0 / 1018)).x, float2((1.0 / 1920), (1.0 / 1018)).y)).rgb, float3(0.2126, 0.7151, 0.0721));
float valW = dot(tex2D(s, texcoord + float2(-float2((1.0 / 1920), (1.0 / 1018)).x, 0.0)).rgb, float3(0.2126, 0.7151, 0.0721));
float valNW = dot(tex2D(s, texcoord + float2(-float2((1.0 / 1920), (1.0 / 1018)).x, -float2((1.0 / 1920), (1.0 / 1018)).y)).rgb, float3(0.2126, 0.7151, 0.0721));
#line 517
float diffNS = abs(valN - valS);
float diffWE = abs(valW - valE);
float diffNWSE = abs(valNW - valSE);
float diffSWNE = abs(valSW - valNE);
return saturate((diffNS + diffWE + diffNWSE + diffSWNE) * (1.0 - valC));
}
#line 524
float GetDepthBufferOutlines(float2 texcoord, int fading)
{
float depthC =  ReShade::GetLinearizedDepth(texcoord);
float depthN =  ReShade::GetLinearizedDepth(texcoord + float2(0.0, -float2((1.0 / 1920), (1.0 / 1018)).y));
float depthNE = ReShade::GetLinearizedDepth(texcoord + float2(float2((1.0 / 1920), (1.0 / 1018)).x, -float2((1.0 / 1920), (1.0 / 1018)).y));
float depthE =  ReShade::GetLinearizedDepth(texcoord + float2(float2((1.0 / 1920), (1.0 / 1018)).x, 0.0));
float depthSE = ReShade::GetLinearizedDepth(texcoord + float2(float2((1.0 / 1920), (1.0 / 1018)).x, float2((1.0 / 1920), (1.0 / 1018)).y));
float depthS =  ReShade::GetLinearizedDepth(texcoord + float2(0.0, float2((1.0 / 1920), (1.0 / 1018)).y));
float depthSW = ReShade::GetLinearizedDepth(texcoord + float2(-float2((1.0 / 1920), (1.0 / 1018)).x, float2((1.0 / 1920), (1.0 / 1018)).y));
float depthW =  ReShade::GetLinearizedDepth(texcoord + float2(-float2((1.0 / 1920), (1.0 / 1018)).x, 0.0));
float depthNW = ReShade::GetLinearizedDepth(texcoord + float2(-float2((1.0 / 1920), (1.0 / 1018)).x, -float2((1.0 / 1920), (1.0 / 1018)).y));
float diffNS = abs(depthN - depthS);
float diffWE = abs(depthW - depthE);
float diffNWSE = abs(depthNW - depthSE);
float diffSWNE = abs(depthSW - depthNE);
float outline = (diffNS + diffWE + diffNWSE + diffSWNE);
#line 541
if(fading == 1)
outline *= (1.0 - depthC);
else if(fading == 2)
outline *= depthC;
#line 546
return outline;
}
}
}
#line 41 "C:\Program Files\GShade\gshade-shaders\Shaders\AdaptiveTint.fx"
#line 50
uniform int iUIInfo<
ui_type = "combo";
ui_label = "Info";
ui_items = "Info\0";
ui_tooltip = "Enable Technique 'CalculateStats_MoveToTop'";
> = 0;
#line 57
uniform int iUIWhiteLevelFormula <
ui_type = "combo";
ui_category = "Curves";
ui_label = "White Level Curve (red)";
ui_items = "Linear: x * (value - y) + z\0Square: x * (value - y)^2 + z\0Cube: x * (value - y)^3 + z\0";
> = 1;
#line 64
uniform float3 f3UICurveWhiteParam <
ui_type = "slider";
ui_category = "Curves";
ui_label = "Curve Parameters";
ui_min = -10.0; ui_max = 10.0;
ui_step = 0.01;
> = float3(-0.5, 1.0, 1.0);
#line 72
uniform int iUIBlackLevelFormula <
ui_type = "combo";
ui_category = "Curves";
ui_label = "Black Level Curve (cyan)";
ui_items = "Linear: x * (value - y) + z\0Square: x * (value - y)^2 + z\0Cube: x * (value - y)^3 + z\0";
> = 1;
#line 79
uniform float3 f3UICurveBlackParam <
ui_type = "slider";
ui_category = "Curves";
ui_label = "Curve Parameters";
ui_min = -10.0; ui_max = 10.0;
ui_step = 0.01;
> = float3(0.5, 0.0, 0.0);
#line 87
uniform float fUIColorTempScaling <
ui_type = "slider";
ui_category = "Curves";
ui_label = "Color Temperature Scaling";
ui_min = 1.0; ui_max = 10.0;
ui_step = 0.01;
> = 2.0;
#line 95
uniform float fUISaturation <
ui_type = "slider";
ui_label = "Saturation";
ui_category = "Color";
ui_min = -1.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.0;
#line 103
uniform float3 fUITintWarm <
ui_type = "color";
ui_category = "Color";
ui_label = "Warm Tint";
> = float3(0.04, 0.04, 0.02);
#line 109
uniform float3 fUITintCold <
ui_type = "color";
ui_category = "Color";
ui_label = "Cold Tint";
> = float3(0.02, 0.04, 0.04);
#line 115
uniform float fUIStrength <
ui_type = "slider";
ui_category = "General";
ui_label = "Strength";
ui_min = 0.0; ui_max = 1.0;
> = 1.0;
#line 126
float2 CalculateLevels(float avgLuma) {
float2 level = float2(0.0, 0.0);
#line 129
if(iUIBlackLevelFormula == 2)
level.x = f3UICurveBlackParam.x * pow(avgLuma - f3UICurveBlackParam.y, 3) + f3UICurveBlackParam.z;
else if(iUIBlackLevelFormula == 1)
level.x = f3UICurveBlackParam.x * ((avgLuma - f3UICurveBlackParam.y) * 2) + f3UICurveBlackParam.z;
else
level.x = f3UICurveBlackParam.x * (avgLuma - f3UICurveBlackParam.y) + f3UICurveBlackParam.z;
#line 136
if(iUIWhiteLevelFormula == 2)
level.y = f3UICurveWhiteParam.x * pow(avgLuma - f3UICurveWhiteParam.y, 3) + f3UICurveWhiteParam.z;
else if(iUIWhiteLevelFormula == 1)
level.y = f3UICurveWhiteParam.x * ((avgLuma - f3UICurveWhiteParam.y) * 2) + f3UICurveWhiteParam.z;
else
level.y = f3UICurveWhiteParam.x * (avgLuma - f3UICurveWhiteParam.y) + f3UICurveWhiteParam.z;
#line 143
return saturate(level);
}
#line 146
float GetColorTemp(float2 texcoord) {
const float colorTemp = Stats::AverageColorTemp();
return Tools::Functions::Map(colorTemp * fUIColorTempScaling, float2(-0.5957, 0.5957), float2(0.0, 1.0));
}
#line 154
float3 AdaptiveTint_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
#line 159
const float3 backbuffer = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float3 lutWarm = fUITintWarm * backbuffer;
const float3 lutCold = fUITintCold * backbuffer;
#line 166
const float colorTemp = GetColorTemp(texcoord);
const float3 tint = lerp(lutCold, lutWarm, colorTemp);
#line 172
const float3 luma   = dot(backbuffer, float3(0.2126, 0.7151, 0.0721)).rrr;
const float2 levels = CalculateLevels(Stats::AverageLuma());
const float3 factor = Tools::Functions::Level(luma.r, levels.x, levels.y).rrr;
const float3 result = lerp(tint, lerp(luma, backbuffer, fUISaturation + 1.0), factor);
#line 181
return lerp(backbuffer, result, fUIStrength);
#line 183
}
#line 185
technique AdaptiveTint
{
pass {
VertexShader = PostProcessVS;
PixelShader = AdaptiveTint_PS;
}
}

