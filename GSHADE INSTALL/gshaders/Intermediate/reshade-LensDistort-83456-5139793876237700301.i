// ITU_REC=709
// PATNOMORPHIC_LENS_MODE=0
// PARALLAX_ABERRATION=1
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\LensDistort.fx"
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
#line 86 "C:\Program Files\GShade\gshade-shaders\Shaders\LensDistort.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorConversion.fxh"
#line 52
namespace ColorConvert
{
#line 67
static const float3x3 YCbCrMtx =
float3x3(
float3(0.2126, 1f-0.2126-0.0722, 0.0722), 
float3(-0.5*0.2126/(1f-0.0722), -0.5*(1f-0.2126-0.0722)/(1f-0.0722), 0.5), 
float3(0.5, -0.5*(1f-0.2126-0.0722)/(1f-0.2126), -0.5*0.0722/(1f-0.2126))  
);
#line 75
static const float3x3 RGBMtx =
float3x3(
float3(1f, 0f, 2f-2f*0.2126), 
float3(1f, -0.0722/(1f-0.2126-0.0722)*(2f-2f*0.0722), -0.2126/(1f-0.2126-0.0722)*(2f-2f*0.2126)), 
float3(1f, 2f-2f*0.0722, 0f) 
);
#line 86
float3 RGB_to_YCbCr(float3 color)  
{ return mul(YCbCrMtx, color);}
float  RGB_to_Luma(float3 color)   
{ return dot(YCbCrMtx[0], color);}
float2 RGB_to_Chroma(float3 color) 
{ return float2(dot(YCbCrMtx[1], color), dot(YCbCrMtx[2], color));}
#line 93
float3 YCbCr_to_RGB(float3 color)  
{ return mul(RGBMtx, color);}
}
#line 87 "C:\Program Files\GShade\gshade-shaders\Shaders\LensDistort.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\LinearGammaWorkflow.fxh"
#line 39
namespace GammaConvert
{
#line 54
float  to_display(float  g) { return ((g)<=0.0031308? (g)*12.92 : exp(log(g)/2.4)*1.055-0.055); }
float2 to_display(float2 g) { return ((g)<=0.0031308? (g)*12.92 : exp(log(g)/2.4)*1.055-0.055); }
float3 to_display(float3 g) { return ((g)<=0.0031308? (g)*12.92 : exp(log(g)/2.4)*1.055-0.055); }
float4 to_display(float4 g) { return ((g)<=0.0031308? (g)*12.92 : exp(log(g)/2.4)*1.055-0.055); }
#line 59
float  to_linear( float  g) { return ((g)<=0.04049936? (g)/12.92 : exp(log((g+0.055)/1.055)*2.4)); }
float2 to_linear( float2 g) { return ((g)<=0.04049936? (g)/12.92 : exp(log((g+0.055)/1.055)*2.4)); }
float3 to_linear( float3 g) { return ((g)<=0.04049936? (g)/12.92 : exp(log((g+0.055)/1.055)*2.4)); }
float4 to_linear( float4 g) { return ((g)<=0.04049936? (g)/12.92 : exp(log((g+0.055)/1.055)*2.4)); }
}
#line 88 "C:\Program Files\GShade\gshade-shaders\Shaders\LensDistort.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\BlueNoiseDither.fxh"
#line 54
namespace BlueNoise
{
#line 59
texture BlueNoiseTex
<
source = "j_bluenoise.png";
pooled = true;
>
{
Width = 64u;
Height = 64u;
Format = RGBA8;
};
#line 70
sampler BlueNoiseTexSmp
{
Texture = BlueNoiseTex;
#line 74
AddressU = REPEAT;
AddressV = REPEAT;
};
#line 87
float dither(float gradient, uint2 pixelPos)
{
#line 90
float noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u).r;
#line 92
gradient = ceil(mad(255u, gradient, -noise)); 
#line 94
return gradient/255u;
}
float3 dither(float3 color, uint2 pixelPos)
{
#line 99
float3 noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u).rgb;
#line 101
color = ceil(mad(255u, color, -noise)); 
#line 103
return color/255u;
}
float4 dither(float4 color, uint2 pixelPos)
{
#line 108
float4 noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u);
#line 110
color = ceil(mad(255u, color, -noise)); 
#line 112
return color/255u;
}
}
#line 89 "C:\Program Files\GShade\gshade-shaders\Shaders\LensDistort.fx"
#line 94
uniform bool ShowGrid
<
ui_type = "input";
ui_label = "Display calibration grid";
ui_tooltip =
"This can be used in conjunction with Image.fx\n"
"to display real-world camera lens image and\n"
"match its distortion profile.";
> = false;
#line 107
uniform float4 K
<
ui_type = "drag";
ui_min = -0.2;
ui_max =  0.2;
ui_label = "Radial distortion";
ui_tooltip = "Radial distortion coefficients K1, K2, K3, K4.";
ui_category = "Geometrical lens distortions";
> = 0f;
#line 117
uniform float S
<
ui_type = "slider";
ui_min = 1f;
ui_max = 2f;
ui_step = 0.05;
ui_label = "Anamorphic";
ui_tooltip =
"Anamorphic squeeze factor S,\n"
"affects vertical axis:\n"
"\n"
"1      spherical lens\n"
"1.25   Ultra Panavision 70\n"
"1.33   16x9 TV\n"
"1.5    Technirama\n"
"1.6    digital anamorphic\n"
"1.8    4x3 full-frame\n"
"2      golden-standard";
ui_category = "Geometrical lens distortions";
> = 1f;
#line 165
uniform bool UseVignette
<
ui_type = "drag";
ui_label = "Brightness aberration";
ui_tooltip = "Automatically change image brightness based on projection area.";
ui_category = "Color aberrations";
> = true;
#line 173
uniform float T
<
ui_type = "drag";
ui_min = -0.2;
ui_max =  0.2;
ui_label = "Chromatic radius";
ui_tooltip = "Color separation amount using T.";
ui_category = "Color aberrations";
> = -0.2;
#line 185
uniform float2 P
<
ui_type = "drag";
ui_min = -0.1;
ui_max =  0.1;
ui_label = "Decentering";
ui_tooltip = "Correct image sensor alignment to the optical axis, using P1, P2.";
ui_category = "Elements misalignment";
> = 0f;
#line 195
uniform float2 Q
<
ui_type = "drag";
ui_min = -0.05;
ui_max =  0.05;
ui_label = "Thin prism";
ui_tooltip = "Correct optical elements offset from the optical axis, using Q1, Q2.";
ui_category = "Elements misalignment";
> = 0f;
#line 205
uniform float2 C
<
ui_type = "drag";
ui_min = -0.05;
ui_max =  0.05;
ui_label = "Center";
ui_tooltip = "Offset lens optical center, to correct image cropping, using C1, C2.";
ui_category = "Elements misalignment";
> = 0f;
#line 219
uniform float4 Kp
<
ui_type = "drag";
ui_min = -0.2;
ui_max = 0f;
ui_label = "Radial parallax";
ui_tooltip =
"Parallax aberration radial coefficients K1, K2, K3, K4.\n"
"Requires depth-buffer access.";
ui_category = "Parallax aberration";
> = 0f;
#line 234
uniform bool MirrorBorder
<
ui_type = "input";
ui_label = "Mirror on border";
ui_tooltip = "Choose between mirrored image or original background on the border.";
ui_category = "Border";
ui_category_closed = true;
> = true;
#line 243
uniform bool BorderVignette
<
ui_type = "input";
ui_label = "Brightness aberration on border";
ui_tooltip = "Apply brightness aberration effect to the border.";
ui_category = "Border";
> = true;
#line 251
uniform float4 BorderColor
<
ui_type = "color";
ui_label = "Border color";
ui_tooltip = "Use alpha to change border transparency.";
ui_category = "Border";
> = float4(0.027, 0.027, 0.027, 0.96);
#line 259
uniform float BorderCorner
<
ui_type = "slider";
ui_min = 0f; ui_max = 1f;
ui_label = "Corner radius";
ui_tooltip = "Value of 0.0 gives sharp corners.";
ui_category = "Border";
> = 0.062;
#line 268
uniform uint BorderGContinuity
<
ui_type = "slider";
ui_min = 1u; ui_max = 3u;
ui_units = "G";
ui_label = "Corner roundness";
ui_tooltip =
"G-surfacing continuity level for the corners:\n"
"\n"
"G0   sharp\n"
"G1   circular\n"
"G2   smooth\n"
"G3   very smooth";
ui_category = "Border";
> = 3u;
#line 286
uniform float DimGridBackground
<
ui_type = "slider";
ui_min = 0.25; ui_max = 1f; ui_step = 0.1;
ui_label = "Dim background";
ui_tooltip = "Adjust background visibility.";
ui_category = "Grid";
ui_category_closed = true;
ui_text =
"Use this in conjunction with Image.fx, to match\n"
"lens distortion with a real-world camera profile.";
> = 1f;
#line 299
uniform uint GridLook
<
ui_type = "combo";
ui_items =
"yellow grid\0"
"black grid\0"
"white grid\0"
"red-green grid\0";
ui_label = "Grid look";
ui_tooltip = "Select look of the grid.";
ui_category = "Grid";
> = 0u;
#line 312
uniform uint GridSize
<
ui_type = "slider";
ui_min = 1u; ui_max = 32u;
ui_label = "Grid size";
ui_tooltip = "Adjust calibration grid size.";
ui_category = "Grid";
> = 16u;
#line 321
uniform uint GridWidth
<
ui_type = "slider";
ui_min = 2u; ui_max = 16u;
ui_units = " pixels";
ui_label = "Grid bar width";
ui_tooltip = "Adjust calibration grid bar width in pixels.";
ui_category = "Grid";
> = 2u;
#line 331
uniform float GridTilt
<
ui_type = "slider";
ui_min = -1f; ui_max = 1f; ui_step = 0.01;
ui_units = "°";
ui_label = "Tilt grid";
ui_tooltip = "Adjust calibration grid tilt in degrees.";
ui_category = "Grid";
> = 0f;
#line 343
uniform uint ChromaticSamplesLimit
<
ui_type = "slider";
ui_min = 6u; ui_max = 64u; ui_step = 2u;
ui_label = "Chromatic aberration samples limit";
ui_tooltip =
"Sample count is generated automatically per pixel, based on visible amount.\n"
"This option limits maximum sample (steps) count allowed for color fringing.\n"
"Only even numbers are accepted, odd numbers will be clamped.";
ui_category = "Performance";
> = 32u;
#line 356
uniform uint ParallaxSamples
<
ui_type = "slider";
ui_min = 2u; ui_max = 64u;
ui_label = "Parallax aberration samples";
ui_tooltip =
"Amount of samples (steps) for parallax aberration mapping.";
ui_category = "Performance";
> = 32u;
#line 372
sampler BackBuffer
{
Texture = ReShade::BackBufferTex;
#line 376
AddressU = MIRROR;
AddressV = MIRROR;
};
#line 393
float glength(uint G, float2 pos)
{
#line 396
if (G==0u) return max(abs(pos.x), abs(pos.y)); 
#line 398
pos = pow(abs(pos), ++G); 
return pow(pos.x+pos.y, rcp(G)); 
}
#line 405
float aastep(float grad)
{
#line 408
float2 Del = float2(ddx(grad), ddy(grad));
#line 410
return saturate(rsqrt(dot(Del, Del))*grad+0.5); 
}
#line 416
float3 Spectrum(float hue)
{
float3 hueColor;
hue *= 4f; 
hueColor.rg = hue-float2(1f, 2f);
hueColor.rg = saturate(1.5-abs(hueColor.rg));
hueColor.r += saturate(hue-3.5);
hueColor.b = 1f-hueColor.r;
return hueColor;
}
#line 428
float GetBorderMask(float2 borderCoord)
{
#line 431
borderCoord = abs(borderCoord);
if (BorderGContinuity!=0u && BorderCorner!=0f) 
{
#line 435
if ((1920 * (1.0 / 1018))>1f) 
borderCoord.x = borderCoord.x*(1920 * (1.0 / 1018))+(1f-(1920 * (1.0 / 1018)));
else if ((1920 * (1.0 / 1018))<1f) 
borderCoord.y = borderCoord.y*(1018*(1.0 / 1920))+(1f-(1018*(1.0 / 1920)));
#line 440
borderCoord = max(borderCoord+(BorderCorner-1f), 0f)/BorderCorner;
#line 443
return aastep(glength(BorderGContinuity, borderCoord)-1f); 
}
else 
return aastep(glength(0u, borderCoord)-1f);
}
#line 454
void LensDistortVS(
in  uint   id        : SV_VertexID,
out float4 position  : SV_Position,
out float2 viewCoord : TEXCOORD
)
{
#line 461
const float2 vertexPos[3] =
{
float2(-1f, 1f), 
float2(-1f,-3f), 
float2( 3f, 1f)  
};
#line 468
viewCoord.x =  vertexPos[id].x;
viewCoord.y = -vertexPos[id].y;
#line 471
viewCoord *= normalize(float2(1920, 1018));
#line 473
position = float4(vertexPos[id], 0f, 1f);
}
#line 478
void ParallaxPS(
float4 pixelPos  : SV_Position,
float2 viewCoord : TEXCOORD,
out float3 color : SV_Target
)
{
if (all(Kp==0f)) 
{
color = tex2Dfetch(BackBuffer, uint2(pixelPos.xy)).rgb;
return;
}
#line 491
const float2 aspectScalar = 0.5/normalize(float2(1920, 1018));
#line 493
float2 texCoord = viewCoord*aspectScalar+0.5;
#line 496
float4 R;
R[0] = dot(viewCoord, viewCoord); 
R[1] = R[0]*R[0]; 
R[2] = R[1]*R[0]; 
R[3] = R[2]*R[0]; 
#line 502
float2 centerCoord = texCoord-0.5;
centerCoord *= rcp(1f+dot(Kp, R))-1f;
#line 506
uint maxStepAmount = clamp(ParallaxSamples, 2u, 255u);
#line 508
float offset; 
float stepSize = rcp(maxStepAmount-1u);
for (int counter = maxStepAmount-1u; counter >= 0; counter--)
{
offset = counter*stepSize;
float reverseDepth = 1f-ReShade::GetLinearizedDepth(texCoord-centerCoord*offset);
if (offset <= reverseDepth)
{
float prevOffset = (counter+3u)*stepSize;
float prevDifference = prevOffset-1f+ReShade::GetLinearizedDepth(texCoord-centerCoord*prevOffset);
#line 519
offset = lerp(prevOffset, offset, prevDifference/(prevDifference+reverseDepth-offset));
break;
}
}
#line 524
texCoord -= centerCoord*offset;
#line 526
color = tex2D(BackBuffer, texCoord).rgb;
}
#line 531
void LensDistortPS(
float4 pixelPos  : SV_Position,
float2 viewCoord : TEXCOORD,
out float3 color : SV_Target
)
{
#line 539
if (!ShowGrid && all(K==0f) && all(P==0f) && all(Q==0f))
#line 543
{
color = tex2Dfetch(BackBuffer, uint2(pixelPos.xy)).rgb;
return;
}
#line 549
const float2 aspectScalar = 0.5/normalize(float2(1920, 1018));
#line 552
bool isDistorted = any(K!=0f) || any(P!=0f) || any(Q!=0f);
#line 556
if (isDistorted) 
{
viewCoord -= C; 
#line 561
float2 anamViewCoord = viewCoord; anamViewCoord.y /= S;
#line 563
float4 anamorphR;
anamorphR[0] = dot(anamViewCoord, anamViewCoord); 
anamorphR[1] = anamorphR[0]*anamorphR[0]; 
anamorphR[2] = anamorphR[1]*anamorphR[0]; 
anamorphR[3] = anamorphR[2]*anamorphR[0]; 
float R2 = dot(viewCoord, viewCoord); 
#line 570
viewCoord *=
rcp(1f+dot(K, anamorphR)) 
+ dot(viewCoord, P); 
#line 574
viewCoord +=
R2*Q 
+ C;     
#line 596
}
#line 599
float2 texCoord = viewCoord*aspectScalar+0.5;
#line 601
if (isDistorted && T!=0f && !ShowGrid) 
{
#line 604
float2 orygTexCoord = (pixelPos.xy+0.5)*float2((1.0 / 1920), (1.0 / 1018));
#line 606
float2 distortion = texCoord-orygTexCoord;
#line 608
uint evenSampleCount = min(ChromaticSamplesLimit-ChromaticSamplesLimit%2u, 64u); 
#line 610
uint totalPixelOffset = uint(ceil(length(T*(distortion*float2(1920, 1018)))));
#line 612
evenSampleCount = clamp(totalPixelOffset+totalPixelOffset%2u, 4u, evenSampleCount);
#line 615
color = 0f; 
for (uint i=0u; i<evenSampleCount; i++)
#line 618
color += GammaConvert::to_linear(tex2Dlod(
BackBuffer, 
float4(
(T*(i/float(evenSampleCount-1u)-0.5)+1f) 
*distortion 
+orygTexCoord, 
0f, 0f)
).rgb)
*Spectrum(i/float(evenSampleCount)); 
#line 628
color *= 2f/evenSampleCount;
}
else if (ShowGrid) 
{
#line 633
color = GammaConvert::to_linear(tex2Dfetch(BackBuffer, uint2(pixelPos.xy)).rgb); 
#line 636
{
#line 638
float tiltRad = radians(GridTilt);
#line 640
float tiltSin = sin(tiltRad);
float tiltCos = cos(tiltRad);
#line 643
viewCoord = mul(
#line 645
float2x2(
tiltCos, tiltSin,
-tiltSin, tiltCos
),
viewCoord
);
}
#line 654
float2 delX = float2(ddx(viewCoord.x), ddy(viewCoord.x));
float2 delY = float2(ddx(viewCoord.y), ddy(viewCoord.y));
#line 657
viewCoord = frac(viewCoord*GridSize)-0.5;
#line 661
viewCoord *= float2(
rsqrt(dot(delX, delX)),
rsqrt(dot(delY, delY))
)/GridSize; 
#line 666
viewCoord = GridWidth*0.5-abs(viewCoord);
viewCoord = saturate(viewCoord); 
#line 670
color = lerp(
#line 672
GammaConvert::to_linear(16f/255f),
color,
DimGridBackground
);
switch (GridLook)
{
#line 679
case 1:
color *= (1f-viewCoord.x)*(1f-viewCoord.y);
break;
#line 683
case 2:
color = 1f-(1f-viewCoord.x)*(1f-viewCoord.y)*(1f-color);
break;
#line 687
case 3:
{
color = lerp(color, float3(1f, 0f, 0f), viewCoord.y);
color = lerp(color, float3(0f, 1f, 0f), viewCoord.x);
}  break;
#line 693
default:
color = lerp(float3(1f, 1f, 0f), color, (1f-viewCoord.x)*(1f-viewCoord.y));
break;
}
}
else 
color = GammaConvert::to_linear(tex2D(BackBuffer, texCoord).rgb); 
#line 701
if (!ShowGrid) 
{
#line 704
texCoord *= float2(1920, 1018);
float vignetteMask = UseVignette? ddx(texCoord.x)*ddy(texCoord.y) : 1f;
#line 708
viewCoord *= aspectScalar*2f;
#line 710
float3 border = lerp(
#line 712
MirrorBorder? color : GammaConvert::to_linear(tex2Dfetch(BackBuffer, uint2(pixelPos.xy)).rgb), 
#line 715
GammaConvert::to_linear(BorderColor.rgb), 
GammaConvert::to_linear(BorderColor.a)    
);
#line 720
color = BorderVignette?
vignetteMask*lerp(color, border, GetBorderMask(viewCoord)): 
lerp(vignetteMask*color, border, GetBorderMask(viewCoord)); 
color = saturate(color);
}
#line 727
color = GammaConvert::to_display(color); 
color = BlueNoise::dither(color, uint2(pixelPos.xy)); 
}
#line 735
technique LensDistort
<
ui_label = "Lens distortion";
ui_tooltip =
"Apply camera lens distortion to the image.\n"
"\n"
"	· Brown-Conrady lens division model\n"
#line 743
"	· Anamorphic distortion\n"
#line 748
"	· Parallax aberration\n"
#line 750
"	· Chromatic aberration\n"
"	· Lens vignetting\n"
"\n"
"The algorithm is part of a scientific article:\n"
"	arXiv:2010.04077 [cs.GR] (2020)\n"
"	arXiv:2102.12682 [cs.GR] (2021)\n"
"\n"
"This effect © 2022-2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY-NC-ND 3.0 +\n"
"for additional permissions see the source code.";
>
{
#line 763
pass Parallax
{
VertexShader = LensDistortVS;
PixelShader = ParallaxPS;
}
#line 769
pass Distort
{
VertexShader = LensDistortVS;
PixelShader = LensDistortPS;
}
}

