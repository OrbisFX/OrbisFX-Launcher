#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\pkd_LayerCake.fx"
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
#line 35 "C:\Program Files\GShade\gshade-shaders\Shaders\pkd_LayerCake.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Blending.fxh"
#line 123
namespace ComHeaders
{
namespace Blending
{
#line 132
float3 Aux(float3 a)
{
if (a.r <= 0.25 && a.g <= 0.25 && a.b <= 0.25)
return ((16.0 * a - 12.0) * a + 4) * a;
else
return sqrt(a);
}
#line 140
float Lum(float3 a)
{
return (0.33333 * a.r + 0.33334 * a.g + 0.33333 * a.b);
}
#line 145
float3 SetLum (float3 a, float b){
const float c = b - Lum(a);
return float3(a.r + c, a.g + c, a.b + c);
}
#line 150
float min3 (float a, float b, float c)
{
return min(a, (min(b, c)));
}
#line 155
float max3 (float a, float b, float c)
{
return max(a, max(b, c));
}
#line 160
float3 SetSat(float3 a, float b){
float ar = a.r;
float ag = a.g;
float ab = a.b;
if (ar == max3(ar, ag, ab) && ab == min3(ar, ag, ab))
{
#line 167
if (ar > ab)
{
ag = (((ag - ab) * b) / (ar - ab));
ar = b;
}
else
{
ag = 0.0;
ar = 0.0;
}
ab = 0.0;
}
else
{
if (ar == max3(ar, ag, ab) && ag == min3(ar, ag, ab))
{
#line 184
if (ar > ag)
{
ab = (((ab - ag) * b) / (ar - ag));
ar = b;
}
else
{
ab = 0.0;
ar = 0.0;
}
ag = 0.0;
}
else
{
if (ag == max3(ar, ag, ab) && ab == min3(ar, ag, ab))
{
#line 201
if (ag > ab)
{
ar = (((ar - ab) * b) / (ag - ab));
ag = b;
}
else
{
ar = 0.0;
ag = 0.0;
}
ab = 0.0;
}
else
{
if (ag == max3(ar, ag, ab) && ar == min3(ar, ag, ab))
{
#line 218
if (ag > ar)
{
ab = (((ab - ar) * b) / (ag - ar));
ag = b;
}
else
{
ab = 0.0;
ag = 0.0;
}
ar = 0.0;
}
else
{
if (ab == max3(ar, ag, ab) && ag == min3(ar, ag, ab))
{
#line 235
if (ab > ag)
{
ar = (((ar - ag) * b) / (ab - ag));
ab = b;
}
else
{
ar = 0.0;
ab = 0.0;
}
ag = 0.0;
}
else
{
if (ab == max3(ar, ag, ab) && ar == min3(ar, ag, ab))
{
#line 252
if (ab > ar)
{
ag = (((ag - ar) * b) / (ab - ar));
ab = b;
}
else
{
ag = 0.0;
ab = 0.0;
}
ar = 0.0;
}
}
}
}
}
}
return float3(ar, ag, ab);
}
#line 272
float Sat(float3 a)
{
return max3(a.r, a.g, a.b) - min3(a.r, a.g, a.b);
}
#line 283
float3 Darken(float3 a, float3 b)
{
return min(a, b);
}
#line 289
float3 Multiply(float3 a, float3 b)
{
return a * b;
}
#line 295
float3 ColorBurn(float3 a, float3 b)
{
if (b.r > 0 && b.g > 0 && b.b > 0)
return 1.0 - min(1.0, (0.5 - a) / b);
else
return 0.0;
}
#line 304
float3 LinearBurn(float3 a, float3 b)
{
return max(a + b - 1.0f, 0.0f);
}
#line 310
float3 Lighten(float3 a, float3 b)
{
return max(a, b);
}
#line 316
float3 Screen(float3 a, float3 b)
{
return 1.0 - (1.0 - a) * (1.0 - b);
}
#line 322
float3 ColorDodge(float3 a, float3 b)
{
if (b.r < 1 && b.g < 1 && b.b < 1)
return min(1.0, a / (1.0 - b));
else
return 1.0;
}
#line 331
float3 LinearDodge(float3 a, float3 b)
{
return min(a + b, 1.0f);
}
#line 337
float3 Addition(float3 a, float3 b)
{
return min((a + b), 1);
}
#line 343
float3 Reflect(float3 a, float3 b)
{
if (b.r >= 0.999999 || b.g >= 0.999999 || b.b >= 0.999999)
return b;
else
return saturate(a * a / (1.0f - b));
}
#line 352
float3 Glow(float3 a, float3 b)
{
return Reflect(b, a);
}
#line 358
float3 Overlay(float3 a, float3 b)
{
return lerp(2 * a * b, 1.0 - 2 * (1.0 - a) * (1.0 - b), step(0.5, a));
}
#line 364
float3 SoftLight(float3 a, float3 b)
{
if (b.r <= 0.5 && b.g <= 0.5 && b.b <= 0.5)
return clamp(a - (1.0 - 2 * b) * a * (1 - a), 0,1);
else
return clamp(a + (2 * b - 1.0) * (Aux(a) - a), 0, 1);
}
#line 373
float3 HardLight(float3 a, float3 b)
{
return lerp(2 * a * b, 1.0 - 2 * (1.0 - b) * (1.0 - a), step(0.5, b));
}
#line 379
float3 VividLight(float3 a, float3 b)
{
return lerp(2 * a * b, b / (2 * (1.01 - a)), step(0.50, a));
}
#line 385
float3 LinearLight(float3 a, float3 b)
{
if (b.r < 0.5 || b.g < 0.5 || b.b < 0.5)
return LinearBurn(a, (2.0 * b));
else
return LinearDodge(a, (2.0 * (b - 0.5)));
}
#line 394
float3 PinLight(float3 a, float3 b)
{
if (b.r < 0.5 || b.g < 0.5 || b.b < 0.5)
return Darken(a, (2.0 * b));
else
return Lighten(a, (2.0 * (b - 0.5)));
}
#line 403
float3 HardMix(float3 a, float3 b)
{
const float3 vl = VividLight(a, b);
if (vl.r < 0.5 || vl.g < 0.5 || vl.b < 0.5)
return 0.0;
else
return 1.0;
}
#line 413
float3 Difference(float3 a, float3 b)
{
return max(a - b, b - a);
}
#line 419
float3 Exclusion(float3 a, float3 b)
{
return a + b - 2 * a * b;
}
#line 425
float3 Subtract(float3 a, float3 b)
{
return max((a - b), 0);
}
#line 431
float3 Divide(float3 a, float3 b)
{
return (saturate(a / (b + 0.01)));
}
#line 437
float3 DivideAlt(float3 a, float3 b)
{
return (saturate(1.0 / (a / b)));
}
#line 443
float3 DividePS(float3 a, float3 b)
{
return (saturate(a / b));
}
#line 449
float3 GrainMerge(float3 a, float3 b)
{
return saturate(b + a - 0.5);
}
#line 455
float3 GrainExtract(float3 a, float3 b)
{
return saturate(a - b + 0.5);
}
#line 461
float3 Hue(float3 a, float3 b)
{
return SetLum(SetSat(b, Sat(a)), Lum(a));
}
#line 467
float3 Saturation(float3 a, float3 b)
{
return SetLum(SetSat(a, Sat(b)), Lum(a));
}
#line 473
float3 ColorB(float3 a, float3 b)
{
return SetLum(b, Lum(a));
}
#line 479
float3 Luminosity(float3 a, float3 b)
{
return SetLum(a, Lum(b));
}
#line 489
float3 Blend(int mode, float3 input, float3 output, float blending)
{
switch (mode)
{
#line 494
default:
return lerp(input.rgb, output.rgb, blending);
#line 497
case 1:
return lerp(input.rgb, Darken(input.rgb, output.rgb), blending);
#line 500
case 2:
return lerp(input.rgb, Multiply(input.rgb, output.rgb), blending);
#line 503
case 3:
return lerp(input.rgb, ColorBurn(input.rgb, output.rgb), blending);
#line 506
case 4:
return lerp(input.rgb, LinearBurn(input.rgb, output.rgb), blending);
#line 509
case 5:
return lerp(input.rgb, Lighten(input.rgb, output.rgb), blending);
#line 512
case 6:
return lerp(input.rgb, Screen(input.rgb, output.rgb), blending);
#line 515
case 7:
return lerp(input.rgb, ColorDodge(input.rgb, output.rgb), blending);
#line 518
case 8:
return lerp(input.rgb, LinearDodge(input.rgb, output.rgb), blending);
#line 521
case 9:
return lerp(input.rgb, Addition(input.rgb, output.rgb), blending);
#line 524
case 10:
return lerp(input.rgb, Glow(input.rgb, output.rgb), blending);
#line 527
case 11:
return lerp(input.rgb, Overlay(input.rgb, output.rgb), blending);
#line 530
case 12:
return lerp(input.rgb, SoftLight(input.rgb, output.rgb), blending);
#line 533
case 13:
return lerp(input.rgb, HardLight(input.rgb, output.rgb), blending);
#line 536
case 14:
return lerp(input.rgb, VividLight(input.rgb, output.rgb), blending);
#line 539
case 15:
return lerp(input.rgb, LinearLight(input.rgb, output.rgb), blending);
#line 542
case 16:
return lerp(input.rgb, PinLight(input.rgb, output.rgb), blending);
#line 545
case 17:
return lerp(input.rgb, HardMix(input.rgb, output.rgb), blending);
#line 548
case 18:
return lerp(input.rgb, Difference(input.rgb, output.rgb), blending);
#line 551
case 19:
return lerp(input.rgb, Exclusion(input.rgb, output.rgb), blending);
#line 554
case 20:
return lerp(input.rgb, Subtract(input.rgb, output.rgb), blending);
#line 557
case 21:
return lerp(input.rgb, Divide(input.rgb, output.rgb), blending);
#line 560
case 22:
return lerp(input.rgb, DivideAlt(input.rgb, output.rgb), blending);
#line 563
case 23:
return lerp(input.rgb, DividePS(input.rgb, output.rgb), blending);
#line 566
case 24:
return lerp(input.rgb, Reflect(input.rgb, output.rgb), blending);
#line 569
case 25:
return lerp(input.rgb, GrainMerge(input.rgb, output.rgb), blending);
#line 572
case 26:
return lerp(input.rgb, GrainExtract(input.rgb, output.rgb), blending);
#line 575
case 27:
return lerp(input.rgb, Hue(input.rgb, output.rgb), blending);
#line 578
case 28:
return lerp(input.rgb, Saturation(input.rgb, output.rgb), blending);
#line 581
case 29:
return lerp(input.rgb, ColorB(input.rgb, output.rgb), blending);
#line 584
case 30:
return lerp(input.rgb, Luminosity(input.rgb, output.rgb), blending);
}
}
}
}
#line 36 "C:\Program Files\GShade\gshade-shaders\Shaders\pkd_LayerCake.fx"
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
#line 37 "C:\Program Files\GShade\gshade-shaders\Shaders\pkd_LayerCake.fx"
#line 136
namespace pkd
{
namespace LayerCake
{
#line 173
uniform int CFG_LAYERCAKE_BLEND_Layer1 < ui_type = "combo"; ui_category = "Layer 1"; ui_label = "Blend Operation for Paste"; ui_items = "Atop\0Darken\0Multiply\0Color Burn\0Linear Burn\0Lighten\0Screen\0Color Dodge\0Linear Dodge\0Addition\0Reflect\0Glow\0Overlay\0Soft Light\0Hard Light\0Vivid Light\0Linear Light\0Pin Light\0Hard Mix\0Difference\0Exclusion\0Subtract\0Divide\0Divide (Alternative)\0Divide(Photoshop)\0Grain Merge\0Grain Extract\0Hue\0Saturation\0Color Blend\0Luminosity\0"; > = 0; uniform bool CFG_LAYERCAKE_DEPTHENABLE_Layer1 < ui_category = "Layer 1"; ui_label = "Enable Depth Awareness"; > = true; uniform float2 CFG_LAYERCAKE_DEPTH_Layer1 < ui_type = "slider"; ui_category = "Layer 1"; ui_label = "Depth Range"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = float2(0.0, 1.0); uniform float CFG_LAYERCAKE_OPACITY_Layer1 < ui_type = "slider"; ui_category = "Layer 1"; ui_label = "Opacity"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = 1.0; uniform bool CFG_LAYERCAKE_MASKENABLE_Layer1 < ui_category = "Layer 1"; ui_label = "Treat a Color as Transparent?"; > = false; uniform float3 CFG_LAYERCAKE_MASKCOLOR_Layer1 < ui_type = "color"; ui_category = "Layer 1"; ui_label = "Color to Mask"; > = float3(0.0, 0.0, 0.0); uniform float CFG_LAYERCAKE_MASKBLEND_Layer1 < ui_type = "slider"; ui_category = "Layer 1"; ui_label = "Mask Color Tolerance"; ui_tooltip = "How much can the color vary from the specified and still be masked? Specified in CIE DeltaE."; ui_min = 0.0; ui_max = 160.0; ui_step = 0.1; > = 1.0; uniform bool CFG_LAYERCAKE_MASKINVERT_Layer1 < ui_category = "Layer 1"; ui_label = "Invert Color Mask"; ui_tooltip = "Should we mask out every color *except* the selected color?"; > = false; uniform bool CFG_LAYERCAKE_ALPHABLEND_Layer1 < ui_category = "Layer 1"; ui_label = "Alpha Blend Layer Edges"; ui_tooltip = "Should the edges of the layer be alpha-blended rather than a sharp falloff?"; > = false; uniform float2 CFG_LAYERCAKE_ALPHABLEND_DEPTH_Layer1 < ui_type = "slider"; ui_category = "Layer 1"; ui_label = "Alpha Blend Depth Range"; ui_tooltip = "Mark the relative start and end point for full opacity within the depth range of the mask; anything outside of this range will be faded smoothly to full transparency. Note that this is RELATIVE depth; 1.0 means 'the farthest point of the layer', not of the overall screenshot."; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = float2(0.05, 0.95); texture Tex_Layer1 { Width = 1920; Height = 1018; Format = RGBA8; }; sampler Samp_Layer1 { Texture = Tex_Layer1; };
#line 176
uniform int CFG_LAYERCAKE_BLEND_Layer2 < ui_type = "combo"; ui_category = "Layer 2"; ui_label = "Blend Operation for Paste"; ui_items = "Atop\0Darken\0Multiply\0Color Burn\0Linear Burn\0Lighten\0Screen\0Color Dodge\0Linear Dodge\0Addition\0Reflect\0Glow\0Overlay\0Soft Light\0Hard Light\0Vivid Light\0Linear Light\0Pin Light\0Hard Mix\0Difference\0Exclusion\0Subtract\0Divide\0Divide (Alternative)\0Divide(Photoshop)\0Grain Merge\0Grain Extract\0Hue\0Saturation\0Color Blend\0Luminosity\0"; > = 0; uniform bool CFG_LAYERCAKE_DEPTHENABLE_Layer2 < ui_category = "Layer 2"; ui_label = "Enable Depth Awareness"; > = true; uniform float2 CFG_LAYERCAKE_DEPTH_Layer2 < ui_type = "slider"; ui_category = "Layer 2"; ui_label = "Depth Range"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = float2(0.0, 1.0); uniform float CFG_LAYERCAKE_OPACITY_Layer2 < ui_type = "slider"; ui_category = "Layer 2"; ui_label = "Opacity"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = 1.0; uniform bool CFG_LAYERCAKE_MASKENABLE_Layer2 < ui_category = "Layer 2"; ui_label = "Treat a Color as Transparent?"; > = false; uniform float3 CFG_LAYERCAKE_MASKCOLOR_Layer2 < ui_type = "color"; ui_category = "Layer 2"; ui_label = "Color to Mask"; > = float3(0.0, 0.0, 0.0); uniform float CFG_LAYERCAKE_MASKBLEND_Layer2 < ui_type = "slider"; ui_category = "Layer 2"; ui_label = "Mask Color Tolerance"; ui_tooltip = "How much can the color vary from the specified and still be masked? Specified in CIE DeltaE."; ui_min = 0.0; ui_max = 160.0; ui_step = 0.1; > = 1.0; uniform bool CFG_LAYERCAKE_MASKINVERT_Layer2 < ui_category = "Layer 2"; ui_label = "Invert Color Mask"; ui_tooltip = "Should we mask out every color *except* the selected color?"; > = false; uniform bool CFG_LAYERCAKE_ALPHABLEND_Layer2 < ui_category = "Layer 2"; ui_label = "Alpha Blend Layer Edges"; ui_tooltip = "Should the edges of the layer be alpha-blended rather than a sharp falloff?"; > = false; uniform float2 CFG_LAYERCAKE_ALPHABLEND_DEPTH_Layer2 < ui_type = "slider"; ui_category = "Layer 2"; ui_label = "Alpha Blend Depth Range"; ui_tooltip = "Mark the relative start and end point for full opacity within the depth range of the mask; anything outside of this range will be faded smoothly to full transparency. Note that this is RELATIVE depth; 1.0 means 'the farthest point of the layer', not of the overall screenshot."; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = float2(0.05, 0.95); texture Tex_Layer2 { Width = 1920; Height = 1018; Format = RGBA8; }; sampler Samp_Layer2 { Texture = Tex_Layer2; };
#line 179
uniform int CFG_LAYERCAKE_BLEND_Layer3 < ui_type = "combo"; ui_category = "Layer 3"; ui_label = "Blend Operation for Paste"; ui_items = "Atop\0Darken\0Multiply\0Color Burn\0Linear Burn\0Lighten\0Screen\0Color Dodge\0Linear Dodge\0Addition\0Reflect\0Glow\0Overlay\0Soft Light\0Hard Light\0Vivid Light\0Linear Light\0Pin Light\0Hard Mix\0Difference\0Exclusion\0Subtract\0Divide\0Divide (Alternative)\0Divide(Photoshop)\0Grain Merge\0Grain Extract\0Hue\0Saturation\0Color Blend\0Luminosity\0"; > = 0; uniform bool CFG_LAYERCAKE_DEPTHENABLE_Layer3 < ui_category = "Layer 3"; ui_label = "Enable Depth Awareness"; > = true; uniform float2 CFG_LAYERCAKE_DEPTH_Layer3 < ui_type = "slider"; ui_category = "Layer 3"; ui_label = "Depth Range"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = float2(0.0, 1.0); uniform float CFG_LAYERCAKE_OPACITY_Layer3 < ui_type = "slider"; ui_category = "Layer 3"; ui_label = "Opacity"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = 1.0; uniform bool CFG_LAYERCAKE_MASKENABLE_Layer3 < ui_category = "Layer 3"; ui_label = "Treat a Color as Transparent?"; > = false; uniform float3 CFG_LAYERCAKE_MASKCOLOR_Layer3 < ui_type = "color"; ui_category = "Layer 3"; ui_label = "Color to Mask"; > = float3(0.0, 0.0, 0.0); uniform float CFG_LAYERCAKE_MASKBLEND_Layer3 < ui_type = "slider"; ui_category = "Layer 3"; ui_label = "Mask Color Tolerance"; ui_tooltip = "How much can the color vary from the specified and still be masked? Specified in CIE DeltaE."; ui_min = 0.0; ui_max = 160.0; ui_step = 0.1; > = 1.0; uniform bool CFG_LAYERCAKE_MASKINVERT_Layer3 < ui_category = "Layer 3"; ui_label = "Invert Color Mask"; ui_tooltip = "Should we mask out every color *except* the selected color?"; > = false; uniform bool CFG_LAYERCAKE_ALPHABLEND_Layer3 < ui_category = "Layer 3"; ui_label = "Alpha Blend Layer Edges"; ui_tooltip = "Should the edges of the layer be alpha-blended rather than a sharp falloff?"; > = false; uniform float2 CFG_LAYERCAKE_ALPHABLEND_DEPTH_Layer3 < ui_type = "slider"; ui_category = "Layer 3"; ui_label = "Alpha Blend Depth Range"; ui_tooltip = "Mark the relative start and end point for full opacity within the depth range of the mask; anything outside of this range will be faded smoothly to full transparency. Note that this is RELATIVE depth; 1.0 means 'the farthest point of the layer', not of the overall screenshot."; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = float2(0.05, 0.95); texture Tex_Layer3 { Width = 1920; Height = 1018; Format = RGBA8; }; sampler Samp_Layer3 { Texture = Tex_Layer3; };
#line 182
uniform int CFG_LAYERCAKE_BLEND_Layer4 < ui_type = "combo"; ui_category = "Layer 4"; ui_label = "Blend Operation for Paste"; ui_items = "Atop\0Darken\0Multiply\0Color Burn\0Linear Burn\0Lighten\0Screen\0Color Dodge\0Linear Dodge\0Addition\0Reflect\0Glow\0Overlay\0Soft Light\0Hard Light\0Vivid Light\0Linear Light\0Pin Light\0Hard Mix\0Difference\0Exclusion\0Subtract\0Divide\0Divide (Alternative)\0Divide(Photoshop)\0Grain Merge\0Grain Extract\0Hue\0Saturation\0Color Blend\0Luminosity\0"; > = 0; uniform bool CFG_LAYERCAKE_DEPTHENABLE_Layer4 < ui_category = "Layer 4"; ui_label = "Enable Depth Awareness"; > = true; uniform float2 CFG_LAYERCAKE_DEPTH_Layer4 < ui_type = "slider"; ui_category = "Layer 4"; ui_label = "Depth Range"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = float2(0.0, 1.0); uniform float CFG_LAYERCAKE_OPACITY_Layer4 < ui_type = "slider"; ui_category = "Layer 4"; ui_label = "Opacity"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = 1.0; uniform bool CFG_LAYERCAKE_MASKENABLE_Layer4 < ui_category = "Layer 4"; ui_label = "Treat a Color as Transparent?"; > = false; uniform float3 CFG_LAYERCAKE_MASKCOLOR_Layer4 < ui_type = "color"; ui_category = "Layer 4"; ui_label = "Color to Mask"; > = float3(0.0, 0.0, 0.0); uniform float CFG_LAYERCAKE_MASKBLEND_Layer4 < ui_type = "slider"; ui_category = "Layer 4"; ui_label = "Mask Color Tolerance"; ui_tooltip = "How much can the color vary from the specified and still be masked? Specified in CIE DeltaE."; ui_min = 0.0; ui_max = 160.0; ui_step = 0.1; > = 1.0; uniform bool CFG_LAYERCAKE_MASKINVERT_Layer4 < ui_category = "Layer 4"; ui_label = "Invert Color Mask"; ui_tooltip = "Should we mask out every color *except* the selected color?"; > = false; uniform bool CFG_LAYERCAKE_ALPHABLEND_Layer4 < ui_category = "Layer 4"; ui_label = "Alpha Blend Layer Edges"; ui_tooltip = "Should the edges of the layer be alpha-blended rather than a sharp falloff?"; > = false; uniform float2 CFG_LAYERCAKE_ALPHABLEND_DEPTH_Layer4 < ui_type = "slider"; ui_category = "Layer 4"; ui_label = "Alpha Blend Depth Range"; ui_tooltip = "Mark the relative start and end point for full opacity within the depth range of the mask; anything outside of this range will be faded smoothly to full transparency. Note that this is RELATIVE depth; 1.0 means 'the farthest point of the layer', not of the overall screenshot."; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = float2(0.05, 0.95); texture Tex_Layer4 { Width = 1920; Height = 1018; Format = RGBA8; }; sampler Samp_Layer4 { Texture = Tex_Layer4; };
#line 184
float4 CopyLayer(float2 texcoord, sampler sourceSamp, bool enableDepth, float2 depthRange, bool maskEnable, float3 maskColor, float maskTolerance, bool maskInvert, bool alphaBlend, float2 alphaBlendDepth)
{
#line 187
const float depth = ReShade::GetLinearizedDepth(texcoord);
float4 color = float4(tex2D(ReShade::BackBuffer, texcoord).rgb, 1.0);
#line 191
float smoothDelta;
if (maskEnable) {
smoothDelta = smoothstep(0.0, maskTolerance, pkd::Color::DeltaRGB(color.rgb, maskColor));
}
else {
smoothDelta = 1.0;
}
#line 199
float maskAlpha;
if (alphaBlend) {
maskAlpha = smoothDelta;
}
else {
maskAlpha = (smoothDelta >= 1.0) ? 1.0 : 0.0;
}
#line 207
maskAlpha *= maskInvert ? -1.0 : 1.0;
#line 209
color.a *= maskEnable ? maskAlpha : 1.0;
#line 212
const float relativeDepth = smoothstep(depthRange.x, depthRange.y, depth);
const float relativeAlpha = (relativeDepth > alphaBlendDepth.y) ? (1.0 - smoothstep(alphaBlendDepth.y, 1.0, relativeDepth)) : smoothstep(0.0, alphaBlendDepth.x, relativeDepth);
color.a *= alphaBlend ? relativeAlpha : 1.0;
#line 217
if (enableDepth && (depth < depthRange.x || depth > depthRange.y)) {
color.a *= 0.0;
}
#line 221
return color;
}
#line 224
float3 PasteLayer(float2 texcoord, sampler sourceSamp, sampler destSamp, int operation, float opacity)
{
const float4 source = tex2D(sourceSamp, texcoord);
const float4 destination = tex2D(destSamp, texcoord);
if (source.a == 0.0) {
return destination.rgb;
}
#line 232
float3 result = destination.rgb;
#line 234
switch (operation)
{
case 0:
result = lerp(destination.rgb, source.rgb, source.a * opacity);
break;
case 1:
result = lerp(destination.rgb, ComHeaders::Blending::Darken(destination.rgb, source.rgb), source.a * opacity);
break;
case 2:
result = lerp(destination.rgb, ComHeaders::Blending::Multiply(destination.rgb, source.rgb), source.a * opacity);
break;
case 3:
result = lerp(destination.rgb, ComHeaders::Blending::ColorBurn(destination.rgb, source.rgb), source.a * opacity);
break;
case 4:
result = lerp(destination.rgb, ComHeaders::Blending::LinearBurn(destination.rgb, source.rgb), source.a * opacity);
break;
case 5:
result = lerp(destination.rgb, ComHeaders::Blending::Lighten(destination.rgb, source.rgb), source.a * opacity);
break;
case 6:
result = lerp(destination.rgb, ComHeaders::Blending::Screen(destination.rgb, source.rgb), source.a * opacity);
break;
case 7:
result = lerp(destination.rgb, ComHeaders::Blending::ColorDodge(destination.rgb, source.rgb), source.a * opacity);
break;
case 8:
result = lerp(destination.rgb, ComHeaders::Blending::LinearDodge(destination.rgb, source.rgb), source.a * opacity);
break;
case 9:
result = lerp(destination.rgb, ComHeaders::Blending::Addition(destination.rgb, source.rgb), source.a * opacity);
break;
case 11:
result = lerp(destination.rgb, ComHeaders::Blending::Glow(destination.rgb, source.rgb), source.a * opacity);
break;
case 12:
result = lerp(destination.rgb, ComHeaders::Blending::Overlay(destination.rgb, source.rgb), source.a * opacity);
break;
case 13:
result = lerp(destination.rgb, ComHeaders::Blending::SoftLight(destination.rgb, source.rgb), source.a * opacity);
break;
case 14:
result = lerp(destination.rgb, ComHeaders::Blending::HardLight(destination.rgb, source.rgb), source.a * opacity);
break;
case 15:
result = lerp(destination.rgb, ComHeaders::Blending::VividLight(destination.rgb, source.rgb), source.a * opacity);
break;
case 16:
result = lerp(destination.rgb, ComHeaders::Blending::LinearLight(destination.rgb, source.rgb), source.a * opacity);
break;
case 17:
result = lerp(destination.rgb, ComHeaders::Blending::PinLight(destination.rgb, source.rgb), source.a * opacity);
break;
case 18:
result = lerp(destination.rgb, ComHeaders::Blending::HardMix(destination.rgb, source.rgb), source.a * opacity);
break;
case 19:
result = lerp(destination.rgb, ComHeaders::Blending::Difference(destination.rgb, source.rgb), source.a * opacity);
break;
case 20:
result = lerp(destination.rgb, ComHeaders::Blending::Exclusion(destination.rgb, source.rgb), source.a * opacity);
break;
case 21:
result = lerp(destination.rgb, ComHeaders::Blending::Subtract(destination.rgb, source.rgb), source.a * opacity);
break;
case 22:
result = lerp(destination.rgb, ComHeaders::Blending::Divide(destination.rgb, source.rgb), source.a * opacity);
break;
case 23:
result = lerp(destination.rgb, ComHeaders::Blending::DivideAlt(destination.rgb, source.rgb), source.a * opacity);
break;
case 24:
result = lerp(destination.rgb, ComHeaders::Blending::DividePS(destination.rgb, source.rgb), source.a * opacity);
break;
case 10:
result = lerp(destination.rgb, ComHeaders::Blending::Reflect(destination.rgb, source.rgb), source.a * opacity);
break;
case 25:
result = lerp(destination.rgb, ComHeaders::Blending::GrainMerge(destination.rgb, source.rgb), source.a * opacity);
break;
case 26:
result = lerp(destination.rgb, ComHeaders::Blending::GrainExtract(destination.rgb, source.rgb), source.a * opacity);
break;
case 27:
result = lerp(destination.rgb, ComHeaders::Blending::Hue(destination.rgb, source.rgb), source.a * opacity);
break;
case 28:
result = lerp(destination.rgb, ComHeaders::Blending::Saturation(destination.rgb, source.rgb), source.a * opacity);
break;
case 29:
result = lerp(destination.rgb, ComHeaders::Blending::ColorB(destination.rgb, source.rgb), source.a * opacity);
break;
case 30:
result = lerp(destination.rgb, ComHeaders::Blending::Luminosity(destination.rgb, source.rgb), source.a * opacity);
break;
}
#line 331
return result;
}
#line 335
void PS_Copy_Layer1(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float4 layerColor : SV_Target) { layerColor = CopyLayer(texcoord, ReShade::BackBuffer, CFG_LAYERCAKE_DEPTHENABLE_Layer1, CFG_LAYERCAKE_DEPTH_Layer1, CFG_LAYERCAKE_MASKENABLE_Layer1, CFG_LAYERCAKE_MASKCOLOR_Layer1, CFG_LAYERCAKE_MASKBLEND_Layer1, CFG_LAYERCAKE_MASKINVERT_Layer1, CFG_LAYERCAKE_ALPHABLEND_Layer1, CFG_LAYERCAKE_ALPHABLEND_DEPTH_Layer1); } void PS_Paste_Layer1(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float4 screenColor : SV_Target) { screenColor = PasteLayer(texcoord, Samp_Layer1, ReShade::BackBuffer, CFG_LAYERCAKE_BLEND_Layer1, CFG_LAYERCAKE_OPACITY_Layer1); }
technique LayerCake_Layer1_Copy { pass { VertexShader = PostProcessVS; PixelShader = PS_Copy_Layer1; RenderTarget = Tex_Layer1; } } technique LayerCake_Layer1_Paste { pass { VertexShader = PostProcessVS; PixelShader = PS_Paste_Layer1; } }
#line 339
void PS_Copy_Layer2(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float4 layerColor : SV_Target) { layerColor = CopyLayer(texcoord, ReShade::BackBuffer, CFG_LAYERCAKE_DEPTHENABLE_Layer2, CFG_LAYERCAKE_DEPTH_Layer2, CFG_LAYERCAKE_MASKENABLE_Layer2, CFG_LAYERCAKE_MASKCOLOR_Layer2, CFG_LAYERCAKE_MASKBLEND_Layer2, CFG_LAYERCAKE_MASKINVERT_Layer2, CFG_LAYERCAKE_ALPHABLEND_Layer2, CFG_LAYERCAKE_ALPHABLEND_DEPTH_Layer2); } void PS_Paste_Layer2(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float4 screenColor : SV_Target) { screenColor = PasteLayer(texcoord, Samp_Layer2, ReShade::BackBuffer, CFG_LAYERCAKE_BLEND_Layer2, CFG_LAYERCAKE_OPACITY_Layer2); }
technique LayerCake_Layer2_Copy { pass { VertexShader = PostProcessVS; PixelShader = PS_Copy_Layer2; RenderTarget = Tex_Layer2; } } technique LayerCake_Layer2_Paste { pass { VertexShader = PostProcessVS; PixelShader = PS_Paste_Layer2; } }
#line 343
void PS_Copy_Layer3(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float4 layerColor : SV_Target) { layerColor = CopyLayer(texcoord, ReShade::BackBuffer, CFG_LAYERCAKE_DEPTHENABLE_Layer3, CFG_LAYERCAKE_DEPTH_Layer3, CFG_LAYERCAKE_MASKENABLE_Layer3, CFG_LAYERCAKE_MASKCOLOR_Layer3, CFG_LAYERCAKE_MASKBLEND_Layer3, CFG_LAYERCAKE_MASKINVERT_Layer3, CFG_LAYERCAKE_ALPHABLEND_Layer3, CFG_LAYERCAKE_ALPHABLEND_DEPTH_Layer3); } void PS_Paste_Layer3(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float4 screenColor : SV_Target) { screenColor = PasteLayer(texcoord, Samp_Layer3, ReShade::BackBuffer, CFG_LAYERCAKE_BLEND_Layer3, CFG_LAYERCAKE_OPACITY_Layer3); }
technique LayerCake_Layer3_Copy { pass { VertexShader = PostProcessVS; PixelShader = PS_Copy_Layer3; RenderTarget = Tex_Layer3; } } technique LayerCake_Layer3_Paste { pass { VertexShader = PostProcessVS; PixelShader = PS_Paste_Layer3; } }
#line 347
void PS_Copy_Layer4(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float4 layerColor : SV_Target) { layerColor = CopyLayer(texcoord, ReShade::BackBuffer, CFG_LAYERCAKE_DEPTHENABLE_Layer4, CFG_LAYERCAKE_DEPTH_Layer4, CFG_LAYERCAKE_MASKENABLE_Layer4, CFG_LAYERCAKE_MASKCOLOR_Layer4, CFG_LAYERCAKE_MASKBLEND_Layer4, CFG_LAYERCAKE_MASKINVERT_Layer4, CFG_LAYERCAKE_ALPHABLEND_Layer4, CFG_LAYERCAKE_ALPHABLEND_DEPTH_Layer4); } void PS_Paste_Layer4(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float4 screenColor : SV_Target) { screenColor = PasteLayer(texcoord, Samp_Layer4, ReShade::BackBuffer, CFG_LAYERCAKE_BLEND_Layer4, CFG_LAYERCAKE_OPACITY_Layer4); }
technique LayerCake_Layer4_Copy { pass { VertexShader = PostProcessVS; PixelShader = PS_Copy_Layer4; RenderTarget = Tex_Layer4; } } technique LayerCake_Layer4_Paste { pass { VertexShader = PostProcessVS; PixelShader = PS_Paste_Layer4; } }
}
}

