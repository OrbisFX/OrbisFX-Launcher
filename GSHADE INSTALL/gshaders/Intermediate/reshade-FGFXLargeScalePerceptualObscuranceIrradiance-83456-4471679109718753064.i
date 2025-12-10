// LSPOIRR_SRGB=0
// LSPOIRR_CASCADE_3_ON=0
// LSPOIRR_AUTO_GAIN_SPEED=0.04
// LSPOIRR_AUTO_GAIN_ENABLED=1
// LSPOIRR_BLUR_MAX_RECIPROCAL_THRESHOLD=0.05
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FGFXLargeScalePerceptualObscuranceIrradiance.fx"
#line 110
uniform int ___ABOUT <
ui_type = "radio";
ui_label = " ";
ui_category = "About";
ui_category_closed = true;
ui_text =
"-=[ FGFX::LSPOIrr - Large Scale Perceptual Obscurance and Irradiance ]=-\n"
"\n"
#line 119
"The Large Scale Perceptual Obscurance and Irradiance is a post-processing "
"effect that attempts to inject obscurance and irradiance in the scene at a "
"large scale (low frequency).\n"
"\n"
#line 124
"Due to the fact that the effect operates on the low frequencies of the "
"input image, the effect often plays just on a perceptual level rather "
"than being an actual physically correct rendition of scene obscurrance and "
"irradiance.\n"
"\n"
#line 130
"* How does it work? *\n"
"\n"
#line 133
"The concept sitting at the core of the effect is really simple and relies "
"on some assumptions that more than often are correct. If we take an "
"arbitrary image, blur it with a large gaussian and then overlay (as in "
"standard overlay blending operation) the blurred image onto the original "
"image, we get the illusion that some statistically-correct occlusion and "
"irradiance shows up in the image.\n"
"\n"
#line 141
"* Why does it work? *\n"
"\n"
#line 144
"The effect relies on the statistical fact that if there's a part in the "
"input image that is predominantly dark, chances are that the entire part "
"contains objects that obscure each other, reducing the amount of light "
"radiated in that particular area.\n"
"\n"
#line 150
"Admittedly, the opposite is also true: If a part of the input image is "
"predominantly bright, chances are that the objects in that part of the "
"image have an increased amount of light inter-radiation, as a result of "
"objects in that part of the image bouncing light to each other.\n"
"\n"
#line 156
"* What about performance? *\n"
"\n"
#line 159
"The implementation uses the Fast Cascaded Separable Blur technique, "
"which is blazing-fast. The entire effect executes in less than 0.35 ms "
"on a machine with a i7-8700K running at 4.2Ghz CPU and a GTX 1080Ti "
"running at 2000Mhz GPU in 2560x1440 resolution.\n"
"\n"
#line 165
"And if you think you don't need the auto-gain feature (by disabling it "
"in preprocessor definitions), you can cut 0.05 ms and get the total "
"execution time down to 0.3 ms.\n"
"\n"
#line 170
"* Where is this effect best placed? *\n"
"\n"
#line 173
"Since the effect addresses the lighting in the scene, it's best put "
"after any Global Illumination technique like Ambient Occlusion, "
"Obscurance, RTGI and before tone-mapping, film grain, color grading "
"of any sort, bloom, CA or any lens & sensor effects.\n";
>;
#line 185
uniform bool LSPOIrrEffectEnabled <
ui_category = "Effect Settings";
ui_label = "Effect Enabled";
ui_tooltip = "Enables / disables the effect entirely.";
> = true;
#line 191
uniform float LSPOIrrEffectIntensity <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "Effect Settings";
ui_label = "Effect Intensity";
ui_tooltip = "Adjusts the overall intensity of the effect.";
> = 0.9;
#line 200
uniform float LSPOIrrOcclusionIntensity <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "Effect Settings";
ui_label = "Occlusion Intensity";
ui_tooltip = "Adjusts the occlusion intensity of the effect.";
> = 1.0;
#line 209
uniform float LSPOIrrIrradianceIntensity <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "Effect Settings";
ui_label = "Irradiance Intensity";
ui_tooltip = "Adjusts the irradiance intensity of the effect.";
> = 1.0;
#line 218
uniform float LSPOIrrOclusionIrradianceThreshold <
ui_type = "slider";
ui_min = 0.004;
ui_max = 0.996;
ui_category = "Effect Settings";
ui_label = "Occlusion / Irradiance Threshold";
ui_tooltip = "Adjusts the middle line that determines what occlusion and irradiance affect.";
> = 0.5;
#line 238
 
