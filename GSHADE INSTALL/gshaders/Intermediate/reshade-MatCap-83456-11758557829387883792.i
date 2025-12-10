#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MatCap.fx"
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
#line 3 "C:\Program Files\GShade\gshade-shaders\Shaders\MatCap.fx"
#line 10
uniform bool bDisplayOutlines <
ui_label = "Display Outlines";
> = false;
#line 14
uniform float fOutlinesCorrection <
ui_label = "Outlines Correction";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1000.0;
ui_step = 0.1;
> = 20.0;
#line 24
float get_depth(float2 uv) {
return ReShade::GetLinearizedDepth(uv);
}
#line 28
float get_depth_ddx(float2 uv) {
static const float2 offset = float2((1.0 / 1920), 0.0); 
return (get_depth(uv + offset) - get_depth(uv - offset)) * 1920 * 0.5;
}
#line 33
float get_depth_ddy(float2 uv) {
static const float2 offset = float2(0.0, (1.0 / 1018)); 
return (get_depth(uv - offset) - get_depth(uv + offset)) * 1018 * 0.5;
}
#line 38
float3 get_normals(float2 uv) {
return normalize(float3(
get_depth_ddx(uv),
get_depth_ddy(uv),
get_depth(uv)
));
}
#line 48
float4 PS_Outlines(
const float4 pos : SV_POSITION,
const float2 uv : TEXCOORD
) : SV_TARGET {
float3 col = tex2D(ReShade::BackBuffer, uv).rgb;
const float3 normals = get_normals(uv);
#line 55
float outlines = dot(normals, float3(0.0, 0.0, 1.0));
outlines *= fOutlinesCorrection;
outlines = saturate(outlines);
#line 59
const float gs = (col.r + col.g + col.b) / 3.0;
#line 61
if (bDisplayOutlines)
col = outlines;
else
col = col * outlines;
#line 68
return float4(col, 1.0);
}
#line 71
float4 PS_Experimental(
const float4 pos : SV_POSITION,
const float2 uv : TEXCOORD
) : SV_TARGET {
const float3 normals = get_normals(uv);
float3 col = tex2D(ReShade::BackBuffer, uv).rgb;
#line 79
const float fresnel = length(normals.xy) * normals.y;
#line 82
const float3 sky_color = (tex2D(ReShade::BackBuffer, float2(0.0, 1.0)).rgb
+  tex2D(ReShade::BackBuffer, float2(0.5, 1.0)).rgb
+  tex2D(ReShade::BackBuffer, float2(1.0, 1.0)).rgb) / 3.0;
#line 93
const float3 light  = col + col * col;
const float3 shadow = col * col;
#line 98
col = lerp(shadow, light, saturate(fresnel));
#line 100
return float4(col, 1.0);
}
#line 105
technique MatCap_Outlines {
pass {
VertexShader = PostProcessVS;
PixelShader = PS_Outlines;
}
}
#line 112
technique MatCap_Experimental {
pass {
VertexShader = PostProcessVS;
PixelShader = PS_Experimental;
}
}

