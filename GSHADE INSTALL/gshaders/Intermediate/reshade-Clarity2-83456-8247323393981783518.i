#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Clarity2.fx"
#line 14
uniform int ClarityRadiusTwo
<
ui_type = "slider";
ui_min = 0; ui_max = 4;
ui_tooltip = "[0|1|2|3|4] Higher values will increase the radius of the effect.";
ui_step = 1.00;
> = 3;
#line 22
uniform float ClarityOffsetTwo
<
ui_type = "slider";
ui_min = 1.00; ui_max = 5.00;
ui_tooltip = "Additional adjustment for the blur radius. Increasing the value will increase the radius.";
ui_step = 1.00;
> = 8.00;
#line 30
uniform int ClarityBlendModeTwo
<
ui_type = "combo";
ui_items = "\Soft Light\0Overlay\0Hard Light\0Multiply\0Vivid Light\0Linear Light\0Addition\0";
ui_tooltip = "Blend modes determine how the clarity mask is applied to the original image";
> = 2;
#line 37
uniform int ClarityBlendIfDarkTwo
<
ui_type = "slider";
ui_min = 0; ui_max = 255;
ui_tooltip = "Any pixels below this value will be excluded from the effect. Set to 50 to target mid-tones.";
ui_step = 5;
> = 50;
#line 45
uniform int ClarityBlendIfLightTwo
<
ui_type = "slider";
ui_min = 0; ui_max = 255;
ui_tooltip = "Any pixels above this value will be excluded from the effect. Set to 205 to target mid-tones.";
ui_step = 5;
> = 205;
#line 53
uniform float BlendIfRange
<
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Adjusts the range of the BlendIfMask.";
> = 0.2;
#line 60
uniform float ClarityStrengthTwo
<
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Adjusts the strength of the effect";
> = 0.400;
#line 67
uniform float MaskContrast
<
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Additional adjustment for the blur radius. Increasing the value will increase the radius.";
> = 0.00;
#line 74
uniform float ClarityDarkIntensityTwo
<
ui_type = "slider";
ui_min = 0.00; ui_max = 10.00;
ui_tooltip = "Adjusts the strength of dark halos.";
> = 0.400;
#line 81
uniform float ClarityLightIntensityTwo
<
ui_type = "slider";
ui_min = 0.00; ui_max = 10.00;
ui_tooltip = "Adjusts the strength of light halos.";
> = 0.000;
#line 88
uniform float DitherStrength
<
ui_type = "slider";
ui_min = 0.0; ui_max = 10.0;
ui_tooltip = "Adds dithering to the ClarityMask to help reduce banding";
> = 1.0;
#line 104
uniform int PreprocessorDefinitions
<
ui_type = "combo";
ui_items = "\ReShade must be reloaded to activate these settings.\0UseClarityDebug=1 Activates debug options.\0ClarityRGBMode=1 Runs Clarity in RGB instead of luma.\0";
ui_tooltip = "These settings can be added to the Preprocessor Definitions in the settings tab.";
> = 0;
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
#line 112 "C:\Program Files\GShade\gshade-shaders\Shaders\Clarity2.fx"
#line 240
texture Clarity2Tex{ Width = 1920*0.5; Height = 1018*0.5; Format = R8; };
texture Clarity2Tex2{ Width = 1920*0.5; Height = 1018*0.5; Format = R8; };
#line 243
sampler Clarity2Sampler { Texture = Clarity2Tex; AddressU = CLAMP; AddressV = CLAMP; AddressW = CLAMP; MinFilter = POINT; MagFilter = LINEAR;};
sampler Clarity2Sampler2 { Texture = Clarity2Tex2; AddressU = CLAMP; AddressV = CLAMP; AddressW = CLAMP; MinFilter = POINT; MagFilter = LINEAR;};
#line 246
float4 ClarityFinal(in float4 vpos : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
#line 249
float blur = tex2D(Clarity2Sampler, texcoord/ClarityOffsetTwo).r;
#line 262
float4 orig = tex2D(ReShade::BackBuffer, texcoord);
#line 264
float luma = dot(orig.rgb,float3(0.32786885,0.655737705,0.0163934436));
float3 chroma = orig.rgb/luma;
#line 268
float sharp = 1.0-blur;
#line 270
if(MaskContrast)
{
#line 277
const float vivid = saturate(((1-(1-luma)/(2*sharp))+(luma/(2*(1-sharp))))*0.5);
sharp = (luma+sharp)*0.5;
sharp = lerp(sharp,vivid,MaskContrast);
#line 281
}
else
{
#line 287
sharp = (luma+sharp)*0.5;
#line 289
}
#line 291
if(ClarityDarkIntensityTwo || ClarityLightIntensityTwo)
{
float curve = sharp*sharp*sharp*(sharp*(sharp*6.0 - 15.0) + 10.0);
float sharpMin = lerp(sharp,curve,ClarityDarkIntensityTwo);
float sharpMax = lerp(sharp,curve,ClarityLightIntensityTwo);
float STEP = step(0.5,sharp);
sharp = (sharpMin*(1-STEP))+(sharpMax*STEP);
}
#line 303
sharp = lerp(sharp,sharp-float(frac((sin(dot(texcoord, float2(12.9898,-78.233)))) * 43758.5453 + texcoord.x)*0.015873)-0.0079365,DitherStrength);
#line 317
if(ClarityBlendModeTwo == 0)
{
#line 327
const float A = 2*luma*sharp + luma*luma*(1.0-2*sharp);
const float B = 2*luma*(1.0-sharp)+pow(luma,0.5)*(2*sharp-1.0);
const float C = step(0.49,sharp);
sharp = lerp(A,B,C);
#line 332
}
else
{
if(ClarityBlendModeTwo == 1)
{
#line 345
const float A = 2*luma*sharp;
const float B = 1.0 - 2*(1.0-luma)*(1.0-sharp);
const float C = step(0.50,luma);
sharp = lerp(A,B,C);
#line 350
}
else
{
if(ClarityBlendModeTwo == 2)
{
#line 363
const float A = 2*luma*sharp;
const float B = 1.0 - 2*(1.0-luma)*(1.0-sharp);
const float C = step(0.50,sharp);
const sharp = lerp(A,B,C);
#line 368
}
else
{
if(ClarityBlendModeTwo == 3)
{
#line 377
sharp = saturate(2 * luma * sharp);
#line 379
}
else
{
if(ClarityBlendModeTwo == 4)
{
#line 392
const float A = 2*luma*sharp;
const float B = luma/(2*(1-sharp));
const float C = step(0.50,sharp);
sharp = lerp(A,B,C);
#line 397
}
else
{
if(ClarityBlendModeTwo == 5)
{
#line 407
sharp = luma + 2.0*sharp-1.0;
#line 409
}
else
{
if(ClarityBlendModeTwo == 6)
{
#line 418
sharp = saturate(luma + (sharp - 0.5));
#line 420
}
}
}
}
}
}
}
#line 428
if( ClarityBlendIfDarkTwo || ClarityBlendIfLightTwo < 255)
{
const float ClarityBlendIfD = ((255-ClarityBlendIfDarkTwo)/255.0);
const float ClarityBlendIfL = (ClarityBlendIfLightTwo/255.0);
float mask = 1.0;
float range;
#line 435
if(ClarityBlendIfDarkTwo)
{
range = ClarityBlendIfD*BlendIfRange;
#line 442
const float cmix = 1.0-luma;
mask -= smoothstep(ClarityBlendIfD-(range),ClarityBlendIfD+(range),cmix);
#line 445
}
#line 447
if(ClarityBlendIfLightTwo)
{
range = ClarityBlendIfL*BlendIfRange;
#line 454
const float cmix = luma;
mask = lerp(mask,0.0,smoothstep(ClarityBlendIfL-range, ClarityBlendIfL+range, cmix));
#line 458
}
#line 463
sharp = lerp(luma,sharp,mask);
#line 476
}
#line 482
luma = lerp(luma, sharp, ClarityStrengthTwo);
return float4(luma*chroma,0.0);
#line 485
}
#line 487
float Clarity1(in float4 vpos : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
const float3 color = tex2D(ReShade::BackBuffer, texcoord*ClarityOffsetTwo).rgb;
#line 494
return dot(color.rgb,float3(0.32786885,0.655737705,0.0163934436));
#line 496
}
#line 498
float Clarity2(in float4 vpos : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
#line 501
float blur = tex2D(Clarity2Sampler, texcoord).r;
#line 503
float2 coord;
#line 505
if(ClarityRadiusTwo == 2)
{
static const float offset[11] = { 0.0, 1.4895848401*float2((1.0 / 1920), (1.0 / 1018)).y, 3.4757135714*float2((1.0 / 1920), (1.0 / 1018)).y, 5.4618796741*float2((1.0 / 1920), (1.0 / 1018)).y, 7.4481042327*float2((1.0 / 1920), (1.0 / 1018)).y, 9.4344079746*float2((1.0 / 1920), (1.0 / 1018)).y, 11.420811147*float2((1.0 / 1920), (1.0 / 1018)).y, 13.4073334*float2((1.0 / 1920), (1.0 / 1018)).y, 15.3939936778*float2((1.0 / 1920), (1.0 / 1018)).y, 17.3808101174*float2((1.0 / 1920), (1.0 / 1018)).y, 19.3677999584*float2((1.0 / 1920), (1.0 / 1018)).y };
static const float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 510
blur *= weight[0];
#line 512
[loop]
for(int i = 1; i < 11; ++i)
{
#line 516
coord = float2(0.0, offset[i]);
#line 518
blur += tex2Dlod(Clarity2Sampler, float4(texcoord + coord, 0.0, 0.0)).r * weight[i];
blur += tex2Dlod(Clarity2Sampler, float4(texcoord - coord, 0.0, 0.0)).r * weight[i];
}
}
else
{
if(ClarityRadiusTwo == 3)
{
static const float offset[15] = { 0.0, float2((1.0 / 1920), (1.0 / 1018)).y*1.4953705027, float2((1.0 / 1920), (1.0 / 1018)).y*3.4891992113, float2((1.0 / 1920), (1.0 / 1018)).y*5.4830312105, float2((1.0 / 1920), (1.0 / 1018)).y*7.4768683759, float2((1.0 / 1920), (1.0 / 1018)).y*9.4707125766, float2((1.0 / 1920), (1.0 / 1018)).y*11.4645656736, float2((1.0 / 1920), (1.0 / 1018)).y*13.4584295168, float2((1.0 / 1920), (1.0 / 1018)).y*15.4523059431, float2((1.0 / 1920), (1.0 / 1018)).y*17.4461967743, float2((1.0 / 1920), (1.0 / 1018)).y*19.4401038149, float2((1.0 / 1920), (1.0 / 1018)).y*21.43402885, float2((1.0 / 1920), (1.0 / 1018)).y*23.4279736431, float2((1.0 / 1920), (1.0 / 1018)).y*25.4219399344, float2((1.0 / 1920), (1.0 / 1018)).y*27.4159294386 };
static const float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
#line 529
blur *= weight[0];
#line 531
[loop]
for(int i = 1; i < 15; ++i)
{
coord = float2(0.0, offset[i]);
#line 536
blur += tex2Dlod(Clarity2Sampler, float4(texcoord + coord, 0.0, 0.0)).r * weight[i];
blur += tex2Dlod(Clarity2Sampler, float4(texcoord - coord, 0.0, 0.0)).r * weight[i];
}
}
else
{
if(ClarityRadiusTwo == 4)
{
static const float offset[18] = { 0.0, float2((1.0 / 1920), (1.0 / 1018)).y*1.4953705027, float2((1.0 / 1920), (1.0 / 1018)).y*3.4891992113, float2((1.0 / 1920), (1.0 / 1018)).y*5.4830312105, float2((1.0 / 1920), (1.0 / 1018)).y*7.4768683759, float2((1.0 / 1920), (1.0 / 1018)).y*9.4707125766, float2((1.0 / 1920), (1.0 / 1018)).y*11.4645656736, float2((1.0 / 1920), (1.0 / 1018)).y*13.4584295168, float2((1.0 / 1920), (1.0 / 1018)).y*15.4523059431, float2((1.0 / 1920), (1.0 / 1018)).y*17.4461967743, float2((1.0 / 1920), (1.0 / 1018)).y*19.4661974725, float2((1.0 / 1920), (1.0 / 1018)).y*21.4627427973, float2((1.0 / 1920), (1.0 / 1018)).y*23.4592916956, float2((1.0 / 1920), (1.0 / 1018)).y*25.455844494, float2((1.0 / 1920), (1.0 / 1018)).y*27.4524015179, float2((1.0 / 1920), (1.0 / 1018)).y*29.4489630909, float2((1.0 / 1920), (1.0 / 1018)).y*31.445529535, float2((1.0 / 1920), (1.0 / 1018)).y*33.4421011704 };
static const float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
#line 547
blur *= weight[0];
#line 549
[loop]
for(int i = 1; i < 18; ++i)
{
coord = float2(0.0, offset[i]);
#line 554
blur += tex2Dlod(Clarity2Sampler, float4(texcoord + coord, 0.0, 0.0)).r * weight[i];
blur += tex2Dlod(Clarity2Sampler, float4(texcoord - coord, 0.0, 0.0)).r * weight[i];
}
}
else
{
if(ClarityRadiusTwo == 1)
{
static const float offset[6] = { 0.0, float2((1.0 / 1920), (1.0 / 1018)).y*1.4584295168, float2((1.0 / 1920), (1.0 / 1018)).y*3.40398480678, float2((1.0 / 1920), (1.0 / 1018)).y*5.3518057801, float2((1.0 / 1920), (1.0 / 1018)).y*7.302940716, float2((1.0 / 1920), (1.0 / 1018)).y*9.2581597095 };
static const float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 565
blur *= weight[0];
#line 567
[loop]
for(int i = 1; i < 6; ++i)
{
coord = float2(0.0, offset[i]);
#line 572
blur += tex2Dlod(Clarity2Sampler, float4(texcoord + coord, 0.0, 0.0)).r * weight[i];
blur += tex2Dlod(Clarity2Sampler, float4(texcoord - coord, 0.0, 0.0)).r * weight[i];
}
}
else
{
if(ClarityRadiusTwo == 0)
{
static const float offset[4] = { 0.0, float2((1.0 / 1920), (1.0 / 1018)).y*1.1824255238, float2((1.0 / 1920), (1.0 / 1018)).y*3.0293122308, float2((1.0 / 1920), (1.0 / 1018)).y*5.0040701377 };
static const float weight[4] = { 0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842 };
#line 583
blur *= weight[0];
#line 585
[loop]
for(int i = 1; i < 4; ++i)
{
coord = float2(0.0, offset[i]);
#line 590
blur += tex2Dlod(Clarity2Sampler, float4(texcoord + coord, 0.0, 0.0)).r * weight[i];
blur += tex2Dlod(Clarity2Sampler, float4(texcoord - coord, 0.0, 0.0)).r * weight[i];
}
}
}
#line 596
}
}
}
return blur;
}
#line 602
float Clarity3(in float4 vpos : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
#line 605
float blur = tex2D(Clarity2Sampler2, texcoord).r;
#line 607
float2 coord;
#line 609
if(ClarityRadiusTwo == 2)
{
static const float offset[11] = { 0.0, 1.4895848401*float2((1.0 / 1920), (1.0 / 1018)).x, 3.4757135714*float2((1.0 / 1920), (1.0 / 1018)).x, 5.4618796741*float2((1.0 / 1920), (1.0 / 1018)).x, 7.4481042327*float2((1.0 / 1920), (1.0 / 1018)).x, 9.4344079746*float2((1.0 / 1920), (1.0 / 1018)).x, 11.420811147*float2((1.0 / 1920), (1.0 / 1018)).x, 13.4073334*float2((1.0 / 1920), (1.0 / 1018)).x, 15.3939936778*float2((1.0 / 1920), (1.0 / 1018)).x, 17.3808101174*float2((1.0 / 1920), (1.0 / 1018)).x, 19.3677999584*float2((1.0 / 1920), (1.0 / 1018)).x };
static const float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 614
blur *= weight[0];
#line 616
[loop]
for(int i = 1; i < 11; ++i)
{
#line 620
coord = float2(offset[i],0.0);
#line 622
blur += tex2Dlod(Clarity2Sampler2, float4(texcoord + coord, 0.0, 0.0)).r * weight[i];
blur += tex2Dlod(Clarity2Sampler2, float4(texcoord - coord, 0.0, 0.0)).r * weight[i];
}
}
else
{
if(ClarityRadiusTwo == 3)
{
static const float offset[15] = { 0.0, float2((1.0 / 1920), (1.0 / 1018)).x*1.4953705027, float2((1.0 / 1920), (1.0 / 1018)).x*3.4891992113, float2((1.0 / 1920), (1.0 / 1018)).x*5.4830312105, float2((1.0 / 1920), (1.0 / 1018)).x*7.4768683759, float2((1.0 / 1920), (1.0 / 1018)).x*9.4707125766, float2((1.0 / 1920), (1.0 / 1018)).x*11.4645656736, float2((1.0 / 1920), (1.0 / 1018)).x*13.4584295168, float2((1.0 / 1920), (1.0 / 1018)).x*15.4523059431, float2((1.0 / 1920), (1.0 / 1018)).x*17.4461967743, float2((1.0 / 1920), (1.0 / 1018)).x*19.4401038149, float2((1.0 / 1920), (1.0 / 1018)).x*21.43402885, float2((1.0 / 1920), (1.0 / 1018)).x*23.4279736431, float2((1.0 / 1920), (1.0 / 1018)).x*25.4219399344, float2((1.0 / 1920), (1.0 / 1018)).x*27.4159294386 };
static const float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
#line 633
blur *= weight[0];
#line 635
[loop]
for(int i = 1; i < 15; ++i)
{
coord = float2(offset[i],0.0);
#line 640
blur += tex2Dlod(Clarity2Sampler2, float4(texcoord + coord, 0.0, 0.0)).r * weight[i];
blur += tex2Dlod(Clarity2Sampler2, float4(texcoord - coord, 0.0, 0.0)).r * weight[i];
}
}
else
{
if(ClarityRadiusTwo == 4)
{
static const float offset[18] = { 0.0, float2((1.0 / 1920), (1.0 / 1018)).x*1.4953705027, float2((1.0 / 1920), (1.0 / 1018)).x*3.4891992113, float2((1.0 / 1920), (1.0 / 1018)).x*5.4830312105, float2((1.0 / 1920), (1.0 / 1018)).x*7.4768683759, float2((1.0 / 1920), (1.0 / 1018)).x*9.4707125766, float2((1.0 / 1920), (1.0 / 1018)).x*11.4645656736, float2((1.0 / 1920), (1.0 / 1018)).x*13.4584295168, float2((1.0 / 1920), (1.0 / 1018)).x*15.4523059431, float2((1.0 / 1920), (1.0 / 1018)).x*17.4461967743, float2((1.0 / 1920), (1.0 / 1018)).x*19.4661974725, float2((1.0 / 1920), (1.0 / 1018)).x*21.4627427973, float2((1.0 / 1920), (1.0 / 1018)).x*23.4592916956, float2((1.0 / 1920), (1.0 / 1018)).x*25.455844494, float2((1.0 / 1920), (1.0 / 1018)).x*27.4524015179, float2((1.0 / 1920), (1.0 / 1018)).x*29.4489630909, float2((1.0 / 1920), (1.0 / 1018)).x*31.445529535, float2((1.0 / 1920), (1.0 / 1018)).x*33.4421011704 };
static const float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
#line 651
blur *= weight[0];
#line 653
[loop]
for(int i = 1; i < 18; ++i)
{
coord = float2(offset[i],0.0);
#line 658
blur += tex2Dlod(Clarity2Sampler2, float4(texcoord + coord, 0.0, 0.0)).r * weight[i];
blur += tex2Dlod(Clarity2Sampler2, float4(texcoord - coord, 0.0, 0.0)).r * weight[i];
}
}
else
{
if(ClarityRadiusTwo == 1)
{
static const float offset[6] = { 0.0, float2((1.0 / 1920), (1.0 / 1018)).x*1.4584295168, float2((1.0 / 1920), (1.0 / 1018)).x*3.40398480678, float2((1.0 / 1920), (1.0 / 1018)).x*5.3518057801, float2((1.0 / 1920), (1.0 / 1018)).x*7.302940716, float2((1.0 / 1920), (1.0 / 1018)).x*9.2581597095 };
static const float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 669
blur *= weight[0];
#line 671
[loop]
for(int i = 1; i < 6; ++i)
{
coord = float2(offset[i],0.0);
#line 676
blur += tex2Dlod(Clarity2Sampler2, float4(texcoord + coord, 0.0, 0.0)).r * weight[i];
blur += tex2Dlod(Clarity2Sampler2, float4(texcoord - coord, 0.0, 0.0)).r * weight[i];
}
}
else
{
if(ClarityRadiusTwo == 0)
{
static const float offset[4] = { 0.0, float2((1.0 / 1920), (1.0 / 1018)).x*1.1824255238, float2((1.0 / 1920), (1.0 / 1018)).x*3.0293122308, float2((1.0 / 1920), (1.0 / 1018)).x*5.0040701377 };
static const float weight[4] = { 0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842 };
#line 687
blur *= weight[0];
#line 689
[loop]
for(int i = 1; i < 4; ++i)
{
coord = float2(offset[i],0.0);
#line 694
blur += tex2Dlod(Clarity2Sampler2, float4(texcoord + coord, 0.0, 0.0)).r * weight[i];
blur += tex2Dlod(Clarity2Sampler2, float4(texcoord - coord, 0.0, 0.0)).r * weight[i];
}
}
}
#line 700
}
}
}
#line 704
return blur;
}
#line 707
technique Clarity2
{
#line 710
pass Clarity1
{
VertexShader = PostProcessVS;
PixelShader = Clarity1;
RenderTarget = Clarity2Tex;
}
#line 717
pass Clarity2
{
VertexShader = PostProcessVS;
PixelShader = Clarity2;
RenderTarget = Clarity2Tex2;
}
#line 724
pass Clarity3
{
VertexShader = PostProcessVS;
PixelShader = Clarity3;
RenderTarget = Clarity2Tex;
}
#line 731
pass ClarityFinal
{
VertexShader = PostProcessVS;
PixelShader = ClarityFinal;
}
}

