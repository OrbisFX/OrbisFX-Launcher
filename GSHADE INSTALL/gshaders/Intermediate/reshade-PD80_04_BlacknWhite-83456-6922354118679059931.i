#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_BlacknWhite.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_BlacknWhite.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_00_Noise_Samplers.fxh"
#line 29
texture texNoise        < source = "pd80_bluenoise.png"; >       { Width = 512; Height = 512; Format = RGBA8; };
texture texNoiseRGB     < source = "pd80_bluenoise_rgba.png"; >  { Width = 512; Height = 512; Format = RGBA8; };
texture texGaussNoise   < source = "pd80_gaussnoise.png"; >      { Width = 512; Height = 512; Format = RGBA8; };
#line 34
sampler samplerNoise
{
Texture = texNoise;
MipFilter = POINT;
MinFilter = POINT;
MagFilter = POINT;
AddressU = WRAP;
AddressV = WRAP;
AddressW = WRAP;
};
sampler samplerRGBNoise
{
Texture = texNoiseRGB;
MipFilter = POINT;
MinFilter = POINT;
MagFilter = POINT;
AddressU = WRAP;
AddressV = WRAP;
AddressW = WRAP;
};
sampler samplerGaussNoise
{
Texture = texGaussNoise;
MipFilter = POINT;
MinFilter = POINT;
MagFilter = POINT;
AddressU = WRAP;
AddressV = WRAP;
AddressW = WRAP;
};
#line 66
uniform float2 pp < source = "pingpong"; min = 0; max = 128; step = 1; >;
static const float2 dither_uv = float2( 1920, 1018 ) / 512.0f;
#line 69
float4 dither( sampler2D tex, float2 coords, int var, bool enabler, float str, bool motion, float swing )
{
coords.xy    *= dither_uv.xy;
float4 noise  = tex2D( tex, coords.xy );
float mot     = motion ? pp.x + var : 0.0f;
noise         = frac( noise + 0.61803398875f * mot );
noise         = ( noise * 2.0f - 1.0f ) * swing;
return ( enabler ) ? noise * ( str / 255.0f ) : float4( 0.0f, 0.0f, 0.0f, 0.0f );
}
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_BlacknWhite.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_00_Color_Spaces.fxh"
#line 27
float3 HUEToRGB( in float H )
{
return saturate( float3( abs( H * 6.0f - 3.0f ) - 1.0f,
2.0f - abs( H * 6.0f - 2.0f ),
2.0f - abs( H * 6.0f - 4.0f )));
}
#line 34
float3 RGBToHCV( in float3 RGB )
{
#line 37
float4 P         = ( RGB.g < RGB.b ) ? float4( RGB.bg, -1.0f, 2.0f/3.0f ) : float4( RGB.gb, 0.0f, -1.0f/3.0f );
float4 Q1        = ( RGB.r < P.x ) ? float4( P.xyw, RGB.r ) : float4( RGB.r, P.yzx );
float C          = Q1.x - min( Q1.w, Q1.y );
float H          = abs(( Q1.w - Q1.y ) / ( 6.0f * C + 0.000001f ) + Q1.z );
return float3( H, C, Q1.x );
}
#line 44
float3 RGBToHSL( in float3 RGB )
{
RGB.xyz          = max( RGB.xyz, 0.000001f );
float3 HCV       = RGBToHCV(RGB);
float L          = HCV.z - HCV.y * 0.5f;
float S          = HCV.y / ( 1.0f - abs( L * 2.0f - 1.0f ) + 0.000001f);
return float3( HCV.x, S, L );
}
#line 53
float3 HSLToRGB( in float3 HSL )
{
float3 RGB       = HUEToRGB(HSL.x);
float C          = (1.0f - abs(2.0f * HSL.z - 1.0f)) * HSL.y;
return ( RGB - 0.5f ) * C + HSL.z;
}
#line 62
float3 RGBToHSV(float3 c)
{
float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
float4 p = c.g < c.b ? float4(c.bg, K.wz) : float4(c.gb, K.xy);
float4 q = c.r < p.x ? float4(p.xyw, c.r) : float4(c.r, p.yzx);
#line 68
float d = q.x - min(q.w, q.y);
float e = 1.0e-10;
return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
#line 73
float3 HSVToRGB(float3 c)
{
float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}
#line 82
float3 KelvinToRGB( in float k )
{
float3 ret;
float kelvin     = clamp( k, 1000.0f, 40000.0f ) / 100.0f;
if( kelvin <= 66.0f )
{
ret.r        = 1.0f;
ret.g        = saturate( 0.39008157876901960784f * log( kelvin ) - 0.63184144378862745098f );
}
else
{
float t      = max( kelvin - 60.0f, 0.0f );
ret.r        = saturate( 1.29293618606274509804f * pow( max( t, 0.0f ), -0.1332047592f ));
ret.g        = saturate( 1.12989086089529411765f * pow( max( t, 0.0f ), -0.0755148492f ));
}
if( kelvin >= 66.0f )
ret.b        = 1.0f;
else if( kelvin < 19.0f )
ret.b        = 0.0f;
else
ret.b        = saturate( 0.54320678911019607843f * log( kelvin - 10.0f ) - 1.19625408914f );
return ret;
}
#line 108
float3 LinearTosRGB( float3 color )
{
float3 x = color * 12.92f;
float3 y = 1.055f * pow(saturate(color), 1.0f / 2.4f) - 0.055f;
#line 113
float3 clr = color;
clr.r = color.r < 0.0031308f ? x.r : y.r;
clr.g = color.g < 0.0031308f ? x.g : y.g;
clr.b = color.b < 0.0031308f ? x.b : y.b;
#line 118
return clr;
}
#line 121
float3 SRGBToLinear( float3 color )
{
float3 x = color / 12.92f;
float3 y = pow(max((color + 0.055f) / 1.055f, 0.0f), 2.4f);
#line 126
float3 clr = color;
clr.r = color.r <= 0.04045f ? x.r : y.r;
clr.g = color.g <= 0.04045f ? x.g : y.g;
clr.b = color.b <= 0.04045f ? x.b : y.b;
#line 131
return clr;
}
#line 145
float3 pd80_xyz_to_lab( float3 c )
{
#line 148
float3 w       = max( c / float3( 0.95047, 1.0, 1.08883 ), 0.0f );
float3 v;
v.x            = ( w.x >  float( 216.0 / 24389.0 ) ) ? pow( max( w.x, 0.0f ), 1.0 / 3.0 ) : ( float( 24389.0 / 27.0 ) * w.x + 16.0 ) / 116.0;
v.y            = ( w.y >  float( 216.0 / 24389.0 ) ) ? pow( max( w.y, 0.0f ), 1.0 / 3.0 ) : ( float( 24389.0 / 27.0 ) * w.y + 16.0 ) / 116.0;
v.z            = ( w.z >  float( 216.0 / 24389.0 ) ) ? pow( max( w.z, 0.0f ), 1.0 / 3.0 ) : ( float( 24389.0 / 27.0 ) * w.z + 16.0 ) / 116.0;
return float3( 116.0 * v.y - 16.0,
500.0 * ( v.x - v.y ),
200.0 * ( v.y - v.z ));
}
#line 158
float3 pd80_lab_to_xyz( float3 c )
{
float3 v;
v.y            = ( c.x + 16.0 ) / 116.0;
v.x            = c.y / 500.0 + v.y;
v.z            = v.y - c.z / 200.0;
return float3(( v.x * v.x * v.x > float( 216.0 / 24389.0 ) ) ? v.x * v.x * v.x : ( 116.0 * v.x - 16.0 ) / float( 24389.0 / 27.0 ),
( c.x > float( 24389.0 / 27.0 ) * float( 216.0 / 24389.0 ) ) ? v.y * v.y * v.y : c.x / float( 24389.0 / 27.0 ),
( v.z * v.z * v.z > float( 216.0 / 24389.0 ) ) ? v.z * v.z * v.z : ( 116.0 * v.z - 16.0 ) / float( 24389.0 / 27.0 ) ) *
float3( 0.95047, 1.0, 1.08883 );
}
#line 170
float3 pd80_srgb_to_xyz( float3 c )
{
#line 174
const float3x3 mat = float3x3(
0.4124564, 0.3575761, 0.1804375,
0.2126729, 0.7151522, 0.0721750,
0.0193339, 0.1191920, 0.9503041
);
return mul( mat, c );
}
#line 182
float3 pd80_xyz_to_srgb( float3 c )
{
#line 186
const float3x3 mat = float3x3(
3.2404542,-1.5371385,-0.4985314,
-0.9692660, 1.8760108, 0.0415560,
0.0556434,-0.2040259, 1.0572252
);
return mul( mat, c );
}
#line 196
float3 pd80_srgb_to_lab( float3 c )
{
float3 lab = pd80_srgb_to_xyz( c );
lab        = pd80_xyz_to_lab( lab );
return lab / float3( 100.0, 108.0, 108.0 );
}
#line 203
float3 pd80_lab_to_srgb( float3 c )
{
float3 rgb = pd80_lab_to_xyz( c * float3( 100.0, 108.0, 108.0 ));
rgb        = pd80_xyz_to_srgb( max( min( rgb, float3( 0.95047, 1.0, 1.08883 ) ), 0.0 ));
return saturate( rgb );
}
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_BlacknWhite.fx"
#line 33
namespace pd80_blackandwhite
{
#line 38
uniform bool enable_dither <
ui_label = "Enable Dithering";
ui_tooltip = "Enable Dithering";
ui_category = "Global";
> = true;
uniform float dither_strength <
ui_type = "slider";
ui_label = "Dither Strength";
ui_tooltip = "Dither Strength";
ui_category = "Global";
ui_min = 0.0f;
ui_max = 10.0f;
> = 1.0;
uniform float curve_str <
ui_type = "slider";
ui_label = "Contrast Smoothness";
ui_tooltip = "Contrast Smoothness";
ui_category = "Global";
ui_min = 1.0f;
ui_max = 4.0f;
> = 1.5f;
uniform bool show_clip <
ui_label = "Show Clipping Mask";
ui_tooltip = "Show Clipping Mask";
ui_category = "Global";
> = false;
uniform int bw_mode <
ui_label = "Black & White Conversion";
ui_tooltip = "Black & White Conversion";
ui_category = "Black & White Techniques";
ui_type = "combo";
ui_items = "Red Filter\0Green Filter\0Blue Filter\0High Contrast Red Filter\0High Contrast Green Filter\0High Contrast Blue Filter\0Infrared\0Maximum Black\0Maximum White\0Preserve Luminosity\0Neutral Green Filter\0Maintain Contrasts\0High Contrast\0Custom\0";
> = 13;
uniform float redchannel <
ui_type = "slider";
ui_label = "Custom: Red Weight";
ui_tooltip = "Custom: Red Weight";
ui_category = "Black & White Techniques";
ui_min = -2.0f;
ui_max = 3.0f;
> = 0.2f;
uniform float yellowchannel <
ui_type = "slider";
ui_label = "Custom: Yellow Weight";
ui_tooltip = "Custom: Yellow Weight";
ui_category = "Black & White Techniques";
ui_min = -2.0f;
ui_max = 3.0f;
> = 0.4f;
uniform float greenchannel <
ui_type = "slider";
ui_label = "Custom: Green Weight";
ui_tooltip = "Custom: Green Weight";
ui_category = "Black & White Techniques";
ui_min = -2.0f;
ui_max = 3.0f;
> = 0.6f;
uniform float cyanchannel <
ui_type = "slider";
ui_label = "Custom: Cyan Weight";
ui_tooltip = "Custom: Cyan Weight";
ui_category = "Black & White Techniques";
ui_min = -2.0f;
ui_max = 3.0f;
> = 0.0f;
uniform float bluechannel <
ui_type = "slider";
ui_label = "Custom: Blue Weight";
ui_tooltip = "Custom: Blue Weight";
ui_category = "Black & White Techniques";
ui_min = -2.0f;
ui_max = 3.0f;
> = -0.6f;
uniform float magentachannel <
ui_type = "slider";
ui_label = "Custom: Magenta Weight";
ui_tooltip = "Custom: Magenta Weight";
ui_category = "Black & White Techniques";
ui_min = -2.0f;
ui_max = 3.0f;
> = -0.2f;
uniform bool use_tint <
ui_label = "Enable Tinting";
ui_tooltip = "Enable Tinting";
ui_category = "Tint";
> = false;
uniform float tinthue <
ui_type = "slider";
ui_label = "Tint Hue";
ui_tooltip = "Tint Hue";
ui_category = "Tint";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.083f;
uniform float tintsat <
ui_type = "slider";
ui_label = "Tint Saturation";
ui_tooltip = "Tint Saturation";
ui_category = "Tint";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.12f;
#line 147
uniform float2 pingpong < source = "pingpong"; min = 0; max = 128; step = 1; >;
#line 151
float curve( float x, float k )
{
float s = sign( x - 0.5f );
float o = ( 1.0f + s ) / 2.0f;
return o - 0.5f * s * pow( max( 2.0f * ( o - s * x ), 0.0f ), k );
}
#line 158
float3 ProcessBW( float3 col, float r, float y, float g, float c, float b, float m )
{
float3 hsl         = RGBToHSL( col.xyz );
#line 162
float lum          = 1.0f - hsl.z;
#line 166
float weight_r     = curve( max( 1.0f - abs(  hsl.x               * 6.0f ), 0.0f ), curve_str ) +
curve( max( 1.0f - abs(( hsl.x - 1.0f      ) * 6.0f ), 0.0f ), curve_str );
float weight_y     = curve( max( 1.0f - abs(( hsl.x - 0.166667f ) * 6.0f ), 0.0f ), curve_str );
float weight_g     = curve( max( 1.0f - abs(( hsl.x - 0.333333f ) * 6.0f ), 0.0f ), curve_str );
float weight_c     = curve( max( 1.0f - abs(( hsl.x - 0.5f      ) * 6.0f ), 0.0f ), curve_str );
float weight_b     = curve( max( 1.0f - abs(( hsl.x - 0.666667f ) * 6.0f ), 0.0f ), curve_str );
float weight_m     = curve( max( 1.0f - abs(( hsl.x - 0.833333f ) * 6.0f ), 0.0f ), curve_str );
#line 175
float sat          = hsl.y * ( 1.0f - hsl.y ) + hsl.y;
float ret          = hsl.z;
ret                += ( hsl.z * ( weight_r * r ) * sat * lum );
ret                += ( hsl.z * ( weight_y * y ) * sat * lum );
ret                += ( hsl.z * ( weight_g * g ) * sat * lum );
ret                += ( hsl.z * ( weight_c * c ) * sat * lum );
ret                += ( hsl.z * ( weight_b * b ) * sat * lum );
ret                += ( hsl.z * ( weight_m * m ) * sat * lum );
#line 184
return saturate( ret );
}
#line 188
float4 PS_BlackandWhite(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color      = tex2D( ReShade::BackBuffer, texcoord );
color.xyz         = saturate( color.xyz );
#line 195
float4 dnoise      = dither( samplerRGBNoise, texcoord.xy, 4, enable_dither, dither_strength, 1, 0.5f );
color.xyz          = saturate( color.xyz + dnoise.zyx );
#line 198
float red;  float yellow; float green;
float cyan; float blue;   float magenta;
#line 201
switch( bw_mode )
{
case 0: 
{
red      = 0.2f;
yellow   = 0.5f;
green    = -0.2f;
cyan     = -0.6f;
blue     = -1.0f;
magenta  = -0.2f;
}
break;
case 1: 
{
red      = -0.5f;
yellow   = 0.5f;
green    = 1.2f;
cyan     = -0.2f;
blue     = -1.0f;
magenta  = -0.5f;
}
break;
case 2: 
{
red      = -0.2f;
yellow   = 0.4f;
green    = -0.6f;
cyan     = 0.5f;
blue     = 1.0f;
magenta  = -0.2f;
}
break;
case 3: 
{
red      = 0.5f;
yellow   = 1.2f;
green    = -0.5f;
cyan     = -1.0f;
blue     = -1.5f;
magenta  = -1.0f;
}
break;
case 4: 
{
red      = -1.0f;
yellow   = 1.0f;
green    = 1.2f;
cyan     = -0.2f;
blue     = -1.5f;
magenta  = -1.0f;
}
break;
case 5: 
{
red      = -0.7f;
yellow   = 0.4f;
green    = -1.2f;
cyan     = 0.7f;
blue     = 1.2f;
magenta  = -0.2f;
}
break;
case 6: 
{
red      = -1.35f;
yellow   = 2.35f;
green    = 1.35f;
cyan     = -1.35f;
blue     = -1.6f;
magenta  = -1.07f;
}
break;
case 7: 
{
red      = -1.0f;
yellow   = -1.0f;
green    = -1.0f;
cyan     = -1.0f;
blue     = -1.0f;
magenta  = -1.0f;
}
break;
case 8: 
{
red      = 1.0f;
yellow   = 1.0f;
green    = 1.0f;
cyan     = 1.0f;
blue     = 1.0f;
magenta  = 1.0f;
}
break;
case 9: 
{
red      = -0.7f;
yellow   = 0.9f;
green    = 0.6f;
cyan     = 0.1f;
blue     = -0.4f;
magenta  = -0.4f;
}
break;
case 10: 
{
red      = 0.2f;
yellow   = 0.4f;
green    = 0.6f;
cyan     = 0.0f;
blue     = -0.6f;
magenta  = -0.2f;
}
break;
case 11: 
{
red      = -0.3f;
yellow   = 1.0f;
green    = -0.3f;
cyan     = -0.6f;
blue     = -1.0f;
magenta  = -0.6f;
}
break;
case 12: 
{
red      = -0.3f;
yellow   = 2.6f;
green    = -0.3f;
cyan     = -1.2f;
blue     = -0.6f;
magenta  = -0.4f;
}
break;
case 13: 
{
red      = redchannel;
yellow   = yellowchannel;
green    = greenchannel;
cyan     = cyanchannel;
blue     = bluechannel;
magenta  = magentachannel;
}
break;
default:
{
red      = redchannel;
yellow   = yellowchannel;
green    = greenchannel;
cyan     = cyanchannel;
blue     = bluechannel;
magenta  = magentachannel;
}
break;
}
#line 355
color.xyz         = ProcessBW( color.xyz, red, yellow, green, cyan, blue, magenta );
#line 357
color.xyz         = lerp( color.xyz, HSLToRGB( float3( tinthue, tintsat, color.x )), use_tint );
if( show_clip )
{
float h       = 0.98f;
float l       = 0.01f;
color.xyz     = min( min( color.x, color.y ), color.z ) >= h ? lerp( color.xyz, float3( 1.0f, 0.0f, 0.0f ), smoothstep( h, 1.0f, min( min( color.x, color.y ), color.z ))) : color.xyz;
color.xyz     = max( max( color.x, color.y ), color.z ) <= l ? lerp( float3( 0.0f, 0.0f, 1.0f ), color.xyz, smoothstep( 0.0f, l, max( max( color.x, color.y ), color.z ))) : color.xyz;
}
color.xyz         = saturate( color.xyz + dnoise.xyz );
return float4( color.xyz, 1.0f );
}
#line 370
technique prod80_04_Black_and_White
{
pass prod80_BlackandWhite
{
VertexShader  = PostProcessVS;
PixelShader   = PS_BlackandWhite;
}
}
}

