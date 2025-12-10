// ITU_REC=709
// MIPMAPPING_LEVEL=0
// AXIMORPHIC_MODE=1
// ADVANCED_MENU=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PerfectPerspective.fx"
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
#line 82 "C:\Program Files\GShade\gshade-shaders\Shaders\PerfectPerspective.fx"
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
#line 83 "C:\Program Files\GShade\gshade-shaders\Shaders\PerfectPerspective.fx"
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
#line 84 "C:\Program Files\GShade\gshade-shaders\Shaders\PerfectPerspective.fx"
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
#line 85 "C:\Program Files\GShade\gshade-shaders\Shaders\PerfectPerspective.fx"
#line 90
uniform uint FovAngle
<
ui_type = "slider";
ui_category = "In game";
ui_category_closed = true;
ui_text = "> Match game settings <";
ui_units = "°";
ui_label = "Field of view (FOV)";
ui_tooltip = "Should match in-game FOV value.";
ui_max = 140u;
> = 90u;
#line 102
uniform uint FovType
<
ui_type = "combo";
ui_category = "In game";
ui_label = "Field of view type";
ui_tooltip =
"This should match game-specific FOV type.\n"
"\n"
"Adjust so that round objects are still round when at the corner, and not oblong.\n"
"Tilt head to see better.\n"
"\n"
"Instruction:\n"
"\n"
"	If image bulges in movement, change it to 'diagonal'.\n"
"	When proportions are distorted at the periphery,\n"
"	choose 'vertical' or '4:3'. For ultra-wide display\n"
"	you may want '16:9' instead.\n"
"\n"
#line 121
"	This method only works with all k = 0.5.";
#line 125
ui_items =
"horizontal\0"
"diagonal\0"
"vertical\0"
"horizontal 4:3\0"
"horizontal 16:9\0";
> = 0u;
#line 136
uniform float K
<
ui_type = "slider";
ui_category = "Distortion";
ui_category_closed = true;
ui_units = " k";
ui_text =
"> -0.5 | distance <\n"
">    0 | speed    <\n"
">  0.5 | shape    <";
#line 147
ui_label = "Horizontal profile";
ui_tooltip = "Projection coefficient 'k' horizontal, represents\n"
#line 153
"various azimuthal projections types:\n"
"\n"
"	 Perception of | Value |  Projection  	\n"
"	---------------+-------+--------------	\n"
"	  brightness   |  -1   |  Orthographic	\n"
"	   distances   | -0.5  |   Equisolid  	\n"
"	     speed     |   0   |  Equidistant 	\n"
"	    shapes     |  0.5  | Stereographic	\n"
"	straight lines |   1   |  Rectilinear 	\n"
"\n"
"\n"
"[Ctrl+click] to type value.";
ui_min = -1f; ui_max = 1f; ui_step = 0.01;
> = 0.5;
#line 169
uniform float Ky
<
ui_type = "slider";
ui_category = "Distortion";
ui_units = " k";
ui_label = "Vertical profile";
ui_tooltip =
"Projection coefficient 'k' vertical, represents\n"
"various azimuthal projections types:\n"
"\n"
"	 Perception of | Value |  Projection  	\n"
"	---------------+-------+--------------	\n"
"	  brightness   |  -1   |  Orthographic	\n"
"	   distances   | -0.5  |   Equisolid  	\n"
"	     speed     |   0   |  Equidistant 	\n"
"	    shapes     |  0.5  | Stereographic	\n"
"	straight lines |   1   |  Rectilinear 	\n"
"\n"
"\n"
"[Ctrl+click] to type value.";
ui_min = -1f; ui_max = 1f; ui_step = 0.01;
> = 0.5;
#line 265
uniform float VignetteIntensity
<
ui_type = "slider";
ui_category = "Distortion";
ui_label = "Natural vignette";
ui_tooltip =
"Apply projection-correct natural vignetting effect.\n"
"\n"
"	Value | Vignetting Type\n"
"	------+-------------------------------------\n"
"	  0   | no vignetting\n"
"	  1   | cosine law of illumination\n"
"	  2   | inverse-square law of illumination\n"
"	  3   | visual sphere stretching (no cosine)\n"
"	  4   | radiometric law of illumination";
ui_min = 0f; ui_max = 4f; ui_step = 0.5;
> = 1f;
#line 285
uniform float CroppingFactor
<
ui_type = "slider";
ui_text =
">   0 | circular       <\n"
"> 0.5 | cropped-circle <\n"
">   1 | full-frame     <";
ui_category = "Border appearance";
ui_category_closed = true;
ui_label = "Cropping";
ui_tooltip =
"Adjusts image scale and cropped area size:\n"
"\n"
"	Value | Cropping      	\n"
"	------+---------------	\n"
"	    0 | circular      	\n"
"	  0.5 | cropped-circle	\n"
"	    1 | full-frame    	\n"
"\n"
"\n"
"For horizontal display, circular will snap to vertical bounds,\n"
"cropped-circle to horizontal bounds, and full-frame to corners.";
ui_min = 0f; ui_max = 1f; ui_step = 0.005;
> = 0.5;
#line 310
uniform float4 BorderColor
<
ui_type = "color";
ui_category = "Border appearance";
ui_label = "Border color";
ui_tooltip = "Use alpha to change border transparency.";
> = float4(0.027, 0.027, 0.027, 0.96);
#line 320
uniform float BorderCorner
<
ui_type = "slider";
ui_category = "Cosmetics";
ui_category_closed = true;
ui_label = "Corner roundness";
ui_tooltip = "Value of 0 gives sharp corners.";
ui_min = 0f; ui_max = 1f; ui_step = 0.01;
> = 0.062;
#line 330
uniform uint BorderGContinuity
<
ui_type = "slider";
ui_category = "Cosmetics";
hidden = !0;
ui_units = "G";
ui_label = "Corner profile";
ui_tooltip =
"G-surfacing continuity level for the corners:\n"
"\n"
"	Continuity | Result     	\n"
"	-----------+------------	\n"
"	        G0 | sharp      	\n"
"	        G1 | circular   	\n"
"	        G2 | smooth     	\n"
"	        G3 | very smooth	\n"
"\n"
"\n"
"G is a commonly used indicator for industrial design,\n"
"where G1 is reserved for heavy-duty, G2 for common items,\n"
"and G3 for luxurious items.";
ui_min = 1u; ui_max = 3u;
> = 3u;
#line 354
uniform float VignetteOffset
<
ui_type = "slider";
ui_category = "Cosmetics";
ui_units = "+";
ui_label = "Vignette exposure";
ui_tooltip = "Brighten the image with vignette enabled.";
ui_min = 0f; ui_max = 0.2; ui_step = 0.01;
> = 0.05;
#line 364
uniform bool MirrorBorder
<
ui_type = "input";
ui_category = "Cosmetics";
hidden = !0;
ui_label = "Mirror on border";
ui_tooltip = "Choose mirrored or original image on the border.";
> = false;
#line 375
uniform bool CalibrationModeView
<
ui_type = "input";
ui_category = "Calibration mode";
ui_category_closed = true;
nosave = true;
ui_label = "Enable calibration grid";
ui_tooltip = "Display calibration grid for lens-matching.";
> = false;
#line 385
uniform float GridSize
<
ui_type = "slider";
ui_text = "\n> Calibration grid look <";
ui_category = "Calibration mode";
hidden = !0;
ui_label = "Size";
ui_tooltip = "Adjust calibration grid size.";
ui_min = 2f; ui_max = 32f; ui_step = 0.01;
> = 16f;
#line 396
uniform float GridWidth
<
ui_type = "slider";
ui_category = "Calibration mode";
hidden = !0;
ui_units = " pixels";
ui_label = "Width";
ui_tooltip = "Adjust calibration grid bar width in pixels.";
ui_min = 2f; ui_max = 16f; ui_step = 0.01;
> = 4f;
#line 407
uniform float GridTilt
<
ui_type = "slider";
ui_category = "Calibration mode";
hidden = !0;
ui_units = "°";
ui_label = "Tilt";
ui_tooltip = "Adjust calibration grid tilt in degrees.";
ui_min = -1f; ui_max = 1f; ui_step = 0.01;
> = 0f;
#line 418
uniform float BackgroundDim
<
ui_type = "slider";
ui_category = "Calibration mode";
hidden = !0;
ui_label = "Background dimming";
ui_tooltip = "Choose the calibration background dimming.";
ui_min = 0f; ui_max = 1f; ui_step = 0.01;
> = 0.5;
#line 455
sampler2D BackBuffer
{
#line 460
Texture = ReShade::BackBufferTex; 
#line 464
AddressU = MIRROR;
AddressV = MIRROR;
#line 468
MagFilter = ANISOTROPIC;
MinFilter = ANISOTROPIC;
MipFilter = ANISOTROPIC;
};
#line 484
float glength(uint G, float2 pos)
{
#line 487
if (G==0u) return max(abs(pos.x), abs(pos.y)); 
#line 489
pos = exp(log(abs(pos))*(++G)); 
return exp(log(pos.x+pos.y)/G); 
}
#line 496
float aastep(float grad)
{
#line 499
float2 Del = float2(ddx(grad), ddy(grad));
#line 501
return saturate(mad(rsqrt(dot(Del, Del)), grad, 0.5)); 
}
#line 508
float get_radius(float theta, float rcp_f, float k) 
{
if      (k>0f)  return tan(abs(k)*theta)/rcp_f/abs(k); 
else if (k<0f)  return sin(abs(k)*theta)/rcp_f/abs(k); 
else   return            theta /rcp_f;        
}
#line 515
float get_theta(float radius, float rcp_f, float k) 
{
if      (k>0f)  return atan(abs(k)*radius*rcp_f)/abs(k); 
else if (k<0f)  return asin(abs(k)*radius*rcp_f)/abs(k); 
else   return             radius*rcp_f;         
}
float get_vignette(float theta, float r, float rcp_f) 
{ return sin(theta)/r/rcp_f; }
float2 get_phi_weights(float2 viewCoord) 
{
viewCoord *= viewCoord; 
return viewCoord/(viewCoord.x+viewCoord.y); 
}
#line 530
float getRadiusOfOmega(float2 viewProportions)
{
switch (FovType) 
{
case 1u: 
return 1f;
case 2u: 
return viewProportions.y;
case 3u: 
return viewProportions.y*4f/3f;
case 4u: 
return viewProportions.y*16f/9f;
default: 
return viewProportions.x;
}
}
#line 549
float binarySearchCorner(float halfOmega, float radiusOfOmega, float rcp_focal)
{
float croppingDigonal = 0.5;
#line 553
const static float2 diagonalPhi = get_phi_weights(float2(1920, 1018));
#line 555
const static float diagonalHalfOmega = atan(tan(halfOmega)/radiusOfOmega);
#line 557
for (uint d=4u; d<=ceil(length(float2(1920, 1018))*2u); d*=2u) 
{
#line 560
float diagonalTheta = dot(
diagonalPhi,
float2(
get_theta(croppingDigonal, rcp_focal, K),
get_theta(croppingDigonal, rcp_focal, Ky)
)
);
#line 569
croppingDigonal += diagonalTheta>diagonalHalfOmega ? -rcp(d) : rcp(d); 
}
#line 572
return croppingDigonal;
}
#line 623
float GetBorderMask(float2 borderCoord)
{
#line 626
borderCoord = abs(borderCoord);
if (BorderGContinuity!=0u && BorderCorner!=0f) 
{
#line 630
if ((1920 * (1.0 / 1018))>1f) 
borderCoord.x = mad(borderCoord.x, (1920 * (1.0 / 1018)), 1f-(1920 * (1.0 / 1018)));
else if ((1920 * (1.0 / 1018))<1f) 
borderCoord.y = mad(borderCoord.y, (1018*(1.0 / 1920)), 1f-(1018*(1.0 / 1920)));
#line 635
borderCoord = max(borderCoord+(BorderCorner-1f), 0f)/BorderCorner;
#line 638
return aastep(glength(BorderGContinuity, borderCoord)-1f); 
}
else 
return aastep(glength(0u, borderCoord)-1f);
}
#line 645
float3 GridModeViewPass(
uint2  pixelCoord,
float2 texCoord
)
{
#line 653
 
float3 display = GammaConvert::to_linear(tex2Dfetch(BackBuffer, pixelCoord).rgb);
#line 658
display *= clamp(1f-BackgroundDim, 0f, 1f);
#line 661
texCoord = (texCoord*2f-1f)*normalize(float2(1920, 1018));
#line 663
if (GridTilt!=0f) 
{
#line 666
const static float tiltRad = radians(GridTilt);
#line 668
const static float tiltSin = sin(tiltRad);
const static float tiltCos = cos(tiltRad);
#line 671
texCoord = mul(
#line 673
float2x2(
tiltCos, tiltSin,
-tiltSin, tiltCos
),
texCoord 
);
}
#line 682
float2 delX = float2(ddx(texCoord.x), ddy(texCoord.x));
float2 delY = float2(ddx(texCoord.y), ddy(texCoord.y));
#line 685
texCoord = frac(texCoord*GridSize)-0.5;
#line 689
texCoord *= float2(
rsqrt(dot(delX, delX)),
rsqrt(dot(delY, delY))
)/GridSize; 
#line 694
texCoord = saturate(GridWidth*0.5-abs(texCoord)); 
#line 696
display = lerp(float3(1f, 1f, 0f), display, (1f-texCoord.x)*(1f-texCoord.y));
#line 698
return display; 
}
#line 733
void PerfectPerspective_VS(
in  uint   vertexId  : SV_VertexID,
out float4 position  : SV_Position,
out float2 texCoord  : TEXCOORD0,
out float2 viewCoord : TEXCOORD1
)
{
#line 741
position.x = vertexId==2? 3f :-1f;
position.y = vertexId==1?-3f : 1f;
#line 744
position.z = 0f; 
position.w = 1f; 
#line 748
texCoord.x = viewCoord.x =  position.x;
texCoord.y = viewCoord.y = -position.y;
#line 751
texCoord = texCoord*0.5+0.5;
#line 753
const static float2 viewProportions = normalize(float2(1920, 1018));
#line 755
viewCoord *= viewProportions;
#line 761
const static float halfOmega = radians(FovAngle*0.5);
#line 763
const static float radiusOfOmega = getRadiusOfOmega(viewProportions);
#line 765
const static float rcp_focal = get_radius(halfOmega, radiusOfOmega, K);
#line 768
const static float croppingHorizontal = get_radius(
atan(tan(halfOmega)/radiusOfOmega*viewProportions.x),
rcp_focal, K)/viewProportions.x;
#line 773
const static float croppingVertical = get_radius(
atan(tan(halfOmega)/radiusOfOmega*viewProportions.y),
rcp_focal, Ky)/viewProportions.y;
#line 777
const static float croppingDigonal = binarySearchCorner(halfOmega, radiusOfOmega, rcp_focal);
#line 780
const static float circularFishEye = max(croppingHorizontal, croppingVertical);
#line 782
const static float croppedCircle = min(croppingHorizontal, croppingVertical);
#line 784
const static float fullFrame = croppingDigonal;
#line 826
const static float croppingScalar =
CroppingFactor<0.5
? lerp(
circularFishEye, 
croppedCircle,   
max(CroppingFactor*2f, 0f) 
)
: lerp(
croppedCircle, 
fullFrame, 
min(CroppingFactor*2f-1f, 1f) 
);
#line 840
viewCoord *= croppingScalar;
}
#line 844
float3 PerfectPerspective_PS(
float4 pixelPos  : SV_Position,
float2 texCoord  : TEXCOORD0,
float2 viewCoord : TEXCOORD1
) : SV_Target
{
#line 855
if (FovAngle==0u || (K==1f && Ky==1f && VignetteIntensity<=0f))
#line 862
{
float3 display;
#line 865
if (CalibrationModeView) 
{
display = GridModeViewPass(uint2(pixelPos.xy), texCoord);
display = GammaConvert::to_display(display);
display = BlueNoise::dither(display, uint2(pixelPos.xy));
}
else 
#line 877
 
display = tex2Dfetch(BackBuffer, uint2(pixelPos.xy)).rgb;
#line 881
return display;
}
#line 891
const static float2 viewProportions = normalize(float2(1920, 1018));
#line 893
const static float halfOmega = radians(FovAngle*0.5);
#line 895
const static float radiusOfOmega = getRadiusOfOmega(viewProportions);
#line 897
const static float rcp_focal = get_radius(halfOmega, radiusOfOmega, K);
#line 901
float radius = length(viewCoord);
#line 911
float2 phiMtx = get_phi_weights(viewCoord);
#line 913
float2 theta2 = float2(
get_theta(radius, rcp_focal, K),
#line 916
get_theta(radius, rcp_focal, Ky)
#line 920
);
float theta = dot(phiMtx, theta2); 
#line 923
float vignette = VignetteIntensity>0f ?
exp(log(get_vignette(theta, radius, rcp_focal))*clamp(VignetteIntensity, 0f, 4f)) : 
1f;
#line 947
vignette += VignetteOffset*clamp(VignetteIntensity, 0f, 4f);
#line 951
viewCoord = tan(theta)*normalize(viewCoord);
#line 957
const static float2 toUvCoord = radiusOfOmega/(tan(halfOmega)*viewProportions);
viewCoord *= toUvCoord;
#line 964
texCoord = viewCoord*0.5+0.5;
#line 967
float3 display;
#line 969
if (CalibrationModeView) 
display = GridModeViewPass(uint2(pixelPos.xy), texCoord);
else
{
display =
K!=1f
#line 976
|| Ky!=1f
#line 979
 
? tex2Dgrad(BackBuffer, texCoord, ddx(texCoord), ddy(texCoord)).rgb 
: tex2Dfetch(BackBuffer, uint2(pixelPos.xy)).rgb; 
#line 984
display = GammaConvert::to_linear(display); 
#line 986
}
#line 989
if (
#line 991
(K!=1f || Ky!=1f)
#line 997
&& CroppingFactor<1f) 
{
#line 1000
float3 border = lerp(
#line 1004
 
MirrorBorder ? display : GammaConvert::to_linear(tex2Dfetch(BackBuffer, uint2(pixelPos.xy)).rgb), 
#line 1008
GammaConvert::to_linear(BorderColor.rgb), 
GammaConvert::to_linear(BorderColor.a)    
);
#line 1013
float borderMask = GetBorderMask(viewCoord);
#line 1015
display = MirrorBorder
? vignette*lerp(display, border, borderMask)  
: lerp(vignette*display, border, borderMask); 
}
else if (VignetteIntensity>0f) 
display *= vignette;
#line 1023
display = GammaConvert::to_display(display);
#line 1027
return BlueNoise::dither(display, uint2(pixelPos.xy));
#line 1032
}
#line 1036
technique PerfectPerspective
<
ui_label = "Perfect Perspective (fisheye)";
ui_tooltip =
"Adjust picture perspective for perfect distortion:\n"
"\n"
"      Fish-eye | AXIMORPHIC_MODE 0\n"
"    Anamorphic | AXIMORPHIC_MODE 0\n"
"        * Distortion aspect ratio.\n"
"    Aximorphic | AXIMORPHIC_MODE 1\n"
"        * Separate distortion for X/Y.\n"
"  Asymmetrical | AXIMORPHIC_MODE 2\n"
"        * Separate distortion for X/top/bottom.\n"
"\n"
"\n"
"Instruction:\n"
"\n"
"	1. Select proper FOV angle and type matching game settings.\n"
"	   If FOV type is unknown:\n"
"\n"
"	 a. Find a round object within the game.\n"
"	 b. Stand upfront.\n"
"	 c. Rotate the camera putting the object at the corner.\n"
#line 1060
"	 d. Make sure all 'k' parameters are equal to 0.5.\n"
#line 1064
"	 e. Switch FOV type until object has a round shape, not an egg.\n"
"\n"
"	2. Adjust distortion according to a game-play style.\n"
"\n"
"	 + for other distortion profiles set AXIMORPHIC_MODE to 0, 1, 2.\n"
"\n"
"	3. Adjust visible borders. You can change the cropping, such that\n"
"	   no borders will be visible, or that no image area get lost.\n"
"\n"
"	 + use '4lex4nder/ReshadeEffectShaderToggler' add-on,\n"
"	   to undistort the UI (user interface).\n"
"\n"
"	 + use sharpening, or run the game at Super-Resolution.\n"
"\n"
"	 + for more adjustable parameters set ADVANCED_MENU to 1.\n"
"\n"
"\n"
"The algorithm is part of a scientific article:\n"
"	arXiv:2003.10558 [cs.GR] (2020)\n"
"	arXiv:2010.04077 [cs.GR] (2020)\n"
"	arXiv:2102.12682 [cs.GR] (2021)\n"
"\n"
"This effect © 2018-2025 Jakub Maksymilian Fober\n"
"Licensed under CC+ BY-SA 3.0\n"
"for additional permissions under the CC+ protocol, see the source code.";
>
{
#line 1099
pass PerspectiveDistortion
{
VertexShader = PerfectPerspective_VS;
PixelShader  = PerfectPerspective_PS;
}
}

