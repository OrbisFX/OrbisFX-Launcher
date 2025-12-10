#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\DynamicRaindrops.fx"
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
#line 13 "C:\Program Files\GShade\gshade-shaders\Shaders\DynamicRaindrops.fx"
uniform int rand < source = "random"; min = 0; max = 1; >;
uniform int Frame < source = "framecount"; >;
#line 21
static const float2 shapeList[10] =
{
float2(7,6),
float2(1,7),
float2(5,1),
float2(9,1),
float2(2,0),
float2(3,0),
float2(0,1),
float2(0,1),
float2(2,4),
float2(3,4)
};
#line 35
uniform int bokehShape <
ui_type  = "combo";
ui_label = "Bokeh Shape";
ui_items = "pentagon\0pentagon CA\0hexagon\0hexagon CA\0heptagon\0heptagon CA\0octagon\0octagon CA\0Circle\0Circle CA\0";
> = 1;
#line 41
uniform float uiscale <
ui_type  = "slider";
ui_label = "Bokeh Size";
ui_tooltip = "The size will be further modified\n"
"by a random value per raindrop.";
> = 1;
#line 48
uniform float BokehBrightness <
ui_type  = "slider";
ui_label = "Bokeh Brightness";
> = 0.5;
#line 53
uniform float fadeSpeed <
ui_type  = "slider";
ui_label = "Raindrop Presistence";
ui_tooltip = "Lower values makes raindrops fade sooner.\n"
"If set t one: A thing of beauty, will never fade away :)!";
> = 0.9;
#line 60
uniform float uicount <
ui_type  = "slider";
ui_label = "Spawn Rate";
ui_tooltip = "The probability of new raindrops landing\n"
"on the camera lense relevant to time.";
ui_max = 2;
> = 0.15;
#line 74
texture TexColor : COLOR;
sampler sTexColor {Texture = TexColor;};
#line 77
texture DRD_Tex0 { Width = 1920; Height = 1018; Format = RGBA16f; };
sampler sDRD_Tex0{ Texture = DRD_Tex0; };
#line 80
texture DRD_Tex1 { Width = 1920; Height = 1018; Format = RGBA16f; };
sampler sDRD_Tex1{ Texture = DRD_Tex1; };
#line 83
texture DRD_Tex2 { Width = 1920; Height = 1018; Format = RGBA16f; };
sampler sDRD_Tex2{ Texture = DRD_Tex2; };
#line 86
texture DRD_TexBackBuffer0 { Width = 1920; Height = 1018; Format = RGBA16f; MipLevels = 5; };
sampler sDRD_TexBackBuffer0{ Texture = DRD_TexBackBuffer0; };
#line 89
texture DRD_TexBackBuffer1 { Width = 1920 / 8; Height = 1018 / 8; Format = RGBA16f; };
sampler sDRD_TexBackBuffer1{ Texture = DRD_TexBackBuffer1; };
#line 92
texture DRD_TexBackBuffer2 { Width = 1920 / 8; Height = 1018 / 8; Format = RGBA16f; };
sampler sDRD_TexBackBuffer2{ Texture = DRD_TexBackBuffer2; };
#line 95
texture DRD_BokehTex <source = "NGbokeh.jpg";> { Width = 683; Height = 1024; Format = RGBA8; MipLevels = 8; };
sampler sDRD_BokehTex {Texture = DRD_BokehTex; };
#line 101
float4 SampleTextureCatmullRom9t(in sampler tex, in float4 uv)
{
float2 texSize = tex2Dsize(tex);
float2 samplePos = uv.xy * texSize;
float2 texPos1 = floor(samplePos - 0.5f) + 0.5f;
#line 107
float2 f = samplePos - texPos1;
#line 109
float2 w0 = f * (-0.5f + f * (1.0f - 0.5f * f));
float2 w1 = 1.0f + f * f * (-2.5f + 1.5f * f);
float2 w2 = f * (0.5f + f * (2.0f - 1.5f * f));
float2 w3 = f * f * (-0.5f + 0.5f * f);
#line 114
float2 w12 = w1 + w2;
float2 offset12 = w2 / (w1 + w2);
#line 117
float2 texPos0 = texPos1 - 1;
float2 texPos3 = texPos1 + 2;
float2 texPos12 = texPos1 + offset12;
#line 121
texPos0 /= texSize;
texPos3 /= texSize;
texPos12 /= texSize;
#line 125
float4 result = 0.0f;
result += tex2Dlod(tex, float4(texPos0.x, texPos0.y,0,0)) * w0.x * w0.y;
result += tex2Dlod(tex, float4(texPos12.x, texPos0.y,0,0)) * w12.x * w0.y;
result += tex2Dlod(tex, float4(texPos3.x, texPos0.y,0,0)) * w3.x * w0.y;
#line 130
result += tex2Dlod(tex, float4(texPos0.x, texPos12.y,0,0)) * w0.x * w12.y;
result += tex2Dlod(tex, float4(texPos12.x, texPos12.y,0,0)) * w12.x * w12.y;
result += tex2Dlod(tex, float4(texPos3.x, texPos12.y,0,0)) * w3.x * w12.y;
#line 134
result += tex2Dlod(tex, float4(texPos0.x, texPos3.y,0,0)) * w0.x * w3.y;
result += tex2Dlod(tex, float4(texPos12.x, texPos3.y,0,0)) * w12.x * w3.y;
result += tex2Dlod(tex, float4(texPos3.x, texPos3.y,0,0)) * w3.x * w3.y;
#line 138
return result;
}
#line 141
float lum(in float3 color)
{
return dot(color, float3(0.25, 0.5, 0.25));
}
#line 146
float4 sampleBokeh(in float2 uv, in float2 pos, in float scale, in float opacity)
{
uv -= pos;
uv *= float2(1920, 1018);
#line 151
uv -= 32;
uv /= scale;
uv += 32;
#line 155
bool mask = !(uv.x <= 3 || uv.x >= 61 || uv.y <= 3 || uv.y >= 61);
#line 157
uv += 64 * shapeList[bokehShape];
#line 159
uv /= tex2Dsize(sDRD_BokehTex);
#line 161
float3 color = SampleTextureCatmullRom9t(sDRD_BokehTex, float4(uv,0,0)).rgb;
#line 163
float  alpha = saturate(lum(color)*10);
alpha *= alpha; alpha *= alpha; alpha *= alpha; alpha *= mask;
#line 166
return float4(color * alpha * opacity, alpha * opacity);
}
#line 169
float Randt(float2 co)
{
co += frac(Frame*0.00116589);
return frac(sin(dot(co.xy ,float2(1.0,73))) * 437580.5453);
}
#line 193
float4 fastBlur(sampler s, in float2 texcoord, in float2 step)
{
step *= 8 * 1 / float2(1920, 1018);
const uint steps=5;
#line 199
const float sum=6+15+20+15+6;
const float w = 0.2;
float4 color = 0;
#line 203
float2 offset = -floor(steps / 2) * step;
for( uint i = 0; i < steps; i++) {
float4 c = tex2Dlod(s, float4(texcoord + offset, 0, 3));
offset += step;
c *= 0.2;
color += c;
#line 210
}
return color;
}
#line 219
struct passInput
{
float4 vp : SV_Position;
float2 uv : TEXCOORD;
};
#line 225
void PrePassPS(passInput i, out float4 outColor : SV_Target0)
{
outColor = tex2D(sTexColor, i.uv);
outColor /= (1.01 - outColor);
}
#line 232
float4 Blur0PS(passInput i) : SV_Target0 {return fastBlur(sDRD_TexBackBuffer0, i.uv + (0.5 * 8 / float2(1920, 1018)), float2( 5, 2));}
float4 Blur1PS(passInput i) : SV_Target0 {return fastBlur(sDRD_TexBackBuffer1, i.uv + (0.5 * 8 / float2(1920, 1018)), float2(-2, 5));}
float4 Blur2PS(passInput i) : SV_Target0 {return fastBlur(sDRD_TexBackBuffer2, i.uv + (0.5 * 8 / float2(1920, 1018)), float2( 2, 5));}
float4 Blur3PS(passInput i) : SV_Target0 {return fastBlur(sDRD_TexBackBuffer1, i.uv + (0.5 * 8 / float2(1920, 1018)), float2(-5, 2));}
#line 237
void MainPS(passInput i, out float4 outColor : SV_Target0, out float4 outBackBuffer : SV_Target1)
{
float fac = fadeSpeed * 0.1 + 0.9;
float4 bokehs = tex2D(sDRD_Tex1, i.uv) * fac;
float4 current = 0;
#line 243
if(Randt(1.215435) < (uicount))
{
[loop]for(int x; x <= uicount; x++)
{
float t = x / float(uicount);
float2 offset = float2(Randt(0.168468 * t + 0.546597), Randt(0.2558479 * t));
float scale = Randt(0.3 + t) * uiscale + uiscale;
#line 251
current += sampleBokeh(i.uv, offset, scale, 1);
}
}
#line 255
outColor = bokehs + float4(current.rgb, 1-fac);
outBackBuffer = tex2D(sTexColor, i.uv);
#line 258
outBackBuffer = outBackBuffer / (1 - outBackBuffer);
}
#line 261
void CopyPS(passInput i, out float4 outData : SV_Target0, out float4 outBackBuffer : SV_Target1)
{
outData = tex2D(sDRD_Tex0, i.uv);
outBackBuffer = 1;
}
#line 267
float4 OutPS(passInput i) : SV_Target
{
float4 mainColor = tex2D(sTexColor, i.uv);
float4 Drops     = tex2D(sDRD_Tex1, i.uv);
float4 blurredBackBuffer = tex2D(sDRD_TexBackBuffer2, i.uv);
float4 HDRBackBuffer = mainColor / (1.01 - mainColor);
#line 274
Drops *= BokehBrightness * blurredBackBuffer;
Drops += HDRBackBuffer;
Drops /= (1.0 + Drops);
#line 278
Drops += frac(sin(dot(i.uv.xy ,float2(1.0,73))) * 437580.5453)/255;
#line 280
return Drops;
#line 282
}
#line 287
technique DynamicRaindrops
<
ui_label = "NiceGuy RainDrops";
ui_tooltip = "||         NiceGuy Raindrops || Version 1.0.0           ||\n"
"||                      By NiceGuy                      ||\n"
"||Simulates dynamic raindrops  hitting the camera lense.||";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader  = PrePassPS;
RenderTarget = DRD_TexBackBuffer0;
}
pass
{
VertexShader = PostProcessVS;
PixelShader  = Blur0PS;
RenderTarget = DRD_TexBackBuffer1;
}
pass
{
VertexShader = PostProcessVS;
PixelShader  = Blur1PS;
RenderTarget = DRD_TexBackBuffer2;
}
pass
{
VertexShader = PostProcessVS;
PixelShader  = Blur2PS;
RenderTarget = DRD_TexBackBuffer1;
}
pass
{
VertexShader = PostProcessVS;
PixelShader  = Blur3PS;
RenderTarget = DRD_TexBackBuffer2;
}
pass
{
VertexShader = PostProcessVS;
PixelShader  = MainPS;
RenderTarget = DRD_Tex0;
}
pass
{
VertexShader = PostProcessVS;
PixelShader  = CopyPS;
RenderTarget = DRD_Tex1;
}
pass
{
VertexShader = PostProcessVS;
PixelShader  = OutPS;
}
}