#line 240
uniform float LSPOIrrEffectRadius <
ui_type = "slider";
ui_min = 0.25;
ui_max = 1.00;
ui_category = "Effect Settings";
ui_label = "Effect Radius";
ui_tooltip = "Adjusts the radius of the effect.";
> = 0.65;
#line 249
uniform float LSPOIrrEffectSaturation <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "Effect Settings";
ui_label = "Effect Saturation";
ui_tooltip =
"Adjusts the saturation of the resulting occlusion and irradiance.\n"
"\n"
"Notice this is NOT the final output saturation, but the saturation applied to occlusion and irradiance prior to blending over the color buffer.\n"
"For the final output saturation see 'Saturation' in the 'Toning Settings' category.";
> = 0.1;
#line 262
uniform float LSPOIrrOcclusionIrradianceRecovery <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "Effect Settings";
ui_label = "Occlusion-Irradiance Recovery";
ui_tooltip =
"Adjusts the recovery applied to occlusion and radiance.\n"
"\n"
"Set it to 0 for a dramatic effect overall, set to 1 for maximum recovery of dark and bright areas.";
> = 0.75;
#line 282
uniform float LSPOIrrAutoGain <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "Toning Settings";
ui_label = "Auto-Gain";
ui_tooltip = "Adjusts the influence of auto-gain.";
> = 0.5;
#line 293
uniform float LSPOIrrGamma <
ui_type = "slider";
ui_min = 0.10;
ui_max = 4.00;
ui_category = "Toning Settings";
ui_label = "Gamma";
ui_tooltip = "Adjusts the gamma of the final result.";
> = 1.0;
#line 302
uniform float LSPOIrrGain <
ui_type = "slider";
ui_min = 0.0;
ui_max = 4.0;
ui_category = "Toning Settings";
ui_label = "Gain";
ui_tooltip = "Adjusts the gain of the final result.";
> = 1.0;
#line 311
uniform float LSPOIrrContrast <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "Toning Settings";
ui_label = "Contrast";
ui_tooltip = "Adjusts the contrast of the final result.";
> = 1.0;
#line 320
uniform float LSPOIrrSaturation <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_category = "Toning Settings";
ui_label = "Saturation";
ui_tooltip = "Adjusts the saturation of the final result.";
> = 1.0;
#line 333
uniform int LSPOIrrDebugType <
ui_type = "combo";
ui_category = "Debug";
#line 337
ui_items =
"None\0"
"No Intensity\0"
"No Toning\0"
"Raw Blur\0"
"Saturated Blur\0"
#line 345
"Gained Blur\0"
#line 348
"Scaled Blur\0"
"Occlusion - Irradiance Map\0"
#line 352
"Blur Max Samples Positions\0"
"Blur Max\0"
"Blur Gain\0"
#line 357
"Recovery Blur\0"
"Scaled Recovery Blur\0"
"Recovery Occlusion - Irradiance Map\0";
#line 361
ui_label = "Debug Type";
ui_tooltip = "Different debug outputs";
> = 0;
#line 389
 
#line 407
 
