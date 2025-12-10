#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReflectiveBumpMapping.fx"
#line 11
uniform float fRBM_BlurWidthPixels <
ui_type = "slider";
ui_min = 0.0; ui_max = 400.00;
ui_step = 1;
ui_tooltip = "Controls how far the reflections spread. If you get repeating artifacts, lower this or raise sample count.";
> = 100.0;
#line 18
uniform int iRBM_SampleCount <
ui_type = "slider";
ui_min = 16; ui_max = 128;
ui_tooltip = "Controls how many glossy reflection samples are taken. Raise this if you get repeating artifacts. Performance hit.";
> = 32;
#line 24
uniform float fRBM_ReliefHeight <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.00;
ui_tooltip = "Controls how intensive the relief on surfaces is. 0.0 means mirror-like reflections.";
> = 0.3;
#line 30
uniform float fRBM_FresnelReflectance <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_tooltip = "The lower this value, the lower the view to surface angle has to be to get significant reflection. 1.0 means every surface has 100% gloss.";
> = 0.3;
#line 36
uniform float fRBM_FresnelMult <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_tooltip = "Not physically accurate at all: multiplier of reflection intensity at lowest view-surface angle.";
> = 0.5;
#line 42
uniform float  fRBM_LowerThreshold <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_tooltip = "Anything darker than this does not get reflected at all. Reflection power increases linearly from lower to upper threshold. ";
> = 0.1;
#line 48
uniform float  fRBM_UpperThreshold <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_tooltip = "Anything brighter than this contributes fully to reflection. Reflection power increases linearly from lower to upper threshold. ";
> = 0.2;
#line 54
uniform float  fRBM_ColorMask_Red <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_tooltip = "Reflection mult on red surfaces.Lower this to remove reflections from red surfaces.";
> = 1.0;
#line 60
uniform float  fRBM_ColorMask_Orange <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_tooltip = "Reflection mult on orange surfaces. Lower this to remove reflections from orange surfaces.";
> = 1.0;
#line 66
uniform float  fRBM_ColorMask_Yellow <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_tooltip = "Reflection mult on yellow surfaces. Lower this to remove reflections from yellow surfaces.";
> = 1.0;
#line 72
uniform float  fRBM_ColorMask_Green <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_tooltip = "Reflection mult on green surfaces. Lower this to remove reflections from green surfaces.";
> = 1.0;
#line 78
uniform float  fRBM_ColorMask_Cyan <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_tooltip = "Reflection mult on cyan surfaces. Lower this to remove reflections from cyan surfaces.";
> = 1.0;
#line 84
uniform float  fRBM_ColorMask_Blue <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_tooltip = "Reflection mult on blue surfaces. Lower this to remove reflections from blue surfaces.";
> = 1.0;
#line 90
uniform float  fRBM_ColorMask_Magenta <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.00;
ui_tooltip = "Reflection mult on magenta surfaces. Lower this to remove reflections from magenta surfaces.";
> = 1.0;
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
#line 101 "C:\Program Files\GShade\gshade-shaders\Shaders\ReflectiveBumpMapping.fx"
#line 105
float GetLinearDepth(float2 coords)
{
return ReShade::GetLinearizedDepth(coords);
}
#line 110
float3 GetPosition(float2 coords)
{
float EyeDepth = GetLinearDepth(coords.xy)*1000.0;
return float3((coords.xy * 2.0 - 1.0)*EyeDepth,EyeDepth);
}
#line 116
float3 GetNormalFromDepth(float2 coords)
{
const float3 centerPos = GetPosition(coords.xy);
const float2 offs = float2((1.0 / 1920), (1.0 / 1018))*1.0;
float3 ddx1 = GetPosition(coords.xy + float2(offs.x, 0)) - centerPos;
const float3 ddx2 = centerPos - GetPosition(coords.xy + float2(-offs.x, 0));
#line 123
float3 ddy1 = GetPosition(coords.xy + float2(0, offs.y)) - centerPos;
const float3 ddy2 = centerPos - GetPosition(coords.xy + float2(0, -offs.y));
#line 126
ddx1 = lerp(ddx1, ddx2, abs(ddx1.z) > abs(ddx2.z));
ddy1 = lerp(ddy1, ddy2, abs(ddy1.z) > abs(ddy2.z));
#line 129
return normalize(cross(ddy1, ddx1));
}
#line 132
float3 GetNormalFromColor(float2 coords, float2 offset, float scale, float sharpness)
{
const float3 lumCoeff = float3(0.299,0.587,0.114);
#line 136
const float hpx = dot(tex2Dlod(ReShade::BackBuffer, float4(coords + float2(offset.x,0.0),0,0)).xyz,lumCoeff) * scale;
const float hmx = dot(tex2Dlod(ReShade::BackBuffer, float4(coords - float2(offset.x,0.0),0,0)).xyz,lumCoeff) * scale;
const float hpy = dot(tex2Dlod(ReShade::BackBuffer, float4(coords + float2(0.0,offset.y),0,0)).xyz,lumCoeff) * scale;
const float hmy = dot(tex2Dlod(ReShade::BackBuffer, float4(coords - float2(0.0,offset.y),0,0)).xyz,lumCoeff) * scale;
#line 141
const float dpx = GetLinearDepth(coords + float2(offset.x,0.0));
const float dmx = GetLinearDepth(coords - float2(offset.x,0.0));
const float dpy = GetLinearDepth(coords + float2(0.0,offset.y));
const float dmy = GetLinearDepth(coords - float2(0.0,offset.y));
#line 146
float2 xymult = float2(abs(dmx - dpx), abs(dmy - dpy)) * sharpness;
xymult = saturate(1.0 - xymult);
#line 149
const float ddx = (hmx - hpx) / (2.0 * offset.x) * xymult.x;
const float ddy = (hmy - hpy) / (2.0 * offset.y) * xymult.y;
#line 152
return normalize(float3(ddx, ddy, 1.0));
}
#line 155
float3 GetBlendedNormals(float3 n1, float3 n2)
{
return normalize(float3(n1.xy*n2.z + n2.xy*n1.z, n1.z*n2.z));
}
#line 160
float3 RGB2HSV(float3 RGB)
{
const float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
#line 164
float4 p;
if (RGB.g < RGB.b)
p = float4(RGB.bg, K.wz);
else
p = float4(RGB.gb, K.xy);
#line 170
float4 q;
if (RGB.r < p.x)
q = float4(p.xyw, RGB.r);
else
q = float4(RGB.r, p.yzx);
#line 176
const float d = q.x - min(q.w, q.y);
const float e = 1.0e-10;
return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
#line 181
float3 HSV2RGB(float3 HSV)
{
const float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
const float3 p = abs(frac(HSV.xxx + K.xyz) * 6.0 - K.www);
return HSV.z * lerp(K.xxx, saturate(p - K.xxx), HSV.y); 
}
#line 188
float GetHueMask(in float H)
{
float SMod = 0.0;
SMod += fRBM_ColorMask_Red * ( 1.0 - min( 1.0, abs( H / 0.08333333 ) ) );
SMod += fRBM_ColorMask_Orange * ( 1.0 - min( 1.0, abs( ( 0.08333333 - H ) / ( - 0.08333333 ) ) ) );
SMod += fRBM_ColorMask_Yellow * ( 1.0 - min( 1.0, abs( ( 0.16666667 - H ) / ( - 0.16666667 ) ) ) );
SMod += fRBM_ColorMask_Green * ( 1.0 - min( 1.0, abs( ( 0.33333333 - H ) / 0.16666667 ) ) );
SMod += fRBM_ColorMask_Cyan * ( 1.0 - min( 1.0, abs( ( 0.5 - H ) / 0.16666667 ) ) );
SMod += fRBM_ColorMask_Blue * ( 1.0 - min( 1.0, abs( ( 0.66666667 - H ) / 0.16666667 ) ) );
SMod += fRBM_ColorMask_Magenta * ( 1.0 - min( 1.0, abs( ( 0.83333333 - H ) / 0.16666667 ) ) );
SMod += fRBM_ColorMask_Red * ( 1.0 - min( 1.0, abs( ( 1.0 - H ) / 0.16666667 ) ) );
return SMod;
}
#line 206
void PS_RBM_Gen(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 res : SV_Target0)
{
const float scenedepth 		= GetLinearDepth(texcoord.xy);
float3 SurfaceNormals 		= GetNormalFromDepth(texcoord.xy).xyz;
const float3 TextureNormals 		= GetNormalFromColor(texcoord.xy, 0.01 * float2((1.0 / 1920), (1.0 / 1018)) / scenedepth, 0.0002 / scenedepth + 0.1, 1000.0);
float3 SceneNormals		= GetBlendedNormals(SurfaceNormals, TextureNormals);
SceneNormals 			= normalize(lerp(SurfaceNormals,SceneNormals,fRBM_ReliefHeight));
const float3 ScreenSpacePosition 	= GetPosition(texcoord.xy);
const float3 ViewDirection 		= normalize(ScreenSpacePosition.xyz);
#line 216
float4 color = tex2D(ReShade::BackBuffer, texcoord.xy);
float3 bump = 0.0;
#line 219
for(float i=1; i<=iRBM_SampleCount; i++)
{
const float2 currentOffset 	= texcoord.xy + SceneNormals.xy * float2((1.0 / 1920), (1.0 / 1018)) * i/(float)iRBM_SampleCount * fRBM_BlurWidthPixels;
const float4 texelSample 	= tex2Dlod(ReShade::BackBuffer, float4(currentOffset,0,0));
#line 224
const float depthDiff 	= smoothstep(0.005,0.0,scenedepth-GetLinearDepth(currentOffset));
const float colorWeight 	= smoothstep(fRBM_LowerThreshold,fRBM_UpperThreshold+0.00001,dot(texelSample.xyz,float3(0.299,0.587,0.114)));
bump += lerp(color.xyz,texelSample.xyz,depthDiff*colorWeight);
}
#line 229
bump /= iRBM_SampleCount;
#line 231
const float cosphi = dot(-ViewDirection, SceneNormals);
#line 233
float SchlickReflectance = lerp(pow(1.0-cosphi,5.0), 1.0, fRBM_FresnelReflectance);
SchlickReflectance = saturate(SchlickReflectance)*fRBM_FresnelMult; 
#line 236
const float3 hsvcol = RGB2HSV(color.xyz);
float colorMask = GetHueMask(hsvcol.x);
colorMask = lerp(1.0,colorMask, smoothstep(0.0,0.2,hsvcol.y) * smoothstep(0.0,0.1,hsvcol.z));
color.xyz = lerp(color.xyz,bump.xyz,SchlickReflectance*colorMask);
#line 241
res.xyz = color.xyz;
res.w = 1.0;
#line 244
}
#line 250
technique ReflectiveBumpmapping
{
pass P1
{
VertexShader = PostProcessVS;
PixelShader  = PS_RBM_Gen;
}
}

