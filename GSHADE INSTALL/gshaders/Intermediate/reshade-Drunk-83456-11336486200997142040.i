#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Drunk.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Drunk.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\RadegastShaders.Depth.fxh"
uniform float2 depth_bounds <
ui_type = "slider";
ui_label = "Depth Bounds";
ui_category = "Depth";
ui_tooltip = "The depth bounds where the effect is calculated.";
min = 0.0;
max = 1.0;
> = float2(0.0, 1.0);
#line 10
uniform float min_depth <
ui_type = "slider";
ui_label="Minimum Depth";
ui_tooltip="Unmasks anything before a set depth.";
ui_category="Depth";
ui_min=0.0;
ui_max=1.0;
> = 0;
#line 37 "C:\Program Files\GShade\gshade-shaders\Shaders\Drunk.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\RadegastShaders.Transforms.fxh"
float2x2 swirlTransform(float theta) {
const float c = cos(theta);
const float s = sin(theta);
#line 5
const float m1 = c;
const float m2 = -s;
const float m3 = s;
const float m4 = c;
#line 10
return float2x2(
m1, m2,
m3, m4
);
};
#line 16
float2x2 zigzagTransform(float theta) {
const float c = cos(theta);
return float2x2(
c, 0,
0, c
);
}
#line 24
float3x3 getrot(float3 r)
{
const float cx = cos(radians(r.x));
const float sx = sin(radians(r.x));
const float cy = cos(radians(r.y));
const float sy = sin(radians(r.y));
const float cz = cos(radians(r.z));
const float sz = sin(radians(r.z));
#line 33
const float m1 = cy * cz;
const float m2= cx * sz + sx * sy * cz;
const float m3= sx * sz - cx * sy * cz;
const float m4= -cy * sz;
const float m5= cx * cz - sx * sy * sz;
const float m6= sx * cz + cx * sy * sz;
const float m7= sy;
const float m8= -sx * cy;
const float m9= cx * cy;
#line 43
return float3x3
(
m1,m2,m3,
m4,m5,m6,
m7,m8,m9
);
};
#line 38 "C:\Program Files\GShade\gshade-shaders\Shaders\Drunk.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\RadegastShaders.BlendingModes.fxh"
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
#line 2 "C:\Program Files\GShade\gshade-shaders\Shaders\RadegastShaders.BlendingModes.fxh"
#line 19
uniform int
render_type < ui_category =
"Blending"; ui_category_closed =
false; ui_items = "Normal\0" "Darken\0" "  Multiply\0" "  Color Burn\0" "  Linear Burn\0" "Lighten\0" "  Screen\0" "  Color Dodge\0" "  Linear Dodge\0" "  Addition\0" "  Glow\0" "Overlay\0" "  Soft Light\0" "  Hard Light\0" "  Vivid Light\0" "  Linear Light\0" "  Pin Light\0" "  Hard Mix\0" "Difference\0" "  Exclusion\0" "Subtract\0" "  Divide\0" "  Divide (Alternative)\0" "  Divide (Photoshop)\0" "  Reflect\0" "  Grain Extract\0" "  Grain Merge\0" "Hue\0" "  Saturation\0" "  Color\0" "  Luminosity\0"; ui_label =
"Blending Mode"; ui_tooltip =
"Blends the effect with the previous layers."; ui_type = "combo"; ui_spacing =
0; > =
0
#line 11
;;
#line 13
uniform float blending_amount <
ui_type = "slider";
ui_label = "Opacity";
ui_category = "Blending";
ui_tooltip = "Adjusts the blending amount.";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
#line 39 "C:\Program Files\GShade\gshade-shaders\Shaders\Drunk.fxh"
#line 41
uniform float2 p_drunk_strength<
ui_type = "slider";
ui_label = "Strength";
ui_category = "Distortion";
ui_min = 0.0;
ui_max = 100.0;
ui_step = 0.1;
ui_tooltip = "Controls the magnitude of the distortion along the X and Y axis.";
> = float2(25.0, 25.0);
#line 51
uniform float2 p_drunk_speed<
ui_type = "slider";
ui_label = "Speed";
ui_category = "Distortion";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.1;
ui_tooltip = "Controls the speed of the distortion along the X and Y axis.";
#line 60
> = float2(2.0, 2.0);
#line 62
uniform float angle <
ui_type = "slider";
ui_label = "Bending Angle";
ui_category = "Distortion";
ui_min = -1800.0;
ui_max = 1800.0;
ui_tooltip = "Controls how much the distortion bends.";
ui_step = 1.0;
> = 180.0;
#line 72
uniform float angle_speed<
ui_type = "slider";
ui_label = "Bending Speed";
ui_category = "Distortion";
ui_min = 0.0;
ui_max = 10.0;
ui_step = 0.1;
ui_tooltip = "Controls the speed of the bending.";
#line 81
> = 1.0;
#line 83
uniform float anim_rate <
source = "timer";
>;
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\Drunk.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\Drunk.fx"
#line 33
texture texColorBuffer : COLOR;
#line 35
sampler samplerColor
{
Texture = texColorBuffer;
#line 39
AddressU = MIRROR;
AddressV = MIRROR;
AddressW = MIRROR;
#line 43
MagFilter = LINEAR;
MinFilter = LINEAR;
MipFilter = LINEAR;
#line 47
MinLOD = 0.0f;
MaxLOD = 1000.0f;
#line 50
MipLODBias = 0.0f;
#line 52
SRGBTexture = false;
};
#line 56
float random_time_at(uint i) {
#line 58
const float x[] = { .2, .8, -.2, .452, -.2832, .8,
-.28, -1, -.42, -.89, .72, -.29,
.75, .25, .33, .67, .98, .01,
-.28, 0.8, -.32, -.189, .11, .84,
-.48, 0.1, -.2323, -.555, .421, .23,
-.28, 0.3, -1.3333, 1.333, 4, 1 };
#line 65
return x[i];
}
#line 68
float2 mult_at(int x, int y) {
float x2 = x - 2. * floor(x/2.);
float y2 = y - 2. * floor(y/2.);
#line 72
float2 mult;
mult.x = (x2 < 1.) ? -1. : 1.;
mult.y = (y2 < 1.) ? -1. : 1.;
#line 76
return mult;
}
#line 80
float2 index_UV(uint i, float2 tc) {
const uint x = i/6;
const uint y = i%6;
#line 84
const float theta = radians(angle) * sin(anim_rate * 0.0005 * angle_speed);
#line 86
float2 off = float2(0, 0);
float rta = random_time_at(i);
#line 89
if((x >= 0) && (x < 5) && (y >= 0) && (y < 5))
sincos(anim_rate / 1000.0 * p_drunk_speed.x + rta, off.y, off.x);
#line 92
off *= (p_drunk_strength / 100.0) * tc.xy * 0.5 * mult_at(x, y);
off = mul(swirlTransform(theta), off);
#line 95
return float2 ((x +  off.x) / 5, (y + off.y) / 5);
}
#line 99
void FullScreenVS(uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
#line 104
position = float4(texcoord * float2(2, -2) + float2(-1, 1), 0, 1);
}
#line 108
float4 PSDrunkStage1(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_TARGET {
const float4 base = tex2D(samplerColor, texcoord);
const float depth = ReShade::GetLinearizedDepth(texcoord).r;
float2 fade = frac(texcoord.xy * 5);
fade = (sin((fade - 0.5) * 3.14159265) + 1.0) * 0.5;
#line 115
int2 _low = int2(floor(texcoord.xy * 5));
int2 _hig = int2(ceil(texcoord.xy * 5));
#line 118
_low.x *=   5+1;
_hig.x *=  5+1;
#line 121
float2 uv_tl = index_UV(_low.x + _low.y, texcoord);
float2 uv_tr = index_UV(_hig.x + _low.y, texcoord);
float2 uv_bl = index_UV(_low.x + _hig.y, texcoord);
float2 uv_br = index_UV(_hig.x + _hig.y, texcoord);
#line 126
float2 uv_t = lerp(uv_tl, uv_tr, fade.x);
float2 uv_b = lerp(uv_bl, uv_br, fade.x);
#line 129
float2 uv = lerp(uv_t, uv_b, fade.y);
#line 131
float4 result = tex2D(samplerColor, uv);
float out_depth = ReShade::GetLinearizedDepth(uv).r;
bool inDepthBounds = out_depth >= depth_bounds.x && out_depth <= depth_bounds.y;
#line 135
if(inDepthBounds)
result.rgb = ComHeaders::Blending::Blend(render_type, base.rgb, result.rgb, blending_amount);
else result = base;
#line 139
if(depth < min_depth)
result = tex2D(samplerColor, texcoord);
#line 142
return result;
}
#line 145
technique Drunk <ui_label="Drunk";>
{
pass
{
VertexShader = FullScreenVS;
PixelShader  = PSDrunkStage1;
}
}

