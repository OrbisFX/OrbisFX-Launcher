#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MaskGlowAdvanced.fx"
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
#line 22 "C:\Program Files\GShade\gshade-shaders\Shaders\MaskGlowAdvanced.fx"
#line 24
uniform float aarange  <
ui_type = "slider";
ui_min = 0.0; ui_max = 4.0; ui_step = 0.05;
ui_label = "Smoothing/AA range";
ui_tooltip = "Smoothing/AA range";
> = 1.0;
#line 31
uniform float gamma_c  <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0; ui_step = 0.05;
ui_label = "Gamma Correct";
ui_tooltip = "Gamma Correct";
> = 1.0;
#line 38
uniform float brightboost  <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0; ui_step = 0.01;
ui_label = "Bright Boost";
ui_tooltip = "Bright Boost";
> = 1.0;
#line 45
uniform float saturation  <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.5; ui_step = 0.01;
ui_label = "Saturation Adjustment";
ui_tooltip = "Saturation Adjustment";
> = 1.0;
#line 52
uniform float warpX  <
ui_type = "slider";
ui_min = 0.0; ui_max = 0.5;
ui_label = "CurvatureX";
ui_tooltip = "CurvatureX";
> = 0.0;
#line 59
uniform float warpY  <
ui_type = "slider";
ui_min = 0.0; ui_max = 0.5;
ui_label = "CurvatureY";
ui_tooltip = "CurvatureY";
> = 0.0;
#line 66
uniform float c_shape  <
ui_type = "slider";
ui_min = 0.05; ui_max = 0.6;
ui_label = "Curvature Shape";
ui_tooltip = "Curvature Shape";
> = 0.25;
#line 73
uniform float bsize1  <
ui_type = "slider";
ui_min = 0.0; ui_max = 3.0;
ui_label = "Border Size";
ui_tooltip = "Border Size";
> = 0.02;
#line 80
uniform float sborder  <
ui_type = "slider";
ui_min = 0.25; ui_max = 2.0;
ui_label = "Border Intensity";
ui_tooltip = "Border Intensity";
> = 0.75;
#line 87
uniform int shadowMask <
ui_type = "slider";
ui_min = -1; ui_max = 12;
ui_label = "CRT Mask Type";
ui_tooltip = "CRT Mask Type";
> = 0;
#line 94
uniform float MaskGamma <
ui_type = "slider";
ui_min = 1.0; ui_max = 3.0; ui_step = 0.05;
ui_label = "Mask Gamma";
ui_tooltip = "Mask Gamma";
> = 2.2;
#line 101
uniform float maskstr <
ui_type = "slider";
ui_min = -0.5; ui_max = 1.0; ui_step = 0.05;
ui_label = "Mask Strength masks: 0, 5-12";
ui_tooltip = "Mask Strength masks: 0, 5-12";
> = 0.33;
#line 108
uniform float mcut <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0; ui_step = 0.05;
ui_label = "Mask Strength Low (masks: 0, 5-12)";
ui_tooltip = "Mask Strength Low (masks: 0, 5-12)";
> = 1.10;
#line 115
uniform float maskboost <
ui_type = "slider";
ui_min = 1.0; ui_max = 3.0; ui_step = 0.05;
ui_label = "CRT Mask Boost";
ui_tooltip = "CRT Mask Boost";
> = 1.0;
#line 122
uniform float mshift <
ui_type = "drag";
ui_min = -8.0;
ui_max = 8.0;
ui_step = 0.5;
ui_label = "Mask Shift/Stagger";
> = 0.0;
#line 130
uniform int mask_layout <
ui_type = "slider";
ui_min = 0; ui_max = 1;
ui_label = "Mask Layout: RGB or BGR (check LCD panel)";
ui_tooltip = "Mask Layout: RGB or BGR (check LCD panel)";
> = 0;
#line 137
uniform float maskDark <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0; ui_step = 0.05;
ui_label = "Mask Dark (masks 1-4)";
ui_tooltip = "Mask Dark (masks 1-4)";
> = 0.50;
#line 144
uniform float maskLight <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0; ui_step = 0.05;
ui_label = "Mask Light";
ui_tooltip = "Mask Light";
> = 1.50;
#line 151
uniform float slotmask <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0; ui_step = 0.05;
ui_label = "Slotmask Strength Bright Pixels";
ui_tooltip = "Slotmask Strength Bright Pixels";
> = 0.0;
#line 158
uniform float slotmask1 <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0; ui_step = 0.05;
ui_label = "Slotmask Strength Dark Pixels";
ui_tooltip = "Slotmask Strength Dark Pixels";
> = 0.0;
#line 165
uniform int slotwidth <
ui_type = "slider";
ui_min = 1; ui_max = 8;
ui_label = "Slot Mask Width";
ui_tooltip = "Slot Mask Width";
> = 2;
#line 172
uniform int double_slot <
ui_type = "slider";
ui_min = 1; ui_max = 4;
ui_label = "Slot Mask Heigth";
ui_tooltip = "Slot Mask Heigth";
> = 1;
#line 179
uniform int masksize <
ui_type = "slider";
ui_min = 1; ui_max = 3;
ui_label = "CRT Mask Size";
ui_tooltip = "CRT Mask Size";
> = 1;
#line 186
uniform int smasksize <
ui_type = "slider";
ui_min = 1; ui_max = 3;
ui_label = "Slot Mask Size";
ui_tooltip = "Slot Mask Size";
> = 1;
#line 193
uniform float bloom <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0; ui_step = 0.05;
ui_label = "Bloom Strength";
ui_tooltip = "Bloom Strength";
> = 0.0;
#line 200
uniform float bdist <
ui_type = "slider";
ui_min = 0.0; ui_max = 3.0; ui_step = 0.05;
ui_label = "Bloom Distribution";
ui_tooltip = "Bloom Distribution";
> = 1.0;
#line 207
uniform float halation <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0; ui_step = 0.05;
ui_label = "Halation Strength";
ui_tooltip = "Halation Strength";
> = 0.0;
#line 214
uniform float glow <
ui_type = "slider";
ui_min = 0.0; ui_max = 0.25;
ui_label = "Glow Strength";
ui_tooltip = "Glow Strength";
> = 0.0;
#line 222
uniform float glow_size <
ui_type = "slider";
ui_min = 0.5; ui_max = 6.0;
ui_label = "Glow Size";
ui_tooltip = "Glow Size";
> = 2.0;
#line 230
uniform float decons <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0; ui_step = 0.1;
ui_label = "Deconvergence Strength";
ui_tooltip = "Deconvergence Strength";
> = 1.0;
#line 238
uniform float deconrr <
ui_type = "slider";
ui_min = -8.0; ui_max = 8.0; ui_step = 0.25;
ui_label = "Deconvergence Red Horizontal";
ui_tooltip = "Deconvergence Red Horizontal";
> = 0.0;
#line 245
uniform float deconrg <
ui_type = "slider";
ui_min = -8.0; ui_max = 8.0; ui_step = 0.25;
ui_label = "Deconvergence Green Horizontal";
ui_tooltip = "Deconvergence Green Horizontal";
> = 0.0;
#line 252
uniform float deconrb <
ui_type = "slider";
ui_min = -8.0; ui_max = 8.0; ui_step = 0.25;
ui_label = "Deconvergence Blue Horizontal";
ui_tooltip = "Deconvergence Blue Horizontal";
> = 0.0;
#line 259
uniform float deconrry <
ui_type = "slider";
ui_min = -8.0; ui_max = 8.0; ui_step = 0.25;
ui_label = "Deconvergence Red Vertical";
ui_tooltip = "Deconvergence Red Vertical";
> = 0.0;
#line 266
uniform float deconrgy <
ui_type = "slider";
ui_min = -8.0; ui_max = 8.0; ui_step = 0.25;
ui_label = "Deconvergence Green Vertical";
ui_tooltip = "Deconvergence Green Vertical";
> = 0.0;
#line 273
uniform float deconrby <
ui_type = "slider";
ui_min = -8.0; ui_max = 8.0; ui_step = 0.25;
ui_label = "Deconvergence Blue Vertical";
ui_tooltip = "Deconvergence Blue Vertical";
> = 0.0;
#line 281
texture ShinraAdvanced01L  { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler ShinraAdvanced01SL { Texture = ShinraAdvanced01L; MinFilter = Linear; MagFilter = Linear; };
#line 284
texture ShinraAdvanced02L  { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler ShinraAdvanced02SL { Texture = ShinraAdvanced02L; MinFilter = Linear; MagFilter = Linear; };
#line 287
texture ShinraAdvanced03L  { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler ShinraAdvanced03SL { Texture = ShinraAdvanced03L; MinFilter = Linear; MagFilter = Linear; };
#line 290
float3 plant (float3 tar, float r)
{
const float t = max(max(tar.r,tar.g),tar.b) + 0.00001;
return tar * r / t;
}
#line 296
float4 PASS_SH0(float4 pos : SV_Position, float2 uv : TexCoord) : SV_Target
{
const float x = ReShade::GetPixelSize().x * aarange;
const float y = ReShade::GetPixelSize().y * aarange;
const float2 dg1 = float2( x,y);
const float2 dg2 = float2(-x,y);
const float2 sd1 = dg1*0.5;
const float2 sd2 = dg2*0.5;
const float2 ddx = float2(x,0.0);
const float2 ddy = float2(0.0,y);
#line 307
const float3 c11 = tex2D(ReShade::BackBuffer, uv).xyz;
const float3 s00 = tex2D(ReShade::BackBuffer, uv - sd1).xyz;
const float3 s20 = tex2D(ReShade::BackBuffer, uv - sd2).xyz;
const float3 s22 = tex2D(ReShade::BackBuffer, uv + sd1).xyz;
const float3 s02 = tex2D(ReShade::BackBuffer, uv + sd2).xyz;
const float3 c00 = tex2D(ReShade::BackBuffer, uv - dg1).xyz;
const float3 c22 = tex2D(ReShade::BackBuffer, uv + dg1).xyz;
const float3 c20 = tex2D(ReShade::BackBuffer, uv - dg2).xyz;
const float3 c02 = tex2D(ReShade::BackBuffer, uv + dg2).xyz;
const float3 c10 = tex2D(ReShade::BackBuffer, uv - ddy).xyz;
const float3 c21 = tex2D(ReShade::BackBuffer, uv + ddx).xyz;
const float3 c12 = tex2D(ReShade::BackBuffer, uv + ddy).xyz;
const float3 c01 = tex2D(ReShade::BackBuffer, uv - ddx).xyz;
const float3 dt = float3(1.0,1.0,1.0);
#line 322
const float d1=dot(abs(c00-c22),dt)+0.0001;
const float d2=dot(abs(c20-c02),dt)+0.0001;
const float hl=dot(abs(c01-c21),dt)+0.0001;
const float vl=dot(abs(c10-c12),dt)+0.0001;
const float m1=dot(abs(s00-s22),dt)+0.0001;
const float m2=dot(abs(s02-s20),dt)+0.0001;
#line 329
const float3 t1=(hl*(c10+c12)+vl*(c01+c21)+(hl+vl)*c11)/(3.0*(hl+vl));
const float3 t2=(d1*(c20+c02)+d2*(c00+c22)+(d1+d2)*c11)/(3.0*(d1+d2));
#line 332
float3 color =.25*(t1+t2+(m2*(s00+s22)+m1*(s02+s20))/(m1+m2));
#line 334
const float3 scolor1 = plant(pow(max(color, 0.0), saturation.xxx), max(max(color.r,color.g),color.b));
const float luma = dot(color, float3(0.299, 0.587, 0.114));
const float3 scolor2 = lerp(luma.xxx, color, saturation);
color = (saturation > 1.0) ? scolor1 : scolor2;
#line 339
return float4 (pow(max(color, 0.0), float3(1.0, 1.0, 1.0) * MaskGamma),1.0);
}
#line 343
float4 PASS_SH1(float4 pos : SV_Position, float2 uv : TexCoord) : SV_Target
{
float4 color = tex2D(ShinraAdvanced01SL, uv) * 0.19744746769063704;
color += tex2D(ShinraAdvanced01SL, uv + float2(1.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.1746973469158936;
color += tex2D(ShinraAdvanced01SL, uv - float2(1.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.1746973469158936;
color += tex2D(ShinraAdvanced01SL, uv + float2(2.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.12099884565428047;
color += tex2D(ShinraAdvanced01SL, uv - float2(2.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.12099884565428047;
color += tex2D(ShinraAdvanced01SL, uv + float2(3.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.06560233156931679;
color += tex2D(ShinraAdvanced01SL, uv - float2(3.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.06560233156931679;
color += tex2D(ShinraAdvanced01SL, uv + float2(4.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.027839605612666265;
color += tex2D(ShinraAdvanced01SL, uv - float2(4.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.027839605612666265;
color += tex2D(ShinraAdvanced01SL, uv + float2(5.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.009246250740395456;
color += tex2D(ShinraAdvanced01SL, uv - float2(5.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.009246250740395456;
color += tex2D(ShinraAdvanced01SL, uv + float2(6.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.002403157286908872;
color += tex2D(ShinraAdvanced01SL, uv - float2(6.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.002403157286908872;
color += tex2D(ShinraAdvanced01SL, uv + float2(7.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.00048872837522002;
color += tex2D(ShinraAdvanced01SL, uv - float2(7.0*glow_size * ReShade::GetPixelSize().x, 0.0)) * 0.00048872837522002;
#line 361
return color;
}
#line 364
float4 PASS_SH2(float4 pos : SV_Position, float2 uv : TexCoord) : SV_Target
{
float4 color = tex2D(ShinraAdvanced02SL, uv) * 0.19744746769063704;
color += tex2D(ShinraAdvanced02SL, uv + float2(0.0, 1.0*glow_size * ReShade::GetPixelSize().y)) * 0.1746973469158936;
color += tex2D(ShinraAdvanced02SL, uv - float2(0.0, 1.0*glow_size * ReShade::GetPixelSize().y)) * 0.1746973469158936;
color += tex2D(ShinraAdvanced02SL, uv + float2(0.0, 2.0*glow_size * ReShade::GetPixelSize().y)) * 0.12099884565428047;
color += tex2D(ShinraAdvanced02SL, uv - float2(0.0, 2.0*glow_size * ReShade::GetPixelSize().y)) * 0.12099884565428047;
color += tex2D(ShinraAdvanced02SL, uv + float2(0.0, 3.0*glow_size * ReShade::GetPixelSize().y)) * 0.06560233156931679;
color += tex2D(ShinraAdvanced02SL, uv - float2(0.0, 3.0*glow_size * ReShade::GetPixelSize().y)) * 0.06560233156931679;
color += tex2D(ShinraAdvanced02SL, uv + float2(0.0, 4.0*glow_size * ReShade::GetPixelSize().y)) * 0.027839605612666265;
color += tex2D(ShinraAdvanced02SL, uv - float2(0.0, 4.0*glow_size * ReShade::GetPixelSize().y)) * 0.027839605612666265;
color += tex2D(ShinraAdvanced02SL, uv + float2(0.0, 5.0*glow_size * ReShade::GetPixelSize().y)) * 0.009246250740395456;
color += tex2D(ShinraAdvanced02SL, uv - float2(0.0, 5.0*glow_size * ReShade::GetPixelSize().y)) * 0.009246250740395456;
color += tex2D(ShinraAdvanced02SL, uv + float2(0.0, 6.0*glow_size * ReShade::GetPixelSize().y)) * 0.002403157286908872;
color += tex2D(ShinraAdvanced02SL, uv - float2(0.0, 6.0*glow_size * ReShade::GetPixelSize().y)) * 0.002403157286908872;
color += tex2D(ShinraAdvanced02SL, uv + float2(0.0, 7.0*glow_size * ReShade::GetPixelSize().y)) * 0.00048872837522002;
color += tex2D(ShinraAdvanced02SL, uv - float2(0.0, 7.0*glow_size * ReShade::GetPixelSize().y)) * 0.00048872837522002;
#line 382
return color;
}
#line 385
float3 gc(float3 c)
{
const float mc = max(max(c.r,c.g),c.b);
const float mg = pow(max(mc, 0.0), 1.0/gamma_c);
return c * mg/(mc + 1e-8);
}
#line 394
float3 Mask(float2 pos, float mx)
{
float2 pos0 = pos;
pos.y = floor(pos.y/masksize);
#line 399
float stagg_lvl = 1.0;
if (frac(abs(mshift)) > 0.25 && abs(mshift) > 1.25)
stagg_lvl = 2.0;
const float next_line = float(frac((pos.y/stagg_lvl)*0.5) > 0.25);
pos0.x = (mshift > -0.25) ? (pos0.x + next_line * floor(mshift)) : (pos0.x + floor(pos.y / stagg_lvl) * floor(abs(mshift)));
pos = floor(pos0/masksize);
#line 406
float3 mask = float3(maskDark, maskDark, maskDark);
const float3 one = float3(1.0.xxx);
const float dark_compensate  = lerp(max( clamp( lerp (mcut, maskstr, mx),0.0, 1.0) - 0.5, 0.0) + 1.0, 1.0, mx);
const float mc = 1.0 - max(maskstr, 0.0);
#line 412
if (shadowMask == -1.0)
{
mask = float3(1.0.xxx);
}
#line 418
else if (shadowMask == 0.0)
{
pos.x = frac(pos.x*0.5);
if (pos.x < 0.49)
{
mask.r = 1.0;
mask.g = mc;
mask.b = 1.0;
}
else
{
mask.r = mc;
mask.g = 1.0;
mask.b = mc;
}
}
#line 436
else if (shadowMask == 1.0)
{
float lline = maskLight;
float odd  = 0.0;
#line 441
if (frac(pos.x/6.0) < 0.49)
odd = 1.0;
if (frac((pos.y + odd)/2.0) < 0.49)
lline = maskDark;
#line 446
pos.x = frac(pos.x/3.0);
#line 448
if (pos.x < 0.3)
mask.r = maskLight;
else if (pos.x < 0.6)
mask.g = maskLight;
else
mask.b = maskLight;
#line 455
mask *= lline;
}
#line 459
else if (shadowMask == 2.0)
{
pos.x = frac(pos.x/3.0);
#line 463
if (pos.x < 0.3)
mask.r = maskLight;
else if (pos.x < 0.6)
mask.g = maskLight;
else
mask.b = maskLight;
}
#line 472
else if (shadowMask == 3.0)
{
pos.x += pos.y*3.0;
pos.x  = frac(pos.x/6.0);
#line 477
if (pos.x < 0.3)
mask.r = maskLight;
else if (pos.x < 0.6)
mask.g = maskLight;
else
mask.b = maskLight;
}
#line 486
else if (shadowMask == 4.0)
{
pos.xy = floor(pos.xy*float2(1.0, 0.5));
pos.x += pos.y*3.0;
pos.x  = frac(pos.x/6.0);
#line 492
if (pos.x < 0.3)
mask.r = maskLight;
else if (pos.x < 0.6)
mask.g = maskLight;
else
mask.b = maskLight;
}
#line 501
else if (shadowMask == 5.0)
{
mask = float3(0.0.xxx);
pos.x = frac(pos.x/2.0);
if  (pos.x < 0.49)
{	mask.r  = 1.0;
mask.b  = 1.0;
}
else
{
mask.g = 1.0;
}
mask = clamp(lerp( lerp(one, mask, mcut), lerp(one, mask, maskstr), mx), 0.0, 1.0) * dark_compensate;
}
#line 517
else if (shadowMask == 6.0)
{
mask = float3(0.0.xxx);
pos.x = frac(pos.x/3.0);
if (pos.x < 0.3)
mask.r = 1.0;
else if (pos.x < 0.6)
mask.g = 1.0;
else
mask.b = 1.0;
mask = clamp(lerp( lerp(one, mask, mcut), lerp(one, mask, maskstr), mx), 0.0, 1.0) * dark_compensate;
}
#line 531
else if (shadowMask == 7.0)
{
mask = float3(0.0.xxx);
pos.x = frac(pos.x/2.0);
if  (pos.x < 0.49)
mask  = 0.0.xxx;
else
mask = 1.0.xxx;
mask = clamp(lerp( lerp(one, mask, mcut), lerp(one, mask, maskstr), mx), 0.0, 1.0) * dark_compensate;
}
#line 543
else if (shadowMask == 8.0)
{
mask = float3(0.0.xxx);
pos.x = frac(pos.x/3.0);
if (pos.x < 0.3)
mask = 0.0.xxx;
else if (pos.x < 0.6)
mask = 1.0.xxx;
else
mask = 1.0.xxx;
mask = clamp(lerp( lerp(one, mask, mcut), lerp(one, mask, maskstr), mx), 0.0, 1.0) * dark_compensate;
}
#line 557
else if (shadowMask == 9.0)
{
mask = float3(0.0.xxx);
pos.x = frac(pos.x/3.0);
if (pos.x < 0.3)
mask    = 0.0.xxx;
else if (pos.x < 0.6)
mask.rb = 1.0.xx;
else
mask.g  = 1.0;
mask = clamp(lerp( lerp(one, mask, mcut), lerp(one, mask, maskstr), mx), 0.0, 1.0) * dark_compensate;
}
#line 571
else if (shadowMask == 10.0)
{
mask = float3(0.0.xxx);
pos.x = frac(pos.x * 0.25);
if (pos.x < 0.2)
mask  = 0.0.xxx;
else if (pos.x < 0.4)
mask.r = 1.0;
else if (pos.x < 0.7)
mask.g = 1.0;
else
mask.b = 1.0;
mask = clamp(lerp( lerp(one, mask, mcut), lerp(one, mask, maskstr), mx), 0.0, 1.0) * dark_compensate;
}
#line 587
else if (shadowMask == 11.0)
{
mask = float3(0.0.xxx);
pos.x = frac(pos.x * 0.25);
if (pos.x < 0.2)
mask.r  = 1.0;
else if (pos.x < 0.4)
mask.rg = 1.0.xx;
else if (pos.x < 0.7)
mask.gb = 1.0.xx;
else
mask.b  = 1.0;
mask = clamp(lerp( lerp(one, mask, mcut), lerp(one, mask, maskstr), mx), 0.0, 1.0) * dark_compensate;
}
else if (shadowMask == 12.0)
{
mask = float3(0.0.xxx);
pos.x = frac(pos.x * 0.25);
if (pos.x < 0.2)
mask.r  = 1.0;
else if (pos.x < 0.4)
mask.rb = 1.0.xx;
else if (pos.x < 0.7)
mask.gb = 1.0.xx;
else
mask.g  = 1.0;
mask = clamp(lerp( lerp(one, mask, mcut), lerp(one, mask, maskstr), mx), 0.0, 1.0) * dark_compensate;
}
#line 616
const float maskmin = min(min(mask.r,mask.g),mask.b);
return (mask - maskmin) * maskboost + maskmin;
}
#line 621
float SlotMask(float2 pos, float m)
{
if ((slotmask + slotmask1) == 0.0)
{
return 1.0;
}
else
{
pos = floor(pos/smasksize);
const float mlen = slotwidth*2.0;
const float px = frac(pos.x/mlen);
const float py = floor(frac(pos.y/(2.0*double_slot))*2.0*double_slot);
const float slot_dark = lerp(1.0-slotmask1, 1.0-slotmask, m);
float slot = 1.0;
if (py == 0.0 && px <  0.5)
slot = slot_dark;
else if (py == double_slot && px >= 0.5)
slot = slot_dark;
#line 640
return slot;
}
}
#line 644
float3 declip(float3 c, float b)
{
float m = max(max(c.r,c.g),c.b);
if (m > b)
c = c*b/m;
return c;
}
#line 652
float2 Warp(float2 pos)
{
pos  = pos*2.0-1.0;
pos  = lerp(pos, float2(pos.x*rsqrt(1.0-c_shape*pos.y*pos.y), pos.y*rsqrt(1.0-c_shape*pos.x*pos.x)), float2(warpX, warpY)/c_shape);
return pos*0.5 + 0.5;
}
#line 659
float corner(float2 pos) {
const float2 b = float2(bsize1, bsize1) *  float2(1.0, ReShade::GetPixelSize().x/ReShade::GetPixelSize().y) * 0.05;
pos = clamp(pos, 0.0, 1.0);
pos = abs(2.0*(pos - 0.5));
float2 res = (bsize1 == 0.0) ? 1.0.xx : lerp(0.0.xx, 1.0.xx, smoothstep(1.0.xx, 1.0.xx-b, sqrt(pos)));
res = pow(max(res, 0.0), sborder.xx);
return sqrt(res.x*res.y);
}
#line 669
void fetch_pixel (inout float3 c, inout float3 b, float2 coord, float2 bcoord)
{
const float stepx = ReShade::GetPixelSize().x;
const float stepy = ReShade::GetPixelSize().y;
#line 674
const float ds = decons;
#line 676
const float2 dx = float2(stepx, 0.0);
const float2 dy = float2(0.0, stepy);
#line 679
const float posx = 2.0*coord.x - 1.0;
const float posy = 2.0*coord.y - 1.0;
#line 682
const float2 rc = deconrr * dx + deconrry*dy;
const float2 gc = deconrg * dx + deconrgy*dy;
const float2 bc = deconrb * dx + deconrby*dy;
#line 686
float r1 = tex2D(ShinraAdvanced01SL, coord + rc).r;
float g1 = tex2D(ShinraAdvanced01SL, coord + gc).g;
float b1 = tex2D(ShinraAdvanced01SL, coord + bc).b;
#line 690
float3 d = float3(r1, g1, b1);
c = clamp(lerp(c, d, ds), 0.0, 1.0);
#line 693
r1 = tex2D(ShinraAdvanced03SL, bcoord + rc).r;
g1 = tex2D(ShinraAdvanced03SL, bcoord + gc).g;
b1 = tex2D(ShinraAdvanced03SL, bcoord + bc).b;
#line 697
d = float3(r1, g1, b1);
b = clamp(lerp(b, d, ds), 0.0, 1.0);
}
#line 702
float3 WMASK(float4 pos : SV_Position, float2 uv : TexCoord) : SV_Target
{
#line 705
const float2 coord = Warp(uv);
#line 707
const float w3 = 1.0;
const float2 dx = float2(0.001, 0.0);
const float3 color0 = tex2D(ShinraAdvanced01SL, coord - dx).rgb;
float3 color  = tex2D(ShinraAdvanced01SL, coord).rgb;
const float3 color1 = tex2D(ShinraAdvanced01SL, coord + dx).rgb;
float3 b11 = tex2D(ShinraAdvanced03SL, coord).rgb;
#line 714
fetch_pixel(color, b11, coord, coord);
#line 716
const float3 mcolor = max(max(color0,color),color1);
float mx = max(max(mcolor.r, mcolor.g), mcolor.b);
mx = pow(max(mx, 0.0), 1.4/MaskGamma);
#line 720
const float2 pos1 = floor(uv/ReShade::GetPixelSize());
#line 722
float3 cmask = Mask(pos1, mx);
#line 724
if (float(mask_layout) > 0.5)
cmask = cmask.rbg;
#line 727
color = gc(color)*brightboost;
#line 729
const float3 orig1 = color;
const float3 one = float3(1.0,1.0,1.0);
const float colmx = max(max(orig1.r,orig1.g),orig1.b)/w3;
#line 733
color*=cmask;
#line 735
color = min(color, 1.0);
#line 737
color*=SlotMask(pos1, mx);
#line 739
float3 Bloom1 = b11;
Bloom1 = min(Bloom1*(orig1+color), max(0.5*(colmx + orig1 - color),0.001*Bloom1));
Bloom1 = 0.5*(Bloom1 + lerp(Bloom1, lerp(colmx*orig1, Bloom1, 0.5), 1.0-color));
#line 743
Bloom1 = Bloom1 * lerp(1.0, 2.0-colmx, bdist);
#line 745
Bloom1 = bloom*Bloom1;
#line 747
color = color + Bloom1;
color = color + glow*b11;
#line 750
color = min(color, 1.0);
#line 752
color = min(color, lerp(min(cmask,1.0),one,0.5));
#line 754
float maxb = max(max(b11.r,b11.g),b11.b);
maxb = sqrt(maxb);
float3 Bloom = b11;
#line 758
Bloom = lerp(0.5*(Bloom + Bloom*Bloom), Bloom*Bloom, colmx);
color = color + (0.75+maxb)*Bloom*(0.75 + 0.70*pow(max(colmx, 0.0),0.33333))*lerp(1.0,w3,0.5*colmx)*lerp(one,cmask,0.35 + 0.4*maxb)*halation;
#line 761
color = pow(max(color, 0.0), float3(1.0,1.0,1.0)/MaskGamma);
#line 763
color = color*corner(coord);
#line 765
return color;
}
#line 768
technique MaskGlowAdvanced
{
#line 771
pass bloom1
{
VertexShader = PostProcessVS;
PixelShader = PASS_SH0;
RenderTarget = ShinraAdvanced01L;
}
#line 778
pass bloom2
{
VertexShader = PostProcessVS;
PixelShader = PASS_SH1;
RenderTarget = ShinraAdvanced02L;
}
#line 785
pass bloom3
{
VertexShader = PostProcessVS;
PixelShader = PASS_SH2;
RenderTarget = ShinraAdvanced03L;
}
#line 792
pass mask
{
VertexShader = PostProcessVS;
PixelShader = WMASK;
}
}