#line 417
uniform int ___LSPOIRR_AUTO_GAIN_ENABLED_DESC <
ui_type = "radio";
ui_label = " ";
ui_category = "Preprocessor definitions descriptions";
ui_category_closed = true;
ui_text =
"LSPOIRR_AUTO_GAIN_ENABLED"
":\n- Enables / disables the auto-gain feature. "
"Disable for a slight performance boost if auto-gain is not needed.\n"
"- 0 means disabled, 1 means enabled, default is 1.\n";
>;
#line 429
uniform int ___LSPOIRR_AUTO_GAIN_SPEED_DESC <
ui_type = "radio";
ui_label = " ";
ui_category = "Preprocessor definitions descriptions";
ui_category_closed = true;
ui_text =
"LSPOIRR_AUTO_GAIN_SPEED"
":\n- Defines how fast the auto-gain adapts to the scenery. "
"Disable for a slight performance boost if auto-gain is not needed.\n"
"- Must be greater than 0, less than 0.25, default is 0.04.\n";
>;
#line 441
uniform int ___LSPOIRR_BLUR_MAX_RECIPROCAL_THRESHOLD_DESC <
ui_type = "radio";
ui_label = " ";
ui_category = "Preprocessor definitions descriptions";
ui_category_closed = true;
ui_text =
"LSPOIRR_BLUR_MAX_RECIPROCAL_THRESHOLD"
":\n- Defines the breaking point between the two piecewise functions that make up the compute blur gain function.\n"
"- Must be greater than 0, less than 0.5, default is 0.05.\n";
>;
#line 452
uniform int ___LSPOIRR_CASCADE_3_ON_DESC <
ui_type = "radio";
ui_label = " ";
ui_category = "Preprocessor definitions descriptions";
ui_category_closed = true;
ui_text =
"LSPOIRR_CASCADE_3_ON"
":\n- Enables / disables cascade 3 in the Fast Cascaded Separable Blur implementation in order to achieve a much wider blur radius. "
"Only required for resolutions bigger than 4K.\n"
"- 0 means disabled, 1 means enabled, default is 0.\n";
>;
#line 464
uniform int ___LSPOIRR_SRGB_DESC <
ui_type = "radio";
ui_label = " ";
ui_category = "Preprocessor definitions descriptions";
ui_category_closed = true;
ui_text =
"LSPOIRR_SRGB"
":\n- Enables / disables working in sRGB color space. "
"Blending the effect in sRGB yields slightly different results and it should be toggled as needed by the specific game you're running.\n"
"- However, beware that when enabled, in most cases the final output is lightly darker in the shadows areas than when disabled.\n"
"- 0 means disabled, 1 means enabled, default is 0.\n";
>;
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
#line 480 "C:\Program Files\GShade\gshade-shaders\Shaders\FGFXLargeScalePerceptualObscuranceIrradiance.fx"
#line 489
uniform float FrameTime <source = "frametime";>;
#line 495
sampler2D ReShadeBackBufferSRGBSampler {
Texture = ReShade::BackBufferTex;
#line 499
 
};
#line 506
texture HalfBlurTex {
Width = 1280 >> 1;
Height = 720 >> 1;
Format = RGBA16F;
};
#line 512
sampler HalfBlurSampler {
Texture = HalfBlurTex;
};
#line 516
texture QuadBlurTex {
Width = 1280 >> 2;
Height = 720 >> 2;
Format = RGBA16F;
};
#line 522
sampler QuadBlurSampler {
Texture = QuadBlurTex;
};
#line 526
texture OctoBlurTex {
Width = 1280 >> 3;
Height = 720 >> 3;
Format = RGBA16F;
};
#line 532
sampler OctoBlurSampler {
Texture = OctoBlurTex;
};
#line 536
texture HexaBlurTex {
Width = 1280 >> (4);
Height = 720 >> (4);
Format = RGBA16F;
};
#line 542
sampler HexaBlurSampler {
Texture = HexaBlurTex;
};
#line 550
texture HBlurTex {
Width = 1280 >> (4);
Height = 720 >> (4);
Format = RGBA16F;
};
#line 556
sampler HBlurSampler {
Texture = HBlurTex;
};
#line 560
texture VBlurTex {
Width = 1280 >> (4);
Height = 720 >> (4);
Format = RGBA16F;
};
#line 566
sampler VBlurSampler {
Texture = VBlurTex;
};
#line 570
texture ShortBlurTex {
Width = 1280 >> (4);
Height = 720 >> (4);
Format = RGBA16F;
};
#line 576
sampler ShortBlurSampler {
Texture = ShortBlurTex;
};
#line 586
texture BlurMaxTex {
Width = 1280 >> (4);
Height = 720 >> (4);
Format = R16F;
};
#line 592
sampler BlurMaxSampler {
Texture = BlurMaxTex;
};
#line 596
texture BlurMaxHistoryTex {
Width = 1280 >> (4);
Height = 720 >> (4);
Format = R16F;
};
#line 602
sampler BlurMaxHistorySampler {
Texture = BlurMaxHistoryTex;
};
#line 606
texture BlurMaxHistoryTempTex {
Width = 1280 >> (4);
Height = 720 >> (4);
Format = R16F;
};
#line 612
sampler BlurMaxHistoryTempSampler {
Texture = BlurMaxHistoryTempTex;
};
#line 647
static const float  ___BUFFER_ASPECT_RATIO___            = 1280 / 720;
static const int    ___MAX_BLUR_NUM_TOTAL_SAMPLES___     = (7) * (7);
static const float  ___MAX_BLUR_NUM_TOTAL_SAMPLES_RCP___ = 1.0 / ___MAX_BLUR_NUM_TOTAL_SAMPLES___;
static const int    ___BUFFER_SIZE_DIVIDER___            = 1 << (4);
static const float  ___ONE_THIRD___                      = 1.0 / 3.0;
#line 682
static const float  ___STEP_MULTIPLIER___                                        = 1.5;
static const float  ___BUFFER_SIZE_DIVIDER_COMPENSATION_OFFSET___                = ___BUFFER_SIZE_DIVIDER___ * ___STEP_MULTIPLIER___;
static const float2 ___SCALED_BUFFER_SIZE_DIVIDER_DIVIDER_COMPENSATION_OFFSET___ = ___BUFFER_SIZE_DIVIDER_COMPENSATION_OFFSET___ * float2((1.0 / 1280), (1.0 / 720));
#line 694
float3 CopyBBPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 696
return tex2D(ReShadeBackBufferSRGBSampler, texcoord.xy).rgb;
}
#line 699
float3 CopyHalfPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 701
return tex2D(HalfBlurSampler, texcoord.xy).rgb;
}
#line 704
float3 CopyQuadPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 706
return tex2D(QuadBlurSampler, texcoord.xy).rgb;
}
#line 709
float3 CopyOctoPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 711
return tex2D(OctoBlurSampler, texcoord.xy).rgb;
}
#line 714
float3 CopyHexaPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 716
return tex2D(HexaBlurSampler, texcoord.xy).rgb;
}
#line 792
float3 HBlur(in float2 texcoord : TEXCOORD, float blurSampleOffset, sampler srcSampler) {
float offset = ___SCALED_BUFFER_SIZE_DIVIDER_DIVIDER_COMPENSATION_OFFSET___.x * blurSampleOffset * LSPOIrrEffectRadius;
#line 795
float3 color = tex2D(srcSampler, texcoord).rgb; 
color += tex2D(srcSampler, float2(texcoord.x - offset, texcoord.y)).rgb; 
color += tex2D(srcSampler, float2(texcoord.x + offset, texcoord.y)).rgb; 
color *= ___ONE_THIRD___;
#line 800
return color;
}
#line 803
float3 VBlur(in float2 texcoord : TEXCOORD, float blurSampleOffset, sampler srcSampler) {
float offset = ___SCALED_BUFFER_SIZE_DIVIDER_DIVIDER_COMPENSATION_OFFSET___.y * blurSampleOffset * LSPOIrrEffectRadius;
#line 806
float3 color = tex2D(srcSampler, texcoord).rgb; 
color += tex2D(srcSampler, float2(texcoord.x, texcoord.y - offset)).rgb; 
color += tex2D(srcSampler, float2(texcoord.x, texcoord.y + offset)).rgb; 
color *= ___ONE_THIRD___;
#line 811
return color;
}
#line 818
float3 HBlurC0BBPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 820
return HBlur(texcoord, ( 1.0), ReShadeBackBufferSRGBSampler);
}
#line 823
float3 HBlurC0PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 825
return HBlur(texcoord, ( 1.0), VBlurSampler);
}
#line 828
float3 VBlurC0PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 830
return VBlur(texcoord, ( 1.0), HBlurSampler);
}
#line 837
float3 HBlurC1PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 839
return HBlur(texcoord, ( 3.0), VBlurSampler);
}
#line 842
float3 VBlurC1PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 844
return VBlur(texcoord, ( 3.0), HBlurSampler);
}
#line 851
float3 HBlurC2PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 853
return HBlur(texcoord, ( 9.0), VBlurSampler);
}
#line 856
float3 VBlurC2PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 858
return VBlur(texcoord, ( 9.0), HBlurSampler);
}
#line 865
float3 HBlurC3PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 867
return HBlur(texcoord, ( 27.0), VBlurSampler);
}
#line 870
float3 VBlurC3PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 872
return VBlur(texcoord, ( 27.0), HBlurSampler);
}
#line 879
float3 HBlurC4PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 881
return HBlur(texcoord, ( 81.0), VBlurSampler);
}
#line 884
float3 VBlurC4PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 886
return VBlur(texcoord, ( 81.0), HBlurSampler);
}
#line 893
float3 HBlurC5PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 895
return HBlur(texcoord, (243.0), VBlurSampler);
}
#line 898
float3 VBlurC5PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 900
return VBlur(texcoord, (243.0), HBlurSampler);
}
#line 907
float3 CopyVBlurPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
return tex2D(VBlurSampler, texcoord.xy).rgb;
}
#line 917
float3 Hash31(in float p) {
float3 p3 = frac(p * float3(0.1031, 0.1030, 0.0973));
p3 += dot(p3, p3.yzx + 33.33);
return frac((p3.xxy + p3.yzz) * p3.zyx);
}
#line 923
float3 Hash32(in float2 p) {
float3 p3 = frac(float3(p.xyx) * float3(0.1031, 0.1030, 0.0973));
p3 += dot(p3, p3.yxz + 33.33);
return frac((p3.xxy + p3.yzz) * p3.zyx);
}
#line 929
float3 Hash33(in float3 p3) {
p3 = frac(p3 * float3(0.1031, 0.1030, 0.0973));
p3 += dot(p3, p3.yxz + 33.33);
return frac((p3.xxy + p3.yxx) * p3.zyx);
}
#line 935
float3 Hash32UV(in float2 uv, in float step) {
return Hash33(float3(uv * 14353.45646, (FrameTime % 100.0) * step));
}
#line 997
 
