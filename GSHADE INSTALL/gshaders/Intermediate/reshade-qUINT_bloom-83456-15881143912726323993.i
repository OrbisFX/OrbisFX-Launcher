// SAMPLE_HIGH_QUALITY=1
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_bloom.fx"
#line 30
uniform float BLOOM_INTENSITY <
ui_type = "slider";
ui_min = 0.00; ui_max = 10.00;
ui_label = "Bloom Intensity";
ui_tooltip = "Scales bloom brightness.";
> = 1.2;
#line 37
uniform float BLOOM_CURVE <
ui_type = "slider";
ui_min = 0.00; ui_max = 10.00;
ui_label = "Bloom Curve";
ui_tooltip = "Higher values limit bloom to bright light sources only.";
> = 1.5;
#line 44
uniform float BLOOM_SAT <
ui_type = "slider";
ui_min = 0.00; ui_max = 5.00;
ui_label = "Bloom Saturation";
ui_tooltip = "Adjusts the color strength of the bloom effect";
> = 2.0;
#line 58
uniform float BLOOM_LAYER_MULT_1 <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "Bloom Layer 1 Intensity";
ui_tooltip = "Intensity of this bloom layer. 1 is sharpest layer, 7 the most blurry.";
> = 0.05;
uniform float BLOOM_LAYER_MULT_2 <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "Bloom Layer 2 Intensity";
ui_tooltip = "Intensity of this bloom layer. 1 is sharpest layer, 7 the most blurry.";
> = 0.05;
uniform float BLOOM_LAYER_MULT_3 <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "Bloom Layer 3 Intensity";
ui_tooltip = "Intensity of this bloom layer. 1 is sharpest layer, 7 the most blurry.";
> = 0.05;
uniform float BLOOM_LAYER_MULT_4 <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "Bloom Layer 4 Intensity";
ui_tooltip = "Intensity of this bloom layer. 1 is sharpest layer, 7 the most blurry.";
> = 0.1;
uniform float BLOOM_LAYER_MULT_5 <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "Bloom Layer 5 Intensity";
ui_tooltip = "Intensity of this bloom layer. 1 is sharpest layer, 7 the most blurry.";
> = 0.5;
uniform float BLOOM_LAYER_MULT_6 <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "Bloom Layer 6 Intensity";
ui_tooltip = "Intensity of this bloom layer. 1 is sharpest layer, 7 the most blurry.";
> = 0.01;
uniform float BLOOM_LAYER_MULT_7 <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "Bloom Layer 7 Intensity";
ui_tooltip = "Intensity of this bloom layer. 1 is sharpest layer, 7 the most blurry.";
> = 0.01;
uniform float BLOOM_ADAPT_STRENGTH <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_label = "Bloom Scene Adaptation Sensitivity";
ui_tooltip = "Amount of adaptation applied, 0 means same exposure for all scenes, 1 means complete autoexposure.";
> = 0.5;
uniform float BLOOM_ADAPT_EXPOSURE <
ui_type = "slider";
ui_min = -5.00; ui_max = 5.00;
ui_label = "Bloom Scene Exposure Bias";
ui_tooltip = "qUINT bloom employs eye adaptation to tune bloom intensity for scene differences.\nThis parameter adjusts the final scene exposure.";
> = 0.0;
uniform float BLOOM_ADAPT_SPEED <
ui_type = "slider";
ui_min = 0.50; ui_max = 10.00;
ui_label = "Bloom Scene Adaptation Speed";
ui_tooltip = "Eye adaptation data is created by exponential moving average with last frame data.\nThis parameter controls the adjustment speed.\nHigher parameters let the image adjust more quickly.";
> = 2.0;
uniform bool BLOOM_ADAPT_MODE <
ui_label = "Adapt bloom only";
> = false;
uniform float BLOOM_TONEMAP_COMPRESSION <
ui_type = "slider";
ui_min = 0.00; ui_max = 10.00;
ui_label = "Bloom Tonemap Compression";
ui_tooltip = "Lower values compress a larger color range.";
> = 4.0;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_common.fxh"
#line 111
namespace qUINT
{
uniform float FRAME_TIME < source = "frametime"; >;
uniform int FRAME_COUNT < source = "framecount"; >;
#line 124
static const float2 ASPECT_RATIO 	= float2(1.0, 1280 * (1.0 / 720));
static const float2 PIXEL_SIZE 		= float2((1.0 / 1280), (1.0 / 720));
static const float2 SCREEN_SIZE 	= float2(1280, 720);
#line 130
texture BackBufferTex : COLOR;
texture DepthBufferTex : DEPTH;
#line 133
sampler sBackBufferTex 	{ Texture = BackBufferTex; 	};
sampler sDepthBufferTex { Texture = DepthBufferTex; };
#line 136
float2 depthtex_uv(float2 uv)
{
#line 141
uv.x /= 1;
uv.y /= 1;
#line 145
 
uv.x -= 0 / 2.000000001;
#line 151
uv.y += 0 / 2.000000001;
#line 153
return uv;
}
#line 156
float get_depth(float2 uv)
{
float depth = tex2Dlod(sDepthBufferTex, float4(depthtex_uv(uv), 0, 0)).x;
return depth;
}
#line 162
float linearize_depth(float depth)
{
depth *= 1;
#line 176
const float N = 1.0;
depth /= 1000.0 - depth * (1000.0 - N);
#line 179
return saturate(depth);
}
#line 183
float linear_depth(float2 uv)
{
float depth = get_depth(uv);
depth = linearize_depth(depth);
return depth;
}
}
#line 192
void PostProcessVS(in uint id : SV_VertexID, out float4 vpos : SV_Position, out float2 uv : TEXCOORD)
{
uv.x = (id == 2) ? 2.0 : 0.0;
uv.y = (id == 1) ? 2.0 : 0.0;
vpos = float4(uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 134 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_bloom.fx"
#line 138
static const int BloomTex7_LowestMip = (((720/128 >> 1) != 0) + ((720/128 >> 2) != 0) + ((720/128 >> 3) != 0) + ((720/128 >> 4) != 0) + ((720/128 >> 5) != 0) + ((720/128 >> 6) != 0) + ((720/128 >> 7) != 0) + ((720/128 >> 8) != 0) + ((720/128 >> 9) != 0) + ((720/128 >> 10) != 0) + ((720/128 >> 11) != 0) + ((720/128 >> 12) != 0) + ((720/128 >> 13) != 0) + ((720/128 >> 14) != 0) + ((720/128 >> 15) != 0) + ((720/128 >> 16) != 0));
#line 140
texture2D MXBLOOM_BloomTexSource 	{ Width = 1280/2; 	Height = 720/2;    Format = RGBA16F;};
texture2D MXBLOOM_BloomTex1 		{ Width = 1280/2; 	Height = 720/2;    Format = RGBA16F;};
texture2D MXBLOOM_BloomTex2			{ Width = 1280/4;  	Height = 720/4;    Format = RGBA16F;};
texture2D MXBLOOM_BloomTex3 		{ Width = 1280/8;  	Height = 720/8;    Format = RGBA16F;};
texture2D MXBLOOM_BloomTex4 		{ Width = 1280/16;  Height = 720/16;   Format = RGBA16F;};
texture2D MXBLOOM_BloomTex5 		{ Width = 1280/32;  Height = 720/32;   Format = RGBA16F;};
texture2D MXBLOOM_BloomTex6 		{ Width = 1280/64;  Height = 720/64;   Format = RGBA16F;};
texture2D MXBLOOM_BloomTex7 		{ Width = 1280/128; Height = 720/128;  Format = RGBA16F; MipLevels = BloomTex7_LowestMip;};
texture2D MXBLOOM_BloomTexAdapt		{ Format = R16F; };
#line 150
sampler2D sMXBLOOM_BloomTexSource	{ Texture = MXBLOOM_BloomTexSource;	};
sampler2D sMXBLOOM_BloomTex1		{ Texture = MXBLOOM_BloomTex1;		};
sampler2D sMXBLOOM_BloomTex2		{ Texture = MXBLOOM_BloomTex2;		};
sampler2D sMXBLOOM_BloomTex3		{ Texture = MXBLOOM_BloomTex3;		};
sampler2D sMXBLOOM_BloomTex4		{ Texture = MXBLOOM_BloomTex4;		};
sampler2D sMXBLOOM_BloomTex5		{ Texture = MXBLOOM_BloomTex5;		};
sampler2D sMXBLOOM_BloomTex6		{ Texture = MXBLOOM_BloomTex6;		};
sampler2D sMXBLOOM_BloomTex7		{ Texture = MXBLOOM_BloomTex7;		};
sampler2D sMXBLOOM_BloomTexAdapt	{ Texture = MXBLOOM_BloomTexAdapt;	};
#line 164
float4 downsample(sampler2D tex, float2 tex_size, float2 uv)
{
float4 offset_uv = 0;
#line 168
float2 kernel_small_offsets = float2(2.0,2.0) / tex_size;
float2 kernel_large_offsets = float2(4.0,4.0) / tex_size;
#line 171
float4 kernel_center = tex2D(tex, uv);
#line 173
float4 kernel_small = 0;
#line 175
offset_uv.xy = uv + kernel_small_offsets;
kernel_small += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x - kernel_small_offsets.x;
kernel_small += tex2Dlod(tex, offset_uv); 
offset_uv.y = uv.y - kernel_small_offsets.y;
kernel_small += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x + kernel_small_offsets.x;
kernel_small += tex2Dlod(tex, offset_uv); 
#line 188
float4 kernel_large_1 = 0;
#line 190
offset_uv.xy = uv + kernel_large_offsets;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x - kernel_large_offsets.x;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
offset_uv.y = uv.y - kernel_large_offsets.y;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x + kernel_large_offsets.x;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
#line 199
float4 kernel_large_2 = 0;
#line 201
offset_uv.xy = uv;
offset_uv.x += kernel_large_offsets.x;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
offset_uv.x -= kernel_large_offsets.x * 2.0;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x;
offset_uv.y += kernel_large_offsets.y;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
offset_uv.y -= kernel_large_offsets.y * 2.0;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
#line 212
return kernel_center * 0.5 / 4.0
+ kernel_small  * 0.5 / 4.0
+ kernel_large_1 * 0.125 / 4.0
+ kernel_large_2 * 0.25 / 4.0;
#line 217
}
#line 219
float3 Upsample(sampler2D tex, float2 texel_size, float2 uv)
{
float4 offset_uv = 0;
#line 223
float4 kernel_small_offsets;
kernel_small_offsets.xy = 1.5 * texel_size;
kernel_small_offsets.zw = kernel_small_offsets.xy * 2;
#line 227
float3 kernel_center = tex2D(tex, uv).rgb;
#line 229
float3 kernel_small_1 = 0;
#line 231
offset_uv.xy = uv.xy - kernel_small_offsets.xy;
kernel_small_1 += tex2Dlod(tex, offset_uv).rgb; 
offset_uv.x += kernel_small_offsets.z;
kernel_small_1 += tex2Dlod(tex, offset_uv).rgb; 
offset_uv.y += kernel_small_offsets.w;
kernel_small_1 += tex2Dlod(tex, offset_uv).rgb; 
offset_uv.x -= kernel_small_offsets.z;
kernel_small_1 += tex2Dlod(tex, offset_uv).rgb; 
#line 244
float3 kernel_small_2 = 0;
#line 246
offset_uv.xy = uv.xy + float2(kernel_small_offsets.x, 0);
kernel_small_2 += tex2Dlod(tex, offset_uv).rgb; 
offset_uv.x -= kernel_small_offsets.z;
kernel_small_2 += tex2Dlod(tex, offset_uv).rgb; 
offset_uv.xy = uv.xy + float2(0, kernel_small_offsets.y);
kernel_small_2 += tex2Dlod(tex, offset_uv).rgb; 
offset_uv.y -= kernel_small_offsets.w;
kernel_small_2 += tex2Dlod(tex, offset_uv).rgb; 
#line 255
return kernel_center * 4.0 / 16.0
+ kernel_small_1 * 1.0 / 16.0
+ kernel_small_2 * 2.0 / 16.0;
#line 259
}
#line 265
void PS_BloomPrepass(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 color : SV_Target0)
{
color = downsample(qUINT::sBackBufferTex, qUINT::SCREEN_SIZE, uv);
color.w = saturate(dot(color.rgb, 0.333));
#line 270
color.rgb = lerp(color.w, color.rgb, BLOOM_SAT);
color.rgb *= (pow(color.w, BLOOM_CURVE) * BLOOM_INTENSITY * BLOOM_INTENSITY * BLOOM_INTENSITY) / (color.w + 1e-3);
}
#line 274
void PS_Downsample1(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = downsample(sMXBLOOM_BloomTexSource, ldexp(qUINT::SCREEN_SIZE, -1.0), uv);
}
void PS_Downsample2(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = downsample(sMXBLOOM_BloomTex1, 		ldexp(qUINT::SCREEN_SIZE, -2.0), uv);
}
void PS_Downsample3(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = downsample(sMXBLOOM_BloomTex2, 		ldexp(qUINT::SCREEN_SIZE, -3.0), uv);
}
void PS_Downsample4(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = downsample(sMXBLOOM_BloomTex3, 		ldexp(qUINT::SCREEN_SIZE, -4.0), uv);
}
void PS_Downsample5(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = downsample(sMXBLOOM_BloomTex4, 		ldexp(qUINT::SCREEN_SIZE, -5.0), uv);
}
void PS_Downsample6(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = downsample(sMXBLOOM_BloomTex5, 		ldexp(qUINT::SCREEN_SIZE, -6.0), uv);
}
void PS_Downsample7(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = downsample(sMXBLOOM_BloomTex6, 		ldexp(qUINT::SCREEN_SIZE, -7.0), uv);
bloom.w = lerp(tex2D(sMXBLOOM_BloomTexAdapt, 0).x ,
bloom.w ,
saturate(qUINT::FRAME_TIME * 1e-3 * BLOOM_ADAPT_SPEED));
}
#line 306
void PS_AdaptStoreLast(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float adapt : SV_Target0)
{	adapt = tex2Dlod(sMXBLOOM_BloomTex7, float4(uv.xy,0,BloomTex7_LowestMip)).w;}
#line 309
void PS_Upsample1(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = float4(Upsample(sMXBLOOM_BloomTex7, ldexp(qUINT::PIXEL_SIZE, 7.0), uv) * BLOOM_LAYER_MULT_7, BLOOM_LAYER_MULT_6);}
void PS_Upsample2(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = float4(Upsample(sMXBLOOM_BloomTex6, ldexp(qUINT::PIXEL_SIZE, 6.0), uv), BLOOM_LAYER_MULT_5);
}
void PS_Upsample3(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = float4(Upsample(sMXBLOOM_BloomTex5, ldexp(qUINT::PIXEL_SIZE, 5.0), uv), BLOOM_LAYER_MULT_4);
}
void PS_Upsample4(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = float4(Upsample(sMXBLOOM_BloomTex4, ldexp(qUINT::PIXEL_SIZE, 4.0), uv), BLOOM_LAYER_MULT_3);
}
void PS_Upsample5(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = float4(Upsample(sMXBLOOM_BloomTex3, ldexp(qUINT::PIXEL_SIZE, 3.0), uv), BLOOM_LAYER_MULT_2);
}
void PS_Upsample6(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 bloom : SV_Target0)
{
bloom = float4(Upsample(sMXBLOOM_BloomTex2, ldexp(qUINT::PIXEL_SIZE, 2.0), uv), BLOOM_LAYER_MULT_1);
}
#line 333
void PS_Combine(in float4 pos : SV_Position, in float2 uv : TEXCOORD, out float4 color : SV_Target0)
{
float3 bloom = Upsample(sMXBLOOM_BloomTex1, ldexp(qUINT::PIXEL_SIZE, 1.0), uv);
bloom /= dot(float4(BLOOM_LAYER_MULT_1, BLOOM_LAYER_MULT_2, BLOOM_LAYER_MULT_3, BLOOM_LAYER_MULT_4), 1) + dot(float3(BLOOM_LAYER_MULT_5, BLOOM_LAYER_MULT_6, BLOOM_LAYER_MULT_7), 1);
color = tex2D(qUINT::sBackBufferTex, uv);
#line 339
float adapt = tex2D(sMXBLOOM_BloomTexAdapt, 0).x + 1e-3; 
adapt *= 8;
#line 343
if(BLOOM_ADAPT_MODE)
{
bloom *= lerp(1, rcp(adapt), BLOOM_ADAPT_STRENGTH);
bloom *= exp2(BLOOM_ADAPT_EXPOSURE);
color.rgb += bloom;
}
else
{
color.rgb += bloom;
color.rgb *= lerp(1, rcp(adapt), BLOOM_ADAPT_STRENGTH);
color.rgb *= exp2(BLOOM_ADAPT_EXPOSURE);
}
#line 356
color.rgb = pow(max(0,color.rgb), BLOOM_TONEMAP_COMPRESSION);
color.rgb = color.rgb / (1.0 + color.rgb);
color.rgb = pow(color.rgb, 1.0 / BLOOM_TONEMAP_COMPRESSION);
}
#line 365
technique Bloom
< ui_tooltip = "                >> qUINT::Bloom <<\n\n"
"Bloom is a shader that produces a glow around bright\n"
"light sources and other emitters on screen.\n"
"\nBloom is written by Marty McFly / Pascal Gilcher"; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_BloomPrepass;
RenderTarget0 = MXBLOOM_BloomTexSource;
}
#line 380
pass { VertexShader = PostProcessVS; PixelShader = PS_Downsample1; RenderTarget0 = MXBLOOM_BloomTex1; }
pass { VertexShader = PostProcessVS; PixelShader = PS_Downsample2; RenderTarget0 = MXBLOOM_BloomTex2; }
pass { VertexShader = PostProcessVS; PixelShader = PS_Downsample3; RenderTarget0 = MXBLOOM_BloomTex3; }
pass { VertexShader = PostProcessVS; PixelShader = PS_Downsample4; RenderTarget0 = MXBLOOM_BloomTex4; }
pass { VertexShader = PostProcessVS; PixelShader = PS_Downsample5; RenderTarget0 = MXBLOOM_BloomTex5; }
pass { VertexShader = PostProcessVS; PixelShader = PS_Downsample6; RenderTarget0 = MXBLOOM_BloomTex6; }
pass { VertexShader = PostProcessVS; PixelShader = PS_Downsample7; RenderTarget0 = MXBLOOM_BloomTex7; }
#line 388
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_AdaptStoreLast;
RenderTarget0 = MXBLOOM_BloomTexAdapt;
}
#line 397
pass {VertexShader = PostProcessVS;PixelShader = PS_Upsample1;RenderTarget0 = MXBLOOM_BloomTex6;ClearRenderTargets = false;BlendEnable = true;BlendOp = ADD;SrcBlend = ONE;DestBlend = SRCALPHA;}
pass {VertexShader = PostProcessVS;PixelShader = PS_Upsample2;RenderTarget0 = MXBLOOM_BloomTex5;ClearRenderTargets = false;BlendEnable = true;BlendOp = ADD;SrcBlend = ONE;DestBlend = SRCALPHA;}
pass {VertexShader = PostProcessVS;PixelShader = PS_Upsample3;RenderTarget0 = MXBLOOM_BloomTex4;ClearRenderTargets = false;BlendEnable = true;BlendOp = ADD;SrcBlend = ONE;DestBlend = SRCALPHA;}
pass {VertexShader = PostProcessVS;PixelShader = PS_Upsample4;RenderTarget0 = MXBLOOM_BloomTex3;ClearRenderTargets = false;BlendEnable = true;BlendOp = ADD;SrcBlend = ONE;DestBlend = SRCALPHA;}
pass {VertexShader = PostProcessVS;PixelShader = PS_Upsample5;RenderTarget0 = MXBLOOM_BloomTex2;ClearRenderTargets = false;BlendEnable = true;BlendOp = ADD;SrcBlend = ONE;DestBlend = SRCALPHA;}
pass {VertexShader = PostProcessVS;PixelShader = PS_Upsample6;RenderTarget0 = MXBLOOM_BloomTex1;ClearRenderTargets = false;BlendEnable = true;BlendOp = ADD;SrcBlend = ONE;DestBlend = SRCALPHA;}
#line 404
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_Combine;
}
}

