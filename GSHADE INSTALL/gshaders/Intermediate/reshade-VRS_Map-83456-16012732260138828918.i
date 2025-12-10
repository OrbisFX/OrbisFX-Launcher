// VRS_MAP=1
// VRS_USE_OPTICAL_FLOW=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\VRS_Map.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\VRS_Map.fxh"
#line 139
uniform int VRS_FrameCount < source = "framecount";>;
#line 151
texture VRS {Width = (uint2((uint(uint(1920 + 8 - 1) / uint(8))), (uint(uint(1018 + 8 - 1) / uint(8))))).x; Height = (uint2((uint(uint(1920 + 8 - 1) / uint(8))), (uint(uint(1018 + 8 - 1) / uint(8))))).y; Format = RGBA8;};
texture VRSUpdated {Width = 1; Height = 1; Format = R32f;};
#line 154
sampler sVRS {Texture = VRS;};
sampler sVRSUpdated {Texture = VRSUpdated;};
#line 158
static const uint VRS_RATE1D_1X = 0x0;
static const uint VRS_RATE1D_2X = 0x1;
static const uint VRS_RATE1D_4X = 0x2;
#line 163
static const uint VRS_RATE_1X1 = ((VRS_RATE1D_1X << 2) | (VRS_RATE1D_1X)); 
static const uint VRS_RATE_1X2 = ((VRS_RATE1D_1X << 2) | (VRS_RATE1D_2X)); 
static const uint VRS_RATE_2X1 = ((VRS_RATE1D_2X << 2) | (VRS_RATE1D_1X)); 
static const uint VRS_RATE_2X2 = ((VRS_RATE1D_2X << 2) | (VRS_RATE1D_2X)); 
#line 168
static const uint VRS_RATE_2X4 = ((VRS_RATE1D_2X << 2) | (VRS_RATE1D_4X)); 
static const uint VRS_RATE_4X2 = ((VRS_RATE1D_4X << 2) | (VRS_RATE1D_2X)); 
static const uint VRS_RATE_4X4 = ((VRS_RATE1D_4X << 2) | (VRS_RATE1D_4X)); 
#line 172
namespace VRS_Map
{
#line 175
uint ShadingRate(float2 texcoord, bool UseVRS)
{
if(!(bool((int((asint(tex2Dfetch(sVRSUpdated, int2(0, 0)).x))) == VRS_FrameCount) || (int((asint(tex2Dfetch(sVRSUpdated, int2(0, 0)).x))) == (VRS_FrameCount - 1)))) || !UseVRS)
{
return 0;
}
else
{
return uint(tex2Dfetch(sVRS, int2(texcoord * (uint2((uint(uint(1920 + 8 - 1) / uint(8))), (uint(uint(1018 + 8 - 1) / uint(8))))))).w * 255);
}
}
#line 189
uint ShadingRate(float2 texcoord, float VarianceCutoff, bool UseVRS)
{
if(!(bool((int((asint(tex2Dfetch(sVRSUpdated, int2(0, 0)).x))) == VRS_FrameCount) || (int((asint(tex2Dfetch(sVRSUpdated, int2(0, 0)).x))) == (VRS_FrameCount - 1)))) || !UseVRS)
{
return 0;
}
else
{
float3 variances = (tex2Dfetch(sVRS, int2(texcoord * (uint2((uint(uint(1920 + 8 - 1) / uint(8))), (uint(uint(1018 + 8 - 1) / uint(8))))))).xyz / 4);
float varH = variances.x;
float varV = variances.y;
float var = variances.z;
uint shadingRate = ((VRS_RATE1D_1X << 2) | (VRS_RATE1D_1X));
#line 203
if (var < VarianceCutoff)
{
shadingRate = ((VRS_RATE1D_2X << 2) | (VRS_RATE1D_2X));
}
else
{
if (varH > varV)
{
shadingRate = ((VRS_RATE1D_1X << 2) | ((varV > VarianceCutoff) ? VRS_RATE1D_1X : VRS_RATE1D_2X));
}
else
{
shadingRate = (((varH > VarianceCutoff) ? VRS_RATE1D_1X : VRS_RATE1D_2X << 2) | (VRS_RATE1D_1X));
}
}
return shadingRate;
}
}
#line 224
uint ShadingRate(float2 texcoord, bool UseVRS, uint offRate)
{
if(!(bool((int((asint(tex2Dfetch(sVRSUpdated, int2(0, 0)).x))) == VRS_FrameCount) || (int((asint(tex2Dfetch(sVRSUpdated, int2(0, 0)).x))) == (VRS_FrameCount - 1)))) || !UseVRS)
{
return offRate;
}
else
{
return uint(tex2Dfetch(sVRS, int2(texcoord * (uint2((uint(uint(1920 + 8 - 1) / uint(8))), (uint(uint(1018 + 8 - 1) / uint(8))))))).w * 255);
}
}
#line 239
uint ShadingRate(float2 texcoord, float VarianceCutoff, bool UseVRS, uint offRate)
{
if(!(bool((int((asint(tex2Dfetch(sVRSUpdated, int2(0, 0)).x))) == VRS_FrameCount) || (int((asint(tex2Dfetch(sVRSUpdated, int2(0, 0)).x))) == (VRS_FrameCount - 1)))) || !UseVRS)
{
return offRate;
}
else
{
float3 variances = (tex2Dfetch(sVRS, int2(texcoord * (uint2((uint(uint(1920 + 8 - 1) / uint(8))), (uint(uint(1018 + 8 - 1) / uint(8))))))).xyz / 4);
float varH = variances.x;
float varV = variances.y;
float var = variances.z;
uint shadingRate = ((VRS_RATE1D_1X << 2) | (VRS_RATE1D_1X));
#line 253
if (var < VarianceCutoff)
{
shadingRate = ((VRS_RATE1D_2X << 2) | (VRS_RATE1D_2X));
}
else
{
if (varH > varV)
{
shadingRate = ((VRS_RATE1D_1X << 2) | ((varV > VarianceCutoff) ? VRS_RATE1D_1X : VRS_RATE1D_2X));
}
else
{
shadingRate = (((varH > VarianceCutoff) ? VRS_RATE1D_1X : VRS_RATE1D_2X << 2) | (VRS_RATE1D_1X));
}
}
return shadingRate;
}
}
float3 DebugImage(float3 originalImage, float2 texcoord, float VarianceCutoff, bool DebugView)
{
if(DebugView)
{
#line 276
float3 color = float3(1, 1, 1);
#line 278
switch (ShadingRate(texcoord, VarianceCutoff, true))
{
case VRS_RATE_1X1:
color = float3(0.5, 0.0, 0.0);
break;
case VRS_RATE_1X2:
color = float3(0.5, 0.5, 0.0);
break;
case VRS_RATE_2X1:
color = float3(0.5, 0.25, 0.0);
break;
case VRS_RATE_2X2:
color = float3(0.0, 0.5, 0.0);
break;
case VRS_RATE_2X4:
color = float3(0.25, 0.25, 0.5);
break;
case VRS_RATE_4X2:
color = float3(0.5, 0.25, 0.5);
break;
case VRS_RATE_4X4:
color = float3(0.0, 0.5, 0.5);
break;
}
#line 303
color = lerp(color, originalImage, 0.35);
int2 grid = uint2(texcoord.xy * float2(1920, 1018)) % 8;
bool border = (grid.x == 0) || (grid.y == 0);
return color * (border ? 0.5f : 1.0f);
}
else
{
return originalImage;
}
}
}
#line 354
 
