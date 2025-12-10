// BLOOM_USE_FOCUS_BLOOM=0
// BLOOM_LIMITER=0.0001
// BLOOM_LOOPCOUNT=300
// BLOOM_QUALITY_0_TO_2=1
// BLOOM_ENABLE_CA=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_02_Bloom.fx"
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
#line 35 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_02_Bloom.fx"
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
#line 36 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_02_Bloom.fx"
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
#line 37 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_02_Bloom.fx"
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
#line 38 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_02_Bloom.fx"
#line 39
namespace pd80_hqbloom
{
#line 80
uniform bool debugBloom <
ui_label  = "Show only bloom on screen";
ui_category = "Bloom debug";
> = false;
uniform float dither_strength <
ui_label = "Bloom Dither Stength";
ui_tooltip = "Bloom Dither Stength";
ui_category = "Bloom";
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
> = 2.0;
uniform float BloomMix <
ui_label = "Bloom Mix";
ui_tooltip = "Bloom Mix";
ui_category = "Bloom";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.5;
uniform float BloomLimit <
ui_label = "Bloom Threshold";
ui_tooltip = "Bloom Threshold";
ui_category = "Bloom";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.333;
uniform float GreyValue <
ui_label = "Bloom Exposure 50% Greyvalue";
ui_tooltip = "Bloom Exposure 50% Greyvalue";
ui_category = "Bloom";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.333;
uniform float bExposure <
ui_label = "Bloom Exposure";
ui_tooltip = "Bloom Exposure";
ui_category = "Bloom";
ui_type = "slider";
ui_min = -1.0;
ui_max = 5.0;
> = 0.0;
#line 142
uniform float BlurSigma <
ui_label = "Bloom Width";
ui_tooltip = "Bloom Width";
ui_category = "Bloom";
ui_type = "slider";
ui_min = 10.0;
ui_max = 300.0;
> = 30.0;
uniform float BloomSaturation <
ui_label = "Bloom Add Saturation";
ui_tooltip = "Bloom Add Saturation";
ui_category = "Bloom";
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
> = 0.0;
#line 159
uniform bool enableBKelvin <
ui_label  = "Enable Bloom Color Temp (K)";
ui_tooltip = "Enable Bloom Color Temp (K)";
ui_category = "Bloom Color Temperature";
> = false;
uniform uint BKelvin <
ui_type = "slider";
ui_label = "Bloom Color Temp (K)";
ui_tooltip = "Bloom Color Temp (K)";
ui_category = "Bloom Color Temperature";
ui_min = 1000;
ui_max = 40000;
> = 6500;
#line 213
texture texPrepLOD { Width = 1920; Height = 1018; MipLevels = 5; };
texture texBLuma { Width = 256; Height = 256; Format = R16F; MipLevels = 9; };
texture texBAvgLuma { Format = R16F; };
texture texBPrevAvgLuma { Format = R16F; };
#line 234
texture texBloomIn { Width = ( 1920 / 2 ); Height = ( 1018 / 2 ); Format = RGBA16F; };
texture texBloomH { Width = ( 1920 / 2 ); Height = ( 1018 / 2 ); Format = RGBA16F; };
texture texBloom { Width = ( 1920 / 2 ); Height = ( 1018 / 2 ); Format = RGBA16F; };
texture texBloomAll { Width = ( 1920 / 2 ); Height = ( 1018 / 2 ); Format = RGBA16F; };
#line 256
sampler samplerLODColor { Texture = texPrepLOD; };
sampler samplerLinColor { Texture = ReShade::BackBufferTex; SRGBTexture = true; };
sampler samplerBLuma { Texture = texBLuma; };
sampler samplerBAvgLuma { Texture = texBAvgLuma; };
sampler samplerBPrevAvgLuma { Texture = texBPrevAvgLuma; };
sampler samplerBloomIn
{
Texture = texBloomIn;
AddressU = BORDER;
AddressV = BORDER;
AddressW = BORDER;
};
sampler samplerBloomH
{
Texture = texBloomH;
AddressU = BORDER;
AddressV = BORDER;
AddressW = BORDER;
};
#line 288
sampler samplerBloom { Texture = texBloom; };
sampler samplerBloomAll { Texture = texBloomAll; };
#line 291
uniform float frametime < source = "frametime"; >;
#line 297
float getLuminance( in float3 x )
{
return dot( x, float3(0.212656, 0.715158, 0.072186) );
}
#line 302
float Log2Exposure( in float avgLuminance, in float GreyValue )
{
float exposure   = 0.0f;
avgLuminance     = max(avgLuminance, 0.000001f);
#line 308
float linExp     = GreyValue / avgLuminance;
exposure         = log2( linExp );
return exposure;
}
#line 313
float3 CalcExposedColor( in float3 color, in float avgLuminance, in float offset, in float GreyValue )
{
float exposure   = Log2Exposure( avgLuminance, GreyValue );
exposure         += offset; 
return exp2( exposure ) * color;
}
#line 320
float3 screen( in float3 c, in float3 b )
{
return 1.0f - ( 1.0f - c ) * ( 1.0f - b );
}
#line 329
float PS_WriteBLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2D( samplerLinColor, texcoord );
float luma       = getLuminance( color.xyz );
luma             = max( luma, BloomLimit ); 
return log2( luma );
}
#line 337
float PS_AvgBLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float luma       = tex2Dlod( samplerBLuma, float4(0.5f, 0.5f, 0, 8 )).x;
luma             = exp2( luma );
float prevluma   = tex2D( samplerBPrevAvgLuma, float2( 0.5f, 0.5f )).x;
float fps        = max( 1000.0f / frametime, 0.001f );
fps              *= 0.5f; 
float avgLuma    = lerp( prevluma, luma, saturate( 1.0f / fps ));
return avgLuma;
}
#line 348
float4 PS_PrepLOD(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return tex2D( ReShade::BackBuffer, texcoord );
}
#line 353
float4 PS_BloomIn(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2Dlod( samplerLODColor, float4( texcoord.xy, 0, 1 ));
float luma       = tex2D( samplerBAvgLuma, float2( 0.5f, 0.5f )).x;
luma             = clamp( luma, 0.000001f, 0.999999f );
color.xyz        = saturate( color.xyz - luma ) / saturate( 1.0f - luma );
color.xyz        = CalcExposedColor( color.xyz, luma, bExposure, GreyValue );
return float4( color.xyz, 1.0f );
}
#line 364
float4 PS_GaussianH(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2D( samplerBloomIn, texcoord );
float px         = rcp( ( 1920 / 2 ) );
float SigmaSum   = 0.0f;
float pxlOffset  = 1.5f;
float2 buffSigma = 0.0f;
#line 374
float bSigma = BlurSigma * 0.5f;
#line 379
float3 Sigma;
Sigma.x          = 1.0f / ( sqrt( 2.0f * 3.1415926535897932 ) * bSigma );
Sigma.y          = exp( -0.5f / ( bSigma * bSigma ));
Sigma.z          = Sigma.y * Sigma.y;
#line 385
color.xyz        *= Sigma.x;
#line 387
SigmaSum         += Sigma.x;
#line 389
Sigma.xy         *= Sigma.yz;
#line 391
[loop]
for( int i = 0; i < 300 && Sigma.x > 0.0001; ++i )
{
buffSigma.x  = Sigma.x * Sigma.y;
buffSigma.y  = Sigma.x + buffSigma.x;
color        += tex2Dlod( samplerBloomIn, float4( texcoord.xy + float2( pxlOffset * px, 0.0f ), 0, 0 )) * buffSigma.y;
color        += tex2Dlod( samplerBloomIn, float4( texcoord.xy - float2( pxlOffset * px, 0.0f ), 0, 0 )) * buffSigma.y;
SigmaSum     += ( 2.0f * Sigma.x + 2.0f * buffSigma.x );
pxlOffset    += 2.0f;
Sigma.xy     *= Sigma.yz;
Sigma.xy     *= Sigma.yz;
}
#line 404
color            /= SigmaSum;
return color;
}
#line 492
float4 PS_GaussianV(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2D( samplerBloomH, texcoord );
float py         = rcp( ( 1018 / 2 ) );
float SigmaSum   = 0.0f;
float pxlOffset  = 1.5f;
float2 buffSigma = 0.0f;
#line 502
float bSigma = BlurSigma * 0.5f;
#line 507
float3 Sigma;
Sigma.x          = 1.0f / ( sqrt( 2.0f * 3.1415926535897932 ) * bSigma );
Sigma.y          = exp( -0.5f / ( bSigma * bSigma ));
Sigma.z          = Sigma.y * Sigma.y;
#line 513
color.xyz        *= Sigma.x;
#line 515
SigmaSum         += Sigma.x;
#line 517
Sigma.xy         *= Sigma.yz;
#line 519
[loop]
for( int i = 0; i < 300 && Sigma.x > 0.0001; ++i )
{
buffSigma.x  = Sigma.x * Sigma.y;
buffSigma.y  = Sigma.x + buffSigma.x;
color        += tex2Dlod( samplerBloomH, float4( texcoord.xy + float2( 0.0f, pxlOffset * py ), 0, 0 )) * buffSigma.y;
color        += tex2Dlod( samplerBloomH, float4( texcoord.xy - float2( 0.0f, pxlOffset * py ), 0, 0 )) * buffSigma.y;
SigmaSum     += ( 2.0f * Sigma.x + 2.0f * buffSigma.x );
pxlOffset    += 2.0f;
Sigma.xy     *= Sigma.yz;
Sigma.xy     *= Sigma.yz;
}
#line 532
color            /= SigmaSum;
return color;
}
#line 582
float4 PS_Combine(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 widebloom = tex2D( samplerBloom, texcoord );
#line 589
return widebloom;
#line 591
}
#line 674
float4 PS_Gaussian(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 677
float4 bloom     = tex2D( samplerBloomAll, texcoord );
#line 682
float4 color     = tex2D( ReShade::BackBuffer, texcoord );
#line 684
float4 dnoise    = dither( samplerRGBNoise, texcoord.xy, 0, 1, dither_strength, 1, 2.0f - ( 1.0f - BloomLimit ) );
float3 steps     = smoothstep( 0.0f, 0.012f, bloom.xyz );
bloom.xyz        = saturate( bloom.xyz + dnoise.xyz * steps.xyz );
#line 689
if( enableBKelvin )
{
float3 K       = KelvinToRGB( BKelvin );
float3 bLum    = RGBToHSL( bloom.xyz );
float3 retHSV  = RGBToHSL( bloom.xyz * K.xyz );
bloom.xyz      = HSLToRGB( float3( retHSV.xy, bLum.z ));
}
#line 698
bloom.xyz        = vib( bloom.xyz, BloomSaturation );
float3 bcolor    = screen( color.xyz, bloom.xyz );
color.xyz        = lerp( color.xyz, bcolor.xyz, BloomMix );
color.xyz        = debugBloom ? bloom.xyz : color.xyz; 
return float4( color.xyz, 1.0f );
}
#line 705
float PS_PrevAvgBLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float avgLuma    = tex2D( samplerBAvgLuma, float2( 0.5f, 0.5f )).x;
return avgLuma;
}
#line 712
technique prod80_02_Bloom
< ui_tooltip = "Bloom\n\n"
"Bloom is an effect that causes diffraction of light around bright reflective or emittive sources\n\n"
"Preprocessor Settings\n\n"
"BLOOM_ENABLE_CA: Enables a chromatic aberration effect on bloom\n\n"
"BLOOM_QUALITY_0_TO_2: Sets the quality, 0 is full (and heavy!), 2 is low and very fast,\n"
"1 is high quality and best trade off between quality and performance\n\n"
"BLOOM_LOOPCOUNT: Limit to the amount of loops of the Width effect. Wider blooms may need higher\n"
"values (eg. max width is 300, this value should be 300)\n\n"
"BLOOM_LIMITER: Limiter to the bloom. Wider blooms may need lower values or the bloom starts to look\n"
"rectangular (eg. 0.0001 (default) is good to about width 100, after that start to decrease this value)\n\n"
"BLOOM_USE_FOCUS_BLOOM: Enables another pass to add a narrow bloom on top of the wide bloom";>
{
pass BLuma
{
VertexShader   = PostProcessVS;
PixelShader    = PS_WriteBLuma;
RenderTarget   = texBLuma;
}
pass AvgBLuma
{
VertexShader   = PostProcessVS;
PixelShader    = PS_AvgBLuma;
RenderTarget   = texBAvgLuma;
}
pass PrepLod
{
VertexShader   = PostProcessVS;
PixelShader    = PS_PrepLOD;
RenderTarget   = texPrepLOD;
}
pass BloomIn
{
VertexShader   = PostProcessVS;
PixelShader    = PS_BloomIn;
RenderTarget   = texBloomIn;
}
#line 759
pass GaussianH
{
VertexShader   = PostProcessVS;
PixelShader    = PS_GaussianH;
RenderTarget   = texBloomH;
}
#line 766
pass GaussianV
{
VertexShader   = PostProcessVS;
PixelShader    = PS_GaussianV;
RenderTarget   = texBloom;
}
#line 780
pass Combine
{
VertexShader   = PostProcessVS;
PixelShader    = PS_Combine;
RenderTarget   = texBloomAll;
}
#line 787
pass GaussianBlur
{
VertexShader   = PostProcessVS;
PixelShader    = PS_Gaussian;
}
#line 806
pass PreviousBLuma
{
VertexShader   = PostProcessVS;
PixelShader    = PS_PrevAvgBLuma;
RenderTarget   = texBPrevAvgLuma;
}
}
}

