#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MC_SSAO.fx"
#line 29
uniform float Strength <
ui_type = "slider";
ui_min = 0.0; ui_max = 16.0; ui_step = 0.1;
ui_tooltip = "Strength of the effect (recommended 1.0 to 2.0)";
ui_label = "Strength";
> = 1.4;
#line 36
uniform int SampleDistance <
ui_type = "slider";
ui_min = 1; ui_max = 64;
ui_tooltip = "Sampling disk radius (in pixels)\nrecommended: 32";
ui_label = "Sampling disk radius";
> = 32.0;
#line 43
uniform int Quality <
ui_type = "combo";
ui_label = "Total number of samples";
ui_tooltip = "Higher numbers yield better quality at the cost of performance\nrecommended: 8";
ui_items = "Samples: 4\0Samples: 8\0Samples: 16\0Samples: 24\0Samples: 32\0Samples: 36\0Samples: 48\0Samples: 64\0";
> = 1;
#line 50
uniform float StartFade <
ui_type = "slider";
ui_min = 0.0; ui_max = 300.0; ui_step = 0.1;
ui_tooltip = "AO starts fading when Z difference is greater than this\nmust be bigger than \"Z difference end fade\"\nrecommended: 0.4";
ui_label = "Z difference start fade";
> = 0.4;
#line 57
uniform float EndFade <
ui_type = "slider";
ui_min = 0.0; ui_max = 300.0; ui_step = 0.1;
ui_tooltip = "AO completely fades when Z difference is greater than this\nmust be bigger than \"Z difference start fade\"\nrecommended: 0.6";
ui_label = "Z difference end fade";
> = 0.6;
#line 64
uniform float NormalBias <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0; ui_step = 0.025;
ui_tooltip = "prevents self occlusion (recommended 0.1)";
ui_label = "Normal bias";
> = 0.1;
#line 71
uniform int DebugEnabled <
ui_type = "combo";
ui_label = "Enable Debug View";
ui_items = "Disabled\0Blurred\0Before Blur\0";
> = 0;
#line 77
uniform int Bilateral <
ui_type = "combo";
ui_label = "Fake bilateral filter\nrecommended: \"Disabled\" for max performance, \"Horizontal first\" for better quality";
ui_items = "Disabled (cheaper, more blurry)\0Vertical first\0Horizontal first\0";
> = 2;
#line 83
uniform int BlurRadius <
ui_type = "slider";
ui_min = 1.0; ui_max = 32.0;
ui_tooltip = "Blur radius (in pixels)\nrecommended: 3 or 4";
ui_label = "Blur radius";
> = 3.0;
#line 90
uniform float BlurQuality <
ui_type = "slider";
ui_min = 0.5; ui_max = 1.0; ui_step = 0.1;
ui_label = "Blur Quality";
ui_tooltip = "Blur quality (recommended 0.6)";
> = 0.6;
#line 97
uniform float Gamma <
ui_type = "slider";
ui_min = 1.0; ui_max = 4.0; ui_step = 0.1;
ui_label = "Gamma";
ui_tooltip = "Recommended 2.2\n(assuming the texture is stored with gamma applied)";
> = 2.2;
#line 104
uniform float NormalPower <
ui_type = "slider";
ui_min = 0.5; ui_max = 8.0; ui_step = 0.1;
ui_label = "Normal power";
ui_tooltip = "Acts like softer version of normal bias without a threshold\nrecommended: 1.4";
> = 1.4;
#line 111
uniform int FOV <
ui_type = "slider";
ui_min = 40; ui_max = 180; ui_step = 1.0;
ui_label = "FOV";
ui_tooltip = "Leaving it at 90 regardless of your actual FOV provides accetable results";
> = 90;
#line 118
uniform float DepthShrink <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0; ui_step = 0.05;
ui_label = "Depth shrink";
ui_tooltip = "Higher values cause AO to become finer on distant objects\nrecommended: 0.65";
> = 0.65;
#line 137
uniform int DepthEndFade <
ui_type = "slider";
ui_min = 0; ui_max = 4000;
ui_label = "Depth end fade";
ui_tooltip = "AO completely fades at this Z value\nrecommended: 1000";
> = 1000;
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
#line 146 "C:\Program Files\GShade\gshade-shaders\Shaders\MC_SSAO.fx"
#line 147
texture2D InterleavedAOTex  { Width = 1920 / 2;   Height = 1018 / 2;   Format = R8; MipLevels = 1;};
texture2D InterleavedAOTex2 { Width = 1920 / 2;   Height = 1018 / 2;   Format = R8; MipLevels = 1;};
texture2D InterleavedAOTex3 { Width = 1920 / 2;   Height = 1018 / 2;   Format = R8; MipLevels = 1;};
texture2D InterleavedAOTex4 { Width = 1920 / 2;   Height = 1018 / 2;   Format = R8; MipLevels = 1;};
#line 152
texture2D MCAOTex	{ Width = 1920;   Height = 1018;   Format = R8; MipLevels = 1;};
texture2D MCAOTex2	{ Width = 1920;   Height = 1018;   Format = R8; MipLevels = 1;};
texture2D MCNormalTex	{ Width = 1920;   Height = 1018;   Format = RGBA8; MipLevels = 1;};
#line 156
sampler2D sAOTex { Texture = MCAOTex; };
sampler2D sAOTex2 { Texture = MCAOTex2; };
sampler2D sInterleavedAOTex { Texture = InterleavedAOTex; };
sampler2D sInterleavedAOTex2 { Texture = InterleavedAOTex2; };
sampler2D sInterleavedAOTex3 { Texture = InterleavedAOTex3; };
sampler2D sInterleavedAOTex4 { Texture = InterleavedAOTex4; };
sampler2D sNormalTex { Texture = MCNormalTex; };
#line 164
float GetTrueDepth(float2 coords)
{
return ReShade::GetLinearizedDepth(coords) * 1000.0;
}
#line 169
float3 GetPosition(float2 coords)
{
float2 fov;
fov.x = FOV / 180.0 * 3.1415;
fov.y = fov.x / (1920 * (1.0 / 1018));
float3 pos;
pos.z = GetTrueDepth(coords.xy);
coords.y = 1.0 - coords.y;
pos.xy = coords.xy * 2.0 - 1.0;
pos.xy /= float2(1.0 / tan(fov.x * 0.5), 1.0 / tan(fov.y * 0.5)) / pos.z;
return pos;
}
#line 182
float4 GetNormalFromDepth(float2 coords)
{
const float3 centerPos = GetPosition(coords);
#line 186
const float2 offx = float2(float2((1.0 / 1920), (1.0 / 1018)).x, 0);
const float2 offy = float2(0, float2((1.0 / 1920), (1.0 / 1018)).y);
#line 189
return float4(normalize(cross((GetPosition(coords + offx) - centerPos) + (centerPos - GetPosition(coords - offx)), (GetPosition(coords + offy) - centerPos) + (centerPos - GetPosition(coords - offy)))), centerPos.z);
}
#line 192
float4 GetNormalFromTexture(float2 coords)
{
float4 normal = tex2Dlod(sNormalTex, float4(coords, 0.0, 0.0));
normal.xyz = normal.xyz * 2.0 - float3(1,1,1);
return normal;
}
#line 199
float4 DepthNormalsPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float4 normal = GetNormalFromDepth(texcoord);
normal.xyz = normal.xyz * 0.5 + 0.5;
return normal;
}
#line 206
float rand2D(float2 uv){
uv = frac(uv);
return frac(cos((frac(cos(uv.x*64)*256)+frac(cos(uv.y*137)*241))*107)*269);
}
#line 211
float BlurAOFirstPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
if (clamp(DebugEnabled, 0, 2) == 2)
{
return tex2D(sAOTex, texcoord).r;
}
#line 218
const float normal_bias = clamp(NormalBias, 0.0, 1.0);
const int bilateral = clamp(Bilateral, 0, 2);
#line 221
float range = clamp(BlurRadius, 1, 32);
const float fade_range = EndFade - StartFade;
#line 224
const float tmp = 1.0 / (range * range);
float gauss = 1.0;
float helper = exp(tmp * 0.5);
const float helper2 = exp(tmp);
float sum = tex2D(sAOTex, texcoord).r;
float sumCoef = 1.0;
#line 231
range *= 3.0 * clamp(BlurQuality, 0.0, 1.0);
#line 233
float2 off = float2(float2((1.0 / 1920), (1.0 / 1018)).x, 0);
#line 235
float4 my_normal;
#line 237
if (bilateral)
{
my_normal = GetNormalFromTexture(texcoord);
}
#line 242
if (Bilateral == 2)
{
off = float2(0, float2((1.0 / 1920), (1.0 / 1018)).y);
}
#line 247
float weights[32];
weights[0] = 1;
#line 250
[unroll]
for (int i = 1; i < 32; i++)
{
gauss = gauss / helper;
helper = helper * helper2;
weights[i] = gauss;
}
#line 258
[loop]
for(int k = 1; k < range; k++)
{
float weight = weights[abs(k)];
#line 263
if (bilateral)
{
float4 normal = GetNormalFromTexture(texcoord + off * k);
weight *= saturate((dot(my_normal.xyz, normal.xyz) - normal_bias) / (1.0 - normal_bias));
float zdiff = abs(my_normal.w - normal.w);
if (zdiff >= StartFade)
{
float fade = saturate(1.0 - (zdiff - StartFade) / fade_range);
weight *= fade * fade;
}
sum += tex2Dlod(sAOTex, float4(texcoord + off * k, 0.0, 0.0)).r * weight;
sumCoef += weight;
}
else
{
sum += tex2Dlod(sAOTex, float4(texcoord + off * k, 0.0, 0.0)).r * weight;
sumCoef += weight;
}
}
#line 283
[loop]
for(int k = 1; k < range; k++)
{
float weight = weights[abs(k)];
#line 288
if (bilateral)
{
float4 normal = GetNormalFromTexture(texcoord + off * k);
normal *= pow(saturate((dot(my_normal.xyz, normal.xyz) - normal_bias) / (1.0 - normal_bias)), NormalPower);
weight *= max(0.0, dot(my_normal.xyz, normal.xyz));
float zdiff = abs(my_normal.w - normal.w);
if (zdiff >= StartFade)
{
float fade = saturate(1.0 - (zdiff - StartFade) / fade_range);
weight *= fade * fade;
}
sum += tex2Dlod(sAOTex, float4(texcoord - off * k, 0.0, 0.0)).r * weight;
sumCoef += weight;
}
else
{
sum += tex2Dlod(sAOTex, float4(texcoord - off * k, 0.0, 0.0)).r * weight;
sumCoef += weight;
}
}
#line 309
return sum / sumCoef;
}
#line 313
float3 BlurAOSecondPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
int debugEnabled = clamp(DebugEnabled, 0, 2);
if (debugEnabled == 2)
{
return tex2D(sAOTex2, texcoord).r;
}
#line 321
const int bilateral = clamp(Bilateral, 0, 2);
const float normal_bias = clamp(NormalBias, 0.0, 1.0);
#line 324
float range = clamp(BlurRadius, 1, 32);
const float fade_range = EndFade - StartFade;
#line 327
const float tmp = 1.0 / (range * range);
float gauss = 1.0;
float helper = exp(tmp * 0.5);
const float helper2 = exp(tmp);
float sum = tex2D(sAOTex, texcoord).r;
float sumCoef = 1.0;
#line 334
range *= 3.0 * clamp(BlurQuality, 0.0, 1.0);
#line 336
float2 off = float2(0, float2((1.0 / 1920), (1.0 / 1018)).y);
#line 338
float4 my_normal;
#line 340
if (bilateral)
{
my_normal = GetNormalFromTexture(texcoord);
}
#line 345
if (Bilateral == 2)
{
off = float2(float2((1.0 / 1920), (1.0 / 1018)).x, 0);
}
#line 350
float weights[32];
weights[0] = 1;
#line 353
[unroll]
for (int i = 1; i < 32; i++)
{
gauss = gauss / helper;
helper = helper * helper2;
weights[i] = gauss;
}
#line 361
[loop]
for(int k = 1; k < range; k++)
{
float weight = weights[abs(k)];
#line 366
if (bilateral)
{
float4 normal = GetNormalFromTexture(texcoord + off * k);
weight *= max(0.0, dot(my_normal.xyz, normal.xyz));
float zdiff = abs(my_normal.w - normal.w);
zdiff *= zdiff;
if (zdiff >= StartFade)
{
float fade = saturate(1.0 - (zdiff - StartFade) / fade_range);
weight *= fade * fade;
}
sum += tex2Dlod(sAOTex2, float4(texcoord + off * k, 0.0, 0.0)).r * weight;
sumCoef += weight;
}
else
{
sum += tex2Dlod(sAOTex2, float4(texcoord + off * k, 0.0, 0.0)).r * weight;
sumCoef += weight;
}
}
#line 387
[loop]
for(int k = 1; k < range; k++)
{
float weight = weights[abs(k)];
#line 392
if (bilateral)
{
float4 normal = GetNormalFromTexture(texcoord - off * k);
normal *= pow(saturate((dot(my_normal.xyz, normal.xyz) - normal_bias) / (1.0 - normal_bias)), NormalPower);
weight *= saturate((dot(my_normal.xyz, normal.xyz) - normal_bias) / (1.0 - normal_bias));
float zdiff = abs(my_normal.w - normal.w);
if (zdiff >= StartFade)
{
float fade = saturate(1.0 - (zdiff - StartFade) / fade_range);
weight *= fade * fade;
}
sum += tex2Dlod(sAOTex2, float4(texcoord - off * k, 0.0, 0.0)).r * weight;
sumCoef += weight;
}
else
{
sum += tex2Dlod(sAOTex2, float4(texcoord - off * k, 0.0, 0.0)).r * weight;
sumCoef += weight;
}
}
#line 413
if (debugEnabled)
{
return sum / sumCoef;
}
else
{
return tex2D(ReShade::BackBuffer, texcoord).rgb * sum / sumCoef;
}
}
#line 423
float2 ensure_1px_offset(float2 ray)
{
const float2 ray_in_pixels = ray / float2((1.0 / 1920), (1.0 / 1018));
const float coef = max(abs(ray_in_pixels.x), abs(ray_in_pixels.y));
if (coef < 1.0)
{
ray /= coef;
}
return ray;
}
#line 434
float3 MergeAOPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
uint2 texcoord_px = texcoord / float2((1.0 / 1920), (1.0 / 1018));
#line 447
if (texcoord_px.x % 2 && texcoord_px.y % 2)
return tex2D(sInterleavedAOTex4, texcoord).r;
if (texcoord_px.x % 2)
return tex2D(sInterleavedAOTex2, texcoord).r;
if (texcoord_px.y % 2)
return tex2D(sInterleavedAOTex3, texcoord).r;
return tex2D(sInterleavedAOTex, texcoord).r;
}
#line 456
float GetOcclusion(float2 texcoord, float angle_jitter)
{
const float3 position = GetPosition(texcoord);
const float3 normal = GetNormalFromTexture(texcoord).xyz;
#line 461
int num_angle_samples;
int num_distance_samples;
#line 464
switch(clamp(Quality, 0, 7))
{
case 0:
num_angle_samples = 4;
num_distance_samples = 1;
break;
case 1:
num_angle_samples = 4;
num_distance_samples = 2;
break;
case 2:
num_angle_samples = 4;
num_distance_samples = 4;
break;
case 3:
num_angle_samples = 6;
num_distance_samples = 4;
break;
case 4:
num_angle_samples = 8;
num_distance_samples = 4;
break;
case 5:
num_angle_samples = 6;
num_distance_samples = 6;
break;
case 6:
num_angle_samples = 8;
num_distance_samples = 6;
break;
case 7:
num_angle_samples = 8;
num_distance_samples = 8;
break;
}
#line 500
const int sample_dist = clamp(SampleDistance, 1, 128);
const float normal_bias = clamp(NormalBias, 0.0, 1.0);
#line 503
float occlusion = 0.0;
const float fade_range = EndFade - StartFade;
#line 506
[loop]
for (int i = 0; i < num_angle_samples; i++)
{
float angle = 3.1415 * 2.0 / num_angle_samples * (i + angle_jitter);
#line 511
float2 ray;
ray.x = sin(angle);
ray.y = cos(angle);
ray *= float2((1.0 / 1920), (1.0 / 1018)) * sample_dist;
ray /= 1.0 + position.z * lerp(0, 0.05, pow(max(DepthShrink, 0.0),4));
#line 517
float angle_occlusion = 0.0;
#line 519
[loop]
for (int k = 0; k < num_distance_samples; k++)
{
float3 v = GetPosition(texcoord + ensure_1px_offset(ray * max((k + 1.0 - rand2D(texcoord + float2(i, 0))) / num_distance_samples, 0.01))) - position;
float ray_occlusion = saturate((pow(max(dot(normal.xyz, normalize(v)), 0.0), NormalPower) - normal_bias) / (1.0 - normal_bias));
float zdiff = abs(v.z);
if (zdiff >= StartFade)
{
float fade = saturate(1.0 - (zdiff - StartFade) / fade_range);
ray_occlusion *= fade * fade;
}
#line 531
float fade_coef = float(num_distance_samples - k) / num_distance_samples;
fade_coef *= fade_coef;
angle_occlusion = max(angle_occlusion, ray_occlusion * fade_coef);
}
#line 536
occlusion += angle_occlusion;
}
#line 539
return pow(max(saturate(1.0 - ((occlusion / num_angle_samples * 2.0) * saturate(1.0 - (position.z / DepthEndFade))) * Strength), 0.0), Gamma);
}
#line 542
void SSAOPass(float4 vpos : SV_Position, in float2 texcoord : TexCoord,
out float occlusion_1 : SV_Target0, out float occlusion_2 : SV_Target1, out float occlusion_3 : SV_Target2, out float occlusion_4 : SV_Target3)
{
occlusion_1 = GetOcclusion(texcoord + float2(-0.25,  0.25) * float2((1.0 / 1920), (1.0 / 1018)),  0.00);
occlusion_2 = GetOcclusion(texcoord + float2( 0.25,  0.25) * float2((1.0 / 1920), (1.0 / 1018)),  0.25);
occlusion_3 = GetOcclusion(texcoord + float2(-0.25, -0.25) * float2((1.0 / 1920), (1.0 / 1018)),  0.50);
occlusion_4 = GetOcclusion(texcoord + float2( 0.25, -0.25) * float2((1.0 / 1920), (1.0 / 1018)),  0.75);
}
#line 551
technique MC_DAO
{
pass
{
VertexShader = PostProcessVS;
PixelShader = DepthNormalsPass;
RenderTarget0 = MCNormalTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = SSAOPass;
RenderTarget0 = InterleavedAOTex;
RenderTarget1 = InterleavedAOTex2;
RenderTarget2 = InterleavedAOTex3;
RenderTarget3 = InterleavedAOTex4;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = MergeAOPass;
RenderTarget0 = MCAOTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = BlurAOFirstPass;
RenderTarget0 = MCAOTex2;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = BlurAOSecondPass;
}
}

