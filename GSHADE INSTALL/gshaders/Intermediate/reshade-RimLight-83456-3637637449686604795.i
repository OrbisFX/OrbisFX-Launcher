#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\RimLight.fx"
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
#line 15 "C:\Program Files\GShade\gshade-shaders\Shaders\RimLight.fx"
#line 25
uniform float3 Color <
ui_label = "Rim Light Color";
ui_tooltip = "Adjust rim light tint";
ui_type = "color";
> = float3(1, 1, 1);
#line 31
uniform bool Debug <
ui_label = "Display Normal Map Pass";
ui_tooltip = "Surface vector angle color map";
ui_category = "Debug Tools";
ui_category_closed = true;
> = false;
#line 38
uniform bool CustomFarPlane <
ui_label = "Custom Far Plane";
ui_tooltip = "Enable custom far plane display outside debug view";
ui_category = "Debug Tools";
> = true;
#line 44
uniform float FarPlane <
ui_label = "Depth Far Plane Preview";
ui_tooltip = "Adjust this option for proper normal map display\n"
"and change preprocessor definitions, so that\n"
"RESHADE_DEPTH_LINEARIZATION_FAR_PLANE = Your_Value";
ui_type = "slider";
ui_min = 0; ui_max = 1000; ui_step = 1;
ui_category = "Debug Tools";
> = 1000.0;
#line 60
float Overlay(float Layer)
{
const float MinLayer = min(Layer, 0.5);
const float MaxLayer = max(Layer, 0.5);
return 2 * (MinLayer * MinLayer + 2 * MaxLayer - MaxLayer * MaxLayer) - 1.5;
}
#line 68
float GetDepth(float2 TexCoord)
{
float depth;
if(Debug || CustomFarPlane)
{
#line 77
depth = tex2Dlod(ReShade::DepthBuffer, float4(TexCoord, 0, 0)).x;
#line 87
depth /= FarPlane - depth * (FarPlane - 1.0);
}
else
{
depth = ReShade::GetLinearizedDepth(TexCoord);
}
return depth;
}
#line 97
float3 NormalVector(float2 TexCoord)
{
const float3 offset = float3(float2((1.0 / 1920), (1.0 / 1018)).xy, 0.0);
const float2 posCenter = TexCoord.xy;
const float2 posNorth = posCenter - offset.zy;
const float2 posEast = posCenter + offset.xz;
#line 104
const float3 vertCenter = float3(posCenter - 0.5, 1) * GetDepth(posCenter);
const float3 vertNorth = float3(posNorth - 0.5, 1) * GetDepth(posNorth);
const float3 vertEast = float3(posEast - 0.5, 1) * GetDepth(posEast);
#line 108
return normalize(cross(vertCenter - vertNorth, vertCenter - vertEast)) * 0.5 + 0.5;
}
#line 116
void RimLightPS(in float4 position : SV_Position, in float2 TexCoord : TEXCOORD, out float3 color : SV_Target)
{
const float3 NormalPass = NormalVector(TexCoord);
#line 120
if(Debug) color = NormalPass;
else
{
color = cross(NormalPass, float3(0.5, 0.5, 1.0));
const float rim = max(max(color.x, color.y), color.z);
color = tex2D(ReShade::BackBuffer, TexCoord).rgb;
color += Color * Overlay(rim);
}
#line 132
}
#line 139
technique RimLight < ui_label = "Rim Light"; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader = RimLightPS;
}
}

