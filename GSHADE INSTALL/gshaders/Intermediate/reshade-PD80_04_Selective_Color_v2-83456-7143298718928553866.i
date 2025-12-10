#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Selective_Color_v2.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Selective_Color_v2.fx"
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
#line 35 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Selective_Color_v2.fx"
#line 36
namespace pd80_selectivecolorv2
{
#line 40
uniform int corr_method <
ui_label = "Correction Method";
ui_tooltip = "Correction Method";
ui_category = "Selective Color";
ui_type = "combo";
ui_items = "Absolute\0Relative\0"; 
> = 1;
#line 48
uniform float r_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Reds: Cyan";
ui_category = "Selective Color: Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float r_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Reds: Magenta";
ui_category = "Selective Color: Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float r_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Reds: Yellow";
ui_category = "Selective Color: Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float r_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Reds: Black";
ui_category = "Selective Color: Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float r_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Reds: Saturation";
ui_category = "Selective Color: Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float r_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Reds: Lightness Curve";
ui_category = "Selective Color: Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float r_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Reds: Lightness";
ui_category = "Selective Color: Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 106
uniform float o_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Oranges: Cyan";
ui_category = "Selective Color: Oranges";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float o_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Oranges: Magenta";
ui_category = "Selective Color: Oranges";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float o_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Oranges: Yellow";
ui_category = "Selective Color: Oranges";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float o_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Oranges: Black";
ui_category = "Selective Color: Oranges";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float o_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Oranges: Saturation";
ui_category = "Selective Color: Oranges";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float o_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Oranges: Lightness Curve";
ui_category = "Selective Color: Oranges";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float o_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Oranges: Lightness";
ui_category = "Selective Color: Oranges";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 164
uniform float y_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Yellows: Cyan";
ui_category = "Selective Color: Yellows";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float y_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Yellows: Magenta";
ui_category = "Selective Color: Yellows";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float y_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Yellows: Yellow";
ui_category = "Selective Color: Yellows";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float y_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Yellows: Black";
ui_category = "Selective Color: Yellows";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float y_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Yellows: Saturation";
ui_category = "Selective Color: Yellows";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float y_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Yellows: Lightness Curve";
ui_category = "Selective Color: Yellows";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float y_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Yellows: Lightness";
ui_category = "Selective Color: Yellows";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 222
uniform float yg_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Yellow-Greens: Cyan";
ui_category = "Selective Color: Yellow-Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float yg_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Yellow-Greens: Magenta";
ui_category = "Selective Color: Yellow-Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float yg_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Yellow-Greens: Yellow";
ui_category = "Selective Color: Yellow-Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float yg_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Yellow-Greens: Black";
ui_category = "Selective Color: Yellow-Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float yg_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Yellow-Greens: Saturation";
ui_category = "Selective Color: Yellow-Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float yg_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Yellow-Greens: Lightness Curve";
ui_category = "Selective Color: Yellow-Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float yg_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Yellow-Greens: Lightness";
ui_category = "Selective Color: Yellow-Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 280
uniform float g_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Greens: Cyan";
ui_category = "Selective Color: Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float g_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Greens: Magenta";
ui_category = "Selective Color: Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float g_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Greens: Yellow";
ui_category = "Selective Color: Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float g_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Greens: Black";
ui_category = "Selective Color: Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float g_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Greens: Saturation";
ui_category = "Selective Color: Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float g_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Greens: Lightness Curve";
ui_category = "Selective Color: Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float g_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Greens: Lightness";
ui_category = "Selective Color: Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 338
uniform float gc_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Green-Cyans: Cyan";
ui_category = "Selective Color: Green-Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float gc_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Green-Cyans: Magenta";
ui_category = "Selective Color: Green-Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float gc_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Green-Cyans: Yellow";
ui_category = "Selective Color: Green-Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float gc_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Green-Cyans: Black";
ui_category = "Selective Color: Green-Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float gc_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Green-Cyans: Saturation";
ui_category = "Selective Color: Green-Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float gc_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Green-Cyans: Lightness Curve";
ui_category = "Selective Color: Green-Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float gc_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Green-Cyans: Lightness";
ui_category = "Selective Color: Green-Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 396
uniform float c_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Cyans: Cyan";
ui_category = "Selective Color: Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float c_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Cyans: Magenta";
ui_category = "Selective Color: Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float c_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Cyans: Yellow";
ui_category = "Selective Color: Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float c_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Cyans: Black";
ui_category = "Selective Color: Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float c_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Cyans: Saturation";
ui_category = "Selective Color: Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float c_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Cyans: Lightness Curve";
ui_category = "Selective Color: Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float c_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Cyans: Lightness";
ui_category = "Selective Color: Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 454
uniform float cb_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Cyan-Blues: Cyan";
ui_category = "Selective Color: Cyan-Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float cb_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Cyan-Blues: Magenta";
ui_category = "Selective Color: Cyan-Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float cb_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Cyan-Blues: Yellow";
ui_category = "Selective Color: Cyan-Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float cb_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Cyan-Blues: Black";
ui_category = "Selective Color: Cyan-Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float cb_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Cyan-Blues: Saturation";
ui_category = "Selective Color: Cyan-Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float cb_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Cyan-Blues: Lightness Curve";
ui_category = "Selective Color: Cyan-Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float cb_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Cyan-Blues: Lightness";
ui_category = "Selective Color: Cyan-Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 512
uniform float b_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Blues: Cyan";
ui_category = "Selective Color: Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float b_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Blues: Magenta";
ui_category = "Selective Color: Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float b_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Blues: Yellow";
ui_category = "Selective Color: Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float b_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Blues: Black";
ui_category = "Selective Color: Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float b_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Blues: Saturation";
ui_category = "Selective Color: Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float b_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Blues: Lightness Curve";
ui_category = "Selective Color: Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float b_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Blues: Lightness";
ui_category = "Selective Color: Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 570
uniform float bm_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Blue-Magentas: Cyan";
ui_category = "Selective Color: Blue-Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float bm_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Blue-Magentas: Magenta";
ui_category = "Selective Color: Blue-Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float bm_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Blue-Magentas: Yellow";
ui_category = "Selective Color: Blue-Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float bm_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Blue-Magentas: Black";
ui_category = "Selective Color: Blue-Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float bm_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Blue-Magentas: Saturation";
ui_category = "Selective Color: Blue-Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float bm_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Blue-Magentas: Lightness Curve";
ui_category = "Selective Color: Blue-Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float bm_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Blue-Magentas: Lightness";
ui_category = "Selective Color: Blue-Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 628
uniform float m_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Magentas: Cyan";
ui_category = "Selective Color: Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float m_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Magentas: Magenta";
ui_category = "Selective Color: Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float m_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Magentas: Yellow";
ui_category = "Selective Color: Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float m_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Magentas: Black";
ui_category = "Selective Color: Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float m_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Magentas: Saturation";
ui_category = "Selective Color: Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float m_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Magentas: Lightness Curve";
ui_category = "Selective Color: Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float m_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Magentas: Lightness";
ui_category = "Selective Color: Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 686
uniform float mr_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Magenta-Reds: Cyan";
ui_category = "Selective Color: Magenta-Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float mr_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Magenta-Reds: Magenta";
ui_category = "Selective Color: Magenta-Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float mr_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Magenta-Reds: Yellow";
ui_category = "Selective Color: Magenta-Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float mr_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Magenta-Reds: Black";
ui_category = "Selective Color: Magenta-Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float mr_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Magenta-Reds: Saturation";
ui_category = "Selective Color: Magenta-Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float mr_adj_lig_curve <
ui_type = "slider";
ui_label = "Lightness Curve";
ui_tooltip = "Selective Color Magenta-Reds: Lightness Curve";
ui_category = "Selective Color: Magenta-Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float mr_adj_lig <
ui_type = "slider";
ui_label = "Lightness";
ui_tooltip = "Selective Color Magenta-Reds: Lightness";
ui_category = "Selective Color: Magenta-Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 744
uniform float w_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Whites: Cyan";
ui_category = "Selective Color: Whites";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float w_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Whites: Magenta";
ui_category = "Selective Color: Whites";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float w_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Whites: Yellow";
ui_category = "Selective Color: Whites";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float w_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Whites: Black";
ui_category = "Selective Color: Whites";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float w_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Whites: Saturation";
ui_category = "Selective Color: Whites";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 786
uniform float n_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Neutrals: Cyan";
ui_category = "Selective Color: Neutrals";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float n_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Neutrals: Magenta";
ui_category = "Selective Color: Neutrals";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float n_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Neutrals: Yellow";
ui_category = "Selective Color: Neutrals";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float n_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Neutrals: Black";
ui_category = "Selective Color: Neutrals";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float n_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Neutrals: Saturation";
ui_category = "Selective Color: Neutrals";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 828
uniform float bk_adj_cya <
ui_type = "slider";
ui_label = "Cyan";
ui_tooltip = "Selective Color Blacks: Cyan";
ui_category = "Selective Color: Blacks";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float bk_adj_mag <
ui_type = "slider";
ui_label = "Magenta";
ui_tooltip = "Selective Color Blacks: Magenta";
ui_category = "Selective Color: Blacks";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float bk_adj_yel <
ui_type = "slider";
ui_label = "Yellow";
ui_tooltip = "Selective Color Blacks: Yellow";
ui_category = "Selective Color: Blacks";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float bk_adj_bla <
ui_type = "slider";
ui_label = "Black";
ui_tooltip = "Selective Color Blacks: Black";
ui_category = "Selective Color: Blacks";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
uniform float bk_adj_sat <
ui_type = "slider";
ui_label = "Saturation";
ui_tooltip = "Selective Color Blacks: Saturation";
ui_category = "Selective Color: Blacks";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 876
float mid( float3 c )
{
float sum = c.x + c.y + c.z;
float mn = min( min( c.x, c.y ), c.z );
float mx = max( max( c.x, c.y ), c.z );
return sum - mn - mx;
}
#line 886
float brightness_curve( float x, float k )
{
float s = sign( x - 0.5f );
float o = ( 1.0f + s ) / 2.0f;
return o - 0.5f * s * pow( max( 2.0f * ( o - s * x ), 0.0f ), k );
}
#line 893
float curve( float x )
{
return x * x * ( 3.0 - 2.0 * x );
}
#line 898
float smooth( float x )
{
return x * x * x * ( x * ( x * 6.0f - 15.0f ) + 10.0f );
}
#line 903
float adjustcolor( float scale, float colorvalue, float adjust, float bk, int method )
{
#line 910
return clamp((( -1.0f - adjust ) * bk - adjust ) * ( 1.0f - colorvalue * method ), -colorvalue, 1.0f - colorvalue) * scale;
}
#line 914
float4 PS_SelectiveColor(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color      = tex2D( ReShade::BackBuffer, texcoord );
#line 919
color.xyz         = saturate( color.xyz );
#line 922
float min_value   = min( min( color.x, color.y ), color.z );
float max_value   = max( max( color.x, color.y ), color.z );
float mid_value   = mid( color.xyz );
float scalar      = max_value - min_value;
float alt_scalar  = ( mid_value - min_value ) / 2.0f;
float cmy_scalar  = scalar / 2.0f;
#line 930
float3 hsl        = RGBToHSL( color.xyz ).x;
#line 933
float sWhites     = smooth( min_value );
float sBlacks     = 1.0f - smooth( max_value );
float sNeutrals   = 1.0f - smooth( max_value - min_value );
#line 938
float sw_r        = curve( max( 1.0f - abs(  hsl.x                   * 6.0f ), 0.0f )) +
curve( max( 1.0f - abs(( hsl.x - 1.0f          ) * 6.0f ), 0.0f ));
float sw_o        = curve( max( 1.0f - abs(( hsl.x - 1.0f  / 12.0f ) * 6.0f ), 0.0f )) +
curve( max( 1.0f - abs(( hsl.x - 13.0f / 12.0f ) * 6.0f ), 0.0f ));
float sw_y        = curve( max( 1.0f - abs(( hsl.x - 2.0f  / 12.0f ) * 6.0f ), 0.0f ));
float sw_yg       = curve( max( 1.0f - abs(( hsl.x - 3.0f  / 12.0f ) * 6.0f ), 0.0f ));
float sw_g        = curve( max( 1.0f - abs(( hsl.x - 4.0f  / 12.0f ) * 6.0f ), 0.0f ));
float sw_gc       = curve( max( 1.0f - abs(( hsl.x - 5.0f  / 12.0f ) * 6.0f ), 0.0f ));
float sw_c        = curve( max( 1.0f - abs(( hsl.x - 6.0f  / 12.0f ) * 6.0f ), 0.0f ));
float sw_cb       = curve( max( 1.0f - abs(( hsl.x - 7.0f  / 12.0f ) * 6.0f ), 0.0f ));
float sw_b        = curve( max( 1.0f - abs(( hsl.x - 8.0f  / 12.0f ) * 6.0f ), 0.0f ));
float sw_bm       = curve( max( 1.0f - abs(( hsl.x - 9.0f  / 12.0f ) * 6.0f ), 0.0f ));
float sw_m        = curve( max( 1.0f - abs(( hsl.x - 10.0f / 12.0f ) * 6.0f ), 0.0f ));
float sw_mr       = curve( max( 1.0f - abs(( hsl.x - 11.0f / 12.0f ) * 6.0f ), 0.0f )) +
curve( max( 1.0f - abs(( hsl.x + 1.0f  / 12.0f ) * 6.0f ), 0.0f ));
#line 954
float w_r         = sw_r  * scalar;
float w_o         = sw_o  * alt_scalar;
float w_y         = sw_y  * cmy_scalar;
float w_yg        = sw_yg * alt_scalar;
float w_g         = sw_g  * scalar;
float w_gc        = sw_gc * alt_scalar;
float w_c         = sw_c  * cmy_scalar;
float w_cb        = sw_cb * alt_scalar;
float w_b         = sw_b  * scalar;
float w_bm        = sw_bm * alt_scalar;
float w_m         = sw_m  * cmy_scalar;
float w_mr        = sw_mr * alt_scalar;
#line 969
color.x           = color.x + adjustcolor( w_r, color.x, r_adj_cya, r_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_r, color.y, r_adj_mag, r_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_r, color.z, r_adj_yel, r_adj_bla, corr_method );
#line 973
color.x           = color.x + adjustcolor( w_o, color.x, o_adj_cya, o_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_o, color.y, o_adj_mag, o_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_o, color.z, o_adj_yel, o_adj_bla, corr_method );
#line 977
color.x           = color.x + adjustcolor( w_y, color.x, y_adj_cya, y_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_y, color.y, y_adj_mag, y_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_y, color.z, y_adj_yel, y_adj_bla, corr_method );
#line 981
color.x           = color.x + adjustcolor( w_yg, color.x, yg_adj_cya, yg_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_yg, color.y, yg_adj_mag, yg_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_yg, color.z, yg_adj_yel, yg_adj_bla, corr_method );
#line 985
color.x           = color.x + adjustcolor( w_g, color.x, g_adj_cya, g_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_g, color.y, g_adj_mag, g_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_g, color.z, g_adj_yel, g_adj_bla, corr_method );
#line 989
color.x           = color.x + adjustcolor( w_gc, color.x, gc_adj_cya, gc_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_gc, color.y, gc_adj_mag, gc_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_gc, color.z, gc_adj_yel, gc_adj_bla, corr_method );
#line 993
color.x           = color.x + adjustcolor( w_c, color.x, c_adj_cya, c_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_c, color.y, c_adj_mag, c_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_c, color.z, c_adj_yel, c_adj_bla, corr_method );
#line 997
color.x           = color.x + adjustcolor( w_cb, color.x, cb_adj_cya, cb_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_cb, color.y, cb_adj_mag, cb_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_cb, color.z, cb_adj_yel, cb_adj_bla, corr_method );
#line 1001
color.x           = color.x + adjustcolor( w_b, color.x, b_adj_cya, b_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_b, color.y, b_adj_mag, b_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_b, color.z, b_adj_yel, b_adj_bla, corr_method );
#line 1005
color.x           = color.x + adjustcolor( w_bm, color.x, bm_adj_cya, bm_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_bm, color.y, bm_adj_mag, bm_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_bm, color.z, bm_adj_yel, bm_adj_bla, corr_method );
#line 1009
color.x           = color.x + adjustcolor( w_m, color.x, m_adj_cya, m_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_m, color.y, m_adj_mag, m_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_m, color.z, m_adj_yel, m_adj_bla, corr_method );
#line 1013
color.x           = color.x + adjustcolor( w_mr, color.x, mr_adj_cya, mr_adj_bla, corr_method );
color.y           = color.y + adjustcolor( w_mr, color.y, mr_adj_mag, mr_adj_bla, corr_method );
color.z           = color.z + adjustcolor( w_mr, color.z, mr_adj_yel, mr_adj_bla, corr_method );
#line 1017
color.x           = color.x + adjustcolor( sWhites, color.x, w_adj_cya, w_adj_bla, corr_method );
color.y           = color.y + adjustcolor( sWhites, color.y, w_adj_mag, w_adj_bla, corr_method );
color.z           = color.z + adjustcolor( sWhites, color.z, w_adj_yel, w_adj_bla, corr_method );
#line 1021
color.x           = color.x + adjustcolor( sBlacks, color.x, bk_adj_cya, bk_adj_bla, corr_method );
color.y           = color.y + adjustcolor( sBlacks, color.y, bk_adj_mag, bk_adj_bla, corr_method );
color.z           = color.z + adjustcolor( sBlacks, color.z, bk_adj_yel, bk_adj_bla, corr_method );
#line 1025
color.x           = color.x + adjustcolor( sNeutrals, color.x, n_adj_cya, n_adj_bla, corr_method );
color.y           = color.y + adjustcolor( sNeutrals, color.y, n_adj_mag, n_adj_bla, corr_method );
color.z           = color.z + adjustcolor( sNeutrals, color.z, n_adj_yel, n_adj_bla, corr_method );
#line 1031
float curr_sat    = 0.0f;
#line 1034
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( r_adj_sat > 0.0f ) ?  saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_r * r_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_r * r_adj_sat ));
#line 1038
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( o_adj_sat > 0.0f ) ?  saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_o * o_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_o * o_adj_sat ));
#line 1042
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( y_adj_sat > 0.0f ) ?  saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_y * y_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_y * y_adj_sat ));
#line 1046
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( yg_adj_sat > 0.0f ) ? saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_yg * yg_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_yg * yg_adj_sat ));
#line 1050
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( g_adj_sat > 0.0f ) ?  saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_g * g_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_g * g_adj_sat ));
#line 1054
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( gc_adj_sat > 0.0f ) ? saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_gc * gc_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_gc * gc_adj_sat ));
#line 1058
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( c_adj_sat > 0.0f ) ?  saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_c * c_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_c * c_adj_sat ));
#line 1062
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( cb_adj_sat > 0.0f ) ? saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_cb * cb_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_cb * cb_adj_sat ));
#line 1066
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( b_adj_sat > 0.0f ) ?  saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_b * b_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_b * b_adj_sat ));
#line 1070
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( bm_adj_sat > 0.0f ) ? saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_bm * bm_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_bm * bm_adj_sat ));
#line 1074
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( m_adj_sat > 0.0f ) ?  saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_m * m_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_m * m_adj_sat ));
#line 1078
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( mr_adj_sat > 0.0f ) ? saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_mr * mr_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sw_mr * mr_adj_sat ));
#line 1082
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( w_adj_sat > 0.0f ) ?  saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sWhites * w_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sWhites * w_adj_sat ));
#line 1086
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( bk_adj_sat > 0.0f ) ? saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sBlacks * bk_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sBlacks * bk_adj_sat ));
#line 1090
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
color.xyz         = ( n_adj_sat > 0.0f ) ?  saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sNeutrals * n_adj_sat * ( 1.0f - curr_sat ))) :
saturate( lerp( dot( color.xyz, 0.333333f ), color.xyz, 1.0f + sNeutrals * n_adj_sat ));
#line 1095
float3 temp       = 0.0f;
#line 1098
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + r_adj_lig ));
temp.z            = brightness_curve( temp.z, max( r_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_r * smooth( curr_sat ));
#line 1104
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + o_adj_lig ));
temp.z            = brightness_curve( temp.z, max( o_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_o * smooth( curr_sat ));
#line 1110
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + y_adj_lig ));
temp.z            = brightness_curve( temp.z, max( y_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_y * smooth( curr_sat ));
#line 1116
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + yg_adj_lig ));
temp.z            = brightness_curve( temp.z, max( yg_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_yg * smooth( curr_sat ));
#line 1122
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + g_adj_lig ));
temp.z            = brightness_curve( temp.z, max( g_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_g * smooth( curr_sat ));
#line 1128
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + gc_adj_lig ));
temp.z            = brightness_curve( temp.z, max( gc_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_gc * smooth( curr_sat ));
#line 1134
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + c_adj_lig ));
temp.z            = brightness_curve( temp.z, max( c_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_c * smooth( curr_sat ));
#line 1140
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + cb_adj_lig ));
temp.z            = brightness_curve( temp.z, max( cb_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_cb * smooth( curr_sat ));
#line 1146
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + b_adj_lig ));
temp.z            = brightness_curve( temp.z, max( b_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_b * smooth( curr_sat ));
#line 1152
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + bm_adj_lig ));
temp.z            = brightness_curve( temp.z, max( bm_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_bm * smooth( curr_sat ));
#line 1158
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + m_adj_lig ));
temp.z            = brightness_curve( temp.z, max( m_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_m * smooth( curr_sat ));
#line 1164
curr_sat          = max( max( color.x, color.y ), color.z ) - min( min( color.x, color.y ), color.z );
temp.xyz          = RGBToHSL( color.xyz );
temp.z            = saturate( temp.z * ( 1.0f + mr_adj_lig ));
temp.z            = brightness_curve( temp.z, max( mr_adj_lig_curve, 0.001f ) + 1.0f );
color.xyz         = lerp( color.xyz, HSLToRGB( temp.xyz ), sw_mr * smooth( curr_sat ));
#line 1170
return float4( color.xyz, 1.0f );
}
#line 1174
technique prod80_04_SelectiveColor_v2
{
pass prod80_sc
{
VertexShader   = PostProcessVS;
PixelShader    = PS_SelectiveColor;
}
}
}