#line 58 "C:\Program Files\GShade\gshade-shaders\ComputeShaders\VRS_Map.fx"
#line 78
texture BackBuffer : COLOR;
#line 80
sampler sBackBuffer {Texture = BackBuffer;};
#line 82
storage wVRS {Texture = VRS;};
storage wVRSUpdated {Texture = VRSUpdated;};
#line 85
static const int2 g_Resolution = int2(1920, 1018);
static const uint g_TileSize = 8;
uniform float g_VarianceCutoff<
ui_type = "slider";
ui_label = "Variance Cutoff";
ui_tooltip = "Maximum luminance variance acceptable to accept reduced shading rate";
ui_min = 0; ui_max = 0.1;
ui_step = 0.001;
> = 0.05;
#line 115
static const float g_MotionFactor = 0;
#line 118
uniform bool ShowOverlay <
ui_label = "Show Overlay";
> = 1;
#line 124
float   VRS_ReadLuminance(int2 pos)
{
return dot(tex2Dfetch(sBackBuffer, pos).rgb, float3(0.299, 0.587, 0.114));
}
#line 149
float2  VRS_ReadMotionVec2D(int2 pos)
{
return float2(0, 0);
}
#line 154
void    VRS_WriteVrsImage(int2 pos, uint value)
{
tex2Dstore(wVRS, pos, float4(float(value)/255, 0, 0, 0));
}
#line 159
static const uint VRS_ThreadCount1D = 8;
static const uint VRS_NumBlocks1D = 2;
#line 162
static const uint VRS_SampleCount1D = VRS_ThreadCount1D + 2;
#line 164
groupshared uint VRS_LdsGroupReduce;
#line 166
static const uint VRS_ThreadCount = VRS_ThreadCount1D * VRS_ThreadCount1D;
static const uint VRS_SampleCount = VRS_SampleCount1D * VRS_SampleCount1D;
static const uint VRS_NumBlocks = VRS_NumBlocks1D * VRS_NumBlocks1D;
#line 170
groupshared float3 VRS_LdsVariance[VRS_SampleCount];
groupshared float VRS_LdsMin[VRS_SampleCount];
groupshared float VRS_LdsMax[VRS_SampleCount];
#line 174
float VRS_GetLuminance(int2 pos)
{
return VRS_ReadLuminance(pos);
}
#line 179
int VRS_FlattenLdsOffset(int2 coord)
{
coord += 1;
return coord.y * VRS_SampleCount1D + coord.x;
}
#line 185
groupshared uint4 diffX;
groupshared uint4 diffY;
groupshared uint4 diffZ;
#line 189
int floatToOrderedInt( float floatVal ) {
int intVal = asint( floatVal );
return (intVal >= 0 ) ? intVal : intVal ^ 0x7FFFFFFF;
}
#line 194
float orderedIntToFloat( int intVal ) {
return asfloat( (intVal >= 0) ? intVal : intVal ^ 0x7FFFFFFF);
}
#line 201
void VRS_GenerateVrsImage(uint3 id : SV_DispatchThreadID, uint3 Gtid : SV_GroupThreadID)
{
uint3 Gid = uint3(id.x / 8, id.y / 8, 0);
int2 tileOffset = Gid.xy * VRS_ThreadCount1D * 2;
int2 baseOffset = tileOffset + int2(-2, -2);
uint Gidx = Gtid.y * 8 + Gtid.x;
uint index = Gidx;
if(all(id.xy == 0))
{
tex2Dstore(wVRSUpdated, Gtid.xy, float4(asfloat(VRS_FrameCount), 0, 0, 0));
}
#line 214
while (index < VRS_SampleCount)
{
int2 index2D = 2 * int2(index % VRS_SampleCount1D, index / VRS_SampleCount1D);
float4 lum = 0;
lum.x = VRS_GetLuminance(baseOffset + index2D + int2(0, 0));
lum.y = VRS_GetLuminance(baseOffset + index2D + int2(1, 0));
lum.z = VRS_GetLuminance(baseOffset + index2D + int2(0, 1));
lum.w = VRS_GetLuminance(baseOffset + index2D + int2(1, 1));
#line 224
float3 delta;
delta.x = max(abs(lum.x - lum.y), abs(lum.z - lum.w));
delta.y = max(abs(lum.x - lum.z), abs(lum.y - lum.w));
float2 minmax = float2(min(min(min(lum.x, lum.y), lum.z), lum.w), max(max(max(lum.x, lum.y), lum.z), lum.w));
delta.z = minmax.y - minmax.x;
#line 231
float v = length(VRS_ReadMotionVec2D(baseOffset + index2D));
v *= g_MotionFactor;
delta -= v;
minmax.y -= v;
#line 237
VRS_LdsVariance[index] = delta;
VRS_LdsMin[index] = minmax.x;
VRS_LdsMax[index] = minmax.y;
#line 241
index += VRS_ThreadCount;
}
#line 244
if(Gtid.x == 0 && Gtid.y == 0)
{
diffX = 0;
diffY = 0;
diffZ = 0;
}
barrier();
#line 253
int2 threadUV = Gtid.xy;
#line 256
float3 delta = VRS_LdsVariance[VRS_FlattenLdsOffset(threadUV + int2(0, 0))];
#line 259
float minNeighbour = VRS_LdsMin[VRS_FlattenLdsOffset(threadUV + int2(0, -1))];
minNeighbour = min(minNeighbour, VRS_LdsMin[VRS_FlattenLdsOffset(threadUV + int2(-1, 0))]);
minNeighbour = min(minNeighbour, VRS_LdsMin[VRS_FlattenLdsOffset(threadUV + int2(0, 1))]);
minNeighbour = min(minNeighbour, VRS_LdsMin[VRS_FlattenLdsOffset(threadUV + int2(1, 0))]);
float dMin = max(0, VRS_LdsMin[VRS_FlattenLdsOffset(threadUV + int2(0, 0))] - minNeighbour);
#line 266
float maxNeighbour = VRS_LdsMax[VRS_FlattenLdsOffset(threadUV + int2(0, -1))];
maxNeighbour = max(maxNeighbour, VRS_LdsMax[VRS_FlattenLdsOffset(threadUV + int2(-1, 0))]);
maxNeighbour = max(maxNeighbour, VRS_LdsMax[VRS_FlattenLdsOffset(threadUV + int2(0, 1))]);
maxNeighbour = max(maxNeighbour, VRS_LdsMax[VRS_FlattenLdsOffset(threadUV + int2(1, 0))]);
float dMax = max(0, maxNeighbour - VRS_LdsMax[VRS_FlattenLdsOffset(threadUV + int2(0, 0))]);
#line 273
delta = max(0, delta + dMin + dMax);
#line 276
uint idx = (Gtid.y & (VRS_NumBlocks1D - 1)) * VRS_NumBlocks1D + (Gtid.x & (VRS_NumBlocks1D - 1));
atomicMax(diffX[idx], floatToOrderedInt(delta.x));
atomicMax(diffY[idx], floatToOrderedInt(delta.y));
atomicMax(diffZ[idx], floatToOrderedInt(delta.z));
#line 283
if (Gidx < VRS_NumBlocks)
{
float varH = orderedIntToFloat(diffX[Gidx]);
float varV = orderedIntToFloat(diffY[Gidx]);
float var = orderedIntToFloat(diffZ[Gidx]);;
uint shadingRate = ((VRS_RATE1D_1X << 2) | (VRS_RATE1D_1X));
#line 290
if (var < g_VarianceCutoff)
{
shadingRate = ((VRS_RATE1D_2X << 2) | (VRS_RATE1D_2X));
}
else
{
if (varH > varV)
{
shadingRate = ((VRS_RATE1D_1X << 2) | ((varV > g_VarianceCutoff) ? VRS_RATE1D_1X : VRS_RATE1D_2X));
}
else
{
shadingRate = (((varH > g_VarianceCutoff) ? VRS_RATE1D_1X : VRS_RATE1D_2X << 2) | (VRS_RATE1D_1X));
}
}
#line 307
tex2Dstore(wVRS, Gid.xy* VRS_NumBlocks1D + uint2(Gidx / VRS_NumBlocks1D, Gidx % VRS_NumBlocks1D), float4(float3(varH, varV, var) * 4, float(shadingRate) / 255));
}
}
#line 311
struct VERTEX_OUT
{
float4 vPosition : SV_POSITION;
float2 texcoord : TEXCOORD;
};
#line 317
VERTEX_OUT mainVS(uint id : SV_VertexID)
{
VERTEX_OUT output;
output.vPosition = float4(float2(id & 1, id >> 1) * float2(4, -4) + float2(-1, 1), 0, 1);
output.texcoord = float2(0, 0);
return output;
}
#line 325
float3 mainPS(VERTEX_OUT input) : SV_Target
{
if(!ShowOverlay) discard;
float2 texcoord = input.vPosition.xy * float2((1.0 / 1920), (1.0 / 1018));
float3 originalImage = tex2Dfetch(sBackBuffer, input.vPosition.xy).rgb;
return VRS_Map::DebugImage(originalImage, texcoord, g_VarianceCutoff, ShowOverlay);
}
#line 333
technique VariableRateShading
{
pass
{
ComputeShader = VRS_GenerateVrsImage<8, 8>;
DispatchSizeX = (uint2((uint(uint((uint2((uint(uint(1920 + 8 - 1) / uint(8))), (uint(uint(1018 + 8 - 1) / uint(8))))).x + 2 - 1) / uint(2))), (uint(uint((uint2((uint(uint(1920 + 8 - 1) / uint(8))), (uint(uint(1018 + 8 - 1) / uint(8))))).y + 2 - 1) / uint(2))))).x;
DispatchSizeY = (uint2((uint(uint((uint2((uint(uint(1920 + 8 - 1) / uint(8))), (uint(uint(1018 + 8 - 1) / uint(8))))).x + 2 - 1) / uint(2))), (uint(uint((uint2((uint(uint(1920 + 8 - 1) / uint(8))), (uint(uint(1018 + 8 - 1) / uint(8))))).y + 2 - 1) / uint(2))))).y;
}
pass
{
VertexShader = mainVS;
PixelShader = mainPS;
}
}

