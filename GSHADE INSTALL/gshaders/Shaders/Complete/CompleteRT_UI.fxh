//Stochastic Screen Space Ray Tracing
//Written by MJ_Ehsan for Reshade
//Version 1.6 - User Interface

static const bool bTest0 = 0;
static const bool bTest1 = 1;
static const bool UI_TemporalReSTIRGI = 0;

#if C_RT_UI_DIFFICULTY == 1

uniform int Hints <
	ui_text = "1- Use with a motion estimation shader such as:\n"
	
	          "  A: RECOMMENDED - ReShade_MotionVectors\n"
	          "  B: qUINT_MotionVectors\n"
	          "  C: DRME\n"
	          "  D: iMMERSE Launchpad\n"
	          "  E: DH_UBER_MOTION\n"
	          "2- Read the PreProcessor Settings tooltip before changing them.\n"
	          "3- Enjoy! :)";
			  
	ui_category = "Hints - Please Read for good results.";
	ui_category_closed = true;
	ui_label = " ";
	ui_type = "radio";
>;

//Reflection
uniform bool UI_ReflectionEnable <
	ui_label = "Enable Reflections";
	ui_category = "Reflection";
	ui_category_toggle = true;
> = 1;

uniform float UI_ReflectionRayDepth <
	ui_label = "Surface thickness";
	ui_type = "slider";
	ui_category = "Reflection";
	ui_category_closed = true;
	ui_min = 0.05;
	ui_max = 10;
> = 3;


uniform uint UI_ReflectionRaySteps <
	ui_label = "Ray Precision"; 
	ui_type = "slider";
	ui_category = "Reflection";
	ui_tooltip = "Increases precision at the cost of performance.";
	ui_category_closed = true;
	ui_min = 1;
	ui_max = 24;
> = 20;

uniform uint UI_SampleCount <
	ui_label = "SampleCount"; 
	ui_type = "slider";
	ui_category = "Reflection";
	ui_tooltip = "Increases detail and stability at the cost of performance.";
	ui_category_closed = true;
	ui_min = 1;
	ui_max = 4;
> = 1;

uniform float UI_SpecularIntensity <
	ui_label = "Intensity";
	ui_type = "slider";
	ui_category = "Reflection";
> = 0.5;

uniform float fov <
	ui_label = "Field of View";
	ui_type = "slider";
	ui_category = "Reflection";
	ui_tooltip = "Adjust if reflections look odd.";
	ui_min = 60;
	ui_max = 120;
> = 70;

uniform float UI_Roughness <
	ui_label = "Roughness";
	ui_type = "slider";
	ui_category = "Reflection";
	ui_category_closed = true;
	ui_min = 0.0;
	ui_max = 0.999;
> = 0.4;

uniform bool UI_RainRoughness <
	ui_label           = "Rainy Mode";
	ui_category        = "Reflection";
	ui_category_closed = true;
	ui_tooltip         = "Reduces roughness on the ground to simulate rainy weather,\n"
	                     "while keeping other surafeces' roughness untouched.";
> = 0;

//Diffuse Illumination
uniform bool UI_GIAOEnable <
	ui_label = "Enable Diffuse Lighting";
	ui_category = "Diffuse Illumination";
	ui_category_toggle = true;
> = 1;

uniform bool UI_ReuseSamples <
	ui_label    = "Enable ReSTIR-GI";
	ui_type     = "radio";
	ui_category = "Diffuse Illumination";
	ui_tooltip  = "Decreases noise and increases accuracy at the cost of performance\n";
	ui_category_closed = true;
> = 0;

uniform int UI_RTColorSubCategory <
	ui_label = " ";
	ui_text = "=== COLOR ADJUSTMENTS ===";
	ui_category = "Diffuse Illumination";
	ui_type = "radio";
> = 0;

uniform float UI_Exposure <
	ui_type = "slider";
	ui_label = "Exposure";
	ui_category = "Diffuse Illumination";
	ui_category_closed = true;
	ui_min = 0;
	ui_max = 4;
> = 1;

uniform float UI_Saturation <
	ui_type = "slider";
	ui_label = "Saturation";
	ui_category = "Diffuse Illumination";
	ui_min = 0;
	ui_max = 2;
> = 1;

uniform int UI_GIMaskSubCategory <
	ui_label = " ";
	ui_text = "=== LIGHT MAP MASKING ===";
	ui_category = "Diffuse Illumination";
	ui_type = "radio";
