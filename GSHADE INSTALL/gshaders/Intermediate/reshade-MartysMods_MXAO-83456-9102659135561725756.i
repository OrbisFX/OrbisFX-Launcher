// MXAO_USE_LAUNCHPAD_NORMALS=0
// MXAO_AO_TYPE=0
#line 1 "unknown"

#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_MXAO.fx"
#line 53
uniform int MXAO_GLOBAL_SAMPLE_QUALITY_PRESET <
ui_type = "combo";
ui_label = "Sample Quality";
ui_items = "Low\0Medium\0High\0Very High\0Ultra\0Extreme\0IDGAF\0";
ui_tooltip = "Global quality control, main performance knob. Higher radii might require higher quality.";
ui_category = "Global";
> = 1;
#line 61
uniform int SHADING_RATE <
ui_type = "combo";
ui_label = "Shading Rate";
ui_items = "Full Rate\0Half Rate\0Quarter Rate\0";
ui_tooltip = "0: render all pixels each frame\n1: render only 50% of pixels each frame\n2: render only 25% of pixels each frame";
ui_category = "Global";
> = 1;
#line 69
uniform float MXAO_SAMPLE_RADIUS <
ui_type = "drag";
ui_min = 0.5; ui_max = 10.0;
ui_label = "Sample Radius";
ui_tooltip = "Sample radius of MXAO, higher means more large-scale occlusion with less fine-scale details.";
ui_category = "Global";
> = 2.5;
#line 77
uniform bool MXAO_WORLDSPACE_ENABLE <
ui_label = "Increase Radius with Distance";
ui_category = "Global";
> = false;
#line 82
uniform float MXAO_SSAO_AMOUNT <
ui_type = "drag";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Ambient Occlusion Amount";
ui_tooltip = "Intensity of AO effect. Can cause pitch black clipping if set too high.";
ui_category = "Blending";
> = 0.8;
#line 90
uniform float MXAO_FADE_DEPTH <
ui_type = "drag";
ui_label = "Fade Out Distance";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Fadeout distance for MXAO. Higher values show MXAO in farther areas.";
ui_category = "Blending";
> = 0.25;
#line 98
uniform int MXAO_FILTER_SIZE <
ui_type = "slider";
ui_label = "Filter Quality";
ui_min = 0; ui_max = 2;
ui_category = "Blending";
> = 1;
#line 105
uniform bool MXAO_DEBUG_VIEW_ENABLE <
ui_label = "Show Raw AO";
ui_category = "Debug";
> = false;
#line 112
uniform int HELP1 <
ui_type = "radio";
ui_label = " ";
ui_category = "Preprocessor definition Documentation";
ui_category_closed = false;
ui_text =
"\n"
"MXAO_AO_TYPE"
":\n\n0: Ground Truth Ambient Occlusion (high contrast, fast)\n"
"1: Solid Angle (smoother, fastest)\n"
"2: Visibility Bitmask (DX11+ only, highest quality, slower)\n"
"3: Visibility Bitmask w/ Solid Angle (like 2, only smoother)\n"
"\n"
"MXAO_USE_LAUNCHPAD_NORMALS"
":\n\n0: Compute normal vectors on the fly (fast)\n"
"1: Use normals from iMMERSE Launchpad (far slower)\n"
"   This allows to use Launchpad's smooth normals feature.";
>;
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
#line 161 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_MXAO.fx"
#line 164
texture ColorInputTex : COLOR;
texture DepthInputTex : DEPTH;
sampler ColorInput 	{ Texture = ColorInputTex; };
sampler DepthInput  { Texture = DepthInputTex; };
#line 169
texture MXAOTex1 { Width = 1920;   Height = 1018;   Format = RGBA16F;  };
texture MXAOTex2 { Width = 1920;   Height = 1018;   Format = RGBA16F;  };
sampler sMXAOTex1 { Texture = MXAOTex1; };
sampler sMXAOTex2 { Texture = MXAOTex2; };
#line 174
texture ZSrc { Width = 1920;   Height = 1018;   Format = R16F; };
sampler sZSrc { Texture = ZSrc; MinFilter=POINT; MipFilter=POINT; MagFilter=POINT;};
#line 178
storage stMXAOTex1       { Texture = MXAOTex1;        };
storage stMXAOTex2       { Texture = MXAOTex2;        };
storage2D stZSrc { Texture = ZSrc; };
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
#line 208 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_MXAO.fx"
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
#line 209 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_MXAO.fx"
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
#line 210 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_MXAO.fx"
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
#line 211 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_MXAO.fx"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_qmc.fxh"
#line 1 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_global.fxh"
#line 22 "C:\Users\Public\GShade Custom Shaders\Shaders\.\MartysMods\mmx_qmc.fxh"
#line 23
namespace QMC
{
#line 33
float roberts1(in uint idx, in float seed = 0.5)
{
uint useed = uint(seed * exp2(32.0));
uint phi = 2654435769u;
return float(phi * idx + useed) * exp2(-32.0);
}
#line 40
float2 roberts2(in uint idx, in float2 seed = 0.5)
{
uint2 useed = uint2(seed * exp2(32.0));
uint2 phi = uint2(3242174889u, 2447445413u);
return float2(phi * idx + useed) * exp2(-32.0);
}
#line 47
float3 roberts3(in uint idx, in float3 seed = 0.5)
{
uint3 useed = uint3(seed * exp2(32.0));
uint3 phi = uint3(776648141u, 1412856951u, 2360945575u);
return float3(phi * idx + useed) * exp2(-32.0);
}
#line 62
 
#line 70
uint P(uint v) 
{
v ^=  v                << 16;
v ^= (v & 0x00FF00FFu) <<  8;
v ^= (v & 0x0F0F0F0Fu) <<  4;
v ^= (v & 0x33333333u) <<  2;
v ^= (v & 0x55555555u) <<  1;
return v;
}
#line 80
uint JPJ(uint v)
{
#line 83
v ^=  v                >> 16;
v ^= (v & 0xFF00FF00u) >>  8;
v ^= (v & 0xF0F0F0F0u) >>  4;
v ^= (v & 0xCCCCCCCCu) >>  2;
v ^= (v & 0xAAAAAAAAu) >>  1;
return v;
}
#line 92
uint JPJ(uint v, int m)
{   
return (JPJ(v >> (32 - m)) << (32 - m)) | ((v << m) >> m);
}
#line 97
uint G(uint x, int m)
{
uint v = JPJ(x >> (32 - m));
v ^=  v >> 1;
#line 102
return (v << (32 - m)) | ((x << m) >> m);
}
#line 105
uint mmdX(uint x, int m)
{
uint v = JPJ(x >> (32 - m));
int padding = (m - 6) >> 1;
v ^= (v & (0x10u << padding)) >> 1;
return (v << (32 - m)) | ((x << m) >> m);
}
#line 113
uint mmdY(uint y, int m)
{
uint v = JPJ(y >> (32 - m));
int padding = (m - 6) >> 1;
v ^= ((v & (0x30u << padding)) >> 1) ^ ((v & (0x08u << padding)) >> 2);
return (v << (32 - m)) | ((y << m) >> m);
}
#line 121
void optimize_lstar(inout uint2 p, int logn)
{
p.x =   G(p.x, logn);
p.y = JPJ(p.y, logn);
}
#line 127
void optimize_distance(inout uint2 p, int logn)
{
p.x = mmdX(p.x, logn);
p.y = mmdY(p.y, logn);
}
#line 134
uint lk_hash(uint x, uint seed)
{
x ^= x * 0x3D20ADEAu;
x += seed;
x *= (seed >> 16) | 1u;
x ^= x * 0x05526C56u;
x ^= x * 0x53A22864u;
return x;
}
#line 144
uint owen_scramble(uint p, uint seed)
{
return reversebits(lk_hash(reversebits(p), seed));
}
#line 149
uint2 sobol_raw(uint i)
{
uint x = reversebits(i); 
uint y = P(x);
return uint2(x, y);
}
#line 156
float2 sobol(uint i)
{
return sobol_raw(i) * exp2(-32.0);
}
#line 161
float2 scrambled_sobol(uint i, uint2 seed = uint2(1337u, 1338u))
{
uint2 p = sobol_raw(i);
p.x = owen_scramble(p.x, seed.x);
p.y = owen_scramble(p.y, seed.y);
return float2(p) * exp2(-32.0);
}
#line 169
float2 shuffled_scrambled_sobol(uint i, uint seed)
{
#line 172
uint x = lk_hash(reversebits(i), seed);
uint y = P(x);
#line 176
return float2(owen_scramble(x, 80085u), owen_scramble(y, 420u)) * exp2(-32.0);
}
#line 187
float3 get_stratificator(int n_samples)
{
float3 stratificator;
stratificator.xy = rcp(float2(ceil(sqrt(n_samples)), n_samples));
stratificator.z = stratificator.y / stratificator.x;
return stratificator;
}
#line 195
float2 get_stratified_sample(float2 per_sample_rand, float3 stratificator, int i)
{
float2 stratified_sample = frac(i * stratificator.xy + stratificator.xz * per_sample_rand);
return stratified_sample;
}
#line 201
} 
#line 212 "C:\Users\Public\GShade Custom Shaders\Shaders\MartysMods_MXAO.fx"
#line 213
uniform uint FRAMECOUNT < source = "framecount"; >;
#line 215
struct VSOUT
{
float4 vpos : SV_Position;
float2 uv   : TEXCOORD0;
};
#line 221
struct CSIN
{
uint3 groupthreadid     : SV_GroupThreadID;         
uint3 groupid           : SV_GroupID;               
uint3 dispatchthreadid  : SV_DispatchThreadID;      
uint threadid           : SV_GroupIndex;            
};
#line 229
static const uint2 samples_per_preset[7] =
{
#line 232
uint2(2, 2),    
uint2(2, 4),    
uint2(2, 10),   
uint2(3, 12),   
uint2(4, 14),   
uint2(6, 16),   
uint2(8, 20)    
};
#line 245
float2 pixel_idx_to_uv(float2 pos, float2 texture_size)
{
float2 inv_texture_size = rcp(texture_size);
return pos * inv_texture_size + 0.5 * inv_texture_size;
}
#line 251
bool check_boundaries(uint2 pos, uint2 dest_size)
{
return pos.x < dest_size.x && pos.y < dest_size.y; 
}
#line 256
uint2 deinterleave_pos(uint2 pos, uint2 tiles, uint2 gridsize)
{
int2 tilesize = ((((gridsize) - 1) / (tiles)) + 1); 
int2 tile_idx    = pos % tiles;
int2 pos_in_tile = pos / tiles;
return tile_idx * tilesize + pos_in_tile;
}
#line 264
uint2 reinterleave_pos(uint2 pos, uint2 tiles, uint2 gridsize)
{
int2 tilesize = ((((gridsize) - 1) / (tiles)) + 1); 
int2 tile_idx    = pos / tilesize;
int2 pos_in_tile = pos % tilesize;
return pos_in_tile * tiles + tile_idx;
}
#line 272
float2 deinterleave_uv(float2 uv)
{
float2 splituv = uv * 4u;
float2 splitoffset = floor(splituv) - 4u * 0.5 + 0.5;
splituv = frac(splituv) + splitoffset * BUFFER_PIXEL_SIZE_DLSS;
return splituv;
}
#line 280
float2 reinterleave_uv(float2 uv)
{
uint2 whichtile = floor(uv / BUFFER_PIXEL_SIZE_DLSS) % 4u;
float2 newuv = uv + whichtile;
newuv /= 4u;
return newuv;
}
#line 288
float3 get_normals(in float2 uv, out float edge_weight)
{
float3 delta = float3(BUFFER_PIXEL_SIZE_DLSS, 0);
#line 292
float3 center = Camera::uv_to_proj(uv);
float3 deltaL = Camera::uv_to_proj(uv - delta.xz) - center;
float3 deltaR = Camera::uv_to_proj(uv + delta.xz) - center;
float3 deltaT = Camera::uv_to_proj(uv - delta.zy) - center;
float3 deltaB = Camera::uv_to_proj(uv + delta.zy) - center;
#line 298
float4 zdeltaLRTB = abs(float4(deltaL.z, deltaR.z, deltaT.z, deltaB.z));
float4 w = zdeltaLRTB.xzyw + zdeltaLRTB.zywx;
w = rcp(0.001 + w * w); 
#line 302
edge_weight = saturate(1.0 - dot(w, 1));
#line 308
float3 n0 = cross(deltaT, deltaL);
float3 n1 = cross(deltaR, deltaT);
float3 n2 = cross(deltaB, deltaR);
float3 n3 = cross(deltaL, deltaB);
#line 313
float4 finalweight = w * rsqrt(float4(dot(n0, n0), dot(n1, n1), dot(n2, n2), dot(n3, n3)));
float3 normal = n0 * finalweight.x + n1 * finalweight.y + n2 * finalweight.z + n3 * finalweight.w;
normal *= rsqrt(dot(normal, normal) + 1e-8);
#line 317
return normal;
}
#line 320
float get_jitter(uint2 p)
{
#line 325
uint tiles = 4u;
uint jitter_idx = dot(p % tiles, uint2(1, tiles));
jitter_idx *= 0 ? 17u : 11u;
return ((jitter_idx % (tiles * tiles)) + 0.5) / (tiles * tiles);
#line 330
}
#line 332
float get_fade_factor(float depth)
{
float fade = saturate(1 - depth * depth); 
depth /= MXAO_FADE_DEPTH;
return fade * saturate(exp2(-depth * depth)); 
}
#line 343
static uint occlusion_bitfield;
#line 345
void bitfield_init()
{
occlusion_bitfield = 0xFFFFFFFF;
}
#line 350
void process_horizons(float2 h)
{
uint a = uint(h.x * 32);
uint b = ceil(saturate(h.y - h.x) * 32); 
b = uint(h.y * 32) - a;
uint occlusion = ((1 << b) - 1) << a;
occlusion_bitfield &= ~occlusion; 
}
#line 359
float integrate_sectors()
{
return saturate(countbits(occlusion_bitfield) / 32.0);
}
#line 364
bool shading_rate(uint2 tile_idx)
{
bool skip_pixel = false;
switch(SHADING_RATE)
{
case 1: skip_pixel = ((tile_idx.x + tile_idx.y) & 1) ^ (FRAMECOUNT & 1); break;
case 2: skip_pixel = (tile_idx.x & 1 + (tile_idx.y & 1) * 2) ^ (FRAMECOUNT & 3); break;
}
return skip_pixel;
}
#line 433
 
