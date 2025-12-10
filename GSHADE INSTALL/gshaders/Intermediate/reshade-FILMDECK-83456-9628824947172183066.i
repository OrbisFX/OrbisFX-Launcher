// LET_ME_COOK=0
// FORCE_8_BIT_OUTPUT=0
// ENABLE_GRAIN_DISPLACEMENT=1
// ENABLE_HALATION=1
// SWAPCHAIN_PRECISION=2
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
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
#line 35 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/FILMDECK/Setup.fxh"
#line 60
texture TexCook < source = "SHADERDECK/LETMECOOK/ross.png"; > { Width = 1920; Height = 1018; Format = RGBA8; };
sampler TextureCook { Texture = TexCook; };
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/FILMDECK/Custom.fxh"
#line 67 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/FILMDECK/Setup.fxh"
#line 73
texture NegativeStocks < source = "SHADERDECK/LUTs/StandardNegativeAtlas.png"; > { Width  = 7056; Height = 252; };
sampler NegativeAtlas
{
Texture   = NegativeStocks;
MagFilter = LINEAR;
MinFilter = LINEAR;
MipFilter = LINEAR;
};
#line 83
texture PrintStocks < source = "SHADERDECK/LUTs/StandardPrintAtlas.png"; > { Width  = 7056; Height = 252; };
sampler PrintAtlas
{
Texture   = PrintStocks;
MagFilter = LINEAR;
MinFilter = LINEAR;
MipFilter = LINEAR;
};
#line 93
texture CustomNegativeStocks < source = "SHADERDECK/LUTs/" "CustomNegative.png"; >
{
Width     = 1024;
Height    = 32;
};
sampler CustomNegativeAtlas
{
Texture   = CustomNegativeStocks;
MagFilter = LINEAR;
MinFilter = LINEAR;
MipFilter = LINEAR;
};
#line 108
texture CustomPrintStocks < source = "SHADERDECK/LUTs/""CustomPrint.png"; >
{
Width     = 1024;
Height    = 32;
};
sampler CustomPrintAtlas
{
Texture   = CustomPrintStocks;
MagFilter = LINEAR;
MinFilter = LINEAR;
MipFilter = LINEAR;
};
#line 125
struct FilmStruct
{
float  iso;
float3 halation;
int    temp;
};
#line 132
FilmStruct Default()
{
FilmStruct film;
#line 136
film.iso        = 800;
#line 138
film.halation.x = 0.0;  
film.halation.y = 85.0; 
film.halation.z = 75.0; 
#line 142
film.temp       = 6500;
#line 144
return film;
};
#line 150
FilmStruct K5207D()
{
FilmStruct film = Default();
#line 154
film.iso        = 250;
#line 156
film.halation.x = 40.0; 
film.halation.y = 100.0; 
film.halation.z = 40.0; 
#line 160
film.temp       = 6500;
#line 162
return film;
};
#line 165
FilmStruct K5213T()
{
FilmStruct film = Default();
#line 169
film.iso        = 200;
#line 171
film.halation.x = 100.0; 
film.halation.y = 80.0; 
film.halation.z = 20.0; 
#line 175
film.temp       = 3200;
#line 177
return film;
};
#line 180
FilmStruct FR500D()
{
FilmStruct film;
#line 184
film.iso        = 500;
#line 186
film.halation.x = 0.0; 
#line 188
film.temp       = 6500;
#line 190
return film;
};
#line 196
FilmStruct K2383()
{
FilmStruct film = Default();
#line 200
return film;
};
#line 203
FilmStruct F3521()
{
FilmStruct film = Default();
#line 207
return film;
};
#line 210
FilmStruct K2302()
{
FilmStruct film = Default();
#line 214
return film;
};
#line 236
FilmStruct Generic35mm()
{
FilmStruct film = Default();
#line 240
return film;
};
#line 243
FilmStruct GenericSuper35()
{
FilmStruct film = Default();
#line 247
return film;
};
#line 250
FilmStruct Generic16mm()
{
FilmStruct film = Default();
#line 254
return film;
};
#line 36 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
#line 207
uniform int _TUT1 < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""INTRODUCTION""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
"   Welcome to FILMDECK!\n\n"
#line 210
"     FILMDECK was created to help people achieve cinematic color\n"
"   quickly and easily. This is done by emulating one of the color\n"
"   grading workflows used by colorists working in the film industry.\n\n"
#line 214
"     When a movie is shot on actual film, there are multiple steps\n"
"   in achieving the final look. Initially, the negative captured in\n"
"   the camera must be scanned digitally for manipulation in a tool\n"
"   like Davinci Resolve.\n\n"
#line 219
"     Once scanned, the film footage is similar to any other high-end\n"
"   digital cinema camera footage and can be graded in the same manner.\n"
"   Often color grading is done with a Film Print LUT at the end of the\n"
"   grading chain so that the colorist can get an idea of how their work\n"
"   will appear in the final result. These LUTs are often provided by\n"
"   the lab that will be creating the final film print.\n\n"
#line 226
"     If the footage is going to be 'printed', the print emulation LUT\n"
"   is removed once the grading is complete and the digital file is sent\n"
"   to be 'printed' on a Film Print stock, such as Kodak 2383.\n\n"
#line 230
"     For the purposes of FILMDECK, since we are entirely in the digital\n"
"   domain, we will be emulating the color reponse of both the negative\n"
"   and print stages, as well as the color grading stage which occurs in\n"
"   the middle. The beauty of this workflow is the volume of variations\n"
"   you can achieve by simply mixing and matching various negative and\n"
"   print combinations.\n\n"
#line 237
"   Internal render order:\n"
"       Film Halation\n"
"       Film Negative\n"
"       Color Grade\n"
"       Film Print\n\n"
#line 243
"   How to use:\n"
"       Select a film negative, select a film print, then adjust\n"
"       your color grade.\n\n\n"
#line 247
"   Happy grading,\n"
#line 84
"   TreyM"; > = 0;
#line 96
uniform int FILM_NEGATIVE < ui_type = "combo"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " ""Negative"; ui_items =
#line 93
"Bypass\0" "Kodak VISION3 250D 5207\0" "Kodak VISION3 200T 5213\0" "Fuji Reala 500D 8592\0"; ui_tooltip = ""; > = 1;
#line 106
uniform int FILM_FORMATN < ui_type = "combo"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " ""Negative Format"; ui_items =
"16mm\0"
"Super 35\0"
#line 97
"35mm Full Frame\0"; ui_tooltip = ""; > = 1;
uniform int GRAIN_N < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " ""Negative Grain"; ui_tooltip = ""; ui_min = 0; ui_max = 100; > = 50;
uniform float NEG_EXP < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " ""Negative Exposure"; ui_tooltip = ""; ui_min = -4.0; ui_max = 4.0; > = 0.0;
uniform int N_TEMP < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " ""Negative Color Temperature"; ui_tooltip = ""; ui_min = -100; ui_max = 100; > = 0;
uniform int AUTO_TEMP < ui_type = "combo"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " ""Use Film Negative Whitebalance"; ui_items = "Disabled\0Enabled\0"; ui_tooltip = ""; > = 0;
#line 118
uniform int _WBMASG < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
" This will force FILMDECK to white balance\n"
" the image as it goes into the Negative profile\n"
" according to the real world white balance\n"
#line 106
" of your selected film negative."; > = 0;
#line 112
uniform int FILM_PRINT < ui_type = "combo"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " ""Print"; ui_items =
#line 109
"Bypass\0" "KODAK VISION Color Print Film 2383\0" "Fujicolor Positive Film Eterna-CP 3521XD\0" "KODAK B&W 2302\0"; ui_tooltip = ""; > = 1;
#line 122
uniform int FILM_FORMATP < ui_type = "combo"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " ""Print Format"; ui_items =
"16mm\0"
"Super 35\0"
#line 113
"35mm Full Frame\0"; ui_tooltip = ""; > = 2;
uniform int GRAIN_P < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " ""Print Grain"; ui_tooltip = ""; ui_min = 0; ui_max = 100; > = 50;
uniform float PRT_EXP < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " ""Print Exposure"; ui_tooltip = ""; ui_min = -4.0; ui_max = 4.0; > = 0.0;
uniform int P_TEMP < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " ""Print Color Temperature"; ui_tooltip = ""; ui_min = -100; ui_max = 100; > = 0;
#line 118
uniform int _PATREON2 < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""FILM SETUP""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text = " For the full set of film profiles: https://patreon.com/TreyM"; > = 0;
#line 158
uniform int ENABLE_GRADE < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Quick Toggle"; ui_tooltip = ""; ui_min = 0; ui_max = 1; > = 1;
#line 160
uniform int SATURATION < ui_type = "slider"; ui_spacing = 5; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Saturation"; ui_tooltip = ""; ui_min = 0; ui_max = 200; > = 100;
#line 162
uniform float3 GAIN < ui_type = "color"; ui_spacing = 5; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Highlights"; ui_tooltip = ""; > = float3(0.5, 0.5, 0.5);
uniform float3 GAMMA < ui_type = "color"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Midtones"; ui_tooltip = ""; > = float3(0.5, 0.5, 0.5);
uniform float3 LIFT < ui_type = "color"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Shadows"; ui_tooltip = ""; > = float3(0.5, 0.5, 0.5);
#line 172
uniform float3 GREYS < ui_type = "color"; ui_spacing = 5; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Grey"; ui_tooltip = "Tint grey tones"; > = float3(0.50, 0.50, 0.50);
uniform float3 HUERed < ui_type = "color"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Red"; ui_tooltip = "Be careful. Do not to push too far!\n" "You can only shift as far as the next\n" "or previous hue's current value.\n\n" "Editing is easiest using the widget\n" "Click the colored box to open it."; > = float3(0.75, 0.25, 0.25);
uniform float3 HUEOrange < ui_type = "color"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Orange"; ui_tooltip = "Be careful. Do not to push too far!\n" "You can only shift as far as the next\n" "or previous hue's current value.\n\n" "Editing is easiest using the widget\n" "Click the colored box to open it."; > = float3(0.75, 0.50, 0.25);
uniform float3 HUEYellow < ui_type = "color"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Yellow"; ui_tooltip = "Be careful. Do not to push too far!\n" "You can only shift as far as the next\n" "or previous hue's current value.\n\n" "Editing is easiest using the widget\n" "Click the colored box to open it."; > = float3(0.75, 0.75, 0.25);
uniform float3 HUEGreen < ui_type = "color"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Green"; ui_tooltip = "Be careful. Do not to push too far!\n" "You can only shift as far as the next\n" "or previous hue's current value.\n\n" "Editing is easiest using the widget\n" "Click the colored box to open it."; > = float3(0.25, 0.75, 0.25);
uniform float3 HUECyan < ui_type = "color"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Cyan"; ui_tooltip = "Be careful. Do not to push too far!\n" "You can only shift as far as the next\n" "or previous hue's current value.\n\n" "Editing is easiest using the widget\n" "Click the colored box to open it."; > = float3(0.25, 0.75, 0.75);
uniform float3 HUEBlue < ui_type = "color"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Blue"; ui_tooltip = "Be careful. Do not to push too far!\n" "You can only shift as far as the next\n" "or previous hue's current value.\n\n" "Editing is easiest using the widget\n" "Click the colored box to open it."; > = float3(0.25, 0.25, 0.75);
uniform float3 HUEPurple < ui_type = "color"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Purple"; ui_tooltip = "Be careful. Do not to push too far!\n" "You can only shift as far as the next\n" "or previous hue's current value.\n\n" "Editing is easiest using the widget\n" "Click the colored box to open it."; > = float3(0.50, 0.25, 0.75);
uniform float3 HUEMagenta < ui_type = "color"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Magenta"; ui_tooltip = "Be careful. Do not to push too far!\n" "You can only shift as far as the next\n" "or previous hue's current value.\n\n" "Editing is easiest using the widget\n" "Click the colored box to open it."; > = float3(0.75, 0.25, 0.75);
#line 182
uniform int CONTRAST < ui_type = "slider"; ui_spacing = 5; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Contrast"; ui_tooltip = ""; ui_min = -100; ui_max = 100; > = 0;
uniform float OUT_GAMMA < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Gamma"; ui_tooltip = "Midtones brightness"; ui_min = 0.01; ui_max = 2.0; > = 1.0;
uniform int2 LEVELS < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Levels"; ui_tooltip = "Black Point | White point"; ui_min = -100; ui_max = 100; > = int2(0, 0);
#line 186
uniform int CLIP_CAL < ui_type = "combo"; ui_spacing = 5; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Clipping Guides"; ui_items = "Disabled\0Enabled\0"; ui_tooltip = ""; > = 0;
uniform int GREY_CAL < ui_type = "combo"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " ""Grey Calibration"; ui_items = "Disabled\0Enabled\0"; ui_tooltip = ""; > = 0;
#line 212
uniform int _CALMSG < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""GRADE""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
" These tools will help you with color grade\n"
" balance. The clipping guide will show where\n"
" your black and white points are clipping, and\n"
" the grey calibration guide will light up green\n"
" anywhere on the image that is near to perfect\n"
#line 194
" grey saturation."; > = 0;
#line 209
uniform int PUSH_MODE < ui_type = "combo"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Exposure Push"; ui_items =
"Automatic by ISO\0"
#line 203
"Manual\0"; ui_tooltip = ""; > = 0;
uniform int AUTO_PUSH < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Automatic Push Range"; ui_tooltip = ""; ui_min = 0; ui_max = 100; > = 100;
uniform float PUSH < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Manual Push"; ui_tooltip = ""; ui_min = 0.0; ui_max = 3.0; > = 0.0;
#line 226
uniform int _PUSHMSG < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
" Exposure push will underexpose the film negative\n"
" while increasing exposure in the film print to\n"
" compensate. The affects color response and grain\n"
" response. Requires both negative and print to be\n"
#line 211
" active."; > = 0;
#line 226
uniform int ENABLE_HAL < ui_type = "combo"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Enable Halation"; ui_items =
"Disabled\0"
"Automatic by Film Negative\0"
#line 217
"Manual\0"; ui_tooltip = ""; > = 1;
uniform int HAL_AMT < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Manual Halation Intensity"; ui_tooltip = ""; ui_min = 0; ui_max = 100; > = 33;
uniform int HAL_SEN < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Manual Halation Sensitivity"; ui_tooltip = ""; ui_min = 10; ui_max = 100; > = 85;
uniform int HAL_WDT < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Manual Halation Size"; ui_tooltip = ""; ui_min = 10; ui_max = 100; > = 75;
#line 233
uniform int _HALMSG < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
" Halation is a film artifact that will cause highlights\n"
" to glow red. This effect actually has nothing to do\n"
#line 224
" with bloom or other lens artifacts."; > = 0;
#line 239
uniform int ENABLE_RES < ui_type = "combo"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Use Film Format Resolution"; ui_items =
"Disabled\0"
"Automatic by Film Format\0"
#line 230
"Manual\0"; ui_tooltip = ""; > = 1;
uniform int RESOLUTION < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Manual Film Resolution"; ui_tooltip = ""; ui_min = 0.0; ui_max = 200.0; > = 100.0;
#line 244
uniform int _RESMSG < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
" Enabling this will allow FILMDECK to adjust the\n"
" overall softness of the image based on the selected\n"
#line 235
" film format (16mm, Super 35, or 35mm)"; > = 0;
#line 237
uniform int ENABLE_GW < ui_type = "combo"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Gate Weave"; ui_items = "Disabled\0Enabled\0"; ui_tooltip = "May cause motion sickness!"; > = 0;
uniform int WEAVE_AMT < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Gate Weave Intensity"; ui_tooltip = "May cause motion sickness!"; ui_min = 0; ui_max = 100; > = 50;
#line 259
uniform int _WVMSG < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
" Gate weave is the effect of film being slightly\n"
" misaligned as it moves quickly through a projector.\n"
" in FILMDECK, this is represented as a slight\n"
" side-to-side wobble. Be careful, it may cause\n"
#line 244
" motion sickness in gameplay."; > = 0;
#line 246
uniform int ENABLE_FLK < ui_type = "combo"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Image Flicker"; ui_items = "Disabled\0Enabled\0"; ui_tooltip = ""; > = 0;
uniform int FLK_INT < ui_type = "slider"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " ""Filcker Intensity"; ui_tooltip = ""; ui_min = 0; ui_max = 100; > = 50;
#line 256
uniform int _FLKMSG < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""MISC OPTIONS""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
" This enables a very subtle image flicker, mimicking\n"
#line 250
" a film projector. Take care, it could cause headaches."; > = 0;
#line 274
uniform int _INFO1 < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""PREPROCESSOR INFO""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
"   ENABLE_GRAIN_DISPLACEMENT\n"
"       Enables FILMDECK to distort the image slightly\n"
"       based on the film grain texture. This provides\n"
#line 262
"       a more realistic result."; > = 0;
#line 279
uniform int _INFO2 < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""PREPROCESSOR INFO""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
"   ENABLE_HALATION\n"
"       Enables a red glow around bright highlights\n"
"       based on the selected film negative or to be\n"
#line 267
"       set manually. Disabling can increase performance."; > = 0;
#line 284
uniform int _INFO3 < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""PREPROCESSOR INFO""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
"   FORCE_8_BIT_OUTPUT\n"
"       Forces FILMDECK to dither the output to 8-bit.\n"
"       This is useful when you have an 8-bit monitor,\n"
#line 272
"       but the game uses an RGB10A2 color buffer."; > = 0;
#line 289
uniform int _INFO4 < ui_type = "radio"; ui_spacing = 0; ui_category = "\n""PREPROCESSOR INFO""\n\n"; ui_category_closed = true; ui_label = " "" "; ui_text =
"   SWAPCHAIN_PRECISION\n"
"       1 = Use game's internal bit depth (not recommended)\n"
"       2 = RGBA16  - 16-bit (default mode)\n"
#line 277
"       3 = RGBA16F - 16-bit float"; > = 0;
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
#line 285 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/Functions/3DLUT.fxh"
float3 MultiLUT_Linear(float3 color, sampler InTex, int index)
{
int2   tex_size;
float2 lutsize;
float3 lutuv, lutcolor;
#line 8
tex_size   = tex2Dsize(InTex);
#line 11
lutsize    = float2(1.0 / tex_size.x, 1.0 / sqrt(tex_size.x));
color.rgb  = saturate(color.rgb) * (sqrt(tex_size.x) - 1.0);
lutuv.z    = floor(color.z);
color.z   -= lutuv.z;
color.xy   = (color.xy + 0.5) * lutsize;
color.x   += lutuv.z * lutsize.y;
color.y   *= (sqrt(tex_size.x) / tex_size.y);
lutuv.x    = color.x;
lutuv.z    = lutuv.x + lutsize.y;
#line 21
lutuv.y    = color.y + (index) * (sqrt(tex_size.x) / tex_size.y);
#line 23
lutcolor   = lerp(tex2D(InTex, lutuv.xy).rgb, tex2D(InTex, lutuv.zy).rgb, color.z);
#line 25
return saturate(lutcolor);
}
#line 38
float4 tex2Dfetch_atlas(sampler2D s, int3 size, int3 pos, int slice)
{
return tex2Dfetch(s, int2(pos.x + size.x * pos.z, pos.y + size.y * slice));
}
#line 43
float3 ApplyTLUT(sampler2D samplerIn, float3 color, int slice)
{
const int size = sqrt(tex2Dsize(samplerIn).x);
#line 47
float3 d =  color * (size.xxx - 1);
int3   i =  d, p00, p11;
int2   j = int2(1, 0);
bool3  b = (d -= i) >= d.gbr;
#line 52
[flatten] 
if (b.x)  
{
[flatten]
if      (b.y) d = d.xyz, p00 = j.xyy, p11 = j.xxy; 
else if (b.z) d = d.zxy, p00 = j.yyx, p11 = j.xyx; 
else          d = d.xzy, p00 = j.xyy, p11 = j.xyx; 
}
#line 61
else 
{
[flatten]
if      (!b.y) d = d.zyx, p00 = j.yyx, p11 = j.yxx; 
else if (!b.z) d = d.yxz, p00 = j.yxy, p11 = j.xxy; 
else           d = d.yzx, p00 = j.yxy, p11 = j.yxx; 
}
#line 69
return mul(float4(1. - d.x, d.z, d.xy - d.yz),
float4x3(tex2Dfetch_atlas(samplerIn, size, i + j.y, slice).rgb,
tex2Dfetch_atlas(samplerIn, size, i + j.x, slice).rgb,
tex2Dfetch_atlas(samplerIn, size, i + p00, slice).rgb,
tex2Dfetch_atlas(samplerIn, size, i + p11, slice).rgb));
}
#line 76
float3 ApplyTLUT(sampler2D samplerIn, float3 color)
{
return ApplyTLUT(samplerIn, color, 0);
}
#line 81
float3 FilmNegative(float3 color, int tex, int stock)
{
switch(tex)
{
case  0: return saturate(ApplyTLUT(NegativeAtlas, color, stock));
#line 88
case  1: return saturate(ApplyTLUT(CustomNegativeAtlas, color, stock));
#line 91
default: return color;
}
}
#line 95
float3 FilmPrint(float3 color, int tex, int stock)
{
switch(tex)
{
case  0: return saturate(ApplyTLUT(PrintAtlas, color, stock));
#line 102
case  1: return saturate(ApplyTLUT(CustomPrintAtlas, color, stock));
#line 105
default: return color;
}
}
#line 286 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/Functions/Contrast.fxh"
float3 ContrastCurve(float3 colorInput, int Contrast)
{
float3 lumCoeff = float3(0.2126, 0.7152, 0.0722);  
float Contrast_blend = Contrast;
const float PI = 3.1415927;
#line 13
float luma = dot(lumCoeff, colorInput.rgb);
#line 15
float3 chroma = colorInput.rgb - luma;
#line 19
float3 x;
x = luma; 
x = x - 0.5;
x = (x / (0.5 + abs(x))) + 0.5;
#line 24
x = lerp(luma, x, Contrast_blend * 0.02); 
colorInput.rgb = x + chroma; 
#line 27
return saturate(colorInput);
}
#line 287 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
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
#line 288 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
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
#line 289 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/Functions/Grain.fxh"
uniform int red_x   < source = "random"; min = 0; max = 100; >;
uniform int red_y   < source = "random"; min = 0; max = 100; >;
#line 4
uniform int green_x < source = "random"; min = 0; max = 100; >;
uniform int green_y < source = "random"; min = 0; max = 100; >;
#line 7
uniform int blue_x  < source = "random"; min = 0; max = 100; >;
uniform int blue_y  < source = "random"; min = 0; max = 100; >;
#line 10
texture TexGrain < source = "SHADERDECK/Grain/Grain.png"; > { Width = 1024; Height = 1024; Format = RGBA8; };
sampler TextureGrain { Texture = TexGrain; AddressU = WRAP; AddressV = WRAP; AddressW = WRAP; };
#line 13
float3 GetGrainTexture(int index, float inv, float2 coord)
{
float3 grain;
float2 rpos, gpos, bpos, scale;
#line 19
rpos       = float2(red_x,   red_y)   * 0.01 * inv;
gpos       = float2(green_x, green_y) * 0.01 * inv;
bpos       = float2(blue_x,  blue_y)  * 0.01 * inv;
#line 23
scale      = float2(1920, 1018) / 1024.0;
#line 25
switch(index)
{
case 0:
#line 29
grain.r  = tex2D(TextureGrain, ((coord) + rpos) * scale).x;
grain.g  = tex2D(TextureGrain, ((coord) + gpos) * scale).x;
grain.b  = tex2D(TextureGrain, ((coord) + bpos) * scale).x;
break;
#line 34
case 1:
#line 36
grain.r  = tex2D(TextureGrain, ((coord) + rpos) * scale).y;
grain.g  = tex2D(TextureGrain, ((coord) + gpos) * scale).y;
grain.b  = tex2D(TextureGrain, ((coord) + bpos) * scale).y;
break;
#line 41
case 2:
#line 43
grain.r  = tex2D(TextureGrain, ((coord) + rpos) * scale).z;
grain.g  = tex2D(TextureGrain, ((coord) + gpos) * scale).z;
grain.b  = tex2D(TextureGrain, ((coord) + bpos) * scale).z;
break;
}
#line 49
return grain;
}
#line 52
float3 FilmGrain(float3 color, int index, float mult, int intensity, float2 coord)
{
float3 range, grain, hsl, shadows, midtones, highlights;
float2 rpos, gpos, bpos, scale;
float  luma;
int    profile;
#line 59
profile = index;
#line 61
grain = GetGrainTexture(index, mult, coord);
#line 64
float3 satcurve[3] =
{
#line 67
float3(0.55, 0.45, 0.25),
#line 70
float3(0.5, 0.5, 0.4),
#line 73
float3(0.5, 0.4, 0.3)
};
#line 77
float3 lumacurve[3] =
{
#line 80
float3(1.0, 0.5, 0.75),
#line 83
float3(0.25, 0.75, 1.0),
#line 86
float3(0.66, 0.33, 1.0)
};
#line 90
float3 rgbshadows[3] =
{
#line 93
float3(1.0, 0.33, 0.75),
#line 96
float3(0.33, 1.0, 0.5),
#line 99
float3(0.66, 0.15, 1.0)
};
#line 103
float3 rgbmids[3] =
{
#line 106
float3(0.25, 1.0, 0.33),
#line 109
float3(0.66, 0.25, 0.5),
#line 112
float3(1.0, 1.0, 1.0)
};
#line 116
float3 rgbhighs[3] =
{
#line 119
float3(1.0, 0.33, 0.5),
#line 122
float3(1.0, 0.15, 1.0),
#line 125
float3(1.0, 1.0, 1.0)
};
#line 129
luma        = dot(pow(abs(color), 0.75), float3(0.212395, 0.701049, 0.086556));
range.x     = smoothstep(0.333, 0.0, luma);
range.z     = smoothstep(0.333, 1.0, luma);
range.y     = saturate(1 - range.x - range.z);
#line 151
shadows     = lerp(0.5, grain, rgbshadows[profile]);
midtones    = lerp(0.5, grain, rgbmids[profile]);
highlights  = lerp(0.5, grain, rgbhighs[profile]);
#line 157
shadows     = lerp(0.5, shadows,    lumacurve[profile].x);
midtones    = lerp(0.5, midtones,   lumacurve[profile].y);
highlights  = lerp(0.5, highlights, lumacurve[profile].z);
#line 170
shadows     = lerp(dot(shadows, float3(0.212395, 0.701049, 0.086556)),    shadows,    satcurve[profile].x);
midtones    = lerp(dot(midtones, float3(0.212395, 0.701049, 0.086556)),   midtones,   satcurve[profile].y);
highlights  = lerp(dot(highlights, float3(0.212395, 0.701049, 0.086556)), highlights, satcurve[profile].z);
#line 176
grain       = 0.0;
grain      += lerp(0.0, shadows,    range.x);
grain      += lerp(0.0, midtones,   range.y);
grain      += lerp(0.0, highlights, range.z);
#line 182
color += (((grain - 0.5) * 2) * (intensity * 0.0125));
#line 184
return saturate(color);
}
#line 290 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/Functions/HSLShift.fxh"
#line 3
static const float HSL_Threshold_Base  = 0.05;
static const float HSL_Threshold_Curve = 1.0;
#line 6
float3 HSLShift(float3 color)
{
float3 hsl = RGBToHSL(color);
const float4 node[9]=
{
float4(HUERed,       0.0),
float4(HUEOrange,   30.0),
float4(HUEYellow,   60.0),
float4(HUEGreen,   120.0),
float4(HUECyan,    180.0),
float4(HUEBlue,    240.0),
float4(HUEPurple,  270.0),
float4(HUEMagenta, 300.0),
float4(HUERed,     360.0),
};
#line 22
int base;
for(int i=0; i<8; i++) if(node[i].a < hsl.r*360.0 )base = i;
#line 25
float w = saturate(abs(hsl.r * 360.0 - node[base].a) / (node[base+1].a - node[base].a));
#line 27
float3 H0 = RGBToHSL(node[base].rgb);
float3 H1 = RGBToHSL(node[base + 1].rgb);
#line 30
H1.x += (H1.x < H0.x)? 1.0:0.0;
#line 32
float3 shift = frac(lerp( H0, H1 , w));
w = max(hsl.g, 0.0) * max(1.0-hsl.b, 0.0);
shift.b = (shift.b - 0.5) * (pow(w, HSL_Threshold_Curve) * (1.0-HSL_Threshold_Base) + HSL_Threshold_Base) * 2.0;
#line 36
return saturate(HSLToRGB(saturate(float3(shift.r, hsl.g * (shift.g * 2.0), hsl.b * (1.0 + shift.b)))));
}
#line 291 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
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
#line 292 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
#line 296
texture RT_Swapchain1 { Width = 1920; Height = 1018; Format = RGBA16; }; sampler TextureSwapchain1 { Texture = RT_Swapchain1; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
texture RT_Swapchain2 { Width = 1920; Height = 1018; Format = RGBA16; }; sampler TextureSwapchain2 { Texture = RT_Swapchain2; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
#line 302
void PS_Downscale(float4 vpos : SV_Position, float2 uv : TEXCOORD, out float4 scaled : SV_Target)
{
#line 306
if ((ENABLE_RES > 0) && ((FILM_NEGATIVE > 0) || (FILM_PRINT > 0)))
{
scaled = tex2Dbicub(TextureColor, (uv - 0.5) / 0.5 + 0.5); 
}
#line 311
else
{
scaled = tex2D(TextureColor, uv); 
}
#line 316
scaled = SRGBToLinear(scaled);
}
#line 319
void PS_Upscale(float4 vpos : SV_Position, float2 uv : TEXCOORD, out float4 color : SV_Target)
{
float4 soften, blur1;
float  mask, res, halsen;
#line 326
color  = SRGBToLinear(tex2D(TextureColor, uv));
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/FILMDECK/ProfileArrays.fxh"
#line 47
FilmStruct NegativeProfile[3];
NegativeProfile[0] = K5207D(); NegativeProfile[1] = K5213T(); NegativeProfile[2] = FR500D();
#line 50
FilmStruct PrintProfile[3];
PrintProfile[0] = K2383(); PrintProfile[1] = F3521(); PrintProfile[2] = K2302();
#line 332 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
#line 336
if ((ENABLE_RES > 0) && ((FILM_NEGATIVE > 0) || (FILM_PRINT > 0))) 
{                                                                  
res    = (ENABLE_RES == 1)
? lerp(0.0, 1.0, lerp(0.5, (FILM_FORMATN * 0.25), (FILM_NEGATIVE > 0)) + lerp(0.5, (FILM_FORMATP * 0.25), (FILM_PRINT > 0)))
: (RESOLUTION * 0.005);
soften = tex2Dbicub(TextureSwapchain1, (uv - 0.5) / (1.0 / 0.5) + 0.5);
mask   = pow(smoothstep(0.1, 1.0, dot(LinearToSRGB(color.rgb), float3(0.212395, 0.701049, 0.086556))), 0.75);
mask   = lerp(lerp(0.25, 1.0, mask), 0.0, res);
color  = lerp(color, soften, mask);
}
#line 351
if ((ENABLE_HAL > 0) && (FILM_NEGATIVE > 0))
{
halsen  = (ENABLE_HAL < 2)
? (NegativeProfile[FILM_NEGATIVE - 1].halation.y * 0.01)
: (HAL_SEN * 0.01);
#line 357
color.a = dot(MultiLUT_Linear(tex2Dbicub(TextureColor, (uv - 0.5) / 0.25 + 0.5).rgb, NegativeAtlas, FILM_NEGATIVE - 1), float3(0.212395, 0.701049, 0.086556));
#line 359
color.a = pow(SRGBToLinear(color.aaa).x, lerp(20.0, 4.0, halsen));
}
#line 362
}
#line 365
void PS_Halate1(float4 vpos : SV_Position, float2 uv : TEXCOORD, out float4 color : SV_Target)
{
float halation, width;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/FILMDECK/ProfileArrays.fxh"
#line 47
FilmStruct NegativeProfile[3];
NegativeProfile[0] = K5207D(); NegativeProfile[1] = K5213T(); NegativeProfile[2] = FR500D();
#line 50
FilmStruct PrintProfile[3];
PrintProfile[0] = K2383(); PrintProfile[1] = F3521(); PrintProfile[2] = K2302();
#line 372 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
#line 376
color = tex2D(TextureSwapchain2, uv);
#line 381
if ((ENABLE_HAL > 0) && (FILM_NEGATIVE > 0))
{
width    = (ENABLE_HAL == 1)
? (NegativeProfile[FILM_NEGATIVE - 1].halation.z * 0.01)
: (HAL_WDT * 0.01);
halation = HalateH(color.a, TextureSwapchain2, width, BoundsMid, uv);
}
#line 389
else
{
halation = 0.0;
}
#line 394
color.a = halation;
}
#line 397
void PS_Halate2(float4 vpos : SV_Position, float2 uv : TEXCOORD, out float4 color : SV_Target)
{
float halation, width;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/FILMDECK/ProfileArrays.fxh"
#line 47
FilmStruct NegativeProfile[3];
NegativeProfile[0] = K5207D(); NegativeProfile[1] = K5213T(); NegativeProfile[2] = FR500D();
#line 50
FilmStruct PrintProfile[3];
PrintProfile[0] = K2383(); PrintProfile[1] = F3521(); PrintProfile[2] = K2302();
#line 404 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
#line 408
color = tex2D(TextureSwapchain1, uv);
#line 413
if ((ENABLE_HAL > 0) && (FILM_NEGATIVE > 0))
{
width    = (ENABLE_HAL == 1)
? (NegativeProfile[FILM_NEGATIVE - 1].halation.z * 0.01)
: (HAL_WDT * 0.01);
halation = HalateV(color.a, TextureSwapchain1, width, BoundsMid, uv);
}
#line 421
else
{
halation = 0.0;
}
#line 426
color.a = halation;
}
#line 431
void PS_GrainDisplacement(float4 vpos : SV_Position, float2 uv : TEXCOORD, out float4 color : SV_Target)
{
float  dist;
float3 grain;
#line 436
dist      = lerp(150.0, 275.0, FILM_FORMATN * 0.5);
#line 438
grain     = GetGrainTexture(FILM_FORMATN, 1.0, uv) - 0.5;
grain    *= (pow(GRAIN_N * 0.01, 0.333)) / (dist * (1440.0 / (1018 * 1.0)));
#line 441
color.rgb = tex2D(TextureSwapchain2, uv + float2(grain.x / (1920 * (1.0 / 1018)), grain.y)).rgb;
color.a   = tex2D(TextureSwapchain2, uv).a;
}
#line 446
void PS_FilmDeck(float4 vpos : SV_Position, float2 uv : TEXCOORD, out float4 film : SV_Target)
{
float  dist, luma, pmask, avg, ntemp, ptemp;
float3 halate;
float3 orig, lift, gamma, gain, grain, grey, hsl;
#line 456
dist   = lerp(150.0, 275.0, FILM_FORMATP * 0.5);
grain  = GetGrainTexture(FILM_FORMATP, -1.0, uv) - 0.5;
grain *= (pow(GRAIN_P * 0.01, 0.333)) / (dist * (1440.0 / (1018 * 1.0)));
film   = tex2D(TextureSwapchain1, uv + float2(grain.z / (1920 * (1.0 / 1018)), grain.y)).rgb;
#line 463
avg  = pow(dot(avGen::get(), float3(0.212395, 0.701049, 0.086556)), 0.75); 
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Include/FILMDECK/ProfileArrays.fxh"
#line 47
FilmStruct NegativeProfile[3];
NegativeProfile[0] = K5207D(); NegativeProfile[1] = K5213T(); NegativeProfile[2] = FR500D();
#line 50
FilmStruct PrintProfile[3];
PrintProfile[0] = K2383(); PrintProfile[1] = F3521(); PrintProfile[2] = K2302();
#line 469 "C:\Program Files\GShade\gshade-shaders\Shaders\FILMDECK.fx"
#line 474
if ((ENABLE_HAL > 0) && (FILM_NEGATIVE > 0))
{
#line 478
halate.r = tex2Dbicub(TextureSwapchain1, (uv - 0.5) / 4.0 + 0.5).a;
#line 482
halate.y = (ENABLE_HAL == 1)
? (NegativeProfile[FILM_NEGATIVE - 1].halation.x * 0.02)
: (HAL_AMT * 0.02);
film.r   = lerp(film.r, BlendScreen(film.r, halate.r), halate.y);
}
#line 496
pmask = dot(SRGBToLinear(tex2D(TextureColor, uv)), float3(0.212395, 0.701049, 0.086556));
#line 498
if (FILM_NEGATIVE > 0)\
    {
film *= exp2(NEG_EXP);
#line 501
if ((PUSH_MODE < 1) && (FILM_PRINT > 0)) 
{
film *= lerp(1.0, lerp(lerp(NegativeProfile[FILM_NEGATIVE - 1].iso / 800.0, 1.0, avg), 1.0, pmask), AUTO_PUSH * 0.01);
}
#line 506
else if (FILM_PRINT > 0) 
{
film *= exp2(lerp(-PUSH, 0.0, pmask));
}
}
#line 512
film = LinearToSRGB(saturate(film));
#line 515
if (FILM_NEGATIVE > 0)
{
#line 519
ntemp = (N_TEMP > 0)
? lerp(6500.0, 40000.0, abs(N_TEMP * 0.01))
: lerp(6500.0,  2000.0, abs(N_TEMP * 0.01));
#line 523
luma  = dot(film.rgb, float3(0.212395, 0.701049, 0.086556));
#line 525
if ((AUTO_TEMP) && (FILM_NEGATIVE > 0))
{
film.rgb = lerp(WhiteBalance(film.rgb, ntemp, NegativeProfile[FILM_NEGATIVE - 1].temp), film.rgb, luma);
}
#line 530
else
{
film.rgb = lerp(WhiteBalance(film.rgb, ntemp, 6500), film.rgb, luma);
}
#line 538
film.rgb = FilmGrain(saturate(film.rgb), FILM_FORMATN, 1.0, GRAIN_N, uv);
#line 554
film.rgb = FilmNegative(saturate(film.rgb), 0, FILM_NEGATIVE - 1).rgb;
#line 556
}
#line 561
if (ENABLE_GRADE)
{
#line 565
film.rgb = RGBToHSL(film.rgb);
film.y   = (SATURATION < 100)
? (lerp(0.0, film.y, SATURATION * 0.01))
: (pow(film.y, lerp(1.0, 0.66, (SATURATION - 100) * 0.01)));
film.rgb = HSLToRGB(film.rgb);
#line 574
lift     = (LIFT  - 0.5) * 0.5;
gamma    = (GAMMA + 0.5);
gain     = (GAIN  + 0.5);
film.rgb = pow(saturate(gain * (film.rgb + lift * (1 - film.rgb))), 1.0 / gamma);
#line 582
hsl      = RGBToHSL(film.rgb);
grey     = (GREYS * 2.0);
film.rgb = saturate(lerp(film.rgb, film.rgb * grey, saturate(pow(1-hsl.y, 10.0) * pow(smoothstep(0.66, 0.0, hsl.z), 1.0))));
#line 589
film.rgb = HSLShift(film.rgb);
#line 594
film.rgb = ContrastCurve(film.rgb, CONTRAST);
}
#line 604
film.rgb   = SRGBToLinear(film.rgb);
if (FILM_PRINT > 0)
{
film      *= exp2(PRT_EXP);
#line 609
if ((PUSH_MODE < 1) && (FILM_NEGATIVE > 0)) 
{
film /= lerp(1.0, lerp(lerp(NegativeProfile[FILM_NEGATIVE - 1].iso / 800.0, 1.0, avg), 1.0, pmask), AUTO_PUSH * 0.01);
}
#line 614
else if (FILM_NEGATIVE > 0) 
{
film *= exp2(lerp(PUSH, 0.0, pmask));
}
}
#line 621
if (FILM_PRINT > 0)
{
#line 625
ptemp    = (P_TEMP > 0)
? lerp(6500.0, 40000.0, abs(P_TEMP * 0.01))
: lerp(6500.0,  2000.0, abs(P_TEMP * 0.01));
luma     = dot(film.rgb, float3(0.212395, 0.701049, 0.086556));
film.rgb = lerp(WhiteBalance(saturate(film.rgb), ptemp, 6500), film.rgb, luma);
#line 633
film     = LinearToSRGB(film);
film.rgb = FilmGrain(saturate(film.rgb), FILM_FORMATP, -0.75, GRAIN_P, uv);
#line 650
film.rgb = FilmPrint(saturate(film.rgb), 0, FILM_PRINT - 1).rgb;
#line 652
}
#line 654
else
{
film.rgb = LinearToSRGB(film.rgb);
}
#line 659
if (ENABLE_GRADE)
{
#line 663
film = pow(film, 1.0 / OUT_GAMMA);
film = saturate(lerp(LEVELS.x / 255.0, (LEVELS.y + 255) / 255.0, film));
#line 669
if (CLIP_CAL)
{
film.rgb = lerp(film.rgb, float3(1, 0, 0), (dot(film.rgb, float3(0.212395, 0.701049, 0.086556)) > (254.0 / 255.0)));
film.rgb = lerp(film.rgb, float3(0, 0, 1), (dot(film.rgb, float3(0.212395, 0.701049, 0.086556)) == 0.0));
}
#line 675
hsl = RGBToHSV(film.rgb);
#line 677
if (GREY_CAL)
{
hsl.z    = SRGBToLinear(hsl.zzz).x;
film.rgb = lerp(film.rgb, float3(0, 1, 0), smoothstep(0.15, 0.05, hsl.y) * (1 - smoothstep(0.055, 0.0, hsl.z) - smoothstep(0.305, 1.0, hsl.z)));
}
}
#line 687
film.rgb += TriDither(film.rgb, uv, 0 ? 8 : 8);
}
#line 690
void PS_GateWeave(float4 vpos : SV_Position, float2 uv : TEXCOORD, out float4 color : SV_Target)
{
float animate;
#line 694
animate = (ENABLE_GW)
? ((cos(Timer * (1.0 / 24.0)) * 0.0001) * (WEAVE_AMT * 0.015))
: 0.0;
#line 698
color   = tex2D(TextureColor, uv + float2(animate, 0.0));
#line 700
if (ENABLE_FLK)
{
color = lerp(color, color * lerp(1.0, 0.975, FLK_INT * 0.01), ((cos(Timer * 3.14159265359) + 1) * 0.5));
}
#line 708
}
#line 713
technique FILMDECK < ui_label = "FILMDECK"; ui_tooltip = "Film Emulation"; >
{
pass 
{
VertexShader = avGen::vs_main;
PixelShader  = avGen::ps_main;
RenderTarget = avGen::texLod;
}
#line 722
pass 
{
VertexShader = VS_Tri;
PixelShader  = PS_Downscale;
RenderTarget = RT_Swapchain1;
}
#line 729
pass 
{
VertexShader = VS_Tri;
PixelShader  = PS_Upscale;
RenderTarget = RT_Swapchain2;
}
#line 737
pass 
{
VertexShader = VS_Tri;
PixelShader  = PS_Halate1;
RenderTarget = RT_Swapchain1;
}
#line 744
pass 
{
VertexShader = VS_Tri;
PixelShader  = PS_Halate2;
RenderTarget = RT_Swapchain2;
}
#line 753
pass 
{
VertexShader = VS_Tri;
PixelShader  = PS_GrainDisplacement;
RenderTarget = RT_Swapchain1;
}
#line 761
pass 
{
VertexShader = VS_Tri;
PixelShader  = PS_FilmDeck;
}
#line 767
pass 
{
VertexShader = VS_Tri;
PixelShader  = PS_GateWeave;
}
}

