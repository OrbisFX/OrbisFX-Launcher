/*
#if (__RENDERER__ == 0x9000)
	uniform int DX9_WARNING <
		ui_type = "radio";
		ui_text = "\nNOTE: Due to a Dx9 limitation, some settings have been moved to preprocessors at the bottom of the menu";
		ui_label = " ";
	> = 0;
#endif
*/
//============================================================================================
//Rendering
//============================================================================================
#pragma once

#ifndef HIDE_GUIDES
//============================================================================================
	#define HIDE_GUIDES 0
//============================================================================================
#endif

uniform bool RENDER <
	ui_category = "Rendering";
	ui_label = "Render";
	ui_tooltip = "Begins accumulating frames, recommended to set a keybind (right click the setting)";
	ui_category_closed = true;
> = 0;

uniform bool HOLD_RENDER <
	ui_category = "Rendering";
	ui_label = "Pause Render\n\n";
	ui_category_closed = true;
> = 0;

uniform bool DO_BLOOM <
	ui_category = "Rendering";
	ui_label = "Bloom";
	ui_category_closed = true;
> = 1;

uniform int BLOOM_TYPE <
	ui_type = "combo";
	ui_items = "Edge - Center\0Random\0";//\0Center - Edge
	ui_category = "Rendering";
	ui_tooltip = "Selects the sample pattern for the bloom. 'Edge - Center' is fastest by far and produces the highest quality results"; 
	ui_label = "Bloom Sample Pattern";
	ui_category_closed = true;
> = 0;


uniform int BLOOM_SAMPLES <
	ui_type = "slider";
	ui_category = "Rendering";
	ui_label = "Bloom Samples";
	ui_tooltip = "Bloom samples taken per frame || Higher values will have less noise but are less performant";
	ui_category_closed = true;
	ui_min = 3;
	ui_max = 16;
> = 4;

uniform float BLOOM_SPEED <
	ui_type = "slider";
	ui_category = "Rendering";
	ui_label = "Bloom Convergence";
	ui_tooltip = "Higher values will accumulate faster with more noise, Lower values take longer to render with much less noise\n"
				"Only applies to 'Edge - Center' Sampling";
	ui_category_closed = true;
	ui_min = 0.15;
	ui_max = 3.0;
> = 1.0;

uniform bool BLOOM_BAR <
	ui_category = "Rendering";
	ui_label = "Bloom progress bar\n\n";
	ui_tooltip = "Shows a progress bar for the initial bloom pass, after which random sampling is used";
	ui_category_closed = true;
> = 1;


uniform bool DO_HALATION <
	ui_category = "Rendering";
	ui_label = "Halation";
	ui_category_closed = true;
> = 1;



uniform int HALATION_SAMPLES <
		ui_type = "slider";
		ui_category = "Rendering";
		ui_label = "Halation Samples";
		ui_tooltip = "Halation samples taken per frame || Set as high as you can without significantly reducing frame rate";
		ui_category_closed = true;
		ui_min = 3;
		ui_max = 16;
> = 4;

uniform int BLOOM_SETTINGS <
	ui_type = "radio";
	ui_text = "\nBloom Settings:";
	ui_label = " ";
	ui_category = "Bloom";
> = 0;


uniform int APETURE_SIDES <
	ui_type = "slider";
	ui_category = "Bloom";
	ui_label = "Aperture Sides";
	ui_tooltip = "The amount of sides the apeture has for bloom || Linear effect on performance";
	ui_category_closed = true;
	ui_min = 2;
	ui_max = 9;
> = 6;

uniform float BLOOM_DIFFRACTION <
	ui_type = "slider";
	ui_category = "Bloom";
	ui_label = "Diffraction";
	ui_tooltip = "The density of diffraction in the bloom || Controls the 'Rainbowing' of the effect";
	ui_category_closed = true;
	ui_min = 0.0;
	ui_max = 8.0;
> = 5.0;

uniform float BLOOM_DEFLECTION <
	ui_type = "slider";
	ui_category = "Bloom";
	ui_label = "Deflection";
	ui_tooltip = "How much bloom deflects || Higher values will cause longer streaks and take slightly longer to render";
	ui_category_closed = true;
	ui_min = 0.0;
	ui_max = 1.1;
> = 0.85;

