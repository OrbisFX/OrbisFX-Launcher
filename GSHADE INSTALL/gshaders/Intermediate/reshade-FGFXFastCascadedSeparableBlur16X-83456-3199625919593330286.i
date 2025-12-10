// FCSB16X_CASCADE_3_ON=0
// FCSB16X_CASCADE_2_ON=1
// FCSB16X_CASCADE_1_ON=1
// FCSB16X_ANTI_ALIASED_DOWN_SAMPLING_ON=1
// FCSB16X_BLUR_ON=1
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FGFXFastCascadedSeparableBlur16X.fx"
#line 76
uniform int ___ABOUT <
ui_type = "radio";
ui_label = " ";
ui_category = "About";
ui_category_closed = true;
ui_text =
"-=[ FGFX::FCSB[16X] - Fast Cascaded Separable Blur [16X] ]=-\n"
"\n"
#line 85
"FCSB is a blur technique that combines cascaded H / V blur "
"passes and alias-free down-sampling in order to produce "
"large, smooth and alias-free blur at a fraction of the cost of "
"traditional separable Gaussian blur.\n"
"\n"
#line 91
"For reference, the technique performs ~35 times faster than "
"traditional separable Gaussian blur on a 121 texels radius and "
"an astonishing ~122 times faster on a 484 texels radius.\n"
"\n"
#line 96
"The complexity of standard separable Gaussian blur is "
"O(n), while the complexity of FCSB is O(log(n)), making it "
"ideal for cases where large smooth blur is required.\n"
"\n"
#line 101
"In other words, as the radius increases exponentially, the "
"cost of FCSB increases linearly.\n"
"\n"
#line 105
"The FCSB16X effect is provided not as an actual usable in-game "
"effect, but rather as a technique demonstration that can be "
"used as a performance booster alternative to the classic "
"separable Gaussian blur in other effects that make use of "
"blur to achieve their goals.\n"
"\n"
#line 112
"The 16X refers to the fact that prior to cascading, the "
"back-buffer is down-sampled 16 times its original size, "
"yielding a performance boost of 16X compared to cascading on "
"the full-sized back-buffer.\n"
"\n"
#line 118
"Even used on the full back-buffer, FCSB is much faster than "
"standard separable Gaussian blur due to the exhibited "
"O(log(n)) complexity.";
>;
#line 127
uniform float BlurRadius <
ui_type = "slider";
ui_min = 0.00;
ui_max = 1.00;
ui_category = "Parameters";
ui_label = "Blue Radius";
ui_tooltip = "Blur radius in unit space.";
> = 0.25;
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
#line 139 "C:\Program Files\GShade\gshade-shaders\Shaders\FGFXFastCascadedSeparableBlur16X.fx"
#line 150
texture HalfBlurTex {
Width = 1920 >> 1;
Height = 1018 >> 1;
Format = RGBA16F;
};
#line 156
sampler HalfBlurSampler {
Texture = HalfBlurTex;
};
#line 160
texture QuadBlurTex {
Width = 1920 >> 2;
Height = 1018 >> 2;
Format = RGBA16F;
};
#line 166
sampler QuadBlurSampler {
Texture = QuadBlurTex;
};
#line 170
texture OctoBlurTex {
Width = 1920 >> 3;
Height = 1018 >> 3;
Format = RGBA16F;
};
#line 176
sampler OctoBlurSampler {
Texture = OctoBlurTex;
};
#line 180
texture HexaBlurTex {
Width = 1920 >> (4);
Height = 1018 >> (4);
Format = RGBA16F;
};
#line 186
sampler HexaBlurSampler {
Texture = HexaBlurTex;
};
#line 194
texture HBlurTex {
Width = 1920 >> (4);
Height = 1018 >> (4);
Format = RGBA16F;
};
#line 200
sampler HBlurSampler {
Texture = HBlurTex;
};
#line 204
texture VBlurTex {
Width = 1920 >> (4);
Height = 1018 >> (4);
Format = RGBA16F;
};
#line 210
sampler VBlurSampler {
Texture = VBlurTex;
};
#line 229
static const int ___BUFFER_SIZE_DIVIDER___ = 1 << (4);
#line 260
static const float ___STEP_MULTIPLIER___ = 1.5;
static const float ___BUFFER_SIZE_DIVIDER_COMPENSATION_OFFSET___ = ___BUFFER_SIZE_DIVIDER___ * ___STEP_MULTIPLIER___;
static const float2 ___SCALED_BUFFER_SIZE_DIVIDER_DIVIDER_COMPENSATION_OFFSET___ = ___BUFFER_SIZE_DIVIDER_COMPENSATION_OFFSET___ * float2((1.0 / 1920), (1.0 / 1018));
#line 272
float3 CopyBBPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 274
return tex2D(ReShade::BackBuffer, texcoord.xy).rgb;
}
#line 277
float3 CopyHalfPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 279
return tex2D(HalfBlurSampler, texcoord.xy).rgb;
}
#line 282
float3 CopyQuadPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 284
return tex2D(QuadBlurSampler, texcoord.xy).rgb;
}
#line 287
float3 CopyOctoPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 289
return tex2D(OctoBlurSampler, texcoord.xy).rgb;
}
#line 292
float3 CopyHexaPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 294
return tex2D(HexaBlurSampler, texcoord.xy).rgb;
}
#line 370
float3 HBlur(in float2 texcoord : TEXCOORD, float blurSampleOffset, sampler srcSampler) {
float offset = ___SCALED_BUFFER_SIZE_DIVIDER_DIVIDER_COMPENSATION_OFFSET___.x * blurSampleOffset * BlurRadius;
#line 373
float3 color = tex2D(srcSampler, texcoord).rgb; 
color += tex2D(srcSampler, float2(texcoord.x - offset, texcoord.y)).rgb; 
color += tex2D(srcSampler, float2(texcoord.x + offset, texcoord.y)).rgb; 
color *= (0.333333333);
#line 378
return color;
}
#line 381
float3 VBlur(in float2 texcoord : TEXCOORD, float blurSampleOffset, sampler srcSampler) {
float offset = ___SCALED_BUFFER_SIZE_DIVIDER_DIVIDER_COMPENSATION_OFFSET___.y * blurSampleOffset * BlurRadius;
#line 384
float3 color = tex2D(srcSampler, texcoord).rgb; 
color += tex2D(srcSampler, float2(texcoord.x, texcoord.y - offset)).rgb; 
color += tex2D(srcSampler, float2(texcoord.x, texcoord.y + offset)).rgb; 
color *= (0.333333333);
#line 389
return color;
}
#line 396
float3 HBlurC0BBPS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 398
return HBlur(texcoord, ( 1.0), ReShade::BackBuffer);
}
#line 401
float3 HBlurC0PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 403
return HBlur(texcoord, ( 1.0), VBlurSampler);
}
#line 406
float3 VBlurC0PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 408
return VBlur(texcoord, ( 1.0), HBlurSampler);
}
#line 415
float3 HBlurC1PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 417
return HBlur(texcoord, ( 3.0), VBlurSampler);
}
#line 420
float3 VBlurC1PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 422
return VBlur(texcoord, ( 3.0), HBlurSampler);
}
#line 429
float3 HBlurC2PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 431
return HBlur(texcoord, ( 9.0), VBlurSampler);
}
#line 434
float3 VBlurC2PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 436
return VBlur(texcoord, ( 9.0), HBlurSampler);
}
#line 443
float3 HBlurC3PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 445
return HBlur(texcoord, ( 27.0), VBlurSampler);
}
#line 448
float3 VBlurC3PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 450
return VBlur(texcoord, ( 27.0), HBlurSampler);
}
#line 457
float3 HBlurC4PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 459
return HBlur(texcoord, ( 81.0), VBlurSampler);
}
#line 462
float3 VBlurC4PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 464
return VBlur(texcoord, ( 81.0), HBlurSampler);
}
#line 471
float3 HBlurC5PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 473
return HBlur(texcoord, (243.0), VBlurSampler);
}
#line 476
float3 VBlurC5PS(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD): COLOR {
#line 478
return VBlur(texcoord, (243.0), HBlurSampler);
}
#line 485
technique FGFXFCSB16X <
ui_label = "FGFX::FCSB[16X]";
ui_tooltip =
"+------------------------------------------------------------+\n"
"|-=[ FGFX::FCSB[16X] - Fast Cascaded Separable Blur [16X] ]=-|\n"
"+------------------------------------------------------------+\n"
"\n"
#line 493
"FCSB is a blur technique that combines cascaded H / V blur\n"
"passes and alias-free down-sampling in order to produce\n"
"large, smooth and alias-free blur at a fraction of the cost of\n"
"traditional separable Gaussian blur.\n"
"\n"
#line 499
"The Fast Cascaded Separable Blur is written by Alex Tuduran.\n";
> {
#line 508
pass CopyBB {
VertexShader = PostProcessVS;
PixelShader  = CopyBBPS;
RenderTarget = HalfBlurTex;
}
#line 514
pass CopyHalf {
VertexShader = PostProcessVS;
PixelShader  = CopyHalfPS;
RenderTarget = QuadBlurTex;
}
#line 520
pass CopyQuad {
VertexShader = PostProcessVS;
PixelShader  = CopyQuadPS;
RenderTarget = OctoBlurTex;
}
#line 526
pass CopyOcto {
VertexShader = PostProcessVS;
PixelShader  = CopyOctoPS;
RenderTarget = HexaBlurTex;
}
#line 540
 
#line 548
pass CopyHexa {
VertexShader = PostProcessVS;
PixelShader  = CopyHexaPS;
RenderTarget = VBlurTex;
}
#line 557
pass HBlurC0R {
VertexShader = PostProcessVS;
PixelShader  = HBlurC0PS;
RenderTarget = HBlurTex;
}
#line 563
pass VBlurC0R {
VertexShader = PostProcessVS;
PixelShader  = VBlurC0PS;
RenderTarget = VBlurTex;
}
#line 573
pass HBlurC0S {
VertexShader = PostProcessVS;
PixelShader  = HBlurC0PS;
RenderTarget = HBlurTex;
}
#line 579
pass VBlurC0S {
VertexShader = PostProcessVS;
PixelShader  = VBlurC0PS;
RenderTarget = VBlurTex;
}
#line 589
pass HBlurC0SS {
VertexShader = PostProcessVS;
PixelShader  = HBlurC0PS;
RenderTarget = HBlurTex;
}
#line 595
pass VBlurC0SS {
VertexShader = PostProcessVS;
PixelShader  = VBlurC0PS;
RenderTarget = VBlurTex;
}
#line 605
pass HBlurC1R {
VertexShader = PostProcessVS;
PixelShader  = HBlurC1PS;
RenderTarget = HBlurTex;
}
#line 611
pass VBlurC1R {
VertexShader = PostProcessVS;
PixelShader  = VBlurC1PS;
RenderTarget = VBlurTex;
}
#line 621
pass HBlurC2R {
VertexShader = PostProcessVS;
PixelShader  = HBlurC2PS;
RenderTarget = HBlurTex;
}
#line 627
pass VBlurC2R {
VertexShader = PostProcessVS;
PixelShader  = VBlurC2PS;
RenderTarget = VBlurTex;
}
#line 637
pass HBlurC2S {
VertexShader = PostProcessVS;
PixelShader  = HBlurC2PS;
RenderTarget = HBlurTex;
}
#line 643
pass VBlurC2S {
VertexShader = PostProcessVS;
PixelShader  = VBlurC2PS;
RenderTarget = VBlurTex;
}
#line 665
 
#line 669
pass HBlurC0US {
VertexShader = PostProcessVS;
PixelShader  = HBlurC0PS;
RenderTarget = HBlurTex;
}
#line 675
pass VBlurC0US {
VertexShader = PostProcessVS;
PixelShader  = VBlurC0PS;
#line 679
}
#line 691
 
#line 695
} 

