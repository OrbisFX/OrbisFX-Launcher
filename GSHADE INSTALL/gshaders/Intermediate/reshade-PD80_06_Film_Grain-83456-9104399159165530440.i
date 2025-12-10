// FG_GRAIN_SMOOTHING=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_06_Film_Grain.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_06_Film_Grain.fx"
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
#line 35 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_06_Film_Grain.fx"
#line 40
namespace pd80_filmgrain
{
#line 43
uniform bool enable_test <
ui_label = "Enable Setup Mode";
ui_tooltip = "Enable Setup Mode";
ui_category = "Film Grain (simplex)";
> = false;
uniform int grainMotion <
ui_label = "Grain Motion";
ui_tooltip = "Grain Motion";
ui_category = "Film Grain (simplex)";
ui_type = "combo";
ui_items = "Disabled\0Enabled\0";
> = 1;
uniform float grainAdjust <
ui_type = "slider";
ui_label = "Grain Pattern Adjust (for still noise)";
ui_tooltip = "Grain Pattern Adjust (for still noise)";
ui_category = "Film Grain (simplex)";
ui_min = 1.0f;
ui_max = 2.0f;
> = 1.0;
uniform int grainSize <
ui_type = "slider";
ui_label = "Grain Size";
ui_tooltip = "Grain Size";
ui_category = "Film Grain (simplex)";
ui_min = 1;
ui_max = 4;
> = 1;
#line 81
uniform int grainOrigColor <
ui_label = "Use Original Color";
ui_tooltip = "Use Original Color";
ui_category = "Film Grain (simplex)";
ui_type = "combo";
ui_items = "Use Random Color\0Use Original Color\0";
> = 1;
uniform bool use_negnoise <
ui_label = "Use Negative Noise (highlights)";
ui_tooltip = "Use Negative Noise (highlights)";
ui_category = "Film Grain (simplex)";
> = false;
uniform float grainColor <
ui_type = "slider";
ui_label = "Grain Color Amount";
ui_tooltip = "Grain Color Amount";
ui_category = "Film Grain (simplex)";
ui_min = 0.0f;
ui_max = 1.0f;
> = 1.0;
uniform float grainAmount <
ui_type = "slider";
ui_label = "Grain Amount";
ui_tooltip = "Grain Amount";
ui_category = "Film Grain (simplex)";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.333;
uniform float grainIntensity <
ui_type = "slider";
ui_label = "Grain Intensity";
ui_tooltip = "Grain Intensity";
ui_category = "Film Grain (simplex)";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.65;
uniform float grainDensity <
ui_type = "slider";
ui_label = "Grain Density";
ui_tooltip = "Grain Density";
ui_category = "Film Grain (simplex)";
ui_min = 0.0f;
ui_max = 10.0f;
> = 10.0;
uniform float grainIntHigh <
ui_type = "slider";
ui_label = "Grain Intensity Highlights";
ui_tooltip = "Grain Intensity Highlights";
ui_category = "Film Grain (simplex)";
ui_min = 0.0f;
ui_max = 1.0f;
> = 1.0;
uniform float grainIntLow <
ui_type = "slider";
ui_label = "Grain Intensity Shadows";
ui_tooltip = "Grain Intensity Shadows";
ui_category = "Film Grain (simplex)";
ui_min = 0.0f;
ui_max = 1.0f;
> = 1.0;
uniform bool enable_depth <
ui_label = "Enable depth based adjustments.\nMake sure you have setup your depth buffer correctly.";
ui_tooltip = "Enable depth based adjustments";
ui_category = "Film Grain (simplex): Depth";
> = false;
uniform bool display_depth <
ui_label = "Show depth texture";
ui_tooltip = "Show depth texture";
ui_category = "Film Grain (simplex): Depth";
> = false;
uniform float depthStart <
ui_type = "slider";
ui_label = "Change Depth Start Plane";
ui_tooltip = "Change Depth Start Plane";
ui_category = "Film Grain (simplex): Depth";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.0;
uniform float depthEnd <
ui_type = "slider";
ui_label = "Change Depth End Plane";
ui_tooltip = "Change Depth End Plane";
ui_category = "Film Grain (simplex): Depth";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.1;
uniform float depthCurve <
ui_label = "Depth Curve Adjustment";
ui_tooltip = "Depth Curve Adjustment";
ui_category = "Film Grain (simplex): Depth";
ui_type = "slider";
ui_min = 0.05;
ui_max = 8.0;
> = 1.0;
#line 176
texture texPerm < source = "pd80_permtexture.png"; > { Width = 256; Height = 256; Format = RGBA8; };
texture texNoise { Width = 1920; Height = 1018; Format = RGBA16F; };
#line 184
sampler samplerPermTex { Texture = texPerm; };
sampler samplerNoise { Texture = texNoise; };
#line 197
uniform float Timer < source = "timer"; >;
#line 199
float4 rnm( float2 tc, float t )
{
float noise       = sin( dot( tc, float2( 12.9898, 78.233 ))) * ( 43758.5453 + t );
float noiseR      = frac( noise * grainAdjust ) * 2.0 - 1.0;
float noiseG      = frac( noise * 1.2154 * grainAdjust ) * 2.0 - 1.0;
float noiseB      = frac( noise * 1.3453 * grainAdjust ) * 2.0 - 1.0;
float noiseA      = frac( noise * 1.3647 * grainAdjust ) * 2.0 - 1.0;
return float4( noiseR, noiseG, noiseB, noiseA );
}
#line 209
float fade( float t )
{
return t * t * t * ( t * ( t * 6.0 - 15.0 ) + 10.0 );
}
#line 214
float curve( float x )
{
return x * x * ( 3.0 - 2.0 * x );
}
#line 219
float pnoise3D( float3 p, float t )
{
float3 pi         = 1.0f / 256.0f * floor( p ) + 0.5f * 1.0f / 256.0f;
pi.xy             *= 256;
pi.xy             = round(( pi.xy - 0.5f * 1.0f / 256.0f ) / grainSize ) * grainSize;
pi.xy             /= 256;
float3 pf         = frac( p );
#line 227
float perm00      = rnm( pi.xy, t ).x;
float3 grad000    = tex2D( samplerPermTex, float2( perm00, pi.z )).xyz * 4.0 - 1.0;
float n000        = dot( grad000, pf );
float3 grad001    = tex2D( samplerPermTex, float2( perm00, pi.z + 1.0f / 256.0f )).xyz * 4.0 - 1.0;
float n001        = dot( grad001, pf - float3( 0.0, 0.0, 1.0 ));
#line 233
float perm01      = rnm( pi.xy + float2( 0.0, 1.0f / 256.0f ), t ).y ;
float3  grad010   = tex2D( samplerPermTex, float2( perm01, pi.z )).xyz * 4.0 - 1.0;
float n010        = dot( grad010, pf - float3( 0.0, 1.0, 0.0 ));
float3  grad011   = tex2D( samplerPermTex, float2( perm01, pi.z + 1.0f / 256.0f )).xyz * 4.0 - 1.0;
float n011        = dot( grad011, pf - float3( 0.0, 1.0, 1.0 ));
#line 239
float perm10      = rnm( pi.xy + float2( 1.0f / 256.0f, 0.0 ), t ).z ;
float3  grad100   = tex2D( samplerPermTex, float2( perm10, pi.z )).xyz * 4.0 - 1.0;
float n100        = dot( grad100, pf - float3( 1.0, 0.0, 0.0 ));
float3  grad101   = tex2D( samplerPermTex, float2( perm10, pi.z + 1.0f / 256.0f )).xyz * 4.0 - 1.0;
float n101        = dot( grad101, pf - float3( 1.0, 0.0, 1.0 ));
#line 245
float perm11      = rnm( pi.xy + float2( 1.0f / 256.0f, 1.0f / 256.0f ), t ).w ;
float3  grad110   = tex2D( samplerPermTex, float2( perm11, pi.z )).xyz * 4.0 - 1.0;
float n110        = dot( grad110, pf - float3( 1.0, 1.0, 0.0 ));
float3  grad111   = tex2D( samplerPermTex, float2( perm11, pi.z + 1.0f / 256.0f )).xyz * 4.0 - 1.0;
float n111        = dot( grad111, pf - float3( 1.0, 1.0, 1.0 ));
#line 251
float4 n_x        = lerp( float4( n000, n001, n010, n011 ), float4( n100, n101, n110, n111 ), fade( pf.x ));
#line 253
float2 n_xy       = lerp( n_x.xy, n_x.zw, fade( pf.y ));
#line 255
float n_xyz       = lerp( n_xy.x, n_xy.y, fade( pf.z ));
#line 257
return n_xyz;
}
#line 260
float getAvgColor( float3 col )
{
return dot( col.xyz, float3( 0.333333f, 0.333334f, 0.333333f ));
}
#line 267
float3 ClipColor( float3 color )
{
float lum         = getAvgColor( color.xyz );
float mincol      = min( min( color.x, color.y ), color.z );
float maxcol      = max( max( color.x, color.y ), color.z );
color.xyz         = ( mincol < 0.0f ) ? lum + (( color.xyz - lum ) * lum ) / ( lum - mincol ) : color.xyz;
color.xyz         = ( maxcol > 1.0f ) ? lum + (( color.xyz - lum ) * ( 1.0f - lum )) / ( maxcol - lum ) : color.xyz;
return color;
}
#line 279
float3 blendLuma( float3 base, float3 blend )
{
float lumbase     = getAvgColor( base.xyz );
float lumblend    = getAvgColor( blend.xyz );
float ldiff       = lumblend - lumbase;
float3 col        = base.xyz + ldiff;
return ClipColor( col.xyz );
}
#line 289
float4 PS_FilmGrain(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 292
float timer       = 1.0f;
if( grainMotion )
timer         = Timer % 1000.0f;
float2 uv         = texcoord.xy * float2( 1920, 1018 );
float3 noise      = pnoise3D( float3( uv.xy, 1 ), timer );
noise.y           = pnoise3D( float3( uv.xy, 2 ), timer );
noise.z           = pnoise3D( float3( uv.xy, 3 ), timer );
#line 301
noise.xyz         *= grainIntensity;
#line 304
noise.xyz         = lerp( noise.xxx, noise.xyz, grainColor );
#line 307
noise.xyz         = pow( abs( noise.xyz ), max( 11.0f - grainDensity, 0.1f )) * sign( noise.xyz );
#line 311
noise.xyz         = saturate(( noise.xyz + 1.0f ) * 0.5f );
#line 313
return float4( noise.xyz, 1.0f );
}
#line 376
float4 PS_MergeNoise(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 381
float4 noise      = tex2D( samplerNoise, texcoord );
#line 383
float4 color      = tex2D( ReShade::BackBuffer, texcoord );
#line 386
noise.xyz         = noise.xyz * 2.0f - 1.0f;
#line 389
float depth       = ReShade::GetLinearizedDepth( texcoord ).x;
depth             = smoothstep( depthStart, depthEnd, depth );
depth             = pow( depth, depthCurve );
float d           = enable_depth ? depth : 1.0f;
#line 395
float3 testenv    = ( texcoord.y < 0.25f ) ? texcoord.xxx : ( texcoord.y < 0.5f ) ? float3( texcoord.x, 0.0f, 0.0f ) :
( texcoord.y < 0.75f ) ? float3( 0.0f, texcoord.x, 0.0f ) : float3( 0.0f, 0.0f, texcoord.x );
color.xyz         = enable_test ? testenv.xyz : color.xyz;
#line 400
float3 origHSV    = RGBToHSV( color.xyz );
float3 orig       = color.xyz;
float maxc        = max( max( color.x, color.y ), color.z );
float minc        = min( min( color.x, color.y ), color.z );
#line 406
float lum         = maxc;
noise.xyz         = lerp( noise.xyz * grainIntLow, noise.xyz * grainIntHigh, fade( lum )); 
float3 negnoise   = -abs( noise.xyz );
lum               *= lum;
#line 412
negnoise.xyz      = lerp( noise.xyz, negnoise.zxy * 0.5f, lum );
noise.xyz         = use_negnoise ? negnoise.xyz : noise.xyz;
#line 419
float factor      = 1.2f;
float weight      = max( 1.0f - abs(( origHSV.x - 0.166667f ) * 6.0f ), 0.0f ) * factor;
weight            += max( 1.0f - abs(( origHSV.x - 0.333333f ) * 6.0f ), 0.0f ) / factor;
weight            = saturate( curve( weight / factor ));
#line 425
weight            *= saturate(( maxc + 1.0e-10 - minc ) / maxc + 1.0e-10 );
#line 428
float adj         = saturate(( maxc - 0.2f ) * 1.25f ) + saturate( 1.0f - maxc * 5.0f );
adj               = 1.0f - curve( adj );
weight            *= adj;
#line 433
float adjNoise    = lerp( 1.0f, 0.5f, grainOrigColor * weight );
#line 435
color.xyz         = lerp( color.xyz, color.xyz + ( noise.xyz * d ), grainAmount * adjNoise );
color.xyz         = saturate( color.xyz );
#line 439
float3 col        = blendLuma( orig.xyz, color.xyz );
color.xyz         = grainOrigColor ? col.xyz : color.xyz;
#line 442
color.xyz         = display_depth ? depth.xxx : color.xyz;
return float4( color.xyz, 1.0f );
}
#line 447
technique prod80_06_FilmGrain
{
pass prod80_WriteNoise
{
VertexShader  = PostProcessVS;
PixelShader   = PS_FilmGrain;
RenderTarget  = texNoise;
}
#line 469
pass prod80_MixNoise
{
VertexShader  = PostProcessVS;
PixelShader   = PS_MergeNoise;
}
}
}

