#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_FILMGRAIN.fx"
#line 47
uniform int FILM_MODE <
ui_type = "combo";
ui_label = "Film Mode";
ui_items = "Monochrome\0Color\0";
ui_category = "Global";
> = 0;
#line 57
uniform int GRAIN_TYPE <
ui_type = "combo";
ui_label = "Grain Type";
ui_items = "Analog Film Grain\0Digital Sensor Noise\0";
ui_category = "Global";
> = 0;
#line 67
uniform float GRAIN_INTENSITY <
ui_label = "Intensity";
ui_type = "drag";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "Global";
> = 0.85;
#line 75
uniform bool ANIMATE <
ui_label = "Animate Grain";
ui_category = "Global";
> = false;
#line 80
uniform float GRAIN_SAT <
ui_type = "drag";
ui_label = "Noise Saturation";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "Parameters for ISO Noise";
> = 1.0;
#line 88
uniform bool GRAIN_USE_BAYER <
ui_label = "Bayer Matrix RGB Weighting";
ui_tooltip = "Camera Sensors allocate twice as much area to green pixel\n"
"thus reducing the noise sigma by sqrt(2) for green.      \n"
"This causes the grain to adopt a pink hue in dark areas  \n";
ui_category = "Parameters for ISO Noise";
> = true;
#line 96
uniform float GRAIN_SIZE <
ui_type = "drag";
ui_label = "Grain Size";
ui_min = 0.0;
ui_max = 1.0;
ui_category = "Parameters for Analog Film Grain";
> = 0.3;
#line 104
uniform float FILM_CURVE_GAMMA <
ui_type = "drag";
ui_min = -1.0; ui_max = 1.0;
ui_label = "Analog Film Gamma";
ui_category = "Parameters for Analog Film Grain";
> = 0.0;
#line 111
uniform float FILM_CURVE_TOE <
ui_type = "drag";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Analog Film Shadow Emphasis";
ui_category = "Parameters for Analog Film Grain";
> = 0.0;
#line 144
texture ColorInputTex : COLOR;
sampler ColorInput 	{ Texture = ColorInputTex; };
#line 150
texture PoissonLookupTex            { Width = 256;   Height = 1024;   Format = RGBA8;  };
sampler sPoissonLookupTex           { Texture = PoissonLookupTex; };
storage stPoissonLookupTex          { Texture = PoissonLookupTex; };
#line 154
texture GrainIntermediateTex  < pooled = true; > { Width = 1920;   Height = 1018;   Format = RGBA16F;  };
sampler sGrainIntermediateTex                    { Texture = GrainIntermediateTex; };
#line 157
uniform uint FRAMECOUNT < source = "framecount"; >;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_global.fxh"
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
#line 160 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_FILMGRAIN.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_math.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_global.fxh"
#line 21 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_math.fxh"
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
#line 161 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_FILMGRAIN.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_hash.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_math.fxh"
#line 21 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_hash.fxh"
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
#line 162 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_FILMGRAIN.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_bxdf.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_global.fxh"
#line 21 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_bxdf.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_math.fxh"
#line 22 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_bxdf.fxh"
#line 23
namespace BXDF
{
#line 30
float2 sample_disc(float2 u)
{
float2 dir;
sincos(u.x * TAU, dir.y, dir.x);
dir *= sqrt(u.y);
return dir;
}
#line 38
float3 sample_sphere(float2 u)
{
float3 dir;
sincos(u.x * TAU, dir.y, dir.x);
dir.z = u.y * 2.0 - 1.0;
dir.xy *= sqrt(1.0 - dir.z * dir.z);
return dir;
}
#line 47
float3 ray_cosine(float2 u, float3 n)
{
return normalize(sample_sphere(u) + n);
}
#line 52
float3 ray_uniform(float2 u, float3 n)
{
float3 dir = sample_sphere(u);
dir = dot(dir, n) < 0 ? -dir : dir;
return normalize(dir + n * 0.01);
}
#line 59
float2 boxmuller(float2 u)
{
return sample_disc(float2(u.x, -2.0 * log(1 - u.y)));
}
#line 64
float3 boxmuller3D(float3 u)
{
return sample_sphere(u.xy) * sqrt(-2.0 * log(u.z));
}
#line 73
float3 sample_phase_henyey_greenstein(float2 u, float g = 0.75)
{
float3 wi; sincos(TAU * u.y, wi.x, wi.y);
float sqr = (1 - g * g) / (1 - g + 2 * g * u.x);
wi.z = (1 + g * g - sqr * sqr) / (2 * g); 
wi.xy *= sqrt(saturate(1 - wi.z * wi.z)); 
return wi;
#line 81
}
#line 84
float henyey_greenstein_cdf(float cos_theta, float g = 0.75)
{
float a = (rcp(g) - g) / 2;
float b = a * rcp(1 + g);
return rsqrt(1 + g * (g - 2 * cos_theta)) * a - b; 
}
#line 91
float henyey_greenstein_icdf(float x, float g = 0.75)
{
float a = (rcp(g) - g) / 2;
float b = a * rcp(1 + g);
float c = a / (x + b);
float cos_theta = rcp(2 * g) * ((g * g + 1) - c * c);
return cos_theta;
}
#line 104
float fresnel_schlick(float cos_theta, float F0)
{
float f = saturate(1 - cos_theta);
float f2 = f * f;
return mad(f2 * f2 * f, 1 - F0, F0);
}
#line 115
namespace GGX
{
#line 118
float smith_G1(float ndotx, float alpha)
{
float ndotx2 = ndotx * ndotx;
float tantheta2 = (1 - ndotx2) / ndotx2;
return 2 / (sqrt(mad(alpha*alpha, tantheta2, 1)) + 1);
}
#line 125
float smith_G2_heightcorrelated(float ndotl, float ndotv, float alpha)
{
float a2 = alpha * alpha;
float termv = ndotl * sqrt((-ndotv * a2 + ndotv) * ndotv + a2);
float terml = ndotv * sqrt((-ndotl * a2 + ndotl) * ndotl + a2);
return (2 * ndotv * ndotl) / (termv + terml);
}
#line 133
float smith_G2_over_G1_heightcorrelated(float alpha, float ndotwi, float ndotwo)
{
float G1wi = smith_G1(ndotwi, alpha);
float G1wo = smith_G1(ndotwo, alpha);
return G1wi / (G1wi + G1wo - G1wi * G1wo);
}
#line 140
float spec_half_angle_from_alpha(float alpha)
{
return PI * alpha / (1 + alpha);
}
#line 148
float3 sample_vndf(float3 wi, float2 alpha, float2 u, float coverage)
{
#line 151
float3 wi_std = normalize(float3(wi.xy * alpha, wi.z));
#line 153
float3 c;
c.z = mad((1 - u.y * coverage), (1 + wi_std.z), -wi_std.z);
sincos(u.x * TAU, c.x, c.y);
c.xy *= sqrt(saturate(1 - c.z * c.z));
#line 158
float3 wm_std = wi_std + c;
#line 160
return normalize(float3(wm_std.xy * alpha, wm_std.z));
}
#line 166
float3 sample_vndf_bounded(float3 wi, float2 alpha, float2 u, float coverage, out float pdf_ratio)
{
#line 169
float z2 = wi.z * wi.z;
float a = saturate(min(alpha.x, alpha.y)); 
float a2 = a * a;
#line 173
float3 wi_std = float3(wi.xy * alpha, wi.z);
float t = sqrt((1 - z2) * a2 + z2);
wi_std /= t;
#line 177
float s = 1 + sqrt(saturate(1 - z2)); 
float s2 = s * s;
float k = (1 - a2) * s2 / (s2 + a2 * z2);
#line 181
pdf_ratio = (k * wi.z + t) / (wi.z + t);
#line 183
float b = wi_std.z;
b = wi.z > 0 ? k * b : b;
float3 c;
c.z = mad((1 - u.y * coverage), (1 + b), -b);
sincos(u.x * TAU, c.x, c.y);
c.xy *= sqrt(saturate(1 - c.z * c.z));
#line 190
float3 wm_std = c + wi_std;
#line 192
return normalize(float3(wm_std.xy * alpha, wm_std.z));
}
#line 196
float3 sample_vndf_bounded_iso(float3 wi, float3 n, float alpha, float2 u, float coverage, out float pdf_ratio)
{
#line 199
float wi_z = dot(wi, n);
float3 wi_xy = wi - wi_z * n;
#line 202
float a = saturate(alpha);
float a2 = a * a;
float z2 = wi_z * wi_z;
#line 206
float3 wiStd = lerp(wi, wi_z * n, 1 + alpha);
float t = sqrt((1 - z2) * a2 + z2);
wiStd /= t;
#line 210
float s = 1 + sqrt(1 - z2);
float s2 = s * s;
float k = (s2 - a2 * s2) / (s2 + a2 * z2);
#line 214
pdf_ratio = (k * wi_z + t) / (wi_z + t);
#line 216
float3 c_std;
float b = dot(wiStd, n); 
b = wi_z > 0 ? k * b : b;
c_std.z = mad((1 - u.y * coverage), (1 + b), -b);
sincos(u.x * TAU, c_std.x, c_std.y);
c_std.xy *= sqrt(saturate(1.0 - c_std.z * c_std.z));
#line 223
float3 wr = float3(n.xy, n.z + 1);
float3 c = (dot(wr, c_std) / wr.z) * wr - c_std;
#line 226
float3 wm_std = c + wiStd;
float3 wm_std_z = n * dot(n, wm_std);
float3 wm_std_xy = wm_std_z - wm_std;
#line 230
return normalize(wm_std_z + alpha * wm_std_xy);
}
#line 234
float ndf(float ndoth, float alpha)
{
float a2 = alpha * alpha;
float d = ((ndoth * a2 - ndoth) * ndoth + 1);
return a2 / (d * d * PI);
}
#line 241
float pdf_vndf_bounded_iso(float3 wi, float3 wo, float3 n, float alpha)
{
float3 m = normalize(wi + wo);
float ndoth = saturate(dot(m, n));
float ndf = ndf(ndoth, alpha);
#line 247
float wi_z = dot(n, wi);
float z2 = wi_z * wi_z;
float a = saturate(alpha);
float a2 = a * a;
float len2 = (1 - z2) * a2;
float t = sqrt(len2 + z2);
#line 254
if(wi_z > 0.0)
{
float s = 1 + sqrt(saturate(1 - z2));
float s2 = s * s;
float k = (1 - a2) * s2 / (s2 + a2 * z2);
return ndf / (2 * (k * wi_z + t)) ;
}
#line 262
return ndf * (t - wi_z) / (2 * len2);
}
#line 265
float3 dominant_direction(float3 n, float3 v, float alpha)
{
float roughness = sqrt(alpha);
float f = (1 - roughness) * (sqrt(1 - roughness) + roughness);
float3 r = reflect(-v, n);
return normalize(lerp(n, r, f));
}
#line 273
} 
#line 275
} 
#line 163 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_FILMGRAIN.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_sfc.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_math.fxh"
#line 21 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_sfc.fxh"
#line 22
namespace SFC
{
#line 33
uint2 morton_i_to_xy(uint i, uint N = 0)
{
uint2 p = uint2(i, i >> 1);
p &= 0x55555555;
p = (p ^ (p >> 1)) & 0x33333333;
p = (p ^ (p >> 2)) & 0x0F0F0F0F;
p = (p ^ (p >> 4)) & 0x00FF00FF;
p = (p ^ (p >> 8)) & 0x0000FFFF;
return p;
}
#line 44
uint morton_xy_to_i(uint2 p)
{
p = (p | (p << 8)) & 0x00FF00FF;
p = (p | (p << 4)) & 0x0F0F0F0F;
p = (p | (p << 2)) & 0x33333333;
p = (p | (p << 1)) & 0x55555555;
return p.x | (p.y << 1);
}
#line 74
uint2 hilbert_i_to_xy(uint i, uint N)
{
uint2 p = 0; uint2 r;
for(uint s = 1u; s < N; s += s)
{
r.y = i;  i >>= 1;
r.y ^= i;
r.x = i;  i >>= 1;
r &= 1u;
p = r.y ? p : (r.x == 1u ? (s - 1u - p.yx) : p.yx);
p += s * r;
}
return p;
}
#line 96
uint2 h_curve_i_to_xy(uint i, uint N)
{
uint2 p = 0;
#line 100
while((N>>=2) >= 16u)
{
uint2 q;
q.x = i / N;
q.y = q.x >> 1;
p = 2u * p + (uint2(q.y, q.x ^ q.y) & 1u);
i += ((q.x * 2u + 5u) & 7u) * (N >> 3);
}
#line 109
p = p * 4u + ((uint2(0xAFFA5005, 0x41BEBE41) >> (2u * i)) & 3u);
return p;
}
#line 114
uint h_curve_xy_to_i(uint2 p, uint N)
{
uint i = (p.x&2u)<<2u|((p.x^p.y)&2u)<<1u|(p.y^(~p.x<<1u))&2u|(p.x^p.y)&1u;
#line 118
p *= 4u;
uint2 t;
for(uint k = 16u; k < N*N; k *= 4u)
{
t = p & k;
t = 2u * t + t.x ^ t.y;
i = ((i + ((3u * k) >> 3u) + (t.y >> 2u)) & (k - 1u)) | t.x;
p *= 2u;
}
return i;
}
#line 132
}
#line 164 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_FILMGRAIN.fx"
#line 165
struct VSOUT
{
float4 vpos : SV_Position;
float2 uv   : TEXCOORD0;
};
#line 171
struct CSIN
{
uint3 groupthreadid     : SV_GroupThreadID;
uint3 groupid           : SV_GroupID;
uint3 dispatchthreadid  : SV_DispatchThreadID;
uint threadid           : SV_GroupIndex;
};
#line 185
float3 to_hdr(float3 c)
{
float w = 1 + rcp(1e-6 + 15.0);
c = c / (w - c);
return c;
}
float3 from_hdr(float3 c)
{
float w = 1 + rcp(1e-6 + 15.0);
c = w * c * rcp(1 + c);
return c;
}
#line 201
float get_grey_value(int2 p)
{
float3 color = tex2Dfetch(ColorInput, p).rgb;
color = ((color)*0.283799*((2.52405+(color))*(color)));
return dot(color, float3(0.299, 0.587, 0.114));
}
#line 209
float3 filmic_curve(float3 x, float toe_strength, float gamma)
{
#line 212
gamma = gamma < 0.0 ? gamma * 0.5 : gamma * 6.0;
#line 214
x = saturate(x);
float3 toe = saturate(1 - x);
toe *= toe;
toe *= toe;
x = saturate(x - x * toe_strength * toe);
float3 gx = x * gamma;
return (gx + x) / (gx + 1);
}
#line 224
float4 next_rand_lq(inout uint rng)
{
#line 227
float4 res;
res.xy = Hash::next2D(rng);
res.zw = Hash::next2D(rng);
return res;
}
#line 236
uint grain_intensity_to_halide_count()
{
return uint(1 + 127 * saturate(2.0 -(1-(1-GRAIN_INTENSITY)*(1-GRAIN_INTENSITY)) * 2.0));
}
#line 241
float grain_intensity_to_blend()
{
return saturate((1-(1-GRAIN_INTENSITY)*(1-GRAIN_INTENSITY)) * 2.0);
}
#line 246
uint morton2Dto1D(uint2 p)
{
p = (p | (p << 8)) & 0x00FF00FFu;
p = (p | (p << 4)) & 0x0F0F0F0Fu;
p = (p | (p << 2)) & 0x33333333u;
p = (p | (p << 1)) & 0x55555555u;
return p.x | (p.y << 1);
}
#line 259
VSOUT AnalogGrainVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv); 
#line 264
if(GRAIN_TYPE != 0)
o.vpos = asfloat(0x7F800000u); 
#line 267
return o;
}
#line 270
VSOUT DigitalSensorNoiseVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv); 
#line 275
if(GRAIN_TYPE != 1)
o.vpos = asfloat(0x7F800000u); 
#line 278
return o;
}
#line 283
void PoissonTableCS(in CSIN i)
{
if(GRAIN_TYPE != 0)
return;
#line 288
uint trial = i.dispatchthreadid.y;
#line 290
uint rng = Hash::uhash(trial + 2); 
rng = ANIMATE ? rng + FRAMECOUNT : rng;
#line 293
float4 poisson_result[4];
float exposure_level[4];
#line 296
[unroll]
for(uint j = 0u; j < 4; j++)
{
uint color_idx = i.dispatchthreadid.x * 4 + j;
float c = color_idx / (256 - 1.0);
c = filmic_curve(c, FILM_CURVE_TOE, FILM_CURVE_GAMMA).x; 
c = ((c)*0.283799*((2.52405+(c))*(c)));
#line 304
exposure_level[j] = c;
poisson_result[j] = 0;
}
#line 308
uint num_grains = grain_intensity_to_halide_count();
#line 310
[loop]
for(int g = 0; g < num_grains; g++)
{
float4 rand_rgba = next_rand_lq(rng);
[unroll]
for(int j = 0; j < 4; j++)
poisson_result[j] += step(rand_rgba, exposure_level[j].xxxx);
}
#line 319
[unroll]
for(uint j = 0u; j < 4; j++)
{
uint color_idx = i.dispatchthreadid.x * 4 + j;
tex2Dstore(stPoissonLookupTex, int2(color_idx, trial), poisson_result[j] / num_grains);
}
}
#line 327
void AnalogGrainPS(in VSOUT i, out float4 o : SV_Target0)
{
uint2 p = uint2(i.vpos.xy);
uint2 block = p % 32u;
uint2 tile  = p / 32u;
uint tile_rng = Hash::uhash(Hash::uhash(tile.y) + tile.x);
#line 334
if(tile_rng & 1u)
block.x = 31u - block.x;
tile_rng >>= 1;
if(tile_rng & 1u)
block.y = 31u - block.y;
tile_rng >>= 1;
if(tile_rng & 1u)
block = block.yx;
tile_rng >>= 1;
uint row_idx = SFC::morton_xy_to_i(block);
row_idx += tile_rng;
row_idx %= 1024;
#line 347
float3 tcol = tex2Dfetch(ColorInput, p).rgb;
float3 poisson = 0;
#line 350
[branch]
if(FILM_MODE == 1)
{
poisson.x = tex2Dfetch(sPoissonLookupTex, int2(tcol.x * 256 * 0.99999, row_idx), 0).x;
poisson.y = tex2Dfetch(sPoissonLookupTex, int2(tcol.y * 256 * 0.99999, row_idx), 0).y;
poisson.z = tex2Dfetch(sPoissonLookupTex, int2(tcol.z * 256 * 0.99999, row_idx), 0).z;
}
else
{
float tgrey = (1.14374*(-0.126893*(dot(((tcol)*0.283799*((2.52405+(tcol))*(tcol))), float3(0.2126729, 0.7151522, 0.072175)))+sqrt((dot(((tcol)*0.283799*((2.52405+(tcol))*(tcol))), float3(0.2126729, 0.7151522, 0.072175))))));
poisson = tex2Dfetch(sPoissonLookupTex, int2(tgrey * 256 * 0.99999, row_idx)).x;
}
#line 363
o.rgb = poisson;
o.w = Hash::uhash(Hash::uhash(p.y) + p.x) & 1023u; 
#line 366
}
#line 368
void FilmDiffusionPS(in VSOUT i, out float3 o : SV_Target0)
{
float2 gaussian = float2(1, 0.5 * lerp(0.1, 1.0, GRAIN_SIZE));
float sigma = rsqrt(grain_intensity_to_halide_count());
#line 373
float wsum = 0;
uint2 p = uint2(i.vpos.xy);
o = 0;
#line 377
[unroll]for(int x = -1; x <= 1; x++)
[unroll]for(int y = -1; y <= 1; y++)
{
uint2 tp = p + int2(x, y);
float4 texel = tex2Dfetch(sGrainIntermediateTex, tp);
float3 tcol = texel.rgb;
uint rng = uint(texel.w);
#line 385
float2 rand01 = float2(rng & 31u, rng >> 5u) / 32.0; 
#line 387
float2 offs = float2(x, y) + BXDF::boxmuller(rand01) * sigma;
float w = exp(-dot(offs, offs));
#line 390
w *= gaussian[abs(x)] * gaussian[abs(y)];
#line 392
o += tcol * w;
wsum += w;
}
#line 396
o /= wsum;
#line 398
float3 center = tex2Dfetch(ColorInput, p).rgb;
center = filmic_curve(center, FILM_CURVE_TOE, FILM_CURVE_GAMMA);
#line 401
[branch]
if(FILM_MODE == 1)
{
center = ((center)*0.283799*((2.52405+(center))*(center)));
o.rgb = lerp(center, o.rgb, grain_intensity_to_blend());
}
else
{
float grey = dot(((center)*0.283799*((2.52405+(center))*(center))), float3(0.2126729, 0.7151522, 0.072175));
o.rgb = lerp(grey, o.rgb, grain_intensity_to_blend());
}
#line 413
o.rgb = (1.14374*(-0.126893*(o.rgb)+sqrt((o.rgb))));
}
#line 416
void ApplySensorNoisePS(in VSOUT i, out float3 o : SV_Target0)
{
o = tex2Dfetch(ColorInput, uint2(i.vpos.xy)).rgb;
o = ((o)*0.283799*((2.52405+(o))*(o)));
#line 421
uint2 p = uint2(i.vpos.xy);
uint rng = Hash::uhash(Hash::uhash(p.y) + p.x);
if(ANIMATE) rng += FRAMECOUNT;
float3 u3 = next_rand_lq(rng).xyz;
#line 427
float3 gaussian = BXDF::boxmuller3D(u3);
#line 429
[branch]
if(FILM_MODE == 1)
{
gaussian.g *= GRAIN_USE_BAYER > 0.5 ? 0.7071 : 1; 
gaussian = lerp(gaussian.xxx, gaussian, GRAIN_SAT);
o = to_hdr(o);
o += gaussian * GRAIN_INTENSITY * GRAIN_INTENSITY * 0.35;
o = from_hdr(o);
}
else
{
o = dot(o, float3(0.2126729, 0.7151522, 0.072175));
o = to_hdr(o);
o += gaussian.x * GRAIN_INTENSITY * GRAIN_INTENSITY * 0.35;
o = from_hdr(o);
}
#line 446
o = (1.14374*(-0.126893*(o)+sqrt((o))));
}
#line 453
technique MartyMods_FilmGrain
<
ui_label = "METEOR: Film Grain";
ui_tooltip =
"                            MartysMods - Film Grain                           \n"
"                   Marty's Extra Effects for ReShade (METEOR)                 \n"
"______________________________________________________________________________\n"
"\n"
#line 462
"METEOR Film Grain is a physically based film grain emulation effect. Modeled \n"
"after extensive offline simulations to produce results as seen in the real world.\n"
"\n"
"\n"
"Visit https://martysmods.com for more information.                            \n"
"\n"
"______________________________________________________________________________";
>
{
pass
{
ComputeShader = PoissonTableCS<256 / 4, 1>;
DispatchSizeX = 1;
DispatchSizeY = 1024;
}
pass
{
VertexShader = AnalogGrainVS;
PixelShader  = AnalogGrainPS;
RenderTarget = GrainIntermediateTex;
}
pass
{
VertexShader = AnalogGrainVS;
PixelShader  = FilmDiffusionPS;
}
pass
{
VertexShader = DigitalSensorNoiseVS;
PixelShader  = ApplySensorNoisePS;
}
}

