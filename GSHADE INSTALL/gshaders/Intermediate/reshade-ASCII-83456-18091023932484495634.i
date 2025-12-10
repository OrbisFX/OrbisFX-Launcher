#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ASCII.fx"
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
#line 72 "C:\Program Files\GShade\gshade-shaders\Shaders\ASCII.fx"
#line 78
uniform int Ascii_spacing <
ui_type = "slider";
ui_min = 0;
ui_max = 5;
ui_label = "Character Spacing";
ui_tooltip = "Determines the spacing between characters. I feel 1 to 3 looks best.";
ui_category = "Font style";
> = 1;
#line 87
uniform int Ascii_font <
ui_type = "combo";
ui_label = "Font Size";
ui_tooltip = "Choose font size";
ui_category = "Font style";
ui_items =
"Smaller 3x5 font\0"
"Normal 5x5 font\0"
;
> = 1;
#line 98
uniform int Ascii_font_color_mode <
ui_type = "slider";
ui_min = 0;
ui_max = 2;
ui_label = "Font Color Mode";
ui_tooltip = "0 = Foreground color on background color, 1 = Colorized grayscale, 2 = Full color";
ui_category = "Color options";
> = 1;
#line 107
uniform float3 Ascii_font_color <
ui_type = "color";
ui_label = "Font Color";
ui_tooltip = "Choose a font color";
ui_category = "Color options";
> = float3(1.0, 1.0, 1.0);
#line 114
uniform float3 Ascii_background_color <
ui_type = "color";
ui_label = "Background Color";
ui_tooltip = "Choose a background color";
ui_category = "Color options";
> = float3(0.0, 0.0, 0.0);
#line 121
uniform bool Ascii_swap_colors <
ui_label = "Swap Colors";
ui_tooltip = "Swaps the font and background color when you are too lazy to edit the settings above (I know I am)";
ui_category = "Color options";
> = 0;
#line 127
uniform bool Ascii_invert_brightness <
ui_label = "Invert Brightness";
ui_category = "Color options";
> = 0;
#line 132
uniform bool Ascii_dithering <
ui_label = "Dithering";
ui_category = "Dithering";
> = 1;
#line 137
uniform float Ascii_dithering_intensity <
ui_type = "slider";
ui_min = 0.0;
ui_max = 4.0;
ui_label = "Dither shift intensity";
ui_tooltip = "For debugging purposes";
ui_category = "Debugging";
> = 2.0;
#line 146
uniform bool Ascii_dithering_debug_gradient <
ui_label = "Dither debug gradient";
ui_category = "Debugging";
> = 0;
#line 157
uniform float timer < source = "timer"; >;
uniform float framecount < source = "framecount"; >;
#line 186
int charindex( float quant, float gray, int chararraylen )
{
float q = quant;
int index = 0;
#line 191
[unroll]
for ( int i = 0; i < chararraylen; i++ )
{
q += quant;
index += step( q, gray );
}
#line 198
return index;
}
#line 209
float3 AsciiPass( float2 tex )
{
#line 216
float2 Ascii_font_size = float2(3.0,5.0); 
float num_of_chars = 14. ;
#line 219
if (Ascii_font == 1)
{
Ascii_font_size = float2(5.0,5.0); 
num_of_chars = 17.;
}
#line 225
float quant = 1.0/(num_of_chars-1.0); 
#line 227
const float2 Ascii_block = Ascii_font_size + float(Ascii_spacing);
const float2 cursor_position = trunc((float2(1920, 1018) / Ascii_block) * tex) * (Ascii_block / float2(1920, 1018));
#line 231
const float2 cp15 = cursor_position + float2((1.0 / 1920), (1.0 / 1018)) * 1.5;
const float2 cp35 = cursor_position + float2((1.0 / 1920), (1.0 / 1018)) * 3.5;
const float2 cp55 = cursor_position + float2((1.0 / 1920), (1.0 / 1018)) * 5.5;
#line 235
float3 color = tex2D(ReShade::BackBuffer, float2( cp15.x, cp15.y )).rgb;
color += tex2D(ReShade::BackBuffer, float2( cp15.x, cp35.y )).rgb;
color += tex2D(ReShade::BackBuffer, float2( cp15.x, cp55.y )).rgb;
color += tex2D(ReShade::BackBuffer, float2( cp35.x, cp15.y )).rgb;
color += tex2D(ReShade::BackBuffer, float2( cp35.x, cp35.y )).rgb;
color += tex2D(ReShade::BackBuffer, float2( cp35.x, cp55.y )).rgb;
color += tex2D(ReShade::BackBuffer, float2( cp55.x, cp15.y )).rgb;
color += tex2D(ReShade::BackBuffer, float2( cp55.x, cp35.y )).rgb;
color += tex2D(ReShade::BackBuffer, float2( cp55.x, cp55.y )).rgb;
#line 247
color /= 9.0;
#line 253
float gray = dot(color,float3(0.2126, 0.7152, 0.0722));
#line 255
if (Ascii_invert_brightness)
gray = 1.0 - gray;
#line 263
if (Ascii_dithering_debug_gradient)
{
gray = cursor_position.x; 
}
#line 272
const float2 p = trunc(frac((float2(1920, 1018) / Ascii_block) * tex) * Ascii_block); 
#line 274
const float x = (Ascii_font_size.x * p.y + p.x); 
#line 282
if (Ascii_dithering != 0)
{
#line 286
const float seed = dot(cursor_position, float2(12.9898,78.233)); 
const float sine = sin(seed); 
const float noise = frac(sine * 43758.5453 + cursor_position.y);
#line 290
float dither_shift = (quant * Ascii_dithering_intensity); 
#line 292
const float dither_shift_half = (dither_shift * 0.5); 
dither_shift = dither_shift * noise - dither_shift_half; 
#line 296
gray += dither_shift; 
}
#line 303
float n = 0;
#line 305
if (Ascii_font == 1)
{
#line 316
float	chars[16];
chars[0]  = 4194304.0;
chars[1]  = 131200.00;
chars[2]  = 324.00000;
chars[3]  = 330.00000;
chars[4]  = 283712.00;
chars[5]  = 12650880.;
chars[6]  = 4532768.0;
chars[7]  = 13191552.;
chars[8]  = 10648704.;
chars[9]  = 11195936.;
chars[10] = 15218734.;
chars[11] = 15255086.;
chars[12] = 15252014.;
chars[13] = 32294446.;
chars[14] = 15324974.;
chars[15] = 11512810.;
#line 338
const float4	charsA = float4(  2.,  3.,  4.,  5. )	* quant;
const float4	charsB = float4(  6.,  7.,  8.,  9. )	* quant;
const float4	charsC = float4( 10., 11., 12., 13. )	* quant;
const float3	charsD = float3( 14., 15., 16.) 	* quant;
#line 343
int		index  = dot( step( charsA, gray ), 1 );
index += dot( step( charsB, gray ), 1 );
index += dot( step( charsC, gray ), 1 );
index += dot( step( charsD, gray ), 1 );
#line 351
n = chars[index];
#line 353
}
else 
{
#line 396
float	chars[13];
chars[0]  = 4096.0;
chars[1]  = 1040.0;
chars[2]  = 5136.0;
chars[3]  = 5200.0;
chars[4]  = 2728.0;
chars[5]  = 11088.;
chars[6]  = 14478.;
chars[7]  = 11114.;
chars[8]  = 23213.;
chars[9]  = 15211.;
chars[10] = 23533.;
chars[11] = 31599.;
chars[12] = 31727.;
#line 427
const float4	charsA = float4(  2.,  3.,  4.,  5. ) * quant;
const float4	charsB = float4(  6.,  7.,  8.,  9. ) * quant;
const float4	charsC = float4( 10., 11., 12., 13. ) * quant;
#line 431
int		index  = dot( step( charsA, gray ), 1 );
index += dot( step( charsB, gray ), 1 );
index += dot( step( charsC, gray ), 1 );
#line 438
n = chars[index];
}
#line 446
float character = 0.0;
#line 454
float lit = 1.0;
if (gray <= 1.0 * quant)
lit = 0.0;
#line 459
float signbit = 0.0;
if (n < 0.0)
signbit = lit;
#line 466
if (x < 23.5)
signbit = 0.0;
#line 471
if (frac(abs(n*exp2(-x-1.0))) >= 0.5) 
character = lit;
else
character = signbit;
#line 477
const float2 clampP = clamp(p.xy, 0.0, Ascii_font_size.xy);
#line 480
if (clampP.x != p.x || clampP.y != p.y)
character = 0.0;
#line 488
if (Ascii_swap_colors)
{
switch (Ascii_font_color_mode)
{
case 1:
if (character)
color = Ascii_background_color;
else
color = Ascii_font_color;
break;
case 2:
if (character == 0.0)
color = Ascii_font_color;
break;
default:
if (character)
color = Ascii_background_color;
else
color = Ascii_font_color;
break;
}
}
else
{
switch (Ascii_font_color_mode)
{
case 1:
if (character)
color = Ascii_font_color * gray;
else
color = Ascii_background_color;
break;
case 2:
if (character == 0.0)
color = Ascii_background_color;
break;
default:
if (character)
color = Ascii_font_color;
else
color = Ascii_background_color;
break;
}
}
#line 538
return saturate(color);
}
#line 542
float3 PS_Ascii(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return AsciiPass(texcoord).rgb;
}
#line 548
technique ASCII
{
pass ASCII
{
VertexShader=PostProcessVS;
PixelShader=PS_Ascii;
}
}

