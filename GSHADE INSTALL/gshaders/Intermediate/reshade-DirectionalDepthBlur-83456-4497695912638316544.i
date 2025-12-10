#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\DirectionalDepthBlur.fx"
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
#line 49 "C:\Program Files\GShade\gshade-shaders\Shaders\DirectionalDepthBlur.fx"
#line 50
namespace DirectionalDepthBlur
{
#line 63
uniform float FocusPlane <
ui_category = "Focusing";
ui_label= "Focus plane";
ui_type = "slider";
ui_min = 0.001; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "The depth of the plane where the blur starts, related to the camera";
> = 0.010;
uniform float FocusRange <
ui_category = "Focusing";
ui_label= "Focus range";
ui_type = "slider";
ui_min = 0.001; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "The range around the focus plane that's more or less not blurred.\n1.0 is the FocusPlaneMaxRange.";
> = 0.001;
uniform float FocusPlaneMaxRange <
ui_category = "Focusing";
ui_label= "Focus plane max range";
ui_type = "slider";
ui_min = 10; ui_max = 300;
ui_step = 1;
ui_tooltip = "The max range Focus Plane for when Focus Plane is 1.0.\n1000 is the horizon.";
> = 150;
uniform float BlurAngle <
ui_category = "Blur tweaking";
ui_label="Blur angle";
ui_type = "slider";
ui_min = 0.01; ui_max = 1.00;
ui_tooltip = "The angle of the blur direction";
ui_step = 0.01;
> = 1.0;
uniform float BlurLength <
ui_category = "Blur tweaking";
ui_label = "Blur length";
ui_type = "slider";
ui_min = 0.000; ui_max = 1.0;
ui_step = 0.001;
ui_tooltip = "The length of the blur strokes per pixel. 1.0 is the entire screen.";
> = 0.1;
uniform float BlurQuality <
ui_category = "Blur tweaking";
ui_label = "Blur quality";
ui_type = "slider";
ui_min = 0.01; ui_max = 1.0;
ui_step = 0.01;
ui_tooltip = "The quality of the blur. 1.0 means all pixels in the blur length are\nread, 0.5 means half of them are read.";
> = 0.5;
uniform float ScaleFactor <
ui_category = "Blur tweaking";
ui_label = "Scale factor";
ui_type = "slider";
ui_min = 0.010; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "The scale factor for the pixels to blur. Lower values downscale the\nsource frame and will result in wider blur strokes.";
> = 1.000;
uniform int BlurType <
ui_category = "Blur tweaking";
ui_type = "combo";
ui_min= 0; ui_max=1;
ui_items="Parallel Strokes\0Focus Point Targeting Strokes\0";
ui_label = "The blur type";
ui_tooltip = "The blur type. Focus Point Targeting Strokes means the blur directions\nper pixel are towards the Focus Point.";
> = 0;
uniform float2 FocusPoint <
ui_category = "Blur tweaking, Focus Point";
ui_label = "Blur focus point";
ui_type = "slider";
ui_step = 0.001;
ui_min = 0.000; ui_max = 1.000;
ui_tooltip = "The X and Y coordinates of the blur focus point, which is used for\nthe Blur type 'Focus Point Targeting Strokes'. 0,0 is the\nupper left corner, and 0.5, 0.5 is at the center of the screen.";
> = float2(0.5, 0.5);
uniform float3 FocusPointBlendColor <
ui_category = "Blur tweaking, Focus Point";
ui_label = "Color";
ui_type= "color";
ui_tooltip = "The color of the focus point in Point focused mode. The closer a\npixel is to the focus point, the more it will become this color.\nIn (red , green, blue)";
> = float3(0.0,0.0,0.0);
uniform float FocusPointBlendFactor <
ui_category = "Blur tweaking, Focus Point";
ui_label = "Color blend factor";
ui_type = "slider";
ui_min = 0.000; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "The factor with which the focus point color is blended with the final image";
> = 1.000;
uniform bool FocusPointViewFilterCircleOnMouseDown <
ui_category = "Blur tweaking, Focus Point";
ui_label = "Show filter circle on mouse down";
ui_tooltip = "For Focus Point Targeting Strokes blur type:\nIf checked, an overlay is shown with the current filter circle.\nWhite means blur will be present,\ntransparent means no blur will be present";
> = false;
uniform bool FocusPointFadeBlurInFeatherBand <
ui_category = "Blur tweaking, Focus Point";
ui_label = "Fade blur in feather band";
ui_tooltip = "For Focus Point Targeting Strokes blur type:\nIf checked, it'll fade out the blur in the feather area in the filter circle";
> = false;
uniform bool FlipFadeBlurInFeatherBand <
ui_category = "Blur tweaking, Focus Point";
ui_label = "Flip feather band";
ui_tooltip = "For Focus Point Targeting Strokes blur type:\nIf checked, it'll flip the feather band from being towards the center to towards the edges";
> = false;
uniform bool FlipFocusPointTargetingBlurDirection <
ui_category = "Blur tweaking, Focus Point";
ui_label = "Flip Focus Point Targeting strokes blur direction";
ui_tooltip = "For Focus Point Targeting Strokes blur type:\nIf checked, it'll flip the direction of the blur from inside-to-outside to outside-to-inside";
> = false;
uniform float FilterCircleRadius <
ui_category = "Blur tweaking, Focus Point";
ui_label = "Filter circle radius";
ui_type = "slider";
ui_min = 0.000; ui_max = 2.000;
ui_step = 0.001;
ui_tooltip = "For Focus Point Targeting Strokes blur type:\nThe radius of the filter circle.\nAll points within this circle are not or only partially blurred";
> = 0.1;
uniform float2 FilterCircleDeformFactors <
ui_category = "Blur tweaking, Focus Point";
ui_label = "Filter circle deform factors";
ui_type = "slider";
ui_min = 0.000; ui_max = 2.000;
ui_step = 0.001;
ui_tooltip = "For Focus Point Targeting Strokes blur type:\nThe radius factors for width and height of the filter circle.\n1.0 means no deformation, another value means deformation in that direction";
> = float2(1.0, 1.0);
uniform float FilterCircleRotationFactor <
ui_category = "Blur tweaking, Focus Point";
ui_label = "Filter circle rotation factor";
ui_type = "slider";
ui_min = 0.000; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "For Focus Point Targeting Strokes blur type:\nThe rotation factor of the filter circle";
> = 0.0;
uniform float FilterCircleFeather <
ui_category = "Blur tweaking, Focus Point";
ui_label = "Filter circle feather";
ui_type = "slider";
ui_min = 0.000; ui_max = 1.000;
ui_step = 0.001;
ui_tooltip = "For Focus Point Targeting Strokes blur type:\nThe feather area within the filter circle.\n1.0 means the whole inner area is feathered,\n0.0 means no feather area.";
> = 0.1;
#line 202
uniform float HighlightGain <
ui_category = "Blur tweaking";
ui_label="Highlight gain";
ui_type = "slider";
ui_min = 0.00; ui_max = 10.00;
ui_tooltip = "The gain for highlights in the strokes plane. The higher the more a highlight gets\nbrighter.";
ui_step = 0.01;
> = 0.5;
uniform float BlendFactor <
ui_category = "Blur tweaking";
ui_label="Blend factor";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "How strong the effect is applied to the original image. 1.0 is 100%, 0.0 is 0%.";
ui_step = 0.01;
> = 1.000;
#line 252
uniform float2 MouseCoords < source = "mousepoint"; >;
uniform bool LeftMouseDown < source = "mousebutton"; keycode = 0; toggle = false; >;
#line 255
texture texDownsampledBackBuffer { Width = 1920; Height = 1018; Format = RGBA16F; };
texture texBlurDestination { Width = 1920; Height = 1018; Format = RGBA16F; };
texture texFilterCircle { Width = 1920; Height = 1018; Format = R16F; };
#line 259
sampler samplerDownsampledBackBuffer { Texture = texDownsampledBackBuffer; AddressU = MIRROR; AddressV = MIRROR; AddressW = MIRROR;};
sampler samplerBlurDestination { Texture = texBlurDestination; };
sampler samplerFilterCircle { Texture = texFilterCircle; };
#line 263
struct VSPIXELINFO
{
float4 vpos : SV_Position;
float2 texCoords : TEXCOORD0;
float2 pixelDelta: TEXCOORD1;
float blurLengthInPixels: TEXCOORD2;
float focusPlane: TEXCOORD3;
float focusRange: TEXCOORD4;
float4 texCoordsScaled: TEXCOORD5;
float2x2 rotationMatrix: TEXCOORD6;
float2 centerDisplacementDelta: TEXCOORD8;
float featherRadius: TEXCOORD9;
};
#line 283
float2 CalculatePixelDeltas(float2 texCoords)
{
float2 newCoords = (FlipFocusPointTargetingBlurDirection && BlurType==1) ? float2(texCoords.x - FocusPoint.x, texCoords.y - FocusPoint.y)
: float2(FocusPoint.x - texCoords.x, FocusPoint.y - texCoords.y);
return newCoords * length(float2((1.0 / 1920), (1.0 / 1018)));
}
#line 290
float3 AccentuateWhites(float3 fragment)
{
return fragment / (1.5 - clamp(fragment, 0, 1.49));	
}
#line 295
float3 CorrectForWhiteAccentuation(float3 fragment)
{
return (fragment.rgb * 1.5) / (1.0 + fragment.rgb);		
}
#line 300
float3 PostProcessBlurredFragment(float3 fragment, float maxLuma, float3 averageGained, float normalizationFactor)
{
const float3 lumaDotWeight = float3(0.3, 0.59, 0.11);
#line 304
float newFragmentLuma = dot(fragment, lumaDotWeight);
averageGained.rgb = CorrectForWhiteAccentuation(averageGained.rgb);
#line 308
averageGained.rgb *= 1+saturate(maxLuma-newFragmentLuma);
fragment = (1-normalizationFactor) * fragment + normalizationFactor * averageGained.rgb;
return fragment;
}
#line 319
VSPIXELINFO VS_PixelInfo(in uint id : SV_VertexID)
{
VSPIXELINFO pixelInfo;
#line 323
pixelInfo.texCoords.x = (id == 2) ? 2.0 : 0.0;
pixelInfo.texCoords.y = (id == 1) ? 2.0 : 0.0;
pixelInfo.vpos = float4(pixelInfo.texCoords * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
float angleToUse = 6.28318530717958 * BlurAngle;
sincos(angleToUse, pixelInfo.pixelDelta.y, pixelInfo.pixelDelta.x);
float pixelSizeLength = length(float2((1.0 / 1920), (1.0 / 1018)));
pixelInfo.pixelDelta *= pixelSizeLength;
pixelInfo.blurLengthInPixels = length(float2(1920, 1018)) * BlurLength;
pixelInfo.focusPlane = (FocusPlane * FocusPlaneMaxRange) / 1000.0;
pixelInfo.focusRange = (FocusRange * FocusPlaneMaxRange) / 1000.0;
pixelInfo.texCoordsScaled = float4(pixelInfo.texCoords * ScaleFactor, pixelInfo.texCoords / ScaleFactor);
#line 335
float2 sincosFactor = float2(0,0);
sincos(6.28318530717958 * FilterCircleRotationFactor, sincosFactor.x, sincosFactor.y);
pixelInfo.rotationMatrix = float2x2(sincosFactor.y, sincosFactor.x, -sincosFactor.x, sincosFactor.y);
#line 339
pixelInfo.centerDisplacementDelta = FocusPoint - float2(0.5, 0.5);
pixelInfo.featherRadius = FilterCircleRadius - (FilterCircleRadius * FilterCircleFeather);
return pixelInfo;
}
#line 350
void PS_Blur(VSPIXELINFO pixelInfo, out float4 fragment : SV_Target0)
{
const float3 lumaDotWeight = float3(0.3, 0.59, 0.11);
#line 354
float filterCircleValue = tex2Dlod(samplerFilterCircle, float4(pixelInfo.texCoords, 0, 0)).r;
#line 356
float3 color = tex2Dlod(samplerDownsampledBackBuffer, float4(pixelInfo.texCoordsScaled.xy, 0, 0)).rgb;
float4 average = float4(color, 1.0);
float3 averageGained = AccentuateWhites(average.rgb);
float2 pixelDelta = BlurType==0 ? pixelInfo.pixelDelta : CalculatePixelDeltas(pixelInfo.texCoords);
float maxLuma = dot(averageGained.rgb, lumaDotWeight);
float blurLengthInPixels = pixelInfo.blurLengthInPixels;
float alpha = 0.0f;
float highlightGainToUse = HighlightGain;
if(BlurType==1)
{
blurLengthInPixels *= filterCircleValue;
highlightGainToUse *= filterCircleValue;
}
for(float tapIndex=0.0;tapIndex<blurLengthInPixels;tapIndex+=(1/BlurQuality))
{
float2 tapCoords = saturate(pixelInfo.texCoords + (pixelDelta * tapIndex));
#line 373
float3 tapColor = tex2Dlod(samplerDownsampledBackBuffer, float4(tapCoords * (ScaleFactor-0.001), 0, 0)).rgb;
float tapDepth = ReShade::GetLinearizedDepth(tapCoords);
float weight = tapDepth <= pixelInfo.focusPlane ? 0.0 : 1-(tapIndex / (blurLengthInPixels + (blurLengthInPixels==0)));
average.rgb+=(tapColor * weight);
average.a+=weight;
float3 gainedTap = AccentuateWhites(tapColor.rgb);
averageGained += gainedTap * weight;
float lumaSample = saturate(dot(gainedTap, lumaDotWeight));
maxLuma = weight > 0 ? max(maxLuma, lumaSample) : maxLuma;
alpha = 1.0f;
}
float distanceToFocusPoint = distance(pixelInfo.texCoords, FocusPoint);
fragment.rgb = average.rgb / (average.a + (average.a==0));
fragment.rgb = BlurType==0
? fragment.rgb
: lerp(fragment.rgb, saturate(lerp(FocusPointBlendColor, fragment.rgb, smoothstep(0, 1, distanceToFocusPoint))), FocusPointBlendFactor);
#line 390
float blendFactorToUse = BlendFactor * (BlurType==0 ? 1.0 : filterCircleValue);
fragment.rgb = lerp(color, PostProcessBlurredFragment(fragment.rgb, saturate(maxLuma), (averageGained / (average.a + (average.a==0))), highlightGainToUse), blendFactorToUse);
fragment.a = alpha;
}
#line 396
void PS_Combiner(VSPIXELINFO pixelInfo, out float3 fragment : SV_Target0)
{
float colorDepth = ReShade::GetLinearizedDepth(pixelInfo.texCoords);
float3 realColor = tex2Dlod(ReShade::BackBuffer, float4(pixelInfo.texCoords, 0, 0)).rgb;
float filterCircleValue = tex2Dlod(samplerFilterCircle, float4(pixelInfo.texCoords, 0, 0)).r;
if(colorDepth <= pixelInfo.focusPlane || (BlurLength <= 0.0))
{
fragment = realColor;
return;
}
float4 color = tex2Dlod(samplerBlurDestination, float4(pixelInfo.texCoords, 0, 0));
float rangeEnd = (pixelInfo.focusPlane+pixelInfo.focusRange);
float blendFactor = rangeEnd < colorDepth
? 1.0
: smoothstep(0, 1, 1-((rangeEnd-colorDepth) / pixelInfo.focusRange));
#line 412
if(BlurType==1 && FocusPointFadeBlurInFeatherBand)
{
blendFactor *= filterCircleValue;
}
fragment.rgb = lerp(realColor.rgb, color.rgb, blendFactor * color.a);
if(FocusPointViewFilterCircleOnMouseDown && LeftMouseDown && BlurType==1)
{
fragment.rgb = lerp(fragment.rgb, float3(1.0f, 1.0f, 1.0f), filterCircleValue * 0.7f);
}
}
#line 423
void PS_DownSample(VSPIXELINFO pixelInfo, out float4 fragment : SV_Target0)
{
#line 426
float2 sourceCoords = pixelInfo.texCoordsScaled.zw;
if(max(sourceCoords.x, sourceCoords.y) > 1.0001)
{
#line 430
discard;
}
fragment = tex2D(ReShade::BackBuffer, sourceCoords);
}
#line 436
void PS_CreateFilterCircle(VSPIXELINFO pixelInfo, out float4 fragment : SV_Target0)
{
fragment = 0.0f;
if(BlurType!=1)
{
return;
}
#line 446
float2 texcoordCenterNormalized = mul(((pixelInfo.texCoords-pixelInfo.centerDisplacementDelta) - 0.5), pixelInfo.rotationMatrix) * FilterCircleDeformFactors;
float2 focusPointCenterNormalized = (FocusPoint-pixelInfo.centerDisplacementDelta) - 0.5;
float texcoordDistance = distance(texcoordCenterNormalized, focusPointCenterNormalized);
#line 451
if(texcoordDistance < pixelInfo.featherRadius)
{
#line 454
fragment = 0.0f;
}
else
{
if(texcoordDistance > FilterCircleRadius)
{
#line 461
fragment = 1.0f;
}
else
{
#line 466
float featherbandWidth = FilterCircleRadius - pixelInfo.featherRadius;
fragment = lerp(0.0f, 1.0f, (texcoordDistance - pixelInfo.featherRadius) / (featherbandWidth + (featherbandWidth==0)));
}
}
if(FlipFadeBlurInFeatherBand)
{
fragment = 1.0 - fragment;
}
}
#line 482
technique DirectionalDepthBlur
< ui_tooltip = "Directional Depth Blur "
"v1.5"
"\n===========================================\n\n"
"Directional Depth Blur is a shader for adding far plane directional blur\n"
"based on the depth of each pixel\n\n"
"Directional Depth Blur was written by Frans 'Otis_Inf' Bouma and is part of OtisFX\n"
"https://fransbouma.com | https://github.com/FransBouma/OtisFX"; >
{
pass CreateFilterCircle { VertexShader = VS_PixelInfo; PixelShader = PS_CreateFilterCircle; RenderTarget = texFilterCircle; }
pass Downsample { VertexShader = VS_PixelInfo ; PixelShader = PS_DownSample; RenderTarget = texDownsampledBackBuffer; }
pass BlurPass { VertexShader = VS_PixelInfo; PixelShader = PS_Blur; RenderTarget = texBlurDestination; }
pass Combiner { VertexShader = VS_PixelInfo; PixelShader = PS_Combiner; }
}
}

