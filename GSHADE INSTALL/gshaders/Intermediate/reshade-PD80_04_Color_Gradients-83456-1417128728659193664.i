#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Color_Gradients.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Color_Gradients.fx"
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
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Color_Gradients.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Color_Gradients.fx"
#line 33
namespace pd80_ColorGradients
{
#line 36
uniform int luma_mode <
ui_label = "Luma Mode";
ui_tooltip = "Luma Mode";
ui_category = "Global";
ui_type = "combo";
ui_items = "Use Average\0Use Perceived Luma\0Use Max Value\0";
> = 0;
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
> = 1.0;
uniform float CGdesat <
ui_label = "Desaturate Base Image";
ui_tooltip = "Desaturate Base Image";
ui_category = "Mixing Values";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.0;
uniform float finalmix <
ui_label = "Mix with Original";
ui_tooltip = "Mix with Original";
ui_category = "Mixing Values";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.333;
#line 80
uniform float3 blendcolor_ls_m <
ui_type = "color";
ui_label = "Color";
ui_tooltip = "Light Scene: Midtone Color";
ui_category = "Light Scene: Midtone Color";
> = float3( 0.98, 0.588, 0.0 );
uniform int blendmode_ls_m <
ui_label = "Blendmode";
ui_tooltip = "Light Scene: Midtone Color Blendmode";
ui_category = "Light Scene: Midtone Color";
ui_type = "combo";
ui_items = "Default\0Darken\0Multiply\0Linearburn\0Colorburn\0Lighten\0Screen\0Colordodge\0Lineardodge\0Overlay\0Softlight\0Vividlight\0Linearlight\0Pinlight\0Hardmix\0Reflect\0Glow\0Hue\0Saturation\0Color\0Luminosity\0";
> = 10;
uniform float opacity_ls_m <
ui_label = "Opacity";
ui_tooltip = "Light Scene: Midtone Color Opacity";
ui_category = "Light Scene: Midtone Color";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
uniform float3 blendcolor_ls_s <
ui_type = "color";
ui_label = "Color";
ui_tooltip = "Light Scene: Shadow Color";
ui_category = "Light Scene: Shadow Color";
> = float3( 0.0,  0.365, 1.0 );
uniform int blendmode_ls_s <
ui_label = "Blendmode";
ui_tooltip = "Light Scene: Shadow Color Blendmode";
ui_category = "Light Scene: Shadow Color";
ui_type = "combo";
ui_items = "Default\0Darken\0Multiply\0Linearburn\0Colorburn\0Lighten\0Screen\0Colordodge\0Lineardodge\0Overlay\0Softlight\0Vividlight\0Linearlight\0Pinlight\0Hardmix\0Reflect\0Glow\0Hue\0Saturation\0Color\0Luminosity\0";
> = 5;
uniform float opacity_ls_s <
ui_label = "Opacity";
ui_tooltip = "Light Scene: Shadow Color Opacity";
ui_category = "Light Scene: Shadow Color";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.3;
#line 123
uniform bool enable_ds <
ui_text = "-------------------------------------\n"
"Enables transitions of gradients\n"
"depending on average scene luminance.\n"
"To simulate Day-Night color grading.\n"
"-------------------------------------";
ui_label = "Enable Color Transitions";
ui_tooltip = "Enable Color Transitions";
ui_category = "Enable Color Transitions";
> = true;
uniform float3 blendcolor_ds_m <
ui_type = "color";
ui_label = "Color";
ui_tooltip = "Dark Scene: Midtone Color";
ui_category = "Dark Scene: Midtone Color";
> = float3( 0.0,  0.365, 1.0 );
uniform int blendmode_ds_m <
ui_label = "Blendmode";
ui_tooltip = "Dark Scene: Midtone Color Blendmode";
ui_category = "Dark Scene: Midtone Color";
ui_type = "combo";
ui_items = "Default\0Darken\0Multiply\0Linearburn\0Colorburn\0Lighten\0Screen\0Colordodge\0Lineardodge\0Overlay\0Softlight\0Vividlight\0Linearlight\0Pinlight\0Hardmix\0Reflect\0Glow\0Hue\0Saturation\0Color\0Luminosity\0";
> = 10;
uniform float opacity_ds_m <
ui_label = "Opacity";
ui_tooltip = "Dark Scene: Midtone Color Opacity";
ui_category = "Dark Scene: Midtone Color";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
uniform float3 blendcolor_ds_s <
ui_type = "color";
ui_label = "Color";
ui_tooltip = "Dark Scene: Shadow Color";
ui_category = "Dark Scene: Shadow Color";
> = float3( 0.0,  0.039, 0.588 );
uniform int blendmode_ds_s <
ui_label = "Blendmode";
ui_tooltip = "Dark Scene: Shadow Color Blendmode";
ui_category = "Dark Scene: Shadow Color";
ui_type = "combo";
ui_items = "Default\0Darken\0Multiply\0Linearburn\0Colorburn\0Lighten\0Screen\0Colordodge\0Lineardodge\0Overlay\0Softlight\0Vividlight\0Linearlight\0Pinlight\0Hardmix\0Reflect\0Glow\0Hue\0Saturation\0Color\0Luminosity\0";
> = 10;
uniform float opacity_ds_s <
ui_label = "Opacity";
ui_tooltip = "Dark Scene: Shadow Color Opacity";
ui_category = "Dark Scene: Shadow Color";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
uniform float minlevel <
ui_label = "Pure Dark Scene Level";
ui_tooltip = "Pure Dark Scene Level";
ui_category = "Scene Luminance Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.125;
uniform float maxlevel <
ui_label = "Pure Light Scene Level";
ui_tooltip = "Pure Light Scene Level";
ui_category = "Scene Luminance Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.3;
#line 192
texture texLuma { Width = 256; Height = 256; Format = R16F; MipLevels = 8; };
texture texAvgLuma { Format = R16F; };
texture texPrevAvgLuma { Format = R16F; };
#line 197
sampler samplerLuma { Texture = texLuma; };
sampler samplerAvgLuma { Texture = texAvgLuma; };
sampler samplerPrevAvgLuma { Texture = texPrevAvgLuma; };
#line 203
uniform float Frametime < source = "frametime"; >;
uniform float2 pingpong < source = "pingpong"; min = 0; max = 128; step = 1; >;
#line 207
float getLuminance( in float3 x )
{
return dot( x, float3(0.212656, 0.715158, 0.072186) );
}
#line 212
float curve( float x )
{
return x * x * ( 3.0f - 2.0f * x );
}
#line 218
float PS_WriteLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2D( ReShade::BackBuffer, texcoord );
float luma       = max( max( color.x, color.y ), color.z );
return luma; 
}
#line 225
float PS_AvgLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float luma       = tex2Dlod( samplerLuma, float4( 0.5f, 0.5f, 0, 8 )).x;
float prevluma   = tex2D( samplerPrevAvgLuma, float2( 0.5f, 0.5f )).x;
float avgLuma    = lerp( prevluma, luma, saturate( Frametime * 0.003f ));
return avgLuma; 
}
#line 233
float4 PS_ColorGradients(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2D( ReShade::BackBuffer, texcoord );
float sceneluma  = tex2D( samplerAvgLuma, float2( 0.5f, 0.5f )).x;
float ml         = ( minlevel >= maxlevel ) ? maxlevel - 0.01f : minlevel;
sceneluma        = smoothstep( ml, maxlevel, sceneluma );
color.xyz        = saturate( color.xyz );
#line 243
float4 dnoise      = dither( samplerRGBNoise, texcoord.xy, 5, enable_dither, dither_strength, 1, 0.5f );
color.xyz          = saturate( color.xyz + dnoise.xyz );
#line 247
float cWeight;
switch( luma_mode )
{
case 0: 
{
cWeight = dot( color.xyz, float3( 0.333333f, 0.333334f, 0.333333f ));
}
break;
case 1: 
{
cWeight = dot( color.xyz, float3( 0.212656f, 0.715158f, 0.072186f ));
}
break;
case 2: 
{
cWeight = max( max( color.x, color.y ), color.z );
}
break;
}
#line 267
float w_s; float w_h; float w_m;
switch( separation_mode )
{
#line 281
case 0:
{
w_s      = curve( max( 1.0f - cWeight * 2.0f, 0.0f ));
w_h      = curve( max(( cWeight - 0.5f ) * 2.0f, 0.0f ));
w_m      = saturate( 1.0f - w_s - w_h );
} break;
#line 300
case 1:
{
w_s      = pow( 1.0f - cWeight, 4.0f );
w_h      = pow( cWeight, 4.0f );
w_m      = saturate( 1.0f - w_s - w_h );
} break;
}
#line 310
color.xyz        = lerp( color.xyz, cWeight, CGdesat );
#line 313
float3 LS_col;
float3 DS_col;
#line 317
float3 LS_b_s    = blendmode( color.xyz, blendcolor_ls_s.xyz, blendmode_ls_s, opacity_ls_s );
float3 LS_b_m    = blendmode( color.xyz, blendcolor_ls_m.xyz, blendmode_ls_m, opacity_ls_m );
LS_col.xyz       = LS_b_s.xyz * w_s + LS_b_m.xyz * w_m + w_h;
#line 322
float3 DS_b_s    = blendmode( color.xyz, blendcolor_ds_s.xyz, blendmode_ds_s, opacity_ds_s );
float3 DS_b_m    = blendmode( color.xyz, blendcolor_ds_m.xyz, blendmode_ds_m, opacity_ds_m );
DS_col.xyz       = DS_b_s.xyz * w_s + DS_b_m.xyz * w_m + w_h;
#line 327
float3 new_c     = lerp( DS_col.xyz, LS_col.xyz, sceneluma );
new_c.xyz        = ( enable_ds ) ? new_c.xyz : LS_col.xyz;
color.xyz        = lerp( color.xyz, new_c.xyz, finalmix );
#line 331
return float4( color.xyz, 1.0f );
}
#line 334
float PS_PrevAvgLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float avgLuma    = tex2D( samplerAvgLuma, float2( 0.5f, 0.5f )).x;
return avgLuma; 
}
#line 341
technique prod80_04_ColorGradient
{
pass Luma
{
VertexShader   = PostProcessVS;
PixelShader    = PS_WriteLuma;
RenderTarget   = texLuma;
}
pass AvgLuma
{
VertexShader   = PostProcessVS;
PixelShader    = PS_AvgLuma;
RenderTarget   = texAvgLuma;
}
pass ColorGradients
{
VertexShader   = PostProcessVS;
PixelShader    = PS_ColorGradients;
}
pass PreviousLuma
{
VertexShader   = PostProcessVS;
PixelShader    = PS_PrevAvgLuma;
RenderTarget   = texPrevAvgLuma;
}
}
}

