// COLOR_HEIGHT=12
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\ColorSort_CS.fx"
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
#line 44 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\ColorSort_CS.fx"
#line 49
namespace COBRA_XCOL
{
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\CobraUtility.fxh"
#line 64 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\ColorSort_CS.fx"
#line 92
uniform uint UI_RotationAngle <
ui_label     = " Angle of Rotation";
ui_type      = "slider";
ui_spacing   = 2;
ui_min       = 0;
ui_max       = 360;
ui_units     = "°";
ui_step      = 1;
ui_tooltip   = "Rotation of the sorting axis.";
ui_category  = "\n / General Options /\n";
>                = 0;
#line 104
uniform float UI_MaskingNoise <
ui_label     = " Masking Noise";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 1.001;
ui_step      = 0.001;
ui_tooltip   = "Strength of the noise applied to mask itself.";
ui_category  = "\n / General Options /\n";
>                = 0.000;
#line 114
uniform float UI_NoiseSize <
ui_label     = " Noise Size";
ui_type      = "slider";
ui_min       = 0.001;
ui_max       = 1.000;
ui_step      = 0.001;
ui_tooltip   = "Size of the noise texture. A lower value means larger noise pixels.";
ui_category  = "\n / General Options /\n";
>                = 1.000;
#line 124
uniform bool UI_ReverseSort <
ui_label     = " Reverse Sorting";
ui_tooltip   = "While active, it sorts from dark to bright. Otherwise it will sort from bright to dark.";
ui_category  = "\n / General Options /\n";
>                = false;
#line 130
uniform bool UI_HotsamplingMode <
ui_label     = " Hotsampling Mode";
ui_tooltip   = "The noise will be the same at all resolutions. Activate this, then adjust your options\n"
"and it will stay the same at all resolutions. Turn this off when you do not intend\n"
"to hotsample.";
ui_category  = "\n / General Options /\n";
>                = false;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\CobraUtility.fxh"
#line 114
uniform bool UI_ShowMask <
ui_label     = " Show Mask";
ui_spacing   = 2;
ui_tooltip   = "Show the masked pixels. White areas will be preserved, black/grey areas can be affected by\n"
"the shaders encompassed.";
ui_category  = "\n / General Options /\n";
>                = false;
#line 122
uniform bool UI_InvertMask <
ui_label     = " Invert Mask";
ui_tooltip   = "Invert the mask.";
ui_category  = "\n / General Options /\n";
>                = false;
#line 128
uniform bool UI_FilterColor <
ui_label     = " Filter by Color";
ui_spacing   = 2;
ui_tooltip   = "Activates the color masking option.";
ui_category  = "\n /  Color Masking  /\n";
>                = false;
#line 135
uniform bool UI_ShowSelectedHue <
ui_label     = " Show Selected Hue";
ui_tooltip   = "Display the currently selected hue range at the top of the image.";
ui_category  = "\n /  Color Masking  /\n";
>                = false;
#line 141
uniform float UI_Lightness <
ui_label     = " Lightness";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 1.000;
ui_step      = 0.001;
ui_tooltip   = "Lightness describes the perceived luminance of a color in comparsion to perceptually uniform\n"
"greyscale. In simple terms, it is comparable to brightness.";
ui_category  = "\n /  Color Masking  /\n";
>                = 1.000;
#line 152
uniform float UI_LightnessRange <
ui_label     = " Lightness Range";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 1.001;
ui_step      = 0.001;
ui_tooltip   = "The tolerance around the Lightness.";
ui_category  = "\n /  Color Masking  /\n";
>                = 1.001;
#line 162
uniform float UI_LightnessEdge <
ui_label     = " Lightness Fade";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 1.000;
ui_step      = 0.001;
ui_tooltip   = "The smoothness beyond the Lightness range.";
ui_category  = "\n /  Color Masking  /\n";
hidden       = true;
>                = 0.000;
#line 173
uniform float UI_Chroma <
ui_label     = " Chroma";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 1.000;
ui_step      = 0.001;
ui_tooltip   = "Chroma describes how distinct a color is from a grey tone of the same lightness.\n"
"Pure hues possess high chroma, tints and shades possess a lower chroma, with\n"
"pure grey at zero.";
ui_category  = "\n /  Color Masking  /\n";
>                = 1.000;
#line 185
uniform float UI_ChromaRange <
ui_label     = " Chroma Range";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 1.001;
ui_step      = 0.001;
ui_tooltip   = "The tolerance around the Chroma.";
ui_category  = "\n /  Color Masking  /\n";
>                = 1.001;
#line 195
uniform float UI_ChromaEdge <
ui_label     = " Chroma Fade";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 1.000;
ui_step      = 0.001;
ui_tooltip   = "The smoothness beyond the Chroma range.";
ui_category  = "\n /  Color Masking  /\n";
hidden       = true;
>                = 0.000;
#line 206
uniform float UI_Hue <
ui_label     = " Hue";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 1.000;
ui_step      = 0.001;
ui_tooltip   = "Hue describes the color category. It can be red, orange, yellow, green, blue,\n"
"violet or inbetween.";
ui_category  = "\n /  Color Masking  /\n";
>                = 1.000;
#line 217
uniform float UI_HueRange <
ui_label     = " Hue Range";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 0.501;
ui_step      = 0.001;
ui_tooltip   = "The tolerance around the hue.";
ui_category  = "\n /  Color Masking  /\n";
>                = 0.501;
#line 227
uniform float UI_HueEdge <
ui_label     = " Hue Fade";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 0.501;
ui_step      = 0.001;
ui_tooltip   = "The smoothness beyond the hue range.";
ui_category  = "\n /  Color Masking  /\n";
hidden       = true;
>                = 0.000;
#line 238
uniform bool UI_FilterDepth <
ui_label     = " Filter By Depth";
ui_spacing   = 2;
ui_tooltip   = "Activates the depth masking option.";
ui_category  = "\n /  Depth Masking  /\n";
>                = false;
#line 245
uniform float UI_FocusDepth <
ui_label     = " Focus Depth";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 1.000;
ui_step      = 0.001;
ui_tooltip   = "Manual focus depth of the point which has the focus. Ranges from 0.0, which means camera is\n"
"the focus plane, till 1.0 which means the horizon is the focus plane.";
ui_category  = "\n /  Depth Masking  /\n";
>                = 0.030;
#line 256
uniform float UI_FocusRangeDepth <
ui_label     = " Focus Range";
ui_type      = "slider";
ui_min       = 0.0;
ui_max       = 1.000;
ui_step      = 0.001;
ui_tooltip   = "The range of the depth around the manual focus which should still be in focus.";
ui_category  = "\n /  Depth Masking  /\n";
>                = 0.020;
#line 266
uniform float UI_FocusEdgeDepth <
ui_label     = " Focus Fade";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 1.000;
ui_tooltip   = "The smoothness of the edge of the focus range. Range from 0.0, which means sudden transition,\n"
"till 1.0, which means the effect is smoothly fading towards camera and horizon.";
ui_step      = 0.001;
ui_category  = "\n /  Depth Masking  /\n";
hidden       = true;
>                = 0.000;
#line 278
uniform bool UI_Spherical <
ui_label     = " Spherical Focus";
ui_tooltip   = "Enables the mask in a sphere around the focus-point instead of a 2D plane.";
ui_category  = "\n /  Depth Masking  /\n";
>                = false;
#line 284
uniform int UI_SphereFieldOfView <
ui_label     = " Spherical Field of View";
ui_type      = "slider";
ui_min       = 1;
ui_max       = 180;
ui_units     = "°";
ui_tooltip   = "Specifies the estimated Field of View (FOV) you are currently playing with. Range from 1°,\n"
"till 180° (half the scene). Normal games tend to use values between 60° and 90°.";
ui_category  = "\n /  Depth Masking  /\n";
>                = 75;
#line 295
uniform float UI_SphereFocusHorizontal <
ui_label     = " Spherical Horizontal Focus";
ui_type      = "slider";
ui_min       = 0.0;
ui_max       = 1.0;
ui_tooltip   = "Specifies the location of the focus point on the horizontal axis. Range from 0, which means\n"
"left screen border, till 1 which means right screen border.";
ui_category  = "\n /  Depth Masking  /\n";
>                = 0.5;
#line 305
uniform float UI_SphereFocusVertical <
ui_label     = " Spherical Vertical Focus";
ui_type      = "slider";
ui_min       = 0.0;
ui_max       = 1.0;
ui_tooltip   = "Specifies the location of the focus point on the vertical axis. Range from 0, which means\n"
"upper screen border, till 1 which means bottom screen border.";
ui_category  = "\n /  Depth Masking  /\n";
>                = 0.5;
#line 141 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\ColorSort_CS.fx"
#line 142
uniform int UI_BufferEnd <
ui_type     = "radio";
ui_spacing  = 2;
ui_text     = " Preprocessor Options:\n * COLOR_HEIGHT (default value: 12) multiplied by 64 defines the "
"resolution of the effect along the sorting axis. The value needs to be integer. Smaller values "
"give performance at cost of visual fidelity. 8: Performance, 12: Default, 16: HD\n\n"
" Shader Version: " "0.7.0";
ui_label    = " ";
> ;
#line 160
texture TEX_HalfRes
{
Width  = 1920;
Height = (12) * 64;
#line 165
Format = RGBA8;
#line 171
};
#line 173
texture TEX_Noise < source = "uniform_noise.png";
>
{
Width  = 4096;
Height = 1024;
Format = R8;
};
#line 181
texture TEX_Mask
{
Width  = 1920;
Height = (12) * 64;
Format = R8; 
};
#line 188
texture TEX_Background
{
Width  = 1920;
Height = 1018;
#line 193
Format = RGBA8;
#line 199
};
#line 201
texture TEX_ColorSort
{
Width  = 1920;
Height = (12) * 64;
#line 206
Format = RGBA8;
#line 212
};
#line 216
sampler2D SAM_HalfRes    { Texture = TEX_HalfRes;    };
sampler2D SAM_Background { Texture = TEX_Background; };
sampler2D SAM_ColorSort  { Texture = TEX_ColorSort;  };
#line 220
sampler2D SAM_Noise
{
Texture   = TEX_Noise;
MagFilter = POINT;
MinFilter = POINT;
MipFilter = POINT;
};
#line 228
sampler2D SAM_Mask
{
Texture   = TEX_Mask;
MagFilter = POINT;
MinFilter = POINT;
MipFilter = POINT;
};
#line 238
storage STOR_ColorSort { Texture = TEX_ColorSort; };
#line 242
groupshared uint color_table[(12) * 64];
groupshared uint even_block[((uint)32)];
groupshared uint odd_block[((uint)32)];
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\CobraUtility.fxh"
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
#line 802
float3 screen_to_camera(float2 texcoord, float z)
{
const float FOVY = float(UI_SphereFieldOfView) * 3.1415927 / 180.0;
const float FAR  = 1000.0;
const float F    = cos(0.5 * FOVY) / sin(0.5 * FOVY);
const float AR   = ReShade::GetAspectRatio();
#line 809
float2 xy_screen = texcoord * 2.0 - 1.0;
float4 camera = float4(0.0, 0.0, 0.0, 0.0);
camera.z      = z;
camera.w      = -camera.z;
camera.y      = xy_screen.y * camera.w / F;
camera.x      = xy_screen.x * camera.w * AR / F;
return camera.xyz / FAR;
}
#line 819
float3 show_hue(float2 texcoord, float3 fragment)
{
const float RANGE = 0.145;
const float DEPTH = 0.06;
if (abs(texcoord.x - 0.5) < RANGE && texcoord.y < DEPTH)
{
float2 texcoord_new = float2(saturate(texcoord.x - 0.5 + RANGE)
/ (2.0 * RANGE), (1.0 - texcoord.y / DEPTH));
float3 oklch        = float3(0.75, 0.151 * texcoord_new.y,  texcoord_new.x * 2.0 * 3.1415927 - 3.1415927);
float3 oklch_norm   = normalize_oklch(oklch, false);
float3 col          = oklch_to_csp(oklch);
#line 834
float c             = abs(oklch_norm.y - UI_Chroma);
float c_edge        = saturate(c - (UI_ChromaRange));
c = 1.0 - smoothstep(0.0, UI_ChromaEdge, c_edge);
#line 839
float h             = min(float(abs(oklch_norm.z - UI_Hue)), float(1.0 - abs(oklch_norm.z - UI_Hue)));
h                   = h - rcp(100.0 * saturate((oklch_norm.y < 0.15 ? oklch_norm.y / 0.15 : 1.0) - 0.08)
+ 1.0);
float h_edge        = saturate(h - (UI_HueRange * 1.05 - 0.025));
h                   = 1.0 - smoothstep(0.0, UI_HueEdge, h_edge);
#line 845
fragment = lerp(0.5, col, c * h); 
}
#line 848
return fragment;
}
#line 852
float check_focus(float3 col, float scene_depth, float2 texcoord)
{
#line 855
float3 oklch      = csp_to_oklch(col);
float3 oklch_norm = normalize_oklch(oklch, true);
#line 859
float l = check_range(oklch_norm.x, UI_Lightness, UI_LightnessRange, UI_LightnessEdge);
#line 862
float c      = abs(oklch_norm.y - UI_Chroma);
float c_edge = saturate(c - (UI_ChromaRange));
c            = 1.0 - smoothstep(0.0, UI_ChromaEdge, c_edge);
#line 867
float h      = min(float(abs(oklch_norm.z - UI_Hue)), float(1.0 - abs(oklch_norm.z - UI_Hue)));
h            = h - rcp(100 * saturate((oklch_norm.y < 0.15 ? oklch_norm.y/0.15 : 1.0) - 0.08) + 1.0);
float h_edge = saturate(h - (UI_HueRange * 1.05 - 0.025));
h            = 1.0 - smoothstep(0.0, UI_HueEdge, h_edge);
#line 872
float is_color_focus = max(l * c * h, UI_FilterColor == 0);
#line 875
const float POW_FACTOR       = 2.0;
const float FOCUS_RANGE      = pow(UI_FocusRangeDepth, POW_FACTOR);
const float FOCUS_EDGE       = pow(UI_FocusEdgeDepth, POW_FACTOR);
const float FOCUS_DEPTH      = pow(UI_FocusDepth, POW_FACTOR);
const float FOCUS_FULL_RANGE = FOCUS_RANGE + FOCUS_EDGE;
float3 camera_sphere         = screen_to_camera(float2(UI_SphereFocusHorizontal, UI_SphereFocusVertical),
get_z_from_uniform(FOCUS_DEPTH));
float3 camera_pixel          = screen_to_camera(texcoord, get_z_from_depth(scene_depth));
float depth_diff             = UI_Spherical
? sqrt(dot(camera_sphere - camera_pixel, camera_sphere - camera_pixel))
: abs(scene_depth - FOCUS_DEPTH);
#line 887
float depth_val              = 1.0 - saturate((depth_diff > FOCUS_FULL_RANGE)
? 1.0 : smoothstep(FOCUS_RANGE, FOCUS_FULL_RANGE, depth_diff));
#line 890
depth_val                    = max(depth_val, UI_FilterDepth == 0);
float in_focus               = is_color_focus * depth_val;
return lerp(in_focus, 1.0 - in_focus, UI_InvertMask);
}
#line 255 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\ColorSort_CS.fx"
#line 258
float2 rotate(float2 texcoord, bool revert)
{
uint ANGLE     = UI_RotationAngle;
float2 rotated = texcoord;
#line 263
rotated = (ANGLE == 90)  ? float2(texcoord.y, texcoord.x) : rotated;
rotated = (ANGLE == 180) ? float2(1.0 - texcoord.x, 1.0 - texcoord.y) : rotated;
rotated = (ANGLE == 270) ? float2(1.0 - texcoord.y, 1.0 - texcoord.x) : rotated;
#line 268
if (!((ANGLE) % 90 == 0))
{
#line 272
ANGLE           = (frac((ANGLE + 180)*rcp(360)) * (360)); 
#line 274
const float PHI = ANGLE * 3.1415927 / 180.0;
#line 277
const float3 P01 = float3(0.0, 1.0, -1.0);
#line 280
float2 PHISC;
sincos(PHI, PHISC.x, PHISC.y);
const float4 X = PHISC.y * P01.xxyy - PHISC.x * P01.xyxy;
const float4 Y = PHISC.x * P01.xxyy + PHISC.y * P01.xyxy;
#line 286
const float LVAL = min(min(X.x, X.y), min(X.z, X.w));
const float RVAL = max(max(X.x, X.y), max(X.z, X.w));
#line 290
float2 current      = PHISC.yx * texcoord.xx + P01.zy * PHISC.xy * texcoord.yy;
current.x           = revert ? current.x : LVAL + texcoord.x * (RVAL - LVAL);
float current_x_rel = abs(LVAL - current.x) / abs(LVAL - RVAL);
#line 296
float4 x_rel     = abs(X.xxyz - current.xxxx) / abs(X.xxyz - X.yzww);
float4 y_abs     = (1.0 - x_rel) * Y.xxyz + x_rel * Y.yzww;
uint4 in_between =    (X.xxyz < current.xxxx && current.xxxx < X.yzww)
|| (X.xxyz > current.xxxx && current.xxxx > X.yzww);
float3 ylow      = 1000.0;
float3 yhigh     = -1000.0;
float4 pre_ylow  = y_abs * in_between + 1000.0 * (1.0 - in_between);
float4 pre_yhigh = y_abs * in_between - 1000.0 * (1.0 - in_between);
ylow.z           = min(min(pre_ylow.x, pre_ylow.y), min(pre_ylow.z, pre_ylow.w));
yhigh.z          = max(max(pre_yhigh.x, pre_yhigh.y), max(pre_yhigh.z, pre_yhigh.w));
float4 pre_x     = float4(0.0, x_rel.y, x_rel.z, 1.0);
float4 pre_y     = float4(x_rel.x, 0.0, 1.0, x_rel.w);
ylow.x           = dot((ylow.z == pre_ylow) * pre_x, 1.0);
ylow.y           = dot((ylow.z == pre_ylow) * pre_y, 1.0);
yhigh.x          = dot((yhigh.z == pre_yhigh) * pre_x, 1.0);
yhigh.y          = dot((yhigh.z == pre_yhigh) * pre_y, 1.0);
#line 314
rotated = revert ? float2(current_x_rel, abs(yhigh.z - current.y) / abs(ylow.z - yhigh.z))
: (1.0 - texcoord.y) * yhigh.xy + texcoord.y * ylow.xy; 
#line 317
}
#line 319
return rotated;
}
#line 325
bool min_color(uint a, uint b)
{
return b < a;
}
#line 331
void merge_sort(int low, int high, int em)
{
uint temp[(12) * 64 / ((uint)32)];
[unroll] for (int i = 0; i < (12) * 64 / ((uint)32); i++)
{
temp[i] = color_table[low + i];
}
#line 339
for (int m = em; m <= high - low; m = 2 * m)
{
for (int i = low; i < high; i += 2 * m)
{
int from = i;
int mid  = i + m - 1;
int to   = min(i + 2 * m - 1, high);
#line 347
int k = from, i_2 = from, j = mid + 1;
while (i_2 <= mid && j <= to)
{
if (min_color(color_table[i_2], color_table[j]))
{
temp[k++ - low] = color_table[i_2++];
}
else
{
temp[k++ - low] = color_table[j++];
}
}
#line 360
while (i_2 < high && i_2 <= mid)
{
temp[k++ - low] = color_table[i_2++];
}
#line 365
for (i_2 = from; i_2 <= to; i_2++)
{
color_table[i_2] = temp[i_2 - low];
}
}
}
}
#line 381
void PS_MaskColor(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float fragment : SV_Target)
{
#line 388
float result = 0.0;
#line 391
float3 color      = tex2D(ReShade::BackBuffer, texcoord).rgb;
color             = enc_to_lin(color);
float scene_depth = ReShade::GetLinearizedDepth(texcoord);
bool in_focus     = check_focus(color, scene_depth, texcoord);
#line 396
if (!in_focus)
{
fragment = 1.0;
return;
}
#line 403
bool was_focus = true;
if (vpos.y > 1.0)
{
int2 prev_coords   = int2(floor(texcoord * float2(1920, 1018))) - int2(0, 1);
float3 color2      = tex2Dfetch(ReShade::BackBuffer, prev_coords).rgb;
color2             = enc_to_lin(color2);
float scene_depth2 = ReShade::GetLinearizedDepth(prev_coords / float2(1920, 1018));
was_focus          = check_focus(color2, scene_depth2, prev_coords / float2(1920, 1018));
}
#line 414
const uint HS_WIDTH = UI_HotsamplingMode ? 2036 : 1920;
const float PHI     = UI_RotationAngle * 3.1415927 / 180.0;
float2 PHISC;
sincos(PHI, PHISC.x, PHISC.y);
const float4 XCOLWH_NWH = float4(HS_WIDTH, (12) * 64, 4096, 1024);
float2 t_noise          = texcoord.xy * UI_NoiseSize;
t_noise                 = PHISC.yx * t_noise.xx + float2(-1.0, 1.0) * PHISC.xy * t_noise.yy;
t_noise                 = (frac((t_noise * XCOLWH_NWH.xy)*rcp(XCOLWH_NWH.zw)) * (XCOLWH_NWH.zw)) / XCOLWH_NWH.zw;
float noise             = tex2D(SAM_Noise, t_noise).r; 
#line 424
bool one = (1 - UI_MaskingNoise < noise) || (!was_focus);
fragment = one; 
}
#line 428
void PS_SaveBackground(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target)
{
fragment = tex2D(ReShade::BackBuffer, texcoord);
}
#line 435
void PS_PrepareColorSort(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target)
{
#line 438
float2 texcoord_new = rotate(texcoord, false);
fragment            = tex2D(ReShade::BackBuffer, texcoord_new); 
#line 441
float mask          = tex2D(SAM_Mask, texcoord_new).r;
fragment.a          = mask;
}
#line 446
void CS_ColorSort(uint3 id : SV_DispatchThreadID, uint3 tid : SV_GroupThreadID)
{
uint row            = tid.y * (12) * 64 / ((uint)32);
uint interval_start = row;
uint interval_end   = row - 1 + (12) * 64 / ((uint)32);
uint i;
#line 454
[unroll] for (i = 0; i <= 0 - 1 + (12) * 64 / ((uint)32); i++)
{
#line 457
float4 value         = tex2Dfetch(SAM_HalfRes, int2(id.x, i + row));
#line 463
uint interval        = value.a;         
uint brightness      = csp_to_luminance(value.rgb) * 1023.0; 
brightness           = brightness + (1023 - 2 * brightness) * UI_ReverseSort;
uint position        = i + row; 
color_table[i + row] = (interval << 21u) | (brightness << 11u) | position;
}
#line 470
barrier();
#line 472
if (tid.y == 0)
{
uint mask_val = 0;
for (i = 0; i < (12) * 64; i++)
{
#line 479
float focus_val = (color_table[i] >> 21u);
bool one        = focus_val > 0.5;
mask_val       += one;
uint final_val  = (2047 - mask_val);
color_table[i]  = (final_val << 21u) | (color_table[i] & uint(2097151));
}
}
#line 487
barrier();
#line 490
merge_sort(interval_start, interval_end, 1);
#line 493
uint key[((uint)32)];
uint key_sorted[((uint)32)];
uint sorted_array[2 * (12) * 64 / ((uint)32)];
for (i = 1; i < ((uint)32); i = 2 * i) 
{
barrier();
uint group_size = 2 * i;
#line 501
for (int j = 0; j < group_size; j++) 
{
int curr  = tid.y - (tid.y % group_size) + j;
key[curr] = color_table[curr * (12) * 64 / ((uint)32)];
}
#line 508
int idy_sorted;
int even = tid.y - (tid.y % group_size);
int k    = even;
int mid  = even + group_size / 2 - 1;
int odd  = mid + 1;
int to   = even + group_size - 1;
while (even <= mid && odd <= to)
{
if (min_color(key[even], key[odd]))
{
if (tid.y == even)
idy_sorted = k;
key_sorted[k++] = key[even++];
}
else
{
if (tid.y == odd)
idy_sorted = k;
key_sorted[k++] = key[odd++];
}
}
#line 531
while (even <= mid)
{
if (tid.y == even)
idy_sorted = k;
key_sorted[k++] = key[even++];
}
#line 538
while (odd <= to)
{
if (tid.y == odd)
idy_sorted = k;
key_sorted[k++] = key[odd++];
}
#line 546
int diff_sorted = (idy_sorted % group_size) - (tid.y % (group_size / 2));
uint pos1       = tid.y * (12) * 64 / ((uint)32);
bool is_even    = (tid.y % group_size) < group_size / 2;
if (is_even)
{
even_block[idy_sorted] = pos1;
if (diff_sorted == 0)
{
odd_block[idy_sorted] = (tid.y - (tid.y % group_size) + group_size / 2) * (12) * 64 / ((uint)32);
}
else
{
int odd_block_search_start = (tid.y - (tid.y % group_size) + group_size / 2 + diff_sorted - 1) * (12) * 64 / ((uint)32);
for (int i2 = 0; i2 < (12) * 64 / ((uint)32); i2++)
{ 
odd_block[idy_sorted] = odd_block_search_start + i2;
if (min_color(key_sorted[idy_sorted], color_table[odd_block_search_start + i2]))
{
break;
}
else
{
odd_block[idy_sorted] = odd_block_search_start + i2 + 1;
}
}
}
}
else
{
odd_block[idy_sorted] = pos1;
if (diff_sorted == 0)
{
even_block[idy_sorted] = (tid.y - (tid.y % group_size)) * (12) * 64 / ((uint)32);
}
else
{
int even_block_search_start = (tid.y - (tid.y % group_size) + diff_sorted - 1) * (12) * 64 / ((uint)32);
for (int i2 = 0; i2 < (12) * 64 / ((uint)32); i2++)
{
even_block[idy_sorted] = even_block_search_start + i2;
if (min_color(key_sorted[idy_sorted], color_table[even_block_search_start + i2]))
{
break;
}
else
{
even_block[idy_sorted] = even_block_search_start + i2 + 1;
}
}
}
}
#line 598
barrier();
#line 601
int even_start, even_end, odd_start, odd_end;
even_start = even_block[tid.y];
odd_start  = odd_block[tid.y];
if ((tid.y + 1) % group_size == 0)
{
even_end = (tid.y - (tid.y % group_size) + group_size / 2) * (12) * 64 / ((uint)32);
odd_end  = (tid.y - (tid.y % group_size) + group_size) * (12) * 64 / ((uint)32);
}
else
{
even_end = even_block[tid.y + 1];
odd_end  = odd_block[tid.y + 1];
}
#line 616
int even_counter = even_start;
int odd_counter  = odd_start;
int cc           = 0;
while (even_counter < even_end && odd_counter < odd_end)
{
if (min_color(color_table[even_counter], color_table[odd_counter]))
{
sorted_array[cc++] = color_table[even_counter++];
}
else
{
sorted_array[cc++] = color_table[odd_counter++];
}
}
#line 631
while (even_counter < even_end)
{
sorted_array[cc++] = color_table[even_counter++];
}
#line 636
while (odd_counter < odd_end)
{
sorted_array[cc++] = color_table[odd_counter++];
}
#line 641
barrier();
#line 644
int global_position = odd_start + even_start - (tid.y - (tid.y % group_size) + group_size / 2) * (12) * 64 / ((uint)32);
for (int w = 0; w < cc; w++)
{
color_table[global_position + w] = sorted_array[w];
}
}
#line 651
barrier();
#line 653
[unroll] for (i = 0; i < (12) * 64 / ((uint)32); i++)
{
uint y       = row + i;
float4 color = tex2Dfetch(SAM_HalfRes, int2(id.x, color_table[y] & 2047));
#line 658
tex2Dstore(STOR_ColorSort, float2(id.x, row + i), color);
}
}
#line 663
void PS_PrintColorSort(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target)
{
float2 texcoord_new  = rotate(texcoord, true);
fragment             = tex2D(SAM_Background, texcoord);
fragment.rgb         = enc_to_lin(fragment.rgb);
float fragment_depth = ReShade::GetLinearizedDepth(texcoord);
float4 sorted        = tex2D(SAM_ColorSort, texcoord_new);
sorted.rgb           = enc_to_lin(sorted.rgb);
fragment             = check_focus(fragment.rgb, fragment_depth, texcoord) ? sorted : fragment;
fragment.rgb         = UI_ShowMask ? 1.0 - tex2D(SAM_Mask, texcoord).rrr : fragment.rgb; 
fragment.rgb         = (UI_ShowSelectedHue * UI_FilterColor) ? show_hue(texcoord, fragment.rgb) : fragment.rgb;
fragment.rgb         = lin_to_enc(fragment.rgb);
}
#line 683
technique TECH_ColorSortMasking <
ui_label     = "Color Sort: Masking";
ui_tooltip   = "This is the masking part of the shader. It has to be placed above ColorSort: Main.\n"
"All effects between Masking and Main (e.g. Monochrome) will only apply to the sorted area.\n"
"------About-------\n"
"ColorSort_CS.fx can sort the image pixels by brightness along a user-specified axis.\n"
"You can filter the affected pixels by depth and by color.\n"
"The shader consumes a lot of resources. To balance between quality and performance,\n"
"adjust the preprocessor parameter COLOR_HEIGHT. Check the tooltip for further info.\n\n"
"Version:    " "0.7.0" "\nAuthor:     SirCobra\nCollection: CobraFX\n"
"            https://github.com/LordKobra/CobraFX";
>
{
pass MaskColor
{
VertexShader = PostProcessVS;
PixelShader  = PS_MaskColor;
RenderTarget = TEX_Mask;
}
#line 703
pass SaveBackground
{
VertexShader = PostProcessVS;
PixelShader  = PS_SaveBackground;
RenderTarget = TEX_Background;
}
}
#line 711
technique TECH_ColorSortMain <
ui_label     = "Color Sort: Main";
ui_tooltip   = "------About-------\n"
"ColorSort_CS.fx can sort the image pixels by brightness along a user-specified axis.\n"
"You can filter the affected pixels by depth and by color.\n"
"The shader consumes a lot of resources. To balance between quality and performance,\n"
"adjust the preprocessor parameter COLOR_HEIGHT. Check the tooltip for further info.\n\n"
"Version:    " "0.7.0" "\nAuthor:     SirCobra\nCollection: CobraFX\n"
"            https://github.com/LordKobra/CobraFX";
>
{
pass PrepareColorSort
{
VertexShader = PostProcessVS;
PixelShader  = PS_PrepareColorSort;
RenderTarget = TEX_HalfRes;
}
#line 729
pass sortColor
{
ComputeShader = CS_ColorSort<1, ((uint)32)>;
DispatchSizeX = 1920;
DispatchSizeY = 1;
}
#line 736
pass PrintColorSort
{
VertexShader = PostProcessVS;
PixelShader  = PS_PrintColorSort;
}
}
#line 745
} 

