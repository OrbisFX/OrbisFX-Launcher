// FAST_BLUR_SCALE=1
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\fastBlur.fx"
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
#line 53 "C:\Program Files\GShade\gshade-shaders\Shaders\fastBlur.fx"
#line 54
namespace fastblur {
#line 63
uniform float fast_blur_size <
ui_type = "slider";
ui_category = "Fast Blur";
ui_min = 0; ui_max = 1.5; ui_step = .01;
ui_tooltip = "For an extra big blur set preprocessor definition FAST_BLUR_SCALE to an integer bigger than 1. High values of for FAST_BLUR_SCALE might only look right with fast_blur_size=1.";
ui_label = "Fast Blur size";
> = 1;
#line 71
uniform int fast_blur_shape <
ui_category = "Fast Blur";
ui_type = "combo";
ui_label = "Fast Blur shape";
ui_items = "Gaussian (6 15 20 15 6)\0"
"Block (1 1 1 1 1)\0";
> = 0;
#line 80
sampler2D samplerColor
{
#line 83
Texture = ReShade::BackBufferTex;
#line 86
SRGBTexture = true;
#line 88
};
#line 90
texture HBlurTex {
Width = 1920/1 ;
Height = 1018/1 ;
Format = RGBA16F;
};
#line 96
texture VBlurTex {
Width = 1920/1 ;
Height = 1018/1 ;
Format = RGBA16F;
};
#line 102
sampler HBlurSampler {
Texture = HBlurTex;
#line 105
};
#line 107
sampler VBlurSampler {
Texture = VBlurTex;
#line 110
};
#line 113
float4 fastBlur(sampler s, in float4 pos, in float2 texcoord, in float2 step  ) {
step *= fast_blur_size/float2(1920/1,1018/1);
#line 116
float4 color = 0;
#line 118
const uint steps=5;
#line 121
const float sum=6+15+20+15+6;
float w[steps] = { 6/sum, 15/sum, 20/sum, 15/sum, 6/sum};
if(fast_blur_shape) w = { .2, .2, .2, .2, .2 };
#line 125
float2 offset=-floor(steps/2)*step ; ;
for( uint i=0; i<steps; i++) {
float4 c = tex2D(s, texcoord + offset);
offset+=step;
c *= (w[i]);
color+=c;
#line 132
}
return color;
}
#line 138
float4 fastBlur1_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 141
return fastBlur(samplerColor, pos, texcoord+(.5/float2(1920/1,1018/1)), float2(5,2) );
}
#line 144
float4 fastBlur1b_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 147
return fastBlur(VBlurSampler, pos, texcoord+(.5/float2(1920/1,1018/1)), float2(5,2) );
}
#line 150
float4 fastBlur2_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 153
return fastBlur(HBlurSampler, pos, texcoord-(.5/float2(1920/1,1018/1)), float2(-2,5) );
}
#line 156
float4 fastBlur3_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 159
return fastBlur(VBlurSampler, pos, texcoord-(.5/float2(1920/1,1018/1)), float2(2,5) );
}
#line 162
float4 fastBlur4_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 165
return fastBlur(HBlurSampler, pos, texcoord+(.5/float2(1920/1,1018/1)), float2(-5,2) );
}
#line 169
float4 copy_VBlurSampler_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR {
return tex2D(VBlurSampler, texcoord);
}
#line 173
float4 copy_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR {
return tex2D(samplerColor, texcoord);
}
#line 178
technique fastblur <
ui_tooltip = "Big and fast blur.\n\nFor an extra big blur set preprocessor definition FAST_BLUR_SCALE to an integer bigger than 1. High values of for FAST_BLUR_SCALE might only look right with fast_blur_size=1.";
>
{
#line 219
pass  {
VertexShader = PostProcessVS;
PixelShader  = fastBlur1_PS;
RenderTarget = HBlurTex;
}
#line 225
pass  {
VertexShader = PostProcessVS;
PixelShader  = fastBlur2_PS;
RenderTarget = VBlurTex;
}
#line 231
pass  {
VertexShader = PostProcessVS;
PixelShader  = fastBlur3_PS;
RenderTarget = HBlurTex;
}
#line 237
pass  {
VertexShader = PostProcessVS;
PixelShader  = fastBlur4_PS;
SRGBWriteEnable = true;
}
#line 243
}
#line 246
}

