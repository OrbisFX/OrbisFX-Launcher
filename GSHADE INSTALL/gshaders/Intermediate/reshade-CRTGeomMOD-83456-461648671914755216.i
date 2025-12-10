#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\CRTGeomMOD.fx"
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
#line 2 "C:\Program Files\GShade\gshade-shaders\Shaders\CRTGeomMOD.fx"
#line 47
uniform int2 inp_video_size <
ui_type = "input";
#line 52
ui_label = "Input Image Resolution X/Y (pixels)";
ui_tooltip = "This is the resolution of the image in the screen frame buffer (0 = auto/fullscreen)";
> = int2(0, 0);
#line 56
uniform int resize_method <
ui_type = "combo";
ui_items = " Simple Rezize From Top-Left Corner \0 32:9 Locked From Center \0 21:9 Locked From Center \0 16:9 Locked From Center \0 15:9 Locked From Center \0 16:10 Locked From Center \0 4:3 Locked From Center \0 5:4 Locked From Center \0 1:1 Locked From Center \0 4:5 Locked From Center \0 3:4 Locked From Center \0";
ui_label = "Resize Method Used By The Game";
ui_tooltip = "Select how the game is resized depending of the display resolution (Simple Resize matches most old games / Ratio locked from center will match most recent games)";
> = 0;
#line 63
uniform bool ROTATED <
ui_label = "ROTATE";
ui_tooltip = "To rotate the display (90° CCW)";
> = false;
#line 68
uniform int inp_screen_ratio <
ui_type = "combo";
ui_items = " Auto Detection \0 32:9 Screen \0 21:9 Screen \0 16:9 Screen \0 15:9 Screen \0 16:10 Screen \0 4:3 Screen \0 5:4 Screen \0 1:1 Screen \0 4:5 Screen \0 3:4 Screen \0";
ui_label = "Simulated Screen Ratio";
> = 0;
#line 74
uniform int inp_game_ratio <
ui_type = "combo";
ui_items = " Auto Detection \0 32:9 Display \0 21:9 Display \0 16:9 Display \0 15:9 Display \0 16:10 Display \0 4:3 Display \0 5:4 Display \0 1:1 Display \0 4:5 Display \0 3:4 Display \0";
ui_label = "Simulated Game Ratio";
> = 0;
#line 80
uniform float2 aspect_ratio <
ui_type = "slider";
ui_min = 0.1f;
ui_max = 4.0f;
ui_step = 0.01f;
ui_label = "Manual Aspect Ratio Adjustement X/Y";
> = float2(1.0, 1.0);
#line 88
uniform bool USE_BACKGROUND <
ui_label = "BACKGROUND";
ui_tooltip = "To display a full image behind the display (full screen size)";
> = false;
#line 93
uniform bool USE_OFF_BEZEL <
ui_label = "OFF BEZEL";
ui_tooltip = "Show an alternate bezel when CRT effect is not activated";
> = false;
#line 98
uniform float2 arts_aspect_ratio <
ui_type = "slider";
ui_min = 0.1f;
ui_max = 4.0f;
ui_step = 0.01f;
ui_label = "Art Ratio Adjustement X/Y";
ui_category = "Arts Advanced Settings";
ui_category_closed = true;
> = float2(1.0, 1.0);
#line 108
uniform float3 bg_col <
ui_type = "color";
ui_label = "Background Color";
ui_tooltip = "The color the background outside of the display (full screen size)";
ui_category = "Arts Advanced Settings";
> = float3(0.0, 0.0, 0.0);
#line 115
uniform bool CRT_EFFECT <
ui_label = "CRT EFFECT";
ui_tooltip = "To enable or not the CRT effect";
> = true;
#line 120
uniform float2 texture_size <
ui_type = "inp";
#line 125
ui_label = "Simulated Texture Resolution X/Y (pixels)";
ui_tooltip = "This is the native resolution of the game used to build the scanline effect (0.0 = auto/default)";
> = float2(0.0, 0.0);
#line 129
uniform float2 buffer_offset <
ui_type = "slider";
ui_min = -5.0f;
ui_max = 5.0f;
ui_step = 0.1f;
ui_label = "Offset Against The Buffer X/Y (pixels)";
ui_tooltip = "Allows to set a small offset needed sometime to be perfectly centered on the texture";
ui_category = "Texture Advanced Settings";
ui_category_closed = true;
> = float2(0.0, 0.0);
#line 140
uniform bool CURVATURE <
ui_label = "CURVATURE";
ui_tooltip = "To enable or not the screen curvature";
> = true;
#line 145
uniform bool VERTICAL_SCANLINES <
ui_label = "VERTICAL SCANLINES";
ui_tooltip = "To get a vertical scanlines without rotating the display";
> = false;
#line 150
uniform int aperture_type <
ui_type = "combo";
ui_items = " Simulated Aperture (Green/Magenta) \0 Dot-Mask Texture 1x1 \0 Dot-Mask Texture 2x2 \0";
ui_label = "Aperture Mask Type";
> = 0;
#line 156
uniform float dotmask <
ui_type = "slider";
ui_min = 0.1f;
ui_max = 0.9f;
ui_step = 0.01f;
ui_label = "Dot-Mask Strength";
ui_category = "CRT Advanced Settings";
ui_category_closed = true;
> = 0.30f;
#line 177
uniform float sharper <
ui_type = "slider";
ui_min = 1.0f;
ui_max = 4.0f;
ui_step = 0.1f;
ui_label = "Sharpness";
ui_category = "CRT Advanced Settings";
> = 2.0f;
#line 186
uniform bool OVERSAMPLE <
ui_label = "OVERSAMPLE";
ui_tooltip = "Enable 3x oversampling of the beam profile (improves moire effect caused by scanlines + curvature)";
ui_category = "CRT Advanced Settings";
> = true;
#line 192
uniform float ovs_boost <
ui_type = "slider";
ui_min = 1.0f;
ui_max = 3.0f;
ui_step = 0.01f;
ui_label = "Oversample Booster";
ui_tooltip = "Attempts to reduce even more the moire effect but kills the pixel aspect";
ui_category = "CRT Advanced Settings";
> = 1.0f;
#line 202
uniform float lum <
ui_type = "slider";
ui_min = 0.01f;
ui_max = 1.0f;
ui_step = 0.01f;
ui_label = "Luminance Boost";
ui_category = "CRT Advanced Settings";
> = 0.8f;
#line 211
uniform float CRTgamma <
ui_type = "slider";
ui_min  = 0.1f;
ui_max = 5.0f;
ui_step = 0.01f;
ui_label = "Target Gamma";
ui_category = "CRT Advanced Settings";
> = 2.4f;
#line 220
uniform float monitorgamma <
ui_type = "slider";
ui_min = 0.1f;
ui_max = 5.0f;
ui_step = 0.01f;
ui_label = "Monitor Gamma";
ui_category = "CRT Advanced Settings";
> = 2.2f;
#line 229
uniform float R <
ui_type = "slider";
ui_min = 0.0f;
ui_max = 10.0f;
ui_step = 0.1f;
ui_label = "Curvature Radius";
ui_category = "CRT Advanced Settings";
> = 2.9f;
#line 238
uniform float d <
ui_type = "slider";
ui_min = 0.1f;
ui_max = 3.0f;
ui_step = 0.1f;
ui_label =  "Distance";
ui_category = "CRT Advanced Settings";
> = 2.7f;
#line 247
uniform float2 tilt <
ui_type = "slider";
ui_min = -0.5f;
ui_max = 0.5f;
ui_step = 0.01f;
ui_label = "Tilt X/Y";
ui_category = "CRT Advanced Settings";
> = float2(0.0, 0.0);
#line 256
uniform float cornersize <
ui_type = "slider";
ui_min = 0.0f;
ui_max = 0.1f;
ui_step = 0.001f;
ui_label = "Corner Size";
ui_category = "CRT Advanced Settings";
> = 0.01f;
#line 265
uniform float cornersmooth <
ui_type = "slider";
ui_min = 10.0f;
ui_max = 300.0f;
ui_step = 10.0f;
ui_label = "Corner Smoothness";
ui_category = "CRT Advanced Settings";
> = 120.0f;
#line 274
uniform bool BLOOM <
ui_label = "BLOOM";
ui_tooltip = "To Enable Bloom Effect";
> = true;
#line 279
uniform float BloomBlurOffset <
ui_type = "slider";
ui_min = 1.0f;
ui_max = 2.0f;
ui_step = 0.01f;
ui_label = "Bloom Blur Offset";
ui_tooltip = "Additional adjustment for the blur radius. Values less than 1.00 will reduce the radius.";
ui_category = "Bloom Advanced Settings";
ui_category_closed = true;
> = 1.6f;
#line 290
uniform float BloomStrength <
ui_type = "slider";
ui_min = 0.0f;
ui_max = 1.0f;
ui_step = 0.01f;
ui_label = "Bloom Strength";
ui_tooltip = "Adjusts the strength of the effect.";
ui_category = "Bloom Advanced Settings";
> = 0.16f;
#line 300
uniform float BloomContrast <
ui_type = "slider";
ui_min = 0.00;
ui_max = 1.00;
ui_step = 0.01f;
ui_label = "Bloom Contrast";
ui_tooltip = "Adjusts the contrast of the effect.";
ui_category = "Bloom Advanced Settings";
> = 0.66f;
#line 310
uniform bool USE_BEZEL <
ui_label = "BEZEL";
ui_tooltip = "To add a global bezel/overlay (full screen size)";
> = false;
#line 315
uniform bool USE_FRAME <
ui_label = "SCREEN FRAME";
ui_tooltip = "To add a screen frame overlay over the display (display size)";
> = false;
#line 320
uniform bool USE_OVERLAY <
ui_label = "SCREEN OVERLAY";
ui_tooltip = "To add a screen overlay over the display area (display size)";
> = false;
#line 325
uniform float2 h_starts <
ui_type = "slider";
ui_min = 0.0f;
ui_max = 100.0f;
ui_step = 0.05f;
ui_label = "Horizontal Effect START/END (%)";
ui_category = "Zoom & Crop Advanced Settings";
ui_category_closed = true;
> = float2(0.0, 100.0);
#line 335
uniform float2 v_starts <
ui_type = "slider";
ui_min = 0.0f;
ui_max = 100.0f;
ui_step = 0.05f;
ui_label = "Vertical Effect START/END (%)";
ui_category = "Zoom & Crop Advanced Settings";
> = float2(0.0, 100.0);
#line 344
uniform float2 overscan <
ui_type = "slider";
ui_min = 0.1f;
ui_max = 200.0f;
ui_step = 0.1f;
ui_label = "Overscan X/Y (%)";
ui_category = "Zoom & Crop Advanced Settings";
ui_spacing = 1;
> = float2(100.0, 100.0);
#line 354
uniform float2 src_offsets <
ui_type = "slider";
ui_min = -100.0f;
ui_max = 100.0f;
ui_step = 0.05f;
ui_label = "Source Offset X/Y (%)";
ui_category = "Zoom & Crop Advanced Settings";
> = float2(0.0, 0.0);
#line 363
uniform bool PASS_THROUGH_BORDERS <
ui_label = "PASS THROUGH BORDERS";
ui_tooltip = "To display original graphics outside of the effect area";
ui_category = "Zoom & Crop Advanced Settings";
> = false;
#line 369
uniform float2 ext_zoom <
ui_type = "slider";
ui_min = 0.1f;
ui_max = 200.0f;
ui_step = 0.1f;
ui_label = "External Zoom X/Y (%)";
ui_category = "Zoom & Crop Advanced Settings";
> = float2(100.0, 100.0);
#line 378
uniform float2 ext_offsets <
ui_type = "slider";
ui_min = -100.0f;
ui_max = 100.0f;
ui_step = 0.05f;
ui_label = "External Offset X/Y (%)";
ui_category = "Zoom & Crop Advanced Settings";
> = float2(0.0, 0.0);
#line 387
uniform bool ACTIVATION_PIXEL_TEST <
ui_label = "Enable Pixel Test";
ui_tooltip = "To get the effect only when the 2 pixels tested match their colors (positions should be defined in backbuffer with a resolution of 1920x1080)";
ui_category = "Pixel Test Advanced Settings";
ui_category_closed = true;
> = false;
#line 394
uniform float test_epsilon <
ui_type = "slider";
ui_min = 0.0f;
ui_max = 1.0f;
ui_step = 0.001f;
ui_label = "Epsilon (sensitivity)";
ui_category = "Pixel Test Advanced Settings";
> = 0.01f;
#line 403
uniform int2 test_pixel <
ui_type = "input";
ui_label = "1st Pixel Coordinates X/Y";
ui_category = "Pixel Test Advanced Settings";
ui_spacing = 1;
> = int2(0, 0);
#line 410
uniform float3 test_color <
ui_type = "color";
ui_label = "1st Pixel Color (RGB)";
ui_category = "Pixel Test Advanced Settings";
> = float3(0.0, 0.0, 0.0);
#line 416
uniform int2 test_pixel2 <
ui_type = "input";
ui_label = "2nd Pixel Coordinates X/Y";
ui_category = "Pixel Test Advanced Settings";
ui_spacing = 1;
> = int2(0, 0);
#line 423
uniform float3 test_color2 <
ui_type = "color";
ui_label = "2nd Pixel Color (RGB)";
ui_category = "Pixel Test Advanced Settings";
> = float3(0.0, 0.0, 0.0);
#line 430
texture background_texture <source="background.png";> { Width = 1920; Height = 1018; Format = RGBA8; };
sampler background_sampler { Texture = background_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };
#line 433
texture bezel_texture <source="bezel.png";> { Width = 1920; Height = 1018; Format = RGBA8; };
sampler bezel_sampler { Texture = bezel_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };
#line 436
texture bezel_off_texture <source="bezel_off.png";> { Width = 1920; Height = 1018; Format = RGBA8; };
sampler bezel_off_sampler { Texture = bezel_off_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };
#line 439
texture frame_texture <source="frame.png";> { Width = 1920; Height = 1018; Format = RGBA8; };
sampler frame_sampler { Texture = frame_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };
#line 442
texture overlay_texture <source="overlay.png";> { Width = 1920; Height = 1018; Format = RGBA8; };
sampler overlay_sampler { Texture = overlay_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };
#line 445
texture mask_texture <source="mask.png";> { Width = 1920 / 2; Height = 1920 / 2; Format = RGBA8; };
sampler mask_sampler { Texture = mask_texture; AddressU = WRAP; AddressV = WRAP; AddressW = WRAP;
MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR; MinLOD = 0.0f; };
#line 449
texture mask2x2_texture <source="mask2x2.png";> { Width = 1920 / 2; Height = 1920 / 2; Format = RGBA8; };
sampler mask2x2_sampler { Texture = mask2x2_texture; AddressU = WRAP; AddressV = WRAP; AddressW = WRAP;
MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR; MinLOD = 0.0f; };
#line 453
texture PixelTestTex { Width = 1; Height = 1; Format = RGBA8; };
sampler PixelTestSampler { Texture = PixelTestTex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
#line 456
texture BloomBlurTex { Width = 1920 / 2; Height = 1018 / 2; Format = RGBA8; };
sampler BloomBlurSampler { Texture = BloomBlurTex; };
#line 459
texture BloomBlurTex2 { Width = 1920 / 2; Height = 1018 / 2; Format = RGBA8; };
sampler BloomBlurSampler2 { Texture = BloomBlurTex2; };
#line 470
static const float arts_ratio = 16.0f / 9.0f;	
#line 472
float StretchRatio()
{
float stretch_ratio = float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y;
#line 476
switch (resize_method)
{
case 1:
stretch_ratio = 32.0f / 9.0f;
break;
case 2:
stretch_ratio = 2560.0f / 1080.0f;	
break;
case 3:
stretch_ratio = 16.0f / 9.0f;
break;
case 4:
stretch_ratio = 15.0f / 9.0f;
break;
case 5:
stretch_ratio = 1.60f;
break;
case 6:
stretch_ratio = 4.0f / 3.0f;
break;
case 7:
stretch_ratio = 1.25f;
break;
case 8:
stretch_ratio = 1.00f;
break;
case 9:
stretch_ratio = 0.80f;
break;
case 10:
stretch_ratio = 0.75f;
break;
}
return stretch_ratio;
}
#line 513
float2 VideoSize()
{
const float stretch_ratio = StretchRatio();
float2 video_size = inp_video_size;
#line 519
if ((inp_video_size.x == 0) && (inp_video_size.y == 0))	
{
if (float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y <= stretch_ratio)
video_size = float2(float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x, float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x / stretch_ratio);
else
video_size = float2(stretch_ratio * float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y, float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y);
}
else
{
if (inp_video_size.x == 0)
video_size.x = stretch_ratio * video_size.y;
if (inp_video_size.y == 0)
video_size.y = video_size.x / stretch_ratio;
}
return video_size;
}
#line 537
float ScreenRatio()
{
switch (inp_screen_ratio)
{
case 0:
return float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y;
case 1:
return 32.0f / 9.0f;
case 2:
return 2560.0f / 1080.0f;	
case 3:
return 16.0f / 9.0f;
case 4:
return 15.0f / 9.0f;
case 5:
return 1.60f;
case 6:
return 4.0f / 3.0f;
case 7:
return 1.25f;
case 8:
return 1.00f;
case 9:
return 0.80f;
case 10:
return 0.75f;
default:
return float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y;
}
}
#line 569
float GameRatio()
{
const float2 video_size = VideoSize();
#line 573
switch (inp_game_ratio)
{
case 0:
return video_size.x / video_size.y;
case 1:
return 32.0f / 9.0f;
case 2:
return 2560.0f / 1080.0f;	
case 3:
return 16.0f / 9.0f;
case 4:
return 15.0f / 9.0f;
case 5:
return 1.60f;
case 6:
return 4.0f / 3.0f;
case 7:
return 1.25f;
case 8:
return 1.00f;
case 9:
return 0.80f;
case 10:
return 0.75f;
default:
return video_size.x / video_size.y;
}
}
#line 603
float2 ScaleFactor()
{
return float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y) / VideoSize();
}
#line 609
float2 TextureDim()
{
const float2 video_size = VideoSize();
float2 texture_dim = texture_size;
#line 615
if ((texture_dim.x == 0) && (texture_dim.y == 0))
{
if (resize_method == 0)
texture_dim = float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y) / float2(4.0f, 4.0f);	
else
texture_dim = video_size / float2(4.0f, 4.0f);	
}
else
{
if (texture_dim.x == 0)
texture_dim.x = video_size.x / video_size.y * texture_dim.y;
if (texture_dim.y == 0)
texture_dim.y = texture_dim.x * video_size.y / video_size.x;
}
return texture_dim;
}
#line 633
float2 F_Ratio()
{
const float game_ratio = GameRatio();
const float screen_ratio = ScreenRatio();
#line 638
if (!ROTATED)
{
if (game_ratio <= screen_ratio)
return float2(screen_ratio / game_ratio, 1.0);
else
return float2(1.0, game_ratio / screen_ratio);
}
else
return float2(1.0, screen_ratio * game_ratio);	
}
#line 650
float2 AspRatio()
{
if (!ROTATED)
return float2(aspect_ratio.x, aspect_ratio.y);
else
return float2(aspect_ratio.y, aspect_ratio.x);
}
#line 659
float2 DisplaySize()
{
return float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y) / F_Ratio();
}
#line 665
float2 HStart()
{
const float2 display_size = DisplaySize();
#line 669
return float2(h_starts.x * display_size.x / 100.0f, h_starts.y * display_size.x / 100.0f);
}
#line 673
float2 VStart()
{
const float2 display_size = DisplaySize();
#line 677
return float2(v_starts.x * display_size.y / 100.0f, v_starts.y * display_size.y / 100.0f);
}
#line 681
bool PIXELTESTS()
{
const float2 video_size = VideoSize();
#line 685
float2 offset = float2(0.0, 0.0);
float2 scale = float2(1.0, 1.0);
#line 688
if ((inp_video_size.x == 0) && (inp_video_size.y == 0))	
{
offset = float2((float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x - video_size.x) / 2.0f, (float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y - video_size.y) / 2.0f);
scale = float2(video_size.x / 1920.0f, video_size.y / 1080.0f);
}
#line 694
if (ACTIVATION_PIXEL_TEST)
{
const float3 delta = tex2D(ReShade::BackBuffer, float2(1.0f * (test_pixel.x * scale.x + offset.x) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x, 1.0f * (test_pixel.y * scale.y + offset.y) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y)).rgb - test_color;
const float3 delta2 = tex2D(ReShade::BackBuffer, float2(1.0f * (test_pixel2.x * scale.x + offset.x) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x, 1.0f * (test_pixel2.y * scale.y + offset.y) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y)).rgb - test_color2;
if (test_epsilon < dot(delta, delta) || test_epsilon < dot(delta2, delta2))
return false;
else
return true;
}
else
return true;
}
#line 708
bool PIXELTESTS2()
{
if (ACTIVATION_PIXEL_TEST)
{
if (tex2D(PixelTestSampler, float2(0.5, 0.5)).r < 0.5f)
return false;
else
return true;
}
else
return true;
}
#line 722
float2 ExtUV(float2 uv)
{
const float2 video_size = VideoSize();
const float2 ratio = F_Ratio();
#line 727
float2 ext_uv = uv;
#line 729
if (ROTATED)
ext_uv = float2((1.0f - uv.y), uv.x);
ext_uv = ((ext_uv - (0.5f, 0.5f)) * float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y)  * AspRatio() / (ext_zoom / (100.0f, 100.0f)) + (ext_offsets * DisplaySize() / (100.0f, 100.0f))) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y) + (0.5f, 0.5f);
if (resize_method == 0)
ext_uv = ((ext_uv - (0.5f, 0.5f)) * ratio + (0.5f, 0.5f)) * video_size / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y);
else
ext_uv = ((ext_uv - (0.5f, 0.5f)) * ratio * video_size / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y) + (0.5f, 0.5f));
return ext_uv;
}
#line 740
float2 ArtsUV(float2 uv)
{
return (uv - (0.5f, 0.5f)) * float2(ScreenRatio() / arts_ratio, 1.0) * arts_aspect_ratio + (0.5f, 0.5f);
}
#line 746
float2 BezelUV(float2 uv)
{
const float screen_ratio = ScreenRatio();
const float2 video_size = VideoSize();
const float game_ratio = GameRatio();
float2 bezel_uv = ArtsUV(uv) - (0.5f, 0.5f);
#line 753
if (!ROTATED)
{
if (StretchRatio() <= screen_ratio)
{
if (game_ratio <= screen_ratio)
bezel_uv *= float2((video_size.x / video_size.y) / game_ratio, 1.0);
else
bezel_uv *= float2((video_size.x / video_size.y) / screen_ratio, game_ratio / screen_ratio );
}
else
{
if (screen_ratio <= game_ratio)
bezel_uv *= float2(arts_ratio / screen_ratio, game_ratio / (video_size.x / video_size.y) * arts_ratio / screen_ratio);
else
bezel_uv *= float2(arts_ratio / game_ratio, screen_ratio / (video_size.x / video_size.y) * arts_ratio / screen_ratio);
}
}
else
bezel_uv *= float2(game_ratio / (video_size.x / video_size.y), 1.0);
return bezel_uv + (0.5f, 0.5f);
}
#line 776
bool4 OUTS(float2 uv)
{
const float stretch_ratio = StretchRatio();
const float2 asp_ratio = AspRatio();
const float2 display_size = DisplaySize();
#line 782
const float2 offset_ar = (float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y) - display_size / asp_ratio) / (2.0f, 2.0f);
float2 offset0_ar = offset_ar;
const float2 h_start_ar = HStart() / float2(asp_ratio.x, asp_ratio.x);
const float2 v_start_ar = VStart() / float2(asp_ratio.y, asp_ratio.y);
#line 787
bool OUT_DISPLAY = false;
bool OUT_STARTS = false;
bool OUT_DISPLAY_R = false;
bool OUT_STARTS_R = false;
#line 792
if (resize_method != 0)
{
if (stretch_ratio < float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y)
offset0_ar = (float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y) - display_size * float2((float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y) / stretch_ratio, 1.0) / asp_ratio) / (2.0f, 2.0f);
else
offset0_ar = (float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y) - display_size * float2(1.0, stretch_ratio / (float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y)) / asp_ratio) / (2.0f, 2.0f);
}
if (!ROTATED)
{
OUT_DISPLAY = true;
OUT_STARTS = true;
if ((offset0_ar.y / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y < uv.y) && (uv.y < (float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y - offset0_ar.y) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y))
{
if ((offset0_ar.x / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x < uv.x) && (uv.x < (float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x - offset0_ar.x) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x))
{
OUT_DISPLAY = false;
if (((offset_ar.y + v_start_ar.x) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y < uv.y) && (uv.y < (offset_ar.y + v_start_ar.y) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y))
{
if (((offset_ar.x + h_start_ar.x) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x < uv.x) && (uv.x < (offset_ar.x + h_start_ar.y) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x))
OUT_STARTS = false;
}
}
}
}
else	
{
OUT_DISPLAY_R = true;
OUT_STARTS_R = true;
if ((offset0_ar.x / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x < (1.0f - uv.y)) && ((1.0f - uv.y) < (float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x - offset0_ar.x) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x))
{
if ((offset0_ar.y / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y < uv.x) && (uv.x < (float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y - offset0_ar.y) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y))
{
OUT_DISPLAY_R = false;
if (((offset_ar.x + h_start_ar.x) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x < (1.0f - uv.y)) && ((1.0f - uv.y) < (offset_ar.x + h_start_ar.y) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x))
{
if (((offset_ar.y + v_start_ar.x) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y < uv.x) && (uv.x < (offset_ar.y + v_start_ar.y) / float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y))
OUT_STARTS_R = false;
}
}
}
}
return bool4(OUT_DISPLAY, OUT_DISPLAY_R, OUT_STARTS, OUT_STARTS_R);
}
#line 837
float2 DimUV(float2 uv)
{
const float2 h_start = HStart();
const float2 v_start = VStart();
#line 842
const float2 offset = (float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y) - DisplaySize()) / (2.0f, 2.0f);
#line 844
if (ROTATED)
uv = float2((1.0f - uv.y), uv.x);
uv = (uv - (0.5f, 0.5f)) * AspRatio() + (0.5f, 0.5f);
uv.x = (uv.x * float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).x - h_start.x - offset.x) / (h_start.y - h_start.x);
uv.y = (uv.y * float2(ReShade::GetScreenSize().x, ReShade::GetScreenSize().y).y - v_start.x - offset.y) / (v_start.y - v_start.x);
return uv;
}
#line 853
float2 DimXY(float2 xy)
{
const float2 h_start = HStart();
const float2 v_start = VStart();
const float2 display_size = DisplaySize();
#line 859
const float2 src_offset = src_offsets * display_size / (100.0f, 100.0f);
#line 861
xy = (xy - (0.5f, 0.5f)) / (overscan / (100.0f, 100.0f)) + (0.5f, 0.5f);	
xy.x = (xy.x * (h_start.y - h_start.x) + h_start.x + src_offset.x) / display_size.x;
xy.y = (xy.y * (v_start.y - v_start.x) + v_start.x + src_offset.y) / display_size.y;
return xy;
}
#line 868
float2 Asp()
{
return float2(1.0, 1.0f / GameRatio());
}
#line 874
float fmod(float a, float b)
{
const float c = frac(abs(a / b)) * abs(b);
#line 878
if (a < 0)
return -c;
else
return c;
}
#line 885
float intersect(float2 xy, float2 sinangle, float2 cosangle)
{
const float A = dot(xy, xy) + d * d;
const float B = 2.0f * (R * (dot(xy, sinangle) - d * cosangle.x * cosangle.y) - d * d);
return (-B - sqrt(B * B - 4.0f * A * (d * d + 2.0f * R * d * cosangle.x * cosangle.y))) / (2.0f * A);
}
#line 893
float2 bkwtrans(float2 xy, float2 sinangle, float2 cosangle)
{
const float c = intersect(xy, sinangle, cosangle);
float2 pnt = float2(c, c) * xy;
pnt -= float2(-R, -R) * sinangle;
pnt /= float2(R, R);
const float2 tang = sinangle / cosangle;
const float2 poc = pnt / cosangle;
const float A = dot(tang, tang) + 1.0f;
const float B = -2.0f * dot(poc, tang);
const float a = (-B + sqrt(B * B - 4.0f * A * (dot(poc, poc) - 1.0f))) / (2.0f * A);
const float r = max(abs(R * acos(a)), 1e-5);;
return ((pnt - a * sinangle) / cosangle) * r / sin(r / R);
}
#line 909
float2 fwtrans(float2 uv, float2 sinangle, float2 cosangle)
{
const float r = max(abs(sqrt(dot(uv, uv))), 1e-5);;
uv *= sin(r / R) / r;
const float x = 1.0f - cos(r / R);
return d * (uv * cosangle-x * sinangle) / (d / R + x * cosangle.x * cosangle.y + dot(uv, sinangle));
}
#line 918
float3 maxscale(float2 sinangle, float2 cosangle)
{
const float2 aspect = Asp();
#line 922
const float2 c = bkwtrans(-R * sinangle / (1.0 + R / d * cosangle.x * cosangle.y), sinangle, cosangle);
const float2 a = float2(0.5,0.5) * aspect;
const float2 lo = float2(fwtrans(float2(-a.x, c.y), sinangle, cosangle).x,
fwtrans(float2(c.x, -a.y), sinangle, cosangle).y) / aspect;
const float2 hi = float2(fwtrans(float2(+a.x, c.y), sinangle, cosangle).x,
fwtrans(float2(c.x, +a.y), sinangle, cosangle).y) / aspect;
return float3((hi + lo) * aspect * 0.5f, max(hi.x - lo.x, hi.y - lo.y));
}
#line 932
float2 curv(float2 xy)
{
const float2 aspect = Asp();
#line 936
const float2 sinangle = sin(float2(tilt.x, tilt.y));
const float2 cosangle = cos(float2(tilt.x, tilt.y));
const float3 stretch = maxscale(sinangle, cosangle);
#line 940
xy = (xy - (0.5f, 0.5f)) * aspect * stretch.z + stretch.xy;
return bkwtrans(xy, sinangle, cosangle) / aspect + (0.5f, 0.5f);
}
#line 945
float corner(float2 xy)
{
xy = min(xy, (1.0f, 1.0f) - xy) * Asp();
const float2 cdist = float2(cornersize, cornersize);
xy = (cdist - min(xy, cdist));
return clamp((cdist.x - sqrt(dot(xy, xy))) * cornersmooth, 0.0f, 1.0f);
}
#line 954
float4 scanlineWeights(float distance, float4 color)
{
#line 968
const float4 wid = 0.3f + 0.1f * pow(abs(color), float4(3.0, 3.0, 3.0, 3.0));
const float4 weights = distance / wid;
return (lum - 0.3f) * exp(-weights * weights) / wid;
#line 976
}
#line 979
float4 PS_CRTGeomMod(float4 vpos : SV_Position, float2 uv : TexCoord) : SV_Target
{
const float2 video_size = VideoSize();
const float2 scale_factor = ScaleFactor();
const float2 texture_dim = TextureDim();
bool4 OUT_BOOLS = OUTS(uv);
bool OUT_DISPLAY = OUT_BOOLS.x;
bool OUT_DISPLAY_R = OUT_BOOLS.y;
bool OUT_STARTS = OUT_BOOLS.z;
bool OUT_STARTS_R = OUT_BOOLS.w;
bool PIXEL_TESTS = PIXELTESTS2();
#line 991
const float2 ext_uv = ExtUV(uv);
#line 994
float4 background = float4(bg_col, 1.0);
if (USE_BACKGROUND)
{
const float4 imageBackground = tex2D(background_sampler, ArtsUV(uv));
background.rgb = lerp(background.rgb, imageBackground.rgb, imageBackground.a);
}
#line 1001
if (OUT_DISPLAY || OUT_DISPLAY_R)
{
return background;
}
if (OUT_STARTS || OUT_STARTS_R)
{
if (PASS_THROUGH_BORDERS)
{
return tex2D(ReShade::BackBuffer, ext_uv);
}
else
{
return background;
}
}
#line 1018
if (!CRT_EFFECT || !PIXEL_TESTS)	
{
return tex2D(ReShade::BackBuffer, ext_uv);
}
else	
{
float2 sc_texture_size = texture_dim * scale_factor;
if (!VERTICAL_SCANLINES)
sc_texture_size *= float2(sharper, 1.0);
else
sc_texture_size *= float2(1.0, sharper);
const float2 one = float2(1.0, 1.0) / sc_texture_size;
#line 1052
uv = DimUV(uv);
#line 1055
float2 xy = uv;
if (CURVATURE)
xy = curv(xy);
const float cval = corner(xy);
xy = DimXY(xy);
#line 1061
const float2 xy0 = xy;
#line 1063
if (resize_method == 0)
xy = xy / scale_factor;
else
xy = ((xy - (0.5f, 0.5f)) / scale_factor + (0.5f, 0.5f));
#line 1070
const float2 ratio_scale = xy * sc_texture_size - (0.5f, 0.5f);
float2 uv_ratio = frac(ratio_scale);
#line 1074
xy = (floor(ratio_scale) + (0.5f, 0.5f)) / sc_texture_size;
xy = xy + buffer_offset / video_size;
#line 1080
float4 coeffs = float4(1.0, 1.0, 1.0, 1.0);
if (!VERTICAL_SCANLINES)
coeffs = 3.1415926535897932 * float4(1.0f + uv_ratio.x, uv_ratio.x, 1.0f - uv_ratio.x, 2.0f - uv_ratio.x);
else
coeffs = 3.1415926535897932 * float4(1.0f + uv_ratio.y, uv_ratio.y, 1.0f - uv_ratio.y, 2.0f - uv_ratio.y);
#line 1087
coeffs = max(abs(coeffs), 1e-5);;
#line 1090
coeffs = 2.0f * sin(coeffs) * sin(coeffs / 2.0f) / (coeffs * coeffs);
#line 1093
coeffs /= dot(coeffs, float4(1.0, 1.0, 1.0, 1.0));
#line 1098
float3 mul_res = float3(cval, cval, cval);
if (!VERTICAL_SCANLINES)
{
const float4 col  = clamp(mul(coeffs, float4x4(
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(-one.x, 0.0)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(one.x, 0.0)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(2.0f * one.x, 0.0)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)))),
0.0f, 1.0f);
#line 1108
const float4 col2 = clamp(mul(coeffs, float4x4(
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(-one.x, one.y)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(0.0, one.y)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy + one))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(2.0f * one.x, one.y)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)))),
0.0f, 1.0f);
#line 1117
float4 weights  = scanlineWeights(uv_ratio.y, col);
float4 weights2 = scanlineWeights(1.0f - uv_ratio.y, col2);
#line 1120
if (OVERSAMPLE)
{
const float filter = texture_dim.y / video_size.y;
uv_ratio.y = uv_ratio.y + ovs_boost * 1.0f / 3.0f * filter;
weights  = (weights  + scanlineWeights(uv_ratio.y, col)) / 3.0f;
weights2 = (weights2 + scanlineWeights(abs(1.0f - uv_ratio.y), col2)) / 3.0f;
uv_ratio.y = uv_ratio.y - ovs_boost * 2.0f / 3.0f * filter;
weights  = weights  + scanlineWeights(abs(uv_ratio.y), col) / 3.0f;
weights2 = weights2 + scanlineWeights(abs(1.0f - uv_ratio.y), col2) / 3.0f;
}
mul_res *= (col * weights + col2 * weights2).rgb;
}
else	
{
const float4 col  = clamp(mul(coeffs, float4x4(
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(0.0, -one.y)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(0.0, one.y)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(0.0, 2.0f * one.y)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)))),
0.0f, 1.0f);
#line 1141
const float4 col2 = clamp(mul(coeffs, float4x4(
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(one.x, -one.y)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(one.x, 0.0)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy + one))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)),
pow(abs(tex2D(ReShade::BackBuffer, (xy + float2(one.x, 2.0f * one.y)))), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma)))),
0.0f, 1.0f);
#line 1150
float4 weights  = scanlineWeights(uv_ratio.x, col);
float4 weights2 = scanlineWeights(1.0f - uv_ratio.x, col2);
#line 1153
if (OVERSAMPLE)
{
const float filter = texture_dim.x / video_size.x;
uv_ratio.x = uv_ratio.x + ovs_boost * 1.0f / 3.0f * filter;
weights  = (weights  + scanlineWeights(uv_ratio.x, col)) / 3.0f;
weights2 = (weights2 + scanlineWeights(abs(1.0f - uv_ratio.x), col2)) / 3.0f;
uv_ratio.x = uv_ratio.x - ovs_boost * 2.0f / 3.0f * filter;
weights  = weights  + scanlineWeights(abs(uv_ratio.x), col) / 3.0f;
weights2 = weights2 + scanlineWeights(abs(1.0f - uv_ratio.x), col2) / 3.0f;
}
mul_res *= (col * weights + col2 * weights2).rgb;
}
#line 1167
float2 mod_factor = xy0 * texture_dim;
if (VERTICAL_SCANLINES)
mod_factor = float2(mod_factor.y, mod_factor.x);
if (aperture_type == 1 || aperture_type == 2)
{
#line 1173
float3 mask = float3(1.0, 1.0, 1.0);
if (aperture_type == 2)
{
mod_factor *= float2(0.5, 0.5);
mask = tex2D(mask2x2_sampler, mod_factor).rgb;
}
else
mask = tex2D(mask_sampler, mod_factor).rgb;
mul_res *= lerp(float3(1.0, 1.0, 1.0), mask, dotmask * 1.2f);
}
else
{
#line 1186
float val = 1.0f;
val = fmod(2.0f * mod_factor.x + 1.0f, 2.0f) - 1.0f;
val = 2.0f * (abs(val) - 0.5f) + 0.5f;
mul_res *= lerp(float3(1.0, 1.0f - dotmask, 1.0), float3(1.0f - dotmask, 1.0, 1.0f - dotmask), val);
}
#line 1193
mul_res = pow(abs(mul_res), float3(1.0f / monitorgamma, 1.0f / monitorgamma, 1.0f / monitorgamma));
#line 1196
return float4(mul_res, 1.0);
}
}
#line 1201
float3 BloomCommon(sampler source, float4 pos, float2 texcoord, float2 dir)
{
float3 color = tex2D(source, texcoord).rgb;
#line 1205
const float offset[3] = { 0.0, 1.3846153846, 3.2307692308 };
const float weight[3] = { 0.2270270270, 0.3162162162, 0.0702702703 };
#line 1208
color *= weight[0];
#line 1210
[loop]
for(int i = 1; i < 3; ++i)
{
color += tex2Dlod(source, float4(texcoord + offset[i] * dir * BloomBlurOffset, 0.0, 0.0)).rgb * weight[i];
color += tex2Dlod(source, float4(texcoord - offset[i] * dir * BloomBlurOffset, 0.0, 0.0)).rgb * weight[i];
}
#line 1217
return color;
}
#line 1220
float3 PrepareBlur(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
return pow(abs(tex2D(ReShade::BackBuffer, texcoord).rgb), 1.0 / monitorgamma);
}
#line 1225
float3 BloomBlurHorizontal1(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
if (!BLOOM)
{
discard;
}
return BloomCommon(BloomBlurSampler2, pos, texcoord, float2(ReShade::GetPixelSize().x, 0.0));
}
#line 1234
float3 BloomBlurHorizontal2(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
if (!BLOOM)
{
discard;
}
return BloomCommon(BloomBlurSampler, pos, texcoord, 2 * float2(ReShade::GetPixelSize().x, 0.0));
}
#line 1243
float3 BloomBlurVertical1(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
if (!BLOOM)
{
discard;
}
return BloomCommon(BloomBlurSampler2, pos, texcoord, float2(0.0, ReShade::GetPixelSize().y));
}
#line 1252
float3 BloomBlurVertical2(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
if (!BLOOM)
{
discard;
}
return BloomCommon(BloomBlurSampler, pos, texcoord, float2(0.0, ReShade::GetPixelSize().y));
}
#line 1262
float4 PS_CRTGeomModPixelTest(float4 vpos : SV_Position, float2 uv : TexCoord) : SV_Target
{
if (PIXELTESTS())
{
return float4(1.0, 1.0, 1.0, 1.0);
}
else
{
return float4(0.0, 0.0, 0.0, 1.0);
}
}
#line 1275
float4 PS_CRTGeomModFinal(float4 vpos : SV_Position, float2 uv : TexCoord) : SV_Target
{
bool4 OUT_BOOLS = OUTS(uv);
bool OUT_DISPLAY = OUT_BOOLS.x;
bool OUT_DISPLAY_R = OUT_BOOLS.y;
bool OUT_STARTS = OUT_BOOLS.z;
bool OUT_STARTS_R = OUT_BOOLS.w;
#line 1283
bool PIXEL_TESTS = PIXELTESTS2();
const float2 bezel_uv = BezelUV(uv);
const float2 dim_uv = DimUV(uv);
#line 1287
float4 screen_col = tex2D(ReShade::BackBuffer, uv);
if (!CRT_EFFECT || !PIXEL_TESTS)	
{
if (USE_OFF_BEZEL)
{
const float4 bezel_off = tex2D(bezel_off_sampler, bezel_uv);
screen_col.rgb = lerp(screen_col.rgb, bezel_off.rgb, bezel_off.a);
}
return screen_col;
}
else	
{
if (OUT_DISPLAY || OUT_DISPLAY_R || OUT_STARTS || OUT_STARTS_R)
{
if (USE_BEZEL)
{
const float4 bezel = tex2D(bezel_sampler, bezel_uv);
screen_col.rgb = lerp(screen_col.rgb, bezel.rgb, bezel.a);
}
return screen_col;
}
#line 1309
if (BLOOM)
{
screen_col += pow(abs(tex2D(BloomBlurSampler2, uv) * monitorgamma * BloomContrast), BloomContrast) * BloomStrength;
}
#line 1314
if (USE_OVERLAY)
{
const float4 overlay = tex2D(overlay_sampler, dim_uv);
screen_col.rgb = lerp(screen_col.rgb,overlay.rgb, overlay.a);
}
#line 1320
if (USE_FRAME)
{
const float4 frame = tex2D(frame_sampler, dim_uv);
screen_col.rgb = lerp(screen_col.rgb, frame.rgb, frame.a);
}
#line 1326
if (USE_BEZEL)	
{
const float4 bezel = tex2D(bezel_sampler, bezel_uv);
screen_col.rgb = lerp(screen_col.rgb, bezel.rgb, bezel.a);
}
#line 1336
return float4(screen_col.rgb, 1.0);
#line 1338
}
}
#line 1342
technique GeomModCRT
{
pass PixelTest
{
VertexShader = PostProcessVS;
PixelShader = PS_CRTGeomModPixelTest;
RenderTarget = PixelTestTex;
}
pass CRT_GeomMod
{
VertexShader = PostProcessVS;
PixelShader = PS_CRTGeomMod;
}
pass PrepareForBlur
{
VertexShader = PostProcessVS;
PixelShader = PrepareBlur;
RenderTarget = BloomBlurTex2;
}
pass BlurHorizontal1
{
VertexShader = PostProcessVS;
PixelShader = BloomBlurHorizontal1;
RenderTarget = BloomBlurTex;
}
pass BlurHorizontal2
{
VertexShader = PostProcessVS;
PixelShader = BloomBlurHorizontal2;
RenderTarget = BloomBlurTex2;
}
pass BlurVertical1
{
VertexShader = PostProcessVS;
PixelShader = BloomBlurVertical1;
RenderTarget = BloomBlurTex;
}
pass BlurVertical2
{
VertexShader = PostProcessVS;
PixelShader = BloomBlurVertical2;
RenderTarget = BloomBlurTex2;
}
pass Finalize
{
VertexShader = PostProcessVS;
PixelShader = PS_CRTGeomModFinal;
}
}

