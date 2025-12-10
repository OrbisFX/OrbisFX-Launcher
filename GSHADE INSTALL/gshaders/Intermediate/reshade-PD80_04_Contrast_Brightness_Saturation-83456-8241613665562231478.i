#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Contrast_Brightness_Saturation.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Contrast_Brightness_Saturation.fx"
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
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Contrast_Brightness_Saturation.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Contrast_Brightness_Saturation.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_00_Blend_Modes.fxh"
#line 48
float getAvgColor( float3 col )
{
return dot( col.xyz, float3( 0.333333f, 0.333334f, 0.333333f ));
}
#line 55
float3 ClipColor( float3 color )
{
float lum         = getAvgColor( color.xyz );
float mincol      = min( min( color.x, color.y ), color.z );
float maxcol      = max( max( color.x, color.y ), color.z );
color.xyz         = ( mincol < 0.0f ) ? lum + (( color.xyz - lum ) * lum ) / ( lum - mincol ) : color.xyz;
color.xyz         = ( maxcol > 1.0f ) ? lum + (( color.xyz - lum ) * ( 1.0f - lum )) / ( maxcol - lum ) : color.xyz;
return color;
}
#line 67
float3 blendLuma( float3 base, float3 blend )
{
float lumbase     = getAvgColor( base.xyz );
float lumblend    = getAvgColor( blend.xyz );
float ldiff       = lumblend - lumbase;
float3 col        = base.xyz + ldiff;
return ClipColor( col.xyz );
}
#line 78
float3 blendColor( float3 base, float3 blend, float3 lum )
{
float minbase     = min( min( base.x, base.y ), base.z );
float maxbase     = max( max( base.x, base.y ), base.z );
float satbase     = maxbase - minbase;
float minblend    = min( min( blend.x, blend.y ), blend.z );
float maxblend    = max( max( blend.x, blend.y ), blend.z );
float satblend    = maxblend - minblend;
float3 color      = ( satbase > 0.0f ) ? ( base.xyz - minbase ) * satblend / satbase : 0.0f;
return blendLuma( color.xyz, lum.xyz );
}
#line 90
float3 darken(float3 c, float3 b)       { return min(c,b);}
float3 multiply(float3 c, float3 b) 	{ return c*b;}
float3 linearburn(float3 c, float3 b) 	{ return max(c+b-1.0f,0.0f);}
float3 colorburn(float3 c, float3 b)    { return b<=0.0f ? b:saturate(1.0f-((1.0f-c)/b)); }
float3 lighten(float3 c, float3 b) 		{ return max(b,c);}
float3 screen(float3 c, float3 b) 		{ return 1.0f-(1.0f-c)*(1.0f-b);}
float3 colordodge(float3 c, float3 b) 	{ return b>=1.0f ? b:saturate(c/(1.0f-b));}
float3 lineardodge(float3 c, float3 b) 	{ return min(c+b,1.0f);}
float3 overlay(float3 c, float3 b) 		{ return c<0.5f ? 2.0f*c*b:(1.0f-2.0f*(1.0f-c)*(1.0f-b));}
float3 softlight(float3 c, float3 b) 	{ return b<0.5f ? (2.0f*c*b+c*c*(1.0f-2.0f*b)):(sqrt(c)*(2.0f*b-1.0f)+2.0f*c*(1.0f-b));}
float3 vividlight(float3 c, float3 b) 	{ return b<0.5f ? colorburn(c,(2.0f*b)):colordodge(c,(2.0f*(b-0.5f)));}
float3 linearlight(float3 c, float3 b) 	{ return b<0.5f ? linearburn(c,(2.0f*b)):lineardodge(c,(2.0f*(b-0.5f)));}
float3 pinlight(float3 c, float3 b) 	{ return b<0.5f ? darken(c,(2.0f*b)):lighten(c, (2.0f*(b-0.5f)));}
float3 hardmix(float3 c, float3 b)      { return vividlight(c,b)<0.5f ? float3(0.0,0.0,0.0):float3(1.0,1.0,1.0);}
float3 reflect(float3 c, float3 b)      { return b>=1.0f ? b:saturate(c*c/(1.0f-b));}
float3 glow(float3 c, float3 b)         { return reflect(b,c);}
float3 blendhue(float3 c, float3 b)         { return blendColor(b,c,c);}
float3 blendsaturation(float3 c, float3 b)  { return blendColor(c,b,c);}
float3 blendcolor(float3 c, float3 b)       { return blendLuma(b,c);}
float3 blendluminosity(float3 c, float3 b)  { return blendLuma(c,b);}
#line 111
float3 blendmode( float3 c, float3 b, int mode, float o )
{
float3 ret;
switch( mode )
{
case 0:  
{ ret.xyz = b.xyz; } break;
case 1:  
{ ret.xyz = darken( c, b ); } break;
case 2:  
{ ret.xyz = multiply( c, b ); } break;
case 3:  
{ ret.xyz = linearburn( c, b ); } break;
case 4:  
{ ret.xyz = colorburn( c, b ); } break;
case 5:  
{ ret.xyz = lighten( c, b ); } break;
case 6:  
{ ret.xyz = screen( c, b ); } break;
case 7:  
{ ret.xyz = colordodge( c, b ); } break;
case 8:  
{ ret.xyz = lineardodge( c, b ); } break;
case 9:  
{ ret.xyz = overlay( c, b ); } break;
case 10:  
{ ret.xyz = softlight( c, b ); } break;
case 11: 
{ ret.xyz = vividlight( c, b ); } break;
case 12: 
{ ret.xyz = linearlight( c, b ); } break;
case 13: 
{ ret.xyz = pinlight( c, b ); } break;
case 14: 
{ ret.xyz = hardmix( c, b ); } break;
case 15: 
{ ret.xyz = reflect( c, b ); } break;
case 16: 
{ ret.xyz = glow( c, b ); } break;
case 17: 
{ ret.xyz = blendhue( c, b ); } break;
case 18: 
{ ret.xyz = blendsaturation( c, b ); } break;
case 19: 
{ ret.xyz = blendcolor( c, b ); } break;
case 20: 
{ ret.xyz = blendluminosity( c, b ); } break;
}
return saturate( lerp( c.xyz, ret.xyz, o ));
}
#line 33 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Contrast_Brightness_Saturation.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_00_Base_Effects.fxh"
#line 29
float3 sl( float3 c, float3 b )
{
return b < 0.5f ? ( 2.0f * c * b + c * c * ( 1.0f - 2.0f * b )) :
( sqrt( c ) * ( 2.0f * b - 1.0f ) + 2.0f * c * ( 1.0f - b ));
}
#line 35
float getLum( in float3 x )
{
return dot( x, float3( 0.212656, 0.715158, 0.072186 ));
}
#line 40
float3 exposure( float3 res, float x )
{
x = x < 0.0f ? x * 0.333f : x;
return saturate( res.xyz * ( x * ( 1.0f - res.xyz ) + 1.0f ));
}
#line 46
float3 con( float3 res, float x )
{
#line 49
float3 c = sl( res.xyz, res.xyz );
x = ( x < 0.0f ) ? x * 0.5f : x;
return saturate( lerp( res.xyz, c.xyz, x ));
}
#line 54
float3 bri( float3 res, float x )
{
#line 57
float3 c = 1.0f - ( 1.0f - res.xyz ) * ( 1.0f - res.xyz );
x = ( x < 0.0f ) ? x * 0.5f : x;
return saturate( lerp( res.xyz, c.xyz, x ));
}
#line 62
float3 sat( float3 res, float x )
{
return saturate( lerp( getLum( res.xyz ), res.xyz, x + 1.0f ));
}
#line 67
float3 vib( float3 res, float x )
{
float4 sat = 0.0f;
sat.xy = float2( min( min( res.x, res.y ), res.z ), max( max( res.x, res.y ), res.z ));
sat.z = sat.y - sat.x;
sat.w = getLum( res.xyz );
return saturate( lerp( sat.w, res.xyz, 1.0f + ( x * ( 1.0f - sat.z ))));
}
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Contrast_Brightness_Saturation.fx"
#line 35
namespace pd80_conbrisat
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
uniform float tint <
ui_label = "Tint";
ui_tooltip = "Tint";
ui_category = "Final Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float exposureN <
ui_label = "Exposure";
ui_tooltip = "Exposure";
ui_category = "Final Adjustments";
ui_type = "slider";
ui_min = -4.0;
ui_max = 4.0;
> = 0.0;
uniform float contrast <
ui_label = "Contrast";
ui_tooltip = "Contrast";
ui_category = "Final Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.5;
> = 0.0;
uniform float brightness <
ui_label = "Brightness";
ui_tooltip = "Brightness";
ui_category = "Final Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.5;
> = 0.0;
uniform float saturation <
ui_label = "Saturation";
ui_tooltip = "Saturation";
ui_category = "Final Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float vibrance <
ui_label = "Vibrance";
ui_tooltip = "Vibrance";
ui_category = "Final Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float huemid <
ui_label = "Color Hue";
ui_tooltip = "Custom Color Hue";
ui_category = "Custom Saturation Adjustments";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.0;
uniform float huerange <
ui_label = "Hue Range Selection";
ui_tooltip = "Custom Hue Range Selection";
ui_category = "Custom Saturation Adjustments";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.167;
uniform float sat_custom <
ui_label = "Custom Saturation Level";
ui_tooltip = "Custom Saturation Level";
ui_category = "Custom Saturation Adjustments";
ui_type = "slider";
ui_min = -2.0;
ui_max = 2.0;
> = 0.0;
uniform float sat_r <
ui_label = "Red Saturation";
ui_tooltip = "Red Saturation";
ui_category = "Color Saturation Adjustments";
ui_type = "slider";
ui_min = -2.0;
ui_max = 2.0;
> = 0.0;
uniform float sat_y <
ui_label = "Yellow Saturation";
ui_tooltip = "Yellow Saturation";
ui_category = "Color Saturation Adjustments";
ui_type = "slider";
ui_min = -2.0;
ui_max = 2.0;
> = 0.0;
uniform float sat_g <
ui_label = "Green Saturation";
ui_tooltip = "Green Saturation";
ui_category = "Color Saturation Adjustments";
ui_type = "slider";
ui_min = -2.0;
ui_max = 2.0;
> = 0.0;
uniform float sat_a <
ui_label = "Aqua Saturation";
ui_tooltip = "Aqua Saturation";
ui_category = "Color Saturation Adjustments";
ui_type = "slider";
ui_min = -2.0;
ui_max = 2.0;
> = 0.0;
uniform float sat_b <
ui_label = "Blue Saturation";
ui_tooltip = "Blue Saturation";
ui_category = "Color Saturation Adjustments";
ui_type = "slider";
ui_min = -2.0;
ui_max = 2.0;
> = 0.0;
uniform float sat_p <
ui_label = "Purple Saturation";
ui_tooltip = "Purple Saturation";
ui_category = "Color Saturation Adjustments";
ui_type = "slider";
ui_min = -2.0;
ui_max = 2.0;
> = 0.0;
uniform float sat_m <
ui_label = "Magenta Saturation";
ui_tooltip = "Magenta Saturation";
ui_category = "Color Saturation Adjustments";
ui_type = "slider";
ui_min = -2.0;
ui_max = 2.0;
> = 0.0;
uniform bool enable_depth <
ui_label = "Enable depth based adjustments.\nMake sure you have setup your depth buffer correctly.";
ui_tooltip = "Enable depth based adjustments";
ui_category = "Final Adjustments: Depth";
> = false;
uniform bool display_depth <
ui_label = "Show depth texture";
ui_tooltip = "Show depth texture";
ui_category = "Final Adjustments: Depth";
> = false;
uniform float depthStart <
ui_type = "slider";
ui_label = "Change Depth Start Plane";
ui_tooltip = "Change Depth Start Plane";
ui_category = "Final Adjustments: Depth";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.0;
uniform float depthEnd <
ui_type = "slider";
ui_label = "Change Depth End Plane";
ui_tooltip = "Change Depth End Plane";
ui_category = "Final Adjustments: Depth";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.1;
uniform float depthCurve <
ui_label = "Depth Curve Adjustment";
ui_tooltip = "Depth Curve Adjustment";
ui_category = "Final Adjustments: Depth";
ui_type = "slider";
ui_min = 0.05;
ui_max = 8.0;
> = 1.0;
uniform float exposureD <
ui_label = "Exposure Far";
ui_tooltip = "Exposure Far";
ui_category = "Final Adjustments: Far";
ui_type = "slider";
ui_min = -4.0;
ui_max = 4.0;
> = 0.0;
uniform float contrastD <
ui_label = "Contrast Far";
ui_tooltip = "Contrast Far";
ui_category = "Final Adjustments: Far";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.5;
> = 0.0;
uniform float brightnessD <
ui_label = "Brightness Far";
ui_tooltip = "Brightness Far";
ui_category = "Final Adjustments: Far";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.5;
> = 0.0;
uniform float saturationD <
ui_label = "Saturation Far";
ui_tooltip = "Saturation Far";
ui_category = "Final Adjustments: Far";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float vibranceD <
ui_label = "Vibrance Far";
ui_tooltip = "Vibrance Far";
ui_category = "Final Adjustments: Far";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
#line 261
float getLuminance( in float3 x )
{
return dot( x, float3( 0.212656, 0.715158, 0.072186 ));
}
#line 266
float curve( float x )
{
return x * x * ( 3.0 - 2.0 * x );
}
#line 271
float3 channelsat( float3 col, float r, float y, float g, float a, float b, float p, float m, float hue )
{
float desat        = getLuminance( col.xyz );
#line 284
float weight_r     = curve( max( 1.0f - abs(  hue               * 6.0f ), 0.0f )) +
curve( max( 1.0f - abs(( hue - 1.0f      ) * 6.0f ), 0.0f ));
float weight_y     = curve( max( 1.0f - abs(( hue - 0.166667f ) * 6.0f ), 0.0f ));
float weight_g     = curve( max( 1.0f - abs(( hue - 0.333333f ) * 6.0f ), 0.0f ));
float weight_a     = curve( max( 1.0f - abs(( hue - 0.5f      ) * 6.0f ), 0.0f ));
float weight_b     = curve( max( 1.0f - abs(( hue - 0.666667f ) * 6.0f ), 0.0f ));
float weight_p     = curve( max( 1.0f - abs(( hue - 0.75f     ) * 6.0f ), 0.0f ));
float weight_m     = curve( max( 1.0f - abs(( hue - 0.833333f ) * 6.0f ), 0.0f ));
#line 293
col.xyz            = lerp( desat, col.xyz, clamp( 1.0f + r * weight_r, 0.0f, 2.0f ));
col.xyz            = lerp( desat, col.xyz, clamp( 1.0f + y * weight_y, 0.0f, 2.0f ));
col.xyz            = lerp( desat, col.xyz, clamp( 1.0f + g * weight_g, 0.0f, 2.0f ));
col.xyz            = lerp( desat, col.xyz, clamp( 1.0f + a * weight_a, 0.0f, 2.0f ));
col.xyz            = lerp( desat, col.xyz, clamp( 1.0f + b * weight_b, 0.0f, 2.0f ));
col.xyz            = lerp( desat, col.xyz, clamp( 1.0f + p * weight_p, 0.0f, 2.0f ));
col.xyz            = lerp( desat, col.xyz, clamp( 1.0f + m * weight_m, 0.0f, 2.0f ));
#line 301
return saturate( col.xyz );
}
#line 304
float3 customsat( float3 col, float h, float range, float sat, float hue )
{
float desat        = getLuminance( col.xyz );
float r            = rcp( range );
float3 w           = max( 1.0f - abs(( hue - h        ) * r ), 0.0f );
w.y                = max( 1.0f - abs(( hue + 1.0f - h ) * r ), 0.0f );
w.z                = max( 1.0f - abs(( hue - 1.0f - h ) * r ), 0.0f );
float weight       = curve( dot( w.xyz, 1.0f )) * sat;
col.xyz            = lerp( desat, col.xyz, clamp( 1.0f + weight, 0.0f, 2.0f ));
return saturate( col.xyz );
}
#line 317
float4 PS_CBS(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2D( ReShade::BackBuffer, texcoord );
#line 322
float4 dnoise    = dither( samplerRGBNoise, texcoord.xy, 6, enable_dither, dither_strength, 1, 0.5f );
color.xyz        = saturate( color.xyz + dnoise.xyz );
#line 325
float depth      = ReShade::GetLinearizedDepth( texcoord ).x;
depth            = smoothstep( depthStart, depthEnd, depth );
depth            = pow( depth, depthCurve );
float4 dnoise2   = dither( samplerGaussNoise, texcoord.xy, 0, 1, 1.0f, 0, 1.0f );
depth            = saturate( depth + dnoise2.x );
#line 331
float3 cold      = float3( 0.0f,  0.365f, 1.0f ); 
float3 warm      = float3( 0.98f, 0.588f, 0.0f ); 
#line 334
color.xyz        = ( tint < 0.0f ) ? lerp( color.xyz, blendLuma( cold.xyz, color.xyz ), abs( tint )) :
lerp( color.xyz, blendLuma( warm.xyz, color.xyz ), tint );
#line 337
float3 dcolor    = color.xyz;
color.xyz        = exposure( color.xyz, exposureN );
color.xyz        = con( color.xyz, contrast   );
color.xyz        = bri( color.xyz, brightness );
color.xyz        = sat( color.xyz, saturation );
color.xyz        = vib( color.xyz, vibrance   );
#line 344
dcolor.xyz       = exposure( dcolor.xyz, exposureD );
dcolor.xyz       = con( dcolor.xyz, contrastD   );
dcolor.xyz       = bri( dcolor.xyz, brightnessD );
dcolor.xyz       = sat( dcolor.xyz, saturationD );
dcolor.xyz       = vib( dcolor.xyz, vibranceD   );
#line 350
color.xyz        = lerp( color.xyz, dcolor.xyz, enable_depth * depth ); 
#line 352
float chue       = RGBToHSL( color.xyz ).x;
color.xyz        = channelsat( color.xyz, sat_r, sat_y, sat_g, sat_a, sat_b, sat_p, sat_m, chue );
color.xyz        = customsat( color.xyz, huemid, huerange, sat_custom, chue );
#line 356
color.xyz        = display_depth ? depth.xxx : color.xyz; 
#line 358
return float4( color.xyz, 1.0f );
}
#line 362
technique prod80_04_ContrastBrightnessSaturation
{
pass ConBriSat
{
VertexShader   = PostProcessVS;
PixelShader    = PS_CBS;
}
}
}