#line 440
VSOUT MainVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv);
return o;
}
#line 448
void DeinterleaveCS(in CSIN i)
{
if(!check_boundaries(i.dispatchthreadid.xy * 2, BUFFER_SCREEN_SIZE_DLSS)) return;
#line 452
float2 uv = pixel_idx_to_uv(i.dispatchthreadid.xy * 2, BUFFER_SCREEN_SIZE_DLSS);
float2 corrected_uv = Depth::correct_uv(uv); 
#line 459
float4 depth_texels = tex2DgatherR(DepthInput, corrected_uv);
#line 462
depth_texels = Depth::linearize(depth_texels);
depth_texels.x = Camera::depth_to_z(depth_texels.x);
depth_texels.y = Camera::depth_to_z(depth_texels.y);
depth_texels.z = Camera::depth_to_z(depth_texels.z);
depth_texels.w = Camera::depth_to_z(depth_texels.w);
#line 469
const uint2 offsets[4] = {uint2(0, 1), uint2(1, 1), uint2(1, 0), uint2(0, 0)};
#line 471
[unroll]
for(uint j = 0; j < 4; j++)
{
uint2 write_pos = deinterleave_pos(i.dispatchthreadid.xy * 2 + offsets[j], 4u, BUFFER_SCREEN_SIZE_DLSS);
tex2Dstore(stZSrc, write_pos, depth_texels[j]);
}
}
#line 485
float2 MXAOFused(uint2 screenpos, float4 uv)
{
float z = tex2Dlod(sZSrc, uv.xy, 0).x;
float d = Camera::z_to_depth(z);
#line 490
[branch]
if(get_fade_factor(d) < 0.001) return float2(1, d);
#line 493
float3 p = Camera::uv_to_proj(uv.zw, z);
float edge_weight;
float3 n = get_normals(uv.zw, edge_weight);
p = p * 0.996;
float3 v = normalize(-p);
#line 499
float4 texture_scale = float2(1.0 / 4u, 1.0).xxyy * BUFFER_ASPECT_RATIO_DLSS.xyxy;
#line 501
uint slice_count  = samples_per_preset[MXAO_GLOBAL_SAMPLE_QUALITY_PRESET].x;
uint sample_count = samples_per_preset[MXAO_GLOBAL_SAMPLE_QUALITY_PRESET].y;
#line 504
float2 jitter = get_jitter(screenpos);
#line 506
float3 slice_dir = 0; sincos(jitter.x * PI * (6.0/slice_count), slice_dir.x, slice_dir.y);
float2x2 rotslice; sincos(PI / slice_count, rotslice._21, rotslice._11); rotslice._12 = -rotslice._21; rotslice._22 = rotslice._11;
#line 509
float worldspace_radius = MXAO_SAMPLE_RADIUS * 0.5;
float screenspace_radius = worldspace_radius / p.z * 0.5;
#line 512
[flatten]
if(MXAO_WORLDSPACE_ENABLE)
{
screenspace_radius = MXAO_SAMPLE_RADIUS * 0.03;
worldspace_radius = screenspace_radius * p.z * 2.0;
}
#line 519
float visibility = 0;
float slicesum = 0;
float T = log(1 + worldspace_radius) * 0.3333;
#line 523
float falloff_factor = rcp(worldspace_radius);
falloff_factor *= falloff_factor;
#line 528
float2 vcrossn_xy = float2(v.yz * n.zx - v.zx * n.yz);
float ndotv = dot(n, v);
#line 531
while(slice_count-- > 0) 
{
slice_dir.xy = mul(slice_dir.xy, rotslice);
float4 scaled_dir = (slice_dir.xy * screenspace_radius).xyxy * texture_scale;
#line 536
float sdotv = dot(slice_dir.xy, v.xy);
float sdotn = dot(slice_dir.xy, n.xy);
float ndotns = dot(slice_dir.xy, vcrossn_xy) * rsqrt(saturate(1 - sdotv * sdotv));
#line 540
float sliceweight = sqrt(saturate(1 - ndotns * ndotns));
float cosn = saturate(ndotv * rcp(sliceweight));
float normal_angle = Math::fast_acos(cosn);
normal_angle = sdotn < sdotv * ndotv ? -normal_angle : normal_angle;
#line 545
float2 maxhorizoncos = sin(normal_angle); maxhorizoncos.y = -maxhorizoncos.y; 
bitfield_init();
[unroll]
for(int side = 0; side < 2; side++)
{
maxhorizoncos = maxhorizoncos.yx; 
float lowesthorizoncos = maxhorizoncos.x; 
#line 553
[loop]
for(int _sample = 0; _sample < sample_count; _sample += 2)
{
float2 s = (_sample + float2(0, 1) + jitter.y) / sample_count; s *= s;
#line 558
float4 tap_uv[2] = {uv + s.x * scaled_dir,
uv + s.y * scaled_dir};
#line 561
if(!all(saturate(tap_uv[1].zw - tap_uv[1].zw * tap_uv[1].zw))) break;
#line 563
float2 zz; 
zz.x = tex2Dlod(sZSrc, tap_uv[0].xy, 0).x;
zz.y = tex2Dlod(sZSrc, tap_uv[1].xy, 0).x;
#line 567
[unroll] 
for(uint pair = 0; pair < 2; pair++)
{
float3 deltavec = Camera::uv_to_proj(tap_uv[pair].zw, zz[pair]) - p;
#line 572
float ddotd = dot(deltavec, deltavec);
float samplehorizoncos = dot(deltavec, v) * rsqrt(ddotd);
float falloff = rcp(1 + ddotd * falloff_factor);
samplehorizoncos = lerp(lowesthorizoncos, samplehorizoncos, falloff);
maxhorizoncos.x = max(maxhorizoncos.x, samplehorizoncos);
#line 592
  
}
}
scaled_dir = -scaled_dir; 
}
#line 598
float2 max_horizon_angle = Math::fast_acos(maxhorizoncos);
float2 h = float2(-max_horizon_angle.x, max_horizon_angle.y); 
visibility += dot(cosn + 2.0 * h * sin(normal_angle) - cos(2.0 * h - normal_angle), sliceweight);
slicesum++;
#line 610
}
#line 613
visibility /= slicesum * 4;
#line 620
float2 res = float2(saturate(visibility), edge_weight > 0.5 ? -d : d);
#line 625
return res;
}
#line 629
void OcclusionWrapCS(in CSIN i)
{
if(!check_boundaries(i.dispatchthreadid.xy, ((((BUFFER_SCREEN_SIZE_DLSS) - 1) / (4u)) + 1) * 4u)) return;
#line 633
uint2 screen_pos = reinterleave_pos(i.dispatchthreadid.xy, 4u, BUFFER_SCREEN_SIZE_DLSS);
uint2 tile_idx = i.dispatchthreadid.xy / ((((BUFFER_SCREEN_SIZE_DLSS) - 1) / (4u)) + 1);
#line 636
if(shading_rate(tile_idx)) return;
#line 638
float4 uv;
uv.xy = pixel_idx_to_uv(i.dispatchthreadid.xy, BUFFER_SCREEN_SIZE_DLSS);
uv.zw = pixel_idx_to_uv(screen_pos, BUFFER_SCREEN_SIZE_DLSS);
#line 642
float2 o = MXAOFused(screen_pos, uv);
#line 644
o.x = lerp(1, o.x, saturate(MXAO_SSAO_AMOUNT));
if(MXAO_SSAO_AMOUNT > 1) o.x = lerp(o.x, o.x * o.x, saturate(MXAO_SSAO_AMOUNT - 1)); 
o.x = lerp(1, o.x, get_fade_factor(o.y));
#line 648
tex2Dstore(stMXAOTex1, screen_pos, float4(o.xy, o.xy * o.xy));
}
#line 686
float2 filter(float2 uv, sampler sAO, int iter)
{
float g = tex2D(sAO, uv).y;
bool blurry = g < 0;
float flip = iter ? -1 : 1;
#line 692
float4 ao, depth, mv;
ao = tex2DgatherR(sAO, uv + flip * BUFFER_PIXEL_SIZE_DLSS * float2(-0.5, -0.5));
depth = abs(tex2DgatherG(sAO, uv + flip * BUFFER_PIXEL_SIZE_DLSS * float2(-0.5, -0.5))); 
mv = float4(dot(depth, 1), dot(depth, depth), dot(ao, 1), dot(ao, depth));
#line 697
ao = tex2DgatherR(sAO, uv + flip * BUFFER_PIXEL_SIZE_DLSS * float2(1.5, -0.5));
depth = abs(tex2DgatherG(sAO, uv + flip * BUFFER_PIXEL_SIZE_DLSS * float2(1.5, -0.5)));
mv += float4(dot(depth, 1), dot(depth, depth), dot(ao, 1), dot(ao, depth));
#line 701
ao = tex2DgatherR(sAO, uv + flip * BUFFER_PIXEL_SIZE_DLSS * float2(-0.5, 1.5));
depth = abs(tex2DgatherG(sAO, uv + flip * BUFFER_PIXEL_SIZE_DLSS * float2(-0.5, 1.5)));
mv += float4(dot(depth, 1), dot(depth, depth), dot(ao, 1), dot(ao, depth));
#line 705
ao = tex2DgatherR(sAO, uv + flip * BUFFER_PIXEL_SIZE * float2(1.5, 1.5));
depth = abs(tex2DgatherG(sAO, uv + flip * BUFFER_PIXEL_SIZE_DLSS * float2(1.5, 1.5)));
mv += float4(dot(depth, 1), dot(depth, depth), dot(ao, 1), dot(ao, depth));
#line 709
mv /= 16.0;
#line 711
float b = (mv.w - mv.x * mv.z) / max(mv.y - mv.x * mv.x, exp2(blurry ? -12 : -30));
float a = mv.z - b * mv.x;
return float2(saturate(b * abs(g) + a), g); 
}
#line 716
void Filter1PS(in VSOUT i, out float2 o : SV_Target0)
{
o = 0; 
if(MXAO_FILTER_SIZE < 2) discard;
o = filter(i.uv, sMXAOTex1, 0);
}
#line 784
 
