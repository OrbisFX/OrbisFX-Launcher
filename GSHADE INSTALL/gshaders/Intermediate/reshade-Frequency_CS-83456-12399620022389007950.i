#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\Frequency_CS.fx"
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
#line 44 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\Frequency_CS.fx"
#line 45
uniform float timer <
source = "timer";
> ;
#line 53
namespace COBRA_XFRQ
{
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\CobraUtility.fxh"
#line 68 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\Frequency_CS.fx"
#line 89
uniform uint UI_Frequency <
ui_label     = " Period";
ui_type      = "slider";
ui_spacing   = 2;
ui_min       = 1;
ui_max       = 200;
ui_step      = 1;
ui_tooltip   = "Determines the frequency of the wave appearance. Low values let the wave appear in\n"
"short intervals.";
ui_category  = "\n / General Options /\n";
>                = 20;
#line 101
uniform float UI_Thickness <
ui_label     = " Thickness";
ui_type      = "slider";
ui_min       = 1;
ui_max       = 100;
ui_step      = 1;
ui_units     = "px";
ui_tooltip   = "The thickness of the wave in pixel.";
ui_category  = "\n / General Options /\n";
>                = 4;
#line 112
uniform float UI_Gamma <
ui_label     = " Gamma";
ui_type      = "slider";
ui_min       = 0.4;
ui_max       = 4.4;
ui_step      = 0.01;
ui_tooltip   = "The gamma correction value. The default value is 1.0. The higher this value, the more\n"
"persistent highlights will be.";
ui_category  = "\n / General Options /\n";
>                = 1.0;
#line 123
uniform float UI_BaseIncrease <
ui_label     = " Base Increase";
ui_type      = "slider";
ui_min       = 0.00;
ui_max       = 10.00;
ui_step      = 0.01;
ui_tooltip   = "This value is added to every pixel to create a base frequency independent of the image.";
ui_category  = "\n / General Options /\n";
>                = 0.15;
#line 133
uniform bool UI_BaseMultiply <
ui_label     = " Multiply Base with Background";
ui_tooltip   = "The base value is multiplied with the scene value to depend on the image content.\n"
"It now serves as a multiplier of the image value.";
ui_category  = "\n / General Options /\n";
>                = false;
#line 140
uniform float UI_Decay <
ui_label     = " Decay";
ui_type      = "slider";
ui_min       = 0.000;
ui_max       = 1.000;
ui_step      = 0.001;
ui_tooltip   = "Decay of the wave frequency after each wave. Highly instable, but can produce\n"
"interesting results. Not recommended above 0 with animated waves.";
ui_category  = "\n / General Options /\n";
>                = 0.000;
#line 151
uniform float UI_Offset <
ui_label     = " Offset";
ui_type      = "slider";
ui_min       = 0.0;
ui_max       = 100.0;
ui_step      = 0.1;
ui_units     = "%%";
ui_tooltip   = "Initial offset of the first wave.";
ui_category  = "\n / General Options /\n";
>                = 0.1;
#line 162
uniform int UI_BlendMode <
ui_label     = " Blend Mode";
ui_type      = "combo";
ui_items     = "Tint\0Color\0Value\0";
ui_tooltip   = "The blend mode applied to the wave.";
ui_category  = "\n / General Options /\n";
>                = 2;
#line 170
uniform float3 UI_EffectTint <
ui_label     = " Tint";
ui_type      = "color";
ui_tooltip   = "Specifies the tint of the wave, when blend mode is set to tint.";
ui_category  = "\n / General Options /\n";
>                = float3(1.00, 0.50, 0.50);
#line 177
uniform float UI_Transparency <
ui_label     = " Black Transparency";
ui_type      = "slider";
ui_min       = 0.0;
ui_max       = 100.0;
ui_step      = 0.1;
ui_units     = "%%";
ui_tooltip   = "Transparency of the area not affected by the waves.";
ui_category  = "\n / General Options /\n";
>                = 0.0;
#line 188
uniform uint UI_RotationType <
ui_label     = " Direction";
ui_type      = "combo";
ui_items     = "Left\0Bottom\0Right\0Top\0";
ui_tooltip   = "The direction from which the effect starts.";
ui_category  = "\n / General Options /\n";
>                = 0;
#line 196
uniform int UI_Blur <
ui_label     = " Blur";
ui_type      = "combo";
ui_items     = "None\0Two\0Four\0Six\0Eight\0";
ui_tooltip   = "The blur applied to the input. Higher values smoothen the wave.";
ui_category  = "\n / General Options /\n";
>                = 2;
#line 204
uniform bool UI_Animate <
ui_label     = " Animate";
ui_tooltip   = "Make the wave move with time.";
ui_category  = "\n / General Options /\n";
>                = true;
#line 210
uniform bool UI_Invert <
ui_label     = " Invert";
ui_tooltip   = "Invert the wave.";
ui_category  = "\n / General Options /\n";
>                = false;
#line 216
uniform bool UI_UseDepth <
ui_label     = " Use Depth";
ui_tooltip   = "The waves will respond to scene depth instead of the scene luminance.\n"
"Requires a working depth buffer.";
ui_category  = "\n / General Options /\n";
>                = false;
#line 223
uniform float UI_DepthMultiplier <
ui_label     = " Depth Multiplier";
ui_type      = "slider";
ui_min       = 0.01;
ui_max       = 10.00;
ui_tooltip   = "Multiplier of the depth value when depth is used.";
ui_category  = "\n / General Options /\n";
>                = 1.0;
#line 232
uniform bool UI_HotsamplingMode <
ui_label     = " Hotsampling Mode";
ui_tooltip   = "Activate this, then adjust your options and the effect will stay similar at\n"
"all resolutions. Turn this off when you do not intend to hotsample.";
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
hidden       = false;
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
hidden       = false;
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
hidden       = false;
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
hidden       = false;
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
#line 241 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\Frequency_CS.fx"
#line 242
uniform int UI_BufferEnd <
ui_type     = "radio";
ui_spacing  = 2;
ui_text     = " Shader Version: " "0.2.0";
ui_label    = " ";
> ;
#line 257
texture TEX_Frequency
{
Width  = 1920;
Height = 1018;
Format = R8; 
};
#line 264
texture TEX_Mask
{
Width  = 1920;
Height = 1018;
Format = R16F; 
};
#line 273
sampler2D SAM_Frequency { Texture = TEX_Frequency; };
sampler2D SAM_Mask { Texture = TEX_Mask; };
#line 278
storage STOR_Frequency { Texture = TEX_Frequency; };
storage STOR_Mask { Texture = TEX_Mask; };
#line 282
groupshared float summary[16 * 16];
groupshared uint overlap[16 * 16];
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
#line 293 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\Frequency_CS.fx"
#line 295
float2 rotate(float2 texcoord1, bool revert)
{
float2 texcoord = texcoord1.xy;
uint ANGLE      = UI_RotationType * 90 + (360 - 2 * UI_RotationType * 90) * revert;
float2 rotated  = texcoord;
#line 302
rotated = (ANGLE == 90) ? float2(texcoord.y, 1 - texcoord.x) : rotated;
rotated = (ANGLE == 180) ? float2(1 - texcoord.x, 1 - texcoord.y) : rotated;
rotated = (ANGLE == 270) ? float2(1 - texcoord.y, texcoord.x) : rotated;
return rotated.xy;
}
#line 314
void PS_Mask(float4 vpos : SV_Position, out float fragment : SV_TARGET)
{
float val    = 0.0;
uint counter = 0;
[unroll] for (int i = -8; i <= 8; i++)
{
if (((vpos.y + i) > 0) && ((vpos.y + i) < 1018) && (abs(i) <= (2 * UI_Blur)))
{
float2 texcoord = (vpos.xy + int2(0, i)) / float2(1920, 1018);
texcoord        = rotate(texcoord, false);
float3 srgb     = tex2D(ReShade::BackBuffer, texcoord).rgb; 
float3 rgb      = enc_to_lin(srgb);
float depth     = ReShade::GetLinearizedDepth(texcoord);
float f         = check_focus(rgb, depth, texcoord);
if (f)
{
val += UI_UseDepth ? f * UI_DepthMultiplier * pow(abs(depth), UI_Gamma)
: f * csp_to_luminance(pow(abs(rgb), UI_Gamma));
counter++;
}
}
}
#line 337
float HS_MULT       = UI_HotsamplingMode ? 1920.0 / 1920 : 1.0;
fragment            = val / max(counter, 0.5);
float intermediate  = UI_BaseMultiply ? fragment : 1.0;
fragment            = fragment + UI_BaseIncrease * intermediate;
fragment           *= HS_MULT;
}
#line 344
void CS_Frequency(uint3 id : SV_DispatchThreadID, uint3 tid : SV_GroupThreadID)
{
uint start       = id.x * (((1920 - 1) / 16) + 1);
uint end         = min(start + (((1920 - 1) / 16) + 1) - 1, 1920 - 1);
uint global_zero = tid.y * 16;
float accum_s    = UI_Offset / 100.0 * UI_Frequency - (frac((UI_Animate * timer / 200.0)*rcp(UI_Frequency)) * (UI_Frequency));
accum_s          = (id.x == 0) ? accum_s : 0.0;
float accum      = accum_s;
float section[(((1920 - 1) / 16) + 1)];
#line 355
if (id.y < 1018)
{
for (uint i = start; i <= end; i++)
{
section[i - start] = tex2Dfetch(SAM_Mask, int2(i, id.y)).r;
accum += section[i - start];
}
summary[global_zero + id.x] = accum;
}
#line 366
overlap[global_zero + id.x] = 0;
#line 368
barrier();
#line 370
float accum_l = accum_s;
if (id.y < 1018)
{
for (uint i = 0; i < id.x; i++)
{
accum_l += summary[global_zero + i];
}
}
#line 383
float decay         = 1.0;
uint remaining      = 0;
uint first_position = end;
const uint R        = UI_HotsamplingMode ? UI_Thickness * float(1920) / 1920.0 : UI_Thickness;
const float U       = 1.0 + UI_Decay;
if (id.y < 1018)
{
#line 425
while (accum_l > 0.0)
{
accum_l -= UI_Frequency * decay;
decay *= U;
}
#line 431
for (uint i = start; i <= end; i++)
{
accum_l += section[i - start];
if (accum_l > 0.0)
{
remaining      = R;
first_position = min(i, first_position);
accum_l -= UI_Frequency * decay;
decay *= U;
}
#line 442
if (remaining > 0)
{
remaining--;
tex2Dstore(STOR_Frequency, int2(i, id.y), 1.0);
}
}
#line 449
uint next = 1;
while (remaining > 0 && ((id.x + next) < 16))
{
atomicMax(overlap[global_zero + id.x + next++], remaining);
remaining = max(int(remaining) - (((1920 - 1) / 16) + 1), 0);
}
}
#line 457
barrier();
#line 460
if (id.y < 1018)
{
remaining = overlap[global_zero + id.x];
for (uint i = start; i < first_position; i++)
{
if (remaining > 0)
{
remaining--;
tex2Dstore(STOR_Frequency, int2(i, id.y), 1.0); 
}
}
}
}
#line 475
void PS_PrintFrequency(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target)
{
float4 srgb         = tex2Dfetch(ReShade::BackBuffer, floor(vpos.xy));
float3 rgb          = enc_to_lin(srgb.rgb);
float3 intermediate = UI_BlendMode == 2 ? csp_to_luminance(rgb.rgb) : rgb;
intermediate        = UI_BlendMode == 0 ? ui_to_csp(UI_EffectTint) : intermediate; 
float2 texcoord_new = rotate(texcoord, true);
float intensity     = tex2D(SAM_Frequency, texcoord_new).r;
intensity           = intensity + (1.0 - 2.0 * intensity) * UI_Invert;
fragment.rgb        = intensity * intermediate + (1.0 - intensity) * rgb * UI_Transparency / 100.0;
fragment.rgb        = UI_ShowMask ? saturate(1.0 - tex2D(SAM_Mask, texcoord_new).rrr) : fragment.rgb; 
fragment.rgb        = (UI_ShowSelectedHue * UI_FilterColor) ? show_hue(texcoord, fragment.rgb) : fragment.rgb;
fragment.rgb        = lin_to_enc(fragment.rgb);
fragment.a          = srgb.a; 
}
#line 497
technique TECH_Frequency <
ui_label     = "Frequency";
ui_tooltip   = "------About-------\n"
"Frequency_CS.fx creates an effect also known as 'Frequency Modulation', which\n"
"scans the image from left to right and releases a wave whenever a luminance-\n"
"based threshold is reached. The pixel luminance is summed up and modulated\n"
"depending on a given period. Additional parameters give the effect a unique\n"
"look. A masking stage enables filtering affected colors and depth.\n\n"
"Version:    " "0.2.0" "\nAuthor:     SirCobra\nCollection: CobraFX\n"
"            https://github.com/LordKobra/CobraFX";
>
{
pass Mask
{
VertexShader = PostProcessVS;
PixelShader  = PS_Mask;
RenderTarget = TEX_Mask;
}
#line 516
pass PrepareFrequency
{
VertexShader       = VS_Clear;
PixelShader        = PS_Clear;
RenderTarget0      = TEX_Frequency;
ClearRenderTargets = true;
PrimitiveTopology  = POINTLIST;
VertexCount        = 1;
}
#line 526
pass Frequency
{
ComputeShader = CS_Frequency<16, 16>;
DispatchSizeX = 1;
DispatchSizeY = (((1018 - 1) / 16) + 1);
}
#line 533
pass PrintFrequency
{
VertexShader = PostProcessVS;
PixelShader  = PS_PrintFrequency;
}
}
#line 542
} 

