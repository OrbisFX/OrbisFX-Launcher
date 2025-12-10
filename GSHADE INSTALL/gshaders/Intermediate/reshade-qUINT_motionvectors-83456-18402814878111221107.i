// PRE_BLOCK_SIZE_2_TO_7=3
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_motionvectors.fx"
#line 33
uniform int UI_ME_LAYER_MAX <
ui_type = "combo";
ui_items = "Full Resolution\0Half Resolution\0Quarter Resolution\0";
ui_min = 0;
ui_max = 2;
> = 1;
#line 40
uniform float UI_ME_PYRAMID_UPSCALE_FILTER_RADIUS <
ui_type = "drag";
ui_label = "Filter Smoothness";
ui_min = 0.0;
ui_max = 6.0;
> = 4.0;
#line 47
uniform bool SHOWME <
ui_label = "Debug Output";
> =false;
#line 81
texture ColorInputTex : COLOR;
texture DepthInputTex : DEPTH;
sampler ColorInput 	{ Texture = ColorInputTex; };
sampler DepthInput  { Texture = DepthInputTex; };
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 57
namespace ReShade
{
float GetAspectRatio() { return 1920 * (1.0 / 1018); }
float2 GetPixelSize() { return float2((1.0 / 1920), (1.0 / 1018)); }
float2 GetScreenSize() { return float2(1920, 1018); }
#line 67
texture BackBufferTex : COLOR;
texture DepthBufferTex : DEPTH;
#line 70
sampler BackBuffer { Texture = BackBufferTex; };
sampler DepthBuffer { Texture = DepthBufferTex; };
#line 74
float GetLinearizedDepth(float2 texcoord)
{
#line 82
texcoord.x /= 1;
texcoord.y /= 1;
#line 86
 
texcoord.x -= 0 / 2.000000001;
#line 92
texcoord.y += 0 / 2.000000001;
#line 94
float depth = tex2Dlod(DepthBuffer, float4(texcoord, 0, 0)).x * 1;
#line 103
const float N = 1.0;
depth /= 1000.0 - depth * (1000.0 - N);
#line 106
return depth;
}
}
#line 112
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 119
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 124
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 87 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_motionvectors.fx"
#line 91
uniform uint FRAME_COUNT < source = "framecount"; >;
#line 108
texture FeatureCurr          { Width = 1920;   Height = 1018;   Format = RG16F; MipLevels = 8; };
sampler sFeatureCurr         { Texture = FeatureCurr;  };
texture FeaturePrev          { Width = 1920;   Height = 1018;   Format = RG16F; MipLevels = 8; };
sampler sFeaturePrev         { Texture = FeaturePrev;   };
#line 113
texture texMotionVectors          { Width = 1920;   Height = 1018;   Format = RG16F; };
sampler sMotionVectorTex         { Texture = texMotionVectors;  };
#line 116
texture MotionTexCur7               { Width = 1920 >> 7;   Height = 1018 >> 7;   Format = RGBA16F;  };
sampler sMotionTexCur7              { Texture = MotionTexCur7;};
texture MotionTexCur6               { Width = 1920 >> 6;   Height = 1018 >> 6;   Format = RGBA16F;  };
sampler sMotionTexCur6              { Texture = MotionTexCur6;};
texture MotionTexCur5               { Width = 1920 >> 5;   Height = 1018 >> 5;   Format = RGBA16F;  };
sampler sMotionTexCur5              { Texture = MotionTexCur5;};
texture MotionTexCur4               { Width = 1920 >> 4;   Height = 1018 >> 4;   Format = RGBA16F;  };
sampler sMotionTexCur4              { Texture = MotionTexCur4;};
texture MotionTexCur3               { Width = 1920 >> 3;   Height = 1018 >> 3;   Format = RGBA16F;  };
sampler sMotionTexCur3              { Texture = MotionTexCur3;};
texture MotionTexCur2               { Width = 1920 >> 2;   Height = 1018 >> 2;   Format = RGBA16F;  };
sampler sMotionTexCur2              { Texture = MotionTexCur2;};
texture MotionTexCur1               { Width = 1920 >> 1;   Height = 1018 >> 1;   Format = RGBA16F;  };
sampler sMotionTexCur1              { Texture = MotionTexCur1;};
texture MotionTexCur0               { Width = 1920 >> 0;   Height = 1018 >> 0;   Format = RGBA16F;  };
sampler sMotionTexCur0              { Texture = MotionTexCur0;};
#line 135
texture MVJitterTex       < source = "mv_bluenoise.png"; > { Width = 32; Height = 32; Format = RGBA8; };
sampler	sJitterTex      { Texture = MVJitterTex; AddressU = WRAP; AddressV = WRAP; };
#line 138
struct VSOUT
{
float4 vpos : SV_Position;
float2 uv   : TEXCOORD0;
};
#line 144
struct CSIN
{
uint3 groupthreadid     : SV_GroupThreadID;         
uint3 groupid           : SV_GroupID;               
uint3 dispatchthreadid  : SV_DispatchThreadID;      
uint threadid           : SV_GroupIndex;            
};
#line 156
float2 pixel_idx_to_uv(uint2 pos, float2 texture_size)
{
float2 inv_texture_size = rcp(texture_size);
return pos * inv_texture_size + 0.5 * inv_texture_size;
}
#line 162
float4 CalcMotionLayer(VSOUT i, int mip_gcurr, float2 searchStart, sampler sFeatureCurr, sampler sFeaturePrev)
{
float2 texelsize = rcp(float2(1920, 1018) / exp2(mip_gcurr));
float2 localBlock[((3) * (3))];
float2 searchBlock[((3) * (3))];
#line 168
float4 moments_local = 0;
float4 moments_search = 0;
float2 moment_covariate = 0;
#line 172
i.uv -= texelsize * ((3) * 0.5 - 0.5); 
#line 174
[unroll]
for(uint k = 0; k < (3) * (3); k++)
{
float2 tuv = i.uv + float2(k / (3), k % (3)) * texelsize;
float2 t_local = tex2Dlod(sFeatureCurr, float4(tuv, 0.0, 0.0), int2(mip_gcurr, 0)).xy;
float2 t_search = tex2Dlod(sFeaturePrev, float4(tuv + searchStart, 0.0, 0.0), int2(mip_gcurr, 0)).xy;
#line 181
localBlock[k] = t_local;
searchBlock[k] = t_search;
#line 184
moments_local += float4(t_local, t_local * t_local);
moments_search += float4(t_search, t_search * t_search);
moment_covariate += t_local * t_search;
}
#line 189
moments_local /= ((3) * (3));
moments_search /= ((3) * (3));
moment_covariate /= ((3) * (3));
#line 193
float2 cossim = moment_covariate * rsqrt(moments_local.zw * moments_search.zw);
float best_sim = saturate(min(cossim.x, cossim.y));
#line 196
float local_features = abs(moments_local.x * moments_local.x - moments_local.z);
float best_features = abs(moments_search.x * moments_search.x - moments_search.z);
#line 199
float2 bestMotion = 0;
float2 searchCenter = searchStart;
#line 202
float randseed = tex2Dfetch(sJitterTex, uint2(i.vpos.xy) % 32u).x;
randseed = frac(randseed + (FRAME_COUNT % 16) * 5 * 2 * 0.6180339887498);
float2 randdir; sincos(randseed * 6.283, randdir.x, randdir.y); 
float2 scale = texelsize;
#line 207
[loop]
for(int j = 0; j < 2 && best_sim < 0.999999; j++)
{
[loop]
for (int s = 1; s < 5 && best_sim < 0.999999; s++)
{
randdir = mul(randdir, float2x2(-0.7373688, 0.6754903, -0.6754903, -0.7373688));
float2 pixelOffset = randdir * scale;
float2 samplePos = i.uv + searchCenter + pixelOffset;
#line 217
float4 moments_candidate = 0;
moment_covariate = 0;
#line 220
[loop]
for(uint k = 0; k < (3) * (3); k++)
{
float2 t = tex2Dlod(sFeaturePrev, float4(samplePos + float2(k / (3), k % (3)) * texelsize, 0.0, 0.0), int2(mip_gcurr, 0)).xy;
moments_candidate += float4(t, t * t);
moment_covariate += t * localBlock[k];
}
moments_candidate /= ((3) * (3));
moment_covariate /= ((3) * (3));
#line 230
cossim = moment_covariate * rsqrt(moments_local.zw * moments_candidate.zw);
float candidate_similarity = saturate(min(cossim.x, cossim.y));
#line 233
[flatten]
if(candidate_similarity > best_sim)
{
best_sim = candidate_similarity;
bestMotion = pixelOffset;
best_features = abs(moments_candidate.x * moments_candidate.x - moments_candidate.z);
}
}
searchCenter += bestMotion;
bestMotion = 0;
scale *= 0.5;
}
#line 246
return float4(searchCenter, sqrt(best_features), best_sim * best_sim * best_sim * best_sim);  
}
#line 249
float4 atrous_upscale(VSOUT i, int mip_gcurr, sampler sMotionLow, sampler sFeatureCurr)
{
float2 texelsize = rcp(float2(1920, 1018) / exp2(mip_gcurr + 1));
float rand = frac(mip_gcurr * 0.2114 + (FRAME_COUNT % 16) * 0.6180339887498) * 3.1415927*0.5;
float2x2 rotm = float2x2(cos(rand), -sin(rand), sin(rand), cos(rand)) * UI_ME_PYRAMID_UPSCALE_FILTER_RADIUS;
const float3 gauss = float3(1, 0.85, 0.65);
#line 256
float center_z = tex2Dlod(sFeatureCurr, float4(i.uv, 0.0, 0.0), int2(mip_gcurr, 0)).y;
#line 258
float4 gbuffer_sum = 0;
float wsum = 1e-6;
#line 261
for(int x = -1; x <= 1; x++)
for(int y = -1; y <= 1; y++)
{
float2 offs = mul(float2(x, y), rotm) * texelsize;
float2 sample_uv = i.uv + offs;
#line 267
float sample_z = tex2Dlod(sFeatureCurr, float4(sample_uv, 0.0, 0.0), int2(mip_gcurr + 1, 0)).y;
float4 sample_gbuf = tex2Dlod(sMotionLow, float4(sample_uv, 0.0, 0.0), int2(0, 0));
#line 270
float wz = abs(sample_z - center_z) * 4;
float ws = saturate(1 - sample_gbuf.w * 4);
float wf = saturate(1 - sample_gbuf.b * 128.0);
float wm = dot(sample_gbuf.xy, sample_gbuf.xy) * 4;
#line 275
float weight = exp2(-(wz + ws + wm + wf)) * gauss[abs(x)] * gauss[abs(y)];
gbuffer_sum += sample_gbuf * weight;
wsum += weight;
}
#line 280
return gbuffer_sum / wsum;
}
#line 287
VSOUT VS_Main(in uint id : SV_VertexID)
{
VSOUT o;
PostProcessVS(id, o.vpos, o.uv);
return o;
}
#line 294
void PSWriteColorAndDepth(in VSOUT i, out float2 o : SV_Target0)
{
float depth = ReShade::GetLinearizedDepth(i.uv);
float luma = dot(tex2D(ColorInput, i.uv).rgb, float3(0.299, 0.587, 0.114));
o = float2(luma, depth);
}
#line 301
float4 motion_estimation(in VSOUT i, sampler sMotionLow, sampler sFeatureCurr, sampler sFeaturePrev, int mip_gcurr)
{
float4 upscaledLowerLayer = 0;
#line 305
[branch]
if(6 <= (mip_gcurr-1))
return 0;
#line 309
[branch]
if(mip_gcurr < 6)
upscaledLowerLayer = atrous_upscale(i, mip_gcurr, sMotionLow, sFeatureCurr);
#line 313
[branch]
if(mip_gcurr >= UI_ME_LAYER_MAX)
upscaledLowerLayer = CalcMotionLayer(i, mip_gcurr, upscaledLowerLayer.xy, sFeatureCurr, sFeaturePrev);
#line 318
return upscaledLowerLayer;
}
#line 321
void PSMotion6(in VSOUT i, out float4 o : SV_Target0){o = motion_estimation(i, sMotionTexCur7, sFeatureCurr, sFeaturePrev, 6);}
void PSMotion5(in VSOUT i, out float4 o : SV_Target0){o = motion_estimation(i, sMotionTexCur6, sFeatureCurr, sFeaturePrev, 5);}
void PSMotion4(in VSOUT i, out float4 o : SV_Target0){o = motion_estimation(i, sMotionTexCur5, sFeatureCurr, sFeaturePrev, 4);}
void PSMotion3(in VSOUT i, out float4 o : SV_Target0){o = motion_estimation(i, sMotionTexCur4, sFeatureCurr, sFeaturePrev, 3);}
void PSMotion2(in VSOUT i, out float4 o : SV_Target0){o = motion_estimation(i, sMotionTexCur3, sFeatureCurr, sFeaturePrev, 2);}
void PSMotion1(in VSOUT i, out float4 o : SV_Target0){o = motion_estimation(i, sMotionTexCur2, sFeatureCurr, sFeaturePrev, 1);}
void PSMotion0(in VSOUT i, out float4 o : SV_Target0){o = motion_estimation(i, sMotionTexCur1, sFeatureCurr, sFeaturePrev, 0);}
#line 331
float3 HUEtoRGB(in float H)
{
float R = abs(H * 6.f - 3.f) - 1.f;
float G = 2 - abs(H * 6.f - 2.f);
float B = 2 - abs(H * 6.f - 4.f);
return saturate(float3(R,G,B));
}
#line 339
float3 HSLtoRGB(in float3 HSL)
{
float3 RGB = HUEtoRGB(HSL.x);
float C = (1.f - abs(2.f * HSL.z - 1.f)) * HSL.y;
return (RGB - 0.5f) * C + HSL.z;
}
#line 346
float4 motionToLgbtq(float2 motion)
{
float angle = degrees(atan2(motion.y, motion.x));
float dist = length(motion);
float3 rgb = HSLtoRGB(float3((angle / 360.f) + 0.5, saturate(dist * 100.0), 0.5));
return float4(rgb.r, rgb.g, rgb.b, 0);
}
#line 354
void PSOut(in VSOUT i, out float4 o : SV_Target0)
{
if(!SHOWME) discard;
o = motionToLgbtq(tex2D(sMotionTexCur0, i.uv).xy);
#line 360
}
void PSWriteVectors(in VSOUT i, out float2 o : SV_Target0)
{
o = tex2D(sMotionTexCur0, i.uv).xy;
}
#line 372
technique qUINT_MotionVectors
{
#line 375
pass 
{
VertexShader = VS_Main;
PixelShader  = PSWriteColorAndDepth;
RenderTarget = FeatureCurr;
#line 381
}
#line 383
pass {VertexShader = VS_Main;PixelShader = PSMotion6;RenderTarget = MotionTexCur6;}
pass {VertexShader = VS_Main;PixelShader = PSMotion5;RenderTarget = MotionTexCur5;}
pass {VertexShader = VS_Main;PixelShader = PSMotion4;RenderTarget = MotionTexCur4;}
pass {VertexShader = VS_Main;PixelShader = PSMotion3;RenderTarget = MotionTexCur3;}
pass {VertexShader = VS_Main;PixelShader = PSMotion2;RenderTarget = MotionTexCur2;}
pass {VertexShader = VS_Main;PixelShader = PSMotion1;RenderTarget = MotionTexCur1;}
pass {VertexShader = VS_Main;PixelShader = PSMotion0;RenderTarget = MotionTexCur0;}
#line 391
pass
{
VertexShader = VS_Main;
PixelShader  = PSWriteColorAndDepth;
RenderTarget0 = FeaturePrev;
}
pass
{
VertexShader = VS_Main;
PixelShader  = PSWriteVectors;
RenderTarget = texMotionVectors;
}
#line 404
pass
{
VertexShader = VS_Main;
PixelShader  = PSOut;
}
}

