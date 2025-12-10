// OILIFY_ITERATIONS=1
// OILIFY_SIZE=7
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Oilify.fx"
#line 35
static const float PI = 3.1415926536;
static const float GAUSSIAN_WEIGHTS[5] = {0.095766,	0.303053,	0.20236,	0.303053,	0.095766};
static const float GAUSSIAN_OFFSETS[5] = {-3.2979345488, -1.40919905099, 0, 1.40919905099, 3.2979345488};
#line 39
namespace Oilify
{
texture BackBuffer : COLOR;
texture Anisotropy {Width = 1920; Height = 1018; Format = RGBA16f;};
#line 44
sampler sBackBuffer{Texture = BackBuffer;};
sampler sAnisotropy{Texture = Anisotropy;};
#line 47
uniform float Sharpness<
ui_type = "slider";
ui_label = "Sharpness";
ui_tooltip = "Higher settings result in a sharper image, while lower values give the\n"
"image a more simplified look.";
ui_min = 0; ui_max = 1;
ui_step = 0.001;
> = 1;
#line 56
uniform float Tuning<
ui_type = "slider";
ui_label = "Anistropy Tuning";
ui_tooltip = "Adjusts how elliptical the sampling can become with anisotropy\n"
"Smaller numbers mean more elliptical. (Use this if the shader looks stretched)";
ui_min = 0; ui_max = 4;
> = 2;
#line 64
uniform float Scale<
ui_type = "slider";
ui_label = "Scale";
ui_tooltip = "Similar to size it raises the range the effect is applied over, \n"
"however, the number of samples remains unchanged resulting in a less, \n"
"detailed image.";
ui_min = 1; ui_max = 4;
> = 1;
#line 74
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 81
void AnisotropyPS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD, out float4 anisotropyData : SV_TARGET0)
{
float3 center = tex2D(sBackBuffer, texcoord).rgb * 255;
float3 dx = center * GAUSSIAN_WEIGHTS[2];
float3 dy = dx;
#line 87
[unroll]
for(int i = 0; i < 5; i++)
{
if (i == 2) i++;
float3 offsets = float3((1.0 / 1920), (1.0 / 1018), 0) * GAUSSIAN_OFFSETS[i];
dx += tex2D(sBackBuffer, texcoord + offsets.xz).rgb * GAUSSIAN_WEIGHTS[i] * 255;
dy += tex2D(sBackBuffer, texcoord + offsets.zy).rgb * GAUSSIAN_WEIGHTS[i] * 255;
}
dx = ddx(dx);
dy = ddy(dy);
#line 98
float e = dot(dx, dx);
float f = dot(dx, dy);
float g = dot(dy, dy);
float root = sqrt((e-g) * (e-g) + 4 * f * f);
float2 eigenvalues = float2(e + g + root, e + g - root) / 2;
#line 104
float2 t;
[flatten]
if(any(abs(float2(eigenvalues.x - e, -f)) > 1e-15))
{
t = (normalize((float2(eigenvalues.x - e, -f))));
}
else
t = float2(1, 0);
#line 113
float anisotropy = abs((eigenvalues.y - eigenvalues.x) / (eigenvalues.x + eigenvalues.y));
anisotropy *= anisotropy;
anisotropy = saturate(anisotropy);
anisotropy = max(anisotropy, 1e-15);
anisotropyData.xyz = float3(t, anisotropy);
anisotropyData.w = 1;
}
#line 122
void KuwaharaPS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD, out float3 kuwahara : SV_TARGET0)
{
float sharpnessMultiplier = max(1023 * pow(( 2 * Sharpness / 3) + 0.333333, 4), 1e-10);
float3 sum[6];
float3 squaredSum[6];
float gaussianSum[6];
float sampleCount[6];
#line 130
float radius = length(float2((float(7) / 2), (float(7) / 4)));
#line 132
float3 anistropyData = tex2D(sAnisotropy, texcoord).xyz;
float2 t = anistropyData.xy;
float anisotropy = anistropyData.z;
float tuning = exp2(Tuning - 1);
float2x2 tuningMatrix = float2x2(tuning / (anisotropy + tuning), 0,
0, (tuning + anisotropy) / tuning);
float2x2 rotationMatrix = float2x2(t.x, -t.y, t.y, t.x);
float2x2 offsetMatrix = mul(rotationMatrix, tuningMatrix);
[unroll]
for(int i = -(7 / 2); i < ((7 + 1) / 2); i++)
{
[unroll]
for(int j = -(7 / 2); j < ((7 + 1) / 2); j++)
{
float2 offset = float2(i, j);
if(abs(j) % 2 != 0)
{
offset.y -= 0.5;
}
#line 152
if(all(int2(i, j) == 0))
{
[unroll]
for(int k = 0; k < 6; k++)
{
float3 color = tex2D(sBackBuffer, texcoord).rgb * sharpnessMultiplier;
sum[k] += color;
squaredSum[k] += color * color;
sampleCount[k]++;
}
}
else if(length(offset) <= radius)
{
float angle = atan2(offset.x, offset.y) + PI;
if(angle > 5.75958653158)
{
angle -= 2 * PI;
}
float sectorOffset = (float((angle * 6) / PI) + 1) / 2;
int sector = floor(sectorOffset);
sectorOffset -= float(sector);
offset *= float2((1.0 / 1920), (1.0 / 1018)) * Scale;
offset = mul(offset, offsetMatrix);
float3 color = tex2D(sBackBuffer, texcoord + offset).rgb * sharpnessMultiplier;
sum[sector] += color;
squaredSum[sector] += color * color;
sampleCount[sector]++;
}
}
}
#line 183
float3 weightedSum = 0;
float3 weightSum = 0;
[unroll]
for(int i = 0; i < 6; i++)
{
float3 sumSquared = sum[i] * sum[i];
float3 mean = sum[i] / sampleCount[i];
float3 variance = (squaredSum[i] - ((sumSquared) / sampleCount[i]));
variance /= sampleCount[0];
float3 weight = 1 / (1 + pow(sqrt(max(dot(variance, float3(0.299, 0.587, 0.114)), 1e-5)), 8));
weightedSum += mean * weight;
weightSum += weight;
}
kuwahara = ((weightedSum) / weightSum) / sharpnessMultiplier;
#line 200
}
#line 202
technique Oilify<ui_tooltip = "Oilify is a revised version of the anisotropic kuwahara filter,\n"
"which is used to create a painterly effect.\n\n"
"Part of Insane Shaders\n"
"By: Lord of Lunacy\n\n"
"OILIFY_SIZE: Changes the size of the filter used.\n"
"OILIFY_ITERATIONS: Ranges from 1 to 8.";>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = AnisotropyPS;
RenderTarget0 = Anisotropy;
}
#line 216
pass
{
VertexShader = PostProcessVS;
PixelShader = KuwaharaPS;
}
#line 242
}
}

