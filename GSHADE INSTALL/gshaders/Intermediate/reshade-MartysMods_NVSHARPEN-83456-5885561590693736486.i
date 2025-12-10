#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_NVSHARPEN.fx"
#line 50
uniform float SHARP_AMT <
ui_type = "drag";
ui_label = "Sharpen Intensity";
ui_min = 0.0;
ui_max = 1.0;
> = 0.5;
#line 57
uniform float DETECT_THRESH_MULT <
ui_type = "drag";
ui_label = "Edge Detection Threshold";
ui_min = 0.0;
ui_max = 1.0;
> = 0.3;
#line 72
texture ColorInputTex : COLOR;
sampler ColorInput 	{ Texture = ColorInputTex;  SRGBTexture = true;};
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
#line 76 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_NVSHARPEN.fx"
#line 77
struct VSOUT
{
float4                  vpos        : SV_Position;
float2                  uv          : TEXCOORD0;
};
#line 92
static const float kDetectRatio = 2 * 1127.f / 1024.f;
#line 94
static const float kMinContrastRatio = 2.0f;
static const float kMaxContrastRatio = 10.0f;
#line 97
static const float kSharpStartY = 0.45f;
static const float kSharpEndY = 0.9f;
#line 100
static const float kRatioNorm = 1.0f / (kMaxContrastRatio - kMinContrastRatio);
static const float kSharpScaleY = 1.0f / (kSharpEndY - kSharpStartY);
#line 103
struct NVSharpenParams
{
float kSharpStrengthMin;
float kSharpStrengthMax;
float kSharpLimitMin;
float kSharpLimitMax;
float kSharpStrengthScale;
float kSharpLimitScale;
};
#line 113
NVSharpenParams setup()
{
float sharpen_slider = saturate(SHARP_AMT) - 0.5;
#line 117
float LimitScale = sharpen_slider > 0 ? 1.25 : 1;
float MaxScale = sharpen_slider > 0 ? 1.25 : 1.75;
float MinScale = sharpen_slider > 0 ? 1.25 : 1;
#line 121
NVSharpenParams params;
#line 123
params.kSharpStrengthMin    = max(0.0f, 0.4f + sharpen_slider * MinScale * 1.2f);
params.kSharpStrengthMax    = 1.6f + sharpen_slider * MaxScale * 1.8f;
params.kSharpLimitMin       = max(0.1f, 0.14f + sharpen_slider * LimitScale * 0.32f);
params.kSharpLimitMax       = 0.5f + sharpen_slider * LimitScale * 0.6f;
params.kSharpStrengthScale  = params.kSharpStrengthMax - params.kSharpStrengthMin;
params.kSharpLimitScale     = params.kSharpLimitMax - params.kSharpLimitMin;
#line 130
return params;
}
#line 133
float CalcLTIFast(const float y[5])
{
const float a_min = min(min(y[0], y[1]), y[2]);
const float a_max = max(max(y[0], y[1]), y[2]);
#line 138
const float b_min = min(min(y[2], y[3]), y[4]);
const float b_max = max(max(y[2], y[3]), y[4]);
#line 141
const float a_cont = a_max - a_min;
const float b_cont = b_max - b_min;
#line 144
const float cont_ratio = max(a_cont, b_cont) / (min(a_cont, b_cont) + (1.0f / 255.0f));
return (1.0f - saturate((cont_ratio - kMinContrastRatio) * kRatioNorm)) * 1.0;
}
#line 149
float EvalUSM(float pxl[5], float sharpnessStrength, float sharpnessLimit)
{
#line 152
float y_usm = -0.6001f * pxl[1] + 1.2002f * pxl[2] - 0.6001f * pxl[3];
#line 154
y_usm *= sharpnessStrength;
#line 156
y_usm = min(sharpnessLimit, max(-sharpnessLimit, y_usm));
#line 158
y_usm *= CalcLTIFast(pxl);
#line 160
return y_usm;
}
#line 164
float4 GetDirUSM(float p[25], NVSharpenParams params)
{
#line 167
const float scaleY = 1.0f - saturate((p[5*2+2] - kSharpStartY) * kSharpScaleY);
#line 169
const float sharpnessStrength = scaleY * params.kSharpStrengthScale + params.kSharpStrengthMin;
#line 171
const float sharpnessLimit = (scaleY * params.kSharpLimitScale + params.kSharpLimitMin) * p[5*2+2];
#line 173
float4 rval;
#line 175
float interp0Deg[5];
{
[unroll]for (int i = 0; i < 5; ++i)
{
interp0Deg[i] = p[i*5+2];
}
}
#line 183
rval.x = EvalUSM(interp0Deg, sharpnessStrength, sharpnessLimit);
#line 186
float interp90Deg[5];
{
[unroll]for (int i = 0; i < 5; ++i)
{
interp90Deg[i] = p[2*5+i];
}
}
#line 194
rval.y = EvalUSM(interp90Deg, sharpnessStrength, sharpnessLimit);
#line 197
float interp45Deg[5];
interp45Deg[0] = p[1*5+1];
interp45Deg[1] = lerp(p[2*5+1], p[1*5+2], 0.5f);
interp45Deg[2] = p[2*5+2];
interp45Deg[3] = lerp(p[3*5+2], p[2*5+3], 0.5f);
interp45Deg[4] = p[3*5+3];
#line 204
rval.z = EvalUSM(interp45Deg, sharpnessStrength, sharpnessLimit);
#line 207
float interp135Deg[5];
interp135Deg[0] = p[3*5+1];
interp135Deg[1] = lerp(p[3*5+2], p[2*5+1], 0.5f);
interp135Deg[2] = p[2*5+2];
interp135Deg[3] = lerp(p[2*5+3], p[1*5+2], 0.5f);
interp135Deg[4] = p[1*5+3];
#line 214
rval.w = EvalUSM(interp135Deg, sharpnessStrength, sharpnessLimit);
return rval;
}
#line 218
float4 GetEdgeMap(float p[25], int i, int j)
{
float g_0 = abs(p[(0 + i)*5+(0 + j)] + p[(0 + i)*5+(1 + j)] + p[(0 + i)*5+(2 + j)] - p[(2 + i)*5+(0 + j)] - p[(2 + i)*5+(1 + j)] - p[(2 + i)*5+(2 + j)]);
float g_45 = abs(p[(1 + i)*5+(0 + j)] + p[(0 + i)*5+(0 + j)] + p[(0 + i)*5+(1 + j)] - p[(2 + i)*5+(1 + j)] - p[(2 + i)*5+(2 + j)] - p[(1 + i)*5+(2 + j)]);
float g_90 = abs(p[(0 + i)*5+(0 + j)] + p[(1 + i)*5+(0 + j)] + p[(2 + i)*5+(0 + j)] - p[(0 + i)*5+(2 + j)] - p[(1 + i)*5+(2 + j)] - p[(2 + i)*5+(2 + j)]);
float g_135 = abs(p[(1 + i)*5+(0 + j)] + p[(2 + i)*5+(0 + j)] + p[(2 + i)*5+(1 + j)] - p[(0 + i)*5+(1 + j)] - p[(0 + i)*5+(2 + j)] - p[(1 + i)*5+(2 + j)]);
#line 225
float g_0_90_max = max(g_0, g_90);
float g_0_90_min = min(g_0, g_90);
float g_45_135_max = max(g_45, g_135);
float g_45_135_min = min(g_45, g_135);
#line 230
float e_0_90 = 0;
float e_45_135 = 0;
#line 233
if (g_0_90_max + g_45_135_max == 0)
{
return float4(0, 0, 0, 0);
}
#line 238
e_0_90 = min(g_0_90_max / (g_0_90_max + g_45_135_max), 1.0f);
e_45_135 = 1.0f - e_0_90;
#line 241
bool c_0_90 = (g_0_90_max > (g_0_90_min * kDetectRatio)) && (g_0_90_max > (64.0f / 1024.0f * saturate(DETECT_THRESH_MULT * DETECT_THRESH_MULT))) && (g_0_90_max > g_45_135_min);
bool c_45_135 = (g_45_135_max > (g_45_135_min * kDetectRatio)) && (g_45_135_max > (64.0f / 1024.0f * saturate(DETECT_THRESH_MULT * DETECT_THRESH_MULT))) && (g_45_135_max > g_0_90_min);
bool c_g_0_90 = g_0_90_max == g_0;
bool c_g_45_135 = g_45_135_max == g_45;
#line 246
float f_e_0_90 = (c_0_90 && c_45_135) ? e_0_90 : 1.0f;
float f_e_45_135 = (c_0_90 && c_45_135) ? e_45_135 : 1.0f;
#line 249
float weight_0 = (c_0_90 && c_g_0_90) ? f_e_0_90 : 0.0f;
float weight_90 = (c_0_90 && !c_g_0_90) ? f_e_0_90 : 0.0f;
float weight_45 = (c_45_135 && c_g_45_135) ? f_e_45_135 : 0.0f;
float weight_135 = (c_45_135 && !c_g_45_135) ? f_e_45_135 : 0.0f;
#line 254
return float4(weight_0, weight_90, weight_45, weight_135);
}
#line 261
VSOUT MainVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv); 
return o;
}
#line 268
void MainPS(in VSOUT i, out float3 o : SV_Target0)
{
NVSharpenParams params = setup();
#line 272
float p[25];
#line 274
[unroll]for(int x = 0; x < 5; x++)
[unroll]for(int y = 0; y < 5; y++)
{
float lum = dot(tex2D(ColorInput, i.uv, int2(x-2, y-2)).rgb, float3(0.2126, 0.7152, 0.0722));
int idx = x *5 + y;
p[idx] = lum;
}
#line 283
float4 dirUSM = GetDirUSM(p, params);
#line 286
float4 w = GetEdgeMap(p, 5 / 2 - 1, 5 / 2 - 1);
#line 289
float usmY = (dirUSM.x * w.x + dirUSM.y * w.y + dirUSM.z * w.z + dirUSM.w * w.w);
#line 291
float4 op = tex2D(ColorInput, i.uv);
#line 293
op.rgb += usmY;
op.rgb = saturate(op.rgb);
o = op.rgb;
}
#line 302
technique MartysMods_NvidiaSharpen
<
ui_label = "METEOR: NVSharpen";
ui_tooltip =
"                             MartysMods - NVSharpen                           \n"
"                   Marty's Extra Effects for ReShade (METEOR)                 \n"
"______________________________________________________________________________\n"
"\n"
#line 311
"This is a port of Nvidia's NVSharpen filter from the NIS Library, made compatible\n"
"with DirectX 9 as well.                                                       \n"
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
SRGBWriteEnable = true;
}
}

