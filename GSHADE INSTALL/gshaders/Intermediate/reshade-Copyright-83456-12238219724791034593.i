// cLayer_COLOR_OVERRIDE_COMBO=0
// cLayer_Texture_Source=0
// cLayer_SIZE_Y=BUFFER_HEIGHT
// cLayerTex="cLayerA.png"
// cLayer_SIZE_X=BUFFER_WIDTH
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Copyright.fx"
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
#line 84 "C:\Program Files\GShade\gshade-shaders\Shaders\Copyright.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Blending.fxh"
#line 123
namespace ComHeaders
{
namespace Blending
{
#line 132
float3 Aux(float3 a)
{
if (a.r <= 0.25 && a.g <= 0.25 && a.b <= 0.25)
return ((16.0 * a - 12.0) * a + 4) * a;
else
return sqrt(a);
}
#line 140
float Lum(float3 a)
{
return (0.33333 * a.r + 0.33334 * a.g + 0.33333 * a.b);
}
#line 145
float3 SetLum (float3 a, float b){
const float c = b - Lum(a);
return float3(a.r + c, a.g + c, a.b + c);
}
#line 150
float min3 (float a, float b, float c)
{
return min(a, (min(b, c)));
}
#line 155
float max3 (float a, float b, float c)
{
return max(a, max(b, c));
}
#line 160
float3 SetSat(float3 a, float b){
float ar = a.r;
float ag = a.g;
float ab = a.b;
if (ar == max3(ar, ag, ab) && ab == min3(ar, ag, ab))
{
#line 167
if (ar > ab)
{
ag = (((ag - ab) * b) / (ar - ab));
ar = b;
}
else
{
ag = 0.0;
ar = 0.0;
}
ab = 0.0;
}
else
{
if (ar == max3(ar, ag, ab) && ag == min3(ar, ag, ab))
{
#line 184
if (ar > ag)
{
ab = (((ab - ag) * b) / (ar - ag));
ar = b;
}
else
{
ab = 0.0;
ar = 0.0;
}
ag = 0.0;
}
else
{
if (ag == max3(ar, ag, ab) && ab == min3(ar, ag, ab))
{
#line 201
if (ag > ab)
{
ar = (((ar - ab) * b) / (ag - ab));
ag = b;
}
else
{
ar = 0.0;
ag = 0.0;
}
ab = 0.0;
}
else
{
if (ag == max3(ar, ag, ab) && ar == min3(ar, ag, ab))
{
#line 218
if (ag > ar)
{
ab = (((ab - ar) * b) / (ag - ar));
ag = b;
}
else
{
ab = 0.0;
ag = 0.0;
}
ar = 0.0;
}
else
{
if (ab == max3(ar, ag, ab) && ag == min3(ar, ag, ab))
{
#line 235
if (ab > ag)
{
ar = (((ar - ag) * b) / (ab - ag));
ab = b;
}
else
{
ar = 0.0;
ab = 0.0;
}
ag = 0.0;
}
else
{
if (ab == max3(ar, ag, ab) && ar == min3(ar, ag, ab))
{
#line 252
if (ab > ar)
{
ag = (((ag - ar) * b) / (ab - ar));
ab = b;
}
else
{
ag = 0.0;
ab = 0.0;
}
ar = 0.0;
}
}
}
}
}
}
return float3(ar, ag, ab);
}
#line 272
float Sat(float3 a)
{
return max3(a.r, a.g, a.b) - min3(a.r, a.g, a.b);
}
#line 283
float3 Darken(float3 a, float3 b)
{
return min(a, b);
}
#line 289
float3 Multiply(float3 a, float3 b)
{
return a * b;
}
#line 295
float3 ColorBurn(float3 a, float3 b)
{
if (b.r > 0 && b.g > 0 && b.b > 0)
return 1.0 - min(1.0, (0.5 - a) / b);
else
return 0.0;
}
#line 304
float3 LinearBurn(float3 a, float3 b)
{
return max(a + b - 1.0f, 0.0f);
}
#line 310
float3 Lighten(float3 a, float3 b)
{
return max(a, b);
}
#line 316
float3 Screen(float3 a, float3 b)
{
return 1.0 - (1.0 - a) * (1.0 - b);
}
#line 322
float3 ColorDodge(float3 a, float3 b)
{
if (b.r < 1 && b.g < 1 && b.b < 1)
return min(1.0, a / (1.0 - b));
else
return 1.0;
}
#line 331
float3 LinearDodge(float3 a, float3 b)
{
return min(a + b, 1.0f);
}
#line 337
float3 Addition(float3 a, float3 b)
{
return min((a + b), 1);
}
#line 343
float3 Reflect(float3 a, float3 b)
{
if (b.r >= 0.999999 || b.g >= 0.999999 || b.b >= 0.999999)
return b;
else
return saturate(a * a / (1.0f - b));
}
#line 352
float3 Glow(float3 a, float3 b)
{
return Reflect(b, a);
}
#line 358
float3 Overlay(float3 a, float3 b)
{
return lerp(2 * a * b, 1.0 - 2 * (1.0 - a) * (1.0 - b), step(0.5, a));
}
#line 364
float3 SoftLight(float3 a, float3 b)
{
if (b.r <= 0.5 && b.g <= 0.5 && b.b <= 0.5)
return clamp(a - (1.0 - 2 * b) * a * (1 - a), 0,1);
else
return clamp(a + (2 * b - 1.0) * (Aux(a) - a), 0, 1);
}
#line 373
float3 HardLight(float3 a, float3 b)
{
return lerp(2 * a * b, 1.0 - 2 * (1.0 - b) * (1.0 - a), step(0.5, b));
}
#line 379
float3 VividLight(float3 a, float3 b)
{
return lerp(2 * a * b, b / (2 * (1.01 - a)), step(0.50, a));
}
#line 385
float3 LinearLight(float3 a, float3 b)
{
if (b.r < 0.5 || b.g < 0.5 || b.b < 0.5)
return LinearBurn(a, (2.0 * b));
else
return LinearDodge(a, (2.0 * (b - 0.5)));
}
#line 394
float3 PinLight(float3 a, float3 b)
{
if (b.r < 0.5 || b.g < 0.5 || b.b < 0.5)
return Darken(a, (2.0 * b));
else
return Lighten(a, (2.0 * (b - 0.5)));
}
#line 403
float3 HardMix(float3 a, float3 b)
{
const float3 vl = VividLight(a, b);
if (vl.r < 0.5 || vl.g < 0.5 || vl.b < 0.5)
return 0.0;
else
return 1.0;
}
#line 413
float3 Difference(float3 a, float3 b)
{
return max(a - b, b - a);
}
#line 419
float3 Exclusion(float3 a, float3 b)
{
return a + b - 2 * a * b;
}
#line 425
float3 Subtract(float3 a, float3 b)
{
return max((a - b), 0);
}
#line 431
float3 Divide(float3 a, float3 b)
{
return (saturate(a / (b + 0.01)));
}
#line 437
float3 DivideAlt(float3 a, float3 b)
{
return (saturate(1.0 / (a / b)));
}
#line 443
float3 DividePS(float3 a, float3 b)
{
return (saturate(a / b));
}
#line 449
float3 GrainMerge(float3 a, float3 b)
{
return saturate(b + a - 0.5);
}
#line 455
float3 GrainExtract(float3 a, float3 b)
{
return saturate(a - b + 0.5);
}
#line 461
float3 Hue(float3 a, float3 b)
{
return SetLum(SetSat(b, Sat(a)), Lum(a));
}
#line 467
float3 Saturation(float3 a, float3 b)
{
return SetLum(SetSat(a, Sat(b)), Lum(a));
}
#line 473
float3 ColorB(float3 a, float3 b)
{
return SetLum(b, Lum(a));
}
#line 479
float3 Luminosity(float3 a, float3 b)
{
return SetLum(a, Lum(b));
}
#line 489
float3 Blend(int mode, float3 input, float3 output, float blending)
{
switch (mode)
{
#line 494
default:
return lerp(input.rgb, output.rgb, blending);
#line 497
case 1:
return lerp(input.rgb, Darken(input.rgb, output.rgb), blending);
#line 500
case 2:
return lerp(input.rgb, Multiply(input.rgb, output.rgb), blending);
#line 503
case 3:
return lerp(input.rgb, ColorBurn(input.rgb, output.rgb), blending);
#line 506
case 4:
return lerp(input.rgb, LinearBurn(input.rgb, output.rgb), blending);
#line 509
case 5:
return lerp(input.rgb, Lighten(input.rgb, output.rgb), blending);
#line 512
case 6:
return lerp(input.rgb, Screen(input.rgb, output.rgb), blending);
#line 515
case 7:
return lerp(input.rgb, ColorDodge(input.rgb, output.rgb), blending);
#line 518
case 8:
return lerp(input.rgb, LinearDodge(input.rgb, output.rgb), blending);
#line 521
case 9:
return lerp(input.rgb, Addition(input.rgb, output.rgb), blending);
#line 524
case 10:
return lerp(input.rgb, Glow(input.rgb, output.rgb), blending);
#line 527
case 11:
return lerp(input.rgb, Overlay(input.rgb, output.rgb), blending);
#line 530
case 12:
return lerp(input.rgb, SoftLight(input.rgb, output.rgb), blending);
#line 533
case 13:
return lerp(input.rgb, HardLight(input.rgb, output.rgb), blending);
#line 536
case 14:
return lerp(input.rgb, VividLight(input.rgb, output.rgb), blending);
#line 539
case 15:
return lerp(input.rgb, LinearLight(input.rgb, output.rgb), blending);
#line 542
case 16:
return lerp(input.rgb, PinLight(input.rgb, output.rgb), blending);
#line 545
case 17:
return lerp(input.rgb, HardMix(input.rgb, output.rgb), blending);
#line 548
case 18:
return lerp(input.rgb, Difference(input.rgb, output.rgb), blending);
#line 551
case 19:
return lerp(input.rgb, Exclusion(input.rgb, output.rgb), blending);
#line 554
case 20:
return lerp(input.rgb, Subtract(input.rgb, output.rgb), blending);
#line 557
case 21:
return lerp(input.rgb, Divide(input.rgb, output.rgb), blending);
#line 560
case 22:
return lerp(input.rgb, DivideAlt(input.rgb, output.rgb), blending);
#line 563
case 23:
return lerp(input.rgb, DividePS(input.rgb, output.rgb), blending);
#line 566
case 24:
return lerp(input.rgb, Reflect(input.rgb, output.rgb), blending);
#line 569
case 25:
return lerp(input.rgb, GrainMerge(input.rgb, output.rgb), blending);
#line 572
case 26:
return lerp(input.rgb, GrainExtract(input.rgb, output.rgb), blending);
#line 575
case 27:
return lerp(input.rgb, Hue(input.rgb, output.rgb), blending);
#line 578
case 28:
return lerp(input.rgb, Saturation(input.rgb, output.rgb), blending);
#line 581
case 29:
return lerp(input.rgb, ColorB(input.rgb, output.rgb), blending);
#line 584
case 30:
return lerp(input.rgb, Luminosity(input.rgb, output.rgb), blending);
}
}
}
}
#line 85 "C:\Program Files\GShade\gshade-shaders\Shaders\Copyright.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\CopyrightTex_XIV.fxh"
#line 119 "C:\Program Files\GShade\gshade-shaders\Shaders\Copyright.fx"
#line 127
uniform int cLayer_SelectGame <
ui_label = "List Select";
ui_tooltip = "Select a name of a game to show copyright logo for.   ";
ui_category = "List Selection";
ui_category_closed = true;
ui_type = "combo";
ui_items = "Auto-Select\0"
"Final Fantasy XIV\0"
"Phantasy Star Online 2:NGS\0"
"Custom List\0"
;
ui_bind = "cLayer_TEXTURE_SELECTION";
> = 0;
#line 149
uniform int
cLayer_Select < ui_items = "FFXIV\0" "Nalukai\0" "Yomi\0" "Kabel\0" "Neneko Fipps\0" "Neneko Foglihten No.07\0" "Neneko 000webfont\0" "Neneko !Sketchy Times\0" "Neneko Arual\0" "Poppins\0" "Sophia DF 4.5\0" "Meridien\0" "Euphoria Script\0" "Grandmaster\0" "Midnight Sun DF\0" "With GShade Dark\0" "With GShade White\0" "-------------------------------------------------\0" "Gill Sans\0" "Sophia DF 4\0" "Midnight Sun DF 2\0" "Grandmaster 2.5\0" "-------------------------------------------------\0" "Frutiger XCn\0" "Poppins Rectangle\0" "Futura Large\0" "Sophia DF Large\0" "Sophia DF Large 2\0" "Sophia DF\0" "Meridien Large\0" "Caslon Old Face\0" "Andante\0" "Tokyosign\0" "Candlelight\0" "Helvetica\0" "-------------------------------------------------\0" "Futura\0" "Sophia DF 3\0" "Copperplate Gothic\0" "Grandmaster 2\0" "-------------------------------------------------\0" "Baskerville\0" "Josefin Slab\0" "Josefin Slab 2\0" "Codex\0" "Empire\0" "Rachel DF\0" "-------------------------------------------------\0" "Futura 2\0" "Futura Square\0" "Sophia DF Square\0" "Sophia DF 2\0" "Meridian Square\0" "Stymie Square\0" "Stymie Square 2\0" "Broadway Square\0" "Grandmaster 3\0" "Bernhard Neo DF\0" "Super Bodoni DF\0" "Bungee Shade\0" "Bernhard Neo DF 2\0" "Grandmaster 4\0" "-------------------------------------------------\0" "Gill Sans Framed\0" "Gill Sans Framed 2\0" ; ui_bind = "_Copyright_Texture_Source"; ui_label =
"Copyright Logo Selection"; ui_tooltip =
"The image/texture you'd like to use.   "
#line 145
; ui_spacing = 1; ui_type = "combo"; > = 0;;
#line 147
uniform float cLayer_Scale <
ui_label = "Scale";
ui_tooltip = "If you need to increase more scale value,    \nyou can use Scale X&Y combined below.   \nExcessive scaling might degrade the texture   \nhowever.";
ui_type = "slider";
ui_min = 0.500; ui_max = 1.0;
ui_step = 0.001;
> = 0.780;
#line 155
uniform float cLayer_ScaleX <
ui_label = "Scale X";
ui_category = "ScaleXY";
ui_category_closed = true;
ui_type = "slider";
ui_min = 0.001; ui_max = 5.0;
ui_step = 0.001;
> = 1.0;
#line 164
uniform float cLayer_ScaleY <
ui_label = "Scale Y";
ui_category = "ScaleXY";
ui_type = "slider";
ui_min = 0.001; ui_max = 5.0;
ui_step = 0.001;
> = 1.0;
#line 173
uniform bool  cLayer_Mouse <
ui_label = "Mouse Following Mode";
ui_tooltip = "Press right click to logo texture follow the mouse cursor.   \nRight click again to back to Position X and Y coord.";
ui_spacing = 2;
> = false;
#line 179
uniform float cLayer_PosX <
ui_label = "Position X";
ui_tooltip = "X & Y coordinates of the textures.\nAxes start upper left screen corner.   ";
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.680;
#line 187
uniform float cLayer_PosY <
ui_label = "Position Y";
ui_tooltip = "X & Y coordinates of the textures.\nAxes start upper left screen corner.   ";
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.970;
#line 195
uniform int cLayer_SnapRotate <
ui_label = "Snap Rotation";
ui_tooltip = "Snap rotation to a specific angle.\nPress arrow button to rotate 90° each direction.   ";
ui_type = "combo";
ui_spacing = 2;
ui_items = "-90 Degrees\0"
"0 Degrees\0"
"90 Degrees\0"
"180 Degrees\0"
;
> = 1;
#line 207
uniform float cLayer_Rotate <
ui_label = "Rotate";
ui_tooltip = "Rotate the texture to desired angle.   ";
ui_type = "slider";
ui_min = -180.0;
ui_max = 180.0;
ui_step = 0.01;
> = 0;
#line 217
uniform bool cLayer_Color_Invert <
ui_label = "Invert Colors";
ui_tooltip = "Can invert all colors.";
ui_spacing = 2;
> = 0;
#line 227
uniform int cLayer_Color_Override <
ui_label = "Recolor";
ui_tooltip = "Can colorize   \nto any color to black/white areas.";
ui_type = "combo";
ui_items = "None\0"
"Recolor White Part\0"
"Recolor Black Part\0"
"Recolor Both Parts\0"
"Recolor Both in One Color\0"
;
ui_bind = "cLayer_COLOR_OVERRIDE_COMBO";
> = 3;
#line 273
uniform int
cLayer_BlendMode < ui_category =
""; ui_category_closed =
false; ui_items = "Normal\0" "Darken\0" "  Multiply\0" "  Color Burn\0" "  Linear Burn\0" "Lighten\0" "  Screen\0" "  Color Dodge\0" "  Linear Dodge\0" "  Addition\0" "  Glow\0" "Overlay\0" "  Soft Light\0" "  Hard Light\0" "  Vivid Light\0" "  Linear Light\0" "  Pin Light\0" "  Hard Mix\0" "Difference\0" "  Exclusion\0" "Subtract\0" "  Divide\0" "  Divide (Alternative)\0" "  Divide (Photoshop)\0" "  Reflect\0" "  Grain Extract\0" "  Grain Merge\0" "Hue\0" "  Saturation\0" "  Color\0" "  Luminosity\0"; ui_label =
"Blending Mode"; ui_tooltip =
"Select the blending mode applied to the texture.   "; ui_type = "combo"; ui_spacing =
2; > =
0
#line 265
;;
#line 267
uniform float cLayer_Blend <
ui_label = "Blending Amount";
ui_tooltip = "The amount of blending applied to the texture.   ";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 277
uniform float cLayer_Depth <
ui_label = "Depth Position";
ui_type = "slider";
ui_tooltip = "Place the texture behind characters,   \nterrains, etc.";
ui_spacing = 2;
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 288
uniform float Gauss_Blend <
ui_label = "Blending Amount Gaussian Layer";
ui_tooltip = "The amount of blending applied to the   \nGaussian Layer.";
ui_spacing = 2;
ui_category = "Gaussian Layer";
ui_category_closed = false;
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
ui_step = 0.001;
> = 0.0;
#line 300
uniform float cLayer_PosX_Gauss <
ui_label = "Gaussian Layer Offset X";
ui_tooltip = "Offset of the Gaussian layer based on texture's    \ncoordinates.";
ui_category = "Gaussian Layer";
ui_type = "slider";
ui_spacing = 2;
ui_min = -0.35; ui_max = 0.35;
ui_step = 0.001;
> = 0.025;
#line 310
uniform float cLayer_PosY_Gauss <
ui_label = "Gaussian Layer Offset Y";
ui_tooltip = "Offset of the Gaussian layer based on texture's    \ncoordinates.";
ui_category = "Gaussian Layer";
ui_type = "slider";
ui_min = -0.35; ui_max = 0.35;
ui_step = 0.001;
> = 0.050;
#line 319
uniform float cLayer_Scale_Gauss <
ui_label = "Gaussian Layer Scale";
ui_tooltip = "Scale of the Gaussian layer.   ";
ui_category = "Gaussian Layer";
ui_type = "slider";
ui_min = 0.75; ui_max = 1.5;
ui_step = 0.001;
> = 1.000;
#line 328
uniform int GaussianBlurRadius <
ui_label = "Gaussian Blur Radius";
ui_tooltip = "[0|1|2|3] Adjusts the blur radius.\nEach values Assumed to use for better results accord to   \ndifferent sizes of logos.   \nValue 3 is intended as some challenge.";
ui_category = "Gaussian Layer";
ui_type = "slider";
ui_spacing = 2;
ui_min = 0;
ui_max = 3;
ui_step = 1;
> = 1;
#line 339
uniform float GaussWeight <
ui_label = "Gaussian Weight";
ui_tooltip = "Weight based on Gaussian Radius.   \nIncreasing value makes more blur.   ";
ui_category = "Gaussian Layer";
ui_type = "slider";
ui_min = 0.001;
ui_max = 3.0;
ui_step = 0.001;
> = 0.600;
#line 349
uniform float GaussWeightH <
ui_label = "Gaussian Weight X";
ui_tooltip = "Weight based on Gaussian Radius.   \nIncreasing value makes more blur.   ";
ui_category = "Gaussian Layer";
ui_type = "slider";
ui_min = 0.001;
ui_max = 10.0;
ui_step = 0.001;
> = 0.001;
#line 359
uniform float GaussWeightV <
ui_label = "Gaussian Weight Y";
ui_tooltip = "Weight based on Gaussian Radius.   \nIncreasing value makes more blur.   ";
ui_category = "Gaussian Layer";
ui_type = "slider";
ui_min = 0.001;
ui_max = 10.0;
ui_step = 0.001;
> = 0.001;
#line 369
uniform float3 GaussColor <
ui_label = "Gaussian Layer Color";
ui_tooltip = "Color applied to the Gaussian Layer.   ";
ui_category = "Gaussian Layer";
ui_type = "color";
ui_spacing = 2;
ui_tooltip = "Color of the shadow layer";
> = float3(0.0, 0.0, 0.0);
#line 394
uniform int
cLayer_BlendMode_Gauss < ui_category =
"Gaussian Layer"; ui_category_closed =
false; ui_items = "Normal\0" "Darken\0" "  Multiply\0" "  Color Burn\0" "  Linear Burn\0" "Lighten\0" "  Screen\0" "  Color Dodge\0" "  Linear Dodge\0" "  Addition\0" "  Glow\0" "Overlay\0" "  Soft Light\0" "  Hard Light\0" "  Vivid Light\0" "  Linear Light\0" "  Pin Light\0" "  Hard Mix\0" "Difference\0" "  Exclusion\0" "Subtract\0" "  Divide\0" "  Divide (Alternative)\0" "  Divide (Photoshop)\0" "  Reflect\0" "  Grain Extract\0" "  Grain Merge\0" "Hue\0" "  Saturation\0" "  Color\0" "  Luminosity\0"; ui_label =
"Gaussian Layer Blending Mode"; ui_tooltip =
"Select the blending mode applied to the Gaussian Layer.   "; ui_type = "combo"; ui_spacing =
2; > =
0
#line 386
;;
#line 407
uniform int
cLayer_BlendMode_BG < ui_category =
"BG Blending Mode"; ui_category_closed =
false; ui_items = "Normal\0" "Darken\0" "  Multiply\0" "  Color Burn\0" "  Linear Burn\0" "Lighten\0" "  Screen\0" "  Color Dodge\0" "  Linear Dodge\0" "  Addition\0" "  Glow\0" "Overlay\0" "  Soft Light\0" "  Hard Light\0" "  Vivid Light\0" "  Linear Light\0" "  Pin Light\0" "  Hard Mix\0" "Difference\0" "  Exclusion\0" "Subtract\0" "  Divide\0" "  Divide (Alternative)\0" "  Divide (Photoshop)\0" "  Reflect\0" "  Grain Extract\0" "  Grain Merge\0" "Hue\0" "  Saturation\0" "  Color\0" "  Luminosity\0"; ui_label =
"BG Blend Mode"; ui_tooltip =
#line 413
"Select the blending mode applied to the bg-texture.   \n\
    - note -   \nWhen using this mode, it requires reducing blending\namount of logo texture.   \nThe priority of this mode is to be set to later.   "; ui_type = "combo"; ui_spacing =
