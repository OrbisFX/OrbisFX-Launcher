#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_06_Posterize_Pixelate.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_06_Posterize_Pixelate.fx"
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
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_06_Posterize_Pixelate.fx"
#line 32
namespace pd80_posterizepixelate
{
#line 37
uniform int number_of_levels <
ui_label = "Number of Levels";
ui_tooltip = "Number of Levels";
ui_category = "Posterize";
ui_type = "slider";
ui_min = 2;
ui_max = 255;
> = 255;
uniform int pixel_size <
ui_label = "Pixel Size";
ui_tooltip = "Pixel Size";
ui_category = "Pixelate";
ui_type = "slider";
ui_min = 1;
ui_max = 9;
> = 1;
uniform float effect_strength <
ui_type = "slider";
ui_label = "Effect Strength";
ui_tooltip = "Effect Strength";
ui_category = "Posterize Pixelate";
ui_min = 0.0f;
ui_max = 1.0f;
> = 1.0;
uniform float border_str <
ui_type = "slider";
ui_label = "Border Strength";
ui_tooltip = "Border Strength";
ui_category = "Posterize Pixelate";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.0;
uniform bool enable_dither <
ui_label = "Enable Dithering";
ui_tooltip = "Enable Dithering";
ui_category = "Posterize Pixelate";
> = false;
uniform bool dither_motion <
ui_label = "Dither Motion";
ui_tooltip = "Dither Motion";
ui_category = "Posterize Pixelate";
> = true;
uniform float dither_strength <
ui_type = "slider";
ui_label = "Dither Strength";
ui_tooltip = "Dither Strength";
ui_category = "Posterize Pixelate";
ui_min = 0.0f;
ui_max = 10.0f;
> = 1.0;
#line 88
texture texMipMe { Width = 1920; Height = 1018; MipLevels = 9; };
#line 91
sampler samplerMipMe
{
Texture = texMipMe;
MipFilter = POINT;
MinFilter = POINT;
MagFilter = POINT;
};
#line 103
uniform float2 pingpong < source = "pingpong"; min = 0; max = 128; step = 1; >;
#line 106
float4 PS_MipMe(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return tex2D( ReShade::BackBuffer, texcoord );
}
#line 111
float4 PS_Posterize(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float3 color      = tex2Dlod( samplerMipMe, float4( texcoord.xy, 0.0f, pixel_size - 1 )).xyz;
float exp         = exp2( pixel_size - 1 );
float rcp_exp     = max( rcp( exp ) - 0.00001f, 0.0f ); 
float2 bwbh       = float2( floor( 1920 / exp ), floor( 1018 / exp ));
#line 118
float2 tx         = bwbh.xy / 512.0f;
tx.xy             *= texcoord.xy;
float3 dnoise     = tex2D( samplerRGBNoise, tx ).xyz;
float mot         = dither_motion ? pingpong.x + 9 : 1.0f;
dnoise.xyz        = frac( dnoise + 0.61803398875f * mot );
dnoise.xyz        = dnoise * 2.0f - 1.0f;
color.xyz         = enable_dither ? saturate( color.xyz + dnoise.xyz * ( dither_strength / number_of_levels )) : color.xyz;
#line 126
float3 orig       = color.xyz;
color.xyz         = floor( color.xyz * number_of_levels ) / ( number_of_levels - 1 );
float2 uv         = frac( texcoord.xy * bwbh.xy );
float grade       = ( uv.x <= rcp_exp ) ? 1.0 : 0.0;
grade            += ( uv.y <= rcp_exp ) ? 1.0 : 0.0;
color.xyz         = lerp( color.xyz, lerp( color.xyz, 0.0f, border_str * saturate( pixel_size - 1 )), saturate( grade ));
color.xyz         = lerp( orig.xyz, color.xyz, effect_strength );
return float4( color.xyz, 1.0f );
}
#line 137
technique prod80_06_Posterize_Pixelate
{
pass prod80_pass0
{
VertexShader   = PostProcessVS;
PixelShader    = PS_MipMe;
RenderTarget   = texMipMe;
}
pass prod80_pass1
{
VertexShader   = PostProcessVS;
PixelShader    = PS_Posterize;
}
}
}

