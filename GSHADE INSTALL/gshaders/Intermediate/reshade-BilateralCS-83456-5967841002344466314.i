#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\BilateralCS.fx"
#line 45
namespace Spatial_IIR_Bilateral
{
texture BackBuffer:COLOR;
texture Temp0 <Pooled = true;>{Width = 1920; Height = 1018; Format = RGB10A2;};
texture Temp1 <Pooled = true;>{Width = 1920 * 2; Height = 1018; Format = RGB10A2;};
#line 51
sampler sBackBuffer{Texture = BackBuffer;};
sampler sTemp0 {Texture = Temp0;};
sampler sTemp1{Texture = Temp1;};
#line 56
storage wTemp0{Texture = Temp0;};
storage wTemp1{Texture = Temp1;};
#line 59
uniform float Strength<
ui_type = "slider";
ui_label = "Strength";
ui_min = 0; ui_max = 2;
ui_step = 0.001;
> = 1;
#line 66
uniform bool Sharpen = false;
#line 68
uniform float WeightExponent<
ui_type = "slider";
ui_label = "Bilateral Width";
ui_tooltip = "Use this slider to adjust the width of the bilateral";
ui_min = 10; ui_max = 50;
> = 30;
#line 76
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 83
void Temp0PS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD, out float Temp0 : SV_Target0)
{
Temp0 = dot(tex2D(sBackBuffer, texcoord).rgb, float3(0.299, 0.587, 0.114));
}
#line 88
void CombinePS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD, out float4 output : SV_Target0)
{
texcoord.x /= 2;
output = (tex2D(sTemp1, texcoord) + tex2D(sTemp1, float2(texcoord.x + 0.5, texcoord.y))) * 0.5;
output.w = 1;
}
#line 95
void HorizontalFilterCS0(uint3 id : SV_DispatchThreadID)
{
if(id.x < (uint2((uint(((1920) + (128) - 1) / (128)) * 2), uint(((1018) + (64) - 1) / (64))).x / 2))
{
float2 coord = float2(id.x * 128, id.y);
float3 curr;
float3 prev;
float3 weight;
prev = tex2Dfetch(sBackBuffer, float2(coord.x - 32, coord.y)).xyz;
for(int i = -32 + 1; i < 128; i++)
{
curr = tex2Dfetch(sBackBuffer, float2(coord.x + i, coord.y)).xyz;
weight = 1 - abs(curr - prev);
weight = pow(abs(weight), WeightExponent);
prev = lerp(curr, prev, weight);
if(i >= 0  && (coord.x + i) < 1920)
{
tex2Dstore(wTemp1, int2(coord.x + i, coord.y), prev.xyzx);
}
}
}
else
{
float2 coord = float2((id.x - (uint2((uint(((1920) + (128) - 1) / (128)) * 2), uint(((1018) + (64) - 1) / (64))).x / 2)) * 128 + 128, id.y);
float3 curr;
float3 prev;
float3 weight;
prev = tex2Dfetch(sBackBuffer, float2(coord.x + 32, coord.y)).xyz;
for(int i = 32 - 1; i > -128; i--)
{
curr = tex2Dfetch(sBackBuffer, float2(coord.x + i, coord.y)).xyz;
weight = 1 - abs(curr - prev);
weight = pow(abs(weight), WeightExponent);
prev = lerp(curr, prev, weight);
if(i <= 0)
{
tex2Dstore(wTemp1, int2(1920 + coord.x + i, coord.y), prev.xyzx);
}
}
}
}
#line 137
void VerticalFilterCS0(uint3 id : SV_DispatchThreadID, uint3 tid : SV_GroupThreadID)
{
if(id.y < (uint2(uint(((1920) + (64) - 1) / (64)), (uint(((1018) + (128) - 1) / (128)) * 2)).y / 2))
{
float2 coord = float2(id.x, id.y * 128);
float3 curr;
float3 prev;
float3 weight;
prev = tex2Dfetch(sTemp0, float2(coord.x, coord.y - 32)).xyz;
if(coord.x < 1920)
{
for(int i = -32 + 1; i < 128; i++)
{
curr = tex2Dfetch(sTemp0, float2(coord.x, coord.y + i)).xyz;
weight = 1 - abs(curr - prev);
weight = pow(abs(weight), WeightExponent);
prev = lerp(curr, prev, weight);
if(i >= 0)
{
tex2Dstore(wTemp1, int2(coord.x, coord.y + i), float4(prev.xyz, 1));
}
}
}
}
else
{
float2 coord = float2(id.x, (id.y - (uint2(uint(((1920) + (64) - 1) / (64)), (uint(((1018) + (128) - 1) / (128)) * 2)).y / 2)) * 128 + 128);
float3 curr;
float3 prev;
float3 weight;
prev = tex2Dfetch(sTemp0, float2(coord.x, coord.y + 32)).xyz;
for(int i = 32 - 1; i > -128; i--)
{
curr = tex2Dfetch(sTemp0, float2(coord.x, coord.y + i)).xyz;
weight = 1 - abs(curr - prev);
weight = pow(abs(weight), WeightExponent);
prev = lerp(curr, prev, weight);
if(i <= 0)
{
tex2Dstore(wTemp1, int2(1920 + coord.x, coord.y + i), float4(prev.xyz, 1));
}
}
}
}
#line 182
void OutputPS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD, out float4 output : SV_TARGET0)
{
float3 color = tex2D(sBackBuffer, texcoord).rgb;
texcoord.x /= 2;
float3 blur = (tex2D(sTemp1, texcoord).rgb + tex2D(sTemp1, float2(texcoord.x + 0.5, texcoord.y)).rgb) * 0.5;
float alpha = (Sharpen) ? -Strength : Strength;
output.rgb = lerp(color, blur, alpha);
output.a = 1;
}
#line 192
technique BilateralCS <ui_tooltip = "A bilateral filter which can be used to soften or sharpen the texture components of an image.\n\n"
"Part of Insane Shaders\n"
"By: Lord of Lunacy";>
{
#line 197
pass
{
ComputeShader = HorizontalFilterCS0<uint2(1, 64).x, uint2(1, 64).y>;
DispatchSizeX = uint2((uint(((1920) + (128) - 1) / (128)) * 2), uint(((1018) + (64) - 1) / (64))).x;
DispatchSizeY = uint2((uint(((1920) + (128) - 1) / (128)) * 2), uint(((1018) + (64) - 1) / (64))).y;
}
#line 204
pass
{
VertexShader = PostProcessVS;
PixelShader = CombinePS;
RenderTarget0 = Temp0;
}
#line 211
pass
{
ComputeShader = VerticalFilterCS0<uint2(64, 1).x, uint2(64, 1).y>;
DispatchSizeX = uint2(uint(((1920) + (64) - 1) / (64)), (uint(((1018) + (128) - 1) / (128)) * 2)).x;
DispatchSizeY = uint2(uint(((1920) + (64) - 1) / (64)), (uint(((1018) + (128) - 1) / (128)) * 2)).y;
}
#line 219
pass
{
VertexShader = PostProcessVS;
PixelShader = OutputPS;
}
}
}

