#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_02_Cinetools_LUT.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_LUT_v2.fxh"
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
#line 18 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_LUT_v2.fxh"
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
#line 19 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_LUT_v2.fxh"
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
#line 20 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_LUT_v2.fxh"
#line 21
namespace prod80_02_Cinetools_LUTName
{
#line 25
uniform bool enable_dither <
ui_label = "Enable Dithering";
ui_tooltip = "Enable Dithering";
> = true;
uniform float dither_strength <
ui_type = "slider";
ui_label = "Dither Strength";
ui_tooltip = "Dither Strength";
ui_min = 0.0f;
ui_max = 10.0f;
> = 1.0;
uniform int PD80_LutSelector <
ui_type = "combo";
ui_items= "FilmicGold\0FilmicGold_Contrast\0FilmicBlue\0FilmicBlue_Contrast\0TealOrangeNeutral\0TealOrangeYCSplit\0TealOrangeWarmMatte\0CinematicColors\0UltraWarmMatte\0UltraMatte\0BW-Max\0BW-MaxSepia\0BW-MatteLooks\0AlternativeProcess-01\0AlternativeProcess-02\0SuperGreens\0ColorHarmony-01\0ColorHarmony-02\0GoingBrownAgain\0Cyanolyte\0DustyOldMan\0DustyOldMatte\0DrankAllTheRedWine\0OldEleganceClean\0OldEleganceMatte\0HundredDollarStripper\0HundredDollarStripperMatte\0ClassicTealOrange\0ClassicTealOrangeMatte\0ClassicTealOrangeYHL\0ClassicTealOrangeYHLMatte\0";
ui_label = "LUT Selection";
ui_tooltip = "The LUT to use for color transformation.";
> = 0;
uniform float PD80_MixChroma <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Chroma";
ui_tooltip = "LUT Chroma";
> = 1.00;
uniform float PD80_MixLuma <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Luma";
ui_tooltip = "LUT Luma";
> = 1.00;
uniform float PD80_Intensity <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Intensity";
ui_tooltip = "Intensity of LUT effect";
> = 1.00;
uniform float3 ib <
ui_type = "color";
ui_label = "LUT Black IN Level";
ui_tooltip = "LUT Black IN Level";
ui_category = "LUT Levels";
> = float3(0.0, 0.0, 0.0);
uniform float3 iw <
ui_type = "color";
ui_label = "LUT White IN Level";
ui_tooltip = "LUT White IN Level";
ui_category = "LUT Levels";
> = float3(1.0, 1.0, 1.0);
uniform float3 ob <
ui_type = "color";
ui_label = "LUT Black OUT Level";
ui_tooltip = "LUT Black OUT Level";
ui_category = "LUT Levels";
> = float3(0.0, 0.0, 0.0);
uniform float3 ow <
ui_type = "color";
ui_label = "LUT White OUT Level";
ui_tooltip = "LUT White OUT Level";
ui_category = "LUT Levels";
> = float3(1.0, 1.0, 1.0);
uniform float ig <
ui_label = "LUT Gamma Adjustment";
ui_tooltip = "LUT Gamma Adjustment";
ui_category = "LUT Levels";
ui_type = "slider";
ui_min = 0.05;
ui_max = 10.0;
> = 1.0;
#line 94
texture prod80_02_Cinetools_LUTTex < source = "pd80_cinelut.png"; >
{
Width = 64 * 64;
Height = 64 * 31;
};
sampler	prod80_02_Cinetools_LUTSamp { Texture = prod80_02_Cinetools_LUTTex; };
#line 102
float3 levels( float3 color, float3 blackin, float3 whitein, float gamma, float3 outblack, float3 outwhite )
{
float3 ret       = saturate( color.xyz - blackin.xyz ) / max( whitein.xyz - blackin.xyz, 0.000001f );
ret.xyz          = pow( ret.xyz, gamma );
ret.xyz          = ret.xyz * saturate( outwhite.xyz - outblack.xyz ) + outblack.xyz;
return ret;
}
#line 111
void PS_MultiLUT_v2( float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target0 )
{
color            = tex2D( ReShade::BackBuffer, texcoord.xy );
float4 dnoise    = dither( samplerRGBNoise, texcoord.xy, 10, enable_dither, dither_strength, 1, 0.5f );
#line 116
float2 texelsize = rcp( 64 );
texelsize.x     /= 64;
#line 119
float3 lutcoord  = float3(( color.xy * 64 - color.xy + 0.5f ) * texelsize.xy, color.z * 64 - color.z );
lutcoord.y      /= 31;
lutcoord.y      += ( float( PD80_LutSelector ) / 31 );
float lerpfact   = frac( lutcoord.z );
lutcoord.x      += ( lutcoord.z - lerpfact ) * texelsize.y;
#line 125
float3 lutcolor  = lerp( tex2D( prod80_02_Cinetools_LUTSamp, lutcoord.xy ).xyz, tex2D( prod80_02_Cinetools_LUTSamp, float2( lutcoord.x + texelsize.y, lutcoord.y )).xyz, lerpfact );
lutcolor.xyz     = levels( lutcolor.xyz,    saturate( ib.xyz + dnoise.xyz ),
saturate( iw.xyz + dnoise.yzx ),
ig,
saturate( ob.xyz + dnoise.zxy ),
saturate( ow.xyz + dnoise.wxz ));
float3 lablut    = pd80_srgb_to_lab( lutcolor.xyz );
float3 labcol    = pd80_srgb_to_lab( color.xyz );
float newluma    = lerp( labcol.x, lablut.x, PD80_MixLuma );
float2 newAB     = lerp( labcol.yz, lablut.yz, PD80_MixChroma );
lutcolor.xyz     = pd80_lab_to_srgb( float3( newluma, newAB ));
color.xyz        = lerp( color.xyz, saturate( lutcolor.xyz + dnoise.wzx ), PD80_Intensity );
}
#line 140
technique prod80_02_Cinetools_LUT
{
pass MultiLUT_Apply
{
VertexShader = PostProcessVS;
PixelShader  = PS_MultiLUT_v2;
}
}
}