uniform float BLOOM_EXPOSURE <
	ui_type = "slider";
	ui_category = "Bloom";
	ui_label = "Threshold";
	ui_tooltip = "How bright something has to be to produce bloom || 1.0 will accept every surface, 20.0 will only accept the very brightest";
	ui_category_closed = true;
	ui_min = 1.0;
	ui_max = 4.0;
> = 1.0;

uniform float BLOOM_INTENSITY <
	ui_type = "slider";
	ui_category = "Bloom";
	ui_label = "Intensity";
	ui_tooltip = "Overall intensity of the bloom ";
	ui_category_closed = true;
	ui_min = 0.0;
	ui_max = 1.0;
> = 0.3;

uniform float BLOOM_BRIGHT <
	ui_type = "slider";
	ui_category = "Bloom";
	ui_label = "Brightness";
	ui_tooltip = "Peak intensity if the bloom";
	ui_category_closed = true;
	ui_min = 0.0;
	ui_max = 4.0;
> = 1.25;

uniform float BLOOM_ANGLE <
	ui_type = "slider";
	ui_category = "Bloom";
	ui_label = "Aperture Rotation";
	ui_tooltip = "The direction of bloom streaks";
	ui_category_closed = true;
	ui_min = 0.0;
	ui_max = 3.14;
> = 0.4;

//============================================================================================
//Film Grain
//============================================================================================

uniform int FILM_GUIDE <
	ui_type = "radio";
	ui_text = "Film Settings:\n\n"
			"Settings to control film grain, dust/dirt, and the film border";
	ui_label = " ";
	hidden = HIDE_GUIDES;
	ui_category = "Film Settings guide";
> = 0;

uniform float DB_SEED <
	ui_type = "slider";
	ui_min = 1.0;
	ui_max = 128.0;
	ui_step = 1.0;
	ui_label = "Dust/Border Seed";
	ui_tooltip = "Allows for variation between still shots";
	ui_category = "Film";
	ui_category_closed = true;
> = 1.0;

uniform bool STATIC_GRAIN <
	ui_label = "Static Film";
	ui_tooltip = "Toggle static film grain, dust, and border for stills shots";
	ui_category = "Film";
> = 1;

uniform int GRAIN_SETTINGS <
	ui_type = "radio";
	ui_text = "Film Grain Settings:";
	ui_label = " ";
	ui_category = "Film Grain";
> = 0;

uniform float GRAIN_INTENSITY <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_label = "Intensity";
	ui_tooltip = "Overall intensity of the film grain";
	ui_category = "Film Grain";
	ui_category_closed = true;
> = 0.45;

uniform float NOISE_FLOOR <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_label = "Noise Floor";
	ui_tooltip = "Adds noise in the image to raise blacks";
	ui_category = "Film Grain";
	ui_category_closed = true;
> = 0.07;

uniform float GRAIN_SIZE <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_label = "Size";
	ui_tooltip = "Scale of the film grain";
	ui_category = "Film Grain";
	ui_category_closed = true;
> = 0.5;

uniform float GRAIN_DEFINITION <
	ui_type = "slider";
	ui_min = 1.0;
	ui_max = 3.0;
	ui_label = "Definition";
	ui_tooltip = "How defined film grain particles are from their surroundings";
	ui_category = "Film Grain";
	ui_category_closed = true;
	hidden = true;
> = 1.0;

uniform float GRAIN_SATURATION <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_label = "Saturation";
	ui_tooltip = "How saturated the film grain is";
	ui_category = "Film Grain";
	ui_category_closed = true;
> = 0.9;



//============================================================================================
//Film Dust
//============================================================================================

uniform int DUST_SETTINGS <
	ui_type = "radio";
	ui_text = "\nFilm Dirt Settings:";
	ui_label = " ";
	ui_category = "Film Dust";
> = 0;

uniform bool DO_DUST <
	ui_label = "Enable Dust";
	ui_category = "Film Dust";
> = 1;

uniform float DUST_STRENGTH <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_label = "Strength";
	ui_tooltip = "How much the dust darkens the image";
	ui_category = "Film Dust";
	ui_category_closed = true;
> = 0.33;

uniform float DUST_THRESH <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_label = "Threshold";
	ui_tooltip = "Density of dust particles";
	ui_category = "Film Dust";
	ui_category_closed = true;
> = 0.5;

