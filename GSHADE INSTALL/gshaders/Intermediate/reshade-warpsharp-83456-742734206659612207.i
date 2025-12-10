#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\warpsharp.fx"
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
#line 58 "C:\Program Files\GShade\gshade-shaders\Shaders\warpsharp.fx"
#line 59
namespace warpsharp {
#line 61
uniform float warp_strength <
ui_type = "slider";
ui_category = "WarpSharp";
ui_min = 0; ui_max = 5; ui_step = .01;
ui_tooltip = "Multiplier for the warp distance. May need to be higher for low contrast images, or lower for high-contrast images.";
ui_label = "WarpSharp Strength";
> = .5;
#line 69
uniform float warp_scale <
ui_type = "slider";
ui_category = "WarpSharp";
ui_min = 1; ui_max = 25; ui_step = .5;
ui_tooltip = "Scale in pixels - the bigger the blur on the input image the larger this needs to be. This is both the distance of input points when calculating the edge bump map, and maximum displacement when warping the final output. ";
ui_label = "WarpSharp Scale";
> = 1;
#line 78
texture warpTex {
Width = 1920 ;
Height = 1018 ;
Format = R16F;
};
#line 85
sampler warpSampler {
Texture = warpTex;
#line 88
};
#line 90
texture warpTex2 {
Width = 1920 ;
Height = 1018 ;
Format = R16F;
};
#line 97
sampler warpSampler2 {
Texture = warpTex;
#line 100
};
#line 107
float warpSharp1_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 116
const float3 ne = tex2D(ReShade::BackBuffer, texcoord + ((warp_scale-.5)*1/float2(1920,1018))).rgb;
const float3 se = tex2D(ReShade::BackBuffer, texcoord + ((warp_scale-.5)*1/float2(1920,1018))*float2(1,-1)).rgb;
const float3 sw = tex2D(ReShade::BackBuffer, texcoord - ((warp_scale-.5)*1/float2(1920,1018))).rgb;
const float3 nw = tex2D(ReShade::BackBuffer, texcoord - ((warp_scale-.5)*1/float2(1920,1018))*float2(1,-1)).rgb;
#line 121
const float dx = length(ne+se-sw-nw);
const float dy = length(ne+nw-se-sw);
#line 125
return sqrt(length(float2(dx,dy)));
}
#line 129
float warpSharp2_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
const float ne = tex2D(warpSampler, texcoord + ((warp_scale-.5)*1/float2(1920,1018)) ).r;
const float se = tex2D(warpSampler, texcoord + ((warp_scale-.5)*1/float2(1920,1018))*float2(1,-1)).r;
const float sw = tex2D(warpSampler, texcoord - ((warp_scale-.5)*1/float2(1920,1018))).r;
const float nw = tex2D(warpSampler, texcoord - ((warp_scale-.5)*1/float2(1920,1018))*float2(1,-1)).r;
#line 136
float total = (ne+se+sw+nw);
if(warp_scale>=1.5) total = (total + tex2D(warpSampler, texcoord)).r /5;
else total = total /4;
return total;
}
#line 143
float4 warpSharp3_PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
const float ne = tex2D(warpSampler2, texcoord + ((warp_scale-.5)*1/float2(1920,1018))).r;
const float se = tex2D(warpSampler2, texcoord + ((warp_scale-.5)*1/float2(1920,1018))*float2(1,-1)).r;
const float sw = tex2D(warpSampler2, texcoord - ((warp_scale-.5)*1/float2(1920,1018))).r;
const float nw = tex2D(warpSampler2, texcoord - ((warp_scale-.5)*1/float2(1920,1018))*float2(1,-1)).r;
#line 150
const float dx = ne+se-sw-nw;
const float dy = ne+nw-se-sw;
#line 153
float2 offset = float2(dx, dy) * warp_strength*.01;
#line 155
offset = clamp(offset, -((warp_scale-.5)*1/float2(1920,1018)), ((warp_scale-.5)*1/float2(1920,1018)));
#line 157
return tex2D(ReShade::BackBuffer, texcoord - offset);
}
#line 164
technique WarpSharp <
ui_tooltip = "Warp sharp sharpens blurry edges by detecting edges then sampling a point away from the centre line of the edge.\n\nWarp sharp is good for restoring clear edges (but not texture details) on images that have been blurred or upscaled.\n\nIt is not necessarily good for sharpening game output, as games have a mixture of very sharp edges of objects, and varying levels of blurrines in different textures.";
>
{
#line 169
pass  {
VertexShader = PostProcessVS;
PixelShader  = warpSharp1_PS;
RenderTarget = warpTex;
}
#line 175
pass  {
VertexShader = PostProcessVS;
PixelShader  = warpSharp2_PS;
RenderTarget = warpTex2;
}
#line 181
pass  {
VertexShader = PostProcessVS;
PixelShader  = warpSharp3_PS;
}
}
#line 188
}

