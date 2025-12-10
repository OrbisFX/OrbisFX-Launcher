#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Color_Space_Curves.fx"
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
#line 40 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Color_Space_Curves.fx"
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
#line 41 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Color_Space_Curves.fx"
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
#line 42 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Color_Space_Curves.fx"
#line 43
namespace pd80_cscurves
{
#line 48
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
uniform int color_space <
ui_type = "combo";
ui_category = "Global";
ui_label = "Color Space";
ui_tooltip = "Color Space";
ui_items = "RGB-W\0L* a* b*\0HSL\0HSV\0";
> = 1;
#line 69
uniform float pos0_shoulder_grey <
ui_type = "slider";
ui_label = "Shoulder Position X";
ui_tooltip = "Shoulder Position X";
ui_category = "Contrast Curves";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.8;
uniform float pos1_shoulder_grey <
ui_type = "slider";
ui_label = "Shoulder Position Y";
ui_tooltip = "Shoulder Position Y";
ui_category = "Contrast Curves";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.8;
uniform float pos0_toe_grey <
ui_type = "slider";
ui_label = "Toe Position X";
ui_tooltip = "Toe Position X";
ui_category = "Contrast Curves";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.2;
uniform float pos1_toe_grey <
ui_type = "slider";
ui_label = "Toe Position Y";
ui_tooltip = "Toe Position Y";
ui_category = "Contrast Curves";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.2;
#line 102
uniform float colorsat <
ui_type = "slider";
ui_category = "Color Control";
ui_label = "Saturation";
ui_tooltip = "Saturation";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
#line 116
struct TonemapParams
{
float3 mToe;
float2 mMid;
float3 mShoulder;
float2 mBx;
};
#line 125
float3 Tonemap(const TonemapParams tc, float3 x)
{
float3 toe = - tc.mToe.x / (x + tc.mToe.y) + tc.mToe.z;
float3 mid = tc.mMid.x * x + tc.mMid.y;
float3 shoulder = - tc.mShoulder.x / (x + tc.mShoulder.y) + tc.mShoulder.z;
float3 result = ( x >= tc.mBx.x ) ? mid : toe;
result = ( x >= tc.mBx.y ) ? shoulder : result;
return result;
}
#line 136
float4 setBoundaries( float tx, float ty, float sx, float sy )
{
if( tx > sx )
tx = sx;
if( ty > sy )
ty = sy;
return float4( tx, ty, sx, sy );
}
#line 145
void PrepareTonemapParams(float2 p1, float2 p2, float2 p3, out TonemapParams tc)
{
float denom = p2.x - p1.x;
denom = abs(denom) > 1e-5 ? denom : 1e-5;
float slope = (p2.y - p1.y) / denom;
{
tc.mMid.x = slope;
tc.mMid.y = p1.y - slope * p1.x;
}
{
float denom = p1.y - slope * p1.x;
denom = abs(denom) > 1e-5 ? denom : 1e-5;
tc.mToe.x = slope * p1.x * p1.x * p1.y * p1.y / (denom * denom);
tc.mToe.y = slope * p1.x * p1.x / denom;
tc.mToe.z = p1.y * p1.y / denom;
}
{
float denom = slope * (p2.x - p3.x) - p2.y + p3.y;
denom = abs(denom) > 1e-5 ? denom : 1e-5;
tc.mShoulder.x = slope * pow(p2.x - p3.x, 2.0) * pow(p2.y - p3.y, 2.0) / (denom * denom);
tc.mShoulder.y = (slope * p2.x * (p3.x - p2.x) + p3.x * (p2.y - p3.y) ) / denom;
tc.mShoulder.z = (-p2.y * p2.y + p3.y * (slope * (p2.x - p3.x) + p2.y) ) / denom;
}
tc.mBx = float2(p1.x, p2.x);
}
#line 172
float4 PS_CSCurves(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color      = tex2D( ReShade::BackBuffer, texcoord );
#line 178
float4 dnoise     = dither( samplerRGBNoise, texcoord.xy, 1, enable_dither, dither_strength, 1, 0.5f );
color.xyz         = saturate( color.xyz + dnoise.xyz );
#line 182
float4 grey       = setBoundaries( pos0_toe_grey, pos1_toe_grey, pos0_shoulder_grey, pos1_shoulder_grey );
TonemapParams tc;
PrepareTonemapParams( grey.xy, grey.zw, float2( 1.0f, 1.0f ), tc );
#line 187
float rgb_luma    = min( min( color.x, color.y ), color.z );
float temp_luma   = rgb_luma;
float3 rgb_chroma = color.xyz - rgb_luma;
rgb_luma          = Tonemap( tc, rgb_luma.xxx ).x;
rgb_chroma       *= ( colorsat + 1.0f );
#line 194
float3 lab_color  = pd80_srgb_to_lab( color.xyz );
lab_color.x       = Tonemap( tc, lab_color.xxx ).x;
lab_color.yz     *= ( colorsat + 1.0f );
#line 199
float3 hsl_color  = RGBToHSL( color.xyz );
hsl_color.z       = Tonemap( tc, hsl_color.zzz ).z;
hsl_color.y      *= ( colorsat + 1.0f );
#line 204
float3 hsv_color  = RGBToHSV( color.xyz );
hsv_color.z       = Tonemap( tc, hsv_color.zzz ).z;
hsv_color.y      *= ( colorsat + 1.0f );
#line 208
switch( color_space )
{
case 0: { color.xyz = saturate( rgb_chroma.xyz + rgb_luma ); } break;
case 1: { color.xyz = pd80_lab_to_srgb( lab_color.xyz );     } break;
case 2: { color.xyz = HSLToRGB( saturate( hsl_color.xyz ));  } break;
case 3: { color.xyz = HSVToRGB( saturate( hsv_color.xyz ));  } break;
}
#line 216
color.xyz         = saturate( color.xyz + dnoise.wxy );
return float4(color.xyz, 1.0f );
}
#line 221
technique prod80_03_Color_Space_Curves
{
pass prod80_CCpass0
{
VertexShader   = PostProcessVS;
PixelShader    = PS_CSCurves;
}
}
}

