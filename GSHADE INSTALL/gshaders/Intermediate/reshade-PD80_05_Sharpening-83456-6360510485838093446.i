#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_05_Sharpening.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_05_Sharpening.fx"
#line 31
namespace pd80_lumasharpen
{
#line 34
uniform bool enableShowEdges <
ui_label = "Show only Sharpening Texture";
ui_tooltip = "Show only Sharpening Texture";
ui_category = "Sharpening";
> = false;
uniform float BlurSigma <
ui_label = "Sharpening Width";
ui_tooltip = "Sharpening Width";
ui_category = "Sharpening";
ui_type = "slider";
ui_min = 0.3;
ui_max = 1.2;
> = 0.45;
uniform float Sharpening <
ui_label = "Sharpening Strength";
ui_tooltip = "Sharpening Strength";
ui_category = "Sharpening";
ui_type = "slider";
ui_min = 0.0;
ui_max = 5.0;
> = 1.7;
uniform float Threshold <
ui_label = "Sharpening Threshold";
ui_tooltip = "Sharpening Threshold";
ui_category = "Sharpening";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.0;
uniform float limiter <
ui_label = "Sharpening Highlight Limiter";
ui_tooltip = "Sharpening Highlight Limiter";
ui_category = "Sharpening";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.03;
uniform bool enable_depth <
ui_label = "Enable depth based adjustments.\nMake sure you have setup your depth buffer correctly.";
ui_tooltip = "Enable depth based adjustments";
ui_category = "Sharpening: Depth";
> = false;
uniform bool enable_reverse <
ui_label = "Reverses the effect (sharpen close, or sharpen far)";
ui_tooltip = "Reverses the effect";
ui_category = "Sharpening: Depth";
> = false;
uniform bool display_depth <
ui_label = "Show depth texture";
ui_tooltip = "Show depth texture";
ui_category = "Sharpening: Depth";
> = false;
uniform float depthStart <
ui_type = "slider";
ui_label = "Change Depth Start Plane";
ui_tooltip = "Change Depth Start Plane";
ui_category = "Sharpening: Depth";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.0;
uniform float depthEnd <
ui_type = "slider";
ui_label = "Change Depth End Plane";
ui_tooltip = "Change Depth End Plane";
ui_category = "Sharpening: Depth";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.1;
uniform float depthCurve <
ui_label = "Depth Curve Adjustment";
ui_tooltip = "Depth Curve Adjustment";
ui_category = "Sharpening: Depth";
ui_type = "slider";
ui_min = 0.05;
ui_max = 8.0;
> = 1.0;
#line 112
texture texGaussianH { Width = 1920; Height = 1018; };
texture texGaussian { Width = 1920; Height = 1018; };
#line 116
sampler samplerGaussianH { Texture = texGaussianH; };
sampler samplerGaussian { Texture = texGaussian; };
#line 124
float getLuminance( in float3 x )
{
return dot( x, float3( 0.212656, 0.715158, 0.072186 ));
}
#line 129
float getAvgColor( float3 col )
{
return dot( col.xyz, float3( 0.333333f, 0.333334f, 0.333333f ));
}
#line 136
float3 ClipColor( float3 color )
{
float lum         = getAvgColor( color.xyz );
float mincol      = min( min( color.x, color.y ), color.z );
float maxcol      = max( max( color.x, color.y ), color.z );
color.xyz         = ( mincol < 0.0f ) ? lum + (( color.xyz - lum ) * lum ) / ( lum - mincol ) : color.xyz;
color.xyz         = ( maxcol > 1.0f ) ? lum + (( color.xyz - lum ) * ( 1.0f - lum )) / ( maxcol - lum ) : color.xyz;
return color;
}
#line 148
float3 blendLuma( float3 base, float3 blend )
{
float lumbase     = getAvgColor( base.xyz );
float lumblend    = getAvgColor( blend.xyz );
float ldiff       = lumblend - lumbase;
float3 col        = base.xyz + ldiff;
return ClipColor( col.xyz );
}
#line 157
float3 screen(float3 c, float3 b) { return 1.0f-(1.0f-c)*(1.0f-b);}
#line 160
float4 PS_GaussianH(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2D( ReShade::BackBuffer, texcoord );
float px         = (1.0 / 1920);
float SigmaSum   = 0.0f;
float pxlOffset  = 1.0f;
float loops      = max( 1920, 1018 ) / 1920.0f * 4.0f;
#line 169
float3 Sigma;
float bSigma     = BlurSigma * ( max( 1920, 1018 ) / 1920.0f ); 
Sigma.x          = 1.0f / ( sqrt( 2.0f * 3.1415926535897932 ) * bSigma );
Sigma.y          = exp( -0.5f / ( bSigma * bSigma ));
Sigma.z          = Sigma.y * Sigma.y;
#line 176
color.xyz        *= Sigma.x;
#line 178
SigmaSum         += Sigma.x;
#line 180
Sigma.xy         *= Sigma.yz;
#line 182
[loop]
for( int i = 0; i < loops; ++i )
{
color        += tex2Dlod( ReShade::BackBuffer, float4( texcoord.xy + float2( pxlOffset*px, 0.0f ), 0.0, 0.0 )) * Sigma.x;
color        += tex2Dlod( ReShade::BackBuffer, float4( texcoord.xy - float2( pxlOffset*px, 0.0f ), 0.0, 0.0 )) * Sigma.x;
SigmaSum     += ( 2.0f * Sigma.x );
pxlOffset    += 1.0f;
Sigma.xy     *= Sigma.yz;
}
#line 192
color.xyz        /= SigmaSum;
return float4( color.xyz, 1.0f );
}
#line 196
float4 PS_GaussianV(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2D( samplerGaussianH, texcoord );
float py         = (1.0 / 1018);
float SigmaSum   = 0.0f;
float pxlOffset  = 1.0f;
float loops      = max( 1920, 1018 ) / 1920.0f * 4.0f;
#line 205
float3 Sigma;
float bSigma     = BlurSigma * ( max( 1920, 1018 ) / 1920.0f ); 
Sigma.x          = 1.0f / ( sqrt( 2.0f * 3.1415926535897932 ) * bSigma );
Sigma.y          = exp( -0.5f / ( bSigma * bSigma ));
Sigma.z          = Sigma.y * Sigma.y;
#line 212
color.xyz        *= Sigma.x;
#line 214
SigmaSum         += Sigma.x;
#line 216
Sigma.xy         *= Sigma.yz;
#line 218
[loop]
for( int i = 0; i < loops; ++i )
{
color        += tex2Dlod( samplerGaussianH, float4( texcoord.xy + float2( 0.0f, pxlOffset*py ), 0.0, 0.0 )) * Sigma.x;
color        += tex2Dlod( samplerGaussianH, float4( texcoord.xy - float2( 0.0f, pxlOffset*py ), 0.0, 0.0 )) * Sigma.x;
SigmaSum     += ( 2.0f * Sigma.x );
pxlOffset    += 1.0f;
Sigma.xy     *= Sigma.yz;
}
#line 228
color.xyz        /= SigmaSum;
return float4( color.xyz, 1.0f );
}
#line 232
float4 PS_LumaSharpen(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 orig      = tex2D( ReShade::BackBuffer, texcoord );
float4 gaussian  = tex2D( samplerGaussian, texcoord );
#line 237
float depth      = ReShade::GetLinearizedDepth( texcoord ).x;
depth            = smoothstep( depthStart, depthEnd, depth );
depth            = pow( depth, depthCurve );
depth            = enable_reverse ? 1.0f - depth : depth;
#line 242
float3 edges     = max( saturate( orig.xyz - gaussian.xyz ) - Threshold, 0.0f );
float3 invGauss  = saturate( 1.0f - gaussian.xyz );
float3 oInvGauss = saturate( orig.xyz + invGauss.xyz );
float3 invOGauss = max( saturate( 1.0f - oInvGauss.xyz ) - Threshold, 0.0f );
edges            = max(( saturate( Sharpening * edges.xyz )) - ( saturate( Sharpening * invOGauss.xyz )), 0.0f );
float3 blend     = screen( orig.xyz, lerp( min( edges.xyz, limiter ), 0.0f, enable_depth * depth ));
float3 color     = blendLuma( orig.xyz, blend.xyz );
color.xyz        = enableShowEdges ? lerp( min( edges.xyz, limiter ), min( edges.xyz, limiter ) * depth, enable_depth ) : color.xyz;
color.xyz        = display_depth ? depth.xxx : color.xyz;
return float4( color.xyz, 1.0f );
}
#line 255
technique prod80_05_LumaSharpen
{
pass GaussianH
{
VertexShader   = PostProcessVS;
PixelShader    = PS_GaussianH;
RenderTarget   = texGaussianH;
}
pass GaussianV
{
VertexShader   = PostProcessVS;
PixelShader    = PS_GaussianV;
RenderTarget   = texGaussian;
}
pass LumaSharpen
{
VertexShader   = PostProcessVS;
PixelShader    = PS_LumaSharpen;
}
}
}

