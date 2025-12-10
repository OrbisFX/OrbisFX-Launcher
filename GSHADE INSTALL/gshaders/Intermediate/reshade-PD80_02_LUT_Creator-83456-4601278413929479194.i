// PD80_LC_TEXTURE_HEIGHT=512.0
// PD80_LC_TEXTURE_WIDTH=512.0
// PD80_LC_TEXTURE_NAME="pd80_neutral-lut.png"
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_02_LUT_Creator.fx"
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
#line 54 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_02_LUT_Creator.fx"
#line 67
namespace pd80_lutoverlay
{
#line 74
texture texPicture < source = "pd80_neutral-lut.png"; > { Width = 512.0; Height = 512.0; Format = RGBA8; };
#line 77
sampler samplerPicture {
Texture = texPicture;
AddressU = CLAMP;
AddressV = CLAMP;
AddressW = CLAMP;
};
#line 89
float4 PS_OverlayLUT(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float2 coords   = float2( 1920, 1018 ) / float2( 512.0, 512.0 );
coords.xy      *= texcoord.xy;
float3 lut      = tex2D( samplerPicture, coords ).xyz;
float3 color    = tex2D( ReShade::BackBuffer, texcoord ).xyz;
float2 cutoff   = float2( (1.0 / 1920), (1.0 / 1018) ) * float2( 512.0, 512.0 );
color           = ( texcoord.y > cutoff.y || texcoord.x > cutoff.x ) ? color : lut;
#line 98
return float4( color.xyz, 1.0f );
}
#line 102
technique prod80_02_LUT_Creator
< ui_tooltip =  "This shader overlays the screen with a 512x512 high quality LUT.\n"
"One can run effects on this LUT using Reshade and export the results in a PNG\n"
"screenshot. You can take this screenshot into your favorite image editor and\n"
"make it into a 4096x64 LUT texture that can be read by Reshade's LUT shaders.\n"
"This way you can safe performance by using a texture to apply your favorite\n"
"effects instead of Reshade's color manipulation shaders.";>
{
pass prod80_pass0
{
VertexShader   = PostProcessVS;
PixelShader    = PS_OverlayLUT;
}
}
}

