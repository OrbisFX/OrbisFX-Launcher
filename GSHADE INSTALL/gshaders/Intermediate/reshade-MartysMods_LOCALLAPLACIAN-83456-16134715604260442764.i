#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_LOCALLAPLACIAN.fx"
#line 50
uniform float STRENGTH <
ui_label = "Local Contrast Strength";
ui_type = "drag";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
#line 57
uniform int INTERP <
ui_type = "combo";
ui_label = "Pyramid Upscaling";
ui_items = "Bilinear\0Bicubic\0";
> = 0;
#line 67
texture ColorInputTex : COLOR;
sampler ColorInput 	{ Texture = ColorInputTex; };
#line 70
struct VSOUT
{
float4                  vpos        : SV_Position;
float2                  uv          : TEXCOORD0;
};
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
#line 77 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_LOCALLAPLACIAN.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_texture.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_global.fxh"
#line 21 "C:\Program Files\GShade\gshade-shaders\Shaders\.\MartysMods\mmx_texture.fxh"
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
#line 78 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_LOCALLAPLACIAN.fx"
#line 124
texture GaussianPyramidAtlasTexLevel0 { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>0; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>0; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel0 { Texture = GaussianPyramidAtlasTexLevel0;};
#line 128
texture GaussianPyramidAtlasTexLevel1Tmp { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>1; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>0; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel1Tmp { Texture = GaussianPyramidAtlasTexLevel1Tmp;};
texture GaussianPyramidAtlasTexLevel1 { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>1; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>1; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel1 { Texture = GaussianPyramidAtlasTexLevel1;};
#line 134
texture GaussianPyramidAtlasTexLevel2Tmp { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>2; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>1; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel2Tmp { Texture = GaussianPyramidAtlasTexLevel2Tmp;};
texture GaussianPyramidAtlasTexLevel2 { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>2; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>2; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel2 { Texture = GaussianPyramidAtlasTexLevel2;};
#line 140
texture GaussianPyramidAtlasTexLevel3Tmp { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>3; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>2; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel3Tmp { Texture = GaussianPyramidAtlasTexLevel3Tmp;};
texture GaussianPyramidAtlasTexLevel3 { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>3; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>3; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel3 { Texture = GaussianPyramidAtlasTexLevel3;};
#line 146
texture GaussianPyramidAtlasTexLevel4Tmp { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>4; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>3; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel4Tmp { Texture = GaussianPyramidAtlasTexLevel4Tmp;};
texture GaussianPyramidAtlasTexLevel4 { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>4; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>4; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel4 { Texture = GaussianPyramidAtlasTexLevel4;};
#line 152
texture GaussianPyramidAtlasTexLevel5Tmp { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>5; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>4; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel5Tmp { Texture = GaussianPyramidAtlasTexLevel5Tmp;};
texture GaussianPyramidAtlasTexLevel5 { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>5; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>5; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel5 { Texture = GaussianPyramidAtlasTexLevel5;};
#line 158
texture GaussianPyramidAtlasTexLevel6Tmp { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>6; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>5; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel6Tmp { Texture = GaussianPyramidAtlasTexLevel6Tmp;};
texture GaussianPyramidAtlasTexLevel6 { Width = ((((((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (2)))>>6; Height = ((((((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2)))) * (3)))>>6; Format = RGBA16F;};
sampler sGaussianPyramidAtlasTexLevel6 { Texture = GaussianPyramidAtlasTexLevel6;};
#line 182
texture CollapsedLaplacianPyramidTex { Width = (((((1920 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2))); Height = (((((1018 / 2)) - 1) / ((1 << (((8) - 2))))) + 1) * (1 << (((8) - 2))); Format = RG16F;};
sampler sCollapsedLaplacianPyramidTex { Texture = CollapsedLaplacianPyramidTex;};
#line 209
float remap_function(float x, float gaussian, float alpha)
{
#line 212
[flatten]if(gaussian < 0) return x;
#line 226
alpha = alpha > 0 ? 2 * alpha : alpha;
gaussian = saturate(gaussian);
float delta = x - gaussian;
float w = saturate(1 - x * 2);
w *= w;
return x + alpha * delta * exp(-delta * delta * 100.0) * saturate(1 - w * w);
}
#line 237
float get_luma(float3 c)
{
return (1.14374*(-0.126893*(dot(((c)*0.283799*((2.52405+(c))*(c))), float3(0.2126, 0.7152, 0.0722)))+sqrt(dot(((c)*0.283799*((2.52405+(c))*(c))), float3(0.2126, 0.7152, 0.0722)))));
}
#line 246
VSOUT MainVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv.xy);
return o;
}
#line 253
void InitPyramidAtlasPS(in VSOUT i, out float4 o : SV_Target0)
{
#line 256
int2 tile_id = floor(i.uv * float2(2, 3));
int tile_id_1d = tile_id.y * 2 + tile_id.x;
#line 262
int num_remapping_intervals = 2 * 3 * 4;
int4 curr_remapping_intervals = tile_id_1d * 4 + int4(0, 1, 2, 3); 
curr_remapping_intervals--; 
num_remapping_intervals--; 
#line 269
float4 normalized_remapping_intervals = float4(curr_remapping_intervals) / (num_remapping_intervals - 1);
#line 271
float2 tile_uv = frac(i.uv * float2(2, 3));
float grey = get_luma(tex2D(ColorInput, tile_uv).rgb);
#line 274
float4 remapped;
remapped.x = remap_function(grey, normalized_remapping_intervals.x, STRENGTH);
remapped.y = remap_function(grey, normalized_remapping_intervals.y, STRENGTH);
remapped.z = remap_function(grey, normalized_remapping_intervals.z, STRENGTH);
remapped.w = remap_function(grey, normalized_remapping_intervals.w, STRENGTH);
#line 280
remapped = saturate(remapped);
o = remapped;
}
#line 285
float4 tile_downsample_new(sampler s, float2 uv, const bool horizontal)
{
float2 num_tiles = float2(2, 3);
const float2 tile_uv_size = rcp(num_tiles);
float2 tile_mid_uv = (floor(uv * num_tiles) + 0.5) * tile_uv_size;
#line 291
float2 texelsize = rcp(tex2Dsize(s, 0));
float2 axis = horizontal ? float2(texelsize.x, 0) : float2(0, texelsize.y);
#line 294
float4 result = 0;
float weightsum = 0;
#line 297
[unroll]for(int j = -4; j < 4; j++)
{
float offset = (j + 0.5);
float w = exp(-offset * offset * 0.13);
float2 tap_uv = uv + axis * offset;
float4 tap = tex2Dlod(s, tap_uv, 0);
#line 305
if(horizontal)
w *= step(abs(tap_uv.x - tile_mid_uv.x), tile_uv_size.x * 0.5 - texelsize.x * 0.125);
else
w *= step(abs(tap_uv.y - tile_mid_uv.y), tile_uv_size.y * 0.5 - texelsize.y * 0.125);
#line 310
tap *= tap;
#line 312
result += tap * w;
weightsum += w;
}
#line 316
result *= rcp(weightsum);
result = sqrt(result);
return result;
}
#line 323
void DownsamplePyramidsPS0H(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel0, i.uv, true);}
void DownsamplePyramidsPS0V(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel1Tmp, i.uv, false);}
#line 327
void DownsamplePyramidsPS1H(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel1, i.uv, true);}
void DownsamplePyramidsPS1V(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel2Tmp, i.uv, false);}
#line 331
void DownsamplePyramidsPS2H(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel2, i.uv, true);}
void DownsamplePyramidsPS2V(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel3Tmp, i.uv, false);}
#line 335
void DownsamplePyramidsPS3H(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel3, i.uv, true);}
void DownsamplePyramidsPS3V(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel4Tmp, i.uv, false);}
#line 339
void DownsamplePyramidsPS4H(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel4, i.uv, true);}
void DownsamplePyramidsPS4V(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel5Tmp, i.uv, false);}
#line 343
void DownsamplePyramidsPS5H(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel5, i.uv, true);}
void DownsamplePyramidsPS5V(in VSOUT i, out float4 o : SV_Target0){o = tile_downsample_new(sGaussianPyramidAtlasTexLevel6Tmp, i.uv, false);}
#line 359
float sample_pyramid(sampler s, float2 uv, int pyramid_index)
{
const int2 num_tiles = int2(2, 3);
float2 tile_res = tex2Dsize(s, 0) / num_tiles;
float2 texelsize = rcp(tile_res);
#line 366
uv = clamp(uv, texelsize, 1 - texelsize);
#line 368
int tile_id_1d = pyramid_index / 4;
int channel = pyramid_index % 4;
#line 371
int2 tile_id = int2(tile_id_1d % 2, tile_id_1d / 2);
float2 tile_start = float2(tile_id) / num_tiles;
float2 tile_end = float2(tile_id + 1) / num_tiles;
#line 375
float2 tile_uv = lerp(tile_start, tile_end, uv);
float pyramid = 0;
#line 378
if(INTERP == 0)
{
pyramid = tex2Dlod(s, tile_uv, 0)[channel];
}
else
{
pyramid = Texture::sample2D_bspline_auto(s, tile_uv)[channel];
}
#line 387
return pyramid;
}
#line 390
float eval_laplacian(sampler s_i, sampler s_iplus1, float2 uv, int level)
{
float G = sample_pyramid(s_i, uv, 0);
#line 394
const float num_remapping_intervals = 2 * 3 * 4 - 1; 
float denormalizedG = G * (num_remapping_intervals - 1);
#line 397
int lo_idx = floor(denormalizedG);
int hi_idx = ceil(denormalizedG);
float interpolant = frac(denormalizedG);
#line 402
lo_idx++;
hi_idx++;
#line 405
float layer_a = lerp(sample_pyramid(s_i,      uv, lo_idx), sample_pyramid(s_i,      uv, hi_idx), interpolant);
float layer_b = lerp(sample_pyramid(s_iplus1, uv, lo_idx), sample_pyramid(s_iplus1, uv, hi_idx), interpolant);
return ((level + 1) == ((8) - 2)) ? layer_a : layer_a - layer_b;
}
#line 410
void CollapseTiledPyramidPS(in VSOUT i, out float2 o : SV_Target0)
{
float collapsed = 0;
#line 416
collapsed += eval_laplacian(sGaussianPyramidAtlasTexLevel0, sGaussianPyramidAtlasTexLevel1, i.uv, 0);
#line 419
collapsed += eval_laplacian(sGaussianPyramidAtlasTexLevel1, sGaussianPyramidAtlasTexLevel2, i.uv, 1);
#line 422
collapsed += eval_laplacian(sGaussianPyramidAtlasTexLevel2, sGaussianPyramidAtlasTexLevel3, i.uv, 2);
#line 425
collapsed += eval_laplacian(sGaussianPyramidAtlasTexLevel3, sGaussianPyramidAtlasTexLevel4, i.uv, 3);
#line 428
collapsed += eval_laplacian(sGaussianPyramidAtlasTexLevel4, sGaussianPyramidAtlasTexLevel5, i.uv, 4);
#line 431
collapsed += eval_laplacian(sGaussianPyramidAtlasTexLevel5, sGaussianPyramidAtlasTexLevel6, i.uv, 5);
#line 443
o.x = collapsed;
o.y = get_luma(tex2D(ColorInput, i.uv).rgb);
}
#line 447
void GuidedUpsamplingPS(in VSOUT i, out float3 o : SV_Target0)
{
float2 gaussian_sigma0dot7 = float2(0.5424, 0.2288);
#line 451
float4 moments = 0; 
float ws = 0.0;
#line 454
[unroll]for(int y = -1; y <= 1; y++)
[unroll]for(int x = -1; x <= 1; x++)
{
float2 offs = float2(x, y);
float2 t = tex2D(sCollapsedLaplacianPyramidTex, i.uv + offs * BUFFER_PIXEL_SIZE * 2).xy;
float w = gaussian_sigma0dot7[abs(x)] * gaussian_sigma0dot7[abs(y)];
moments += float4(t.y, t.y * t.y, t.y * t.x, t.x) * w;
ws += w;
}
#line 464
moments /= ws;
#line 466
float A = (moments.z - moments.x * moments.w) / (max(moments.y - moments.x * moments.x, 0.0) + 0.00001);
float B = moments.w - A * moments.x;
#line 469
o = tex2D(ColorInput, i.uv).rgb;
#line 471
float luma = get_luma(o);
float adjusted_luma = A * luma + B;
#line 474
o = ((o)*0.283799*((2.52405+(o))*(o)));
o = o / (1.1 - o);
float ratioooo = adjusted_luma / (luma + 1e-6);
o *= ratioooo;
o = 1.1 * o / (1.0 + o);
o = (1.14374*(-0.126893*(o)+sqrt(o)));
}
#line 487
technique MartysMods_LocalLaplacian
<
ui_label = "METEOR: Local Laplacian";
ui_tooltip =
"                          MartysMods - Local Laplacian                        \n"
"                   Marty's Extra Effects for ReShade (METEOR)                 \n"
"______________________________________________________________________________\n"
"\n"
#line 496
"METEOR Local Laplacian is an implementation of the 'Fast Local Laplacian'.   \n"
"FLL is state of the art in terms of local contrast enhancement and the backbone\n"
"of ADOBE Lightroom's Clarity/Texture/Dehaze feature.                          \n"
"METEOR Local Laplacian is the only realtime capable implementation so far.   \n"
"\n"
"\n"
"Visit https://martysmods.com for more information.                            \n"
"\n"
"______________________________________________________________________________";
>
{
pass    {VertexShader = MainVS;PixelShader = InitPyramidAtlasPS; RenderTarget = GaussianPyramidAtlasTexLevel0; }
#line 510
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS0H; RenderTarget = GaussianPyramidAtlasTexLevel1Tmp; }
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS0V; RenderTarget = GaussianPyramidAtlasTexLevel1; }
#line 514
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS1H; RenderTarget = GaussianPyramidAtlasTexLevel2Tmp; }
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS1V; RenderTarget = GaussianPyramidAtlasTexLevel2; }
#line 518
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS2H; RenderTarget = GaussianPyramidAtlasTexLevel3Tmp; }
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS2V; RenderTarget = GaussianPyramidAtlasTexLevel3; }
#line 522
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS3H; RenderTarget = GaussianPyramidAtlasTexLevel4Tmp; }
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS3V; RenderTarget = GaussianPyramidAtlasTexLevel4; }
#line 526
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS4H; RenderTarget = GaussianPyramidAtlasTexLevel5Tmp; }
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS4V; RenderTarget = GaussianPyramidAtlasTexLevel5; }
#line 530
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS5H; RenderTarget = GaussianPyramidAtlasTexLevel6Tmp; }
pass    {VertexShader = MainVS;PixelShader = DownsamplePyramidsPS5V; RenderTarget = GaussianPyramidAtlasTexLevel6; }
#line 546
pass    {VertexShader = MainVS;PixelShader = CollapseTiledPyramidPS; RenderTarget = CollapsedLaplacianPyramidTex; }
pass    {VertexShader = MainVS;PixelShader = GuidedUpsamplingPS; }
}

