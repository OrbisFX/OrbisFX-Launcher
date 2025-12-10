#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_FLOYDSTEINBERG.fx"
#line 58
texture ColorInputTex : COLOR;
sampler ColorInput 	{ Texture = ColorInputTex;  };
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods\mmx_global.fxh"
#line 47
static const float2 BUFFER_PIXEL_SIZE = float2((1.0 / 1920), (1.0 / 1018));
static const uint2 BUFFER_SCREEN_SIZE = uint2(1920, 1018);
static const float2 BUFFER_ASPECT_RATIO = float2(1.0, 1920 * (1.0 / 1018));
#line 81
static const float2 BUFFER_PIXEL_SIZE_DLSS   = float2((1.0 / 1920), (1.0 / 1018));
static const uint2 BUFFER_SCREEN_SIZE_DLSS   = uint2(1920, 1018);
static const float2 BUFFER_ASPECT_RATIO_DLSS = float2(1.0, 1920 * (1.0 / 1018));
#line 85
void FullscreenTriangleVS(in uint id : SV_VertexID, out float4 vpos : SV_Position, out float2 uv : TEXCOORD)
{
uv = id.xx == uint2(2, 1) ? 2.0.xx : 0.0.xx;
vpos = float4(uv * float2(2, -2) + float2(-1, 1), 0, 1);
}
#line 91
struct PSOUT1
{
float4 t0 : SV_Target0;
};
struct PSOUT2
{
float4 t0 : SV_Target0,
t1 : SV_Target1;
};
struct PSOUT3
{
float4 t0 : SV_Target0,
t1 : SV_Target1,
t2 : SV_Target2;
};
struct PSOUT4
{
float4 t0 : SV_Target0,
t1 : SV_Target1,
t2 : SV_Target2,
t3 : SV_Target3;
};
#line 132
float max3(float a, float b, float c){ return max(max(a, b), c);}float2 max3(float2 a, float2 b, float2 c){ return max(max(a, b), c);}float3 max3(float3 a, float3 b, float3 c){ return max(max(a, b), c);}float4 max3(float4 a, float4 b, float4 c){ return max(max(a, b), c);}int max3(int a, int b, int c){ return max(max(a, b), c);}int2 max3(int2 a, int2 b, int2 c){ return max(max(a, b), c);}int3 max3(int3 a, int3 b, int3 c){ return max(max(a, b), c);}int4 max3(int4 a, int4 b, int4 c){ return max(max(a, b), c);}
float max4(float a, float b, float c, float d){ return max(max(a, b), max(c, d));}float2 max4(float2 a, float2 b, float2 c, float2 d){ return max(max(a, b), max(c, d));}float3 max4(float3 a, float3 b, float3 c, float3 d){ return max(max(a, b), max(c, d));}float4 max4(float4 a, float4 b, float4 c, float4 d){ return max(max(a, b), max(c, d));}int max4(int a, int b, int c, int d){ return max(max(a, b), max(c, d));}int2 max4(int2 a, int2 b, int2 c, int2 d){ return max(max(a, b), max(c, d));}int3 max4(int3 a, int3 b, int3 c, int3 d){ return max(max(a, b), max(c, d));}int4 max4(int4 a, int4 b, int4 c, int4 d){ return max(max(a, b), max(c, d));}
float min3(float a, float b, float c){ return min(min(a, b), c);}float2 min3(float2 a, float2 b, float2 c){ return min(min(a, b), c);}float3 min3(float3 a, float3 b, float3 c){ return min(min(a, b), c);}float4 min3(float4 a, float4 b, float4 c){ return min(min(a, b), c);}int min3(int a, int b, int c){ return min(min(a, b), c);}int2 min3(int2 a, int2 b, int2 c){ return min(min(a, b), c);}int3 min3(int3 a, int3 b, int3 c){ return min(min(a, b), c);}int4 min3(int4 a, int4 b, int4 c){ return min(min(a, b), c);}
float min4(float a, float b, float c, float d){ return min(min(a, b), min(c, d));}float2 min4(float2 a, float2 b, float2 c, float2 d){ return min(min(a, b), min(c, d));}float3 min4(float3 a, float3 b, float3 c, float3 d){ return min(min(a, b), min(c, d));}float4 min4(float4 a, float4 b, float4 c, float4 d){ return min(min(a, b), min(c, d));}int min4(int a, int b, int c, int d){ return min(min(a, b), min(c, d));}int2 min4(int2 a, int2 b, int2 c, int2 d){ return min(min(a, b), min(c, d));}int3 min4(int3 a, int3 b, int3 c, int3 d){ return min(min(a, b), min(c, d));}int4 min4(int4 a, int4 b, int4 c, int4 d){ return min(min(a, b), min(c, d));}
float med3(float a, float b, float c) { return clamp(a, min(b, c), max(b, c));}int med3(int a, int b, int c) { return clamp(a, min(b, c), max(b, c));}
#line 144
float maxc(float  t) {return t;}
float maxc(float2 t) {return max(t.x, t.y);}
float maxc(float3 t) {return max3(t.x, t.y, t.z);}
float maxc(float4 t) {return max4(t.x, t.y, t.z, t.w);}
float minc(float  t) {return t;}
float minc(float2 t) {return min(t.x, t.y);}
float minc(float3 t) {return min3(t.x, t.y, t.z);}
float minc(float4 t) {return min4(t.x, t.y, t.z, t.w);}
float medc(float3 t) {return med3(t.x, t.y, t.z);}
#line 154
float4 tex2Dlod(sampler s, float2 uv, float mip)
{
return tex2Dlod(s, float4(uv, 0, mip));
}
#line 62 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_FLOYDSTEINBERG.fx"
#line 63
struct VSOUT
{
float4                  vpos        : SV_Position;
float2                  uv          : TEXCOORD0;
};
#line 69
texture ColorMapU { Width = 1920;   Height = 1018;   Format = R32I; };
sampler<int> sColorMapU { Texture = ColorMapU; };
storage<int> stColorMapU { Texture = ColorMapU; };
#line 73
texture ColorMapOut { Width = 1920;   Height = 1018;   Format = R32I; };
sampler<int> sColorMapOut { Texture = ColorMapOut; };
storage<int> stColorMapOut { Texture = ColorMapOut; };
#line 77
struct CSIN
{
uint3 groupthreadid     : SV_GroupThreadID;         
uint3 groupid           : SV_GroupID;               
uint3 dispatchthreadid  : SV_DispatchThreadID;      
uint threadid           : SV_GroupIndex;            
};
#line 89
float2 pixel_idx_to_uv(uint2 pos, float2 texture_size)
{
float2 inv_texture_size = rcp(texture_size);
return pos * inv_texture_size + 0.5 * inv_texture_size;
}
#line 95
bool check_boundaries(uint2 pos, uint2 dest_size)
{
return all(pos < dest_size) && all(pos >= uint2(0, 0));
}
#line 104
VSOUT MainVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv); 
return o;
}
#line 111
void ToGreyCS(in CSIN i)
{
if(!check_boundaries(i.dispatchthreadid.xy, BUFFER_SCREEN_SIZE))
return;
float3 c = tex2Dlod(ColorInput, pixel_idx_to_uv(i.dispatchthreadid.xy, BUFFER_SCREEN_SIZE), 0).rgb;
c = c*0.283799*((2.52405+c)*c);
float greyv = dot(float3(0.2125, 0.7154, 0.0721), c);
#line 119
int igrey = int(greyv  * 255.99);
tex2Dstore(stColorMapU, i.dispatchthreadid.xy, igrey);
}
#line 124
groupshared int4 diffused_errors[1024];
#line 127
groupshared int diffused_errors_packed[1024];
#line 129
int4 unpack_errors(int _packed)
{
int4 unpacked;
unpacked.x = (_packed >> 24) & 0xFF; 
unpacked.y = (_packed >> 16) & 0xFF; 
unpacked.z = (_packed >> 8) & 0xFF;  
unpacked.w = _packed & 0xFF;         
return unpacked - 127;
}
#line 139
int pack_errors(int4 errors)
{
#line 142
return (errors.x + 127) << 24 | (errors.y + 127) << 16 | (errors.z + 127) << 8 | (errors.w + 127);
}
#line 145
void FloydSteinbergCS(in CSIN i)
{
[loop]
for(int stripe_id = 0; stripe_id <= 1018 / 1024; stripe_id++)
{
#line 151
diffused_errors_packed[i.threadid] = 0x7F7F7F7F;
barrier();
#line 154
int2 launch_pos;
launch_pos.y = stripe_id * 1024 + i.threadid;
launch_pos.x = -2 * i.threadid;  
#line 158
[loop]
for(int j = 0; j < 1920 + 1024 * 2; j++)
{
int error = 0;
bool in_working_area = launch_pos.x >= 0 && launch_pos.y < 1018;
#line 164
[branch]
if(in_working_area)
{
int4 next_errors = unpack_errors(diffused_errors_packed[i.threadid]);
int grey = tex2Dfetch(stColorMapU, launch_pos.xy).x + next_errors.x;
int rounded = grey > 127 ? 255 : 0;
error = grey - rounded;
#line 172
tex2Dstore(stColorMapOut, launch_pos.xy, rounded); 
#line 174
diffused_errors_packed[i.threadid] = pack_errors(int4(next_errors.y + (error * 7) / 16, next_errors.zw, 0));
}
#line 177
barrier();
#line 179
[branch]
if(in_working_area)
{
[branch]
if(i.threadid == (1024 - 1))
{
atomicAdd(stColorMapU, launch_pos.xy + int2(-1, 1), (error * 3) / 16);
atomicAdd(stColorMapU, launch_pos.xy + int2(0, 1),  (error * 5) / 16);
atomicAdd(stColorMapU, launch_pos.xy + int2(1, 1),  (error * 1) / 16);
}
else
{
int addpacked = ((error * 3) / 16)  << 24 | (((error * 5) / 16) << 16) | (((error * 1) / 16) << 8) | 0;
atomicAdd(diffused_errors_packed[i.threadid + 1], addpacked);
#line 197
}
#line 199
}
barrier();
launch_pos.x++;
}
}
}
#line 206
void MainPS(in VSOUT i, out float4 o : SV_Target0)
{
o = tex2D(sColorMapOut, i.uv).x / 255.0;
}
#line 215
technique MartysMods_FloydSteinbergDither
{
pass
{
ComputeShader = ToGreyCS<32, 32>;
DispatchSizeX = ((((1920) - 1) / (32)) + 1);
DispatchSizeY = ((((1018) - 1) / (32)) + 1);
}
pass
{
ComputeShader = FloydSteinbergCS<1, 1024>;
DispatchSizeX = 1;
DispatchSizeY = 1;
}
pass
{
VertexShader = MainVS;
PixelShader  = MainPS;
}
}

