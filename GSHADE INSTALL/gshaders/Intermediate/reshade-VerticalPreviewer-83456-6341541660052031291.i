#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\VerticalPreviewer.fx"
#line 64
uniform bool VPreToggle <
ui_text = "*** The preview by this shader is ignored on the screenshot ***";
ui_label = "Toggle Preview ON/OFF";
ui_tooltip = "You can assign a hotkey by right-clicking.";
> = false;
#line 70
uniform int cLayerVPre_Angle <
ui_type = "combo";
ui_spacing = 1;
ui_label = "Vertical Preview";
ui_tooltip = "-90 Degrees: Rotate Left.\n"
" 90 Degrees: Rotate Right.   \n";
ui_items = "-90 Degree\0"
"  0 Degree\0"
" 90 Degree\0"
"180 Degree\0"
"Disable Vertical Preview\0";
> = 2;
#line 83
uniform float cLayerVPre_Scale <
ui_type = "slider";
ui_label = "Scale";
ui_tooltip = "0.75 will vertically fit \n"
"in 16:9(FHD) ratio.        ";
ui_min = 0.50; ui_max = 1.00;
ui_step = 0.001;
> = 0.750;
#line 92
uniform float cLayerVPre_PosX <
ui_type = "slider";
ui_label = "Position X";
ui_tooltip = "Useful in situations like UI is hidden behind a preview.\n";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.500;
#line 100
uniform float cLayerVPre_PosY <
ui_type = "slider";
ui_label = "Position Y";
ui_tooltip = "Useful in situations like preview interferes with the UI.\n";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.500;
#line 108
uniform int cLayerVPre_Composition <
ui_type = "combo";
ui_spacing = 1;
ui_label = "Composition Line";
ui_tooltip = " By positioning subjects/objects\n"
"     in the center of square\n    "
"           or                   \n"
"aligning to lines or cross point,\n"
" your screen may more balanced.";
ui_items = "OFF\0"
"Center Lines\0"
"Thirds\0"
"Fourth\0"
"Fifths\0"
"Golden Ratio\0"
"Silver Ratio\0"
"Diagonals One\0"
"Diagonals Two\0"
"Golden Section Grid\0"
"OneHalf Section Grid\0"
"Harmonic Armature\0"
"Railman Ratio\0";
> = 2;
#line 132
uniform float4 UIGridColor <
ui_type = "color";
ui_label = "Grid Color";
> = float4(1.0, 1.0, 1.0, 0.294);
#line 137
uniform float UIGridLineWidth <
ui_type = "slider";
ui_label = "Grid Line Width";
ui_min = 0.0; ui_max = 5.0;
ui_steps = 0.01;
> = 2.0;
#line 144
uniform int cLayerVPre_CompositionARatio <
ui_type = "combo";
ui_spacing = 1;
ui_label = "Thumbnail Cropping Guide";
ui_tooltip = "Display a guide to thumbnail cropping\n"
"on Twitter and Instagram.\n"
"The area between lines will be\n"
"reflected to thumbnails.\n";
ui_items = "OFF\0"
"1.33 (1 vertical image on Twitter)\0"
"1.15 (2 vertical image on Twitter)\0"
"1.44 (Latter 2 vertical images out of 3 posts)\0"
"2.05 (2 horizontal image on Twitter)\0"
"1:1  (Instagram)\0";
> = 0;
#line 160
uniform float4 UIGridColorARatio <
ui_type = "color";
ui_label = "Grid Color";
> = float4(0.686, 1.000, 0.196, 0.529);
#line 165
uniform float UIGridLineWidthARatio <
ui_type = "slider";
ui_label = "Grid Line Width";
ui_min = 0.0; ui_max = 5.0;
ui_steps = 0.01;
> = 2.5;
#line 172
uniform float cLayer_Blend_BGFill <
ui_type = "slider";
ui_spacing = 1;
ui_label = "Background FIll";
ui_tooltip = "-0.5 will filled with black,\n"
"+0.5 to white.";
ui_min = -0.5; ui_max = 0.5;
ui_step = 0.001;
> = 0.000;
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
#line 187 "C:\Program Files\GShade\gshade-shaders\Shaders\VerticalPreviewer.fx"
#line 188
texture texDraw { Width = 1920; Height = 1018; };
texture texDrawARatio { Width = 1920; Height = 1018; };
texture texVPreOut { Width = 1920; Height = 1018; };
#line 192
sampler samplerDraw { Texture = texDraw; };
sampler samplerDrawARatio { Texture = texDrawARatio; };
sampler samplerVPreOut { Texture = texVPreOut; };
#line 196
struct sctpoint {
float3 color;
float2 coord;
float2 offset;
};
#line 202
sctpoint NewPoint(float3 color, float2 offset, float2 coord) {
sctpoint p;
p.color = color;
p.offset = offset;
p.coord = coord;
return p;
}
#line 210
float3 DrawPoint(float3 texcolor, sctpoint p, float2 texCoord) {
float2 pixelsize = float2((1.0 / 1920), (1.0 / 1018)) * p.offset;
#line 213
if(p.coord.x == -1 || p.coord.y == -1)
return texcolor;
#line 216
if(texCoord.x <= p.coord.x + pixelsize.x &&
texCoord.x >= p.coord.x - pixelsize.x &&
texCoord.y <= p.coord.y + pixelsize.y &&
texCoord.y >= p.coord.y - pixelsize.y)
return p.color;
return texcolor;
}
#line 224
float3 DrawCenterLines(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 227
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(0.5, texCoord.y));
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 0.5));
#line 230
result = DrawPoint(background, lineV1, texCoord);
result = DrawPoint(result, lineH1, texCoord);
#line 233
return result;
}
#line 236
float3 DrawThirds(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 239
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 3.0, texCoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(2.0 / 3.0, texCoord.y));
#line 242
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 / 3.0));
sctpoint lineH2 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 2.0 / 3.0));
#line 245
result = DrawPoint(background, lineV1, texCoord);
result = DrawPoint(result, lineV2, texCoord);
result = DrawPoint(result, lineH1, texCoord);
result = DrawPoint(result, lineH2, texCoord);
#line 250
return result;
}
#line 253
float3 DrawFourth(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 256
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 4.0, texCoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(2.0 / 4.0, texCoord.y));
sctpoint lineV3 = NewPoint(gridColor, lineWidth, float2(3.0 / 4.0, texCoord.y));
#line 260
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 / 4.0));
sctpoint lineH2 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 2.0 / 4.0));
sctpoint lineH3 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 3.0 / 4.0));
#line 264
result = DrawPoint(background, lineV1, texCoord);
result = DrawPoint(result, lineV2, texCoord);
result = DrawPoint(result, lineV3, texCoord);
result = DrawPoint(result, lineH1, texCoord);
result = DrawPoint(result, lineH2, texCoord);
result = DrawPoint(result, lineH3, texCoord);
#line 271
return result;
}
#line 274
float3 DrawFifths(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 277
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 5.0, texCoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(2.0 / 5.0, texCoord.y));
sctpoint lineV3 = NewPoint(gridColor, lineWidth, float2(3.0 / 5.0, texCoord.y));
sctpoint lineV4 = NewPoint(gridColor, lineWidth, float2(4.0 / 5.0, texCoord.y));
#line 282
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 / 5.0));
sctpoint lineH2 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 2.0 / 5.0));
sctpoint lineH3 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 3.0 / 5.0));
sctpoint lineH4 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 4.0 / 5.0));
#line 287
result = DrawPoint(background, lineV1, texCoord);
result = DrawPoint(result, lineV2, texCoord);
result = DrawPoint(result, lineV3, texCoord);
result = DrawPoint(result, lineV4, texCoord);
result = DrawPoint(result, lineH1, texCoord);
result = DrawPoint(result, lineH2, texCoord);
result = DrawPoint(result, lineH3, texCoord);
result = DrawPoint(result, lineH4, texCoord);
#line 296
return result;
}
#line 299
float3 DrawGoldenRatio(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 302
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 1.6180339887, texCoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(1.0 - 1.0 / 1.6180339887, texCoord.y));
#line 305
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 / 1.6180339887));
sctpoint lineH2 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 - 1.0 / 1.6180339887));
#line 308
result = DrawPoint(background, lineV1, texCoord);
result = DrawPoint(result, lineV2, texCoord);
result = DrawPoint(result, lineH1, texCoord);
result = DrawPoint(result, lineH2, texCoord);
#line 313
return result;
}
#line 316
float3 DrawSilverRatio(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 319
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 1.4142135623, texCoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(1.0 - 1.0 / 1.4142135623, texCoord.y));
#line 322
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 / 1.4142135623));
sctpoint lineH2 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 - 1.0 / 1.4142135623));
#line 325
result = DrawPoint(background, lineV1, texCoord);
result = DrawPoint(result, lineV2, texCoord);
result = DrawPoint(result, lineH1, texCoord);
result = DrawPoint(result, lineH2, texCoord);
#line 330
return result;
}
#line 333
float3 DrawDiagonalsOne(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 336
sctpoint line1 = NewPoint(gridColor, lineWidth + 1.0, float2(texCoord.x, texCoord.x));
sctpoint line2 = NewPoint(gridColor, lineWidth + 1.0, float2(texCoord.x, 1.0 - texCoord.x));
#line 339
result = DrawPoint(background, line1, texCoord);
result = DrawPoint(result, line2, texCoord);
#line 342
return result;
}
#line 345
float3 DrawDiagonalsTwo(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 348
float slope = 1.50;
#line 350
sctpoint line1 = NewPoint(gridColor, lineWidth + 1.0, float2(texCoord.x, texCoord.x * slope));
sctpoint line2 = NewPoint(gridColor, lineWidth + 1.0, float2(texCoord.x, 1.0 - texCoord.x * slope));
sctpoint line3 = NewPoint(gridColor, lineWidth + 1.0, float2(texCoord.x, (1.0 - texCoord.x) * slope));
sctpoint line4 = NewPoint(gridColor, lineWidth + 1.0, float2(texCoord.x, texCoord.x * slope + 1.0 - slope));
#line 355
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 3.0, texCoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(2.0 / 3.0, texCoord.y));
#line 358
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 / 3.0));
sctpoint lineH2 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 2.0 / 3.0));
#line 361
result = DrawPoint(background, line1, texCoord);
result = DrawPoint(result, line2, texCoord);
result = DrawPoint(result, line3, texCoord);
result = DrawPoint(result, line4, texCoord);
result = DrawPoint(result, lineV1, texCoord);
result = DrawPoint(result, lineV2, texCoord);
result = DrawPoint(result, lineH1, texCoord);
result = DrawPoint(result, lineH2, texCoord);
#line 370
return result;
}
#line 373
float3 DrawGoldenSection(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 376
sctpoint line1 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x, texCoord.x));
sctpoint line2 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x,1.0 - texCoord.x));
#line 379
float slope = pow(1.6180339887, 2);
#line 381
sctpoint line3 = NewPoint(gridColor, lineWidth + 2.0, float2(texCoord.x, texCoord.x * slope));
sctpoint line4 = NewPoint(gridColor, lineWidth + 2.0, float2(texCoord.x, 1.0 - texCoord.x * slope));
#line 384
sctpoint line5 = NewPoint(gridColor, lineWidth + 2.0, float2(texCoord.x, (1.0 - texCoord.x) * slope));
sctpoint line6 = NewPoint(gridColor, lineWidth + 2.0, float2(texCoord.x, texCoord.x * slope + 1.0 - slope));
#line 387
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 1.6180339887, texCoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(1.0 - 1.0 / 1.6180339887, texCoord.y));
#line 390
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 / 1.6180339887));
sctpoint lineH2 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 - 1.0 / 1.6180339887));
#line 393
result = DrawPoint(background, line1, texCoord);
result = DrawPoint(result, line2, texCoord);
result = DrawPoint(result, line3, texCoord);
result = DrawPoint(result, line4, texCoord);
result = DrawPoint(result, line5, texCoord);
result = DrawPoint(result, line6, texCoord);
result = DrawPoint(result, lineV1, texCoord);
result = DrawPoint(result, lineV2, texCoord);
result = DrawPoint(result, lineH1, texCoord);
result = DrawPoint(result, lineH2, texCoord);
#line 404
return result;
}
#line 407
float3 DrawOneHalfRectangle(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 410
sctpoint line1 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x, texCoord.x));
sctpoint line2 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x, 1.0 - texCoord.x));
#line 413
float slope = pow(1.5, 2);
#line 415
sctpoint line3 = NewPoint(gridColor, lineWidth + 2.0, float2(texCoord.x, texCoord.x * slope));
sctpoint line4 = NewPoint(gridColor, lineWidth + 2.0, float2(texCoord.x, 1.0 - texCoord.x * slope));
#line 418
sctpoint line5 = NewPoint(gridColor, lineWidth + 2.0, float2(texCoord.x, (1.0 - texCoord.x) * slope));
sctpoint line6 = NewPoint(gridColor, lineWidth + 2.0, float2(texCoord.x, texCoord.x * slope + 1.0 - slope));
#line 421
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 1.8, texCoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(1.0 - 1.0 / 1.8, texCoord.y));
#line 424
sctpoint lineH1 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 / 1.8));
sctpoint lineH2 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 - 1.0 /1.8));
#line 427
result = DrawPoint(background, line1, texCoord);
result = DrawPoint(result, line2, texCoord);
result = DrawPoint(result, line3, texCoord);
result = DrawPoint(result, line4, texCoord);
result = DrawPoint(result, line5, texCoord);
result = DrawPoint(result, line6, texCoord);
result = DrawPoint(result, lineV1, texCoord);
result = DrawPoint(result, lineV2, texCoord);
result = DrawPoint(result, lineH1, texCoord);
result = DrawPoint(result, lineH2, texCoord);
#line 438
return result;
}
#line 441
float3 DrawHarmonicArmature(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 444
sctpoint line1 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x, texCoord.x));
sctpoint line2 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x,1.0 - texCoord.x));
#line 447
float slope1 = 0.5;
#line 449
sctpoint line3 = NewPoint(gridColor, lineWidth, float2(texCoord.x, texCoord.x * slope1));
sctpoint line4 = NewPoint(gridColor, lineWidth, float2(texCoord.x, 1.0 - texCoord.x * slope1));
#line 452
sctpoint line5 = NewPoint(gridColor, lineWidth, float2(texCoord.x, (1.0 - texCoord.x) * slope1));
sctpoint line6 = NewPoint(gridColor, lineWidth, float2(texCoord.x, texCoord.x * slope1 + 1.0 - slope1));
#line 455
float slope2 = 1.5;
#line 457
sctpoint line7 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x, texCoord.x * slope2));
sctpoint line8 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x, 1.0 - texCoord.x * slope2));
#line 460
sctpoint line9 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x, (1.0 - texCoord.x) * slope2));
sctpoint line10 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x, texCoord.x * slope2 + 1.0 - slope2));
#line 463
result = DrawPoint(background, line1, texCoord);
result = DrawPoint(result, line2, texCoord);
result = DrawPoint(result, line3, texCoord);
result = DrawPoint(result, line4, texCoord);
result = DrawPoint(result, line5, texCoord);
result = DrawPoint(result, line6, texCoord);
result = DrawPoint(result, line7, texCoord);
result = DrawPoint(result, line8, texCoord);
result = DrawPoint(result, line9, texCoord);
result = DrawPoint(result, line10, texCoord);
#line 474
return result;
}
#line 477
float3 DrawRailmanRatio(float3 background, float3 gridColor, float lineWidth, float2 texCoord) {
float3 result;
#line 480
sctpoint line1 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x, texCoord.x));
sctpoint line2 = NewPoint(gridColor, lineWidth + 0.6, float2(texCoord.x, 1.0 - texCoord.x));
#line 483
sctpoint lineV1 = NewPoint(gridColor, lineWidth, float2(1.0 / 4.0, texCoord.y));
sctpoint lineV2 = NewPoint(gridColor, lineWidth, float2(2.0 / 4.0, texCoord.y));
sctpoint lineV3 = NewPoint(gridColor, lineWidth, float2(3.0 / 4.0, texCoord.y));
#line 487
result = DrawPoint(background, line1, texCoord);
result = DrawPoint(result, line2, texCoord);
result = DrawPoint(result, lineV1, texCoord);
result = DrawPoint(result, lineV2, texCoord);
result = DrawPoint(result, lineV3, texCoord);
#line 493
return result;
}
#line 496
void PS_DrawLine(in float4 pos : SV_Position, float2 texCoord : TEXCOORD, out float4 passColor : SV_Target) {
const float4 backColor = tex2D(ReShade::BackBuffer, texCoord);
switch(cLayerVPre_Composition)
{
default:
passColor = float4(backColor.rgb, backColor.a);
break;
case 1:
const float3 VPreCenter = DrawCenterLines(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreCenter.rgb, UIGridColor.w).rgb, backColor.a);
break;
case 2:
const float3 VPreThirds = DrawThirds(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreThirds.rgb, UIGridColor.w).rgb, backColor.a);
break;
case 3:
const float3 VPreFourth = DrawFourth(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreFourth.rgb, UIGridColor.w).rgb, backColor.a);
break;
case 4:
const float3 VPreFifths = DrawFifths(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreFifths.rgb, UIGridColor.w).rgb, backColor.a);
break;
case 5:
const float3 VPreGolden = DrawGoldenRatio(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreGolden.rgb, UIGridColor.w).rgb, backColor.a);
break;
case 6:
const float3 VPreSilver = DrawSilverRatio(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreSilver.rgb, UIGridColor.w).rgb, backColor.a);
break;
case 7:
const float3 VPreDiagonalsOne = DrawDiagonalsOne(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreDiagonalsOne.rgb, UIGridColor.w).rgb, backColor.a);
break;
case 8:
const float3 VPreDiagonalsTwo = DrawDiagonalsTwo(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreDiagonalsTwo.rgb, UIGridColor.w).rgb, backColor.a);
break;
case 9:
const float3 VPreGoldenSection = DrawGoldenSection(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreGoldenSection.rgb, UIGridColor.w).rgb, backColor.a);
break;
case 10:
const float3 VPreOneHalfRectangle = DrawOneHalfRectangle(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreOneHalfRectangle.rgb, UIGridColor.w).rgb, backColor.a);
break;
case 11:
const float3 VPreHarmonicArmature = DrawHarmonicArmature(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreHarmonicArmature.rgb, UIGridColor.w).rgb, backColor.a);
break;
case 12:
const float3 VPreRailman = DrawRailmanRatio(backColor.rgb, UIGridColor.rgb, UIGridLineWidth, texCoord);
passColor = float4(lerp(backColor.rgb, VPreRailman.rgb, UIGridColor.w).rgb, backColor.a);
break;
}
}
#line 554
float3 DrawLineARatio(float3 background, float3 gridColorARatio, float lineWidthARatio, float2 texCoord) {
float3 result;
#line 557
sctpoint lineV1 = NewPoint(gridColorARatio, lineWidthARatio, float2(((1920 / 1018) * 0.5) * 0.25, texCoord.y));
sctpoint lineH1 = NewPoint(gridColorARatio, lineWidthARatio, float2(((1920 / 1018) * 0.5) * 1.75, texCoord.y));
#line 560
result = DrawPoint(background, lineV1, texCoord);
result = DrawPoint(result, lineH1, texCoord);
#line 563
return result;
}
#line 566
float3 DrawLineARatio_2(float3 background, float3 gridColorARatio, float lineWidthARatio, float2 texCoord) {
float3 result;
#line 569
sctpoint lineV1 = NewPoint(gridColorARatio, lineWidthARatio, float2(((1920 / 1018) * 0.5) * 0.35, texCoord.y));
sctpoint lineH1 = NewPoint(gridColorARatio, lineWidthARatio, float2(((1920 / 1018) * 0.5) * 1.65, texCoord.y));
#line 572
result = DrawPoint(background, lineV1, texCoord);
result = DrawPoint(result, lineH1, texCoord);
#line 575
return result;
}
#line 578
float3 DrawLineARatio_3(float3 background, float3 gridColorARatio, float lineWidthARatio, float2 texCoord) {
float3 result;
#line 581
sctpoint lineV1 = NewPoint(gridColorARatio, lineWidthARatio, float2(((1920 / 1018) * 0.5) * 0.69, texCoord.y));
sctpoint lineH1 = NewPoint(gridColorARatio, lineWidthARatio, float2(((1920 / 1018) * 0.5) * 1.31, texCoord.y));
#line 584
result = DrawPoint(background, lineV1, texCoord);
result = DrawPoint(result, lineH1, texCoord);
#line 587
return result;
}
#line 590
float3 DrawLineARatio_4(float3 background, float3 gridColorARatio, float lineWidthARatio, float2 texCoord) {
float3 result;
#line 593
sctpoint lineV1 = NewPoint(gridColorARatio, lineWidthARatio, float2(((1920 / 1018) * 0.5) * 0.514, texCoord.y));
sctpoint lineH1 = NewPoint(gridColorARatio, lineWidthARatio, float2(((1920 / 1018) * 0.5) * 1.486, texCoord.y));
#line 596
result = DrawPoint(background, lineV1, texCoord);
result = DrawPoint(result, lineH1, texCoord);
#line 599
return result;
}
#line 602
float3 DrawLineARatio_5(float3 background, float3 gridColorARatio, float lineWidthARatio, float2 texCoord) {
float3 result;
#line 605
sctpoint lineV1 = NewPoint(gridColorARatio, lineWidthARatio, float2(((1920 / 1018) * 0.5) * 0.5, texCoord.y));
sctpoint lineH1 = NewPoint(gridColorARatio, lineWidthARatio, float2(((1920 / 1018) * 0.5) * 1.5, texCoord.y));
#line 608
result = DrawPoint(background, lineV1, texCoord);
result = DrawPoint(result, lineH1, texCoord);
#line 611
return result;
}
#line 614
void PS_DrawLineARatio(in float4 pos : SV_Position, float2 texCoord : TEXCOORD, out float4 passColor : SV_Target) {
const float4 backColor = tex2D(samplerDraw, texCoord);
switch(cLayerVPre_CompositionARatio)
{
default:
passColor = float4(backColor.rgb, backColor.a);
break;
case 1:
const float3 DrawLineARatio = DrawLineARatio(backColor.rgb, UIGridColorARatio.rgb, UIGridLineWidthARatio, texCoord);
passColor = float4(lerp(backColor.rgb, DrawLineARatio.rgb, UIGridColorARatio.w).rgb, backColor.a);
break;
case 2:
const float3 DrawLineARatio_2 = DrawLineARatio_2(backColor.rgb, UIGridColorARatio.rgb, UIGridLineWidthARatio, texCoord);
passColor = float4(lerp(backColor.rgb, DrawLineARatio_2.rgb, UIGridColorARatio.w).rgb, backColor.a);
break;
case 3:
const float3 DrawLineARatio_3 = DrawLineARatio_3(backColor.rgb, UIGridColorARatio.rgb, UIGridLineWidthARatio, texCoord);
passColor = float4(lerp(backColor.rgb, DrawLineARatio_3.rgb, UIGridColorARatio.w).rgb, backColor.a);
break;
case 4:
const float3 DrawLineARatio_4 = DrawLineARatio_4(backColor.rgb, UIGridColorARatio.rgb, UIGridLineWidthARatio, texCoord);
passColor = float4(lerp(backColor.rgb, DrawLineARatio_4.rgb, UIGridColorARatio.w).rgb, backColor.a);
break;
case 5:
const float3 DrawLineARatio_5 = DrawLineARatio_5(backColor.rgb, UIGridColorARatio.rgb, UIGridLineWidthARatio, texCoord);
passColor = float4(lerp(backColor.rgb, DrawLineARatio_5.rgb, UIGridColorARatio.w).rgb, backColor.a);
break;
}
}
#line 644
float3 bri(float3 backColor, float x)
{
#line 647
const float3 c = 1.0 - ( 1.0 - backColor.rgb ) * ( 1.0 - backColor.rgb );
if (x < 0.0) {
x = x * 0.5;
}
return saturate( lerp( backColor.rgb, c.rgb, x ));
}
#line 654
void PS_VPreOut(in float4 pos : SV_Position, float2 texCoord : TEXCOORD, out float4 passColor : SV_Target) {
if (VPreToggle) {
passColor = tex2D(ReShade::BackBuffer, texCoord);
}
else {
const float3 pivot = float3(0.5, 0.5, 0.0);
const float3 mulUV = float3(texCoord.x, texCoord.y, 1);
const float2 ScaleSize = (float2(1920, 1018) * cLayerVPre_Scale);
const float ScaleX =  ScaleSize.x * cLayerVPre_Scale;
const float ScaleY =  ScaleSize.y * cLayerVPre_Scale;
#line 665
float Rotate = 0;
switch(cLayerVPre_Angle)
{
case 0:
Rotate = -90.0 * (3.1415926 / 180.0);
break;
case 1:
Rotate = 0;
break;
case 2:
Rotate = 90.0 * (3.1415926 / 180.0);
break;
case 3:
Rotate = 180 * (3.1415926 / 180.0);
break;
case 4:
Rotate = 0;
break;
}
#line 685
const float3x3 positionMatrix = float3x3 (
1, 0, 0,
0, 1, 0,
-cLayerVPre_PosX, -cLayerVPre_PosY, 1
);
#line 692
const float3x3 scaleMatrix = float3x3 (
1/ScaleX, 0, 0,
0,  1/ScaleY, 0,
0, 0, 1
);
#line 698
const float3x3 rotateMatrix = float3x3 (
cos (Rotate), -sin(Rotate), 0,
sin(Rotate), cos(Rotate), 0,
0, 0, 1
);
#line 704
float3 SumUV = mul (mul (mul (mulUV, positionMatrix) * float3(float2(1920, 1018), 1.0), rotateMatrix), scaleMatrix);
float4 backColor = tex2D(samplerDrawARatio, texCoord);
switch (cLayerVPre_Angle) {
default:
const float4 Void = float4(0.0, 0.0, 0.0, 1.0) * all(SumUV + pivot == saturate(SumUV + pivot));
const float4 VPreOut = tex2D(samplerDrawARatio, SumUV.rg + pivot.rg) * all(SumUV + pivot == saturate(SumUV + pivot));
const float FillValue = cLayer_Blend_BGFill + 0.5;
if (cLayer_Blend_BGFill != 0.0) {
backColor.rgb = lerp(2 * backColor.rgb * FillValue, 1.0 - 2 * (1.0 - backColor.rgb) * (1.0 - FillValue), step(0.5, FillValue));
}
passColor = VPreOut + lerp(backColor, Void, Void.a);
break;
case 4:
passColor = backColor;
break;
}
}
}
#line 727
technique Vertical_Previewer <
ui_label = "Vertical Previewer and Composition (Hidden In Screenshots)";
enabled_in_screenshot = false;
ui_tooltip = "+++ Vertical Previewer and Composition +++\n"
"***バーチカル プレビュワー アンド コンポジション***\n\n"
"By showing a preview on the screen to protect\n"
"your neck while taking vertical screenshots.\n\n"
"      Can be used as a composition guide\n"
"   or a small preview window overlooking\n"
"     whole screen with your preference.\n\n"
"     Recommend adding to your hotkeys\n"
" by right click from here for easy access."; >
{
pass pass0
{
VertexShader = PostProcessVS;
PixelShader = PS_DrawLine;
RenderTarget = texDraw;
}
pass pass1
{
VertexShader = PostProcessVS;
PixelShader = PS_DrawLineARatio;
RenderTarget = texDrawARatio;
}
pass pass2
{
VertexShader = PostProcessVS;
PixelShader = PS_VPreOut;
}
#line 758
}
#line 760
technique Vertical_Previewer_S <
ui_label = "Vertical Previewer and Composition (Visible In Screenshots)";
ui_tooltip = "+++ Vertical Previewer and Composition +++\n"
"***バーチカル プレビュワー アンド コンポジション***\n\n"
"By showing a preview on the screen to protect\n"
"your neck while taking vertical screenshots.\n\n"
"      Can be used as a composition guide\n"
"   or a small preview window overlooking\n"
"     whole screen with your preference.\n\n"
"     Recommend adding to your hotkeys\n"
" by right click from here for easy access."; >
{
pass pass0
{
VertexShader = PostProcessVS;
PixelShader = PS_DrawLine;
RenderTarget = texDraw;
}
pass pass1
{
VertexShader = PostProcessVS;
PixelShader = PS_DrawLineARatio;
RenderTarget = texDrawARatio;
}
pass pass2
{
VertexShader = PostProcessVS;
PixelShader = PS_VPreOut;
}
#line 790
}

