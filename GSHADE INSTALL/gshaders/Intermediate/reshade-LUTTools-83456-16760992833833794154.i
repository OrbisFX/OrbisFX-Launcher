// LUT_VERTICAL=0
// LUT_FILE_NAME="lut_ReShade.png"
// LUT_BLOCK_SIZE=32
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\LUTTools.fx"
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
#line 26 "C:\Program Files\GShade\gshade-shaders\Shaders\LUTTools.fx"
#line 56
uniform int LutRes
<
ui_label = "LUT box resolution";
ui_tooltip =
"Horizontal resolution equals value squared.\n"
"Default 32 is 1024.\n"
"To set texture size and name for ApplyLUT, define\n"
" LUT_BLOCK_SIZE [number]\n"
"and \n"
" LUT_FILE_NAME [name]";
ui_type = "drag";
ui_category = "Display LUT settings";
ui_min = 8; ui_max = 128; ui_step = 1;
> = 32;
#line 71
uniform bool VerticalOrietation
<
ui_label = "Vertical LUT";
ui_tooltip =
"Select LUT texture orientation, default is horizontal.\n"
"To change orientation for input LUT, add PreProcessor definition 'LUT_VERTICAL true'.";
ui_type = "input";
ui_category = "Display LUT settings";
> = false;
#line 81
uniform float2 LutChromaLuma
<
ui_label = "LUT chroma/luma blend";
ui_tooltip = "How much LUT affects chrominance/luminance";
ui_type = "slider";
ui_category = "Apply LUT settings";
ui_min = 0f; ui_max = 1f; ui_step = 0.005;
> = float2(1f, 1f);
#line 95
int2 toLut2D(int3 lut3D)
{
#line 100
return int2(lut3D.x+lut3D.z, lut3D.y);
#line 102
}
#line 109
texture LUTTex < source = "lut_ReShade.png";>
{
Width  = int2(32*32, 32).x;
Height = int2(32*32, 32).y;
Format = RGBA8;
};
sampler LUTSampler
{ Texture = LUTTex; };
#line 123
float3 DisplayLutPS(
float4 vois : SV_Position,
float2 TexCoord : TEXCOORD
) : SV_Target
{
#line 129
const float2 LutBounds = (VerticalOrietation ? float2(LutRes, LutRes*LutRes) : float2(LutRes*LutRes, LutRes)) * float2((1.0 / 1280), (1.0 / 720));
#line 131
if( any(TexCoord>=LutBounds) ) return tex2D(ReShade::BackBuffer, TexCoord).rgb;
else
{
#line 135
const float2 Gradient = TexCoord*float2(1280, 720)/LutRes;
#line 137
float3 LUT;
LUT.rg = frac(Gradient)-0.5/LutRes;
LUT.rg /= 1f-1f/LutRes;
LUT.b = floor(VerticalOrietation? Gradient.g : Gradient.r)/(LutRes-1);
#line 142
return LUT;
}
}
#line 147
void ApplyLutPS(
float4 vois : SV_Position,
float2 TexCoord : TEXCOORD,
out float3 Image : SV_Target
)
{
#line 154
Image = tex2D(ReShade::BackBuffer, TexCoord).rgb;
#line 157
const float3 lut3D = Image*(32-1);
#line 160
float2 lut2D[2];
#line 170
lut2D[0].x = floor(lut3D.z)*32+lut3D.x;
lut2D[0].y = lut3D.y;
#line 173
lut2D[1].x = ceil(lut3D.z)*32+lut3D.x;
lut2D[1].y = lut3D.y;
#line 178
lut2D[0] = (lut2D[0]+0.5)*1f/int2(32*32, 32);
lut2D[1] = (lut2D[1]+0.5)*1f/int2(32*32, 32);
#line 182
float3 LutImage = lerp(
tex2D(LUTSampler, lut2D[0]).rgb, 
tex2D(LUTSampler, lut2D[1]).rgb, 
frac(lut3D.z)
);
#line 189
if ( all(LutChromaLuma==1f) )
Image = LutImage;
else
{
Image = lerp(
normalize(Image),
normalize(LutImage),
LutChromaLuma.x
)*lerp(
length(Image),
length(LutImage),
LutChromaLuma.y
);
}
}
#line 209
technique DisplayLUT
<
ui_label = "Display LUT";
ui_tooltip =
"Display generated-neutral LUT texture in left to corner of the screen\n"
"\n"
"How to use:\n"
"* adjust lut size\n"
"* (optionally) adjust color effecs to bake shaders into LUT\n"
"* take a screenshot\n"
"* adjust and crop screenshot to texture using external image editor\n"
"* load LUT texture in 'Apply LUT .fx'"
"\n"
"This effect © 2018-2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY-SA 4.0";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = DisplayLutPS;
}
}
#line 233
technique ApplyLUT
<
ui_label = "Apply LUT";
ui_tooltip =
"Apply LUT texture color adjustment\n"
"To change texture name, add following to global preprocessor definitions:\n"
"\n"
"   LUT_FILE_NAME 'YourLUT.png'\n"
"\n"
"To change LUT texture resolution, define:\n"
"\n"
"   LUT_BLOCK_SIZE 17\n"
"\n"
"To change LUT texture orientation, define:\n"
"\n"
"   LUT_VERTICAL true\n"
"\n"
"This effect © 2018-2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY-SA 4.0";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ApplyLutPS;
}
}

