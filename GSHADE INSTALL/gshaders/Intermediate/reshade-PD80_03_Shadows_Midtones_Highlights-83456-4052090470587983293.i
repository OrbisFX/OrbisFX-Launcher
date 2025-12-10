#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Shadows_Midtones_Highlights.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Shadows_Midtones_Highlights.fx"
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
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Shadows_Midtones_Highlights.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Shadows_Midtones_Highlights.fx"
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
#line 33 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Shadows_Midtones_Highlights.fx"
#line 34
namespace pd80_SMH
{
#line 37
uniform int luma_mode <
ui_label = "Luma Mode";
ui_tooltip = "Luma Mode";
ui_category = "Global";
ui_type = "combo";
ui_items = "Use Average\0Use Perceived Luma\0Use Max Value\0";
> = 2;
uniform int separation_mode <
ui_label = "Luma Separation Mode";
ui_tooltip = "Luma Separation Mode";
ui_category = "Global";
ui_type = "combo";
ui_items = "Harsh Separation\0Smooth Separation\0";
> = 0;
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
> = 2.0;
uniform float exposure_s <
ui_label = "Exposure";
ui_tooltip = "Shadow Exposure";
ui_category = "Shadow Adjustments";
ui_type = "slider";
ui_min = -4.0;
ui_max = 4.0;
> = 0.0;
uniform float contrast_s <
ui_label = "Contrast";
ui_tooltip = "Shadow Contrast";
ui_category = "Shadow Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.5;
> = 0.0;
uniform float brightness_s <
ui_label = "Brightness";
ui_tooltip = "Shadow Brightness";
ui_category = "Shadow Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.5;
> = 0.0;
uniform float3 blendcolor_s <
ui_type = "color";
ui_label = "Color";
ui_tooltip = "Shadow Color";
ui_category = "Shadow Adjustments";
> = float3( 0.0,  0.365, 1.0 );
uniform int blendmode_s <
ui_label = "Blendmode";
ui_tooltip = "Shadow Blendmode";
ui_category = "Shadow Adjustments";
ui_type = "combo";
ui_items = "Default\0Darken\0Multiply\0Linearburn\0Colorburn\0Lighten\0Screen\0Colordodge\0Lineardodge\0Overlay\0Softlight\0Vividlight\0Linearlight\0Pinlight\0Hardmix\0Reflect\0Glow\0Hue\0Saturation\0Color\0Luminosity\0";
> = 0;
uniform float opacity_s <
ui_label = "Opacity";
ui_tooltip = "Shadow Opacity";
ui_category = "Shadow Adjustments";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.0;
uniform float tint_s <
ui_label = "Tint";
ui_tooltip = "Shadow Tint";
ui_category = "Shadow Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float saturation_s <
ui_label = "Saturation";
ui_tooltip = "Shadow Saturation";
ui_category = "Shadow Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float vibrance_s <
ui_label = "Vibrance";
ui_tooltip = "Shadow Vibrance";
ui_category = "Shadow Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float exposure_m <
ui_label = "Exposure";
ui_tooltip = "Midtone Exposure";
ui_category = "Midtone Adjustments";
ui_type = "slider";
ui_min = -4.0;
ui_max = 4.0;
> = 0.0;
uniform float contrast_m <
ui_label = "Contrast";
ui_tooltip = "Midtone Contrast";
ui_category = "Midtone Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.5;
> = 0.0;
uniform float brightness_m <
ui_label = "Brightness";
ui_tooltip = "Midtone Brightness";
ui_category = "Midtone Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.5;
> = 0.0;
uniform float3 blendcolor_m <
ui_type = "color";
ui_label = "Color";
ui_tooltip = "Midtone Color";
ui_category = "Midtone Adjustments";
> = float3( 0.98, 0.588, 0.0 );
uniform int blendmode_m <
ui_label = "Blendmode";
ui_tooltip = "Midtone Blendmode";
ui_category = "Midtone Adjustments";
ui_type = "combo";
ui_items = "Default\0Darken\0Multiply\0Linearburn\0Colorburn\0Lighten\0Screen\0Colordodge\0Lineardodge\0Overlay\0Softlight\0Vividlight\0Linearlight\0Pinlight\0Hardmix\0Reflect\0Glow\0Hue\0Saturation\0Color\0Luminosity\0";
> = 0;
uniform float opacity_m <
ui_label = "Opacity";
ui_tooltip = "Midtone Opacity";
ui_category = "Midtone Adjustments";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.0;
uniform float tint_m <
ui_label = "Tint";
ui_tooltip = "Midtone Tint";
ui_category = "Midtone Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float saturation_m <
ui_label = "Saturation";
ui_tooltip = "Midtone Saturation";
ui_category = "Midtone Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float vibrance_m <
ui_label = "Vibrance";
ui_tooltip = "Midtone Vibrance";
ui_category = "Midtone Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float exposure_h <
ui_label = "Exposure";
ui_tooltip = "Highlight Exposure";
ui_category = "Highlight Adjustments";
ui_type = "slider";
ui_min = -4.0;
ui_max = 4.0;
> = 0.0;
uniform float contrast_h <
ui_label = "Contrast";
ui_tooltip = "Highlight Contrast";
ui_category = "Highlight Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.5;
> = 0.0;
uniform float brightness_h <
ui_label = "Brightness";
ui_tooltip = "Highlight Brightness";
ui_category = "Highlight Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.5;
> = 0.0;
uniform float3 blendcolor_h <
ui_type = "color";
ui_label = "Color";
ui_tooltip = "Highlight Color";
ui_category = "Highlight Adjustments";
> = float3( 1.0, 1.0, 1.0 );
uniform int blendmode_h <
ui_label = "Blendmode";
ui_tooltip = "Highlight Blendmode";
ui_category = "Highlight Adjustments";
ui_type = "combo";
ui_items = "Default\0Darken\0Multiply\0Linearburn\0Colorburn\0Lighten\0Screen\0Colordodge\0Lineardodge\0Overlay\0Softlight\0Vividlight\0Linearlight\0Pinlight\0Hardmix\0Reflect\0Glow\0Hue\0Saturation\0Color\0Luminosity\0";
> = 0;
uniform float opacity_h <
ui_label = "Opacity";
ui_tooltip = "Highlight Opacity";
ui_category = "Highlight Adjustments";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.0;
uniform float tint_h <
ui_label = "Tint";
ui_tooltip = "Highlight Tint";
ui_category = "Highlight Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float saturation_h <
ui_label = "Saturation";
ui_tooltip = "Highlight Saturation";
ui_category = "Highlight Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
uniform float vibrance_h <
ui_label = "Vibrance";
ui_tooltip = "Highlight Vibrance";
ui_category = "Highlight Adjustments";
ui_type = "slider";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
#line 278
uniform float2 pingpong < source = "pingpong"; min = 0; max = 128; step = 1; >;
#line 280
float getLuminance( in float3 x )
{
return dot( x, float3( 0.212656, 0.715158, 0.072186 ));
}
#line 285
float curve( float x )
{
return x * x * x * ( x * ( x * 6.0f - 15.0f ) + 10.0f );
}
#line 291
float4 PS_SMH(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color      = tex2D( ReShade::BackBuffer, texcoord );
color.xyz         = saturate( color.xyz );
#line 298
float4 dnoise      = dither( samplerRGBNoise, texcoord.xy, 3, enable_dither, dither_strength, 1, 0.5f );
color.xyz          = saturate( color.xyz + dnoise.xyz );
#line 301
float pLuma       = 0.0f;
switch( luma_mode )
{
case 0: 
{
pLuma     = dot( color.xyz, float3( 0.333333f, 0.333334f, 0.333333f ));
}
break;
case 1: 
{
pLuma     = getLuminance( color.xyz );
}
break;
case 2: 
{
pLuma     = max( max( color.x, color.y ), color.z );
}
break;
}
#line 321
float weight_s; float weight_h; float weight_m;
#line 323
switch( separation_mode )
{
#line 336
case 0:
{
weight_s  = curve( max( 1.0f - pLuma * 2.0f, 0.0f ));
weight_h  = curve( max(( pLuma - 0.5f ) * 2.0f, 0.0f ));
weight_m  = saturate( 1.0f - weight_s - weight_h );
} break;
#line 355
case 1:
{
weight_s  = pow( 1.0f - pLuma, 4.0f );
weight_h  = pow( pLuma, 4.0f );
weight_m  = saturate( 1.0f - weight_s - weight_h );
} break;
}
#line 363
float3 cold       = float3( 0.0f,  0.365f, 1.0f ); 
float3 warm       = float3( 0.98f, 0.588f, 0.0f ); 
#line 367
color.xyz        = exposure( color.xyz, exposure_s * weight_s );
color.xyz        = con( color.xyz, contrast_s * weight_s );
color.xyz        = bri( color.xyz, brightness_s * weight_s );
color.xyz        = blendmode( color.xyz, blendcolor_s.xyz, blendmode_s, opacity_s * weight_s );
if( tint_s < 0.0f )
color.xyz    = lerp( color.xyz, softlight( color.xyz, cold.xyz ), abs( tint_s * weight_s ));
else
color.xyz    = lerp( color.xyz, softlight( color.xyz, warm.xyz ), tint_s * weight_s );
color.xyz        = sat( color.xyz, saturation_s * weight_s );
color.xyz        = vib( color.xyz, vibrance_s   * weight_s );
#line 379
color.xyz        = exposure( color.xyz, exposure_m * weight_m );
color.xyz        = con( color.xyz, contrast_m   * weight_m );
color.xyz        = bri( color.xyz, brightness_m * weight_m );
color.xyz        = blendmode( color.xyz, blendcolor_m.xyz, blendmode_m, opacity_m * weight_m );
if( tint_m < 0.0f )
color.xyz    = lerp( color.xyz, softlight( color.xyz, cold.xyz ), abs( tint_m * weight_m ));
else
color.xyz    = lerp( color.xyz, softlight( color.xyz, warm.xyz ), tint_m * weight_m );
color.xyz        = sat( color.xyz, saturation_m * weight_m );
color.xyz        = vib( color.xyz, vibrance_m   * weight_m );
#line 391
color.xyz        = exposure( color.xyz, exposure_h * weight_h );
color.xyz        = con( color.xyz, contrast_h   * weight_h );
color.xyz        = bri( color.xyz, brightness_h * weight_h );
color.xyz        = blendmode( color.xyz, blendcolor_h.xyz, blendmode_h, opacity_h * weight_h );
if( tint_h < 0.0f )
color.xyz    = lerp( color.xyz, softlight( color.xyz, cold.xyz ), abs( tint_h * weight_h ));
else
color.xyz    = lerp( color.xyz, softlight( color.xyz, warm.xyz ), tint_h * weight_h );
color.xyz        = sat( color.xyz, saturation_h * weight_h );
color.xyz        = vib( color.xyz, vibrance_h   * weight_h );
#line 402
return float4( color.xyz, 1.0f );
}
#line 406
technique prod80_03_Shadows_Midtones_Highlights
{
pass prod80_pass0
{
VertexShader   = PostProcessVS;
PixelShader    = PS_SMH;
}
}
}

