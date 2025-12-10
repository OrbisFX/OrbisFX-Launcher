#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Selective_Color.fx"
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
#line 29 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Selective_Color.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Selective_Color.fx"
#line 31
namespace pd80_selectivecolor
{
#line 35
uniform int corr_method <
ui_label = "Correction Method";
ui_tooltip = "Correction Method";
ui_category = "Selective Color";
ui_type = "combo";
ui_items = "Absolute\0Relative\0"; 
> = 1;
uniform int corr_method2 <
ui_label = "Correction Method Saturation";
ui_tooltip = "Correction Method Saturation";
ui_category = "Selective Color";
ui_type = "combo";
ui_items = "Absolute\0Relative\0"; 
> = 1;
#line 50
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
uniform float r_adj_vib <
ui_type = "slider";
ui_label = "Vibrance";
ui_tooltip = "Selective Color Reds: Vibrance";
ui_category = "Selective Color: Reds";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 100
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
uniform float y_adj_vib <
ui_type = "slider";
ui_label = "Vibrance";
ui_tooltip = "Selective Color Yellows: Vibrance";
ui_category = "Selective Color: Yellows";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 150
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
uniform float g_adj_vib <
ui_type = "slider";
ui_label = "Vibrance";
ui_tooltip = "Selective Color Greens: Vibrance";
ui_category = "Selective Color: Greens";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 200
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
uniform float c_adj_vib <
ui_type = "slider";
ui_label = "Vibrance";
ui_tooltip = "Selective Color Cyans: Vibrance";
ui_category = "Selective Color: Cyans";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 250
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
uniform float b_adj_vib <
ui_type = "slider";
ui_label = "Vibrance";
ui_tooltip = "Selective Color Blues: Vibrance";
ui_category = "Selective Color: Blues";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 300
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
uniform float m_adj_vib <
ui_type = "slider";
ui_label = "Vibrance";
ui_tooltip = "Selective Color Magentas: Vibrance";
ui_category = "Selective Color: Magentas";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 350
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
uniform float w_adj_vib <
ui_type = "slider";
ui_label = "Vibrance";
ui_tooltip = "Selective Color Whites: Vibrance";
ui_category = "Selective Color: Whites";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 400
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
uniform float n_adj_vib <
ui_type = "slider";
ui_label = "Vibrance";
ui_tooltip = "Selective Color Neutrals: Vibrance";
ui_category = "Selective Color: Neutrals";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 450
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
uniform float bk_adj_vib <
ui_type = "slider";
ui_label = "Vibrance";
ui_tooltip = "Selective Color Blacks: Vibrance";
ui_category = "Selective Color: Blacks";
ui_min = -1.0f;
ui_max = 1.0f;
> = 0.0;
#line 507
float mid( float3 c )
{
float sum = c.x + c.y + c.z;
float mn = min( min( c.x, c.y ), c.z );
float mx = max( max( c.x, c.y ), c.z );
return sum - mn - mx;
}
#line 515
float adjustcolor( float scale, float colorvalue, float adjust, float bk, int method )
{
#line 522
return clamp((( -1.0f - adjust ) * bk - adjust ) * ( 1.0f - colorvalue * method ), -colorvalue, 1.0f - colorvalue) * scale;
}
#line 526
float4 PS_SelectiveColor(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color      = tex2D( ReShade::BackBuffer, texcoord );
#line 531
color.xyz         = saturate( color.xyz );
#line 534
float min_value   = min( min( color.x, color.y ), color.z );
float max_value   = max( max( color.x, color.y ), color.z );
float mid_value   = mid( color.xyz );
#line 539
float3 orig       = color.xyz;
#line 542
float sRGB        = max_value - mid_value;
float sCMY        = mid_value - min_value;
float sNeutrals   = 1.0f - ( abs( max_value - 0.5f ) + abs( min_value - 0.5f ));
float sWhites     = ( min_value - 0.5f ) * 2.0f;
float sBlacks     = ( 0.5f - max_value ) * 2.0f;
#line 558
float r_d_m       = orig.x - orig.z;
float r_d_y       = orig.x - orig.y;
#line 561
float y_d         = mid_value - orig.z;
#line 563
float g_d_y       = orig.y - orig.x;
float g_d_c       = orig.y - orig.z;
#line 566
float c_d         = mid_value - orig.x;
#line 568
float b_d_c       = orig.z - orig.y;
float b_d_m       = orig.z - orig.x;
#line 571
float m_d         = mid_value - orig.y;
#line 573
float r_delta     = 1.0f;
float y_delta     = 1.0f;
float g_delta     = 1.0f;
float c_delta     = 1.0f;
float b_delta     = 1.0f;
float m_delta     = 1.0f;
#line 580
if( corr_method2 ) 
{
r_delta       = min( r_d_m, r_d_y );
y_delta       = y_d;
g_delta       = min( g_d_y, g_d_c );
c_delta       = c_d;
b_delta       = min( b_d_c, b_d_m );
m_delta       = m_d;
}
#line 591
if( max_value == orig.x )
{
color.x       = color.x + adjustcolor( sRGB, color.x, r_adj_cya, r_adj_bla, corr_method );
color.y       = color.y + adjustcolor( sRGB, color.y, r_adj_mag, r_adj_bla, corr_method );
color.z       = color.z + adjustcolor( sRGB, color.z, r_adj_yel, r_adj_bla, corr_method );
color.xyz     = sat( color.xyz, r_adj_sat * r_delta );
color.xyz     = vib( color.xyz, r_adj_vib * r_delta );
}
#line 600
if( min_value == orig.z )
{
color.x       = color.x + adjustcolor( sCMY, color.x, y_adj_cya, y_adj_bla, corr_method );
color.y       = color.y + adjustcolor( sCMY, color.y, y_adj_mag, y_adj_bla, corr_method );
color.z       = color.z + adjustcolor( sCMY, color.z, y_adj_yel, y_adj_bla, corr_method );
color.xyz     = sat( color.xyz, y_adj_sat * y_delta );
color.xyz     = vib( color.xyz, y_adj_vib * y_delta );
}
#line 609
if( max_value == orig.y )
{
color.x       = color.x + adjustcolor( sRGB, color.x, g_adj_cya, g_adj_bla, corr_method );
color.y       = color.y + adjustcolor( sRGB, color.y, g_adj_mag, g_adj_bla, corr_method );
color.z       = color.z + adjustcolor( sRGB, color.z, g_adj_yel, g_adj_bla, corr_method );
color.xyz     = sat( color.xyz, g_adj_sat * g_delta );
color.xyz     = vib( color.xyz, g_adj_vib * g_delta );
}
#line 618
if( min_value == orig.x )
{
color.x       = color.x + adjustcolor( sCMY, color.x, c_adj_cya, c_adj_bla, corr_method );
color.y       = color.y + adjustcolor( sCMY, color.y, c_adj_mag, c_adj_bla, corr_method );
color.z       = color.z + adjustcolor( sCMY, color.z, c_adj_yel, c_adj_bla, corr_method );
color.xyz     = sat( color.xyz, c_adj_sat * c_delta );
color.xyz     = vib( color.xyz, c_adj_vib * c_delta );
}
#line 627
if( max_value == orig.z )
{
color.x       = color.x + adjustcolor( sRGB, color.x, b_adj_cya, b_adj_bla, corr_method );
color.y       = color.y + adjustcolor( sRGB, color.y, b_adj_mag, b_adj_bla, corr_method );
color.z       = color.z + adjustcolor( sRGB, color.z, b_adj_yel, b_adj_bla, corr_method );
color.xyz     = sat( color.xyz, b_adj_sat * b_delta );
color.xyz     = vib( color.xyz, b_adj_vib * b_delta );
}
#line 636
if( min_value == orig.y )
{
color.x       = color.x + adjustcolor( sCMY, color.x, m_adj_cya, m_adj_bla, corr_method );
color.y       = color.y + adjustcolor( sCMY, color.y, m_adj_mag, m_adj_bla, corr_method );
color.z       = color.z + adjustcolor( sCMY, color.z, m_adj_yel, m_adj_bla, corr_method );
color.xyz     = sat( color.xyz, m_adj_sat * m_delta );
color.xyz     = vib( color.xyz, m_adj_vib * m_delta );
}
#line 645
if( min_value >= 0.5f )
{
color.x       = color.x + adjustcolor( sWhites, color.x, w_adj_cya, w_adj_bla, corr_method );
color.y       = color.y + adjustcolor( sWhites, color.y, w_adj_mag, w_adj_bla, corr_method );
color.z       = color.z + adjustcolor( sWhites, color.z, w_adj_yel, w_adj_bla, corr_method );
color.xyz     = sat( color.xyz, w_adj_sat * smoothstep( 0.5f, 1.0f, min_value ));
color.xyz     = vib( color.xyz, w_adj_vib * smoothstep( 0.5f, 1.0f, min_value ));
}
#line 654
if( max_value > 0.0f && min_value < 1.0f )
{
color.x       = color.x + adjustcolor( sNeutrals, color.x, n_adj_cya, n_adj_bla, corr_method );
color.y       = color.y + adjustcolor( sNeutrals, color.y, n_adj_mag, n_adj_bla, corr_method );
color.z       = color.z + adjustcolor( sNeutrals, color.z, n_adj_yel, n_adj_bla, corr_method );
color.xyz     = sat( color.xyz, n_adj_sat );
color.xyz     = vib( color.xyz, n_adj_vib );
}
#line 663
if( max_value < 0.5f )
{
color.x       = color.x + adjustcolor( sBlacks, color.x, bk_adj_cya, bk_adj_bla, corr_method );
color.y       = color.y + adjustcolor( sBlacks, color.y, bk_adj_mag, bk_adj_bla, corr_method );
color.z       = color.z + adjustcolor( sBlacks, color.z, bk_adj_yel, bk_adj_bla, corr_method );
color.xyz     = sat( color.xyz, bk_adj_sat * smoothstep( 0.5f, 0.0f, max_value ));
color.xyz     = vib( color.xyz, bk_adj_vib * smoothstep( 0.5f, 0.0f, max_value ));
}
#line 672
return float4( color.xyz, 1.0f );
}
#line 676
technique prod80_04_SelectiveColor
{
pass prod80_sc
{
VertexShader   = PostProcessVS;
PixelShader    = PS_SelectiveColor;
}
}
}