uniform float DUST_SIZE <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 0.9;
	ui_label = "Size";
	ui_tooltip = "Size of dust particles";
	ui_category = "Film Dust";
	ui_category_closed = true;
> = 0.6;

uniform float DUST_DEFINITION <
	ui_type = "slider";
	ui_min = 1.0;
	ui_max = 2.0;
	ui_label = "Definition";
	ui_tooltip = "Definition of dust particles";
	ui_category = "Film Dust";
	ui_category_closed = true;
> = 1.1;
//============================================================================================
//Film Border Settings
//============================================================================================

uniform int BORDER_SETTINGS <
	ui_type = "radio";
	ui_text = "\nFilm Border Settings:";
	ui_label = " ";
	ui_category = "Film Border";
> = 0;

uniform bool DO_BORDER <
	ui_label = "Enable Border";
	ui_category = "Film Border";
> = 1;

uniform float X_TILT <
	ui_type = "slider";
	ui_min = -0.3;
	ui_max = 0.3;
	ui_label = "X Tilt";
	ui_category = "Film Border";
	ui_category_closed = true;
> = 0.01;

uniform float Y_TILT <
	ui_type = "slider";
	ui_min = -0.3;
	ui_max = 0.3;
	ui_label = "Y Tilt";
	ui_category = "Film Border";
	ui_category_closed = true;
> = -0.005;

uniform int X_WIDTH <
	ui_type = "slider";
	ui_min = 0;
	ui_max = BUFFER_WIDTH / 2;
	ui_label = "X Width";
	ui_category = "Film Border";
	ui_category_closed = true;
> = 20;

uniform int Y_WIDTH <
	ui_type = "slider";
	ui_min = 0;
	ui_max = BUFFER_HEIGHT / 2;
	ui_label = "Y Width";
	ui_category = "Film Border";
	ui_category_closed = true;
> = 20;

uniform float BORDER_NOISE <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 0.5;
	ui_label = "Texture Amount";
	ui_tooltip = "How much texture affects the film border";
	ui_category = "Film Border";
	ui_category_closed = true;
> = 0.015;

uniform float BORDER_TEX_DENSITY <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 0.2;
	ui_label = "Texture Density \n\n";
	ui_tooltip = "Scale of the film border texturing";
	ui_category = "Film Border";
	ui_category_closed = true;
> = 0.045;



//============================================================================================
//Halation
//============================================================================================

uniform int HALATION_SETTINGS <
	ui_type = "radio";
	ui_text = "\nHalation Settings: \n\n"
			"Halation is an effect caused by light bouncing off the film backing and scattering inside individual film color layers\n"
			"Here you have near complete control over the positioning and properties of these layers"
	"\n\n\n";
	ui_label = " ";
	hidden = HIDE_GUIDES;
	ui_category = "Halation Guide";
> = 0;

uniform float FILM_HALATION <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 0.3;
	ui_label = "Intensity";
	ui_tooltip = "Intensity of halation, increase scatter multiplier if wider halation is wanted";
	ui_category = "Halation";
	ui_category_closed = true;
> = 0.2;

uniform float3 FILM_LPOS <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 120.0;
	ui_label = "Layer Position";
	ui_tooltip = "How far the Red, Green, and Blue sensitive layers are from the anti-halation layer in microns";
	ui_category = "Halation";
	ui_category_closed = true;
> = float3(28.0, 51.0, 69.0);

uniform float2 FILM_LOCC <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_label = "Layer Occlusion";
	ui_tooltip = "How much light is blocked by subsequent light layers (How much scattering affects the G and B layers)";
	ui_category = "Halation";
	ui_category_closed = true;
> = float2(0.5, 0.5);

uniform float FILM_DIFFUSE <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_label = "Diffuse";
	ui_tooltip = "Ratio of the diffuse component for halation. 1.0 is fully diffuse, 0.0 is fully gloss";
	ui_category = "Halation";
	ui_category_closed = true;
> = 0.8;

uniform float FILM_GLOSS <
	ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_label = "Gloss";
	ui_tooltip = "Smoothness of the gloss component of the film backing for halation";
	ui_category = "Halation";
	ui_category_closed = true;
> = 0.5;

