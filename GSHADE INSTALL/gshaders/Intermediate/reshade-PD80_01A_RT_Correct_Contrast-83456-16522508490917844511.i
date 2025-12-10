#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_01A_RT_Correct_Contrast.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 57
namespace ReShade
{
float GetAspectRatio() { return 1280 * (1.0 / 720); }
float2 GetPixelSize() { return float2((1.0 / 1280), (1.0 / 720)); }
float2 GetScreenSize() { return float2(1280, 720); }
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_01A_RT_Correct_Contrast.fx"
#line 31
namespace pd80_correctcontrast
{
#line 36
uniform bool enable_fade <
ui_text = "----------------------------------------------";
ui_label = "Enable Time Based Fade";
ui_tooltip = "Enable Time Based Fade";
ui_category = "Global: Correct Contrasts";
> = true;
uniform bool freeze <
ui_label = "Freeze Correction";
ui_tooltip = "Freeze Correction";
ui_category = "Global: Correct Contrasts";
> = false;
uniform float transition_speed <
ui_type = "slider";
ui_label = "Time Based Fade Speed";
ui_tooltip = "Time Based Fade Speed";
ui_category = "Global: Correct Contrasts";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.5;
uniform bool rt_enable_whitepoint_correction <
ui_text = "----------------------------------------------";
ui_label = "Enable Whitepoint Correction";
ui_tooltip = "Enable Whitepoint Correction";
ui_category = "Whitepoint Correction";
> = false;
uniform float rt_wp_str <
ui_type = "slider";
ui_label = "White Point Correction Strength";
ui_tooltip = "White Point Correction Strength";
ui_category = "Whitepoint Correction";
ui_min = 0.0f;
ui_max = 1.0f;
> = 1.0;
uniform bool rt_enable_blackpoint_correction <
ui_text = "----------------------------------------------";
ui_label = "Enable Blackpoint Correction";
ui_tooltip = "Enable Blackpoint Correction";
ui_category = "Blackpoint Correction";
> = true;
uniform float rt_bp_str <
ui_type = "slider";
ui_label = "Black Point Correction Strength";
ui_tooltip = "Black Point Correction Strength";
ui_category = "Blackpoint Correction";
ui_min = 0.0f;
ui_max = 1.0f;
> = 1.0;
#line 85
texture texDS_1_Max { Width = 32; Height = 32; Format = RGBA16F; };
texture texDS_1_Min { Width = 32; Height = 32; Format = RGBA16F; };
texture texPrevious { Width = 4; Height = 2; Format = RGBA16F; };
texture texDS_1x1 { Width = 4; Height = 2; Format = RGBA16F; };
#line 91
sampler samplerDS_1_Max
{
Texture = texDS_1_Max;
MipFilter = POINT;
MinFilter = POINT;
MagFilter = POINT;
};
sampler samplerDS_1_Min
{
Texture = texDS_1_Min;
MipFilter = POINT;
MinFilter = POINT;
MagFilter = POINT;
};
sampler samplerPrevious
{
Texture   = texPrevious;
MipFilter = POINT;
MinFilter = POINT;
MagFilter = POINT;
};
sampler samplerDS_1x1
{
Texture   = texDS_1x1;
MipFilter = POINT;
MinFilter = POINT;
MagFilter = POINT;
};
#line 121
uniform float frametime < source = "frametime"; >;
#line 123
float3 interpolate( float3 o, float3 n, float factor, float ft )
{
return lerp( o.xyz, n.xyz, 1.0f - exp( -factor * ft ));
}
#line 131
void PS_MinMax_1( float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 minValue : SV_Target0, out float4 maxValue : SV_Target1 )
{
float3 currColor;
minValue.xyz       = 1.0f;
maxValue.xyz       = 0.0f;
#line 138
float pst          = 0.03125f;    
float hst          = 0.5f * pst;  
#line 142
float2 stexSize    = float2( 1280, 720 );
float2 start       = floor(( texcoord.xy - hst ) * stexSize.xy );    
float2 stop        = floor(( texcoord.xy + hst ) * stexSize.xy );    
#line 146
for( int y = start.y; y < stop.y; ++y )
{
for( int x = start.x; x < stop.x; ++x )
{
currColor    = tex2Dfetch( ReShade::BackBuffer, int2( x, y ), 0 ).xyz;
#line 152
minValue.xyz = min( minValue.xyz, currColor.xyz );
#line 154
maxValue.xyz = max( currColor.xyz, maxValue.xyz );
}
}
#line 158
minValue           = float4( minValue.xyz, 1.0f );
maxValue           = float4( maxValue.xyz, 1.0f );
}
#line 163
float4 PS_MinMax_1x1( float4 pos : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{
float3 minColor; float3 maxColor;
float3 minValue    = 1.0f;
float3 maxValue    = 0.0f;
#line 169
uint SampleRes     = 32;
float Sigma        = 0.0f;
#line 172
for( int y = 0; y < SampleRes; ++y )
{
for( int x = 0; x < SampleRes; ++x )
{
#line 177
minColor     = tex2Dfetch( samplerDS_1_Min, int2( x, y), 0 ).xyz;
minValue.xyz = min( minValue.xyz, minColor.xyz );
#line 180
maxColor     = tex2Dfetch( samplerDS_1_Max, int2( x, y ), 0 ).xyz;
maxValue.xyz = max( maxColor.xyz, maxValue.xyz );
}
}
#line 187
float3 prevMin     = tex2D( samplerPrevious, float2( texcoord.x / 4.0f, texcoord.y )).xyz;
float3 prevMax     = tex2D( samplerPrevious, float2(( texcoord.x + 2.0f ) / 4.0, texcoord.y )).xyz;
float smoothf      = transition_speed * 4.0f + 0.5f;
float time         = frametime * 0.001f;
maxValue.xyz       = enable_fade ? interpolate( prevMax.xyz, maxValue.xyz, smoothf, time ) : maxValue.xyz;
minValue.xyz       = enable_fade ? interpolate( prevMin.xyz, minValue.xyz, smoothf, time ) : minValue.xyz;
#line 194
maxValue.xyz       = freeze ? prevMax.xyz : maxValue.xyz;
minValue.xyz       = freeze ? prevMin.xyz : minValue.xyz;
#line 197
if( pos.x < 2 )
return float4( minValue.xyz, 1.0f );
else
return float4( maxValue.xyz, 1.0f );
}
#line 203
float4 PS_CorrectContrast(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color       = tex2D( ReShade::BackBuffer, texcoord );
float3 minValue    = tex2D( samplerDS_1x1, float2( texcoord.x / 4.0f, texcoord.y )).xyz;
float3 maxValue    = tex2D( samplerDS_1x1, float2(( texcoord.x + 2.0f ) / 4.0f, texcoord.y )).xyz;
#line 209
float adjBlack     = min( min( minValue.x, minValue.y ), minValue.z );
float adjWhite     = max( max( maxValue.x, maxValue.y ), maxValue.z );
#line 212
adjBlack           = lerp( 0.0f, adjBlack, rt_bp_str );
adjBlack           = rt_enable_blackpoint_correction ? adjBlack : 0.0f;
#line 215
adjWhite           = lerp( 1.0f, adjWhite, rt_wp_str );
adjWhite           = rt_enable_whitepoint_correction ? adjWhite : 1.0f;
#line 218
color.xyz          = saturate( color.xyz - adjBlack ) / saturate( adjWhite - adjBlack );
#line 221
return float4( color.xyz, 1.0f );
}
#line 224
float4 PS_StorePrev( float4 pos : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{
float3 minValue    = tex2D( samplerDS_1x1, float2( texcoord.x / 4.0f, texcoord.y )).xyz;
float3 maxValue    = tex2D( samplerDS_1x1, float2(( texcoord.x + 2.0f ) / 4.0f, texcoord.y )).xyz;
if( pos.x < 2 )
return float4( minValue.xyz, 1.0f );
else
return float4( maxValue.xyz, 1.0f );
}
#line 235
technique prod80_01A_RT_Correct_Contrast
{
pass prod80_pass1
{
VertexShader       = PostProcessVS;
PixelShader        = PS_MinMax_1;
RenderTarget0      = texDS_1_Min;
RenderTarget1      = texDS_1_Max;
}
pass prod80_pass2
{
VertexShader       = PostProcessVS;
PixelShader        = PS_MinMax_1x1;
RenderTarget       = texDS_1x1;
}
pass prod80_pass3
{
VertexShader       = PostProcessVS;
PixelShader        = PS_CorrectContrast;
}
pass prod80_pass4
{
VertexShader       = PostProcessVS;
PixelShader        = PS_StorePrev;
RenderTarget       = texPrevious;
}
}
}

