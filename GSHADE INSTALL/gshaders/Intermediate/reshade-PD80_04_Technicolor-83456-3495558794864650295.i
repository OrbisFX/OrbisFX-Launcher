#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Technicolor.fx"
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
#line 32 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_04_Technicolor.fx"
#line 33
namespace pd80_technicolor
{
#line 37
uniform float3 Red2strip <
ui_type = "color";
ui_label = "Red Dye Color";
ui_tooltip = "Red Color used to create Cyan (contemporary)";
ui_category = "Technicolor 2 strip";
> = float3(1.0, 0.098, 0.0);
uniform float3 Cyan2strip <
ui_type = "color";
ui_label = "Cyan Dye Color";
ui_tooltip = "Cyan Color used to create Red (contemporary)";
ui_category = "Technicolor 2 strip";
> = float3(0.0, 0.988, 1.0);
uniform float3 colorKey <
ui_type = "color";
ui_label = "Funky Color Adjustment";
ui_tooltip = "3rd Layer for Fun, lower values increase contrast";
ui_category = "Technicolor 2 strip";
> = float3(1.0, 1.0, 1.0);
uniform float Saturation2 <
ui_min = 1.0;
ui_max = 2.0;
ui_type = "slider";
ui_label = "Saturation Adjustment";
ui_tooltip = "Additional saturation control as 2 Strip Process is not very saturated by itself";
ui_category = "Technicolor 2 strip";
> = 1.5;
uniform bool enable3strip <
ui_label = "Enable Technicolor 3 strip";
ui_tooltip = "Enable Technicolor 3 strip";
ui_category = "Technicolor 3 strip";
> = false;
uniform float3 ColorStrength <
ui_type = "color";
ui_tooltip = "Higher means darker and more intense colors.";
ui_category = "Technicolor 3 strip";
> = float3(0.2, 0.2, 0.2);
uniform float Brightness <
ui_type = "slider";
ui_label = "Brightness Adjustment";
ui_min = 0.5;
ui_max = 1.5;
ui_tooltip = "Higher means brighter image.";
ui_category = "Technicolor 3 strip";
> = 1.0;
uniform float Saturation <
ui_type = "slider";
ui_label = "Saturation Adjustment";
ui_min = 0.0;
ui_max = 1.5;
ui_tooltip = "Additional saturation control since this effect tends to oversaturate the image.";
ui_category = "Technicolor 3 strip";
> = 1.0;
uniform float Strength <
ui_type = "slider";
ui_label = "Effect Strength";
ui_min = 0.0;
ui_max = 1.0;
ui_tooltip = "Adjust the strength of the effect.";
ui_category = "Technicolor 3 strip";
> = 1.0;
#line 105
float getLuminance( in float3 x )
{
return dot( x, float3( 0.212656f, 0.715158f, 0.072186f ));
}
#line 111
float3x3 QuaternionToMatrix( float4 quat )
{
float3 cross = quat.yzx * quat.zxy;
float3 square= quat.xyz * quat.xyz;
float3 wimag = quat.w * quat.xyz;
#line 117
square = square.xyz + square.yzx;
#line 119
float3 diag = 0.5f - square;
float3 a = (cross + wimag);
float3 b = (cross - wimag);
#line 123
return float3x3(
2.0f * float3(diag.x, b.z, a.y),
2.0f * float3(a.z, diag.y, b.x),
2.0f * float3(b.y, a.x, diag.z));
}
#line 130
float4 PS_Technicolor(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color      = tex2D( ReShade::BackBuffer, texcoord );
color.xyz         = saturate( color.xyz );
float3 root3      = 0.57735f;
float3 keyC       = 0.0f;
float half_angle  = 0.0f;
float4 rot_quat   = 0.0f;
float3x3 rot_Mat;
float HueAdj      = 0.52f; 
float3 orig       = color.xyz;
float negR        = 1.0f - color.x;
float negG        = 1.0f - color.y;
float3 newR       = 1.0f - negR * Cyan2strip;
float3 newC       = 1.0f - negG * Red2strip;
half_angle        = 0.5f * radians( 180.0f ); 
rot_quat          = float4(( root3 * sin( half_angle )), cos( half_angle ));
rot_Mat           = QuaternionToMatrix( rot_quat );
float3 key        = colorKey.xyz;
key.xyz           = mul( rot_Mat, key.xyz );
key.xyz           = max( color.yyy, key.xyz );
color.xyz         = newR.xyz * newC.xyz * key.xyz; 
#line 153
half_angle        = 0.5f * radians( HueAdj * 360.0f ); 
rot_quat          = float4(( root3 * sin( half_angle )), cos( half_angle ));
rot_Mat           = QuaternionToMatrix( rot_quat );
color.xyz         = mul( rot_Mat, color.xyz );
#line 158
color.xyz         = lerp( getLuminance( color.xyz ), color.xyz, Saturation2 );
#line 160
if( enable3strip ) {
float3 temp    = 1.0 - orig.xyz;
float3 target  = temp.grg;
float3 target2 = temp.bbr;
float3 temp2   = orig.xyz * target.xyz;
temp2.xyz      *= target2.xyz;
temp.xyz       = temp2.xyz * ColorStrength;
temp2.xyz      *= Brightness;
target.xyz     = temp.yxy;
target2.xyz    = temp.zzx;
temp.xyz       = orig.xyz - target.xyz;
temp.xyz       += temp2.xyz;
temp2.xyz      = temp.xyz - target2.xyz;
color.xyz      = lerp( orig.xyz, temp2.xyz, Strength );
color.xyz      = lerp( getLuminance( color.xyz ), color.xyz, Saturation);
}
#line 177
return float4( color.xyz, 1.0f );
}
#line 181
technique prod80_04_Technicolor
{
pass prod80_TC
{
VertexShader   = PostProcessVS;
PixelShader    = PS_Technicolor;
}
}
}

