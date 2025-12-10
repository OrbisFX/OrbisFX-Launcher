// ResolutionYGCRT=240
// ResolutionXGCRT=320
// ShadowMaskGCRT=1
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\GuestCRT.fx"
#line 28
uniform int ResolutionX <
ui_type = "input";
ui_label = "Resolution X";
ui_bind = "ResolutionXGCRT";
> = 320;
#line 38
uniform int ResolutionY <
ui_type = "input";
ui_label = "Resolution Y";
ui_bind = "ResolutionYGCRT";
> = 240;
#line 48
uniform float TATE <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 1.0;
ui_label = "TATE Mode";
> = 0.0;
#line 56
uniform float IOS <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_step = 1.0;
ui_label = "Smart Integer Scaling: 1.0:Y, 2.0:'X'+Y";
> = 0.0;
#line 64
uniform float OS <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_step = 1.0;
ui_label = "Raster Bloom Overscan Mode";
> = 1.0;
#line 72
uniform float blm1 <
ui_type = "slider";
ui_min = 0.0;
ui_max = 20.0;
ui_step = 1.0;
ui_label = "Raster Bloom %";
> = 0.0;
#line 80
uniform float brightboost1 <
ui_type = "slider";
ui_min = 0.5;
ui_max = 4.0;
ui_step = 0.05;
ui_label = "Bright Boost Dark Pixels";
> = 1.4;
#line 88
uniform float brightboost2 <
ui_type = "slider";
ui_min = 0.5;
ui_max = 3.0;
ui_step = 0.05;
ui_label = "Bright Boost Bright Pixels";
> = 1.1;
#line 96
uniform float gsl <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_step = 1.0;
ui_label = "Scanline Type";
> = 0.0;
#line 104
uniform float scanline1 <
ui_type = "slider";
ui_min = 1.0;
ui_max = 15.0;
ui_step = 1.0;
ui_label = "Scanline Beam Shape Low";
> = 6.0;
#line 112
uniform float scanline2 <
ui_type = "slider";
ui_min = 5.0;
ui_max = 23.0;
ui_step = 1.0;
ui_label = "Scanline Beam Shape High";
> = 8.0;
#line 120
uniform float beam_min <
ui_type = "slider";
ui_min = 0.5;
ui_max = 2.5;
ui_step = 0.05;
ui_label = "Scanline Dark";
> = 1.35;
#line 128
uniform float beam_max <
ui_type = "slider";
ui_min = 0.5;
ui_max = 2.0;
ui_step = 0.05;
ui_label = "Scanline Bright";
> = 1.05;
#line 136
uniform float beam_size <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.05;
ui_label = "Increased Bright Scanline Beam";
> = 0.7;
#line 144
uniform float spike <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_step = 0.1;
ui_label = "Scanline Spike Removal";
> = 1.1;
#line 152
uniform float h_sharp <
ui_type = "slider";
ui_min = 1.0;
ui_max = 15.0;
ui_step = 0.25;
ui_label = "Horizontal Sharpness";
> = 5.25;
#line 160
uniform float s_sharp <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.1;
ui_label = "Substractive Sharpness";
> = 0.4;
#line 168
uniform float csize <
ui_type = "slider";
ui_min = 0.0;
ui_max = 0.07;
ui_step = 0.01;
ui_label = "Corner Size";
> = 0.0;
#line 176
uniform float bsize <
ui_type = "slider";
ui_min = 100.0;
ui_max = 600.0;
ui_step = 25.0;
ui_label = "Border Smoothness";
> = 600.0;
#line 184
uniform float warpX <
ui_type = "slider";
ui_min = 0.0;
ui_max = 0.125;
ui_step = 0.01;
ui_label = "Curvature X (Default 0.03)";
> = 0.0;
#line 192
uniform float warpY <
ui_type = "slider";
ui_min = 0.0;
ui_max = 0.125;
ui_step = 0.01;
ui_label = "Curvature Y (Default 0.04)";
> = 0.0;
#line 200
uniform float glow <
ui_type = "slider";
ui_min = 0.0;
ui_max = 0.5;
ui_step = 0.01;
ui_label = "Glow Strength";
> = 0.02;
#line 208
uniform uint shadowMask <
ui_type = "slider";
ui_min = 0;
ui_max = 7;
ui_step = 1;
ui_label = "CRT Mask: 1:CGWG, 2-5:Lottes, 6-7:'Trinitron'";
ui_bind = "ShadowMaskGCRT";
> = 1;
#line 221
uniform float masksize <
ui_type = "slider";
ui_min = 1.0;
ui_max = 2.0;
ui_step = 1.0;
ui_label = "CRT Mask Size (2.0 is nice in 4K)";
> = 1.0;
#line 229
uniform float vertmask <
ui_type = "slider";
ui_min = 0.0;
ui_max = 0.25;
ui_step = 0.01;
ui_label = "PVM Like Colors";
> = 0.0;
#line 237
uniform float slotmask <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.05;
ui_label = "Slot Mask Strength";
> = 0.0;
#line 245
uniform float slotwidth <
ui_type = "slider";
ui_min = 1.0;
ui_max = 6.0;
ui_step = 0.5;
ui_label = "Slot Mask Width";
> = 2.0;
#line 253
uniform float double_slot <
ui_type = "slider";
ui_min = 1.0;
ui_max = 2.0;
ui_step = 1.0;
ui_label = "Slot Mask Height: 2x1 or 4x1";
> = 1.0;
#line 261
uniform float slotms <
ui_type = "slider";
ui_min = 1.0;
ui_max = 2.0;
ui_step = 1.0;
ui_label = "Slot Mask Size";
> = 1.0;
#line 269
uniform float mcut <
ui_type = "slider";
ui_min = 0.0;
ui_max = 0.5;
ui_step = 0.05;
ui_label = "Mask 5-7 Cutoff";
> = 0.2;
#line 277
uniform float maskDark <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_step = 0.05;
ui_label = "Lottes&Trinitron Mask Dark";
> = 0.5;
#line 285
uniform float maskLight <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_step = 0.05;
ui_label = "Lottes & Trinitron Mask Bright";
> = 1.5;
#line 293
uniform float CGWG <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.05;
ui_label = "Mask 0 & 7 Strength";
> = 0.3;
#line 301
uniform float gamma_in <
ui_type = "slider";
ui_min = 0.1;
ui_max = 5.0;
ui_step = 0.05;
ui_label = "Gamma Input";
> = 2.4;
#line 309
uniform float gamma_out <
ui_type = "slider";
ui_min = 1.0;
ui_max = 3.5;
ui_step = 0.05;
ui_label = "Gamma Output";
> = 2.4;
#line 317
uniform float inter <
ui_type = "slider";
ui_min = 0.0;
ui_max = 800.0;
ui_step = 25.0;
ui_label = "Interlace Trigger Resolution";
> = 400.0;
#line 325
uniform float interm <
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
ui_step = 1.0;
ui_label = "Interlace Mode (0.0 = OFF)";
> = 2.0;
#line 333
uniform float blm2 <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_step = 0.1;
ui_label = "Bloom Strength";
> = 0.0;
#line 341
uniform float scans <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.1;
ui_label = "Scanline 1 & 2 Saturation";
> = 0.5;
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
#line 350 "C:\Program Files\GShade\gshade-shaders\Shaders\GuestCRT.fx"
#line 361
texture Texture1GCRT{Width = 1920; Height = 1018; Format = RGBA16F;};
sampler Sampler1GCRT{Texture = Texture1GCRT; MinFilter = Linear; MagFilter = Linear;};
#line 364
texture Texture2GCRT{Width = 1920; Height = 1018; Format = RGBA16F;};
sampler Sampler2GCRT{Texture = Texture2GCRT; MinFilter = Linear; MagFilter = Linear;};
#line 367
sampler Sampler3GCRT{Texture = ReShade::BackBufferTex;};
#line 369
uniform int framecount<source = "framecount";>;
#line 371
float st(float x)
{
return exp2(-10.0 * x * x);
}
#line 376
float3 sw0(float3 x, float3 color, float scanline)
{
const float3 ex = x * lerp(beam_min, beam_max, color);
#line 380
return exp2(-scanline * ex * ex);
}
#line 383
float3 sw1(float3 x, float3 color, float scanline)
{
const float mx = max(max(color.r, color.g), color.b);
x = lerp(x, beam_min * x, max(x - 0.4 * mx, 0.0));
const float3 ex = x * lerp(1.2*beam_min,beam_max,color);
const float br = clamp(0.8 * beam_min - 1.0, 0.2, 0.45);
const float3 res = exp2(-scanline * ex * ex) / (1.0 - br + br * mx);
float scans1 = scans;
if(abs(vertmask) > 0.01)
scans1 = 1.0;
#line 394
return lerp(max(max(res.r, res.g), res.b), res, scans1);
}
#line 397
float3 sw2(float3 x, float3 color, float scanline)
{
const float3 ex = x * lerp(beam_max, lerp(2.5 * beam_min, beam_max, color), pow(abs(x), color + 0.3));
const float3 res = exp2(-scanline * ex * ex) / (0.6 + 0.4 * max(max(color.r, color.g), color.b));
float scans1 = scans;
if(abs(vertmask) > 0.01)
scans1 = 0.85;
#line 405
return lerp(max(max(res.r, res.g), res.b), res, scans1);
}
#line 408
float3 mask1(float2 pos, float3 c)
{
pos = floor(pos / masksize);
float3 mask = maskDark;
#line 416
pos.x = frac(pos.x * 0.5);
const float mc = 1.0 - CGWG;
if(pos.x < 0.5)
{
mask.r = 1.1;
mask.g = mc;
mask.b = 1.1;
}
else
{
mask.r = mc;
mask.g = 1.1;
mask.b = mc;
}
#line 499
return mask;
}
#line 502
float mask2(float2 pos, float3 c)
{
if(slotmask == 0.0)
return 1.0;
pos = floor(pos / slotms);
const float mx = pow(max(max(c.r, c.g), c.b), 1.33);
const float px = frac(pos.x / (slotwidth * 2.0));
const float py = floor(frac(pos.y / (2.0 * double_slot)) * 2.0 * double_slot);
const float slot_dark = lerp(1.0 - slotmask, 1.0 - 0.80 * slotmask, mx);
if(py == 0.0 && px < 0.5)
return slot_dark;
else if(py == double_slot && px >= 0.5)
return slot_dark;
#line 516
return 1.0 + 0.7 * slotmask * (1.0 - mx);
}
#line 519
float2 warp(float2 pos)
{
pos = pos * 2.0 - 1.0;
pos *= float2(1.0 + (pos.y * pos.y) * warpX, 1.0 + (pos.x * pos.x) * warpY);
#line 524
return pos * 0.5 + 0.5;
}
#line 527
float2 overscan(float2 pos, float dx, float dy)
{
pos = pos * 2.0 - 1.0;
pos *= float2(dx, dy);
#line 532
return pos * 0.5 + 0.5;
}
#line 535
float corner(float2 coord)
{
coord *= float4(float2(320, 240), 1.0 / float2(320, 240)).xy / float2(320, 240).xy;
coord = (coord - 0.5) * 1.0 + 0.5;
coord = min(coord, 1.0 - coord) * float2(1.0, float4(float2(1920, 1018), 1.0 / float2(1920, 1018)).y / float4(float2(1920, 1018), 1.0 / float2(1920, 1018)).x);
const float2 cdist = max(csize, max((1.0 - smoothstep(100.0, 600.0, bsize)) * 0.01, 0.002));
coord = (cdist - min(coord, cdist));
#line 543
return clamp((cdist.x - sqrt(dot(coord, coord))) * bsize, 0.0, 1.0);
}
#line 546
float3 declip(float3 c, float b)
{
const float m = max(max(c.r, c.g), c.b);
if(m > b)
return c * b / m;
#line 552
return c;
}
#line 555
float4 LinearizePS(float4 position:SV_Position, float2 texcoord:TEXCOORD):SV_Target
{
return float4(pow(abs(tex2D(Sampler3GCRT, texcoord)), gamma_in));
}
#line 560
float4 ScanlinesPS(float4 position:SV_Position, float2 texcoord:TEXCOORD):SV_Target
{
return float4(pow(tex2D(Sampler3GCRT, texcoord).rgb, 10.0), 1.0);
}
#line 565
float4 GuestPS(float4 position:SV_Position, float2 texcoord:TEXCOORD):SV_Target
{
if(IOS > 0.0)
{
const float2 ofactor = float4(float2(1920, 1018), 1.0 / float2(1920, 1018)).xy / float2(320, 240).xy;
const float2 diff = ofactor / round(ofactor);
const float scan = lerp(diff.y, diff.x, TATE);
texcoord = overscan(texcoord * (float4(float2(320, 240), 1.0 / float2(320, 240)).xy / float2(320, 240).xy), scan, scan) * (float2(320, 240).xy / float4(float2(320, 240), 1.0 / float2(320, 240)).xy);
if(IOS == 1.0)
texcoord = lerp(float2(texcoord.x, texcoord.y), float2(texcoord.x, texcoord.y), TATE);
}
#line 577
const float factor = 1.00 + (1.0 - 0.5 * OS) * blm1 / 100.0 - tex2D(Sampler3GCRT, 0.05).a * blm1 / 100.0;
texcoord = overscan(texcoord * (float4(float2(320, 240), 1.0 / float2(320, 240)).xy / float2(320, 240).xy), factor, factor) * (float2(320, 240).xy / float4(float2(320, 240), 1.0 / float2(320, 240)).xy);
const float2 pos = warp(texcoord * (float2(320, 240).xy / float2(320, 240).xy)) * (float2(320, 240).xy / float2(320, 240).xy);
#line 581
float2 coffset = 0.5;
if((interm == 1.0 || interm == 2.0) && inter <= lerp(float2(320, 240).y, float2(320, 240).x, TATE))
{
if (TATE < 0.5)
coffset = float2(0.5, 0.0);
else
coffset = float2(0.0, 0.5);
}
#line 590
const float2 ps = float4(float2(320, 240), 1.0 / float2(320, 240)).zw;
const float2 ogl2pos = pos * float4(float2(320, 240), 1.0 / float2(320, 240)).xy - coffset;
const float2 fp = frac(ogl2pos);
const float2 dx = float2(ps.x, 0.0);
const float2 dy = float2(0.0, ps.y);
#line 596
float2 offx = dx;
float2 off2 = 2.0 * dx;
float2 offy = dy;
float fpx = fp.x;
#line 601
if(TATE > 0.5)
{
offx = dy;
off2 = 2.0 * dy;
offy = dx;
fpx = fp.y;
}
#line 609
const float f = (TATE < 0.5)?fp.y:fp.x;
#line 611
float2 pc4 = floor(ogl2pos) * ps + 0.5 * ps;
#line 613
const float sharp1 = s_sharp * exp2(-h_sharp);
#line 615
float wl3 = 2.0 + fpx;
float wl2 = 1.0 + fpx;
float wl1 = fpx;
float wr1 = 1.0 - fpx;
float wr2 = 2.0 - fpx;
float wr3 = 3.0 - fpx;
#line 622
wl3 *= wl3;
wl3 = exp2(-h_sharp * wl3);
#line 625
wl2 *= wl2;
wl2 = exp2(-h_sharp * wl2);
#line 628
wl1 *= wl1;
wl1 = exp2(-h_sharp * wl1);
#line 631
wr1 *= wr1;
wr1 = exp2(-h_sharp * wr1);
#line 634
wr2 *= wr2;
wr2 = exp2(-h_sharp * wr2);
#line 637
wr3 *= wr3;
wr3 = exp2(-h_sharp * wr3);
#line 640
const float twl3 = max(wl3 - sharp1, 0.0);
const float twl2 = max(wl2 - sharp1, lerp(0.0, lerp(-0.17, -0.025, fp.x), float(s_sharp > 0.05)));
const float twl1 = max(wl1 - sharp1, 0.0);
const float twr1 = max(wr1 - sharp1, 0.0);
const float twr2 = max(wr2 - sharp1, lerp(0.0, lerp(-0.17, -0.025, 1.0 - fp.x), float(s_sharp > 0.05)));
const float twr3 = max(wr3 - sharp1, 0.0);
#line 647
const float wtt = 1.0 / (twl3 + twl2 + twl1 + twr1 + twr2 + twr3);
const float wt = 1.0 / (wl2 + wl1 + wr1 + wr2);
const bool sharp = (s_sharp > 0.05);
#line 651
float3 l3 = tex2D(Sampler1GCRT, pc4 - off2).xyz;
float3 l2 = tex2D(Sampler1GCRT, pc4 - offx).xyz;
float3 l1 = tex2D(Sampler1GCRT, pc4).xyz;
float3 r1 = tex2D(Sampler1GCRT, pc4 + offx).xyz;
float3 r2 = tex2D(Sampler1GCRT, pc4 + off2).xyz;
float3 r3 = tex2D(Sampler1GCRT, pc4 + offx + off2).xyz;
#line 658
float3 sl2 = tex2D(Sampler2GCRT, pc4 - offx).xyz;
float3 sl1 = tex2D(Sampler2GCRT, pc4).xyz;
float3 sr1 = tex2D(Sampler2GCRT, pc4 + offx).xyz;
float3 sr2 = tex2D(Sampler2GCRT, pc4 + off2).xyz;
#line 663
float3 color1 = (l3 * twl3 + l2 * twl2 + l1 * twl1 + r1 * twr1 + r2 * twr2 + r3 * twr3) * wtt;
#line 665
float3 colmin = min(min(l1, r1), min(l2, r2));
float3 colmax = max(max(l1, r1), max(l2, r2));
#line 668
if(sharp)
color1 = clamp(color1, colmin, colmax);
#line 671
const float3 gtmp = gamma_out * 0.1;
float3 scolor1 = color1;
#line 674
scolor1 = (sl2 * wl2 + sl1 * wl1 + sr1 * wr1 + sr2 * wr2) * wt;
scolor1 = pow(abs(scolor1), gtmp);
const float3 mcolor1 = scolor1;
scolor1 = lerp(color1, scolor1, spike);
#line 679
pc4 += offy;
#line 681
l3 = tex2D(Sampler1GCRT, pc4 - off2).xyz;
l2 = tex2D(Sampler1GCRT, pc4 - offx).xyz;
l1 = tex2D(Sampler1GCRT, pc4).xyz;
r1 = tex2D(Sampler1GCRT, pc4 + offx).xyz;
r2 = tex2D(Sampler1GCRT, pc4 + off2).xyz;
r3 = tex2D(Sampler1GCRT, pc4 + offx + off2).xyz;
#line 688
sl2 = tex2D(Sampler2GCRT, pc4 - offx).xyz;
sl1 = tex2D(Sampler2GCRT, pc4).xyz;
sr1 = tex2D(Sampler2GCRT, pc4 + offx).xyz;
sr2 = tex2D(Sampler2GCRT, pc4 + off2).xyz;
#line 693
float3 color2 = (l3 * twl3 + l2 * twl2 + l1 * twl1 + r1 * twr1 + r2 * twr2 + r3 * twr3) * wtt;
#line 695
colmin = min(min(l1, r1), min(l2, r2));
colmax = max(max(l1, r1), max(l2, r2));
#line 698
if(sharp)
color2 = clamp(color2, colmin, colmax);
#line 701
float3 scolor2 = color2;
#line 703
scolor2 = (sl2 * wl2 + sl1 * wl1 + sr1 * wr1 + sr2 * wr2) * wt;
scolor2 = pow(abs(scolor2), gtmp);float3 mcolor2 = scolor2;
scolor2 = lerp(color2, scolor2, spike);
#line 707
float3 color0 = color1;
#line 709
if((interm == 1.0 || interm == 2.0) && inter <= lerp(float2(320, 240).y, float2(320, 240).x, TATE))
{
pc4 -= 2.0 * offy;
#line 713
l3 = tex2D(Sampler1GCRT, pc4 - off2).xyz;
l2 = tex2D(Sampler1GCRT, pc4 - offx).xyz;
l1 = tex2D(Sampler1GCRT, pc4).xyz;
r1 = tex2D(Sampler1GCRT, pc4 + offx).xyz;
r2 = tex2D(Sampler1GCRT, pc4 + off2).xyz;
r3 = tex2D(Sampler1GCRT, pc4 + offx + off2).xyz;
#line 720
color0 = (l3 * twl3 + l2 * twl2 + l1 * twl1 + r1 * twr1 + r2 * twr2 + r3 * twr3) * wtt;
#line 722
colmin = min(min(l1, r1), min(l2, r2));
colmax = max(max(l1, r1), max(l2, r2));
#line 725
if(sharp)
color0 = clamp(color0, colmin, colmax);
}
#line 729
const float shape1 = lerp(scanline1, scanline2, f);
const float shape2 = lerp(scanline1, scanline2, 1.0 - f);
#line 732
const float wt1 = st(f);
const float wt2 = st(1.0 - f);
#line 735
float3 mcolor = (mcolor1 * wt1 + mcolor2 * wt2) / (wt1 + wt2);
#line 737
float3 ctmp = (color1 * wt1 + color2 * wt2) / (wt1 + wt2);
const float3 sctmp = (scolor1 * wt1 + scolor2 * wt2) / (wt1 + wt2);
#line 740
const float3 tmp = pow(abs(ctmp), 1.0 / gamma_out);
mcolor = clamp(lerp(ctmp, mcolor, 1.5), 0.0, 1.0);
mcolor = pow(mcolor, 1.4 / gamma_out);
#line 744
float3 w1, w2 = 0.0;
#line 746
const float3 cref1 = lerp(sctmp, scolor1, beam_size);
const float3 cref2 = lerp(sctmp, scolor2, beam_size);
#line 749
const float3 shift = float3(-vertmask, vertmask, -vertmask);
#line 751
const float3 f1 = clamp(f + shift * 0.5 * (1.0 + f), 0.0, 1.0);
const float3 f2 = clamp((1.0 - f) - shift * 0.5 * (2.0 - f), 0.0, 1.0);
#line 754
if(gsl == 0.0){
w1 = sw0(f1, cref1, shape1);
w2 = sw0(f2, cref2, shape2);
}
else if(gsl == 1.0)
{
w1 = sw1(f1, cref1, shape1);
w2 = sw1(f2, cref2, shape2);
}
else if(gsl == 2.0)
{
w1 = sw2(f1, cref1, shape1);
w2 = sw2(f2, cref2, shape2);
}
#line 769
float3 color = color1 * w1 + color2 * w2;
color = min(color, 1.0);
#line 772
if(interm > 0.5 && inter <= lerp(float2(320, 240).y, float2(320, 240).x, TATE))
{
if(interm < 3.0)
{
float ii = 0.5;
if(interm < 1.5)
ii = abs(floor((lerp(ogl2pos.y, ogl2pos.x, TATE) - 2.0 * trunc(lerp(ogl2pos.y, ogl2pos.x, TATE) / 2.0))) - floor((float(framecount) - 2.0 * trunc(float(framecount) / 2.0))));
#line 780
color = lerp(lerp(color1, color0, ii), lerp(color1, color2, ii), f);
}
else
color = lerp(color1, color2, f);
#line 785
mcolor = sqrt(color);
}
#line 788
ctmp = 0.5 * (ctmp + tmp);
color *= lerp(brightboost1, brightboost2, max(max(ctmp.r, ctmp.g), ctmp.b));
#line 791
const float3 orig1 = color;
w1 = w1 + w2;
float3 cmask = 1.0;
float3 cmask1 = 1.0;
#line 796
if (TATE < 0.5)
{
cmask *= mask1(position.xy * 1.000001, mcolor);
cmask1 *= mask2(position.xy * 1.000001, tmp);
}
else
{
cmask *= mask1(position.yx * 1.000001, mcolor);
cmask1 *= mask2(position.yx * 1.000001, tmp);
}
#line 807
color = min(color * cmask, 1.0) * cmask1;
cmask = min(cmask * cmask1, 1.0);
#line 810
const float3 Bloom1 = tex2D(Sampler3GCRT, pos).xyz;
#line 812
float3 Bloom2 = min(2.0 * Bloom1 * Bloom1, 0.80);
const float pmax = lerp(0.825, 0.725, max(max(ctmp.r, ctmp.g), ctmp.b));
Bloom2 = min(Bloom2, pmax * max(max(Bloom2.r, Bloom2.g), Bloom2.b)) / pmax;
#line 816
Bloom2 = blm2 * lerp(min(Bloom2, color), Bloom2, 0.5 * (orig1 + color));
#line 818
color = min(color + Bloom2, 1.0);
if(interm < 0.5 || inter > lerp(float2(320, 240).y, float2(320, 240).x, TATE))
color = declip(color, pow(max(max(w1.r, w1.g), w1.b), 0.5));
#line 826
return float4(pow(abs(min(color, lerp(cmask, 1.0, 0.5)) + glow * Bloom1), 1.0 / gamma_out) * corner(pos), 1.0);
#line 828
}
#line 830
technique GuestCRT
{
pass Linearize_Gamma
{
VertexShader = PostProcessVS;
PixelShader = LinearizePS;
RenderTarget = Texture1GCRT;
}
#line 839
pass Linearize_Scanlines
{
VertexShader = PostProcessVS;
PixelShader = ScanlinesPS;
RenderTarget = Texture2GCRT;
}
#line 846
pass Guest_Dr_Venom
{
VertexShader = PostProcessVS;
PixelShader = GuestPS;
}
}

