// fLUT_Format=RGBA8
// fLUT_Resolution=32
// fLUT_TextureName="lut.png"
// ENABLE_ADVANCED_COLOR_CORRECTION=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\pColors.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 57
namespace ReShade
{
float GetAspectRatio() { return 1280 * (1.0 / 720); }
float2 GetPixelSize() { return float2((1.0 / 1280), (1.0 / 720)); }
float2 GetScreenSize() { return float2(1280, 720); }
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\pColors.fx"
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
static const float2 ASPECT_RATIO = float2(1.0, 1.0/(1280 * (1.0 / 720)));
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
#line 33 "C:\Program Files\GShade\gshade-shaders\Shaders\pColors.fx"
#line 34
static const float PI = pUtils::PI;
#line 37
uniform float WBTemperature <
ui_type = "slider";
ui_min = -0.25; ui_max = 0.25;
ui_label = "Temperature";
ui_tooltip = "Color temperature adjustment (Blue <-> Yellow)";
ui_category = "White balance";
> = 0.0;
uniform float WBTint <
ui_type = "slider";
ui_min = -0.25; ui_max = 0.25;
ui_label = "Tint";
ui_tooltip = "Color tint adjustment (Magenta <-> Green)";
ui_category = "White balance";
> = 0.0;
#line 52
uniform float GlobalSaturation <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_label = "Saturation";
ui_tooltip = "Saturation adjustment";
ui_category = "Global adjustments";
> = 0.0;
uniform float GlobalBrightness <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_label = "Brightness";
ui_tooltip = "Brightness adjustment";
ui_category = "Global adjustments";
> = 0.0;
#line 246
uniform float3 ShadowTintColor <
ui_type = "color";
ui_label = "Tint";
ui_tooltip = "Color to which shadows are tinted";
ui_category = "Shadows";
> = float3(0.69, 0.82, 1.0);
uniform float ShadowSaturation <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_label = "Saturation";
ui_tooltip = "Saturation adjustment for shadows";
ui_category = "Shadows";
> = 0.0;
uniform float ShadowBrightness <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_label = "Brightness";
ui_tooltip = "Brightness adjustment for shadows";
ui_category = "Shadows";
> = 0.0;
uniform float ShadowThreshold <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Threshold";
ui_tooltip = "Threshold for what is considered shadows";
ui_category = "Shadows";
> = 0.25;
uniform float ShadowCurveSlope <
ui_type = "slider";
ui_min = 1.0; ui_max = 5.0;
ui_label = "Curve Slope";
ui_tooltip = "How steep the transition to shadows is";
ui_category = "Shadows";
> = 2.5;
#line 281
uniform float3 MidtoneTintColor <
ui_type = "color";
ui_label = "Tint";
ui_tooltip = "Color to which midtones are tinted";
ui_category = "Midtones";
> = float3(1.0, 1.0, 1.0);
uniform float MidtoneSaturation <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_label = "Saturation";
ui_tooltip = "Saturation adjustment for midtones";
ui_category = "Midtones";
> = 0.0;
uniform float MidtoneBrightness <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_label = "Brightness";
ui_tooltip = "Brightness adjustment for midtones";
ui_category = "Midtones";
> = 0.0;
#line 302
uniform float3 HighlightTintColor <
ui_type = "color";
ui_label = "Tint";
ui_tooltip = "Color to which highlights are tinted";
ui_category = "Highlights";
> = float3(1.0, 0.98, 0.90);
uniform float HighlightSaturation <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_label = "Saturation";
ui_tooltip = "Saturation adjustment for highlights";
ui_category = "Highlights";
> = 0.0;
uniform float HighlightBrightness <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
ui_label = "Brightness";
ui_tooltip = "Brightness adjustment for highlights";
ui_category = "Highlights";
> = 0.0;
uniform float HighlightThreshold <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Threshold";
ui_tooltip = "Threshold for what is considered highlights";
ui_category = "Highlights";
> = 0.75;
uniform float HighlightCurveSlope <
ui_type = "slider";
ui_min = 1.0; ui_max = 5.0;
ui_label = "Curve Slope";
ui_tooltip = "How steep the transition to highlights is";
ui_category = "Highlights";
> = 2.5;
#line 339
uniform bool EnableLUT <
ui_type = "bool";
ui_label = "Enable LUT";
ui_tooltip = "Apply a LUT as a final processing step\n\nIncrease HDR_PEAK_LUMINANCE_NITS if enabling this causes clipping";
ui_category = "LUT";
> = false;
#line 355
static const float LUT_WhitePoint = 1.0;
#line 367
texture LUT < source = "lut.png"; > { Height = 32; Width = 32 * 32; Format = RGBA8; };
sampler sLUT { Texture = LUT; };
#line 372
uniform bool UseApproximateTransforms <
ui_type = "bool";
ui_label = "Fast colorspace transform";
ui_tooltip = "Use less accurate approximations instead of the full transform functions";
ui_category = "Performance";
> = false;
#line 381
float get_Weight(float v, float t, float s) 
{
v = (v - t) * s;
return (v > 1.0)
? 1.0
: (v < 0.0)
? 0.0
: v * v * (3.0 - 2.0 * v);
}
#line 391
float3 Apply_LUT(float3 c) 
{
static const float EXPANSION_FACTOR = Oklab::INVNORM_FACTOR;
float3 LUT_coord = c / EXPANSION_FACTOR / LUT_WhitePoint;
#line 396
float bounds = max(LUT_coord.x, max(LUT_coord.y, LUT_coord.z));
#line 398
if (bounds <= 1.0) 
{
float2 texel_size = rcp(32);
texel_size.x /= 32;
#line 403
const float3 oc = LUT_coord;
LUT_coord.xy = (LUT_coord.xy * 32 - LUT_coord.xy + 0.5) * texel_size;
LUT_coord.z *= (32 - 1.0);
#line 407
float lerp_factor = frac(LUT_coord.z);
LUT_coord.x += floor(LUT_coord.z) * texel_size.y;
c = lerp(tex2D(sLUT, LUT_coord.xy).rgb, tex2D(sLUT, float2(LUT_coord.x + texel_size.y, LUT_coord.y)).rgb, lerp_factor);
#line 411
if (bounds > 0.9 && LUT_WhitePoint != 1.0) 
{
c = lerp(c, oc, 10.0 * (bounds - 0.9));
}
#line 416
return c * LUT_WhitePoint * EXPANSION_FACTOR;
}
#line 419
return c;
}
#line 422
float3 Manipulate_By_Hue(float3 color, float3 hue, float hue_shift, float hue_saturation, float hue_brightness)
{
float weight = max(1.0 - pUtils::cdistance(color.z, hue.z), 0.0); 
#line 426
if (weight != 0.0)
{
color.z += hue_shift * weight;
color.xy *= 1.0 + float2(hue_brightness, hue_saturation) * weight;
color = Oklab::Saturate_LCh(color);
}
#line 433
return color;
}
#line 438
float3 ColorsPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 442
color = (UseApproximateTransforms)
? Oklab::Fast_DisplayFormat_to_Linear(color)
: Oklab::DisplayFormat_to_Linear(color);
float adapted_luminance = Oklab::get_Adapted_Luminance_RGB(color, 1.0);
color = Oklab::RGB_to_Oklab(color);
#line 451
if (WBTemperature != 0.0 || WBTint != 0.0)
{
color.g = color.g - WBTint;
color.b = (WBTint < 0.0)
? color.b + WBTemperature + WBTint
: color.b + WBTemperature;
}
#line 461
color.r *= (1.0 + GlobalBrightness);
color.gb *= (1.0 + GlobalSaturation);
#line 499
static const float3 ShadowTintColor = Oklab::RGB_to_Oklab(ShadowTintColor) * (1 + GlobalSaturation);
static const float ShadowTintColorC = Oklab::get_Oklab_Chromacity(ShadowTintColor);
static const float3 MidtoneTintColor = Oklab::RGB_to_Oklab(MidtoneTintColor) * (1 + GlobalSaturation);
static const float MidtoneTintColorC = Oklab::get_Oklab_Chromacity(MidtoneTintColor);
static const float3 HighlightTintColor = Oklab::RGB_to_Oklab(HighlightTintColor) * (1 + GlobalSaturation);
static const float HighlightTintColorC = Oklab::get_Oklab_Chromacity(HighlightTintColor);
#line 508
float shadow_weight = get_Weight(adapted_luminance, ShadowThreshold, -ShadowCurveSlope);
if (shadow_weight != 0.0)
{
color.r *= (1.0 + ShadowBrightness * shadow_weight);
color.g = lerp(color.g, ShadowTintColor.g + (1.0 - ShadowTintColorC) * color.g, shadow_weight) * (1.0 + ShadowSaturation * shadow_weight);
color.b = lerp(color.b, ShadowTintColor.b + (1.0 - ShadowTintColorC) * color.b, shadow_weight) * (1.0 + ShadowSaturation * shadow_weight);
}
#line 516
float highlight_weight = get_Weight(adapted_luminance, HighlightThreshold, HighlightCurveSlope);
if (highlight_weight != 0.0)
{
color.r *= (1.0 + HighlightBrightness * highlight_weight);
color.g = lerp(color.g, HighlightTintColor.g + (1.0 - HighlightTintColorC) * color.g, highlight_weight) * (1.0 + HighlightSaturation * highlight_weight);
color.b = lerp(color.b, HighlightTintColor.b + (1.0 - HighlightTintColorC) * color.b, highlight_weight) * (1.0 + HighlightSaturation * highlight_weight);
}
#line 524
float midtone_weight = max(1.0 - (shadow_weight + highlight_weight), 0.0);
if (midtone_weight != 0.0)
{
color.r *= (1.0 + MidtoneBrightness * midtone_weight);
color.g = lerp(color.g, MidtoneTintColor.g + (1.0 - MidtoneTintColorC) * color.g, midtone_weight) * (1.0 + MidtoneSaturation * midtone_weight);
color.b = lerp(color.b, MidtoneTintColor.b + (1.0 - MidtoneTintColorC) * color.b, midtone_weight) * (1.0 + MidtoneSaturation * midtone_weight);
}
color = Oklab::Oklab_to_RGB(color);
#line 535
if (EnableLUT)
{
color = Apply_LUT(Oklab::Saturate_RGB(color));
}
#line 540
if (!Oklab::IS_HDR) { color = Oklab::Saturate_RGB(color); }
color = (UseApproximateTransforms)
? Oklab::Fast_Linear_to_DisplayFormat(color)
: Oklab::Linear_to_DisplayFormat(color);
return color.rgb;
}
#line 549
technique Colors <ui_tooltip =
"Shader with tools for advanced color correction and grading.\n\n"
"(HDR compatible)";>
{
pass
{
VertexShader = PostProcessVS; PixelShader = ColorsPass;
}
}

