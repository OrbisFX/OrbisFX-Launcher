// SMAA_USE_EXTENDED_EDGE_DETECTION=0
#line 1 "unknown"

#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_SMAA.fx"
#line 75
uniform int EDGE_DETECTION_MODE <
ui_type = "combo";
ui_items = "Luminance edge detection\0Color edge detection (max)\0Color edge detection (weighted)\0Depth edge detection\0";
ui_label = "Edge Detection Type";
> = 1;
#line 81
uniform float SMAA_THRESHOLD <
ui_type = "drag";
ui_min = 0.05; ui_max = 0.20; ui_step = 0.001;
ui_tooltip = "Edge detection threshold. If SMAA misses some edges try lowering this slightly.";
ui_label = "Edge Detection Threshold";
> = 0.10;
#line 88
uniform float SMAA_DEPTH_THRESHOLD <
ui_type = "drag";
ui_min = 0.001; ui_max = 0.10; ui_step = 0.001;
ui_tooltip = "Depth Edge detection threshold. If SMAA misses some edges try lowering this slightly.";
ui_label = "Depth Edge Detection Threshold";
> = 0.01;
#line 95
uniform int SMAA_MAX_SEARCH_STEPS <
ui_type = "slider";
ui_min = 0; ui_max = 112;
ui_label = "Max Search Steps";
ui_tooltip = "Determines the radius SMAA will search for aliased edges.";
> = 32;
#line 102
uniform int SMAA_MAX_SEARCH_STEPS_DIAG <
ui_type = "slider";
ui_min = 0; ui_max = 25;
ui_label = "Max Search Steps Diagonal";
ui_tooltip = "Determines the radius SMAA will search for diagonal aliased edges";
> = 16;
#line 109
uniform int SMAA_CORNER_ROUNDING <
ui_type = "slider";
ui_min = 0; ui_max = 100;
ui_label = "Corner Rounding";
ui_tooltip = "Determines the percent of anti-aliasing to apply to corners.";
> = 25;
#line 116
uniform bool SMAA_PREDICATION <
ui_label = "Enable Predicated Thresholding";
> = false;
#line 120
uniform float SMAA_PREDICATION_THRESHOLD <
ui_type = "drag";
ui_min = 0.005; ui_max = 1.00; ui_step = 0.01;
ui_tooltip = "Threshold to be used in the additional predication buffer.";
ui_label = "Predication Threshold";
> = 0.01;
#line 127
uniform float SMAA_PREDICATION_SCALE <
ui_type = "slider";
ui_min = 1; ui_max = 8;
ui_tooltip = "How much to scale the global threshold used for luma or color edge.";
ui_label = "Predication Scale";
> = 2.0;
#line 134
uniform float SMAA_PREDICATION_STRENGTH <
ui_type = "slider";
ui_min = 0; ui_max = 4;
ui_tooltip = "How much to locally decrease the threshold.";
ui_label = "Predication Strength";
> = 0.4;
#line 141
uniform int DebugOutput <
ui_type = "combo";
ui_items = "None\0View edges\0View weights\0";
ui_label = "Debug Output";
> = false;
#line 175
texture ColorInputTex : COLOR;
texture DepthInputTex : DEPTH;
sampler DepthInput  { Texture = DepthInputTex; };
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_global.fxh"
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
#line 180 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_SMAA.fx"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_depth.fxh"
#line 56
namespace Depth
{
#line 82
float linearize(float x) { x *= 1; x = x; x = x; x /= 1000.0 - x * (1000.0 - 1.0); return saturate(x); }
float2 linearize(float2 x) { x *= 1; x = x; x = x; x /= 1000.0 - x * (1000.0 - 1.0); return saturate(x); }
float3 linearize(float3 x) { x *= 1; x = x; x = x; x /= 1000.0 - x * (1000.0 - 1.0); return saturate(x); }
float4 linearize(float4 x) { x *= 1; x = x; x = x; x /= 1000.0 - x * (1000.0 - 1.0); return saturate(x); }
#line 87
float2 correct_uv(float2 uv)
{
#line 92
uv *= rcp(float2(1, 1));
#line 96
uv.x -= 0 / 2.000000001;
#line 101
uv.y += 0 / 2.000000001;
#line 103
return uv;
}
#line 106
float get_depth(float2 uv)
{
return tex2Dlod(DepthInput, float4(correct_uv(uv), 0, 0)).x;
}
#line 111
float get_linear_depth(float2 uv)
{
float depth = get_depth(uv);
depth = linearize(depth);
return depth;
}
#line 118
} 
#line 181 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_SMAA.fx"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_math.fxh"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_global.fxh"
#line 21 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_math.fxh"
#line 22
static const float PI      = 3.1415926535;
static const float HALF_PI = 1.5707963268;
static const float TAU     = 6.2831853072;
#line 26
static const float FLOAT32MAX = 3.402823466e+38f;
static const float FLOAT16MAX = 65504.0;
#line 31
namespace Math
{
#line 38
float fast_sign(float x){return x >= 0.0 ? 1.0 : -1.0;}
float2 fast_sign(float2 x){return x >= 0.0.xx ? 1.0.xx : -1.0.xx;}
float3 fast_sign(float3 x){return x >= 0.0.xxx ? 1.0.xxx : -1.0.xxx;}
float4 fast_sign(float4 x){return x >= 0.0.xxxx ? 1.0.xxxx : -1.0.xxxx;}
#line 43
float fast_acos(float x)
{
float o = -0.156583 * abs(x) + HALF_PI;
o *= sqrt(1.0 - abs(x));
return x >= 0.0 ? o : PI - o;
}
#line 50
float2 fast_acos(float2 x)
{
float2 o = -0.156583 * abs(x) + HALF_PI;
o *= sqrt(1.0 - abs(x));
return x >= 0.0.xx ? o : PI - o;
}
#line 61
float4 get_rotator(float phi)
{
float2 t;
sincos(phi, t.x, t.y);
return float4(t.yx, -t.x, t.y);
}
#line 68
float4 merge_rotators(float4 ra, float4 rb)
{
return ra.xyxy * rb.xxzz + ra.zwzw * rb.yyww;
}
#line 73
float2 rotate_2D(float2 v, float4 r)
{
return float2(dot(v, r.xy), dot(v, r.zw));
}
#line 78
float3x3 get_rotation_matrix(float3 axis, float angle)
{
#line 81
float s, c; sincos(angle, s, c);
float3x3 m = float3x3((1 - c) * axis.xxx * axis.xyz + float3(c, -s * axis.z, s * axis.y),
(1 - c) * axis.xyy * axis.yyz + float3(s * axis.z, c, -s * axis.x),
(1 - c) * axis.xyz * axis.zzz + float3(-s * axis.y, s * axis.x, c));
return m;
}
#line 88
float3x3 base_from_vector(float3 n)
{
#line 91
float2 nz = -n.xy / (1.0 + abs(n.z));
float3 t = float3(1.0 + n.x*nz.x, n.x*nz.y, -n.x);
float3 b = float3(1.0 + n.y*nz.y, n.x*nz.y, -n.y);
#line 95
t.z  = n.z >= 0.5 ? t.z : -t.z;
b.xy = n.z >= 0.5 ? b.yx : -b.yx;
return float3x3(t, b, n);
}
#line 100
float3 aabb_clip(float3 p, float3 mincorner, float3 maxcorner)
{
float3 center = 0.5 * (maxcorner + mincorner);
float3 range  = 0.5 * (maxcorner - mincorner);
float3 delta = p - center;
#line 106
float3 t = abs(range / (delta + 1e-7));
float mint = saturate(min(min(t.x, t.y), t.z));
#line 109
return center + delta * mint;
}
#line 112
float2 aabb_hit_01(float2 origin, float2 dir)
{
float2 hit_t = abs((dir < 0.0.xx ? origin : 1.0.xx - origin) / dir);
return origin + dir * min(hit_t.x, hit_t.y);
}
#line 118
float3 aabb_hit_01(float3 origin, float3 dir)
{
float3 hit_t = abs((dir < 0.0.xxx ? origin : 1.0.xxx - origin) / dir);
return origin + dir * min(min(hit_t.x, hit_t.y), hit_t.z);
}
#line 124
bool inside_screen(float2 uv)
{
return all(saturate(uv - uv * uv));
}
#line 132
float2 octahedral_enc(in float3 v)
{
float2 result = v.xy * rcp(dot(abs(v), 1));
float2 sgn = fast_sign(v.xy);
result = v.z < 0 ? sgn - abs(result.yx) * sgn : result;
return result * 0.5 + 0.5;
}
#line 141
float3 octahedral_dec(float2 o)
{
o = o * 2.0 - 1.0;
float3 v = float3(o.xy, 1.0 - abs(o.x) - abs(o.y));
#line 146
float t = saturate(-v.z);
v.xy += v.xy >= 0.0.xx ? -t.xx : t.xx;
return normalize(v);
}
#line 151
float3x3 invert(float3x3 m)
{
float3x3 adj;
adj[0][0] =  (m[1][1] * m[2][2] - m[1][2] * m[2][1]);
adj[0][1] = -(m[0][1] * m[2][2] - m[0][2] * m[2][1]);
adj[0][2] =  (m[0][1] * m[1][2] - m[0][2] * m[1][1]);
adj[1][0] = -(m[1][0] * m[2][2] - m[1][2] * m[2][0]);
adj[1][1] =  (m[0][0] * m[2][2] - m[0][2] * m[2][0]);
adj[1][2] = -(m[0][0] * m[1][2] - m[0][2] * m[1][0]);
adj[2][0] =  (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
adj[2][1] = -(m[0][0] * m[2][1] - m[0][1] * m[2][0]);
adj[2][2] =  (m[0][0] * m[1][1] - m[0][1] * m[1][0]);
#line 164
float det = dot(float3(adj[0][0], adj[0][1], adj[0][2]), float3(m[0][0], m[1][0], m[2][0]));
return adj * rcp(det + (abs(det) < 1e-8));
}
#line 168
float4x4 invert(float4x4 m)
{
float4x4 adj;
adj[0][0] = m[2][1] * m[3][2] * m[1][3] - m[3][1] * m[2][2] * m[1][3] + m[3][1] * m[1][2] * m[2][3] - m[1][1] * m[3][2] * m[2][3] - m[2][1] * m[1][2] * m[3][3] + m[1][1] * m[2][2] * m[3][3];
adj[0][1] = m[3][1] * m[2][2] * m[0][3] - m[2][1] * m[3][2] * m[0][3] - m[3][1] * m[0][2] * m[2][3] + m[0][1] * m[3][2] * m[2][3] + m[2][1] * m[0][2] * m[3][3] - m[0][1] * m[2][2] * m[3][3];
adj[0][2] = m[1][1] * m[3][2] * m[0][3] - m[3][1] * m[1][2] * m[0][3] + m[3][1] * m[0][2] * m[1][3] - m[0][1] * m[3][2] * m[1][3] - m[1][1] * m[0][2] * m[3][3] + m[0][1] * m[1][2] * m[3][3];
adj[0][3] = m[2][1] * m[1][2] * m[0][3] - m[1][1] * m[2][2] * m[0][3] - m[2][1] * m[0][2] * m[1][3] + m[0][1] * m[2][2] * m[1][3] + m[1][1] * m[0][2] * m[2][3] - m[0][1] * m[1][2] * m[2][3];
#line 176
adj[1][0] = m[3][0] * m[2][2] * m[1][3] - m[2][0] * m[3][2] * m[1][3] - m[3][0] * m[1][2] * m[2][3] + m[1][0] * m[3][2] * m[2][3] + m[2][0] * m[1][2] * m[3][3] - m[1][0] * m[2][2] * m[3][3];
adj[1][1] = m[2][0] * m[3][2] * m[0][3] - m[3][0] * m[2][2] * m[0][3] + m[3][0] * m[0][2] * m[2][3] - m[0][0] * m[3][2] * m[2][3] - m[2][0] * m[0][2] * m[3][3] + m[0][0] * m[2][2] * m[3][3];
adj[1][2] = m[3][0] * m[1][2] * m[0][3] - m[1][0] * m[3][2] * m[0][3] - m[3][0] * m[0][2] * m[1][3] + m[0][0] * m[3][2] * m[1][3] + m[1][0] * m[0][2] * m[3][3] - m[0][0] * m[1][2] * m[3][3];
adj[1][3] = m[1][0] * m[2][2] * m[0][3] - m[2][0] * m[1][2] * m[0][3] + m[2][0] * m[0][2] * m[1][3] - m[0][0] * m[2][2] * m[1][3] - m[1][0] * m[0][2] * m[2][3] + m[0][0] * m[1][2] * m[2][3];
#line 181
adj[2][0] = m[2][0] * m[3][1] * m[1][3] - m[3][0] * m[2][1] * m[1][3] + m[3][0] * m[1][1] * m[2][3] - m[1][0] * m[3][1] * m[2][3] - m[2][0] * m[1][1] * m[3][3] + m[1][0] * m[2][1] * m[3][3];
adj[2][1] = m[3][0] * m[2][1] * m[0][3] - m[2][0] * m[3][1] * m[0][3] - m[3][0] * m[0][1] * m[2][3] + m[0][0] * m[3][1] * m[2][3] + m[2][0] * m[0][1] * m[3][3] - m[0][0] * m[2][1] * m[3][3];
adj[2][2] = m[1][0] * m[3][1] * m[0][3] - m[3][0] * m[1][1] * m[0][3] + m[3][0] * m[0][1] * m[1][3] - m[0][0] * m[3][1] * m[1][3] - m[1][0] * m[0][1] * m[3][3] + m[0][0] * m[1][1] * m[3][3];
adj[2][3] = m[2][0] * m[1][1] * m[0][3] - m[1][0] * m[2][1] * m[0][3] - m[2][0] * m[0][1] * m[1][3] + m[0][0] * m[2][1] * m[1][3] + m[1][0] * m[0][1] * m[2][3] - m[0][0] * m[1][1] * m[2][3];
#line 186
adj[3][0] = m[3][0] * m[2][1] * m[1][2] - m[2][0] * m[3][1] * m[1][2] - m[3][0] * m[1][1] * m[2][2] + m[1][0] * m[3][1] * m[2][2] + m[2][0] * m[1][1] * m[3][2] - m[1][0] * m[2][1] * m[3][2];
adj[3][1] = m[2][0] * m[3][1] * m[0][2] - m[3][0] * m[2][1] * m[0][2] + m[3][0] * m[0][1] * m[2][2] - m[0][0] * m[3][1] * m[2][2] - m[2][0] * m[0][1] * m[3][2] + m[0][0] * m[2][1] * m[3][2];
adj[3][2] = m[3][0] * m[1][1] * m[0][2] - m[1][0] * m[3][1] * m[0][2] - m[3][0] * m[0][1] * m[1][2] + m[0][0] * m[3][1] * m[1][2] + m[1][0] * m[0][1] * m[3][2] - m[0][0] * m[1][1] * m[3][2];
adj[3][3] = m[1][0] * m[2][1] * m[0][2] - m[2][0] * m[1][1] * m[0][2] + m[2][0] * m[0][1] * m[1][2] - m[0][0] * m[2][1] * m[1][2] - m[1][0] * m[0][1] * m[2][2] + m[0][0] * m[1][1] * m[2][2];
#line 191
float det = dot(float4(adj[0][0], adj[1][0], adj[2][0], adj[3][0]), float4(m[0][0], m[0][1],  m[0][2],  m[0][3]));
return adj * rcp(det + (abs(det) < 1e-8));
}
#line 195
float2 anisotropy_map(float2 kernel, float3 n, float limit)
{
n.xy *= limit;
float2 distorted = kernel - n.xy * dot(n.xy, kernel);
return distorted;
}
#line 203
float2 anisotropy_map2(float2 kernel, float3 n, float limit)
{
n.xy *= limit;
float cosine = rsqrt(1 - dot(n.xy, n.xy));
float2 distorted = kernel - n.xy * dot(n.xy, kernel) * cosine;
return distorted * cosine;
}
#line 211
float chebyshev_weight(float mean, float variance, float xi)
{
return saturate(variance * rcp(max(1e-7, variance + (xi - mean) * (xi - mean))));
}
#line 218
bool bitfield_get(float bitfield, int bit)
{
float state = floor(bitfield / exp2(bit)); 
return frac(state * 0.5) > 0.25; 
}
#line 224
void bitfield_set(inout float bitfield, int bit, bool value)
{
bool is_set = bitfield_get(bitfield, bit);
#line 228
bitfield += exp2(bit) * (value - is_set);
}
#line 231
}
#line 182 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_SMAA.fx"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_camera.fxh"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_global.fxh"
#line 21 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_camera.fxh"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_depth.fxh"
#line 22 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_camera.fxh"
#line 29
namespace Camera
{
#line 32
float depth_to_z(float depth)
{
return depth * 1000.0 + 1.0;
}
#line 37
float z_to_depth(float z)
{
float ifar = rcp(1000.0);
return z * ifar - ifar;
}
#line 43
float2 proj_to_uv(float3 pos)
{
#line 47
static const float3 uvtoprojADD = float3(-tan(radians(60.0) * 0.5).xx, 1.0) * BUFFER_ASPECT_RATIO_DLSS.yxx;
static const float3 uvtoprojMUL = float3(-2.0 * uvtoprojADD.xy, 0.0);
static const float4 projtouv    = float4(rcp(uvtoprojMUL.xy), -rcp(uvtoprojMUL.xy) * uvtoprojADD.xy);
return (pos.xy / pos.z) * projtouv.xy + projtouv.zw;
}
#line 53
float3 uv_to_proj(float2 uv, float z)
{
#line 57
static const float3 uvtoprojADD = float3(-tan(radians(60.0) * 0.5).xx, 1.0) * BUFFER_ASPECT_RATIO_DLSS.yxx;
static const float3 uvtoprojMUL = float3(-2.0 * uvtoprojADD.xy, 0.0);
static const float4 projtouv    = float4(rcp(uvtoprojMUL.xy), -rcp(uvtoprojMUL.xy) * uvtoprojADD.xy);
return (uv.xyx * uvtoprojMUL + uvtoprojADD) * z;
}
#line 63
float3 uv_to_proj(float2 uv)
{
float z = depth_to_z(Depth::get_linear_depth(uv));
return uv_to_proj(uv, z);
}
#line 69
float3 uv_to_proj(float2 uv, sampler2D linearz, int mip)
{
float z = tex2Dlod(linearz, float4(uv.xyx, mip)).x;
return uv_to_proj(uv, z);
}
#line 75
}
#line 183 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_SMAA.fx"
#line 184
texture DepthTex < pooled = true; > { 	Width = 1920;   	Height = 1018;   	Format = R16F;  };
texture EdgesTex < pooled = true; > {	Width = 1920;	    Height = 1018;	    Format = RG8;   };
texture BlendTex < pooled = true; > {	Width = 1920;   	Height = 1018; 	Format = RGBA8; };
#line 189
texture areaLUT < source = "AreaLUT.png"; > {	Width = 560;	Height = 80;	Format = RGBA8;};
texture searchLUT  {	Width = 64;	Height = 16;	Format = R8;};
#line 192
sampler sDepthTex {	Texture = DepthTex; };
#line 195
sampler sColorInputTexGamma {	Texture = ColorInputTex; MipFilter = POINT; MinFilter = LINEAR; MagFilter = LINEAR; SRGBTexture = false;};
sampler sColorInputTexLinear{	Texture = ColorInputTex; MipFilter = POINT; MinFilter = LINEAR; MagFilter = LINEAR; SRGBTexture = true;};
#line 202
sampler edgesSampler { Texture = EdgesTex;	};
sampler blendSampler { Texture = BlendTex;  };
#line 206
storage stEdgesTex   { Texture = EdgesTex;  };
storage stBlendTex   { Texture = BlendTex;  };
storage stDepthTex   { Texture = DepthTex;  };
#line 211
sampler areaLUTSampler {	Texture = areaLUT;	SRGBTexture = false;};
sampler searchLUTSampler {	Texture = searchLUT; MipFilter = POINT; MinFilter = POINT; MagFilter = POINT; };
#line 224
struct VSOUT
{
float4 vpos : SV_Position;
float2 uv   : TEXCOORD0;
};
#line 230
struct CSIN
{
uint3 groupthreadid     : SV_GroupThreadID;         
uint3 groupid           : SV_GroupID;               
uint3 dispatchthreadid  : SV_DispatchThreadID;      
uint threadid           : SV_GroupIndex;            
};
#line 242
float2 pixel_idx_to_uv(uint2 pos, float2 texture_size)
{
float2 inv_texture_size = rcp(texture_size);
return pos * inv_texture_size + 0.5 * inv_texture_size;
}
#line 248
bool check_boundaries(uint2 pos, uint2 dest_size)
{
return pos.x < dest_size.x && pos.y < dest_size.y; 
}
#line 253
void SMAAMovc(bool2 cond, inout float2 variable, float2 value)
{
#line 257
variable = cond ? value : variable;
}
#line 260
void SMAAMovc(bool4 cond, inout float4 variable, float4 value)
{
variable = cond ? value : variable;
#line 265
}
#line 267
float3 SMAAGatherNeighbours(float2 texcoord, float4 offset[3], sampler tex)
{
return tex2DgatherR(tex, texcoord + BUFFER_PIXEL_SIZE * float2(-0.5, -0.5)).grb;
}
#line 272
float2 SMAACalculatePredicatedThreshold(float2 texcoord, float4 offset[3], sampler predicationTex)
{
float3 neighbours = SMAAGatherNeighbours(texcoord, offset, predicationTex);
float2 delta = abs(neighbours.xx - neighbours.yz);
float2 edges = step(SMAA_PREDICATION_THRESHOLD, delta);
return SMAA_PREDICATION_SCALE * SMAA_THRESHOLD * (1.0 - SMAA_PREDICATION_STRENGTH * edges);
}
#line 280
void SMAAEdgeDetectionVS(float2 texcoord, out float4 offset[3])
{
offset[0] = mad(BUFFER_PIXEL_SIZE.xyxy, float4(-1.0, 0.0, 0.0, -1.0), texcoord.xyxy);
offset[1] = mad(BUFFER_PIXEL_SIZE.xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
offset[2] = mad(BUFFER_PIXEL_SIZE.xyxy, float4(-2.0, 0.0, 0.0, -2.0), texcoord.xyxy);
}
#line 287
void SMAABlendingWeightCalculationVS(float2 texcoord, out float2 pixcoord, out float4 offset[3])
{
pixcoord = texcoord * BUFFER_SCREEN_SIZE;
#line 292
offset[0] = mad(BUFFER_PIXEL_SIZE.xyxy, float4(-0.25, -0.125,  1.25, -0.125), texcoord.xyxy);
offset[1] = mad(BUFFER_PIXEL_SIZE.xyxy, float4(-0.125, -0.25, -0.125,  1.25), texcoord.xyxy);
#line 296
offset[2] = mad(BUFFER_PIXEL_SIZE.xxyy,
float4(-2.0, 2.0, -2.0, 2.0) * float(SMAA_MAX_SEARCH_STEPS),
float4(offset[0].xz, offset[1].yw));
}
#line 301
void SMAANeighborhoodBlendingVS(float2 texcoord,  out float4 offset)
{
offset = mad(BUFFER_PIXEL_SIZE.xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
}
#line 306
float edge_metric(float3 A, float3 B)
{
float3 t = abs(A - B);
if(EDGE_DETECTION_MODE == 2)
return dot(abs(A - B), float3(0.229, 0.587, 0.114) * 1.33);
#line 312
return max(max(t.r, t.g), t.b);
}
#line 315
float2 SMAALumaEdgePredicationDetectionPS(float2 texcoord, float4 offset[3], sampler _colorTex, sampler _predicationTex)
{
float2 threshold = float2(SMAA_THRESHOLD, SMAA_THRESHOLD);
[branch]
if(SMAA_PREDICATION)
threshold = SMAACalculatePredicatedThreshold(texcoord, offset, _predicationTex);
#line 322
float3 weights = float3(0.2126, 0.7152, 0.0722);
float L = dot(tex2D(_colorTex, texcoord).rgb, weights);
#line 325
float Lleft = dot(tex2Dlod(_colorTex, offset[0].xy, 0).rgb, weights);
float Ltop  = dot(tex2Dlod(_colorTex, offset[0].zw, 0).rgb, weights);
#line 328
float4 delta;
delta.xy = abs(L - float2(Lleft, Ltop));
float2 edges = step(threshold, delta.xy);
#line 333
if(edges.x == -edges.y) discard;
#line 335
float Lright   = dot(tex2Dlod(_colorTex, offset[1].xy, 0).rgb, weights);
float Lbottom  = dot(tex2Dlod(_colorTex, offset[1].zw, 0).rgb, weights);
delta.zw = abs(L - float2(Lright, Lbottom));
#line 339
float2 maxDelta = max(delta.xy, delta.zw);
#line 341
float Lleftleft = dot(tex2Dlod(_colorTex, offset[2].xy, 0).rgb, weights);
float Ltoptop = dot(tex2Dlod(_colorTex, offset[2].zw, 0).rgb, weights);
delta.zw = abs(float2(Lleft, Ltop) - float2(Lleftleft, Ltoptop));
#line 345
maxDelta = max(maxDelta.xy, delta.zw);
float finalDelta = max(maxDelta.x, maxDelta.y);
#line 348
edges.xy *= step(finalDelta, 2.0 * delta.xy);
return edges;
}
#line 352
float2 SMAAColorEdgePredicationDetectionPS(float2 texcoord, float4 offset[3], sampler _colorTex , sampler _predicationTex)
{
float2 threshold = float2(SMAA_THRESHOLD, SMAA_THRESHOLD);
[branch]
if(SMAA_PREDICATION)
threshold = SMAACalculatePredicatedThreshold(texcoord, offset, _predicationTex);
#line 359
float4 delta;
float3 C = tex2Dlod(_colorTex, texcoord, 0).rgb;
#line 362
float3 Cleft = tex2Dlod(_colorTex, offset[0].xy, 0).rgb;
delta.x = edge_metric(C, Cleft);
float3 Ctop  = tex2Dlod(_colorTex, offset[0].zw, 0).rgb;
delta.y = edge_metric(C, Ctop);
#line 367
float2 edges = step(threshold, delta.xy);
#line 369
if(edges.x == -edges.y) discard;
#line 371
float3 Cright = tex2Dlod(_colorTex, offset[1].xy, 0).rgb;
delta.z = edge_metric(C, Cright);
float3 Cbottom  = tex2Dlod(_colorTex, offset[1].zw, 0).rgb;
delta.w = edge_metric(C, Cbottom);
#line 376
float2 maxDelta = max(delta.xy, delta.zw);
#line 378
float3 Cleftleft  = tex2Dlod(_colorTex, offset[2].xy, 0).rgb;
delta.z = edge_metric(Cleft, Cleftleft);
#line 381
float3 Ctoptop = tex2Dlod(_colorTex, offset[2].zw, 0).rgb;
delta.w = edge_metric(Ctop, Ctoptop);
#line 384
maxDelta = max(maxDelta.xy, delta.zw);
#line 386
float finalDelta = max(maxDelta.x, maxDelta.y);
edges.xy *= step(finalDelta, 2.0 * delta.xy);
return edges;
}
#line 391
float2 SMAADepthEdgeDetectionPS(float2 texcoord, float4 offset[3], sampler DepthTex)
{
float3 neighbours = SMAAGatherNeighbours(texcoord, offset, DepthTex);
float2 delta = abs(neighbours.xx - float2(neighbours.y, neighbours.z));
float2 edges = step(SMAA_DEPTH_THRESHOLD, delta);
#line 399
if(edges.x == -edges.y) discard;
#line 401
return edges;
}
#line 405
float2 SMAADecodeDiagBilinearAccess(float2 e)
{
e.r = e.r * abs(5.0 * e.r - 5.0 * 0.75);
return round(e);
}
#line 411
float4 SMAADecodeDiagBilinearAccess(float4 e)
{
e.rb = e.rb * abs(5.0 * e.rb - 5.0 * 0.75);
return round(e);
}
#line 417
float2 SMAASearchDiag1(sampler EdgesTex, float2 texcoord, float2 dir, out float2 e)
{
float4 coord = float4(texcoord, -1.0, 1.0);
float3 t = float3(BUFFER_PIXEL_SIZE.xy, 1.0);
while(coord.z < float(SMAA_MAX_SEARCH_STEPS_DIAG - 1) && coord.w > 0.9)
{
coord.xyz = mad(t, float3(dir, 1.0), coord.xyz);
e = tex2Dlod(EdgesTex, coord.xy, 0).rg;
coord.w = dot(e, 0.5);
}
return coord.zw;
}
#line 430
float2 SMAASearchDiag2(sampler EdgesTex, float2 texcoord, float2 dir, out float2 e)
{
float4 coord = float4(texcoord, -1.0, 1.0);
coord.x += 0.25 * BUFFER_PIXEL_SIZE.x;
float3 t = float3(BUFFER_PIXEL_SIZE.xy, 1.0);
while (coord.z < float(SMAA_MAX_SEARCH_STEPS_DIAG - 1) && coord.w > 0.9)
{
coord.xyz = mad(t, float3(dir, 1.0), coord.xyz);
#line 439
e = tex2Dlod(EdgesTex, coord.xy, 0).rg;
e = SMAADecodeDiagBilinearAccess(e);
coord.w = dot(e, 0.5);
}
return coord.zw;
}
#line 446
float2 SMAAAreaDiag(sampler areaTex, float2 dist, float2 e, float offset)
{
float2 texcoord = mad(float2(20, 20), e, dist);
#line 450
texcoord = mad((1.0 / float2(80.0, 560.0)), texcoord, 0.5 * (1.0 / float2(80.0, 560.0)));
texcoord.y += (1.0 / 7.0) * offset;
#line 453
return tex2Dlod(areaLUTSampler, texcoord.yx, 0).zw; 
}
#line 456
float2 SMAACalculateDiagWeights(sampler EdgesTex, sampler areaTex, float2 texcoord, float2 e, float4 subsampleIndices)
{
float2 weights = 0;
#line 461
float4 d;
float2 end;
if (e.r > 0.0)
{
d.xz = SMAASearchDiag1(EdgesTex, texcoord, float2(-1.0,  1.0), end);
d.x += float(end.y > 0.9);
}
else
{
d.xz = 0;
}
#line 473
d.yw = SMAASearchDiag1(EdgesTex, texcoord, float2(1.0, -1.0), end);
#line 475
[branch]
if (d.x + d.y > 2.0)  
{
#line 479
float4 coords = mad(float4(-d.x + 0.25, d.x, d.y, -d.y - 0.25), BUFFER_PIXEL_SIZE.xyxy, texcoord.xyxy);
float4 c;
c.xy = tex2Dlod(EdgesTex, coords.xy + int2(-1,  0) * BUFFER_PIXEL_SIZE, 0).rg;
c.zw = tex2Dlod(EdgesTex, coords.zw + int2( 1,  0) * BUFFER_PIXEL_SIZE, 0).rg;
c.yxwz = SMAADecodeDiagBilinearAccess(c.xyzw);
#line 486
float2 cc = mad(float2(2.0, 2.0), c.xz, c.yw);
#line 489
SMAAMovc(bool2(step(0.9, d.zw)), cc, float2(0.0, 0.0));
#line 494
weights += SMAAAreaDiag(areaTex, d.xy, cc, subsampleIndices.z);
}
#line 498
d.xz = SMAASearchDiag2(EdgesTex, texcoord, float2(-1.0, -1.0), end);
if (tex2Dlod(EdgesTex, texcoord + int2(1, 0) * BUFFER_PIXEL_SIZE, 0).r > 0.0)
{
d.yw = SMAASearchDiag2(EdgesTex, texcoord, float2(1.0, 1.0), end);
d.y += float(end.y > 0.9);
}
else
{
d.yw = 0;
}
#line 509
[branch]
if (d.x + d.y > 2.0) 
{
#line 513
float4 coords = mad(float4(-d.x, -d.x, d.y, d.y), BUFFER_PIXEL_SIZE.xyxy, texcoord.xyxy);
float4 c;
c.x  = tex2Dlod(EdgesTex, coords.xy + int2(-1,  0) * BUFFER_PIXEL_SIZE, 0).g;
c.y  = tex2Dlod(EdgesTex, coords.xy + int2( 0, -1) * BUFFER_PIXEL_SIZE, 0).r;
c.zw = tex2Dlod(EdgesTex, coords.zw + int2( 1,  0) * BUFFER_PIXEL_SIZE, 0).gr;
float2 cc = mad(float2(2.0, 2.0), c.xz, c.yw);
#line 521
SMAAMovc(bool2(step(0.9, d.zw)), cc, float2(0.0, 0.0));
#line 525
weights += SMAAAreaDiag(areaTex, d.xy, cc, subsampleIndices.w).gr;
}
#line 528
return weights;
}
#line 531
float SMAASearchLength(sampler searchTex, float2 e, float offset)
{
return tex2Dfetch(searchTex, floor(float2(e.x + offset, 1 - e.y) * 33.0)).r;
}
#line 536
float SMAASearchXLeft(sampler EdgesTex, sampler searchTex, float2 texcoord, float end)
{
float2 e = float2(0.0, 1.0);
while (texcoord.x > end
&& e.g > 0.8281 
&&  e.r == 0.0) 
{
e = tex2Dlod(EdgesTex, texcoord, 0).rg;
texcoord = mad(-float2(2.0, 0.0), BUFFER_PIXEL_SIZE.xy, texcoord);
}
#line 547
float offset = mad(-(255.0 / 127.0), SMAASearchLength(searchTex, e, 0.0), 3.25);
return mad(BUFFER_PIXEL_SIZE.x, offset, texcoord.x);
}
#line 551
float SMAASearchXRight(sampler EdgesTex, sampler searchTex, float2 texcoord, float end)
{
float2 e = float2(0.0, 1.0);
while (texcoord.x < end
&& e.g > 0.8281  
&& e.r == 0.0) 
{
e = tex2Dlod(EdgesTex, texcoord, 0).rg;
texcoord = mad(float2(2.0, 0.0), BUFFER_PIXEL_SIZE.xy, texcoord);
}
#line 562
float offset = mad(-(255.0 / 127.0), SMAASearchLength(searchTex, e, 1.0), 3.25);
return mad(-BUFFER_PIXEL_SIZE.x, offset, texcoord.x);
}
#line 566
float SMAASearchYUp(sampler EdgesTex, sampler searchTex, float2 texcoord, float end)
{
float2 e = float2(1.0, 0.0);
while (texcoord.y > end &&
e.r > 0.8281 && 
e.g == 0.0) { 
e = tex2Dlod(EdgesTex, texcoord, 0).rg;
texcoord = mad(-float2(0.0, 2.0), BUFFER_PIXEL_SIZE.xy, texcoord);
}
float offset = mad(-(255.0 / 127.0), SMAASearchLength(searchTex, e.gr, 0.0), 3.25);
return mad(BUFFER_PIXEL_SIZE.y, offset, texcoord.y);
}
#line 579
float SMAASearchYDown(sampler EdgesTex, sampler searchTex, float2 texcoord, float end)
{
float2 e = float2(1.0, 0.0);
while (texcoord.y < end &&
e.r > 0.8281 && 
e.g == 0.0) { 
e = tex2Dlod(EdgesTex, texcoord, 0).rg;
texcoord = mad(float2(0.0, 2.0), BUFFER_PIXEL_SIZE.xy, texcoord);
}
float offset = mad(-(255.0 / 127.0), SMAASearchLength(searchTex, e.gr, 1.0), 3.25);
return mad(-BUFFER_PIXEL_SIZE.y, offset, texcoord.y);
}
#line 592
float2 SMAAArea(sampler areaTex, float2 dist, float e1, float e2, float offset)
{
#line 595
float2 texcoord = mad(float2(16, 16), round(4.0 * float2(e1, e2)), dist);
#line 597
texcoord = mad((1.0 / float2(80.0, 560.0)), texcoord, 0.5 * (1.0 / float2(80.0, 560.0)));
texcoord.y = mad((1.0 / 7.0), offset, texcoord.y);
#line 600
return tex2Dlod(areaLUTSampler, texcoord.yx, 0).xy; 
}
#line 603
void SMAADetectHorizontalCornerPattern(sampler EdgesTex, inout float2 weights, float4 texcoord, float2 d)
{
float2 leftRight = step(d.xy, d.yx);
float2 rounding = (1.0 - (float(SMAA_CORNER_ROUNDING) / 100.0)) * leftRight;
#line 608
rounding /= leftRight.x + leftRight.y; 
#line 610
float2 factor = float2(1.0, 1.0);
#line 612
factor.x -= rounding.x * tex2Dlod(EdgesTex, texcoord.xy + int2(0,  1) * BUFFER_PIXEL_SIZE, 0).r;
factor.x -= rounding.y * tex2Dlod(EdgesTex, texcoord.zw + int2(1,  1) * BUFFER_PIXEL_SIZE, 0).r;
factor.y -= rounding.x * tex2Dlod(EdgesTex, texcoord.xy + int2(0, -2) * BUFFER_PIXEL_SIZE, 0).r;
factor.y -= rounding.y * tex2Dlod(EdgesTex, texcoord.zw + int2(1, -2) * BUFFER_PIXEL_SIZE, 0).r;
#line 625
weights *= saturate(factor);
}
#line 628
void SMAADetectVerticalCornerPattern(sampler EdgesTex, inout float2 weights, float4 texcoord, float2 d)
{
float2 leftRight = step(d.xy, d.yx);
float2 rounding = (1.0 - (float(SMAA_CORNER_ROUNDING) / 100.0)) * leftRight;
#line 633
rounding /= leftRight.x + leftRight.y;
#line 635
float2 factor = float2(1.0, 1.0);
#line 637
factor.x -= rounding.x * tex2Dlod(EdgesTex, texcoord.xy + int2( 1, 0) * BUFFER_PIXEL_SIZE, 0).g;
factor.x -= rounding.y * tex2Dlod(EdgesTex, texcoord.zw + int2( 1, 1) * BUFFER_PIXEL_SIZE, 0).g;
factor.y -= rounding.x * tex2Dlod(EdgesTex, texcoord.xy + int2(-2, 0) * BUFFER_PIXEL_SIZE, 0).g;
factor.y -= rounding.y * tex2Dlod(EdgesTex, texcoord.zw + int2(-2, 1) * BUFFER_PIXEL_SIZE, 0).g;
#line 650
weights *= saturate(factor);
}
#line 655
float4 SMAABlendingWeightCalculationPS(float2 texcoord,
float2 pixcoord,
float4 offset[3],
sampler EdgesTex,
sampler areaTex,
sampler searchTex,
float4 subsampleIndices) 
{
float4 weights = float4(0.0, 0.0, 0.0, 0.0);
float2 e = tex2Dfetch(EdgesTex, pixcoord).rg;
#line 666
[branch]
if (e.g > 0.0)
{
#line 672
weights.rg = SMAACalculateDiagWeights(EdgesTex, areaTex, texcoord, e, subsampleIndices);
#line 676
[branch]
if (weights.r == -weights.g)  
{
float2 d;
#line 682
float3 coords;
coords.x = SMAASearchXLeft(EdgesTex, searchTex, offset[0].xy, offset[2].x);
coords.y = offset[1].y; 
d.x = coords.x;
#line 690
float e1 = tex2Dlod(EdgesTex, coords.xy, 0).r;
#line 693
coords.z = SMAASearchXRight(EdgesTex, searchTex, offset[0].zw, offset[2].y);
d.y = coords.z;
#line 698
d = abs(round(mad(BUFFER_SCREEN_SIZE.xx, d, -pixcoord.xx)));
#line 702
float2 sqrt_d = sqrt(d);
#line 705
float e2 = tex2Dlod(EdgesTex, coords.zy + int2(1, 0) * BUFFER_PIXEL_SIZE, 0).r;
#line 709
weights.rg = SMAAArea(areaTex, sqrt_d, e1, e2, subsampleIndices.y);
#line 712
coords.y = texcoord.y;
SMAADetectHorizontalCornerPattern(EdgesTex, weights.rg, coords.xyzy, d);
}
else
e.r = 0.0; 
}
#line 719
[branch]
if (e.r > 0.0) 
{
float2 d;
#line 725
float3 coords;
coords.y = SMAASearchYUp(EdgesTex, searchTex, offset[1].xy, offset[2].z);
coords.x = offset[0].x; 
d.x = coords.y;
#line 731
float e1 = tex2Dlod(EdgesTex, coords.xy, 0).g;
#line 734
coords.z = SMAASearchYDown(EdgesTex, searchTex, offset[1].zw, offset[2].w);
d.y = coords.z;
#line 738
d = abs(round(mad(BUFFER_SCREEN_SIZE.yy, d, -pixcoord.yy)));
#line 742
float2 sqrt_d = sqrt(d);
#line 745
float e2 = tex2Dlod(EdgesTex, coords.xz + int2(0, 1) * BUFFER_PIXEL_SIZE, 0).g;
#line 748
weights.ba = SMAAArea(areaTex, sqrt_d, e1, e2, subsampleIndices.x);
#line 751
coords.x = texcoord.x;
SMAADetectVerticalCornerPattern(EdgesTex, weights.ba, coords.xyxz, d);
}
#line 755
return weights;
}
#line 759
float4 SMAANeighborhoodBlendingPS(float2 texcoord,
float4 offset,
sampler colorTex,
sampler BlendTex)
{
#line 765
float4 a;
a.x = tex2Dlod(BlendTex, offset.xy, 0).a; 
a.y = tex2Dlod(BlendTex, offset.zw, 0).g; 
a.wz = tex2Dlod(BlendTex, texcoord, 0).xz; 
#line 771
[branch]
if (dot(a, 1) < 1e-5)
#line 774
{
discard;
}
else
{
bool h = max(a.x, a.z) > max(a.y, a.w); 
#line 782
float4 blendingOffset = float4(0.0, a.y, 0.0, a.w);
float2 blendingWeight = a.yw;
SMAAMovc(bool4(h, h, h, h), blendingOffset, float4(a.x, 0.0, a.z, 0.0));
SMAAMovc(bool2(h, h), blendingWeight, a.xz);
blendingWeight /= dot(blendingWeight, float2(1.0, 1.0));
#line 789
float4 blendingCoord = mad(blendingOffset, float4(BUFFER_PIXEL_SIZE.xy, -BUFFER_PIXEL_SIZE.xy), texcoord.xyxy);
#line 791
if(dot(blendingOffset, 1) < 0.01) discard;
#line 795
float4 color = blendingWeight.x * tex2Dlod(colorTex, blendingCoord.xy, 0);
color += blendingWeight.y * tex2Dlod(colorTex, blendingCoord.zw, 0);
#line 798
return color;
}
}
#line 806
VSOUT MainVS(in uint id : SV_VertexID)
{
VSOUT o; FullscreenTriangleVS(id, o.vpos, o.uv); return o;
}
#line 817
 
#line 819
void SMAADepthLinearizationCS(in CSIN i)
{
if(!check_boundaries(i.dispatchthreadid.xy * 2, BUFFER_SCREEN_SIZE) || (!SMAA_PREDICATION && EDGE_DETECTION_MODE != 3)) return;
#line 823
float2 uv = pixel_idx_to_uv(i.dispatchthreadid.xy * 2, BUFFER_SCREEN_SIZE);
float2 corrected_uv = Depth::correct_uv(uv); 
#line 830
float4 depth_texels = tex2DgatherR(DepthInput, corrected_uv);
#line 833
depth_texels = Depth::linearize(depth_texels);
tex2Dstore(stDepthTex, i.dispatchthreadid.xy * 2 + uint2(0, 1), depth_texels.x);
tex2Dstore(stDepthTex, i.dispatchthreadid.xy * 2 + uint2(1, 1), depth_texels.y);
tex2Dstore(stDepthTex, i.dispatchthreadid.xy * 2 + uint2(1, 0), depth_texels.z);
tex2Dstore(stDepthTex, i.dispatchthreadid.xy * 2 + uint2(0, 0), depth_texels.w);
}
#line 846
float2 SMAAEdgeDetectionWrapPS(in VSOUT i) : SV_Target
{
float2 texcoord = i.uv;
#line 850
float4 offset[3];
SMAAEdgeDetectionVS(texcoord, offset);
#line 853
[branch]
if(EDGE_DETECTION_MODE == 0)
return SMAALumaEdgePredicationDetectionPS(texcoord, offset, sColorInputTexGamma, sDepthTex);
else
[branch]
if(EDGE_DETECTION_MODE == 3)
return SMAADepthEdgeDetectionPS(texcoord, offset, sDepthTex);
#line 861
return SMAAColorEdgePredicationDetectionPS(texcoord, offset, sColorInputTexGamma, sDepthTex);
}
#line 887
 
#line 890
void SMAAEdgeDetectionWrapAndClearPS(in VSOUT i, out PSOUT2 o)
{
float2 texcoord = i.uv;
#line 894
float4 offset[3];
SMAAEdgeDetectionVS(texcoord, offset);
#line 897
o.t0 = o.t1 = 0; 
#line 899
[branch]
if(EDGE_DETECTION_MODE == 0)
o.t0 = SMAALumaEdgePredicationDetectionPS(texcoord, offset, sColorInputTexGamma, sDepthTex);
else
[branch]
if(EDGE_DETECTION_MODE == 3)
o.t0 = SMAADepthEdgeDetectionPS(texcoord, offset, sDepthTex);
else
o.t0 =  SMAAColorEdgePredicationDetectionPS(texcoord, offset, sColorInputTexGamma, sDepthTex);
}
#line 914
groupshared uint g_worker_ids[16 * 16 * 2];
groupshared uint g_total_workers;
#line 920
void SMAABlendingWeightCalculationWrapCS(in CSIN i)
{
const uint2 groupsize = uint2(16, 16);
const uint2 working_area = groupsize * uint2(1, 2);
const uint global_counter_idx = working_area.x * working_area.y;
#line 926
if(i.threadid == 0) g_total_workers = 0;
barrier();
#line 929
[unroll]
for(uint batch = 0; batch < 2; batch++)
{
uint id = i.threadid * 2 + batch;
uint2 pos = i.groupid.xy * working_area + uint2(id % groupsize.x, id / groupsize.x);
#line 935
if(any(tex2Dfetch(edgesSampler, pos).xy))
{
uint harderworker_id = atomicAdd(g_total_workers, 1u);
g_worker_ids[harderworker_id] = id;
}
}
#line 942
barrier();
#line 945
uint total_work = g_total_workers;
#line 950
if(total_work < 4)
return;
#line 956
while(i.threadid < total_work)
{
uint id = g_worker_ids[i.threadid];
uint2 pos = i.groupid.xy * working_area + uint2(id % groupsize.x, id / groupsize.x);
#line 961
float2 uv = pixel_idx_to_uv(pos, BUFFER_SCREEN_SIZE);
float2 pixcoord;
float4 offset[3];
SMAABlendingWeightCalculationVS(uv, pixcoord, offset);
float4 blend_weights = SMAABlendingWeightCalculationPS(uv, pixcoord, offset, edgesSampler, areaLUTSampler, searchLUTSampler, 0.0);
tex2Dstore(stBlendTex, pos, blend_weights);
i.threadid += groupsize.x * groupsize.y;
}
}
#line 977
void SMAANeighborhoodBlendingWrapVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0, out float4 offset : TEXCOORD1)
{
FullscreenTriangleVS(id, position, texcoord);
SMAANeighborhoodBlendingVS(texcoord, offset);
}
#line 983
float3 SMAANeighborhoodBlendingWrapPS(float4 position : SV_Position,float2 texcoord : TEXCOORD0,float4 offset : TEXCOORD1) : SV_Target
{
if(DebugOutput == 1)
return tex2Dlod(edgesSampler, texcoord, 0).rgb;
if(DebugOutput == 2)
return tex2Dlod(blendSampler, texcoord, 0).rgb;
#line 990
return SMAANeighborhoodBlendingPS(texcoord, offset, sColorInputTexLinear, blendSampler).rgb;
}
#line 993
float SMAAMakeLUTTexPS(in VSOUT i) : SV_Target
{
#line 1010
float2 pos = floor(i.vpos.xy);
bool rightside = pos.x > 33;
pos.x = pos.x % 33;
float2 a = max(0, abs(pos - 16.0) - 4.0) - saturate(abs(pos - 16.0) - 10.0);
float2 u1 = round(abs(sin(a * PI / 3.0)));
if(rightside) return u1.y * (saturate(1 - 0.5 * pos.x) + saturate(1 - abs(7.5 - pos.x)));
float h = pos.x < 16.0 && pos.y < 5.0 ? round(saturate(sin(-a.x * PI / 3.0))) : 0;
return (u1.x + h) * u1.y * 0.5;
}
#line 1024
technique MartysMods_AntiAliasing_Prepass
<
hidden = true;
enabled = true;
timeout = 1;
>
{
pass
{
VertexShader = MainVS;
PixelShader = SMAAMakeLUTTexPS;
RenderTarget = searchLUT;
}
}
#line 1039
technique MartysMods_AntiAliasing
<
ui_label = "iMMERSE: Anti Aliasing";
ui_tooltip =
"                               MartysMods - SMAA                              \n"
"                   MartysMods Epic ReShade Effects (iMMERSE)                 \n"
"______________________________________________________________________________\n"
"\n"
#line 1048
"This implementation of 'Enhanced subpixel morphological antialiasing' (SMAA)  \n"
"delivers up to twice the performance of the original depending on settings.   \n"
"\n"
"\n"
"Visit https://martysmods.com for more information.                            \n"
"\n"
"______________________________________________________________________________";
>
{
#line 1058
pass
{
ComputeShader = SMAADepthLinearizationCS<16, 16>;
DispatchSizeX = ((((1920) - 1) / (32)) + 1);
DispatchSizeY = ((((1018) - 1) / (32)) + 1);
}
pass SMAAEdgeDetectionWrapAndClearPS
{
VertexShader = MainVS;
PixelShader = SMAAEdgeDetectionWrapAndClearPS;
ClearRenderTargets = true;
RenderTarget0 = EdgesTex;
RenderTarget1 = BlendTex;
}
pass
{
ComputeShader = SMAABlendingWeightCalculationWrapCS<16, 16>;
DispatchSizeX = ((((1920) - 1) / (16)) + 1);
DispatchSizeY = ((((1018) - 1) / ((16*2))) + 1);
}
#line 1107
pass NeighborhoodBlendingPass
{
VertexShader = SMAANeighborhoodBlendingWrapVS;
PixelShader = SMAANeighborhoodBlendingWrapPS;
StencilEnable = false;
#line 1113
SRGBWriteEnable = true;
#line 1115
}
}

