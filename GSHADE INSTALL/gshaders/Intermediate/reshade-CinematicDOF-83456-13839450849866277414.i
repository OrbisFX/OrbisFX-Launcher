// CINEMATIC_DOF_SHAPES=0
// CD_DEBUG=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\CinematicDOF.fx"
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
#line 113 "C:\Program Files\GShade\gshade-shaders\Shaders\CinematicDOF.fx"
#line 114
namespace CinematicDOF
{
#line 139
uniform bool UseAutoFocus <
ui_category = "Focusing";
ui_label = "Use auto-focus";
ui_tooltip = "If enabled it will make the shader focus on the point specified as 'Auto-focus point',\notherwise it will put the focus plane at the depth specified in 'Manual-focus plane'.";
> = true;
uniform bool UseMouseDrivenAutoFocus <
ui_category = "Focusing";
ui_label = "Use mouse-driven auto-focus";
ui_tooltip = "Enables mouse driven auto-focus. If enabled, and 'Use auto-focus' is enabled, the\nauto-focus point is read from the mouse coordinates, otherwise the 'Auto-focus point' is used.";
> = true;
uniform float2 AutoFocusPoint <
ui_category = "Focusing";
ui_label = "Auto-focus point";
ui_type = "slider";
ui_step = 0.001;
ui_min = 0.000; ui_max = 1.000;
ui_tooltip = "The X and Y coordinates of the auto-focus point. 0,0 is the upper left corner,\nand 0.5, 0.5 is at the center of the screen. Only used if 'Use auto focus' is enabled.";
> = float2(0.5, 0.5);
uniform float AutoFocusTransitionSpeed <
ui_category = "Focusing";
ui_label= "Auto-focus transition speed";
ui_type = "slider";
ui_min = 0.001; ui_max = 1.0;
ui_step = 0.01;
ui_tooltip = "The speed the shader will transition between different focus points when using auto-focus.\n0.001 means very slow, 1.0 means instantly. Only used if 'Use auto-focus' is enabled.";
> = 0.2;
uniform float ManualFocusPlane <
ui_category = "Focusing";
ui_label= "Manual-focus plane";
ui_type = "slider";
ui_min = 0.100; ui_max = 150.00;
ui_step = 0.01;
ui_tooltip = "The depth of focal plane related to the camera when 'Use auto-focus' is off.\nOnly used if 'Use auto-focus' is disabled.";
> = 10.00;
uniform float FocalLength <
ui_category = "Focusing";
ui_label = "Focal length (mm)";
ui_type = "slider";
ui_min = 10; ui_max = 300.0;
ui_step = 1.0;
ui_tooltip = "Focal length of the used lens. The longer the focal length, the narrower the\ndepth of field and thus the more is out of focus. For portraits, start with 120 or 150.";
> = 100.00;
uniform float FNumber <
ui_category = "Focusing";
ui_label = "Aperture (f-number)";
ui_type = "slider";
ui_min = 1; ui_max = 22.0;
ui_step = 0.1;
ui_tooltip = "The f-number (also known as f-stop) to use. The higher the number, the wider\nthe depth of field, meaning the more is in-focus and thus the less is out of focus.\nFor portraits, start with 2.8.";
> = 2.8;
#line 190
uniform bool ShowOutOfFocusPlaneOnMouseDown <
ui_category = "Focusing, overlay";
ui_label = "Show out-of-focus plane overlay on mouse down";
ui_tooltip = "Enables the out-of-focus plane overlay when the left mouse button is pressed down,\nwhich helps with fine-tuning the focusing.";
> = true;
uniform float3 OutOfFocusPlaneColor <
ui_category = "Focusing, overlay";
ui_label = "Out-of-focus plane overlay color";
ui_type= "color";
ui_tooltip = "Specifies the color of the out-of-focus planes rendered when the left-mouse button\nis pressed and 'Show out-of-focus plane on mouse down' is enabled. In (red , green, blue)";
> = float3(0.8,0.8,0.8);
uniform float OutOfFocusPlaneColorTransparency <
ui_category = "Focusing, overlay";
ui_label = "Out-of-focus plane transparency";
ui_type = "slider";
ui_min = 0.01; ui_max = 1.0;
ui_tooltip = "Amount of transparency of the out-of-focus planes. 0.0 is transparent, 1.0 is opaque.";
> = 0.7;
uniform float3 FocusPlaneColor <
ui_category = "Focusing, overlay";
ui_label = "Focus plane overlay color";
ui_type= "color";
ui_tooltip = "Specifies the color of the focus plane rendered when the left-mouse button\nis pressed and 'Show out-of-focus plane on mouse down' is enabled. In (red , green, blue)";
> = float3(0.0, 0.0, 1.0);
uniform float4 FocusCrosshairColor<
ui_category = "Focusing, overlay";
ui_label = "Focus crosshair color";
ui_type = "color";
ui_tooltip = "Specifies the color of the crosshair for the auto-focus.\nAuto-focus must be enabled";
> = float4(1.0, 0.0, 1.0, 1.0);
#line 222
uniform float FarPlaneMaxBlur <
ui_category = "Blur tweaking";
ui_label = "Far plane max blur";
ui_type = "slider";
ui_min = 0.000; ui_max = 8.0;
ui_step = 0.01;
ui_tooltip = "The maximum blur a pixel can have when it has its maximum CoC in the far plane. Use this as a tweak\nto adjust the max far plane blur defined by the lens parameters. Don't use this as your primarily\nblur factor, use the lens parameters Focal Length and Aperture for that instead.";
> = 1.0;
uniform float NearPlaneMaxBlur <
ui_category = "Blur tweaking";
ui_label = "Near plane max blur";
ui_type = "slider";
ui_min = 0.000; ui_max = 4.0;
ui_step = 0.01;
ui_tooltip = "The maximum blur a pixel can have when it has its maximum CoC in the near Plane. Use this as a tweak to\nadjust the max near plane blur defined by the lens parameters.  Don't use this as your primarily blur factor,\nuse the lens parameters Focal Length and Aperture for that instead.";
> = 1.0;
uniform float BlurQuality <
ui_category = "Blur tweaking";
ui_label = "Overall blur quality";
ui_type = "slider";
ui_min = 2.0; ui_max = 30.0;
ui_tooltip = "The number of rings to use in the disc-blur algorithm. The more rings the better\nthe blur results, but also the slower it will get.";
ui_step = 1;
> = 7.0;
uniform float BokehBusyFactor <
ui_category = "Blur tweaking";
ui_label="Bokeh busy factor";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "The 'bokeh busy factor' for the blur: 0 means no busyness boost, 1.0 means extra busyness boost.";
ui_step = 0.01;
> = 0.500;
uniform float PostBlurSmoothing <
ui_category = "Blur tweaking";
ui_label = "Post-blur smoothing factor";
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_tooltip = "The amount of post-blur smoothing blur to apply. 0.0 means no smoothing blur is applied.";
ui_step = 0.01;
> = 0.0;
uniform float NearFarDistanceCompensation <
ui_category = "Blur tweaking";
ui_label = "Near-Far plane distance compenation";
ui_type = "slider";
ui_min = 1.0; ui_max = 5.0;
ui_tooltip = "The amount of compensation is applied for edges which are far away from the background.\nIncrease to a value > 1.0 to avoid hard edges in areas out of focus which\nare close to the in-focus area.";
ui_step = 0.01;
> = 1.0f;
#line 272
uniform float HighlightAnamorphicFactor <
ui_category = "Highlight tweaking, anamorphism";
ui_label="Anamorphic factor";
ui_type = "slider";
ui_min = 0.01; ui_max = 1.00;
ui_tooltip = "The anamorphic factor of the bokeh highlights. A value of 1.0 (default) gives perfect\ncircles, a factor of e.g. 0.1 gives thin ellipses";
ui_step = 0.01;
> = 1.0;
uniform float HighlightAnamorphicSpreadFactor <
ui_category = "Highlight tweaking, anamorphism";
ui_label="Anamorphic spread factor";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "The spread factor for the anamorphic factor. 0.0 means it's relative to the distance\nto the center of the screen, 1.0 means the factor is applied everywhere evenly,\nno matter how far the pixel is to the center of the screen.";
ui_step = 0.01;
> = 0.0;
uniform float HighlightAnamorphicAlignmentFactor <
ui_category = "Highlight tweaking, anamorphism";
ui_label="Anamorphic alignment factor";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "The alignment factor for the anamorphic deformation. 0.0 means you get evenly rotated\nellipses around the center of the screen, 1.0 means all bokeh highlights are\naligned vertically.";
ui_step = 0.01;
> = 0.0;
uniform float HighlightBoost <
ui_category = "Highlight tweaking";
ui_label="Highlight boost factor";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Will boost/dim the highlights a small amount";
ui_step = 0.001;
> = 0.90;
uniform float HighlightGammaFactor <
ui_category = "Highlight tweaking";
ui_label="Highlight gamma factor";
ui_type = "slider";
ui_min = 0.001; ui_max = 5.00;
ui_tooltip = "Controls the gamma factor to boost/dim highlights\n2.2, the default, gives natural colors and brightness";
ui_step = 0.01;
> = 2.2;
uniform float HighlightSharpeningFactor <
ui_category = "Highlight tweaking";
ui_label="Highlight sharpening factor";
ui_type = "slider";
ui_min = 0.000; ui_max = 1.00;
ui_tooltip = "Controls the sharpness of the bokeh highlight edges.";
ui_step = 0.01;
> = 0.0;
uniform int HighlightShape <
ui_category = "Highlight shape settings";
ui_type = "combo";
ui_label = "Highlight custom shape";
ui_items = "Circle (No custom shape)\0Heart / Custom (Preprocessor Definitions)\0Hexagon\0Circle with fringe\0Hexagon with fringe\0Star\0Square\0";
ui_tooltip = "Controls if a custom shape has to be used for the highlights.\nCircle means no custom shape.\nAnamorphic distortion only works with Circle";
ui_bind = "CINEMATIC_DOF_SHAPES";
> = 0;
#line 346
static const float HighlightShapeRotationAngle = 0.0;
static const float HighlightShapeGamma = 0.0;
#line 351
uniform bool MitigateUndersampling <
ui_category = "Advanced";
ui_label = "Mitigate undersampling";
ui_tooltip = "If you see bright pixels in the highlights,\ncheck this checkbox to smoothen the highlights.\nOnly needed with high blur factors and low blur quality.";
> = false;
uniform bool ShowCoCValues <
ui_category = "Advanced";
ui_label = "Show CoC values and focus plane";
ui_tooltip = "Shows blur disc size (CoC) as grey (far plane) and red (near plane) and focus plane as blue";
> = false;
#line 441
texture texCDCurrentFocus		{ Width = 1; Height = 1; Format = R16F; };		
texture texCDPreviousFocus		{ Width = 1; Height = 1; Format = R16F; };		
texture texCDCoC				{ Width = 1920; Height = 1018; Format = R16F; };
texture texCDCoCTileTmp			{ Width = 1920/1; Height = 1018/1; Format = R16F; };	
texture texCDCoCTile			{ Width = 1920/1; Height = 1018/1; Format = R16F; };	
texture texCDCoCTileNeighbor	{ Width = 1920/1; Height = 1018/1; Format = R16F; };	
texture texCDCoCTmp1			{ Width = 1920/2; Height = 1018/2; Format = R16F; };	
texture texCDCoCBlurred			{ Width = 1920/2; Height = 1018/2; Format = RG16F; };	
texture texCDBuffer1 			{ Width = 1920/2; Height = 1018/2; Format = RGBA16F; };
texture texCDBuffer2 			{ Width = 1920/2; Height = 1018/2; Format = RGBA16F; };
texture texCDBuffer3 			{ Width = 1920/2; Height = 1018/2; Format = RGBA16F; };
texture texCDBuffer4 			{ Width = 1920; Height = 1018; Format = RGBA16F; }; 	
texture texCDBuffer5 			{ Width = 1920; Height = 1018; Format = RGBA16F; }; 	
texture texCDNoise				< source = "pd80_gaussnoise.png"; > { Width = 512; Height = 512; Format = RGBA8; };
#line 468
texture texBokehShape1			< source = "moyheart.png"; > { Width = 512; Height = 512; Format = RGBA8; };
#line 471
sampler	SamplerCDCurrentFocus		{ Texture = texCDCurrentFocus; };
sampler SamplerCDPreviousFocus		{ Texture = texCDPreviousFocus; };
sampler SamplerCDBuffer1 			{ Texture = texCDBuffer1; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler SamplerCDBuffer2 			{ Texture = texCDBuffer2; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler SamplerCDBuffer3 			{ Texture = texCDBuffer3; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler SamplerCDBuffer4 			{ Texture = texCDBuffer4; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler SamplerCDBuffer5 			{ Texture = texCDBuffer5; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler SamplerCDCoC				{ Texture = texCDCoC; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler SamplerCDCoCTmp1			{ Texture = texCDCoCTmp1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler SamplerCDCoCBlurred			{ Texture = texCDCoCBlurred; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler SamplerCDCoCTileTmp			{ Texture = texCDCoCTileTmp; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler SamplerCDCoCTile			{ Texture = texCDCoCTile; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler SamplerCDCoCTileNeighbor	{ Texture = texCDCoCTileNeighbor; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler SamplerCDNoise				{ Texture = texCDNoise; MipFilter = POINT; MinFilter = POINT; MagFilter = POINT; AddressU = WRAP; AddressV = WRAP; AddressW = WRAP;};
#line 496
sampler SamplerCDBokehShape1		{ Texture = texBokehShape1; };
#line 499
uniform float2 MouseCoords < source = "mousepoint"; >;
uniform bool LeftMouseDown < source = "mousebutton"; keycode = 0; toggle = false; >;
#line 503
struct VSFOCUSINFO
{
float4 vpos : SV_Position;
float2 texcoord : TEXCOORD0;
float focusDepth : TEXCOORD1;
float focusDepthInM : TEXCOORD2;
float focusDepthInMM : TEXCOORD3;
float pixelSizeLength : TEXCOORD4;
float nearPlaneInMM : TEXCOORD5;
float farPlaneInMM : TEXCOORD6;
};
#line 515
struct VSDISCBLURINFO
{
float4 vpos : SV_Position;
float2 texcoord : TEXCOORD0;
float numberOfRings : TEXCOORD1;
float farPlaneMaxBlurInPixels : TEXCOORD2;
float nearPlaneMaxBlurInPixels : TEXCOORD3;
float cocFactorPerPixel : TEXCOORD4;
float highlightBoostFactor: TEXCOORD5;
};
#line 532
float3 ConeOverlap(float3 fragment)
{
float k = 0.4 * 0.33;
float2 f = float2(1-2 * k, k);
float3x3 m = float3x3(f.xyy, f.yxy, f.yyx);
return mul(fragment, m);
}
#line 540
float3 ConeOverlapInverse(float3 fragment)
{
float k = 0.4 * 0.33;
float2 f = float2(k-1, k) * rcp(3 * k-1);
float3x3 m = float3x3(f.xyy, f.yxy, f.yyx);
return mul(fragment, m);
}
#line 548
float3 AccentuateWhites(float3 fragment)
{
#line 552
fragment = pow(abs(ConeOverlap(fragment)), HighlightGammaFactor);
return fragment / max((1.001 - (HighlightBoost * fragment)), 0.001);
}
#line 556
float3 CorrectForWhiteAccentuation(float3 fragment)
{
#line 559
float3 toReturn = fragment / (1.001 + (HighlightBoost * fragment));
return ConeOverlapInverse(pow(abs(toReturn), 1.0/ HighlightGammaFactor));
}
#line 565
float4 CalculateAnamorphicFactor(float2 pixelVector)
{
const float normalizedFactor = lerp(1, HighlightAnamorphicFactor, lerp(length(pixelVector * 2), 1, HighlightAnamorphicSpreadFactor));
return float4(0, 1 + (1-normalizedFactor), normalizedFactor, 0);
}
#line 574
float2x2 CalculateAnamorphicRotationMatrix(float2 texcoord)
{
float2 pixelVector = normalize(texcoord - 0.5);
const float limiter = (1-HighlightAnamorphicAlignmentFactor)/2;
pixelVector.y = clamp(pixelVector.y, -limiter, limiter);
const float2 refVector = normalize(float2(-0.5, 0));
float2 sincosFactor = float2(0,0);
#line 582
sincos(atan2(pixelVector.y, pixelVector.x) - atan2(refVector.y, refVector.x), sincosFactor.x, sincosFactor.y);
return float2x2(sincosFactor.y, sincosFactor.x, -sincosFactor.x, sincosFactor.y);
}
#line 586
float2 MorphPointOffsetWithAnamorphicDeltas(float2 pointOffset, float4 anamorphicFactors, float2x2 anamorphicRotationMatrix)
{
pointOffset.x = pointOffset.x * anamorphicFactors.x + pointOffset.x*anamorphicFactors.z;
pointOffset.y = pointOffset.y * anamorphicFactors.y + pointOffset.y*anamorphicFactors.w;
return mul(pointOffset, anamorphicRotationMatrix);
}
#line 595
float PerformTileGatherHorizontal(sampler source, float2 texcoord)
{
const float tileSize = 1 * (float(float2(1920, 1018).x) / 1920.0f);
float minCoC = 10;
float coc;
float2 coordOffset = float2(float2((1.0 / 1920), (1.0 / 1018)).x, 0);
for(float i = 0; i <= tileSize; ++i)
{
coc = tex2Dlod(source, float4(texcoord + coordOffset, 0, 0)).r;
minCoC = min(minCoC, coc);
coc = tex2Dlod(source, float4(texcoord - coordOffset, 0, 0)).r;
minCoC = min(minCoC, coc);
coordOffset.x+=float2((1.0 / 1920), (1.0 / 1018)).x;
}
return minCoC;
}
#line 614
float PerformTileGatherVertical(sampler source, float2 texcoord)
{
const float tileSize = 1 * (float(float2(1920, 1018).y) / 1200.0f);
float minCoC = 10;
float coc;
float2 coordOffset = float2(0, float2((1.0 / 1920), (1.0 / 1018)).y);
[unroll]
for(float i = 0; i <= tileSize; ++i)
{
coc = tex2Dlod(source, float4(texcoord + coordOffset, 0, 0)).r;
minCoC = min(minCoC, coc);
coc = tex2Dlod(source, float4(texcoord - coordOffset, 0, 0)).r;
minCoC = min(minCoC, coc);
coordOffset.y+=float2((1.0 / 1920), (1.0 / 1018)).y;
}
return minCoC;
}
#line 633
float PerformNeighborTileGather(sampler source, float2 texcoord)
{
float minCoC = 10;
const float tileSizeX = 1 * (float(float2(1920, 1018).x) / 1920.0f);
const float tileSizeY = 1 * (float(float2(1920, 1018).y) / 1200.0f);
#line 640
const float2 baseCoordOffset = float2(float2((1.0 / 1920), (1.0 / 1018)).x * (tileSizeX*2+1), float2((1.0 / 1920), (1.0 / 1018)).x * (tileSizeY*2+1));
for(float i=-1;i<2;i++)
{
for(float j=-1;j<2;j++)
{
float2 coordOffset = float2(baseCoordOffset.x * i, baseCoordOffset.y * j);
float coc = tex2Dlod(source, float4(texcoord + coordOffset, 0, 0)).r;
minCoC = min(minCoC, coc);
}
}
return minCoC;
}
#line 657
float4 GetDebugFragment(float radius, bool showInFocus)
{
float4 toReturn = (radius/2 <= length(float2((1.0 / 1920), (1.0 / 1018)))) && showInFocus ? float4(0.0, 0.0, 1.0, 1.0) : float4(radius, radius, radius, 1.0);
if(radius < 0)
{
toReturn = float4(-radius, 0, 0, 1);
}
return toReturn;
}
#line 669
float4 GetShapeTap(float angle, float shapeRingDistance, sampler2D shapeSampler)
{
float2 pointOffsetForShape = float2(0,0);
#line 675
sincos(angle + (6.28318530717958 * HighlightShapeRotationAngle) + (6.28318530717958 * 0.75f), pointOffsetForShape.x, pointOffsetForShape.y);
pointOffsetForShape.y*=-1.0f;
float4 shapeTapCoords = float4((shapeRingDistance * pointOffsetForShape) + 0.5f, 0, 0);	
float4 shapeTap = tex2Dlod(shapeSampler, shapeTapCoords);
shapeTap.a = dot(shapeTap.rgb, float3(0.3, 0.59, 0.11));
return shapeTap;
}
#line 686
float CalculateBlurDiscSize(VSFOCUSINFO focusInfo)
{
const float pixelDepth = ReShade::GetLinearizedDepth(focusInfo.texcoord);
const float pixelDepthInM = pixelDepth * 1000.0;			
#line 700
const float cocInMM = (((FocalLength*FocalLength) / FNumber) / ((focusInfo.focusDepthInM/1000.0) -FocalLength)) *
(abs(pixelDepthInM - focusInfo.focusDepthInM) / (pixelDepthInM + (pixelDepthInM==0)));
const float toReturn = clamp(saturate(abs(cocInMM) * 0.024), 0, 1); 
return (pixelDepth < focusInfo.focusDepth) ? -toReturn : toReturn;
}
#line 708
float CalculateSampleWeight(float sampleRadiusInCoC, float ringDistanceInCoC)
{
return saturate(sampleRadiusInCoC - (ringDistanceInCoC * NearFarDistanceCompensation) + 0.5);
}
#line 722
float4 PerformNearPlaneDiscBlur(VSDISCBLURINFO blurInfo, sampler2D source, sampler2D shapeSampler)
{
float4 fragment = tex2Dlod(source, float4(blurInfo.texcoord, 0, 0));
#line 726
const float2 fragmentRadii = tex2Dlod(SamplerCDCoCBlurred, float4(blurInfo.texcoord, 0, 0)).rg;
const float fragmentRadiusToUse = fragmentRadii.r;
#line 729
if(fragmentRadii.r <=0)
{
#line 733
fragment.a = 0;
return fragment;
}
#line 738
const float numberOfRings = max(blurInfo.numberOfRings, 1) + 1;
const float pointsFirstRing = 7;
#line 741
float bokehBusyFactorToUse = saturate(1.0-BokehBusyFactor);		
float4 average = float4(fragment.rgb * fragmentRadiusToUse * bokehBusyFactorToUse, bokehBusyFactorToUse);
float2 pointOffset = float2(0,0);
const float nearPlaneBlurInPixels = blurInfo.nearPlaneMaxBlurInPixels * fragmentRadiusToUse;
const float2 ringRadiusDeltaCoords = float2((1.0 / 1920), (1.0 / 1018)) * (nearPlaneBlurInPixels / (numberOfRings-1));
float pointsOnRing = pointsFirstRing;
float2 currentRingRadiusCoords = ringRadiusDeltaCoords;
float4 anamorphicFactors = CalculateAnamorphicFactor(blurInfo.texcoord - 0.5); 
float2x2 anamorphicRotationMatrix = CalculateAnamorphicRotationMatrix(blurInfo.texcoord);
float4 shapeTap = float4(1.0f, 1.0f, 1.0f, 1.0f);
for(float ringIndex = 0; ringIndex < numberOfRings; ringIndex++)
{
float anglePerPoint = 6.28318530717958 / pointsOnRing;
float angle = anglePerPoint;
#line 756
float weight = lerp(ringIndex/numberOfRings, 1, smoothstep(0, 1, bokehBusyFactorToUse));
float shapeRingDistance = ((ringIndex+1)/numberOfRings) * 0.5f;
for(float pointNumber = 0; pointNumber < pointsOnRing; pointNumber++)
{
sincos(angle, pointOffset.y, pointOffset.x);
#line 768
pointOffset = MorphPointOffsetWithAnamorphicDeltas(pointOffset, anamorphicFactors, anamorphicRotationMatrix);
#line 770
float4 tapCoords = float4(blurInfo.texcoord + (pointOffset * currentRingRadiusCoords), 0, 0);
float4 tap = tex2Dlod(source, tapCoords);
#line 776
float2 sampleRadii = tex2Dlod(SamplerCDCoCBlurred, tapCoords).rg;
float blurredSampleRadius = sampleRadii.r;
float sampleWeight = weight * (shapeTap.a > 0.01 ? 1.0f : 0.0f);
average.rgb += tap.rgb * sampleWeight;
average.w += sampleWeight ;
angle+=anglePerPoint;
}
pointsOnRing+=pointsFirstRing;
currentRingRadiusCoords += ringRadiusDeltaCoords;
}
#line 787
average.rgb/=(average.w + (average.w ==0));
const float alpha = saturate((min(2.5, NearPlaneMaxBlur) + 0.4) * (fragmentRadiusToUse > 0.1 ? (fragmentRadii.g <=0 ? 2 : 1) * fragmentRadiusToUse : max(fragmentRadiusToUse, -fragmentRadii.g)));
fragment.rgb = average.rgb;
fragment.a = alpha;
#line 803
return fragment;
}
#line 813
float4 PerformDiscBlur(VSDISCBLURINFO blurInfo, sampler2D source, sampler2D shapeSampler)
{
const float pointsFirstRing = 7; 	
float4 fragment = tex2Dlod(source, float4(blurInfo.texcoord, 0, 0));
const float fragmentRadius = tex2Dlod(SamplerCDCoC, float4(blurInfo.texcoord, 0, 0)).r;
#line 819
if(fragmentRadius < 0 || blurInfo.farPlaneMaxBlurInPixels <=0)
{
#line 822
return fragment;
}
float bokehBusyFactorToUse = saturate(1.0-BokehBusyFactor);		
float4 average = float4(fragment.rgb * fragmentRadius * bokehBusyFactorToUse, bokehBusyFactorToUse);
float2 pointOffset = float2(0,0);
const float2 ringRadiusDeltaCoords =  (float2((1.0 / 1920), (1.0 / 1018)) * blurInfo.farPlaneMaxBlurInPixels * fragmentRadius) / blurInfo.numberOfRings;
float2 currentRingRadiusCoords = ringRadiusDeltaCoords;
const float cocPerRing = (fragmentRadius * FarPlaneMaxBlur) / blurInfo.numberOfRings;
float pointsOnRing = pointsFirstRing;
float4 anamorphicFactors = CalculateAnamorphicFactor(blurInfo.texcoord - 0.5); 
float2x2 anamorphicRotationMatrix = CalculateAnamorphicRotationMatrix(blurInfo.texcoord);
float4 shapeTap = float4(1.0f, 1.0f, 1.0f, 1.0f);
for(float ringIndex = 0; ringIndex < blurInfo.numberOfRings; ringIndex++)
{
float anglePerPoint = 6.28318530717958 / pointsOnRing;
float angle = anglePerPoint;
float ringWeight = lerp(ringIndex/blurInfo.numberOfRings, 1, bokehBusyFactorToUse);
float ringDistance = cocPerRing * ringIndex;
float shapeRingDistance = ((ringIndex+1)/blurInfo.numberOfRings) * 0.5f;
for(float pointNumber = 0; pointNumber < pointsOnRing; pointNumber++)
{
sincos(angle, pointOffset.y, pointOffset.x);
#line 851
pointOffset = MorphPointOffsetWithAnamorphicDeltas(pointOffset, anamorphicFactors, anamorphicRotationMatrix);
#line 853
float4 tapCoords = float4(blurInfo.texcoord + (pointOffset * currentRingRadiusCoords), 0, 0);
float sampleRadius = tex2Dlod(SamplerCDCoC, tapCoords).r;
float weight = (sampleRadius >=0) * ringWeight * CalculateSampleWeight(sampleRadius * FarPlaneMaxBlur, ringDistance) * (shapeTap.a > 0.01 ? 1.0f : 0.0f);
#line 858
weight *= (1.0 + min(FarPlaneMaxBlur, 3.0f) * saturate(fragmentRadius - sampleRadius));
float4 tap = tex2Dlod(source, tapCoords);
#line 863
average.rgb += tap.rgb * weight;
average.w += weight;
angle+=anglePerPoint;
}
pointsOnRing+=pointsFirstRing;
currentRingRadiusCoords += ringRadiusDeltaCoords;
}
fragment.rgb = average.rgb / (average.w + (average.w==0));
return fragment;
}
#line 880
float4 PerformPreDiscBlur(VSDISCBLURINFO blurInfo, sampler2D source)
{
const float radiusFactor = 1.0/max(blurInfo.numberOfRings, 1);
const float pointsFirstRing = max(blurInfo.numberOfRings-3, 2); 	
#line 885
float4 fragment = tex2Dlod(source, float4(blurInfo.texcoord, 0, 0));
fragment.rgb = AccentuateWhites(fragment.rgb);
if(!MitigateUndersampling)
{
#line 890
return fragment;
}
#line 893
float signedFragmentRadius = tex2Dlod(SamplerCDCoC, float4(blurInfo.texcoord, 0, 0)).x * radiusFactor;
float absoluteFragmentRadius = abs(signedFragmentRadius);
bool isNearPlaneFragment = signedFragmentRadius < 0;
const float blurFactorToUse = isNearPlaneFragment ? NearPlaneMaxBlur : FarPlaneMaxBlur;
#line 898
const float numberOfRings = max(blurInfo.numberOfRings-2, 1);
float4 average = absoluteFragmentRadius == 0 ? fragment : float4(fragment.rgb * absoluteFragmentRadius, absoluteFragmentRadius);
float2 pointOffset = float2(0,0);
#line 902
const float2 ringRadiusDeltaCoords = float2((1.0 / 1920), (1.0 / 1018))
* ((isNearPlaneFragment ? blurInfo.nearPlaneMaxBlurInPixels : blurInfo.farPlaneMaxBlurInPixels) *  absoluteFragmentRadius)
* rcp((numberOfRings-1) + (numberOfRings==1));
float pointsOnRing = pointsFirstRing;
float2 currentRingRadiusCoords = ringRadiusDeltaCoords;
const float cocPerRing = (signedFragmentRadius * blurFactorToUse) / numberOfRings;
for(float ringIndex = 0; ringIndex < numberOfRings; ringIndex++)
{
float anglePerPoint = 6.28318530717958 / pointsOnRing;
float angle = anglePerPoint;
float ringDistance = cocPerRing * ringIndex;
for(float pointNumber = 0; pointNumber < pointsOnRing; pointNumber++)
{
sincos(angle, pointOffset.y, pointOffset.x);
float4 tapCoords = float4(blurInfo.texcoord + (pointOffset * currentRingRadiusCoords), 0, 0);
float signedSampleRadius = tex2Dlod(SamplerCDCoC, tapCoords).x * radiusFactor;
float absoluteSampleRadius = abs(signedSampleRadius);
float isSamePlaneAsFragment = ((signedSampleRadius > 0 && !isNearPlaneFragment) || (signedSampleRadius <= 0 && isNearPlaneFragment));
float weight = CalculateSampleWeight(absoluteSampleRadius * blurFactorToUse, ringDistance) * isSamePlaneAsFragment *
(absoluteFragmentRadius - absoluteSampleRadius < 0.001);
float3 tap = tex2Dlod(source, tapCoords).rgb;
average.rgb += AccentuateWhites(tap.rgb) * weight;
average.w += weight;
angle+=anglePerPoint;
}
pointsOnRing+=pointsFirstRing;
currentRingRadiusCoords += ringRadiusDeltaCoords;
}
fragment.rgb = average.rgb/(average.w + (average.w==0));
return fragment;
}
#line 942
float GetBlurDiscRadiusFromSource(sampler2D source, float2 texcoord, bool flattenToZero)
{
const float coc = tex2Dlod(source, float4(texcoord, 0, 0)).r;
#line 947
return (flattenToZero && coc >= 0) ? 0 : abs(coc);
}
#line 959
float PerformSingleValueGaussianBlur(sampler2D source, float2 texcoord, float2 offsetWeight, bool flattenToZero)
{
const float offset[18] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4661974725, 21.4627427973, 23.4592916956, 25.455844494, 27.4524015179, 29.4489630909, 31.445529535, 33.4421011704 };
float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
#line 964
float coc = GetBlurDiscRadiusFromSource(source, texcoord, flattenToZero);
coc *= weight[0];
#line 967
float2 factorToUse = offsetWeight * NearPlaneMaxBlur * 0.8f;
for(int i = 1; i < 18; ++i)
{
float2 coordOffset = factorToUse * offset[i];
float weightSample = weight[i];
coc += GetBlurDiscRadiusFromSource(source, texcoord + coordOffset, flattenToZero) * weightSample;
coc += GetBlurDiscRadiusFromSource(source, texcoord - coordOffset, flattenToZero) * weightSample;
}
#line 976
return saturate(coc);
}
#line 985
float4 PerformFullFragmentGaussianBlur(sampler2D source, float2 texcoord, float2 offsetWeight)
{
const float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
const float3 lumaDotWeight = float3(0.3, 0.59, 0.11);
#line 991
const float coc = tex2Dlod(SamplerCDCoC, float4(texcoord, 0, 0)).r;
float4 fragment = tex2Dlod(source, float4(texcoord, 0, 0));
const float fragmentLuma = dot(fragment.rgb, lumaDotWeight);
const float4 originalFragment = fragment;
const float absoluteCoC = abs(coc);
const float lengthPixelSize = length(float2((1.0 / 1920), (1.0 / 1018)));
if(absoluteCoC < 0.2 || PostBlurSmoothing < 0.01 || fragmentLuma < 0.3)
{
#line 1000
return fragment;
}
fragment.rgb *= weight[0];
const float2 factorToUse = offsetWeight * PostBlurSmoothing;
for(int i = 1; i < 6; ++i)
{
float2 coordOffset = factorToUse * offset[i];
float weightSample = weight[i];
float sampleCoC = tex2Dlod(SamplerCDCoC, float4(texcoord + coordOffset, 0, 0)).r;
float maskFactor = abs(sampleCoC) < 0.2;		
fragment.rgb += (originalFragment.rgb * maskFactor * weightSample) +
(tex2Dlod(source, float4(texcoord + coordOffset, 0, 0)).rgb * (1-maskFactor) * weightSample);
sampleCoC = tex2Dlod(SamplerCDCoC, float4(texcoord - coordOffset, 0, 0)).r;
maskFactor = abs(sampleCoC) < 0.2;
fragment.rgb += (originalFragment.rgb * maskFactor * weightSample) +
(tex2Dlod(source, float4(texcoord - coordOffset, 0, 0)).rgb * (1-maskFactor) * weightSample);
}
return saturate(fragment);
}
#line 1022
void FillFocusInfoData(inout VSFOCUSINFO toFill)
{
#line 1029
toFill.focusDepth = tex2Dlod(SamplerCDCurrentFocus, float4(0, 0, 0, 0)).r;
toFill.focusDepthInM = toFill.focusDepth * 1000.0; 		
toFill.focusDepthInMM = toFill.focusDepthInM * 1000.0; 	
toFill.pixelSizeLength = length(float2((1.0 / 1920), (1.0 / 1018)));
#line 1035
float hyperFocal = (FocalLength * FocalLength) / (FNumber * 0.024);
float hyperFocalFocusDepthFocus = (hyperFocal * toFill.focusDepthInMM);
toFill.nearPlaneInMM = (hyperFocalFocusDepthFocus / (hyperFocal + (toFill.focusDepthInMM - FocalLength)));	
toFill.farPlaneInMM = hyperFocalFocusDepthFocus / (hyperFocal - (toFill.focusDepthInMM - FocalLength));		
}
#line 1043
float4 SharpeningPass_BlurSample(in sampler2D source, in float2 texcoord, in float2 xoff, in float2 yoff, in float centerCoC, inout float3 minv, inout float3 maxv)
{
float3 v11 = tex2D(source, texcoord + xoff).rgb;
float3 v12 = tex2D(source, texcoord + yoff).rgb;
float3 v21 = tex2D(source, texcoord - xoff).rgb;
float3 v22 = tex2D(source, texcoord - yoff).rgb;
float3 center = tex2D(source, texcoord).rgb;
#line 1051
float v11CoC = tex2D(SamplerCDCoC, texcoord + xoff).r;
float v12CoC = tex2D(SamplerCDCoC, texcoord + yoff).r;
float v21CoC = tex2D(SamplerCDCoC, texcoord - xoff).r;
float v22CoC = tex2D(SamplerCDCoC, texcoord - yoff).r;
float accepted = sign(centerCoC)==sign(v11CoC)? 1.0f: 0.0f;
accepted+= sign(centerCoC)==sign(v12CoC)? 1.0f: 0.0f;
accepted+= sign(centerCoC)==sign(v21CoC)? 1.0f: 0.0f;
accepted+= sign(centerCoC)==sign(v22CoC)? 1.0f: 0.0f;
#line 1061
minv = min(minv, v11);
minv = min(minv, v12);
minv = min(minv, v21);
minv = min(minv, v22);
#line 1066
maxv = max(maxv, v11);
maxv = max(maxv, v12);
maxv = max(maxv, v21);
maxv = max(maxv, v22);
return float4((v11 + v12 + v21 + v22 + 2.0 * center) * 0.166667, accepted);
}
#line 1075
float3 SharpeningPass_EdgeStrength(in float3 fragment, in sampler2D source, in float2 texcoord, in float sharpeningFactor)
{
const float spread = 0.5;
float2 offset = float2(1.0, 1.0) / float2(1920, 1018).xy;
float2 up    = float2(0.0, offset.y) * spread;
float2 right = float2(offset.x, 0.0) * spread;
#line 1082
float3 minv = 1000000000;
float3 maxv = 0;
#line 1085
float centerCoC = tex2D(SamplerCDCoC, texcoord).r;
float4 v12 = SharpeningPass_BlurSample(source, texcoord + up, 	right, up, centerCoC, minv, maxv);
float4 v21 = SharpeningPass_BlurSample(source, texcoord - right,right, up, centerCoC, minv, maxv);
float4 v22 = SharpeningPass_BlurSample(source, texcoord, 		right, up, centerCoC, minv, maxv);
float4 v23 = SharpeningPass_BlurSample(source, texcoord + right,right, up, centerCoC, minv, maxv);
float4 v32 = SharpeningPass_BlurSample(source, texcoord - up, 	right, up, centerCoC, minv, maxv);
#line 1092
float accepted = v12.a + v21.a + v23.a + v32.a;
if(accepted < 15.5)
{
#line 1096
return fragment;
}
#line 1099
float3 laplacian_of_g = v12.rgb + v21.rgb + v22.rgb * -4.0 + v23.rgb + v32.rgb;
return clamp(fragment - laplacian_of_g.rgb * sharpeningFactor, minv, maxv);
}
#line 1112
VSFOCUSINFO VS_Focus(in uint id : SV_VertexID)
{
VSFOCUSINFO focusInfo;
#line 1116
focusInfo.texcoord.x = (id == 2) ? 2.0 : 0.0;
focusInfo.texcoord.y = (id == 1) ? 2.0 : 0.0;
focusInfo.vpos = float4(focusInfo.texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 1129
FillFocusInfoData(focusInfo);
#line 1131
return focusInfo;
}
#line 1135
VSDISCBLURINFO VS_DiscBlur(in uint id : SV_VertexID)
{
VSDISCBLURINFO blurInfo;
#line 1139
blurInfo.texcoord.x = (id == 2) ? 2.0 : 0.0;
blurInfo.texcoord.y = (id == 1) ? 2.0 : 0.0;
blurInfo.vpos = float4(blurInfo.texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 1143
blurInfo.numberOfRings = round(BlurQuality);
float pixelSizeLength = length(float2((1.0 / 1920), (1.0 / 1018)));
blurInfo.farPlaneMaxBlurInPixels = (FarPlaneMaxBlur / 100.0) / pixelSizeLength;
blurInfo.nearPlaneMaxBlurInPixels = (NearPlaneMaxBlur / 100.0) / pixelSizeLength;
blurInfo.cocFactorPerPixel = length(float2((1.0 / 1920), (1.0 / 1018))) * blurInfo.farPlaneMaxBlurInPixels;	
return blurInfo;
}
#line 1158
void PS_DetermineCurrentFocus(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float fragment : SV_Target0)
{
const float2 autoFocusPointToUse = UseMouseDrivenAutoFocus ? MouseCoords * float2((1.0 / 1920), (1.0 / 1018)) : AutoFocusPoint;
fragment = UseAutoFocus ? lerp(tex2D(SamplerCDPreviousFocus, float2(0, 0)).r, ReShade::GetLinearizedDepth(autoFocusPointToUse), AutoFocusTransitionSpeed)
: (ManualFocusPlane / 1000);
}
#line 1166
void PS_CopyCurrentFocus(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float fragment : SV_Target0)
{
fragment = tex2D(SamplerCDCurrentFocus, float2(0, 0)).r;
}
#line 1172
void PS_CalculateCoCValues(VSFOCUSINFO focusInfo, out float fragment : SV_Target0)
{
#line 1177
fragment = CalculateBlurDiscSize(focusInfo);
}
#line 1182
void PS_PreBlur(VSDISCBLURINFO blurInfo, out float4 fragment : SV_Target0)
{
fragment = PerformPreDiscBlur(blurInfo, ReShade::BackBuffer);
}
#line 1188
void PS_BokehBlur(VSDISCBLURINFO blurInfo, out float4 fragment : SV_Target0)
{
#line 1201
fragment = PerformDiscBlur(blurInfo, SamplerCDBuffer1, SamplerCDBokehShape1);
#line 1203
}
#line 1207
void PS_NearBokehBlur(VSDISCBLURINFO blurInfo, out float4 fragment : SV_Target0)
{
#line 1220
fragment = PerformNearPlaneDiscBlur(blurInfo, SamplerCDBuffer2, SamplerCDBokehShape1);
#line 1222
}
#line 1225
void PS_CoCTile1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float fragment : SV_Target0)
{
fragment = PerformTileGatherHorizontal(SamplerCDCoC, texcoord);
}
#line 1231
void PS_CoCTile2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float fragment : SV_Target0)
{
fragment = PerformTileGatherVertical(SamplerCDCoCTileTmp, texcoord);
}
#line 1237
void PS_CoCTileNeighbor(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float fragment : SV_Target0)
{
fragment = PerformNeighborTileGather(SamplerCDCoCTile, texcoord);
}
#line 1243
void PS_CoCGaussian1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float fragment : SV_Target0)
{
#line 1246
fragment = PerformSingleValueGaussianBlur(SamplerCDCoCTileNeighbor, texcoord,
float2(float2((1.0 / 1920), (1.0 / 1018)).x * (float2(1920, 1018).x/1920.0f), 0.0), true);
}
#line 1251
void PS_CoCGaussian2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float2 fragment : SV_Target0)
{
#line 1254
fragment = float2(PerformSingleValueGaussianBlur(SamplerCDCoCTmp1, texcoord,
float2(0.0, float2((1.0 / 1920), (1.0 / 1018)).y * (float2(1920, 1018).y/1200.0f)), false),
tex2D(SamplerCDCoCTileNeighbor, texcoord).x);
}
#line 1260
void PS_Combiner(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target0)
{
#line 1263
float4 originalFragment = tex2D(ReShade::BackBuffer, texcoord);
originalFragment.rgb = AccentuateWhites(originalFragment.rgb);
float4 farFragment = tex2D(SamplerCDBuffer3, texcoord);
float4 nearFragment = tex2D(SamplerCDBuffer1, texcoord);
float pixelCoC = tex2D(SamplerCDCoC, texcoord).r;
#line 1269
float realCoC = pixelCoC * clamp(0, 1, FarPlaneMaxBlur);
if(HighlightSharpeningFactor > 0.0f)
{
#line 1273
float sharpeningFactor = abs(pixelCoC) * 80.0 * HighlightSharpeningFactor;		
farFragment.rgb = SharpeningPass_EdgeStrength(farFragment.rgb, SamplerCDBuffer3, texcoord, sharpeningFactor * realCoC);
nearFragment.rgb = SharpeningPass_EdgeStrength(nearFragment.rgb, SamplerCDBuffer1, texcoord, sharpeningFactor * (abs(pixelCoC) * clamp(0, 1, NearPlaneMaxBlur)));
}
#line 1279
const float blendFactor = (realCoC > 0.1) ? 1 : smoothstep(0, 1, (realCoC / 0.1));
fragment = lerp(originalFragment, farFragment, blendFactor);
fragment.rgb = lerp(fragment.rgb, nearFragment.rgb, nearFragment.a * (NearPlaneMaxBlur != 0));
#line 1288
fragment.rgb = CorrectForWhiteAccentuation(fragment.rgb);
fragment.a = 1.0;
}
#line 1295
void PS_TentFilter(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target0)
{
const float4 coord = float2((1.0 / 1920), (1.0 / 1018)).xyxy * float4(1, 1, -1, 0);
float4 average;
average = tex2D(SamplerCDBuffer2, texcoord - coord.xy);
average += tex2D(SamplerCDBuffer2, texcoord - coord.wy) * 2;
average += tex2D(SamplerCDBuffer2, texcoord - coord.zy);
average += tex2D(SamplerCDBuffer2, texcoord + coord.zw) * 2;
average += tex2D(SamplerCDBuffer2, texcoord) * 4;
average += tex2D(SamplerCDBuffer2, texcoord + coord.xw) * 2;
average += tex2D(SamplerCDBuffer2, texcoord + coord.zy);
average += tex2D(SamplerCDBuffer2, texcoord + coord.wy) * 2;
average += tex2D(SamplerCDBuffer2, texcoord + coord.xy);
fragment = average / 16;
}
#line 1313
void PS_PostSmoothing1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target0)
{
fragment = PerformFullFragmentGaussianBlur(SamplerCDBuffer4, texcoord, float2(float2((1.0 / 1920), (1.0 / 1018)).x, 0.0));
}
#line 1322
void PS_PostSmoothing2AndFocusing(in VSFOCUSINFO focusInfo, out float4 fragment : SV_Target0)
{
if(ShowCoCValues)
{
fragment = GetDebugFragment(tex2D(SamplerCDCoC, focusInfo.texcoord).r, true);
return;
}
#line 1351
fragment = PerformFullFragmentGaussianBlur(SamplerCDBuffer5, focusInfo.texcoord, float2(0.0, float2((1.0 / 1920), (1.0 / 1018)).y));
float4 originalFragment = tex2D(SamplerCDBuffer4, focusInfo.texcoord);
#line 1354
float2 uv = float2(1920, 1018) / float2( 512.0f, 512.0f ); 
uv.xy = uv.xy * focusInfo.texcoord.xy;
float noise = tex2D(SamplerCDNoise, uv).x; 
fragment.xyz = saturate(fragment.xyz + lerp( -0.5/255.0, 0.5/255.0, noise)); 
#line 1359
float coc = abs(tex2Dlod(SamplerCDCoC, float4(focusInfo.texcoord, 0, 0)).r);
fragment.rgb = lerp(originalFragment.rgb, fragment.rgb, saturate(coc < length(float2((1.0 / 1920), (1.0 / 1018))) ? 0 : 4 * coc));
fragment.w = 1.0;
#line 1366
if(ShowOutOfFocusPlaneOnMouseDown && LeftMouseDown)
{
const float depthPixelInMM = ReShade::GetLinearizedDepth(focusInfo.texcoord) * 1000.0 * 1000.0;
float4 colorToBlend = fragment;
if(depthPixelInMM < focusInfo.nearPlaneInMM || (focusInfo.farPlaneInMM > 0 && depthPixelInMM > focusInfo.farPlaneInMM))
{
colorToBlend = float4(OutOfFocusPlaneColor, 1.0);
}
else
{
if(abs(coc) < focusInfo.pixelSizeLength)
{
colorToBlend = float4(FocusPlaneColor, 1.0);
}
}
fragment = lerp(fragment, colorToBlend, OutOfFocusPlaneColorTransparency);
if(UseAutoFocus)
{
const float2 focusPointCoords = UseMouseDrivenAutoFocus ? MouseCoords * float2((1.0 / 1920), (1.0 / 1018)) : AutoFocusPoint;
fragment = lerp(fragment, FocusCrosshairColor, FocusCrosshairColor.w * saturate(exp(-1920 * length(focusInfo.texcoord - float2(focusPointCoords.x, focusInfo.texcoord.y)))));
fragment = lerp(fragment, FocusCrosshairColor, FocusCrosshairColor.w * saturate(exp(-1018 * length(focusInfo.texcoord - float2(focusInfo.texcoord.x, focusPointCoords.y)))));
}
}
#line 1390
}
#line 1398
technique CinematicDOF
< ui_tooltip = "Cinematic Depth of Field "
"v1.2.10"
"\n===========================================\n\n"
"Cinematic Depth of Field is a state of the art depth of field shader,\n"
"offering fine-grained control over focusing, blur aspects and highlights,\n"
"using real-life lens aspects. Cinematic Depth of Field is based on\n"
"various papers, of which the references are included in the source code.\n\n"
"Cinematic Depth of Field was written by Frans 'Otis_Inf' Bouma and is part of OtisFX\n"
"https://fransbouma.com | https://github.com/FransBouma/OtisFX"; >
{
pass DetermineCurrentFocus { VertexShader = PostProcessVS; PixelShader = PS_DetermineCurrentFocus; RenderTarget = texCDCurrentFocus; }
pass CopyCurrentFocus { VertexShader = PostProcessVS; PixelShader = PS_CopyCurrentFocus; RenderTarget = texCDPreviousFocus; }
pass CalculateCoC { VertexShader = VS_Focus; PixelShader = PS_CalculateCoCValues; RenderTarget = texCDCoC; }
pass CoCTile1 { VertexShader = PostProcessVS; PixelShader = PS_CoCTile1; RenderTarget = texCDCoCTileTmp; }
pass CoCTile2 { VertexShader = PostProcessVS; PixelShader = PS_CoCTile2; RenderTarget = texCDCoCTile; }
pass CoCTileNeighbor { VertexShader = PostProcessVS; PixelShader = PS_CoCTileNeighbor; RenderTarget = texCDCoCTileNeighbor; }
pass CoCBlur1 { VertexShader = PostProcessVS; PixelShader = PS_CoCGaussian1; RenderTarget = texCDCoCTmp1; }
pass CoCBlur2 { VertexShader = PostProcessVS; PixelShader = PS_CoCGaussian2; RenderTarget = texCDCoCBlurred; }
pass PreBlur { VertexShader = VS_DiscBlur; PixelShader = PS_PreBlur; RenderTarget = texCDBuffer1; }
pass BokehBlur { VertexShader = VS_DiscBlur; PixelShader = PS_BokehBlur; RenderTarget = texCDBuffer2; }
pass NearBokehBlur { VertexShader = VS_DiscBlur; PixelShader = PS_NearBokehBlur; RenderTarget = texCDBuffer1; }
pass TentFilter { VertexShader = PostProcessVS; PixelShader = PS_TentFilter; RenderTarget = texCDBuffer3; }
pass Combiner { VertexShader = PostProcessVS; PixelShader = PS_Combiner; RenderTarget = texCDBuffer4; }
pass PostSmoothing1 { VertexShader = PostProcessVS; PixelShader = PS_PostSmoothing1; RenderTarget = texCDBuffer5; }
pass PostSmoothing2AndFocusing { VertexShader = VS_Focus; PixelShader = PS_PostSmoothing2AndFocusing;}
}
}

