// ENABLE_MISC_CONTROLS=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ATMOSPHERE.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\ATMOSPHERE.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/Lib/Common.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/Lib/Macros.fxh"
#line 38 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/Lib/Common.fxh"
#line 42
uniform float Timer     < source = "timer"; >;
uniform float FrameTime < source = "frametime"; >;
#line 53
float  linearstep(float  Low, float  Up, float  x)
{
return saturate((x - Low) / (Up - Low));
}
#line 58
float2 linearstep(float2 Low, float2 Up, float2 x)
{
return saturate((x - Low) / (Up - Low));
}
#line 63
float3 linearstep(float3 Low, float3 Up, float3 x)
{
return saturate((x - Low) / (Up - Low));
}
#line 68
float3 ConeOverlap(float3 c)
{
float k = 0.4 * 0.5;
float2 f = float2(1 - 2 * k, k);
float3x3 m = float3x3(f.xyy, f.yxy, f.yyx);
return mul(c, m);
}
#line 76
float3 ConeOverlapInv(float3 c)
{
float k = 0.4 * 0.5;
float2 f = float2(k - 1, k) * rcp(3 * k - 1);
float3x3 m = float3x3(f.xyy, f.yxy, f.yyx);
return mul(c, m);
}
#line 84
float LinearToSRGB( float x )
{
#line 87
return x < 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1.0 / 2.4) - 0.055;
}
#line 90
float3 LinearToSRGB( float3 x )
{
#line 93
return x < 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1.0 / 2.4) - 0.055;
}
#line 96
float4 LinearToSRGB( float4 x )
{
#line 99
return x < 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1.0 / 2.4) - 0.055;
}
#line 102
float SRGBToLinear( float x )
{
#line 105
return x < 0.04045 ? x / 12.92 : pow( (x + 0.055) / 1.055, 2.4 );
}
#line 108
float3 SRGBToLinear( float3 x )
{
#line 111
return x < 0.04045 ? x / 12.92 : pow( (x + 0.055) / 1.055, 2.4 );
}
#line 114
float4 SRGBToLinear( float4 x )
{
#line 117
return x < 0.04045 ? x / 12.92 : pow( (x + 0.055) / 1.055, 2.4 );
}
#line 120
float3 ToHDR(float3 color, float multi)
{
color = ConeOverlap(color);
return exp2(multi * color);
}
#line 126
float3 ToSDR(float3 color, float multi)
{
color = log2(color) / multi;
return saturate(ConeOverlapInv(color));
}
#line 132
float3 LogC3(float3 LinearColor)
{
float3 LogColor;
#line 137
LogColor =  LinearColor > 0.010591
? (0.247190 * log10(5.555556 * LinearColor + 0.052272) + 0.385537)
: (5.367655 * LinearColor + 0.092809);
#line 141
LogColor = ConeOverlapInv(LogColor);
#line 143
return saturate(LogColor);
}
#line 146
float3 LogC4(float3 HDRLinear)
{
float3 LogColor;
#line 150
LogColor = (HDRLinear <=  -0.0180570)
? (HDRLinear  - (-0.0180570)) / 0.113597
: (log2(2231.826309067688 * HDRLinear + 64.0) - 6.0) / 14.0 * 0.9071358748778104 + 0.0928641251221896;
#line 154
LogColor = ConeOverlapInv(LogColor);
#line 156
return saturate(LogColor);
}
#line 161
float3 RGBToHCV(float3 RGB)
{
#line 164
float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0/3.0) : float4(RGB.gb, 0.0, -1.0/3.0);
float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
float C = Q.x - min(Q.w, Q.y);
float H = abs((Q.w - Q.y) / (6 * C + 1e-10) + Q.z);
return float3(H, C, Q.x);
}
#line 172
float3 RGBToHSL(float3 RGB)
{
float3 HCV = RGBToHCV(RGB);
float L = HCV.z - HCV.y * 0.5;
float S = HCV.y / (1 - abs(L * 2 - 1) + 1e-10);
return float3(HCV.x, S, L);
}
#line 272
float3 HUEToRGB(float H)
{
float R = abs(H * 6 - 3) - 1;
float G = 2 - abs(H * 6 - 2);
float B = 2 - abs(H * 6 - 4);
#line 278
return saturate(float3(R,G,B));
}
#line 282
float3 HSLToRGB(float3 HSL)
{
float3 RGB = HUEToRGB(HSL.x);
float  C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
return (RGB - 0.5) * C + HSL.z;
}
#line 290
float RGBCVtoHUE(float3 RGB, float C, float V)
{
float3 Delta = (V - RGB) / C;
Delta.rgb -= Delta.brg;
Delta.rgb += float3(2,4,6);
#line 297
Delta.brg = step(V, RGB) * Delta.brg;
float H;
#line 300
H = max(Delta.r, max(Delta.g, Delta.b));
#line 302
return frac(H / 6);
}
#line 305
float3 RGBToHSV(float3 RGB)
{
float3 HSV = 0;
HSV.z = max(RGB.r, max(RGB.g, RGB.b));
#line 310
float M = min(RGB.r, min(RGB.g, RGB.b));
float C = HSV.z - M;
#line 313
if (C != 0)
{
HSV.x = RGBCVtoHUE(RGB, C, HSV.z);
HSV.y = C / HSV.z;
}
#line 319
return HSV;
}
#line 323
float3 HSVToRGB(float3 HSV)
{
float3 RGB = HUEToRGB(HSV.x);
#line 327
return ((RGB - 1) * HSV.y + 1) * HSV.z;
}
#line 330
float3 ColorTemperatureToRGB(float temperatureInKelvins)
{
float3 retColor;
#line 334
temperatureInKelvins = clamp(temperatureInKelvins, 1000.0, 40000.0) / 100.0;
#line 336
if (temperatureInKelvins <= 66.0)
{
retColor.r = 1.0;
retColor.g = clamp(0.39008157876901960784 * log(temperatureInKelvins) - 0.63184144378862745098, 0.0, 30000.0);
}
#line 342
else
{
float t = temperatureInKelvins - 60.0;
retColor.r = clamp(1.29293618606274509804 * pow(abs(t), -0.1332047592), 0.0, 30000.0);
retColor.g = clamp(1.12989086089529411765 * pow(abs(t), -0.0755148492), 0.0, 30000.0);
}
#line 349
if (temperatureInKelvins >= 66.0)
{
retColor.b = 1.0;
}
#line 354
else if (temperatureInKelvins <= 19.0)
{
retColor.b = 0.0;
}
#line 359
else
{
retColor.b = clamp(0.54320678911019607843 * log(temperatureInKelvins - 10.0) - 1.19625408914, 0.0, 30000.0);
}
#line 364
return retColor;
}
#line 367
float3 Kelvin(float3 color, float kelvin)
{
float3 ktemp, result, hsl, lumablend;
float luma;
#line 372
ktemp     = ColorTemperatureToRGB(kelvin);
#line 374
luma      = dot(color, float3(0.212395, 0.701049, 0.086556));
#line 376
result    = color * ktemp;
#line 378
hsl       = RGBToHSL(result);
lumablend = HSLToRGB(float3(hsl.x, hsl.y, luma));
#line 381
return lerp(result, lumablend, 0.75);
}
#line 384
float3 WhiteBalance(float3 color, float scene, float cam)
{
float luma;
#line 389
luma   = dot(color, float3(0.212395, 0.701049, 0.086556));
#line 392
color /= ColorTemperatureToRGB(cam); 
#line 395
color *= ColorTemperatureToRGB(scene); 
color /= dot(color, float3(0.212395, 0.701049, 0.086556)); 
color *= luma; 
#line 399
return color;
}
#line 404
float3 NMToRGB(int nm)
{
float  atten;
float3 color;
#line 409
if      ((nm >= 380) && (nm <= 440))
{
atten   = 0.3 + 0.7 * (nm - 380) / (440 - 380);
color.r = pow((-(nm - 440) / (440 - 380)) * atten, 0.8);
color.g = 0.0;
color.b = pow(1.0 * atten, 0.8);
}
#line 417
else if ((nm >= 440) && (nm <= 490))
{
color.r = 0.0;
color.g = pow((nm - 440) / (490 - 440), 0.8);
color.b = 1.0;
}
#line 424
else if ((nm >= 490) && (nm <= 510))
{
color.r = 0.0;
color.g = 1.0;
color.b = pow(-(nm - 510) / (510 - 490), 0.8);
}
#line 431
else if ((nm >= 510) && (nm <= 580))
{
color.r = pow((nm - 510) / (580 - 510), 0.8);
color.g = 1.0;
color.b = 0.0;
}
#line 438
else if ((nm >= 580) && (nm <= 645))
{
color.r = 1.0;
color.g = pow(-(nm - 645) / (645 - 580), 0.8);
color.b = 0.0;
}
#line 445
else if ((nm >= 645) && (nm <= 750))
{
atten   = 0.3 + 0.7 * (750 - nm) / (750 - 645);
color.r = pow(1.0 * atten, 0.8);
color.g = 0.0;
color.b = 0.0;
}
#line 453
else
{
color = 0.0;
}
#line 458
return color;
}
#line 461
float ScotopicLuma(float3 color)
{
float3x3 RGBToXYZ = float3x3
(
0.5149, 0.3244, 0.1607,
0.3654, 0.6704, 0.0642,
0.0248, 0.1248, 0.8504
);
#line 470
color = mul(RGBToXYZ, color);
#line 472
return color.y * (1.33 * (1.0 + ((color.y + color.z) / color.x)) - 1.68);
}
#line 475
float3 PurkinjeEffect(float3 color, float blend)
{
#line 478
return lerp(color, ScotopicLuma(color) * lerp(0.5, (NMToRGB(475) * 0.5), 0.25), blend);
}
#line 482
float DepthEdges(float2 uv)
{
float2 loc;
float  edge_depth;
int    id;
#line 488
int gweights[9] =
{
1,   2,  1,
2, -12,  2,
1,   2,  1
};
#line 495
edge_depth = 0;
#line 497
for(int x = -1; x <= 1; x++)
{
for(int y = -1; y <= 1; y++)
{
loc         = float2(x, y) * (float2((1.0 / float2(1920, 1018).x), (1.0 / float2(1920, 1018).x) * (1920 * (1.0 / 1018))));
id          = (x + 1) + (y + 1) * 3;
edge_depth += pow(smoothstep(0.0, 0.5, ReShade::GetLinearizedDepth(uv + loc)), 0.25) * gweights[id];
}
}
#line 507
return saturate(1-abs(edge_depth) * 40.0);
}
#line 511
float4 tex2Dbicub(sampler texSampler, float2 coord)
{
float2 texsize = float2(1920, 1018);
#line 515
float4 uv;
uv.xy = coord * texsize;
#line 519
float2 center  = floor(uv.xy - 0.5) + 0.5;
float2 dist1st = uv.xy - center;
float2 dist2nd = dist1st * dist1st;
float2 dist3rd = dist2nd * dist1st;
#line 525
float2 weight0 =     -dist3rd + 3 * dist2nd - 3 * dist1st + 1;
float2 weight1 =  3 * dist3rd - 6 * dist2nd               + 4;
float2 weight2 = -3 * dist3rd + 3 * dist2nd + 3 * dist1st + 1;
float2 weight3 =      dist3rd;
#line 530
weight0 += weight1;
weight2 += weight3;
#line 534
uv.xy  = center - 1 + weight1 / weight0;
uv.zw  = center + 1 + weight3 / weight2;
uv    /= texsize.xyxy;
#line 539
return (weight0.y * (tex2D(texSampler, uv.xy) * weight0.x + tex2D(texSampler, uv.zy) * weight2.x) +
weight2.y * (tex2D(texSampler, uv.xw) * weight0.x + tex2D(texSampler, uv.zw) * weight2.x)) / 36;
}
#line 543
float4 tex2Dbicub2(sampler texSampler, float2 coord, float2 inscale)
{
float2 texsize = int2(1920 * inscale.x, 1018 * inscale.y);
#line 547
float4 uv;
uv.xy = coord * texsize;
#line 551
float2 center  = floor(uv.xy - 0.5) + 0.5;
float2 dist1st = uv.xy - center;
float2 dist2nd = dist1st * dist1st;
float2 dist3rd = dist2nd * dist1st;
#line 557
float2 weight0 =     -dist3rd + 3 * dist2nd - 3 * dist1st + 1;
float2 weight1 =  3 * dist3rd - 6 * dist2nd               + 4;
float2 weight2 = -3 * dist3rd + 3 * dist2nd + 3 * dist1st + 1;
float2 weight3 =      dist3rd;
#line 562
weight0 += weight1;
weight2 += weight3;
#line 566
uv.xy  = center - 1 + weight1 / weight0;
uv.zw  = center + 1 + weight3 / weight2;
uv    /= texsize.xyxy;
#line 571
return (weight0.y * (tex2D(texSampler, uv.xy) * weight0.x + tex2D(texSampler, uv.zy) * weight2.x) +
weight2.y * (tex2D(texSampler, uv.xw) * weight0.x + tex2D(texSampler, uv.zw) * weight2.x)) / 36;
}
#line 578
texture BACKBUFFER               : COLOR;
texture DEPTHBUFFER              : DEPTH;
sampler TextureColor             { Texture = BACKBUFFER;  AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };
sampler TextureColorMirror       { Texture = BACKBUFFER;  AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR; };
#line 586
void VS_Tri(in uint id : SV_VertexID, out float4 vpos : SV_Position, out float2 uv : TEXCOORD)
{
uv.x = (id == 2) ? 2.0 : 0.0;
uv.y = (id == 1) ? 2.0 : 0.0;
vpos = float4(uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\ATMOSPHERE.fx"
#line 46
uniform int DISTANCE < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""Fog Physical Properties""\n\n"; ui_label = " ""Density"; ui_tooltip = "Determines the apparent thickness of the fog."; ui_min = 1; ui_max = 100; > = 75;
#line 48
uniform int HIGHLIGHT_DIST < ui_type = "slider"; ui_spacing = 1; ui_category = "\n""Fog Physical Properties""\n\n"; ui_label = " ""Highlight Distance"; ui_tooltip = "Controls how far into the fog that highlights can penetrate."; ui_min = 0; ui_max = 100; > = 100;
#line 50
uniform float3 FOG_TINT < ui_type = "color"; ui_spacing = 5; ui_category = "\n""Fog Physical Properties""\n\n"; ui_label = " ""Fog Color"; ui_tooltip = ""; > = float3(0.4, 0.45, 0.5);
#line 63
uniform int AUTO_COLOR < ui_type = "combo"; ui_spacing = 1; ui_category = "\n""Fog Physical Properties""\n\n"; ui_label = " ""Fog Color Mode"; ui_items =
"Exact Fog Color\0"
"Preserve Scene Luminance\0"
#line 54
"Use Blurred Scene Luminance\0"; ui_tooltip = ""; > = 2;
uniform int WIDTH < ui_type = "slider"; ui_spacing = 1; ui_category = "\n""Fog Physical Properties""\n\n"; ui_label = " ""Light Scattering"; ui_tooltip = "Controls width of light glow. Needs blurred scene luminance enabled."; ui_min = 0; ui_max = 100; > = 50;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/Functions/AVGen.fxh"
#line 64
namespace avGen {
#line 69
texture texOrig : COLOR;
texture texLod {
Width  = ((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1); Height = ((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1);
MipLevels =
( ((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1) >  ((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) * ( (((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xAAAAAAAA) != 0) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xFFFF0000) != 0) << 4) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xFF00FF00) != 0) << 3) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xF0F0F0F0) != 0) << 2) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xCCCCCCCC) != 0) << 1)) +
( ((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1) >= ((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) * ( (((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xAAAAAAAA) != 0) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xFFFF0000) != 0) << 4) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xFF00FF00) != 0) << 3) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xF0F0F0F0) != 0) << 2) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xCCCCCCCC) != 0) << 1)) - 1 ;
Format = RGB10A2;
};
texture texDepthLod {
Width  = ((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1); Height = ((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1);
MipLevels =
( ((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1) >  ((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) * ( (((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xAAAAAAAA) != 0) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xFFFF0000) != 0) << 4) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xFF00FF00) != 0) << 3) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xF0F0F0F0) != 0) << 2) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xCCCCCCCC) != 0) << 1)) +
( ((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1) >= ((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) * ( (((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xAAAAAAAA) != 0) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xFFFF0000) != 0) << 4) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xFF00FF00) != 0) << 3) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xF0F0F0F0) != 0) << 2) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xCCCCCCCC) != 0) << 1)) - 1 ;
Format = R16F;
};
#line 85
sampler sampOrig      { Texture = texOrig; };
sampler sampLod       { Texture = texLod; };
sampler sampDepthLod  { Texture = texDepthLod; };
#line 89
float3 get() {
float3 res    = 0;
int2   lvl    = int2(( (((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xAAAAAAAA) != 0) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xFFFF0000) != 0) << 4) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xFF00FF00) != 0) << 3) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xF0F0F0F0) != 0) << 2) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xCCCCCCCC) != 0) << 1)), ( (((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xAAAAAAAA) != 0) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xFFFF0000) != 0) << 4) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xFF00FF00) != 0) << 3) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xF0F0F0F0) != 0) << 2) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xCCCCCCCC) != 0) << 1)));
float4 stp    = 0;
stp.xy = 0.5 / float2(1 << max(lvl.xy-lvl.yx,0));
stp.zw = stp.x > stp.y ? stp.zy : stp.xw;
lvl    = int2(min(lvl.x, lvl.y)-1, 1 << abs(lvl.x-lvl.y) );
#line 97
[unroll]
for(int i=0; i < lvl.y; i++)
res += tex2Dlod(sampLod, float4(stp.xy + stp.zw*2*i,0,lvl.x)).rgb;
#line 101
return res/(float)lvl.y;
}
float getDepth() {
float  res    = 0;
int2   lvl    = int2(( (((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xAAAAAAAA) != 0) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xFFFF0000) != 0) << 4) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xFF00FF00) != 0) << 3) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xF0F0F0F0) != 0) << 2) | ((((((( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) | ( ( ( (1920) | ( (1920) >> 1) ) | ( ( (1920) | ( (1920) >> 1) ) >> 2) ) >> 4) ) >> 8) ) >>1)+1)) & 0xCCCCCCCC) != 0) << 1)), ( (((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xAAAAAAAA) != 0) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xFFFF0000) != 0) << 4) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xFF00FF00) != 0) << 3) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xF0F0F0F0) != 0) << 2) | ((((((( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) | ( ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) | ( ( ( (1018) | ( (1018) >> 1) ) | ( ( (1018) | ( (1018) >> 1) ) >> 2) ) >> 4) ) >> 8) )>>1)+1)) & 0xCCCCCCCC) != 0) << 1)));
float4 stp    = 0;
stp.xy = 0.5 / float2(1 << max(lvl.xy-lvl.yx,0));
stp.zw = stp.x > stp.y ? stp.zy : stp.xw;
lvl    = int2(min(lvl.x, lvl.y)-1, 1 << abs(lvl.x-lvl.y) );
#line 111
[unroll]
for(int i=0; i < lvl.y; i++)
res += tex2Dlod(sampDepthLod, float4(stp.xy + stp.zw*2*i,0,lvl.x)).x;
#line 115
return res/(float)lvl.y;
}
float3 getLog() {
return exp2(get());
}
float4 vs_main( uint vid : SV_VertexID, out float2 uv : TEXCOORD0 ) : SV_Position {
uv = (vid.xx == uint2(2,1))?(float2)2:0;
return float4(uv.x*2.-1.,1.-uv.y*2.,0,1);
}
float4 ps_main( float4 pos: SV_Position, float2 uv: TEXCOORD0 ) : SV_Target {
return tex2D(sampOrig, uv); 
}
float4 ps_main_log( float4 pos: SV_Position, float2 uv: TEXCOORD0 ) : SV_Target {
return log2(tex2D(sampOrig, uv)); 
}
float ps_depth( float4 pos: SV_Position, float2 uv: TEXCOORD0 ) : SV_Target {
return ReShade::GetLinearizedDepth(uv); 
}
} 
#line 73 "C:\Program Files\GShade\gshade-shaders\Shaders\ATMOSPHERE.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/Functions/BlendingModes.fxh"
#line 8
float BlendOverlay(float base, float blend)
{
return lerp((2.0 * base * blend),
(1.0 - 2.0 * (1.0 - base) * (1.0 - blend)),
step(blend, 0.5));
}
#line 15
float3 BlendOverlay(float3 base, float3 blend)
{
return lerp((2.0 * base * blend),
(1.0 - 2.0 * (1.0 - base) * (1.0 - blend)),
step(blend, 0.5));
}
#line 25
float BlendSoftLight(float base, float blend)
{
return lerp((2.0 * base * blend + base * base * (1.0 - 2.0 * blend)),
(sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)),
step(blend, 0.5));
}
#line 32
float3 BlendSoftLight(float3 base, float3 blend)
{
return lerp((2.0 * base * blend + base * base * (1.0 - 2.0 * blend)),
(sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)),
step(blend, 0.5));
}
#line 42
float BlendHardLight(float base, float blend)
{
return (blend <= 0.5) ? 2*base*blend : 1 - 2*(1-base)*(1-blend);
}
#line 47
float3 BlendHardLight(float3 base, float3 blend)
{
return float3(BlendHardLight(base.r, blend.r),
BlendHardLight(base.g, blend.g),
BlendHardLight(base.b, blend.b));
}
#line 56
float BlendAdd(float base, float blend)
{
return min(base + blend, 1.0);
}
#line 61
float3 BlendAdd(float3 base, float3 blend)
{
return min(base + blend, 1.0);
}
#line 69
float BlendSubtract(float base, float blend)
{
return max(base + blend - 1.0, 0.0);
}
#line 74
float3 BlendSubtract(float3 base, float3 blend)
{
return max(base + blend - 1.0, 0.0);
}
#line 82
float BlendLinearDodge(float base, float blend)
{
return BlendAdd(base, blend);
}
#line 87
float3 BlendLinearDodge(float3 base, float3 blend)
{
return BlendAdd(base, blend);
}
#line 95
float BlendLinearBurn(float base, float blend)
{
return BlendSubtract(base, blend);
}
#line 100
float3 BlendLinearBurn(float3 base, float3 blend)
{
return BlendSubtract(base, blend);
}
#line 108
float BlendLighten(float base, float blend)
{
return max(blend, base);
}
#line 113
float3 BlendLighten(float3 base, float3 blend)
{
return max(blend, base);
}
#line 121
float BlendDarken(float base, float blend)
{
return min(blend, base);
}
#line 126
float3 BlendDarken(float3 base, float3 blend)
{
return min(blend, base);
}
#line 134
float BlendLinearLight(float base, float blend)
{
return lerp(BlendLinearBurn(base, (2.0 *  blend)),
BlendLinearDodge(base, (2.0 * (blend - 0.5))),
step(blend, 0.5));
}
#line 141
float3 BlendLinearLight(float3 base, float3 blend)
{
return lerp(BlendLinearBurn(base, (2.0 *  blend)),
BlendLinearDodge(base, (2.0 * (blend - 0.5))),
step(blend, 0.5));
}
#line 151
float BlendScreen(float base, float blend)
{
return 1.0 - ((1.0 - base) * (1.0 - blend));
}
#line 156
float3 BlendScreen(float3 base, float3 blend)
{
return 1.0 - ((1.0 - base) * (1.0 - blend));
}
#line 164
float BlendScreenHDR(float base, float blend)
{
return base + (blend / (1 + base));
}
#line 169
float3 BlendScreenHDR(float3 base, float3 blend)
{
return base + (blend / (1 + base));
}
#line 177
float BlendColorDodge(float base, float blend)
{
return lerp(blend, min(base / (1.0 - blend), 1.0), (blend == 1.0));
}
#line 182
float3 BlendColorDodge(float3 base, float3 blend)
{
return lerp(blend, min(base / (1.0 - blend), 1.0), (blend == 1.0));
}
#line 190
float BlendColorBurn(float base, float blend)
{
return lerp(blend, max((1.0 - ((1.0 - base) / blend)), 0.0), (blend == 0.0));
}
#line 195
float3 BlendColorBurn(float3 base, float3 blend)
{
return lerp(blend, max((1.0 - ((1.0 - base) / blend)), 0.0), (blend == 0.0));
}
#line 203
float BlendVividLight(float base, float blend)
{
return lerp(BlendColorBurn (base, (2.0 *  blend)),
BlendColorDodge(base, (2.0 * (blend - 0.5))),
step(blend, 0.5));
}
#line 210
float3 BlendVividLight(float3 base, float3 blend)
{
return lerp(BlendColorBurn (base, (2.0 *  blend)),
BlendColorDodge(base, (2.0 * (blend - 0.5))),
step(blend, 0.5));
}
#line 220
float BlendPinLight(float base, float blend)
{
return lerp(BlendDarken (base, (2.0 *  blend)),
BlendLighten(base, (2.0 * (blend - 0.5))),
step(blend, 0.5));
}
#line 227
float3 BlendPinLight(float3 base, float3 blend)
{
return lerp(BlendDarken (base, (2.0 *  blend)),
BlendLighten(base, (2.0 * (blend - 0.5))),
step(blend, 0.5));
}
#line 237
float BlendHardMix(float base, float blend)
{
return lerp(0.0, 1.0, step(BlendVividLight(base, blend), 0.5));
}
#line 242
float3 BlendHardMix(float3 base, float3 blend)
{
return lerp(0.0, 1.0, step(BlendVividLight(base, blend), 0.5));
}
#line 250
float BlendReflect(float base, float blend)
{
return lerp(blend, min(base * base / (1.0 - blend), 1.0), (blend == 1.0));
}
#line 255
float3 BlendReflect(float3 base, float3 blend)
{
return lerp(blend, min(base * base / (1.0 - blend), 1.0), (blend == 1.0));
}
#line 263
float BlendAverage(float base, float blend)
{
return (base + blend) / 2.0;
}
#line 268
float3 BlendAverage(float3 base, float3 blend)
{
return (base + blend) / 2.0;
}
#line 276
float BlendDifference(float base, float blend)
{
return abs(base - blend);
}
#line 281
float3 BlendDifference(float3 base, float3 blend)
{
return abs(base - blend);
}
#line 289
float BlendNegation(float base, float blend)
{
return 1.0 - abs(1.0 - base - blend);
}
#line 294
float3 BlendNegation(float3 base, float3 blend)
{
return 1.0 - abs(1.0 - base - blend);
}
#line 302
float BlendExclusion(float base, float blend)
{
return base + blend - 2.0 * base * blend;
}
#line 307
float3 BlendExclusion(float3 base, float3 blend)
{
return base + blend - 2.0 * base * blend;
}
#line 315
float BlendGlow(float base, float blend)
{
return BlendReflect(blend, base);
}
#line 320
float3 BlendGlow(float3 base, float3 blend)
{
return BlendReflect(blend, base);
}
#line 328
float BlendPhoenix(float base, float blend)
{
return min(base, blend) - max(base, blend) + 1.0;
}
#line 333
float3 BlendPhoenix(float3 base, float3 blend)
{
return min(base, blend) - max(base, blend) + 1.0;
}
#line 74 "C:\Program Files\GShade\gshade-shaders\Shaders\ATMOSPHERE.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/Functions/TriDither.fxh"
#line 31
uniform float DitherTimer < source = "timer"; >;
#line 34
float rand21(float2 uv)
{
float2 noise = frac(sin(dot(uv, float2(12.9898, 78.233) * 2.0)) * 43758.5453);
return (noise.x + noise.y) * 0.5;
}
#line 40
float rand11(float x)
{
return frac(x * 0.024390243);
}
#line 45
float permute(float x)
{
return ((34.0 * x + 1.0) * x) % 289.0;
}
#line 50
float3 TriDither(float3 color, float2 uv, int bits)
{
float bitstep = exp2(bits) - 1.0;
float lsb = 1.0 / bitstep;
float lobit = 0.5 / bitstep;
float hibit = (bitstep - 0.5) / bitstep;
#line 57
float3 m = float3(uv, rand21(uv + (DitherTimer * 0.001))) + 1.0;
float h = permute(permute(permute(m.x) + m.y) + m.z);
#line 60
float3 noise1, noise2;
noise1.x = rand11(h); h = permute(h);
noise2.x = rand11(h); h = permute(h);
noise1.y = rand11(h); h = permute(h);
noise2.y = rand11(h); h = permute(h);
noise1.z = rand11(h); h = permute(h);
noise2.z = rand11(h);
#line 68
float3 lo = saturate((((color.xyz) - (0.0)) / ((lobit) - (0.0))));
float3 hi = saturate((((color.xyz) - (1.0)) / ((hibit) - (1.0))));
float3 uni = noise1 - 0.5;
float3 tri = noise1 - noise2;
return lerp(uni, tri, min(lo, hi)) * lsb;
}
#line 75 "C:\Program Files\GShade\gshade-shaders\Shaders\ATMOSPHERE.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/Functions/GaussianBlurBounds.fxh"
float3 AtlasBlurH (float3 color, sampler SamplerColor, float2 coord)
{
float weight[25] =
{
0.03466328834561044,
0.034543051433222484,
0.0341852539511399,
0.033597253107481094,
0.03279100448992231,
0.031782736261255995,
0.030592386782017884,
0.029242937328683466,
0.027759668708179856,
0.026169373490628617,
0.024499556655159425,
0.02277765667455162,
0.021030316584527704,
0.019282730633218392,
0.017558087011933985,
0.01587712131274775,
0.014257789148914941,
0.01271506021108285,
0.011260830280013286,
0.009903942680156272,
0.008650306566931923,
0.007503096437824797,
0.006463015400665202,
0.005528603997864302,
0.004696576679070732
};
#line 32
color *= weight[0];
#line 34
[loop]
for(int i = 1; i < 25; ++i)
{
color.rgb += tex2D(SamplerColor, coord + float2(i * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0)).rgb * weight[i];
color.rgb += tex2D(SamplerColor, coord - float2(i * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0)).rgb * weight[i];
}
#line 41
return float4(color.rgb, 1);
}
#line 44
float3 AtlasBlurV (float3 color, sampler SamplerColor, float2 coord)
{
float weight[25] =
{
0.03466328834561044,
0.034543051433222484,
0.0341852539511399,
0.033597253107481094,
0.03279100448992231,
0.031782736261255995,
0.030592386782017884,
0.029242937328683466,
0.027759668708179856,
0.026169373490628617,
0.024499556655159425,
0.02277765667455162,
0.021030316584527704,
0.019282730633218392,
0.017558087011933985,
0.01587712131274775,
0.014257789148914941,
0.01271506021108285,
0.011260830280013286,
0.009903942680156272,
0.008650306566931923,
0.007503096437824797,
0.006463015400665202,
0.005528603997864302,
0.004696576679070732
};
#line 75
color *= weight[0];
#line 77
[loop]
for(int i = 1; i < 25; ++i)
{
color.rgb += tex2D(SamplerColor, coord + float2(0.0, i * float2((1.0 / 1920), (1.0 / 1018)).y)).rgb * weight[i];
color.rgb += tex2D(SamplerColor, coord - float2(0.0, i * float2((1.0 / 1920), (1.0 / 1018)).y)).rgb * weight[i];
}
#line 84
return float4(color.rgb, 1);
}
#line 87
float4 AtlasBlurH (float4 color, sampler SamplerColor, float2 coord)
{
float weight[18] =
{
0.033245,     0.0659162217, 0.0636705814,
0.0598194658, 0.0546642566, 0.0485871646,
0.0420045997, 0.0353207015, 0.0288880982,
0.0229808311, 0.0177815511, 0.013382297,
0.0097960001, 0.0069746748, 0.0048301008,
0.0032534598, 0.0021315311, 0.0013582974
};
#line 99
color *= weight[0];
#line 101
[loop]
for(int i = 1; i < 18; ++i)
{
color += tex2D(SamplerColor, coord + float2(i * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0)) * weight[i];
color += tex2D(SamplerColor, coord - float2(i * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0)) * weight[i];
}
#line 108
return color;
}
#line 111
float4 AtlasBlurV (float4 color, sampler SamplerColor, float2 coord)
{
float weight[18] =
{
0.033245,     0.0659162217, 0.0636705814,
0.0598194658, 0.0546642566, 0.0485871646,
0.0420045997, 0.0353207015, 0.0288880982,
0.0229808311, 0.0177815511, 0.013382297,
0.0097960001, 0.0069746748, 0.0048301008,
0.0032534598, 0.0021315311, 0.0013582974
};
#line 123
color *= weight[0];
#line 125
[loop]
for(int i = 1; i < 18; ++i)
{
color += tex2D(SamplerColor, coord + float2(0.0, i * float2((1.0 / 1920), (1.0 / 1018)).y)) * weight[i];
color += tex2D(SamplerColor, coord - float2(0.0, i * float2((1.0 / 1920), (1.0 / 1018)).y)) * weight[i];
}
#line 132
return color;
}
#line 143
static const float4 BoundsDefault = float4(0.000, 1.000, 0.000, 1.000);
static const float4 BoundsMid     = float4(0.300, 0.700, 0.300, 0.700);
static const float4 BoundsHalate  = float4(0.550, 1.000, 0.550, 1.000);
#line 148
float Blur18H (float luma, sampler Samplerluma, float4 bounds, float width, float2 coord)
{
float offset[18] =
{
0.0,            1.4953705027, 3.4891992113,
5.4830312105,   7.4768683759, 9.4707125766,
11.4645656736, 13.4584295168, 15.4523059431,
17.4461967743, 19.4661974725, 21.4627427973,
23.4592916956, 25.455844494,  27.4524015179,
29.4489630909, 31.445529535,  33.4421011704
};
#line 160
float kernel[18] =
{
0.033245,     0.0659162217, 0.0636705814,
0.0598194658, 0.0546642566, 0.0485871646,
0.0420045997, 0.0353207015, 0.0288880982,
0.0229808311, 0.0177815511, 0.013382297,
0.0097960001, 0.0069746748, 0.0048301008,
0.0032534598, 0.0021315311, 0.0013582974
};
#line 170
luma *= kernel[0];
#line 172
[branch]
#line 174
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
discard;
#line 178
[loop]
for(int i = 1; i < 18; ++i)
{
#line 182
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 185
luma += tex2Dlod(Samplerluma, float4(coord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)).x * kernel[i];
luma += tex2Dlod(Samplerluma, float4(coord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)).x * kernel[i];
}
#line 189
return luma;
}
#line 192
float Blur18V (float luma, sampler Samplerluma, float4 bounds, float width, float2 coord)
{
float offset[18] =
{
0.0,            1.4953705027, 3.4891992113,
5.4830312105,   7.4768683759, 9.4707125766,
11.4645656736, 13.4584295168, 15.4523059431,
17.4461967743, 19.4661974725, 21.4627427973,
23.4592916956, 25.455844494,  27.4524015179,
29.4489630909, 31.445529535,  33.4421011704
};
#line 204
float kernel[18] =
{
0.033245,     0.0659162217, 0.0636705814,
0.0598194658, 0.0546642566, 0.0485871646,
0.0420045997, 0.0353207015, 0.0288880982,
0.0229808311, 0.0177815511, 0.013382297,
0.0097960001, 0.0069746748, 0.0048301008,
0.0032534598, 0.0021315311, 0.0013582974
};
#line 214
luma *= kernel[0];
#line 216
[branch]
#line 218
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
discard;
#line 222
[loop]
for(int i = 1; i < 18; ++i)
{
#line 226
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 229
luma += tex2Dlod(Samplerluma, float4(coord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)).a * kernel[i];
luma += tex2Dlod(Samplerluma, float4(coord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)).a * kernel[i];
}
#line 233
return luma;
}
#line 236
float3 Blur18H (float3 color, sampler SamplerColor, float width, float4 bounds, float2 coord)
{
float offset[18] =
{
0.0,            1.4953705027, 3.4891992113,
5.4830312105,   7.4768683759, 9.4707125766,
11.4645656736, 13.4584295168, 15.4523059431,
17.4461967743, 19.4661974725, 21.4627427973,
23.4592916956, 25.455844494,  27.4524015179,
29.4489630909, 31.445529535,  33.4421011704
};
#line 248
float kernel[18] =
{
0.033245,     0.0659162217, 0.0636705814,
0.0598194658, 0.0546642566, 0.0485871646,
0.0420045997, 0.0353207015, 0.0288880982,
0.0229808311, 0.0177815511, 0.013382297,
0.0097960001, 0.0069746748, 0.0048301008,
0.0032534598, 0.0021315311, 0.0013582974
};
#line 258
color *= kernel[0];
#line 260
[branch]
#line 262
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
discard;
#line 266
[loop]
for(int i = 1; i < 18; ++i)
{
#line 270
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 273
color += tex2Dlod(SamplerColor, float4(coord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)).rgb * kernel[i];
color += tex2Dlod(SamplerColor, float4(coord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)).rgb * kernel[i];
}
#line 277
return color;
}
#line 280
float3 Blur18V (float3 color, sampler SamplerColor, float width, float4 bounds, float2 coord)
{
float offset[18] =
{
0.0,            1.4953705027, 3.4891992113,
5.4830312105,   7.4768683759, 9.4707125766,
11.4645656736, 13.4584295168, 15.4523059431,
17.4461967743, 19.4661974725, 21.4627427973,
23.4592916956, 25.455844494,  27.4524015179,
29.4489630909, 31.445529535,  33.4421011704
};
#line 292
float kernel[18] =
{
0.033245,     0.0659162217, 0.0636705814,
0.0598194658, 0.0546642566, 0.0485871646,
0.0420045997, 0.0353207015, 0.0288880982,
0.0229808311, 0.0177815511, 0.013382297,
0.0097960001, 0.0069746748, 0.0048301008,
0.0032534598, 0.0021315311, 0.0013582974
};
#line 302
color *= kernel[0];
#line 304
[branch]
#line 306
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
discard;
#line 310
[loop]
for(int i = 1; i < 18; ++i)
{
#line 314
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 317
color += tex2Dlod(SamplerColor, float4(coord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)).rgb * kernel[i];
color += tex2Dlod(SamplerColor, float4(coord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)).rgb * kernel[i];
}
#line 321
return color;
}
#line 324
float4 Blur18H (float4 color, sampler SamplerColor, float width, float4 bounds, float2 coord)
{
float offset[18] =
{
0.0,            1.4953705027, 3.4891992113,
5.4830312105,   7.4768683759, 9.4707125766,
11.4645656736, 13.4584295168, 15.4523059431,
17.4461967743, 19.4661974725, 21.4627427973,
23.4592916956, 25.455844494,  27.4524015179,
29.4489630909, 31.445529535,  33.4421011704
};
#line 336
float kernel[18] =
{
0.033245,     0.0659162217, 0.0636705814,
0.0598194658, 0.0546642566, 0.0485871646,
0.0420045997, 0.0353207015, 0.0288880982,
0.0229808311, 0.0177815511, 0.013382297,
0.0097960001, 0.0069746748, 0.0048301008,
0.0032534598, 0.0021315311, 0.0013582974
};
#line 346
color *= kernel[0];
#line 348
[branch]
#line 350
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
discard;
#line 354
[loop]
for(int i = 1; i < 18; ++i)
{
#line 358
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 361
color += tex2Dlod(SamplerColor, float4(coord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)) * kernel[i];
color += tex2Dlod(SamplerColor, float4(coord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)) * kernel[i];
}
#line 365
return color;
}
#line 368
float4 Blur18V (float4 color, sampler SamplerColor, float width, float4 bounds, float2 coord)
{
float offset[18] =
{
0.0,            1.4953705027, 3.4891992113,
5.4830312105,   7.4768683759, 9.4707125766,
11.4645656736, 13.4584295168, 15.4523059431,
17.4461967743, 19.4661974725, 21.4627427973,
23.4592916956, 25.455844494,  27.4524015179,
29.4489630909, 31.445529535,  33.4421011704
};
#line 380
float kernel[18] =
{
0.033245,     0.0659162217, 0.0636705814,
0.0598194658, 0.0546642566, 0.0485871646,
0.0420045997, 0.0353207015, 0.0288880982,
0.0229808311, 0.0177815511, 0.013382297,
0.0097960001, 0.0069746748, 0.0048301008,
0.0032534598, 0.0021315311, 0.0013582974
};
#line 390
color *= kernel[0];
#line 392
[branch]
#line 394
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
discard;
#line 398
[loop]
for(int i = 1; i < 18; ++i)
{
#line 402
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 405
color += tex2Dlod(SamplerColor, float4(coord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)) * kernel[i];
color += tex2Dlod(SamplerColor, float4(coord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)) * kernel[i];
}
#line 409
return color;
}
#line 414
float Blur11H (float luma, sampler Samplerluma, float4 bounds, float width, float2 coord)
{
float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
float kernel[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 419
luma *= kernel[0];
#line 421
[branch]
#line 423
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
return luma;
#line 427
[loop]
for(int i = 1; i < 11; ++i)
{
#line 431
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 434
luma += tex2Dlod(Samplerluma, float4(coord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)).x * kernel[i];
luma += tex2Dlod(Samplerluma, float4(coord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)).x * kernel[i];
}
#line 438
return luma;
}
#line 441
float Blur11V (float luma, sampler Samplerluma, float4 bounds, float width, float2 coord)
{
float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
float kernel[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 446
luma *= kernel[0];
#line 448
[branch]
#line 450
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
return luma;
#line 454
[loop]
for(int i = 1; i < 11; ++i)
{
#line 458
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 461
luma += tex2Dlod(Samplerluma, float4(coord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)).x * kernel[i];
luma += tex2Dlod(Samplerluma, float4(coord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)).x * kernel[i];
}
#line 465
return luma;
}
#line 468
float3 Blur11H (float3 color, sampler SamplerColor, float4 bounds, float2 coord)
{
float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
float kernel[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 473
color *= kernel[0];
#line 475
[branch]
#line 477
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
return color;
#line 481
[loop]
for(int i = 1; i < 11; ++i)
{
#line 485
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 488
color += tex2Dlod(SamplerColor, float4(coord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0), 0.0, 0.0)).rgb * kernel[i];
color += tex2Dlod(SamplerColor, float4(coord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0), 0.0, 0.0)).rgb * kernel[i];
}
#line 492
return color;
}
#line 495
float3 Blur11V (float3 color, sampler SamplerColor, float4 bounds, float2 coord)
{
float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
float kernel[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 500
color *= kernel[0];
#line 502
[branch]
#line 504
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
return color;
#line 508
[loop]
for(int i = 1; i < 11; ++i)
{
#line 512
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 515
color += tex2Dlod(SamplerColor, float4(coord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y), 0.0, 0.0)).rgb * kernel[i];
color += tex2Dlod(SamplerColor, float4(coord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y), 0.0, 0.0)).rgb * kernel[i];
}
#line 519
return color;
}
#line 524
float Blur6H (float luma, sampler Samplerluma, float4 bounds, float width, float2 coord)
{
float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
float kernel[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 529
luma *= kernel[0];
#line 531
[branch]
#line 533
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
return luma;
#line 537
[loop]
for(int i = 1; i < 6; ++i)
{
#line 541
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 544
luma += tex2Dlod(Samplerluma, float4(coord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)).x * kernel[i];
luma += tex2Dlod(Samplerluma, float4(coord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)).x * kernel[i];
}
#line 548
return luma;
}
#line 551
float Blur6V (float luma, sampler Samplerluma, float4 bounds, float width, float2 coord)
{
float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
float kernel[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 556
luma *= kernel[0];
#line 558
[branch]
#line 560
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
return luma;
#line 564
[loop]
for(int i = 1; i < 6; ++i)
{
#line 568
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 571
luma += tex2Dlod(Samplerluma, float4(coord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)).x * kernel[i];
luma += tex2Dlod(Samplerluma, float4(coord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)).x * kernel[i];
}
#line 575
return luma;
}
#line 578
float3 Blur6H (float3 color, sampler SamplerColor, float4 bounds, float2 coord)
{
float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
float kernel[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 583
color *= kernel[0];
#line 585
[branch]
#line 587
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
return color;
#line 591
[loop]
for(int i = 1; i < 6; ++i)
{
#line 595
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 598
color += tex2Dlod(SamplerColor, float4(coord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0), 0.0, 0.0)).rgb * kernel[i];
color += tex2Dlod(SamplerColor, float4(coord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0), 0.0, 0.0)).rgb * kernel[i];
}
#line 602
return color;
}
#line 605
float3 Blur6V (float3 color, sampler SamplerColor, float4 bounds, float2 coord)
{
float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
float kernel[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 610
color *= kernel[0];
#line 612
[branch]
#line 614
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
return color;
#line 618
[loop]
for(int i = 1; i < 6; ++i)
{
#line 622
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 625
color += tex2Dlod(SamplerColor, float4(coord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y), 0.0, 0.0)).rgb * kernel[i];
color += tex2Dlod(SamplerColor, float4(coord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y), 0.0, 0.0)).rgb * kernel[i];
}
#line 629
return color;
}
#line 633
float HalateH (float luma, sampler Samplerluma, float width, float4 bounds, float2 coord)
{
float kernel[7] =
{
0.1736,
0.1469,
0.0983,
0.0527,
0.0224,
0.0063,
0.0010
};
#line 646
luma *= kernel[0];
#line 648
[branch]
#line 650
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
return luma;
#line 654
[loop]
for(int i = 1; i < 7; ++i)
{
#line 658
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 661
luma += tex2Dlod(Samplerluma, float4(coord + float2(i * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)).a * kernel[i];
luma += tex2Dlod(Samplerluma, float4(coord - float2(i * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * width, 0.0, 0.0)).a * kernel[i];
}
#line 665
return luma;
}
#line 668
float HalateV (float luma, sampler Samplerluma, float width, float4 bounds, float2 coord)
{
float kernel[7] =
{
0.1736,
0.1469,
0.0983,
0.0527,
0.0224,
0.0063,
0.0010
};
#line 681
luma *= kernel[0];
#line 683
[branch]
#line 685
if ((coord.x > bounds.y || coord.x < bounds.x  ||
coord.y > bounds.w || coord.y < bounds.z))
return luma;
#line 689
[loop]
for(int i = 1; i < 7; ++i)
{
#line 693
if (((coord.x + i * float2((1.0 / 1920), (1.0 / 1018)).x) > bounds.y  ||
(coord.x - i * float2((1.0 / 1920), (1.0 / 1018)).x) < bounds.x)) continue;
#line 696
luma += tex2Dlod(Samplerluma, float4(coord + float2(0.0, i * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)).a * kernel[i];
luma += tex2Dlod(Samplerluma, float4(coord - float2(0.0, i * float2((1.0 / 1920), (1.0 / 1018)).y) * width, 0.0, 0.0)).a * kernel[i];
}
#line 700
return luma;
}
#line 704
float ColorEdgeH (float luma, sampler Samplerluma, float2 coord)
{
float kernel[4] =
{
0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842
};
#line 711
luma *= kernel[0];
#line 713
[loop]
for(int i = 1; i < 4; ++i)
{
luma += dot(tex2Dlod(Samplerluma, float4(coord + float2(i * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0), 0.0, 0.0)).rgb, float3(0.212395, 0.701049, 0.086556)) * kernel[i];
luma += dot(tex2Dlod(Samplerluma, float4(coord - float2(i * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0), 0.0, 0.0)).rgb, float3(0.212395, 0.701049, 0.086556)) * kernel[i];
}
#line 720
return luma;
}
#line 723
float ColorEdgeV (float luma, sampler Samplerluma, float2 coord)
{
float orig, blend;
#line 727
orig = dot(tex2D(Samplerluma, coord).rgb, float3(0.212395, 0.701049, 0.086556));
#line 729
float kernel[4] =
{
0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842
};
#line 734
luma *= kernel[0];
#line 736
[loop]
for(int i = 1; i < 4; ++i)
{
luma += tex2Dlod(Samplerluma, float4(coord + float2(0.0, i * float2((1.0 / 1920), (1.0 / 1018)).y), 0.0, 0.0)).a * kernel[i];
luma += tex2Dlod(Samplerluma, float4(coord - float2(0.0, i * float2((1.0 / 1920), (1.0 / 1018)).y), 0.0, 0.0)).a * kernel[i];
}
#line 745
luma = BlendDifference(orig, luma);
luma = step(0.775, pow(luma, 0.1));
#line 748
return 1-luma;
}
#line 76 "C:\Program Files\GShade\gshade-shaders\Shaders\ATMOSPHERE.fx"
#line 88
texture RT_Copy { Width = 1920; Height = 1018; Format = RGBA8; }; sampler TextureCopy { Texture = RT_Copy; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
texture RT_Blur1 { Width = 1920; Height = 1018; Format = RGBA16F; }; sampler TextureBlur1 { Texture = RT_Blur1; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
texture RT_Blur2 { Width = 1920; Height = 1018; Format = RGBA16F; }; sampler TextureBlur2 { Texture = RT_Blur2; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
#line 97
void PS_Copy(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 color : SV_Target)
{
color  = tex2D(TextureColor, coord).rgb;
}
#line 104
void PS_PrepLuma(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 luma : SV_Target)
{
float depth, sky;
luma  = tex2D(TextureColor, coord).rgb;
depth = ReShade::GetLinearizedDepth(coord);
sky   = all(1-depth);
#line 112
luma  = lerp(luma, pow(abs(luma), lerp(2.0, 4.0, pow(DISTANCE * 0.01, 0.125))), depth * sky);
#line 115
luma  = dot(luma, float3(0.212395, 0.701049, 0.086556));
#line 120
}
#line 123
void PS_Prep(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 color : SV_Target)
{
float depth, sky, width, luma;
float3 tint, orig;
color  = tex2D(TextureColor, coord).rgb;
#line 129
if (AUTO_COLOR > 1)
{
#line 135
luma  = tex2Dbicub(TextureBlur1, (coord - 0.5) / 8.0 + 0.5).rgb;
#line 137
}
else
{
#line 141
luma  = tex2D(TextureBlur1, coord).xxx;
}
#line 144
depth  = ReShade::GetLinearizedDepth(coord);
sky    = all(1-depth);
#line 148
depth  = pow(abs(depth), lerp(10.0, 0.25, pow(DISTANCE * 0.01, 0.125)));
#line 151
color  = lerp(color, pow(abs(color), lerp(2.0, 4.0, pow(DISTANCE * 0.01, 0.125))), depth * sky);
#line 154
color  = lerp(color, lerp(dot(color, float3(0.212395, 0.701049, 0.086556)), color, lerp(0.75, 1.0, (AUTO_COLOR != 0))), depth);
#line 157
tint   = FOG_TINT;
#line 160
if (AUTO_COLOR > 0)
{
#line 163
if (AUTO_COLOR > 1)
{
#line 166
width  = sin(3.1415927 * 0.5 * luma);
width *= width;
luma   = lerp(luma, width, lerp(1.0, -1.0, WIDTH * 0.01));
}
#line 171
tint = tint - dot(tint, 0.3333); 
tint = tint + luma;         
}
#line 177
color  = lerp(color, lerp(tint + 0.125, tint, tint), depth * (1-smoothstep(0.0, 1.0, color) * (smoothstep(1.0, lerp(0.5, lerp(1.0, 0.75, pow(DISTANCE * 0.01, 0.125)), HIGHLIGHT_DIST * 0.01), depth))));
#line 184
}
#line 189
void PS_Downscale1(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 luma : SV_Target)
{
#line 192
if (AUTO_COLOR > 1)
{
#line 198
luma = tex2D(TextureColor, (coord - 0.5) / 0.125 + 0.5).rgb;
#line 200
}
else
{
#line 204
luma = tex2D(TextureColor, coord).rgb;
}
}
#line 209
void PS_Downscale2(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 color : SV_Target)
{
#line 212
color  = tex2D(TextureColor, (coord - 0.5) / 0.5 + 0.5).rgb;
}
#line 216
void PS_Downscale3(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 color : SV_Target)
{
#line 222
color = tex2D(TextureColor, (coord - 0.5) / 0.125 + 0.5).rgb;
#line 224
}
#line 229
void PS_LumaBlurH(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 luma : SV_Target)
{
luma = tex2D(TextureBlur1, coord).x;
#line 233
if (AUTO_COLOR > 1)
{
luma  = Blur18H(luma, TextureBlur1, BoundsDefault, 1.0, coord).xxx;
}
}
#line 239
void PS_LumaBlurV(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 luma : SV_Target)
{
luma  = tex2D(TextureBlur2, coord).x;
#line 243
if (AUTO_COLOR > 1)
{
luma = Blur18V(luma, TextureBlur2, BoundsDefault, 1.0, coord).xxx;
}
}
#line 250
void PS_BlurH(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 color : SV_Target)
{
color  = tex2D(TextureBlur1, coord).rgb;
color  = Blur18H(color, TextureBlur1, 1.0, BoundsDefault, coord);
}
#line 256
void PS_BlurV(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 color : SV_Target)
{
color  = tex2D(TextureBlur2, coord).rgb;
color  = Blur18V(color, TextureBlur2, 1.0, BoundsDefault, coord);
}
#line 264
void PS_UpScale(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 color : SV_Target)
{
#line 267
color  = tex2Dbicub(TextureBlur1, (coord - 0.5) / 2.0 + 0.5).rgb;
}
#line 271
void PS_Combine(float4 vpos : SV_Position, float2 coord : TEXCOORD, out float3 color : SV_Target)
{
float3 orig, blur, blur2, tint;
float  depth, depth_avg, sky;
#line 279
blur  = tex2Dbicub(TextureBlur1, (coord - 0.5) / 8.0 + 0.5).rgb;
#line 282
blur2     = tex2D(TextureColor, coord).rgb;
color     = tex2D(TextureCopy,  coord).rgb;
depth     = ReShade::GetLinearizedDepth(coord);
sky       = all(1-depth);
depth_avg = avGen::get().x;
orig      = color;
#line 294
depth     = pow(abs(depth), lerp(10.0, 0.33, pow(DISTANCE * 0.01, 0.125)));
#line 297
color     = lerp(color, blur2, depth);
#line 301
if (AUTO_COLOR < 1)
{
color = lerp(color, lerp(color * pow(abs(blur), 10.0), color, color), depth * saturate(1-dot(color * 0.75, float3(0.212395, 0.701049, 0.086556))) * sky);
}
#line 308
color     = lerp(color, pow(abs(blur), lerp(0.75, 1.0, (AUTO_COLOR != 0))), depth * saturate(1-dot(color * 0.75, float3(0.212395, 0.701049, 0.086556))));
#line 314
color     = lerp(color, ((color * 0.5) + pow(abs(blur * 2.0), 0.75)) * 0.5, depth);
#line 317
color    += TriDither(color, coord, 8);
#line 322
}
#line 375
technique ATMOSPHERE < ui_label = "ATMOSPHERE"; ui_tooltip = ""; > {
#line 378
pass { VertexShader = VS_Tri; PixelShader = PS_Copy; RenderTarget = RT_Copy; }
#line 381
pass { VertexShader = VS_Tri; PixelShader = PS_PrepLuma; RenderTarget = RT_Blur2; }
pass { VertexShader = VS_Tri; PixelShader = PS_Downscale1; RenderTarget = RT_Blur1; }
pass { VertexShader = VS_Tri; PixelShader = PS_LumaBlurH; RenderTarget = RT_Blur2; }
pass { VertexShader = VS_Tri; PixelShader = PS_LumaBlurV; RenderTarget = RT_Blur1; }
#line 387
pass { VertexShader = VS_Tri; PixelShader = PS_Prep; }
#line 390
pass { VertexShader = VS_Tri; PixelShader = PS_Downscale2; RenderTarget = RT_Blur1; }
pass { VertexShader = VS_Tri; PixelShader = PS_UpScale; }
#line 394
pass { VertexShader = VS_Tri; PixelShader = PS_Downscale3; RenderTarget = RT_Blur1; }
pass { VertexShader = VS_Tri; PixelShader = PS_BlurH; RenderTarget = RT_Blur2; }
pass { VertexShader = VS_Tri; PixelShader = PS_BlurV; RenderTarget = RT_Blur1; }
#line 351
pass { VertexShader = VS_Tri; PixelShader = PS_Combine; } }             