#line 999
float OverlayBlend(in float a, in float b) {
[branch]
if (a < 0.5) {
return a * b * 2.0;
} else {
return 1.0 - (1.0 - a) * (1.0 - b) * 2.0;
}
}
#line 1008
float3 OverlayBlend(in float3 a, in float3 b) {
return float3(
OverlayBlend(a.r, b.r),
OverlayBlend(a.g, b.g),
OverlayBlend(a.b, b.b)
);
}
#line 1016
float ScaleOcclusionAndIrradiance(in float occlusionIrradianceOverlay, in float occlusionIntensity, in float irradianceIntensity) {
#line 1018
return 0.5 + (occlusionIrradianceOverlay - 0.5) * (occlusionIrradianceOverlay < 0.5 ? occlusionIntensity : irradianceIntensity);
}
#line 1021
float3 ScaleOcclusionAndIrradiance(in float3 occlusionIrradianceOverlay, in float occlusionIntensity, in float irradianceIntensity) {
return float3(
ScaleOcclusionAndIrradiance(occlusionIrradianceOverlay.r, occlusionIntensity, irradianceIntensity),
ScaleOcclusionAndIrradiance(occlusionIrradianceOverlay.g, occlusionIntensity, irradianceIntensity),
ScaleOcclusionAndIrradiance(occlusionIrradianceOverlay.b, occlusionIntensity, irradianceIntensity)
);
}
#line 1029
float ThresholdedScaleOcclusionAndIrradiance(in float occlusionIrradianceOverlay, in float occlusionIntensity, in float irradianceIntensity) {
#line 1033
if (occlusionIrradianceOverlay <= LSPOIrrOclusionIrradianceThreshold) {
return 0.5 + occlusionIntensity * (occlusionIrradianceOverlay - LSPOIrrOclusionIrradianceThreshold) / (LSPOIrrOclusionIrradianceThreshold * 2);
} else {
return 0.5 + irradianceIntensity * (occlusionIrradianceOverlay - LSPOIrrOclusionIrradianceThreshold) / ((1 - LSPOIrrOclusionIrradianceThreshold) * 2);
}
}
#line 1040
float3 ThresholdedScaleOcclusionAndIrradiance(in float3 occlusionIrradianceOverlay, in float occlusionIntensity, in float irradianceIntensity) {
return float3(
ThresholdedScaleOcclusionAndIrradiance(occlusionIrradianceOverlay.r, occlusionIntensity, irradianceIntensity),
ThresholdedScaleOcclusionAndIrradiance(occlusionIrradianceOverlay.g, occlusionIntensity, irradianceIntensity),
ThresholdedScaleOcclusionAndIrradiance(occlusionIrradianceOverlay.b, occlusionIntensity, irradianceIntensity)
);
}
#line 1088
 
