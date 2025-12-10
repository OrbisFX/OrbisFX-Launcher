#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\DLAA.fx"
#line 26
uniform int View_Mode <
ui_type = "combo";
ui_items = "DLAA Out\0Mask View A\0Mask View B\0";
ui_label = "View Mode";
ui_tooltip = "This is used to select the normal view output or debug view.";
> = 0;
#line 38
texture BackBufferTex : COLOR;
#line 40
sampler BackBuffer
{
Texture = BackBufferTex;
};
texture SLPtex {Width = 1920; Height = 1018; Format = RGBA8; };
#line 46
sampler SamplerLoadedPixel
{
Texture = SLPtex;
};
#line 52
float LI(in float3 value)
{
#line 57
return dot(value.ggg,float3(0.333, 0.333, 0.333));
}
#line 60
float4 LP(float2 tc,float dx, float dy) 
{
return tex2D(BackBuffer, tc + float2(dx, dy) * float2((1.0 / 1920), (1.0 / 1018)).xy);
}
#line 65
float4 PreFilter(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target 
{
#line 68
const float4 center = LP(texcoord,  0,  0);
const float4 left   = LP(texcoord, -1,  0);
const float4 right  = LP(texcoord,  1,  0);
const float4 top    = LP(texcoord,  0, -1);
const float4 bottom = LP(texcoord,  0,  1);
#line 74
const float4 edges = 4.0 * abs((left + right + top + bottom) - 4.0 * center);
const float  edgesLum = LI(edges.rgb);
#line 77
return float4(center.rgb, edgesLum);
}
#line 80
float4 SLP(float2 tc,float dx, float dy) 
{
return tex2D(SamplerLoadedPixel, tc + float2(dx, dy) * float2((1.0 / 1920), (1.0 / 1018)).xy);
}
#line 86
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 89
float4 DLAA, DLAA_S, DLAA_L; 
#line 92
const float4 Center 		= SLP(texcoord, 0   , 0);
const float4 Left			= SLP(texcoord,-1.0 , 0);
const float4 Right		= SLP(texcoord, 1.0 , 0);
const float4 Up			= SLP(texcoord, 0 ,-1.0);
const float4 Down			= SLP(texcoord, 0 , 1.);
#line 100
const float4 combH		= 2.0 * ( Left + Right );
const float4 combV   		= 2.0 * ( Up + Down );
#line 106
const float4 CenterDiffH	= abs( combH - 4.0 * Center ) / 4.0;
const float4 CenterDiffV	= abs( combV - 4.0 * Center ) / 4.0;
#line 110
const float4 blurredH		= (combH + 2.0 * Center) / 6.0;
const float4 blurredV		= (combV + 2.0 * Center) / 6.0;
#line 114
const float LumH			= LI( CenterDiffH.rgb );
const float LumV			= LI( CenterDiffV.rgb );
#line 117
const float LumHB = LI(blurredH.xyz);
const float LumVB = LI(blurredV.xyz);
#line 121
const float satAmountH 	= saturate( ( 3.0f * LumH - 0.1f ) / LumVB );
const float satAmountV 	= saturate( ( 3.0f * LumV - 0.1f ) / LumHB );
#line 126
DLAA = lerp( Center, blurredH, satAmountV );
DLAA = lerp( DLAA,   blurredV, satAmountH *  0.5f);
#line 129
float4  HNeg, HNegA, HNegB, HNegC, HNegD, HNegE,
HPos, HPosA, HPosB, HPosC, HPosD, HPosE,
VNeg, VNegA, VNegB, VNegC,
VPos, VPosA, VPosB, VPosC;
#line 136
HNeg    = Left;
HNegA   = SLP( texcoord,  -3.5 ,  0.0 );
HNegB   = SLP( texcoord,  -5.5 ,  0.0 );
HNegC   = SLP( texcoord,  -7.5 ,  0.0 );
#line 141
HPos    = Right;
HPosA   = SLP( texcoord,  3.5 ,  0.0 );
HPosB   = SLP( texcoord,  5.5 ,  0.0 );
HPosC   = SLP( texcoord,  7.5 ,  0.0 );
#line 146
VNeg    = Up;
VNegA   = SLP( texcoord,  0.0,-3.5  );
VNegB   = SLP( texcoord,  0.0,-5.5  );
VNegC   = SLP( texcoord,  0.0,-7.5  );
#line 151
VPos    = Down;
VPosA   = SLP( texcoord,  0.0, 3.5  );
VPosB   = SLP( texcoord,  0.0, 5.5  );
VPosC   = SLP( texcoord,  0.0, 7.5  );
#line 157
const float4 AvgBlurH = ( HNeg + HNegA + HNegB + HNegC + HPos + HPosA + HPosB + HPosC ) / 8;
const float4 AvgBlurV = ( VNeg + VNegA + VNegB + VNegC + VPos + VPosA + VPosB + VPosC ) / 8;
const float EAH = saturate( AvgBlurH.a * 2.0 - 1.0 );
const float EAV = saturate( AvgBlurV.a * 2.0 - 1.0 );
#line 162
const float longEdge = abs( EAH - EAV ) + abs(LumH + LumV);
const float Mask = longEdge > 0.2;
#line 165
if ( Mask )
{
const float4 left			= LP(texcoord,-1 , 0);
const float4 right		= LP(texcoord, 1 , 0);
const float4 up			= LP(texcoord, 0 ,-1);
const float4 down			= LP(texcoord, 0 , 1);
#line 174
const float LongBlurLumH	= LI( AvgBlurH.rgb);
#line 176
const float LongBlurLumV	= LI( AvgBlurV.rgb );
#line 178
const float centerLI		= LI( Center.rgb );
const float leftLI		= LI( left.rgb );
const float rightLI		= LI( right.rgb );
const float upLI			= LI( up.rgb );
const float downLI		= LI( down.rgb );
#line 184
const float blurUp = saturate( 0.0 + ( LongBlurLumH - upLI    ) / (centerLI - upLI) );
const float blurLeft = saturate( 0.0 + ( LongBlurLumV - leftLI   ) / (centerLI - leftLI) );
const float blurDown = saturate( 1.0 + ( LongBlurLumH - centerLI ) / (centerLI - downLI) );
const float blurRight = saturate( 1.0 + ( LongBlurLumV - centerLI ) / (centerLI - rightLI) );
#line 189
float4 UDLR = float4( blurLeft, blurRight, blurUp, blurDown );
#line 191
if (UDLR.r == 0.0 && UDLR.g == 0.0 && UDLR.b == 0.0 && UDLR.a == 0.0)
UDLR = float4(1.0, 1.0, 1.0, 1.0);
#line 194
float4 V = lerp( left , Center, UDLR.x );
V = lerp( right, V	  , UDLR.y );
#line 197
float4 H = lerp( up   , Center, UDLR.z );
H = lerp( down , H	  , UDLR.w );
#line 201
DLAA = lerp( DLAA , V , EAV);
DLAA = lerp( DLAA , H , EAH);
}
#line 205
if(View_Mode == 1)
{
DLAA = Mask * 2;
}
else if (View_Mode == 2)
{
DLAA = lerp(DLAA,float4(1,1,0,1),Mask * 2);
}
#line 214
return DLAA;
}
#line 220
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 234
technique Directionally_Localized_Anti_Aliasing
{
pass Pre_Filter
{
VertexShader = PostProcessVS;
PixelShader = PreFilter;
RenderTarget = SLPtex;
}
pass DLAA_Light
{
VertexShader = PostProcessVS;
PixelShader = Out;
}
}

