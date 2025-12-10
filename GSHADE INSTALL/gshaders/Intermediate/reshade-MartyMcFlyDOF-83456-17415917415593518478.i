// iADOF_ShapeVerticesD=4
// iADOF_ShapeVerticesT=3
// iADOF_ShapeVerticesP=5
// iADOF_ShapeVertices=12
// bADOF_ImageGrainEnable=0
// bADOF_ShapeTextureEnable=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartyMcFlyDOF.fx"
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
#line 109
uniform int iADOF1_ShapeType <
ui_type = "combo";
ui_items = "Circle (GShade/Angelite)\0Pentagon (ReShade 3/4)\0Diamond\0Triangle\0";
ui_tooltip = "Shape of the DOF.";
ui_category = "MartyMcFly DOF";
> = 0;
uniform int iADOF2_ShapeType <
ui_type = "combo";
ui_items = "Circle (GShade/Angelite)\0Pentagon (ReShade 3/4)\0Diamond\0Triangle\0";
ui_tooltip = "Shape of the DOF.";
ui_category = "MartyMcFly DOF";
> = 0;
uniform int iADOF3_ShapeType <
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
#line 223
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
#line 263
uniform float fADOF_SmootheningAmount <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
ui_tooltip = "Blur multiplicator of box blur after bokeh to smoothen shape. Box blur is better than gaussian.";
ui_category = "MartyMcFly DOF Advanced";
> = 1.0;
#line 309
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
#line 318 "C:\Program Files\GShade\gshade-shaders\Shaders\MartyMcFlyDOF.fx"
#line 319
uniform float2 MouseCoords < source = "mousepoint"; >;
#line 321
float GetCoC(float2 coords)
{
float scenedepth = ReShade::GetLinearizedDepth(coords);
float scenefocus, scenecoc = 0.0;
#line 326
if (DOF_AUTOFOCUS)
{
scenefocus = 0.0;
#line 330
float2 focusPoint;
if (DOF_MOUSEDRIVEN_AF)
focusPoint = MouseCoords * float2((1.0 / 1920), (1.0 / 1018));
else
focusPoint = DOF_FOCUSPOINT;
#line 336
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
#line 350
scenefocus = smoothstep(0.0, DOF_INFINITEFOCUS, scenefocus);
scenedepth = smoothstep(0.0, DOF_INFINITEFOCUS, scenedepth);
#line 353
if (scenedepth < scenefocus)
{
scenecoc = (scenedepth - scenefocus) / scenefocus;
}
else
{
scenecoc = saturate((scenedepth - scenefocus) / (scenefocus * pow(4.0, DOF_FARBLURCURVE) - scenefocus));
}
#line 362
return saturate(scenecoc * 0.5 + 0.5);
}
#line 368
void PS_Focus(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr1R : SV_Target0)
{
hdr1R = tex2D(ReShade::BackBuffer, texcoord);
hdr1R.w = GetCoC(texcoord);
}
#line 375
float2 GetDistortedOffsets(float2 intexcoord, float2 sampleoffset)
{
const float2 tocenter = intexcoord - float2(0.5, 0.5);
const float3 perp = normalize(float3(tocenter.y, -tocenter.x, 0.0));
#line 380
const float rotangle = length(tocenter) * 2.221 * fADOF_ShapeDistortAmount;
const float3 oldoffset = float3(sampleoffset, 0);
#line 383
const float3 rotatedoffset =  oldoffset * cos(rotangle) + cross(perp, oldoffset) * sin(rotangle) + perp * dot(perp, oldoffset) * (1.0 - cos(rotangle));
#line 385
return rotatedoffset.xy;
}
#line 388
float4 tex2Dchroma(sampler2D tex, float2 sourcecoord, float2 offsetcoord)
{
#line 391
const float3 sample1 = tex2Dlod(tex, float4(sourcecoord.xy + offsetcoord.xy * (1.0 - fADOF_ShapeChromaAmount), 0, 0)).xyz;
const float4 sample2 = tex2Dlod(tex, float4(sourcecoord.xy + offsetcoord.xy, 0, 0));
const float3 sample3 = tex2Dlod(tex, float4(sourcecoord.xy + offsetcoord.xy * (1.0 + fADOF_ShapeChromaAmount), 0, 0)).xyz;
float4 res = (0.0, 0.0, 0.0, sample2.w);
#line 396
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
#line 424
uniform float Timer < source = "timer"; >;
#line 426
float3 BokehBlur(sampler2D tex, float2 coord, float CoC, float centerDepth)
{
float4 res = float4(tex2Dlod(tex, float4(coord.xy, 0.0, 0.0)).xyz, 1.0);
const int ringCount = round(lerp(1.0, (float)iADOF_ShapeQuality, CoC / DOF_BLURRADIUS));
float rotAngle = fADOF_ShapeRotation;
float2 discRadius = CoC * float2((1.0 / 1920), (1.0 / 1018));
int shapeVertices;
float2 edgeVertices[12 + 1];
float2 Grain;
#line 436
switch(iADOF1_ShapeType)
{
#line 439
case 0:
shapeVertices = 12;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 444
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 446
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 449
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 452
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 458
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 464
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 477
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 483
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 485
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 488
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 491
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 494
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 500
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 505
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 512
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 519
default:
shapeVertices = 5;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 524
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 526
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 529
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 532
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 538
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 544
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 557
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 563
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 565
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 568
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 571
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 574
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 580
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 585
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 592
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 599
case 2:
shapeVertices = 4;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 604
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 606
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 609
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 612
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 618
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 624
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 637
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 643
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 645
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 648
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 651
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 654
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 660
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 665
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 672
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 680
case 3:
shapeVertices = 3;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 685
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 687
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 690
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 693
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 699
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 705
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 718
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 724
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 726
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 729
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 732
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 735
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 741
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 746
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 753
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
}
#line 761
res.xyz = max(res.xyz / res.w, 0.0);
return pow(res.xyz, 1.0 / fADOF_BokehCurve);
}
#line 765
float3 BokehBlur2(sampler2D tex, float2 coord, float CoC, float centerDepth)
{
float4 res = float4(tex2Dlod(tex, float4(coord.xy, 0.0, 0.0)).xyz, 1.0);
const int ringCount = round(lerp(1.0, (float)iADOF_ShapeQuality, CoC / DOF_BLURRADIUS));
float rotAngle = fADOF_ShapeRotation;
float2 discRadius = CoC * float2((1.0 / 1920), (1.0 / 1018));
int shapeVertices;
float2 edgeVertices[12 + 1];
float2 Grain;
#line 775
switch(iADOF2_ShapeType)
{
#line 778
case 0:
shapeVertices = 12;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 783
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 785
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 788
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 791
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 797
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 803
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 816
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 822
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 824
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 827
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 830
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 833
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 839
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 844
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 851
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 858
default:
shapeVertices = 5;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 863
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 865
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 868
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 871
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 877
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 883
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 896
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 902
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 904
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 907
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 910
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 913
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 919
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 924
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 931
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 938
case 2:
shapeVertices = 4;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 943
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 945
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 948
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 951
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 957
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 963
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 976
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 982
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 984
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 987
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 990
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 993
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 999
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 1004
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 1011
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 1019
case 3:
shapeVertices = 3;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 1024
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 1026
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 1029
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 1032
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 1038
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 1044
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 1057
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 1063
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 1065
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 1068
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 1071
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 1074
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 1080
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 1085
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 1092
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
}
#line 1100
res.xyz = max(res.xyz / res.w, 0.0);
return pow(res.xyz, 1.0 / fADOF_BokehCurve);
}
#line 1104
float3 BokehBlur3(sampler2D tex, float2 coord, float CoC, float centerDepth)
{
float4 res = float4(tex2Dlod(tex, float4(coord.xy, 0.0, 0.0)).xyz, 1.0);
const int ringCount = round(lerp(1.0, (float)iADOF_ShapeQuality, CoC / DOF_BLURRADIUS));
float rotAngle = fADOF_ShapeRotation;
float2 discRadius = CoC * float2((1.0 / 1920), (1.0 / 1018));
int shapeVertices;
float2 edgeVertices[12 + 1];
float2 Grain;
#line 1114
switch(iADOF3_ShapeType)
{
#line 1117
case 0:
shapeVertices = 12;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 1122
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 1124
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 1127
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 1130
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 1136
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 1142
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 1155
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 1161
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 1163
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 1166
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 1169
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 1172
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 1178
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 1183
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 1190
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 1197
default:
shapeVertices = 5;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 1202
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 1204
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 1207
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 1210
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 1216
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 1222
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 1235
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 1241
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 1243
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 1246
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 1249
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 1252
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 1258
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 1263
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 1270
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 1277
case 2:
shapeVertices = 4;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 1282
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 1284
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 1287
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 1290
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 1296
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 1302
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 1315
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 1321
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 1323
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 1326
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 1329
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 1332
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 1338
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 1343
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 1350
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
#line 1358
case 3:
shapeVertices = 3;
if (bADOF_ShapeWeightEnable)
res.w = (1.0 - fADOF_ShapeWeightAmount);
#line 1363
res.xyz = pow(abs(res.xyz), fADOF_BokehCurve)*res.w;
#line 1365
if (bADOF_ShapeAnamorphEnable)
discRadius.x *= fADOF_ShapeAnamorphRatio;
#line 1368
if (bADOF_RotAnimationEnable)
rotAngle += fADOF_RotAnimationSpeed * Timer * 0.005;
#line 1371
if (bADOF_ShapeDiffusionEnable)
{
Grain = float2(frac(sin(coord.x + coord.y * 543.31) *  493013.0), frac(cos(coord.x - coord.y * 573.31) * 289013.0));
Grain = (Grain - 0.5) * fADOF_ShapeDiffusionAmount + 1.0;
}
#line 1377
[unroll]
for (int z = 0; z <= shapeVertices; z++)
{
sincos((6.2831853 / shapeVertices)*z + radians(rotAngle), edgeVertices[z].y, edgeVertices[z].x);
}
#line 1383
[loop]
for (float i = 1; i <= ringCount; i++)
{
[loop]
for (int j = 1; j <= shapeVertices; j++)
{
float radiusCoeff = i / ringCount;
float blursamples = i;
#line 1396
[loop]
for (float k = 0; k < blursamples; k++)
{
if (bADOF_ShapeApertureEnable)
radiusCoeff *= 1.0 + sin(k / blursamples * 6.2831853 - 1.5707963)*fADOF_ShapeApertureAmount; 
#line 1402
float2 sampleOffset = lerp(edgeVertices[j - 1], edgeVertices[j], k / blursamples) * radiusCoeff;
#line 1404
if (bADOF_ShapeCurvatureEnable)
sampleOffset = lerp(sampleOffset, normalize(sampleOffset) * radiusCoeff, fADOF_ShapeCurvatureAmount);
#line 1407
if (bADOF_ShapeDistortEnable)
sampleOffset = GetDistortedOffsets(coord, sampleOffset);
#line 1410
if (bADOF_ShapeDiffusionEnable)
sampleOffset *= Grain;
#line 1413
float4 tap;
if (bADOF_ShapeChromaEnable)
tap = tex2Dchroma(tex, coord, sampleOffset * discRadius);
else
tap = tex2Dlod(tex, float4(coord.xy + sampleOffset.xy * discRadius, 0, 0));
#line 1419
if (tap.w >= centerDepth*0.99)
tap.w = 1.0;
else
tap.w = pow(abs(tap.w * 2.0 - 1.0), 4.0);
#line 1424
if (bADOF_ShapeWeightEnable)
tap.w *= lerp(1.0, pow(length(sampleOffset), fADOF_ShapeWeightCurve), fADOF_ShapeWeightAmount);
#line 1431
res.xyz += pow(abs(tap.xyz), fADOF_BokehCurve) * tap.w;
res.w += tap.w;
}
}
}
break;
}
#line 1439
res.xyz = max(res.xyz / res.w, 0.0);
return pow(res.xyz, 1.0 / fADOF_BokehCurve);
}
#line 1443
void PS_McFlyDOF1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr2R : SV_Target0)
{
texcoord /= 0.6;
#line 1447
hdr2R = tex2D(SamplerHDR1, saturate(texcoord));
#line 1449
const float centerDepth = hdr2R.w;
float discRadius = abs(centerDepth * 2.0 - 1.0) * DOF_BLURRADIUS;
#line 1452
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
#line 1457
if (max(texcoord.x, texcoord.y) <= 1.05 && discRadius >= 1.2)
{
#line 1460
if (discRadius >= 1.2)
hdr2R.xyz = BokehBlur(SamplerHDR1, texcoord, discRadius, centerDepth);
#line 1463
hdr2R.w = centerDepth;
}
}
void PS_McFlyDOF12(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr2R : SV_Target0)
{
texcoord /= 0.6;
#line 1470
hdr2R = tex2D(SamplerHDR1, saturate(texcoord));
#line 1472
const float centerDepth = hdr2R.w;
float discRadius = abs(centerDepth * 2.0 - 1.0) * DOF_BLURRADIUS;
#line 1475
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
#line 1480
if (max(texcoord.x, texcoord.y) <= 1.05 && discRadius >= 1.2)
{
#line 1483
if (discRadius >= 1.2)
hdr2R.xyz = BokehBlur2(SamplerHDR1, texcoord, discRadius, centerDepth);
#line 1486
hdr2R.w = centerDepth;
}
}
void PS_McFlyDOF13(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hdr2R : SV_Target0)
{
texcoord /= 0.6;
#line 1493
hdr2R = tex2D(SamplerHDR1, saturate(texcoord));
#line 1495
const float centerDepth = hdr2R.w;
float discRadius = abs(centerDepth * 2.0 - 1.0) * DOF_BLURRADIUS;
#line 1498
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
#line 1503
if (max(texcoord.x, texcoord.y) <= 1.05 && discRadius >= 1.2)
{
#line 1506
if (discRadius >= 1.2)
hdr2R.xyz = BokehBlur3(SamplerHDR1, texcoord, discRadius, centerDepth);
#line 1509
hdr2R.w = centerDepth;
}
}
void PS_McFlyDOF2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 scenecolor : SV_Target)
{
scenecolor = 0.0;
#line 1516
const float centerDepth = GetCoC(texcoord);
float discRadius = abs(centerDepth * 2.0 - 1.0) * DOF_BLURRADIUS;
#line 1519
if (centerDepth < 0.5)
discRadius *= 1.0 / max(DOF_NEARBLURCURVE * 2.0, 1.0);
else
discRadius *= 1.0;
#line 1527
if (bADOF_ImageChromaEnable)
{
const float2 coord = texcoord * 2.0 - 1.0;
float centerfact = length(coord);
centerfact = pow(centerfact, fADOF_ImageChromaCurve) * fADOF_ImageChromaAmount;
#line 1533
float3 chromadivisor = 0.0;
#line 1535
for (float c = 0; c < iADOF_ImageChromaHues; c++)
{
const float temphue = c / iADOF_ImageChromaHues;
float3 tempchroma = saturate(float3(abs(temphue * 6.0 - 3.0) - 1.0, 2.0 - abs(temphue * 6.0 - 2.0), 2.0 - abs(temphue * 6.0 - 4.0)));
scenecolor.xyz += tex2Dlod(SamplerHDR2, float4((coord.xy * (1.0 + ((1.0 / 1920) * centerfact * discRadius) * ((c + 0.5) / iADOF_ImageChromaHues - 0.5)) * 0.5 + 0.5) * 0.6, 0, 0)).xyz*tempchroma.xyz;
chromadivisor += tempchroma;
}
#line 1543
scenecolor.xyz /= dot(chromadivisor.xyz, 0.333);
}
else
{
scenecolor = tex2D(SamplerHDR2, texcoord*0.6);
}
#line 1550
scenecolor.xyz = lerp(scenecolor.xyz, tex2D(ReShade::BackBuffer, texcoord).xyz, smoothstep(2.0,1.2,discRadius));
#line 1552
scenecolor.w = centerDepth;
}
void PS_McFlyDOF3(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 scenecolor : SV_Target)
{
scenecolor = tex2D(ReShade::BackBuffer, texcoord);
float4 blurcolor = 0.0001;
#line 1560
const float2 blurmult = smoothstep(0.3, 0.8, abs(scenecolor.w * 2.0 - 1.0)) * float2((1.0 / 1920), (1.0 / 1018)) * fADOF_SmootheningAmount;
#line 1562
const float weights[3] = { 1.0,0.75,0.5 };
#line 1564
for (int x = -2; x <= 2; x++)
{
for (int y = -2; y <= 2; y++)
{
const float offsetweight = weights[abs(x)] * weights[abs(y)];
blurcolor.xyz += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(x, y) * blurmult, 0, 0)).xyz * offsetweight;
blurcolor.w += offsetweight;
}
}
#line 1574
scenecolor.xyz = blurcolor.xyz / blurcolor.w;
#line 1596
}
#line 1601
technique MartyMcFlyDOF1
{
pass Focus { VertexShader = PostProcessVS; PixelShader = PS_Focus; RenderTarget = texHDR1; }
pass McFlyDOF1 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF1; RenderTarget = texHDR2; }
pass McFlyDOF2 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF2;  }
pass McFlyDOF3 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF3;  }
}
technique MartyMcFlyDOF2
{
pass Focus { VertexShader = PostProcessVS; PixelShader = PS_Focus; RenderTarget = texHDR1; }
pass McFlyDOF1 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF12; RenderTarget = texHDR2; }
pass McFlyDOF2 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF2;  }
pass McFlyDOF3 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF3;  }
}
technique MartyMcFlyDOF3
{
pass Focus { VertexShader = PostProcessVS; PixelShader = PS_Focus; RenderTarget = texHDR1; }
pass McFlyDOF1 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF13; RenderTarget = texHDR2; }
pass McFlyDOF2 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF2;  }
pass McFlyDOF3 { VertexShader = PostProcessVS; PixelShader = PS_McFlyDOF3;  }
}

