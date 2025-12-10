#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_HALFTONE.fx"
#line 43
uniform float DOT_SCALE <
ui_type = "drag";
ui_label = "Grid Scale";
ui_min = 1.0;
ui_max = 4.0;
> = 2.0;
#line 54
texture ColorInputTex : COLOR;
sampler ColorInput { Texture = ColorInputTex; };
#line 57
texture FBMNoise { Width = 128; Height = 128; Format = RG8; };
sampler sFBMNoise { Texture = FBMNoise;	AddressU = WRAP; AddressV = WRAP; };
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
#line 61 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_HALFTONE.fx"
#line 66
struct VSOUT
{
float4 vpos : SV_Position;
float2 uv : TEXCOORD0;
};
#line 72
VSOUT MainVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv);
return o;
}
#line 79
float4 rgb_to_cmyk(float3 c)
{
float k = 1 - max(max(c.r, c.g), c.b);
return float4((1 - c.rgb - k) / (1 - k), k);
}
#line 85
float3 cmyk_to_rgb(float4 c)
{
return (1 - c.rgb) * (1 - c.a);
}
#line 90
float draw_circle_aa(float x, float t)
{
float ddxy = fwidth(x) * 0.71;
return saturate(((x - t) - (-ddxy)) * rcp((ddxy) - (-ddxy)));
}
#line 96
float2 rotate(float2 v, float phi)
{
float2 t; sincos(phi, t.x, t.y);
return mul(v, float2x2(t.y, -t.x, t.xy));
}
#line 102
float2 hash(float2 p)
{
p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
return frac(sin(p) * 43758.5453123) * 2 - 1;
}
#line 109
float noise(float2 p)
{
const float G = 0.211324865;
float2 skewed = floor(p + dot(p, 0.366025404));
float2 d0 = p - skewed + dot(skewed, G);
float2 side; side.x = d0.x > d0.y; side.y = !side.x;
float2 d1 = d0 - side + G;
float2 d2 = d0 + G * 2 - 1;
float3 weights = saturate(0.5 - float3(dot(d0, d0), dot(d1, d1), dot(d2, d2))); weights*= weights; weights*= weights;
float3 surflets = float3(dot(d0, hash(skewed)), dot(d1, hash(skewed + side)), dot(d2, hash(skewed + 1.0)));
return dot(surflets * weights, 70.0);
}
#line 128
void NoiseGenPS(in VSOUT i, out float2 o : SV_Target0)
{
float2 jitter;
jitter.x = noise(i.vpos.xy);
jitter.y = noise(i.vpos.xy + 157.44);
jitter.x += noise(0.25 * i.vpos.xy);
jitter.y += noise(0.25 * i.vpos.xy + 44.27);
jitter.x += noise(0.0625 * i.vpos.xy);
jitter.y += noise(0.0625 * i.vpos.xy + 259.4);
o = jitter * 0.5 * 0.25 + 0.5;
}
#line 140
void MainPS(in VSOUT i, out float3 o : SV_Target0)
{
float3 rgb = tex2D(ColorInput, i.uv).rgb;
float4 cmyk = rgb_to_cmyk(rgb);
#line 145
float2 p = i.vpos.xy / DOT_SCALE * 0.2;
float jitter_w = max(0, 1 - DOT_SCALE * 0.2);
#line 148
float4 ang = float4(0.5617993, 1.7217304, 0.5, 1.285398);
float4 grid;
#line 151
[unroll]
for(int j = 0; j < 4; j++)
{
float2 gridcoord = rotate(p, ang[j]);
float2 jitter = tex2Dlod(sFBMNoise, gridcoord / 128, 0).xy - 0.5;
#line 157
float2 sector_uv = frac(gridcoord) + jitter * jitter_w;
float r = length(sector_uv * 2 - 1);
#line 160
grid[j] = draw_circle_aa(r * 0.78, sqrt(cmyk[j]));
}
#line 163
o = cmyk_to_rgb(1 - grid);
}
#line 171
technique MartyMods_Halftone
<
ui_label = "METEOR: Halftone";
ui_tooltip =
"                            MartysMods - Halftone                             \n"
"                   Marty's Extra Effects for ReShade (METEOR)                 \n"
"______________________________________________________________________________\n"
"\n"
"Simulates halftone printing. That's it. Does what it says on the box.         \n"
"\n"
"\n"
"Visit https://martysmods.com for more information.                            \n"
"\n"
"______________________________________________________________________________";
>
{
pass { VertexShader = MainVS;PixelShader  = NoiseGenPS; RenderTarget = FBMNoise; }
pass { VertexShader = MainVS;PixelShader  = MainPS; }
}

