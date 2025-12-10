#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ZN_LC.fx"
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
#line 5 "C:\Program Files\GShade\gshade-shaders\Shaders\ZN_LC.fx"
#line 6
uniform int ZN_LocalContrast <
ui_type = "radio";
ui_label = " ";
ui_text = "ZN Local Contrast is a low cost unsharp mask and bloom shader\n"
"It leverages a heavy blur to increase overall contrast and reduce washed out colors without 'Deep Frying' the image";
ui_category = "ZN Local Contrast";
ui_category_closed = true;
> = 0;
#line 15
uniform float BLUR_OFFSET <
ui_type = "slider";
ui_min = 0.0;
ui_max = 20.0;
ui_label = "Blur Offset";
ui_tooltip = "Blur radius for Unsharp and bloom";
> = 15.0;
#line 23
uniform float INTENSITY <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Intensity";
ui_tooltip = "Effect Intensity";
> = 0.3;
#line 31
uniform float BLOOM_INTENSITY <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Bloom Intensity";
ui_tooltip = "How much bloom is added into the original image";
> = 0.2;
#line 39
uniform bool DEBUG <
> = 0;
#line 43
texture DYDownTex0{Width = 1920 / 2; Height = 1018 / 2; Format = RGBA8;};
texture DYDownTex1{Width = 1920 / 4; Height = 1018 / 4; Format = RGBA8;};
texture DYDownTex2{Width = 1920 / 8; Height = 1018 / 8; Format = RGBA8;};
texture DYDownTex3{Width = 1920 / 16; Height = 1018 / 16; Format = RGBA8;};
texture DYUpTex0{Width = 1920 / 8; Height = 1018 / 8; Format = RGBA8;};
texture DYUpTex1{Width = 1920 / 4; Height = 1018 / 4; Format = RGBA8;};
texture DYUpTex2{Width = 1920 / 2; Height = 1018 / 2; Format = RGBA8;};
texture DYUpTex3{Width = 1920; Height = 1018; Format = RGBA8;};
#line 52
sampler DownSam0{Texture = DYDownTex0;};
sampler DownSam1{Texture = DYDownTex1;};
sampler DownSam2{Texture = DYDownTex2;};
sampler DownSam3{Texture = DYDownTex3;};
sampler UpSam0{Texture = DYUpTex0;};
sampler UpSam1{Texture = DYUpTex1;};
sampler UpSam2{Texture = DYUpTex2;};
sampler UpSam3{Texture = DYUpTex3;};
#line 62
float4 DownSample0(float4 vpos : SV_Position, float2 xy : TexCoord) : SV_Target
{
#line 65
float2 res = float2(1920, 1018) / 2.0;
float2 hp = 0.5 / res;
float offset = BLUR_OFFSET;
#line 69
float3 acc = tex2D(ReShade::BackBuffer, xy).rgb * 4.0;
acc += tex2D(ReShade::BackBuffer, xy - hp * offset).rgb;
acc += tex2D(ReShade::BackBuffer, xy + hp * offset).rgb;
acc += tex2D(ReShade::BackBuffer, xy + float2(hp.x, -hp.y) * offset).rgb;
acc += tex2D(ReShade::BackBuffer, xy - float2(hp.x, -hp.y) * offset).rgb;
#line 75
return float4(acc / 8.0, 1.0);
#line 77
}
#line 79
float4 DownSample1(float4 vpos : SV_Position, float2 xy : TexCoord) : SV_Target
{
#line 82
float2 res = float2(1920, 1018) / 2.0;
float2 hp = 0.5 / res;
float offset = BLUR_OFFSET;
#line 86
float3 acc = tex2D(DownSam0, xy).rgb * 4.0;
acc += tex2D(DownSam0, xy - hp * offset).rgb;
acc += tex2D(DownSam0, xy + hp * offset).rgb;
acc += tex2D(DownSam0, xy + float2(hp.x, -hp.y) * offset).rgb;
acc += tex2D(DownSam0, xy - float2(hp.x, -hp.y) * offset).rgb;
#line 92
return float4(acc / 8.0, 1.0);
#line 94
}
#line 96
float4 DownSample2(float4 vpos : SV_Position, float2 xy : TexCoord) : SV_Target
{
#line 99
float2 res = float2(1920, 1018) / 2.0;
float2 hp = 0.5 / res;
float offset = BLUR_OFFSET;
#line 103
float3 acc = tex2D(DownSam1, xy).rgb * 4.0;
acc += tex2D(DownSam1, xy - hp * offset).rgb;
acc += tex2D(DownSam1, xy + hp * offset).rgb;
acc += tex2D(DownSam1, xy + float2(hp.x, -hp.y) * offset).rgb;
acc += tex2D(DownSam1, xy - float2(hp.x, -hp.y) * offset).rgb;
#line 109
return float4(acc / 8.0, 1.0);
#line 111
}
#line 113
float4 DownSample3(float4 vpos : SV_Position, float2 xy : TexCoord) : SV_Target
{
#line 116
float2 res = float2(1920, 1018) / 2.0;
float2 hp = 0.5 / res;
float offset = BLUR_OFFSET;
#line 120
float3 acc = tex2D(DownSam1, xy).rgb * 4.0;
acc += tex2D(DownSam2, xy - hp * offset).rgb;
acc += tex2D(DownSam2, xy + hp * offset).rgb;
acc += tex2D(DownSam2, xy + float2(hp.x, -hp.y) * offset).rgb;
acc += tex2D(DownSam2, xy - float2(hp.x, -hp.y) * offset).rgb;
#line 126
return float4(acc / 8.0, 1.0);
#line 128
}
#line 130
float4 UpSample0(float4 vpos : SV_Position, float2 xy : TexCoord) : SV_Target
{
#line 133
float2 res = float2(1920, 1018) / 2.0;
float2 hp = 0.5 / res;
float offset = BLUR_OFFSET;
float3 acc = tex2D(DownSam3, xy + float2(-hp.x * 2.0, 0.0) * offset).rgb;
#line 138
acc += tex2D(DownSam3, xy + float2(-hp.x, hp.y) * offset).rgb * 2.0;
acc += tex2D(DownSam3, xy + float2(0.0, hp.y * 2.0) * offset).rgb;
acc += tex2D(DownSam3, xy + float2(hp.x, hp.y) * offset).rgb * 2.0;
acc += tex2D(DownSam3, xy + float2(hp.x * 2.0, 0.0) * offset).rgb;
acc += tex2D(DownSam3, xy + float2(hp.x, -hp.y) * offset).rgb * 2.0;
acc += tex2D(DownSam3, xy + float2(0.0, -hp.y * 2.0) * offset).rgb;
acc += tex2D(DownSam3, xy + float2(-hp.x, -hp.y) * offset).rgb * 2.0;
#line 146
return float4(acc / 12.0, 1.0);
}
#line 151
float4 UpSample1(float4 vpos : SV_Position, float2 xy : TexCoord) : SV_Target
{
#line 154
float2 res = float2(1920, 1018) / 2.0;
float2 hp = 0.5 / res;
float offset = BLUR_OFFSET;
float3 acc = tex2D(UpSam0, xy + float2(-hp.x * 2.0, 0.0) * offset).rgb;
#line 159
acc += tex2D(UpSam0, xy + float2(-hp.x, hp.y) * offset).rgb * 2.0;
acc += tex2D(UpSam0, xy + float2(0.0, hp.y * 2.0) * offset).rgb;
acc += tex2D(UpSam0, xy + float2(hp.x, hp.y) * offset).rgb * 2.0;
acc += tex2D(UpSam0, xy + float2(hp.x * 2.0, 0.0) * offset).rgb;
acc += tex2D(UpSam0, xy + float2(hp.x, -hp.y) * offset).rgb * 2.0;
acc += tex2D(UpSam0, xy + float2(0.0, -hp.y * 2.0) * offset).rgb;
acc += tex2D(UpSam0, xy + float2(-hp.x, -hp.y) * offset).rgb * 2.0;
#line 167
return float4(acc / 12.0, 1.0);
}
#line 170
float4 UpSample2(float4 vpos : SV_Position, float2 xy : TexCoord) : SV_Target
{
#line 173
float2 res = float2(1920, 1018) / 2.0;
float2 hp = 0.5 / res;
float offset = BLUR_OFFSET;
float3 acc = tex2D(UpSam0, xy + float2(-hp.x * 2.0, 0.0) * offset).rgb;
#line 178
acc += tex2D(UpSam1, xy + float2(-hp.x, hp.y) * offset).rgb * 2.0;
acc += tex2D(UpSam1, xy + float2(0.0, hp.y * 2.0) * offset).rgb;
acc += tex2D(UpSam1, xy + float2(hp.x, hp.y) * offset).rgb * 2.0;
acc += tex2D(UpSam1, xy + float2(hp.x * 2.0, 0.0) * offset).rgb;
acc += tex2D(UpSam1, xy + float2(hp.x, -hp.y) * offset).rgb * 2.0;
acc += tex2D(UpSam1, xy + float2(0.0, -hp.y * 2.0) * offset).rgb;
acc += tex2D(UpSam1, xy + float2(-hp.x, -hp.y) * offset).rgb * 2.0;
#line 186
return float4(acc / 12.0, 1.0);
}
#line 189
float4 UpSample3(float4 vpos : SV_Position, float2 xy : TexCoord) : SV_Target
{
#line 192
float2 res = float2(1920, 1018) / 2.0;
float2 hp = 0.5 / res;
float offset = BLUR_OFFSET;
float3 acc = tex2D(UpSam2, xy + float2(-hp.x * 2.0, 0.0) * offset).rgb;
#line 197
acc += tex2D(UpSam2, xy + float2(-hp.x, hp.y) * offset).rgb * 2.0;
acc += tex2D(UpSam2, xy + float2(0.0, hp.y * 2.0) * offset).rgb;
acc += tex2D(UpSam2, xy + float2(hp.x, hp.y) * offset).rgb * 2.0;
acc += tex2D(UpSam2, xy + float2(hp.x * 2.0, 0.0) * offset).rgb;
acc += tex2D(UpSam2, xy + float2(hp.x, -hp.y) * offset).rgb * 2.0;
acc += tex2D(UpSam2, xy + float2(0.0, -hp.y * 2.0) * offset).rgb;
acc += tex2D(UpSam2, xy + float2(-hp.x, -hp.y) * offset).rgb * 2.0;
#line 205
return float4(acc / 12.0, 1.0);
}
#line 208
float3 ZN_DUAL(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 input = tex2D(ReShade::BackBuffer, texcoord).rgb;
float3 blur = tex2D(UpSam3, texcoord).rgb;
float3 bloom = pow(max(blur, 0.0), 2.2) * BLOOM_INTENSITY;
float blurLum = blur.r * 0.2126 + blur.g * 0.7152 + blur.b * 0.0722;
#line 215
if(DEBUG) {return INTENSITY * (input - blur) + bloom;}
return input + INTENSITY * (input - blurLum) + bloom;
}
#line 219
technique ZN_LocalContrast
{
pass
{
VertexShader = PostProcessVS;
PixelShader = DownSample0;
RenderTarget = DYDownTex0;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = DownSample1;
RenderTarget = DYDownTex1;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = DownSample2;
RenderTarget = DYDownTex2;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = DownSample3;
RenderTarget = DYDownTex3;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = UpSample0;
RenderTarget = DYUpTex0;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = UpSample1;
RenderTarget = DYUpTex1;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = UpSample2;
RenderTarget = DYUpTex2;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = UpSample3;
RenderTarget = DYUpTex3;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = ZN_DUAL;
}
}

