// ZNRY_MV_TYPE=0
// IMPORT_SAM=0
// HIDE_INTERMEDIATE=1
// HIDE_ADVANCED=1
// HIDE_EXPERIMENTAL=1
// ZNRY_RENDER_SCL=0.5
// ZNRY_SAMPLE_DIV=4
// DO_REFLECT=0
// ZNRY_MAX_LODS=6
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ZN_DAMP_RT.fx"
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
#line 33 "C:\Program Files\GShade\gshade-shaders\Shaders\ZN_DAMP_RT.fx"
#line 94
uniform int FRAME_COUNT <
source = "framecount";>;
#line 99
static int2 TAA_SAM_DST[8] = {
int2(1,-3), int2(-1,3),
int2(5,1), int2(-3,-5),
int2(-5,5), int2(-7,-1),
int2(3,7), int2(7,-7)};
#line 105
uniform int ZN_DAMPRT <
ui_label = " ";
ui_text = "NOTE: Read the 'Preprocessor Info' and enable motion vectors before using\n\n"
"Zentient DAMP RT (Depth Aware Mipmapped Ray Tracing) is a shader built around\n"
"sampling miplevels in order to approximate cone tracing in 2D space\n"
"before extrapolating into 3D \n"
"While not directly taken from any papers, it was heavily inspired after seeing\n"
"Alexander Sannikov's approach to calculating GI with radiance cascasdes.\n";
ui_type = "radio";
ui_category = "ZN DAMP RT";
> = 1;
#line 117
uniform float BUFFER_SCALE <
ui_type = "slider";
ui_min = 0.5;
ui_max = 5.0;
ui_label = "Buffer Scale";
ui_tooltip = "Adjusts the accuracy of the depth buffer for closer objects";
ui_category = "Depth Buffer Settings";
hidden = true;
> = 2.0;
#line 127
uniform float NEAR_PLANE <
ui_type = "slider";
ui_min = -1.0;
ui_max = 2.0;
ui_label = "Near Plane";
ui_tooltip = "Adjust min depth for depth buffer, increase slightly if dark lines or occlusion artifacts are visible";
ui_category = "Depth Buffer Settings";
ui_category_closed = true;
hidden = 1;
> = 0.0;
#line 138
uniform float FOV <
ui_type = "slider";
ui_min = 0.0;
ui_max = 110.0;
ui_label = "FOV";
hidden = true;
ui_tooltip = "Adjust to match ingame FOV";
ui_category = "Depth Buffer Settings";
ui_step = 1;
> = 70;
#line 149
uniform bool SMOOTH_NORMALS <
ui_label = "Smooth Normals";
ui_tooltip = "Smooths normals to fake higher poly models || Moderate Performance Impact";
ui_category = "Depth Buffer Settings";
hidden = 1;
> = 0;
#line 156
uniform float INTENSITY <
ui_type = "slider";
ui_min = 0.0;
ui_max = 20.0;
ui_label = "GI Intensity";
ui_tooltip = "Intensity of the effect. It goes up to 40, I don't recommend keeping it there";
ui_category = "Display";
ui_category_closed = true;
> = 6.0;
#line 166
uniform float SHADOW_INT <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Shadow Intesity";
ui_tooltip = "Darkens shadows before adding GI to the image";
ui_category = "Display";
> = 0.8;
#line 175
uniform float SHADOW_GAMMA <
ui_type = "slider";
ui_min = 0.01;
ui_max = 2.0;
ui_label = "Shadow Gamma";
ui_tooltip = "Gamma applied to shadow before blending";
hidden = 1;
ui_category = "Display";
> = 1.0;
#line 186
uniform float3 SKY_COLOR <
ui_type = "color";
ui_label = "Ambient Color";
ui_tooltip = "Adds ambient light to the scene";
ui_category = "Display";
> = float3(0.45, 0.45, 0.5);
#line 193
uniform float LIGHTMAP_SAT <
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
ui_label = "LightMap saturation";
ui_tooltip = "Boosts lightmap saturation to compensate for downsampling";
hidden = 1;
ui_category = "Display";
ui_category_closed = true;
> = 1.2;
#line 204
uniform float HDR_RED <
ui_type = "slider";
ui_min = 1.01;
ui_max = 1.6;
ui_label = "HDR Reduction";
ui_tooltip = "Reduces the maximum difference between light and dark areas";
hidden = 1;
ui_category = "Display";
ui_category_closed = true;
> = 1.1;
#line 215
uniform bool DO_BOUNCE <
ui_label = "Bounce lighting";
ui_tooltip = "Accumulates GI from previous frames to calculate extra GI steps || No Performance Impact";
ui_category = "Display";
hidden = 1;
> = 1;
#line 222
uniform float TERT_INTENSITY <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Bounce intensity";
ui_tooltip = "Intensity of accumulated bounce lighting, has a compounding effect on GI";
ui_category = "Display";
hidden = 1;
ui_category_closed = true;
> = 0.5;
#line 233
uniform float AMBIENT_NEG <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Exposure Reduction";
ui_tooltip = "Reduces exposure before adding GI";
ui_category = "Display";
> = 0.0;
#line 242
uniform bool DO_AO <
ui_label = "Ambient occlusion";
ui_tooltip = "Lightweight ambient occlusion implementation || Low performance impact";
ui_category = "Display";
> = 1;
#line 248
uniform float DEPTH_MASK <
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_label = "Depth Mask";
ui_tooltip = "Depth dropoff to allow compatibility with in game fog";
ui_category = "Display";
> = 0.08;
#line 257
uniform float COLORMAP_BIAS <
ui_type = "slider";
ui_label = "Colormap Bias";
ui_tooltip = "Normalizes the color buffer, recommended to keep very close to 1.0";
ui_category = "Colors";
ui_category_closed = true;
hidden = 1;
ui_min = 0.9;
ui_max = 1.0;
> = 0.997;
#line 268
uniform float COLORMAP_OFFSET <
ui_type = "slider";
ui_label = "Colormap Offset";
hidden = 1;
ui_tooltip = "Attempts to reduce artifacts in dark colors, but can wash them out in certain scenes";
ui_category = "Colors";
ui_min = 0.0;
ui_max = 0.01;
> = 0.001;
#line 278
uniform float3 DETINT_COLOR <
ui_type = "color";
ui_label = "Detint Color";
ui_tooltip = "Can help remove certain boosted colors from the GI (ex. Purple shadows)";
ui_category = "Colors";
> = float3(0.06, 0.45, 1.0);
#line 285
uniform float DETINT_LEVEL <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Detint Strength";
ui_tooltip = "The amount of Detinting applied";
ui_category = "Colors";
> = 0.0;
#line 294
uniform bool TAA_ERROR <
ui_label = "Temporal Smoothing";
ui_tooltip = "Reduces noise almost completely when paired with a motion vector shader, disable if not using one\n"
"vort_motion or qUINT_MotionVectors recommended, although it should be compatible with most motion vectors";
ui_category = "Denoising";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
#line 303
uniform bool DONT_SPATIAL <
ui_label = "Disable Spatial Denoising";
ui_tooltip = "Disables the spatial upscaler/denoiser before temporal denoising";
ui_category = "Denoising";
hidden = 1;
> = 0;
#line 310
uniform float TAA_SKIP <
ui_type = "slider";
ui_label = "Temporal Skipping";
ui_tooltip = "Helps reduce flickering when no motion vectors are available\n"
"Set to 2 if not using motion vectors";
ui_category = "Denoising";
ui_min = 1.0;
ui_max = 2.0;
ui_step = 1.0;
> = 1.0;
#line 321
uniform float FRAME_PERSIST <
ui_type = "slider";
ui_label = "Frame Persistence";
ui_tooltip = "Lower values will have less ghosting but more noise, higher values will have lower noise but more ghosting\n";
ui_category = "Denoising";
ui_min = 0.1;
ui_max = 0.95;
> = 0.875;
#line 330
uniform int UPSCALE_ITER <
ui_type = "slider";
ui_label = "Denoiser Samples";
ui_tooltip = "Reduces noise and improves upscaling at the cost of detail and performance";
ui_min = 2;
ui_max = 64;
> = 8;
#line 338
uniform int SAMPLE_COUNT <
ui_type = "slider";
ui_label = "Ray count";
ui_min = 3;
ui_max = 24;
ui_tooltip = "How many rays are cast per pixel. Massively diminishing returns over 6 || Large Performance Impact";
ui_category = "Sampling";
ui_category_closed = true;
> = 5;
#line 350
uniform bool SHADOW <
ui_label = "Shadows";
ui_tooltip = "Rejects some samples to cast soft shadows, essentially a pretty nice AO || Almost No Performance Impact";
ui_category = "Sampling";
hidden = 1;
> = 1;
#line 357
uniform bool ENABLE_Z_THK <
ui_label = "Enable Z thickness";
ui_tooltip = "Enables thickness for shadow occlusion to prevent shadow haloing || Low Performance Impact";
ui_category = "Sampling";
hidden = 1;
> = 1;
#line 364
uniform float SHADOW_Z_THK <
ui_type = "slider";
ui_label = "Z Thickness";
ui_tooltip = "Depth of cast shadows";
ui_category = "Sampling";
hidden = 1;
ui_min = 0.001;
ui_max = 1.0;
> = 0.01;
#line 374
uniform float SHADOW_BIAS <
ui_type = "slider";
ui_label = "Shadow Bias";
ui_tooltip = "Reduces artifacts and intensity of shadows";
ui_category = "Sampling";
hidden = 1;
ui_min = -0.01;
ui_max = 0.01;
> = 0.001;
#line 384
uniform bool BLOCK_SCATTER <
ui_label = "Block Scattering";
ui_tooltip = "Prevents surface scattering and brightening of already bright areas || Low-Medium Performance Impact";
ui_category = "Sampling";
hidden = 1;
> = 1;
#line 391
uniform float RAY_LENGTH <
ui_type = "slider";
ui_min = 0.5;
ui_max = 10.0;
ui_label = "Ray Step Length";
ui_tooltip = "Changes the length of ray steps per Mip, reduces overall sample quality but increases ray range || Moderate Performance Impact";
ui_category = "Sampling";
hidden = 1;
> = 4.0;
#line 401
uniform float DIST_BIAS <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_label = "Distance Bias";
ui_tooltip = "Gives distant samples a slightly higher weight to account for incomplete sampling || No Performance Impact";
ui_category = "Sampling";
hidden = 1;
> = 0.25;
#line 411
uniform float DISTANCE_SCALE <
ui_type = "slider";
ui_min = 0.01;
ui_max = 20.0;
ui_label = "Distance Scale";
ui_tooltip = "The scale at which brightness calculations are made\n"
"Higher values cause light to disperse more quickly, lower values will cause light to propogate furtherm.\n"
"Note that lower values aren't particularly 'better'";
ui_category = "Sampling";
hidden = 1;
> = 1.0;
#line 423
uniform float DISTANCE_POW <
ui_type = "slider";
ui_min = 0.5;
ui_max = 3.0;
ui_label = "Distance Power";
ui_tooltip = "The inverse power light dissipates from, 2.0 is inverse square, 1.0 is linear";
ui_category = "Sampling";
hidden = 1;
> = 2.0;
#line 433
uniform int DEBUG <
ui_type = "combo";
ui_category = "Debug Settings";
ui_items = "None\0Lighting\0GI * Color Map\0GI\0Shadows\0Color Map\0DeGhosting mask\0Normals\0Depth\0LightMap\0";
hidden = 1;
> = 0;
#line 440
uniform bool SHOW_MIPS <
ui_label = "Display Mipmaps";
ui_category = "Debug Settings";
ui_tooltip = "Just for fun, for anyone wanting to visualize how it works\n"
"recommended to use either the lighting or GI debug view";
hidden = 1;
> = 0;
#line 448
uniform bool STATIC_NOISE <
ui_label = "Static Noise";
ui_category = "Debug Settings";
ui_tooltip = "Disables sample jittering";
hidden = 1;
> = 0;
#line 455
uniform bool DONT_DENOISE <
ui_category = "Debug Settings";
ui_label = "Disable Temporal Denoising";
hidden = 1;
> = 0;
#line 462
uniform float SPECULAR_POW <
ui_type = "slider";
ui_min = 0.5;
ui_max = 10.0;
ui_label = "Reflection power";
ui_tooltip = "Diffuse reflection power, only works if experimental reflections are enabled";
hidden = 1 - 0;
> = 2.0;
#line 471
uniform int TONEMAPPER <
ui_type = "combo";
ui_items = "ZN Filmic\0Sony A7RIII\0ACES\0Modified Reinhard Jodie\0None\0"; 
ui_label = "Tonemapper";
ui_tooltip = "Tonemapper Selection, Reinhardt Jodie is the truest to original image, but other options are included";
ui_category = "Experimental";
hidden = 1;
> = 3;
#line 480
uniform bool DYNA_SAMPL <
ui_category = "Experimental";
ui_label = "Dynamic Sampling";
ui_tooltip = "Applies sample amount dynamically to save performance";
hidden = 1;
> = 0;
#line 487
uniform bool REMOVE_DIRECTL <
ui_label = "Brightness Mask";
ui_tooltip = "Prevents excessive illumination in already lit areas, but tends to reduce local contrast significantly || No Performance Impact";
ui_category = "Experimental";
hidden = true;
> = 0;
#line 495
uniform int PREPRO_SETTINGS <
ui_type = "radio";
ui_category = "Preprocessor Info";
ui_category_closed = true;
ui_text = "Preprocessor Definition Guide:\n"
"\n"
"NOTE: ONLY CHANGE PREPROCESSORS IF YOU KNOW WHAT YOU ARE DOING, IF CHANGEING A SETTING CAUSES COMPILER FAILURE, MAKE A NEW PRESET OR CLEAR OUT THE DAMP PREPROCESSOR SETTINGS IN THE RESHADEPRESET.ini\n"
"\n"
"DO_REFLECT - Enables experimental diffuse reflections, unfinished, quite innacurate, and has a substantial performance impact\n"
"\n"
"HIDE INTERMEDIATE/ADVANCED/EXPERIMENTAL - Displays varying levels of advanced settings, experimental settings are unfinished and untested\n"
"\n"
"IMPORT_SAM - Toggles experimental importance sampling to cherry pick results, has a moderate performance impact, and generally provides worse results\n"
"\n"
"ZNRY_MAX_LODS - The maximum LOD sampled, has a direct performance impact, and an exponential impact on ray range. Max recommended is 7, max generally is 9 but may cause compiler failure at low resolution scales\n"
"7 is usually enough for near fullscreen coverage\n"
"\n"
"ZNRY_MV_TYPE - Selects the motion vector shader to use: 0 for vort_Motion, 1 for launchpad, and 2 for most others (qUINT, Uber, etc)\n"
"Note that motion vectors must be properly configured to prevent noise and ghosting\n"
"\n"
"ZNRY_RENDER_SCL - The resolution scale for GI (0.5 is 50%, 1.0 is 100%), changes may require reloading ReShade.\n"
"\n"
"ZNRY_SAMPLE_DIV - The miplevel of sampled textures (ex, 4 is 1/4 resolution, 2 is half resolution, 1 is full resolution)\n"
"This has a moderate performance impact, with minimal quality improvements and negative effects on range, not recommended to set below 2";
> = 1;
#line 521
uniform int CREDITS <
ui_type = "radio";
ui_category = "Credits";
ui_text = "\nCredits and thanks:\n"
"A big thanks to, Soop, Beta|Alea, Can, AlucardDH, BlueSkyDefender, Ceejay.dk and Dreamt for shader testing and feedback\n"
"And a thank you to BlueSkyDefender, Vortigern, and LordofLunacy\n"
"for being crazy enough to try and understand bits of the spaghetti code that is this shader\n"
"And a big thank you to Crushius for providing me with a copy of 'Shadow Man Remastered' so I could test in something other than Skyrim\n"
"If you did help with development and I forgot to mention you here, please reach out so I can amend the credits";
ui_label = " ";
> = 0;
#line 533
uniform int SHADER_VERSION <
ui_type = "radio";
ui_text = "\n" "Shader Version - Test Release A26-3-1 (v0.2.6.3.1)";
ui_label = " ";
> = 0;
#line 544
namespace A26{
texture BlueNoiseTex < source = "ZNbluenoise512.png"; >
{
Width  = 512.0;
Height = 512.0;
Format = RGBA8;
};
sampler NoiseSam{Texture = BlueNoiseTex; MipFilter = Point;};
#line 553
texture NorTex{Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 3;};
sampler NorSam{Texture = NorTex;};
#line 556
texture NorDivTex{
Width = 1920 / 4;
Height = 1018 / 4;
Format = RGBA8;
MipLevels = 6;
};
sampler NorDivSam{
Texture = NorDivTex;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
};
#line 569
texture NorInTex{
Width = 1920;
Height = 1018;
Format = RGBA8;
MipLevels = 6;
};
sampler NorInSam{Texture = NorInTex;};
#line 577
texture BufTex{
Width = int(1920 * 0.5 / 4);
Height = int(1018 * 0.5 / 4);
Format = R16;
MipLevels = 6;
};
sampler DepSam{
Texture = BufTex;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = POINT;
};
#line 590
texture BilaTex{
Width = int(1920 * 0.5);
Height = int(1018 * 0.5);
Format = RGBA8;
MipLevels = 6;
};
sampler BilaSam{Texture = BilaTex;};
texture LumTex{
Width = int(1920 * 0.5 / 4);
Height = int(1018 * 0.5 / 4);
Format = RGBA16F;
MipLevels = 6 + 1;
};
sampler LumSam{Texture = LumTex;};
#line 605
texture GITex{
Width = int(1920 * 0.5);
Height = int(1018 * 0.5);
Format = RGBA16F;MipLevels = 3;
};
sampler GISam{
Texture = GITex;
};
texture UpscaleTex{
Width = 1920;
Height = 1018;
Format = RGBA16F;MipLevels = 3;
};
sampler UpSam{
Texture = UpscaleTex;
};
#line 622
texture PreTex {
Width = 1920;
Height = 1018;
Format = RGBA8;
};
sampler PreFrm {Texture = PreTex;};
#line 629
texture PreLuminTex {
Width = int(1920 * 0.5);
Height = int(1018 * 0.5);
Format = R16;
MipLevels = 2;
};
sampler PreLumin {Texture = PreLuminTex;};
#line 637
texture CurTex {
Width = 1920;
Height = 1018;
Format = RGBA8;
MipLevels = 3;
};
sampler CurFrm {Texture = CurTex;};
#line 645
texture DualTex {
Width = 1920;
Height = 1018;
Format = RGBA8; MipLevels = 3;
};
sampler DualFrm {Texture = DualTex;};
}
#line 669
texture2D MotVectTexVort {Width = 1920; Height = 1018; Format = RG16F;};
sampler motionSam {Texture = MotVectTexVort; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
#line 677
float3 SONYA7RIII(float3 z) 
{							
float a = 0.1;
float b = 1.1;
float c = 0.5;
float3 d = float3(0.02, 0.01, 0.02);
float e = 1.3;
float f = 4.8;
float g = 0.3;
float h = 2.0;
float i = 0.2;
float j = 0.6;
float k = 1.3;
float l = 2.5;
#line 692
z *= 20.0;
z = h*(c+pow(a*z,b)-d*(sin(e*z)-j)/((k*z-f)*(k*z-f)+g));
z = i*l*log(z);
#line 696
return saturate(z);
}
#line 699
float3 ReinhardtJ(float3 x) 
{
float  lum = dot(x, float3(0.2126, 0.7152, 0.0722));
float3 tx  = x / (x + 1.0);
return HDR_RED * lerp(x / (lum + 1.0), tx, pow(tx, 0.7));
}
#line 706
float3 InvReinhardtJ(float3 x)
{
float  lum = dot(x, float3(0.2126, 0.7152, 0.0722));
float3 tx  = -x / (x - HDR_RED);
return lerp(tx, -lum / ((0.5 * x + 0.5 * lum) - HDR_RED), pow(x, 0.7));
}
#line 713
float3 ZNFilmic(float3 x)
{
float a = 17.36;
float b = 16.667;
float c = 3.0;
float d = 0.4;
return saturate((a*x*x+d*x) / (b*x*x + c*x + 1.0));
}
#line 722
float3 ACESFilm(float3 x)
{
float a = 2.51f;
float b = 0.03f;
float c = 2.43f;
float d = 0.59f;
float e = 0.14f;
return saturate((x*(a*x+b))/(x*(c*x+d)+e));
}
#line 736
float3 saturation(float3 c, float sat)
{
float lum = c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722;
c	 	= lerp(lum, c, sat);
return saturate(c);
}
#line 743
float3 eyePos(float2 xy, float z)
{
float  nd	 = z * 1000.0;
float3 eyp	= float3((2f * xy - 1f) * nd, nd);
return eyp * float3(float2(1920, 1018).x/float2(1920, 1018).y, 1.0, 1.0);
}
#line 750
float3 NorEyePos(float2 xy)
{
float  nd	 = ReShade::GetLinearizedDepth(xy) * 1000.0;
float3 eyp	= float3((2f * xy - 1f) * nd, nd);
return eyp * float3(float2(1920, 1018).x/float2(1920, 1018).y, 1.0, 1.0);
}
#line 757
float3 GetScreenPos(float3 xyz)
{
xyz /= float3(float2(1920, 1018).x/float2(1920, 1018).y, 1.0, 1.0);
return float3(0.5 + 0.5 * (xyz.xy / xyz.z), xyz.z / 1000.0);
}
#line 763
int weighthash(float2 p, float w1, float w2) 
{
float3 p3	= frac(float3(p.xyx) * .1031);
p3	+= dot(p3, p3.yzx + 33.33);
float  hsh   = frac((p3.x + p3.y) * p3.z);
float  c	 = w1 / (w1 + w2);
#line 770
if(hsh < c) return 0;
else return 1;
}
#line 774
float2 hash(float2 p)
{
float3 p3	= frac(p.xyx * float3(.1031, .1030, .0973));
p3	+= dot(p3, p3.yzx+33.33);
return frac((p3.xx+p3.yz)*p3.zy);
}
#line 781
float hash12(float2 p)
{
float3 p3  = frac(p.xyx * .1031);
p3 += dot(p3, p3.yzx + 33.33);
return frac((p3.x + p3.y) * p3.z);
}
#line 788
float3 hash3(float3 x)
{
x		= frac(x * float3(.1031, .1030, .0973));
x		+= dot(x, x.yxz+33.33);
return   frac((x.xxy + x.yxx)*x.zyx);
}
#line 795
float4 DAMPGI(float2 xy, float2 offset)
{
float2 res = float2(1920, 1018);
float  f	 = 1000.0;
float  n	 = NEAR_PLANE;
float2 PW	= 2.0 * tan(FOV * 0.00875) * (f - n); 
PW.y *= res.x / res.y;
#line 803
int	LODS  = 6;
float  trueD = ReShade::GetLinearizedDepth(xy);
if(trueD == 1.0) {return float4(0.0, 0.0, 0.0, 1.0);}
float3 surfN = 2.0 * tex2D(A26::NorSam, xy).rgb - 1.0;
#line 808
float  d	 = trueD;
float3 rp	= float3(xy, d);
float3 l;	
#line 812
float  occ;
float3 trueC = pow(tex2D(A26::LumSam, xy).rgb, 1.0 / 2.2);
#line 815
int sampl = SAMPLE_COUNT;
if(DYNA_SAMPL) sampl = 1 + ceil((1.0 - 0.33 * (trueC.r + trueC.g + trueC.b)) * max(SAMPLE_COUNT - 1, 0));
float3 actSam; 
float  resW; 
float  iW;	
for(int i = 0; i < sampl; i++){
#line 822
d =  trueD;
int iLOD = 0;
rp	  = float3(xy, d);
float3 minD	= 1.0;
float3 maxD	= 0.0;
float2 vec	 = float2(sin((6.28 * offset.r) + (i+1) * 6.28 / sampl), cos((6.28 * offset.r) + (i+1) * 6.28 / sampl));
float3 pixP	= float3(xy, trueD);
#line 830
for(int ii = 2; ii <= 6; ii++)
{
#line 833
float3 compVec0	= normalize(rp - pixP + 0.000001);
float3 compVec1	= normalize(minD - pixP + 0.000001);
float3 compVec2	= normalize(maxD - pixP + 0.000001);
#line 837
if(compVec0.z <= compVec1.z) {minD = rp;}
if(compVec0.z >= compVec1.z) {maxD = float3(rp.xy, rp.z + SHADOW_Z_THK);}
#line 841
float2 rd = offset.xy * abs(SHOW_MIPS - 1.0);
#line 844
rp.xy += (RAY_LENGTH * (vec + rd) * pow(2, ii)) / res;
if(rp.x > 1.0 || rp.y > 1.0) {break;}
if(rp.x < 0 || rp.y < 0) {break;}
#line 848
d = tex2Dlod(A26::DepSam, float4(rp.xy, 0, floor(0.75 * iLOD))).r;
rp.z = d;
#line 853
float sh;
if(SHADOW == 0) {sh = 1.0;}
float3 eyeXY	 = eyePos(rp.xy, rp.z);
float3 texXY	 = eyePos(xy, trueD);
float3 shvMin	= normalize(minD - pixP);
float3 shvMax	= normalize(maxD - pixP);
float  shd	   = distance(rp, float3(xy, trueD));
float  sb		= SHADOW_BIAS;
bool   zd;		
#line 863
if(ENABLE_Z_THK) zd = d > (trueD + shd * shvMax.z + SHADOW_Z_THK) - sb;
if(d <= (trueD + shd * shvMin.z) + sb || zd) {sh = 1.0;}
#line 867
float3 col = tex2Dlod(A26::LumSam, float4(rp.xy, 0, iLOD)).rgb;
float  smb = 1.0;
#line 870
if(BLOCK_SCATTER)
{
float3 nor = 2.0 * tex2Dlod(A26::NorDivSam, float4(rp.xy, 0, iLOD)).rgb - 1.0;
float3 lv2 = normalize(eyePos(pixP.xy, pixP.z) - eyePos(rp.xy, rp.z) );
smb = 4.0 * max(dot(nor, lv2), 0.0);
}
#line 877
float  ed	 = 1.0 + pow(abs((DISTANCE_SCALE * distance(texXY, 0.0))), DISTANCE_POW) / f;
float  cd	 = 1.0 + pow(abs((DISTANCE_SCALE * distance(eyeXY, texXY))), DISTANCE_POW) / f;
float3 lv	 = normalize(eyePos(rp.xy, rp.z) - eyePos(pixP.xy, pixP.z));
float  amb	= max(dot(surfN, lv), 0.0);
#line 882
float  rfs	= 1.0;
#line 889
col *= ed;
float3 lAcc = smb * amb * (col / (cd *ed));
l += rfs * sh * lAcc * pow(1.0 + DIST_BIAS, iLOD);
occ += amb * sh * saturate(length(col) / ed);
#line 894
iW += (lAcc.r + lAcc.g + lAcc.b); 
iLOD++;
}
#line 901
}
#line 905
l /= sampl / 16.0;
l = pow(l / LODS, 1.0 / 2.2);
occ = saturate(4.0 * length(l + 0.01) * length(tex2D(A26::LumSam, xy)));
#line 909
float4 result = float4(l, pow(occ, SHADOW_GAMMA));
#line 911
return max(0.001, result);
}
#line 914
float3 tonemap(float3 input)
{
input = max(0.0, input);
if(TONEMAPPER == 0) input = ZNFilmic(input);
if(TONEMAPPER == 1) input = SONYA7RIII(input);
if(TONEMAPPER == 2) input = ACESFilm(input);
if(TONEMAPPER == 3) input = ReinhardtJ(input);
if(TONEMAPPER == 4) {return pow(input, 1.0 / 2.2);}
if(TONEMAPPER == 5) input = pow(input, 0.5 * input + 1.0);
input = pow(input, 1.0 / 2.2);
return saturate(input);
}
#line 927
float SampleAO(float2 xy, float SampleLength, float Thickness)
{
return 1.0;
#line 950
}
#line 952
float3 BlendGI(float3 input, float4 GI, float depth, float2 xy)
{
float dAccp = 1.0 - DEPTH_MASK;
input	   = pow(input, 2.2);
float3 ICol = saturate(input);
ICol = lerp(normalize(ICol + COLORMAP_OFFSET) / 0.577, input, 0.5 + 0.5 * COLORMAP_BIAS);
#line 959
float  ILum = (input.r + input.g + input.b) / 3.0;
float3 iGI;
GI.rgb	  = pow(GI.rgb, 2.2);
GI.rgb	  *= 1.0 + (1.0 - DETINT_COLOR) * pow(DETINT_LEVEL, 7.0);
GI.rgb	  /= exp(pow(15.0 * depth * DEPTH_MASK, 2.0));
GI.a		=  lerp(1.0, GI.a, 1.0 / exp(pow(15.0 * depth * DEPTH_MASK, 2.0)));
float GILum = (GI.r + GI.g + GI.b) / 3.0;
#line 968
if(REMOVE_DIRECTL == 0) {ILum = 0.0;}
#line 971
if(DEBUG == 2) {input = saturate(INTENSITY * GI.rgb) * ICol;}
else if(DEBUG == 3) {input = saturate(GI.rgb);}
else if(DEBUG == 4) {input = saturate(pow(GI.a, 2.2));}
else if(DEBUG == 1)
{
input	= 0.33;
input	= input * GI.a;
iGI	  = INTENSITY * (GI.rgb);
#line 980
}
else if(DEBUG == 5) {input = ICol;}
else
{
if(depth == 1.0) return - input / (input - 1.1);
input	= normalize(input) / 0.577 * pow((input.r + input.g + input.b) / 3.0, 1.0 + AMBIENT_NEG);
input	= lerp(input, GI.a * input, SHADOW_INT);
iGI	  = (INTENSITY * (GI.rgb - (ILum)) * ICol);
}
#line 990
return iGI - input / (input - 1.1);
}
#line 995
float4 NbrClamp(sampler frame, float2 xy, float4 col, float deG)
{
float2 res	 = float2(1920, 1018);
float2 mVec	= tex2D(motionSam, xy).xy;
#line 1000
float4 m;
float4 m1;
float gam = 1.0;
for(int i = 0; i <= 1; i++) for(int ii = 0; ii <= 1; ii++)
{
float2 coord = xy + TAA_SKIP * float2(i - 0.5, ii - 0.5) / res;
float4 c 	= tex2Dlod(frame, float4(coord, 0, 1));
float4 cb	= tex2Dlod(A26::PreFrm, float4(coord + mVec, 0, 1));
#line 1009
c  = lerp(c, cb, FRAME_PERSIST * TAA_ERROR * round(1.0 - deG));
m  += c;
m1 += c*c;
}
float4 mu	  = m / 4.0;
float4 sig	 = sqrt(m1 / 4.0 - mu * mu);
float4 minC	= mu - sig * gam;
float4 maxC	= mu + sig * gam;
return clamp(col, minC, maxC);
}
#line 1025
float4 LightMap(float4 vpos : SV_Position, float2 xy : TexCoord) : SV_Target
{
float2 res	   = float2(1920, 1018) / 2.0;
float2 hp		= 0.5 / res;
float  offset	= 4.0;
#line 1031
float3 acc =  tex2D(ReShade::BackBuffer, xy).rgb * 4.0;
acc += tex2D(ReShade::BackBuffer, xy - hp * offset).rgb;
acc += tex2D(ReShade::BackBuffer, xy + hp * offset).rgb;
acc += tex2D(ReShade::BackBuffer, xy + float2(hp.x, -hp.y) * offset).rgb;
acc += tex2D(ReShade::BackBuffer, xy - float2(hp.x, -hp.y) * offset).rgb;
acc /= 8.0;
#line 1038
float  p 	= 2.2;
float3 te	= acc;
te	= pow(te, p);
#line 1042
te = saturate(saturation(te, LIGHTMAP_SAT));
te = InvReinhardtJ(te);
if(DO_BOUNCE)
{
float2 mVec	 =  tex2Dlod(motionSam, float4(xy, 0, 0)).xy;
float3 GISec	=  tex2Dlod(A26::DualFrm, float4(mVec + xy, 0, 2)).rgb;
te += ((te) * 5.0 * pow(SKY_COLOR, 2.2)) + lerp(normalize(te), te, 0.9) * GISec * TERT_INTENSITY;
#line 1050
}
#line 1054
return float4(max(0, te), 1.0);
}
#line 1058
float4 NormalBuffer(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 vc	  = NorEyePos(texcoord);
#line 1062
float3 vx0	  = vc - NorEyePos(texcoord + float2(1, 0) / float2(1920, 1018));
float3 vy0 	 = vc - NorEyePos(texcoord + float2(0, 1) / float2(1920, 1018));
#line 1065
float3 vx1	  = -vc + NorEyePos(texcoord - float2(1, 0) / float2(1920, 1018));
float3 vy1 	 = -vc + NorEyePos(texcoord - float2(0, 1) / float2(1920, 1018));
#line 1068
float3 vx = abs(vx0.z) < abs(vx1.z) ? vx0 : vx1;
float3 vy = abs(vy0.z) < abs(vy1.z) ? vy0 : vy1;
#line 1071
float3 output = 0.5 + 0.5 * normalize(cross(vy, vx));
#line 1073
return float4(output, 1.0);
}
#line 1076
float4 NormalSmooth(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
if(!SMOOTH_NORMALS) return float4(tex2D(A26::NorInSam, texcoord).xyz, 1.0);
float3 cCol;
float3 cNor = tex2D(A26::NorInSam, texcoord).xyz;
float  cDep = ReShade::GetLinearizedDepth(texcoord);
float  ang  = hash12(texcoord * float2(1920, 1018));
float  tw;
#line 1085
for(int i; i <= 4; i++)
{
float2 npos = 15.0 * float2(sin(ang), cos(ang)) * hash12((texcoord + 0.5) * float2(1920, 1018) * (i + 1.0)) / float2(1920, 1018);
float3 rNor = tex2Dlod(A26::NorInSam, float4(texcoord + npos, 0, 0)).xyz;
float3 rCol = tex2Dlod(A26::NorInSam, float4(texcoord + npos, 0, 0)).xyz;
float  rDep = ReShade::GetLinearizedDepth(texcoord + npos);
ang  += 6.28 / 4;
float wn  = pow(2.0 * max(dot(2.0 * rNor - 1.0, 2.0 * cNor - 1.0) - 0.5, 0.0), 1.0);
float wd  = exp(-distance(rDep, cDep) / 0.00003);
tw += wn*wd;
#line 1096
cCol += rCol * wn*wd;
}
if(tw < 0.00001) return float4(tex2D(A26::NorInSam, texcoord).xyz, 1.0);
return float4(cCol / tw, 1.0);
}
#line 1103
float4 RawGI(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
#line 1106
float2 bxy		= float2(1920, 1018);
float2 MSOff	  = 1.0 * TAA_SAM_DST[FRAME_COUNT % 8] / (16.0 * bxy);
float2 tempOff	= 1.0 * (1-STATIC_NOISE) * hash((1.0 + FRAME_COUNT % 128) * bxy);
tempOff	= floor(tempOff * float2(1920, 1018)) / float2(1920, 1018);
#line 1111
float2 offset	= frac(0.4 + tempOff + texcoord * (bxy / (512 / 0.5)));
float3 noise	 = tex2D(A26::NoiseSam, offset).rgb;
#line 1114
float4 GI		= float4(DAMPGI(MSOff + texcoord, 3.0 * (0.5 - noise.xy)));
GI		= saturate(GI + 0.125 * (noise.r - 0.5));
float  AO		= 1;
if(DO_AO) AO	 = SampleAO(texcoord, noise.r, 0.001);
return AO * (GI / (GI + 1.0));
#line 1120
}
#line 1122
float4 NormalDiv(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
return tex2Dlod(A26::NorSam, float4(texcoord, 0, 0));
}
#line 1127
float4 UpFrame(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
if(DONT_SPATIAL) return tex2D(A26::GISam, texcoord);
float4 cCol;
float3 cNor = 2.0 * tex2D(A26::NorSam, texcoord).xyz - 1.0;
float  cDep = ReShade::GetLinearizedDepth(texcoord);
float  ang  = 6.28 * hash12(texcoord * float2(1920, 1018) * (FRAME_COUNT % 128));
float  tw;
for(int i; i <= UPSCALE_ITER; i++)
{
float2 npos = float2(sin(ang), cos(ang)) ;
npos = (1.0 / 0.5) * npos * (1.0 + i) / float2(1920, 1018);
float3 rNor = 2.0 * tex2Dlod(A26::BilaSam, float4(texcoord + npos, 0, 0)).xyz - 1.0;
float  rDep = tex2Dlod(A26::PreLumin, float4(texcoord + npos, 0, 0)).r;
float4 rCol = tex2Dlod(A26::GISam, float4(texcoord + npos, 0, 0));
ang  += 12.56 / UPSCALE_ITER;
float nw  = pow(max(dot(rNor, cNor) - 0.5, 0), 4.0);
float dw  = exp(-distance(eyePos(texcoord, rDep), eyePos(texcoord, cDep)) * 3.0);
tw += nw * dw;
#line 1147
cCol += rCol * nw * dw;
}
if(tw < 0.0001) return tex2D(A26::GISam, texcoord);
return cCol / tw;
}
#line 1154
float4 CurrentFrame(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float4 CF	  = tex2D(A26::UpSam, texcoord);
float2 mVec	= tex2D(motionSam, texcoord).xy;
float3 nor	 = tex2D(A26::NorSam, texcoord).rgb;
float3 CC	  = tex2D(ReShade::BackBuffer, texcoord).rgb;
float  CD	  = ReShade::GetLinearizedDepth(texcoord);
float4 PF	  = tex2D(A26::PreFrm, texcoord + mVec);
float  PD	  = tex2D(A26::PreLumin, texcoord + mVec).r;
#line 1164
float  DeGhostMask = 1.0 - saturate(pow(abs(PD / CD), 12.0) + 0.02);
CF = lerp(PF.rgba, CF, (1.0 - FRAME_PERSIST));
CF = NbrClamp(A26::UpSam, texcoord, CF, DeGhostMask);
return float4(CF);
}
#line 1170
float4 DualFrame(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float4 CF	  = tex2D(A26::CurFrm, texcoord);
float2 mVec	= tex2D(motionSam, texcoord).xy;
float3 nor	 = tex2D(A26::NorSam, texcoord).rgb;
float3 CC	  = tex2D(ReShade::BackBuffer, texcoord).rgb;
float  CD	  = ReShade::GetLinearizedDepth(texcoord);
float4 PF	  = tex2D(A26::PreFrm, texcoord + mVec);
float  PD	  = tex2D(A26::PreLumin, texcoord + 1.0 * mVec).r;
#line 1180
float  DeGhostMask = 1.0 - saturate(pow(abs(PD / CD), 12.0) + 0.02);
if(DEBUG == 6) {return DeGhostMask;}
CF = lerp(PF.rgba, CF, (1.0 - FRAME_PERSIST));
CF = NbrClamp(A26::CurFrm, texcoord, CF, DeGhostMask);
return float4(CF);
}
#line 1187
float DrawDepth(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
return ReShade::GetLinearizedDepth(texcoord);
}
#line 1192
float DrawLum(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 c   = tex2D(ReShade::BackBuffer, texcoord).rgb;
return saturate(c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722);
}
#line 1198
float4 PreviousFrame(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
#line 1201
return tex2D(A26::CurFrm, texcoord);
}
#line 1212
float3 DAMPRT(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 input = tex2D(ReShade::BackBuffer, texcoord).rgb;
input = saturate(input);
float4 GI;
if(DONT_DENOISE) GI	= saturate(tex2Dlod(A26::UpSam, float4(texcoord, 0, 0)));
else 			GI	= tex2Dlod(A26::DualFrm, float4(texcoord, 0, 0));
float			depth = ReShade::GetLinearizedDepth(texcoord);
if(depth > 0.99) return input;
GI = 1.1 * -GI / (GI - 1.1);
#line 1223
input = BlendGI(input, GI, depth, texcoord);
float3 AmbientFog = pow(SKY_COLOR, 2.2) / exp(pow(15.0 * depth * DEPTH_MASK, 2.0));
input = tonemap(input * (1.0 + 5.0 * AmbientFog));
#line 1227
if(DEBUG == 6) {input = GI.rgb;}
else if(DEBUG == 7) {input = tex2D(A26::NorSam, texcoord).rgb;}
else if(DEBUG == 8) {input = tex2D(A26::DepSam, texcoord).r;}
else if(DEBUG == 9) {input = tex2D(A26::LumSam, texcoord).rgb;}
return input;
}
#line 1234
technique ZN_DAMPRT_A26 <
ui_label = "DAMP RT A26-3-1";
ui_tooltip ="Zentient DAMP RT - by Zenteon\n"
"The sucessor to SDIL, a much more efficient and accurate GI approximation";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = LightMap;
RenderTarget = A26::LumTex;
}
#line 1247
pass
{
VertexShader = PostProcessVS;
PixelShader = DrawDepth;
RenderTarget = A26::BufTex;
}
#line 1254
pass
{
VertexShader = PostProcessVS;
PixelShader = NormalBuffer;
RenderTarget = A26::NorInTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = NormalSmooth;
RenderTarget = A26::NorTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = NormalDiv;
RenderTarget = A26::NorDivTex;
}
#line 1273
pass
{
VertexShader = PostProcessVS;
PixelShader = NormalDiv;
RenderTarget = A26::BilaTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = RawGI;
RenderTarget = A26::GITex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = UpFrame;
RenderTarget = A26::UpscaleTex;
}
#line 1292
pass
{
VertexShader = PostProcessVS;
PixelShader = CurrentFrame;
RenderTarget = A26::CurTex;
}
#line 1299
pass
{
VertexShader = PostProcessVS;
PixelShader = DualFrame;
RenderTarget = A26::DualTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = DrawDepth;
RenderTarget = A26::PreLuminTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = DAMPRT;
}
#line 1317
pass
{
VertexShader = PostProcessVS;
PixelShader = PreviousFrame;
RenderTarget = A26::PreTex;
}
#line 1324
}

