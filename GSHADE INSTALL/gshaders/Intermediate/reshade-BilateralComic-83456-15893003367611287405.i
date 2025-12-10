#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\BilateralComic.fx"
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
#line 10 "C:\Program Files\GShade\gshade-shaders\Shaders\BilateralComic.fx"
#line 15
texture BackBuffer : COLOR;
texture Luma <Pooled = true;> {Width = 1920; Height = 1018; Format = R16f;};
texture Sobel <Pooled = true;> {Width = 1920; Height = 1018; Format = R8;};
#line 19
sampler sBackBuffer {Texture = BackBuffer;};
sampler sLuma {Texture = Luma;};
sampler sSobel {Texture = Sobel;};
#line 23
uniform float Sigma0 <
ui_type = "slider";
ui_category = "Bilateral";
ui_label = "Spatial Blur Strength";
ui_min = 0; ui_max = 2;
> = 2;
#line 30
uniform float Sigma1 <
ui_type = "slider";
ui_category = "Bilateral";
ui_label = "Gradient Blur Strength";
ui_min = 0.001; ui_max = 10;
> = 10;
#line 37
uniform int Anisotropy<
ui_type = "radio";
ui_items = "None \0 Depth \0 Gradient\0";
ui_category = "Anisotropy";
> = 2;
#line 43
uniform float EdgeThreshold <
ui_type = "slider";
ui_category = "Edges";
ui_label = "Edge Threshold";
ui_min = 0; ui_max = 1.001;
> = 0.3;
#line 50
uniform float EdgeStrength <
ui_type = "slider";
ui_category = "Edges";
ui_label = "Edge Strength";
ui_min = 0; ui_max = 2;
> = 1.4;
#line 57
uniform bool QuantizeLuma <
ui_category = "Quantization";
ui_label = "Quantize Luma";
> = 1;
#line 62
uniform int LevelCount<
ui_type = "slider";
ui_category = "Quantization";
ui_label = "Quantization Depth";
ui_min = 1; ui_max = 255;
> = 48;
#line 69
uniform bool IgnoreSky<
ui_category = "Quantization";
ui_label = "Don't Quantize Sky";
> = 1;
#line 75
float3 BSplineBicubicFilter(sampler sTexture, float2 texcoord)
{
float2 textureSize = tex2Dsize(sTexture);
float2 coord = texcoord * textureSize;
float2 x = frac(coord);
coord = floor(coord) - 0.5;
float2 x2 = x * x;
float2 x3 = x2 * x;
#line 85
float2 w0 = x2 - 0.5 * (x3 + x);
float2 w1 = 1.5 * x3 - 2.5 * x2 + 1.0;
float2 w3 = 0.5 * (x3 - x2);
float2 w2 = 1.0 - w0 - w1 - w3;
#line 92
float2 s0 = w0 + w1;
float2 s1 = w2 + w3;
#line 95
float2 f0 = w1 / (w0 + w1);
float2 f1 = w3 / (w2 + w3);
#line 98
float2 t0 = coord - 1 + f0;
float2 t1 = coord + 1 + f1;
t0 /= textureSize;
t1 /= textureSize;
#line 104
return
(tex2D(sTexture, float2(t0.x, t0.y)).rgb * s0.x
+  tex2D(sTexture, float2(t1.x, t0.y)).rgb * s1.x) * s0.y
+ (tex2D(sTexture, float2(t0.x, t1.y)).rgb * s0.x
+  tex2D(sTexture, float2(t1.x, t1.y)).rgb * s1.x) * s1.y;
#line 110
}
#line 113
float3 NormalVector(float2 texcoord)
{
float3 offset = float3(float2((1.0 / 1920), (1.0 / 1018)), 0.0);
float c;
float4 h;
float4 v;
if(Anisotropy == 1)
{
c = ReShade::GetLinearizedDepth(texcoord);
#line 123
if(c == 0)
{
return float3(1.0, 1.0, 1.0);
}
#line 128
h.x = ReShade::GetLinearizedDepth(texcoord - offset.xz);
h.y = ReShade::GetLinearizedDepth(texcoord + offset.xz);
h.z = ReShade::GetLinearizedDepth(texcoord - 2 * offset.xz);
h.w = ReShade::GetLinearizedDepth(texcoord + 2 * offset.xz);
#line 133
v.x = ReShade::GetLinearizedDepth(texcoord - offset.zy);
v.y = ReShade::GetLinearizedDepth(texcoord + offset.zy);
v.z = ReShade::GetLinearizedDepth(texcoord - 2 * offset.zy);
v.w = ReShade::GetLinearizedDepth(texcoord + 2 * offset.zy);
}
else if(Anisotropy == 2)
{
c = tex2Dlod(sLuma, float4(texcoord, 0, 0)).x;
#line 142
h.x = tex2Dlod(sLuma, float4(texcoord, 0, 0), int2(-1, 0)).x;
h.y = tex2Dlod(sLuma, float4(texcoord, 0, 0), int2(1, 0)).x;
h.z = tex2Dlod(sLuma, float4(texcoord, 0, 0), int2(-2, 0)).x;
h.w = tex2Dlod(sLuma, float4(texcoord, 0, 0), int2(2, 0)).x;
#line 147
v.x = tex2Dlod(sLuma, float4(texcoord, 0, 0), int2(0, -1)).x;
v.y = tex2Dlod(sLuma, float4(texcoord, 0, 0), int2(0, 1)).x;
v.z = tex2Dlod(sLuma, float4(texcoord, 0, 0), int2(0, -2)).x;
v.w = tex2Dlod(sLuma, float4(texcoord, 0, 0), int2(0, 2)).x;
}
#line 153
float2 he = abs(h.xy *h.zw * rcp(2 * h.zw - h.xy) - c);
float3 hDeriv;
#line 156
if(he.x > he.y)
{
float3 pos1 = float3(texcoord.xy - offset.xz, 1);
float3 pos2 = float3(texcoord.xy - 2 * offset.xz, 1);
hDeriv = pos1 * h.x - pos2 * h.z;
}
else
{
float3 pos1 = float3(texcoord.xy - offset.xz, 1);
float3 pos2 = float3(texcoord.xy - 2 * offset.xz, 1);
hDeriv = pos1 * h.x - pos2 * h.z;
}
#line 169
float2 ve = abs(v.xy *v.zw * rcp(2 * v.zw - v.xy) - c);
float3 vDeriv;
#line 172
if(ve.x > ve.y)
{
float3 pos1 = float3(texcoord.xy - offset.zy, 1);
float3 pos2 = float3(texcoord.xy - 2 * offset.zy, 1);
vDeriv = pos1 * v.x - pos2 * v.z;
}
else
{
float3 pos1 = float3(texcoord.xy - offset.zy, 1);
float3 pos2 = float3(texcoord.xy - 2 * offset.zy, 1);
vDeriv = pos1 * v.x - pos2 * v.z;
}
#line 185
return (normalize(min(cross(-vDeriv, hDeriv), float3(0.00001, 0.00001, 0.00001))) * 0.5 + 0.5);
}
#line 188
void LumaBicubicPS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD, out float luma : SV_TARGET0)
{
luma = 0.0;
if(Anisotropy == 2)
{
luma = dot(BSplineBicubicFilter(sBackBuffer, texcoord), float3(0.299, 0.587, 0.114));
}
else discard;
}
#line 199
void SobelFilterPS(float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float edges : SV_Target0)
{
float2 sums;
float sobel[9] = {1, 2, 1, 0, 0, 0, -1, -2, -1};
[unroll]
for(int i = -1; i <= 1; i++)
{
[unroll]
for(int j = -1; j <= 1; j++)
{
int2 indexes = int2((i + 1) * 3 + (j + 1), (j + 1) * 3 + (i + 1));
float3 color = tex2D(sBackBuffer, texcoord, int2(i, j)).rgb;
float x = dot(color * sobel[indexes.x], float3(0.333, 0.333, 0.333));
float y = dot(color * sobel[indexes.y], float3(0.333, 0.333, 0.333));
sums += float2(x, y);
}
}
#line 217
edges = saturate(length(sums));
}
#line 220
void BilateralFilterPS(float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target0)
{
float sigma0 = max(Sigma0, 0.001);
float sigma1 = exp(Sigma1);
color = float4(0, 0, 0, 1);
float3 center = tex2D(sBackBuffer, texcoord).rgb;
color += center;
float3 weightSum = 1;
center = dot(center, float3(0.299, 0.587, 0.114)).xxx * 255;
float2 normals;
if(Anisotropy > 0)
{
normals = (NormalVector(texcoord).xy);
}
else
{
normals = 1;
}
[unroll]
for(int i = -2; i <= 2; i ++)
{
[unroll]
for(int j = -2; j <= 2; j ++)
{
if(all(abs(float2(i, j)) != 0))
{
float2 offset = (float2(i, j) * normals.xy) * 1 / float2(1920, 1018);
float3 s = tex2D(sBackBuffer, texcoord + offset).rgb;
float luma = dot(s, float3(0.299, 0.587, 0.114));
float3 w = exp(((-(i * i + j * j) / (sigma0 * sigma0)) - ((center - luma) * (center - luma) / (sigma1 * sigma1))) * 0.5);
color.rgb += s * w;
weightSum += w;
}
}
}
color.rgb /= weightSum;
#line 259
}
#line 262
void OutputPS(float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target0)
{
color = float4(0.0, 0.0, 0.0, 0.0);
float sobel = tex2D(sSobel, texcoord).x;
if(1 - sobel > (1 - EdgeThreshold)) sobel = 0;
sobel *= exp(-(2 - EdgeStrength));
if (QuantizeLuma == true)
{
sobel = round(sobel * LevelCount) / LevelCount;
}
sobel = 1 - sobel;
color = tex2D(sBackBuffer, texcoord).rgba * sobel;
if (QuantizeLuma == true)
{
float depth = ReShade::GetLinearizedDepth(texcoord);
if(!IgnoreSky || depth < 1)
{
#line 280
float luma = round(dot(color.rgb, float3(0.299, 0.587, 0.114)) * LevelCount)/LevelCount;
float cb = -0.168736 * color.r - 0.331264 * color.g + 0.500000 * color.b;
float cr = +0.500000 * color.r - 0.418688 * color.g - 0.081312 * color.b;
color = float3(
luma + 1.402 * cr,
luma - 0.344136 * cb - 0.714136 * cr,
luma + 1.772 * cb);
}
}
#line 293
}
#line 295
technique BilateralComic<ui_tooltip = "Cel-shading shader that uses a combination of bilateral filtering, posterization,\n"
"and edge detection to create a comic book style effect in games.\n\n"
"Part of Insane Shaders\n"
"By: Lord of Lunacy";>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = LumaBicubicPS;
RenderTarget0 = Luma;
}
#line 307
pass
{
VertexShader = PostProcessVS;
PixelShader = SobelFilterPS;
RenderTarget0 = Sobel;
}
#line 314
pass
{
VertexShader = PostProcessVS;
PixelShader = BilateralFilterPS;
}
#line 320
pass
{
VertexShader = PostProcessVS;
PixelShader = OutputPS;
}
}

