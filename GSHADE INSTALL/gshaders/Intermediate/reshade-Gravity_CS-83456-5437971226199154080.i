// GRAVITY_HEIGHT=1080
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\Gravity_CS.fx"
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
#line 48 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\Gravity_CS.fx"
#line 53
namespace COBRA_XGRV
{
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\CobraUtility.fxh"
#line 68 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\Gravity_CS.fx"
#line 98
uniform float UI_GravityIntensity <
ui_label     = " Gravity Intensity";
ui_type      = "slider";
ui_spacing   = 2;
ui_min       = 0.00;
ui_max       = 1.00;
ui_step      = 0.01;
ui_tooltip   = "Gravity strength. Higher values look cooler but can decrease FPS!";
ui_category  = "\n / General Options /\n";
>                = 0.50;
#line 109
uniform float UI_GravityRNG <
ui_label     = " Gravity RNG";
ui_type      = "slider";
ui_min       = 0.01;
ui_max       = 0.99;
ui_step      = 0.02;
ui_tooltip   = "Changes the random intensity of each pixel.";
ui_category  = "\n / General Options /\n";
>                = 0.75;
#line 119
uniform bool UI_UseImage <
ui_label     = " Use Image";
ui_tooltip   = "Changes the RNG to the input image called gravity_noise.png located in the Textures folder.\n"
"You can change the image for your own RNG as long as the name and resolution stay the same.";
ui_category  = "\n / General Options /\n";
>                = true;
#line 126
uniform bool UI_InvertGravity <
ui_label     = " Invert Gravity";
ui_tooltip   = "Pixels will gravitate upwards.";
ui_category  = "\n / General Options /\n";
>                = false;
#line 132
uniform bool UI_AllowOverlapping <
ui_label     = " Allow Overlapping";
ui_tooltip   = "This way, the effect does not get hidden behind other objects.";
ui_category  = "\n / General Options /\n";
>                = false;
#line 138
uniform float UI_NoiseSize <
ui_label     = " Noise Size";
ui_type      = "slider";
ui_min       = 0.001;
ui_max       = 1.000;
ui_step      = 0.001;
ui_tooltip   = "Size of the noise texture. A lower value means larger noise pixels.";
ui_category  = "\n / General Options /\n";
>                = 1.000;
#line 148
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
#line 158 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\Gravity_CS.fx"
#line 168
uniform bool UI_LockLightness <
ui_label           = " Lock Lightness";
ui_spacing         = 2;
ui_tooltip         = "Lock the lightness to the ingame lightness.";
ui_category        = "\n /      Extras     /\n";
ui_category_closed = true; 
>                      = true;
#line 176
uniform bool UI_LockChroma <
ui_label     = " Lock Chroma";
ui_tooltip   = "Lock the chroma to the ingame chroma.";
ui_category  = "\n /      Extras     /\n";
>                = false;
#line 182
uniform bool UI_LockHue <
ui_label     = " Lock Hue";
ui_tooltip   = "Lock the hue to the ingame hue.";
ui_category  = "\n /      Extras     /\n";
>                = false;
#line 188
uniform float3 UI_EffectTint <
ui_label     = " Effect Tint";
ui_type      = "color";
ui_tooltip   = "Specifies the tint of the gravitating pixels, the further they move away from their origin.";
ui_category  = "\n /      Extras     /\n";
>                = float3(0.50, 0.50, 0.50);
#line 195
uniform float UI_BlendIntensity <
ui_label     = " Blend Intensity";
ui_type      = "slider";
ui_min       = 0.0;
ui_max       = 1.0;
ui_tooltip   = "Specifies intensity of the blending applied to the gravitating pixels. Range from 0.0, which\n"
"means no change, till 1.0, which means fully blended.";
ui_category  = "\n /      Extras     /\n";
>                = 0.0;
#line 205
uniform int UI_BufferEnd <
ui_type     = "radio";
ui_spacing  = 2;
ui_text     = " Preprocessor Options:\n * GRAVITY_HEIGHT (default value: 1024) defines the "
"resolution of the effect along the gravitational axis. The value needs to be integer. "
"Smaller values give performance at cost of visual fidelity. 768: Performance 1080: HD Quality. "
"Set it to 'BUFFER_HEIGHT' if you always want to run the effect at native resolution.\n\n"
" Shader Version: " "0.4.0";
ui_label    = " ";
> ;
#line 224
texture TEX_GravitySeedMap
{
Width  = (float(1920) / 1);
Height = (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000));
Format = R16F;
};
#line 231
texture TEX_GravitySeedMap2 <
source = "gravity_noise.png";
>
{
Width  = 1920;
Height = 1080;
Format = R8;
};
#line 240
texture TEX_GravityCurrentSettings
{
Width  = 1;
Height = 1;
Format = R16F;
};
#line 247
texture TEX_GravityMain
{
Width  = (float(1920) / 1);
Height = (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000));
#line 252
Format = RGBA8;
#line 258
};
#line 262
sampler2D SAM_GravitySeedMap
{
Texture   = TEX_GravitySeedMap;
MagFilter = POINT;
MinFilter = POINT;
MipFilter = POINT;
};
#line 270
sampler2D SAM_GravitySeedMap2
{
Texture   = TEX_GravitySeedMap2;
MagFilter = POINT;
MinFilter = POINT;
MipFilter = POINT;
#line 278
};
sampler2D SAM_GravityCurrentSettings { Texture = TEX_GravityCurrentSettings; };
#line 281
sampler2D SAM_GravityMain
{
Texture   = TEX_GravityMain;
MagFilter = POINT;
MinFilter = POINT;
MipFilter = POINT;
};
#line 291
storage STOR_GravityMain { Texture = TEX_GravityMain; };
#line 295
groupshared uint final_list[(((((int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 1) / 8) + 1) * 8)];
groupshared float depth_list[(((((int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 1) / 8) + 1) * 8)];
groupshared float depth_listU[(((((int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 1) / 8) + 1) * 8)];
groupshared uint strengthen[(((((int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 1) / 8) + 1) * 8)];
groupshared uint max_str;
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
#line 310 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\Gravity_CS.fx"
#line 313
float mandelbrot_rng(float2 texcoord : TEXCOORD)
{
const float2 CENTER = float2(0.675, 0.46);           
const float ZOOM    = 0.033 * UI_GravityRNG;                                
const float AR      = float(ReShade::GetScreenSize().x) / ReShade::GetScreenSize().y; 
float2 c            = float2(AR, 1.0) * (texcoord - 0.5) * ZOOM - CENTER;
float2 z            = c;
uint i;
for (i = 0; i < 100; i++)
{
float x = z.x * z.x - z.y * z.y + c.x;
float y = 2.0 * z.x * z.y + c.y;
if ((x * x + y * y) > 4.0)
break;
z.x = x;
z.y = y;
}
#line 331
const float INTENSITY = 1.0;
return saturate(((INTENSITY * (i == 100 ? 0.0 : float(i)) / 100.0) - 0.8) / 0.22);
}
#line 341
void CS_Gravity(uint3 id : SV_DispatchThreadID, uint3 tid : SV_GroupThreadID, uint gi : SV_GroupIndex)
{
uint max_strength = 0;
if(tid.y == 0)
max_str = 0;
#line 347
barrier();
uint start        = tid.y * 8;
uint finish       = -1 + 8;
float x_norm      = (round(id.x * 1) + 0.5) / 1920;
#line 353
const uint F   = (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) * 8;
uint fi_start  = round(sqrt(tid.y * F));
uint fi_finish = UI_AllowOverlapping ? (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 1 : round(sqrt((tid.y + 1) * F)) - 1;
#line 358
[unroll] for (uint yz = 0; yz <= finish; yz++)
{
uint y        = yz + start;
uint yi       = y + ((int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 1 - 2 * y) * UI_InvertGravity;
final_list[y] = y;
depth_list[y] = depth_listU[y] = ReShade::GetLinearizedDepth(float2(x_norm, (round(yi * (float(1018) / (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)))) + 0.5) / 1018));
float3 rgb                     = tex2Dfetch(ReShade::BackBuffer, int2(id.x * 1, yi * (float(1018) / (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000))))).rgb;
rgb                            = enc_to_lin(rgb);
float strength                 = tex2Dfetch(SAM_GravitySeedMap, int2(id.x, yi)).r;
strength     *= check_focus(rgb, depth_list[y], float2(x_norm, (round(y * (float(1018) / (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)))) + 0.5) / 1018));
strengthen[y] = strength * UI_GravityIntensity * ((int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 2.0);
max_strength = max(max_strength, strengthen[y]);
}
atomicMax(max_str, max_strength);
barrier();
#line 374
max_strength = max_str;
#line 376
uint paint_iterator = 0;
#line 379
uint skip_position = 0;
float skip_depth   = 1.0; 
#line 383
for (uint y = max(0, fi_start - max_strength - 1); y < fi_finish; y++) 
{
float scene_depth = depth_list[y];
uint strength     = strengthen[y];
#line 388
if (!UI_AllowOverlapping)
{
#line 391
uint yymax = min(fi_finish, min(y + strength, (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 1));
bool skip  = (skip_position >= yymax && skip_depth <= scene_depth || yymax < fi_start);
if (skip)
continue;
#line 396
if (yymax > skip_position)
{
skip_position = yymax;
skip_depth    = scene_depth;
}
#line 402
for (uint yy = max(y + 1, fi_start); yy <= yymax; yy++)
{
if (depth_listU[yy] > scene_depth) 
{
final_list[yy]  = y;
depth_listU[yy] = depth_list[y];
#line 409
}
}
}
else
{
if (tid.y == 0)
{ 
if (paint_iterator == y)
paint_iterator++;
#line 419
uint imax      = min(y + strength, (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 1);
uint i         = paint_iterator;
paint_iterator = max(paint_iterator, imax);
#line 423
for (i; i <= imax; i++)
{
final_list[i] = y;
#line 427
}
}
}
}
#line 432
barrier();
#line 434
uint3 LOCK              = uint3(UI_LockLightness, UI_LockChroma, UI_LockHue);
float3 effect_oklch     = csp_to_oklch(ui_to_csp(UI_EffectTint));
effect_oklch            = effect_oklch * (1.0 - LOCK);
float4 store_val        = 1.0;
#line 440
for (uint yy = 0; yy <= finish; yy++)
{
uint y  = yy + start;
uint fi = final_list[y] + ((int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 1 - 2 * final_list[y]) * UI_InvertGravity;
uint yi = y + ((int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 1 - 2 * y) * UI_InvertGravity;
if (y != final_list[y])
{
store_val.rgb         = tex2Dfetch(ReShade::BackBuffer, int2(id.x, fi * (float(1018) / (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000))))).rgb; 
store_val.rgb         = enc_to_lin(store_val.rgb);
float blend_intensity = smoothstep(0.0, strengthen[final_list[y]], distance(y, final_list[y]));
float3 source_oklab   = csp_to_oklab(store_val.rgb);
float3 source_oklch   = oklab_to_oklch(source_oklab);
float3 target_oklab   = oklch_to_oklab(source_oklch * LOCK + effect_oklch);
target_oklab          = lerp(source_oklab, target_oklab, blend_intensity * UI_BlendIntensity); 
store_val.rgb         = oklab_to_csp(target_oklab);
store_val.rgb         = lin_to_enc(store_val.rgb);
tex2Dstore(STOR_GravityMain, float2(id.x, yi), store_val);
}
}
}
#line 463
void PS_GenerateRNGSetup(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float fragment : SV_Target)
{
uint2 coords = (frac((vpos.xy * UI_NoiseSize)*rcp(float2(1920, 1080))) * (float2(1920, 1080)));
coords       = UI_HotsamplingMode ? vpos.xy * float2(1919.0, 1079.0)
/ (float2((float(1920) / 1), (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000))) - 1.0) * UI_NoiseSize
: coords;
float value  = tex2Dfetch(SAM_GravitySeedMap2, coords).r;
value        = saturate((value - 1.0 + UI_GravityRNG) / UI_GravityRNG);
fragment     = UI_UseImage ? value : mandelbrot_rng(texcoord.xy);
}
#line 477
vs2ps VS_GenerateRNG(uint id : SV_VertexID)
{
float settings = tex2Dfetch(SAM_GravityCurrentSettings, int2(0, 0)).r;
float new_rng  = UI_NoiseSize * 1000 + UI_UseImage * 100 + UI_HotsamplingMode + UI_GravityRNG;
bool renew     = abs(settings - new_rng) > 0.005;
vs2ps o        = vs_basic(id, 0.0);
if (!renew)
o.vpos.xy = 0.0;
#line 486
return o;
}
#line 489
void PS_GenerateRNG(vs2ps o, out float fragment : SV_Target)
{
uint2 coords = (frac((o.vpos.xy * UI_NoiseSize)*rcp(float2(1920, 1080))) * (float2(1920, 1080)));
coords       = UI_HotsamplingMode ? o.vpos.xy * float2(1919.0, 1079.0)
/ (float2((float(1920) / 1), (int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000))) - 1) * UI_NoiseSize : coords;
float value  = tex2Dfetch(SAM_GravitySeedMap2, coords).r;
value        = saturate((value - 1.0 + UI_GravityRNG) / UI_GravityRNG);
fragment     = UI_UseImage ? value : mandelbrot_rng(o.uv.xy);
}
#line 511
void PS_UpdateRNGSettings(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float fragment : SV_Target)
{
fragment = UI_NoiseSize * 1000 + UI_UseImage * 100 + UI_HotsamplingMode + UI_GravityRNG;
}
#line 517
void PS_PrintGravity(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target)
{
fragment               = tex2D(SAM_GravityMain, texcoord);
fragment.rgb           = enc_to_lin(fragment.rgb);
float depth            = ReShade::GetLinearizedDepth(texcoord);
float3 color           = tex2Dfetch(ReShade::BackBuffer, floor(vpos.xy)).rgb;
color                  = enc_to_lin(color);
fragment.rgb    = fragment.a ? fragment.rgb : color;
float focus     = 1.0 - check_focus(color, depth, texcoord);
fragment        = UI_ShowMask ? focus : fragment;
fragment.rgb    = (UI_ShowSelectedHue * UI_FilterColor) ? show_hue(texcoord, fragment.rgb) : fragment.rgb;
fragment.rgb    = lin_to_enc(fragment.rgb);
fragment.a      = 1.0;
}
#line 538
technique TECH_PreGravity < 
hidden     = true;
enabled    = true;
timeout    = 1;
>
{
pass GenerateRNG
{
VertexShader = PostProcessVS;
PixelShader  = PS_GenerateRNGSetup;
RenderTarget = TEX_GravitySeedMap;
}
}
#line 552
technique TECH_GravityCS <
ui_label     = "Gravity CS";
ui_tooltip   = "------About-------\n"
"Gravity_CS.fx lets pixels gravitate towards the bottom of the screen in the game's 3D environment.\n"
"You can filter the affected pixels by depth and by color.\n"
"It uses a custom seed (currently the Mandelbrot set) to determine the intensity of each pixel.\n"
"Make sure to also test out the image-RNG variant with the picture 'gravity_noise.png' provided\n"
"in the Textures folder. You can replace the texture with your own picture, as long as it\n"
"is 1920x1080, RGBA8 and has the same name. Only the red-intensity is taken. So either use red\n"
"images or greyscale images.\n"
"CS is the compute shader version of Gravity.fx, it works best on resolutions above 1080p,\n"
"although it can still perform like as Gravity.fx at lower resolutions. For quality-perfomance\n"
"balancing, read the preprocessor tooltip of GRAVITY_HEIGHT.\n\n"
"Version:    " "0.4.0" "\nAuthor:     SirCobra\nCollection: CobraFX\n"
"            https://github.com/LordKobra/CobraFX";
>
{
pass GenerateRNG
{
VertexShader = VS_GenerateRNG;
PixelShader  = PS_GenerateRNG;
RenderTarget = TEX_GravitySeedMap;
}
#line 576
pass PrepareGravity
{
VertexShader       = VS_Clear;
PixelShader        = PS_Clear;
RenderTarget0      = TEX_GravityMain;
ClearRenderTargets = true;
PrimitiveTopology  = POINTLIST;
VertexCount        = 1;
}
#line 586
pass GravityMain
{
ComputeShader = CS_Gravity<1, ((((int((1080) < (2000)) * (1080) + int((2000) <= (1080)) * (2000)) - 1) / 8) + 1)>;
DispatchSizeX = (float(1920) / 1);
DispatchSizeY = 1;
}
#line 593
pass UpdateSettings
{
VertexShader = PostProcessVS;
PixelShader  = PS_UpdateRNGSettings;
RenderTarget = TEX_GravityCurrentSettings;
}
#line 600
pass PrintGravity
{
VertexShader = PostProcessVS;
PixelShader  = PS_PrintGravity;
}
}
#line 608
}

