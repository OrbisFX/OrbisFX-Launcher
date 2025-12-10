// SilhouetteTexture2_Source=1
// SILHOUETTE_TEXFORMAT=RGBA8
// SilhouetteTexture_Source=0
// SilhouetteBackgroundName="Papyrus6.png"
// SilhouetteForegroundName="Papyrus2.png"
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Silhouette.fx"
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
#line 42 "C:\Program Files\GShade\gshade-shaders\Shaders\Silhouette.fx"
#line 55
uniform bool SEnable_Foreground_Color <
ui_label = "Enable Foreground Color";
ui_tooltip = "Enable this to use a color instead of a texture for the foreground!";
> = false;
#line 60
uniform float3 SForeground_Color <
ui_type = "color";
ui_label = "Foreground Color (If Enabled)";
ui_tooltip = "If you enabled foreground color, use this to select the color.";
ui_min = 0;
ui_max = 255;
> = float3(0, 0, 0);
#line 68
uniform float SForeground_Stage_Opacity <
ui_label = "Foreground Opacity";
ui_tooltip = "Set the transparency of the image.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 77
uniform int SForeground_Tex_Select <
ui_label = "Foreground Texture";
ui_tooltip = "The image to use in the foreground.";
ui_type = "combo";
ui_items = "Papyrus2.png\0Papyrus6.png\0Metal1.jpg\0Ice1.jpg\0Silhouette1.png\0Silhouette2.png\0";
ui_bind = "SilhouetteTexture_Source";
> = 0;
#line 88
uniform bool SDisable_Background_Processing <
ui_label = "Disable Background Processing";
ui_tooltip = "Enable this to only modify the foreground!";
> = false;
#line 93
uniform bool SEnable_Background_Color <
ui_label = "Enable Background Color";
ui_tooltip = "Enable this to use a color instead of a texture for the background!";
> = false;
#line 98
uniform float3 SBackground_Color <
ui_type = "color";
ui_label = "Background Color (If Enabled)";
ui_tooltip = "If you enabled background color, use this to select the color.";
ui_min = 0;
ui_max = 255;
> = float3(0, 0, 0);
#line 106
uniform float SBackground_Stage_Opacity <
ui_label = "Background Opacity";
ui_tooltip = "Set the transparency of the image.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.002;
> = 1.0;
#line 115
uniform float SBackground_Stage_depth <
ui_type = "slider";
ui_min = 0.001;
ui_max = 1.0;
ui_label = "Background Depth";
> = 0.500;
#line 122
uniform int SBackground_Tex_Select <
ui_label = "Background Texture";
ui_tooltip = "The image to use in the background.";
ui_type = "combo";
ui_items = "Papyrus2.png\0Papyrus6.png\0Metal1.jpg\0Ice1.jpg\0Silhouette1.png\0Silhouette2.png\0";
ui_bind = "SilhouetteTexture2_Source";
> = 1;
#line 161
texture Silhouette_Back_Texture { Width = 1920; Height = 1018; Format = RGBA8; };
sampler Silhouette_Back_Sampler { Texture = Silhouette_Back_Texture; };
#line 164
texture Silhouette_Texture <source = "Papyrus2.png";> { Width = 1920; Height = 1018; Format=RGBA8; };
sampler Silhouette_Sampler { Texture = Silhouette_Texture; };
#line 167
texture Silhouette2_Texture < source = "Papyrus6.png"; > { Width = 1920; Height = 1018; Format = RGBA8; };
sampler Silhouette2_Sampler { Texture = Silhouette2_Texture; };
#line 170
void PS_SilhouetteBackbufffer(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float3 color : SV_Target)
{
color = tex2D(ReShade::BackBuffer, texcoord).rgb;
}
#line 175
void PS_SilhouetteForeground(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float3 color : SV_Target)
{
const float4 Silhouette_Stage = tex2D(Silhouette_Sampler, texcoord);
color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 180
if (SEnable_Foreground_Color == true)
{
color = lerp(color, SForeground_Color.rgb, SForeground_Stage_Opacity);
}
else
{
color = lerp(color, Silhouette_Stage.rgb, Silhouette_Stage.a * SForeground_Stage_Opacity);
}
}
#line 190
void PS_SilhouetteBackground(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float3 color : SV_Target)
{
const float4 Silhouette2_Stage = tex2D(Silhouette2_Sampler, texcoord);
const float depth = 1 - ReShade::GetLinearizedDepth(texcoord).r;
color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 196
if (SEnable_Background_Color && depth < SBackground_Stage_depth)
{
color = lerp(color, SBackground_Color.rgb, SBackground_Stage_Opacity);
}
else if (SDisable_Background_Processing && depth < SBackground_Stage_depth)
{
color = lerp(color, tex2D(Silhouette_Back_Sampler, texcoord).rgb, SBackground_Stage_Opacity);
}
else if (depth < SBackground_Stage_depth)
{
color = lerp(color, Silhouette2_Stage.rgb, Silhouette2_Stage.a * SBackground_Stage_Opacity);
}
}
#line 210
technique Silhouette
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_SilhouetteBackbufffer;
RenderTarget = Silhouette_Back_Texture;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_SilhouetteForeground;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_SilhouetteBackground;
}
}

