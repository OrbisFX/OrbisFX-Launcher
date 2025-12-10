// ALightLensTexY=1080
// ALightLensTex2Y=1080
// ALightLensTexX=1920
// ALightLensTex2X=1920
// ALightLensTex="LensDBA.png"
// ALightLensTex2="LensDB2.png"
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\AmbientLight.fx"
#line 33
uniform bool alDebug <
ui_tooltip = "Activates debug mode of AL, upper bar shows detected light, lower bar shows adaptation";
> = false;
uniform float alInt <
ui_type = "slider";
ui_min = 0.0; ui_max = 20.0;
ui_tooltip = "Base intensity of AL";
> = 10.15;
uniform float alThreshold <
ui_type = "slider";
ui_min = 0.0; ui_max = 100.0;
ui_tooltip = "Reduces intensity for not bright light";
> = 0.050;
#line 47
uniform bool AL_Dither <
ui_tooltip = "Applies dither - may cause diagonal stripes";
> = false;
#line 51
uniform bool AL_Adaptation <
ui_tooltip = "Activates adaptation algorithm";
> = true;
uniform float alAdapt <
ui_type = "slider";
ui_min = 0.0; ui_max = 4.0;
ui_tooltip = "Intensity of AL correction for bright light";
> = 0.70;
uniform float alAdaptBaseMult <
ui_type = "slider";
ui_min = 0.0; ui_max = 4.0;
ui_tooltip = "Multiplier for adaption applied to the original image";
> = 1.00;
uniform int alAdaptBaseBlackLvL <
ui_type = "slider";
ui_min = 0; ui_max = 4;
ui_tooltip = "Distinction level of black and white (lower => less distinct)";
> = 2;
#line 70
uniform bool AL_Dirt <
> = true;
uniform bool AL_DirtTex <
ui_tooltip = "Defines if dirt texture is used as overlay";
> = false;
uniform bool AL_Vibrance <
ui_tooltip = "Vibrance of dirt effect";
> = false;
uniform int AL_Adaptive <
ui_type = "combo";
ui_min = 0; ui_max = 2;
ui_items = "Warm\0Cold\0Light Dependent\0";
> = 0;
uniform float alDirtInt <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_tooltip = "Intensity of dirt effect";
> = 1.0;
uniform float alDirtOVInt <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_tooltip = "Intensity of colored dirt effect";
> = 1.0;
uniform bool AL_Lens <
ui_tooltip = "Lens effect based on AL";
> = false;
uniform float alLensThresh <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Reduces intensity of lens effect for not bright light";
> = 0.5;
uniform float alLensInt <
ui_type = "slider";
ui_min = 0.0; ui_max = 10.0;
ui_tooltip = "Intensity of lens effect";
> = 2.0;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 57
namespace ReShade
{
float GetAspectRatio() { return 1280 * (1.0 / 720); }
float2 GetPixelSize() { return float2((1.0 / 1280), (1.0 / 720)); }
float2 GetScreenSize() { return float2(1280, 720); }
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
#line 108 "C:\Program Files\GShade\gshade-shaders\Shaders\AmbientLight.fx"
#line 133
uniform float2 AL_t < source = "pingpong"; min = 0.0f; max = 6.28f; step = float2(0.1f, 0.2f); >;
#line 137
texture alInTex  { Width = 1280 / 16; Height = 720 / 16; Format = RGBA32F; };
texture alOutTex { Width = 1280 / 16; Height = 720 / 16; Format = RGBA32F; };
texture detectIntTex { Width = 32; Height = 32; Format = RGBA8; };
sampler detectIntColor { Texture = detectIntTex; };
texture detectLowTex { Width = 1; Height = 1; Format = RGBA8; };
sampler detectLowColor { Texture = detectLowTex; };
#line 144
texture dirtTex    < source = "DirtA.png";    > { Width = 1920; Height = 1080; MipLevels = 1; Format = RGBA8; };
texture dirtOVRTex < source = "DirtOVR.png"; > { Width = 1920; Height = 1080; MipLevels = 1; Format = RGBA8; };
texture dirtOVBTex < source = "DirtOVB.png"; > { Width = 1920; Height = 1080; MipLevels = 1; Format = RGBA8; };
texture lensDBTex  < source = "LensDBA.png";  > { Width = 1920; Height = 1080; MipLevels = 1; Format = RGBA8; };
texture lensDB2Tex < source = "LensDB2.png"; > { Width = 1920; Height = 1080; MipLevels = 1; Format = RGBA8; };
texture lensDOVTex < source = "LensDOV.png"; > { Width = 1920; Height = 1080; MipLevels = 1; Format = RGBA8; };
texture lensDUVTex < source = "LensDUV.png"; > { Width = 1920; Height = 1080; MipLevels = 1; Format = RGBA8; };
#line 152
sampler alInColor { Texture = alInTex; };
sampler alOutColor { Texture = alOutTex; };
sampler dirtSampler { Texture = dirtTex; };
sampler dirtOVRSampler { Texture = dirtOVRTex; };
sampler dirtOVBSampler { Texture = dirtOVBTex; };
sampler lensDBSampler { Texture = lensDBTex; };
sampler lensDB2Sampler { Texture = lensDB2Tex; };
sampler lensDOVSampler { Texture = lensDOVTex; };
sampler lensDUVSampler { Texture = lensDUVTex; };
#line 162
void PS_AL_DetectInt(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 detectInt : SV_Target0)
{
detectInt = tex2D(ReShade::BackBuffer, texcoord);
}
void PS_AL_DetectLow(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 detectLow : SV_Target0)
{
detectLow = 0;
#line 170
if (texcoord.x != 0.5 && texcoord.y != 0.5)
discard;
#line 173
[unroll]
for (float i = 0.0; i <= 1; i += 0.03125)
{
[unroll]
for (float j = 0.0; j <= 1; j += 0.03125)
{
detectLow.xyz += tex2D(detectIntColor, float2(i, j)).xyz;
}
}
#line 183
detectLow.xyz /= 32 * 32;
}
void PS_AL_DetectHigh(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 x : SV_Target)
{
x = tex2D(ReShade::BackBuffer, texcoord);
x = float4(x.rgb * ((abs(max(x.r, max(x.g, x.b)))) * 2.0), 1.0f);
#line 190
float base = (x.r + x.g + x.b); base /= 3;
#line 192
float nR = (x.r * 2) - base;
float nG = (x.g * 2) - base;
float nB = (x.b * 2) - base;
#line 196
[flatten]
if (nR < 0)
{
nG += nR / 2;
nB += nR / 2;
nR = 0;
}
[flatten]
if (nG < 0)
{
nB += nG / 2;
[flatten] if (nR > -nG / 2) nR += nG / 2; else nR = 0;
nG = 0;
}
[flatten]
if (nB < 0)
{
[flatten] if (nR > -nB / 2) nR += nB / 2; else nR = 0;
[flatten] if (nG > -nB / 2) nG += nB / 2; else nG = 0;
nB = 0;
}
#line 218
[flatten]
if (nR > 1)
{
nG += (nR - 1) / 2;
nB += (nR - 1) / 2;
nR = 1;
}
[flatten]
if (nG > 1)
{
nB += (nG - 1) / 2;
[flatten] if (nR + (nG - 1) < 1) nR += (nG - 1) / 2; else nR = 1;
nG = 1;
}
[flatten]
if (nB > 1)
{
[flatten] if (nR + (nB - 1) < 1) nR += (nB - 1) / 2; else nR = 1;
[flatten] if (nG + (nB - 1) < 1) nG += (nB - 1) / 2; else nG = 1;
nB = 1;
}
#line 240
x.r = nR; x.g = nG; x.b = nB;
}
#line 243
void PS_AL_HGB(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 hgb : SV_Target)
{
const float sampleOffsets[5] = { 0.0, 2.4347826, 4.3478260, 6.2608695, 8.1739130 };
const float sampleWeights[5] = { 0.16818994, 0.27276957, 0.111690125, 0.024067905, 0.0021112196 };
#line 248
hgb = tex2D(alInColor, texcoord) * sampleWeights[0];
hgb = float4(max(hgb.rgb - alThreshold, 0.0), hgb.a);
const float stepMult = 1.08 + (AL_t.x / 100) * 0.02;
#line 252
[flatten]
if ((texcoord.x + sampleOffsets[1] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x) < 1.05)
hgb += tex2D(alInColor, texcoord + float2(sampleOffsets[1] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x, 0.0)) * sampleWeights[1] * stepMult;
[flatten]
if ((texcoord.x - sampleOffsets[1] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x) > -0.05)
hgb += tex2D(alInColor, texcoord - float2(sampleOffsets[1] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x, 0.0)) * sampleWeights[1] * stepMult;
#line 259
[flatten]
if ((texcoord.x + sampleOffsets[2] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x) < 1.05)
hgb += tex2D(alInColor, texcoord + float2(sampleOffsets[2] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x, 0.0)) * sampleWeights[2] * stepMult;
[flatten]
if ((texcoord.x - sampleOffsets[2] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x) > -0.05)
hgb += tex2D(alInColor, texcoord - float2(sampleOffsets[2] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x, 0.0)) * sampleWeights[2] * stepMult;
#line 266
[flatten]
if ((texcoord.x + sampleOffsets[3] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x) < 1.05)
hgb += tex2D(alInColor, texcoord + float2(sampleOffsets[3] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x, 0.0)) * sampleWeights[3] * stepMult;
[flatten]
if ((texcoord.x - sampleOffsets[3] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x) > -0.05)
hgb += tex2D(alInColor, texcoord - float2(sampleOffsets[3] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x, 0.0)) * sampleWeights[3] * stepMult;
#line 273
[flatten]
if ((texcoord.x + sampleOffsets[4] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x) < 1.05)
hgb += tex2D(alInColor, texcoord + float2(sampleOffsets[4] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x, 0.0)) * sampleWeights[4] * stepMult;
[flatten]
if ((texcoord.x - sampleOffsets[4] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x) > -0.05)
hgb += tex2D(alInColor, texcoord - float2(sampleOffsets[4] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).x, 0.0)) * sampleWeights[4] * stepMult;
}
void PS_AL_VGB(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 vgb : SV_Target)
{
const float sampleOffsets[5] = { 0.0, 2.4347826, 4.3478260, 6.2608695, 8.1739130 };
const float sampleWeights[5] = { 0.16818994, 0.27276957, 0.111690125, 0.024067905, 0.0021112196 };
#line 285
vgb = tex2D(alOutColor, texcoord) * sampleWeights[0];
vgb = float4(max(vgb.rgb - alThreshold, 0.0), vgb.a);
const float stepMult = 1.08 + (AL_t.x / 100) * 0.02;
#line 289
[flatten]
if ((texcoord.y + sampleOffsets[1] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y) < 1.05)
vgb += tex2D(alOutColor, texcoord + float2(0.0, sampleOffsets[1] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y)) * sampleWeights[1] * stepMult;
[flatten]
if ((texcoord.y - sampleOffsets[1] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y) > -0.05)
vgb += tex2D(alOutColor, texcoord - float2(0.0, sampleOffsets[1] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y)) * sampleWeights[1] * stepMult;
#line 296
[flatten]
if ((texcoord.y + sampleOffsets[2] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y) < 1.05)
vgb += tex2D(alOutColor, texcoord + float2(0.0, sampleOffsets[2] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y)) * sampleWeights[2] * stepMult;
[flatten]
if ((texcoord.y - sampleOffsets[2] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y) > -0.05)
vgb += tex2D(alOutColor, texcoord - float2(0.0, sampleOffsets[2] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y)) * sampleWeights[2] * stepMult;
#line 303
[flatten]
if ((texcoord.y + sampleOffsets[3] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y) < 1.05)
vgb += tex2D(alOutColor, texcoord + float2(0.0, sampleOffsets[3] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y)) * sampleWeights[3] * stepMult;
[flatten]
if ((texcoord.y - sampleOffsets[3] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y) > -0.05)
vgb += tex2D(alOutColor, texcoord - float2(0.0, sampleOffsets[3] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y)) * sampleWeights[3] * stepMult;
#line 310
[flatten]
if ((texcoord.y + sampleOffsets[4] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y) < 1.05)
vgb += tex2D(alOutColor, texcoord + float2(0.0, sampleOffsets[4] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y)) * sampleWeights[4] * stepMult;
[flatten]
if ((texcoord.y - sampleOffsets[4] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y) > -0.05)
vgb += tex2D(alOutColor, texcoord - float2(0.0, sampleOffsets[4] * float2(1.0f / (1280 / 16.0f), 1.0f / (720 / 16.0f)).y)) * sampleWeights[4] * stepMult;
}
#line 318
float4 PS_AL_Magic(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 base = tex2D(ReShade::BackBuffer, texcoord);
float4 high = tex2D(alInColor, texcoord);
float adapt = 0;
#line 327
if (AL_Adaptation)
{
#line 330
const float4 detectLow = tex2D(detectLowColor, 0.5) / 4.215;
float low = sqrt(0.241 * detectLow.r * detectLow.r + 0.691 * detectLow.g * detectLow.g + 0.068 * detectLow.b * detectLow.b);
#line 334
low = pow(low * 1.25f, 2);
adapt = low * (low + 1.0f) * alAdapt * alInt * 5.0f;
#line 337
if (alDebug)
{
float mod = (texcoord.x * 1000.0f) % 1.001f;
#line 342
if (texcoord.y < 0.01f && (texcoord.x < low * 10f && mod < 0.3f))
return float4(1f, 0.5f, 0.3f, 0f);
#line 345
if (texcoord.y > 0.01f && texcoord.y < 0.02f && (texcoord.x < adapt / (alInt * 1.5) && mod < 0.3f))
return float4(0.2f, 1f, 0.5f, 0f);
}
}
#line 350
high = min(0.0325f, high) * 1.15f;
float4 highOrig = high;
#line 353
const float2 flipcoord = 1.0f - texcoord;
float4 highFlipOrig = tex2D(alInColor, flipcoord);
highFlipOrig = min(0.03f, highFlipOrig) * 1.15f;
#line 357
float4 highFlip = highFlipOrig;
float4 highLensSrc = high;
#line 363
if (AL_Dirt)
{
const float4 dirt = tex2D(dirtSampler, texcoord);
const float4 dirtOVR = tex2D(dirtOVRSampler, texcoord);
const float4 dirtOVB = tex2D(dirtOVBSampler, texcoord);
#line 369
const float maxhigh = max(high.r, max(high.g, high.b));
const float threshDiff = maxhigh - 3.2f;
#line 372
[flatten]
if (threshDiff > 0)
{
high.r = (high.r / maxhigh) * 3.2f;
high.g = (high.g / maxhigh) * 3.2f;
high.b = (high.b / maxhigh) * 3.2f;
}
#line 380
float4 highDirt;
if (AL_DirtTex)
highDirt = highOrig * dirt * alDirtInt;
else
highDirt = highOrig * high * alDirtInt;
#line 386
if (AL_Vibrance)
{
highDirt *= 1.0f + 0.5f * sin(AL_t.x);
}
#line 391
const float highMix = highOrig.r + highOrig.g + highOrig.b;
const float red = highOrig.r / highMix;
const float green = highOrig.g / highMix;
const float blue = highOrig.b / highMix;
highOrig = highOrig + highDirt;
#line 397
if (AL_Adaptive == 2)
{
high = high + high * dirtOVR * alDirtOVInt * green;
high = high + highDirt;
high = high + highOrig * dirtOVB * alDirtOVInt * blue;
high = high + highOrig * dirtOVR * alDirtOVInt* red;
}
else if (AL_Adaptive == 1)
{
high = high + highDirt;
high = high + highOrig * dirtOVB * alDirtOVInt;
}
else
{
high = high + highDirt;
high = high + highOrig * dirtOVR * alDirtOVInt;
}
#line 415
highLensSrc = high * 85f * ((1.25f - (abs(texcoord.x - 0.5f) + abs(texcoord.y - 0.5f))) * 2);
}
#line 418
const float origBright = max(highLensSrc.r, max(highLensSrc.g, highLensSrc.b));
const float maxOrig = max((1.8f * alLensThresh) - pow(origBright * (0.5f - abs(texcoord.x - 0.5f)), 4), 0.0f);
float smartWeight = maxOrig * max(abs(flipcoord.x - 0.5f), 0.3f * abs(flipcoord.y - 0.5f)) * (2.2 - 1.2 * (abs(flipcoord.x - 0.5f))) * alLensInt;
if (AL_Adaptation)
smartWeight = min(0.85f, saturate(smartWeight - adapt));
else
smartWeight = min(0.85f, saturate(smartWeight));
#line 428
if (AL_Lens)
{
const float4 lensDB = tex2D(lensDBSampler, texcoord);
const float4 lensDB2 = tex2D(lensDB2Sampler, texcoord);
const float4 lensDOV = tex2D(lensDOVSampler, texcoord);
const float4 lensDUV = tex2D(lensDUVSampler, texcoord);
#line 435
float4 highLens = highFlip * lensDB * 0.7f * smartWeight;
high += highLens;
#line 438
highLens = highFlipOrig * lensDUV * 1.15f * smartWeight;
highFlipOrig += highLens;
high += highLens;
#line 442
highLens = highFlipOrig * lensDB2 * 0.7f * smartWeight;
highFlipOrig += highLens;
high += highLens;
#line 446
highLens = highFlipOrig * lensDOV * 1.15f * smartWeight / 2f + highFlipOrig * smartWeight / 2f;
highFlipOrig += highLens;
high += highLens;
}
#line 451
float dither = 0.0;
if (AL_Dither)
{
dither = 0.15 * (1.0 / (pow(2, 10.0) - 1.0));
dither = lerp(2.0 * dither, -2.0 * dither, frac(dot(texcoord, float2(1280, 720) * float2(1.0 / 16.0, 10.0 / 36.0)) + 0.25));
}
#line 458
if (all(base.xyz == 1.0))
{
return 1.0;
}
#line 467
if (AL_Adaptation)
{
base.xyz *= saturate((1.0f - adapt * 0.75f * alAdaptBaseMult * pow(abs(1.0f - (base.x + base.y + base.z) / 3), alAdaptBaseBlackLvL)));
const float4 highSampleMix = (1.0 - ((1.0 - base) * (1.0 - high * 1.0))) + dither;
const float4 baseSample = lerp(base, highSampleMix, saturate(alInt - adapt));
const float baseSampleMix = baseSample.r + baseSample.g + baseSample.b;
#line 474
if (baseSampleMix > 0.008)
{
#line 479
return baseSample;
#line 481
}
else
{
#line 488
return lerp(base, highSampleMix, saturate((alInt - adapt) * 0.85f) * baseSampleMix);
#line 490
}
}
else
{
const float4 highSampleMix = (1.0 - ((1.0 - base) * (1.0 - high * 1.0))) + dither + adapt;
const float4 baseSample = lerp(base, highSampleMix, alInt);
const float baseSampleMix = baseSample.r + baseSample.g + baseSample.b;
#line 498
if (baseSampleMix > 0.008)
{
#line 503
return baseSample;
#line 505
}
else
{
#line 512
return lerp(base, highSampleMix, saturate(alInt * 0.85f) * baseSampleMix);
#line 514
}
}
}
#line 518
technique AmbientLight
{
pass AL_DetectInt
{
VertexShader = PostProcessVS;
PixelShader = PS_AL_DetectInt;
RenderTarget = detectIntTex;
}
pass AL_DetectLow
{
VertexShader = PostProcessVS;
PixelShader = PS_AL_DetectLow;
RenderTarget = detectLowTex;
}
pass AL_DetectHigh
{
VertexShader = PostProcessVS;
PixelShader = PS_AL_DetectHigh;
RenderTarget = alInTex;
}
#line 554
pass AL_H1 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V1 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
pass AL_H2 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V2 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
pass AL_H3 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V3 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
pass AL_H4 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V4 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
pass AL_H5 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V5 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
pass AL_H6 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V6 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
pass AL_H7 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V7 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
pass AL_H8 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V8 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
pass AL_H9 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V9 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
pass AL_H10 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V10 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
pass AL_H11 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V11 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
pass AL_H12 { VertexShader = PostProcessVS; PixelShader = PS_AL_HGB; RenderTarget = alOutTex; }
pass AL_V12 { VertexShader = PostProcessVS; PixelShader = PS_AL_VGB; RenderTarget = alInTex; }
#line 579
pass AL_Magic
{
VertexShader = PostProcessVS;
PixelShader = PS_AL_Magic;
}
}

