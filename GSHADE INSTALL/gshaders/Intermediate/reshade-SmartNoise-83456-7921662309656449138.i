#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\SmartNoise.fx"
#line 15
uniform float noise <
ui_type = "slider";
ui_min = 0.0; ui_max = 4.0;
ui_label = "Amount of noise";
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
#line 24 "C:\Program Files\GShade\gshade-shaders\Shaders\SmartNoise.fx"
#line 25
static const float PHI = 1.61803398874989484820459 * 00000.1; 
static const float PI  = 3.14159265358979323846264 * 00000.1; 
static const float SQ2 = 1.41421356237309504880169 * 10000.0; 
#line 29
float gold_noise(float2 coordinate, float seed){
return frac(tan(distance(coordinate*(seed+PHI), float2(PHI, PI)))*SQ2);
}
#line 33
float3 SmartNoise(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float amount = noise * 0.08;
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 39
const float luminance = (0.2126 * color.r) + (0.7152 * color.g) + (0.0722 * color.b);
#line 42
if (luminance < 0.5){
amount *= (luminance / 0.5);
} else {
amount *= ((1.0 - luminance) / 0.5);
}
#line 49
const float redDiff = color.r - ((color.g + color.b) / 2.0);
if (redDiff > 0.0){
amount *= (1.0 - (redDiff * 0.5));
}
#line 55
float sub = (0.5 * amount);
#line 58
if (luminance - sub < 0.0){
amount *= (luminance / sub);
sub *= (luminance / sub);
} else if (luminance + sub > 1.0){
if (luminance > sub){
amount *= (sub / luminance);
sub *= (sub / luminance);
} else {
amount *= (luminance / sub);
sub *= (luminance / sub);
}
}
#line 76
return color + ((gold_noise(texcoord * float2(1920, 1018).y * 2.0, ((luminance * float2(1920, 1018).y) + (float2(1920, 1018).x * texcoord.y) + texcoord.x + ReShade::GetLinearizedDepth(texcoord) * float2(1920, 1018).y) * 0.0001) * amount) - sub);
}
#line 79
technique SmartNoise
{
pass
{
VertexShader = PostProcessVS;
PixelShader  = SmartNoise;
}
}

