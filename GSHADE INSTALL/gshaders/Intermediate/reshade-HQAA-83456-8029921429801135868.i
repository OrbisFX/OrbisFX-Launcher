// HQAA__INTRODUCTION_ACKNOWLEDGED=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\HQAA.fx"
#line 435
 
#line 457
uniform uint HqaaFramecounter < source = "framecount"; >;
#line 499
 
#line 503
uniform int HqaaAboutSTART <
ui_type = "radio";
ui_label = " ";
ui_text = "\n"
"---------------------------------- HQAA v30.4 ----------------------------------\n"
#line 509
"READ THIS INFO BEFORE FIRST USE as this information is IMPORTANT and will allow\n"
"you to get the most out of this shader.\n"
"HQAA is designed to provide anti-aliasing in games that do not have a desirable\n"
"AA method active. The defaults (quality profiles, global presets, and advanced\n"
"options) assume HQAA is the only anti-aliasing method in use, unless otherwise\n"
"explicitly stated. All default settings are intended to provide a balanced\n"
"overall final image quality; however the shader can easily be configured either\n"
"for increased AA effect or reduced blur, as desired. ALL pre-processor defines\n"
"visible in the 'Preprocessor definitions' tab at the end are user-configurable\n"
"in HQAA, and control the various features available in the shader.\n"
"The Quality Profile determines how aggressively HQAA will search for and correct\n"
"edges. Please note that the Balanced profile is intended for general-purpose use\n"
"and should be more than capable of handling just about any game. The Aggressive\n"
"profile is representative of overkill settings and requires a lot of GPU time to\n"
"run. HQAA also depends on 'Performance Mode' being enabled in ReShade as a large\n"
"quantity of code will be removed from the compiled shader when it is enabled.\n"
"To disable this message and unlock full shader configuration, set the define\n"
"'HQAA__INTRODUCTION_ACKNOWLEDGED' to 1.\n"
"--------------------------------------------------------------------------------\n"
#line 529
"\n";
>;
#line 748
 
#line 774
static const uint HqaaOutputMode = 0;
static const float HqaaHdrNits = 1000.0;
#line 813
static const uint HqaaDebugMode = 0;
#line 838
static const float HqaaSplitscreenPosition = 0.5;
static const bool HqaaSplitscreenFlipped = false;
static const bool HqaaSplitscreenAuto = true;
#line 851
 
#line 935
static const float HqaaEdgeThresholdCustom = 0.05;
static const float HqaaLowLumaThreshold = 0.1;
static const float HqaaDynamicThresholdCustom = 60.0;
static const float HqaaFxQualityCustom = 20;
static const float HqaaResolutionScalar = 900.;
static const uint HqaaSourceInterpolation = 0;
static const uint HqaaSourceInterpolationOffset = 0;
static const float HqaaFxTexelCustom = 0.6;
static const bool HqaaFxTexelGrowth = true;
static const float HqaaFxTexelGrowAfter = 40;
static const float HqaaFxTexelGrowPercent = 33.333333;
static const bool HqaaFxDiagScans = true;
static const bool HqaaFxEarlyExit = true;
static const bool HqaaFxOverlapAbort = false;
static const bool HqaaDoLumaHysteresis = false;
static const float HqaaHysteresisFudgeFactor = 0;
static const bool HqaaSmDualCardinal = true;
static const bool HqaaSmCornerDetection = true;
#line 965
static const uint HqaaPresetDetailRetain = 1;
#line 1118
 
#line 1425
 
#line 1449
static const bool HqaaEnableSharpening = true;
#line 1516
 
#line 1591
static const bool HqaaEnableBrightnessGain = false;
static const float HqaaDehazeStrength = 0.0;
static const float HqaaGainStrength = 0.0;
static const bool HqaaGainLowLumaCorrection = false;
static const float HqaaRaiseBlack = 0.0;
static const float HqaaLumaGain = 0.0;
#line 1737
static const bool HqaaEnableColorPalette = false;
static const float HqaaSaturationStrength = 0.5;
static const float HqaaContrastEnhance = 0.0;
static const float HqaaVibranceStrength = 50;
static const bool HqaaVibranceNoCorrection = false;
static const bool HqaaContrastUseYUV = false;
static const float HqaaColorTemperature = 0.5;
static const float HqaaBlueLightFilter = 0.0;
static const uint HqaaTonemapping = 0;
static const float HqaaTonemappingParameter = 0;
#line 1953
 
#line 1968
static const float HqaaBlueLightFilter = 0.0;
#line 1985
static const bool HqaaBlueFilterLumaCorrection = true;
#line 2041
 
#line 2137
static const float HqaaSmCorneringCustom[3] = {0.667, 0.25, 0.0};
static const float HqaaFxBlendCustom[3] = {1, 1, 0.75};
static const float HqaaHysteresisStrength[3] = {0.125, 0.333333, 0.75};
#line 2151
 
#line 2177
 
#line 2189
 
#line 2207
 
#line 2225
 
#line 2248
 
#line 2263
 
#line 2287
 
#line 2299
 
#line 2312
 
#line 2322
 
#line 2339
 
#line 2342
static const float HqaaFxBlurControl = 0.25;
static const float HqaaSharpenerStrength = 0.7;
static const float HqaaSharpenerClamping = 0.3;
static const float HqaaTaaJitterOffset = 0.6;
#line 2349
static const float HqaaTaaMinimumBlend = 0.0;
static const bool HqaaTaaLumaCorrection = false;
#line 2368
 
#line 2381
 
#line 2392
 
#line 2408
 
