// LAUNCHPAD_DEBUG_OUTPUT=0
#line 1 "unknown"

#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_LAUNCHPAD.fx"
#line 50
uniform int OPTICAL_FLOW_Q <
ui_type = "combo";
ui_label = "Flow Quality";
ui_items = "Low\0Medium\0High\0";
ui_tooltip = "Higher settings produce more accurate results, at a performance cost.";
ui_category = "Motion Estimation / Optical Flow";
> = 0;
#line 58
uniform int OPTICAL_FLOW_OPT <
ui_type = "combo";
ui_label = "Flow Optimizer";
ui_items = "Sophia (Second-Order Hessian Optimizer)\0Newton\0";
ui_tooltip = "Launchpad's Optical Flow uses gradient descent, similar to AI training.\n\n"
"Sophia converges better at high quality settings.\n"
"Newton descents faster at low settings but may converge worse.";
ui_category = "Motion Estimation / Optical Flow";
> = 0;
#line 68
uniform bool ENABLE_SMOOTH_NORMALS <
ui_label = "Enable Smooth Normals";
ui_tooltip = "Filters the normal buffer to reduce low-poly look in MXAO and RTGI."
"\n\n"
"Lighting algorithms depend on normal vectors, which describe the orientation\n"
"of the geometry in the scene. As ReShade does not access the game's own normals,\n"
"they are generated from the depth buffer instead. However, this process is lossy\n"
"and does not contain normal maps and smoothing groups.\n"
"As a result, they represent the true (blocky) object shapes and lighting calculated\n"
"using them can make the low-poly appearance of geometry apparent.\n";
ui_category = "NORMAL MAPS";
> = false;
#line 81
uniform bool ENABLE_TEXTURED_NORMALS <
ui_label = "Enable Texture Normals";
ui_tooltip = "Estimates surface relief based on color information, for more accurate geometry representation.\n"
"Requires smooth normals to be enabled!";
ui_category = "NORMAL MAPS";
> = false;
#line 88
uniform float TEXTURED_NORMALS_RADIUS <
ui_type = "drag";
ui_label = "Textured Normals Sample Radius";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "NORMAL MAPS";
> = 0.5;
#line 96
uniform float TEXTURED_NORMALS_INTENSITY <
ui_type = "drag";
ui_label = "Textured Normals Intensity";
ui_tooltip = "Higher values cause stronger surface bumpyness.";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "NORMAL MAPS";
> = 0.5;
#line 105
uniform int TEXTURED_NORMALS_QUALITY <
ui_type = "slider";
ui_min = 1; ui_max = 3;
ui_label = "Textured Normals Quality";
ui_tooltip = "Higher settings produce more accurate results, at a performance cost.";
ui_category = "NORMAL MAPS";
> = 2;
#line 180
texture ColorInputTex : COLOR;
texture DepthInputTex : DEPTH;
sampler ColorInput 	{ Texture = ColorInputTex; };
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
#line 186 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_LAUNCHPAD.fx"
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
#line 187 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_LAUNCHPAD.fx"
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
#line 188 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_LAUNCHPAD.fx"
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
#line 189 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_LAUNCHPAD.fx"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_deferred.fxh"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_global.fxh"
#line 21 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_deferred.fxh"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_math.fxh"
#line 22 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_deferred.fxh"
#line 23
namespace Deferred
{
#line 26
texture NormalsTexV3 { Width = 1920; Height = 1018; Format = RGBA16; };
sampler sNormalsTexV3 { Texture = NormalsTexV3; MinFilter = POINT; MipFilter = POINT; MagFilter = POINT; };
#line 29
float3 get_normals(float2 uv)
{
float2 encoded = tex2Dlod(sNormalsTexV3, uv, 0).xy;
return -Math::octahedral_dec(encoded); 
}
#line 35
float3 get_geometry_normals(float2 uv)
{
float2 encoded = tex2Dlod(sNormalsTexV3, uv, 0).zw;
return -Math::octahedral_dec(encoded);
}
#line 42
texture MotionVectorsTex { Width = 1920; Height = 1018; Format = RG16F; };
sampler sMotionVectorsTex { Texture = MotionVectorsTex;};
#line 45
float2 get_motion(float2 uv)
{
return tex2Dlod(sMotionVectorsTex, uv, 0).xy;
}
#line 50
float4 get_motion_wide(float2 uv)
{
return tex2Dlod(sMotionVectorsTex, uv, 0);
}
#line 56
texture AlbedoTex { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler sAlbedoTex { Texture = AlbedoTex;};
#line 59
float3 get_albedo(float2 uv)
{
return tex2Dlod(sAlbedoTex, uv, 0).rgb;
}
#line 64
float3 fetch_albedo(int2 p)
{
return tex2Dfetch(sAlbedoTex, p).rgb;
}
#line 69
}
#line 190 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_LAUNCHPAD.fx"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_texture.fxh"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_global.fxh"
#line 21 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_texture.fxh"
#line 22
namespace Texture
{
#line 25
float4 sample2D_biquadratic(sampler s, float2 iuv, int2 size)
{
float2 q = frac(iuv * size);
float2 c = (q * (q - 1.0) + 0.5) * rcp(size);
float4 uv = iuv.xyxy + float4(-c, c);
return (tex2Dlod(s, uv.xy, 0)
+ tex2Dlod(s, uv.xw, 0)
+ tex2Dlod(s, uv.zw, 0)
+ tex2Dlod(s, uv.zy, 0)) * 0.25;
}
#line 36
float4 sample2D_biquadratic_auto(sampler s, float2 iuv)
{
return sample2D_biquadratic(s, iuv, tex2Dsize(s));
}
#line 44
float4 sample2D_bspline(sampler s, float2 iuv, int2 size)
{
float4 uv;
uv.xy = iuv * size;
#line 49
float2 center = floor(uv.xy - 0.5) + 0.5;
float4 d = float4(uv.xy - center, 1 + center - uv.xy);
float4 d2 = d * d;
float4 d3 = d2 * d;
#line 54
float4 o = d2 * 0.12812 + d3 * 0.07188; 
uv.xy = center - o.zw;
uv.zw = center + 1 + o.xy;
uv /= size.xyxy;
#line 59
float4 w = 0.16666666 + d * 0.5 + 0.5 * d2 - d3 * 0.3333333;
w = w.wwyy * w.zxzx;
#line 62
return w.x * tex2Dlod(s, uv.xy, 0)
+ w.y * tex2Dlod(s, uv.zy, 0)
+ w.z * tex2Dlod(s, uv.xw, 0)
+ w.w * tex2Dlod(s, uv.zw, 0);
}
#line 68
float4 sample2D_bspline_auto(sampler s, float2 iuv)
{
return sample2D_bspline(s, iuv, tex2Dsize(s));
}
#line 73
float4 sample2D_catmullrom(in sampler tex, in float2 uv, in float2 texsize)
{
float2 UV =  uv * texsize;
float2 tc = floor(UV - 0.5) + 0.5;
float2 f = UV - tc;
float2 f2 = f * f;
float2 f3 = f2 * f;
#line 81
float2 w0 = f2 - 0.5 * (f3 + f);
float2 w1 = 1.5 * f3 - 2.5 * f2 + 1.0;
float2 w3 = 0.5 * (f3 - f2);
float2 w12 = 1.0 - w0 - w3;
#line 86
float4 ws[3];
ws[0].xy = w0;
ws[1].xy = w12;
ws[2].xy = w3;
#line 91
ws[0].zw = tc - 1.0;
ws[1].zw = tc + 1.0 - w1 / w12;
ws[2].zw = tc + 2.0;
#line 95
ws[0].zw /= texsize;
ws[1].zw /= texsize;
ws[2].zw /= texsize;
#line 99
float4 ret;
ret  = tex2Dlod(tex, float2(ws[1].z, ws[0].w), 0) * ws[1].x * ws[0].y;
ret += tex2Dlod(tex, float2(ws[0].z, ws[1].w), 0) * ws[0].x * ws[1].y;
ret += tex2Dlod(tex, float2(ws[1].z, ws[1].w), 0) * ws[1].x * ws[1].y;
ret += tex2Dlod(tex, float2(ws[2].z, ws[1].w), 0) * ws[2].x * ws[1].y;
ret += tex2Dlod(tex, float2(ws[1].z, ws[2].w), 0) * ws[1].x * ws[2].y;
float normfact = 1.0 / (1.0 - (f.x - f2.x)*(f.y - f2.y) * 0.25); 
return max(0, ret * normfact);
}
#line 109
float4 sample2D_catmullrom_auto(sampler s, float2 iuv)
{
return sample2D_catmullrom(s, iuv, tex2Dsize(s));
}
#line 115
float4 sample3D_trilinear(sampler s, float3 uvw, int3 size, int atlas_idx)
{
uvw = saturate(uvw);
uvw = uvw * size - uvw;
float3 rcpsize = rcp(size);
uvw.xy = (uvw.xy + 0.5) * rcpsize.xy;
#line 122
float zlerp = frac(uvw.z);
uvw.x = (uvw.x + uvw.z - zlerp) * rcpsize.z;
#line 125
float2 uv_a = uvw.xy;
float2 uv_b = uvw.xy + float2(1.0/size.z, 0);
#line 128
int atlas_size = tex2Dsize(s).y * rcpsize.y;
uv_a.y = (uv_a.y + atlas_idx) / atlas_size;
uv_b.y = (uv_b.y + atlas_idx) / atlas_size;
#line 132
return lerp(tex2Dlod(s, uv_a, 0), tex2Dlod(s, uv_b, 0), zlerp);
}
#line 137
float4 sample3D_tetrahedral(sampler s, float3 uvw, int3 size, int atlas_idx)
{
float3 p = saturate(uvw) * (size - 1);
float3 c000 = floor(p); float3 c111 = ceil(p);
float3 f = p - c000;
#line 143
float maxv = max(max(f.x, f.y), f.z);
float minv = min(min(f.x, f.y), f.z);
float medv = dot(f, 1) - maxv - minv;
#line 147
float3 minaxis = minv == f.x ? float3(1,0,0) : (minv == f.y ? float3(0,1,0) : float3(0,0,1));
float3 maxaxis = maxv == f.x ? float3(1,0,0) : (maxv == f.y ? float3(0,1,0) : float3(0,0,1));
#line 150
int3 cmin = lerp(c111, c000, minaxis);
int3 cmax = lerp(c000, c111, maxaxis);
#line 154
float4 w = float4(1, maxv, medv, minv);
w.xyz -= w.yzw;
#line 157
return  tex2Dfetch(s, int2(c000.x + c000.z * size.x, c000.y + size.y * atlas_idx)) * w.x     
+ tex2Dfetch(s, int2(cmax.x + cmax.z * size.x, cmax.y + size.y * atlas_idx)) * w.y     
+ tex2Dfetch(s, int2(cmin.x + cmin.z * size.x, cmin.y + size.y * atlas_idx)) * w.z     
+ tex2Dfetch(s, int2(c111.x + c111.z * size.x, c111.y + size.y * atlas_idx)) * w.w;    
}
#line 163
}
#line 191 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_LAUNCHPAD.fx"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_hash.fxh"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_math.fxh"
#line 21 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_hash.fxh"
#line 22
namespace Hash
{
#line 27
uint uhash(uint x)
{
x ^= x >> 16;
x *= 0x21f0aaad;
x ^= x >> 15;
x *= 0xd35a2d97;
x ^= x >> 16;
return x;
}
#line 38
float  uint_to_unorm  (uint  u){return asfloat((u >> 9u) | 0x3F800000u) - 1.0;}
float2 uint2_to_unorm2(uint2 u){return asfloat((u >> 9u) | 0x3F800000u) - 1.0;}
float3 uint3_to_unorm3(uint3 u){return asfloat((u >> 9u) | 0x3F800000u) - 1.0;}
float4 uint4_to_unorm4(uint4 u){return asfloat((u >> 9u) | 0x3F800000u) - 1.0;}
#line 43
float2 uint_to_unorm2(uint u){return asfloat((uint2(u << 7u, u >> 9u)                     & 0x7FFF80u) | 0x3F800000u) - 1.0;}
#line 45
float3 uint_to_unorm3(uint u){return asfloat((uint3(u >> 9u,  u << 2u, u << 13u)          & 0x7FF000u) | 0x3F800000u) - 1.0;}
#line 47
float4 uint_to_unorm4(uint u){return asfloat((uint4(u >> 9u,  u >> 1u, u << 7u, u << 15u) & 0x7F8000u) | 0x3F800000u) - 1.0;}
#line 49
float  next1D(inout uint rng_state){rng_state = uhash(rng_state);return uint_to_unorm(rng_state);}
float2 next2D(inout uint rng_state){rng_state = uhash(rng_state);return uint_to_unorm2(rng_state);}
float3 next3D(inout uint rng_state){rng_state = uhash(rng_state);return uint_to_unorm3(rng_state);}
float4 next4D(inout uint rng_state){rng_state = uhash(rng_state);return uint_to_unorm4(rng_state);}
#line 54
void hash_combine(inout uint state, uint value)
{
state ^= value + 0x9e3779b9 + (state << 6) + (state >> 2);
}
#line 59
}
#line 192 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_LAUNCHPAD.fx"
#line 193
uniform uint FRAMECOUNT < source = "framecount"; >;
uniform float FRAMETIME < source = "frametime"; >;
#line 196
texture MotionTexNewA       { Width = 1920 >> 3;   Height = 1018 >> 3;   Format = RGBA16F; };
sampler sMotionTexNewA      { Texture = MotionTexNewA;   MipFilter=POINT; MagFilter=POINT; MinFilter=POINT; };
texture MotionTexNewB       { Width = 1920 >> 3;   Height = 1018 >> 3;   Format = RGBA16F; };
sampler sMotionTexNewB      { Texture = MotionTexNewB;   MipFilter=POINT; MagFilter=POINT; MinFilter=POINT; };
texture MotionTexUpscale    { Width = 1920 >> 2;   Height = 1018 >> 2;   Format = RGBA16F;};
sampler sMotionTexUpscale   { Texture = MotionTexUpscale;  MipFilter=POINT; MagFilter=POINT; MinFilter=POINT; };
texture MotionTexUpscale2   { Width = 1920 >> 1;   Height = 1018 >> 1;   Format = RGBA16F;};
sampler sMotionTexUpscale2  { Texture = MotionTexUpscale2;  MipFilter=POINT; MagFilter=POINT; MinFilter=POINT; };
#line 206
texture BlueNoiseJitterTex     < source = "iMMERSE_bluenoise.png"; > { Width = 256; Height = 256; Format = RGBA8; };
sampler	sBlueNoiseJitterTex   { Texture = BlueNoiseJitterTex; AddressU = WRAP; AddressV = WRAP; };
#line 209
texture FlowFeaturesCurrL0   { Width = 1920 >> 0;   Height = 1018 >> 0;   Format = R16F;};
texture FlowFeaturesCurrL1   { Width = 1920 >> 1;   Height = 1018 >> 1;   Format = R16F;};
texture FlowFeaturesCurrL2   { Width = 1920 >> 2;   Height = 1018 >> 2;   Format = R16F;};
texture FlowFeaturesCurrL3   { Width = 1920 >> 3;   Height = 1018 >> 3;   Format = R16F;};
texture FlowFeaturesCurrL4   { Width = 1920 >> 4;   Height = 1018 >> 4;   Format = R16F;};
texture FlowFeaturesCurrL5   { Width = 1920 >> 5;   Height = 1018 >> 5;   Format = R16F;};
texture FlowFeaturesCurrL6   { Width = 1920 >> 6;   Height = 1018 >> 6;   Format = R16F;};
texture FlowFeaturesCurrL7   { Width = 1920 >> 7;   Height = 1018 >> 7;   Format = R16F;};
sampler sFlowFeaturesCurrL0  { Texture = FlowFeaturesCurrL0; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesCurrL1  { Texture = FlowFeaturesCurrL1; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesCurrL2  { Texture = FlowFeaturesCurrL2; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesCurrL3  { Texture = FlowFeaturesCurrL3; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesCurrL4  { Texture = FlowFeaturesCurrL4; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesCurrL5  { Texture = FlowFeaturesCurrL5; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesCurrL6  { Texture = FlowFeaturesCurrL6; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesCurrL7  { Texture = FlowFeaturesCurrL7; AddressU = MIRROR; AddressV = MIRROR; };
texture FlowFeaturesPrevL0   { Width = 1920 >> 0;   Height = 1018 >> 0;   Format = R16F;};
texture FlowFeaturesPrevL1   { Width = 1920 >> 1;   Height = 1018 >> 1;   Format = R16F;};
texture FlowFeaturesPrevL2   { Width = 1920 >> 2;   Height = 1018 >> 2;   Format = R16F;};
texture FlowFeaturesPrevL3   { Width = 1920 >> 3;   Height = 1018 >> 3;   Format = R16F;};
texture FlowFeaturesPrevL4   { Width = 1920 >> 4;   Height = 1018 >> 4;   Format = R16F;};
texture FlowFeaturesPrevL5   { Width = 1920 >> 5;   Height = 1018 >> 5;   Format = R16F;};
texture FlowFeaturesPrevL6   { Width = 1920 >> 6;   Height = 1018 >> 6;   Format = R16F;};
texture FlowFeaturesPrevL7   { Width = 1920 >> 7;   Height = 1018 >> 7;   Format = R16F;};
sampler sFlowFeaturesPrevL0  { Texture = FlowFeaturesPrevL0; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesPrevL1  { Texture = FlowFeaturesPrevL1; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesPrevL2  { Texture = FlowFeaturesPrevL2; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesPrevL3  { Texture = FlowFeaturesPrevL3; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesPrevL4  { Texture = FlowFeaturesPrevL4; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesPrevL5  { Texture = FlowFeaturesPrevL5; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesPrevL6  { Texture = FlowFeaturesPrevL6; AddressU = MIRROR; AddressV = MIRROR; };
sampler sFlowFeaturesPrevL7  { Texture = FlowFeaturesPrevL7; AddressU = MIRROR; AddressV = MIRROR; };
#line 244
texture LinearDepthCurr      { Width = 1920;   Height = 1018;   Format = R16F; MipLevels = 4; };
sampler sLinearDepthCurr     { Texture = LinearDepthCurr; };
texture LinearDepthPrevLo      { Width = 1920>>3;   Height = 1018>>3;   Format = R16F; };
sampler sLinearDepthPrevLo     { Texture = LinearDepthPrevLo; };
#line 249
struct VSOUT
{
float4 vpos : SV_Position;
float2 uv   : TEXCOORD0;
};
#line 255
struct CSIN
{
uint3 groupthreadid     : SV_GroupThreadID;         
uint3 groupid           : SV_GroupID;               
uint3 dispatchthreadid  : SV_DispatchThreadID;      
uint threadid           : SV_GroupIndex;            
};
#line 276
static float2 star_kernel[19] =
{
#line 279
float2(0, 0),
#line 281
float2(-1, 2),
float2(2, 0),
float2(-1, -2),
#line 285
float2(1, 2),
float2(1, -2),
float2(-2, 0),
#line 289
float2(-3, 2),
float2(3, 2),
float2(0,-4),
#line 293
float2(0, 4),
float2(3, -2),
float2(-3, -2),
#line 297
float2(-4, 0),
float2(2, 4),
float2(2,-4),
#line 301
float2(-2, 4),
float2(4, 0),
float2(-2, -4)
};
#line 306
static const float2 daisy_kernel[33] =
{
float2(0, 0),
#line 310
float2(1,0),
float2(0.707, 0.707),
float2(0, 1),
float2(0.707, -0.707),
float2(0,-1),
float2(-0.707, 0.707),
float2(-1,0),
float2(-0.707, -0.707),
#line 319
2*float2(1,0),
2*float2(0.707, 0.707),
2*float2(0, 1),
2*float2(0.707, -0.707),
2*float2(0,-1),
2*float2(-0.707, 0.707),
2*float2(-1,0),
2*float2(-0.707, -0.707),
#line 328
3*float2(1,0),
3*float2(0.707, 0.707),
3*float2(0, 1),
3*float2(0.707, -0.707),
3*float2(0,-1),
3*float2(-0.707, 0.707),
3*float2(-1,0),
3*float2(-0.707, -0.707),
#line 337
4 * float2(1,0),
4 * float2(0.707, 0.707),
4 * float2(0, 1),
4 * float2(0.707, -0.707),
4 * float2(0,-1),
4 * float2(-0.707, 0.707),
4 * float2(-1,0),
4 * float2(-0.707, -0.707)
};
#line 352
VSOUT MainVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv);
return o;
}
#line 359
float3 get_jitter_blue(in int2 pos)
{
return tex2Dfetch(sBlueNoiseJitterTex, pos % 256).xyz;
}
#line 364
float3 showmotion(float2 motion)
{
float angle = atan2(motion.y, motion.x);
float dist = length(motion);
float3 rgb = saturate(3 * abs(2 * frac(angle / 6.283 + float3(0, -1.0/3.0, 1.0/3.0)) - 1) - 1);
#line 370
return lerp(0.5, rgb, saturate(log(1 + dist * 3000.0 / FRAMETIME )));
}
#line 373
float3 inferno_quintic(float x)
{
x = saturate( x );
float4 x1 = float4( 1.0, x, x * x, x * x * x ); 
float4 x2 = x1 * x1.w * x; 
return float3(
dot( x1.xyzw, float4( -0.027780558, +1.228188385, +0.278906882, +3.892783760 ) ) + dot( x2.xy, float2( -8.490712758, +4.069046086 ) ),
dot( x1.xyzw, float4( +0.014065206, +0.015360518, +1.605395918, -4.821108251 ) ) + dot( x2.xy, float2( +8.389314011, -4.193858954 ) ),
dot( x1.xyzw, float4( -0.019628385, +3.122510347, -5.893222355, +2.798380308 ) ) + dot( x2.xy, float2( -3.608884658, +4.324996022 ) ) );
}
#line 386
float3 gradient(float t)
{
return inferno_quintic(t);
#line 398
}
#line 413
void WriteCurrFeatureAndDepthPS(in VSOUT i, out float o0 : SV_Target0, out float o1 : SV_Target1)
{
o0 = dot(0.3333, tex2Dfetch(ColorInput, int2(i.vpos.xy)).rgb);
o0 += 0.05;
o0 *= o0;
o1 = Depth::get_linear_depth(i.uv);
#line 420
}
#line 422
void WritePrevFeaturePS(in VSOUT i, out float o : SV_Target0)
{
o = dot(0.3333, tex2Dfetch(ColorInput, int2(i.vpos.xy)).rgb);
o += 0.05;
o *= o;
#line 428
}
#line 430
void WritePrevDepthMipPS(in VSOUT i, out float o : SV_Target0)
{
o = tex2Dlod(sLinearDepthCurr, i.uv, 3).x; 
#line 434
}
#line 436
void downsample_features(sampler s0, sampler s1, float2 uv, out float f0, out float f1)
{
f0 = f1 = 0;
float wsum = 0;
float2 tx = rcp(tex2Dsize(s0));
#line 442
[unroll]for(int x = -1; x <= 1; x++)
[unroll]for(int y = -1; y <= 1; y++)
{
float2 offs = float2(x, y) * 2;
float2 offs_tl = offs + float2(-0.5, -0.5);
float2 offs_tr = offs + float2( 0.5, -0.5);
float2 offs_bl = offs + float2(-0.5,  0.5);
float2 offs_br = offs + float2( 0.5,  0.5);
#line 451
float4 g = float4(dot(offs_tl, offs_tl), dot(offs_tr, offs_tr), dot(offs_bl, offs_bl), dot(offs_br, offs_br));
g = exp(-g * 0.1);
float tg = dot(g, 1);
offs = (offs_tl * g.x + offs_tr * g.y + offs_bl * g.z + offs_br * g.w) / tg;
f0 += tg * tex2Dlod(s0, uv + offs * tx, 0).x;
f1 += tg * tex2Dlod(s1, uv + offs * tx, 0).x;
wsum += tg;
}
#line 460
f0 /= wsum; f1 /= wsum;
}
#line 463
void DownsampleFeaturesPS1(in VSOUT i, out float f0 : SV_Target0, out float f1 : SV_Target1){downsample_features(sFlowFeaturesCurrL0, sFlowFeaturesPrevL0, i.uv, f0, f1);}
void DownsampleFeaturesPS2(in VSOUT i, out float f0 : SV_Target0, out float f1 : SV_Target1){downsample_features(sFlowFeaturesCurrL1, sFlowFeaturesPrevL1, i.uv, f0, f1);}
void DownsampleFeaturesPS3(in VSOUT i, out float f0 : SV_Target0, out float f1 : SV_Target1){downsample_features(sFlowFeaturesCurrL2, sFlowFeaturesPrevL2, i.uv, f0, f1);}
void DownsampleFeaturesPS4(in VSOUT i, out float f0 : SV_Target0, out float f1 : SV_Target1){downsample_features(sFlowFeaturesCurrL3, sFlowFeaturesPrevL3, i.uv, f0, f1);}
void DownsampleFeaturesPS5(in VSOUT i, out float f0 : SV_Target0, out float f1 : SV_Target1){downsample_features(sFlowFeaturesCurrL4, sFlowFeaturesPrevL4, i.uv, f0, f1);}
void DownsampleFeaturesPS6(in VSOUT i, out float f0 : SV_Target0, out float f1 : SV_Target1){downsample_features(sFlowFeaturesCurrL5, sFlowFeaturesPrevL5, i.uv, f0, f1);}
void DownsampleFeaturesPS7(in VSOUT i, out float f0 : SV_Target0, out float f1 : SV_Target1){downsample_features(sFlowFeaturesCurrL6, sFlowFeaturesPrevL6, i.uv, f0, f1);}
#line 475
struct SophiaOptimizer
{
float2 m;
float  h;
float  beta1, beta2;
float  epsilon;
float  lr;
float  rho;
};
#line 486
SophiaOptimizer init_sophia()
{
SophiaOptimizer s;
s.m = 0;
s.h = 0;
s.beta1   = 0.965;
s.beta2   = 0.99;
s.epsilon = 1e-15;
s.lr      = 0.002;
s.rho     = 0.04;
return s;
}
#line 500
float2 update_sophia(inout SophiaOptimizer s, float2 grad)
{
s.m = lerp(grad, s.m, s.beta1);
float g2 = dot(grad, grad);
s.h = lerp(g2, s.h, s.beta2);
#line 507
float mlen = length(s.m);
float2 mnorm = s.m / (mlen + s.epsilon);
#line 510
float ratio = saturate(mlen / (s.rho * s.h + s.epsilon));
return s.lr * mnorm * ratio;
}
#line 514
float4 filter_flow(in VSOUT i, sampler s_flow, const int depth_mip = 3, const int radius = 3)
{
#line 517
float2 txflow = rcp(tex2Dsize(s_flow));
float depth = tex2Dlod(sLinearDepthCurr, i.uv, depth_mip).x;
float4 blurred = float4(0,0,0, 1e-8);
#line 521
float4 center_flow = tex2Dlod(s_flow, i.uv, 0);
#line 523
[loop]for(int y = -radius; y <= radius; y++)
[loop]for(int x = -radius; x <= radius; x++)
{
float2 tuv = i.uv + txflow * float2(x * abs(x), y * abs(y));
float4 tap = tex2Dlod(s_flow, tuv, 0);
float ew = Math::inside_screen(tuv);
float lw = log2(1.0 + max(0, center_flow.z / (tap.z + 1e-6) - 0.5)); 
float zw = exp(-abs(tap.w / (depth + 1e-6) - 1) * 64.0);
blurred += float4(tap.xyz, 1) * (lw * zw * ew + 1e-7);
}
#line 534
blurred.xyz /= blurred.w;
return float4(blurred.xyz, tex2Dlod(sLinearDepthPrevLo, i.uv + blurred.xy, 0).x);
}
#line 539
float4 filter_flow_final(in VSOUT i, sampler s_flow, const int depth_mip = 2, const int radius = 3)
{
#line 542
float2 txflow = rcp(tex2Dsize(s_flow));
float depth = tex2Dlod(sLinearDepthCurr, i.uv, depth_mip).x;
float4 blurred = 0;
#line 546
[loop]for(int y = -radius; y <= radius; y++)
[loop]for(int x = -radius; x <= radius; x++)
{
float2 tuv = i.uv + txflow * float2(x, y) * 2;
float4 tap = tex2Dlod(s_flow, tuv, 0);
float ew = Math::inside_screen(tuv);
float lw = exp2(-tap.z * 4.0); 
float zw = exp(-abs(tap.w / (depth + 1e-6) - 1) * 64.0);
blurred += float4(tap.xyz, 1) * (lw * zw * ew + 1e-7);
}
#line 557
blurred.xyz /= blurred.w;
return float4(blurred.xyz, depth);
}
#line 565
float4 calc_flow(VSOUT i,
sampler s_feature_curr,
sampler s_feature_prev,
sampler s_flow,
const int level,
const int blocksize)
{
float2 motion = 0;
#line 574
[branch]
if(level < 7)
{
motion = filter_flow(i, s_flow, 3, 4).xy;
}
#line 580
float2 texsize = tex2Dsize(s_feature_curr);
float2 texelsize = rcp(texsize);
#line 583
float randphi = get_jitter_blue(i.vpos.xy).x;
float2 sc; sincos(randphi * TAU / 6.0, sc.x, sc.y);
#line 587
float2x2 km = float2x2(sc.y * texelsize.x, -sc.x * texelsize.y, sc.x * texelsize.x,  sc.y * texelsize.y);
#line 589
float mean = 0;
float local_block[16];
#line 592
[unroll]
for(uint k = 0; k < blocksize; k++)
{
float2 tuv = i.uv + mul(star_kernel[k], km);
#line 597
float4 texels = tex2DgatherR(s_feature_curr, tuv);
float2 t = frac(tuv * texsize - 0.5);
local_block[k] = lerp(lerp(texels.w, texels.z, t.x), lerp(texels.x, texels.y, t.x), t.y);
#line 603
local_block[k] = sqrt(local_block[k]);
mean += local_block[k];
}
#line 607
mean /= blocksize;
float MAD = 0;
[unroll]
for(uint k = 0; k < blocksize; k++)
MAD += abs(mean - local_block[k]);
#line 613
SophiaOptimizer sophia = init_sophia();
#line 615
int num_steps = 4 + level;
num_steps *= 1 + 3 * OPTICAL_FLOW_Q;
sophia.lr /= 1 + 3 * OPTICAL_FLOW_Q;
#line 619
num_steps = MAD < 1.0/255.0 ? 1 : num_steps;
#line 621
float2 best_motion = motion;
float  best_loss = 1e10;
#line 624
[loop]
for(int j = 0; j < num_steps; j++)
{
const float delta = 0.01;
float3 loss = 0;
#line 630
float4 prevv = 0;
float3 altloss = 0;
#line 633
[unroll]
for(uint k = 0; k < blocksize; k++)
{
float2 tuv = i.uv + motion + mul(star_kernel[k], km);
float3 f;
#line 639
float4 texels = tex2DgatherR(s_feature_prev, tuv);
float2 t = frac(tuv * texsize - 0.5);
float4 flerp = lerp(texels.wxwx, texels.zyzy, float4(t.xx, t.xx + delta));
f = lerp(flerp.xzx, flerp.ywy, float3(t.yy, t.y + delta));
#line 648
f = sqrt(f);
loss += abs(local_block[k] - f);
}
#line 652
[branch]
if(loss.x < best_loss * 0.9999)
{
best_loss = loss.x;
best_motion = motion;
}
else
{
j++;
}
#line 663
float2 grad = (loss.yz - loss.x) * texsize / delta;
#line 665
float2 gradstep = 0;
if(OPTICAL_FLOW_OPT == 0)
gradstep = update_sophia(sophia, grad);
else
gradstep = grad / (1e-15 + dot(grad, grad)) * loss.x;
#line 671
gradstep *= saturate(0.5 * rsqrt(1e-8 + dot(gradstep * texsize, gradstep * texsize)));
motion -= gradstep;
}
#line 675
float depth_key = 0;
#line 677
[branch]
if(level == 0) 
{
depth_key = tex2Dlod(sLinearDepthCurr, i.uv, 2).x; 
}
else 
{
depth_key = tex2Dlod(sLinearDepthPrevLo, i.uv + motion, 0).x;
}
#line 687
best_loss = best_loss / (0.01 + MAD);
best_loss += saturate(1 - MAD * 255.0) * 0.5; 	
#line 690
float4 curr_layer = float4(best_motion, best_loss, depth_key);
return curr_layer;
}
#line 694
void FilterFlowPS(in VSOUT i, out float4 o : SV_Target0){o = filter_flow(i, sMotionTexNewB, 3, 3);}
void BlockMatchingPassNewPS7(in VSOUT i, out float4 o : SV_Target0){o = calc_flow(i, sFlowFeaturesCurrL7, sFlowFeaturesPrevL7, sMotionTexNewA, 7, 10);}
void BlockMatchingPassNewPS6(in VSOUT i, out float4 o : SV_Target0){o = calc_flow(i, sFlowFeaturesCurrL6, sFlowFeaturesPrevL6, sMotionTexNewA, 6, 10);}
void BlockMatchingPassNewPS5(in VSOUT i, out float4 o : SV_Target0){o = calc_flow(i, sFlowFeaturesCurrL5, sFlowFeaturesPrevL5, sMotionTexNewA, 5, 10);}
void BlockMatchingPassNewPS4(in VSOUT i, out float4 o : SV_Target0){o = calc_flow(i, sFlowFeaturesCurrL4, sFlowFeaturesPrevL4, sMotionTexNewA, 4, 10);}
void BlockMatchingPassNewPS3(in VSOUT i, out float4 o : SV_Target0){o = calc_flow(i, sFlowFeaturesCurrL3, sFlowFeaturesPrevL3, sMotionTexNewA, 3, 10);}
void BlockMatchingPassNewPS2(in VSOUT i, out float4 o : SV_Target0){o = calc_flow(i, sFlowFeaturesCurrL2, sFlowFeaturesPrevL2, sMotionTexNewA, 2, 13);}
void BlockMatchingPassNewPS1(in VSOUT i, out float4 o : SV_Target0){o = calc_flow(i, sFlowFeaturesCurrL1, sFlowFeaturesPrevL1, sMotionTexNewA, 1, 16);}
void BlockMatchingPassNewPS0(in VSOUT i, out float4 o : SV_Target0){o = calc_flow(i, sFlowFeaturesCurrL0, sFlowFeaturesPrevL0, sMotionTexNewA, 0, 16);}
#line 704
void UpscaleFilter8to4PS(in VSOUT i, out float4 o : SV_Target0){o = filter_flow_final(i, sMotionTexNewB, 2, 3);}
void UpscaleFilter4to2PS(in VSOUT i, out float4 o : SV_Target0){o = filter_flow_final(i, sMotionTexUpscale, 1, 2);}
void UpscaleFilter2to1PS(in VSOUT i, out float4 o : SV_Target0){o = filter_flow_final(i, sMotionTexUpscale2, 0, 1);}
#line 712
void NormalsPS(in VSOUT i, out float4 o : SV_Target0)
{
const float2 dirs[9] =
{
BUFFER_PIXEL_SIZE_DLSS * float2(-1,-1),
BUFFER_PIXEL_SIZE_DLSS * float2(0,-1),
BUFFER_PIXEL_SIZE_DLSS * float2(1,-1),
BUFFER_PIXEL_SIZE_DLSS * float2(1,0),
BUFFER_PIXEL_SIZE_DLSS * float2(1,1),
BUFFER_PIXEL_SIZE_DLSS * float2(0,1),
BUFFER_PIXEL_SIZE_DLSS * float2(-1,1),
BUFFER_PIXEL_SIZE_DLSS * float2(-1,0),
BUFFER_PIXEL_SIZE_DLSS * float2(-1,-1)
};
#line 727
float z_center = Depth::get_linear_depth(i.uv);
float3 center_pos = Camera::uv_to_proj(i.uv, Camera::depth_to_z(z_center));
#line 731
float2 z_prev;
z_prev.x = Depth::get_linear_depth(i.uv + dirs[0]);
z_prev.y = Depth::get_linear_depth(i.uv + dirs[0] * 2);
float3 dv_prev = Camera::uv_to_proj(i.uv + dirs[0], Camera::depth_to_z(z_prev.x)) - center_pos;
#line 736
float4 best_normal = float4(0,0,0,100000);
float4 weighted_normal = 0;
#line 739
[unroll]
for(int j = 1; j < 9; j++)
{
float2 z_curr;
z_curr.x = Depth::get_linear_depth(i.uv + dirs[j]);
z_curr.y = Depth::get_linear_depth(i.uv + dirs[j] * 2);
#line 746
float3 dv_curr = Camera::uv_to_proj(i.uv + dirs[j], Camera::depth_to_z(z_curr.x)) - center_pos;
float3 temp_normal = cross(dv_curr, dv_prev);
#line 749
float2 z_guessed = 2 * float2(z_prev.x, z_curr.x) - float2(z_prev.y, z_curr.y);
float error = dot(1, abs(z_guessed - z_center));
#line 752
float w = rcp(dot(temp_normal, temp_normal));
w *= rcp(error * error + exp2(-32.0));
#line 755
weighted_normal += float4(temp_normal, 1) * w;
best_normal = error < best_normal.w ? float4(temp_normal, error) : best_normal;
#line 758
z_prev = z_curr;
dv_prev = dv_curr;
}
#line 762
float3 normal = weighted_normal.w < 1.0 ? best_normal.xyz : weighted_normal.xyz;
#line 764
normal *= rsqrt(dot(normal, normal) + 1e-8);
#line 766
o = Math::octahedral_enc(-normal).xyxy;
}
#line 770
texture SmoothNormalsTempTex0  { Width = 1920/2;   Height = 1018/2;   Format = RGBA16F;  };
sampler sSmoothNormalsTempTex0 { Texture = SmoothNormalsTempTex0; MinFilter = POINT; MagFilter = POINT; MipFilter = POINT; };
#line 773
texture SmoothNormalsTempTex1  { Width = 1920/2;   Height = 1018/2;   Format = RGBA16F;  };
sampler sSmoothNormalsTempTex1 { Texture = SmoothNormalsTempTex1; MinFilter = POINT; MagFilter = POINT; MipFilter = POINT;  };
#line 776
texture SmoothNormalsTempTex2  < pooled = true; > { Width = 1920;   Height = 1018;   Format = RGBA16;  };
sampler sSmoothNormalsTempTex2 { Texture = SmoothNormalsTempTex2; MinFilter = POINT; MagFilter = POINT; MipFilter = POINT;  };
#line 779
void SmoothNormalsMakeGbufPS(in VSOUT i, out float4 o : SV_Target0)
{
o.xyz = Deferred::get_normals(i.uv);
o.w = Camera::depth_to_z(Depth::get_linear_depth(i.uv));
}
#line 785
void get_gbuffer(in sampler s, in float2 uv, out float3 p, out float3 n)
{
float4 t = tex2Dlod(s, uv, 0);
n = t.xyz;
p = Camera::uv_to_proj(uv, t.w);
}
#line 792
void get_gbuffer_hi(in float2 uv, out float3 p, out float3 n)
{
n = Deferred::get_normals(uv);
p = Camera::uv_to_proj(uv);
}
#line 798
float sample_distribution(float x, int iteration)
{
if(!iteration) return x * sqrt(x);
return x;
#line 804
}
#line 806
float sample_pdf(float x, int iteration)
{
if(!iteration) return 1.5 * sqrt(x);
return 1;
#line 812
}
#line 814
float2x3 to_tangent(float3 n)
{
bool bestside = n.z < n.y;
float3 n2 = bestside ? n.xzy : n;
float3 k = (-n2.xxy * n2.xyy) * rcp(1.0 + n2.z) + float3(1, 0, 1);
float3 u = float3(k.xy, -n2.x);
float3 v = float3(k.yz, -n2.y);
u = bestside ? u.xzy : u;
v = bestside ? v.xzy : v;
return float2x3(u, v);
}
#line 826
float4 smooth_normals_mkii(in VSOUT i, int iteration, sampler sGbuffer)
{
int num_dirs = iteration ? 6 : 4;
int num_steps = iteration ? 3 : 6;
float radius_mult = iteration ? 0.2 : 1.0;
#line 832
float2 angle_tolerance = float2(45.0, 30.0); 
#line 834
radius_mult *= 0.2 * 0.2;
#line 836
float4 rotator = Math::get_rotator(TAU / num_dirs);
float2 kernel_dir; sincos(TAU / num_dirs + TAU / 12.0, kernel_dir.x, kernel_dir.y);
#line 839
float3 p, n;
get_gbuffer_hi(i.uv, p, n);
float2x3 kernel_matrix = to_tangent(n);
#line 843
float4 bin_front = float4(n, 1) * 0.001;
float4 bin_back = float4(n, 1) * 0.001;
#line 846
float2 sigma_n = cos(radians(angle_tolerance));
#line 848
[loop]
for(int dir = 0; dir < num_dirs; dir++)
{
[loop]
for(int stp = 0; stp < num_steps; stp++)
{
float fi = float(stp + 1.0) / num_steps;
#line 856
float r = sample_distribution(fi, iteration);
float ipdf = sample_pdf(fi, iteration);
#line 859
float2 sample_dir = normalize(Camera::proj_to_uv(p + 0.1 * mul(kernel_dir, kernel_matrix)) - i.uv);
#line 863
float2 sample_uv = i.uv + sample_dir * r * radius_mult;
if(!Math::inside_screen(sample_uv)) break;
#line 866
float3 sp, sn;
get_gbuffer(sGbuffer, sample_uv, sp, sn);
#line 869
float ndotn = dot(sn, n);
float plane_distance = abs(dot(sp - p, n)) + abs(dot(p - sp, sn));
#line 872
float wn = smoothstep(sigma_n.x, sigma_n.y, ndotn);
float wz = exp2(-plane_distance*plane_distance * 10.0);
float wd = exp2(-dot(p - sp, p - sp));
#line 876
float w = wn * wz * wd;
#line 889
float d2 = (ndotn * dot(p - sp,  n) - dot(p - sp, sn)) / (ndotn*ndotn - 1);
float d1 = (ndotn * dot(p - sp, sn) - dot(p - sp,  n)) / (1 - ndotn*ndotn);
#line 893
float3 hit1 = p + n * d1;
float3 hit2 = sp + sn * d2;
#line 897
float3 middle = (hit1 + hit2) * 0.5;
float side = dot(middle - p, n);
#line 901
float front_weight = saturate(side * 3.0 + 0.5);
float back_weight = 1 - front_weight;
#line 904
if(ndotn > 0.9999) 
{
front_weight = 1;
back_weight = 1;
}
#line 910
bin_front += float4(sn, 1) * ipdf * w * front_weight;
bin_back += float4(sn, 1) * ipdf * w * back_weight;
#line 913
if(w < 0.01) break;
}
#line 916
kernel_dir = Math::rotate_2D(kernel_dir, rotator);
}
#line 919
bin_back.xyz = normalize(bin_back.xyz);
bin_front.xyz = normalize(bin_front.xyz);
#line 923
float bal = bin_back.w / (bin_front.w + bin_back.w);
bal = smoothstep(0, 1, bal);
bal = smoothstep(0, 1, bal);
#line 927
float3 best_bin = lerp(bin_front.xyz, bin_back.xyz, bal);
return float4(((best_bin) * rsqrt(max(1e-8, dot((best_bin), (best_bin))))), p.z);
}
#line 931
VSOUT SmoothNormalsVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv);
if(!ENABLE_SMOOTH_NORMALS) o.vpos = -100000; 
return o;
}
#line 939
void SmoothNormalsPass0PS(in VSOUT i, out float4 o : SV_Target0)
{
o = smooth_normals_mkii(i, 0, sSmoothNormalsTempTex0);
}
#line 944
void SmoothNormalsPass1PS(in VSOUT i, out float4 o : SV_Target0)
{
float3 n = -smooth_normals_mkii(i, 1, sSmoothNormalsTempTex1).xyz;
float3 orig_n = n;
#line 949
[branch]
if(ENABLE_TEXTURED_NORMALS)
{
float3 p = Camera::uv_to_proj(i.uv);
float3 e_y = (p - Camera::uv_to_proj(i.uv + BUFFER_PIXEL_SIZE_DLSS * float2(0, 2)));
float3 e_x = (p - Camera::uv_to_proj(i.uv + BUFFER_PIXEL_SIZE_DLSS * float2(2, 0)));
e_y = normalize(cross(n, e_y));
e_x = normalize(cross(n, e_x));
#line 958
float radius_scale = (0.5 + 1000.0 * 0.01 * saturate(TEXTURED_NORMALS_RADIUS)) / 50.0;
#line 960
float3 v_y = e_y * radius_scale;
float3 v_x = e_x * radius_scale;
#line 963
float3 center_color = Deferred::get_albedo(i.uv);
float center_luma = dot(center_color, float3(0.2126, 0.7152, 0.0722));
#line 966
float3 center_p_height = p + center_luma * n;
float3 summed_normal = n * 0.01;
#line 969
int octaves = TEXTURED_NORMALS_QUALITY;
#line 971
float total_luma = center_luma;
#line 973
[loop]
for(int octave = 0; octave < octaves; octave++)
{
float3 height[4];
float4 plane_dist;
#line 979
float2 axis; sincos(HALF_PI * octave / float(octaves), axis.y, axis.x); 
const float4 next_axis = Math::get_rotator(HALF_PI);
#line 982
float fi = exp2(octave);
axis *= fi;
#line 985
[unroll]
for(int a = 0; a < 4; a++)
{
float3 virtual_p = p + v_x * axis.x + v_y * axis.y;
float2 uv = Camera::proj_to_uv(virtual_p);
float3 actual_p = Camera::uv_to_proj(uv);
#line 992
float3 tap_color = Deferred::get_albedo(uv);
float tap_luma = dot(tap_color, float3(0.2126, 0.7152, 0.0722));
total_luma += tap_luma;
#line 996
height[a] = virtual_p + tap_luma * n;
plane_dist[a] = abs(dot(n, actual_p - p));
#line 999
axis = Math::rotate_2D(axis, next_axis);
}
#line 1002
[unroll]
for(int j = 0; j < 4; j++)
{
uint this_idx = j;
uint next_idx = (j + 1) % 4;
#line 1008
float w = rcp(0.05 + plane_dist[this_idx] + plane_dist[next_idx]);
float3 curr_n = -cross(height[this_idx] - center_p_height, height[next_idx] - center_p_height);
curr_n *= rsqrt(1e-5 + dot(curr_n, curr_n));
w *= exp2(-octave);
summed_normal += curr_n * w;
}
}
#line 1016
summed_normal.xyz = ((summed_normal.xyz) * rsqrt(max(1e-8, dot((summed_normal.xyz), (summed_normal.xyz)))));
float3 halfvec = n - summed_normal.xyz * 0.95;
halfvec.xyz /= lerp(total_luma, 0.5,  0.5);
n += halfvec * saturate(TEXTURED_NORMALS_INTENSITY * TEXTURED_NORMALS_INTENSITY * TEXTURED_NORMALS_INTENSITY) * 10.0;
n = normalize(n);
}
#line 1023
o.xy = Math::octahedral_enc(n);
o.zw = Math::octahedral_enc(orig_n);
}
#line 1027
void CopyNormalsPS(in VSOUT i, out float4 o : SV_Target0)
{
o = tex2D(sSmoothNormalsTempTex2, i.uv);
}
#line 1036
float3 srgb_to_AgX(float3 srgb)
{
float3x3 toagx = float3x3(0.842479, 0.0784336, 0.0792237,
0.042328, 0.8784686, 0.0791661,
0.042376, 0.0784336, 0.8791430);
return mul(toagx, srgb);
}
#line 1044
float3 AgX_to_srgb(float3 AgX)
{
float3x3 fromagx = float3x3(1.19688,  -0.0980209, -0.0990297,
-0.0528969, 1.1519,    -0.0989612,
-0.0529716, -0.0980435, 1.15107);
return mul(fromagx, AgX);
}
#line 1052
float3 cone_overlap(float3 c)
{
float k = 0.99 * 0.33;
float2 f = float2(1 - 2 * k, k);
float3x3 m = float3x3(f.xyy, f.yxy, f.yyx);
return mul(c, m);
}
#line 1060
float3 cone_overlap_inv(float3 c)
{
float k = 0.99 * 0.33;
float2 f = float2(k - 1, k) * rcp(3 * k - 1);
float3x3 m = float3x3(f.xyy, f.yxy, f.yyx);
return mul(c, m);
}
#line 1068
float3 unpack_hdr_rtgi(float3 color)
{
color  = saturate(color);
color = cone_overlap(color);
color = color*0.283799*((2.52405+color)*color);
#line 1074
color = color * rcp(1.04 - saturate(color));
return color;
}
#line 1078
float3 pack_hdr_rtgi(float3 color)
{
color =  1.04 * color * rcp(color + 1.0);
#line 1082
color  = saturate(color);
color = 1.14374*(-0.126893*color+sqrt(color));
color = cone_overlap_inv(color);
return color;
}
#line 1088
float3 sdr_to_hdr(float3 c)
{
return unpack_hdr_rtgi(c);
}
#line 1093
float3 hdr_to_sdr(float3 c)
{
return pack_hdr_rtgi(c);
}
#line 1098
float get_sdr_luma(float3 c)
{
c = c*0.283799*((2.52405+c)*c);
float lum = dot(c, float3(0.2125, 0.7154, 0.0721));
lum = 1.14374*(-0.126893*(lum)+sqrt(lum));
return lum;
}
#line 1106
float2 downsample_kuwahara(const sampler s0, float2 uv, const bool horizontal)
{
const float2 texelsize = rcp(tex2Dsize(s0, 0));
float2 axis = horizontal ? float2(texelsize.x, 0) : float2(0, texelsize.y);
#line 1111
float4 mL = 0;
float4 mR = 0;
float2 wsum = 0;
#line 1115
[unroll]
for(int j = -11; j <= 11; j++)
{
float2 off = j * axis;
float2 tuv = uv + off;
float w = exp(-j*j/121.0 * 3.0) * Math::inside_screen(tuv);
#line 1122
float2 t = tex2Dlod(s0, tuv, 0).xy;
#line 1124
w *= j == 0 ? 0.5 : 1;
mL += float4(t, t * t) * w * (j <= 0);
mR += float4(t, t * t) * w * (j >= 0);
wsum += w * float2(j <= 0, j >= 0);
}
#line 1130
mL /= wsum.x;
mR /= wsum.y;
float vL = max(0, mL.w - mL.y * mL.y); 
float vR = max(0, mR.w - mR.y * mR.y);
float2 w = rcp(0.25 + sqrt(float2(vL, vR)));
return (mL.xy * w.x + mR.xy * w.y) / (w.x + w.y);
}
#line 1168
texture AlbedoPyramidL0     { Width = (1920 / 2)>>0; Height = (1018 / 2)>>0; Format = RG16F;};
sampler sAlbedoPyramidL0    { Texture = AlbedoPyramidL0;};
#line 1171
texture AlbedoPyramidL1Tmp  { Width = (1920 / 2)>>1; Height = (1018 / 2)>>0; Format = RG16F;}; 
sampler sAlbedoPyramidL1Tmp { Texture = AlbedoPyramidL1Tmp;};
texture AlbedoPyramidL1     { Width = (1920 / 2)>>1; Height = (1018 / 2)>>1; Format = RG16F;};
sampler sAlbedoPyramidL1    { Texture = AlbedoPyramidL1;};
void DownsamplePS0H(in VSOUT i, out float2 o : SV_Target0){o = downsample_kuwahara(sAlbedoPyramidL0,    i.uv, true);}
void DownsamplePS0V(in VSOUT i, out float2 o : SV_Target0){o = downsample_kuwahara(sAlbedoPyramidL1Tmp, i.uv, false);}
#line 1179
texture AlbedoPyramidL2Tmp  { Width = (1920 / 2)>>2; Height = (1018 / 2)>>1; Format = RG16F;}; 
sampler sAlbedoPyramidL2Tmp { Texture = AlbedoPyramidL2Tmp;};
texture AlbedoPyramidL2     { Width = (1920 / 2)>>2; Height = (1018 / 2)>>2; Format = RG16F;};
sampler sAlbedoPyramidL2    { Texture = AlbedoPyramidL2;};
void DownsamplePS1H(in VSOUT i, out float2 o : SV_Target0){o = downsample_kuwahara(sAlbedoPyramidL1,    i.uv, true);}
void DownsamplePS1V(in VSOUT i, out float2 o : SV_Target0){o = downsample_kuwahara(sAlbedoPyramidL2Tmp, i.uv, false);}
#line 1187
texture AlbedoPyramidL3Tmp  { Width = (1920 / 2)>>3; Height = (1018 / 2)>>2; Format = RG16F;}; 
sampler sAlbedoPyramidL3Tmp { Texture = AlbedoPyramidL3Tmp;};
texture AlbedoPyramidL3     { Width = (1920 / 2)>>3; Height = (1018 / 2)>>3; Format = RG16F;};
sampler sAlbedoPyramidL3    { Texture = AlbedoPyramidL3;};
void DownsamplePS2H(in VSOUT i, out float2 o : SV_Target0){o = downsample_kuwahara(sAlbedoPyramidL2,    i.uv, true);}
void DownsamplePS2V(in VSOUT i, out float2 o : SV_Target0){o = downsample_kuwahara(sAlbedoPyramidL3Tmp, i.uv, false);}
#line 1195
texture AlbedoPyramidL4Tmp  { Width = (1920 / 2)>>4; Height = (1018 / 2)>>3; Format = RG16F;}; 
sampler sAlbedoPyramidL4Tmp { Texture = AlbedoPyramidL4Tmp;};
texture AlbedoPyramidL4     { Width = (1920 / 2)>>4; Height = (1018 / 2)>>4; Format = RG16F;};
sampler sAlbedoPyramidL4    { Texture = AlbedoPyramidL4;};
void DownsamplePS3H(in VSOUT i, out float2 o : SV_Target0){o = downsample_kuwahara(sAlbedoPyramidL3,    i.uv, true);}
void DownsamplePS3V(in VSOUT i, out float2 o : SV_Target0){o = downsample_kuwahara(sAlbedoPyramidL4Tmp, i.uv, false);}
#line 1203
texture AlbedoPyramidL5Tmp  { Width = (1920 / 2)>>5; Height = (1018 / 2)>>4; Format = RG16F;}; 
sampler sAlbedoPyramidL5Tmp { Texture = AlbedoPyramidL5Tmp;};
texture AlbedoPyramidL5     { Width = (1920 / 2)>>5; Height = (1018 / 2)>>5; Format = RG16F;};
sampler sAlbedoPyramidL5    { Texture = AlbedoPyramidL5;};
void DownsamplePS4H(in VSOUT i, out float2 o : SV_Target0){o = downsample_kuwahara(sAlbedoPyramidL4,    i.uv, true);}
void DownsamplePS4V(in VSOUT i, out float2 o : SV_Target0){o = downsample_kuwahara(sAlbedoPyramidL5Tmp, i.uv, false);}
#line 1243
texture FusedAlbedoPyramid    { Width = (1920 / 2)>>0; Height = (1018 / 2)>>0; Format = RG16F;};
sampler sFusedAlbedoPyramid    { Texture = FusedAlbedoPyramid;};
#line 1246
void InitAlbedoPyramidPS(in VSOUT i, out float2 o : SV_Target0)
{
float3 hdr = sdr_to_hdr(tex2D(ColorInput, i.uv).rgb);
float loglum = dot(0.3333, log2(max(1e-3, hdr)));
o.y = loglum; 
o.x = -loglum;
}
#line 1254
float func(float a, float b, float levelnorm)
{
float res = abs(a - b) / max3(a, b, 1);
res *= lerp(0.02, 0.3, 1.0);
return saturate(res / (1 + res));
}
#line 1261
void FusePS(in VSOUT i, out float2 o : SV_Target0)
{
float2 G[5 + 1];
G[0] = tex2D(sAlbedoPyramidL0, i.uv).xy;
#line 1266
G[1] = tex2D(sAlbedoPyramidL1, i.uv).xy;
#line 1269
G[2] = tex2D(sAlbedoPyramidL2, i.uv).xy;
#line 1272
G[3] = tex2D(sAlbedoPyramidL3, i.uv).xy;
#line 1275
G[4] = Texture::sample2D_bspline(sAlbedoPyramidL4, i.uv, (BUFFER_SCREEN_SIZE / 2) >> 4).xy;
#line 1278
G[5] = Texture::sample2D_bspline(sAlbedoPyramidL5, i.uv, (BUFFER_SCREEN_SIZE / 2) >> 5).xy;
#line 1293
float2 bias = G[5]; 
#line 1295
[unroll]
for(int j = 5 - 1; j >= 0; j--)
{
bias = lerp(bias, G[j], func(G[j].y, bias.y, float(j) / 5));
}
#line 1301
o.x = bias.x;
o.y = dot(0.3333, tex2D(ColorInput, i.uv).rgb);
}
#line 1305
void AlbedoMainPS(in VSOUT i, out float3 o : SV_Target0)
{
float4 m = 0;
float ws = 0.0;
#line 1310
[unroll]for(int y = -1; y <= 1; y++)
[unroll]for(int x = -1; x <= 1; x++)
{
float2 t = tex2D(sFusedAlbedoPyramid, i.uv, int2(x, y)).xy;
float w = exp(-(x * x + y * y));
m += float4(t.y, t.y * t.y, t.y * t.x, t.x) * w;
ws += w;
}
#line 1319
m /= ws;
float a = (m.z - m.x * m.w) / (max(m.y - m.x * m.x, 0.0) + 0.00001);
float b = m.w - a * m.x;
#line 1323
float guide = dot(0.3333, tex2D(ColorInput, i.uv).rgb);
float bias = a * guide + b;
#line 1326
float target = 0.18;
float3 target_hdr = sdr_to_hdr(target.xxx);
float target_loglum = dot(0.3333, log2(max(1e-3, target_hdr)));
bias += target_loglum;
#line 1331
o = bias.x * 0.05 + 0.5;
#line 1333
o = tex2D(ColorInput, i.uv).rgb;
o = sdr_to_hdr(o);
#line 1336
o *= exp2(bias);
#line 1343
float3 L = 1; 
float3 C = o.rgb;
float p = 0.5; 
#line 1349
{
float3 reverse_multiscattered = C / (L + C * p);
o = normalize(reverse_multiscattered + 1e-3) * length(o); 
}
}
#line 1439
technique MartysMods_Launchpad
<
ui_label = "iMMERSE: Launchpad (enable and move to the top!)";
ui_tooltip =
"                           MartysMods - Launchpad                             \n"
"                   MartysMods Epic ReShade Effects (iMMERSE)                  \n"
"______________________________________________________________________________\n"
"\n"
#line 1448
"Launchpad is a catch-all setup shader that prepares various data for the other\n"
"effects. Enable this effect and move it to the top of the effect list.        \n"
"\n"
"\n"
"Visit https://martysmods.com for more information.                            \n"
"\n"
"______________________________________________________________________________";
>
{
#line 1460
pass {VertexShader = MainVS;PixelShader = WriteCurrFeatureAndDepthPS;RenderTarget0 = FlowFeaturesCurrL0;RenderTarget1 = LinearDepthCurr; }
pass {VertexShader = MainVS;PixelShader = DownsampleFeaturesPS1;RenderTarget0 = FlowFeaturesCurrL1;RenderTarget1 = FlowFeaturesPrevL1;}
pass {VertexShader = MainVS;PixelShader = DownsampleFeaturesPS2;RenderTarget0 = FlowFeaturesCurrL2;RenderTarget1 = FlowFeaturesPrevL2;}
pass {VertexShader = MainVS;PixelShader = DownsampleFeaturesPS3;RenderTarget0 = FlowFeaturesCurrL3;RenderTarget1 = FlowFeaturesPrevL3;}
pass {VertexShader = MainVS;PixelShader = DownsampleFeaturesPS4;RenderTarget0 = FlowFeaturesCurrL4;RenderTarget1 = FlowFeaturesPrevL4;}
pass {VertexShader = MainVS;PixelShader = DownsampleFeaturesPS5;RenderTarget0 = FlowFeaturesCurrL5;RenderTarget1 = FlowFeaturesPrevL5;}
pass {VertexShader = MainVS;PixelShader = DownsampleFeaturesPS6;RenderTarget0 = FlowFeaturesCurrL6;RenderTarget1 = FlowFeaturesPrevL6;}
pass {VertexShader = MainVS;PixelShader = DownsampleFeaturesPS7;RenderTarget0 = FlowFeaturesCurrL7;RenderTarget1 = FlowFeaturesPrevL7;}
pass {VertexShader = MainVS;PixelShader = BlockMatchingPassNewPS7;	RenderTarget = MotionTexNewB;}
pass {VertexShader = MainVS;PixelShader = FilterFlowPS;	RenderTarget = MotionTexNewA;}
pass {VertexShader = MainVS;PixelShader = BlockMatchingPassNewPS6;	RenderTarget = MotionTexNewB;}
pass {VertexShader = MainVS;PixelShader = FilterFlowPS;	RenderTarget = MotionTexNewA;}
pass {VertexShader = MainVS;PixelShader = BlockMatchingPassNewPS5;	RenderTarget = MotionTexNewB;}
pass {VertexShader = MainVS;PixelShader = FilterFlowPS;	RenderTarget = MotionTexNewA;}
pass {VertexShader = MainVS;PixelShader = BlockMatchingPassNewPS4;	RenderTarget = MotionTexNewB;}
pass {VertexShader = MainVS;PixelShader = FilterFlowPS;	RenderTarget = MotionTexNewA;}
pass {VertexShader = MainVS;PixelShader = BlockMatchingPassNewPS3;	RenderTarget = MotionTexNewB;}
pass {VertexShader = MainVS;PixelShader = FilterFlowPS;	RenderTarget = MotionTexNewA;}
pass {VertexShader = MainVS;PixelShader = BlockMatchingPassNewPS2;	RenderTarget = MotionTexNewB;}
pass {VertexShader = MainVS;PixelShader = FilterFlowPS;	RenderTarget = MotionTexNewA;}
pass {VertexShader = MainVS;PixelShader = BlockMatchingPassNewPS1;	RenderTarget = MotionTexNewB;}
pass {VertexShader = MainVS;PixelShader = FilterFlowPS;	RenderTarget = MotionTexNewA;}
pass {VertexShader = MainVS;PixelShader = BlockMatchingPassNewPS0;	RenderTarget = MotionTexNewB;}
pass {VertexShader = MainVS;PixelShader = UpscaleFilter8to4PS;	RenderTarget = MotionTexUpscale;}
pass {VertexShader = MainVS;PixelShader = UpscaleFilter4to2PS;	RenderTarget = MotionTexUpscale2;}
pass {VertexShader = MainVS;PixelShader = UpscaleFilter2to1PS;	RenderTarget = Deferred::MotionVectorsTex;}
pass {VertexShader = MainVS;PixelShader = WritePrevFeaturePS;RenderTarget0 = FlowFeaturesPrevL0;}
pass {VertexShader = MainVS;PixelShader = WritePrevDepthMipPS;RenderTarget0 = LinearDepthPrevLo;}
#line 1490
pass    {VertexShader = MainVS;PixelShader = InitAlbedoPyramidPS;  RenderTarget0 = AlbedoPyramidL0; }
#line 1492
pass    {VertexShader = MainVS;PixelShader = DownsamplePS0H;  RenderTarget0 = AlbedoPyramidL1Tmp; }
pass    {VertexShader = MainVS;PixelShader = DownsamplePS0V;  RenderTarget0 = AlbedoPyramidL1; }
#line 1496
pass    {VertexShader = MainVS;PixelShader = DownsamplePS1H;  RenderTarget0 = AlbedoPyramidL2Tmp; }
pass    {VertexShader = MainVS;PixelShader = DownsamplePS1V;  RenderTarget0 = AlbedoPyramidL2; }
#line 1500
pass    {VertexShader = MainVS;PixelShader = DownsamplePS2H;  RenderTarget0 = AlbedoPyramidL3Tmp; }
pass    {VertexShader = MainVS;PixelShader = DownsamplePS2V;  RenderTarget0 = AlbedoPyramidL3; }
#line 1504
pass    {VertexShader = MainVS;PixelShader = DownsamplePS3H;  RenderTarget0 = AlbedoPyramidL4Tmp; }
pass    {VertexShader = MainVS;PixelShader = DownsamplePS3V;  RenderTarget0 = AlbedoPyramidL4; }
#line 1508
pass    {VertexShader = MainVS;PixelShader = DownsamplePS4H;  RenderTarget0 = AlbedoPyramidL5Tmp; }
pass    {VertexShader = MainVS;PixelShader = DownsamplePS4V;  RenderTarget0 = AlbedoPyramidL5; }
#line 1527
pass    {VertexShader = MainVS; PixelShader = FusePS; RenderTarget0 = FusedAlbedoPyramid; }
pass    {VertexShader = MainVS; PixelShader = AlbedoMainPS; RenderTarget = Deferred::AlbedoTex;}
#line 1531
pass {VertexShader = MainVS;PixelShader = NormalsPS; RenderTarget = Deferred::NormalsTexV3; }
pass {VertexShader = SmoothNormalsVS;PixelShader = SmoothNormalsMakeGbufPS;  RenderTarget = SmoothNormalsTempTex0;}
pass {VertexShader = SmoothNormalsVS;PixelShader = SmoothNormalsPass0PS;  RenderTarget = SmoothNormalsTempTex1;}
pass {VertexShader = SmoothNormalsVS;PixelShader = SmoothNormalsPass1PS;  RenderTarget = SmoothNormalsTempTex2;}
pass {VertexShader = SmoothNormalsVS;PixelShader = CopyNormalsPS; RenderTarget = Deferred::NormalsTexV3; }
#line 1551
}