#line 786
void Filter2PS(in VSOUT i, out float3 o : SV_Target0)
{
float mxao = 0;
#line 790
[branch]
if(MXAO_FILTER_SIZE == 2)
mxao = filter(i.uv, sMXAOTex2, 1).x;
else if(MXAO_FILTER_SIZE == 1)
mxao = filter(i.uv, sMXAOTex1, 1).x;
else
mxao = tex2Dlod(sMXAOTex1, i.uv, 0).x;
#line 799
 
float3 color = tex2D(ColorInput, i.uv).rgb;
#line 802
color *= color;
color = color * rcp(1.1 - color);
color *= mxao;
color = 1.1 * color * rcp(color + 1.0);
color = sqrt(color);
#line 808
o = MXAO_DEBUG_VIEW_ENABLE ? mxao : color;
}
#line 815
technique MartysMods_MXAO
<
ui_label = "iMMERSE: MXAO";
ui_tooltip =
"                              MartysMods - MXAO                               \n"
"                   MartysMods Epic ReShade Effects (iMMERSE)                  \n"
"______________________________________________________________________________\n"
"\n"
#line 824
"MXAO is a high quality, high performance Screen-Space Ambient Occlusion (SSAO)\n"
"effect which accurately simulates diffuse shadows in dark corners and crevices\n"
"\n"
"\n"
"Visit https://martysmods.com for more information.                            \n"
"\n"
"______________________________________________________________________________";
>
{
#line 834
pass
{
ComputeShader = DeinterleaveCS<32, 32>;
DispatchSizeX = ((((1920) - 1) / (64)) + 1);
DispatchSizeY = ((((1018) - 1) / (64)) + 1);
}
pass
{
ComputeShader = OcclusionWrapCS<16, 16>;
DispatchSizeX = ((((1920) - 1) / (16)) + 1);
DispatchSizeY = ((((1018) - 1) / (16)) + 1);
}
#line 856
pass { VertexShader = MainVS; PixelShader = Filter1PS; RenderTarget = MXAOTex2; }
#line 859
pass { VertexShader = MainVS; PixelShader = Filter2PS; }
}

