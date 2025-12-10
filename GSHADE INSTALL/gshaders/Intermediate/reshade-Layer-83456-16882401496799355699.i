// LAYER_QUANTITY=0
// LAYER_SIZE_Y=BUFFER_HEIGHT
// LAYER_SIZE_X=BUFFER_WIDTH
// LayerTex="LayerStage.png"
// LAYER_TEXFORMAT=RGBA8
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Layer.fx"
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
#line 70 "C:\Program Files\GShade\gshade-shaders\Shaders\Layer.fx"
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
#line 71 "C:\Program Files\GShade\gshade-shaders\Shaders\Layer.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Layer.fxh"
#line 72 "C:\Program Files\GShade\gshade-shaders\Shaders\Layer.fx"
#line 86
uniform int Layer_Quantity <
ui_type = "combo";
ui_label = "Number of Layers";
ui_tooltip = "The number of Layer techniques to generate. Enabling too many of these in a DirectX 9 game or on lower end hardware is a very, very bad idea.";
ui_items =  "1\0"
"2\0"
"3\0"
"4\0"
"5\0"
"6\0"
"7\0"
"8\0"
"9\0"
"10\0"
"11\0"
"12\0"
"13\0"
"14\0"
"15\0"
"16\0"
"17\0"
"18\0"
"19\0"
"20\0";
ui_bind = "LAYER_QUANTITY";
> = 0;
#line 117
texture Layer_Texture <source = "LayerStage.png";> { Width = 1920; Height = 1018; Format=RGBA8; }; sampler Layer_Sampler { Texture = Layer_Texture; AddressU = CLAMP; AddressV = CLAMP; }; uniform float Layer_Saturation < ui_category = "Layer 1"; ui_type = "slider"; ui_label = "Saturation"; ui_tooltip = "The amount of saturation applied to the layer."; ui_min = 0.0; ui_max = 2.0; > = 1.0; uniform float Layer_Brightness < ui_category = "Layer 1"; ui_type = "slider"; ui_label = "Brightness"; ui_tooltip = "The amount of brightness applied to the layer."; ui_min = -2.0; ui_max = 2.0; > = 0.0; uniform int Layer_BlendMode < ui_category = "Layer 1"; ui_category_closed = true; ui_items = "Normal\0" "Darken\0" "  Multiply\0" "  Color Burn\0" "  Linear Burn\0" "Lighten\0" "  Screen\0" "  Color Dodge\0" "  Linear Dodge\0" "  Addition\0" "  Glow\0" "Overlay\0" "  Soft Light\0" "  Hard Light\0" "  Vivid Light\0" "  Linear Light\0" "  Pin Light\0" "  Hard Mix\0" "Difference\0" "  Exclusion\0" "Subtract\0" "  Divide\0" "  Divide (Alternative)\0" "  Divide (Photoshop)\0" "  Reflect\0" "  Grain Extract\0" "  Grain Merge\0" "Hue\0" "  Saturation\0" "  Color\0" "  Luminosity\0"; ui_label = "Blending Mode"; ui_tooltip = "Select the blending mode applied to the layer."; ui_type = "combo"; ui_spacing = 0; > = 0; uniform float Layer_Blend < ui_category = "Layer 1"; ui_label = "Blending Amount"; ui_tooltip = "The amount of blending applied to the layer."; ui_type = "slider"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; > = 1.0; uniform float Layer_Scale < ui_category = "Layer 1"; ui_type = "slider"; ui_label = "Scale X & Y"; ui_min = 0.001; ui_max = 5.0; ui_step = 0.001; > = 1.001; uniform float Layer_ScaleX < ui_category = "Layer 1"; ui_type = "slider"; ui_label = "Scale X"; ui_min = 0.001; ui_max = 5.0; ui_step = 0.001; > = 1.0; uniform float Layer_ScaleY < ui_category = "Layer 1"; ui_type = "slider"; ui_label = "Scale Y"; ui_min = 0.001; ui_max = 5.0; ui_step = 0.001; > = 1.0; uniform float Layer_PosX < ui_category = "Layer 1"; ui_type = "slider"; ui_label = "Position X"; ui_min = -2.0; ui_max = 2.0; ui_step = 0.001; > = 0.5; uniform float Layer_PosY < ui_category = "Layer 1"; ui_type = "slider"; ui_label = "Position Y"; ui_min = -2.0; ui_max = 2.0; ui_step = 0.001; > = 0.5; uniform int Layer_SnapRotate < ui_category = "Layer 1"; ui_type = "combo"; ui_label = "Snap Rotation"; ui_items = "None\0" "90 Degrees\0" "-90 Degrees\0" "180 Degrees\0" "-180 Degrees\0"; ui_tooltip = "Snap rotation to a specific angle."; > = false; uniform float Layer_Rotate < ui_category = "Layer 1"; ui_label = "Rotate"; ui_type = "slider"; ui_min = -180.0; ui_max = 180.0; ui_step = 0.01; > = 0; void PS_Layer(in float4 pos : SV_Position, float2 texCoord : TEXCOORD, out float4 passColor : SV_Target) { const float4 backColor = tex2D(ReShade::BackBuffer, texCoord); const float3 pivot = float3(0.5, 0.5, 0.0); const float3 mulUV = float3(texCoord.x, texCoord.y, 1); const float2 ScaleSize = (float2(1920, 1018) * Layer_Scale); const float ScaleX = ScaleSize.x * Layer_ScaleX; const float ScaleY = ScaleSize.y * Layer_ScaleY; float Rotate = Layer_Rotate * (3.1415926 / 180.0); switch(Layer_SnapRotate) { default: break; case 1: Rotate = -90.0 * (3.1415926 / 180.0); break; case 2: Rotate = 90.0 * (3.1415926 / 180.0); break; case 3: Rotate = 0.0; break; case 4: Rotate = 180.0 * (3.1415926 / 180.0); break; } const float3x3 positionMatrix = float3x3 ( 1, 0, 0, 0, 1, 0, -Layer_PosX, -Layer_PosY, 1 ); const float3x3 scaleMatrix = float3x3 ( 1/ScaleX, 0, 0, 0, 1/ScaleY, 0, 0, 0, 1 ); const float3x3 rotateMatrix = float3x3 ( cos (Rotate), -sin(Rotate), 0, sin(Rotate), cos(Rotate), 0, 0, 0, 1 ); const float3 SumUV = mul (mul (mul (mulUV, positionMatrix) * float3(float2(1920, 1018), 1.0), rotateMatrix), scaleMatrix); passColor = tex2D(Layer_Sampler, SumUV.rg + pivot.rg) * all(SumUV + pivot == saturate(SumUV + pivot)); passColor.rgb = (passColor.rgb - dot(passColor.rgb, 0.333)) * Layer_Saturation + dot(passColor.rgb, 0.333); passColor.rgb = passColor.rgb + Layer_Brightness; passColor = float4(ComHeaders::Blending::Blend(Layer_BlendMode, backColor.rgb, passColor.rgb, passColor.a * Layer_Blend), backColor.a); } technique Layer { pass { VertexShader = PostProcessVS; PixelShader = PS_Layer; } }