> = 0;

uniform float UI_MaskDirect <
	ui_type     = "slider";
	ui_label    = "Exclude Direct Lights";
	ui_category = "Diffuse Illumination";
	ui_tooltip  = "Direct lights (sun, lamps, etc.) will not affect the Diffuse Illumination.\n"
	              "Lower values detects direct lights more sensitively.";
	ui_min      = 0.5;
> = 1;

uniform bool UI_MaskSky <
	ui_label    = "Exclude Sky from RT";
	ui_category = "Diffuse Illumination";
	ui_tooltip  = "Sky will not affect the ray traced lighting if enabled.";
> = 1;

uniform int UI_DiffuseRaySubCategory <
	ui_label = " ";
	ui_text = "=== RAY TRACING =========";
	ui_category = "Diffuse Illumination";
	ui_type = "radio";
> = 0;

uniform uint UI_RaySteps <
	ui_label = "Ray Precision"; 
	ui_type = "slider";
	ui_category = "Diffuse Illumination";
	ui_tooltip = "Increases precision at the cost of performance.";
	ui_category_closed = true;
	ui_min = 1;
	ui_max = 64;
> = 64;

uniform float UI_RayLength <
	ui_label = "Ray Length";
	ui_type = "slider";
	ui_category = "Diffuse Illumination";
	ui_tooltip = "Increases ray length at the cost of precision.";
	ui_category_closed = true;
	ui_min = 0;
	ui_max = 1;
> = 1.0;

uniform float UI_RayDepth <
	ui_label = "Surface thickness";
	ui_type = "slider";
	ui_category = "Diffuse Illumination";
	ui_tooltip = "Multiplier to the estimated surface thickness";
	ui_category_closed = true;
	ui_min = 0.05;
	ui_max = 10;
> = 3;

uniform bool UI_ThicknessEstimation <
	ui_label = "Estimate thickness";
	ui_category = "Diffuse Illumination";
	ui_tooltip = "Use to imrpove lights coming from tiny objects";
	ui_category_closed = true;
> = 0;

//Ambient Occlusion
uniform float UI_AORadius <
	ui_label = "Radius";
	ui_type = "slider";
	ui_category = "Ambient Occlusion (Enable Diffuse Lighting)";
	ui_category_closed = true;
	ui_tooltip = "Maximum distance to find occlusions.";
> = 0.25;

uniform float UI_AOIntensity <
	ui_label = "Intensity";
	ui_type = "slider";
	ui_category = "Ambient Occlusion (Enable Diffuse Lighting)";
> = 0.5;

//Ambient Lighting
uniform float UI_SkyColorIntensity <
	ui_type = "slider";
	ui_label = "Sky Color Intensity";
	ui_category = "Ambient Lighting";
	ui_min = 0;
	ui_max = 1;
> = 0;

uniform float3 UI_SkyColorTint <
	ui_type = "color";
	ui_label = "Tint";
	ui_category = "Ambient Lighting";
> = float3(1.0, 1.0, 1.0);

uniform bool UI_SkyColorMode <
	ui_type = "radio";
	ui_label = "Auto Detect Sky Color";
	ui_category = "Ambient Lighting";
> = 1;

uniform float UI_AmbientLight <
	ui_label = "Ambient Light Intensity";
	ui_type  = "slider";
	ui_category = "Ambient Lighting";
> = 1.0;

//Normal Filtering
uniform float UI_BumpStrength <
	ui_label = "Bump mapping strengh";
	ui_type = "slider";
	ui_category = "Normal Filtering";
	ui_tooltip = "Adds tiny details to the lighting.";
	ui_min = 0.0;
	ui_max = 1.0;
> = 0.4;

uniform int UI_SmoothNormals <
	ui_label = "Smooth normals quality";
	ui_type  = "slider";
	ui_category = "Normal Filtering";
	ui_min = 0;
	ui_max = 10;
> = 3;

uniform float UI_ResolutionScale <
	ui_type = "slider";
	ui_category = "Performance";
	ui_label = "Resolution Scale";
	ui_min  = 0.333333;
> = 0.5;

//Denoiser (Advanced)
uniform float UI_MVErrorT <
	ui_label = "Motion Vector\nError Tolerance";
	ui_type = "slider";
	ui_category = "Denoiser (Advanced)";
	ui_tooltip = "Lower values result in less ghosting\n"
	             "Higher values result in more stability\n"
	             "If the game has unstable image - such as\n"
	             "intensive film grain, increase the value a bit.";
	ui_category_closed = true;
	//hidden = true;
	ui_min = 0;
	ui_max = 0.1;
