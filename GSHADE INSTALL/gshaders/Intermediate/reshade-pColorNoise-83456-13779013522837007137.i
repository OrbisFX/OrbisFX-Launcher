#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\pColorNoise.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\pColorNoise.fx"
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
#line 33 "C:\Program Files\GShade\gshade-shaders\Shaders\pColorNoise.fx"
#line 34
static const float PI = pUtils::PI;
static const float EPSILON = pUtils::EPSILON;
static const float INVNORM_FACTOR = Oklab::INVNORM_FACTOR;
#line 38
uniform float Strength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Noise strength";
ui_category = "Settings";
> = 0.12;
uniform bool UseApproximateTransforms <
ui_type = "bool";
ui_label = "Fast colorspace transform";
ui_tooltip = "Use less accurate approximations instead of the full transform functions";
ui_category = "Performance";
> = false;
#line 52
float3 ColorNoisePass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
color = (UseApproximateTransforms)
? Oklab::Fast_DisplayFormat_to_Linear(color)
: Oklab::DisplayFormat_to_Linear(color);
#line 59
static const float NOISE_CURVE = max(INVNORM_FACTOR * 0.025, 1.0);
float luminance = dot(color, float3(0.2126, 0.7152, 0.0722));
#line 63
float noise1 = pUtils::wnoise(texcoord, float2(6.4949, 39.116));
float noise2 = pUtils::wnoise(texcoord, float2(19.673, 5.5675));
float noise3 = pUtils::wnoise(texcoord, float2(36.578, 26.118));
#line 68
float r = sqrt(-2.0 * log(noise1 + EPSILON));
float theta1 = 2.0 * PI * noise2;
float theta2 = 2.0 * PI * noise3;
#line 73
float3 gauss_noise = float3(r * cos(theta1) * 1.33, r * sin(theta1) * 1.25, r * cos(theta2) * 2.0);
#line 75
float weight = (Strength * Strength) * NOISE_CURVE / (luminance * (1.0 + rcp(INVNORM_FACTOR)) + 2.0); 
color.rgb = Oklab::Saturate_RGB(color.rgb + gauss_noise * weight);
#line 78
color = (UseApproximateTransforms)
? Oklab::Fast_Linear_to_DisplayFormat(color)
: Oklab::Linear_to_DisplayFormat(color);
return color.rgb;
}
#line 84
technique ColorNoise <ui_tooltip =
"Generates gaussian chroma noise to simulate amplifier noise in digital cameras.\n\n"
"(HDR compatible)";>
{
pass
{
VertexShader = PostProcessVS; PixelShader = ColorNoisePass;
}
}

