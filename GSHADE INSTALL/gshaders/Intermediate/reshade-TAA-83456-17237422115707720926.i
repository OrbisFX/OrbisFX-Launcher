#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\TAA.fx"
#line 7
uniform float Jitter_Ammount <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Jitter Ammount";
ui_tooltip = "Adjust Randomized Halton base(2,3) Jitter.\n"
"Default is 0.5.";
> = 0.5;
#line 15
uniform float Seeking <
ui_type = "slider";
ui_min = 0.025; ui_max = 0.250;
ui_label = "Seeking";
ui_tooltip = "Default is 0.150";
> = 0.150;
#line 22
uniform int DebugOutput <
ui_type = "combo";
ui_items = "Off\0On\0";
ui_label = "Debug Output";
> = false;
#line 29
texture BackBufferTex : COLOR;
#line 31
sampler BackBuffer
{
Texture = BackBufferTex;
};
#line 36
texture PastBackBuffer  { Width = 1920; Height = 1018; Format = RGBA8;};
#line 38
sampler PBackBuffer
{
Texture = PastBackBuffer;
};
#line 43
texture TAABackBuffer  { Width = 1920; Height = 1018; Format = RGBA8;};
#line 45
sampler BackBufferTAA
{
Texture = TAABackBuffer;
};
#line 54
float3 encodePalYuv(float3 rgb)
{
const float3 RGB2Y =  float3( 0.299, 0.587, 0.114);
const float3 RGB2Cb = float3(-0.14713, -0.28886, 0.436);
const float3 RGB2Cr = float3(0.615,-0.51499,-0.10001);
#line 60
return float3(dot(rgb, RGB2Y), dot(rgb, RGB2Cb), dot(rgb, RGB2Cr));
}
#line 63
float3 decodePalYuv(float3 ycc)
{
const float3 YCbCr2R = float3( 1.000, 0.000, 1.13983);
const float3 YCbCr2G = float3( 1.000,-0.39465,-0.58060);
const float3 YCbCr2B = float3( 1.000, 2.03211, 0.000);
return float3(dot(ycc, YCbCr2R), dot(ycc, YCbCr2G), dot(ycc, YCbCr2B));
}
#line 72
uniform int random < source = "random"; min = -128; max = 128; >;
#line 74
float Halton(float i, float base)
{
float x = 1.0f / base;
float v = 0.0f;
while (i > 0)
{
v += x * (i % base);
i = floor(i / base);
x /= base;
}
return v;
}
#line 87
float4 TAA(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 90
float2 XY = float2(random,random);
#line 92
XY = float2(Halton(XY.x, 2),Halton(XY.y, 3));
XY = XY * (float2((1.0 / 1920), (1.0 / 1018)) * Jitter_Ammount);
#line 95
const float4 PastColor = tex2D(PBackBuffer,texcoord + XY);
#line 97
float3 antialiased = PastColor.xyz;
const float mixRate = min(PastColor.w, 0.5);
#line 100
float3 in0 = tex2D(BackBuffer, texcoord).xyz;
#line 102
antialiased = lerp(antialiased * antialiased, in0 * in0, mixRate);
antialiased = sqrt(antialiased);
antialiased = encodePalYuv(antialiased);
#line 106
float3 in1 = tex2D(BackBuffer, texcoord + float2(+float2((1.0 / 1920), (1.0 / 1018)).x, 0.0)).xyz;
float3 in2 = tex2D(BackBuffer, texcoord + float2(-float2((1.0 / 1920), (1.0 / 1018)).x, 0.0)).xyz;
float3 in3 = tex2D(BackBuffer, texcoord + float2(0.0, +float2((1.0 / 1920), (1.0 / 1018)).y)).xyz;
float3 in4 = tex2D(BackBuffer, texcoord + float2(0.0, -float2((1.0 / 1920), (1.0 / 1018)).y)).xyz;
float3 in5 = tex2D(BackBuffer, texcoord + float2(+float2((1.0 / 1920), (1.0 / 1018)).x, +float2((1.0 / 1920), (1.0 / 1018)).y)).xyz;
float3 in6 = tex2D(BackBuffer, texcoord + float2(-float2((1.0 / 1920), (1.0 / 1018)).x, +float2((1.0 / 1920), (1.0 / 1018)).y)).xyz;
float3 in7 = tex2D(BackBuffer, texcoord + float2(+float2((1.0 / 1920), (1.0 / 1018)).x, -float2((1.0 / 1920), (1.0 / 1018)).y)).xyz;
float3 in8 = tex2D(BackBuffer, texcoord + float2(-float2((1.0 / 1920), (1.0 / 1018)).x, -float2((1.0 / 1920), (1.0 / 1018)).y)).xyz;
#line 115
in0 = encodePalYuv(in0);
in1 = encodePalYuv(in1);
in2 = encodePalYuv(in2);
in3 = encodePalYuv(in3);
in4 = encodePalYuv(in4);
in5 = encodePalYuv(in5);
in6 = encodePalYuv(in6);
in7 = encodePalYuv(in7);
in8 = encodePalYuv(in8);
#line 125
float3 minColor = min(min(min(in0, in1), min(in2, in3)), in4);
float3 maxColor = max(max(max(in0, in1), max(in2, in3)), in4);
minColor = lerp(minColor, min(min(min(in5, in6), min(in7, in8)), minColor), 0.5);
maxColor = lerp(maxColor, max(max(max(in5, in6), max(in7, in8)), maxColor), 0.5);
#line 130
antialiased = clamp(antialiased, minColor, maxColor);
#line 132
antialiased = decodePalYuv(antialiased);
#line 134
return float4(antialiased,0);
}
#line 137
void Out(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
#line 140
const float2 XYoffset[6] = { float2( 0, +1 ), float2( 0, -1 ), float2(+1,  0 ), float2(-1,  0),float2(-1,  -1),float2(+1,  +1)};
#line 142
const float4 center_color = tex2D(BackBuffer, texcoord);
#line 144
float4 neighbor_sum = center_color;
#line 146
for (int i = 0; i < 6; i++)
{
float4 neighbor = tex2D(BackBuffer, texcoord + XYoffset[i] * float2((1.0 / 1920), (1.0 / 1018)) );
#line 150
const float3 color_diff = abs(neighbor.xyz - center_color.xyz);
#line 152
float3 ycc = encodePalYuv(color_diff.xyz);
#line 154
const float cbcr_threshhold = Seeking;
#line 156
const float cbcr_len = length(color_diff.yz);
#line 158
if (cbcr_threshhold < cbcr_len)
{
ycc = (cbcr_threshhold / cbcr_len) * ycc;
#line 162
neighbor.rgb = decodePalYuv(ycc);
}
#line 165
neighbor_sum += neighbor;
}
float4 FinColor = neighbor_sum / 7.0f;
#line 169
FinColor = length(abs(FinColor-center_color));
#line 171
const float Mask = 1-saturate(dot(FinColor,FinColor * 100)< 1);
#line 173
float4 Done;
if(!DebugOutput)
{
Done = lerp(center_color,tex2D(BackBufferTAA,texcoord),Mask);
}
else
{
Done = Mask.xxxx;
}
#line 183
color = Done;
}
#line 186
void Past_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 Past : SV_Target)
{
Past = tex2D(BackBuffer,texcoord);
}
#line 193
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 200
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 205
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
technique TAA
{
pass TAA
{
VertexShader = PostProcessVS;
PixelShader = TAA;
RenderTarget = TAABackBuffer;
}
pass Out
{
VertexShader = PostProcessVS;
PixelShader = Out;
}
pass PBB
{
VertexShader = PostProcessVS;
PixelShader = Past_BackBuffer;
RenderTarget = PastBackBuffer;
#line 226
}
}

