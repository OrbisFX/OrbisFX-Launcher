// iADOF_ShapeVerticesD=4
// iADOF_ShapeVerticesT=3
// iADOF_ShapeVerticesP=5
// iADOF_ShapeVertices=12
// bADOF_ImageGrainEnable=0
// bADOF_ShapeTextureEnable=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\DOF.fx"
#line 24
uniform bool DOF_AUTOFOCUS <
ui_tooltip = "Enables automated focus recognition based on samples around autofocus center.";
ui_category = "DOF";
> = true;
uniform bool DOF_MOUSEDRIVEN_AF <
ui_tooltip = "Enables mouse driven auto-focus. If 1 the AF focus point is read from the mouse coordinates, otherwise the DOF_FOCUSPOINT is used.";
ui_category = "DOF";
> = false;
uniform float2 DOF_FOCUSPOINT <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "X and Y coordinates of autofocus center. Axes start from upper left screen corner.";
ui_category = "DOF";
> = float2(0.5, 0.5);
uniform float DOF_FOCUSSAMPLES <
ui_type = "slider";
ui_min = 3; ui_max = 10;
ui_tooltip = "Amount of samples around the focus point for smoother focal plane detection.";
ui_category = "DOF";
> = 6;
uniform float DOF_FOCUSRADIUS <
ui_type = "slider";
ui_min = 0.02; ui_max = 0.20;
ui_tooltip = "Radius of samples around the focus point.";
ui_category = "DOF";
> = 0.05;
uniform float DOF_NEARBLURCURVE <
ui_type = "slider";
ui_min = 0.5; ui_max = 1000.0;
ui_step = 0.5;
ui_tooltip = "Curve of blur closer than focal plane. Higher means less blur.";
ui_category = "DOF";
> = 1.60;
uniform float DOF_FARBLURCURVE <
ui_type = "slider";
ui_min = 0.05; ui_max = 5.0;
ui_tooltip = "Curve of blur behind focal plane. Higher means less blur.";
ui_category = "DOF";
> = 2.00;
uniform float DOF_MANUALFOCUSDEPTH <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Depth of focal plane when autofocus is off. 0.0 means camera, 1.0 means infinite distance.";
ui_category = "DOF";
> = 0.02;
uniform float DOF_INFINITEFOCUS <
ui_type = "slider";
ui_min = 0.01; ui_max = 1.0;
ui_tooltip = "Distance at which depth is considered as infinite. 1.0 is standard.\nLow values only produce out of focus blur when focus object is very close to the camera. Recommended for gaming.";
ui_category = "DOF";
> = 1.00;
uniform float DOF_BLURRADIUS <
ui_type = "slider";
ui_min = 2.0; ui_max = 100.0;
ui_tooltip = "Maximal blur radius in pixels.";
ui_category = "DOF";
> = 15.0;
#line 83
uniform float iRingDOFSamples <
ui_type = "slider";
ui_min = 5; ui_max = 30;
ui_tooltip = "Samples on the first ring. The other rings around have more samples.";
ui_category = "Ring DOF";
> = 6;
uniform float iRingDOFRings <
ui_type = "slider";
ui_min = 1; ui_max = 8;
ui_tooltip = "Ring count";
ui_category = "Ring DOF";
> = 4;
uniform float fRingDOFThreshold <
ui_type = "slider";
ui_min = 0.5; ui_max = 3.0;
ui_tooltip = "Threshold for bokeh brightening. Above this value, everything gets much much brighter.\n1.0 is maximum value for LDR games like GTASA, higher values work only on HDR games like Skyrim etc.";
ui_category = "Ring DOF";
> = 0.7;
uniform float fRingDOFGain <
ui_type = "slider";
ui_min = 0.1; ui_max = 30.0;
ui_tooltip = "Amount of brightening for pixels brighter than threshold.";
ui_category = "Ring DOF";
> = 27.0;
uniform float fRingDOFBias <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_tooltip = "Bokeh bias";
ui_category = "Ring DOF";
> = 0.0;
uniform float fRingDOFFringe <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Amount of chromatic aberration";
ui_category = "Ring DOF";
> = 0.5;
#line 121
uniform float iMagicDOFBlurQuality <
ui_type = "slider";
ui_min = 1; ui_max = 30;
ui_tooltip = "Blur quality as control value over tap count.\nQuality 15 produces 721 taps, impossible with other DOF shaders by far, most they can do is about 150.";
ui_category = "Magic DOF";
> = 8;
uniform float fMagicDOFColorCurve <
ui_type = "slider";
ui_min = 1.0; ui_max = 10.0;
ui_tooltip = "DOF weighting curve";
ui_category = "Magic DOF";
> = 4.0;
#line 135
uniform float iGPDOFQuality <
ui_type = "slider";
ui_min = 0; ui_max = 7;
ui_tooltip = "0 = only slight gaussian farblur but no bokeh. 1-7 bokeh blur, higher means better quality of blur but less fps. ";
ui_category = "GP65CJ042 DOF";
> = 6;
uniform bool bGPDOFPolygonalBokeh <
ui_tooltip = "Enables polygonal bokeh shape, e.g. POLYGON_NUM 5 means pentagonal bokeh shape. Setting this value to false results in circular bokeh shape.";
ui_category = "GP65CJ042 DOF";
> = true;
uniform float iGPDOFPolygonCount <
ui_type = "slider";
ui_min = 3; ui_max = 9;
ui_tooltip = "Controls the amount pf polygons for polygonal bokeh shape. 3 = triangular, 4 = square, 5 = pentagonal etc.";
ui_category = "GP65CJ042 DOF";
> = 5;
uniform float fGPDOFBias <
ui_type = "slider";
ui_min = 0.0; ui_max = 20.0;
ui_tooltip = "Shifts bokeh weighting to bokeh shape edge. Set to 0 for even bright bokeh shapes, raise it for darker bokeh shapes in center and brighter on edge.";
ui_category = "GP65CJ042 DOF";
> = 10.0;
uniform float fGPDOFBiasCurve <
ui_type = "slider";
ui_min = 0.0; ui_max = 3.0;
ui_tooltip = "Power of Bokeh Bias. Raise for more defined bokeh outlining on bokeh shape edge.";
ui_category = "GP65CJ042 DOF";
> = 2.0;
uniform float fGPDOFBrightnessThreshold <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
ui_tooltip = "Threshold for bokeh brightening. Above this value, everything gets much much brighter.\n1.0 is maximum value for LDR games like GTASA, higher values work only on HDR games like Skyrim etc.";
ui_category = "GP65CJ042 DOF";
> = 0.5;
uniform float fGPDOFBrightnessMultiplier <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_tooltip = "Amount of brightening for pixels brighter than fGPDOFBrightnessThreshold.";
ui_category = "GP65CJ042 DOF";
> = 2.0;
uniform float fGPDOFChromaAmount <
ui_type = "slider";
ui_min = 0.0; ui_max = 0.4;
ui_tooltip = "Amount of color shifting applied on blurred areas. ";
ui_category = "GP65CJ042 DOF";
> = 0.15;
#line 183
uniform bool bMatsoDOFChromaEnable <
ui_tooltip = "Enables chromatic aberration.";
ui_category = "Matso DOF";
> = true;
uniform float fMatsoDOFChromaPow <
ui_type = "slider";
ui_min = 0.2; ui_max = 3.0;
ui_tooltip = "Amount of chromatic aberration color shifting.";
ui_category = "Matso DOF";
> = 1.4;
uniform float fMatsoDOFBokehCurve <
ui_type = "slider";
ui_min = 0.5; ui_max = 20.0;
ui_tooltip = "Bokeh curve";
ui_category = "Matso DOF";
> = 8.0;
uniform float iMatsoDOFBokehQuality <
ui_type = "slider";
ui_min = 1; ui_max = 10;
ui_tooltip = "Blur quality as control value over tap count.";
ui_category = "Matso DOF";
> = 2;
uniform float fMatsoDOFBokehAngle <
ui_type = "slider";
ui_min = 0; ui_max = 360; ui_step = 1;
ui_tooltip = "Rotation angle of bokeh shape.";
ui_category = "Matso DOF";
> = 0;
#line 239
uniform int iADOF_ShapeType <
ui_type = "combo";
ui_items = "Circle (GShade/Angelite)\0Pentagon (ReShade 3/4)\0Diamond\0Triangle\0";
ui_tooltip = "Shape of the DOF.";
ui_category = "MartyMcFly DOF";
> = 0;
uniform float iADOF_ShapeQuality <
ui_type = "slider";
ui_min = 1; ui_max = 255;
ui_tooltip = "Quality level of DOF shape. Higher means more offsets taken, cleaner shape but also less performance. Compilation time stays same.";
ui_category = "MartyMcFly DOF";
> = 17;
uniform float fADOF_ShapeRotation <
ui_type = "slider";
ui_min = 0; ui_max = 360; ui_step = 1;
ui_tooltip = "Static rotation of bokeh shape.";
ui_category = "MartyMcFly DOF";
> = 15;
uniform bool bADOF_RotAnimationEnable <
ui_tooltip = "Enables constant shape rotation in time.";
ui_category = "MartyMcFly DOF";
> = false;
uniform float fADOF_RotAnimationSpeed <
ui_type = "slider";
ui_min = -5; ui_max = 5;
ui_tooltip = "Speed of shape rotation. Negative numbers change direction.";
ui_category = "MartyMcFly DOF";
> = 2.0;
uniform bool bADOF_ShapeCurvatureEnable <
ui_tooltip = "Bends edges of polygonal shape outwards (or inwards). Circular shape best with vertices > 7";
ui_category = "MartyMcFly DOF";
> = false;
uniform float fADOF_ShapeCurvatureAmount <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Amount of edge bending. 1.0 results in circular shape. Values below 0 produce star-like shapes.";
ui_category = "MartyMcFly DOF";
> = 0.3;
uniform bool bADOF_ShapeApertureEnable <
ui_tooltip = "Enables deformation of bokeh shape into swirl-like aperture. You will recognize it when you try it out. Best with big bokeh shapes.";
ui_category = "MartyMcFly DOF";
> = false;
uniform float fADOF_ShapeApertureAmount <
ui_type = "slider";
ui_min = -0.300; ui_max = 0.800;
ui_tooltip = "Amount of deformation. Negative values mirror the effect. ";
ui_category = "MartyMcFly DOF";
> = 0.01;
uniform bool bADOF_ShapeAnamorphEnable <
ui_tooltip = "Lessens horizontal width of shape to simulate anamorphic bokeh shape seen in movies.";
ui_category = "MartyMcFly DOF";
> = false;
uniform float fADOF_ShapeAnamorphRatio <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Horizontal width factor. 1.0 means 100% width, 0.0 means 0% width (bokeh shape will be vertical line).";
ui_category = "MartyMcFly DOF";
> = 0.2;
uniform bool bADOF_ShapeDistortEnable <
ui_tooltip = "Deforms bokeh shape at screen borders to simulate lens distortion. Bokeh shapes at screen egdes look like an egg.";
ui_category = "MartyMcFly DOF";
> = false;
uniform float fADOF_ShapeDistortAmount <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Amount of deformation.";
ui_category = "MartyMcFly DOF";
> = 0.2;
uniform bool bADOF_ShapeDiffusionEnable <
ui_tooltip = "Enables some fuzzyness of bokeh shape, makes it less clearly defined.";
ui_category = "MartyMcFly DOF";
> = false;
uniform float fADOF_ShapeDiffusionAmount <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Amount of shape diffusion. High values look like the bokeh shape exploded.";
ui_category = "MartyMcFly DOF";
> = 0.1;
uniform bool bADOF_ShapeWeightEnable <
ui_tooltip = "Enables bokeh shape weight bias and shifts color to the shape borders.";
ui_category = "MartyMcFly DOF";
> = false;
uniform float fADOF_ShapeWeightCurve <
ui_type = "slider";
ui_min = 0.5; ui_max = 8.0;
ui_tooltip = "Curve of shape weight bias.";
ui_category = "MartyMcFly DOF";
> = 4.0;
uniform float fADOF_ShapeWeightAmount <
ui_type = "slider";
ui_min = 0.5; ui_max = 8.0;
ui_tooltip = "Amount of shape weight bias.";
ui_category = "MartyMcFly DOF";
> = 1.0;
uniform float fADOF_BokehCurve <
ui_type = "slider";
ui_min = 1.0; ui_max = 20.0;
ui_tooltip = "Bokeh factor. Higher values produce more defined bokeh shapes for separated bright spots.";
ui_category = "MartyMcFly DOF";
> = 4.0;
#line 341
uniform bool bADOF_ShapeChromaEnable <
ui_tooltip = "Enables chromatic aberration at bokeh shape borders. This means 3 times more samples = less performance.";
ui_category = "MartyMcFly DOF Advanced";
> = false;
uniform int iADOF_ShapeChromaMode <
ui_type = "combo";
ui_items = "Mode 1\0Mode 2\0Mode 3\0Mode 4\0Mode 5\0Mode 6\0";
ui_tooltip = "Switches through the possible R G B shifts.";
ui_category = "MartyMcFly DOF Advanced";
> = 3;
uniform float fADOF_ShapeChromaAmount <
ui_type = "slider";
ui_min = 0.0; ui_max = 0.5;
ui_tooltip = "Amount of color shifting.";
ui_category = "MartyMcFly DOF Advanced";
> = 0.125;
uniform bool bADOF_ImageChromaEnable <
ui_tooltip = "Enables image chromatic aberration at screen corners.\nThis one is way more complex than the shape chroma (and any other chroma on the web).";
ui_category = "MartyMcFly DOF Advanced";
> = false;
uniform float iADOF_ImageChromaHues <
ui_type = "slider";
ui_min = 2; ui_max = 20;
ui_tooltip = "Amount of samples through the light spectrum to get a smooth gradient.";
ui_category = "MartyMcFly DOF Advanced";
> = 5;
uniform float fADOF_ImageChromaCurve <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
ui_tooltip = "Image chromatic aberration curve. Higher means less chroma at screen center areas.";
ui_category = "MartyMcFly DOF Advanced";
> = 1.0;
uniform float fADOF_ImageChromaAmount <
ui_type = "slider";
ui_min = 0.25; ui_max = 10.0;
ui_tooltip = "Linearly increases image chromatic aberration amount.";
ui_category = "MartyMcFly DOF Advanced";
> = 3.0;
#line 381
uniform float fADOF_SmootheningAmount <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
ui_tooltip = "Blur multiplicator of box blur after bokeh to smoothen shape. Box blur is better than gaussian.";
ui_category = "MartyMcFly DOF Advanced";
> = 1.0;
#line 427
texture texHDR1 { Width = 1920 * 0.6; Height = 1018 * 0.6; Format = RGBA8; };
texture texHDR2 { Width = 1920 * 0.6; Height = 1018 * 0.6; Format = RGBA8; };
sampler SamplerHDR1 { Texture = texHDR1; };
sampler SamplerHDR2 { Texture = texHDR2; };
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
#line 436 "C:\Program Files\GShade\gshade-shaders\Shaders\DOF.fx"
#line 437
uniform float2 MouseCoords < source = "mousepoint"; >;
#line 439
float GetCoC(float2 coords)
{
float scenedepth = ReShade::GetLinearizedDepth(coords);
float scenefocus, scenecoc = 0.0;
#line 444
if (DOF_AUTOFOCUS)
{
scenefocus = 0.0;
#line 448
float2 focusPoint;
if (DOF_MOUSEDRIVEN_AF)
focusPoint = MouseCoords * float2((1.0 / 1920), (1.0 / 1018));
else
focusPoint = DOF_FOCUSPOINT;
#line 454
[loop]
for (int r = DOF_FOCUSSAMPLES; 0 < r; r--)
{
sincos((6.2831853 / DOF_FOCUSSAMPLES) * r, coords.y, coords.x);
coords.y *= (1920 * (1.0 / 1018));
scenefocus += ReShade::GetLinearizedDepth(coords * DOF_FOCUSRADIUS + focusPoint);
}
scenefocus /= DOF_FOCUSSAMPLES;
}
else
{
scenefocus = DOF_MANUALFOCUSDEPTH;
}
#line 468
scenefocus = smoothstep(0.0, DOF_INFINITEFOCUS, scenefocus);
scenedepth = smoothstep(0.0, DOF_INFINITEFOCUS, scenedepth);
#line 471
if (scenedepth < scenefocus)
{
scenecoc = (scenedepth - scenefocus) / scenefocus;
}
else
{
scenecoc = saturate((scenedepth - scenefocus) / (scenefocus * pow(4.0, DOF_FARBLURCURVE) - scenefocus));
}
#line 480
return saturate(scenecoc * 0.5 + 0.5);
}
#line 486
void PS_Focus(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr1R : SV_Target0)
{
hdr1R = tex2D(ReShade::BackBuffer, texcoord);
hdr1R.w = GetCoC(texcoord);
}
#line 493
void PS_RingDOF1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr2R : SV_Target0)
{
hdr2R = tex2D(SamplerHDR1, texcoord);
#line 497
const float centerDepth = hdr2R.w;
const float blurAmount = abs(centerDepth * 2.0 - 1.0);
float discRadius = blurAmount * DOF_BLURRADIUS;
#line 501
if (centerDepth < 0.5)
discRadius *= (1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0));
else
discRadius *= 1.0;
#line 506
hdr2R.x = tex2Dlod(SamplerHDR1, float4(texcoord + float2( 0.000,  1.0) * fRingDOFFringe * discRadius * float2((1.0 / 1920), (1.0 / 1018)), 0, 0)).x;
hdr2R.y = tex2Dlod(SamplerHDR1, float4(texcoord + float2(-0.866, -0.5) * fRingDOFFringe * discRadius * float2((1.0 / 1920), (1.0 / 1018)), 0, 0)).y;
hdr2R.z = tex2Dlod(SamplerHDR1, float4(texcoord + float2( 0.866, -0.5) * fRingDOFFringe * discRadius * float2((1.0 / 1920), (1.0 / 1018)), 0, 0)).z;
#line 510
hdr2R.w = centerDepth;
}
void PS_RingDOF2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 blurcolor : SV_Target)
{
blurcolor = tex2D(SamplerHDR2, texcoord);
const float3 noblurcolor = tex2D(ReShade::BackBuffer, texcoord).xyz;
#line 517
const float centerDepth = GetCoC(texcoord);
#line 519
const float blurAmount = abs(centerDepth * 2.0 - 1.0);
float discRadius = blurAmount * DOF_BLURRADIUS;
#line 522
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
#line 527
if (discRadius < 1.2)
{
blurcolor = float4(noblurcolor, centerDepth);
return;
}
#line 533
blurcolor.w = 1.0;
#line 535
const float s = 1.0;
int ringsamples;
#line 538
[loop]
for (int g = 1; g <= iRingDOFRings; g += 1)
{
ringsamples = g * iRingDOFSamples;
#line 543
[loop]
for (int j = 0; j < ringsamples; j += 1)
{
float2 sampleoffset = 0.0;
sincos(j * (6.283 / ringsamples), sampleoffset.y, sampleoffset.x);
float4 tap = tex2Dlod(SamplerHDR2, float4(texcoord + sampleoffset * float2((1.0 / 1920), (1.0 / 1018)) * discRadius * g / iRingDOFRings, 0, 0));
#line 550
tap.xyz *= 1.0 + max((dot(tap.xyz, 0.333) - fRingDOFThreshold) * fRingDOFGain, 0.0) * blurAmount;
#line 552
if (tap.w >= centerDepth * 0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 557
tap.w *= lerp(1.0, g / iRingDOFRings, fRingDOFBias);
blurcolor.xyz += tap.xyz * tap.w;
blurcolor.w += tap.w;
}
}
#line 563
blurcolor.xyz /= blurcolor.w;
blurcolor.xyz = lerp(noblurcolor, blurcolor.xyz, smoothstep(1.2, 2.0, discRadius)); 
blurcolor.w = centerDepth;
}
#line 569
void PS_MagicDOF1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr2R : SV_Target0)
{
float4 blurcolor = tex2D(SamplerHDR1, texcoord);
#line 573
const float centerDepth = blurcolor.w;
float discRadius = abs(centerDepth * 2.0 - 1.0) * DOF_BLURRADIUS;
#line 576
if (centerDepth < 0.5)
discRadius *= (1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0));
else
discRadius *= 1.0;
#line 581
if (discRadius < 1.2)
{
hdr2R = float4(blurcolor.xyz, centerDepth);
}
else
{
blurcolor = 0.0;
#line 589
[loop]
for (int i = -iMagicDOFBlurQuality; i <= iMagicDOFBlurQuality; ++i)
{
float4 tap = tex2Dlod(SamplerHDR1, float4(texcoord + (float2(1, 0) * i) * discRadius * float2((1.0 / 1920), (1.0 / 1018)).x / iMagicDOFBlurQuality, 0, 0));
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
blurcolor.xyz += tap.xyz*tap.w;
blurcolor.w += tap.w;
}
#line 601
blurcolor.xyz /= blurcolor.w;
blurcolor.w = centerDepth;
hdr2R = blurcolor;
}
}
void PS_MagicDOF2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 blurcolor : SV_Target)
{
blurcolor = 0.0;
const float3 noblurcolor = tex2D(ReShade::BackBuffer, texcoord).xyz;
#line 611
const float centerDepth = GetCoC(texcoord); 
float discRadius = abs(centerDepth * 2.0 - 1.0) * DOF_BLURRADIUS;
#line 614
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
#line 619
if (discRadius < 1.2)
{
blurcolor = float4(noblurcolor, centerDepth);
return;
}
#line 625
[loop]
for (int i = -iMagicDOFBlurQuality; i <= iMagicDOFBlurQuality; ++i)
{
const float2 tapoffset1 = float2(0.5, 0.866) * i;
#line 630
blurcolor.xyz += pow(abs(min(tex2Dlod(SamplerHDR2, float4(texcoord + tapoffset1 * discRadius * float2((1.0 / 1920), (1.0 / 1018)) / iMagicDOFBlurQuality, 0, 0)).xyz, tex2Dlod(SamplerHDR2, float4(texcoord + float2(-tapoffset1.x, tapoffset1.y) * discRadius * float2((1.0 / 1920), (1.0 / 1018)) / iMagicDOFBlurQuality, 0, 0)).xyz)), fMagicDOFColorCurve);
blurcolor.w += 1.0;
}
#line 634
blurcolor.xyz /= blurcolor.w;
blurcolor.xyz = pow(saturate(blurcolor.xyz), 1.0 / fMagicDOFColorCurve);
blurcolor.xyz = lerp(noblurcolor, blurcolor.xyz, smoothstep(1.2, 2.0, discRadius));
}
#line 640
void PS_GPDOF1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr2R : SV_Target0)
{
hdr2R = tex2D(SamplerHDR1, texcoord);
#line 644
const float centerDepth = hdr2R.w;
float discRadius = saturate(abs(centerDepth * 2.0 - 1.0) - 0.1) * DOF_BLURRADIUS; 
#line 647
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
#line 652
float3 distortion = float3(-1.0, 0.0, 1.0);
distortion *= fGPDOFChromaAmount;
#line 655
float4 chroma1 = tex2D(SamplerHDR1, texcoord + discRadius * float2((1.0 / 1920), (1.0 / 1018)) * distortion.x);
chroma1.w = smoothstep(0.0, centerDepth, chroma1.w);
hdr2R.x = lerp(hdr2R.x, chroma1.x, chroma1.w);
#line 659
float4 chroma2 = tex2D(SamplerHDR1, texcoord + discRadius * float2((1.0 / 1920), (1.0 / 1018)) * distortion.z);
chroma2.w = smoothstep(0.0, centerDepth, chroma2.w);
hdr2R.z = lerp(hdr2R.z, chroma2.z, chroma2.w);
#line 663
hdr2R.w = centerDepth;
}
void PS_GPDOF2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 blurcolor : SV_Target)
{
blurcolor = tex2D(SamplerHDR2, texcoord);
const float4 noblurcolor = tex2D(ReShade::BackBuffer, texcoord);
#line 670
const float centerDepth = GetCoC(texcoord);
#line 672
const float blurAmount = abs(centerDepth * 2.0 - 1.0);
float discRadius = blurAmount * DOF_BLURRADIUS;
#line 675
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
#line 680
if (discRadius < 1.2)
{
blurcolor = float4(noblurcolor.xyz, centerDepth);
return;
}
#line 686
blurcolor.w = dot(blurcolor.xyz, 0.3333);
blurcolor.w = max((blurcolor.w - fGPDOFBrightnessThreshold) * fGPDOFBrightnessMultiplier, 0.0);
blurcolor.xyz *= (1.0 + blurcolor.w * blurAmount);
blurcolor.xyz *= lerp(1.0, 0.0, saturate(fGPDOFBias));
blurcolor.w = 1.0;
#line 692
int sampleCycle = 0;
int sampleCycleCounter = 0;
int sampleCounterInCycle = 0;
const float basedAngle = 360.0 / iGPDOFPolygonCount;
float2 currentVertex, nextVertex;
#line 698
int dofTaps;
if (bGPDOFPolygonalBokeh)
dofTaps = iGPDOFQuality * (iGPDOFQuality + 1) * iGPDOFPolygonCount / 2.0;
else
dofTaps = iGPDOFQuality * (iGPDOFQuality + 1) * 4;
#line 704
for (int i = 0; i < dofTaps; i++)
{
#line 707
bool dothatstep = sampleCounterInCycle == 0;
if (sampleCycle != 0)
{
if (float(sampleCounterInCycle) % float(sampleCycle) == 0)
dothatstep = true;
}
#line 718
if (dothatstep)
{
sampleCounterInCycle = 0;
sampleCycleCounter++;
#line 723
if (bGPDOFPolygonalBokeh)
{
sampleCycle += iGPDOFPolygonCount;
currentVertex.xy = float2(1.0, 0.0);
sincos(basedAngle* 0.017453292, nextVertex.y, nextVertex.x);
}
else
{
sampleCycle += 8;
}
}
#line 735
sampleCounterInCycle++;
#line 737
float2 sampleOffset;
#line 739
if (bGPDOFPolygonalBokeh)
{
const float sampleAngle = basedAngle / float(sampleCycleCounter) * sampleCounterInCycle;
const float remainAngle = frac(sampleAngle / basedAngle) * basedAngle;
#line 744
if (remainAngle < 0.000001)
{
currentVertex = nextVertex;
sincos((sampleAngle + basedAngle) * 0.017453292, nextVertex.y, nextVertex.x);
}
#line 750
sampleOffset = lerp(currentVertex.xy, nextVertex.xy, remainAngle / basedAngle);
}
else
{
const float sampleAngle = 0.78539816 / float(sampleCycleCounter) * sampleCounterInCycle;
sincos(sampleAngle, sampleOffset.y, sampleOffset.x);
}
#line 758
sampleOffset *= sampleCycleCounter;
#line 760
float4 tap = tex2Dlod(SamplerHDR2, float4(texcoord + sampleOffset * discRadius * float2((1.0 / 1920), (1.0 / 1018)) / iGPDOFQuality, 0, 0));
#line 762
const float brightMultipiler = max((dot(tap.xyz, 0.333) - fGPDOFBrightnessThreshold) * fGPDOFBrightnessMultiplier, 0.0);
tap.xyz *= 1.0 + brightMultipiler * abs(tap.w * 2.0 - 1.0);
#line 765
if (tap.w >= centerDepth * 0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
float BiasCurve = 1.0 + fGPDOFBias * pow(abs((float)sampleCycleCounter / iGPDOFQuality), fGPDOFBiasCurve);
#line 771
blurcolor.xyz += tap.xyz * tap.w * BiasCurve;
blurcolor.w += tap.w * BiasCurve;
#line 774
}
#line 776
blurcolor.xyz /= blurcolor.w;
blurcolor.xyz = lerp(noblurcolor.xyz, blurcolor.xyz, smoothstep(1.2, 2.0, discRadius));
}
#line 781
float4 GetMatsoDOFCA(sampler col, float2 tex, float CoC)
{
const float3 chroma = pow(float3(0.5, 1.0, 1.5), fMatsoDOFChromaPow * CoC);
return float4(float3(tex2Dlod(col, float4(((2.0 * tex - 1.0) * chroma.r) * 0.5 + 0.5,0,0)).r, tex2Dlod(col, float4(((2.0 * tex - 1.0) * chroma.g) * 0.5 + 0.5,0,0)).g, tex2Dlod(col, float4(((2.0 * tex - 1.0) * chroma.b) * 0.5 + 0.5,0,0)).b) * (1.0 - CoC), 1.0);
}
float4 GetMatsoDOFBlur(int axis, float2 coord, sampler SamplerHDRX)
{
float4 blurcolor = tex2D(SamplerHDRX, coord.xy);
#line 790
const float centerDepth = blurcolor.w;
float discRadius = abs(centerDepth * 2.0 - 1.0) * DOF_BLURRADIUS; 
#line 793
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
blurcolor = 0.0;
#line 799
const float2 tdirs[4] = {
float2(-0.306,  0.739),
float2( 0.306,  0.739),
float2(-0.739,  0.306),
float2(-0.739, -0.306)
};
#line 806
for (int i = -iMatsoDOFBokehQuality; i < iMatsoDOFBokehQuality; i++)
{
float2 taxis =  tdirs[axis];
#line 810
taxis.x = cos(fMatsoDOFBokehAngle * 0.0175) * taxis.x - sin(fMatsoDOFBokehAngle * 0.0175) * taxis.y;
taxis.y = sin(fMatsoDOFBokehAngle * 0.0175) * taxis.x + cos(fMatsoDOFBokehAngle * 0.0175) * taxis.y;
#line 813
const float2 tcoord = coord.xy + (float)i * taxis * discRadius * float2((1.0 / 1920), (1.0 / 1018)) * 0.5 / iMatsoDOFBokehQuality;
#line 815
float4 ct;
if (bMatsoDOFChromaEnable)
ct = GetMatsoDOFCA(SamplerHDRX, tcoord.xy, discRadius * float2((1.0 / 1920), (1.0 / 1018)).x * 0.5 / iMatsoDOFBokehQuality);
else
ct = tex2Dlod(SamplerHDRX, float4(tcoord.xy, 0, 0));
#line 821
const float w = pow(abs(dot(ct.rgb, 0.333) + length(ct.rgb) + 0.1), fMatsoDOFBokehCurve) + abs((float)i);
#line 823
blurcolor.xyz += ct.xyz * w;
blurcolor.w += w;
}
#line 827
blurcolor.xyz /= blurcolor.w;
blurcolor.w = centerDepth;
return blurcolor;
}
#line 832
void PS_MatsoDOF1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr2R : SV_Target0)
{
hdr2R = GetMatsoDOFBlur(2, texcoord, SamplerHDR1);
}
void PS_MatsoDOF2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr1R : SV_Target0)
{
hdr1R = GetMatsoDOFBlur(3, texcoord, SamplerHDR2);
}
void PS_MatsoDOF3(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr2R : SV_Target0)
{
hdr2R = GetMatsoDOFBlur(0, texcoord, SamplerHDR1);
}
void PS_MatsoDOF4(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 blurcolor : SV_Target)
{
blurcolor = GetMatsoDOFBlur(1, texcoord, SamplerHDR2);
const float centerDepth = GetCoC(texcoord); 
#line 849
float discRadius = abs(centerDepth * 2.0 - 1.0) * DOF_BLURRADIUS;
#line 851
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
#line 857
blurcolor.xyz = lerp(tex2D(ReShade::BackBuffer, texcoord).xyz,blurcolor.xyz,smoothstep(0.2,2.0,discRadius));
}
#line 861
float2 GetDistortedOffsets(float2 intexcoord, float2 sampleoffset)
{
const float2 tocenter = intexcoord - float2(0.5, 0.5);
const float3 perp = normalize(float3(tocenter.y, -tocenter.x, 0.0));
#line 866
const float rotangle = length(tocenter) * 2.221 * fADOF_ShapeDistortAmount;
const float3 oldoffset = float3(sampleoffset, 0);
#line 869
const float3 rotatedoffset =  oldoffset * cos(rotangle) + cross(perp, oldoffset) * sin(rotangle) + perp * dot(perp, oldoffset) * (1.0 - cos(rotangle));
#line 871
return rotatedoffset.xy;
}
#line 874
float4 tex2Dchroma(sampler2D tex, float2 sourcecoord, float2 offsetcoord)
{
#line 877
const float3 sample1 = tex2Dlod(tex, float4(sourcecoord.xy + offsetcoord.xy * (1.0 - fADOF_ShapeChromaAmount), 0, 0)).xyz;
const float4 sample2 = tex2Dlod(tex, float4(sourcecoord.xy + offsetcoord.xy, 0, 0));
const float3 sample3 = tex2Dlod(tex, float4(sourcecoord.xy + offsetcoord.xy * (1.0 + fADOF_ShapeChromaAmount), 0, 0)).xyz;
float4 res = (0.0, 0.0, 0.0, sample2.w);
#line 882
switch (iADOF_ShapeChromaMode)
{
case 0:
res.xyz = float3(sample1.x, sample2.y, sample3.z);
return res;
case 1:
res.xyz = float3(sample2.x, sample3.y, sample1.z);
return res;
case 2:
res.xyz = float3(sample3.x, sample1.y, sample2.z);
return res;
case 3:
res.xyz = float3(sample1.x, sample3.y, sample2.z);
return res;
case 4:
res.xyz = float3(sample2.x, sample1.y, sample3.z);
return res;
default:
res.xyz = float3(sample3.x, sample2.y, sample1.z);
return res;
}
}
#line 910
uniform float Timer < source = "timer"; >;
#line 912
float3 BokehBlur(sampler2D tex, float2 coord, float CoC, float centerDepth)
{
float4 res = float4(tex2Dlod(tex, float4(coord.xy, 0.0, 0.0)).xyz, 1.0);
const int ringCount = round(lerp(1.0, (float)iADOF_ShapeQuality, CoC / DOF_BLURRADIUS));
float rotAngle = fADOF_ShapeRotation;
float2 discRadius = CoC * float2((1.0 / 1920), (1.0 / 1018));
int shapeVertices;
float2 edgeVertices[12 + 1];
float2 Grain;
#line 922
switch(iADOF_ShapeType)
{
#line 925
case 0:
shapeVertices = 12;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 930
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 932
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 935
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 938
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 944
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 950
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 963
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 969
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 971
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 974
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 977
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 980
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 986
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 991
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 998
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 1005
default:
shapeVertices = 5;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 1010
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 1012
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 1015
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 1018
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 1024
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 1030
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 1043
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 1049
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 1051
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 1054
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 1057
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 1060
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 1066
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 1071
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 1078
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 1085
case 2:
shapeVertices = 4;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 1090
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 1092
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 1095
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 1098
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 1104
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 1110
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 1123
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 1129
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 1131
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 1134
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 1137
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 1140
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 1146
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 1151
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 1158
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 1166
case 3:
shapeVertices = 3;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 1171
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 1173
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 1176
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 1179
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 1185
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 1191
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 1204
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 1210
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 1212
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 1215
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 1218
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 1221
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 1227
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 1232
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 1239
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
}
#line 1247
res.xyz = max(res.xyz / res.w, 0.0);
return pow(res.xyz, 1.0 / fADOF_BokehCurve);
}
#line 1251
void PS_McFlyDOF1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr2R : SV_Target0)
{
texcoord /= 0.6;
#line 1255
hdr2R = tex2D(SamplerHDR1, saturate(texcoord));
#line 1257
const float centerDepth = hdr2R.w;
float discRadius = abs(centerDepth * 2.0 - 1.0) * DOF_BLURRADIUS;
#line 1260
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
#line 1265
if (max(texcoord.x, texcoord.y) <= 1.05 && discRadius >= 1.2)
{
#line 1268
if (discRadius >= 1.2)
hdr2R.xyz = BokehBlur(SamplerHDR1, texcoord, discRadius, centerDepth);
#line 1271
hdr2R.w = centerDepth;
}
}
void PS_McFlyDOF2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 scenecolor : SV_Target)
{
scenecolor = 0.0;
#line 1278
const float centerDepth = GetCoC(texcoord);
float discRadius = abs(centerDepth * 2.0 - 1.0) * DOF_BLURRADIUS;
#line 1281
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
#line 1289
if (bADOF_ImageChromaEnable)
{
const float2 coord = texcoord * 2.0 - 1.0;
float centerfact = length(coord);
centerfact = pow(centerfact, fADOF_ImageChromaCurve) * fADOF_ImageChromaAmount;
#line 1295
float3 chromadivisor = 0.0;
#line 1297
for (float c = 0; c < iADOF_ImageChromaHues; c++)
{
const float temphue = c / iADOF_ImageChromaHues;
float3 tempchroma = saturate(float3(abs(temphue * 6.0 - 3.0) - 1.0, 2.0 - abs(temphue * 6.0 - 2.0), 2.0 - abs(temphue * 6.0 - 4.0)));
scenecolor.xyz += tex2Dlod(SamplerHDR2, float4((coord.xy * (1.0 + ((1.0 / 1920) * centerfact * discRadius) * ((c + 0.5) / iADOF_ImageChromaHues - 0.5)) * 0.5 + 0.5) * 0.6, 0, 0)).xyz*tempchroma.xyz;
chromadivisor += tempchroma;
}
#line 1305
scenecolor.xyz /= dot(chromadivisor.xyz, 0.333);
}
else
{
scenecolor = tex2D(SamplerHDR2, texcoord*0.6);
}
#line 1312
scenecolor.xyz = lerp(scenecolor.xyz, tex2D(ReShade::BackBuffer, texcoord).xyz, smoothstep(2.0,1.2,discRadius));
#line 1314
scenecolor.w = centerDepth;
}
void PS_McFlyDOF3(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 scenecolor : SV_Target)
{
scenecolor = tex2D(ReShade::BackBuffer, texcoord);
float4 blurcolor = 0.0001;
#line 1322
const float2 blurmult = smoothstep(0.3, 0.8, abs(scenecolor.w * 2.0 - 1.0)) * float2((1.0 / 1920), (1.0 / 1018)) * fADOF_SmootheningAmount;
#line 1324
const float weights[3] = { 1.0,0.75,0.5 };
#line 1326
for (int x = -2; x <= 2; x++)
{
for (int y = -2; y <= 2; y++)
{
const float offsetweight = weights[abs(x)] * weights[abs(y)];
blurcolor.xyz += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(x, y) * blurmult, 0, 0)).xyz * offsetweight;
blurcolor.w += offsetweight;
}
}
#line 1336
scenecolor.xyz = blurcolor.xyz / blurcolor.w;
#line 1358
}
#line 1363
technique RingDOF
{
pass Focus { VertexShader = PostProcessVS; PixelShader = PS_Focus; RenderTarget = texHDR1; }
pass RingDOF1 { VertexShader = PostProcessVS; PixelShader = PS_RingDOF1; RenderTarget = texHDR2; }
pass RingDOF2 { VertexShader = PostProcessVS; PixelShader = PS_RingDOF2;  }
}
#line 1370
technique MagicDOF
{
pass Focus { VertexShader = PostProcessVS; PixelShader = PS_Focus; RenderTarget = texHDR1; }
pass MagicDOF1 { VertexShader = PostProcessVS; PixelShader = PS_MagicDOF1; RenderTarget = texHDR2; }
pass MagicDOF2 { VertexShader = PostProcessVS; PixelShader = PS_MagicDOF2;  }
}
#line 1377
technique GP65CJ042DOF
{
pass Focus { VertexShader = PostProcessVS; PixelShader = PS_Focus; RenderTarget = texHDR1; }
pass GPDOF1 { VertexShader = PostProcessVS; PixelShader = PS_GPDOF1; RenderTarget = texHDR2; }
pass GPDOF2 { VertexShader = PostProcessVS; PixelShader = PS_GPDOF2;  }
}
#line 1384
technique MatsoDOF
{
pass Focus { VertexShader = PostProcessVS; PixelShader = PS_Focus; RenderTarget = texHDR1; }
pass MatsoDOF1 { VertexShader = PostProcessVS; PixelShader = PS_MatsoDOF1; RenderTarget = texHDR2; }
pass MatsoDOF2 { VertexShader = PostProcessVS; PixelShader = PS_MatsoDOF2; RenderTarget = texHDR1; }
pass MatsoDOF3 { VertexShader = PostProcessVS; PixelShader = PS_MatsoDOF3; RenderTarget = texHDR2; }
pass MatsoDOF4 { VertexShader = PostProcessVS; PixelShader = PS_MatsoDOF4;  }
}
#line 1393
technique MartyMcFlyDOF
{
pass Focus { VertexShader = PostProcessVS; PixelShader = PS_Focus; RenderTarget = texHDR1; }
pass McFlyDOF1 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF1; RenderTarget = texHDR2; }
pass McFlyDOF2 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF2;  }
pass McFlyDOF3 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF3;  }
}

