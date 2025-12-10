#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmGrain2.fx"
#line 11
uniform float grainamount <
ui_type = "slider";
ui_min = 0.0; ui_max = 0.2;
ui_label = "Amount";
> = 0.05;
uniform float coloramount <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Color Amount";
> = 0.6;
uniform float lumamount <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Luminance Amount";
> = 1.0;
#line 27
uniform float grainsize <
ui_type = "slider";
ui_min = 1.5; ui_max = 2.5;
ui_label = "Grain Particle Size";
> = 1.6;
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmGrain2.fx"
#line 35
uniform float timer < source = "timer"; >;
#line 37
float4 rnm(in float2 tc)
{
#line 40
float noise = sin(dot(tc, float2(12.9898, 78.233))) * 43758.5453;
#line 42
float noiseR = frac(noise) * 2.0 - 1.0;
float noiseG = frac(noise * 1.2154) * 2.0 - 1.0;
float noiseB = frac(noise * 1.3453) * 2.0 - 1.0;
float noiseA = frac(noise * 1.3647) * 2.0 - 1.0;
#line 47
return float4(noiseR, noiseG, noiseB, noiseA);
}
float pnoise3D(in float3 p)
{
#line 52
static const float permTexUnit = 1.0 / 256.0;
#line 54
static const float permTexUnitHalf = 0.5 / 256.0;
#line 58
float3 pi = permTexUnit * floor(p) + permTexUnitHalf;
#line 60
float3 pf = frac(p);
#line 63
float perm00 = rnm(pi.xy).a;
float3 grad000 = rnm(float2(perm00, pi.z)).rgb * 4.0 - 1.0;
float n000 = dot(grad000, pf);
float3 grad001 = rnm(float2(perm00, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
float n001 = dot(grad001, pf - float3(0.0, 0.0, 1.0));
#line 70
float perm01 = rnm(pi.xy + float2(0.0, permTexUnit)).a;
float3 grad010 = rnm(float2(perm01, pi.z)).rgb * 4.0 - 1.0;
float n010 = dot(grad010, pf - float3(0.0, 1.0, 0.0));
float3 grad011 = rnm(float2(perm01, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
float n011 = dot(grad011, pf - float3(0.0, 1.0, 1.0));
#line 77
float perm10 = rnm(pi.xy + float2(permTexUnit, 0.0)).a;
float3 grad100 = rnm(float2(perm10, pi.z)).rgb * 4.0 - 1.0;
float n100 = dot(grad100, pf - float3(1.0, 0.0, 0.0));
float3 grad101 = rnm(float2(perm10, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
float n101 = dot(grad101, pf - float3(1.0, 0.0, 1.0));
#line 84
float perm11 = rnm(pi.xy + float2(permTexUnit, permTexUnit)).a;
float3 grad110 = rnm(float2(perm11, pi.z)).rgb * 4.0 - 1.0;
float n110 = dot(grad110, pf - float3(1.0, 1.0, 0.0));
float3 grad111 = rnm(float2(perm11, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
float n111 = dot(grad111, pf - float3(1.0, 1.0, 1.0));
#line 91
float fade_x = pf.x * pf.x * pf.x * (pf.x * (pf.x * 6.0 - 15.0) + 10.0);
float4 n_x = lerp(float4(n000, n001, n010, n011), float4(n100, n101, n110, n111), fade_x);
#line 95
float fade_y = pf.y * pf.y * pf.y * (pf.y * (pf.y * 6.0 - 15.0) + 10.0);
float2 n_xy = lerp(n_x.xy, n_x.zw, fade_y);
#line 99
float fade_z = pf.z * pf.z * pf.z * (pf.z * (pf.z * 6.0 - 15.0) + 10.0);
float n_xyz = lerp(n_xy.x, n_xy.y, fade_z);
#line 103
return n_xyz;
}
#line 106
float2 coordRot(in float2 tc, in float angle)
{
float rotX = ((tc.x * 2.0 - 1.0) * (1920 * (1.0 / 1018)) * cos(angle)) - ((tc.y * 2.0 - 1.0) * sin(angle));
float rotY = ((tc.y * 2.0 - 1.0) * cos(angle)) + ((tc.x * 2.0 - 1.0) * (1920 * (1.0 / 1018)) * sin(angle));
rotX = ((rotX / (1920 * (1.0 / 1018))) * 0.5 + 0.5);
rotY = rotY * 0.5 + 0.5;
#line 113
return float2(rotX, rotY);
}
#line 116
float4 main(float4 vpos : SV_Position, float2 texCoord : TexCoord) : SV_Target
{
float3 rotOffset = float3(1.425, 3.892, 5.835); 
float2 rotCoordsR = coordRot(texCoord, timer + rotOffset.x);
float3 noise = pnoise3D(float3(rotCoordsR * float2(1920, 1018) / grainsize, 0.0)).xxx;
#line 122
if (coloramount > 0)
{
float2 rotCoordsG = coordRot(texCoord, timer + rotOffset.y);
float2 rotCoordsB = coordRot(texCoord, timer + rotOffset.z);
noise.g = lerp(noise.r, pnoise3D(float3(rotCoordsG * float2(1920, 1018) / grainsize, 1.0)), coloramount);
noise.b = lerp(noise.r, pnoise3D(float3(rotCoordsB * float2(1920, 1018) / grainsize, 2.0)), coloramount);
}
#line 130
float3 col = tex2D(ReShade::BackBuffer, texCoord).rgb;
#line 132
const float3 lumcoeff = float3(0.299, 0.587, 0.114);
float luminance = lerp(0.0, dot(col, lumcoeff), lumamount);
float lum = smoothstep(0.2, 0.0, luminance);
lum += luminance;
#line 138
noise = lerp(noise, 0.0, pow(lum, 4.0));
col = col + noise * grainamount;
#line 141
return float4(col, 1.0);
}
#line 144
technique FilmGrain2
{
pass
{
VertexShader = PostProcessVS;
PixelShader = main;
}
}