#line 2421
float max3(float a, float b, float c)
{
return max(max(a,b),c);
}
float max4(float a, float b, float c, float d)
{
float2 step1 = max(float2(a,b), float2(c,d));
return max(step1.x, step1.y);
}
float max5(float a, float b, float c, float d, float e)
{
float2 step1 = max(float2(a,b), float2(c,d));
return max(max(step1.x, step1.y), e);
}
float max6(float a, float b, float c, float d, float e, float f)
{
float2 step1 = max(max(float2(a,b), float2(c,d)), float2(e,f));
return max(step1.x, step1.y);
}
float max7(float a, float b, float c, float d, float e, float f, float g)
{
float2 step1 = max(max(float2(a,b), float2(c,d)), float2(e,f));
return max(max(step1.x, step1.y), g);
}
float max8(float a, float b, float c, float d, float e, float f, float g, float h)
{
float4 step1 = max(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = max(step1.xy, step1.zw);
return max(step2.x, step2.y);
}
float max9(float a, float b, float c, float d, float e, float f, float g, float h, float i)
{
float4 step1 = max(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = max(step1.xy, step1.zw);
return max(max(step2.x, step2.y), i);
}
float max10(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j)
{
float4 step1 = max(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = max(step1.xy, step1.zw);
return max(max(step2.x, step2.y), max(i, j));
}
float max11(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k)
{
float4 step1 = max(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = max(step1.xy, step1.zw);
return max(max(max(step2.x, step2.y), max(i, j)), k);
}
float max12(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l)
{
float4 step1 = max(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = max(step1.xy, step1.zw);
float2 step3 = max(float2(i,j), float2(k,l));
float2 step4 = max(step2, step3);
return max(step4.x, step4.y);
}
float max13(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l, float m)
{
float4 step1 = max(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = max(step1.xy, step1.zw);
float2 step3 = max(float2(i,j), float2(k,l));
float2 step4 = max(step2, step3);
return max(max(step4.x, step4.y), m);
}
float max14(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l, float m, float n)
{
float4 step1 = max(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = max(step1.xy, step1.zw);
float2 step3 = max(float2(i,j), float2(k,l));
float2 step4 = max(step2, step3);
return max(max(step4.x, step4.y), max(m, n));
}
float max15(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l, float m, float n, float o)
{
float4 step1 = max(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = max(step1.xy, step1.zw);
float2 step3 = max(float2(i,j), float2(k,l));
float2 step4 = max(step2, step3);
return max(max(step4.x, step4.y), max(m, max(n, o)));
}
float max16(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l, float m, float n, float o, float p)
{
float4 step1 = max(float4(a,b,c,d), float4(e,f,g,h));
float4 step2 = max(float4(i,j,k,l), float4(m,n,o,p));
float4 step3 = max(step1, step2);
float2 step4 = max(step3.xy, step3.zw);
return max(step4.x, step4.y);
}
#line 2511
float min3(float a, float b, float c)
{
return min(min(a,b),c);
}
float min4(float a, float b, float c, float d)
{
float2 step1 = min(float2(a,b), float2(c,d));
return min(step1.x, step1.y);
}
float min5(float a, float b, float c, float d, float e)
{
float2 step1 = min(float2(a,b), float2(c,d));
return min(min(step1.x, step1.y), e);
}
float min6(float a, float b, float c, float d, float e, float f)
{
float2 step1 = min(min(float2(a,b), float2(c,d)), float2(e,f));
return min(step1.x, step1.y);
}
float min7(float a, float b, float c, float d, float e, float f, float g)
{
float2 step1 = min(min(float2(a,b), float2(c,d)), float2(e,f));
return min(min(step1.x, step1.y), g);
}
float min8(float a, float b, float c, float d, float e, float f, float g, float h)
{
float4 step1 = min(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = min(step1.xy, step1.zw);
return min(step2.x, step2.y);
}
float min9(float a, float b, float c, float d, float e, float f, float g, float h, float i)
{
float4 step1 = min(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = min(step1.xy, step1.zw);
return min(min(step2.x, step2.y), i);
}
float min10(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j)
{
float4 step1 = min(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = min(step1.xy, step1.zw);
return min(min(step2.x, step2.y), min(i, j));
}
float min11(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k)
{
float4 step1 = min(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = min(step1.xy, step1.zw);
return min(min(min(step2.x, step2.y), min(i, j)), k);
}
float min12(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l)
{
float4 step1 = min(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = min(step1.xy, step1.zw);
float2 step3 = min(float2(i,j), float2(k,l));
float2 step4 = min(step2, step3);
return min(step4.x, step4.y);
}
float min13(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l, float m)
{
float4 step1 = min(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = min(step1.xy, step1.zw);
float2 step3 = min(float2(i,j), float2(k,l));
float2 step4 = min(step2, step3);
return min(min(step4.x, step4.y), m);
}
float min14(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l, float m, float n)
{
float4 step1 = min(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = min(step1.xy, step1.zw);
float2 step3 = min(float2(i,j), float2(k,l));
float2 step4 = min(step2, step3);
return min(min(step4.x, step4.y), min(m, n));
}
float min15(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l, float m, float n, float o)
{
float4 step1 = min(float4(a,b,c,d), float4(e,f,g,h));
float2 step2 = min(step1.xy, step1.zw);
float2 step3 = min(float2(i,j), float2(k,l));
float2 step4 = min(step2, step3);
return min(min(step4.x, step4.y), min(m, min(n, o)));
}
float min16(float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k, float l, float m, float n, float o, float p)
{
float4 step1 = min(float4(a,b,c,d), float4(e,f,g,h));
float4 step2 = min(float4(i,j,k,l), float4(m,n,o,p));
float4 step3 = min(step1, step2);
float2 step4 = min(step3.xy, step3.zw);
return min(step4.x, step4.y);
}
#line 2607
float3 RGBtoYUV(float3 input)
{
float3 yuv;
yuv.x = dot(input, float3(0.299, 0.587, 0.114));
yuv.y = 0.713 * (input.r - yuv.x);
yuv.z = 0.564 * (input.b - yuv.x);
yuv.yz = clamp(yuv.yz, -0.5, 0.5);
yuv.x = saturate(yuv.x);
#line 2616
return yuv;
}
float4 RGBtoYUV(float4 input)
{
return float4(RGBtoYUV(input.rgb), input.a);
}
#line 2627
float3 YUVtoRGB(float3 yuv)
{
float3 argb;
argb.r = (1.402525 * yuv.y) + yuv.x;
argb.b = (1.77305 * yuv.z) + yuv.x;
argb.g = (1.703578 * yuv.x) - (0.50937 * argb.r) - (0.194208 * argb.b);
#line 2634
return saturate(argb);
}
float4 YUVtoRGB(float4 yuv)
{
return float4(YUVtoRGB(yuv.xyz), yuv.a);
}
#line 2641
float dotsat(float3 x)
{
float xmax = max(max(x.r, x.g), x.b);
float xmin = min(min(x.r, x.g), x.b);
if (!xmax) return 0.0;
float xmid = (x.r + x.g + x.b) - (xmax + xmin);
float xbrightness = (xmax + xmid) * 0.5;
return (xmax - xmin) * xbrightness;
}
float dotsat(float4 x)
{
return dotsat(x.rgb);
}
#line 2656
float chromadelta(float3 pixel1, float3 pixel2)
{
float3 delta = abs(pixel1 - pixel2);
return max3(delta.r, delta.g, delta.b);
}
#line 2663
float maxcolordelta(float3 pixel)
{
float3 deltas = abs(float3(pixel.r - pixel.g, pixel.g - pixel.b, pixel.b - pixel.r));
return max(max(deltas.x, deltas.y), deltas.z);
}
#line 2670
float3 AdjustVibrance(float3 pixel, float satadjust)
{
float3 outdot = pixel;
float refY = dot(pixel, float3(0.2126, 0.7152, 0.0722));
float refsat = dotsat(pixel);
float realadjustment = saturate(refsat + satadjust) - refsat;
float2 highlow = float2(max3(pixel.r, pixel.g, pixel.b), min3(pixel.r, pixel.g, pixel.b));
float maxpositive = 1.0 - highlow.x;
float maxnegative = -highlow.y;
[branch] if (abs(realadjustment) > rcp(pow(2., 8)))
{
#line 2682
float mid = -1.0;
#line 2685
float lowadjust = clamp(((highlow.y - highlow.x * 0.5) * rcp(highlow.x)) * realadjustment, maxnegative, maxpositive);
#line 2688
float highadjust = clamp(0.5 * realadjustment, maxnegative, maxpositive);
#line 2691
if (pixel.r == highlow.x) outdot.r = pow(abs(1.0 + highadjust) * 2.0, log2(pixel.r));
else if (pixel.r == highlow.y) outdot.r = pow(abs(1.0 + lowadjust) * 2.0, log2(pixel.r));
else mid = pixel.r;
#line 2695
if (pixel.g == highlow.x) outdot.g = pow(abs(1.0 + highadjust) * 2.0, log2(pixel.g));
else if (pixel.g == highlow.y) outdot.g = pow(abs(1.0 + lowadjust) * 2.0, log2(pixel.g));
else mid = pixel.g;
#line 2699
if (pixel.b == highlow.x) outdot.b = pow(abs(1.0 + highadjust) * 2.0, log2(pixel.b));
else if (pixel.b == highlow.y) outdot.b = pow(abs(1.0 + lowadjust) * 2.0, log2(pixel.b));
else mid = pixel.b;
#line 2704
if (mid > 0.0)
{
#line 2707
float midadjust = clamp(((mid - highlow.x * 0.5) * rcp(highlow.x)) * realadjustment, maxnegative, maxpositive);
#line 2710
if (pixel.r == mid) outdot.r = pow(abs(1.0 + midadjust) * 2.0, log2(pixel.r));
else if (pixel.g == mid) outdot.g = pow(abs(1.0 + midadjust) * 2.0, log2(pixel.g));
else if (pixel.b == mid) outdot.b = pow(abs(1.0 + midadjust) * 2.0, log2(pixel.b));
}
}
#line 2716
if (!HqaaVibranceNoCorrection)
{
float outY = dot(outdot, float3(0.2126, 0.7152, 0.0722));
float deltaY = (outY == 0.0) ? 0.0 : (refY * rcp(outY));
outdot *= deltaY;
}
#line 2723
return saturate(outdot);
}
float4 AdjustVibrance(float4 pixel, float satadjust)
{
return float4(AdjustVibrance(pixel.rgb, satadjust), pixel.a);
}
#line 2731
float3 AdjustSaturation(float3 input, float requestedadjustment)
{
#line 2735
float3 yuv = RGBtoYUV(input);
#line 2738
float adjustment = 2.0 * (saturate(requestedadjustment) - 0.5);
#line 2741
if (adjustment > 0.0)
{
float maxboost = 1.0 * rcp(max(abs(yuv.y), abs(yuv.z)) * 2.0);
if (adjustment > maxboost) adjustment = maxboost;
}
#line 2748
yuv.y = yuv.y > 0.0 ? (yuv.y + (adjustment * yuv.y)) : (yuv.y - (adjustment * abs(yuv.y)));
yuv.z = yuv.z > 0.0 ? (yuv.z + (adjustment * yuv.z)) : (yuv.z - (adjustment * abs(yuv.z)));
#line 2752
return YUVtoRGB(yuv);
}
#line 2757
float encodePQ(float x)
{
#line 2766
float xpm2rcp = pow(saturate(x), rcp(2523./32.));
float numerator = max(xpm2rcp - 107./128., 0.0);
float denominator = 2413./128. - ((2392./128.) * xpm2rcp);
#line 2770
float output = pow(abs(numerator * rcp(denominator)), rcp(1305./8192.));
if (8 == 10) output *= 500.0;
else output *= 10000.0;
return output;
}
float2 encodePQ(float2 x)
{
float2 xpm2rcp = pow(saturate(x), rcp(2523./32.));
float2 numerator = max(xpm2rcp - 107./128., 0.0);
float2 denominator = 2413./128. - ((2392./128.) * xpm2rcp);
#line 2781
float2 output = pow(abs(numerator * rcp(denominator)), rcp(1305./8192.));
if (8 == 10) output *= 500.0;
else output *= 10000.0;
return output;
}
float3 encodePQ(float3 x)
{
float3 xpm2rcp = pow(saturate(x), rcp(2523./32.));
float3 numerator = max(xpm2rcp - 107./128., 0.0);
float3 denominator = 2413./128. - ((2392./128.) * xpm2rcp);
#line 2792
float3 output = pow(abs(numerator * rcp(denominator)), rcp(1305./8192.));
if (8 == 10) output *= 500.0;
else output *= 10000.0;
return output;
}
float4 encodePQ(float4 x)
{
float4 xpm2rcp = pow(saturate(x), rcp(2523./32.));
float4 numerator = max(xpm2rcp - 107./128., 0.0);
float4 denominator = 2413./128. - ((2392./128.) * xpm2rcp);
#line 2803
float4 output = pow(abs(numerator * rcp(denominator)), rcp(1305./8192.));
if (8 == 10) output *= 500.0;
else output *= 10000.0;
return output;
}
#line 2809
float decodePQ(float x)
{
#line 2818
float xpm1;
if (8 == 10) xpm1 = pow(saturate(x / 500.0), 1305./8192.);
else xpm1 = pow(saturate(x / 10000.0), 1305./8192.);
float numerator = 107./128. + ((2413./128.) * xpm1);
float denominator = 1.0 + ((2392./128.) * xpm1);
#line 2824
return saturate(pow(abs(numerator / denominator), 2523./32.));
}
float2 decodePQ(float2 x)
{
float2 xpm1;
if (8 == 10) xpm1 = pow(saturate(x / 500.0), 1305./8192.);
else xpm1 = pow(saturate(x / 10000.0), 1305./8192.);
float2 numerator = 107./128. + ((2413./128.) * xpm1);
float2 denominator = 1.0 + ((2392./128.) * xpm1);
#line 2834
return saturate(pow(abs(numerator / denominator), 2523./32.));
}
float3 decodePQ(float3 x)
{
float3 xpm1;
if (8 == 10) xpm1 = pow(saturate(x / 500.0), 1305./8192.);
else xpm1 = pow(saturate(x / 10000.0), 1305./8192.);
float3 numerator = 107./128. + ((2413./128.) * xpm1);
float3 denominator = 1.0 + ((2392./128.) * xpm1);
#line 2844
return saturate(pow(abs(numerator / denominator), 2523./32.));
}
float4 decodePQ(float4 x)
{
float4 xpm1;
if (8 == 10) xpm1 = pow(saturate(x / 500.0), 1305./8192.);
else xpm1 = pow(saturate(x / 10000.0), 1305./8192.);
float4 numerator = 107./128. + ((2413./128.) * xpm1);
float4 denominator = 1.0 + ((2392./128.) * xpm1);
#line 2854
return saturate(pow(abs(numerator / denominator), 2523./32.));
}
#line 2857
float fastencodePQ(float x)
{
float y;
float z;
if (8 == 10) {y = saturate(x) * 4.728708; z = 500.0;}
else {y = saturate(x) * 10.0; z = 10000.0;}
y *= y;
y *= y;
return clamp(y, 0.0, z);
}
float2 fastencodePQ(float2 x)
{
float2 y;
float z;
if (8 == 10) {y = saturate(x) * 4.728708; z = 500.0;}
else {y = saturate(x) * 10.0; z = 10000.0;}
y *= y;
y *= y;
return clamp(y, 0.0, z);
}
float3 fastencodePQ(float3 x)
{
float3 y;
float z;
if (8 == 10) {y = saturate(x) * 4.728708; z = 500.0;}
else {y = saturate(x) * 10.0; z = 10000.0;}
y *= y;
y *= y;
return clamp(y, 0.0, z);
}
float4 fastencodePQ(float4 x)
{
float4 y;
float z;
if (8 == 10) {y = saturate(x) * 4.728708; z = 500.0;}
else {y = saturate(x) * 10.0; z = 10000.0;}
y *= y;
y *= y;
return clamp(y, 0.0, z);
}
#line 2898
float fastdecodePQ(float x)
{
return 8 == 10 ? saturate((sqrt(sqrt(clamp(x, rcp(pow(2., 8)), 500.0))) / 4.7287080450158790665084805994361)) : saturate((sqrt(sqrt(clamp(x, rcp(pow(2., 8)), 10000.0))) / 10.0));
}
float2 fastdecodePQ(float2 x)
{
return 8 == 10 ? saturate((sqrt(sqrt(clamp(x, rcp(pow(2., 8)), 500.0))) / 4.7287080450158790665084805994361)) : saturate((sqrt(sqrt(clamp(x, rcp(pow(2., 8)), 10000.0))) / 10.0));
}
float3 fastdecodePQ(float3 x)
{
return 8 == 10 ? saturate((sqrt(sqrt(clamp(x, rcp(pow(2., 8)), 500.0))) / 4.7287080450158790665084805994361)) : saturate((sqrt(sqrt(clamp(x, rcp(pow(2., 8)), 10000.0))) / 10.0));
}
float4 fastdecodePQ(float4 x)
{
return 8 == 10 ? saturate((sqrt(sqrt(clamp(x, rcp(pow(2., 8)), 500.0))) / 4.7287080450158790665084805994361)) : saturate((sqrt(sqrt(clamp(x, rcp(pow(2., 8)), 10000.0))) / 10.0));
}
#line 2915
float encodeHDR(float x)
{
return saturate(x) * HqaaHdrNits;
}
float2 encodeHDR(float2 x)
{
return saturate(x) * HqaaHdrNits;
}
float3 encodeHDR(float3 x)
{
return saturate(x) * HqaaHdrNits;
}
float4 encodeHDR(float4 x)
{
return saturate(x) * HqaaHdrNits;
}
#line 2932
float decodeHDR(float x)
{
return saturate(x * rcp(HqaaHdrNits));
}
float2 decodeHDR(float2 x)
{
return saturate(x * rcp(HqaaHdrNits));
}
float3 decodeHDR(float3 x)
{
return saturate(x * rcp(HqaaHdrNits));
}
float4 decodeHDR(float4 x)
{
return saturate(x * rcp(HqaaHdrNits));
}
#line 2949
float ConditionalEncode(float x)
{
if (HqaaOutputMode == 1) return encodeHDR(x);
if (HqaaOutputMode == 2) return encodePQ(x);
if (HqaaOutputMode == 3) return fastencodePQ(x);
return x;
}
float2 ConditionalEncode(float2 x)
{
if (HqaaOutputMode == 1) return encodeHDR(x);
if (HqaaOutputMode == 2) return encodePQ(x);
if (HqaaOutputMode == 3) return fastencodePQ(x);
return x;
}
float3 ConditionalEncode(float3 x)
{
if (HqaaOutputMode == 1) return encodeHDR(x);
if (HqaaOutputMode == 2) return encodePQ(x);
if (HqaaOutputMode == 3) return fastencodePQ(x);
return x;
}
float4 ConditionalEncode(float4 x)
{
if (HqaaOutputMode == 1) return encodeHDR(x);
if (HqaaOutputMode == 2) return encodePQ(x);
if (HqaaOutputMode == 3) return fastencodePQ(x);
return x;
}
#line 2978
float ConditionalDecode(float x)
{
if (HqaaOutputMode == 1) return decodeHDR(x);
if (HqaaOutputMode == 2) return decodePQ(x);
if (HqaaOutputMode == 3) return fastdecodePQ(x);
return x;
}
float2 ConditionalDecode(float2 x)
{
if (HqaaOutputMode == 1) return decodeHDR(x);
if (HqaaOutputMode == 2) return decodePQ(x);
if (HqaaOutputMode == 3) return fastdecodePQ(x);
return x;
}
float3 ConditionalDecode(float3 x)
{
if (HqaaOutputMode == 1) return decodeHDR(x);
if (HqaaOutputMode == 2) return decodePQ(x);
if (HqaaOutputMode == 3) return fastdecodePQ(x);
return x;
}
float4 ConditionalDecode(float4 x)
{
if (HqaaOutputMode == 1) return decodeHDR(x);
if (HqaaOutputMode == 2) return decodePQ(x);
if (HqaaOutputMode == 3) return fastdecodePQ(x);
return x;
}
#line 3009
void HQAAMovc(bool2 cond, inout float2 variable, float2 value)
{
[flatten] if (cond.x) variable.x = value.x;
[flatten] if (cond.y) variable.y = value.y;
}
void HQAAMovc(bool4 cond, inout float4 variable, float4 value)
{
HQAAMovc(cond.xy, variable.xy, value.xy);
HQAAMovc(cond.zw, variable.zw, value.zw);
}
#line 3021
float2 HQAADecodeDiagBilinearAccess(float2 e)
{
e.r = e.r * abs(5.0 * e.r - 3.75);
return round(e);
}
float4 HQAADecodeDiagBilinearAccess(float4 e)
{
e.rb = e.rb * abs(5.0 * e.rb - 3.75);
return round(e);
}
#line 3032
float2 HQAASearchDiag(sampler2D HQAAedgesTex, float2 texcoord, float2 dir, out float2 e)
{
float4 coord = float4(texcoord, -1.0, 1.0);
float3 t = float3(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy, 1.0);
float range = 20. - 1.0;
#line 3038
[loop] while (coord.z < range)
{
coord.xyz = mad(t, float3(dir, 1.0), coord.xyz);
e = tex2Dlod(HQAAedgesTex, coord.xyxy).rg;
coord.w = dot(e, 0.5);
if (coord.w < 0.9) break;
}
#line 3046
return coord.zw;
}
float2 HQAASearchDiag2(sampler2D edgesTex, float2 texcoord, float2 dir, out float2 e)
{
float4 coord = float4(texcoord, -1.0, 1.0);
coord.x += 0.25 * float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).x;
float3 t = float3(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy, 1.0);
float range = 20. - 1.0;
#line 3055
[loop] while (coord.z < range)
{
coord.xyz = mad(t, float3(dir, 1.0), coord.xyz);
#line 3059
e = tex2Dlod(edgesTex, coord.xyxy).rg;
e = HQAADecodeDiagBilinearAccess(e);
#line 3062
coord.w = dot(e, 0.5);
if (coord.w < 0.9) break;
}
#line 3066
return coord.zw;
}
#line 3070
float2 HQAAAreaDiag(sampler2D HQAAareaTex, float2 dist, float2 e)
{
float2 texcoord = mad(float(20.).xx, e, dist);
#line 3074
texcoord = mad(rcp(float2(160., 560.)), texcoord, 0.5 * rcp(float2(160., 560.)));
texcoord.x += 0.5;
#line 3077
return tex2Dlod(HQAAareaTex, texcoord.xyxy).rg;
}
#line 3080
float2 HQAACalculateDiagWeights(sampler2D HQAAedgesTex, sampler2D HQAAareaTex, float2 texcoord, float2 e)
{
float2 weights = 0;
float2 end;
float4 d;
d.ywxz = float4(HQAASearchDiag(HQAAedgesTex, texcoord, float2(1.0, -1.0), end), 0.0, 0.0);
#line 3087
if (e.r > 0.0)
{
d.xz = HQAASearchDiag(HQAAedgesTex, texcoord, float2(-1.0,  1.0), end);
d.x += float(end.y > 0.9);
}
#line 3093
if ((d.x + d.y) > 2.0)
{
float4 coords = mad(float4(-d.x, d.x, d.y, -d.y), float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, texcoord.xyxy);
float4 c;
c.x = tex2Dlod(HQAAedgesTex, coords.xyxy, int2(-1, 0)).g;
c.y = tex2Dlod(HQAAedgesTex, coords.xyxy, int2( 0, 0)).r;
c.z = tex2Dlod(HQAAedgesTex, coords.zwzw, int2( 1, 0)).g;
c.w = tex2Dlod(HQAAedgesTex, coords.zwzw, int2( 1, -1)).r;
#line 3102
float2 cc = mad(float(2.0).xx, c.xz, c.yw);
#line 3104
HQAAMovc(bool2(step(0.9, d.zw)), cc, 0.0);
#line 3106
weights += HQAAAreaDiag(HQAAareaTex, d.xy, cc);
}
#line 3109
d.xz = HQAASearchDiag2(HQAAedgesTex, texcoord, float2(-1.0, -1.0), end);
d.yw = 0.0;
#line 3112
if (tex2Dlod(HQAAedgesTex, (texcoord + float2((1.0 / 1920), 0)).xyxy).r > 0.0)
{
d.yw = HQAASearchDiag2(HQAAedgesTex, texcoord, 1.0, end);
d.y += float(end.y > 0.9);
}
#line 3118
if ((d.x + d.y) > 2.0)
{
float4 coords = mad(float4(-d.x, -d.x, d.y, d.y), float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, texcoord.xyxy);
float4 c;
c.x  = tex2Dlod(HQAAedgesTex, coords.xyxy, int2(-1, 0)).g;
c.y  = tex2Dlod(HQAAedgesTex, coords.xyxy, int2( 0, -1)).r;
c.zw = tex2Dlod(HQAAedgesTex, coords.zwzw, int2( 1, 0)).gr;
float2 cc = mad(2.0, c.xz, c.yw);
#line 3127
HQAAMovc(bool2(step(0.9, d.zw)), cc, 0.0);
#line 3129
weights += HQAAAreaDiag(HQAAareaTex, d.xy, cc).gr;
}
#line 3132
return weights;
}
#line 3135
float HQAASearchLength(sampler2D HQAAsearchTex, float2 e, float offset)
{
float2 scale = float2(66.0, 33.0) * float2(0.5, -1.0);
float2 bias = float2(66.0, 33.0) * float2(offset, 1.0);
#line 3140
scale += float2(-1.0,  1.0);
bias  += float2( 0.5, -0.5);
#line 3143
scale *= rcp(float2(64.0, 16.0));
bias *= rcp(float2(64.0, 16.0));
#line 3146
return tex2Dlod(HQAAsearchTex, mad(scale, e, bias).xyxy).r;
}
#line 3149
float HQAASearchXLeft(sampler2D HQAAedgesTex, sampler2D HQAAsearchTex, float2 texcoord, float end)
{
float2 e = float2(0.0, 1.0);
float failsafe = texcoord.x;
#line 3154
[loop] while (texcoord.x > end)
{
e = tex2Dlod(HQAAedgesTex, texcoord.xyxy).rg;
texcoord.x -= 2 * (1.0 / 1920);
#line 3159
if (e.r || (e.g < 0.751)) break;
}
float offset = mad(-2.007874, HQAASearchLength(HQAAsearchTex, e, 0.0), 3.25);
if (texcoord.x <= end) return failsafe;
return mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).x, offset, texcoord.x);
}
float HQAASearchXRight(sampler2D HQAAedgesTex, sampler2D HQAAsearchTex, float2 texcoord, float end)
{
float2 e = float2(0.0, 1.0);
float failsafe = texcoord.x;
#line 3170
[loop] while (texcoord.x < end)
{
e = tex2Dlod(HQAAedgesTex, texcoord.xyxy).rg;
texcoord.x += 2 * (1.0 / 1920);
#line 3175
if (e.r || (e.g < 0.751)) break;
}
float offset = mad(-2.007874, HQAASearchLength(HQAAsearchTex, e, 0.5), 3.25);
if (texcoord.x >= end) return failsafe;
return mad(-float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).x, offset, texcoord.x);
}
float HQAASearchYUp(sampler2D HQAAedgesTex, sampler2D HQAAsearchTex, float2 texcoord, float end)
{
float2 e = float2(1.0, 0.0);
float failsafe = texcoord.y;
#line 3186
[loop] while (texcoord.y > end)
{
e = tex2Dlod(HQAAedgesTex, texcoord.xyxy).rg;
texcoord.y -= 2 * (1.0 / 1018);
#line 3191
if (e.g || (e.r < 0.874)) break;
}
float offset = mad(-2.007874, HQAASearchLength(HQAAsearchTex, e.gr, 0.0), 3.25);
if (texcoord.y <= end) return failsafe;
return mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).y, offset, texcoord.y);
}
float HQAASearchYDown(sampler2D HQAAedgesTex, sampler2D HQAAsearchTex, float2 texcoord, float end)
{
float2 e = float2(1.0, 0.0);
float failsafe = texcoord.y;
#line 3202
[loop] while (texcoord.y < end)
{
e = tex2Dlod(HQAAedgesTex, texcoord.xyxy).rg;
texcoord.y += 2 * (1.0 / 1018);
#line 3207
if (e.g || (e.r < 0.874)) break;
}
float offset = mad(-2.007874, HQAASearchLength(HQAAsearchTex, e.gr, 0.5), 3.25);
if (texcoord.y >= end) return failsafe;
return mad(-float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).y, offset, texcoord.y);
}
#line 3214
float2 HQAAArea(sampler2D HQAAareaTex, float2 dist, float e1, float e2)
{
float2 texcoord = mad(16., 4.0 * float2(e1, e2), dist);
#line 3218
texcoord = mad(rcp(float2(160., 560.)), texcoord, 0.5 * rcp(float2(160., 560.)));
#line 3220
return tex2Dlod(HQAAareaTex, texcoord.xyxy).rg;
}
#line 3223
void HQAADetectHorizontalCornerPattern(sampler2D HQAAedgesTex, inout float2 weights, float4 texcoord, float2 d)
{
float2 leftRight = step(d.xy, d.yx);
float2 rounding = (1.0 - HqaaSmCorneringCustom[clamp(HqaaPresetDetailRetain, 0, 2)]) * leftRight;
float2 tcs = float2((1.0 / 1920), (1.0 / 1018));
#line 3229
float2 factor = float(1.0).xx;
factor.x -= rounding.x * tex2Dlod(HQAAedgesTex, texcoord.xyxy + float4(0, tcs.y, 0, 0)).r;
factor.x -= rounding.y * tex2Dlod(HQAAedgesTex, texcoord.zwzw + float4(tcs, 0, 0)).r;
factor.y -= rounding.x * tex2Dlod(HQAAedgesTex, texcoord.xyxy + float4(0, clamp(-3.5 * saturate(1018 * rcp(HqaaResolutionScalar)), -3.5, -2.0) * tcs.y, 0, 0)).r;
factor.y -= rounding.y * tex2Dlod(HQAAedgesTex, texcoord.zwzw + float4(tcs.x, clamp(-3.5 * saturate(1018 * rcp(HqaaResolutionScalar)), -3.5, -2.0) * tcs.y, 0, 0)).r;
#line 3235
weights *= saturate(factor);
}
void HQAADetectVerticalCornerPattern(sampler2D HQAAedgesTex, inout float2 weights, float4 texcoord, float2 d)
{
float2 leftRight = step(d.xy, d.yx);
float2 rounding = (1.0 - HqaaSmCorneringCustom[clamp(HqaaPresetDetailRetain, 0, 2)]) * leftRight;
float2 tcs = float2((1.0 / 1920), (1.0 / 1018));
#line 3243
float2 factor = float(1.0).xx;
factor.x -= rounding.x * tex2Dlod(HQAAedgesTex, texcoord.xyxy + float4(tcs.x, 0, 0, 0)).g;
factor.x -= rounding.y * tex2Dlod(HQAAedgesTex, texcoord.zwzw + float4(tcs, 0, 0)).g;
factor.y -= rounding.x * tex2Dlod(HQAAedgesTex, texcoord.xyxy + float4(clamp(-3.5 * saturate(1018 * rcp(HqaaResolutionScalar)), -3.5, -2.0) * tcs.x, 0, 0, 0)).g;
factor.y -= rounding.y * tex2Dlod(HQAAedgesTex, texcoord.zwzw + float4(clamp(-3.5 * saturate(1018 * rcp(HqaaResolutionScalar)), -3.5, -2.0) * tcs.x, tcs.y, 0, 0)).g;
#line 3249
weights *= saturate(factor);
}
#line 3270
 
#line 3274
float3 tonemap_adjustluma(float3 x, float xl_out)
{
float xl = dot(x, float3(0.2126, 0.7152, 0.0722));
return x * (xl_out * rcp(xl));
}
#line 3280
float3 reinhard_jodie(float3 x)
{
float xl = dot(x, float3(0.2126, 0.7152, 0.0722));
float3 xv = x * rcp(1.0 + x);
return lerp(x * rcp(1.0 + xl), xv, xv);
}
#line 3287
float3 extended_reinhard(float3 x, float param)
{
float whitepoint = abs(param);
float3 numerator = x * (1.0 + (x * rcp(whitepoint * whitepoint)));
return numerator * rcp(1.0 + x);
}
#line 3294
float3 extended_reinhard_luma(float3 x, float param)
{
float whitepoint = abs(param);
float xl = dot(x, float3(0.2126, 0.7152, 0.0722));
float numerator = xl * (1.0 + (xl * rcp(whitepoint * whitepoint)));
float xl_shift = numerator * rcp(1.0 + xl);
return tonemap_adjustluma(x, xl_shift);
}
#line 3303
float3 uncharted2_partial(float3 x)
{
float A = 0.15;
float B = 0.5;
float C = 0.1;
float D = 0.2;
float E = 0.02;
float F = 0.3;
#line 3312
return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}
#line 3315
float3 uncharted2_filmic(float3 x)
{
float exposure_bias = 2.0;
float3 curr = uncharted2_partial(x * exposure_bias);
float3 whitescale = rcp(uncharted2_partial(float(11.2).xxx));
return curr * whitescale;
}
#line 3323
float3 aces_approx(float3 x)
{
float3 xout = x * 0.6;
float A = 2.51;
float B = 0.03;
float C = 2.43;
float D = 0.59;
float E = 0.14;
#line 3332
return saturate((xout*(A*xout+B))/(xout*(C*xout+D)+E));
}
#line 3335
float3 logarithmic_fake_hdr(float3 x, float param)
{
bool3 truezero = !x;
return pow(abs(2.718282 + (abs(param) * (0.5 - log2(1.0 + dot(x, float3(0.2126, 0.7152, 0.0722)))))), log(clamp(x, rcp(pow(2., 8)), 1.0))) * (!truezero);
}
#line 3341
float3 logarithmic_range_compression(float3 x, float param)
{
float luma = dot(x, float3(0.2126, 0.7152, 0.0722));
bool3 truezero = !x;
float offset = abs(param) * (0.5 - luma);
float3 result = pow(abs(2.718282 - offset), log(clamp(x, rcp(pow(2., 8)), 1.0))) * (!truezero);
return result;
}
#line 3350
float3 logarithmic_dehaze(float3 x)
{
float luma = dot(x, float3(0.2126, 0.7152, 0.0722));
bool3 truezero = !x;
float adjust = saturate(0.666666 - luma);
adjust = saturate((0.666666 - (2. * abs(0.444444 - adjust))) * rcp(0.666666));
float offset = clamp(HqaaDehazeStrength * 2.718282, 0.0, 2.718282) * adjust;
float3 result = pow(abs(2.718282 + offset), log(clamp(x, rcp(pow(2., 8)), 1.0))) * (!truezero);
return result;
}
#line 3361
float3 contrast_enhance(float3 x)
{
float luma = dot(x, float3(0.2126, 0.7152, 0.0722));
float average = HqaaContrastUseYUV ? dot(x, float3(0.3505, 0.2065, 0.443)) : dot(x, float3(0.3937, 0.1424, 0.4639));
bool3 truezero = !x;
float offset = clamp(HqaaContrastEnhance * 2.718282, 0.0, 2.718282) * saturate(1.0 - average);
float3 result = pow(abs(2.718282 + offset), log(clamp(x, rcp(pow(2., 8)), 1.0))) * (!truezero);
float deltaL = luma * rcp(dot(result, float3(0.2126, 0.7152, 0.0722)));
result *= deltaL;
return result;
}
#line 3373
float3 logarithmic_black_stretch(float3 x, float param)
{
bool3 truezero = !x;
float xlevel = max(max(x.r, x.g), x.b);
return pow(abs(2.718282 + (abs(param) * (xlevel - log2(1.0 + dot(x, float3(0.2126, 0.7152, 0.0722)))))), log(clamp(x, rcp(pow(2., 8)), 1.0))) * (!truezero);
}
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
#line 3389 "C:\Program Files\GShade\gshade-shaders\Shaders\HQAA.fx"
#line 3393
texture HQAAedgesTex
#line 3395
< pooled = true; >
#line 3397
{
Width = 1920;
Height = 1018;
#line 3403
Format = RGBA16F;
#line 3405
};
sampler HQAAsamplerAlphaEdges {Texture = HQAAedgesTex;};
#line 3411
texture HQAAblendTex
#line 3413
< pooled = true; >
#line 3415
{
Width = 1920;
Height = 1018;
#line 3421
Format = RGBA16F;
#line 3423
};
sampler HQAAsamplerSMweights {Texture = HQAAblendTex;};
#line 3428
texture HQAAareaTex < source = "AreaTex.png"; >
{
Width = 160;
Height = 560;
Format = RG8;
};
sampler HQAAsamplerSMarea {Texture = HQAAareaTex;};
#line 3437
texture HQAAsearchTex < source = "SearchTex.png"; >
{
Width = 64;
Height = 16;
Format = R8;
};
sampler HQAAsamplerSMsearch {Texture = HQAAsearchTex;};
#line 3447
texture HQAAOriginalBufferTex
{
Width = 1920;
Height = 1018;
#line 3452
Format = RGBA8;
#line 3458
};
sampler OriginalBuffer {Texture = HQAAOriginalBufferTex;};
#line 3534
 
#line 3539
void HQAAEdgeDetectionVS(float2 texcoord,
out float4 offset[3]) {
offset[0] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4(-1.0, 0.0, 0.0, -1.0), texcoord.xyxy);
offset[1] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
offset[2] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4(-2.0, 0.0, 0.0, -2.0), texcoord.xyxy);
}
void HQAAEdgeDetectionWrapVS(
in uint id : SV_VertexID,
out float4 position : SV_Position,
out float2 texcoord : TEXCOORD0,
out float4 offset[3] : TEXCOORD1)
{
PostProcessVS(id, position, texcoord);
HQAAEdgeDetectionVS(texcoord, offset);
}
#line 3556
void HQAABlendingWeightCalculationVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0, out float2 pixcoord : TEXCOORD1, out float4 offset[3] : TEXCOORD2)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
pixcoord = texcoord * float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).zw;
#line 3563
offset[0] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4(-0.25, -0.125,  1.25, -0.125), texcoord.xyxy);
offset[1] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4(-0.125, -0.25, -0.125,  1.25), texcoord.xyxy);
#line 3566
float searchrange = round(clamp((round(clamp(HqaaFxQualityCustom * saturate(1018 * rcp(HqaaResolutionScalar)), 1, 1920)) + 32.) * float(1018 / 1080.), 32., 1920));
#line 3568
offset[2] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xxyy,
float2(-2.0, 2.0).xyxy * searchrange,
float4(offset[0].xz, offset[1].yw));
}
#line 3574
void HQAANeighborhoodBlendingVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0, out float4 offset : TEXCOORD1)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
offset = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
}
#line 3591
float4 HQAAHybridEdgeDetectionPS(float4 position : SV_Position, float2 texcoord : TEXCOORD0, float4 offset[3] : TEXCOORD1) : SV_Target
{
if ((HqaaSourceInterpolation == 1) && ((HqaaFramecounter + HqaaSourceInterpolationOffset) % 2 == 0)) discard;
if ((HqaaSourceInterpolation == 2) && !((HqaaFramecounter + HqaaSourceInterpolationOffset) % 4 == 1)) discard;
#line 3596
float3 middle = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord).xyxy)).rgb;
float3 ref = float3(0.2126, 0.7152, 0.0722);
#line 3599
float L = dot(middle, ref);
float3 top = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (offset[0].zw).xyxy)).rgb;
float Dtop = chromadelta(middle, top);
float Ltop = dot(top, ref);
float3 left = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (offset[0].xy).xyxy)).rgb;
float Dleft = chromadelta(middle, left);
float Lleft = dot(left, ref);
float Lavg = (L + Ltop + Lleft) * 0.333333;
#line 3608
float rangemult = HqaaLowLumaThreshold ? saturate(1.0 - clamp(Lavg, 0.0, HqaaLowLumaThreshold) * rcp(HqaaLowLumaThreshold)) : 0.0;
#line 3610
float edgethreshold = clamp(HqaaEdgeThresholdCustom, 0.02, 1.00);
#line 3612
edgethreshold = clamp(mad(rangemult, -(saturate(HqaaDynamicThresholdCustom * 0.01) * edgethreshold), edgethreshold), 0.008, 1.00);
float2 bufferdata = float2(L, edgethreshold);
#line 3615
float2 edges = step(edgethreshold, float2(Dleft, Dtop));
if (!any(edges)) return float4(0.0, 0.0, bufferdata);
#line 3618
float3 right = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (offset[1].xy).xyxy)).rgb;
float Dright = chromadelta(middle, right);
float3 bottom = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (offset[1].zw).xyxy)).rgb;
float Dbottom = chromadelta(middle, bottom);
#line 3623
float2 maxdelta = float2(max(Dleft, Dright), max(Dtop, Dbottom));
#line 3625
float Dleftleft = chromadelta(left, ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (offset[2].xy).xyxy)).rgb);
float Dtoptop = chromadelta(top, ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (offset[2].zw).xyxy)).rgb);
#line 3628
maxdelta = max(maxdelta, float2(Dleftleft, Dtoptop));
float largestdelta = max(maxdelta.x, maxdelta.y);
#line 3631
float3 localcontrast = (middle + left + top + right + bottom) * 0.2;
float LCsat = dotsat(localcontrast);
float LCL = dot(localcontrast, ref);
float LCmult = length(float2(LCsat, LCL));
float contrastadaptation = 2.0 + (localcontrast.r + localcontrast.g + localcontrast.b) * LCmult;
edges *= step(largestdelta, contrastadaptation * float2(Dleft, Dtop));
#line 3638
return float4(edges, bufferdata);
}
#line 3662
float4 HQAABlendingWeightCalculationPS(float4 position : SV_Position, float2 texcoord : TEXCOORD0, float2 pixcoord : TEXCOORD1, float4 offset[3] : TEXCOORD2) : SV_Target
{
float4 weights = 0;
float2 e = tex2Dlod(HQAAsamplerAlphaEdges, (texcoord).xyxy).rg;
#line 3667
[branch] if (e.g)
{
float2 diagweights = HQAACalculateDiagWeights(HQAAsamplerAlphaEdges, HQAAsamplerSMarea, texcoord, e);
if (any(diagweights)) {weights.xy = diagweights; e.r = HqaaSmDualCardinal ? e.r : 0.0;}
else
{
float3 coords = float3(HQAASearchXLeft(HQAAsamplerAlphaEdges, HQAAsamplerSMsearch, offset[0].xy, offset[2].x), offset[1].y, HQAASearchXRight(HQAAsamplerAlphaEdges, HQAAsamplerSMsearch, offset[0].zw, offset[2].y));
float e1 = tex2Dlod(HQAAsamplerAlphaEdges, (coords.xy).xyxy).r;
float2 d = coords.xz;
d = abs((mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).zz, d, -pixcoord.xx)));
float e2 = tex2Dlod(HQAAsamplerAlphaEdges, (coords.zy + float2((1.0 / 1920), 0)).xyxy).r;
weights.rg = HQAAArea(HQAAsamplerSMarea, sqrt(d), e1, e2);
coords.y = texcoord.y;
if (HqaaSmCornerDetection) HQAADetectHorizontalCornerPattern(HQAAsamplerAlphaEdges, weights.rg, coords.xyzy, d);
}
}
#line 3684
if (!e.r) return weights;
#line 3686
float3 coords = float3(offset[0].x, HQAASearchYUp(HQAAsamplerAlphaEdges, HQAAsamplerSMsearch, offset[1].xy, offset[2].z), HQAASearchYDown(HQAAsamplerAlphaEdges, HQAAsamplerSMsearch, offset[1].zw, offset[2].w));
float e1 = tex2Dlod(HQAAsamplerAlphaEdges, (coords.xy).xyxy).g;
float2 d = coords.yz;
d = abs((mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).ww, d, -pixcoord.yy)));
float e2 = tex2Dlod(HQAAsamplerAlphaEdges, (coords.xz + float2(0, (1.0 / 1018))).xyxy).g;
weights.ba = HQAAArea(HQAAsamplerSMarea, sqrt(d), e1, e2);
coords.x = texcoord.x;
if (HqaaSmCornerDetection) HQAADetectVerticalCornerPattern(HQAAsamplerAlphaEdges, weights.ba, coords.xyxz, d);
#line 3695
return weights;
}
#line 3700
float3 HQAANeighborhoodBlendingPS(float4 position : SV_Position, float2 texcoord : TEXCOORD0, float4 offset : TEXCOORD1) : SV_Target
{
float3 dotC = tex2Dlod(ReShade::BackBuffer, (texcoord).xyxy).rgb;
float3 resultAA = dotC;
if (HqaaDebugMode == 9) return resultAA;
#line 3706
float4 m = float4(tex2Dlod(HQAAsamplerSMweights, (offset.xy).xyxy).a, tex2Dlod(HQAAsamplerSMweights, (offset.zw).xyxy).g, tex2Dlod(HQAAsamplerSMweights, (texcoord).xyxy).zx);
#line 3708
[branch] if (any(m))
{
resultAA = ConditionalDecode(resultAA);
#line 3712
float maxweight = max(m.x + m.z, m.y + m.w);
float minweight = min(m.x + m.z, m.y + m.w);
float maxratio = maxweight * rcp(minweight + maxweight);
float minratio = minweight * rcp(minweight + maxweight);
#line 3717
bool horiz = (abs(m.x) + abs(m.z)) > (abs(m.y) + abs(m.w));
#line 3719
float4 blendingOffset = 0.0.xxxx;
float2 blendingWeight;
#line 3722
HQAAMovc(bool4(horiz, !horiz, horiz, !horiz), blendingOffset, float4(m.x, m.y, m.z, m.w));
HQAAMovc(bool(horiz).xx, blendingWeight, m.xz);
HQAAMovc(bool(!horiz).xx, blendingWeight, m.yw);
blendingWeight *= rcp(dot(blendingWeight, float(1.0).xx));
float4 blendingCoord = mad(blendingOffset, float4(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy, -float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy), texcoord.xyxy);
resultAA = (HqaaSmDualCardinal ? maxratio : 1.0) * blendingWeight.x * ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (blendingCoord.xy).xyxy)).rgb;
resultAA += (HqaaSmDualCardinal ? maxratio : 1.0) * blendingWeight.y * ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (blendingCoord.zw).xyxy)).rgb;
#line 3731
[branch] if (HqaaSmDualCardinal && minratio != 0.0)
{
blendingOffset = 0.0.xxxx;
HQAAMovc(bool4(!horiz, horiz, !horiz, horiz), blendingOffset, float4(m.x, m.y, m.z, m.w));
HQAAMovc(bool(!horiz).xx, blendingWeight, m.xz);
HQAAMovc(bool(horiz).xx, blendingWeight, m.yw);
blendingWeight *= rcp(dot(blendingWeight, float(1.0).xx));
blendingCoord = mad(blendingOffset, float4(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy, -float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy), texcoord.xyxy);
resultAA += minratio * blendingWeight.x * ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (blendingCoord.xy).xyxy)).rgb;
resultAA += minratio * blendingWeight.y * ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (blendingCoord.zw).xyxy)).rgb;
}
#line 3743
resultAA = ConditionalEncode(resultAA);
}
#line 3746
return resultAA;
}
#line 3759
float3 HQAAFXPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float3 original = tex2Dlod(ReShade::BackBuffer, (texcoord).xyxy).rgb;
if (HqaaDebugMode == 10) return original;
#line 3764
bool earlyExit = false;
bool smaaoverlap = false;
#line 3768
smaaoverlap = any(tex2Dlod(HQAAsamplerSMweights, (texcoord).xyxy));
if (HqaaFxOverlapAbort) earlyExit = smaaoverlap;
#line 3772
float2 lengthSign = float2((1.0 / 1920), (1.0 / 1018));
#line 3775
float4 smaadata = tex2Dlod(HQAAsamplerAlphaEdges, (texcoord).xyxy);
#line 3794
float edgethreshold = smaadata.a;
float3 middle = ConditionalDecode(original);
#line 3797
float sumrgb = middle.r + middle.g + middle.b;
float msat = dotsat(middle);
float3 ref = sumrgb ? (lerp(middle * rcp(sumrgb), 0.333333, msat)) : float3(0.2126, 0.7152, 0.0722);
#line 3801
float lumaM = dot(middle, float3(0.2126, 0.7152, 0.0722));
float deltaLm = lumaM - dot(middle, ref);
#line 3804
float3 psouth = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord + float2(0, lengthSign.y)).xyxy)).rgb;
float3 peast = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord + float2(lengthSign.x, 0)).xyxy)).rgb;
float3 pnorth = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord - float2(0, lengthSign.y)).xyxy)).rgb;
float3 pwest = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord - float2(lengthSign.x, 0)).xyxy)).rgb;
#line 3809
float lumaS = dot(psouth, ref);
float lumaE = dot(peast, ref);
float lumaN = dot(pnorth, ref);
float lumaW = dot(pwest, ref);
float4 crossdelta = abs(lumaM - float4(lumaS, lumaE, lumaN, lumaW));
float2 weightsHV = float2(max(crossdelta.x, crossdelta.z), max(crossdelta.y, crossdelta.w));
#line 3821
float2 diagstep = lengthSign * 0.707107;
float3 pnw = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord - diagstep).xyxy)).rgb;
float3 pse = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord + diagstep).xyxy)).rgb;
float3 pne = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord + float2(diagstep.x, -diagstep.y)).xyxy)).rgb;
float3 psw = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord + float2(-diagstep.x, diagstep.y)).xyxy)).rgb;
#line 3827
float lumaNW = dot(pnw, ref);
float lumaSE = dot(pse, ref);
float lumaNE = dot(pne, ref);
float lumaSW = dot(psw, ref);
float4 diagdelta = abs(lumaM - float4(lumaNW, lumaSE, lumaNE, lumaSW));
float2 weightsDI = float2(max(diagdelta.w, diagdelta.z), max(diagdelta.x, diagdelta.y));
#line 3840
bool diagSpan = false;
if (HqaaFxDiagScans) diagSpan = max(weightsDI.x, weightsDI.y) > max(weightsHV.x, weightsHV.y);
bool inverseDiag = diagSpan && weightsDI.y > weightsDI.x;
bool horzSpan = weightsHV.x >= weightsHV.y;
#line 3845
float range = max4(weightsHV.x, weightsHV.y, weightsDI.x, weightsDI.y);
#line 3848
if (HqaaFxEarlyExit) earlyExit = earlyExit || ((range - abs(deltaLm)) < edgethreshold);
#line 3851
if (earlyExit)
if ((clamp(HqaaDebugMode, 3, 6) == HqaaDebugMode) || (HqaaDebugMode == 13)) return original * 0.125;
else return original;
#line 3855
float mindelta = 8 * rcp(pow(2., 8)) * 0.75;
float sdelta = (abs(lumaM - dot(psw, ref)) + abs(lumaM - dot(pne, ref))) - abs(deltaLm);
float bsdelta = (abs(lumaM - dot(pnw, ref)) + abs(lumaM - dot(pse, ref))) - abs(deltaLm);
float hdelta = (abs(lumaM - dot(peast, ref)) + abs(lumaM - dot(pwest, ref))) - abs(deltaLm);
float vdelta = (abs(lumaM - dot(pnorth, ref)) + abs(lumaM - dot(psouth, ref))) - abs(deltaLm);
#line 3865
float PRP = diagSpan * ((sdelta * inverseDiag) + (bsdelta * !inverseDiag));
PRP += !diagSpan * ((hdelta * horzSpan) + (vdelta * !horzSpan));
PRP = pow(abs(PRP), 0.0625 + (HqaaFxBlurControl * 0.0625));
if (HqaaDebugMode == 13) return float3(1.0 - PRP, 0.5 * saturate(2. * PRP), 0.5 * saturate(2. * PRP));
#line 3870
float2 lumaNP = float2(lumaN, lumaS);
HQAAMovc(!horzSpan.xx, lumaNP, float2(lumaW, lumaE));
HQAAMovc(diagSpan.xx, lumaNP, float2(lumaSW, lumaNE));
HQAAMovc((diagSpan && inverseDiag).xx, lumaNP, float2(lumaNW, lumaSE));
float2 gradientNP = abs(lumaNP - lumaM);
float lumaNN = ((gradientNP.y > gradientNP.x) ? (lumaNP.y + lumaM + deltaLm) : (lumaNP.x + lumaM + deltaLm)) * 0.555555;
if (gradientNP.x >= gradientNP.y && !diagSpan) lengthSign = -lengthSign;
if (diagSpan && inverseDiag) lengthSign.y = -lengthSign.y;
float gradientScaled = max(gradientNP.x, gradientNP.y) * 0.111111;
bool lumaMLTZero = (lumaM - lumaNN) < 0.0;
#line 3881
float2 offNPdir = float2(horzSpan || diagSpan, (!diagSpan && !horzSpan) || (diagSpan && !inverseDiag)) - float2(0.0, diagSpan && inverseDiag);
float2 offNPsign = offNPdir * float2((1.0 / 1920), (1.0 / 1018));
float2 offNPref = clamp(HqaaFxTexelCustom * saturate(1018 * rcp(HqaaResolutionScalar)), 0.0, 4.0).xx;
float2 offNP = offNPref * offNPsign;
#line 3886
float2 posB = !diagSpan ? (texcoord + lengthSign * 0.666666 * abs(offNPdir.yx)) : (texcoord + lengthSign * float2(2.1, -1.05));
float2 posN = posB - offNP;
float2 posP = posB + offNP;
float lumaEndN = dot(ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (posN).xyxy)).rgb, ref);
float lumaEndP = dot(ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (posP).xyxy)).rgb, ref);
#line 3892
lumaEndN -= lumaNN;
lumaEndP -= lumaNN;
#line 3895
bool doneN = abs(lumaEndN) >= gradientScaled;
bool doneP = abs(lumaEndP) >= gradientScaled;
float iterations = 0.;
float maxiterations = round(clamp(HqaaFxQualityCustom * saturate(1018 * rcp(HqaaResolutionScalar)), 1, 1920));
float startgrowingafter = max(round((clamp(HqaaFxTexelGrowAfter, 1, 100) / 100.) * maxiterations), 1.);
float growpercent = saturate(HqaaFxTexelGrowPercent / 100.) + 1.;
#line 3902
[loop] while (iterations < maxiterations)
{
if (doneN) {posP += offNPsign; break;}
if (doneP) {posN -= offNPsign; break;}
[branch] if (!doneN)
{
posN -= offNP;
lumaEndN = dot(ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (posN).xyxy)).rgb, ref);
lumaEndN -= lumaNN;
doneN = abs(lumaEndN) >= gradientScaled;
}
[branch] if (!doneP)
{
posP += offNP;
lumaEndP = dot(ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (posP).xyxy)).rgb, ref);
lumaEndP -= lumaNN;
doneP = abs(lumaEndP) >= gradientScaled;
}
[branch] if (HqaaFxTexelGrowth && (iterations > startgrowingafter))
{
offNPref *= growpercent;
offNP = offNPref * offNPsign;
}
iterations+=1.0;
}
#line 3928
float dst = doneN ? (texcoord.y - posN.y) : (posP.y - texcoord.y);
if (horzSpan) dst = doneN ? (texcoord.x - posN.x) : (posP.x - texcoord.x);
if (diagSpan) dst = doneN ? length(float2(texcoord.y - posN.y, texcoord.x - posN.x)) : length(float2(posP.y - texcoord.y, posP.x - texcoord.x));
#line 3932
float endluma = doneN ? lumaEndN : lumaEndP;
bool goodSpan = endluma < 0.0 != lumaMLTZero;
#line 3935
if ((HqaaDebugMode == 11) && !goodSpan) return original;
if ((HqaaDebugMode == 12) && goodSpan) return original;
#line 3938
if ((HqaaDebugMode == 0 || HqaaDebugMode == 3) && !any(smaadata.rg) && !goodSpan) return original;
#line 3940
float madapt = 1 * 0.0625;
float goodSpanMul = abs(mad(-rcp(dst + dst), dst, 1.0625 - madapt));
float localdelta = dot(crossdelta, 0.125) + dot(diagdelta, 0.125);
float cross = lumaS + lumaE + lumaN + lumaW;
float star = lumaNW + lumaSE + lumaNE + lumaSW;
float fallback = mad(cross + star, 0.125, -lumaM) * rcp(range); 
fallback = pow(saturate(mad(-2.0, fallback, 3.0) * (fallback * fallback)), 2.0); 
float badSpanMul = (localdelta ? (sqrt(localdelta)) : 1.0) * fallback;
float spanMult = goodSpan ? lerp(goodSpanMul * sqrt(fallback), badSpanMul, HqaaFxBlurControl * HqaaFxBlurControl) : badSpanMul;
float subpixOut = spanMult;
subpixOut *= HqaaFxBlendCustom[clamp(HqaaPresetDetailRetain, 0, 2)] * PRP * (1.0 - 0.333333 * smaaoverlap);
#line 3952
float2 posM = texcoord;
HQAAMovc(bool2(!horzSpan || diagSpan, horzSpan || diagSpan), posM, float2(texcoord.x + lengthSign.x * subpixOut, texcoord.y + lengthSign.y * subpixOut));
#line 3956
if (HqaaDebugMode == 4)
{
float3 debugout = sumrgb ? (ref * min3(ref.r, ref.g, ref.b) * rcp(lumaM)) : ref;
return debugout;
}
if (HqaaDebugMode == 5)
{
#line 3964
float runtime = float(iterations * rcp(maxiterations)) * 0.5;
float3 FxaaMetrics = float3(runtime, 0.5 - runtime, 0.0);
return FxaaMetrics;
}
if (HqaaDebugMode == 6)
{
#line 3971
if (goodSpan) return float3(0.4, 0.4, 0.4);
else
{
float3 spantype = float3(!horzSpan && !diagSpan, horzSpan && !diagSpan, diagSpan);
return spantype * float3(0.5, 0.375, 0.9);
}
}
#line 3980
return tex2Dlod(ReShade::BackBuffer, (posM).xyxy).rgb;
}
#line 3995
float3 HQAASharpenPS(float4 vpos, float2 texcoord)
#line 3997
{
if (HqaaEnableSharpening && (HqaaDebugMode == 0))
{
float3 casdot = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord).xyxy)).rgb;
bool3 truezero = !casdot;
#line 4003
float4 edgedata = tex2Dlod(HQAAsamplerAlphaEdges, (texcoord).xyxy);
#line 4006
float sharpening = saturate(HqaaSharpenerStrength);
#line 4009
if (any(edgedata.rg)) sharpening = saturate(sharpening + clamp(HqaaSharpenerClamping, -1.0, 1.0));
#line 4012
float2 hvstep = float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy;
#line 4014
float Mmax = max(max(casdot.r, casdot.g), casdot.b);
float Msat = Mmax ? ((Mmax - min(min(casdot.r, casdot.g), casdot.b)) * rcp(Mmax)) : 0.0;
#line 4017
float3 a = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord - hvstep).xyxy)).rgb;
float3 b = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord - float2(0.0, hvstep.y)).xyxy)).rgb;
float3 c = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord - float2(hvstep.x, 0.0)).xyxy)).rgb;
#line 4021
float3 mnRGB = min(min(casdot,a),min(b,c));
float3 mxRGB = max(max(casdot,a),max(b,c));
#line 4024
float maxcontrast = max(max(mxRGB.r, mxRGB.g), mxRGB.b) - min(min(mnRGB.r, mnRGB.g), mnRGB.b);
float predication = (maxcontrast > 1.0) ? (rcp(maxcontrast)) : (1.0 - maxcontrast);
predication = sqrt(predication);
#line 4028
float scaleRGB = max(max(mxRGB.r, mxRGB.b), mxRGB.g);
float compressRGB = rcp(scaleRGB);
#line 4031
float3 origin = casdot;
casdot *= compressRGB;
b *= compressRGB;
c *= compressRGB;
#line 4036
mnRGB *= 2.;
mnRGB *= compressRGB;
mxRGB *= 2.;
mxRGB *= compressRGB;
#line 4041
float Mluma = 1.333333 - dot(casdot, float3(0.12, 0.41, 0.47));
predication *= Mluma;
predication *= (Msat + 0.333333);
#line 4045
float3 ampRGB = rsqrt(saturate(min(mnRGB, 2.0 - mxRGB) * rcp(mxRGB)));
float3 wRGB = -rcp(ampRGB * mad(-3.5, saturate(predication), 8.0));
float3 window = (b + c + casdot) * 1.333;
#line 4049
float3 outColor = saturate(mad(window, wRGB, casdot) * rcp(mad(4.0, wRGB, 1.0)) * scaleRGB * (!truezero));
casdot = lerp(origin, outColor, sharpening);
#line 4052
return ConditionalEncode(casdot);
}
return tex2Dlod(ReShade::BackBuffer, (texcoord).xyxy).rgb;
}
#line 4057
float3 HQAAPostProcessPS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float3 pixel = tex2Dlod(ReShade::BackBuffer, (texcoord).xyxy).rgb;
#line 4061
float4 edgedata = tex2Dlod(HQAAsamplerAlphaEdges, (texcoord).xyxy);
#line 4065
if (HqaaDebugMode == 1) return float3(edgedata.rg, 0.0);
#line 4067
if (HqaaDebugMode == 2) return tex2Dlod(HQAAsamplerSMweights, (texcoord).xyxy).rgb;
#line 4069
if (HqaaDebugMode == 8) { float usedthreshold = 1.0 - rcp(clamp(HqaaEdgeThresholdCustom, 0.02, 1.00) * rcp(edgedata.a)); return float3(0.0, saturate(usedthreshold), 0.0); }
#line 4071
if ((HqaaDebugMode != 0) && (HqaaDebugMode != 7)) return pixel;
#line 4073
float3 original = pixel;
bool altered = false;
float3 AAdot = ConditionalDecode(pixel);
#line 4078
pixel = HQAASharpenPS(position, texcoord);
if (dot(pixel - AAdot, 1.)) altered = true;
#line 4085
if (HqaaDoLumaHysteresis)
{
float lowlumaclamp = rcp(clamp(HqaaEdgeThresholdCustom, 0.02, 1.00) * rcp(edgedata.a));
float blendstrength = HqaaHysteresisStrength[clamp(HqaaPresetDetailRetain, 0, 2)] * lowlumaclamp;
#line 4090
float hysteresis = (dot(pixel, float3(0.2126, 0.7152, 0.0722)) - edgedata.b) * blendstrength;
if (abs(hysteresis) > saturate(HqaaHysteresisFudgeFactor * 0.01))
{
bool3 truezero = !pixel;
pixel = pow(abs(1.0 + hysteresis) * 2.0, log2(pixel)) * (!truezero);
altered = true;
}
}
#line 4101
if (HqaaDebugMode == 7)
{
#line 4104
if (altered) return sqrt(abs(pixel - AAdot));
else return 0.0.xxx;
}
#line 4108
if (HqaaEnableColorPalette && (saturate(HqaaSaturationStrength) != 0.5))
{
float3 outdot = AdjustSaturation(pixel, saturate(HqaaSaturationStrength));
pixel = outdot;
altered = true;
}
#line 4115
if (HqaaEnableColorPalette && (clamp(HqaaVibranceStrength, 0, 100) != 50.0))
{
float3 outdot = pixel;
bool3 truezero = !outdot;
outdot = AdjustVibrance(outdot, -(saturate(HqaaVibranceStrength / 100.0) - 0.5));
pixel = outdot * (!truezero);
altered = true;
}
#line 4124
if (HqaaEnableBrightnessGain && (saturate(HqaaGainStrength) > 0.0))
{
float3 outdot = pixel;
if (HqaaGainLowLumaCorrection) outdot = AdjustSaturation(outdot, 0.5 + lerp(0.0, 0.2, saturate(2.0 * HqaaGainStrength)));
float lift = saturate(HqaaGainStrength);
bool3 truezero = !outdot;
float channelfloor = HqaaGainLowLumaCorrection ? rcp(pow(2., 8)) : 1.0;
float preluma = max(max(outdot.r, outdot.g), outdot.b);
float colorgain = 2.0 - log2(lift + 1.0);
outdot = preluma ? (pow(abs(colorgain), log2(outdot)) * (!truezero)) : 0.0;
pixel = outdot;
altered = true;
#line 4137
if (HqaaGainLowLumaCorrection && (preluma > channelfloor))
{
#line 4140
channelfloor = pow(abs(colorgain), log2(channelfloor));
#line 4142
float contrastgain = log(rcp(abs(max(max(outdot.r, outdot.g), outdot.b) - channelfloor))) * pow(2., 2. + channelfloor) * lift * lift * (1.0 - HqaaDehazeStrength);
outdot = pow(abs((2.718282 * 0.666666) + contrastgain) * 1.5, log(outdot));
float lumadelta = max(max(outdot.r, outdot.g), outdot.b) - preluma;
outdot = RGBtoYUV(outdot);
outdot.x = saturate(outdot.x - lumadelta * channelfloor);
outdot = YUVtoRGB(outdot);
outdot = logarithmic_black_stretch(outdot, lerp(0.0, 1.5, saturate(2.0 * HqaaGainStrength)));
pixel = outdot * !truezero;
}
}
#line 4153
if (HqaaEnableBrightnessGain && (saturate(HqaaLumaGain) > 0.0))
{
float3 outdot = pixel;
float pmin = min(min(outdot.r, outdot.g), outdot.b);
outdot = pow(saturate(outdot), 1.0 - pmin);
outdot = lerp(pixel, outdot, saturate(HqaaLumaGain));
pixel = outdot;
}
#line 4162
if (HqaaEnableColorPalette && (saturate(HqaaColorTemperature) != 0.5))
{
float3 outdot = RGBtoYUV(pixel);
float direction = (0.5 - saturate(HqaaColorTemperature)) * abs(outdot.z) * outdot.x;
outdot.y += direction * 0.5;
outdot.z -= direction;
pixel = YUVtoRGB(outdot);
altered = true;
}
#line 4172
if (HqaaEnableColorPalette && (HqaaContrastEnhance > 0.0))
{
pixel = contrast_enhance(pixel);
altered = true;
}
#line 4178
if (HqaaEnableBrightnessGain && (HqaaDehazeStrength > 0.0))
{
pixel = logarithmic_dehaze(pixel);
altered = true;
}
#line 4185
if (HqaaEnableColorPalette && (HqaaTonemapping > 0))
#line 4189
{
float3 outdot = pixel;
if (HqaaTonemapping == 1) outdot = extended_reinhard(pixel, HqaaTonemappingParameter);
if (HqaaTonemapping == 2) outdot = extended_reinhard_luma(pixel, HqaaTonemappingParameter);
if (HqaaTonemapping == 3) outdot = reinhard_jodie(pixel);
if (HqaaTonemapping == 4) outdot = uncharted2_filmic(pixel);
if (HqaaTonemapping == 5) outdot = aces_approx(pixel);
if (HqaaTonemapping == 6) outdot = logarithmic_fake_hdr(pixel, HqaaTonemappingParameter);
if (HqaaTonemapping == 7) outdot = logarithmic_range_compression(pixel, HqaaTonemappingParameter);
if (HqaaTonemapping == 8) outdot = logarithmic_black_stretch(pixel, HqaaTonemappingParameter);
if (any(outdot - pixel)) altered = true;
pixel = outdot;
}
#line 4203
if (HqaaEnableBrightnessGain && (HqaaRaiseBlack > 0.0))
{
pixel += HqaaRaiseBlack * (1.0 - pixel);
altered = true;
}
#line 4209
if (saturate(HqaaBlueLightFilter) != 0.0)
{
float strength = 1.0 - (saturate(HqaaBlueLightFilter) * 0.9278);
float3 outdot = pixel;
if (HqaaBlueFilterLumaCorrection) {
float lift = saturate(HqaaBlueLightFilter) * 0.1667;
bool3 truezero = !outdot;
float preluma = max(max(outdot.r, outdot.g), outdot.b);
float colorgain = 2.0 - log2(lift + 1.0);
outdot = preluma ? (pow(abs(colorgain), log2(outdot)) * (!truezero)) : 0.0;
}
outdot.b *= strength;
outdot.g *= lerp(0.6564, 1.0, strength);
outdot.r *= lerp(0.8292, 1.0, strength);
pixel = saturate(outdot);
altered = true;
}
#line 4227
if (altered) return ConditionalEncode(pixel);
else return original;
}
#line 4240
float2 HQAATAAEdgeDetectionPS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float3 middle = ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord).xyxy)).rgb;
float2 hvstep = float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy;
#line 4245
float Dtop = chromadelta(middle, ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord - float2(0, hvstep.y)).xyxy)).rgb);
float Dleft = chromadelta(middle, ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord - float2(hvstep.x, 0)).xyxy)).rgb);
float Dright = chromadelta(middle, ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord + float2(hvstep.x, 0)).xyxy)).rgb);
float Dbottom = chromadelta(middle, ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord + float2(0, hvstep.y)).xyxy)).rgb);
#line 4250
float2 edges = float2(max(Dtop, Dbottom), max(Dleft, Dright));
#line 4252
return edges;
}
#line 4257
float4 HQAATAAGenerateBufferJitterPS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_Target
{
float2 edges = HQAATAAEdgeDetectionPS(vpos, texcoord).rg;
float edgeT = edges.x + edges.y;
#line 4263
if (edgeT == 0.0) return ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord).xyxy));
#line 4269
float edgeD = abs(edges.x - edges.y);
edgeD = edgeD ? pow(edgeD, 0.25) : 0.2;
float2 edgeW = edges * rcp(edgeT) + 0.5;
float2 offsetdir = 0.0.xx;
if (((HqaaFramecounter + HqaaSourceInterpolationOffset) % 2 == 0)) offsetdir = float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy;
else offsetdir = float2((1.0 / 1920), -(1.0 / 1018));
offsetdir *= clamp(HqaaTaaJitterOffset * sqrt(1018 / 2160.), 0.0, 4.0) * edgeW * edgeD * saturate(1018 * rcp(HqaaResolutionScalar));
#line 4277
return (ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord + offsetdir).xyxy)) + ConditionalDecode(tex2Dlod(ReShade::BackBuffer, (texcoord - offsetdir).xyxy))) * 0.5;
}
#line 4326
float4 HQAATAATemporalBlendingPS(float4 vpos, float2 texcoord)
#line 4328
{
float2 edges = HQAATAAEdgeDetectionPS(vpos, texcoord).rg;
float edgeW = edges.x + edges.y;
float4 original = tex2Dlod(ReShade::BackBuffer, (texcoord).xyxy);
#line 4335
if (HqaaDebugMode != 0) return original;
#line 4338
if (edgeW == 0.0) return original;
#line 4340
float edgeM = max(edges.r, edges.g);
original = ConditionalDecode(original);
float osat = dotsat(original);
float smult = 1.0 + (0.5 - osat * osat * 0.833333);
float blendweight = saturate(pow(saturate(edgeM), 0.75) * rsqrt(saturate(edgeM)) * smult + HqaaTaaMinimumBlend);
#line 4357
float4 jitter0 = HQAATAAGenerateBufferJitterPS(vpos, texcoord);
if (HqaaTaaLumaCorrection) {
float preluma = dot(original.rgb, float3(0.2126, 0.7152, 0.0722));
float postluma = dot(jitter0.rgb, float3(0.2126, 0.7152, 0.0722));
float Lmult = 1.0 + ((preluma - postluma) * (0.375 * osat + 0.625));
jitter0 *= Lmult;
}
return ConditionalEncode(lerp(original, jitter0, blendweight));
#line 4366
}
#line 4368
float4 HQAATAATemporalBlendingOnePS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_Target
{
#line 4373
return HQAATAATemporalBlendingPS(vpos, texcoord);
#line 4375
}
#line 4386
 
