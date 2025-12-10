#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FineSharp.fx"
#line 17
uniform float sstr <
ui_type = "slider";
ui_min = 0.00; ui_max = 8.00;
ui_label = "Sharpening Strength";
> = 2.00;
#line 23
uniform float cstr <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.249;
ui_label = "Equalization Strength";
ui_tooltip = "Suggested settings for cstr based on sstr value: sstr=0->cstr=0, sstr=0.5->cstr=0.1, 1.0->0.6, 2.0->0.9, 2.5->1.00, 3.0->1.09, 3.5->1.15, 4.0->1.19, 8.0->1.249";
> = 0.90;
#line 30
uniform float xstr <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Strength of XSharpen-style final sharpening.";
> = 0.19;
#line 36
uniform float xrep <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Repair artefacts from final sharpening. (-Vit- addition to original script)";
> = 0.25;
#line 42
uniform float lstr <
ui_type = "input";
ui_tooltip = "Modifier for non-linear sharpening";
> = 1.49;
#line 47
uniform float pstr <
ui_type = "input";
ui_tooltip = "Exponent for non-linear sharpening";
> = 1.272;
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
#line 59 "C:\Program Files\GShade\gshade-shaders\Shaders\FineSharp.fx"
#line 62
float4 Src(float a, float b, float2 tex) {
return tex2D(ReShade::BackBuffer, mad(float2((1.0 / 1920), (1.0 / 1018)), float2(a, b), tex));
}
#line 66
float3x3 RGBtoYUV(float Kb, float Kr) {
return float3x3(float3(Kr, 1.0 - Kr - Kb, Kb), float3(-Kr, Kr + Kb - 1.0, 1.0 - Kb) / (2.0 * (1.0 - Kb)), float3(1.0 - Kr, Kr + Kb - 1.0, -Kb) / (2.0 * (1.0 - Kr)));
}
#line 70
float3x3 YUVtoRGB(float Kb, float Kr) {
return float3x3(float3(1.0, 0.0, 2.0 * (1.0 - Kr)), float3(Kb + Kr - 1.0, 2.0 * (1.0 - Kb) * Kb, 2 * Kr * (1.0 - Kr)) / (Kb + Kr - 1.0), float3(1.0, 2.0 * (1.0 - Kb), 0.0));
}
#line 74
void sort(inout float a1, inout float a2) {
const float t = min(a1, a2);
a2 = max(a1, a2);
a1 = t;
}
#line 80
float median3(float a1, float a2, float a3) {
sort(a2, a3);
sort(a1, a2);
#line 84
return min(a2, a3);
}
#line 87
float median5(float a1, float a2, float a3, float a4, float a5) {
sort(a1, a2);
sort(a3, a4);
sort(a1, a3);
sort(a2, a4);
#line 93
return median3(a2, a3, a5);
}
#line 96
float median9(float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8, float a9) {
sort(a1, a2);
sort(a3, a4);
sort(a5, a6);
sort(a7, a8);
sort(a1, a3);
sort(a5, a7);
sort(a1, a5);
#line 105
sort(a3, a5);
sort(a3, a7);
sort(a2, a4);
sort(a6, a8);
sort(a4, a8);
sort(a4, a6);
sort(a2, a6);
#line 113
return median5(a2, a4, a5, a7, a9);
}
#line 116
void sort_min_max7(inout float a1, inout float a2, inout float a3, inout float a4, inout float a5, inout float a6, inout float a7) {
sort(a1, a2);
sort(a3, a4);
sort(a5, a6);
#line 121
sort(a1, a3);
sort(a1, a5);
sort(a2, a6);
#line 125
sort(a4, a5);
sort(a1, a7);
sort(a6, a7);
}
#line 130
void sort_min_max9(inout float a1, inout float a2, inout float a3, inout float a4, inout float a5, inout float a6, inout float a7, inout float a8, inout float a9) {
sort(a1, a2);
sort(a3, a4);
sort(a5, a6);
sort(a7, a8);
#line 136
sort(a1, a3);
sort(a5, a7);
sort(a1, a5);
sort(a2, a4);
#line 141
sort(a6, a7);
sort(a4, a8);
sort(a1, a9);
sort(a8, a9);
}
#line 147
void sort9_partial2(inout float a1, inout float a2, inout float a3, inout float a4, inout float a5, inout float a6, inout float a7, inout float a8, inout float a9) {
sort_min_max9(a1,a2,a3,a4,a5,a6,a7,a8,a9);
sort_min_max7(a2,a3,a4,a5,a6,a7,a8);
}
#line 153
float SharpDiff(float4 c) {
const float t = c.a - c.x;
return sign(t) * (sstr / 255.0) * pow(abs(abs(t) / (abs(lstr / 255.0))), 1.0 / pstr) * ((t * t) / mad(t, t, (sstr+0.1) / 65025.0));
}
#line 160
float4 PS_FineSharp_P0(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
const float3 yuv = mul(RGBtoYUV(0.0722, 0.2126), Src(0.0, 0.0, texcoord).rgb ) + float3(0.0, 0.5, 0.5);
return float4(yuv, yuv.x);
}
#line 165
float4 PS_FineSharp_P1(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
float4 o = Src(0.0, 0.0, texcoord);
#line 168
o.x += o.x;
o.x += Src( 0.0, -1.0, texcoord).x + Src(-1.0,  0.0, texcoord).x + Src( 1.0, 0.0, texcoord).x + Src(0.0, 1.0, texcoord).x;
o.x += o.x;
o.x += Src(-1.0, -1.0, texcoord).x + Src( 1.0, -1.0, texcoord).x + Src(-1.0, 1.0, texcoord).x + Src(1.0, 1.0, texcoord).x;
o.x *= 0.0625;
#line 174
return o;
}
#line 177
float4 PS_FineSharp_P2(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
float4 o = Src(0.0, 0.0, texcoord);
#line 180
const float t1 = Src(-1.0, -1.0, texcoord).x;
const float t2 = Src( 0.0, -1.0, texcoord).x;
const float t3 = Src( 1.0, -1.0, texcoord).x;
const float t4 = Src(-1.0,  0.0, texcoord).x;
const float t5 = o.x;
const float t6 = Src( 1.0,  0.0, texcoord).x;
const float t7 = Src(-1.0,  1.0, texcoord).x;
const float t8 = Src( 0.0,  1.0, texcoord).x;
const float t9 = Src( 1.0,  1.0, texcoord).x;
o.x = median9(t1,t2,t3,t4,t5,t6,t7,t8,t9);
#line 191
return o;
}
#line 194
float4 PS_FineSharp_P3(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
float4 o = Src(0.0, 0.0, texcoord);
#line 197
float sd = SharpDiff(o);
o.x = o.a + sd;
sd += sd;
sd += SharpDiff(Src( 0.0, -1.0, texcoord)) + SharpDiff(Src(-1.0,  0.0, texcoord)) + SharpDiff(Src( 1.0, 0.0, texcoord)) + SharpDiff(Src( 0.0, 1.0, texcoord));
sd += sd;
sd += SharpDiff(Src(-1.0, -1.0, texcoord)) + SharpDiff(Src( 1.0, -1.0, texcoord)) + SharpDiff(Src(-1.0, 1.0, texcoord)) + SharpDiff(Src( 1.0, 1.0, texcoord));
sd *= 0.0625;
o.x -= cstr * sd;
o.a = o.x;
#line 207
return o;
}
#line 210
float4 PS_FineSharp_P4(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
float4 o = Src(0.0, 0.0, texcoord);
#line 213
float t1 = Src(-1.0, -1.0, texcoord).a;
float t2 = Src( 0.0, -1.0, texcoord).a;
float t3 = Src( 1.0, -1.0, texcoord).a;
float t4 = Src(-1.0,  0.0, texcoord).a;
float t5 = o.a;
float t6 = Src( 1.0,  0.0, texcoord).a;
float t7 = Src(-1.0,  1.0, texcoord).a;
float t8 = Src( 0.0,  1.0, texcoord).a;
float t9 = Src( 1.0,  1.0, texcoord).a;
#line 223
o.x += t1 + t2 + t3 + t4 + t6 + t7 + t8 + t9;
o.x /= 9.0;
o.x = mad(9.9, (o.a - o.x), o.a);
#line 227
sort9_partial2(t1, t2, t3, t4, t5, t6, t7, t8, t9);
o.x = max(o.x, min(t2, o.a));
o.x = min(o.x, max(t8, o.a));
#line 231
return o;
}
#line 234
float4 PS_FineSharp_P5(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
float4 o = Src(0.0, 0.0, texcoord);
#line 237
const float edge = abs(Src(0.0, -1.0, texcoord).x + Src(-1.0, 0.0, texcoord).x + Src(1.0, 0.0, texcoord).x + Src(0.0, 1.0, texcoord).x - 4 * o.x);
o.x = lerp(o.a, o.x, xstr * (1.0 - saturate(edge * xrep)));
#line 240
return o;
}
#line 243
float4 PS_FineSharp_P6(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
float4 rgb = Src(0.0, 0.0, texcoord);
rgb.xyz = mul(YUVtoRGB(0.0722,0.2126), rgb.xyz - float3(0.0, 0.5, 0.5));
return rgb;
}
#line 249
technique Mode1
{
pass ToYUV
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P0;
}
#line 257
pass RemoveGrain11
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P1;
}
#line 263
pass RemoveGrain4
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P2;
}
#line 269
pass FineSharpA
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P3;
}
#line 275
pass FineSharpB
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P4;
}
#line 281
pass FineSharpC
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P5;
}
#line 287
pass ToRGB
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P6;
}
}
#line 294
technique Mode2
{
pass ToYUV
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P0;
}
#line 302
pass RemoveGrain4
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P2;
}
#line 308
pass RemoveGrain11
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P1;
}
#line 314
pass FineSharpA
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P3;
}
#line 320
pass FineSharpB
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P4;
}
#line 326
pass FineSharpC
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P5;
}
#line 332
pass ToRGB
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P6;
}
}
#line 339
technique Mode3
{
pass ToYUV
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P0;
}
#line 347
pass RemoveGrain4_1
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P2;
}
#line 353
pass RemoveGrain11
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P1;
}
#line 359
pass RemoveGrain4_2
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P2;
}
#line 365
pass FineSharpA
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P3;
}
#line 371
pass FineSharpB
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P4;
}
#line 377
pass FineSharpC
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P5;
}
#line 383
pass ToRGB
{
VertexShader = PostProcessVS;
PixelShader = PS_FineSharp_P6;
}
}