> = 0.03;

//Denoiser (Advanced)
uniform int UI_FilterQuality <
	ui_label = "Filter Quality";
	ui_type  = "combo";
	ui_items = "Medium\0High\0";
	ui_category = "Denoiser (Advanced)";
	ui_category_closed = true;
> = 1;

uniform int UI_MaxFrames <
	ui_label = "History Length";
	ui_type = "slider";
	ui_category = "Denoiser (Advanced)";
	ui_tooltip = "Higher values increase smoothness\n"
				 "while preserves more details.";
	ui_category_closed = true;
	//hidden = true;
	ui_min = 1;
	ui_max = 64;
> = 64;

uniform float UI_Sthreshold <
	ui_label = "Spatial Denoiser\nThreshold";
	ui_type = "slider";
	ui_category = "Denoiser (Advanced)";
	ui_tooltip = "MODIFICATION IS NOT RECOMMENDED!!\nBTW, lower = less noise, higher = more details.";
	ui_category_closed = true;
	//hidden = true;
	ui_min = 0.001;
	ui_max = 4;
> = 1;

//Masking
uniform float UI_DepthFade <
	ui_label = "Depth Fade";
	ui_type = "slider";
	ui_category = "Masking";
	ui_category_closed = true;
	ui_tooltip = "Higher values decrease the intensity on distant objects.\n"
				 "Reduces blending issues within in-game fogs.";
	ui_min = 0;
	ui_max = 1;
> = 0.75;

uniform int UI_FadeMode <
	ui_label = "Fade Mode";
	ui_type = "combo";
	ui_category = "Masking";
	ui_tooltip = "Exponential: Good for modern games with pyshical and volumetric fog\n"
	             "Linear: Good for older games with simple and fake fog";
	ui_items = "Exponential\0Linear\0";
#if __RENDERER__ >= 0xb000
> = 0;
#else
> = 1;
#endif

uniform uint UI_Debug <
	ui_type = "combo";
	ui_label = "Debug mode";
	ui_items = "None\0"                                          //0
	           "Lighting\0Lightmap\0"                            //1-2
	           "Depth\0Normal\0Accumulation\0"                   //3-4-5
	           //"Roughness\0Variance\0Motion\0ReSTIR\0Thickness\0"//6-7-8   for DEV_MODE only
				;
	ui_category = "Extra";
#ifndef DevMode
	ui_max = 5;
#endif
	ui_category_closed = true;
> = 0;

uniform int Preprocessordefinitionstooltip<
	ui_text = "C_RT_UI_DIFFICULTY:\n0 is easy Setup. While 1 gives access to more settings.\n\n"

	          "C_RT_USE_LAUNCHPAD_MOTIONS:\nIf you want to use CompleteRT with iMMERESE Launchpad's motion vectors, set this to one.";
	          
	ui_category = "PreProcessor Settings tooltip";
	ui_category_closed = true;
	ui_label = " ";
	ui_type = "radio";
>;

#else //EZ Mode

uniform int Hints <
	ui_text = "1- Use with a motion estimation shader such as:\n"
	
	          "  A: RECOMMENDED - ReShade_MotionVectors\n"
	          "  B: qUINT_MotionVectors\n"
	          "  C: DRME\n"
	          "  D: iMMERSE Launchpad\n"
	          "  E: DH_UBER_MOTION\n"
	          "2- Read the PreProcessor Settings tooltip before changing them.\n"
	          "3- Enjoy! :)";
			  
	ui_category = "Hints - Please Read for good results.";
	ui_category_closed = true;
	ui_label = " ";
	ui_type = "radio";
>;

uniform bool UI_ReflectionEnable <
	ui_label = "Enable Reflections";
> = 1;

uniform bool UI_GIAOEnable <
	ui_label = "Enable Diffuse Lighting";
> = 1;

uniform int UI_QualityPreset <
	ui_type = "combo";
	ui_label = "Quality Preset";
	ui_items = 
"Very Low\0"
"Low\0"
"Medium\0"
"High\0"
"Very High\0";
> = 1;

uniform float UI_BumpStrength <
	ui_label = "Bump mapping strengh";
	ui_type = "slider";
	ui_tooltip = "Adds tiny details to the lighting.";
	ui_min = 0.0;
	ui_max = 1.0;
