// AE_MIN_BRIGHTNESS=0.02
// AE_RANGE=1.0
// ENABLE_ADVANCED_LENS_FLARE_SETTINGS=0
// DOF_SENSOR_SIZE=36.0
// HDR_ACES_TONEMAP=1
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\pCamera.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\pCamera.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Oklab.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\pUtils.fxh"
#line 42
namespace pUtils
{
#line 45
uniform float FrameTime < source = "frametime"; >;
uniform int FrameCount < source = "framecount"; >;
#line 49
static const float PI = 3.1415927;
static const float EPSILON = 1e-10;
static const float2 ASPECT_RATIO = float2(1.0, 1.0/(1920 * (1.0 / 1018)));
#line 56
float fastatan2(float y, float x)
{
bool a = abs(y) < abs(x);
float i = (a) ? (y * rcp(x)) : (x * rcp(y));
i = i * (1.0584 + abs(i) * -0.273);
float piadd = y > 0 ? PI : -PI;
i = a ? (x < 0 ? piadd : 0) + i : 0.5 * piadd - i;
return i;
}
#line 67
float cbrt(float v)
{
return sign(v) * pow(abs(v), 0.33333333);
}
float3 cbrt(float3 v)
{
return sign(v) * pow(abs(v), 0.33333333);
}
#line 77
float clerp(float v, float t, float w)
{
return v + (((t - v) % PI + 1.5 * PI) % PI) * w;
}
#line 83
float cdistance(float v, float t)
{
float d = abs(t - v);
return (d > PI)
? 2.0 * PI - d
: d;
}
#line 92
float wnoise(float2 uv, float2 d)
{
float t = float(FrameCount % 1000 + 1);
return frac(sin(dot(uv - 0.5, d) * t) * 143758.5453);
}
}
#line 41 "C:\Program Files\GShade\gshade-shaders\Shaders\Oklab.fxh"
#line 59
namespace Oklab
{
#line 62
static const float PI = pUtils::PI;
static const float EPSILON = pUtils::EPSILON;
#line 65
static const float SDR_WHITEPOINT = 100.0; 
#line 98
static const bool IS_HDR = false;
#line 102
static const float HDR_PAPER_WHITE = float(80.0) / SDR_WHITEPOINT;
#line 119
                           
static const float INVNORM_FACTOR = 1.0;
#line 126
float3 sRGB_to_Linear(float3 c)
{
return (c < 0.04045)
? c / 12.92
: pow(abs((c + 0.055) / 1.055), 2.4);
}
float3 Linear_to_sRGB(float3 c)
{
return (c < 0.0031308)
? c * 12.92
: 1.055 * pow(abs(c), rcp(2.4)) - 0.055;
}
float3 PQ_to_Linear(float3 c)
{
static const float m1 = 0.15930176; 
static const float m2 = 78.84375;   
static const float c1 = 0.8359375;  
static const float c2 = 18.8515625; 
static const float c3 = 18.6875;    
const float3 p = pow(abs(c), rcp(m2));
c = pow(abs(max(p - c1, 0.0) / (c2 - c3 * p)), rcp(m1));
return c * 10000.0 / SDR_WHITEPOINT;
}
float3 Linear_to_PQ(float3 c)
{
static const float m1 = 0.15930176; 
static const float m2 = 78.84375;   
static const float c1 = 0.8359375;  
static const float c2 = 18.8515625; 
static const float c3 = 18.6875;    
const float3 y = pow(abs(c * (SDR_WHITEPOINT * 0.0001)), m1);
return pow(abs((c1 + c2 * y) / (1.0 + c3 * y)), m2);
}
float3 HLG_to_Linear(float3 c)
{
static const float a = 0.17883277;
static const float b = 0.28466892;
static const float c4 = 0.55991073;
c = (c > 0.5)
? (exp((c + c4) / a) + b) / 12.0
: (c * c) / 3.0;
return c * 1000.0 / SDR_WHITEPOINT;
}
float3 Linear_to_HLG(float3 c)
{
static const float a = 0.17883277;
static const float b = 0.28466892;
static const float c4 = 0.55991073;
c *= (SDR_WHITEPOINT * 0.001);
c = (c < 0.08333333) 
? sqrt(3.0 * c)
: a * log(12.0 * c - b) + c4;
return c;
}
#line 181
float3 Fast_sRGB_to_Linear(float3 c)
{
return max(c * c, c / 12.92);
}
float3 Fast_Linear_to_sRGB(float3 c)
{
return min(sqrt(c), c * 12.92);
}
float3 Fast_PQ_to_Linear(float3 c) 
{
const float3 sq = c * c;
const float3 qq = sq * sq;
const float3 oq = qq * qq;
c = max(max(sq / 455.0, qq / 5.5), oq);
return c * 10000.0 / SDR_WHITEPOINT;
}
float3 Fast_Linear_to_PQ(float3 c)
{
const float3 sr = sqrt(c * (SDR_WHITEPOINT * 0.0001));
const float3 qr = sqrt(sr);
const float3 or = sqrt(qr);
return min(or, min(sqrt(sqrt(5.5)) * qr, sqrt(455.0) * sr));
}
#line 208
float3 DisplayFormat_to_Linear(float3 c)
{
#line 221
 
c = sRGB_to_Linear(c);
#line 224
return c;
}
float3 Linear_to_DisplayFormat(float3 c)
{
#line 237
 
c = Linear_to_sRGB(c);
#line 240
return c;
}
float3 Fast_DisplayFormat_to_Linear(float3 c)
{
#line 255
 
c = Fast_sRGB_to_Linear(c);
#line 258
return c;
}
float3 Fast_Linear_to_DisplayFormat(float3 c)
{
#line 271
 
c = Fast_Linear_to_sRGB(c);
#line 274
return c;
}
#line 278
float3 Saturate_LCh(float3 c) 
{
c.y = saturate(c.y);
c.z = (c.z < -PI)
? c.z + 2.0 * PI
: (c.z > PI)
? c.z - 2.0 * PI
: c.z;
return c;
}
float get_Oklab_Chromacity(float3 c)
{
return length(c.yz);
}
#line 294
float Normalize(float v)
{
return v / INVNORM_FACTOR;
}
float3 Normalize(float3 v)
{
return v / INVNORM_FACTOR;
}
float3 Saturate_RGB(float3 c)
{
return float3(clamp(c.r, 0.0, INVNORM_FACTOR), clamp(c.g, 0.0, INVNORM_FACTOR), clamp(c.b, 0.0, INVNORM_FACTOR));
}
float get_Luminance_RGB(float3 c)
{
return dot(c, float3(0.2126, 0.7152, 0.0722));
}
float get_Adapted_Luminance_RGB(float3 c, float range)
{
return min(2.0 * get_Luminance_RGB(c) / HDR_PAPER_WHITE, range);
}
#line 317
float3 Tonemap(float3 c)
{
#line 321
c *= 0.6;
c *= (2.51 * c + 0.03) / (c * (2.43 * c + 0.59) + 0.14);
#line 327
return Saturate_RGB(c);
}
float3 TonemapInv(float3 c)
{
#line 333
c = (sqrt(-10127.0 * (c * c) + 13702.0 * c + 9.0) + 59.0 * c - 3.0) / (502.0 - 486.0 * c);
c /= 0.6;
#line 341
return c;
}
#line 345
float3 RGB_to_XYZ(float3 c)
{
return mul(float3x3(
0.4124564, 0.3575761, 0.1804375,
0.2126729, 0.7151522, 0.0721750,
0.0193339, 0.1191920, 0.9503041
), c);
}
float3 XYZ_to_RGB(float3 c)
{
return mul(float3x3(
3.2404542, -1.5371385, -0.4985314,
-0.9692660, 1.8760108, 0.0415560,
0.0556434, -0.2040259, 1.0572252
), c);
}
#line 362
float3 XYZ_to_Oklab(float3 c)
{
c = mul(float3x3(
0.8189330101, 0.3618667424, -0.1288597137,
0.0329845436, 0.9293118715, 0.0361456387,
0.0482003018, 0.2643662691, 0.6338517070
), c);
#line 370
c = pUtils::cbrt(c);
#line 372
c = mul(float3x3(
0.2104542553, 0.7936177850, -0.0040720468,
1.9779984951, -2.4285922050, 0.4505937099,
0.0259040371, 0.7827717662, -0.8086757660
), c);
return c;
}
float3 Oklab_to_XYZ(float3 c)
{
c = mul(float3x3(
0.9999999985, 0.3963377922, 0.2158037581,
1.0000000089, -0.1055613423, -0.0638541748,
1.0000000547, -0.0894841821, -1.2914855379
), c);
#line 387
c = c * c * c;
#line 389
c = mul(float3x3(
1.2270138511, -0.5577999807, 0.2812561490,
-0.0405801784, 1.1122568696, -0.0716766787,
-0.0763812845, -0.4214819784, 1.5861632204
), c);
return c;
}
float3 RGB_to_Oklab(float3 c)
{
c = mul(float3x3(
0.4122214708, 0.5363325363, 0.0514459929,
0.2119034982, 0.6806995451, 0.1073969566,
0.0883024619, 0.2817188376, 0.6299787005
), c);
#line 404
c = pUtils::cbrt(c);
#line 406
c = mul(float3x3(
0.2104542553, 0.7936177850, -0.0040720468,
1.9779984951, -2.4285922050, 0.4505937099,
0.0259040371, 0.7827717662, -0.8086757660
), c);
return c;
}
float3 Oklab_to_RGB(float3 c)
{
c = mul(float3x3(
1.0, 0.3963377774, 0.2158037573,
1.0, -0.1055613458, -0.0638541728,
1.0, -0.0894841775, -1.2914855480
), c);
#line 421
c = c * c * c;
#line 423
c = mul(float3x3(
4.0767416621, -3.3077115913, 0.2309699292,
-1.2684380046, 2.6097574011, -0.3413193965,
-0.0041960863, -0.7034186147, 1.7076147010
), c);
return c;
}
float3 Oklab_to_LCh(float3 c)
{
float a = c.y;
#line 434
c.y = length(c.yz);
c.z = pUtils::fastatan2(c.z, a);
return c;
}
float3 LCh_to_Oklab(float3 c)
{
float h = c.z;
#line 442
c.z = c.y * sin(h);
c.y = c.y * cos(h);
return c;
}
#line 449
float3 sRGB_to_Oklab(float3 c)
{
return RGB_to_Oklab(sRGB_to_Linear(c));
}
float3 Oklab_to_sRGB(float3 c)
{
return Linear_to_sRGB(Oklab_to_RGB(c));
}
float3 sRGB_to_LCh(float3 c)
{
return Oklab_to_LCh(RGB_to_Oklab(sRGB_to_Linear(c)));
}
float3 LCh_to_sRGB(float3 c)
{
return Linear_to_sRGB(Oklab_to_RGB(LCh_to_Oklab(c)));
}
float3 RGB_to_LCh(float3 c)
{
return Oklab_to_LCh(RGB_to_Oklab(c));
}
float3 LCh_to_RGB(float3 c)
{
return Oklab_to_RGB(LCh_to_Oklab(c));
}
float3 DisplayFormat_to_Oklab(float3 c)
{
return RGB_to_Oklab(DisplayFormat_to_Linear(c));
}
float3 Oklab_to_DisplayFormat(float3 c)
{
return Linear_to_DisplayFormat(Oklab_to_RGB(c));
}
float3 DisplayFormat_to_LCh(float3 c)
{
return Oklab_to_LCh(RGB_to_Oklab(DisplayFormat_to_Linear(c)));
}
float3 LCh_to_DisplayFormat(float3 c)
{
return Linear_to_DisplayFormat(Oklab_to_RGB(LCh_to_Oklab(c)));
}
float3 Fast_DisplayFormat_to_Oklab(float3 c)
{
return RGB_to_Oklab(Fast_DisplayFormat_to_Linear(c));
}
float3 Fast_Oklab_to_DisplayFormat(float3 c)
{
return Fast_Linear_to_DisplayFormat(Oklab_to_RGB(c));
}
float3 Fast_DisplayFormat_to_LCh(float3 c)
{
return Oklab_to_LCh(RGB_to_Oklab(Fast_DisplayFormat_to_Linear(c)));
}
float3 Fast_LCh_to_DisplayFormat(float3 c)
{
return Fast_Linear_to_DisplayFormat(Oklab_to_RGB(LCh_to_Oklab(c)));
}
}
#line 33 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\pCamera.fx"
#line 43
static const float PI = pUtils::PI;
static const float EPSILON = pUtils::EPSILON;
static const float2 TEXEL_SIZE = float2((1.0 / 1920), (1.0 / 1018));
#line 48
uniform float BlurStrength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Blur amount";
ui_tooltip = "Amount of blur to apply";
ui_category = "Blur";
> = 0.0;
uniform int GaussianQuality <
ui_type = "radio";
ui_label = "Blur quality";
ui_tooltip = "Quality and size of gaussian blur";
ui_items = "High quality\0Medium quality\0Fast\0";
ui_category = "Blur";
> = 2;
#line 67
uniform bool UseDOF <
ui_type = "bool";
ui_label = "Enable DOF";
ui_tooltip = "Use depth of field\n\nMake sure depth is set up correctly using DisplayDepth.fx";
ui_category = "DOF";
> = false;
uniform float DOFAperture <
ui_type = "slider";
ui_min = 0.95; ui_max = 22.0;
ui_label = "Aperture";
ui_tooltip = "Aperture of the simulated camera";
ui_category = "DOF";
> = 1.4;
uniform int DOFFocalLength <
ui_type = "slider";
ui_min = 12u; ui_max = 85u;
ui_label = "Focal length";
ui_tooltip = "Focal length of the simulated camera";
ui_category = "DOF";
ui_units = " mm";
> = 35u;
uniform bool UseDOFAF <
ui_type = "bool";
ui_label = "Autofocus";
ui_tooltip = "Use autofocus";
ui_category = "DOF";
> = true;
uniform float DOFFocusSpeed <
ui_type = "slider";
ui_min = 0.0; ui_max = 5;
ui_label = "Focus speed";
ui_tooltip = "Focus speed in seconds";
ui_category = "DOF";
ui_units = " s";
> = 0.5;
uniform float DOFFocusPx <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Focus point X";
ui_tooltip = "AF focus point position X (width)\nLeft side = 0\nRight side = 1";
ui_category = "DOF";
> = 0.5;
uniform float DOFFocusPy <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Focus point Y";
ui_tooltip = "AF focus point position Y (height)\nTop side = 0\nBottom side = 1";
ui_category = "DOF";
> = 0.5;
uniform float DOFManualFocusDist <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Manual focus";
ui_tooltip = "Manual focus distance, only used when autofocus is disabled";
ui_category = "DOF";
> = 0.5;
uniform int BokehQuality <
ui_type = "radio";
ui_label = "Blur quality";
ui_tooltip = "Quality and size of bokeh blur";
ui_items = "High quality\0Medium quality\0Fast\0";
ui_category = "DOF";
> = 2;
uniform bool DOFDebug <
ui_type = "bool";
ui_label = "AF debug";
ui_tooltip = "Display autofocus point";
ui_category = "DOF";
> = false;
#line 138
uniform bool UseFE <
ui_type = "bool";
ui_label = "Fisheye";
ui_tooltip = "Adds fisheye distortion";
ui_category = "Fisheye";
> = false;
uniform int FEFoV <
ui_type = "slider";
ui_min = 20u; ui_max = 160u;
ui_label = "FOV";
ui_tooltip = "FOV in degrees\n\n(set to in-game FOV)";
ui_category = "Fisheye";
ui_units = "°";
> = 90u;
uniform float FECrop <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Crop";
ui_tooltip = "How much to crop into the image\n\n(0 = circular, 1 = full-frame)";
ui_category = "Fisheye";
> = 0.0;
uniform bool FEVFOV <
ui_type = "bool";
ui_label = "Use vertical FOV";
ui_tooltip = "Assume FOV is vertical\n\n(enable if FOV is given as vertical FOV)";
ui_category = "Fisheye";
> = false;
#line 167
uniform float GeoIStrength <
ui_type = "slider";
ui_min = 0.0; ui_max = 4.0;
ui_label = "Glass quality";
ui_tooltip = "Amount of surface lens imperfections";
ui_category = "Lens Imperfections";
> = 0.25;
#line 176
uniform float CAStrength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "CA amount";
ui_tooltip = "Amount of chromatic aberration";
ui_category = "Lens Imperfections";
> = 0.04;
#line 185
uniform float DirtStrength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Dirt amount";
ui_tooltip = "Amount of dirt on the lens";
ui_category = "Lens Imperfections";
> = 0.08;
uniform float DirtScale <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.5;
ui_label = "Dirt scale";
ui_tooltip = "Scaling of dirt texture";
ui_category = "Lens Imperfections";
> = 1.35;
#line 201
uniform float BloomStrength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Bloom amount";
ui_tooltip = "Amount of blooming to apply";
ui_category = "Bloom";
> = 0.28;
uniform float BloomShape <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Bloom shape";
ui_tooltip = "Controls shape of bloom";
ui_category = "Bloom";
> = 0.4;
uniform float BloomRadius <
ui_type = "slider";
ui_min = 0.25; ui_max = 1.5;
ui_label = "Bloom radius";
ui_tooltip = "Controls radius of bloom";
ui_category = "Bloom";
> = 0.8;
uniform float BloomCurve <
ui_type = "slider";
ui_min = 1.0; ui_max = 5.0;
ui_label = "Bloom curve";
ui_tooltip = "What parts of the image to apply bloom to\n1 = linear      5 = brightest parts only";
ui_category = "Bloom";
> = 1.0;
#line 236
static const float LFLARE_GLOCALMASK_DEFAULT = true;
static const float LFLARE_CURVE_DEFAULT = 1.0;
static const float LFLARE_STRENGTH_DEFAULT = 0.25;
#line 244
uniform bool UseLF <
ui_type = "bool";
ui_label = "Lens flare";
ui_tooltip = "Apply ghosting, haloing and glare from light sources";
ui_category = "Lens Flare";
> = true;
uniform bool GLocalMask <
ui_type = "bool";
ui_label = "Non-intrusive lens flares";
ui_tooltip = "Only apply flaring when looking right at light sources";
ui_category = "Lens Flare";
> = LFLARE_GLOCALMASK_DEFAULT;
uniform float LFStrength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Lens flare amount";
ui_tooltip = "Amount of flaring to apply";
ui_category = "Lens Flare";
> = LFLARE_STRENGTH_DEFAULT;
#line 410
static const float GhostStrength = 0.3;
static const float HaloStrength = 0.2;
static const float HaloRadius = 0.5;
static const float HaloWidth = 0.5;
static const float LensFlareCA = 1.0;
#line 416
uniform float GlareStrength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Glare amount";
ui_tooltip = "Amount of glare to apply";
ui_category = "Lens Flare";
> = 0.5;
uniform int GlareQuality <
ui_type = "radio";
ui_label = "Glare size";
ui_tooltip = "Quality and size of glare";
ui_items = "Large\0Medium\0Small\0";
ui_category = "Lens Flare";
> = 1;
uniform float LensFlareCurve <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_label = "Lens flare curve";
ui_tooltip = "What parts of the image produce lens flares";
ui_category = "Lens Flare";
> = LFLARE_CURVE_DEFAULT;
#line 448
uniform float VignetteStrength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Vignette amount";
ui_tooltip = "Amount of vignetting to apply";
ui_category = "Vignette";
> = 0.0;
uniform float VignetteInnerRadius <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.25;
ui_label = "Inner radius";
ui_tooltip = "Inner vignette radius";
ui_category = "Vignette";
> = 0.25;
uniform float VignetteOuterRadius <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.5;
ui_label = "Outer radius";
ui_tooltip = "Outer vignette radius";
ui_category = "Vignette";
> = 0.75;
uniform float VignetteWidth <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_label = "Width";
ui_tooltip = "Controls the shape of vignette";
ui_category = "Vignette";
> = 1.0;
uniform bool VignetteDebug <
ui_type = "bool";
ui_label = "Vignette debug";
ui_tooltip = "Display vignette radii";
ui_category = "Vignette";
> = false;
#line 484
uniform float NoiseStrength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Noise amount";
ui_tooltip = "Amount of noise to apply";
ui_category = "Noise";
> = 0.08;
uniform int NoiseType <
ui_type = "radio";
ui_label = "Noise type";
ui_tooltip = "Type of noise to use";
ui_items = "Film grain\0Color noise\0";
ui_category = "Noise";
> = 0;
#line 506
uniform bool UseAE <
ui_type = "bool";
ui_label = "Auto exposure";
ui_tooltip = "Enable auto exposure";
ui_category = "Auto Exposure";
> = false;
uniform bool AEProtectHighlights <
ui_type = "bool";
ui_label = "Only underexpose";
ui_tooltip = "Only changes exposure to recover blown-out highlights";
ui_category = "Auto Exposure";
> = false;
uniform float AESpeed <
ui_type = "slider";
ui_min = 0.0; ui_max = 10.0;
ui_label = "Speed";
ui_tooltip = "Auto exposure adaption speed in seconds";
ui_category = "Auto Exposure";
ui_units = " s";
> = 1.0;
uniform float AEGain <
ui_type = "slider";
ui_min = 0.1; ui_max = 1.0;
ui_label = "Gain";
ui_tooltip = "Auto exposure gain";
ui_category = "Auto Exposure";
> = 0.5;
uniform float AETarget <
ui_type = "slider";
ui_min = 0.02; ui_max = 1.0;
ui_label = "Target";
ui_tooltip = "Exposure target";
ui_category = "Auto Exposure";
> = 0.5;
uniform int AEMetering <
ui_type = "radio";
ui_label = "Metering mode";
ui_tooltip = "What metering mode is used:\nMatrix metering considers the whole screen\nSpot metering only considers the center of the screen";
ui_items = "Matrix\0Spot\0";
ui_category = "Auto Exposure";
> = 0;
uniform float AEHighlightSensitivity <
ui_type = "slider";
ui_min = 1.0; ui_max = 40.0;
ui_label = "Highlight sensitivity";
ui_tooltip = "Matrix metering: How sensitive metering is to overexposing highlights";
ui_category = "Auto Exposure";
> = 10.0;
uniform float AEPx <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "AE point X";
ui_tooltip = "Spot metering: Metering point X position (width)\nLeft side = 0\nRight side = 1";
ui_category = "Auto Exposure";
> = 0.5;
uniform float AEPy <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "AE point Y";
ui_tooltip = "Spot metering: Metering point Y position (height)\nTop side = 0\nBottom side = 1";
ui_category = "Auto Exposure";
> = 0.5;
uniform bool AEDebug <
ui_type = "bool";
ui_label = "AE debug";
ui_tooltip = "Spot metering: Display metering point";
ui_category = "Auto Exposure";
> = false;
#line 577
uniform bool UseApproximateTransforms <
ui_type = "bool";
ui_label = "Fast colorspace transform";
ui_tooltip = "Use less accurate approximations instead of the full transform functions";
ui_category = "Performance";
> = false;
#line 605
static const int STORAGE_TEX_MIPLEVELS = 3;
#line 607
texture pStorageTex < pooled = true; > { Width = 32; Height = 32; Format = RG16F; MipLevels = STORAGE_TEX_MIPLEVELS; };
sampler spStorageTex { Texture = pStorageTex; };
texture pStorageTexC < pooled = true; > { Width = 32; Height = 32; Format = RG16F; };
sampler spStorageTexC { Texture = pStorageTexC; };
#line 612
texture pBumpTex < source = "pBumpTex.png"; pooled = true; > { Width = 32; Height = 32; Format = RG8; };
sampler spBumpTex { Texture = pBumpTex; AddressU = REPEAT; AddressV = REPEAT; };
#line 615
texture pDirtTex < source = "pDirtTex.png"; pooled = true; > { Width = 1024; Height = 1024; Format = RGBA8; };
sampler spDirtTex { Texture = pDirtTex; AddressU = REPEAT; AddressV = REPEAT; };
#line 618
texture pBokehBlurTex < pooled = true; > { Width = 1920/2; Height = 1018/2; Format = RGBA16F; };
sampler spBokehBlurTex { Texture = pBokehBlurTex; AddressU = MIRROR; AddressV = MIRROR; };
texture pGaussianBlurTex < pooled = true; > { Width = 1920/2; Height = 1018/2; Format = RGBA16F; };
sampler spGaussianBlurTex { Texture = pGaussianBlurTex; AddressU = MIRROR; AddressV = MIRROR; };
#line 623
texture pFlareTex < pooled = true; > { Width = 1920/4; Height = 1018/4; Format = RGBA16F; };
sampler spFlareTex { Texture = pFlareTex; };
texture pFlareSrcTex < pooled = true; > { Width = 1920/4; Height = 1018/4; Format = RGBA16F; };
sampler spFlareSrcTex { Texture = pFlareSrcTex; AddressU = BORDER; AddressV = BORDER; };
#line 628
texture pBloomTex0 < pooled = true; > { Width = 1920/2; Height = 1018/2; Format = RGBA16F; };
sampler spBloomTex0 { Texture = pBloomTex0; AddressU = MIRROR; AddressV = MIRROR; };
texture pBloomTex1 < pooled = true; > { Width = 1920/4; Height = 1018/4; Format = RGBA16F; };
sampler spBloomTex1 { Texture = pBloomTex1; AddressU = MIRROR; AddressV = MIRROR; };
texture pBloomTex2 < pooled = true; > { Width = 1920/8; Height = 1018/8; Format = RGBA16F; };
sampler spBloomTex2 { Texture = pBloomTex2; AddressU = MIRROR; AddressV = MIRROR; };
texture pBloomTex3 < pooled = true; > { Width = 1920/16; Height = 1018/16; Format = RGBA16F; };
sampler spBloomTex3 { Texture = pBloomTex3; AddressU = MIRROR; AddressV = MIRROR; };
texture pBloomTex4 < pooled = true; > { Width = 1920/32; Height = 1018/32; Format = RGBA16F; };
sampler spBloomTex4 { Texture = pBloomTex4; AddressU = MIRROR; AddressV = MIRROR; };
texture pBloomTex5 < pooled = true; > { Width = 1920/64; Height = 1018/64; Format = RGBA16F; };
sampler spBloomTex5 { Texture = pBloomTex5; AddressU = MIRROR; AddressV = MIRROR; };
texture pBloomTex6 < pooled = true; > { Width = 1920/128; Height = 1018/128; Format = RGBA16F; };
sampler spBloomTex6 { Texture = pBloomTex6; AddressU = MIRROR; AddressV = MIRROR; };
texture pBloomTex7 < pooled = true; > { Width = 1920/256; Height = 1018/256; Format = RGBA16F; };
sampler spBloomTex7 { Texture = pBloomTex7; AddressU = MIRROR; AddressV = MIRROR; };
texture pBloomTex8 < pooled = true; > { Width = 1920/512; Height = 1018/512; Format = RGBA16F; };
sampler spBloomTex8 { Texture = pBloomTex8; AddressU = MIRROR; AddressV = MIRROR; };
#line 649
float2 FishEye(float2 texcoord, float FEFoV, float FECrop)
{
float2 radiant_vector = texcoord - 0.5;
float diagonal_length = length(pUtils::ASPECT_RATIO);
#line 654
float fov_factor = PI * float(FEFoV)/360.0;
if (FEVFOV)
{
fov_factor = atan(tan(fov_factor) * (1920 * (1.0 / 1018)));
}
#line 660
float fit_fov = sin(atan(tan(fov_factor) * diagonal_length));
float crop_value = lerp(1.0 + (diagonal_length - 1.0) * cos(fov_factor), diagonal_length, FECrop * pow(abs(sin(fov_factor)), 6.0));
#line 664
float2 cn_radiant_vector = 2.0 * radiant_vector * pUtils::ASPECT_RATIO / crop_value * fit_fov;
#line 666
if (length(cn_radiant_vector) < 1.0)
{
#line 669
float z = sqrt(1.0 - cn_radiant_vector.x*cn_radiant_vector.x - cn_radiant_vector.y*cn_radiant_vector.y);
float theta = acos(z) / fov_factor;
#line 672
float2 d = normalize(cn_radiant_vector);
texcoord = (theta * d) / (2.0 * pUtils::ASPECT_RATIO) + 0.5;
}
#line 676
return texcoord;
}
#line 679
float3 SampleLinear(float2 texcoord)
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
color = (UseApproximateTransforms)
? Oklab::Fast_DisplayFormat_to_Linear(color)
: Oklab::DisplayFormat_to_Linear(color);
return color;
}
float3 SampleLinear(float2 texcoord, bool use_tonemap)
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
color = (UseApproximateTransforms)
? Oklab::Fast_DisplayFormat_to_Linear(color)
: Oklab::DisplayFormat_to_Linear(color);
#line 694
if (use_tonemap && !Oklab::IS_HDR)
{
color = Oklab::TonemapInv(color);
}
#line 699
return color;
}
#line 702
float4 SampleCA(sampler s, float2 texcoord, float strength)
{
float3 influence = float3(0.04, 0.0, 0.03);
float2 CAr = (texcoord - 0.5) * (1.0 - strength * influence.r) + 0.5;
float2 CAb = (texcoord - 0.5) * (1.0 + strength * influence.b) + 0.5;
#line 708
float4 color;
color.r = tex2D(s, CAr).r;
color.ga = tex2D(s, texcoord).ga;
color.b = tex2D(s, CAb).b;
#line 713
return color;
}
#line 716
float3 RedoTonemap(float3 c)
{
return (Oklab::IS_HDR) ? c : Oklab::Tonemap(c);
}
#line 721
float3 ClipBlacks(float3 c)
{
return float3(max(c.r, 0.0), max(c.g, 0.0), max(c.b, 0.0));
}
#line 726
float4 KarisAverage(float4 c)
{
return 1.0 / (1.0 + Oklab::get_Luminance_RGB(c.rgb) * 0.25);
}
#line 731
float4 GaussianBlur(sampler s, float2 texcoord, float2 texel_size, float size, float2 direction, bool sample_linear, int quality)
{
float2 step_length = texel_size * size;
#line 735
int start;
int end;
switch (quality)
{
case 0: 
{
start = 12;
end = 28;
} break;
case 1: 
{
start = 4;
end = 12;
} break;
case 2: 
{
start = 0;
end = 4;
} break;
}
#line 756
static const float OFFSET[28] = { 0.0, 1.4118, 3.2941, 5.1765,
0.0, 1.4839, 3.4624, 5.4409, 7.4194, 9.3978, 11.3763, 13.3548,
0.0, 1.4971, 3.4931, 5.4892, 7.4853, 9.4813, 11.4774, 13.4735, 15.4695, 17.4656, 19.4617, 21.4578, 23.4538, 25.4499, 27.4460, 29.4420 };
static const float WEIGHT[28] = { 0.1965, 0.2969, 0.0945, 0.0104,
0.0832, 0.1577, 0.1274, 0.0868, 0.0497, 0.0239, 0.0096, 0.0032,
0.0356, 0.0706, 0.0678, 0.0632, 0.0571, 0.0500, 0.0424, 0.0348, 0.0277, 0.0214, 0.0160, 0.0116, 0.0081, 0.0055, 0.0036, 0.0023 };
#line 763
float4 color;
[branch]
if (sample_linear)
{
color.rgb = SampleLinear(texcoord, true) * WEIGHT[start];
[unroll]
for (int i = start + 1; i < end; ++i)
{
color.rgb += SampleLinear(texcoord + direction * OFFSET[i] * step_length, true) * WEIGHT[i];
color.rgb += SampleLinear(texcoord - direction * OFFSET[i] * step_length, true) * WEIGHT[i];
}
}
else
{
color = tex2D(s, texcoord) * WEIGHT[start];
[unroll]
for (int i = start + 1; i < end; ++i)
{
color += tex2D(s, texcoord + direction * OFFSET[i] * step_length) * WEIGHT[i];
color += tex2D(s, texcoord - direction * OFFSET[i] * step_length) * WEIGHT[i];
}
}
#line 786
return color;
}
#line 789
float3 BokehBlur(sampler s, float2 texcoord, float2 texel_size, float size, bool sample_linear)
{
float brightness_compensation;
float size_compensation;
int samples;
#line 795
switch (BokehQuality)
{
case 0: 
{
brightness_compensation = 0.010989010989;
size_compensation = 1.0;
samples = 90;
} break;
case 1: 
{
brightness_compensation = 0.027027027027;
size_compensation = 1.666666666667;
samples = 36;
} break;
case 2: 
{
brightness_compensation = 0.0769230769231;
size_compensation = 2.5;
samples = 12;
} break;
}
#line 817
static const float2 OFFSET[90] = { float2(0.0, 4.0), float2(3.4641, 2.0), float2(3.4641, -2.0), float2(0.0, -4.0), float2(-3.4641, -2.0), float2(-3.4641, 2.0), float2(0.0, 8.0), float2(6.9282, 4.0), float2(6.9282, -4.0), float2(0.0, -8.0), float2(-6.9282, -4.0), float2(-6.9282, 4.0), float2(4.0, 6.9282), float2(8.0, 0.0), float2(4.0, -6.9282), float2(-4.0, -6.9282), float2(-8.0, 0.0), float2(-4.0, 6.9282), float2(0.0, 12.0), float2(4.1042, 11.2763), float2(7.7135, 9.1925), float2(10.3923, 6.0), float2(11.8177, 2.0838), float2(11.8177, -2.0838), float2(10.3923, -6.0), float2(7.7135, -9.1925), float2(4.1042, -11.2763), float2(0.0, -12.0), float2(-4.1042, -11.2763), float2(-7.7135, -9.1925), float2(-10.3923, -6.0), float2(-11.8177, -2.0838), float2(-11.8177, 2.0838), float2(-10.3923, 6.0), float2(-7.7135, 9.1925), float2(-4.1042, 11.2763), float2(0.0, 16.0), float2(4.1411, 15.4548), float2(8.0, 13.8564), float2(11.3137, 11.3137), float2(13.8564, 8.0), float2(15.4548, 4.1411), float2(16.0, 0.0), float2(15.4548, -4.1411), float2(13.8564, -8.0), float2(11.3137, -11.3137), float2(8.0, -13.8564), float2(4.1411, -15.4548), float2(0.0, -16.0), float2(-4.1411, -15.4548), float2(-8.0, -13.8564), float2(-11.3137, -11.3137), float2(-13.8564, -8.0), float2(-15.4548, -4.1411), float2(-16.0, 0.0), float2(-15.4548, 4.1411), float2(-13.8564, 8.0), float2(-11.3137, 11.3137), float2(-8.0, 13.8564), float2(-4.1411, 15.4548), float2(0.0, 20.0), float2(4.1582, 19.563), float2(8.1347, 18.2709), float2(11.7557, 16.1803), float2(14.8629, 13.3826), float2(17.3205, 10.0), float2(19.0211, 6.1803), float2(19.8904, 2.0906), float2(19.8904, -2.0906), float2(19.0211, -6.1803), float2(17.3205, -10.0), float2(14.8629, -13.3826), float2(11.7557, -16.1803), float2(8.1347, -18.2709), float2(4.1582, -19.563), float2(0.0, -20.0), float2(-4.1582, -19.563), float2(-8.1347, -18.2709), float2(-11.7557, -16.1803), float2(-14.8629, -13.3826), float2(-17.3205, -10.0), float2(-19.0211, -6.1803), float2(-19.8904, -2.0906), float2(-19.8904, 2.0906), float2(-19.0211, 6.1803), float2(-17.3205, 10.0), float2(-14.8629, 13.3826), float2(-11.7557, 16.1803), float2(-8.1347, 18.2709), float2(-4.1582, 19.563) };
#line 819
float2 step_length = texel_size * size * size_compensation;
#line 821
static const float MAX_VARIANCE = 0.1;
float2 variance = pUtils::FrameCount * float2(sin(2000.0 * PI * texcoord.x), cos(2000.0 * PI * texcoord.y)) * 1000.0;
variance %= MAX_VARIANCE;
variance = 1.0 + variance - MAX_VARIANCE * 0.5;
#line 826
float3 color;
[branch]
if (sample_linear)
{
color = SampleLinear(texcoord, true);
[unroll]
for (int i = 0; i < samples; ++i)
{
color += SampleLinear(texcoord + step_length * OFFSET[i] * variance, true);
}
}
else
{
color = tex2D(s, texcoord).rgb;
[unroll]
for (int i = 0; i < samples; ++i)
{
color += tex2D(s, texcoord + step_length * OFFSET[i] * variance).rgb;
}
}
#line 847
return color * brightness_compensation;
}
#line 850
float4 KawaseBlurDownSample(sampler s, float2 texcoord, float2 texel_size)
{
float2 half_texel = texel_size * 0.5;
#line 854
float2 DirDiag1 = float2(-half_texel.x,  half_texel.y); 
float2 DirDiag2 = float2( half_texel.x,  half_texel.y); 
float2 DirDiag3 = float2( half_texel.x, -half_texel.y); 
float2 DirDiag4 = float2(-half_texel.x, -half_texel.y); 
#line 859
float4 color = tex2D(s, texcoord) * 4.0;
color += tex2D(s, texcoord + DirDiag1);
color += tex2D(s, texcoord + DirDiag2);
color += tex2D(s, texcoord + DirDiag3);
color += tex2D(s, texcoord + DirDiag4);
#line 865
return color * 0.125;
}
float4 KawaseBlurUpSample(sampler s, float2 texcoord, float2 texel_size)
{
float2 half_texel = float2((1.0 / 1920), (1.0 / 1018)) * 0.5;
#line 871
float2 DirDiag1 = float2(-half_texel.x,  half_texel.y); 
float2 DirDiag2 = float2( half_texel.x,  half_texel.y); 
float2 DirDiag3 = float2( half_texel.x, -half_texel.y); 
float2 DirDiag4 = float2(-half_texel.x, -half_texel.y); 
float2 DirAxis1 = float2(-half_texel.x,  0.0);          
float2 DirAxis2 = float2( half_texel.x,  0.0);          
float2 DirAxis3 = float2(0.0,  half_texel.y);           
float2 DirAxis4 = float2(0.0, -half_texel.y);           
#line 880
float4 color = 0.0;
color += tex2D(s, texcoord + DirDiag1);
color += tex2D(s, texcoord + DirDiag2);
color += tex2D(s, texcoord + DirDiag3);
color += tex2D(s, texcoord + DirDiag4);
#line 886
color += tex2D(s, texcoord + DirAxis1) * 2.0;
color += tex2D(s, texcoord + DirAxis2) * 2.0;
color += tex2D(s, texcoord + DirAxis3) * 2.0;
color += tex2D(s, texcoord + DirAxis4) * 2.0;
#line 891
return color / 12.0;
}
#line 894
float4 HQDownSample(sampler s, float2 texcoord, float2 texel_size)
{
static const float2 OFFSET[16] = { float2(-0.5, 0.5), float2(0.5, 0.5), float2(-0.5, -0.5), float2(0.5, -0.5),
float2(-1.5, 1.5), float2(-0.5, 1.5), float2(-1.5, 0.5),
float2(1.5, 1.5), float2(0.5, 1.5), float2(1.5, 0.5),
float2(-1.5, -1.5), float2(-0.5, -1.5), float2(-1.5, -0.5),
float2(1.5, -1.5), float2(0.5, -1.5), float2(1.5, -0.5) };
static const float WEIGHT[16] = { 0.125, 0.125, 0.125, 0.125,
0.041, 0.042, 0.042,
0.041, 0.042, 0.042,
0.041, 0.042, 0.042,
0.041, 0.042, 0.042 };
#line 907
float4 color;
[unroll]
for (int i = 0; i < 16; ++i)
{
color += tex2Dlod(s, float4(texcoord + OFFSET[i] * texel_size, 0.0, 0.0)) * WEIGHT[i];
}
#line 914
return color;
}
float4 HQDownSampleKA(sampler s, float2 texcoord, float2 texel_size)
{
static const float2 OFFSET[16] = { float2(-0.5, 0.5), float2(0.5, 0.5), float2(-0.5, -0.5), float2(0.5, -0.5),
float2(-1.5, 1.5), float2(-0.5, 1.5), float2(-1.5, 0.5),
float2(1.5, 1.5), float2(0.5, 1.5), float2(1.5, 0.5),
float2(-1.5, -1.5), float2(-0.5, -1.5), float2(-1.5, -0.5),
float2(1.5, -1.5), float2(0.5, -1.5), float2(1.5, -0.5) };
#line 924
float4 samplecolor[16];
[unroll]
for (int i = 0; i < 16; ++i)
{
samplecolor[i] = tex2Dlod(s, float4(texcoord + OFFSET[i] * texel_size, 0.0, 0.0));
}
#line 932
float4 groups[9];
groups[0] = 0.125 * (samplecolor[0] + samplecolor[1] + samplecolor[2] + samplecolor[3]);
groups[1] = 0.015625 * (samplecolor[4] + samplecolor[5] + samplecolor[6] + samplecolor[0]);
groups[2] = 0.015625 * (samplecolor[5] + samplecolor[8] + samplecolor[0] + samplecolor[1]);
groups[3] = 0.015625 * (samplecolor[7] + samplecolor[8] + samplecolor[9] + samplecolor[1]);
groups[4] = 0.015625 * (samplecolor[6] + samplecolor[0] + samplecolor[12] + samplecolor[2]);
groups[5] = 0.015625 * (samplecolor[10] + samplecolor[11] + samplecolor[12] + samplecolor[2]);
groups[6] = 0.015625 * (samplecolor[1] + samplecolor[9] + samplecolor[3] + samplecolor[15]);
groups[7] = 0.015625 * (samplecolor[13] + samplecolor[14] + samplecolor[15] + samplecolor[3]);
groups[8] = 0.015625 * (samplecolor[2] + samplecolor[3] + samplecolor[11] + samplecolor[14]);
#line 944
[unroll]
for (int i = 0; i < 9; ++i)
{
groups[i] *= KarisAverage(groups[i]);
}
#line 950
return groups[0] + groups[1] + groups[2] + groups[3] + groups[4] + groups[5] + groups[6] + groups[7] + groups[8];
}
#line 953
float4 HQUpSample(sampler s, float2 texcoord, float2 texel_size, float radius, float weight)
{
static const float2 OFFSET[9] = { float2(-1.0, 1.0), float2(0.0, 1.0), float2(1.0, 1.0),
float2(-1.0, 0.0), float2(0.0, 0.0), float2(1.0, 0.0),
float2(-1.0, -1.0), float2(0.0, -1.0), float2(1.0, -1.0) };
static const float WEIGHT[9] = { 0.0625, 0.125, 0.0625,
0.125, 0.25, 0.125,
0.0625, 0.125, 0.0625 };
#line 962
float4 color;
[unroll]
for (int i = 0; i < 9; ++i)
{
color += tex2Dlod(s, float4(texcoord + OFFSET[i] * texel_size * radius, 0.0, 0.0)) * WEIGHT[i];
}
color *= weight;
#line 970
return color;
}
#line 975
struct vs2ps
{
float4 vpos : SV_Position;
float4 texcoord : TexCoord;
};
#line 981
vs2ps vs_basic(const uint id)
{
vs2ps o;
o.texcoord.x = (id == 2) ? 2.0 : 0.0;
o.texcoord.y = (id == 1) ? 2.0 : 0.0;
o.vpos = float4(o.texcoord.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
return o;
}
#line 990
vs2ps VS_Storage(uint id : SV_VertexID)
{
vs2ps o = vs_basic(id);
if ((UseDOFAF && UseDOF) || UseAE)
{
o.texcoord.w = ReShade::GetLinearizedDepth(float2(DOFFocusPx, DOFFocusPy));
}
else
{
o.vpos.xy = 0.0;
}
return o;
}
#line 1004
vs2ps VS_Blur(uint id : SV_VertexID)
{
vs2ps o = vs_basic(id);
if (BlurStrength == 0.0)
{
o.vpos.xy = 0.0;
}
return o;
}
#line 1014
vs2ps VS_DOF(uint id : SV_VertexID)
{
vs2ps o = vs_basic(id);
if (UseDOF)
{
float depth = (UseDOFAF) ? tex2Dfetch(spStorageTex, 0, 0).x : DOFManualFocusDist;
float scale = ((float(DOFFocalLength*DOFFocalLength) / 10000.0) * float(36.0) / 18.0) / ((1.0 + depth*depth) * DOFAperture) * length(float2(1920, 1018))/2048.0;
o.texcoord.z = depth;
o.texcoord.w = scale;
}
else
{
o.vpos.xy = 0.0;
}
return o;
}
#line 1031
vs2ps VS_Bloom(uint id : SV_VertexID)
{
vs2ps o = vs_basic(id);
if (BloomStrength == 0.0 && DirtStrength == 0.0)
{
o.vpos.xy = 0.0;
}
return o;
}
#line 1041
vs2ps VS_BloomLF(uint id : SV_VertexID)
{
vs2ps o = vs_basic(id);
if (BloomStrength == 0.0 && DirtStrength == 0.0 && (!UseLF || ((LFStrength == 0.0 || (GhostStrength == 0.0 && HaloStrength == 0.0)) && GlareStrength == 0.0)))
{
o.vpos.xy = 0.0;
}
return o;
}
#line 1051
vs2ps VS_Ghosts(uint id : SV_VertexID)
{
vs2ps o = vs_basic(id);
if (!UseLF || ((LFStrength == 0.0 || (GhostStrength == 0.0 && HaloStrength == 0.0)) && GlareStrength == 0.0))
{
o.vpos.xy = 0.0;
}
return o;
}
#line 1061
vs2ps VS_Glare(uint id : SV_VertexID)
{
vs2ps o = vs_basic(id);
if (!UseLF || GlareStrength == 0.0)
{
o.vpos.xy = 0.0;
}
else
{
o.texcoord.z = GlareStrength * (0.4 * GlareQuality + 1.0);
}
return o;
}
#line 1075
vs2ps VS_Camera(uint id : SV_VertexID)
{
vs2ps o = vs_basic(id);
float exposure;
switch (AEMetering)
{
case 0: 
{
float s;
float2 OFFSET[9] = { float2(0.5, 0.5), float2(0.15, 0.15), float2(0.25, 0.5), float2(0.15, 0.85), float2(0.5, 0.25), float2(0.5, 0.75), float2(0.85, 0.15), float2(0.75, 0.5), float2(0.85, 0.85) };
float WEIGHT[9] = { 0.25, 0.0625, 0.125, 0.0625, 0.125, 0.125, 0.0625, 0.125, 0.0625 };
#line 1087
[unroll]
for (int i = 0; i < 9; ++i)
{
s = tex2Dlod(spStorageTex, float4(OFFSET[i], 0.0, STORAGE_TEX_MIPLEVELS - 1)).y;
#line 1092
exposure += ((s > AETarget) ? AEHighlightSensitivity * (s - AETarget * (1.0 - rcp(AEHighlightSensitivity))) : s) * WEIGHT[i];
}
} break;
case 1: 
{
exposure = tex2Dlod(spStorageTex, float4(AEPx, AEPy, 0.0, STORAGE_TEX_MIPLEVELS - 1)).y;
} break;
}
o.texcoord.z = exposure;
return o;
}
#line 1106
float2 StoragePass(vs2ps o) : COLOR
{
float2 data = tex2D(spStorageTexC, o.texcoord.xy).xy;
#line 1110
data.x = lerp(data.x, o.texcoord.w, min(pUtils::FrameTime / (DOFFocusSpeed * 500.0 + EPSILON), 1.0));
#line 1113
data.y = lerp(data.y, max(Oklab::get_Adapted_Luminance_RGB(SampleLinear(o.texcoord.xy).rgb, 1.0), 0.02), min(pUtils::FrameTime / (AESpeed * 1000.0 + EPSILON), 1.0));
return data.xy;
}
float2 StoragePassC(float4 vpos : SV_Position, float2 texcoord : TexCoord) : COLOR
{
return tex2D(spStorageTex, texcoord).xy;
}
#line 1122
float3 GaussianBlurPass1(vs2ps o) : COLOR
{
return GaussianBlur(spBumpTex, o.texcoord.xy, TEXEL_SIZE, BlurStrength, float2(1.0, 0.0), true, GaussianQuality).rgb;
}
float3 GaussianBlurPass2(vs2ps o) : COLOR
{
return GaussianBlur(spBokehBlurTex, o.texcoord.xy, TEXEL_SIZE, BlurStrength, float2(0.0, 1.0), false, GaussianQuality).rgb;
}
#line 1132
float4 BokehBlurPass(vs2ps o) : COLOR
{
float size = abs(ReShade::GetLinearizedDepth(o.texcoord.xy) - o.texcoord.z) * o.texcoord.w;
float4 color;
color.rgb = (BlurStrength != 0.0) ? BokehBlur(spGaussianBlurTex, o.texcoord.xy, TEXEL_SIZE, size, false) : BokehBlur(spBumpTex, o.texcoord.xy, TEXEL_SIZE, size, true);
color.a = size;
#line 1139
return color;
}
#line 1143
float4 HighPassFilter(vs2ps o) : COLOR
{
float3 color = (UseDOF) ? tex2D(spBokehBlurTex, o.texcoord.xy).rgb : (BlurStrength == 0.0) ? SampleLinear(o.texcoord.xy, true).rgb : tex2D(spGaussianBlurTex, o.texcoord.xy).rgb;
float adapted_luminance = Oklab::get_Adapted_Luminance_RGB(RedoTonemap(color), 1.0);
#line 1148
float mask = pow(abs(Oklab::get_Adapted_Luminance_RGB(color, Oklab::INVNORM_FACTOR) / (1.0 + Oklab::INVNORM_FACTOR)), LensFlareCurve*LensFlareCurve + EPSILON);
#line 1150
color *= pow(abs(adapted_luminance), BloomCurve*BloomCurve);
return float4(color, mask);
}
#line 1154
float4 BloomDownS1(vs2ps o) : COLOR
{
return HQDownSampleKA(spBloomTex0, o.texcoord.xy, 2*TEXEL_SIZE);
}
float4 BloomDownS2(vs2ps o) : COLOR
{
return HQDownSample(spBloomTex1, o.texcoord.xy, 4*TEXEL_SIZE);
}
float4 BloomDownS3(vs2ps o) : COLOR
{
return HQDownSample(spBloomTex2, o.texcoord.xy, 8*TEXEL_SIZE);
}
float4 BloomDownS4(vs2ps o) : COLOR
{
return HQDownSample(spBloomTex3, o.texcoord.xy, 16*TEXEL_SIZE);
}
float4 BloomDownS5(vs2ps o) : COLOR
{
return HQDownSample(spBloomTex4, o.texcoord.xy, 32*TEXEL_SIZE);
}
float4 BloomDownS6(vs2ps o) : COLOR
{
return HQDownSample(spBloomTex5, o.texcoord.xy, 64*TEXEL_SIZE);
}
float4 BloomDownS7(vs2ps o) : COLOR
{
return HQDownSample(spBloomTex6, o.texcoord.xy, 128*TEXEL_SIZE);
}
float4 BloomDownS8(vs2ps o) : COLOR
{
return HQDownSample(spBloomTex7, o.texcoord.xy, 256*TEXEL_SIZE);
}
#line 1187
float4 BloomUpS7(vs2ps o) : COLOR
{
return HQUpSample(spBloomTex8, o.texcoord.xy, 512*TEXEL_SIZE, BloomRadius, exp2(-BloomShape*BloomShape * 10.0));
}
float4 BloomUpS6(vs2ps o) : COLOR
{
return HQUpSample(spBloomTex7, o.texcoord.xy, 256*TEXEL_SIZE, BloomRadius, exp2(-BloomShape*BloomShape * 3.0));
}
float4 BloomUpS5(vs2ps o) : COLOR
{
return HQUpSample(spBloomTex6, o.texcoord.xy, 128*TEXEL_SIZE, BloomRadius, exp2(-BloomShape*BloomShape * 2.0));
}
float4 BloomUpS4(vs2ps o) : COLOR
{
return HQUpSample(spBloomTex5, o.texcoord.xy, 64*TEXEL_SIZE, BloomRadius, exp2(-BloomShape*BloomShape * 1.4));
}
float4 BloomUpS3(vs2ps o) : COLOR
{
return HQUpSample(spBloomTex4, o.texcoord.xy, 32*TEXEL_SIZE, BloomRadius, exp2(-BloomShape*BloomShape * 1.2));
}
float4 BloomUpS2(vs2ps o) : COLOR
{
return HQUpSample(spBloomTex3, o.texcoord.xy, 16*TEXEL_SIZE, BloomRadius, exp2(-BloomShape*BloomShape * 0.8));
}
float4 BloomUpS1(vs2ps o) : COLOR
{
return HQUpSample(spBloomTex2, o.texcoord.xy, 8*TEXEL_SIZE, BloomRadius, exp2(-BloomShape*BloomShape * 3.0));
}
float4 BloomUpS0(vs2ps o) : COLOR
{
float4 color = HQUpSample(spBloomTex1, o.texcoord.xy, 4*TEXEL_SIZE, BloomRadius, 1.0);
color.rgb = RedoTonemap(color.rgb);
return color;
}
#line 1224
float4 FlareDownS2(vs2ps o) : COLOR
{
return KawaseBlurDownSample(spFlareTex, o.texcoord.xy, 4*TEXEL_SIZE);
}
float4 FlareDownS3(vs2ps o) : COLOR
{
return KawaseBlurDownSample(spBloomTex2, o.texcoord.xy, 8*TEXEL_SIZE);
}
float4 FlareDownS4(vs2ps o) : COLOR
{
return KawaseBlurDownSample(spBloomTex3, o.texcoord.xy, 16*TEXEL_SIZE);
}
float4 FlareDownS5(vs2ps o) : COLOR
{
return KawaseBlurDownSample(spBloomTex4, o.texcoord.xy, 32*TEXEL_SIZE);
}
#line 1241
float4 FlareUpS4(vs2ps o) : COLOR
{
return KawaseBlurUpSample(spBloomTex5, o.texcoord.xy, 64*TEXEL_SIZE);
}
float4 FlareUpS3(vs2ps o) : COLOR
{
return KawaseBlurUpSample(spBloomTex4, o.texcoord.xy, 32*TEXEL_SIZE);
}
float4 FlareUpS2(vs2ps o) : COLOR
{
return KawaseBlurUpSample(spBloomTex3, o.texcoord.xy, 16*TEXEL_SIZE);
}
float4 FlareUpS1(vs2ps o) : COLOR
{
return KawaseBlurUpSample(spBloomTex2, o.texcoord.xy, 8*TEXEL_SIZE);
}
#line 1258
float4 CAPass(vs2ps o) : COLOR
{
return SampleCA(spBloomTex1, o.texcoord.xy, LensFlareCA);
}
float3 GhostsPass(vs2ps o) : COLOR
{
float weight;
float4 s = 0.0;
float3 color = 0.0;
#line 1268
float2 texcoord_clean = o.texcoord.xy;
o.texcoord.xy = FishEye(texcoord_clean, FEFoV, FECrop);
#line 1272
float2 radiant_vector;
float2 halo_vector;
if (UseFE)
{
radiant_vector = o.texcoord.xy - 0.5;
halo_vector = texcoord_clean;
}
else
{
radiant_vector = texcoord_clean - 0.5;
halo_vector = o.texcoord.xy;
}
#line 1286
if (GhostStrength != 0.0)
{
#line 1289
for(int i = 0; i < 8; i++)
{
#line 1296
static const float4 GHOST_COLORS[8] = { float4(1.0, 0.8, 0.4, 1.0), float4(1.0, 1.0, 0.6, 1.0), float4(0.8, 0.8, 1.0, 1.0), float4(0.5, 1.0, 0.4, 1.0), float4(0.5, 0.8, 1.0, 1.0), float4(0.9, 1.0, 0.8, 1.0), float4(1.0, 0.8, 0.4, 1.0), float4(0.9, 0.7, 0.7, 1.0) };
static const float GHOST_SCALES[8] = { -1.5, 2.5, -5.0, 10.0, 0.7, -0.4, -0.2, -0.1 };
#line 1301
if(abs(GHOST_COLORS[i].a * GHOST_SCALES[i]) > 0.0001)
{
float2 ghost_vector = radiant_vector * GHOST_SCALES[i];
#line 1306
float distance_mask = 1.0 - length(ghost_vector);
if (GLocalMask)
{
float mask1 = smoothstep(0.5, 0.9, distance_mask);
float mask2 = smoothstep(0.75, 1.0, distance_mask) * 0.95 + 0.05;
weight = mask1 * mask2;
}
else
{
weight = distance_mask;
}
#line 1318
float4 s = tex2D(spFlareSrcTex, ghost_vector + 0.5);
color += s.rgb * s.a * GHOST_COLORS[i].rgb * GHOST_COLORS[i].a * weight;
}
}
#line 1324
static const float SBMASK_SIZE = 0.9;
float sb_mask = clamp(length(float2(abs(SBMASK_SIZE * texcoord_clean.x - 0.5), abs(SBMASK_SIZE * texcoord_clean.y - 0.5))), 0.0, 1.0);
#line 1327
color *= sb_mask * (GhostStrength*GhostStrength);
}
#line 1331
if (HaloStrength != 0.0)
{
halo_vector -= normalize(radiant_vector) * HaloRadius;
weight = 1.0 - min(rcp(HaloWidth + EPSILON) * length(0.5 - halo_vector), 1.0);
weight = pow(abs(weight), 5.0);
#line 1337
s = SampleCA(spFlareSrcTex, halo_vector, 8.0 * LensFlareCA);
color += s.rgb * s.a * weight * (HaloStrength*HaloStrength);
}
#line 1341
return color * (LFStrength*LFStrength);
}
float3 GlarePass(vs2ps o) : COLOR
{
float2 texel_size = 4*TEXEL_SIZE;
float2 radiant_vector = o.texcoord.xy - 0.5;
#line 1348
float2 d_vertical = float2(0.1, 1.0) - 0.5 * radiant_vector;
float2 d_horizontal = float2(1.0, -0.3) + 0.5 * radiant_vector;
d_vertical /= length(d_vertical);
d_horizontal /= length(d_horizontal);
#line 1353
float4 s_vertical = GaussianBlur(spBloomTex1, o.texcoord.xy, texel_size, o.texcoord.z, d_vertical, false, GlareQuality);
float4 s_horizontal = GaussianBlur(spBloomTex1, o.texcoord.xy, texel_size, o.texcoord.z, d_horizontal, false, GlareQuality);
#line 1356
return (s_vertical.rgb * s_vertical.a + s_horizontal.rgb * s_horizontal.a) * (GlareStrength * GlareStrength) / (0.5 * GlareQuality + 1.0);
}
#line 1359
float3 CameraPass(vs2ps o) : SV_Target
{
static const float INVNORM_FACTOR = Oklab::INVNORM_FACTOR;
float2 radiant_vector = o.texcoord.xy - 0.5;
float2 texcoord_clean = o.texcoord.xy;
#line 1367
if (UseFE)
{
o.texcoord.xy = FishEye(texcoord_clean, FEFoV, FECrop);
}
#line 1373
if (GeoIStrength != 0.0)
{
float2 bump = 0.6666667 * tex2D(spBumpTex, o.texcoord.xy * 4).xy + 0.3333333 * tex2D(spBumpTex, o.texcoord.xy * 4 * 3.0).xy;
#line 1377
bump = bump * 2.0 - 1.0;
o.texcoord.xy += bump * TEXEL_SIZE * (GeoIStrength * GeoIStrength);
}
float3 color = SampleLinear(o.texcoord.xy).rgb;
#line 1383
float blur_mix = min((4 - GaussianQuality) * BlurStrength, 1.0);
if (BlurStrength != 0.0)
{
color = lerp(color, RedoTonemap(tex2D(spGaussianBlurTex, o.texcoord.xy).rgb), blur_mix);
}
#line 1390
if (UseDOF)
{
float4 dof_data = tex2D(spBokehBlurTex, o.texcoord.xy);
float dof_mix = min(10.0 * dof_data.a, 1.0);
color = lerp(color, RedoTonemap(dof_data.rgb), dof_mix);
}
#line 1398
if (CAStrength != 0.0)
{
float3 influence = float3(-0.04, 0.0, 0.03);
#line 1402
float2 step_length = CAStrength * radiant_vector;
color.r = (UseDOF) ? RedoTonemap(tex2D(spBokehBlurTex, o.texcoord.xy + step_length * influence.r).rgb).r : lerp(SampleLinear(o.texcoord.xy + step_length * influence.r).r, RedoTonemap(tex2D(spGaussianBlurTex, o.texcoord.xy + step_length * influence.r).rgb).r, blur_mix);
color.b = (UseDOF) ? RedoTonemap(tex2D(spBokehBlurTex, o.texcoord.xy + step_length * influence.b).rgb).b : lerp(SampleLinear(o.texcoord.xy + step_length * influence.b).b, RedoTonemap(tex2D(spGaussianBlurTex, o.texcoord.xy + step_length * influence.b).rgb).b, blur_mix);
}
#line 1408
if (DirtStrength != 0.0)
{
float3 weight = 0.15 * length(radiant_vector) * tex2D(spBloomTex6, -radiant_vector + 0.5).rgb + 0.25 * tex2D(spBloomTex3, o.texcoord.xy).rgb;
color += tex2D(spDirtTex, o.texcoord.xy * float2(1.0, TEXEL_SIZE.x / TEXEL_SIZE.y) * DirtScale).rgb * weight * DirtStrength;
}
#line 1415
if (BloomStrength != 0.0)
{
color += (BloomStrength*BloomStrength) * tex2D(spBloomTex0, o.texcoord.xy).rgb;
}
#line 1421
if (UseLF && (GlareStrength != 0.0 || (LFStrength != 0.0 && (GhostStrength != 0.0 || HaloStrength != 0.0))))
{
color += tex2D(spFlareTex, o.texcoord.xy).rgb;
}
#line 1427
if (VignetteStrength != 0.0)
{
float weight = clamp((length(float2(abs(texcoord_clean.x - 0.5) * rcp(VignetteWidth), abs(texcoord_clean.y - 0.5))) - VignetteInnerRadius) / (VignetteOuterRadius - VignetteInnerRadius), 0.0, 1.0);
color.rgb *= 1.0 - VignetteStrength * weight;
}
#line 1434
if (NoiseStrength != 0.0)
{
static const float NOISE_CURVE = max(INVNORM_FACTOR * 0.025, 1.0);
float luminance = Oklab::get_Luminance_RGB(color);
#line 1440
float noise1 = pUtils::wnoise(texcoord_clean, float2(6.4949, 39.116));
float noise2 = pUtils::wnoise(texcoord_clean, float2(19.673, 5.5675));
float noise3 = pUtils::wnoise(texcoord_clean, float2(36.578, 26.118));
#line 1445
float r = sqrt(-2.0 * log(noise1 + EPSILON));
float theta1 = 2.0 * PI * noise2;
float theta2 = 2.0 * PI * noise3;
#line 1450
float3 gauss_noise = float3(r * cos(theta1) * 1.33, r * sin(theta1) * 1.25, r * cos(theta2) * 2.0);
gauss_noise = (NoiseType == 0) ? gauss_noise.rrr : gauss_noise;
#line 1453
float weight = (NoiseStrength * NoiseStrength) * NOISE_CURVE / (luminance * (1.0 + rcp(INVNORM_FACTOR)) + 2.0); 
color.rgb = ClipBlacks(color.rgb + gauss_noise * weight);
}
#line 1458
if (UseAE && ((AEProtectHighlights && o.texcoord.z > AETarget) || !AEProtectHighlights))
{
color *= lerp(1.0, AETarget / o.texcoord.z, AEGain);
}
#line 1464
if (AEDebug)
{
if (pow(abs(texcoord_clean.x - AEPx) * (1920 * (1.0 / 1018)), 2.0) + pow(abs(texcoord_clean.y - AEPy), 2.0) < 0.001)
{
color.rgb = float3(0.0, 0.0, 1.0) * INVNORM_FACTOR;
}
}
if (DOFDebug)
{
if (pow(abs(texcoord_clean.x - DOFFocusPx) * (1920 * (1.0 / 1018)), 2.0) + pow(abs(texcoord_clean.y - DOFFocusPy), 2.0) < 0.0001)
{
color.rgb = float3(1.0, 0.0, 0.0) * INVNORM_FACTOR;
}
}
if (VignetteDebug)
{
float vignette_distance = length(radiant_vector * float2(rcp(VignetteWidth), 1.0));
if (abs(vignette_distance - VignetteInnerRadius) < 0.001) 
{
color.rgb = float3(1.0, 0.0, 0.0) * INVNORM_FACTOR;
}
if (abs(vignette_distance - VignetteOuterRadius) < 0.0015) 
{
color.rgb = float3(1.0, 0.0, 0.0) * INVNORM_FACTOR;
}
}
#line 1491
if (!Oklab::IS_HDR) { color = Oklab::Saturate_RGB(color); }
color = (UseApproximateTransforms)
? Oklab::Fast_Linear_to_DisplayFormat(color)
: Oklab::Linear_to_DisplayFormat(color);
return color.rgb;
}
#line 1498
technique Camera <ui_tooltip =
"A high performance all-in-one shader with many common camera and lens effects.\n\n"
"(HDR compatible)";>
{
pass
{
VertexShader = VS_Storage; PixelShader = StoragePass; RenderTarget = pStorageTex;
}
pass
{
VertexShader = PostProcessVS; PixelShader = StoragePassC; RenderTarget = pStorageTexC;
}
#line 1512
pass
{
VertexShader = VS_Blur; PixelShader = GaussianBlurPass1; RenderTarget = pBokehBlurTex;
}
pass
{
VertexShader = VS_Blur; PixelShader = GaussianBlurPass2; RenderTarget = pGaussianBlurTex;
}
#line 1522
pass
{
VertexShader = VS_DOF; PixelShader = BokehBlurPass; RenderTarget = pBokehBlurTex;
}
#line 1528
pass
{
VertexShader = VS_BloomLF; PixelShader = HighPassFilter; RenderTarget = pBloomTex0;
}
#line 1537
pass
{
VertexShader = VS_BloomLF; PixelShader = BloomDownS1; RenderTarget = pBloomTex1;
}
#line 1543
pass
{
VertexShader = VS_Ghosts; PixelShader = CAPass; RenderTarget = pFlareSrcTex;
}
pass
{
VertexShader = VS_Ghosts; PixelShader = GhostsPass; RenderTarget = pFlareTex;
}
#line 1558
pass { VertexShader = VS_Ghosts; PixelShader = FlareDownS2; RenderTarget = pBloomTex2; }
#line 1572
pass { VertexShader = VS_Ghosts; PixelShader = FlareUpS1; RenderTarget = pFlareTex; }
#line 1574
pass 
{
VertexShader = VS_Glare; PixelShader = GlarePass; RenderTarget = pFlareTex; ClearRenderTargets = FALSE; BlendEnable = TRUE; BlendOp = 1; SrcBlend = 1; DestBlend = 9;
}
#line 1579
pass { VertexShader = VS_Bloom; PixelShader = BloomDownS2; RenderTarget = pBloomTex2; }
pass { VertexShader = VS_Bloom; PixelShader = BloomDownS3; RenderTarget = pBloomTex3; }
pass { VertexShader = VS_Bloom; PixelShader = BloomDownS4; RenderTarget = pBloomTex4; }
pass { VertexShader = VS_Bloom; PixelShader = BloomDownS5; RenderTarget = pBloomTex5; }
pass { VertexShader = VS_Bloom; PixelShader = BloomDownS6; RenderTarget = pBloomTex6; }
pass { VertexShader = VS_Bloom; PixelShader = BloomDownS7; RenderTarget = pBloomTex7; }
pass { VertexShader = VS_Bloom; PixelShader = BloomDownS8; RenderTarget = pBloomTex8; }
#line 1587
pass { VertexShader = VS_Bloom; PixelShader = BloomUpS7; RenderTarget = pBloomTex7; ClearRenderTargets = FALSE; BlendEnable = TRUE; BlendOp = 1; SrcBlend = 1; DestBlend = 9; }
pass { VertexShader = VS_Bloom; PixelShader = BloomUpS6; RenderTarget = pBloomTex6; ClearRenderTargets = FALSE; BlendEnable = TRUE; BlendOp = 1; SrcBlend = 1; DestBlend = 9; }
pass { VertexShader = VS_Bloom; PixelShader = BloomUpS5; RenderTarget = pBloomTex5; ClearRenderTargets = FALSE; BlendEnable = TRUE; BlendOp = 1; SrcBlend = 1; DestBlend = 9; }
pass { VertexShader = VS_Bloom; PixelShader = BloomUpS4; RenderTarget = pBloomTex4; ClearRenderTargets = FALSE; BlendEnable = TRUE; BlendOp = 1; SrcBlend = 1; DestBlend = 9; }
pass { VertexShader = VS_Bloom; PixelShader = BloomUpS3; RenderTarget = pBloomTex3; ClearRenderTargets = FALSE; BlendEnable = TRUE; BlendOp = 1; SrcBlend = 1; DestBlend = 9; }
pass { VertexShader = VS_Bloom; PixelShader = BloomUpS2; RenderTarget = pBloomTex2; ClearRenderTargets = FALSE; BlendEnable = TRUE; BlendOp = 1; SrcBlend = 1; DestBlend = 9; }
pass { VertexShader = VS_Bloom; PixelShader = BloomUpS1; RenderTarget = pBloomTex1; ClearRenderTargets = FALSE; BlendEnable = TRUE; BlendOp = 1; SrcBlend = 1; DestBlend = 9; }
pass { VertexShader = VS_Bloom; PixelShader = BloomUpS0; RenderTarget = pBloomTex0; ClearRenderTargets = FALSE; BlendEnable = TRUE; BlendOp = 1; SrcBlend = 1; DestBlend = 9; }
#line 1597
pass
{
VertexShader = VS_Camera; PixelShader = CameraPass;
}
}

