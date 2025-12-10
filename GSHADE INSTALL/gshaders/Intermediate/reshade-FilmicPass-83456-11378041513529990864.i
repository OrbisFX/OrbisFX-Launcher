#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicPass.fx"
#line 8
uniform float Strength <
ui_type = "slider";
ui_min = 0.05; ui_max = 1.5;
ui_toolip = "Strength of the color curve altering";
> = 0.85;
#line 14
uniform float Fade <
ui_type = "slider";
ui_min = 0.0; ui_max = 0.6;
ui_tooltip = "Decreases contrast to imitate faded image";
> = 0.4;
uniform float Contrast <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
> = 1.0;
uniform float Linearization <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
> = 0.5;
uniform float Bleach <
ui_type = "slider";
ui_min = -0.5; ui_max = 1.0;
ui_tooltip = "More bleach means more contrasted and less colorful image";
> = 0.0;
uniform float Saturation <
ui_type = "slider";
ui_min = -1.0; ui_max = 1.0;
> = -0.15;
#line 37
uniform float RedCurve <
ui_type = "slider";
ui_min = 0.001; ui_max = 2.0;
> = 1.0;
uniform float GreenCurve <
ui_type = "slider";
ui_min = 0.001; ui_max = 2.0;
> = 1.0;
uniform float BlueCurve <
ui_type = "slider";
ui_min = 0.001; ui_max = 2.0;
> = 1.0;
uniform float BaseCurve <
ui_type = "slider";
ui_min = 0.001; ui_max = 2.0;
> = 1.5;
#line 54
uniform float BaseGamma <
ui_type = "slider";
ui_min = 0.7; ui_max = 2.0;
ui_tooltip = "Gamma Curve";
> = 1.0;
uniform float EffectGamma <
ui_type = "slider";
ui_min = 0.001; ui_max = 2.0;
> = 0.65;
uniform float EffectGammaR <
ui_type = "slider";
ui_min = 0.001; ui_max = 2.0;
> = 1.0;
uniform float EffectGammaG <
ui_type = "slider";
ui_min = 0.001; ui_max = 2.0;
> = 1.0;
uniform float EffectGammaB <
ui_type = "slider";
ui_min = 0.001; ui_max = 2.0;
> = 1.0;
#line 76
uniform float3 LumCoeff <
> = float3(0.212656, 0.715158, 0.072186);
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
#line 80 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicPass.fx"
#line 85
float3 FilmPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 B = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 89
B = saturate(B);
B = pow(B, Linearization);
B = lerp(0.01, B, Contrast);
#line 93
float3 D = dot(B.rgb, LumCoeff);
#line 95
B = pow(abs(B), 1.0 / BaseGamma);
#line 97
const float y = 1.0 / (1.0 + exp(RedCurve / 2.0));
const float z = 1.0 / (1.0 + exp(GreenCurve / 2.0));
const float w = 1.0 / (1.0 + exp(BlueCurve / 2.0));
const float v = 1.0 / (1.0 + exp(BaseCurve / 2.0));
#line 102
float3 C = B;
#line 104
D.r = (1.0 / (1.0 + exp(-RedCurve * (D.r - 0.5))) - y) / (1.0 - 2.0 * y);
D.g = (1.0 / (1.0 + exp(-GreenCurve * (D.g - 0.5))) - z) / (1.0 - 2.0 * z);
D.b = (1.0 / (1.0 + exp(-BlueCurve * (D.b - 0.5))) - w) / (1.0 - 2.0 * w);
#line 108
D = pow(abs(D), 1.0 / EffectGamma);
#line 110
D = lerp(D, 1.0 - D, Bleach);
#line 112
D.r = pow(abs(D.r), 1.0 / EffectGammaR);
D.g = pow(abs(D.g), 1.0 / EffectGammaG);
D.b = pow(abs(D.b), 1.0 / EffectGammaB);
#line 116
if (D.r < 0.5)
C.r = (2.0 * D.r - 1.0) * (B.r - B.r * B.r) + B.r;
else
C.r = (2.0 * D.r - 1.0) * (sqrt(B.r) - B.r) + B.r;
#line 121
if (D.g < 0.5)
C.g = (2.0 * D.g - 1.0) * (B.g - B.g * B.g) + B.g;
else
C.g = (2.0 * D.g - 1.0) * (sqrt(B.g) - B.g) + B.g;
#line 126
if (D.b < 0.5)
C.b = (2.0 * D.b - 1.0) * (B.b - B.b * B.b) + B.b;
else
C.b = (2.0 * D.b - 1.0) * (sqrt(B.b) - B.b) + B.b;
#line 131
float3 F = lerp(B, C, Strength);
#line 133
F = (1.0 / (1.0 + exp(-BaseCurve * (F - 0.5))) - v) / (1.0 - 2.0 * v);
#line 135
const float r2R = 1.0 - Saturation;
const float g2R = 0.0 + Saturation;
const float b2R = 0.0 + Saturation;
#line 139
const float r2G = 0.0 + Saturation;
const float g2G = (1.0 - Fade) - Saturation;
const float b2G = (0.0 + Fade) + Saturation;
#line 143
const float r2B = 0.0 + Saturation;
const float g2B = (0.0 + Fade) + Saturation;
const float b2B = (1.0 - Fade) - Saturation;
#line 147
float3 iF = F;
#line 149
F.r = (iF.r * r2R + iF.g * g2R + iF.b * b2R);
F.g = (iF.r * r2G + iF.g * g2G + iF.b * b2G);
F.b = (iF.r * r2B + iF.g * g2B + iF.b * b2B);
#line 153
const float N = dot(F.rgb, LumCoeff);
float3 Cn;
#line 156
if (N < 0.5)
Cn = (2.0 * N - 1.0) * (F - F * F) + F;
else
Cn = (2.0 * N - 1.0) * (sqrt(F) - F) + F;
#line 161
Cn = pow(max(Cn,0), 1.0 / Linearization);
#line 167
return lerp(B, Cn, Strength);
#line 169
}
#line 171
technique FilmicPass
{
pass
{
VertexShader = PostProcessVS;
PixelShader = FilmPass;
}
}

