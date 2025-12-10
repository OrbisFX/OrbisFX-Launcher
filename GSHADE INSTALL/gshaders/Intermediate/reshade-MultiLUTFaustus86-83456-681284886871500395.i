// faLUT_LutAmount=82
// faLUT_TileAmount=32
// faLUT_TileSizeXY=32
// faLUT_TextureName="Faustus86_MultiLUT.png"
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MultiLUTFaustus86.fx"
#line 27
uniform int faLUT_LutSelector <
ui_type = "combo";
ui_items="Neutral\0Color1\0Color2\0Color3 (Blue oriented)\0Color4 (Hollywood)\0Color5\0Color6\0Color7\0Color8\0Cool light\0Flat & green\0Red lift matte\0Cross process\0Azure Red Dual Tone\0Sepia\0B&W mid constrast\0B&W high contrast\0Bleak Tension\0Bleak Bright\0Boba\0Bobs Fallout\0Bobs Bright\0Arabica\0Ava\0Azrael\0test\0Bleach Bypass\0Bourbon\0Byers\0Candelight\0Chemical\0Clayton\0Clouseu\0Cobi\0Contrail\0Crisb Warm\0Crisb Winter\0Cubicle\0Django\0Domingo\0Drop Blues\0Egypt Ember\0Faded\0Fall Colors\0FGCine Basic\0FGCine Bright\0FGCine Cold\0FGCine Drama\0FGCine TealOrange\0FGCine TealOrange2\0FGCine Vibrant\0FGCine Warm\0Filmstock\0Foggy Night\0Folger\0Fusion\0Futuristic Bleak\0Horror Blue\0Hyla\0Korben\0Late Sunset\0Lenox\0Lucky\0MCKinnon\0Milo\0Moonlight\0Neon\0Night from Day\0Paladin\0Pasadena\0Pitaja\0Reeve\0Remy\0Soft Warming\0Sprocket\0Teal Orange Contrast\0Teigen\0Tension Green\0Trent\0Tweet\0Vireo\0Zed\0Zeke\0";
ui_label = "The LUT to use";
ui_tooltip = "The LUT to use for color transformation. 'Neutral' doesn't do any color transformation.";
> = 0;
#line 34
uniform float faLUT_AmountChroma <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT chroma amount";
ui_tooltip = "Intensity of color/chroma change of the LUT.";
> = 1.00;
#line 41
uniform float faLUT_AmountLuma <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT luma amount";
ui_tooltip = "Intensity of luma change of the LUT.";
> = 1.00;
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
#line 53 "C:\Program Files\GShade\gshade-shaders\Shaders\MultiLUTFaustus86.fx"
#line 58
texture texFaMultiLUT < source = "Faustus86_MultiLUT.png"; > { Width = 32*32; Height = 32 * 82; Format = RGBA8; };
sampler	SamplerFaMultiLUT { Texture = texFaMultiLUT; };
#line 65
void PS_MultiLUT_Apply(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float3 res : SV_Target0)
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord.xy).xyz;
float2 texelsize = 1.0 / 32;
texelsize.x /= 32;
#line 71
float3 lutcoord = float3((color.xy*32-color.xy+0.5)*texelsize.xy,color.z*32-color.z);
lutcoord.y /= 82;
lutcoord.y += (float(faLUT_LutSelector)/ 82);
const float lerpfact = frac(lutcoord.z);
lutcoord.x += (lutcoord.z-lerpfact)*texelsize.y;
#line 77
const float3 lutcolor = lerp(tex2D(SamplerFaMultiLUT, lutcoord.xy).xyz, tex2D(SamplerFaMultiLUT, float2(lutcoord.x+texelsize.y,lutcoord.y)).xyz, lerpfact);
#line 79
res.xyz = lerp(normalize(color.xyz), normalize(lutcolor.xyz), faLUT_AmountChroma) *
lerp(length(color.xyz),    length(lutcolor.xyz),    faLUT_AmountLuma);
#line 85
}
#line 92
technique MultiLUTFaustus < ui_label = "Faustus86 MultiLUT"; >
{
pass MultiLUT_Apply
{
VertexShader = PostProcessVS;
PixelShader = PS_MultiLUT_Apply;
}
}

