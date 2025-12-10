#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\RealLongExposure.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Reshade.fxh"
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
#line 39 "C:\Program Files\GShade\gshade-shaders\Shaders\RealLongExposure.fx"
#line 40
uniform float timer <
source = "timer";
> ;
#line 48
namespace COBRA_RLE
{
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\CobraUtility.fxh"
#line 62 "C:\Program Files\GShade\gshade-shaders\Shaders\RealLongExposure.fx"
#line 79
uniform float UI_ExposureDuration <
ui_label     = " Exposure Duration";
ui_type      = "slider";
ui_spacing   = 2;
ui_min       = 0.1;
ui_max       = 120.0;
ui_step      = 0.1;
ui_units     = "s";
ui_tooltip   = "Exposure duration in seconds.";
ui_category  = "\n / General Options /\n";
>                = 1.0;
#line 91
uniform bool UI_StartExposure <
ui_label     = " Start Exposure";
ui_tooltip   = "Click to start the exposure process. It will run for the given amount of seconds and then "
"freeze.\n"
"TIP: Bind this to a hotkey for convenient usage (right-click the button).";
ui_category  = "\n / General Options /\n";
>                = false;
#line 99
uniform bool UI_ShowProgress <
ui_label     = " Show Progress";
ui_tooltip   = "Display a circular progress bar at the top during the exposure.";
ui_category  = "\n / General Options /\n";
>                = false;
#line 105
uniform bool UI_ShowGreenOnFinish <
ui_label     = " Show Green Dot On Finish";
ui_tooltip   = "Display a green dot at the top to signalize the exposure has finished and entered preview "
"mode.";
ui_category  = "\n / General Options /\n";
>                = false;
#line 121
uniform float UI_ISO <
ui_label     = " ISO";
ui_type      = "slider";
ui_min       = 100.0;
ui_max       = 1600.0;
ui_step      = 1.0;
ui_tooltip   = "Sensitivity to light. 100 is normalized to the game. 1600 is 16 times the sensitivity.";
ui_category  = "\n / General Options /\n";
>                = 100.0;
#line 131
uniform float UI_Gamma <
ui_label     = " Highlight Boost";
ui_type      = "slider";
ui_min       = 0.4;
ui_max       = 4.4;
ui_step      = 0.01;
ui_tooltip   = "The gamma correction value. The higher this value, the more persistent highlights\n"
"will be. The default value is 1.";
ui_category  = "\n / General Options /\n";
>                = 1.0;
#line 142
uniform uint UI_Delay <
ui_label     = " Delay";
ui_type      = "slider";
ui_min       = 0;
ui_max       = 100;
ui_step      = 1;
ui_units     = "ms";
ui_tooltip   = "The delay before exposure starts in milliseconds.";
ui_category  = "\n / General Options /\n";
>                = 1;
#line 153
uniform int UI_BufferEnd <
ui_type     = "radio";
ui_spacing  = 2;
ui_text     = " Shader Version: " "0.6.0";
ui_label    = " ";
> ;
#line 168
texture TEX_Exposure
{
Width  = 1920;
Height = 1018;
Format = RGBA32F; 
};
#line 175
texture TEX_Timer
{
Width  = 1;
Height = 1;
Format = RGBA32F;
};
#line 199
texture TEX_SyncCount
{
Width  = 1;
Height = 1;
Format = R32U;
};
#line 210
sampler2D SAM_Exposure
{
Texture   = TEX_Exposure;
MagFilter = POINT;
MinFilter = POINT;
MipFilter = POINT;
};
#line 218
sampler2D SAM_Timer
{
Texture   = TEX_Timer;
MagFilter = POINT;
MinFilter = POINT;
MipFilter = POINT;
};
#line 247
storage2D<float4> STOR_Exposure { Texture = TEX_Exposure; };
storage2D<float4> STOR_Timer { Texture = TEX_Timer; };
storage<uint> STOR_SyncCount { Texture = TEX_SyncCount; };
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\CobraUtility.fxh"
#line 329
struct vs2ps
{
float4 vpos : SV_Position;
float4 uv : TEXCOORD0;
};
#line 335
vs2ps vs_basic(const uint id, float2 extras)
{
vs2ps o;
o.uv.x  = (id == 2) ? 2.0 : 0.0;
o.uv.y  = (id == 1) ? 2.0 : 0.0;
o.uv.zw = extras;
o.vpos  = float4(o.uv.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
return o;
}
#line 345
void VS_Clear(in uint id : SV_VertexID, out float4 position : SV_Position)
{
position = -3;
}
#line 350
void PS_Clear(float4 position : SV_Position, out float4 output0 : SV_TARGET0)
{
output0 = 0;
discard;
}
#line 361
float atan2_approx(float y, float x)
{
return acos(x * rsqrt(y * y + x * x)) * (y < 0 ? -1 : 1);
}
#line 369
float ign(float2 pixel)
{
return frac(52.9829189 * frac(0.06711056 * pixel.x + 0.00583715 * pixel.y));
}
#line 374
float3 interpolate(float3 a, float3 b, float3 c)
{
return abs(b - c) / abs(a - b);
}
#line 383
float3 srgb_to_xyz(float3 srgb)
{
const float3x3 M_SRGB_TO_XYZ = float3x3( 0.4124564, 0.3575761, 0.1804375,
0.2126729, 0.7151522, 0.0721750,
0.0193339, 0.1191920, 0.9503041  );
return mul(M_SRGB_TO_XYZ, srgb);
}
#line 391
float3 xyz_to_srgb(float3 xyz)
{
const float3x3 M_XYZ_TO_SRGB = float3x3(  3.2404542, -1.5371385, -0.4985314,
-0.9692660,  1.8760108,  0.0415560,
0.0556434, -0.2040259,  1.0572252  );
return mul(M_XYZ_TO_SRGB, xyz);
}
#line 399
float3 xyz_to_cielab(float3 xyz)
{
const float3 W_D65_XYZ  = float3(0.95047, 1.000, 1.08883);
const float EPSILON     = 216.0 / 24389.0;
const float KAPPA       = 24389.09 / 27.0;
#line 405
float3 xyz_r = xyz / W_D65_XYZ;
float3 f = xyz_r > EPSILON ? pow(abs(xyz_r), 1.0 / 3.0) : KAPPA / 116.0 * xyz_r + 16.0 / 116.0;
float3 lab = float3(0.0, 0.0, 0.0);
lab.x = 116.0 * f.y - 16.0;
lab.y = 500.0 * (f.x - f.y);
lab.z = 200.0 * (f.y - f.z);
return lab;
}
#line 414
float3 cielab_to_xyz(float3 lab)
{
const float3 W_D65_XYZ  = float3(0.95047, 1.000, 1.08883);
const float EPSILON     = 216.0 / 24389.0;
const float KAPPA       = 24389.09 / 27.0;
#line 420
float3 f = float3(0.0, 0.0, 0.0);
f.y = (lab.x + 16.0) / 116.0;
f.x = lab.y / 500.0 + f.y;
f.z = f.y - lab.z / 200.0;
float3 xyz = f > pow(EPSILON, 1.0 / 3.0) ? f * f * f : (f - 16.0 / 116.0) * (116.0 / KAPPA);
xyz = xyz * W_D65_XYZ;
return xyz;
}
#line 429
float3 xyz_to_oklab(float3 xyz)
{
const float3x3 M_XYZ_TO_LMS    = float3x3( 0.8189330101,  0.3618667424, -0.1288597137,
0.0329845436,  0.9293118715,  0.0361456387,
0.0482003018,  0.2643662691,  0.6338517070  );
#line 435
const float3x3 M_LMSD_TO_OKLAB = float3x3( 0.2104542553,  0.7936177850, -0.0040720468,
1.9779984951, -2.4285922050,  0.4505937099,
0.0259040371,  0.7827717662, -0.8086757660  );
float3 lms  = mul(M_XYZ_TO_LMS, xyz);
float3 lmsd = pow(abs(lms), 1.0 / 3.0);
return mul(M_LMSD_TO_OKLAB, lmsd);
}
#line 443
float3 oklab_to_xyz(float3 oklab)
{
const float3x3 M_LMS_TO_XYZ    = float3x3(  1.22701385, -0.55779998,  0.28125615,
-0.04058018,  1.11225687, -0.07167668,
-0.07638128, -0.42148198,  1.58616322  );
const float3x3 M_OKLAB_TO_LMSD = float3x3( 1.00000000,  0.39633779,  0.21580376,
1.00000001, -0.10556134, -0.06385417,
1.00000005, -0.08948418, -1.29148554  );
float3 lmsd = mul(M_OKLAB_TO_LMSD, oklab);
float3 lms  = pow(abs(lmsd), 3.0);
return mul(M_LMS_TO_XYZ, lms);
}
#line 456
float3 srgb_to_oklab(float3 srgb)
{
const float3x3 M_SRGB_TO_LMS = float3x3( 0.4122214708, 0.5363325363, 0.0514459929,
0.2119034982, 0.6806995451, 0.1073969566,
0.0883024619, 0.2817188376, 0.6299787005  );
const float3x3 M_LMSD_TO_OKLAB = float3x3( 0.2104542553,  0.7936177850, -0.0040720468,
1.9779984951, -2.4285922050,  0.4505937099,
0.0259040371,  0.7827717662, -0.8086757660  );
float3 lms = mul(M_SRGB_TO_LMS, srgb);
float3 lmsd = pow(abs(lms), 1.0 / 3.0);
return  mul(M_LMSD_TO_OKLAB, lmsd);
}
#line 469
float3 oklab_to_srgb(float3 oklab)
{
const float3x3 M_OKLAB_TO_LMSD = float3x3( 1.00000000,  0.39633779,  0.21580376,
1.00000001, -0.10556134, -0.06385417,
1.00000005, -0.08948418, -1.29148554  );
const float3x3 M_LMS_TO_SRGB = float3x3(  4.0767416621, -3.3077115913,  0.2309699292,
-1.2684380046,  2.6097574011, -0.3413193965,
-0.0041960863, -0.7034186147,  1.7076147010  );
float3 lmsd = mul(M_OKLAB_TO_LMSD, oklab);
float3 lms = pow(abs(lmsd), 3.0);
return mul(M_LMS_TO_SRGB, lms);
}
#line 482
float3 oklab_to_oklch(float3 oklab)
{
float l = oklab.x; 
float c = length(oklab.yz); 
float h = (c == 0) ? 0.0 : atan2_approx(oklab.z, oklab.y); 
return float3(l, c, h);
}
#line 490
float3 oklch_to_oklab(float3 oklch)
{
float l = oklch.x;
float a = oklch.y * cos(oklch.z);
float b = oklch.y * sin(oklch.z);
return float3(l, a, b);
}
#line 498
float3 rec2020_to_xyz(float3 rec2020)
{
const float3x3 M_REC2020_TO_XYZ = float3x3( 0.63695806, 0.14461690,  0.16888096,
0.26270020, 0.67799806,  0.05930171,
0.00000000, 0.02807269,  1.06098508  );
return mul(M_REC2020_TO_XYZ, rec2020);
}
#line 506
float3 xyz_to_rec2020(float3 xyz)
{
const float3x3 M_XYZ_TO_REC2020 = float3x3(  1.71665120, -0.35567077, -0.25336629,
-0.66668432,  1.61648118,  0.01576854,
0.01763985, -0.04277061,  0.94210314  );
return mul(M_XYZ_TO_REC2020, xyz);
}
#line 514
float3 rec2020_to_rec709(float3 rec2020)
{
const float3x3 M_REC2020_TO_REC709 = float3x3(  1.66049098, -0.58764111, -0.07284986,
-0.12455047,  1.13289988, -0.00834942,
-0.01815076, -0.10057889,  1.11872971  );
return mul(M_REC2020_TO_REC709, rec2020);
}
#line 522
float3 rec709_to_rec2020(float3 rec709)
{
const float3x3 M_REC709_TO_REC2020 = float3x3(  0.62740391,  0.32928302,  0.04331306,
0.06909728,  0.91954040,  0.01136231,
0.01639143,  0.08801330,  0.89559525  );
return mul(M_REC709_TO_REC2020, rec709);
}
#line 531
float3 srgb_to_hsv(float3 c)
{
const float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
float4 p       = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
float4 q       = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
float d        = q.x - min(q.w, q.y);
const float E  = 1.0e-10;
return float3(abs(q.z + (q.w - q.y) / (6.0 * d + E)), d / (q.x + E), q.x);
}
#line 541
float3 hsv_to_srgb(float3 c)
{
const float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
float3 p       = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
return float3(c.z * lerp(K.xxx, saturate(p - K.xxx), c.y));
}
#line 548
float3 csp_to_oklab(float3 csp)
{
#line 553
return srgb_to_oklab(csp);
#line 555
}
#line 557
float3 oklab_to_csp(float3 oklab)
{
#line 562
return oklab_to_srgb(oklab);
#line 564
}
#line 566
float3 csp_to_oklch(float3 csp)
{
return oklab_to_oklch(csp_to_oklab(csp));
}
#line 571
float3 oklch_to_csp(float3 oklch)
{
return oklab_to_csp(oklch_to_oklab(oklch));
}
#line 576
float csp_to_luminance(float3 csp)
{
#line 582
const float3 rec709_weight = float3(0.2126729, 0.7151522, 0.0721750);
return dot(csp, rec709_weight);
#line 585
}
#line 587
float3 csp_to_xyz(float3 csp)
{
#line 592
return srgb_to_xyz(csp);
#line 594
}
#line 596
float3 xyz_to_csp(float3 xyz)
{
#line 601
return xyz_to_srgb(xyz);
#line 603
}
#line 605
float3 rec709_to_csp(float3 c)
{
#line 610
return c;
#line 612
}
#line 616
float3 srgb_to_linear(float3 c)
{
#line 622
return (c < 0.04045) ? c / 12.92 : pow((abs(c) + 0.055) / 1.055, 2.4);
}
#line 625
float3 linear_to_srgb(float3 c)
{
#line 628
return (c < 0.0031308) ? c * 12.92 : 1.055 * pow(c, (1.0 / 2.4)) - 0.055;
}
#line 631
float3 scrgb_to_linear(float3 c)
{
c = c * 80.0 / 203.0;
#line 635
return rec709_to_rec2020(c);
}
#line 638
float3 linear_to_scrgb(float3 c)
{
c = rec2020_to_rec709(c);
return c * 203.0 / 80.0;
}
#line 644
float3 pq_eotf(float3 n) 
{
const float M1 = 2610.0 / 4096.0 * 0.25;
const float M2 = 2523.0 / 4096.0 * 128.0;
const float C1 = 3424.0 / 4096.0;
const float C2 = 2413.0 / 4096.0 * 32.0;
const float C3 = 2392.0 / 4096.0 * 32.0;
return pow(max( pow(n, 1.0 / M2) - C1, 0.0) / (C2 - C3 * pow(n, 1.0 / M2)), 1.0 / M1);
}
#line 654
float3 pq_inverse_eotf(float3 l) 
{
const float M1 = 2610.0 / 4096.0 * 0.25;
const float M2 = 2523.0 / 4096.0 * 128.0;
const float C1 = 3424.0 / 4096.0;
const float C2 = 2413.0 / 4096.0 * 32.0;
const float C3 = 2392.0 / 4096.0 * 32.0;
return pow((C1 + C2 * pow(l, M1)) / (1.0 + C3 * pow(l, M1)), M2);
}
#line 664
float3 pq_to_linear(float3 c)
{
c = pq_eotf(c);
return c * 10000.0 / 203.0;
}
#line 670
float3 linear_to_pq(float3 c)
{
c = c * 203.0 / 10000.0; 
return pq_inverse_eotf(c);
}
#line 676
float3 hlg_eotf(float3 es)
{
const float A = 0.17883277;
const float B = 1.0 - 4.0 * A;
const float C = 0.5 - A * log(4.0 * A);
return es < 0.5 ? (es * es) / 3.0 : (exp((es - C) / A) + B) / 12.0;
}
#line 684
float3 hlg_inverse_eotf(float3 e_in)
{
const float  A = 0.17883277;
const float  B = 1.0 - 4.0 * A;
const float  C = 0.5 - A * log(4.0 * A);
float3 e = saturate(e_in);
return e < 1.0 / 12.0 ? sqrt(3.0 * e) : A * log(12.0 * e - B) + C;
}
#line 693
float3 hlg_to_linear(float3 c)
{
c = hlg_eotf(c);
return c * 1000.0 / 203.0;
}
#line 699
float3 linear_to_hlg(float3 c)
{
#line 703
c = c * 203.0 / 1000.0; 
return hlg_inverse_eotf(c);
}
#line 707
float3 enc_to_lin(float3 c)
{
#line 718
return c;
#line 720
}
#line 722
float3 lin_to_enc(float3 c)
{
#line 733
return c;
#line 735
}
#line 737
float3 dither_linear_to_srgb(float3 linear_color, float2 pixel)
{
const float QUANT = 1.0 / (float(1 << 8) - 1.0);
float noise = ign(pixel);
float3 c0   = floor(lin_to_enc(linear_color) / QUANT) * QUANT;
float3 c1   = c0 + QUANT;
float3 ival = interpolate(enc_to_lin(c0), enc_to_lin(c1), linear_color);
ival        = noise > ival;
return lerp(c0, c1, ival);
}
#line 748
float3 dither_linear_to_encoding(float3 linear_color, float2 pixel)
{
#line 751
return dither_linear_to_srgb(linear_color, pixel);
#line 755
}
#line 761
float3 normalize_oklch(float3 oklch, bool hdr_range)
{
const float MAX = csp_to_oklab(float3((1000.0 / 203.0).xxx)).x;
float l_max = hdr_range ? MAX : 1.0; 
#line 766
return (oklch + float3(0.0, 0.0, 3.1415927)) / float3(l_max, 0.48, 2.0 * 3.1415927);
}
#line 769
float3 ui_to_csp(float3 c)
{
c = srgb_to_linear(c);
c = rec709_to_csp(c);
return c;
}
#line 776
float get_z_from_depth(float depth)
{
const float NEAR = 1.0;
const float FAR  = 1000.0;
#line 783
return depth * (FAR - NEAR) + NEAR;
}
#line 786
float get_z_from_uniform(float depth)
{
const float FAR  = 1000.0;
return depth * FAR;
}
#line 793
float check_range(float value, float ui_val, float ui_range, float ui_edge)
{
float val     = saturate(value);
float edge    = abs(value - ui_val) - ui_range;
return 1.0 - smoothstep(0.0, ui_edge, edge);
}
#line 261 "C:\Program Files\GShade\gshade-shaders\Shaders\RealLongExposure.fx"
#line 263
float3 get_exposure(float3 value)
{
float iso_norm = UI_ISO * 0.01;
value      = iso_norm * pow(abs(value), UI_Gamma);
return value;
}
#line 270
float3 show_progress(float2 texcoord, float3 fragment, float progress)
{
fragment          = enc_to_lin(fragment); 
const float2 POS  = float2(0.5, 0.07);
const float RANGE = 0.05;
const float2 AR   = float2((1920 * (1.0 / 1018)), 1.0);
float2 tx         = (texcoord - POS) * AR;
float angle       = (atan2_approx(tx.x, tx.y) + 3.1415927) / (2.0 * 3.1415927);
float intensity   = (sqrt(dot(abs(tx), abs(tx))) - RANGE) * 100.0;
intensity         = progress > 1.0 ? (1.0 - saturate(intensity)) * UI_ShowGreenOnFinish
: (1.0 - abs(intensity)) * UI_ShowProgress;
const float3 background_col = ui_to_csp(float3(0.0, 0.0, 0.0));
const float3 load_col       = ui_to_csp(float3(0.5, 1.0, 0.5));
if (intensity > 0.0 && intensity <= 1.0 && progress < 1.0)
{
fragment = lerp(fragment, background_col, 0.65 * saturate(intensity * 4.0)); 
}
#line 288
intensity = intensity * 0.7;
if (intensity > 0.0 && intensity <= 1.0 && progress > angle)
{
fragment.rgb = lerp(fragment, load_col, saturate(intensity * 4.0)); 
}
#line 294
return lin_to_enc(fragment);
}
#line 373
groupshared float4 timer_value[1];
#line 375
void CS_LongExposure(uint3 id : SV_DispatchThreadID, uint3 tid : SV_GroupThreadID, uint gi : SV_GroupIndex)
{
if (gi == 0)
{
timer_value[0].xy = tex2Dfetch(STOR_Timer, int2(0, 0)).xy;
timer_value[0].z  = timer % 16777216;
timer_value[0].w  = (UI_StartExposure && (abs(timer_value[0].z - timer_value[0].x) > UI_Delay)
&& (abs(timer_value[0].z - timer_value[0].x) < 1000.0 * UI_ExposureDuration));
uint passes = atomicAdd(STOR_SyncCount, int2(0, 0), 1u);
if (passes == (((1920 - 1) / 32) + 1) * (((1018 - 1) / 32) + 1) - 1)
{
float4 frag = 0.0;
frag.a      = 1.0;
if (!UI_StartExposure)
{
frag.x = timer_value[0].z;
}
else
{
frag.x = timer_value[0].x;
frag.y = timer_value[0].y + timer_value[0].w;
}
#line 398
atomicExchange(STOR_SyncCount, int2(0, 0), 0);
tex2Dstore(STOR_Timer, int2(0, 0), frag);
}
}
barrier();
[branch]
if(any(id.xy >= float2(1920, 1018)) || timer_value[0].w < 0.5)
return;
#line 407
float4 fragment = 1.0;
fragment.rgb    = tex2Dfetch(ReShade::BackBuffer, id.xy).rgb;
fragment.rgb    = enc_to_lin(fragment.rgb);
fragment.rgb    = get_exposure(fragment.rgb);
#line 413
fragment.a = timer_value[0].y < 0.5;
fragment.rgb += (1.0 - fragment.a) * tex2Dfetch(STOR_Exposure, id.xy).rgb;
#line 418
tex2Dstore(STOR_Exposure, id.xy, fragment);
}
#line 423
vs2ps VS_DisplayExposure(uint id : SV_VertexID)
{
float2 timer_values = tex2Dfetch(SAM_Timer, int2(0, 0)).rg;
vs2ps o             = vs_basic(id, timer_values);
#line 428
if (!UI_StartExposure)
o.vpos.xy = 0.0;
return o;
}
#line 433
void PS_DisplayExposure(vs2ps o, out float4 fragment : SV_Target)
{
#line 436
float2 timer_values = o.uv.zw;
float current_time  = timer % 16777216;
fragment            = float4(0.0, 0.0, 0.0, 1.0);
#line 440
float4 exposure_rgb = tex2Dfetch(SAM_Exposure, int2(floor(o.vpos.xy)));
float4 game_rgb     = tex2Dfetch(ReShade::BackBuffer, int2(floor(o.vpos.xy)));
#line 443
if (UI_StartExposure && timer_values.y)
{
fragment.rgb = exposure_rgb.rgb / timer_values.y;
fragment.rgb = pow(abs(fragment.rgb), 1.0 / UI_Gamma);
#line 450
fragment.rgb = lin_to_enc(fragment.rgb);
#line 452
}
else
{
fragment.rgba    = game_rgb.rgba;
}
#line 458
bool hide_progress = !UI_StartExposure || !(UI_ShowProgress || UI_ShowGreenOnFinish);
float progress     = (current_time - timer_values.x) / (1000.0 * UI_ExposureDuration);
fragment.rgb       = hide_progress
? fragment.rgb
: show_progress(o.uv.xy, fragment.rgb, progress).rgb;
}
#line 471
technique TECH_RealLongExposure <
ui_label     = "Realistic Long-Exposure";
ui_tooltip   = "------About-------\n"
"RealLongExposure.fx enables you to capture changes over time, like in long-exposure photography.\n"
"It will record the game's output for a user-defined amount of seconds, to create the final image,\n"
"just as a camera would do in real life.\n\n"
"Version:    " "0.6.0" "\nAuthor:     SirCobra\nCollection: CobraFX\n"
"            https://github.com/LordKobra/CobraFX";
>
{
#line 517
pass LongExposure
{
ComputeShader = CS_LongExposure<32, 32>;
DispatchSizeX = (((1920 - 1) / 32) + 1);
DispatchSizeY = (((1018 - 1) / 32) + 1);
}
#line 526
pass DisplayExposure
{
VertexShader = VS_DisplayExposure;
PixelShader  = PS_DisplayExposure;
}
}
}