2; > =
0
#line 398
;;
#line 400
uniform float cLayer_Blend_BG <
ui_label = "BG Blending Amount";
ui_tooltip = "The amount of blending applied to the bg-texture.   ";
ui_category = "BG Blend Mode";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.0;
#line 411
uniform float4 cLayer_CAb_Color_A <
ui_label = "CAb Color A";
ui_tooltip = "A Color appling to Chromatic Aberration layer.   ";
ui_category = "Chromatic Aberration";
ui_category_closed = false;
ui_type = "color";
> = float4(1.0, 0.0, 0.0, 1.0);
#line 419
uniform float4 cLayer_CAb_Color_B <
ui_label = "CAb Color B";
ui_tooltip = "A Color appling to Chromatic Aberration layer.   ";
ui_category = "Chromatic Aberration";
ui_type = "color";
> = float4(0.0, 1.0, 1.0, 1.0);
#line 426
uniform float2 cLayer_CAb_Shift <
ui_label = "CAb Shift";
ui_tooltip = "Degree of Chromatic Aberration.   ";
ui_category = "Chromatic Aberration";
ui_type = "slider";
ui_min = -0.2;
ui_max = 0.2;
> = float2(0.015, -0.015);
#line 435
uniform float cLayer_CAb_Strength <
ui_label = "CAb Strength";
ui_tooltip = "Blending Amount of Chromatic Aberration layer.   ";
ui_category = "Chromatic Aberration";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.0;
#line 444
uniform float cLayer_CAb_Blur <
ui_label = "CAb Blur";
ui_tooltip = "A Simplistic blur for Chromatic Aberration Layer .   ";
ui_category = "Chromatic Aberration";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.5;
> = 0.015;
#line 453
uniform int cLayer_BlendMode_CAb <
ui_label = "CAb Blending Mode";
ui_tooltip = "Select the blending mode applied to the CAb layer.\nDifferent look according to the brightness of background.   ";
ui_category = "Chromatic Aberration";
ui_type = "combo";
ui_items = "Screen\0"
"LinearDodge\0"
"Glow\0"
"LinearLight\0"
"Color\0"
"Grain Merge\0"
"Divide\0"
"Divide(Alternative)\0"
"Normal\0"
;
> = 0;
#line 471
uniform float2 MouseCoords < source = "mousepoint"; >;
uniform bool LeftMouseDown < source = "mousebutton"; keycode = 0; toggle = true; >;
uniform bool RightMouseDown < source = "mousebutton"; keycode = 1; toggle = true; >;
#line 477
texture Copyright_Texture <
source = "Copyright4kH.png";
> {
Width = 1280;
Height = 720;
Format = RGBA8;
};
#line 485
texture Copyright_Texture_Gauss_H
{
Width = 1280;
Height = 720;
Format = RGBA8;
};
#line 492
texture Copyright_Texture_Gauss_V
{
Width = 1280;
Height = 720;
Format = RGBA8;
};
#line 499
texture Copyright_Texture_Gauss_Out
{
Width = 1280;
Height = 720;
Format = RGBA8;
};
#line 506
texture Copyright_Texture_CAb_Gauss_H
{
Width = 1280;
Height = 720;
Format = RGBA8;
};
#line 513
texture Copyright_Texture_CAb_Gauss_Out
{
Width = 1280;
Height = 720;
Format = RGBA8;
};
#line 520
texture Copyright_Texture_CAb_A
{
Width = 1280;
Height = 720;
Format = RGBA8;
};
#line 527
texture Copyright_Texture_CAb_B
{
Width = 1280;
Height = 720;
Format = RGBA8;
};
#line 534
sampler Copyright_Sampler
{
Texture = Copyright_Texture;
AddressU = CLAMP;
AddressV = CLAMP;
};
#line 541
sampler Copyright_Sampler_Gauss_H
{
Texture = Copyright_Texture_Gauss_H;
};
#line 546
sampler Copyright_Sampler_Gauss_V
{
Texture = Copyright_Texture_Gauss_Out;
};
#line 551
sampler Copyright_Sampler_CAb_Gauss_H
{
Texture = Copyright_Texture_CAb_Gauss_H;
};
#line 556
sampler Copyright_Sampler_CAb_Gauss_V
{
Texture = Copyright_Texture_CAb_Gauss_Out;
};
#line 561
sampler Copyright_Sampler_CAb_A
{
Texture = Copyright_Texture_CAb_A;
};
#line 566
sampler Copyright_Sampler_CAb_B
{
Texture = Copyright_Texture_CAb_B;
};
#line 591
float3x3 positionMatrix (in float coord_X, in float coord_Y) {
return float3x3 (
1, 0, 0,
0, 1, 0,
-coord_X, -coord_Y, 1
);
}
#line 599
float3x3 scaleMatrix (in float width_X, in float width_Y) {
return float3x3 (
1/width_X, 0, 0,
0,  1/width_Y, 0,
0, 0, 1
);
}
#line 607
float3x3 rotateMatrix (in float angle) {
float Rotate = angle * (3.1415926 / 180.0);
switch(cLayer_SnapRotate)
{
case 0:
Rotate = (angle * (3.1415926 / 180.0)) + (-90.0 * (3.1415926 / 180.0));
break;
case 1:
break;
case 2:
Rotate = (angle * (3.1415926 / 180.0)) + (90.0 * (3.1415926 / 180.0));
break;
case 3:
Rotate = (angle * (3.1415926 / 180.0)) + (180.0 * (3.1415926 / 180.0));
break;
}
#line 624
return float3x3 (
cos(Rotate), -sin(Rotate), 0,
sin(Rotate), cos(Rotate), 0,
0, 0, 1
);
}
#line 631
float3x3 rotateMatrix_Alt (in float angle) {
return float3x3 (
cos(angle), sin(angle), 0,
-sin(angle), cos(angle), 0,
0, 0, 1
);
}
#line 640
float4 PS_cLayer_Gauss_H(in float4 pos : SV_Position, in float2 texCoord : TEXCOORD) : COLOR  {
#line 642
float4 color = tex2D(Copyright_Sampler_Gauss_V, texCoord);
switch(GaussianBlurRadius)
{
default:
const float sampleOffsets[4] = { 0.0, 1.1824255238, 3.0293122308, 5.0040701377 };
const float sampleWeights[4] = { 0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842 };
color *= sampleWeights[0];
for(int i = 1; i < 4; ++i)
{
color += tex2Dlod(Copyright_Sampler_Gauss_V, float4(texCoord + float2(sampleOffsets[i] * (GaussWeight * (GaussWeightH + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(Copyright_Sampler_Gauss_V, float4(texCoord - float2(sampleOffsets[i] * (GaussWeight * (GaussWeightH + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
}
break;
case 1:
const float sampleOffsets[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float sampleWeights[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
color *= sampleWeights[0];
for(int i = 1; i < 6; ++i)
{
color += tex2Dlod(Copyright_Sampler_Gauss_V, float4(texCoord + float2(sampleOffsets[i] * (GaussWeight * (GaussWeightH + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(Copyright_Sampler_Gauss_V, float4(texCoord - float2(sampleOffsets[i] * (GaussWeight * (GaussWeightH + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
}
break;
case 2:
const float sampleOffsets[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
const float sampleWeights[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
color *= sampleWeights[0];
for(int i = 1; i < 11; ++i)
{
color += tex2Dlod(Copyright_Sampler_Gauss_V, float4(texCoord + float2(sampleOffsets[i] * (GaussWeight * (GaussWeightH + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(Copyright_Sampler_Gauss_V, float4(texCoord - float2(sampleOffsets[i] * (GaussWeight * (GaussWeightH + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
}
break;
case 3:
const float sampleOffsets[6] = { 0.0, 0.25, 0.50, 0.75, 1.00, 1.25 };
const float sampleWeights[6] = { 0.15, 0.25, 0.135, 0.055, 0.0135, 0.0015 };
color *= sampleWeights[0];
for(int i = 1; i < 6; ++i)
{
color += tex2Dlod(Copyright_Sampler_Gauss_V, float4(texCoord + float2(sampleOffsets[i] * (GaussWeight * (GaussWeightH + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(Copyright_Sampler_Gauss_V, float4(texCoord - float2(sampleOffsets[i] * (GaussWeight * (GaussWeightH + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
}
break;
}
color.rgb = (GaussColor.rgb);
return color;
}
#line 690
float4 PS_cLayer_Gauss_V(in float4 pos : SV_Position, in float2 texCoord : TEXCOORD) : COLOR  {
#line 692
const float3 SumUV = mul (mul (mul (float3(texCoord.x, texCoord.y, 1), positionMatrix(0.5 + float(cLayer_PosX_Gauss * 0.1), 0.5 + float(cLayer_PosY_Gauss * 0.1))), rotateMatrix_Alt(0)) * float3(float2(1280, 720), 1.0), scaleMatrix(float(float2(float2(800.0, 100.0) * ((cLayer_Scale) + (-1 + cLayer_Scale_Gauss))).x), float(float2(float2(800.0, 100.0) * ((cLayer_Scale) + (-1 + cLayer_Scale_Gauss))).y)));
float4 color = tex2D(Copyright_Sampler, SumUV.rg + float3(0.5, 0.5, 0.0).rg);
switch(GaussianBlurRadius)
{
default:
const float sampleOffsets[4] = { 0.0, 1.1824255238, 3.0293122308, 5.0040701377 };
const float sampleWeights[4] = { 0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842 };
color *= sampleWeights[0];
for(int i = 1; i < 4; ++i)
{
color += tex2Dlod(Copyright_Sampler_Gauss_H, float4(texCoord + float2(0.0, sampleOffsets[i] * (GaussWeight * (GaussWeightV + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(Copyright_Sampler_Gauss_H, float4(texCoord - float2(0.0, sampleOffsets[i] * (GaussWeight * (GaussWeightV + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).y), 0.0, 0.0)) * sampleWeights[i];
}
break;
case 1:
const float sampleOffsets[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float sampleWeights[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
color *= sampleWeights[0];
for(int i = 1; i < 6; ++i)
{
color += tex2Dlod(Copyright_Sampler_Gauss_H, float4(texCoord + float2(0.0, sampleOffsets[i] * (GaussWeight * (GaussWeightV + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(Copyright_Sampler_Gauss_H, float4(texCoord - float2(0.0, sampleOffsets[i] * (GaussWeight * (GaussWeightV + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).y), 0.0, 0.0)) * sampleWeights[i];
}
break;
case 2:
const float sampleOffsets[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
const float sampleWeights[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
color *= sampleWeights[0];
for(int i = 1; i < 11; ++i)
{
color += tex2Dlod(Copyright_Sampler_Gauss_H, float4(texCoord + float2(0.0, sampleOffsets[i] * (GaussWeight * (GaussWeightV + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(Copyright_Sampler_Gauss_H, float4(texCoord - float2(0.0, sampleOffsets[i] * (GaussWeight * (GaussWeightV + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).y), 0.0, 0.0)) * sampleWeights[i];
}
break;
case 3:
const float sampleOffsets[6] = { 0.0, 0.25, 0.50, 0.75, 1.00, 1.25 };
const float sampleWeights[6] = { 0.15, 0.25, 0.135, 0.055, 0.0135, 0.0015 };
color *= sampleWeights[0];
for(int i = 1; i < 6; ++i)
{
color += tex2Dlod(Copyright_Sampler_Gauss_H, float4(texCoord + float2(0.0, sampleOffsets[i] * (GaussWeight * (GaussWeightV + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(Copyright_Sampler_Gauss_H, float4(texCoord - float2(0.0, sampleOffsets[i] * (GaussWeight * (GaussWeightV + 0.5)) * float2((1.0 / 1280), (1.0 / 720)).y), 0.0, 0.0)) * sampleWeights[i];
}
break;
}
color.rgb = (GaussColor.rgb);
return color;
}
#line 741
float4 PS_cLayer_CAb_Gauss_H(in float4 pos : SV_Position, in float2 texCoord : TEXCOORD) : COLOR  {
#line 743
float4 color = tex2D(Copyright_Sampler_CAb_Gauss_V, texCoord);
const float sampleOffsets[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float sampleWeights[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
color *= sampleWeights[0];
for(int i = 1; i < 6; ++i)
{
color += tex2Dlod(Copyright_Sampler_CAb_Gauss_V, float4(texCoord + float2(sampleOffsets[i] * cLayer_CAb_Blur * float2((1.0 / 1280), (1.0 / 720)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(Copyright_Sampler_CAb_Gauss_V, float4(texCoord - float2(sampleOffsets[i] * cLayer_CAb_Blur * float2((1.0 / 1280), (1.0 / 720)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
}
return color;
}
#line 755
float4 PS_cLayer_CAb_Gauss_V(in float4 pos : SV_Position, in float2 texCoord : TEXCOORD) : COLOR  {
#line 757
const float3 SumUV = mul (mul (mul (float3(texCoord.x, texCoord.y, 1), positionMatrix(0.5, 0.5)) * float3(float2(1280, 720), 1.0), rotateMatrix_Alt(0)), scaleMatrix(float(float2(float2(800.0, 100.0) * cLayer_Scale).x * cLayer_ScaleX), float(float2(float2(800.0, 100.0) * cLayer_Scale).y * cLayer_ScaleY)));
float4 color = tex2D(Copyright_Sampler, SumUV.rg + float2(0.5, 0.5));
const float sampleOffsets[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float sampleWeights[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
color *= sampleWeights[0];
for(int i = 1; i < 6; ++i)
{
color += tex2Dlod(Copyright_Sampler_CAb_Gauss_H, float4(texCoord + float2(0.0, sampleOffsets[i] * cLayer_CAb_Blur * float2((1.0 / 1280), (1.0 / 720)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(Copyright_Sampler_CAb_Gauss_H, float4(texCoord - float2(0.0, sampleOffsets[i] * cLayer_CAb_Blur * float2((1.0 / 1280), (1.0 / 720)).y), 0.0, 0.0)) * sampleWeights[i];
}
return color;
}
#line 770
float4 PS_cLayer_CAb_A(in float4 pos : SV_Position, in float2 texCoord : TEXCOORD) : COLOR  {
#line 772
const float2 CAb_Shift = cLayer_CAb_Shift * 0.05;
const float3 SumUV = mul (mul (float3(texCoord.x, texCoord.y, 1), positionMatrix(0.5 + CAb_Shift.x, 0.5 + CAb_Shift.y * 1280 / 720)), scaleMatrix(1, 1));
float4 color = tex2D(Copyright_Sampler_CAb_Gauss_H, SumUV.rg + float3(0.5, 0.5, 0.0).rg) * all(SumUV.rg + float3(0.5, 0.5, 0.0).rg == saturate(SumUV.rg + float3(0.5, 0.5, 0.0).rg));
color = float4(cLayer_CAb_Color_A.r, cLayer_CAb_Color_A.g, cLayer_CAb_Color_A.b, color.a * cLayer_CAb_Color_A.a);
return color;
}
#line 779
float4 PS_cLayer_CAb_B(in float4 pos : SV_Position, in float2 texCoord : TEXCOORD) : COLOR  {
#line 781
const float2 CAb_Shift = cLayer_CAb_Shift * 0.05;
const float3 SumUV = mul (mul (float3(texCoord.x, texCoord.y, 1), positionMatrix(0.5 - CAb_Shift.x, 0.5 - CAb_Shift.y * 1280 / 720)), scaleMatrix(1, 1));
float4 color = tex2D(Copyright_Sampler_CAb_Gauss_H, SumUV.rg + float3(0.5, 0.5, 0.0).rg) * all(SumUV.rg + float3(0.5, 0.5, 0.0).rg == saturate(SumUV.rg + float3(0.5, 0.5, 0.0).rg));
color = float4(cLayer_CAb_Color_B.r, cLayer_CAb_Color_B.g, cLayer_CAb_Color_B.b, color.a * cLayer_CAb_Color_B.a);
return color;
}
#line 788
void PS_cLayer(in float4 pos : SV_Position, float2 texCoord : TEXCOORD, out float4 passColor : SV_Target) {
#line 790
const float Depth = 0.999 - ReShade::GetLinearizedDepth(texCoord).x;
float4 backColorOrig = tex2D(ReShade::BackBuffer, texCoord);
if (Depth < cLayer_Depth)
{
const float3 SumUV = mul (mul (mul (float3(texCoord.x, texCoord.y, 1), positionMatrix(float(cLayer_Mouse && RightMouseDown? MouseCoords.x * float2((1.0 / 1280), (1.0 / 720)).x : cLayer_PosX), float(cLayer_Mouse && RightMouseDown? MouseCoords.y * float2((1.0 / 1280), (1.0 / 720)).y : cLayer_PosY))) * float3(float2(1280, 720), 1.0), rotateMatrix(cLayer_Rotate)), scaleMatrix(float(float2(float2(800.0, 100.0) * cLayer_Scale).x * cLayer_ScaleX), float(float2(float2(800.0, 100.0) * cLayer_Scale).y * cLayer_ScaleY)));
const float3 SumUV_Gauss = mul (mul (mul (float3(texCoord.x, texCoord.y, 1), positionMatrix(float(cLayer_Mouse && RightMouseDown? MouseCoords.x * float2((1.0 / 1280), (1.0 / 720)).x : cLayer_PosX), float(cLayer_Mouse && RightMouseDown? MouseCoords.y * float2((1.0 / 1280), (1.0 / 720)).y : cLayer_PosY))) * float3(float2(1280, 720), 1.0), rotateMatrix(cLayer_Rotate)), scaleMatrix(1280, 720));
float4 GaussOut = tex2D(Copyright_Sampler_Gauss_H, SumUV_Gauss.rg + float3(0.5, 0.5, 0.0).rg);
const float3 SumUV_CAb = mul (mul (mul (float3(texCoord.x, texCoord.y, 1), positionMatrix(float(cLayer_Mouse && RightMouseDown? MouseCoords.x * float2((1.0 / 1280), (1.0 / 720)).x : cLayer_PosX), float(cLayer_Mouse && RightMouseDown? MouseCoords.y * float2((1.0 / 1280), (1.0 / 720)).y : cLayer_PosY))) * float3(float2(1280, 720), 1.0), rotateMatrix(cLayer_Rotate)), scaleMatrix(1280, 720));
float4 CAb_A = tex2D(Copyright_Sampler_CAb_A, SumUV_CAb.rg + float3(0.5, 0.5, 0.0).rg);
float4 CAb_B = tex2D(Copyright_Sampler_CAb_B, SumUV_CAb.rg + float3(0.5, 0.5, 0.0).rg);
float4 DrawTex = tex2D(Copyright_Sampler, SumUV.rg + float3(0.5, 0.5, 0.0).rg) * all(SumUV.rg + float3(0.5, 0.5, 0.0).rg == saturate(SumUV.rg + float3(0.5, 0.5, 0.0).rg));
#line 802
GaussOut.rgb = ComHeaders::Blending::Blend(cLayer_BlendMode_Gauss, backColorOrig.rgb, GaussOut.rgb, GaussOut.a * Gauss_Blend);
#line 804
switch(cLayer_BlendMode_CAb)
{
case 0:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Screen(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Screen(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 1:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::LinearDodge(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::LinearDodge(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 2:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Glow(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Glow(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 3:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::LinearLight(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::LinearLight(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 4:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::ColorB(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::ColorB(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 5:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::GrainMerge(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::GrainMerge(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 6:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Divide(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Divide(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 7:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::DivideAlt(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::DivideAlt(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 8:
GaussOut = lerp(GaussOut.rgb, CAb_A.rgb, CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, CAb_B.rgb, CAb_B.a * cLayer_CAb_Strength);
break;
}
#line 844
float4 ColorFactor = DrawTex;
#line 856
float4 backColor = GaussOut;
passColor = lerp(GaussOut, backColorOrig, DrawTex.a);
#line 859
passColor.rgb = ComHeaders::Blending::Blend(cLayer_BlendMode_BG, backColor.rgb, passColor.rgb, DrawTex.a * cLayer_Blend_BG);
#line 861
switch (cLayer_BlendMode)
{
case 0:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Screen(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Screen(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 1:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::LinearDodge(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::LinearDodge(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 2:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Glow(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Glow(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 3:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::LinearLight(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::LinearLight(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 4:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::ColorB(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::ColorB(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 5:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::GrainMerge(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::GrainMerge(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 6:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Divide(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::Divide(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 7:
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::DivideAlt(GaussOut.rgb, CAb_A.rgb), CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, ComHeaders::Blending::DivideAlt(GaussOut.rgb, CAb_B.rgb), CAb_B.a * cLayer_CAb_Strength);
break;
case 8:
GaussOut = lerp(GaussOut.rgb, CAb_A.rgb, CAb_A.a * cLayer_CAb_Strength);
GaussOut = lerp(GaussOut.rgb, CAb_B.rgb, CAb_B.a * cLayer_CAb_Strength);
break;
}
#line 901
float3 ColorFactorBlended;
#line 903
switch (cLayer_BlendMode)
{
#line 906
default:
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactor.rgb : ColorFactor.rgb, DrawTex.a * cLayer_Blend);
break;
#line 910
case 1:
ColorFactorBlended = ComHeaders::Blending::Darken(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 915
case 2:
ColorFactorBlended = ComHeaders::Blending::Multiply(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 920
case 3:
ColorFactorBlended = ComHeaders::Blending::ColorBurn(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 925
case 4:
ColorFactorBlended = ComHeaders::Blending::LinearBurn(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 930
case 5:
ColorFactorBlended = ComHeaders::Blending::Lighten(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 935
case 6:
ColorFactorBlended = ComHeaders::Blending::Screen(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 940
case 7:
ColorFactorBlended = ComHeaders::Blending::ColorDodge(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 945
case 8:
ColorFactorBlended = ComHeaders::Blending::LinearDodge(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 950
case 9:
ColorFactorBlended = ComHeaders::Blending::Addition(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 955
case 10:
ColorFactorBlended = ComHeaders::Blending::Glow(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 960
case 11:
ColorFactorBlended = ComHeaders::Blending::Overlay(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 965
case 12:
ColorFactorBlended = ComHeaders::Blending::SoftLight(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 970
case 13:
ColorFactorBlended = ComHeaders::Blending::HardLight(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 975
case 14:
ColorFactorBlended = ComHeaders::Blending::VividLight(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 980
case 15:
ColorFactorBlended = ComHeaders::Blending::LinearLight(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 985
case 16:
ColorFactorBlended = ComHeaders::Blending::PinLight(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 990
case 17:
ColorFactorBlended = ComHeaders::Blending::HardMix(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 995
case 18:
ColorFactorBlended = ComHeaders::Blending::Difference(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1000
case 19:
ColorFactorBlended = ComHeaders::Blending::Exclusion(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1005
case 20:
ColorFactorBlended = ComHeaders::Blending::Subtract(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1010
case 21:
ColorFactorBlended = ComHeaders::Blending::Divide(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1015
case 22:
ColorFactorBlended = ComHeaders::Blending::DivideAlt(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1020
case 23:
ColorFactorBlended = ComHeaders::Blending::DividePS(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1025
case 24:
ColorFactorBlended = ComHeaders::Blending::Reflect(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1030
case 25:
ColorFactorBlended = ComHeaders::Blending::GrainMerge(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1035
case 26:
ColorFactorBlended = ComHeaders::Blending::GrainExtract(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1040
case 27:
ColorFactorBlended = ComHeaders::Blending::Hue(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1045
case 28:
ColorFactorBlended = ComHeaders::Blending::Saturation(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1050
case 29:
ColorFactorBlended = ComHeaders::Blending::ColorB(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
#line 1055
case 30:
ColorFactorBlended = ComHeaders::Blending::Luminosity(backColorOrig.rgb, ColorFactor.rgb);
passColor = lerp(passColor.rgb, cLayer_Color_Invert ? float3(1, 1, 1) - ColorFactorBlended : ColorFactorBlended, DrawTex.a * cLayer_Blend);
break;
}
passColor.a = backColorOrig.a;
}
else
passColor = backColorOrig;
}
#line 1070
technique Copyright< ui_label = "Copyright"; >
{
pass pass0
{
VertexShader = PostProcessVS;
PixelShader = PS_cLayer_Gauss_H;
RenderTarget = Copyright_Texture_Gauss_H;
}
pass pass1
{
VertexShader = PostProcessVS;
PixelShader = PS_cLayer_Gauss_V;
RenderTarget = Copyright_Texture_Gauss_Out;
}
#line 1085
pass pass2
{
VertexShader = PostProcessVS;
PixelShader = PS_cLayer_CAb_Gauss_H;
RenderTarget = Copyright_Texture_CAb_Gauss_H;
}
pass pass3
{
VertexShader = PostProcessVS;
PixelShader = PS_cLayer_CAb_Gauss_V;
RenderTarget = Copyright_Texture_CAb_Gauss_Out;
}
pass pass4
{
VertexShader = PostProcessVS;
PixelShader = PS_cLayer_CAb_A;
RenderTarget = Copyright_Texture_CAb_A;
}
pass pass5
{
VertexShader = PostProcessVS;
PixelShader = PS_cLayer_CAb_B;
RenderTarget = Copyright_Texture_CAb_B;
}
pass pass6
{
VertexShader = PostProcessVS;
PixelShader = PS_cLayer;
}
}

