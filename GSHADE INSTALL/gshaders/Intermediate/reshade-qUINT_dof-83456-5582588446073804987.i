// ADOF_CHROMATIC_ABERRATION_ENABLE=1
// ADOF_OPTICAL_VIGNETTE_ENABLE=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_dof.fx"
#line 41
uniform bool bADOF_AutofocusEnable <
ui_type = "bool";
ui_label = "Enable Autofocus";
ui_tooltip = "Enables automated focus calculation.";
ui_category = "Focusing";
> = true;
#line 48
uniform float2 fADOF_AutofocusCenter <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Autofocus Center";
ui_tooltip = "X and Y coordinates of autofocus center. Axes start from upper left screen corner.";
ui_category = "Focusing";
> = float2(0.5, 0.5);
#line 56
uniform float fADOF_AutofocusRadius <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Autofocus sample radius";
ui_tooltip = "Radius of area contributing to focus calculation.";
ui_category = "Focusing";
> = 0.6;
#line 65
uniform float fADOF_AutofocusSpeed <
ui_type = "slider";
ui_min = 0.05;
ui_max = 1.0;
ui_label = "Autofocus Adjustment Speed";
ui_tooltip = "Adjustment speed of autofocus on focus change";
ui_category = "Focusing";
> = 0.1;
#line 74
uniform float fADOF_ManualfocusDepth <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Manual focus depth";
ui_tooltip = "Manually adjusted static focus depth, disable autofocus to use it.";
ui_category = "Focusing";
> = 0.001;
#line 83
uniform float fADOF_NearBlurCurve <
ui_type = "slider";
ui_min = 0.5;
ui_max = 6.0;
ui_label = "Near blur curve";
ui_category = "Focusing";
> = 6.0;
#line 91
uniform float fADOF_FarBlurCurve <
ui_type = "slider";
ui_min = 0.5;
ui_max = 6.0;
ui_label = "Far blur curve";
ui_category = "Focusing";
> = 1.5;
#line 99
uniform float fADOF_HyperFocus <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Hyperfocal depth distance";
ui_category = "Focusing";
> = 0.10;
#line 107
uniform float fADOF_RenderResolutionMult <
ui_type = "slider";
ui_min = 0.5;
ui_max = 1.0;
ui_label = "Size Scale";
ui_tooltip = "Resolution Scale of bokeh blur. 0.5 means 1/2 screen width and height.";
ui_category = "Blur & Quality";
> = 0.5;
#line 116
uniform float fADOF_ShapeRadius <
ui_type = "slider";
ui_min = 0.0;
ui_max = 100.0;
ui_label = "Bokeh Maximal Blur Size";
ui_tooltip = "Blur size of areas entirely out of focus.";
ui_category = "Blur & Quality";
> = 20.5;
#line 125
uniform float fADOF_SmootheningAmount <
ui_type = "slider";
ui_min = 0.0;
ui_max = 200.0;
ui_label = "Gaussian blur width";
ui_tooltip = "Width of gaussian blur after bokeh filter.";
ui_category = "Blur & Quality";
> = 4.0;
#line 134
uniform float fADOF_BokehIntensity <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Bokeh Intensity";
ui_tooltip = "Intensity of bokeh discs.";
ui_category = "Bokeh";
> = 0.3;
#line 143
uniform int iADOF_BokehMode <
ui_type = "slider";
ui_min = 0;
ui_max = 3;
ui_label = "Bokeh highlight type";
ui_tooltip = "Different methods to emphasize bokeh sprites";
ui_category = "Bokeh";
> = 2;
#line 152
uniform int iADOF_ShapeVertices <
ui_type = "slider";
ui_min = 3;
ui_max = 9;
ui_label = "Bokeh shape vertices";
ui_tooltip = "Vertices of bokeh kernel. 5 = pentagon, 6 = hexagon etc.";
ui_category = "Bokeh";
> = 6;
#line 161
uniform int iADOF_ShapeQuality <
ui_type = "slider";
ui_min = 2;
ui_max = 25;
ui_label = "Bokeh shape quality";
ui_category = "Bokeh";
> = 5;
#line 169
uniform float fADOF_ShapeCurvatureAmount <
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
ui_label = "Bokeh shape roundness";
ui_tooltip = "Roundness of bokeh kernel. 1.0 = circle, 0.0 = polygon.";
ui_category = "Bokeh";
> = 1.0;
#line 178
uniform float fADOF_ShapeRotation <
ui_type = "slider";
ui_min = 0.0;
ui_max = 360.0;
ui_label = "Bokeh shape rotation";
ui_category = "Bokeh";
> = 0.0;
#line 186
uniform float fADOF_ShapeAnamorphRatio <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Bokeh shape aspect ratio";
ui_category = "Bokeh";
> = 1.0;
#line 213
uniform float fADOF_ShapeChromaAmount <
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
ui_label = "Shape chromatic aberration amount";
ui_category = "Chromatic Aberration";
> = -0.1;
#line 221
uniform int iADOF_ShapeChromaMode <
ui_type = "slider";
ui_min = 0;
ui_max = 2;
ui_label = "Shape chromatic aberration type";
ui_category = "Chromatic Aberration";
> = 2;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_common.fxh"
#line 111
namespace qUINT
{
uniform float FRAME_TIME < source = "frametime"; >;
uniform int FRAME_COUNT < source = "framecount"; >;
#line 124
static const float2 ASPECT_RATIO 	= float2(1.0, 1280 * (1.0 / 720));
static const float2 PIXEL_SIZE 		= float2((1.0 / 1280), (1.0 / 720));
static const float2 SCREEN_SIZE 	= float2(1280, 720);
#line 130
texture BackBufferTex : COLOR;
texture DepthBufferTex : DEPTH;
#line 133
sampler sBackBufferTex 	{ Texture = BackBufferTex; 	};
sampler sDepthBufferTex { Texture = DepthBufferTex; };
#line 136
float2 depthtex_uv(float2 uv)
{
#line 141
uv.x /= 1;
uv.y /= 1;
#line 145
 
uv.x -= 0 / 2.000000001;
#line 151
uv.y += 0 / 2.000000001;
#line 153
return uv;
}
#line 156
float get_depth(float2 uv)
{
float depth = tex2Dlod(sDepthBufferTex, float4(depthtex_uv(uv), 0, 0)).x;
return depth;
}
#line 162
float linearize_depth(float depth)
{
depth *= 1;
#line 176
const float N = 1.0;
depth /= 1000.0 - depth * (1000.0 - N);
#line 179
return saturate(depth);
}
#line 183
float linear_depth(float2 uv)
{
float depth = get_depth(uv);
depth = linearize_depth(depth);
return depth;
}
}
#line 192
void PostProcessVS(in uint id : SV_VertexID, out float4 vpos : SV_Position, out float2 uv : TEXCOORD)
{
uv.x = (id == 2) ? 2.0 : 0.0;
uv.y = (id == 1) ? 2.0 : 0.0;
vpos = float4(uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 237 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_dof.fx"
#line 245
texture2D ADOF_FocusTex 	    { Format = R16F; };
texture2D ADOF_FocusTexPrev     { Format = R16F; };
#line 248
sampler2D sADOF_FocusTex	    { Texture = ADOF_FocusTex; };
sampler2D sADOF_FocusTexPrev	{ Texture = ADOF_FocusTexPrev; };
#line 251
texture2D CommonTex0 	{ Width = 1280;   Height = 720;   Format = RGBA8; };
sampler2D sCommonTex0	{ Texture = CommonTex0;	};
#line 254
texture2D CommonTex1 	{ Width = 1280;   Height = 720;   Format = RGBA8; };
sampler2D sCommonTex1	{ Texture = CommonTex1;	};
#line 261
struct ADOF_VSOUT
{
float4   vpos           : SV_Position;
float4   txcoord        : TEXCOORD0;
float4   offset0        : TEXCOORD1;
float2x2 offsmat        : TEXCOORD2;
#line 268
};
#line 270
ADOF_VSOUT VS_ADOF(in uint id : SV_VertexID)
{
ADOF_VSOUT OUT;
#line 274
OUT.txcoord.x = (id == 2) ? 2.0 : 0.0;
OUT.txcoord.y = (id == 1) ? 2.0 : 0.0;
OUT.txcoord.zw = OUT.txcoord.xy / fADOF_RenderResolutionMult;
OUT.vpos = float4(OUT.txcoord.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 280
sincos(6.2831853 / iADOF_ShapeVertices, OUT.offsmat._21, OUT.offsmat._22);
OUT.offsmat._11 = OUT.offsmat._22;
OUT.offsmat._12 = -OUT.offsmat._21;
#line 284
sincos(radians(fADOF_ShapeRotation), OUT.offset0.x, OUT.offset0.y);
OUT.offset0.zw = mul(OUT.offset0.xy, OUT.offsmat);
#line 287
return OUT;
}
#line 294
float GetLinearDepth(float2 coords)
{
return qUINT::linear_depth(coords);
}
#line 299
float CircleOfConfusion(float2 texcoord, bool aggressiveLeakReduction)
{
float2 depthdata; 
float scenecoc;   
#line 304
depthdata.x = GetLinearDepth(texcoord.xy);
#line 306
[branch]
if(aggressiveLeakReduction)
{
float3 neighbourOffsets = float3(qUINT::PIXEL_SIZE.xy, 0);
#line 311
float4 neighbourDepths = float4(GetLinearDepth(texcoord.xy - neighbourOffsets.xz), 
GetLinearDepth(texcoord.xy + neighbourOffsets.xz), 
GetLinearDepth(texcoord.xy - neighbourOffsets.zy), 
GetLinearDepth(texcoord.xy + neighbourOffsets.zy));
#line 316
float neighbourMin = min(min(neighbourDepths.x,neighbourDepths.y),min(neighbourDepths.z,neighbourDepths.w));
depthdata.x = lerp(min(neighbourMin, depthdata.x), depthdata.x, 0.001);
}
#line 320
depthdata.y = tex2D(sADOF_FocusTex, texcoord.xy).x;
float handdepth = depthdata.x;
#line 323
depthdata.xy = saturate(depthdata.xy / fADOF_HyperFocus);
#line 325
[branch]
if(depthdata.x < depthdata.y)
{
scenecoc = depthdata.x / depthdata.y - 1.0;
scenecoc *= exp2(-0.5*fADOF_NearBlurCurve*fADOF_NearBlurCurve);
}
else
{
scenecoc = (depthdata.x - depthdata.y)/((depthdata.y * exp2(fADOF_FarBlurCurve*fADOF_FarBlurCurve)) - depthdata.y);
scenecoc = saturate(scenecoc);
}
#line 339
 
scenecoc = (handdepth < 0.3353 * 1e-4) ? 0.0 : scenecoc;
#line 343
return scenecoc;
}
#line 346
void ShapeRoundness(inout float2 sampleOffset, in float roundness)
{
sampleOffset *= (1.0-roundness) + rsqrt(dot(sampleOffset,sampleOffset))*roundness;
}
#line 351
void OpticalVignette(in float2 sampleOffset, in float2 centerVec, inout float sampleWeight)
{
sampleOffset -= centerVec; 
sampleWeight *= saturate(3.333 - dot(sampleOffset,sampleOffset) * 1.666); 
}
#line 357
float2 CoC2BlurRadius(float CoC)
{
return float2(fADOF_ShapeAnamorphRatio, qUINT::ASPECT_RATIO.y) * CoC * fADOF_ShapeRadius * 6e-4;
}
#line 366
void PS_CopyBackBuffer(in ADOF_VSOUT IN, out float4 color : SV_Target0)
{
color = tex2D(qUINT::sBackBufferTex, IN.txcoord.xy);
}
#line 371
void PS_ReadFocus(in ADOF_VSOUT IN, out float focus : SV_Target0)
{
float scenefocus = 0.0;
#line 375
[branch]
if(bADOF_AutofocusEnable == true)
{
float samples = 10.0;
float weightsum = 1e-6;
#line 381
for(float xcoord = 0.0; xcoord < samples; xcoord++)
for(float ycoord = 0.0; ycoord < samples; ycoord++)
{
float2 sampleOffset = (float2(xcoord,ycoord) + 0.5) / samples;
sampleOffset = sampleOffset * 2.0 - 1.0;
sampleOffset *= fADOF_AutofocusRadius;
sampleOffset += (fADOF_AutofocusCenter - 0.5);
#line 389
float sampleWeight = saturate(1.2 * exp2(-dot(sampleOffset,sampleOffset)*4.0));
#line 391
float tempfocus = GetLinearDepth(sampleOffset * 0.5 + 0.5);
sampleWeight *= rcp(tempfocus + 0.001);
#line 394
sampleWeight *= saturate(tempfocus > 0.3353 * 1e-4); 
#line 396
scenefocus += tempfocus * sampleWeight;
weightsum += sampleWeight;
}
scenefocus /= weightsum;
}
else
{
scenefocus = fADOF_ManualfocusDepth * fADOF_ManualfocusDepth;
}
#line 406
float prevscenefocus = tex2D(sADOF_FocusTexPrev, 0.5).x;
float adjustmentspeed = fADOF_AutofocusSpeed * fADOF_AutofocusSpeed;
adjustmentspeed *= prevscenefocus > scenefocus ? 2.0 : 1.0;
#line 410
focus = lerp(prevscenefocus, scenefocus, saturate(adjustmentspeed));
}
#line 413
void PS_CopyFocus(in ADOF_VSOUT IN, out float focus : SV_Target0)
{
focus = tex2D(sADOF_FocusTex, IN.txcoord.xy).x;
}
#line 418
void PS_CoC(in ADOF_VSOUT IN, out float4 color : SV_Target0)
{
color           = tex2D(qUINT::sBackBufferTex, IN.txcoord.xy);
#line 422
static const float2 sampleOffsets[4] = {    float2( 1.5, 0.5) * qUINT::PIXEL_SIZE.xy,
float2( 0.5,-1.5) * qUINT::PIXEL_SIZE.xy,
float2(-1.5,-0.5) * qUINT::PIXEL_SIZE.xy,
float2(-0.5, 1.5) * qUINT::PIXEL_SIZE.xy};
#line 427
float centerDepth = GetLinearDepth(IN.txcoord.xy);
float4 sampleCoord = 0.0;
float3 neighbourOffsets = float3(qUINT::PIXEL_SIZE.xy, 0);
float4 coccolor = 0.0;
#line 432
[loop]
for(int i=0; i<4; i++)
{
sampleCoord.xy = IN.txcoord.xy + sampleOffsets[i];
#line 437
float3 sampleColor = tex2Dlod(qUINT::sBackBufferTex, sampleCoord).rgb;
#line 439
float4 sampleDepths = float4(GetLinearDepth(sampleCoord.xy + neighbourOffsets.xz),  
GetLinearDepth(sampleCoord.xy - neighbourOffsets.xz),  
GetLinearDepth(sampleCoord.xy + neighbourOffsets.zy),  
GetLinearDepth(sampleCoord.xy - neighbourOffsets.zy)); 
#line 444
float sampleDepthMin = min(min(sampleDepths.x,sampleDepths.y),min(sampleDepths.z,sampleDepths.w));
#line 446
sampleColor /= 1.0 + max(max(sampleColor.r, sampleColor.g), sampleColor.b);
#line 448
float sampleWeight = saturate(sampleDepthMin * rcp(centerDepth) + 1e-3);
coccolor += float4(sampleColor.rgb * sampleWeight, sampleWeight);
}
#line 452
coccolor.rgb /= coccolor.a;
coccolor.rgb /= 1.0 - max(coccolor.r, max(coccolor.g, coccolor.b));
#line 455
color.rgb = lerp(color.rgb, coccolor.rgb, saturate(coccolor.w * 8.0));
color.w = CircleOfConfusion(IN.txcoord.xy, 1);
color.w = saturate(color.w * 0.5 + 0.5);
}
#line 460
void unpack_hdr(inout float3 color)
{
color = color * rcp(1.2 - saturate(color));
}
#line 465
void pack_hdr(inout float3 color)
{
color = 1.2 * color * rcp(color + 1.0);
}
#line 470
float4 PS_DoF_Main(in ADOF_VSOUT IN) : SV_Target0
{
if(max(IN.txcoord.z,IN.txcoord.w) > 1.01) discard;
#line 474
float4 BokehSum, BokehMax;
BokehMax		           = tex2D(sCommonTex0, IN.txcoord.zw);
BokehSum                   = BokehMax;
float weightSum 		   = 1.0;
float CoC 			       = abs(BokehSum.w * 2.0 - 1.0);
float2 bokehRadiusScaled   = CoC2BlurRadius(CoC);
float nRings 			   = lerp(1.0,iADOF_ShapeQuality,saturate(CoC)) + (dot(IN.vpos.xy,1) % 2) * 0.5;
#line 482
if(bokehRadiusScaled.x < 0.25 * qUINT::PIXEL_SIZE.x) return BokehSum;
#line 484
bokehRadiusScaled /= nRings;
CoC /= nRings;
#line 497
int densityScale = max(1, 6 - iADOF_ShapeVertices);
#line 499
[loop]
for (int iVertices = 0; iVertices < iADOF_ShapeVertices && iVertices < 10; iVertices++)
{
[loop]
for(float iRings = 1; iRings <= nRings && iRings < 26; iRings++)
{
[loop]
for(float iSamplesPerRing = 0; iSamplesPerRing < iRings * densityScale && iSamplesPerRing < 26*2; iSamplesPerRing++)
{
float x = iSamplesPerRing/(iRings * densityScale);
float a = x * x * (3.0 - 2.0 * x);
float l = 2.55 * rcp(iADOF_ShapeVertices * iADOF_ShapeVertices * 0.4 - 1.0);
x = lerp(x, (1.0 + l) * x - a * l, fADOF_ShapeCurvatureAmount);
#line 513
float2 sampleOffset = lerp(IN.offset0.xy,IN.offset0.zw, x);
#line 515
ShapeRoundness(sampleOffset,fADOF_ShapeCurvatureAmount);
#line 517
float4 sampleBokeh 	= tex2Dlod(sCommonTex0, float4(IN.txcoord.zw + sampleOffset.xy * (bokehRadiusScaled * iRings),0,0));
float sampleWeight	= saturate(1e6 * (abs(sampleBokeh.a * 2.0 - 1.0) - CoC * (float)iRings) + 1.0);
#line 523
sampleBokeh.rgb *= sampleWeight;
weightSum 		+= sampleWeight;
BokehSum 		+= sampleBokeh;
BokehMax 		= max(BokehMax,sampleBokeh);
}
}
#line 530
IN.offset0.xy = IN.offset0.zw;
IN.offset0.zw = mul(IN.offset0.zw, IN.offsmat);
}
#line 536
float4 ret = 0;
#line 538
BokehSum /= weightSum;
#line 540
unpack_hdr(BokehSum.rgb);
unpack_hdr(BokehMax.rgb);
#line 543
if(iADOF_BokehMode == 0)
{
ret = lerp(BokehSum, BokehMax, fADOF_BokehIntensity * saturate(CoC * nRings * 2.0));
}
else if(iADOF_BokehMode == 1)
{
#line 550
float maxlum = dot(float3(0.3, 0.59, 0.11), BokehMax.rgb);
float avglum = dot(float3(0.3, 0.59, 0.11), BokehSum.rgb);
#line 553
ret = BokehSum * lerp(avglum, maxlum, fADOF_BokehIntensity * saturate(CoC * nRings * 2.0)) / avglum;
}
else if(iADOF_BokehMode == 2)
{
float maxlum = dot(float3(0.3, 0.59, 0.11), BokehMax.rgb);
float avglum = dot(float3(0.3, 0.59, 0.11), BokehSum.rgb);
#line 560
float bokehweight = max(0, maxlum - avglum);
bokehweight = bokehweight * fADOF_BokehIntensity * 2.0;
bokehweight *= bokehweight;
#line 564
ret = BokehSum + BokehMax * saturate(bokehweight * CoC * nRings);
}
else if(iADOF_BokehMode == 3)
{
float maxlum = dot(float3(0.3, 0.59, 0.11), BokehMax.rgb);
float avglum = dot(float3(0.3, 0.59, 0.11), BokehSum.rgb);
#line 571
float bokehweight = maxlum - avglum;
ret = lerp(BokehSum, BokehMax, saturate(bokehweight * CoC * nRings * fADOF_BokehIntensity));
}
#line 575
pack_hdr(ret.rgb);
#line 577
return ret;
}
#line 580
void PS_DoF_Combine(in ADOF_VSOUT IN, out float4 color : SV_Target0)
{
float4 blurredColor = tex2D(sCommonTex1, IN.txcoord.xy * fADOF_RenderResolutionMult);
float4 originalColor  = tex2D(qUINT::sBackBufferTex, IN.txcoord.xy);
#line 585
float CoC 		= abs(CircleOfConfusion(IN.txcoord.xy, 0));
float bokehRadiusPixels = CoC2BlurRadius(CoC).x * 1280;
#line 589
float blendWeight = saturate((bokehRadiusPixels-0.25)/(2.0-0.25));
blendWeight = pow(blendWeight,0.5);
#line 592
color.rgb      = lerp(originalColor.rgb, blurredColor.rgb, blendWeight);
color.a        = saturate(CoC * 4.0) * 0.5 + 0.5;
}
#line 596
void PS_DoF_Gauss1(in ADOF_VSOUT IN, out float4 color : SV_Target0)
{
float4 centerTap = tex2D(sCommonTex0, IN.txcoord.xy);
float CoC = abs(centerTap.a * 2.0 - 1.0);
#line 601
float nSteps 		= floor(CoC * (fADOF_SmootheningAmount + 0.0));
float expCoeff 		= -2.0 * rcp(nSteps * nSteps + 1e-3); 
float2 blurAxisScaled 	= float2(1,0) * qUINT::PIXEL_SIZE.xy;
#line 605
float4 gaussianSum = 0.0;
float  gaussianSumWeight = 1e-3;
#line 608
for(float iStep = -nSteps; iStep <= nSteps; iStep++)
{
float currentWeight = exp(iStep * iStep * expCoeff);
float currentOffset = 2.0 * iStep - 0.5; 
#line 613
float4 currentTap = tex2Dlod(sCommonTex0, float4(IN.txcoord.xy + blurAxisScaled.xy * currentOffset, 0, 0));
currentWeight *= saturate(abs(currentTap.a * 2.0 - 1.0) - CoC * 0.25); 
#line 616
gaussianSum += currentTap * currentWeight;
gaussianSumWeight += currentWeight;
}
#line 620
gaussianSum /= gaussianSumWeight;
#line 622
color.rgb = lerp(centerTap.rgb, gaussianSum.rgb, saturate(gaussianSumWeight));
color.a = centerTap.a;
}
#line 626
void PS_DoF_Gauss2(in ADOF_VSOUT IN, out float4 color : SV_Target0)
{
float4 centerTap = tex2D(sCommonTex1, IN.txcoord.xy);
float CoC = abs(centerTap.a * 2.0 - 1.0);
#line 631
float nSteps 		= min(50,floor(CoC * (fADOF_SmootheningAmount + 0.0)));
float expCoeff 		= -2.0 * rcp(nSteps * nSteps + 1e-3); 
float2 blurAxisScaled 	= float2(0,1) * qUINT::PIXEL_SIZE.xy;
#line 635
float4 gaussianSum = 0.0;
float  gaussianSumWeight = 1e-3;
#line 638
for(float iStep = -nSteps; iStep <= nSteps; iStep++)
{
float currentWeight = exp(iStep * iStep * expCoeff);
float currentOffset = 2.0 * iStep - 0.5; 
#line 643
float4 currentTap = tex2Dlod(sCommonTex1, float4(IN.txcoord.xy + blurAxisScaled.xy * currentOffset, 0, 0));
currentWeight *= saturate(abs(currentTap.a * 2.0 - 1.0) - CoC * 0.25); 
#line 646
gaussianSum += currentTap * currentWeight;
gaussianSumWeight += currentWeight;
}
#line 650
gaussianSum /= gaussianSumWeight;
#line 652
color.rgb = lerp(centerTap.rgb, gaussianSum.rgb, saturate(gaussianSumWeight));
color.a = centerTap.a;
}
#line 657
void PS_DoF_ChromaticAberration(in ADOF_VSOUT IN, out float4 color : SV_Target0)
{
float4 colorVals[5];
float3 neighbourOffsets = float3(qUINT::PIXEL_SIZE.xy, 0);
#line 662
colorVals[0] = tex2D(sCommonTex0, IN.txcoord.xy);                       
colorVals[1] = tex2D(sCommonTex0, IN.txcoord.xy - neighbourOffsets.xz); 
colorVals[2] = tex2D(sCommonTex0, IN.txcoord.xy - neighbourOffsets.zy); 
colorVals[3] = tex2D(sCommonTex0, IN.txcoord.xy + neighbourOffsets.xz); 
colorVals[4] = tex2D(sCommonTex0, IN.txcoord.xy + neighbourOffsets.zy); 
#line 668
float CoC 			= abs(colorVals[0].a * 2.0 - 1.0);
float2 bokehRadiusScaled	= CoC2BlurRadius(CoC);
#line 671
float4 vGradTwosided = float4(dot(colorVals[0].rgb - colorVals[1].rgb, 1),	 
dot(colorVals[0].rgb - colorVals[2].rgb, 1),	 
dot(colorVals[3].rgb - colorVals[0].rgb, 1),	 
dot(colorVals[4].rgb - colorVals[0].rgb, 1)); 	 
#line 676
float2 vGrad = min(vGradTwosided.xy, vGradTwosided.zw);
#line 678
float vGradLen = sqrt(dot(vGrad,vGrad)) + 1e-6;
vGrad = vGrad / vGradLen * saturate(vGradLen * 32.0) * bokehRadiusScaled * 0.125 * fADOF_ShapeChromaAmount;
#line 681
float4 chromaVals[3];
#line 683
chromaVals[0] = colorVals[0];
chromaVals[1] = tex2D(sCommonTex0, IN.txcoord.xy + vGrad);
chromaVals[2] = tex2D(sCommonTex0, IN.txcoord.xy - vGrad);
#line 687
chromaVals[1].rgb = lerp(chromaVals[0].rgb, chromaVals[1].rgb, saturate(4.0 * abs(chromaVals[1].w)));
chromaVals[2].rgb = lerp(chromaVals[0].rgb, chromaVals[2].rgb, saturate(4.0 * abs(chromaVals[2].w)));
#line 690
uint3 chromaMode = (uint3(0,1,2) + iADOF_ShapeChromaMode.xxx) % 3;
#line 692
color.rgb = float3(chromaVals[chromaMode.x].r,
chromaVals[chromaMode.y].g,
chromaVals[chromaMode.z].b);
color.a = 1.0;
}
#line 703
technique ADOF
< ui_tooltip = "                         >> qUINT::ADOF <<\n\n"
"ADOF is a bokeh depth of field shader.\n"
"It blurs the scene in front of and behind the focus plane\n"
"to simulate the behaviour of real lenses. A multitude of features\n"
"allows to simulate various types of bokeh blur that cameras produce.\n"
"\nADOF is written by Marty McFly / Pascal Gilcher"; >
{
#line 717
pass
{
VertexShader = VS_ADOF;
PixelShader = PS_ReadFocus;
RenderTarget = ADOF_FocusTex;
}
pass
{
VertexShader = VS_ADOF;
PixelShader = PS_CopyFocus;
RenderTarget = ADOF_FocusTexPrev;
}
pass
{
VertexShader = VS_ADOF;
PixelShader  = PS_CoC;
RenderTarget = CommonTex0;
}
pass
{
VertexShader = VS_ADOF;
PixelShader  = PS_DoF_Main;
RenderTarget = CommonTex1;
}
pass
{
VertexShader = VS_ADOF;
PixelShader  = PS_DoF_Combine;
RenderTarget = CommonTex0;
}
pass
{
VertexShader = VS_ADOF;
PixelShader  = PS_DoF_Gauss1;
RenderTarget = CommonTex1;
}
#line 754
pass
{
VertexShader = VS_ADOF;
PixelShader  = PS_DoF_Gauss2;
RenderTarget = CommonTex0;
}
pass
{
VertexShader = VS_ADOF;
PixelShader  = PS_DoF_ChromaticAberration;
}
#line 772
}

