// OVERRIDE_COLOR_SPACE=0
// HDR_WHITELEVEL=203
// FAST_AO_POINTS=6
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Glamayre_Fast_Effects.fx"
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
#line 453 "C:\Program Files\GShade\gshade-shaders\Shaders\Glamayre_Fast_Effects.fx"
#line 454
namespace Glamarye_Fast_Effects
{
#line 521
uniform int show_color_space
<
ui_category = "Color Space";
ui_type = "combo";
ui_label = "color space";
ui_tooltip = "When HDR (high-dynamic range) arrived it added several new ways of encoding brightness. \n\nReShade or Glamayre has detected which the game is using. To override that set the OVERRIDE_COLOR_SPACE pre-processor definition. \n\n1 = sRGB (standard dynamic range), 2 = scRGB (linear), 3 = Perceptual Quantizer (SMPTE ST 2084), 4 = hybrid log–gamma (ARIB STD-B67).\0";
#line 529
ui_items = "1 sRGB (autodetected)\0";
#line 539
> = 0;
#line 560
uniform bool fxaa_enabled <
ui_category = "Enabled Effects";
ui_label = "Fast FXAA";
ui_tooltip = "Fullscreen approximate anti-aliasing. Fixes jagged edges. \n\nRecommendation: use with sharpen too, otherwise it can blur details slightly.";
ui_type = "radio";
> = true;
#line 567
uniform bool sharp_enabled <
ui_category = "Enabled Effects";
ui_label = "Intelligent Sharpen";
ui_tooltip = "Sharpens image, but working with FXAA and depth of field instead of fighting them. It darkens pixels more than it brightens them; this looks more realistic.";
ui_type = "radio";
> = true;
#line 575
uniform bool ao_enabled <
ui_category = "Enabled Effects";
ui_label = "Fast Ambient Occlusion (AO) (requires depth buffer)";
ui_tooltip = "Ambient occlusion shades places that are surrounded by points closer to the camera. It's an approximation of the reduced ambient light reaching occluded areas and concave shapes (e.g. under grass and in corners.)\n\nFor quality adjustment, set pre-processor definition FAST_AO_POINTS. Higher is better quality but slower. Valid range: 2-16. Recommended: 4, 6 or 8 as these have optimized fast code paths.";
ui_type = "radio";
> = true;
#line 583
uniform bool dof_enabled <
ui_category = "Enabled Effects";
ui_label = "Subtle Depth of field (DOF) (requires depth buffer)";
ui_tooltip = "Softens distant objects subtly, as if slightly out of focus.";
ui_type = "radio";
> = true;
#line 590
uniform bool depth_detect <
ui_category = "Enabled Effects";
ui_label = "Detect menus & videos (requires depth buffer)";
ui_tooltip = "Skip all processing if depth value is 0 (per pixel). Sometimes menus use depth 1 - in that case use Detect Sky option instead. Full-screen videos and 2D menus do not need anti-aliasing nor sharpening, and may look worse with them.\n\nOnly enable if depth buffer always available in gameplay!";
ui_type = "radio";
> = false;
#line 597
uniform bool sky_detect <
ui_category = "Enabled Effects";
ui_label = "Detect sky (requires depth buffer)";
ui_tooltip = "Skip all processing if depth value is 1 (per pixel). Background sky images might not need anti-aliasing nor sharpening, and may look worse with them.\n\nOnly enable if depth buffer always available in gameplay!";
ui_type = "radio";
> = false;
#line 607
uniform float sharp_strength <
ui_category = "Effects Intensity";
ui_min = 0; ui_max = 2; ui_step = .05;
ui_tooltip = "For high values I suggest depth of field too. Values > 1 only recommended if you can't see individual pixels (i.e. high resolutions on small or far away screens.)";
ui_label = "Sharpen strength";
ui_type = "slider";
> = 0.75;
#line 615
uniform float ao_strength <
ui_category = "Effects Intensity";
ui_min = 0.0; ui_max = 1.0; ui_step = .05;
ui_tooltip = "Ambient Occlusion. Higher mean deeper shade in concave areas.\n\nTip: if increasing AO strength don't set AO Quality to Performance, or you might notice some imperfections.";
ui_label = "AO strength";
ui_type = "slider";
> = 0.6;
#line 624
uniform float ao_shine_strength <
ui_category = "Effects Intensity";
ui_min = 0.0; ui_max = 1; ui_step = .05;
ui_label = "AO shine";
ui_tooltip = "Normally AO just adds shade; with this it also brightens convex shapes. \n\nMaybe not realistic, but it prevents the image overall becoming too dark, makes it more vivid, and makes some corners clearer.";
ui_type = "slider";
> = 0.3;
#line 632
uniform float dof_strength <
ui_category = "Effects Intensity";
ui_min = 0; ui_max = 1; ui_step = .05;
ui_tooltip = "Depth of field. Applies subtle smoothing to distant objects. It's a small effect (1 pixel radius).\n\nAt the default it more-or-less cancels out sharpening, no more.";
ui_label = "DOF blur";
ui_type = "slider";
> = 0.3;
#line 642
uniform float gi_strength <
ui_category = "Fake Global Illumination (with_Fake_GI version only)";
ui_min = 0.0; ui_max = 1.0; ui_step = .05;
ui_label = "Fake GI lighting strength";
ui_tooltip = "Fake Global Illumination wide-area effect. Every pixel gets some light added from the surrounding area of the image.\n\nUsually safe to increase, except in games with unusually bright colors.";
ui_type = "slider";
> = 0.5;
#line 650
uniform float gi_saturation <
ui_category = "Fake Global Illumination (with_Fake_GI version only)";
ui_min = 0.0; ui_max = 1.0; ui_step = .05;
ui_label = "Fake GI saturation";
ui_tooltip = "Fake Global Illumination saturation boost. \n\nThis increases color change, especially in areas of similar brightness. \n\nDecrease this if colors are too saturated or all too similar. Increase for more noticeable indirect light color bounce.";
ui_type = "slider";
> = 0.5;
#line 658
uniform float gi_contrast <
ui_category = "Fake Global Illumination (with_Fake_GI version only)";
ui_min = 0; ui_max = 1.5; ui_step = 0.01;
ui_tooltip = "Increases contrast relative to average light in surrounding area. This makes differences between nearby areas clearer. \n\nHowever, too much contrast looks less realistic and may make near black or near white areas less clear.";
ui_label = "Adaptive contrast enhancement";
ui_type = "slider";
> = 0.25;
#line 666
uniform bool gi_use_depth <
ui_category = "Fake Global Illumination (with_Fake_GI version only)";
ui_label = "Enable Fake GI effects that require depth (below)";
ui_tooltip = "If you don't have depth buffer data, or if you don't want the full effect then 2D mode may be faster. \n\nWith depth enabled, it adds big AO, improved local AO with local bounce light, and better direction for lighting.";
> = true;
#line 672
uniform float gi_ao_strength <
ui_category = "Fake Global Illumination (with_Fake_GI version only)";
ui_min = 0; ui_max = 1; ui_step = .05;
ui_tooltip = "Large scale ambient occlusion. Higher = darker shadows. \n\nA big area effect providing subtle shading of enclosed spaces, which would receive less ambient light. \n\nIt is a fast but very approximate. It is subtle and smooth so it's imperfections are not obvious nor annoying. \n\nUse in combination with normal ambient occlusion, not instead of it.";
ui_label = "Fake GI big AO strength (requires depth)";
ui_type = "slider";
> = .5;
#line 680
uniform float gi_local_ao_strength <
ui_category = "Fake Global Illumination (with_Fake_GI version only)";
ui_min = 0; ui_max = 1; ui_step = .05;
ui_tooltip = "Fake GI provides additional ambient occlusion, subtly enhancing Fast Ambient Occlusion and bounce lighting, at very little cost. \n\nThis Higher = darker shadows. \n\nThis would have visible artifacts at high strength; therefore maximum shade added is very small. Use in combination with normal ambient occlusion, not instead of it.";
ui_label = "Fake GI local AO strength (requires depth)";
ui_type = "slider";
> = .75;
#line 688
uniform float bounce_multiplier <
ui_category = "Fake Global Illumination (with_Fake_GI version only)";
ui_min = 0.0; ui_max = 2.0; ui_step = .05;
ui_label = "Fake GI local bounce strength (requires depth)";
ui_tooltip = "It uses local depth and color information to approximate short-range bounced light. \n\nIt only affects areas made darker by ambient occlusion. A bright red pillar next to a white wall will make the wall a bit red, but how red?";
ui_type = "slider";
> = 1;
#line 697
uniform float gi_shape <
ui_category = "Fake Global Illumination (with_Fake_GI version only)";
ui_min = 0; ui_max = .2; ui_step = .01;
ui_tooltip = "Fake global illumination uses a very blurred version of the image to collect approximate light from a wide area around each pixel. \n\nIf depth is available, it adjusts the offset based on the angle of the local surface. This makes it better pick up color from facing surfaces, but if set too big it may miss nearby surfaces in favor of further ones. \n\nThe value is the maximum offset, as a fraction of screen size.";
ui_label = "Fake GI offset";
ui_type = "slider";
> = .05;
#line 705
uniform bool gi_dof_safe_mode <
ui_category = "Fake Global Illumination (with_Fake_GI version only)";
ui_label = "Cinematic DOF safe mode";
ui_tooltip = "The depth of field effect (out of focus background) is now common in games and sometimes cannot be disabled. It interacts badly with AO and GI effects using depth. Enabling this tweaks effects to use a blurred area depth instead of the depth at every pixel, which makes Fake GI depth effects usable in such games.";
> = false;
#line 714
uniform int debug_mode <
ui_category = "Advanced Tuning and Configuration";
ui_type = "combo";
ui_label = "Debug mode";
ui_items = "Normal output\0"
"Debug: show FXAA edges\0"
"Debug: show AO shade & bounce\0"
"Debug: show depth buffer\0"
"Debug: show depth and edges\0"
"Debug: show Fake GI area light\0"
;
ui_tooltip = "Handy when tuning ambient occlusion settings.";
> = 0;
#line 730
uniform bool ao_big_dither <
ui_category = "Advanced Tuning and Configuration";
ui_tooltip = "Ambient occlusion dither.\n\nDithering means adjacent pixels shade is calculated using different nearby depth samples. If you look closely you may see patterns of alternating light/dark pixels.\n\nIf checked, AO uses an 8 pixel dither pattern; otherwise it uses a 2 pixel pattern.\n\nFrom a distance, bigger dither gives better shadow shapes overall; However, you will see annoying repeating patterns up close.\n\nRecommendation: turn on if you have a high enough screen resolution and far enough distance from your screen that you cannot make out individual pixels by eye.\n\nThe performance is about the same either way.";
ui_label = "AO bigger dither";
> = false;
#line 737
uniform float reduce_ao_in_light_areas <
ui_category = "Advanced Tuning and Configuration";
ui_label = "Reduce AO in bright areas";
ui_min = 0.0; ui_max = 4; ui_step = 0.1;
ui_tooltip = "Do not shade very light areas. Helps prevent unwanted shadows in bright transparent effects like smoke and fire, but also reduces them in solid white objects. Increase if you see shadows in white smoke, decrease for more shade on light objects. Doesn't help with dark smoke.";
ui_type = "slider";
> = 1;
#line 745
uniform float ao_fog_fix <
ui_category = "Advanced Tuning and Configuration";
ui_category_closed=true;
ui_min = 0.0; ui_max = 2; ui_step = .05;
ui_label = "AO max distance";
ui_tooltip = "The ambient occlusion effect fades until it is zero at this distance. Helps to avoid artifacts if the game uses fog or haze. If you see deep shadows in the clouds then reduce this. If the game has long, clear views then increase it.";
ui_type = "slider";
> = .5;
#line 754
uniform float gi_max_distance <
ui_type = "slider";
ui_category = "Advanced Tuning and Configuration";
ui_category_closed=true;
ui_min = 0.0; ui_max = 1; ui_step = .05;
ui_label = "Fake GI max distance";
ui_tooltip = "Fake GI effect will fade out at this distance. \n\nThe default 1 should be fine for most games. \n\nNote: the large scale AO that is part of Fake GI is controlled by the AO max distance control.";
> = 1;
#line 763
uniform float ao_radius <
ui_type = "slider";
ui_category = "Advanced Tuning and Configuration";
ui_min = 0.0; ui_max = 2; ui_step = 0.01;
ui_tooltip = "Ambient Occlusion area size, as percent of screen. Bigger means larger areas of shade, but too big and you lose detail in the shade around small objects. Bigger can be slower too.";
ui_label = "AO radius";
ui_type = "slider";
> = 1;
#line 773
uniform float ao_shape_modifier <
ui_category = "Advanced Tuning and Configuration";
ui_min = 1; ui_max = 4000; ui_step = 1;
ui_tooltip = "Ambient occlusion - weight against shading flat areas. Increase if you get deep shade in almost flat areas. Decrease if you get no-shade in concave areas areas that are shallow, but deep enough that they should be occluded.";
ui_label = "AO shape modifier";
ui_type = "slider";
> = 1000;
#line 781
uniform float ao_max_depth_diff <
ui_category = "Advanced Tuning and Configuration";
ui_min = 0; ui_max = 2; ui_step = 0.001;
ui_tooltip = "Ambient occlusion biggest depth difference to allow, as percent of depth. Prevents nearby objects casting shade on distant objects. Decrease if you get dark halos around objects. Increase if holes that should be shaded are not.";
ui_label = "AO max depth diff";
ui_type = "slider";
> = 0.5;
#line 789
uniform float fxaa_bias <
ui_category = "Advanced Tuning and Configuration";
ui_min = 0; ui_max = 0.1; ui_step = 0.001;
ui_tooltip = "Don't anti-alias edges with very small differences than this - this is to make sure subtle details can be sharpened and do not disappear. Decrease for smoother edges but at the cost of detail, increase to only sharpen high-contrast edges.";
ui_label = "FXAA bias";
ui_type = "slider";
> = 0.020;
#line 798
uniform float tone_map <
ui_category = "Advanced Tuning and Configuration";
ui_min = 1; ui_max = 9; ui_step = .1;
ui_tooltip = "Note: this is ignored in HDR modes.\n\nIn the real world we can see a much wider range of brightness than a standard screen can produce. \n\nGames use tone mapping to reduce the dynamic range, especially in bright areas, to fit into display limits. \n\nTo calculate lighting effects like Fake GI accurately on SDR images, we want to undo tone mapping first, then reapply it afterwards. \n\nOptimal value depends on tone mapping method the game uses. You won't find that info published anywhere for most games. \n\nOur compensation is based on Reinhard tonemapping, but hopefully will be close enough if the game uses another curve like ACES. At 5 it's pretty close to ACES in bright areas but never steeper. \n\nApplies for Fake GI in SDR mode only.";
ui_label = "Tone mapping compensation";
ui_type = "slider";
> = 3;
#line 806
uniform float max_sharp_diff <
ui_type = "slider";
ui_category = "Advanced Tuning and Configuration";
ui_min = 0.05; ui_max = .25; ui_step = 0.01;
ui_label = "Sharpen maximum change";
ui_tooltip = "Maximum amount a pixel can be changed by the sharpen effect. Prevents oversharpening already sharp edges.";
> = 0.1;
#line 814
uniform bool edge_detect_sharpen <
ui_category = "Advanced Tuning and Configuration";
ui_label = "Sharpen jagged edges less";
ui_tooltip = "If enabled, the sharpen effect is reduced on jagged edges. It uses Fast FXAA's edge detection. \n\nIf this is disabled the image will be a bit sharper and, if Fast FXAA is also disabled, faster too. However, without this option sharpening can partially reintroduce jaggies that had been smoothed by Fast FXAA or the game's own anti-aliasing.";
ui_type = "radio";
> = true;
#line 821
uniform bool big_sharpen <
ui_category = "Advanced Tuning and Configuration";
ui_label = "Bigger sharpen & DOF";
ui_tooltip = "Uses a bigger area, making both effects bigger. Affects FXAA too. \n\nThis is useful for high resolutions, with older games with low resolution textures, or viewing far from the screen. However, very fine details will be less accurate. \n\nIt increases overall sharpness too. Tip: use about half sharpen strength to get similar overall sharpness but with the bigger area.";
ui_type = "radio";
> = false;
#line 828
uniform bool abtest <
ui_category = "Advanced Tuning and Configuration";
ui_label = "A/B test";
ui_tooltip = "Ignore this. Used by developer when testing and comparing algorithm changes.";
ui_type = "radio";
> = false;
#line 838
float3 undoTonemap(float3 c) {
if(1 < 2)
{
c=saturate(c);
c = c/(1.0-(1.0-rcp(tone_map))*c);
}
#line 845
return c;
}
#line 848
float3 reapplyTonemap(float3 c) {
#line 850
if(1 < 2)
{
c = c/((1-rcp(tone_map))*c+1.0);
}
#line 855
return c;
}
#line 862
float3 sRGBtoLinearAccurate(float3 r) {
return (r<=.04045) ? (r/12.92) : pow(abs(r+.055)/1.055, 2.4);
}
#line 866
float3 sRGBtoLinearFastApproximation(float3 r) {
#line 868
return max(r/12.92, r*r);
}
#line 871
float3 sRGBtoLinear(float3 r) {
if(2==1) r = sRGBtoLinearFastApproximation(r);
else if(2==0) r = sRGBtoLinearAccurate(r);
return r;
}
#line 877
float3 linearToSRGBAccurate(float3 r) {
return (r<=.0031308) ? (r*12.92) : (1.055*pow(abs(r), 1.0/2.4) - .055);
}
#line 881
float3 linearToSRGBFastApproximation(float3 r) {
#line 883
return min(r*12.92, sqrt(r));
}
#line 887
float3 linearToSRGB(float3 r) {
if(2==1) r = linearToSRGBFastApproximation(r);
else if(2==0) r = linearToSRGBAccurate(r);
#line 891
return r;
}
#line 895
float3 PQtoLinearAccurate(float3 r) {
#line 897
const float m1 = 1305.0/8192.0;
const float m2 = 2523.0/32.0;
const float c1 = 107.0/128.0;
const float c2 = 2413.0/128.0;
const float c3 = 2392.0/128.0;
#line 903
float3 powr = pow(max(r,0),1.0/m2);
r = pow(max( max(powr-c1, 0) / ( c2 - c3*powr ), 0) , 1.0/m1);
#line 906
return r * 10000.0/203;	
}
#line 909
float3 PQtoLinearFastApproximation(float3 r) {
#line 912
float3 square = r*r;
float3 quad = square*square;
float3 oct = quad*quad;
r= max(max(square/340.0, quad/6.0), oct);
#line 917
return r * 10000.0/203;	
}
#line 920
float3 PQtoLinear(float3 r) {
if(2) r = PQtoLinearFastApproximation(r);
else r = PQtoLinearAccurate(r);
return r;
}
#line 926
float3 linearToPQAccurate(float3 r) {
#line 928
const float m1 = 1305.0/8192.0;
const float m2 = 2523.0/32.0;
const float c1 = 107.0/128.0;
const float c2 = 2413.0/128.0;
const float c3 = 2392.0/128.0;
#line 935
r = r*(203/10000.0);
#line 938
float3 powr = pow(max(r,0),m1);
r = pow(max( ( c1 + c2*powr ) / ( 1 + c3*powr ), 0 ), m2);
return r;
}
#line 943
float3 linearToPQFastApproximation(float3 r) {
#line 948
r = r*(203/10000.0);
#line 950
float3 squareroot = sqrt(r);
float3 quadroot = sqrt(squareroot);
float3 octroot = sqrt(quadroot);
r = min(octroot, min(sqrt(sqrt(6.0))*quadroot, sqrt(340.0)*squareroot ) );
return r;
}
#line 957
float3 linearToPQ(float3 r) {
if(2) r = linearToPQFastApproximation(r);
else r = linearToPQAccurate(r);
return r;
}
#line 966
float3 linearToHLG(float3 r) {
r = r*203/1000;
float a = 0.17883277;
float b = 0.28466892; 
float c = 0.55991073; 
float3 s=sqrt(3*r);
return (s<.5) ? s : ( log(12*r - b)*a+c);
}
#line 975
float3 HLGtoLinear(float3 r) {
float a = 0.17883277;
float b = 0.28466892; 
float c = 0.55991073; 
r = (r<.5) ? r*r/3.0 : ( ( exp( (r - c)/a) + b) /12.0);
return r * 1000/203;
#line 982
}
#line 985
float3 toLinearColorspace(float3 r) {
if(1 == 2) r = r*(80.0/203);
else if(1 == 3) r = PQtoLinear(r);
else if(1 == 4) r = HLGtoLinear(r);
else r= sRGBtoLinear(r);
#line 991
return r;
}
#line 994
float3 toOutputColorspace(float3 r) {
if(1 == 2) r=r*(203/80.0); 
else if(1 == 3) r = linearToPQ(r);
else if(1 == 4) r = linearToHLG(r);
else r= linearToSRGB(r);
#line 1000
return r;
}
#line 1003
float getMaxColour()
{
float m = 1;
if(1>=2) m = 10000.0/203;
if(1==4) m = 1000.0/203;
return m;
}
#line 1016
sampler2D samplerColor
{
#line 1019
Texture = ReShade::BackBufferTex;
#line 1023
SRGBTexture = true;
#line 1025
};
#line 1028
float4 getBackBufferLinear(float2 texcoord) {
#line 1030
float4 c = tex2D( samplerColor, texcoord);
c.rgb = toLinearColorspace(c.rgb);
return c;
}
#line 1035
sampler2D samplerDepth
{
#line 1038
Texture = ReShade::DepthBufferTex;
#line 1042
AddressU = CLAMP;
AddressV = CLAMP;
AddressW = CLAMP;
#line 1048
MagFilter = POINT;
MinFilter = POINT;
MipFilter = POINT;
};
#line 1055
float pointDepth(float2 texcoord)
{
#line 1060
texcoord.x /= 1;
texcoord.y /= 1;
#line 1064
 
texcoord.x -= 0 / 2.000000001;
#line 1070
texcoord.y += 0 / 2.000000001;
#line 1072
float depth = (float)tex2D(samplerDepth, texcoord);
return depth;
}
#line 1076
float4 fixDepth4(float4 depth) {
depth *= 1;
#line 1086
const float N = 1.0;
depth /= 1000.0 - depth * (1000.0 - N);
#line 1089
return depth;
}
#line 1093
float3 fixDepth3(float3 depth) {
depth *= 1;
#line 1103
const float N = 1.0;
depth /= 1000.0 - depth * (1000.0 - N);
#line 1106
return depth;
}
#line 1110
static const uint FAKE_GI_WIDTH=192;
static const uint FAKE_GI_HEIGHT=108;
#line 1113
texture GITexture {
Width = FAKE_GI_WIDTH*2;
Height = FAKE_GI_HEIGHT*2 ;
Format = RGBA16F;
MipLevels=4;
};
#line 1120
sampler GITextureSampler {
Texture = GITexture;
AddressU = BORDER;
AddressV = BORDER;
AddressW = BORDER;
};
#line 1131
texture HBlurTex {
Width = FAKE_GI_WIDTH ;
Height = FAKE_GI_HEIGHT ;
Format = RGBA16F;
};
#line 1137
texture VBlurTex {
Width = FAKE_GI_WIDTH ;
Height = FAKE_GI_HEIGHT ;
Format = RGBA16F;
#line 1142
};
#line 1144
sampler HBlurSampler {
Texture = HBlurTex;
};
#line 1148
sampler VBlurSampler {
Texture = VBlurTex;
};
#line 1153
float4 startGI_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : COLOR
{
float4 c=.5;
#line 1157
c.rgb = getBackBufferLinear(texcoord).rgb;
#line 1159
if( 1 == 2 ) {
#line 1162
c=c/(1+0.05*c);
}
#line 1165
c.rgb=undoTonemap(c.rgb);
#line 1168
if(gi_use_depth) {
float depth = ReShade::GetLinearizedDepth(texcoord);
c.rgb = lerp(c.rgb, length(c.rgb)*rsqrt(2), depth*depth);
c.w=depth;
}
return c;
}
#line 1177
float4 bigBlur(sampler s, in float4 pos, in float2 texcoord, in float4 steps  ) {
#line 1179
float2 pixelsize = 1/float2(FAKE_GI_WIDTH,FAKE_GI_HEIGHT);
float4 c1 = tex2D(s, texcoord - pixelsize*steps.xy);
float4 c2 = tex2D(s, texcoord - pixelsize*steps.zw);
float4 c3 = tex2D(s, texcoord + pixelsize*steps.zw);
float4 c4 = tex2D(s, texcoord + pixelsize*steps.xy);
#line 1186
if(c1.w==0) c1.w = c3.w;
if(c2.w==0) c2.w = c3.w;
if(c3.w==0) c3.w = c2.w;
if(c4.w==0) c4.w = c2.w;
#line 1192
float4 c =.25*(c1+c2+c3+c4);
#line 1194
if(gi_use_depth) {
c1=lerp(c1, c, clamp(abs(5*( c1.w/min(c2.w,.5*(c2.w+c3.w)) -1 ) ), 0,1));
c4=lerp(c4, c, clamp(abs(5*( c4.w/min(c3.w,.5*(c2.w+c3.w)) -1 ) ), 0,1));
c2=lerp(c2, c, clamp(abs(3*(c2.w/c.w-1) ), 0,1));
c3=lerp(c3, c, clamp(abs(3*(c3.w/c.w-1) ), 0,1));
#line 1200
c = .25*(c1+c2+c3+c4);
}
#line 1204
return c;
}
#line 1208
float4 bigBlur1_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float4 result = bigBlur(GITextureSampler, pos, texcoord, float4(10.5,1.5,3.5,0.5) );
#line 1212
return result;
}
#line 1215
float4 bigBlur2_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float4 result = bigBlur(HBlurSampler, pos, texcoord, float4(-1.5,10.5, -0.5,3.5) );
#line 1219
return result;
}
#line 1222
float4 bigBlur3_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float4 result = bigBlur(VBlurSampler, pos, texcoord, float4(7.5,7.5,2.5,2.5) );
return result;
}
#line 1228
float4 bigBlur4_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float4 result = bigBlur(HBlurSampler, pos, texcoord, float4(-7.5,7.5,-2.5,2.5) );
return result;
}
#line 1238
float3 Glamarye_Fast_Effects_PS(float4 vpos , float2 texcoord : TexCoord, bool gi_path)
{
#line 1241
float3 c = getBackBufferLinear(texcoord).rgb;
#line 1244
float depth=0 ;
#line 1246
if( (!gi_dof_safe_mode && (ao_enabled || gi_use_depth )) || dof_enabled || debug_mode || depth_detect || sky_detect) {
#line 1248
depth = ReShade::GetLinearizedDepth(texcoord);
}
#line 1252
static const float3 luma = float3(0.2126, 0.7152, 0.0722);
#line 1256
if(!(depth_detect && depth==0) && !(sky_detect && depth == 1) ) {
#line 1258
float ratio=0;
#line 1260
float3 smoothed=c;
float3 sharp_diff = 0;
if(fxaa_enabled || sharp_enabled || dof_enabled) {
#line 1265
float offset = big_sharpen ? 1.4 : .5;
float3 ne = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*float2(offset,offset)).rgb;
float3 sw = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*float2(-offset,-offset)).rgb;
float3 se = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*float2(offset,-offset)).rgb;
float3 nw = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*float2(-offset,offset)).rgb;
#line 1272
smoothed = (ne+nw)+(se+sw);
if(big_sharpen) smoothed = clamp( (smoothed+c)/5, c/2.0, c*2.0);
else smoothed = clamp( (smoothed-c)/3, c/2.0, c*2.0);
smoothed = min(smoothed,getMaxColour());
#line 1278
float dy = dot(luma,abs((ne+nw)-(se+sw)));
float dx = dot(luma,abs((ne+se)-(nw+sw)));
bool horiz =  dy > dx;
#line 1284
float3 n2=horiz ? ne+nw : ne+se;
float3 s2=horiz ? se+sw : nw+sw;
if(big_sharpen) {
n2*=.5;
s2*=.5;
}
else
{
n2-=c;
s2-=c;
}
#line 1297
if(fxaa_enabled || (sharp_enabled && edge_detect_sharpen) ) {
#line 1299
const float dist = 3.5;
float2 wwpos = horiz ? float2(-dist, 0) : float2(0, +dist) ;
float2 eepos = horiz ? float2(+dist, 0) : float2(0, -dist) ;
#line 1303
float3 ww = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*wwpos).rgb;
float3 ee = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*eepos).rgb;
#line 1312
float3 d1 = abs((ww-n2)-(ee-s2));
float3 d2 = abs((ee-n2)-(ww-s2));
#line 1319
float3 total_diff = (d1+d2) + .00004;
float3 max_diff = max(d1,d2) + .00001 - fxaa_bias*sqrt(smoothed);
#line 1323
float score = dot(luma,(max_diff/total_diff)) ;
#line 1327
ratio = max( 2*score-1, 0);
}
#line 1330
if(sharp_enabled && sharp_strength) {
#line 1333
sharp_diff = 2*c+(ne+nw+se+sw) - 3*(max(max(ne,nw),max(se,sw)) + min(min(ne,nw),min(se,sw)));
#line 1336
sharp_diff = dot(luma,sharp_diff);
#line 1342
float3 max_sharp=min(smoothed,.5*c);
#line 1345
max_sharp = min(max_sharp,getMaxColour()-max(smoothed,c));
#line 1349
max_sharp = clamp(max_sharp, 0.00001, max_sharp_diff );
#line 1352
sharp_diff = sharp_diff / ( rcp(sharp_strength) +abs(sharp_diff)/(max_sharp));
#line 1355
if(edge_detect_sharpen) sharp_diff *= (1-ratio);
}
#line 1359
if(fxaa_enabled) c = lerp(c, smoothed, ratio);
#line 1362
c+=sharp_diff;
#line 1365
if(dof_enabled) {
c=lerp(c, clamp(smoothed,c*.5,c*2), dof_strength*depth);
sharp_diff *= dof_strength*depth;
}
}
#line 1371
float ao = 0;
#line 1373
const float shape = ao_shape_modifier*1.1920928955078125e-07F;
#line 1376
float3 bounce=0;
#line 1378
float smoke_fix;
#line 1380
if(gi_path || ao_enabled) {
#line 1382
smoke_fix=max(0,(1-reduce_ao_in_light_areas*length(min(c,smoothed))));
#line 1385
c=undoTonemap(c);
}
#line 1388
float4 gi=0;
float4 bounce_area = 0;
if(gi_path) {
#line 1392
bounce_area = tex2Dlod(GITextureSampler, float4(texcoord.x,texcoord.y, 0, 2.5));
#line 1394
float2 gi_adjust_vector=0;
#line 1396
if(gi_use_depth) {
if(gi_dof_safe_mode) {
depth = tex2Dlod(GITextureSampler, float4(texcoord.x,texcoord.y, 0, 1.5)).w;
} else  {
#line 1401
float4 local_slope = float4(ddx(depth), ddy(depth), 0.1*float2((1.0 / 1920), (1.0 / 1018)));
#line 1403
gi_adjust_vector = normalize(local_slope).xy*gi_shape;
}
#line 1406
float abs_diff = abs(depth-bounce_area.w);
if( abs_diff>shape*2) ao += gi_local_ao_strength*.1*sign(depth-bounce_area.w);
if(gi_dof_safe_mode) depth=bounce_area.w;
}
gi = tex2D(VBlurSampler, texcoord+gi_adjust_vector);
#line 1412
if(gi_use_depth) { 
#line 1415
float gi_bright = max(gi.r,max(gi.g,gi.b)) + min(gi.r,min(gi.g,gi.b));
#line 1418
float light = gi_bright+.005;
#line 1421
float3 unlit_c2 = c/light;
#line 1424
bounce=lerp(bounce, unlit_c2*max(0,2*bounce_area.rgb-c), bounce_multiplier);
}
#line 1427
float contrast = dot(luma,max(0,c-sharp_diff)/max(bounce_area.rgb+gi.rgb,0.00001));
contrast = (contrast)/(1+contrast)+.66666666667;
#line 1431
contrast = lerp(1, contrast, gi_contrast);
#line 1437
float3 avg_light = length((2*gi_strength)*c+gi.rgb)/(1+2*gi_strength);
#line 1439
float3 ambient =  min(avg_light, lerp(1, 1+length(gi.rgb/(c+gi.rgb)),gi_saturation*gi_strength)*gi.rgb );
#line 1441
float3 gi_bounce = (1+.5*gi_saturation*gi_strength)*c*gi.rgb/ambient;
#line 1444
float gi_ratio = min(1, (gi.w+0.00001)/(depth+0.00001));
#line 1447
if(gi_use_depth || sky_detect) gi_ratio *= max(0, 1-depth*depth*depth*rcp(gi_max_distance*gi_max_distance*gi_max_distance));
#line 1449
c = lerp(c, gi_bounce , .6*gi_ratio);
c = c*contrast;
}
#line 1456
if( ao_enabled && !gi_dof_safe_mode && depth>0 && depth<ao_fog_fix ) {
#line 1459
uint square =  (uint(vpos.x+vpos.y)) % 2;
uint circle=0;
if(ao_big_dither) {
circle = (uint(vpos.y/2))%2;
}
#line 1465
uint points = clamp(6,2, 16);
#line 1467
float2 ao_lengths[2];
#line 1469
ao_lengths[0] = float2(.01,.004);
if(!ao_big_dither) ao_lengths[0].x = (min(.002*points,.01));
ao_lengths[1] = float2(.0055,.0085);
#line 1476
float ao_choice = (square ? ao_lengths[circle].x : ao_lengths[circle].y );
float the_vector_len= ao_radius * (1-depth*.8) * ao_choice;
#line 1479
uint i; 
#line 1482
float2 the_vector;
#line 1485
const float angle = radians(180)/points;
#line 1490
texcoord = (floor((vpos.xy)/2)*2+0.5)*float2((1.0 / 1920), (1.0 / 1018));
#line 1494
float2x3 ao_point ;
ao_point[0]=0;
ao_point[1]=0;
#line 1498
[unroll]
for(i = 0; i< 2; i++) {
#line 1504
float2 outer_circle = 1/normalize(float2(1920, 1018))*float2( sin((i*2+.5)*angle), cos((i*2+.5)*angle) );
float2 inner_circle = 1/normalize(float2(1920, 1018))*float2( sin((i*2-.5)*angle), cos((i*2-.5)*angle) );
#line 1507
the_vector = the_vector_len * (!square ? inner_circle : outer_circle);
#line 1510
ao_point[i][0] = pointDepth( texcoord+the_vector);
}
#line 1513
[unroll]
for(i = 2; i< 4; i++) {
#line 1519
float2 outer_circle = 1/normalize(float2(1920, 1018))*float2( sin((i*2+.5)*angle), cos((i*2+.5)*angle) );
float2 inner_circle = 1/normalize(float2(1920, 1018))*float2( sin((i*2-.5)*angle), cos((i*2-.5)*angle) );
#line 1522
the_vector = the_vector_len * (!square ? inner_circle : outer_circle);
#line 1525
ao_point[i-2][1] = pointDepth( texcoord+the_vector);
}
#line 1528
[unroll]
for(i = 4; i< 6; i++) {
#line 1534
float2 outer_circle = 1/normalize(float2(1920, 1018))*float2( sin((i*2+.5)*angle), cos((i*2+.5)*angle) );
float2 inner_circle = 1/normalize(float2(1920, 1018))*float2( sin((i*2-.5)*angle), cos((i*2-.5)*angle) );
#line 1537
the_vector = the_vector_len * (!square ? inner_circle : outer_circle);
#line 1540
ao_point[i-4][2] = pointDepth( texcoord+the_vector);
}
#line 1544
float max_depth = depth+0.01*ao_max_depth_diff;
float min_depth_sq = sqrt(depth)-0.01*ao_max_depth_diff;
min_depth_sq *=  min_depth_sq;
#line 1548
float2x3 adj_point;
adj_point[0]=0;
adj_point[1]=0;
#line 1552
[unroll]
for(i = 0 ; i<2; i++) {
ao_point[i] = fixDepth3(ao_point[i]);
ao_point[i] = (ao_point[i] < min_depth_sq) ? -depth : min(ao_point[i], max_depth);
}
#line 1558
float2x3 opposite;
#line 1560
opposite[0] = ao_point[1].yzx;
opposite[1] = ao_point[0].zxy;
#line 1563
[unroll]
for(i = 0 ; i<2; i++) {
ao_point[i] = (ao_point[i] >= 0) ? ao_point[i] : depth*2-abs(opposite[i]);
}
#line 1568
adj_point[0] = ao_point[1];
adj_point[1] = ao_point[0].yzx;
#line 1576
float3 variance = 0;
#line 1578
for(i = 0 ; i<2; i++) {
variance += (ao_point[i]-adj_point[i])*(ao_point[i]-adj_point[i]);
}
#line 1582
variance = sqrt(dot(variance, float3(1,1,1)/(2*points)));
#line 1585
variance += shape;
#line 1587
float3 ao3=0;
#line 1589
[unroll]
for(i = 0 ; i<2; i++) {
#line 1592
float3 near=min(ao_point[i],adj_point[i]);
float3 far=max(ao_point[i],adj_point[i]);
#line 1596
near -= variance;
far  += variance;
#line 1600
float3 crossing = (depth-near)/(far-near);
#line 1603
crossing = 2*clamp(crossing,0,1)-1;
#line 1605
ao3 += crossing;
}
#line 1610
ao3 *= (50*abs(ao_choice)+.5);
#line 1612
ao += dot(ao3, float3(1,1,1)/points);
#line 1756
}
#line 1761
if(debug_mode==2 ) c=undoTonemap(.33);
#line 1764
float fog_fix_multiplier = clamp((1-depth/ao_fog_fix)*2,0,1 );
#line 1766
if(gi_path && gi_use_depth && depth) {
float depth_ratio = gi.w/depth;
#line 1769
depth_ratio=clamp(depth_ratio,1-depth_ratio,1); 
#line 1771
c = lerp(c, c*depth_ratio, gi_ao_strength*fog_fix_multiplier*smoke_fix);
}
#line 1774
ao = ao*fog_fix_multiplier;
#line 1777
if (ao<0) {
ao*=ao_shine_strength*.5;
ao*=smoke_fix;
#line 1781
c=c*(1-ao);
}
else if(ao>0) {
bounce = bounce*ao_strength*min(ao,.5);
#line 1786
ao *= ao_strength*1.8; 
#line 1788
bounce = min(c*ao,bounce); 
#line 1790
ao*=smoke_fix;
#line 1793
c = clamp( c*(1-ao) + bounce,  0.25*c, c  );
}
#line 1797
if(gi_path) {
#line 1801
if(debug_mode==5) c=gi.rgb;
#line 1809
}
#line 1811
if(gi_path || ao_enabled) c=reapplyTonemap(c);
#line 1814
if(debug_mode==1)	c = lerp(c.ggg, float3(0,1,0), ratio*ratio);
if(debug_mode==4)	c = lerp(depth, float3(0,1,0), ratio*ratio);
#line 1817
}
#line 1822
if(debug_mode == 3) c = depth ;
#line 1824
c.rgb = toOutputColorspace(c);
#line 1826
return c;
}
#line 1830
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 1839
float3 Glamarye_Fast_Effects_all_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
return  Glamarye_Fast_Effects_PS(vpos,  texcoord, true);
}
#line 1844
float3 Glamarye_Fast_Effects_without_Fake_GI_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
return  Glamarye_Fast_Effects_PS(vpos,  texcoord, false);
}
#line 1851
technique Glamarye_Fast_Effects_with_Fake_GI <
ui_tooltip = "Designed for speed, it combines multiple effects in one shader. Higher quality effects exist, but not this fast. \nThe aim is to look good enough without destroying your framerate. If you turn off your game's built-in post-processing options and use these instead you may even get a higher framerate!\n"
"\nBasic effects:\n"
"1. FXAA. Fixes jagged edges. \n"
"2. Intelligent Sharpening. \n"
"3. Ambient occlusion. Shades areas that receive less ambient light. It can optionally brighten exposed shapes too, making the image more vivid (AO shine setting).\n"
"4. Subtle Depth of Field. Softens distant objects.\n"
"5. Detect Menus and Videos. Disables effects when not in-game.\n"
"6. Detect Sky. Disable effects for background images behind the 3D world\n"
"\nFake Global Illumination effects:\n"
" (these attempts to look like fancy GI shaders but using very simple approximations. Not as realistic, but very fast.)\n"
"1. Indirect lighting. Pixels take color from the surrounding area (depth optional!)\n"
"2. Adaptive contrast enhancement. Enhances clarity.\n"
"3. Large scale ambient occlusion. Big area but very soft.\n"
"4. Local bounce light. Enhances ambient occlusion, adding color to it.\n";
#line 1867
>
{
pass makeGI
{
VertexShader = PostProcessVS;
PixelShader = startGI_PS;
RenderTarget = GITexture;
}
#line 1876
pass  {
VertexShader = PostProcessVS;
PixelShader  = bigBlur1_PS;
RenderTarget = HBlurTex;
}
#line 1882
pass  {
VertexShader = PostProcessVS;
PixelShader  = bigBlur2_PS;
RenderTarget = VBlurTex;
}
#line 1888
pass  {
VertexShader = PostProcessVS;
PixelShader  = bigBlur3_PS;
RenderTarget = HBlurTex;
}
#line 1894
pass  {
VertexShader = PostProcessVS;
PixelShader  = bigBlur4_PS;
RenderTarget = VBlurTex;
}
#line 1900
pass {
VertexShader = PostProcessVS;
PixelShader = Glamarye_Fast_Effects_all_PS;
#line 1908
SRGBWriteEnable = true;
#line 1910
}
#line 1913
}
#line 1915
technique Glamarye_Fast_Effects_without_Fake_GI <
ui_tooltip = "Designed for speed, it combines multiple effects in one shader. Higher quality effects exist, but not this fast. \nThe aim is to look good enough without destroying your framerate. If you turn off your game's built-in post-processing options and use these instead you may even get a higher framerate!\n"
"\nBasic effects:\n"
"1. FXAA. Fixes jagged edges. \n"
"2. Intelligent Sharpening. \n"
"3. Ambient Occlusion. Shades areas that receive less ambient light. It can optionally brighten exposed shapes too, making the image more vivid (AO shine setting).\n"
"4. Subtle Depth of Field. Softens distant objects.\n"
"5. Detect Menus and Videos. Disables effects when not in-game.\n"
"6. Detect Sky. Disable effects for background images behind the 3D world\n."
"This version does not include the Fake GI effects, therefore is faster than the full version.\n";
>
{
pass Glamayre
{
VertexShader = PostProcessVS;
PixelShader = Glamarye_Fast_Effects_without_Fake_GI_PS;
#line 1936
SRGBWriteEnable = true;
#line 1938
}
#line 1940
}
#line 1946
}

