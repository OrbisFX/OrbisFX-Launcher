// MultiLUTTexture3=0
// MultiLUTTexture2=0
// MultiLUTTexture_Source=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MultiLUT.fx"
#line 162
uniform int fLUT_MultiLUTSelector <
ui_category = "Pass 1";
ui_type = "combo";
ui_items = "GShade [Angelite-Compatible]\0Custom\0ReShade\0Johto\0Espresso Glow\0Faeshade/Dark Veil/HQ Shade/MoogleShade\0ninjafada Gameplay\0seri14\0Yomi\0Neneko\0Yaes\0Ipsusu\0Nightingale\0Marot\0";
ui_label = "The MultiLUT file to use.";
ui_tooltip = "Select a MultiLUT Atlas!\n\nThese atlases each include a number of different LUT's.\n\nFor loading your own custom MultiLUT Atlas, select \"Custom\" and be sure to set the respective Preprocessor Definitions beneath these settings.";
ui_bind = "MultiLUTTexture_Source";
> = 0;
#line 171
uniform int fLUT_LutSelector <
ui_category = "Pass 1";
ui_type = "combo";
#line 175
ui_items = "Color0\0Color1\0Color2\0Color3\0Color4\0Color5\0Color6\0Color7\0Color8\0Sepia\0Color10\0Color11\0Cross process\0Azure Red Dual Tone\0Sepia\0B&W mid constrast\0B&W high contrast\0";
#line 205
ui_label = "LUT to use.";
ui_tooltip = "LUT to use for color transformation. ReShade's 'Neutral' doesn't do any color transformation.";
> = 0;
#line 209
uniform float fLUT_Intensity <
ui_category = "Pass 1";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Intensity";
ui_tooltip = "Overall intensity of the LUT effect.";
> = 1.00;
#line 217
uniform float fLUT_AmountChroma <
ui_category = "Pass 1";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Chroma Amount";
ui_tooltip = "Intensity of color/chroma change of the LUT.";
> = 1.00;
#line 225
uniform float fLUT_AmountLuma <
ui_category = "Pass 1";
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "LUT Luma Amount";
ui_tooltip = "Intensity of luma change of the LUT.";
> = 1.00;
#line 233
uniform bool fLUT_MultiLUTPass2 <
ui_category = "Pass 2";
ui_label = "Enable Pass 2";
ui_bind = "MultiLUTTexture2";
> = 0;
#line 312
uniform bool fLUT_MultiLUTPass3 <
ui_category = "Pass 3";
ui_label = "Enable Pass 3";
ui_bind = "MultiLUTTexture3";
> = 0;
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
#line 396 "C:\Program Files\GShade\gshade-shaders\Shaders\MultiLUT.fx"
#line 617
texture texMultiLUT < source = "MultiLut_GShade.png"; > { Width = 32 * 32; Height = 32 * 17; Format = RGBA8; };
sampler SamplerMultiLUT { Texture = texMultiLUT; };
#line 634
float3 apply(in const float3 color, in const int tex, in const float lut)
{
const float2 texelsize = 1.0 / float2(32 * 32, 32);
float3 lutcoord = float3((color.xy * 32 - color.xy + 0.5) * texelsize, (color.z  * 32 - color.z));
#line 639
const float lerpfact = frac(lutcoord.z);
lutcoord.x += (lutcoord.z - lerpfact) * texelsize.y;
lutcoord.y = lut / 17 + lutcoord.y / 17;
#line 643
return lerp(tex2D(SamplerMultiLUT, lutcoord.xy).xyz, tex2D(SamplerMultiLUT, float2(lutcoord.x + texelsize.y, lutcoord.y)).xyz, lerpfact);
}
#line 674
void PS_MultiLUT_Apply(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float3 res : SV_Target)
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord).xyz;
#line 683
const float3 lutcolor = lerp(color, apply(color, fLUT_MultiLUTSelector, fLUT_LutSelector), fLUT_Intensity);
#line 688
res = lerp(normalize(color), normalize(lutcolor), fLUT_AmountChroma)
* lerp(   length(color),    length(lutcolor),   fLUT_AmountLuma);
#line 718
}
#line 724
technique MultiLUT
{
pass MultiLUT_Apply
{
VertexShader = PostProcessVS;
PixelShader = PS_MultiLUT_Apply;
}
}

