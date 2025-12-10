#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_06_Luma_Fade.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\PD80_06_Luma_Fade.fx"
#line 31
namespace pd80_lumafade
{
#line 34
uniform float transition_speed <
ui_type = "slider";
ui_label = "Time Based Fade Speed";
ui_tooltip = "Time Based Fade Speed";
ui_category = "Scene Luminance Adaptation";
ui_min = 0.0f;
ui_max = 1.0f;
> = 0.5;
uniform float minlevel <
ui_label = "Pure Dark Scene Level";
ui_tooltip = "Pure Dark Scene Level";
ui_category = "Scene Luminance Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.125;
uniform float maxlevel <
ui_label = "Pure Light Scene Level";
ui_tooltip = "Pure Light Scene Level";
ui_category = "Scene Luminance Adaptation";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
> = 0.3;
#line 59
texture texLuma { Width = 256; Height = 256; Format = R16F; MipLevels = 8; };
texture texAvgLuma { Format = R16F; };
texture texPrevAvgLuma { Format = R16F; };
texture texPrevColor { Width = 1920; Height = 1018; Format = RGBA8; };
#line 65
sampler samplerLuma { Texture = texLuma; };
sampler samplerAvgLuma { Texture = texAvgLuma; };
sampler samplerPrevAvgLuma { Texture = texPrevAvgLuma; };
sampler samplerPrevColor { Texture = texPrevColor; };
#line 71
uniform float Frametime < source = "frametime"; >;
#line 74
float interpolate( float o, float n, float factor, float ft )
{
return lerp( o, n, 1.0f - exp( -factor * ft ));
}
#line 80
float PS_WriteLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color     = tex2D( ReShade::BackBuffer, texcoord );
return dot( color.xyz, 0.333333f );
}
#line 86
float PS_AvgLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float luma       = tex2Dlod( samplerLuma, float4( 0.5f, 0.5f, 0, 8 )).x;
float prevluma   = tex2D( samplerPrevAvgLuma, float2( 0.5f, 0.5f )).x;
float factor     = transition_speed * 4.0f + 1.0f;
return interpolate( prevluma, luma, factor, Frametime * 0.001f );
}
#line 94
float4 PS_StorePrev(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return tex2D( ReShade::BackBuffer, texcoord );
}
#line 99
float PS_PrevAvgLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return tex2D( samplerAvgLuma, float2( 0.5f, 0.5f )).x;
}
#line 104
float4 PS_LumaInterpolation(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 newcol    = tex2D( ReShade::BackBuffer, texcoord );
float4 oldcol    = tex2D( samplerPrevColor, texcoord );
float luma       = tex2D( samplerAvgLuma, float2( 0.5f, 0.5f )).x;
return lerp( oldcol, newcol, smoothstep( minlevel, maxlevel, luma ));
}
#line 113
technique prod80_06_LumaFade_Start
< ui_tooltip = "Luma Fading Effects\n\n"
"This shader allows you to fade in and out ReShade effects based on scene luminance.\n"
"To use: put the Start technque before the shaders you want to enable in a BRIGHT scene and\n"
"put the End technique after those shaders. Then use the UI settings to manipulate the fading.";>
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
pass StoreColor
{
VertexShader   = PostProcessVS;
PixelShader    = PS_StorePrev;
RenderTarget   = texPrevColor;
}
pass PreviousLuma
{
VertexShader   = PostProcessVS;
PixelShader    = PS_PrevAvgLuma;
RenderTarget   = texPrevAvgLuma;
}
}
technique prod80_06_LumaFade_End
{
pass Combine
{
VertexShader   = PostProcessVS;
PixelShader    = PS_LumaInterpolation;
}
}
}

