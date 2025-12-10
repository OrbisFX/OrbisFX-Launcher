// ITU_REC=709
// TILT_SHIFT_MAX_SAMPLES=128u
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\TiltShift.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 57
namespace ReShade
{
float GetAspectRatio() { return 1280 * (1.0 / 720); }
float2 GetPixelSize() { return float2((1.0 / 1280), (1.0 / 720)); }
float2 GetScreenSize() { return float2(1280, 720); }
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
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\TiltShift.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\TiltShift.fx"
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
#line 33 "C:\Program Files\GShade\gshade-shaders\Shaders\TiltShift.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\TiltShift.fx"
#line 41
uniform float4 K
<
ui_type = "drag";
ui_min = -0.2; ui_max = 0.2;
ui_label = "Distortion profile 'k'";
ui_tooltip = "Distortion coefficients K1, K2, K3, K4";
ui_category = "Tilt-shift blur";
> = float4(0.025, 0f, 0f, 0f);
#line 50
uniform int BlurAngle
<
ui_type = "slider";
ui_min = -90; ui_max = 90;
ui_units = "°";
ui_label = "Tilt angle";
ui_tooltip = "Tilt the blur line.";
ui_category = "Tilt-shift blur";
> = 0;
#line 60
uniform float BlurOffset
<
ui_type = "slider";
ui_min = -1f; ui_max = 1f; ui_step = 0.01;
ui_label = "Line offset";
ui_tooltip = "Offset the blur center line.";
ui_category = "Tilt-shift blur";
> = 0f;
#line 71
uniform bool VisibleLine
<
ui_type = "input";
ui_label = "Visualize center line";
ui_tooltip = "Visualize blur center line.";
ui_category = "Blur line";
ui_category_closed = true;
> = false;
#line 80
uniform uint BlurLineWidth
<
ui_type = "slider";
ui_min = 2u; ui_max = 64u;
ui_units = " pixels";
ui_label = "Visualized line width";
ui_tooltip = "Tilt-shift line thickness in pixels.";
ui_category = "Blur line";
> = 15u;
#line 95
sampler BackBuffer
{
Texture = ReShade::BackBufferTex;
#line 99
AddressU = MIRROR;
AddressV = MIRROR;
};
#line 111
float bellWeight(float position)
{
#line 117
const float deviation = log(rcp(256u)); 
#line 120
return exp(position*position*deviation); 
}
#line 124
float2x2 get2dRotationMatrix(int angle)
{
#line 127
float angleRad = radians(angle);
#line 129
float rotSin = sin(angleRad), rotCos = cos(angleRad);
#line 131
return float2x2(
rotCos, rotSin, 
-rotSin, rotCos  
);
}
#line 137
float getBlurRadius(float2 viewCoord)
{
#line 140
const float2x2 rotationMtx = get2dRotationMatrix(BlurAngle);
#line 142
static float2 offsetDir = mul(rotationMtx, float2(0f, BlurOffset)); 
offsetDir.x *= -(1280 * (1.0 / 720)); 
#line 145
viewCoord = mul(rotationMtx, viewCoord+offsetDir);
#line 147
float4 radius;
radius[0] = viewCoord.y*viewCoord.y; 
radius[1] = radius[0]*radius[0]; 
radius[2] = radius[1]*radius[0]; 
radius[3] = radius[2]*radius[0]; 
#line 153
return abs(1f-rcp(dot(radius, K)+1f));
}
#line 161
void TiltShiftVS(
in  uint   vertexId  : SV_VertexID,
out float4 vertexPos : SV_Position,
out float2 texCoord  : TEXCOORD0,
out float2 viewCoord : TEXCOORD1)
{
#line 168
const float2 vertexPosList[3] =
{
float2(-1f, 1f), 
float2(-1f,-3f), 
float2( 3f, 1f)  
};
#line 176
viewCoord.x = (texCoord.x =   vertexPos.x = vertexPosList[vertexId].x)*(1280 * (1.0 / 720));
viewCoord.y =  texCoord.y = -(vertexPos.y = vertexPosList[vertexId].y);
vertexPos.zw = float2(0f, 1f); 
texCoord = texCoord*0.5+0.5; 
}
#line 183
void TiltShiftPassHorizontalPS(
in  float4 pixCoord  : SV_Position,
in  float2 texCoord  : TEXCOORD0,
in  float2 viewCoord : TEXCOORD1,
out float3 color     : SV_Target)
{
#line 190
float blurRadius = getBlurRadius(viewCoord);
#line 192
uint blurPixelCount = uint(ceil(blurRadius*720));
#line 194
if (blurPixelCount!=0u && any(K!=0f))
{
#line 197
blurPixelCount = min(
blurPixelCount+blurPixelCount%2u, 
abs(128u)-abs(128u)%2u 
);
#line 202
blurRadius *= 720*(1.0 / 1280); 
float rcpWeightStep = rcp(blurPixelCount);
float rcpOffsetStep = rcp(blurPixelCount*2u-1u);
color = 0f; float cumulativeWeight = 0f; 
for (uint i=1u; i<blurPixelCount*2u; i+=2u)
{
#line 209
float weight = bellWeight(mad(i, rcpWeightStep, -1f));
#line 211
float offset = (i-1u)*rcpOffsetStep-0.5;
color += GammaConvert::to_linear(tex2Dlod(
BackBuffer,
float4(blurRadius*offset+texCoord.x, texCoord.y, 0f, 0f) 
).rgb)*weight;
cumulativeWeight += weight;
}
#line 219
color /= cumulativeWeight;
}
#line 222
else color = GammaConvert::to_linear(tex2Dfetch(BackBuffer, uint2(pixCoord.xy)).rgb);
color = saturate(color); 
#line 225
color = GammaConvert::to_display(color); 
#line 227
color = BlueNoise::dither(color, uint2(pixCoord.xy));
}
#line 231
void TiltShiftPassVerticalPS(
in  float4 pixCoord  : SV_Position,
in  float2 texCoord  : TEXCOORD0,
in  float2 viewCoord : TEXCOORD1,
out float3 color     : SV_Target)
{
#line 238
float blurRadius = getBlurRadius(viewCoord);
#line 240
uint blurPixelCount = uint(ceil(blurRadius*720));
#line 242
if (blurPixelCount!=0u && any(K!=0f))
{
#line 245
blurPixelCount = min(
blurPixelCount+blurPixelCount%2u, 
abs(128u)-abs(128u)%2u 
);
float rcpWeightStep = rcp(blurPixelCount);
float rcpOffsetStep = rcp(blurPixelCount*2u-1u);
color = 0f; float cumulativeWeight = 0f; 
for (uint i=1u; i<blurPixelCount*2u; i+=2u)
{
#line 255
float weight = bellWeight(mad(i, rcpWeightStep, -1f));
#line 257
float offset = (i-1u)*rcpOffsetStep-0.5;
color += GammaConvert::to_linear(
tex2Dlod(
BackBuffer,
float4(texCoord.x, blurRadius*offset+texCoord.y, 0f, 0f) 
).rgb)*weight;
cumulativeWeight += weight;
}
#line 266
color /= cumulativeWeight;
}
else 
color = GammaConvert::to_linear(tex2Dfetch(BackBuffer, uint2(pixCoord.xy)).rgb);
#line 272
color = saturate(color);
#line 275
if (VisibleLine)
{
const float2x2 rotationMtx = get2dRotationMatrix(BlurAngle);
#line 279
const float2 offsetDir = mul(
float2x2(-rotationMtx[0]*(1280 * (1.0 / 720)), rotationMtx[1]), 
float2(0f, BlurOffset) 
);
#line 284
const float2x2 pixelRoationMtx = rotationMtx*720*0.5; 
#line 287
viewCoord = mul(pixelRoationMtx, viewCoord+offsetDir);
#line 289
float lineHorizontal = saturate(
BlurLineWidth*0.5 
-abs(viewCoord.y)  
);
#line 295
float lineColor = abs(ColorConvert::RGB_to_Luma(color)*2f-1f);
color = lerp(
color,
GammaConvert::to_linear(lineColor), 
lineHorizontal
);
}
#line 304
color = GammaConvert::to_display(color);
#line 306
color = BlueNoise::dither(color, uint2(pixCoord.xy));
}
#line 313
technique TiltShift
<
ui_label = "Tilt Shift";
ui_tooltip =
"Tilt shift blur effect.\n"
"\n"
"	· dynamic per-pixel sampling.\n"
"	· minimal sample count.\n"
"\n"
"This effect © 2018-2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY 3.0";
>
{
pass GaussianBlurHorizontal
{
VertexShader = TiltShiftVS;
PixelShader  = TiltShiftPassHorizontalPS;
}
pass GaussianBlurVerticalWithLine
{
VertexShader = TiltShiftVS;
PixelShader  = TiltShiftPassVerticalPS;
}
}

