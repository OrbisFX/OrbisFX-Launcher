#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_SCENEWEAVER.fx"
#line 43
uniform int UISPACING0 <ui_type = "radio";ui_label = "\n\n";ui_text = "";>;
#line 46
uniform int UIHELP_HOTSAMPLE <
ui_type = "radio";
ui_label = " ";
ui_text = "During hotsampling, the lower part of the game window extends beyond\n"
"the screen edges. This effect rescales the image to fit the screen.\n"
"Automatically disabled in screenshots, so you may leave it enabled.\n\n"
"Enable METEOR: SceneWeaver (Hotsampling) to use this feature\n"
"and move the technique to the bottom of your stack, but before Canvas.";
ui_category = "Hotsampling";
>;
uniform int HOTSAMPLING_TARGET_RESOLUTION_X <
ui_type = "drag";
ui_min = 480; ui_max = 8192;
ui_units = "px";
ui_label = "Your screen width";
ui_tooltip = "The shader will resize the viewport of the game to this resolution.\nThis will make the preview always fill the screen, independent of the hotsampling factor.";
ui_category = "Hotsampling";
> = 3440;
#line 65
uniform int UISPACING1 <ui_type = "radio";ui_label = "\n\n\n";ui_text = "";ui_category = "Hotsampling";>;
#line 67
uniform int UIHELP_LETTERBOX <
ui_type = "radio";
ui_label = " ";
ui_text = "Adds cinematic black bars to the image, to assist you when framing a shot.\n"
"Enable METEOR: SceneWeaver (Letterbox) to use this feature.";
ui_category = "Letterbox";
>;
#line 75
uniform int LETTERBOX_PRESET <
ui_type = "combo";
ui_label = "Preset";
ui_items = " Custom \0 1:1 \0 5:4 \0 4:3 \0 3:2 \0 16:10 \0 Golden Ratio \0 16:9 \0 1.85:1 \0 2:1 \0 2.35:1 \0 ";
ui_tooltip = "Select a desired aspect ratio for the letterbox or create your own.";
ui_category = "Letterbox";
> = 0;
#line 83
uniform int2 LETTERBOX_CUSTOMRATIO <
ui_type = "slider";
ui_min = 1;
ui_max = 20;
ui_label = "Custom Ratio";
ui_tooltip = "Set the letterbox preset to Custom and pick your own aspect ratio.";
ui_category = "Letterbox";
> = int2(1, 1);
#line 92
uniform int UISPACING2 <ui_type = "radio";ui_label = "\n\n\n";ui_text = "";ui_category = "Letterbox";>;
#line 95
uniform int UIHELP_CANVAS <
ui_type = "radio";
ui_label = " ";
ui_text = "This feature masks the cinematic black bars with a more neutral canvas\n"
"color and offers various tools to assist you when framing a screenshot.\n"
"Automatically disabled in screenshots,so only the black bars remain.\n\n"
"Enable METEOR: SceneWeaver (Canvas) to use this feature\n"
"and move the technique to the very bottom of your stack.";
ui_category = "Canvas";
>;
#line 106
uniform float CANVAS_ZOOM <
ui_type = "drag";
ui_label = "Zoom Out";
ui_min = 0.0;
ui_max = 100.0;
ui_step = 1.0;
ui_units = "%%";
ui_tooltip = "Viewing the image from a distance can help you spot issues in the composition.";
ui_category = "Canvas";
> = 0.0;
#line 117
uniform int CANVAS_ROTATE <
ui_type = "slider";
ui_min = -1;
ui_max = 1;
ui_label = "Rotation";
ui_tooltip = "Hotsampling a portrait sideways results in fewer cropped pixels but requires\n"
"turning your head all the time. This feature saves your neck and your time.";
ui_category = "Canvas";
> = 0;
#line 127
uniform float CANVAS_BG <
ui_type = "drag";
ui_label = "Canvas Brightness";
ui_min = 0.0;
ui_max = 100.0;
ui_step = 1.0;
ui_units = "%%";
ui_category = "Canvas";
ui_tooltip = "A more neutral grey background color makes judging the overall exposure of the\n"
"shot a lot easier than a black or white background.";
> = 40.0;
#line 139
uniform int CANVAS_GRID <
ui_type = "combo";
ui_label = "Grid";
ui_items = " None \0 Rule of Thirds \0 Golden Spiral (Top Left) \0 Golden Spiral (Top Right) \0 Golden Spiral (Bottom Left) \0 Golden Spiral (Bottom Right) \0 Golden Spiral (Top Left Alt) \0 Golden Spiral (Top Right Alt) \0 Golden Spiral (Bottom Left Alt) \0 Golden Spiral (Bottom Right Alt) \0 ";
ui_tooltip = "Select an overlay grid to help you with the composition of your shot.";
ui_category = "Canvas";
> = 0;
#line 147
uniform float CANVAS_RULEOFTHIRDS_ALPHA <
ui_type = "drag";
ui_label = "Grid Opacity";
ui_min = 0.0;
ui_max = 100.0;
ui_step = 1.0;
ui_units = "%%";
ui_category = "Canvas";
> = 30.0;
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
#line 178 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_SCENEWEAVER.fx"
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
#line 179 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_SCENEWEAVER.fx"
#line 182
texture ColorInputTex : COLOR;
sampler ColorInput 	{ Texture = ColorInputTex; };
#line 185
texture2D HotsampleStateTex	 {Format = R8;};
sampler2D sHotsampleStateTex {Texture = HotsampleStateTex;};
#line 203
struct VSOUT
{
float4 vpos : SV_Position;
float4 uv   : TEXCOORD0;
};
#line 209
struct CSIN
{
uint3 groupthreadid     : SV_GroupThreadID;
uint3 groupid           : SV_GroupID;
uint3 dispatchthreadid  : SV_DispatchThreadID;
uint threadid           : SV_GroupIndex;
};
#line 221
float lanczos2( float x )
{
#line 228
float t = saturate(x * x * 0.25);
float res = 1 - 4.0/9.0 * t;
res = res - res * t;
res *= res;
res = res - res * t; 
res *= 1 - 4 * t;
return res;
#line 237
}
#line 239
float2 rotate(float2 v, float ang)
{
float2 sc; sincos(radians(ang), sc.x, sc.y);
float2x2 rot = float2x2(sc.y, -sc.x, sc.x, sc.y);
return mul(v, rot);
}
#line 246
float get_target_aspect(uint idx)
{
float aspects[11] = {float(LETTERBOX_CUSTOMRATIO.x) / float(LETTERBOX_CUSTOMRATIO.y),
1,
5.0/4.0,
4.0/3.0,
3.0/2.0,
16.0/10.0,
1.61803398874989484820459,
16.0/9.0,
1.85,
2.0,
2.35};
return aspects[idx];
}
#line 262
float2 transform(float2 uv)
{
float dest  = get_target_aspect(LETTERBOX_PRESET);
float curr  = BUFFER_ASPECT_RATIO.y;
#line 267
float4 scalemad;
scalemad.xy = curr > dest ? float2(curr / dest, 1) : float2(1, dest / curr);
scalemad.zw = 0.5 - 0.5 * scalemad.xy;
return uv * scalemad.xy + scalemad.zw;
}
#line 273
float2 transform_inverse(float2 uv)
{
float dest  = get_target_aspect(LETTERBOX_PRESET);
float curr  = BUFFER_ASPECT_RATIO.y;
#line 278
float4 scalemad;
scalemad.xy = curr < dest ? float2(1, curr * curr) : float2(dest * rcp(curr), dest * curr) * max(1, rcp(dest * curr));
scalemad.zw = 0.5 - 0.5 * scalemad.xy;
return uv * scalemad.xy + scalemad.zw;
}
#line 284
float sdf_goldenspiral(float2 p)
{
const float a = 0.8541019;
const float b = 0.3063489;
#line 289
float r = length(p);
float t = -atan2(p.y, p.x);
#line 292
float n = (log(r / a) / b - t) / TAU;
float2 d = a * exp(b * (t + TAU * floor(n + float2(1, 0)))) - r;
#line 295
return minc(abs(d));
}
#line 302
VSOUT MainVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv.xy); o.uv.zw = o.uv.xy;
return o;
}
#line 309
void MainPS(in VSOUT i, out float4 o : SV_Target)
{
int2 dst_texel = int2(i.vpos.xy);
float scaling = 1920 / float(min(1920, HOTSAMPLING_TARGET_RESOLUTION_X));
if(any(i.uv.xy * scaling >= 1.0))
{
o = 0;
return;
}
#line 319
o = 0;
#line 321
int2 kernelsize = ceil(scaling*2.0);
kernelsize = min(kernelsize, 10);
float2 src_texel_center = floor((dst_texel + 0.5) * scaling);
float2 src_texel;
float2 otdtc;
float2 w;
#line 328
[loop]
for(int y = -kernelsize.y; y < kernelsize.y; y++)
{
src_texel.y = src_texel_center.y + y;
otdtc.y = src_texel.y / scaling - dst_texel.y;
w.y = lanczos2(otdtc.y);
#line 335
[loop]
for(int x = -kernelsize.x; x < kernelsize.x; x++)
{
src_texel.x = src_texel_center.x + x;
otdtc.x = src_texel.x / scaling - dst_texel.x;
w.x = lanczos2(otdtc.x);
#line 342
float3 t = tex2Dfetch(ColorInput, src_texel).rgb;
o += float4(t * t, 1) * w.x * w.y;
}
}
#line 347
o.rgb /= o.w;
o = sqrt(saturate(o));
}
#line 351
float4 HotsamplingStateVS(in uint id : SV_VertexID) : SV_Position {return float4(0,0,0,1);}
void SetHotsamplingStatePS(in float4 vpos : SV_Position, out float o : SV_Target0){o = 1;}
void ResetHotsamplingStatePS(in float4 vpos : SV_Position, out float o : SV_Target0){o = 0;}
bool is_hotsampling_enabled(){return tex2Dfetch(sHotsampleStateTex, int2(0,0)).r > 0.5;}
#line 360
VSOUT LetterboxVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv.xy); o.uv.zw = o.uv.xy;
o.uv.xy = transform(o.uv.xy);
return o;
}
#line 368
void LetterboxPS(in VSOUT i, out float4 o : SV_Target)
{
if(Math::inside_screen(i.uv.xy))
discard;
o = 0;
}
#line 375
VSOUT CanvasVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv.xy);
#line 380
if(CANVAS_ROTATE)
{
o.uv = rotate(o.uv.xy - 0.5, CANVAS_ROTATE * 90.0).xyxy + 0.5;
o.uv.xy = transform_inverse(o.uv.xy);
}
#line 386
o.uv.zw = transform(o.uv.xy);
o.uv = (o.uv - 0.5) * exp2(CANVAS_ZOOM * 0.01) + 0.5;
#line 389
if(is_hotsampling_enabled())
{
float scaling = 1920 / float(min(1920, HOTSAMPLING_TARGET_RESOLUTION_X));
o.vpos.xy += float2(1, -1);
o.vpos.xy /= scaling;
o.vpos.xy -= float2(1, -1);
o.uv.xy /= scaling;
}
#line 400
return o;
}
#line 403
void CanvasPS(in VSOUT i, out float3 o : SV_Target)
{
o = tex2Dlod(ColorInput, i.uv.xyyy).rgb;
float scaling = 1920 / float(min(1920, HOTSAMPLING_TARGET_RESOLUTION_X));
if(is_hotsampling_enabled() && any(i.vpos.xy >= BUFFER_SCREEN_SIZE / scaling))
{
discard;
}
#line 412
if(CANVAS_GRID == 1)
{
float4 griduv   = (i.uv.zwzw - float2(1,2).xxyy / 3.0);
float2 aa       = float2(length(fwidth(griduv.xy)), length(fwidth(griduv.zw)));
float4 gridline = smoothstep(aa.xxyy, 0, abs(griduv));
#line 418
o = lerp(o, dot(o, 0.3333) < 0.5, saturate(dot(gridline, 1)) * CANVAS_RULEOFTHIRDS_ALPHA * 0.01);
}
else if(CANVAS_GRID >= 2 && CANVAS_GRID <= 9)
{
float2 gruv = i.uv.zw * 2.0 - 1.0;
#line 424
switch(CANVAS_GRID)
{
case 2: gruv = float2(-gruv.x, -gruv.y); break;
case 3: gruv = float2( gruv.x, -gruv.y); break;
case 4: gruv = float2(-gruv.x,  gruv.y); break;
case 5: gruv = float2( gruv.x,  gruv.y); break;
case 6: gruv = float2(-gruv.y, -gruv.x); break;
case 7: gruv = float2(-gruv.y,  gruv.x); break;
case 8: gruv = float2( gruv.y, -gruv.x); break;
case 9: gruv = float2( gruv.y,  gruv.x); break;
}
#line 436
gruv -= rsqrt(5.0);
gruv.x *= 1.61803398874989484820459;
#line 439
float sdf = sdf_goldenspiral(gruv);
float dx = max(sdf_goldenspiral(gruv + ddx(gruv)), sdf_goldenspiral(gruv - ddx(gruv))) - sdf;
float dy = max(sdf_goldenspiral(gruv + ddy(gruv)), sdf_goldenspiral(gruv - ddy(gruv))) - sdf;
sdf *= rsqrt(dx * dx + dy * dy);
#line 444
sdf = smoothstep(sqrt(2), 0, sdf);
o = lerp(o, dot(o, 0.3333) < 0.5, sdf * CANVAS_RULEOFTHIRDS_ALPHA * 0.01);
}
#line 448
o = lerp(CANVAS_BG * 0.01, o, all(saturate(i.uv.zw - i.uv.zw * i.uv.zw)));
}
#line 455
technique MartysMods_SceneWeaver_Hotsampling
<
enabled_in_screenshot = false;
ui_label = "METEOR: SceneWeaver (Hotsampling)";
ui_tooltip =
"                         MartysMods - SceneWeaver                       \n"
"                   Marty's Extra Effects for ReShade (METEOR)                 \n"
"______________________________________________________________________________\n"
"\n"
"Various features for hotsampling and framing a screenshot.                    \n"
"\n"
"\n"
"Visit https://martysmods.com for more information.                            \n"
"\n"
"______________________________________________________________________________";
>
{
pass
{
VertexShader = MainVS;
PixelShader  = MainPS;
}
#line 478
pass
{
VertexShader = HotsamplingStateVS;
PixelShader = SetHotsamplingStatePS;
RenderTarget = HotsampleStateTex;
PrimitiveTopology = POINTLIST;
VertexCount = 1;
}
}
#line 488
technique MartysMods_SceneWeaver_Letterbox
<
ui_label = "METEOR: SceneWeaver (Letterbox)";
ui_tooltip =
"                         MartysMods - SceneWeaver                       \n"
"                   Marty's Extra Effects for ReShade (METEOR)                 \n"
"______________________________________________________________________________\n"
"\n"
"Various features for hotsampling and framing a screenshot.                    \n"
"\n"
"\n"
"Visit https://martysmods.com for more information.                            \n"
"\n"
"______________________________________________________________________________";
>
{
pass
{
VertexShader = LetterboxVS;
PixelShader  = LetterboxPS;
}
}
#line 511
technique MartysMods_SceneWeaver_Canvas
<
enabled_in_screenshot = false;
ui_label = "METEOR: SceneWeaver (Canvas)";
ui_tooltip =
"                         MartysMods - SceneWeaver                       \n"
"                   Marty's Extra Effects for ReShade (METEOR)                 \n"
"______________________________________________________________________________\n"
"\n"
"Various features for hotsampling and framing a screenshot.                    \n"
"\n"
"\n"
"Visit https://martysmods.com for more information.                            \n"
"\n"
"______________________________________________________________________________";
>
{
pass
{
VertexShader = CanvasVS;
PixelShader  = CanvasPS;
}
#line 534
pass
{
VertexShader = HotsamplingStateVS;
PixelShader = ResetHotsamplingStatePS;
RenderTarget = HotsampleStateTex;
PrimitiveTopology = POINTLIST;
VertexCount = 1;
}
}

