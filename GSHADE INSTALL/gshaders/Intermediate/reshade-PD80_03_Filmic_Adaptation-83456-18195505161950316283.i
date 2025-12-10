#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Filmic_Adaptation.fx"
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
#line 39 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_03_Filmic_Adaptation.fx"
#line 40
namespace pd80_filmicadaptation
{
#line 43
uniform float adj_shoulder <
ui_label = "Adjust Highlights";
ui_tooltip = "Adjust Highlights";
ui_category = "Tonemapping";
ui_type = "slider";
ui_min = 1.0;
ui_max = 5.0;
> = 1.0;
uniform float adj_linear <
ui_label = "Adjust Linearity";
ui_tooltip = "Adjust Linearity";
ui_category = "Tonemapping";
ui_type = "slider";
ui_min = 1.0;
ui_max = 10.0;
> = 1.0;
uniform float adj_toe <
ui_label = "Adjust Shadows";
ui_tooltip = "Adjust Shadows";
ui_category = "Tonemapping";
ui_type = "slider";
ui_min = 1.0;
ui_max = 5.0;
> = 1.0;
#line 69
texture texLuma { Width = 256; Height = 256; Format = R16F; MipLevels = 9; };
texture texAvgLuma { Format = R16F; };
texture texPrevAvgLuma { Format = R16F; };
#line 74
sampler samplerLinColor { Texture = ReShade::BackBufferTex; SRGBTexture = true; };
sampler samplerLuma { Texture = texLuma; };
sampler samplerAvgLuma { Texture = texAvgLuma; };
sampler samplerPrevAvgLuma { Texture = texPrevAvgLuma; };
#line 81
uniform float Frametime < source = "frametime"; >;
#line 84
float getLuminance( in float3 x )
{
return dot( x, float3(0.212656, 0.715158, 0.072186) );
}
#line 89
float3 Filmic( in float3 Fc, in float FA, in float FB, in float FC, in float FD, in float FE, in float FF, in float FWhite )
{
float3 num       = (( Fc * ( FA * Fc + FC * FB ) + FD * FE ) / ( Fc * ( FA * Fc + FB ) + FD * FF )) - FE / FF;
float3 denom     = (( FWhite * ( FA * FWhite + FC * FB ) + FD * FE ) / ( FWhite * ( FA * FWhite + FB ) + FD * FF )) - FE / FF;
return num / denom;
#line 95
}
#line 98
float PS_WriteLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2D( samplerLinColor, texcoord );
float luma       = getLuminance( color.xyz );
luma             = max( luma, 0.06f ); 
return log2( luma ); 
}
#line 106
float PS_AvgLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float luma       = tex2Dlod( samplerLuma, float4(0.5f, 0.5f, 0, 8 )).x;
luma             = exp2( luma );
float prevluma   = tex2D( samplerPrevAvgLuma, float2( 0.5f, 0.5f )).x;
float fps        = 1000.0f / Frametime;
float delay      = fps; 
float avgLuma    = lerp( prevluma, luma, 1.0f / delay );
return avgLuma;
}
#line 117
float4 PS_Tonemap(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
#line 120
float A          = 0.65f  * adj_shoulder;
float B          = 0.085f * adj_linear;
float C          = 1.83f;
float D          = 0.55f  * adj_toe;
float E          = 0.05f;
float F          = 0.57f;
float W          = 1.0f; 
float4 color     = tex2D( ReShade::BackBuffer, texcoord );
float luma       = tex2D( samplerAvgLuma, float2( 0.5f, 0.5f )).x;
float exp        = lerp( 1.0f, 8.0f, luma ); 
float toe        = max( D * exp, D ); 
color.xyz        = Filmic( color.xyz, A, B, C, toe, E, F, W );
#line 133
return float4( color.xyz, 1.0f );
}
#line 136
float PS_PrevAvgLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float avgLuma    = tex2D( samplerAvgLuma, float2( 0.5f, 0.5f )).x;
return avgLuma;
}
#line 143
technique prod80_03_FilmicTonemap
{
pass Luma
{
VertexShader   = PostProcessVS;
PixelShader    = PS_WriteLuma;
RenderTarget   = texLuma;
}
pass AvgLuma
{
VertexShader   = PostProcessVS;
PixelShader    = PS_AvgLuma;
RenderTarget   = texAvgLuma;
}
pass Tonemapping
{
VertexShader   = PostProcessVS;
PixelShader    = PS_Tonemap;
}
pass PreviousLuma
{
VertexShader   = PostProcessVS;
PixelShader    = PS_PrevAvgLuma;
RenderTarget   = texPrevAvgLuma;
}
}
}

