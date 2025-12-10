#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_CHROMATICABERRATION.fx"
#line 62
uniform int CHROMA_MODE <
ui_type = "combo";
ui_label = "Lens Type";
ui_items = "Chromatic (single lens)\0Achromatic (doublet)\0Apochromatic (triplet)\0";
> = 0;
#line 68
uniform float CA_CURVE <
ui_type = "drag";
ui_label = "Curve";
ui_min = -1.0;
ui_max = 1.0;
> = 0.0;
#line 75
uniform float CA_AMT <
ui_type = "drag";
ui_label = "Amount";
ui_min = -1.0;
ui_max = 1.0;
> = 0.15;
#line 82
uniform int CA_QUALITY_PRES <
ui_type = "combo";
ui_label = "Quality Preset";
ui_items = "Low\0Medium\0High\0Very High\0Ultra\0";
> = 1;
#line 88
uniform bool CA_HDR <
ui_label = "Use HDR";
> = true;
#line 92
uniform bool CA_POSTFILTER <
ui_label = "Use Post Filtering";
> = false;
#line 104
texture ColorInputTex : COLOR;
sampler ColorInput 	{ Texture = ColorInputTex; };
#line 107
texture SpectrumLUTNew       < source = "ca_lut_new.png"; > { Width = 256; Height = 18; Format = RGBA8; };
sampler	sSpectrumLUTNew      { Texture = SpectrumLUTNew; };
#line 110
texture HDRInput <pooled = true;> { Width = 1920;         Height = 1018;     Format = RGBA16F; };
sampler	sHDRInput      { Texture = HDRInput; };
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
#line 114 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_CHROMATICABERRATION.fx"
#line 115
struct VSOUT
{
float4 vpos : SV_Position;
float2 uv : TEXCOORD0;
};
#line 125
float wavelength_to_norm(float lambda)
{
return saturate((lambda - 400.0) / 300.0);
}
#line 130
float3 sdr_to_hdr(float3 c)
{
if(!CA_HDR) return c;
const float W = 4;
c = c * sqrt(1e-6 + dot(c, c)) / 1.733;
float a = 1 + exp2(-W);
c = c / (a - c);
return c;
}
#line 140
float3 hdr_to_sdr(float3 c)
{
if(!CA_HDR) return c;
const float W = 4;
float a = 1 + exp2(-W);
c = a * c * rcp(1 + c);
c *= 1.733;
c = c * rsqrt(sqrt(dot(c, c))+ 1e-5);
return c;
}
#line 151
float3 spectrum_lut_eval(float x, float N)
{
#line 174
float y = saturate((log2(N) - 4)/log2(256.0));
#line 176
y = lerp(0.5, 5.5, y);
y += CHROMA_MODE * 6;
y /= 18.0;
#line 180
float3 spectrum = tex2Dlod(sSpectrumLUTNew, float2(x, y), 0).rgb;
spectrum = CHROMA_MODE != 0 ? (spectrum * spectrum) * (spectrum * spectrum) : spectrum;
return spectrum;
}
#line 185
void get_params(in VSOUT i, out float2 dir, out float divergence)
{
float2 uv = i.uv * 2.0 - 1.0;
uv.x *= BUFFER_ASPECT_RATIO.y;
float r = sqrt(dot(uv, uv) / dot(BUFFER_ASPECT_RATIO, BUFFER_ASPECT_RATIO)); 
#line 191
float curve = exp2(-CA_CURVE * 20.0);
#line 195
float cosphi = rsqrt(1 + r * r * curve);
float scale = rsqrt(1 + curve);
#line 198
float ca_divergence = saturate((1 - cosphi)/(1 - scale)); 
ca_divergence *= abs(CA_AMT) * 128;
#line 201
divergence = ca_divergence;
dir = normalize(uv) * sign(CA_AMT);
}
#line 209
VSOUT MainVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv); 
return o;
}
#line 216
void HDRPS(in VSOUT i, out float3 o : SV_Target0)
{
o = tex2D(ColorInput, i.uv).rgb;
o = sdr_to_hdr(o);
}
#line 222
void MainPS(in VSOUT i, out float4 o : SV_Target0)
{
float divergence; float2 dir;
get_params(i, dir, divergence);
#line 227
const float3 ca_offsets = float3(0.55, 0.05, 0.53); 
float2 ab_madd = float2(divergence, -ca_offsets[CHROMA_MODE] * divergence);
#line 230
float3 sum = 0;
float3 spectral_sum = 0;
#line 233
float qscale = CA_QUALITY_PRES / 4.0;
qscale *= qscale;
#line 236
uint _samples = min(64, 8 + ceil(divergence * qscale));
#line 238
for(int j = 0; j < _samples; j++)
{
float x = float(j + 0.5)/ _samples;
float3 spectral_rgb = spectrum_lut_eval(x, _samples);
float aberration = x * ab_madd.x + ab_madd.y;
#line 244
float3 tap = tex2Dlod(sHDRInput, i.uv + dir * aberration * BUFFER_PIXEL_SIZE.x, 0).rgb;
sum += tap * spectral_rgb;
spectral_sum += spectral_rgb;
}
#line 249
o.rgb = sum / spectral_sum;
o.rgb =  hdr_to_sdr(o.rgb);
#line 252
float sample_spacing_pixels = length(BUFFER_PIXEL_SIZE * divergence) / length(BUFFER_PIXEL_SIZE);
o.w = sample_spacing_pixels / _samples / 16.0; 
#line 268
}
#line 270
void PostPS(in VSOUT i, out float4 o : SV_Target0)
{
float4 center = tex2D(ColorInput, i.uv);
float gwidth = center.w * 16.0 + 0.01;
int spacing = round(gwidth);
#line 276
o = float4(sdr_to_hdr(center.rgb), 1);
#line 278
if(spacing * CA_POSTFILTER == 0)
discard;
#line 281
float divergence; float2 dir;
get_params(i, dir, divergence);
[loop]for(int x = 1; x <= spacing; x++)
{
float w = x / gwidth;
w = exp(-2 * w * w);
float3 t;
t = tex2Dlod(ColorInput, i.uv + dir * BUFFER_PIXEL_SIZE * x, 0).rgb;
o += float4(sdr_to_hdr(t), 1) * w;
t = tex2Dlod(ColorInput, i.uv - dir * BUFFER_PIXEL_SIZE * x, 0).rgb;
o += float4(sdr_to_hdr(t), 1) * w;
}
o /= o.w;
o.rgb = hdr_to_sdr(o.rgb);
}
#line 301
technique MartysMods_ChromaticAberration
<
ui_label = "METEOR: Chromatic Aberration";
ui_tooltip =
"                        MartysMods - Chromatic Aberration                     \n"
"                   Marty's Extra Effects for ReShade (METEOR)                 \n"
"______________________________________________________________________________\n"
"\n"
"A hilariously overengineered chromatic aberration effect.                     \n"
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
PixelShader  = HDRPS;
RenderTarget = HDRInput;
}
pass
{
VertexShader = MainVS;
PixelShader  = MainPS;
}
pass
{
VertexShader = MainVS;
PixelShader  = PostPS;
}
}

