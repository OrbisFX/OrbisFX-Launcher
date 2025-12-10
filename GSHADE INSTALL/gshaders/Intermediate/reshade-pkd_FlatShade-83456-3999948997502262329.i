#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\pkd_FlatShade.fx"
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
#line 39 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\pkd_FlatShade.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\pkd_Color.fxh"
#line 29
namespace pkd {
#line 31
namespace Color {
namespace CIELAB {
#line 40
float __LAB1(float orig)
{
if (orig > 0.04045) {
return pow(abs((orig + 0.55) / 1.055), 2.4);
}
else {
return orig / 12.92;
}
}
#line 50
float __LAB2(float orig)
{
if (orig > 0.008856) {
return pow(abs(orig), 1.0/3);
}
else {
return (7.787 * orig) * 15.0 / 116.0;
}
}
#line 60
float __LAB3(float orig)
{
if (orig * orig * orig > 0.008856) {
return orig * orig * orig;
}
else {
return (orig - 16.0 / 116.0) / 7.787;
}
}
#line 70
float __LAB4(float orig)
{
if (orig > 0.0031308) {
return (1.055 * pow(abs(orig), 1 / 2.4) - 0.055);
}
else {
return 12.92 * orig;
}
}
#line 80
float3 RGB2LAB(float3 color)
{
float rt, gt, bt;
float x, y, z;
#line 85
rt = __LAB1(color.r);
gt = __LAB1(color.g);
bt = __LAB1(color.b);
#line 89
x = (rt * 0.4124 + gt * 0.3576 + bt * 0.1805) / 0.95047;
y = (rt * 0.2126 + gt * 0.7152 + bt * 0.0722) / 1.00000;
z = (rt * 0.0193 + gt * 0.1192 + bt * 0.9505) / 1.08883;
#line 93
x = __LAB2(x);
y = __LAB2(y);
z = __LAB2(z);
#line 97
return float3((116.0 * y) - 16, 500 * (x - y), 200 * (y - z));
}
#line 100
float3 LAB2RGB(float3 color)
{
float r, g, b;
#line 104
float y = (color.x + 16) / 116;
float x = color.y / 500 + y;
float z = y - color.z / 200;
#line 108
x = 0.95047 * __LAB3(x);
y = __LAB3(y);
z = 1.08883 * __LAB3(z);
#line 112
r = x *  3.2406 + y * -1.5372 + z * -0.4986;
g = x * -0.9689 + y *  1.8758 + z *  0.0415;
b = x *  0.0557 + y * -0.2040 + z *  1.0570;
#line 116
r = clamp(__LAB4(r), 0., 1.);
g = clamp(__LAB4(g), 0., 1.);
b = clamp(__LAB4(b), 0., 1.);
#line 120
return float3(r, g, b);
}
#line 123
float DeltaE(float3 lab1, float3 lab2)
{
const float3 delta = lab1 - lab2;
#line 127
const float c1 = sqrt(lab1.y * lab1.y * lab1.z * lab1.z);
const float c2 = sqrt(lab2.y * lab2.y * lab2.z * lab2.z);
#line 130
const float deltaC = c1 - c2;
float deltaH = delta.y * delta.y + delta.z * delta.z - deltaC * deltaC;
if (deltaH < 0) {
deltaH = 0;
}
else {
deltaH = sqrt(deltaH);
}
const float deltaCkcsc = deltaC / (1.0 + 0.045 * c1);
const float deltaHkhsh = deltaH / (1.0 + 0.015 * c1);
const float colorDelta = delta.x * delta.x + deltaCkcsc * deltaCkcsc + deltaHkhsh * deltaHkhsh;
if (colorDelta < 0) {
return 0;
}
else {
return sqrt(colorDelta);
}
}
}
#line 150
float DeltaRGB( in float3 RGB1, in float3 RGB2 )
{
return pkd::Color::CIELAB::DeltaE(pkd::Color::CIELAB::RGB2LAB(RGB1), pkd::Color::CIELAB::RGB2LAB(RGB2));
}
#line 155
float3 HUEToRGB( in float H )
{
return saturate( float3( abs( H * 6.0f - 3.0f ) - 1.0f,
2.0f - abs( H * 6.0f - 2.0f ),
2.0f - abs( H * 6.0f - 4.0f )));
}
#line 162
float3 RGBToHCV( in float3 RGB )
{
#line 165
float4 P;
if ( RGB.g < RGB.b ) {
P = float4( RGB.bg, -1.0f, 2.0f/3.0f );
}
else {
P = float4( RGB.gb, 0.0f, -1.0f/3.0f );
}
#line 173
float4 Q1;
if ( RGB.r < P.x ) {
Q1 = float4( P.xyw, RGB.r );
}
else {
Q1 = float4( RGB.r, P.yzx );
}
#line 181
const float C = Q1.x - min( Q1.w, Q1.y );
#line 183
return float3( abs(( Q1.w - Q1.y ) / ( 6.0f * C + 0.000001f ) + Q1.z ), C, Q1.x );
}
#line 186
float3 RGBToHSL( in float3 RGB )
{
RGB.xyz          = max( RGB.xyz, 0.000001f );
const float3 HCV       = RGBToHCV(RGB);
const float L          = HCV.z - HCV.y * 0.5f;
return float3( HCV.x, HCV.y / ( 1.0f - abs( L * 2.0f - 1.0f ) + 0.000001f), L );
}
#line 194
float3 HSLToRGB( in float3 HSL )
{
return ( HUEToRGB(HSL.x) - 0.5f ) * ((1.0f - abs(2.0f * HSL.z - 1.0f)) * HSL.y) + HSL.z;
}
#line 201
float3 RGBToHSV(float3 c)
{
const float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
#line 205
float4 p;
if (c.g < c.b) {
p = float4(c.bg, K.wz);
}
else {
p = float4(c.gb, K.xy);
}
#line 213
float4 q;
if (c.r < p.x) {
q = float4(p.xyw, c.r);
}
else {
q = float4(c.r, p.yzx);
}
#line 221
const float d = q.x - min(q.w, q.y);
const float e = 1.0e-10;
return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
#line 226
float3 HSVToRGB(float3 c)
{
const float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
return c.z * lerp(K.xxx, saturate(abs(frac(c.xxx + K.xyz) * 6.0 - K.www) - K.xxx), c.y);
}
}
#line 233
}
#line 40 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\pkd_FlatShade.fx"
#line 63
namespace pkd {
#line 65
namespace FlatShade {
#line 67
uniform int CFG_QUANT_ADJUSTORDER <
ui_type = "combo";
ui_category = "Flat Shading";
ui_items = "RGB then Luma\0Luma then RGB\0";
ui_label = "Order of Operations";
> = 0;
#line 74
uniform float CFG_QUANT_LUMALEVELS <
ui_type = "slider";
ui_category = "Flat Shading";
ui_label = "Luma Steps";
ui_tooltip = "The number of steps to use when quantizing the RGB values.";
ui_min = 2.0; ui_max = 64.0; ui_step = 1.0;
> = 4.0;
#line 82
uniform float CFG_QUANT_RGBLEVELS <
ui_type = "slider";
ui_category = "Flat Shading";
ui_label = "RGB Steps";
ui_tooltip = "The number of steps to use when quantizing the RGB values.";
ui_min = 2.0; ui_max = 64.0; ui_step = 1.0;
> = 10.0;
#line 90
uniform bool CFG_BACKGROUND_QUANT <
ui_label = "Isolate Background";
ui_category = "Flat Shading";
ui_tooltip = "Should the background be quantized separately from the foreground?";
> = false;
#line 96
uniform float CFG_FOREGROUND_LIMIT <
ui_type = "slider";
ui_category = "Flat Shading";
ui_tooltip = "How far back should the 'foreground' extend?";
ui_label = "Foreground Depth";
ui_min = 0; ui_max = 1.0; ui_step = 0.01;
> = 0.8;
#line 104
uniform float CFG_QUANT_LUMALEVELS_BACKGROUND <
ui_type = "slider";
ui_category = "Flat Shading";
ui_label = "Background Luma Steps";
ui_tooltip = "The number of steps to use when quantizing the RGB values.";
ui_min = 2.0; ui_max = 64.0; ui_step = 1.0;
> = 64.0;
#line 112
uniform float CFG_QUANT_RGBLEVELS_BACKGROUND <
ui_type = "slider";
ui_category = "Flat Shading";
ui_label = "Background RGB Steps";
ui_tooltip = "The number of steps to use when quantizing the RGB values of the background.";
ui_min = 2.0; ui_max = 64.0; ui_step = 1.0;
> = 64.0;
#line 120
uniform bool CFG_OUTLINE_ENABLED <
ui_category = "Outlines";
ui_label = "Draw outlines around objects.";
> = true;
#line 125
uniform float3 CFG_OUTLINE_COLOR <
ui_type = "color";
ui_label = "Outline Color";
ui_category = "Outlines";
> = float3(0.0, 0.0, 0.0);
#line 131
uniform float CFG_OUTLINE_OUTER_WIDTH <
ui_type = "slider";
ui_category = "Outlines";
ui_label = "Angular Difference Line Width";
ui_tooltip = "The width of the lines generally bordering the exterior of an object.";
ui_min = 0.0; ui_max = 3.0; ui_step = 1.0;
> = 3.0;
#line 139
uniform float CFG_OUTLINE_INNER_WIDTH <
ui_type = "slider";
ui_category = "Outlines";
ui_label = "Mesh Boundary Width";
ui_tooltip = "The width of the lines usually within an object's borders.";
ui_min = 0.0; ui_max = 3.0; ui_step = 1.0;
> = 1.0;
#line 147
uniform int CFG_OUTLINE_FALLOFF <
ui_type = "combo";
ui_category = "Outlines";
ui_items = "No falloff.\0Fade out lines\0Thin lines\0Fadeout and thin lines\0";
ui_label = "Outline Falloff Type";
> = 0;
#line 154
uniform float CFG_OUTLINE_DEPTH_BOUNDARY_START <
ui_type = "slider";
ui_category = "Outlines";
ui_label = "Boundary for where depth falloff begins.";
ui_min = 0.1; ui_max = 1.0; ui_step = 0.01;
> = 0.4;
#line 161
uniform float CFG_OUTLINE_DEPTH_BOUNDARY_END <
ui_type = "slider";
ui_category = "Outlines";
ui_label = "Boundary for where depth falloff ends and outlines vanish entirely.";
ui_min = 0.1; ui_max = 1.0; ui_step = 0.01;
> = 0.9;
#line 168
float SegmentedValue(float v, float level)
{
const float stepval = (64.0 / level);
return (trunc((v * 100) / stepval) * stepval) / 100;
}
#line 174
float3 QuantizeLuma(float3 originalRGB, float levels)
{
const float3 hsl = pkd::Color::RGBToHSL(originalRGB);
#line 178
return pkd::Color::HSLToRGB(float3(hsl.x, hsl.y, SegmentedValue(hsl.z, levels)));
}
#line 181
float3 QuantizeRGB(float3 orig, float levels)
{
const float grayscale = max(orig.r, max(orig.g, orig.b));
#line 185
const float lower = floor(grayscale * levels) / levels;
#line 187
float delta;
if (abs(grayscale - lower))
delta = lower;
else
delta = ceil(grayscale * levels) / levels;
#line 193
return orig.rgb * (delta / grayscale);
}
#line 196
float3 PS_Quantize(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float4 orig = tex2D(ReShade::BackBuffer, texcoord);
#line 200
float rgblevels = CFG_QUANT_RGBLEVELS;
float lumalevels = CFG_QUANT_LUMALEVELS;
if (CFG_BACKGROUND_QUANT && (ReShade::GetLinearizedDepth(texcoord) >= CFG_FOREGROUND_LIMIT))
{
lumalevels = CFG_QUANT_LUMALEVELS_BACKGROUND;
rgblevels = CFG_QUANT_RGBLEVELS_BACKGROUND;
}
#line 208
float3 final;
#line 210
if (CFG_QUANT_ADJUSTORDER == 0) {
final = QuantizeLuma(QuantizeRGB(orig.rgb, rgblevels), lumalevels);
}
else {
final = QuantizeRGB(QuantizeLuma(orig.rgb, lumalevels), rgblevels);
}
#line 217
return final;
}
#line 221
float MeshEdges(float depthC, float4 depth1, float4 depth2) {
float depthCenter = depthC;
float4 depthCardinal = float4(depth1.x, depth2.x, depth1.z, depth2.z);
float4 depthInterCardinal = float4(depth1.y, depth2.y, depth1.w, depth2.w);
#line 226
const float2 mind = float2(min(depthCardinal.x, min(depthCardinal.y, min(depthCardinal.z, depthCardinal.w))), min(depthInterCardinal.x, min(depthInterCardinal.y, min(depthInterCardinal.z, depthInterCardinal.w))));
const float2 maxd = float2(max(depthCardinal.x, max(depthCardinal.y, max(depthCardinal.z, depthCardinal.w))), max(depthInterCardinal.x, max(depthInterCardinal.y, max(depthInterCardinal.z, depthInterCardinal.w))));
const float span = max(maxd.x, maxd.y) - min(mind.x, mind.y) + 0.00001;
#line 231
depthCenter /= span;
depthCardinal /= span;
depthInterCardinal /= span;
#line 235
const float4 diffsCardinal = abs(depthCardinal - depthCenter);
const float4 diffsInterCardinal = abs(depthInterCardinal - depthCenter);
#line 238
const float2 meshEdge = float2(
max(abs(diffsCardinal.x - diffsCardinal.y), abs(diffsCardinal.z - diffsCardinal.w)),
max(abs(diffsInterCardinal.x - diffsInterCardinal.y), abs(diffsInterCardinal.z - diffsInterCardinal.w))
);
#line 252
return max(float2(
max(abs(diffsCardinal.x - diffsCardinal.y), abs(diffsCardinal.z - diffsCardinal.w)),
max(abs(diffsInterCardinal.x - diffsInterCardinal.y), abs(diffsInterCardinal.z - diffsInterCardinal.w)))
.x, float2(
max(abs(diffsCardinal.x - diffsCardinal.y), abs(diffsCardinal.z - diffsCardinal.w)),
max(abs(diffsInterCardinal.x - diffsInterCardinal.y), abs(diffsInterCardinal.z - diffsInterCardinal.w)))
#line 246
.y);
}
#line 250
float StrengthCurve(float3 fade, float depth) {
return smoothstep(0.0, 1.0 - fade.z, depth + (0.2 - 1.2 * fade.x)) * smoothstep(0.0, 1.0 - fade.z, 1.0 - depth + (1.2 * fade.y - 1.0));
}
#line 255
float3 PS_Outline(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float2 pixelSize = ReShade::GetPixelSize();
const float4 color = tex2D(ReShade::BackBuffer, texcoord);
#line 260
if (!CFG_OUTLINE_ENABLED) {
return color.rgb;
}
#line 264
float centerDepth = ReShade::GetLinearizedDepth(texcoord);
float4 depth1[3];
float4 depth2[3];
float alpha = 1.0;
#line 269
float outerWidth = clamp(CFG_OUTLINE_OUTER_WIDTH, 1.0, 3);
float innerWidth = clamp(CFG_OUTLINE_INNER_WIDTH, 1.0, 3);
#line 272
if (CFG_OUTLINE_FALLOFF == 1 || CFG_OUTLINE_FALLOFF == 3)
{
alpha = 1.0 - smoothstep(CFG_OUTLINE_DEPTH_BOUNDARY_START, CFG_OUTLINE_DEPTH_BOUNDARY_END, centerDepth);
}
else if (CFG_OUTLINE_FALLOFF == 2 || CFG_OUTLINE_FALLOFF == 3)
{
if (centerDepth >= CFG_OUTLINE_DEPTH_BOUNDARY_START) {
if (centerDepth <= CFG_OUTLINE_DEPTH_BOUNDARY_END) {
outerWidth = 1.0;
innerWidth = 0.0;
}
else {
outerWidth = 0.0;
innerWidth = 0.0;
}
}
}
#line 290
bool drawLine = false;
const int maxWidth = max(outerWidth, innerWidth);
#line 293
if (maxWidth > 0.0) {
[unroll]
for(int i = 0; i < maxWidth; i++)
{
depth1[i] = float4(
ReShade::GetLinearizedDepth(texcoord+(i+1.0) * float2(0.0, -pixelSize.y)),
ReShade::GetLinearizedDepth(texcoord+(i+1.0) * float2(pixelSize.x, -pixelSize.y)),
ReShade::GetLinearizedDepth(texcoord+(i+1.0) * float2(pixelSize.x, 0.0)),
ReShade::GetLinearizedDepth(texcoord+(i+1.0) * float2(pixelSize.x, pixelSize.y))
);
depth2[i]  = float4(
ReShade::GetLinearizedDepth(texcoord+(i+1.0) * float2(0.0, pixelSize.y)),
ReShade::GetLinearizedDepth(texcoord+(i+1.0) * float2(-pixelSize.x, pixelSize.y)),
ReShade::GetLinearizedDepth(texcoord+(i+1.0) * float2(-pixelSize.x, 0.0)),
ReShade::GetLinearizedDepth(texcoord+(i+1.0) * float2(-pixelSize.x, -pixelSize.y))
);
}
#line 311
const float threshhold = 22.0 / 1000.0;
#line 313
[unroll]
for (int i = 0; i < CFG_OUTLINE_OUTER_WIDTH; i++)
{
const float max1 = max(depth1[i].x, max(depth1[i].y, max(depth1[i].z, depth1[i].w)));
const float min1 = min(depth1[i].x, min(depth1[i].y, min(depth1[i].z, depth1[i].w)));
const float max2 = max(depth2[i].x, max(depth2[i].y, max(depth2[i].z, depth2[i].w)));
const float min2 = min(depth2[i].x, min(depth2[i].y, min(depth2[i].z, depth2[i].w)));
#line 321
if (max(max1, max2) - min(min1, min2) >= threshhold )
{
drawLine = true;
}
}
#line 327
[unroll]
for (int i = 0; i < CFG_OUTLINE_INNER_WIDTH; i++)
{
if ((pow(abs(saturate(MeshEdges(centerDepth, depth1[i], depth2[i]))), 3.0) * 3.0) * StrengthCurve(float3(-1.0, 0.2, 0.8), centerDepth) >= 0.90)
{
drawLine = true;
}
}
}
#line 337
if (drawLine)
{
return lerp(color.rgb, CFG_OUTLINE_COLOR, alpha);
}
else {
return color.rgb;
}
}
#line 346
technique pkd_FlatShade < ui_tooltip = "Reduces the colors of an image in a manner suitable to make a 'flat-shaded' comic-style image."; >
{
pass Quantize
{
VertexShader = PostProcessVS;
PixelShader = PS_Quantize;
}
#line 354
pass Outline
{
VertexShader = PostProcessVS;
PixelShader = PS_Outline;
}
}
}
}