uniform float SCATTER_MULT <
	ui_type = "slider";
	ui_min = 1.0;
	ui_max = 10.0;
	ui_label = "Scatter Multiplier";
	ui_tooltip = "Static multiplier to halation range";
	ui_category = "Halation";
	ui_category_closed = true;
> = 1.5;

//============================================================================================
//Film Layer Response Settings
//============================================================================================

uniform int WAVE_RESPONSE_SETTINGS <
	ui_type = "radio";
	ui_text = "\nWave Emission Settings: \n\n"
			"The wave emission settings allow you to take control of the spectral aspect of your images.\n"
			"Each channel (R, G, and B) are assigned a peak wavelength to emit, as well as a width control, allowing shifting or even complete inversion "
			"of the light spectrum. An additional channel (Q) is provided to allow additional emissions"
			" (ex, making the color blue emit infrared light), Note that different film responses react differently to different wavelengths."
	"\n\n\n";
	ui_label = " ";
	hidden = HIDE_GUIDES;
	ui_category = "Wave Emission Guide";
> = 0;

uniform float R_WAVELENGTH <
	ui_label = "R Channel Wavelength";
	ui_tooltip = "Peak wavelength emmited by the R channel";
	ui_category = "Wave Emission Settings";	
> = 635.0;

uniform float R_WIDTH <
	ui_type = "slider";
	ui_label = "R Channel Width";
	ui_tooltip = "How wide of a frequency band is emitted by the R channel";
	ui_category = "Wave Emission Settings";
	ui_min = 0.0;
	ui_max = 1.0;
> = 0.3;

uniform float R_INTENSITY <
	ui_label = "R Channel Intensity\n\n";
	ui_tooltip = "Intensity of the emmision from the R channel";
	ui_category = "Wave Emission Settings";
	ui_type = "slider";
	ui_min = 0;
	ui_max = 2.0;
> = 1.0;

uniform float G_WAVELENGTH <
	ui_label = "G Channel Wavelength";
	ui_tooltip = "Peak wavelength emmited by the G channel";
	ui_category = "Wave Emission Settings";
> = 532.0;

uniform float G_WIDTH <
	ui_type = "slider";
	ui_label = "G Channel Width";
	ui_tooltip = "How wide of a frequency band is emitted by the G channel";
	ui_category = "Wave Emission Settings";
	ui_min = 0.0;
	ui_max = 1.0;
> = 0.5;

uniform float G_INTENSITY <
	ui_label = "G Channel Intensity\n\n";
	ui_tooltip = "Intensity of the emmision from the G channel";
	ui_category = "Wave Emission Settings";
	ui_type = "slider";
	ui_min = 0;
	ui_max = 2.0;
> = 1.0;

uniform float B_WAVELENGTH <
	ui_label = "B Channel Wavelength";
	ui_tooltip = "Peak wavelength emmited by the B channel";
	ui_category = "Wave Emission Settings";
> = 465.0;

uniform float B_WIDTH <
	ui_type = "slider";
	ui_label = "B Channel Width";
	ui_tooltip = "How wide of a frequency band is emitted by the B channel";
	ui_category = "Wave Emission Settings";
	ui_min = 0.0;
	ui_max = 1.0;
> = 0.5;

uniform float B_INTENSITY <
	ui_label = "B Channel Intensity\n\n";
	ui_tooltip = "Intensity of the emmision from the B channel";
	ui_category = "Wave Emission Settings";	
	ui_type = "slider";
	ui_min = 0;
	ui_max = 2.0;
> = 1.0;

//Additional color for hyperspectral simulation

uniform int Q_RESPONSE_SETTINGS <
	ui_type = "radio";
	ui_text = "\nQ Emission Settings:";
	ui_tooltip = "Wave Emission Settings for the Q channel";
	ui_label = " ";
	ui_category = "Wave Emission Settings";
> = 0;

uniform float3 Q_COLOR <
	ui_label = "Q Color";
	ui_type = "color";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_tooltip = "Target color to emit a frequency of Q";
	ui_category = "Wave Emission Settings";
> = float3(0.1, 0.36, 0.15);

uniform float Q_ACCEPTANCE <
	ui_type = "slider";
	ui_label = "Q Sensitivity";
	ui_tooltip = "How close a color has to be to Q to begin emitting";
	ui_category = "Wave Emission Settings";
	ui_min = 0.0;
	ui_max = 1.0;
> = 0.5;

