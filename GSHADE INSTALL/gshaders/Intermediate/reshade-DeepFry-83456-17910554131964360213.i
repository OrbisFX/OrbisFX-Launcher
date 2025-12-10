#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\DeepFry.fx"
#line 22
static const float DCTCoefficents[64] = {1, 1, 1, 1, 1, 1, 1, 1,
0.980785, 0.83147, 0.55557, 0.19509, -0.19509, -0.55557, -0.83147, -0.980785,
0.92388, 0.382683, -0.382683, -0.92388, -0.92388, -0.382683, 0.382683, 0.92388,
0.83147, -0.19509, -0.980785, -0.55557, 0.55557, 0.980785, 0.19509, -0.83147,
0.707107, -0.707107, -0.707107, 0.707107, 0.707107, -0.707107, -0.707107, 0.707107,
0.55557, -0.980785, 0.19509, 0.83147, -0.83147, -0.19509, 0.980785, -0.55557,
0.382683, -0.92388, 0.92388, -0.382683, -0.382683, 0.92388, -0.92388, 0.382683,
0.19509, -0.55557, 0.83147, -0.980785, 0.980785, -0.83147, 0.55557, -0.19509};
#line 31
static const float LuminanceQuantization[64] = {16, 11, 10, 16, 24, 40, 51, 61,
12, 12, 14, 19, 26, 58, 60, 55,
14, 13, 16, 24, 40, 57, 69, 56,
14, 17, 22, 29, 51, 87, 80, 62,
18, 22, 37, 56, 68, 109, 103, 77,
24, 36, 55, 64, 81, 104, 113, 92,
49, 64, 78, 87, 103, 121, 120, 101,
72, 92, 95, 98, 112, 100, 103, 99};
#line 40
static const float ChrominanceQuantization[64] = {17, 18, 24, 47, 99, 99, 99, 99,
18, 21, 26, 66, 99, 99, 99, 99,
24, 26, 56, 99, 99, 99, 99, 99,
47, 66, 99, 99, 99, 99, 99, 99,
99, 99, 99, 99, 99, 99, 99, 99,
99, 99, 99, 99, 99, 99, 99, 99,
99, 99, 99, 99, 99, 99, 99, 99,
99, 99, 99, 99, 99, 99, 99, 99};
#line 50
uniform float Quality<
ui_type = "slider";
ui_min = 0.5; ui_max = 10;
> = 6;
#line 55
uniform float Reds
<
ui_type = "slider";
ui_min = 0; ui_max = 1;
> = 0.2;
#line 61
texture BackBuffer : COLOR;
sampler sBackBuffer {Texture = BackBuffer;};
#line 64
texture Image0 {Width = int((1920 + 7) / 8) * 8; Height = int((1018 + 7) / 8) * 8; Format = RGBA16f;};
texture Image1 {Width = int((1920 + 7) / 8) * 8; Height = int((1018 + 7) / 8) * 8; Format = RGBA16f;};
#line 67
sampler sImage0 {Texture = Image0;};
sampler sImage1 {Texture = Image1;};
#line 72
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 79
float3 DCT_Horizontal(sampler sTexture, float2 texcoord, bool isInverse)
{
const uint2 coord = uint2(texcoord * float2(int((1920 + 7) / 8) * 8, int((1018 + 7) / 8) * 8));
const uint index = coord.x % 8;
const uint offset = coord.x - index;
#line 85
float3 output = 0;
#line 87
for(uint i = 0; i < 8; i++)
{
uint xCoord = i;
float weight;
#line 92
if(isInverse)
{
weight = DCTCoefficents[xCoord * 8 + index];
weight *= (xCoord == 0) ? 0.707107 : 1;
}
else
{
weight = DCTCoefficents[index * 8 + xCoord];
}
#line 102
xCoord += offset;
float3 value = tex2Dfetch(sTexture, float2(xCoord, coord.y) + 0.5).xyz - 0.5; 
value *= weight;
output += value;
}
#line 108
if(!isInverse)
{
output *= (index == 0) ? 0.707107 : 1;
}
#line 113
output *= 0.5;
return output + 0.5;
}
#line 117
float3 DCT_Vertical(sampler sTexture, float2 texcoord, bool isInverse)
{
const uint2 coord = uint2(texcoord * float2(int((1920 + 7) / 8) * 8, int((1018 + 7) / 8) * 8));
const uint index = coord.y % 8;
const uint offset = coord.y - index;
#line 123
float3 output = 0;
#line 125
for(uint i = 0; i < 8; i++)
{
uint yCoord = (i) % 8;
float weight;
#line 130
if(isInverse)
{
weight = DCTCoefficents[yCoord * 8 + index];
weight *= (yCoord == 0) ? 0.707107 : 1;
}
else
{
weight = DCTCoefficents[index * 8 + yCoord];
}
#line 140
yCoord += offset;
float3 value = tex2Dfetch(sTexture, float2(coord.x, yCoord) + 0.5).xyz - 0.5; 
value *= weight;
output += value;
}
#line 146
if(!isInverse)
{
output *= (index == 0) ? 0.707107 : 1;
}
#line 151
output *= 0.5;
return output + 0.5;
}
#line 155
void ycbcrPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float3 output : SV_Target0)
{
const float3 color = tex2D(sBackBuffer, texcoord).rgb;
output.x = dot(color, float3(0.299, 0.587, 0.114));
output.y = dot(color, float3(-0.168736, -0.331264, 0.5)) + 0.5 - Reds;
output.z = dot(color, float3(0.5, -0.418688, -0.081312)) + 0.5 + Reds;
}
#line 163
void HorizontalPS0(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 output : SV_Target0)
{
output.xyz = DCT_Horizontal(sBackBuffer, texcoord, false);
output.w = 1;
}
#line 169
void VerticalPS0(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 output : SV_Target0)
{
output.xyz = DCT_Vertical(sImage0, texcoord, false);
output.w = 1;
output *= 255;
output += -128;
const uint2 coord = uint2(texcoord * float2(int((1920 + 7) / 8) * 8, int((1018 + 7) / 8) * 8));
const uint index = (coord.y % 8) * 8 + coord.x % 8;
const float3 quantization = float3(LuminanceQuantization[index], ChrominanceQuantization[index].xx) * Quality;
output.xyz = round(output.xyz * rcp(quantization));
output *= quantization;
output /= 255;
output += 0.5;
}
#line 184
void HorizontalPS1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 output : SV_Target0)
{
output.xyz = DCT_Horizontal(sImage1, texcoord, true);
output.w = 1;
}
#line 190
void VerticalPS1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 output : SV_Target0)
{
float3 color = DCT_Vertical(sImage0, texcoord, true);
color.yz -= 0.5;
output.x = dot(color, float3(1, 0, 1.402));
output.y = dot(color, float3(1, -0.344136, -0.714136));
output.z = dot(color, float3(1, 1.772, 0));
output.w = 1;
}
#line 200
technique DeepFry <ui_tooltip = "A simple shader that uses JPEG DCT quantization, \n"
"and turns up the reds in the image to create a \n"
"deep fried meme effect.\n\n"
"Part of Insane Shaders\n"
"By: Lord of Lunacy";>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = ycbcrPS;
}
#line 212
pass
{
VertexShader = PostProcessVS;
PixelShader = HorizontalPS0;
#line 217
RenderTarget = Image0;
}
#line 220
pass
{
VertexShader = PostProcessVS;
PixelShader = VerticalPS0;
#line 225
RenderTarget = Image1;
}
#line 228
pass
{
VertexShader = PostProcessVS;
PixelShader = HorizontalPS1;
RenderTarget = Image0;
}
#line 235
pass
{
VertexShader = PostProcessVS;
PixelShader = VerticalPS1;
}
}