> = 0.4;

uniform float UI_Roughness <
	ui_label = "Roughness";
	ui_type = "slider";
	ui_category = "Reflection";
	ui_category_closed = true;
	ui_tooltip = "Blurriness of reflections.";
	ui_min = 0.0;
	ui_max = 0.999;
> = 0.4;

uniform bool UI_RainRoughness <
	ui_label           = "Rainy Mode";
	ui_category        = "Reflection";
	ui_category_closed = true;
	ui_tooltip         = "Reduces roughness on the ground to simulate rainy weather,\n"
	                     "while keeping other surafeces' roughness untouched.";
> = 0;

uniform float UI_SpecularIntensity <
	ui_label           = "Intensity";
	ui_type            = "slider";
	ui_category        = "Reflection";
	ui_category_closed = true;
	ui_tooltip         = "Intensity of reflections.";
> = 0.5;

uniform float UI_AORadius <
	ui_label = "Ambient Occlusion Radius";
	ui_type = "slider";
	ui_category = "Ambient Occlusion";
	ui_category_closed = true;
	ui_tooltip = "Maximum distance to find occlusions.";
> = 0.25;

uniform float UI_AOIntensity <
	ui_label = "Ambient Occlusion Intensity";
	ui_type = "slider";
	ui_category = "Ambient Occlusion";
	ui_category_closed = true;
> = 0.5;

uniform float UI_AmbientLight <
	ui_label = "Ambient Light Intensity";
	ui_type  = "slider";
	ui_category = "Ambient Occlusion";
> = 1.0;

uniform float UI_Exposure <
	ui_type = "slider";
	ui_label = "GI Exposure";
	ui_category = "Diffuse Illumination";
	ui_category_closed = true;
	ui_min = 0;
	ui_max = 4;
> = 1;

uniform float UI_Saturation <
	ui_type = "slider";
	ui_label = "GI Saturation";
	ui_category = "Diffuse Illumination";
	ui_category_closed = true;
	hidden = true;
	ui_min = 0;
	ui_max = 2;
> = 1;

uniform float UI_MaskDirect <
	ui_type     = "slider";
	ui_label    = "Exclude Direct Lights";
	ui_category = "Diffuse Illumination";
	ui_category_closed = true;
	ui_tooltip  = "Direct lights (sun, lamps, etc.) will not affect the Diffuse Illumination.\n"
	              "Lower values detects direct lights more sensitively.";
	ui_min      = 0.5;
> = 1;

uniform bool UI_MaskSky <
	ui_label    = "Exclude Sky from RT";
	ui_category = "Diffuse Illumination";
	ui_category_closed = true;
	ui_tooltip  = "Sky will not affect the ray traced lighting if enabled.";
> = 1;

uniform float UI_SkyColorIntensity <
	ui_type = "slider";
	ui_label = "Sky Color Intensity";
	ui_category = "Diffuse Illumination";
	ui_category_closed = true;
	ui_min = 0;
	ui_max = 1;
> = 0;
	

uniform float UI_DepthFade <
	ui_label = "Depth Fade";
	ui_type = "slider";
	ui_category = "Masking";
	ui_tooltip = "Higher values decrease the intensity on distant objects.\n"
				 "Reduces blending issues with in-game fogs.";
	ui_min = 0;
	ui_max = 1;
> = 0.75;

uniform uint UI_Debug <
	ui_type = "combo";
	ui_label = "Debug mode";
	ui_items = "None\0"                                      // 0
	           "Lighting\0Lightmap\0"                        //1 -2
	           "Depth\0Normal\0"                             //3-4
	           //"Accumulation\0Roughness\0Variance\0Motion\0ReSTIR\0Thickness\0"      //6-7-8   for DEV_MODE only
;	ui_category = "Debug";
	ui_category_closed = true;
	ui_max = 4;
> = 0;

uniform int Preprocessordefinitionstooltip<
	ui_text = "C_RT_UI_DIFFICULTY:\n0 is easy Setup. While 1 gives access to more settings.\n\n"

	          "C_RT_USE_LAUNCHPAD_MOTIONS:\nIf you want to use CompleteRT with iMMERESE Launchpad's motion vectors, set this to one.";
	          
	ui_category = "PreProcessor Settings tooltip";
	ui_category_closed = true;
	ui_label = " ";
	ui_type = "radio";
>;

#endif