#line 1096
float ComputeBlurMaxChannel(in float2 texcoord) {
#line 1104
float maxChannel = 0;
float2 uv = float2((0.35), (0.35));
#line 1107
[unroll]
for (int i = 0; i < (7); i++) {
uv.x = (0.35);
#line 1111
[unroll]
for (int j = 0; j < (7); j++) {
maxChannel = max(maxChannel, (max(((tex2D(VBlurSampler, uv).rgb).r), max(((tex2D(VBlurSampler, uv).rgb).g), ((tex2D(VBlurSampler, uv).rgb).b)))));
uv.x += (0.05);
}
#line 1117
uv.y += (0.05);
}
#line 1124
maxChannel *= (1.5); 
#line 1126
return maxChannel;
}
#line 1129
float3 DrawBlurMaxSamplesPositions(in float2 texcoord) {
float3 color = 0;
float2 uv = float2((0.35), (0.35));
#line 1133
[unroll]
for (int i = 0; i < (7); i++) {
uv.x = (0.35);
#line 1137
[unroll]
for (int j = 0; j < (7); j++) {
float xDist = uv.x - texcoord.x;
xDist *= ReShade::GetAspectRatio();
float yDist = uv.y - texcoord.y;
float dist = xDist * xDist + yDist * yDist;
dist = sqrt(dist);
#line 1145
dist = 1.0 - dist;
dist = saturate(dist);
dist = pow(dist, 100.0);
#line 1149
dist = dist > 0.5 ? 0.5 : 0;
color += float3(dist, 0, 0);
uv.x += (0.05);
}
#line 1154
uv.y += (0.05);
}
#line 1157
return color;
}
#line 1160
float ComputeBlurGain(in float blurMax, in float reciptocalThreshold) {
[branch]
if (blurMax <= reciptocalThreshold) {
return blurMax / (reciptocalThreshold * reciptocalThreshold);
} else {
return 1.0 / blurMax;
}
}
#line 1169
float ComputeBlurMaxPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR {
return ComputeBlurMaxChannel(texcoord);
}
#line 1177
float3 LSPOIrrPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR {
#line 1179
float2 screenUV = texcoord.xy;
float3 color = tex2D(ReShadeBackBufferSRGBSampler, screenUV).rgb;
#line 1183
[branch]
if (!LSPOIrrEffectEnabled) {
return color;
}
#line 1189
float3 finalColor = color;
#line 1192
float3 overlayColor = tex2D(VBlurSampler, screenUV).rgb;
#line 1195
[branch]
if (LSPOIrrDebugType == (0x03)) {
return overlayColor;
}
#line 1201
overlayColor = (lerp((((overlayColor).r) + ((overlayColor).g) + ((overlayColor).b)) * ___ONE_THIRD___, (overlayColor), (LSPOIrrEffectSaturation)));
#line 1204
[branch]
if (LSPOIrrDebugType == (0x04)) {
return overlayColor;
}
#line 1210
[branch]
if (LSPOIrrDebugType == (0x07)) {
return lerp(color, 1.0 - step(overlayColor, 0.5), 0.65);
}
#line 1218
[branch]
if (LSPOIrrDebugType == (0x08)) {
float3 samplesPositionColor = DrawBlurMaxSamplesPositions(screenUV);
return samplesPositionColor.r < 0.01 ? color : samplesPositionColor;
}
#line 1225
float blurMax = tex2D(BlurMaxHistorySampler, screenUV).r;
#line 1228
[branch]
if (LSPOIrrDebugType == (0x09)) {
return float3(blurMax, blurMax, blurMax);
}
#line 1233
float blurGain = ComputeBlurGain(blurMax, 0.05);
#line 1236
blurGain = clamp(blurGain, 1.0, 4.0); 
#line 1239
[branch]
if (LSPOIrrDebugType == (0x0A)) {
return float3(blurGain, blurGain, blurGain);
}
#line 1245
blurGain = lerp(1.0, blurGain, LSPOIrrAutoGain);
#line 1248
overlayColor *= blurGain;
#line 1251
[branch]
if (LSPOIrrDebugType == (0x05)) {
return overlayColor;
}
#line 1259
overlayColor = ThresholdedScaleOcclusionAndIrradiance(overlayColor, LSPOIrrOcclusionIntensity, LSPOIrrIrradianceIntensity);
#line 1262
[branch]
if (LSPOIrrDebugType == (0x06)) {
return overlayColor;
}
#line 1270
 
finalColor = OverlayBlend(finalColor, overlayColor);
#line 1275
float3 recoveryOverlayColor = tex2D(ShortBlurSampler, screenUV).rgb;
recoveryOverlayColor = (lerp((((recoveryOverlayColor).r) + ((recoveryOverlayColor).g) + ((recoveryOverlayColor).b)) * ___ONE_THIRD___, (recoveryOverlayColor), (0.0)));
recoveryOverlayColor = 1.0 - recoveryOverlayColor;
#line 1280
[branch]
if (LSPOIrrDebugType == (0x0B)) {
return recoveryOverlayColor;
}
#line 1286
[branch]
if (LSPOIrrDebugType == (0x0D)) {
return lerp(color, 1.0 - step(recoveryOverlayColor, 0.5), 0.65);
}
#line 1291
recoveryOverlayColor = (recoveryOverlayColor - 0.5) * LSPOIrrOcclusionIrradianceRecovery + 0.5;
#line 1294
recoveryOverlayColor = ScaleOcclusionAndIrradiance(recoveryOverlayColor, LSPOIrrIrradianceIntensity, LSPOIrrOcclusionIntensity);
#line 1297
[branch]
if (LSPOIrrDebugType == (0x0C)) {
return recoveryOverlayColor;
}
#line 1303
finalColor = OverlayBlend(finalColor, recoveryOverlayColor);
#line 1306
[branch]
if (LSPOIrrDebugType == (0x02)) {
return finalColor;
}
#line 1312
finalColor = pow(max(0.0, finalColor), LSPOIrrGamma);
#line 1315
finalColor *= LSPOIrrGain;
#line 1318
finalColor = (finalColor - 0.5) * LSPOIrrContrast + 0.5;
#line 1321
finalColor = (lerp((((finalColor).r) + ((finalColor).g) + ((finalColor).b)) * ___ONE_THIRD___, (finalColor), (LSPOIrrSaturation)));
#line 1324
float3 originalFinalColor = finalColor;
#line 1327
[branch]
if (LSPOIrrDebugType == (0x01)) {
return finalColor;
}
#line 1333
finalColor = lerp(color, finalColor, LSPOIrrEffectIntensity);
#line 1335
return finalColor;
}
#line 1342
float BlendBlurMaxIntoHistoryPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR {
float blurMax = tex2D(BlurMaxSampler, texcoord).r;
float blurMaxHistory = tex2D(BlurMaxHistorySampler, texcoord).r;
#line 1347
blurMaxHistory = lerp(blurMaxHistory, blurMax, 0.04);
#line 1349
return blurMaxHistory;
}
#line 1352
float CopyBlurMaxHistoryTempPS(in float4 vpos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR {
return tex2D(BlurMaxHistoryTempSampler, texcoord).r;
}
#line 1360
technique FGFXLSPOIrr <
ui_label = "FGFX::LSPOIrr";
ui_tooltip =
"+------------------------------------------------------------------------+\n"
"|-=[ FGFX::LSPOIrr - Large Scale Perceptual Obscurance and Irradiance ]=-|\n"
"+------------------------------------------------------------------------+\n"
"\n"
#line 1368
"The Large Scale Perceptual Obscurance and Irradiance is a post-processing\n"
"effect that attempts to inject obscurance and irradiance in the scene at a\n"
"large scale (low frequency).\n"
"\n"
#line 1373
"The Large Scale Perceptual Obscurance and Irradiance is written by\n"
"Alex Tuduran.\n";
> {
#line 1381
pass CopyBB {
VertexShader = PostProcessVS;
PixelShader  = CopyBBPS;
RenderTarget = HalfBlurTex;
}
#line 1387
pass CopyHalf {
VertexShader = PostProcessVS;
PixelShader  = CopyHalfPS;
RenderTarget = QuadBlurTex;
}
#line 1393
pass CopyQuad {
VertexShader = PostProcessVS;
PixelShader  = CopyQuadPS;
RenderTarget = OctoBlurTex;
}
#line 1399
pass CopyOcto {
VertexShader = PostProcessVS;
PixelShader  = CopyOctoPS;
RenderTarget = HexaBlurTex;
}
#line 1409
pass CopyHexa {
VertexShader = PostProcessVS;
PixelShader  = CopyHexaPS;
RenderTarget = VBlurTex;
}
#line 1418
pass HBlurC0R {
VertexShader = PostProcessVS;
PixelShader  = HBlurC0PS;
RenderTarget = HBlurTex;
}
#line 1424
pass VBlurC0R {
VertexShader = PostProcessVS;
PixelShader  = VBlurC0PS;
RenderTarget = VBlurTex;
}
#line 1434
pass HBlurC0S {
VertexShader = PostProcessVS;
PixelShader  = HBlurC0PS;
RenderTarget = HBlurTex;
}
#line 1440
pass VBlurC0S {
VertexShader = PostProcessVS;
PixelShader  = VBlurC0PS;
RenderTarget = VBlurTex;
}
#line 1450
pass HBlurC0SS {
VertexShader = PostProcessVS;
PixelShader  = HBlurC0PS;
RenderTarget = HBlurTex;
}
#line 1456
pass VBlurC0SS {
VertexShader = PostProcessVS;
PixelShader  = VBlurC0PS;
RenderTarget = VBlurTex;
}
#line 1466
pass HBlurC1R {
VertexShader = PostProcessVS;
PixelShader  = HBlurC1PS;
RenderTarget = HBlurTex;
}
#line 1472
pass VBlurC1R {
VertexShader = PostProcessVS;
PixelShader  = VBlurC1PS;
RenderTarget = VBlurTex;
}
#line 1492
pass HBlurC2R {
VertexShader = PostProcessVS;
PixelShader  = HBlurC2PS;
RenderTarget = HBlurTex;
}
#line 1498
pass VBlurC2R {
VertexShader = PostProcessVS;
PixelShader  = VBlurC2PS;
RenderTarget = VBlurTex;
}
#line 1508
pass ShortBlur {
VertexShader = PostProcessVS;
PixelShader  = CopyVBlurPS;
RenderTarget = ShortBlurTex;
}
#line 1518
pass HBlurC2S {
VertexShader = PostProcessVS;
PixelShader  = HBlurC2PS;
RenderTarget = HBlurTex;
}
#line 1524
pass VBlurC2S {
VertexShader = PostProcessVS;
PixelShader  = VBlurC2PS;
RenderTarget = VBlurTex;
}
#line 1546
 
#line 1550
pass HBlurC0US {
VertexShader = PostProcessVS;
PixelShader  = HBlurC0PS;
RenderTarget = HBlurTex;
}
#line 1556
pass VBlurC0US {
VertexShader = PostProcessVS;
PixelShader  = VBlurC0PS;
RenderTarget = VBlurTex;
}
#line 1568
pass PassComputeBlurMax {
VertexShader = PostProcessVS;
PixelShader  = ComputeBlurMaxPS;
RenderTarget = BlurMaxTex;
}
#line 1574
pass PassBlendBlurMaxIntoHistoryTemp {
VertexShader = PostProcessVS;
PixelShader  = BlendBlurMaxIntoHistoryPS;
RenderTarget = BlurMaxHistoryTempTex;
}
#line 1580
pass CopyBlurMaxHistoryTemp {
VertexShader = PostProcessVS;
PixelShader = CopyBlurMaxHistoryTempPS;
RenderTarget = BlurMaxHistoryTex;
}
#line 1590
pass PassLSPOIrr {
VertexShader = PostProcessVS;
PixelShader  = LSPOIrrPS;
#line 1595
 
}
#line 1600
} 

