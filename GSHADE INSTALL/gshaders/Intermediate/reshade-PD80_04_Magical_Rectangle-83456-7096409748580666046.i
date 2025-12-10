#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Magical_Rectangle.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Magical_Rectangle.fx"
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
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Magical_Rectangle.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Magical_Rectangle.fx"
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
#line 33 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Magical_Rectangle.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Magical_Rectangle.fx"
#line 35
namespace pd80_magicalrectangle
{
#line 40
uniform int shape <
ui_label = "Shape";
ui_tooltip = "Shape";
ui_category = "Shape Manipulation";
ui_type = "combo";
ui_items = "Square\0Circle\0";
> = 0;
uniform bool invert_shape <
ui_label = "Invert Shape";
ui_tooltip = "Invert Shape";
ui_category = "Shape Manipulation";
> = false;
uniform uint rotation <
ui_type = "slider";
ui_label = "Rotation Factor";
ui_tooltip = "Rotation Factor";
ui_category = "Shape Manipulation";
ui_min = 0;
ui_max = 360;
> = 45;
uniform float2 center <
ui_type = "slider";
ui_label = "Center";
ui_tooltip = "Center";
ui_category = "Shape Manipulation";
ui_min = 0.0;
ui_max = 1.0;
> = float2( 0.5, 0.5 );
uniform float ret_size_x <
ui_type = "slider";
ui_label = "Horizontal Size";
ui_tooltip = "Horizontal Size";
ui_category = "Shape Manipulation";
ui_min = 0.0;
ui_max = 0.5;
> = 0.125;
uniform float ret_size_y <
ui_type = "slider";
ui_label = "Vertical Size";
ui_tooltip = "Vertical Size";
ui_category = "Shape Manipulation";
ui_min = 0.0;
ui_max = 0.5;
> = 0.125;
uniform float depthpos <
ui_type = "slider";
ui_label = "Depth Position";
ui_tooltip = "Depth Position";
ui_category = "Shape Manipulation";
ui_min = 0.0;
ui_max = 1.0;
> = 0.0;
uniform float smoothing <
ui_type = "slider";
ui_label = "Edge Smoothing";
ui_tooltip = "Edge Smoothing";
ui_category = "Shape Manipulation";
ui_min = 0.0;
ui_max = 1.0;
> = 0.01;
uniform float depth_smoothing <
ui_type = "slider";
ui_label = "Depth Smoothing";
ui_tooltip = "Depth Smoothing";
ui_category = "Shape Manipulation";
ui_min = 0.0;
ui_max = 1.0;
> = 0.002;
uniform float dither_strength <
ui_type = "slider";
ui_label = "Dither Strength";
ui_tooltip = "Dither Strength";
ui_category = "Shape Manipulation";
ui_min = 0.0f;
ui_max = 10.0f;
> = 0.0;
uniform float3 reccolor <
ui_text = "-------------------------------------\n"
"Use Opacity and Blend Mode to adjust\n"
"Shape controls the Shape coloring\n"
"Image controls the underlying picture\n"
"-------------------------------------";
ui_type = "color";
ui_label = "Shape: Color";
ui_tooltip = "Shape: Color";
ui_category = "Shape Coloration";
> = float3( 0.5, 0.5, 0.5 );
uniform float mr_exposure <
ui_type = "slider";
ui_label = "Image: Exposure";
ui_tooltip = "Image: Exposure";
ui_category = "Shape Coloration";
ui_min = -4.0;
ui_max = 4.0;
> = 0.0;
uniform float mr_contrast <
ui_type = "slider";
ui_label = "Image: Contrast";
ui_tooltip = "Image: Contrast";
ui_category = "Shape Coloration";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float mr_brightness <
ui_type = "slider";
ui_label = "Image: Brightness";
ui_tooltip = "Image: Brightness";
ui_category = "Shape Coloration";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float mr_hue <
ui_type = "slider";
ui_label = "Image: Hue";
ui_tooltip = "Image: Hue";
ui_category = "Shape Coloration";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float mr_saturation <
ui_type = "slider";
ui_label = "Image: Saturation";
ui_tooltip = "Image: Saturation";
ui_category = "Shape Coloration";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float mr_vibrance <
ui_type = "slider";
ui_label = "Image: Vibrance";
ui_tooltip = "Image: Vibrance";
ui_category = "Shape Coloration";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform bool enable_gradient <
ui_label = "Enable Gradient";
ui_tooltip = "Enable Gradient";
ui_category = "Shape Gradient";
> = false;
uniform bool gradient_type <
ui_label = "Gradient Type";
ui_tooltip = "Gradient Type";
ui_category = "Shape Gradient";
> = false;
uniform float gradient_curve <
ui_type = "slider";
ui_label = "Gradient Curve";
ui_tooltip = "Gradient Curve";
ui_category = "Shape Gradient";
ui_min = 0.001;
ui_max = 2.0;
> = 0.25;
uniform float intensity_boost <
ui_type = "slider";
ui_label = "Intensity Boost";
ui_tooltip = "Intensity Boost";
ui_category = "Intensity Boost";
ui_min = 1.0;
ui_max = 4.0;
> = 1.0;
uniform int blendmode_1 <
ui_label = "Blendmode";
ui_tooltip = "Blendmode";
ui_category = "Shape Blending";
ui_type = "combo";
ui_items = "Default\0Darken\0Multiply\0Linearburn\0Colorburn\0Lighten\0Screen\0Colordodge\0Lineardodge\0Overlay\0Softlight\0Vividlight\0Linearlight\0Pinlight\0Hardmix\0Reflect\0Glow\0Hue\0Saturation\0Color\0Luminosity\0";
> = 0;
uniform float opacity <
ui_type = "slider";
ui_label = "Opacity";
ui_tooltip = "Opacity";
ui_category = "Shape Blending";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
#line 217
texture texMagicRectangle { Width = 1920; Height = 1018; Format = RGBA16F; };
#line 220
sampler samplerMagicRectangle { Texture = texMagicRectangle; };
#line 226
uniform bool hasdepth < source = "bufready_depth"; >;
#line 228
float3 hue( float3 res, float shift, float x )
{
float3 hsl = RGBToHSL( res.xyz );
hsl.x = frac( hsl.x + ( shift + 1.0f ) / 2.0f - 0.5f );
hsl.xyz = HSLToRGB( hsl.xyz );
return lerp( res.xyz, hsl.xyz, x );
}
#line 236
float curve( float x )
{
return x * x * x * ( x * ( x * 6.0f - 15.0f ) + 10.0f );
}
#line 245
void PPVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD, out float2 texcoord2 : TEXCOORD2)
{
PostProcessVS(id, position, texcoord);
float2 uv;
uv.x         = ( id == 2 ) ? 2.0 : 0.0;
uv.y         = ( id == 1 ) ? 2.0 : 0.0;
uv.xy        -= center.xy;
uv.y         /= float( 1920 * (1.0 / 1018) );
float dim    = ceil( sqrt( 1920 * 1920 + 1018 * 1018 )); 
float maxlen = min( 1920, 1018 );
dim          = dim / maxlen; 
uv.xy        /= dim;
float sin    = sin( radians( rotation ));
float cos    = cos( radians( rotation ));
texcoord2.x  = ( uv.x * cos ) + ( uv.y * (-sin));
texcoord2.y  = ( uv.x * sin ) + ( uv.y * cos );
texcoord2.xy += float2( 0.5f, 0.5f ); 
}
#line 265
float4 PS_Layer_1( float4 pos : SV_Position, float2 texcoord : TEXCOORD, float2 texcoord2 : TEXCOORD2 ) : SV_Target
{
float4 color      = tex2D( ReShade::BackBuffer, texcoord );
#line 269
float depth       = ReShade::GetLinearizedDepth( texcoord ).x;
#line 271
float dim         = ceil( sqrt( 1920 * 1920 + 1018 * 1018 )); 
float maxlen      = max( 1920, 1018 );
dim               = dim / maxlen; 
float2 uv         = texcoord2.xy;
uv.xy             = uv.xy * 2.0f - 1.0f; 
uv.xy             /= ( float2( ret_size_x + ret_size_x * smoothing, ret_size_y + ret_size_y * smoothing ) * dim ); 
switch( shape )
{
case 0: 
{ uv.xy       = uv.xy; } break;
case 1: 
{ uv.xy       = lerp( dot( uv.xy, uv.xy ), dot( uv.xy, -uv.xy ), gradient_type ); } break;
}
uv.xy             = ( uv.xy + 1.0f ) / 2.0f; 
#line 290
float2 bl         = smoothstep( 0.0f, 0.0f + smoothing, uv.xy );
float2 tr         = smoothstep( 0.0f, 0.0f + smoothing, 1.0f - uv.xy );
if( enable_gradient )
{
if( gradient_type )
{
bl        = smoothstep( 0.0f, 0.0f + smoothing, uv.xy ) * pow( abs( uv.y ), gradient_curve );
}
tr            = smoothstep( 0.0f, 0.0f + smoothing, 1.0f - uv.xy ) * pow( abs( uv.x ), gradient_curve );
}
float depthfade   = smoothstep( depthpos - depth_smoothing, depthpos + depth_smoothing, depth );
depthfade         = lerp( 1.0f, depthfade, hasdepth );
#line 303
float R           = bl.x * bl.y * tr.x * tr.y * depthfade;
R                 = ( invert_shape ) ? 1.0f - R : R;
#line 306
float intensity   = RGBToHSV( reccolor.xyz ).z;
color.xyz         = lerp( color.xyz, saturate( color.xyz * saturate( 1.0f - R ) + R * intensity ), R );
#line 309
return float4( color.xyz, R );
}
#line 312
float4 PS_Blend(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 orig       = tex2D( ReShade::BackBuffer, texcoord );
float3 color;
float4 layer_1    = saturate( tex2D( samplerMagicRectangle, texcoord ));
#line 319
float4 dnoise     = dither( samplerRGBNoise, texcoord.xy, 7, 1, dither_strength, 1, 0.5f );
layer_1.xyz       = saturate( layer_1.xyz + dnoise.xyz );
#line 322
orig.xyz          = exposure( orig.xyz, mr_exposure * layer_1.w );
orig.xyz          = con( orig.xyz, mr_contrast * layer_1.w );
orig.xyz          = bri( orig.xyz, mr_brightness * layer_1.w );
orig.xyz          = hue( orig.xyz, mr_hue, layer_1.w );
orig.xyz          = sat( orig.xyz, mr_saturation * layer_1.w );
orig.xyz          = vib( orig.xyz, mr_vibrance * layer_1.w );
orig.xyz          = saturate( orig.xyz );
#line 330
layer_1.xyz       = saturate( layer_1.xyz * intensity_boost );
layer_1.xyz       = RGBToHSV( layer_1.xyz );
float2 huesat     = RGBToHSV( reccolor.xyz ).xy;
layer_1.xyz       = HSVToRGB( float3( huesat.xy, layer_1.z ));
layer_1.xyz       = saturate( layer_1.xyz );
#line 336
color.xyz         = blendmode( orig.xyz, layer_1.xyz, blendmode_1, saturate( layer_1.w ) * opacity );
#line 338
return float4( color.xyz, 1.0f );
}
#line 342
technique prod80_04_Magical_Rectangle
< ui_tooltip = "The Magical Rectangle\n\n"
"This shader gives you a rectangular shape on your screen that you can manipulate in 3D space.\n"
"It can blend on depth, blur edges, change color, change blending, change shape, and so on.\n"
"It will allow you to manipulate parts of the scene in various ways. Not withstanding; add mist,\n"
"remove mist, change clouds, create backgrounds, draw flares, add contrasts, change hues, etc. in ways\n"
"another shader will not be able to do.\n\n"
"This shader requires access to depth buffer for full functionality!";>
{
pass prod80_pass0
{
VertexShader   = PPVS;
PixelShader    = PS_Layer_1;
RenderTarget   = texMagicRectangle;
}
pass prod80_pass1
{
VertexShader   = PPVS;
PixelShader    = PS_Blend;
}
}
}

