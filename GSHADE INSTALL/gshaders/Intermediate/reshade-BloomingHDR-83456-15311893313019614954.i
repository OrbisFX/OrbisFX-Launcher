#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\BloomingHDR.fx"
#line 97
uniform int Auto_Bloom <
ui_type = "combo";
ui_label = "Auto Bloom";
ui_items = "Off\0Auto Intensity\0Auto Desaturation\0Auto Saturation\0Auto Intensity & Desaturation\0Auto Intensity & Saturation\0";
ui_tooltip = "Auto Intensity will enable the shader to adjust Bloom Intensity automaticly though Bloom Opacity above.\n"
"Auto Saturation will enable the shader to adjust Bloom Saturation automaticly though Bloom Saturation above.\n"
"Default is Off.";
ui_category = "Bloom Adjustments";
> = 0;
#line 107
uniform float CBT_Adjust <
#line 112
ui_type = "slider";
#line 114
ui_min = 0.0; ui_max = 1.0;
ui_label = "Extracting Bright Colors";
ui_tooltip = "Use this to set the color based brightness threshold for what is and what isn't allowed.\n"
"This is the most important setting, use Debug View to adjust this.\n"
"Default Number is 0.5.";
ui_category = "Bloom Adjustments";
> = 0.5;
#line 122
uniform float2 Bloom_Intensity<
#line 126
ui_type = "slider";
#line 128
ui_min = 0.0; ui_max = 1.0;
ui_label = "Bloom Intensity & Bloom Opacity";
ui_tooltip = "Use this to set Primary & Secondary Bloom Intensity and Overall Bloom Opacity for your content.\n"
#line 132
"Number 0.1 & 0.5 is default.";
ui_category = "Bloom Adjustments";
> = float2(0.1,0.5);
#line 136
uniform float BloomSensitivity <
#line 140
ui_type = "slider";
#line 142
ui_min      = 0.1; ui_max      = 5.0;
ui_label    = "Bloom Sensitivity";
ui_tooltip  = "A Curve that is applied to the bloom input.";
ui_category = "Bloom Adjustments";
> = 1.0;
#line 148
uniform float BloomCurve <
#line 152
ui_type = "slider";
#line 154
ui_min      = 0.1; ui_max      = 5.0;
ui_label    = "Bloom Curve";
ui_tooltip  = "Defines the way the bloom spreads.";
ui_category = "Bloom Adjustments";
> = 2.0;
#line 160
uniform float2 Saturation <
#line 164
ui_type = "slider";
#line 166
ui_min = 0.0; ui_max = 1.0;
ui_label = "Bloom Saturation & Auto Cutoff Point";
ui_tooltip = "Adjustment The amount to adjust the saturation of the Bloom.\n"
"Number 0.25 is default for both.";
ui_category = "Bloom Adjustments";
> = float2(0.25,0.25);
#line 173
uniform float Bloom_Spread <
#line 177
ui_type = "slider";
#line 179
ui_min = 0.5; ui_max = 5.0;
ui_label = "Bloom Spread";
ui_tooltip = "Adjust to spread out the primary Bloom.\n"
"This is used for spreading Bloom.\n"
"Number 1.0 is default.";
ui_category = "Bloom Adjustments";
> = 1.0;
#line 187
uniform float Dither_Bloom <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Bloom Dither";
ui_tooltip = "Adjustment The amount Dither on bloom to reduce banding.\n"
"Number 0.25 is default.";
ui_category = "Bloom Adjustments";
> = 0.125;
#line 196
uniform int Tonemappers <
ui_type = "combo";
ui_label = "Tonemappers";
ui_tooltip = "Changes how color get used for the other effects.\n";
ui_items = "Timothy\0ACESFitted\0";
ui_category = "Tonemapper Adjustments";
> = 0;
#line 204
uniform float WP <
ui_type = "drag";
ui_min = 0.00; ui_max = 2.00;
ui_label = "Linear White Point Value";
ui_category = "Tonemapper Adjustments";
> = 1.0;
#line 211
uniform float Exp <
ui_type = "drag";
ui_min = -4.0; ui_max = 4.00;
ui_label = "Exposure";
ui_category = "Tonemapper Adjustments";
> = 0.0;
#line 218
uniform float GreyValue <
ui_type = "drag";
ui_min = 0.0; ui_max = 0.5;
ui_label = "Exposure 50% Greyvalue";
ui_tooltip = "Exposure 50% Greyvalue Set this Higher when using ACES Fitted and Lower when using Timoithy.";
ui_category = "Tonemapper Adjustments";
> = 0.128;
#line 226
uniform float Gamma <
ui_type = "drag";
ui_min = 1.0; ui_max = 4.0;
ui_label = "Gamma value";
ui_tooltip = "Most monitors/images use a value of 2.2. Setting this to 1 disables the inital color space conversion from gamma to linear.";
ui_category = "Tonemapper Adjustments";
> = 2.2;
#line 234
uniform float Contrast <
ui_type = "drag";
ui_min = 0.0; ui_max = 3.0;
ui_tooltip = "Contrast Adjustment.\n"
"Number 1.0 is default.";
ui_category = "Tonemapper Adjustments";
> = 1.0;
#line 242
uniform float Saturate <
ui_type = "drag";
ui_min = 0.0; ui_max = 2.0;
ui_label = "Image Saturation";
ui_tooltip = "Adjustment The amount to adjust the saturation of the color in the image.\n"
"Number 1.0 is default.";
ui_category = "Tonemapper Adjustments";
> = 1.0;
#line 251
uniform int Inv_Tonemappers <
ui_type = "combo";
ui_label = "Extract HDR Information";
ui_tooltip = "Changes how color get used for the other effects.\n"
"Turn this Off when the game has a good HDR implementation.";
ui_items = "Off\0Luma\0Color\0Max Color Brightness\0";
ui_category = "HDR";
> = 2;
#line 260
uniform float HDR_BP <
ui_type = "drag";
ui_min = 0.0; ui_max = 1.0;
ui_label = "HDR Power";
ui_tooltip = "Use adjsut the HDR Power, You can override this value and set it to like 1.5 or something.\n"
"Number 0.5 is default.";
ui_category = "HDR";
> = 0.5;
#line 269
uniform bool Bloom_BA_iToneMapper <
ui_label = "HDR Bloom Application";
ui_tooltip = "This will let you swap between Befor HDR ToneMapper and After.";
ui_category = "HDR";
> = 0;
#line 275
uniform int Auto_Exposure <
ui_type = "combo";
ui_label = "Auto Exposure Type";
ui_items = "Off\0Auto Exposure & Eye Adaptation\0Auto Exposure & Eyelids Adaptation\0";
ui_tooltip = "This will enable the shader to adjust Exposure automaticly.\n"
"This will also turn on Eye Adaptation for this shader.\n"
"This is based off Prod80's Port of an Auto-Expo Algo.\n"
"Padraic Hennessy, MJP and David Neubelt.";
ui_category = "Adaptation";
> = 1;
#line 286
uniform float Adapt_Adjust <
ui_type = "drag";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Eye Adapt Speed";
ui_tooltip = "Use this to Adjust Eye Adaptation Speed.\n"
"Set from Zero to One, Zero is the slowest.\n"
"Number 0.5 is default.";
ui_category = "Adaptation";
> = 0.5;
#line 296
uniform float Adapt_Seek <
ui_type = "drag";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Eye Adapt Seeking";
ui_tooltip = "Use this to Adjust Eye Seeking Radius for Average Brightness.\n"
"Set from 0 to 1, 1 is Full-Screen Average Brightness.\n"
"Number 0.5 is default.";
ui_category = "Adaptation";
> = 0.5;
#line 306
uniform int Debug_View <
ui_type = "combo";
ui_label = "Debug View";
ui_items = "Normal View\0Bloom View\0Heat Map\0";
ui_tooltip = "To view Shade & Blur effect on the game, movie piture & ect.";
ui_category = "Debugging";
> = 0;
#line 324
uniform float timer < source = "timer"; >;
#line 326
texture DepthBufferTex : DEPTH;
#line 328
sampler DepthBuffer
{
Texture = DepthBufferTex;
};
#line 333
texture BackBufferTex : COLOR;
#line 335
sampler BackBuffer
{
Texture = BackBufferTex;
#line 341
};
#line 343
texture texCurrColor { Width = 1920 * 0.5; Height = 1018 * 0.5; Format = RGBA8; MipLevels = 8;};
#line 345
sampler SamplerCurrBB
{
Texture = texCurrColor;
};
#line 351
texture2D BloomTexH_A	        	{ Width = 1920 / 2;  	Height = 1018 / 2;    Format = RGBA16F;};
sampler2D TextureBloomH_A	        { Texture = BloomTexH_A;};
#line 354
texture2D BloomTexV_A	        	{ Width = 1920 / 2;  	Height = 1018 / 2;    Format = RGBA16F;};
sampler2D TextureBloomV_A	    	{ Texture = BloomTexV_A;};
#line 357
texture2D BloomTexH_B	        	{ Width = 1920 / 4;  	Height = 1018 / 4;    Format = RGBA16F;};
sampler2D TextureBloomH_B        	{ Texture = BloomTexH_B;};
#line 360
texture2D BloomTexV_B	        	{ Width = 1920 / 4;  	Height = 1018 / 4;    Format = RGBA16F;};
sampler2D TextureBloomV_B	        { Texture = BloomTexV_B;};
#line 363
texture2D BloomTexH_C	        	{ Width = 1920 / 8;  	Height = 1018 / 8;    Format = RGBA16F;};
sampler2D TextureBloomH_C        	{ Texture = BloomTexH_C;};
#line 366
texture2D BloomTexV_C	        	{ Width = 1920 / 8;  	Height = 1018 / 8;    Format = RGBA16F;};
sampler2D TextureBloomV_C	        { Texture = BloomTexV_C;};
#line 369
texture2D BloomTex	        	{ Width = 1920 / 2;  	Height = 1018 / 2;    Format = RGBA16F;};
sampler2D TextureBloom	        { Texture = BloomTex;};
#line 390
uniform float frametime < source = "frametime";>;
#line 393
float Luma(float3 C)
{
if (0 == 0)
{
const float3 Luma = float3(0.2126, 0.7152, 0.0722); 
return dot(C,Luma);
}
else
{
const float3 Luma = float3(0.2627, 0.6780, 0.0593); 
return dot(C,Luma);
}
}
#line 407
float3 ApplyPQ(float3 color)
{
#line 410
const float m1 = 2610.0 / 4096.0 / 4;
const float m2 = 2523.0 / 4096.0 * 128;
const float c1 = 3424.0 / 4096.0;
const float c2 = 2413.0 / 4096.0 * 32;
const float c3 = 2392.0 / 4096.0 * 32;
const float3 cp = pow(abs(color.xyz), m1);
color.xyz = pow((c1 + c2 * cp) / (1 + c3 * cp), m2);
return color;
}
#line 426
float Log2Exposure( in float avgLuminance, in float GreyValue )
{
float exposure   = 0.0f;
avgLuminance     = max(avgLuminance, 0.000001f);
#line 431
const float linExp     = GreyValue / avgLuminance;
exposure         = log2( linExp );
return exposure;
}
#line 436
float CalcExposedColor(in float avgLuminance, in float offset, in float GreyValue )
{
const float exposure = Log2Exposure( avgLuminance, GreyValue  * 2.2 ) + offset; 
return exp2( exposure );
}
#line 443
texture texDS {Width = 256; Height = 256; Format = RG16F; MipLevels = 9;}; 
#line 445
sampler SamplerDS
{
Texture = texDS;
};
#line 450
texture texTA {Width = 64; Height = 64; Format = R16F; };
#line 452
sampler SamplerTA
{
Texture = texTA;
};
#line 457
texture texStored {Width = 64; Height = 64; Format = R16F; };
#line 459
sampler SamplerStored
{
Texture = texStored;
};
#line 464
float3 Downsample(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float2 texXY = texcoord;
const float2 midHV = (Adapt_Seek-1) * float2(1920 * 0.5,1018 * 0.5) * float2((1.0 / 1920), (1.0 / 1018));
const float2 TC = float2((texXY.x*Adapt_Seek)-midHV.x,(texXY.y*Adapt_Seek)-midHV.y);
#line 470
return float3(Luma(tex2D(BackBuffer,TC).rgb),0,0);
}
#line 473
float PS_Temporal_Adaptation(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{   
float TT = 32500;
float EA = (1-Adapt_Adjust)*1250, L =  tex2Dlod(SamplerDS,float4(texcoord,0,11)).x;
const float PL_A = tex2D(SamplerStored, float2(0.25,0.25)).x;
const float PL_B = tex2D(SamplerStored, float2(0.25,0.75)).x;
EA = Auto_Exposure >= 1 ? PL_A + (L - PL_A) * (1.0 - exp(-frametime/EA)) : L;
TT = Auto_Exposure >= 1 ? PL_B + (L - PL_B) * (1.0 - exp(-frametime/TT)) : L;
const float ITF= 1-(smoothstep(1,0,TT) < 0.85);
const float FT = 2500, PStoredfade = tex2D(SamplerStored, float2(0.75,0.25)).x;
const float TF = PStoredfade + (ITF - PStoredfade) * (1.0 - exp2(-frametime/FT)); 
#line 488
return texcoord.x > 0.5 ?  (texcoord.y > 0.5 ? 0 : TF) : (texcoord.y > 0.5 ? TT : EA);
}
#line 491
float max3(float x, float y, float z)
{
return max(x, max(y, z));
}
#line 496
float3 inv_Tonemapper(float4 color, int TM)
{
if(TM == 1)
return color.rgb * rcp((1.0 + max(color.w,0.001)) - max3(color.r, color.g, color.b));
else if(TM == 2)
return color.rgb * rcp(max((1.0 + color.w) - color.rgb,0.001));
else
return color.rgb * rcp(max((1.0 + lerp(-0.5,0,color.w) ) - Luma(color.rgb),0.001));
}
#line 507
float ColToneB(float hdrMax, float contrast, float shoulder, float midIn, float midOut)
{
return
-((-pow(midIn, contrast) + (midOut*(pow(hdrMax, contrast*shoulder)*pow(midIn, contrast) -
pow(hdrMax, contrast)*pow(midIn, contrast*shoulder)*midOut)) /
(pow(hdrMax, contrast*shoulder)*midOut - pow(midIn, contrast*shoulder)*midOut)) /
(pow(midIn, contrast*shoulder)*midOut));
}
#line 517
float ColToneC(float hdrMax, float contrast, float shoulder, float midIn, float midOut)
{
return (pow(hdrMax, contrast*shoulder)*pow(midIn, contrast) - pow(hdrMax, contrast)*pow(midIn, contrast*shoulder)*midOut) /
(pow(hdrMax, contrast*shoulder)*midOut - pow(midIn, contrast*shoulder)*midOut);
}
#line 524
float ColTone(float x, float4 p)
{
const float z = pow(x, p.r);
return z / (pow(z, p.g)*p.b + p.a);
}
#line 530
float3 TimothyTonemapper(float3 color, float EX)
{
const float hdrMax =  0 ? 25.0 : 16.0; 
const float contrast = Contrast + 0.250; 
static const float shoulder = 1.0; 
static const float midIn = 0.11; 
const float midOut = 0 ? 0.18/25.0 : 0.18; 
#line 538
const float b = ColToneB(hdrMax, contrast, shoulder, midIn, midOut);
const float c = ColToneC(hdrMax, contrast, shoulder, midIn, midOut);
#line 541
color *= EX;
#line 544
float peak = max(color.r, max(color.g, color.b));
peak = max(1e-6f, peak);
#line 547
float3 ratio = color / peak;
peak = ColTone(peak, float4(contrast, shoulder, b, c) );
#line 552
const float crosstalk = 4.0; 
const float saturation = contrast * Saturate; 
const float crossSaturation = contrast*16.0; 
#line 556
float white = WP;
#line 559
ratio = pow(abs(ratio), saturation / crossSaturation);
ratio = lerp(ratio, white, pow(peak, crosstalk));
ratio = pow(abs(ratio), crossSaturation);
#line 564
color = peak * ratio;
return color;
}
#line 569
static const float3x3 ACESInputMat =
float3x3( float3(0.59719, 0.35458, 0.04823),
float3(0.07600, 0.90834, 0.01566),
float3(0.02840, 0.13383, 0.83777));
#line 575
static const float3x3 ACESOutputMat =
float3x3( float3( 1.60475, -0.53108, -0.07367),
float3(-0.10208,  1.10813, -0.00605),
float3(-0.00327, -0.07276,  1.07602));
#line 580
float3 RRTAndODTFit(float3 v)
{
const float3 a = v * (v + 0.0245786f) - 0.000090537f;
const float3 b = v * (0.983729f * v + 0.4329510f) + 0.238081f;
return a / b;
}
#line 587
float3 ACESFitted( float3 color, float EX)
{
color *= EX + 0.5; 
color = mul(ACESInputMat,color);
color = RRTAndODTFit(color);
color = mul(ACESOutputMat,color);
#line 594
return  color/WP;
}
#line 598
float4 SimpleBlur(sampler2D InputTex, float2 Coord, float2 pixelsize)
{
float4 Blur = 0.0;
#line 602
static const float2 Offsets[4]=
{
float2(1.0, 1.0),
float2(1.0, -1.0),
float2(-1.0, 1.0),
float2(-1.0, -1.0)
};
#line 610
for (int i = 0; i < 4; i++)
{
Blur += tex2D(InputTex, Coord + Offsets[i] * pixelsize);
}
#line 615
return Blur * 0.25;
}
#line 618
struct BloomData
{
float4 Blur;
float2 Pixelsize;
float2 Coord;
float  Offset;
float  Weight;
float  WeightSum;
};
#line 628
float2 GetPixelSize(float texsize)
{
return float2((1.0 / 1920), (1.0 / 1018)) * texsize;
}
#line 633
float3 Auto_Luma()
{
return float3(saturate(smoothstep(0,1,1-tex2D(SamplerTA,float2(0.25,0.25)).x)), 
tex2D(SamplerTA,float2(0.25,0.25)).x,                             
saturate(smoothstep(0,1,tex2D(SamplerTA,float2(0.75,0.25)).x)));  
}
#line 640
float3 Color_GS(float4 BC)
{   
float GS = Luma(BC.rgb), Saturate_A = lerp(0,10,Saturation.x), Saturate_B = saturate(Saturation.y), AL = Auto_Luma().x;
#line 644
BC.rgb    = pow(abs(BC.rgb), BloomSensitivity);
BC.rgb /= max(GS, 0.001);
BC.a    = max(0.0, GS - CBT_Adjust);
BC.rgb *= BC.a;
#line 649
if(Auto_Bloom == 2 || Auto_Bloom == 4) 
Saturate_A *= lerp(0.0 + Saturate_B,1,AL);
#line 652
if(Auto_Bloom == 3 || Auto_Bloom == 5) 
Saturate_A *= lerp(2.0 - Saturate_B,1,AL);
#line 655
BC.rgb  = lerp(BC.a, BC.rgb, min(10,Saturate_A));
#line 657
return saturate(BC.rgb);
}
#line 660
void PS_CurrentInfo(float4 pos : SV_Position, float2 texcoords : TEXCOORD, out float4 Color : SV_Target0)
{   
Color = float4(Color_GS(tex2D(BackBuffer, texcoords)), 0);
}
#line 665
float4  Bloom(float2 Coord, float texsize, sampler2D InputTex, int Dir)
{
BloomData Bloom;
Bloom.Pixelsize      = GetPixelSize(texsize);
Bloom.Offset         = Bloom_Spread * 0.5 ;
#line 671
for (int i = 1; i < 8; i++)
{
float2 D = Dir ? float2(Bloom.Offset * Bloom.Pixelsize.x, 0) : float2( 0, Bloom.Offset * Bloom.Pixelsize.y);
Bloom.Weight     = pow(abs(8 - i), BloomCurve);
Bloom.Blur      += tex2Dlod(InputTex, float4(Coord + D ,0,0)) * Bloom.Weight;
Bloom.Blur      += tex2Dlod(InputTex, float4(Coord - D ,0,0)) * Bloom.Weight;
Bloom.Offset    += Bloom_Spread ;
Bloom.WeightSum += Bloom.Weight;
}
#line 681
return Bloom.Blur /= Bloom.WeightSum * 2;
}
#line 684
float4 PS_BloomH_A(float4 pos : SV_Position, float2 Coord : TEXCOORD) : SV_Target
{   
return Bloom(Coord, 2, SamplerCurrBB, 1);
}
#line 689
float4 PS_BloomV_A(float4 pos : SV_Position, float2 Coord : TEXCOORD) : SV_Target
{
return Bloom(Coord, 2, TextureBloomH_A, 0);
}
#line 694
float4 PS_BloomH_B(float4 pos : SV_Position, float2 Coord : TEXCOORD) : SV_Target
{
return Bloom(Coord, 8, TextureBloomV_A, 1);
}
#line 699
float4 PS_BloomV_B(float4 pos : SV_Position, float2 Coord : TEXCOORD) : SV_Target
{
return Bloom(Coord, 8, TextureBloomH_B, 0);
}
#line 704
float4 PS_BloomH_C(float4 pos : SV_Position, float2 Coord : TEXCOORD) : SV_Target
{
return Bloom(Coord, 16, TextureBloomV_B, 1);
}
#line 709
float4 PS_BloomV_C(float4 pos : SV_Position, float2 Coord : TEXCOORD) : SV_Target
{
return Bloom(Coord, 16, TextureBloomH_C, 0);
}
#line 714
float4 Final_Bloom(float4 pos : SV_Position, float2 texcoords : TEXCOORD) : SV_Target
{
const float3 LP = tex2D(BackBuffer, texcoords).rgb;
float4 Bloom  = SimpleBlur(TextureBloomH_A, texcoords, GetPixelSize(2)).rgba;
Bloom += SimpleBlur(TextureBloomV_A, texcoords, GetPixelSize(2)).rgba;
Bloom += SimpleBlur(TextureBloomH_B, texcoords, GetPixelSize(4)).rgba;
Bloom += SimpleBlur(TextureBloomV_B, texcoords, GetPixelSize(4)).rgba;
Bloom += SimpleBlur(TextureBloomH_C, texcoords, GetPixelSize(8)).rgba;
Bloom += SimpleBlur(TextureBloomV_C, texcoords, GetPixelSize(8)).rgba;
Bloom *= lerp(0,10,Bloom_Intensity.x) / 6; 
return float4(lerp(Bloom.rgb, max(Bloom.rgb - LP, 0.0), 0),0);
}
#line 727
float3 Green_Blue( float interpolant )
{
if( interpolant < 0.5 )
return float3(0.0, 1.0, 2.0 * interpolant);
else
return float3(0.0, 2.0 - 2.0 * interpolant, 1.0 );
}
#line 735
float3 Red_Green( float interpolant )
{
if( interpolant < 0.5 )
return float3(1.0, 2.0 * interpolant, 0.0);
else
return float3(2.0 - 2.0 * interpolant, 1.0, 0.0 );
}
#line 743
float3 FHeat( float interpolant )
{
const float invertedInterpolant = interpolant;
if( invertedInterpolant < 0.5 )
{
const float remappedFirstHalf = 1.0 - 2.0 * invertedInterpolant;
return Green_Blue( remappedFirstHalf );
}
else
{
const float remappedSecondHalf = 2.0 - 2.0 * invertedInterpolant;
return Red_Green( remappedSecondHalf );
}
}
#line 758
float3 HeatMap( float interpolant )
{
if( interpolant < 1.0 / 6.0 )
{
const float firstSegmentInterpolant = 6.0 * interpolant;
return ( 1.0 - firstSegmentInterpolant ) * float3(0.0, 0.0, 0.0) + firstSegmentInterpolant * float3(0.0, 0.0, 1.0);
}
else if( interpolant < 5.0 / 6.0 )
{
const float midInterpolant = 0.25 * ( 6.0 * interpolant - 1.0 );
return FHeat( midInterpolant );
}
else
{
const float lastSegmentInterpolant = 6.0 * interpolant - 5.0;
return ( 1.0 - lastSegmentInterpolant ) * float3(1.0, 0.0, 0.0) + lastSegmentInterpolant * float3(1.0, 1.0, 1.0);
}
}
#line 777
float Scale(float val,float max,float min) 
{
return (val - min) / (max - min);
}
#line 782
void GN(inout float Noise,float2 TC,float seed)
{
Noise = frac(tan(distance(TC*((seed+10)+1.61803398874989484820459 * 00000.1), float2(1.61803398874989484820459 * 00000.1, 3.14159265358979323846264 * 00000.1)))*1.41421356237309504880169 * 10000.0);
}
#line 787
float4 HDROut(float2 texcoords)
{   float4 Out, Bloom = SimpleBlur(TextureBloom, texcoords, GetPixelSize(1)).rgba;
const float2 TC = 10 * texcoords.xy - 5;
float AL = Auto_Luma().y, Ex;
#line 792
if(Auto_Exposure >= 1)
Ex = Exp;
else
Ex = lerp(0,2.5,Scale(Exp, 4, -4));
#line 797
float NC = Bloom_Intensity.y;
#line 799
if(Auto_Bloom == 1 || Auto_Bloom == 4 || Auto_Bloom == 5)
NC *= max(0.25,Auto_Luma().x);
#line 802
float3 Noise, iFast, iReinhard, iReinhardLuma, Color = tex2D(BackBuffer, texcoords).rgb;
#line 804
GN( Noise.r, TC, 1 );
GN( Noise.g, TC, 2 );
GN( Noise.b, TC, 3 );
float3 SS  = smoothstep( 0.0, 0.1, Bloom.rgb );
SS *= lerp(0.0,0.1,saturate(Dither_Bloom));
Bloom.rgb = saturate( Bloom.rgb + Noise * SS );
#line 812
Bloom.rgb = lerp( 0.0, Bloom.rgb, saturate(NC));
#line 816
if(Tonemappers >= 1)
Color = lerp(Luma(Color),Color,Saturate);
#line 819
if( Gamma > 1. )
Color = pow(abs(Color),Gamma);
#line 822
if(!Bloom_BA_iToneMapper)
Color += Bloom.rgb;
#line 825
Color = max(0,Color);
#line 827
if(Inv_Tonemappers == 1)
Color = inv_Tonemapper(float4(Color,1-HDR_BP), 0);
else if(Inv_Tonemappers == 2)
Color = inv_Tonemapper(float4(Color,1-HDR_BP), 2);
else if(Inv_Tonemappers == 3)
Color = inv_Tonemapper(float4(Color,1-HDR_BP), 1);
#line 834
if (Bloom_BA_iToneMapper)
Color += Bloom.rgb;
#line 837
if(Auto_Exposure >= 1)
Ex = CalcExposedColor(AL,Ex,GreyValue);
else 
Ex = Ex;
#line 842
if(Tonemappers == 0)
Color = TimothyTonemapper(Color,Ex);
else if (Tonemappers == 1)
Color = ACESFitted(Color,Ex);
#line 860
if( Gamma > 1. )
Color = pow(abs(Color),rcp(2.2));
#line 865
float MD = 0;
if(Tonemappers >= 1)
Color = (Color - 0.5) * (Contrast) + 0.5;
#line 869
if (Debug_View == 0)
Out = float4(Color, 1.);
else if(Debug_View == 1)
Out = Bloom;
else if(Debug_View == 2)
Out = texcoords.y < 0.975 ? HeatMap(Luma( Color )): HeatMap(texcoords.x);
#line 878
texcoords.x = texcoords.x * 0.75 + 0.125;
texcoords *=  1.0 - float2(texcoords.x,texcoords.y);
float vignette = texcoords.x * texcoords.y  * 15.0, Mfactor = pow(smoothstep(0,1,vignette), Auto_Luma().y * 2.0);
if(Auto_Exposure > 1)
vignette = lerp(1,lerp(0,1,saturate(Mfactor)),Auto_Luma().z);
else
vignette = 1;
#line 886
return float4(Out.rgb * vignette,1.0);
}
#line 889
float PS_StoreInfo(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return tex2D(SamplerTA,texcoord).x;
}
#line 895
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float PosX = 0.9525f*1920*float2((1.0 / 1920), (1.0 / 1018)).x,PosY = 0.975f*1018*float2((1.0 / 1920), (1.0 / 1018)).y;
const float3 Color = HDROut(texcoord).rgb;
return float4(Color,1.0);
}
#line 905
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 913
technique Blooming_HDR
{
pass Store_Info
{
VertexShader = PostProcessVS;
PixelShader = PS_StoreInfo;
RenderTarget = texStored;
}
pass Current_Info
{
VertexShader = PostProcessVS;
PixelShader = PS_CurrentInfo;
RenderTarget0 = texCurrColor;
}
pass BloomH_A
{
VertexShader  = PostProcessVS;
PixelShader   = PS_BloomH_A;
RenderTarget = BloomTexH_A;
}
pass BloomV_A
{
VertexShader  = PostProcessVS;
PixelShader   = PS_BloomV_A;
RenderTarget = BloomTexV_A;
}
pass BloomV_B
{
VertexShader  = PostProcessVS;
PixelShader   = PS_BloomH_B;
RenderTarget = BloomTexH_B;
}
pass BloomV_B
{
VertexShader  = PostProcessVS;
PixelShader   = PS_BloomV_B;
RenderTarget = BloomTexV_B;
}
pass BloomV_C
{
VertexShader  = PostProcessVS;
PixelShader   = PS_BloomH_C;
RenderTarget = BloomTexH_C;
}
pass BloomV_C
{
VertexShader  = PostProcessVS;
PixelShader   = PS_BloomV_C;
RenderTarget = BloomTexV_C;
}
pass Bloom
{
VertexShader  = PostProcessVS;
PixelShader   = Final_Bloom;
RenderTarget = BloomTex;
}
pass Downsampler
{
VertexShader = PostProcessVS;
PixelShader = Downsample;
RenderTarget = texDS;
}
pass Temporal_Adaptation
{
VertexShader = PostProcessVS;
PixelShader = PS_Temporal_Adaptation;
RenderTarget = texTA;
}
pass HDROut
{
VertexShader = PostProcessVS;
PixelShader = Out;
#line 988
}
#line 990
}

