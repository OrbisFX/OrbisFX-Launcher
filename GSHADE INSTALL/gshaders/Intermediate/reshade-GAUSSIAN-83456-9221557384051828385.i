// gGaussQuality=0
// gUSE_VerticalGauss=1
// gUSE_HorizontalGauss=1
// gUSE_SlantGauss=1
// gUSE_BP=1
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\GAUSSIAN.fx"
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
#line 10 "C:\Program Files\GShade\gshade-shaders\Shaders\GAUSSIAN.fx"
#line 45
uniform int gGaussEffect <
ui_label = "Gauss Effect";
ui_type = "combo";
ui_items="Off\0Blur\0Unsharpmask (expensive)\0Bloom\0Sketchy\0Effects Image Only\0";
> = 1;
#line 51
uniform float gGaussStrength <
ui_label = "Gauss Strength";
ui_tooltip = "Amount of effect blended into the final image.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.3;
#line 60
uniform bool gAddBloom <
ui_label = "Add Bloom";
> = 0;
#line 68
uniform float gBloomStrength <
ui_label = "Bloom Strength";
ui_tooltip = "Amount of Bloom added to the final image.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.33;
#line 77
uniform float gBloomIntensity <
ui_label = "Bloom Intensity";
ui_tooltip = "Makes bright spots brighter. Also affects Blur and Unsharpmask.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 6.0;
ui_step = 0.001;
> = 3.0;
#line 86
uniform int gGaussBloomWarmth <
ui_label = "Bloom Warmth";
ui_tooltip = "Choose a tonemapping algorithm fitting your personal taste.";
ui_type = "combo";
ui_items="Neutral\0Warm\0Hazy/Foggy\0";
> = 0;
#line 95
uniform int gN_PASSES <
ui_label = "Number of Gaussian Passes";
ui_tooltip = "Still fine tuning this. Changing the number of passes can affect brightness.";
ui_type = "slider";
ui_min = 3;
ui_max = 5;
ui_step = 1;
> = 5;
#line 114
uniform float gBloomHW <
ui_label = "Horizontal Bloom Width";
ui_tooltip = "Higher numbers = wider bloom.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 10.0;
ui_step = 0.001;
> = 1.0;
#line 123
uniform float gBloomVW <
ui_label = "Vertical Bloom Width";
ui_tooltip = "Higher numbers = wider bloom.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 10.0;
ui_step = 0.001;
> = 1.0;
#line 132
uniform float gBloomSW <
ui_label = "Bloom Slant";
ui_tooltip = "Higher numbers = wider bloom.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 10.0;
ui_step = 0.001;
> = 2.0;
#line 148
texture origframeTex2D
{
Width = 1920;
Height = 1018;
Format = R8G8B8A8;
};
#line 155
sampler origframeSampler
{
Texture = origframeTex2D;
AddressU  = Clamp; AddressV = Clamp;
MipFilter = None; MinFilter = Linear; MagFilter = Linear;
SRGBTexture = false;
};
#line 163
float4 BrightPassFilterPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
const float4 color = tex2D(ReShade::BackBuffer, texcoord);
return float4(color.rgb * pow (abs (max (color.r, max (color.g, color.b))), 2.0), 2.0f)*gBloomIntensity;
}
#line 169
float4 HGaussianBlurPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 172
const float sampleOffsets[5] = { 0.0, 1.4347826, 3.3478260, 5.2608695, 7.1739130 };
const float sampleWeights[5] = { 0.16818994, 0.27276957, 0.11690125, 0.024067905, 0.0021112196 };
#line 179
float4 color = tex2D(ReShade::BackBuffer, texcoord) * sampleWeights[0];
for(int i = 1; i < gN_PASSES; ++i) {
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(sampleOffsets[i]*gBloomHW * float2((1.0 / 1920),(1.0 / 1018)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(sampleOffsets[i]*gBloomHW * float2((1.0 / 1920),(1.0 / 1018)).x, 0.0), 0.0, 0.0)) * sampleWeights[i];
}
return color;
}
#line 187
float4 VGaussianBlurPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 190
const float sampleOffsets[5] = { 0.0, 1.4347826, 3.3478260, 5.2608695, 7.1739130 };
const float sampleWeights[5] = { 0.16818994, 0.27276957, 0.11690125, 0.024067905, 0.0021112196 };
#line 197
float4 color = tex2D(ReShade::BackBuffer, texcoord) * sampleWeights[0];
for(int i = 1; i < gN_PASSES; ++i) {
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(0.0, sampleOffsets[i]*gBloomVW * float2((1.0 / 1920),(1.0 / 1018)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(0.0, sampleOffsets[i]*gBloomVW * float2((1.0 / 1920),(1.0 / 1018)).y), 0.0, 0.0)) * sampleWeights[i];
}
return color;
}
#line 205
float4 SGaussianBlurPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 208
const float sampleOffsets[5] = { 0.0, 1.4347826, 3.3478260, 5.2608695, 7.1739130 };
const float sampleWeights[5] = { 0.16818994, 0.27276957, 0.11690125, 0.024067905, 0.0021112196 };
#line 215
float4 color = tex2D(ReShade::BackBuffer, texcoord) * sampleWeights[0];
for(int i = 1; i < gN_PASSES; ++i) {
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(sampleOffsets[i]*gBloomSW * float2((1.0 / 1920),(1.0 / 1018)).x, sampleOffsets[i] * float2((1.0 / 1920),(1.0 / 1018)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(sampleOffsets[i]*gBloomSW * float2((1.0 / 1920),(1.0 / 1018)).x, sampleOffsets[i] * float2((1.0 / 1920),(1.0 / 1018)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(-sampleOffsets[i]*gBloomSW * float2((1.0 / 1920),(1.0 / 1018)).x, sampleOffsets[i] * float2((1.0 / 1920),(1.0 / 1018)).y), 0.0, 0.0)) * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(sampleOffsets[i]*gBloomSW * float2((1.0 / 1920),(1.0 / 1018)).x, -sampleOffsets[i] * float2((1.0 / 1920),(1.0 / 1018)).y), 0.0, 0.0)) * sampleWeights[i];
}
return color * 0.50;
}
#line 225
float4 CombinePS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 231
float4 orig = tex2D(origframeSampler, texcoord);
const float4 blur = tex2D(ReShade::BackBuffer, texcoord);
float3 sharp;
if (gGaussEffect == 0)
orig = orig;
else if (gGaussEffect == 1)
{
#line 239
orig = lerp(orig, blur, gGaussStrength);
}
else if (gGaussEffect == 2)
{
#line 244
sharp = orig.rgb - blur.rgb;
float sharp_luma = dot(sharp, (float3(0.2126, 0.7152, 0.0722) * gGaussStrength + 0.2));
sharp_luma = clamp(sharp_luma, -0.035, 0.035);
orig = orig + sharp_luma;
}
else if (gGaussEffect == 3)
{
#line 252
if (gGaussBloomWarmth == 0)
orig = lerp(orig, blur *4, gGaussStrength);
#line 255
else if (gGaussBloomWarmth == 1)
orig = lerp(orig, max(orig *1.8 + (blur *5) - 1.0, 0.0), gGaussStrength);       
else
orig = lerp(orig, (1.0 - ((1.0 - orig) * (1.0 - blur *1.0))), gGaussStrength);  
}
else if (gGaussEffect == 4)
{
#line 263
sharp = orig.rgb - blur.rgb;
orig = float4(1.0, 1.0, 1.0, 0.0) - min(orig, dot(sharp, (float3(0.2126, 0.7152, 0.0722) * gGaussStrength + 0.2))) *3;
#line 266
}
else
orig = blur;
#line 270
if (gAddBloom == 1)
{
if (gGaussBloomWarmth == 0)
{
orig += lerp(orig, blur *4, gBloomStrength);
orig = orig * 0.5;
}
else if (gGaussBloomWarmth == 1)
{
orig += lerp(orig, max(orig *1.8 + (blur *5) - 1.0, 0.0), gBloomStrength);
orig = orig * 0.5;
}
else
{
orig += lerp(orig, (1.0 - ((1.0 - orig) * (1.0 - blur *1.0))), gBloomStrength);
orig = orig * 0.5;
}
}
else
orig = orig;
#line 296
return orig;
}
#line 299
float4 PassThrough(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
return tex2D(ReShade::BackBuffer, texcoord);
}
#line 304
technique GAUSSSIAN
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PassThrough;
RenderTarget = origframeTex2D;
}
#line 314
pass P0
{
VertexShader = PostProcessVS;
PixelShader = BrightPassFilterPS;
}
#line 322
pass P1
{
VertexShader = PostProcessVS;
PixelShader = HGaussianBlurPS;
}
#line 330
pass P2
{
VertexShader = PostProcessVS;
PixelShader = VGaussianBlurPS;
}
#line 338
pass P3
{
VertexShader = PostProcessVS;
PixelShader = SGaussianBlurPS;
}
#line 345
pass P5
{
VertexShader = PostProcessVS;
PixelShader = CombinePS;
}
}