uniform float Q_WAVELENGTH <
	ui_label = "Q Color Wavelength";
	ui_tooltip = "Peak wavelength emmited by the Q color";
	ui_category = "Wave Emission Settings";
> = 700.0;

uniform float Q_WIDTH <
	ui_type = "slider";
	ui_label = "Q Channel Width";
	ui_tooltip = "How wide of a frequency band is emitted by the Q channel";
	ui_category = "Wave Emission Settings";
	ui_min = 0.0;
	ui_max = 1.0;
> = 0.0;

uniform float Q_INTENSITY <
	ui_label = "Q Channel Intensity\n\n";
	ui_tooltip = "Intensity of the emmision from the Q channel";
	ui_category = "Wave Emission Settings";	
	ui_type = "slider";
	ui_min = 0;
	ui_max = 5.0;
> = 0.0;

uniform int WAVE_DEBUG <
	ui_type = "combo";
	ui_label = "Channel Debug";
	ui_tooltip = "Displays the emission of individual channels for fine tuning";
	ui_category = "Wave Emission Settings";
	ui_items = "None\0Debug R\0Debug G\0Debug B\0Debug Q\0";
> = 0;

uniform bool WAVE_SUBTRACT <
	ui_label = "Color Subtraction";
	ui_category = "Wave Emission Settings";
	ui_tooltip = "Causes colors to destructively interfere. Unrealistic, but can often make colors more pleasing";
> = 0;
//============================================================================================
//Film Response Settings
//============================================================================================

uniform int FILM_RESPONSE_SETTINGS <
	ui_type = "radio";
	ui_text = "\nFilm Response Settings:";
	ui_label = " ";
	ui_category = "Wave Emission Settings";
> = 1;

uniform int FILM_RESPONSE <
	ui_type = "combo";
	ui_label = "Response Type";
	ui_category = "Wave Emission Settings";
	ui_tooltip = "Currently just curves modeled after common film responses with some tweaking,\n"
				"'None' is no filtering and may require additional brightness adjustmens";
	ui_items = "Color\0None\0Infrared\0B&W - Average\0B&W - Luminance\0B&W - Length\0";
> = 0;

uniform int FILM_CURVE <
	ui_type = "combo";
	ui_label = "Output Curve";
	ui_category = "Wave Emission Settings";
	ui_tooltip = "Exposure curve output, not necessarily accurate to film, but may be useful\n";
	ui_items = "Tonemapped\0Linear\0S-Log3\0Reinhardt\0";
> = 3;

//============================================================================================
//Dye Color Settings
//============================================================================================

uniform int DYE_COLOR_SETTINGS <
	ui_type = "radio";
	ui_text = "\nPigment Color Settings:\n"
			  "Allows you to change the color of the dyes used in printing, this can do subtle things like raising blacks, "
			  "as well as much more drastic changes\n\n";
	ui_label = " ";
	ui_category = "Film Pigment Guide";
	hidden = HIDE_GUIDES;
> = 0;

uniform float3 C_COL <
	ui_type = "color";
	ui_label = "Cyan";
	ui_category = "Film Pigments";
	ui_min = 0.0;
	ui_max = 1.0;
> = float3(0.0, 1.0, 1.0);

uniform float3 M_COL <
	ui_type = "color";
	ui_label = "Magenta";
	ui_category = "Film Pigments";
	ui_min = 0.0;
	ui_max = 1.0;
> = float3(0.98, 0.0, 0.87);

uniform float3 Y_COL <
	ui_type = "color";
	ui_label = "Yellow";
	ui_category = "Film Pigments";
	ui_min = 0.0;
	ui_max = 1.0;
> = float3(1.0, 1.0, 0.0);

uniform float3 K_COL <
	ui_type = "color";
	ui_label = "Black";
	ui_category = "Film Pigments";
	ui_min = 0.0;
	ui_max = 1.0;
> = float3(0.020, 0.022, 0.022);

//============================================================================================
//Wave Response Table
//============================================================================================

uniform int WAVE_RESPONSE_TABLE <
	ui_type = "radio";
	ui_text = "\nExample Emission Settings:\n\n"
			"Infrared: R(440, 0.25) G(650, 0.0) B(530, 0.4)";
	hidden = true;		
	ui_label = " ";
	ui_category = "Wave Emission Cheat Sheet";
> = 0;

