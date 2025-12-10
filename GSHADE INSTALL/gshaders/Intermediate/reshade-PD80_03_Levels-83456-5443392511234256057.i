// LEVELS_USE_DEPTH=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Levels.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Levels.fx"
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
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Levels.fx"
#line 32
namespace pd80_levels
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
uniform float3 ib <
ui_type = "color";
ui_label = "Black IN Level";
ui_tooltip = "Black IN Level";
ui_category = "Levels";
> = float3(0.0, 0.0, 0.0);
uniform float3 iw <
ui_type = "color";
ui_label = "White IN Level";
ui_tooltip = "White IN Level";
ui_category = "Levels";
> = float3(1.0, 1.0, 1.0);
uniform float3 ob <
ui_type = "color";
ui_label = "Black OUT Level";
ui_tooltip = "Black OUT Level";
ui_category = "Levels";
> = float3(0.0, 0.0, 0.0);
uniform float3 ow <
ui_type = "color";
ui_label = "White OUT Level";
ui_tooltip = "White OUT Level";
ui_category = "Levels";
> = float3(1.0, 1.0, 1.0);
uniform float ig <
ui_label = "Gamma Adjustment";
ui_tooltip = "Gamma Adjustment";
ui_category = "Levels";
ui_type = "slider";
ui_min = 0.05;
ui_max = 10.0;
> = 1.0;
#line 163
uniform float2 pingpong < source = "pingpong"; min = 0; max = 128; step = 1; >;
#line 165
float3 levels( float3 color, float3 blackin, float3 whitein, float gamma, float3 outblack, float3 outwhite )
{
float3 ret       = saturate( color.xyz - blackin.xyz ) / max( whitein.xyz - blackin.xyz, 0.000001f );
ret.xyz          = pow( ret.xyz, gamma );
ret.xyz          = ret.xyz * saturate( outwhite.xyz - outblack.xyz ) + outblack.xyz;
return ret;
}
#line 174
float4 PS_Levels(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2D( ReShade::BackBuffer, texcoord );
#line 179
float4 dnoise      = dither( samplerRGBNoise, texcoord.xy, 2, enable_dither, dither_strength, 1, 0.5f );
#line 188
color.xyz        = saturate( color.xyz + dnoise.w );
float3 dcolor    = color.xyz;
color.xyz        = levels( color.xyz,  saturate( ib.xyz + dnoise.xyz ),
saturate( iw.xyz + dnoise.yzx ),
ig,
saturate( ob.xyz + dnoise.zxy ),
saturate( ow.xyz + dnoise.wxz ));
#line 207
return float4( color.xyz, 1.0f );
}
#line 211
technique prod80_03_Levels
{
pass DoLevels
{
VertexShader   = PostProcessVS;
PixelShader    = PS_Levels;
}
}
}