#line 4397
 
#line 4408
 
#line 4492
 
#line 4605
 
#line 4619
 
#line 4622
float4 HQAABufferCopyPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return tex2Dlod(ReShade::BackBuffer, (texcoord).xyxy);
}
#line 4627
float4 HQAASplitScreenPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float leftbound = HqaaSplitscreenAuto ? (abs(((HqaaFramecounter % (0.75 * 1920)) / (0.375 * 1920)) -1.) - 2. * (1.0 / 1920)) : (HqaaSplitscreenPosition - 2. * (1.0 / 1920));
float rightbound = HqaaSplitscreenAuto ? (abs(((HqaaFramecounter % (0.75 * 1920)) / (0.375 * 1920)) -1.) + 2. * (1.0 / 1920)) : (HqaaSplitscreenPosition + 2. * (1.0 / 1920));
if (clamp(texcoord.x, leftbound, rightbound) == texcoord.x) return 0.0;
if ((texcoord.x > rightbound) && HqaaSplitscreenFlipped) return tex2Dlod(OriginalBuffer, (texcoord).xyxy);
if ((texcoord.x < leftbound) && !HqaaSplitscreenFlipped) return tex2Dlod(OriginalBuffer, (texcoord).xyxy);
return tex2Dlod(ReShade::BackBuffer, (texcoord).xyxy);
}
#line 4641
technique HQAA <
ui_tooltip = "============================================================\n"
"Hybrid high-Quality Anti-Aliasing combines techniques of\n"
"both SMAA and FXAA to produce best possible image quality\n"
"from using both. HQAA uses customized edge detection methods\n"
"designed for maximum possible aliasing detection.\n"
"============================================================";
>
{
#line 4652
pass CopyBuffer
{
VertexShader = PostProcessVS;
PixelShader = HQAABufferCopyPS;
RenderTarget = HQAAOriginalBufferTex;
ClearRenderTargets = true;
}
#line 4662
pass EdgeDetection
{
VertexShader = HQAAEdgeDetectionWrapVS;
PixelShader = HQAAHybridEdgeDetectionPS;
#line 4667
RenderTarget = HQAAedgesTex;
#line 4671
ClearRenderTargets = true;
}
#line 4686
pass SMAABlendCalculation
{
VertexShader = HQAABlendingWeightCalculationVS;
PixelShader = HQAABlendingWeightCalculationPS;
RenderTarget = HQAAblendTex;
ClearRenderTargets = true;
}
pass SMAABlending
{
VertexShader = HQAANeighborhoodBlendingVS;
PixelShader = HQAANeighborhoodBlendingPS;
}
#line 4710
pass TAABlending
{
VertexShader = PostProcessVS;
PixelShader = HQAATAATemporalBlendingOnePS;
}
#line 4718
pass FXAA
{
VertexShader = PostProcessVS;
PixelShader = HQAAFXPS;
}
#line 4740
 
#line 4765
 
#line 4790
 
#line 4899
pass GeneralPurpose
{
VertexShader = PostProcessVS;
PixelShader = HQAAPostProcessPS;
}
#line 4951
pass SplitScreenPreview
{
VertexShader = PostProcessVS;
PixelShader = HQAASplitScreenPS;
}
#line 4958
}

