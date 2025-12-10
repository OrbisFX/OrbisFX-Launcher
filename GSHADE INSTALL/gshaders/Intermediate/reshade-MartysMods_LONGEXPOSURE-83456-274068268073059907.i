#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_LONGEXPOSURE.fx"
#line 37
uniform int CAPTURE_MODE <
ui_type = "combo";
ui_items = "Click to start capture\0Capture while holding button\0";
ui_label = "Capture Mode";
> = 0;
#line 45
uniform float EXPOSURE_TIME <
ui_type = "drag";
ui_min = 0.05; ui_max = 50.0;
ui_units = " Seconds";
ui_label = "Exposure Time";
#line 51
> = 1.0;
#line 55
uniform float HDR_WHITEPOINT <
ui_type = "drag";
ui_min = 0.0; ui_max = 12.0;
ui_label = "Highlight Intensity";
ui_tooltip = "Higher values let bright pixels build up more, resulting in stronger motion trails.\n"
"This sets the log2 whitepoint used during inverse tonemapping.";
> = 2.0;
#line 63
uniform bool CLOSE_GAPS <
ui_label = "Fake Frame Generation\n";
ui_tooltip = "Inserting fake frames closes gaps between frames.\n\n"
"REQUIRES iMMERSE: LAUNCHPAD";
> = false;
#line 69
uniform bool SHOW_PROGRESS_BAR <
ui_label = "Display Progress Animation";
> = true;
#line 73
uniform bool TRIGGER <
ui_label = "Capture";
ui_type = "button";
ui_spacing = 10;
> = false;
#line 79
uniform bool CLEAR <
ui_label = "Reset";
ui_type = "button";
> = false;
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
#line 89 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_LONGEXPOSURE.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_deferred.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_global.fxh"
#line 21 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_deferred.fxh"
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
#line 22 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_deferred.fxh"
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
#line 90 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_LONGEXPOSURE.fx"
#line 91
texture ColorInputTex : COLOR;
sampler ColorInput 	{ Texture = ColorInputTex; };
#line 94
texture METEORLongExposureCtx       { Format = RGBA32F;};
sampler sMETEORLongExposureCtx	    { Texture = METEORLongExposureCtx; MipFilter = POINT; MagFilter = POINT; MinFilter = POINT; };
texture METEORLongExposureCtxTmp    { Format = RGBA32F;};
sampler sMETEORLongExposureCtxTmp	{ Texture = METEORLongExposureCtxTmp; MipFilter = POINT; MagFilter = POINT; MinFilter = POINT; };
#line 99
texture METEORLongExposureCache    { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler sMETEORLongExposureCache	{ Texture = METEORLongExposureCache; };
#line 103
texture METEORLongExposureAccumRegular         { Width = 1920; Height = 1018; Format = RGBA32F; };
sampler sMETEORLongExposureAccumRegular	       { Texture = METEORLongExposureAccumRegular; };
texture METEORLongExposureAccumInterpolated    { Width = 1920; Height = 1018; Format = RGBA32F; };
sampler sMETEORLongExposureAccumInterpolated   { Texture = METEORLongExposureAccumInterpolated; };
#line 108
uniform float TIMER      < source = "timer"; >;
uniform uint  FRAMECOUNT < source = "framecount"; >;
uniform float FRAMETIME  < source = "frametime"; >;
uniform int ACTIVE_VAR_IDX < source = "overlay_active"; >;
#line 113
struct VSOUT
{
float4 vpos : SV_Position;
float2 uv   : TEXCOORD0;
float weight : TEXCOORD1;
};
#line 122
struct CSIN
{
uint3 groupthreadid     : SV_GroupThreadID;
uint3 groupid           : SV_GroupID;
uint3 dispatchthreadid  : SV_DispatchThreadID;
uint threadid           : SV_GroupIndex;
};
#line 130
storage stMETEORLongExposureCtx	{ Texture = METEORLongExposureCtx;  };
#line 139
float3 sdr_to_hdr(float3 c, float w)
{
float a = 1 + exp2(-w);
c = c * sqrt(1e-6 + dot(c, c));
c /= 1.733;
c = c / (a - c);
return c;
}
#line 148
float3 hdr_to_sdr(float3 c, float w)
{
float a = 1 + exp2(-w);
c = a * c * rcp(1 + c);
c *= 1.733;
c = c * rsqrt(sqrt(dot(c, c))+0.0001);
return c;
}
#line 161
struct CaptureContext
{
float t_elapsed;
bool state;
bool display;
};
#line 168
float get_progress(CaptureContext ctx)
{
return saturate(ctx.t_elapsed / (EXPOSURE_TIME * 1000.0));
}
#line 173
void advance_context(inout CaptureContext ctx)
{
[branch]
if(ctx.state) 
{
ctx.t_elapsed += FRAMETIME;
}
#line 181
switch(CAPTURE_MODE)
{
case 0:
{
[branch]
if(ctx.t_elapsed > (EXPOSURE_TIME * 1000.0)) 
{
ctx.state = false; 
}
[branch]
if(TRIGGER)
{
ctx.state = true;
ctx.display = true;
ctx.t_elapsed = 0;
#line 197
}
[branch]
if(CLEAR)
{
ctx.state = false;
ctx.display = false;
}
break;
}
case 1:
{
[branch]
if(ACTIVE_VAR_IDX == 6)
{
ctx.state = true;
ctx.display = true;
}
else
{
ctx.state = false;
}
#line 219
[branch]
if(CLEAR)
{
ctx.display = false;
ctx.t_elapsed = 0;
}
break;
}
}
}
#line 230
CaptureContext get_capture_context()
{
float3 t = tex2Dfetch(sMETEORLongExposureCtx, int2(0, 0)).xyz;
CaptureContext ctx;
ctx.t_elapsed = t.x;
ctx.state = t.y > 0.5;
ctx.display = t.z > 0.5;
return ctx;
}
#line 242
CaptureContext get_capture_context_rw()
{
float3 t = tex2Dfetch(stMETEORLongExposureCtx, int2(0, 0)).xyz;
CaptureContext ctx;
ctx.t_elapsed = t.x;
ctx.state = t.y > 0.5;
ctx.display = t.z > 0.5;
return ctx;
}
#line 252
void AdvanceContextCS(in CSIN i)
{
CaptureContext ctx = get_capture_context_rw();
advance_context(ctx);
tex2Dstore(stMETEORLongExposureCtx, int2(0, 0), float4(ctx.t_elapsed, ctx.state, ctx.display, 1));
}
#line 278
 
#line 284
VSOUT AccumVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv);
#line 289
CaptureContext ctx = get_capture_context();
#line 291
[branch]
if(!ctx.state)
{
o.vpos.xy = o.weight = 0;
}
else
{
float delta_t = FRAMETIME + 1e-10;
float next_elapsed = ctx.t_elapsed + delta_t;
o.weight = saturate(delta_t / next_elapsed);
}
#line 303
return o;
}
#line 306
void AccumPS(in VSOUT i, out PSOUT2 o)
{
#line 309
o.t0 = float4(tex2Dfetch(sMETEORLongExposureCache, int2(i.vpos.xy)).rgb, i.weight);
#line 312
o.t1 = 0;
#line 314
float2 motion = Deferred::get_motion(i.uv);
int n = min(64, int(1 + length(motion * BUFFER_SCREEN_SIZE)));
#line 317
[loop]
for(int j = 0; j < n; j++)
o.t1 += float4(tex2Dlod(sMETEORLongExposureCache, i.uv + motion * float(j) / n, 0).rgb, 1);
#line 321
o.t1.rgb /= o.t1.w;
o.t1.w = i.weight;
}
#line 329
VSOUT CacheVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv);
o.weight = 0; 
return o;
}
#line 337
void CachePS(in VSOUT i, out float3 o : SV_Target)
{
o = tex2D(ColorInput, i.uv).rgb;
o = sdr_to_hdr(o, exp2(HDR_WHITEPOINT));
}
#line 347
VSOUT OutVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv);
#line 352
[branch]
if(!get_capture_context().display)
{
o.vpos.xy = 0;
}
return o;
}
#line 360
void OutPS(in VSOUT i, out float3 o : SV_Target)
{
o = 0;
#line 364
[branch]
if(CLOSE_GAPS)
{
o = tex2Dlod(sMETEORLongExposureAccumInterpolated, i.uv, 0).rgb;
}
else
{
o = tex2Dlod(sMETEORLongExposureAccumRegular, i.uv, 0).rgb;
}
#line 374
o = hdr_to_sdr(o, exp2(HDR_WHITEPOINT));
#line 376
[flatten]
if(SHOW_PROGRESS_BAR)
{
CaptureContext ctx = get_capture_context();
#line 381
float3 ca = float3(14,145,248) / 255.0;
float3 cb = float3(228,47,226) / 255.0;
#line 384
float2 duv = i.uv * 2.0 - 1.0;
duv *= BUFFER_ASPECT_RATIO.yx;
float t = ctx.t_elapsed * 0.001;
#line 388
[flatten] 
if(CAPTURE_MODE == 1)
{
float scale = 0.2 * t / (0.04 + t);
[unroll]
for(int j = 0; j < 10; j++)
{
float2 p; sincos(j / 10.0 * 6.283 - scale * 6.283, p.x, p.y);
float r = frac(-t * 0.8 - j / 10.0);
float R = length(duv + p * 0.7 * scale) - scale * 0.1 * r;
float mask = smoothstep(2, 0, R / fwidth(R));
o = lerp(o, sqrt(lerp(ca * ca, cb * cb, r)), mask);
}
}
else
{
float progress = get_progress(ctx);
#line 406
float2 duv = i.uv * 2.0 - 1.0;
duv *= BUFFER_ASPECT_RATIO.yx;
float ang = atan2(duv.x, duv.y);
float ramp = saturate(1 - t * 2.0 / min(1.0, EXPOSURE_TIME));
ramp *= ramp * ramp;
ramp = 1-ramp;
#line 413
float norm_ang = saturate(ang / TAU + 0.5);
norm_ang = frac(norm_ang - ramp);
#line 416
float r = length(duv) - 0.15 * ramp;
#line 418
float3 ca = float3(14,145,248) / 255.0;
float3 cb = float3(228,47,226) / 255.0;
#line 421
float3 progresscol = sqrt(lerp(ca * ca, cb * cb, norm_ang));
o = progress < 1.0 ? lerp(o, step(norm_ang, progress) * progresscol, smoothstep(2.0, 0.0, r / fwidth(r))) : o;
}
}
}
#line 431
technique MartysMods_LongExposure
<
ui_label = "METEOR: Long Exposure";
ui_tooltip =
"                           MartysMods - Long Exposure                         \n"
"                   Marty's Extra Effects for ReShade (METEOR)                 \n"
"______________________________________________________________________________\n"
"\n"
#line 440
"Advanced long exposure shader with frametime normalizing and frame generation.\n"
"\n"
"\n"
"Visit https://martysmods.com for more information.                            \n"
"\n"
"______________________________________________________________________________";
>
{
pass 
{
VertexShader = AccumVS;
PixelShader  = AccumPS;
RenderTarget0 = METEORLongExposureAccumRegular;
BlendEnable0 = true;
SrcBlend0 = SRCALPHA;
DestBlend0 = INVSRCALPHA;
RenderTarget1 = METEORLongExposureAccumInterpolated;
BlendEnable1 = true;
SrcBlend1 = SRCALPHA;
DestBlend1 = INVSRCALPHA;
}
pass 
{
VertexShader = CacheVS;
PixelShader  = CachePS;
RenderTarget = METEORLongExposureCache;
}
pass
{
VertexShader = OutVS;
PixelShader  = OutPS;
}
#line 474
pass
{
ComputeShader = AdvanceContextCS<1, 1>;
DispatchSizeX = 1;
DispatchSizeY = 1;
}
#line 497
 
}

