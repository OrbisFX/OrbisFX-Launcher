// CURVEDCONTRASTS_VISUALIZE=0
// CURVEDCONTRASTS_ENABLE_RGB=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Curved_Levels.fx"
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
#line 37 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Curved_Levels.fx"
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
#line 38 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Curved_Levels.fx"
#line 39
namespace pd80_curvedlevels
{
#line 50
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
#line 64
uniform float black_in_grey <
ui_type = "slider";
ui_label = "Grey: Black Point";
ui_tooltip = "Grey: Black Point";
ui_category = "Grey: Contrast Curves";
ui_min = 0;
ui_max = 255;
ui_step = 1;
> = 0.0;
uniform float white_in_grey <
ui_type = "slider";
ui_label = "Grey: White Point";
ui_tooltip = "Grey: White Point";
ui_category = "Grey: Contrast Curves";
ui_min = 0;
ui_max = 255;
ui_step = 1;
> = 255.0;
uniform float pos0_shoulder_grey <
ui_type = "slider";
ui_label = "Grey: Shoulder Position X";
ui_tooltip = "Grey: Shoulder Position X";
ui_category = "Grey: Contrast Curves";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.75;
uniform float pos1_shoulder_grey <
ui_type = "slider";
ui_label = "Grey: Shoulder Position Y";
ui_tooltip = "Grey: Shoulder Position Y";
ui_category = "Grey: Contrast Curves";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.75;
uniform float pos0_toe_grey <
ui_type = "slider";
ui_label = "Grey: Toe Position X";
ui_tooltip = "Grey: Toe Position X";
ui_category = "Grey: Contrast Curves";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.25;
uniform float pos1_toe_grey <
ui_type = "slider";
ui_label = "Grey: Toe Position Y";
ui_tooltip = "Grey: Toe Position Y";
ui_category = "Grey: Contrast Curves";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.25;
uniform float black_out_grey <
ui_type = "slider";
ui_label = "Grey: Black Point Offset";
ui_tooltip = "Grey: Black Point Offset";
ui_category = "Grey: Contrast Curves";
ui_min = 0;
ui_max = 255;
ui_step = 1;
> = 0.0;
uniform float white_out_grey <
ui_type = "slider";
ui_label = "Grey: White Point Offset";
ui_tooltip = "Grey: White Point Offset";
ui_category = "Grey: Contrast Curves";
ui_min = 0;
ui_max = 255;
ui_step = 1;
> = 255.0;
#line 348
struct TonemapParams
{
float3 mToe;
float2 mMid;
float3 mShoulder;
float2 mBx;
};
#line 357
float3 Tonemap(const TonemapParams tc, float3 x)
{
float3 toe = - tc.mToe.x / (x + tc.mToe.y) + tc.mToe.z;
float3 mid = tc.mMid.x * x + tc.mMid.y;
float3 shoulder = - tc.mShoulder.x / (x + tc.mShoulder.y) + tc.mShoulder.z;
float3 result = ( x >= tc.mBx.x ) ? mid : toe;
result = ( x >= tc.mBx.y ) ? shoulder : result;
return result;
}
#line 367
float blackwhiteIN( float c, float b, float w )
{
return saturate( c - b )/max( w - b, 0.000001f );
}
#line 372
float blackwhiteOUT( float c, float b, float w )
{
return c * saturate( w - b ) + b;
}
#line 377
float3 blackwhiteIN( float3 c, float b, float w )
{
return saturate( c.xyz - b )/max( w - b, 0.000001f );
}
#line 382
float3 blackwhiteOUT( float3 c, float b, float w )
{
return c.xyz * saturate( w - b ) + b;
}
#line 387
float4 setBoundaries( float tx, float ty, float sx, float sy )
{
if( tx > sx )
tx = sx;
if( ty > sy )
ty = sy;
return float4( tx, ty, sx, sy );
}
#line 396
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
#line 423
float4 PS_CurvedLevels(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color      = tex2D( ReShade::BackBuffer, texcoord );
float2 coords     = float2(( texcoord.x - 0.75f ) * 4.0f, ( 1.0f - texcoord.y ) * 4.0f ); 
#line 429
float4 dnoise      = dither( samplerRGBNoise, texcoord.xy, 1, enable_dither, dither_strength, 1, 0.5f );
color.xyz          = saturate( color.xyz + dnoise.yzx );
#line 444
TonemapParams tc;
#line 447
float bigr        = saturate( black_in_grey/255.0f + dnoise.w );
float wigr        = saturate( white_in_grey/255.0f + dnoise.w );
float bogr        = saturate( black_out_grey/255.0f + dnoise.w );
float wogr        = saturate( white_out_grey/255.0f + dnoise.w );
#line 452
float4 grey       = setBoundaries( pos0_toe_grey, pos1_toe_grey, pos0_shoulder_grey, pos1_shoulder_grey );
PrepareTonemapParams( grey.xy, grey.zw, float2( 1.0f, 1.0f ), tc );
color.xyz         = blackwhiteIN( color.xyz, bigr, wigr );
color.xyz         = Tonemap( tc, color.xyz );
color.xyz         = blackwhiteOUT( color.xyz, bogr, wogr );
#line 555
return float4( color.xyz, 1.0f );
}
#line 559
technique prod80_03_CurvedLevels
{
pass prod80_CCpass0
{
VertexShader   = PostProcessVS;
PixelShader    = PS_CurvedLevels;
}
}
}

