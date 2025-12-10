#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\4xBRZ.fx"
#line 68
uniform float coef <
ui_type = "slider";
ui_min = 1.0; ui_max = 10.0;
ui_label = "Strength";
ui_tooltip = "Strength of the effect (4 or 6)";
> = 4.0;
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
#line 77 "C:\Program Files\GShade\gshade-shaders\Shaders\4xBRZ.fx"
#line 92
float reduce( const float3 color )
{
return dot( color, float3(65536.0, 256.0, 1.0) );
}
#line 97
float DistYCbCr( const float3 pixA, const float3 pixB )
{
const float3 w      = float3( 0.2627, 0.6780, 0.0593 );
const float  scaleB = 0.5 / (1.0 - w.b);
const float  scaleR = 0.5 / (1.0 - w.r);
float3 diff   = pixA - pixB;
float  Y      = dot(diff, w);
float  Cb     = scaleB * (diff.b - Y);
float  Cr     = scaleR * (diff.r - Y);
#line 107
return sqrt( ((1.0 * Y) * (1.0 * Y)) + (Cb * Cb) + (Cr * Cr) );
}
#line 110
bool IsPixEqual( const float3 pixA, const float3 pixB )
{
return ( DistYCbCr(pixA, pixB) < 30.0 / 255.0 );
}
#line 115
bool IsBlendingNeeded( const int4 blend )
{
return any( !(blend == (int4)0) );
}
#line 126
void VS_Downscale( in  uint   id       : SV_VertexID,
out float4 position : SV_Position,
out float2 texcoord : TEXCOORD0 )
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 135
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 140
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 142
texcoord *= float2(coef, coef);
}
#line 147
void VS_XBRZ4X( in  uint   id       : SV_VertexID,
out float4 position : SV_Position,
out float2 texcoord : TEXCOORD0,
out float4 t1       : TEXCOORD1,
out float4 t2       : TEXCOORD2,
out float4 t3       : TEXCOORD3,
out float4 t4       : TEXCOORD4,
out float4 t5       : TEXCOORD5,
out float4 t6       : TEXCOORD6,
out float4 t7       : TEXCOORD7
)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 164
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 169
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 171
float dx = ( 1.0 / 1920  );
float dy = ( 1.0 / 1018 );
#line 174
texcoord /= float2(coef, coef);
#line 182
t1 = texcoord.xxxy + float4(     -dx,   0, dx, -2.0*dy ); 
t2 = texcoord.xxxy + float4(     -dx,   0, dx,     -dy ); 
t3 = texcoord.xxxy + float4(     -dx,   0, dx,       0 ); 
t4 = texcoord.xxxy + float4(     -dx,   0, dx,      dy ); 
t5 = texcoord.xxxy + float4(     -dx,   0, dx,  2.0*dy ); 
t6 = texcoord.xyyy + float4( -2.0*dx, -dy,  0,      dy ); 
t7 = texcoord.xyyy + float4(  2.0*dx, -dy,  0,      dy ); 
}
#line 204
texture DownscaleTex
{
Width  = 1920;
Height = 1018;
Format = RGBA8;
};
#line 211
texture UpscaleTex
{
Width  = 1920;
Height = 1018;
Format = RGBA8;
};
#line 218
sampler DownscaleSampler
{
Texture   = DownscaleTex;
MinFilter = Point;
MagFilter = Point;
};
#line 225
sampler UpscaleSampler
{
Texture   = UpscaleTex;
MinFilter = Point;
MagFilter = Point;
};
#line 233
float3 PS_Downscale( float4 pos : SV_Position,
float2 uv  : TexCoord0 ) : COLOR
{
#line 240
return tex2D(ReShade::BackBuffer, uv).rgb;
#line 242
}
#line 245
float3 PS_Final( float4 pos : SV_Position,
float2 uv  : TexCoord ) : COLOR
{
#line 252
return tex2D(UpscaleSampler, uv).rgb;
#line 254
}
#line 257
float3 PS_XBRZ4X( float4 pos : SV_Position,
float2 uv  : TexCoord0,
float4 t1  : TexCoord1,
float4 t2  : TexCoord2,
float4 t3  : TexCoord3,
float4 t4  : TexCoord4,
float4 t5  : TexCoord5,
float4 t6  : TexCoord6,
float4 t7  : TexCoord7
) : COLOR
{
#line 270
float2 f = frac( uv * float2(1920, 1018) );
#line 280
float3 src[25];
#line 282
src[21] = tex2D(DownscaleSampler, t1.xw).rgb;
src[22] = tex2D(DownscaleSampler, t1.yw).rgb;
src[23] = tex2D(DownscaleSampler, t1.zw).rgb;
src[ 6] = tex2D(DownscaleSampler, t2.xw).rgb;
src[ 7] = tex2D(DownscaleSampler, t2.yw).rgb;
src[ 8] = tex2D(DownscaleSampler, t2.zw).rgb;
src[ 5] = tex2D(DownscaleSampler, t3.xw).rgb;
src[ 0] = tex2D(DownscaleSampler, t3.yw).rgb;
src[ 1] = tex2D(DownscaleSampler, t3.zw).rgb;
src[ 4] = tex2D(DownscaleSampler, t4.xw).rgb;
src[ 3] = tex2D(DownscaleSampler, t4.yw).rgb;
src[ 2] = tex2D(DownscaleSampler, t4.zw).rgb;
src[15] = tex2D(DownscaleSampler, t5.xw).rgb;
src[14] = tex2D(DownscaleSampler, t5.yw).rgb;
src[13] = tex2D(DownscaleSampler, t5.zw).rgb;
src[19] = tex2D(DownscaleSampler, t6.xy).rgb;
src[18] = tex2D(DownscaleSampler, t6.xz).rgb;
src[17] = tex2D(DownscaleSampler, t6.xw).rgb;
src[ 9] = tex2D(DownscaleSampler, t7.xy).rgb;
src[10] = tex2D(DownscaleSampler, t7.xz).rgb;
src[11] = tex2D(DownscaleSampler, t7.xw).rgb;
#line 304
float v[9];
v[0] = reduce( src[0] );
v[1] = reduce( src[1] );
v[2] = reduce( src[2] );
v[3] = reduce( src[3] );
v[4] = reduce( src[4] );
v[5] = reduce( src[5] );
v[6] = reduce( src[6] );
v[7] = reduce( src[7] );
v[8] = reduce( src[8] );
#line 315
int4 blendResult = (int4)0;
#line 325
if ( !((v[0] == v[1] && v[3] == v[2]) || (v[0] == v[3] && v[1] == v[2])) )
{
float dist_03_01       = DistYCbCr(src[ 4], src[ 0]) + DistYCbCr(src[ 0], src[ 8]) + DistYCbCr(src[14], src[ 2]) +
DistYCbCr(src[ 2], src[10]) + (4.0 * DistYCbCr(src[ 3], src[ 1]));
float dist_00_02       = DistYCbCr(src[ 5], src[ 3]) + DistYCbCr(src[ 3], src[13]) + DistYCbCr(src[ 7], src[ 1]) +
DistYCbCr(src[ 1], src[11]) + (4.0 * DistYCbCr(src[ 0], src[ 2]));
bool  dominantGradient = (3.6 * dist_03_01) < dist_00_02;
#line 333
if ((dist_03_01 < dist_00_02) && (v[0] != v[1]) && (v[0] != v[3]))
{
if (dominantGradient)
{
blendResult[2] = 2;
}
else
{
blendResult[2] = 1;
}
}
else
{
blendResult[2] = 0;
}
}
#line 357
if ( !((v[5] == v[0] && v[4] == v[3]) || (v[5] == v[4] && v[0] == v[3])) )
{
float dist_04_00       = DistYCbCr(src[17], src[ 5]) + DistYCbCr(src[ 5], src[ 7]) + DistYCbCr(src[15], src[ 3]) +
DistYCbCr(src[ 3], src[ 1]) + (4.0 * DistYCbCr(src[ 4], src[ 0]));
float dist_05_03       = DistYCbCr(src[18], src[ 4]) + DistYCbCr(src[ 4], src[14]) + DistYCbCr(src[ 6], src[ 0]) +
DistYCbCr(src[ 0], src[ 2]) + (4.0 * DistYCbCr(src[ 5], src[ 3]));
bool  dominantGradient = (3.6 * dist_05_03) < dist_04_00;
#line 366
if ((dist_04_00 > dist_05_03) && (v[0] != v[5]) && (v[0] != v[3]))
{
if (dominantGradient)
{
blendResult[3] = 2;
}
else
{
blendResult[3] = 1;
}
}
else
{
blendResult[3] = 0;
}
}
#line 389
if ( !((v[7] == v[8] && v[0] == v[1]) || (v[7] == v[0] && v[8] == v[1])) )
{
float dist_00_08       = DistYCbCr(src[ 5], src[ 7]) + DistYCbCr(src[ 7], src[23]) + DistYCbCr(src[ 3], src[ 1]) +
DistYCbCr(src[ 1], src[ 9]) + (4.0 * DistYCbCr(src[ 0], src[ 8]));
float dist_07_01       = DistYCbCr(src[ 6], src[ 0]) + DistYCbCr(src[ 0], src[ 2]) + DistYCbCr(src[22], src[ 8]) +
DistYCbCr(src[ 8], src[10]) + (4.0 * DistYCbCr(src[ 7], src[ 1]));
bool  dominantGradient = (3.6 * dist_07_01) < dist_00_08;
#line 397
if ((dist_00_08 > dist_07_01) && (v[0] != v[7]) && (v[0] != v[1]))
{
if (dominantGradient)
{
blendResult[1] = 2;
}
else
{
blendResult[1] = 1;
}
}
else
{
blendResult[1] = 0;
}
}
#line 420
if ( !((v[6] == v[7] && v[5] == v[0]) || (v[6] == v[5] && v[7] == v[0])) )
{
float dist_05_07       = DistYCbCr(src[18], src[ 6]) + DistYCbCr(src[ 6], src[22]) + DistYCbCr(src[ 4], src[ 0]) +
DistYCbCr(src[ 0], src[ 8]) + (4.0 * DistYCbCr(src[ 5], src[ 7]));
float dist_06_00       = DistYCbCr(src[19], src[ 5]) + DistYCbCr(src[ 5], src[ 3]) + DistYCbCr(src[21], src[ 7]) +
DistYCbCr(src[ 7], src[ 1]) + (4.0 * DistYCbCr(src[ 6], src[ 0]));
bool  dominantGradient = (3.6 * dist_05_07) < dist_06_00;
#line 428
if ((dist_05_07 < dist_06_00) && (v[0] != v[5]) && (v[0] != v[7]))
{
if (dominantGradient)
{
blendResult[0] = 2;
}
else
{
blendResult[0] = 1;
}
}
else
{
blendResult[0] = 0;
}
}
#line 445
float3 dst[16];
dst[ 0] = src[0];
dst[ 1] = src[0];
dst[ 2] = src[0];
dst[ 3] = src[0];
dst[ 4] = src[0];
dst[ 5] = src[0];
dst[ 6] = src[0];
dst[ 7] = src[0];
dst[ 8] = src[0];
dst[ 9] = src[0];
dst[10] = src[0];
dst[11] = src[0];
dst[12] = src[0];
dst[13] = src[0];
dst[14] = src[0];
dst[15] = src[0];
#line 464
if (IsBlendingNeeded(blendResult))
{
#line 468
float dist_01_04     = DistYCbCr(src[1], src[4]);
float dist_03_08     = DistYCbCr(src[3], src[8]);
bool haveShallowLine = (2.2 * dist_01_04 <= dist_03_08) && (v[0] != v[4]) && (v[5] != v[4]);
bool haveSteepLine   = (2.2 * dist_03_08 <= dist_01_04) && (v[0] != v[8]) && (v[7] != v[8]);
bool needBlend       = (blendResult[2] != 0);
#line 474
bool doLineBlend = ( blendResult[2] >= 2 ||
!( (blendResult[1] != 0 && !IsPixEqual(src[0], src[4])) ||
(blendResult[3] != 0 && !IsPixEqual(src[0], src[8])) ||
(IsPixEqual(src[4], src[3]) && IsPixEqual(src[3], src[2]) && IsPixEqual(src[2], src[1]) && IsPixEqual(src[1], src[8]) && !IsPixEqual(src[0], src[2]))
)
);
#line 481
float3 blendPix;
if ( DistYCbCr(src[0], src[1]) <= DistYCbCr(src[0], src[3]) )
blendPix = src[1];
else
blendPix = src[3];
#line 487
if (needBlend && doLineBlend)
{
if (haveShallowLine)
{
if (haveSteepLine)
{
dst[2] = lerp( dst[2], blendPix, 1.0/3.0 );
}
else
{
dst[2] = lerp( dst[2], blendPix, 0.25 );
}
}
else
{
if (haveSteepLine)
{
dst[2] = lerp( dst[2], blendPix, 0.25 );
}
else
{
dst[2] = lerp( dst[2], blendPix, 0.0 );
}
}
}
else
{
dst[2] = lerp( dst[2], blendPix, 0.0 );
}
#line 517
if (needBlend && doLineBlend && haveSteepLine)
dst[9] = lerp( dst[9], blendPix, 0.25 );
else
dst[9] = lerp( dst[9], blendPix, 0.00 );
#line 522
if (needBlend && doLineBlend && haveSteepLine)
dst[10] = lerp( dst[10], blendPix, 0.75 );
else
dst[10] = lerp( dst[10], blendPix, 0.00 );
#line 527
if (needBlend)
{
if (doLineBlend)
{
if (haveSteepLine)
{
dst[11] = lerp( dst[11], blendPix, 1.0);
}
else
{
if (haveShallowLine)
{
dst[11] = lerp( dst[11], blendPix, 0.75);
}
else
{
dst[11] = lerp( dst[11], blendPix, 0.50);
}
}
}
else
{
dst[11] = lerp( dst[11], blendPix, 0.08677704501);
}
}
else
{
dst[11] = lerp( dst[11], blendPix, 0.0);
}
#line 557
if (needBlend)
{
if (doLineBlend)
{
dst[12] = lerp( dst[12], blendPix, 1.0);
}
else
{
dst[12] = lerp( dst[12], blendPix, 0.6848532563);
}
}
else
{
dst[12] = lerp( dst[12], blendPix, 0.00);
}
#line 573
if (needBlend)
{
if (doLineBlend)
{
if (haveShallowLine)
{
dst[13] = lerp( dst[13], blendPix, 1.0);
}
else
{
if (haveSteepLine)
{
dst[13] = lerp( dst[13], blendPix, 0.75);
}
else
{
dst[13] = lerp( dst[13], blendPix, 0.50);
}
}
}
else
{
dst[13] = lerp( dst[13], blendPix, 0.08677704501);
}
}
else
{
dst[13] = lerp( dst[13], blendPix, 0.0);
}
#line 603
if (needBlend && doLineBlend && haveShallowLine)
dst[14] = lerp( dst[14], blendPix, 0.75);
else
dst[14] = lerp( dst[14], blendPix, 0.00);
#line 608
if (needBlend && doLineBlend && haveShallowLine)
dst[15] = lerp( dst[15], blendPix, 0.25);
else
dst[15] = lerp( dst[15], blendPix, 0.00);
#line 615
dist_01_04      = DistYCbCr(src[7], src[2]);
dist_03_08      = DistYCbCr(src[1], src[6]);
haveShallowLine = (2.2 * dist_01_04 <= dist_03_08) && (v[0] != v[2]) && (v[3] != v[2]);
haveSteepLine   = (2.2 * dist_03_08 <= dist_01_04) && (v[0] != v[6]) && (v[5] != v[6]);
needBlend       = (blendResult[1] != 0);
#line 621
doLineBlend = ( blendResult[1] >= 2 ||
!( (blendResult[0] != 0 && !IsPixEqual(src[0], src[2])) ||
(blendResult[2] != 0 && !IsPixEqual(src[0], src[6])) ||
(IsPixEqual(src[2], src[1]) && IsPixEqual(src[1], src[8]) && IsPixEqual(src[8], src[7]) && IsPixEqual(src[7], src[6]) && !IsPixEqual(src[0], src[8]))
)
);
#line 628
blendPix = ( DistYCbCr(src[0], src[7]) <= DistYCbCr(src[0], src[1]) ) ? src[7] : src[1];
dst[ 1] = lerp( dst[ 1], blendPix, (needBlend && doLineBlend) ? ((haveShallowLine) ? ((haveSteepLine) ? 1.0/3.0 : 0.25) : ((haveSteepLine) ? 0.25 : 0.00)) : 0.00 );
dst[ 6] = lerp( dst[ 6], blendPix, (needBlend && doLineBlend && haveSteepLine) ? 0.25 : 0.00 );
dst[ 7] = lerp( dst[ 7], blendPix, (needBlend && doLineBlend && haveSteepLine) ? 0.75 : 0.00 );
dst[ 8] = lerp( dst[ 8], blendPix, (needBlend) ? ((doLineBlend) ? ((haveSteepLine) ? 1.00 : ((haveShallowLine) ? 0.75 : 0.50)) : 0.08677704501) : 0.00 );
dst[ 9] = lerp( dst[ 9], blendPix, (needBlend) ? ((doLineBlend) ? 1.00 : 0.6848532563) : 0.00 );
dst[10] = lerp( dst[10], blendPix, (needBlend) ? ((doLineBlend) ? ((haveShallowLine) ? 1.00 : ((haveSteepLine) ? 0.75 : 0.50)) : 0.08677704501) : 0.00 );
dst[11] = lerp( dst[11], blendPix, (needBlend && doLineBlend && haveShallowLine) ? 0.75 : 0.00 );
dst[12] = lerp( dst[12], blendPix, (needBlend && doLineBlend && haveShallowLine) ? 0.25 : 0.00 );
#line 641
dist_01_04      = DistYCbCr(src[5], src[8]);
dist_03_08      = DistYCbCr(src[7], src[4]);
haveShallowLine = (2.2 * dist_01_04 <= dist_03_08) && (v[0] != v[8]) && (v[1] != v[8]);
haveSteepLine   = (2.2 * dist_03_08 <= dist_01_04) && (v[0] != v[4]) && (v[3] != v[4]);
needBlend       = (blendResult[0] != 0);
#line 647
doLineBlend = ( blendResult[0] >= 2 ||
!( (blendResult[3] != 0 && !IsPixEqual(src[0], src[8])) ||
(blendResult[1] != 0 && !IsPixEqual(src[0], src[4])) ||
(IsPixEqual(src[8], src[7]) && IsPixEqual(src[7], src[6]) && IsPixEqual(src[6], src[5]) && IsPixEqual(src[5], src[4]) && !IsPixEqual(src[0], src[6]))
)
);
#line 654
blendPix = ( DistYCbCr(src[0], src[5]) <= DistYCbCr(src[0], src[7]) ) ? src[5] : src[7];
#line 656
dst[ 0] = lerp( dst[ 0], blendPix, (needBlend && doLineBlend) ? ((haveShallowLine) ? ((haveSteepLine) ? 1.0/3.0 : 0.25) : ((haveSteepLine) ? 0.25 : 0.00)) : 0.00 );
dst[15] = lerp( dst[15], blendPix, (needBlend && doLineBlend && haveSteepLine) ? 0.25 : 0.00 );
dst[ 4] = lerp( dst[ 4], blendPix, (needBlend && doLineBlend && haveSteepLine) ? 0.75 : 0.00 );
dst[ 5] = lerp( dst[ 5], blendPix, (needBlend) ? ((doLineBlend) ? ((haveSteepLine) ? 1.00 : ((haveShallowLine) ? 0.75 : 0.50)) : 0.08677704501) : 0.00 );
dst[ 6] = lerp( dst[ 6], blendPix, (needBlend) ? ((doLineBlend) ? 1.00 : 0.6848532563) : 0.00 );
dst[ 7] = lerp( dst[ 7], blendPix, (needBlend) ? ((doLineBlend) ? ((haveShallowLine) ? 1.00 : ((haveSteepLine) ? 0.75 : 0.50)) : 0.08677704501) : 0.00 );
dst[ 8] = lerp( dst[ 8], blendPix, (needBlend && doLineBlend && haveShallowLine) ? 0.75 : 0.00 );
dst[ 9] = lerp( dst[ 9], blendPix, (needBlend && doLineBlend && haveShallowLine) ? 0.25 : 0.00 );
#line 668
dist_01_04      = DistYCbCr(src[3], src[6]);
dist_03_08      = DistYCbCr(src[5], src[2]);
haveShallowLine = (2.2 * dist_01_04 <= dist_03_08) && (v[0] != v[6]) && (v[7] != v[6]);
haveSteepLine   = (2.2 * dist_03_08 <= dist_01_04) && (v[0] != v[2]) && (v[1] != v[2]);
needBlend       = (blendResult[3] != 0);
#line 674
doLineBlend = ( blendResult[3] >= 2 ||
!( (blendResult[2] != 0 && !IsPixEqual(src[0], src[6])) ||
(blendResult[0] != 0 && !IsPixEqual(src[0], src[2])) ||
(IsPixEqual(src[6], src[5]) && IsPixEqual(src[5], src[4]) && IsPixEqual(src[4], src[3]) && IsPixEqual(src[3], src[2]) && !IsPixEqual(src[0], src[4]))
)
);
#line 681
blendPix = ( DistYCbCr(src[0], src[3]) <= DistYCbCr(src[0], src[5]) ) ? src[3] : src[5];
dst[ 3] = lerp( dst[ 3], blendPix, (needBlend && doLineBlend) ? ((haveShallowLine) ? ((haveSteepLine) ? 1.0/3.0 : 0.25) : ((haveSteepLine) ? 0.25 : 0.00)) : 0.00 );
dst[12] = lerp( dst[12], blendPix, (needBlend && doLineBlend && haveSteepLine) ? 0.25 : 0.00 );
dst[13] = lerp( dst[13], blendPix, (needBlend && doLineBlend && haveSteepLine) ? 0.75 : 0.00 );
dst[14] = lerp( dst[14], blendPix, (needBlend) ? ((doLineBlend) ? ((haveSteepLine) ? 1.00 : ((haveShallowLine) ? 0.75 : 0.50)) : 0.08677704501) : 0.00 );
dst[15] = lerp( dst[15], blendPix, (needBlend) ? ((doLineBlend) ? 1.00 : 0.6848532563) : 0.00 );
dst[ 4] = lerp( dst[ 4], blendPix, (needBlend) ? ((doLineBlend) ? ((haveShallowLine) ? 1.00 : ((haveSteepLine) ? 0.75 : 0.50)) : 0.08677704501) : 0.00 );
dst[ 5] = lerp( dst[ 5], blendPix, (needBlend && doLineBlend && haveShallowLine) ? 0.75 : 0.00 );
dst[ 6] = lerp( dst[ 6], blendPix, (needBlend && doLineBlend && haveShallowLine) ? 0.25 : 0.00 );
}
#line 693
float3 res = lerp
(
lerp
(
lerp( lerp(dst[ 6], dst[ 7], step(0.25, f.x)), lerp(dst[ 8], dst[ 9], step(0.75, f.x)), step(0.50, f.x) ),
lerp( lerp(dst[ 5], dst[ 0], step(0.25, f.x)), lerp(dst[ 1], dst[10], step(0.75, f.x)), step(0.50, f.x) ),
step(0.25, f.y)
),
lerp
(
lerp
( lerp(dst[ 4], dst[ 3], step(0.25, f.x)), lerp(dst[ 2], dst[11], step(0.75, f.x)), step(0.50, f.x) ),
lerp( lerp(dst[15], dst[14], step(0.25, f.x)), lerp(dst[13], dst[12], step(0.75, f.x)), step(0.50, f.x) ),
step(0.75, f.y)
),
step(0.50, f.y)
);
#line 712
return res;
}
#line 716
technique xBRZ4x
{
pass Downscale
{
VertexShader = VS_Downscale;
PixelShader  = PS_Downscale;
RenderTarget = DownscaleTex;
}
pass Upscale
{
VertexShader = VS_XBRZ4X;
PixelShader  = PS_XBRZ4X;
RenderTarget = UpscaleTex;
}
pass Final
{
VertexShader = PostProcessVS;
PixelShader  = PS_Final;
}
}

