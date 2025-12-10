#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\pkd_Kuwahara.fx"
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
#line 61 "C:\Program Files\GShade\gshade-shaders\Shaders\pkd_Kuwahara.fx"
#line 62
static const float2 PIXEL_SIZE 		= float2((1.0 / 1920), (1.0 / 1018));
#line 66
static const float3 CFG_KUWAHARA_LUMINANCE = float3(0.3, 0.6, 0.1);
#line 68
uniform float2 CFG_KUWAHARA_RADIUS <
ui_type = "slider";
ui_label = "Radius";
ui_tooltip = "X and Y radius of the kernels to use.";
ui_min = 1.1; ui_max = 6; ui_step = 0.1;
> = float2(4, 4);
#line 75
uniform float CFG_KUWAHARA_LOD <
ui_type = "slider";
ui_category = "Experimental";
ui_label = "Texel LOD";
ui_tooltip = "How large of a texel offset should we use when performing the Kuwahara convolution. Smaller numbers are more detail, larger are less.";
ui_min = 0.25; ui_max = 2.0; ui_step = 0.01;
> = 0.2;
#line 83
uniform bool CFG_KUWAHARA_ROTATION <
ui_category = "Experimental";
ui_label = "Enable Rotation";
ui_tooltip = "If true, the Kuwahara kernel calculation will be rotated to the dominant angle. In theory, this should produce a slightly more painting-like effect by eliminating the 'boxy' effect that Kuwahara filters sometimes produce.";
> = true;
#line 89
uniform bool CFG_KUWAHARA_DEPTHAWARE <
ui_category = "Experimental";
ui_label = "Enable Depth Awareness";
ui_tooltip = "Adjust the Kuwahara radius based on depth, which will ensure the foreground elements have more detail than background.";
> = false;
#line 95
uniform bool CFG_KUWAHARA_DEPTHAWARE_EXCLUDESKY <
ui_category = "Experimental";
ui_label = "Depth-Awareness Excludes Sky";
ui_tooltip = "Exclude the sky from the depth-aware portion of the Kuwahara filter. Useful for retaining stars in a night sky.";
> = false;
#line 101
uniform int CFG_KUWAHARA_DEPTHAWARE_SKYBLEND_STYLE <
ui_type = "combo";
ui_category = "Experimental";
ui_label = "Sky Blend Style";
ui_tooltip = "Once we restore the sky, how should we blend it?";
ui_items = "Adaptive\0Favor Dark\0Favor Light\0Manual Blend";
> = 0;
#line 109
uniform float CFG_KUWAHARA_DEPTHAWARE_SKYBLEND_STRENGTH <
ui_type = "slider";
ui_category = "Experimental";
ui_label = "Sky Blend Manual Strength";
ui_tooltip = "If the blend style is 'Manual Blend', how strong should the blend be? (0 is the painted foreground, 1.0 is the preserved sky.)";
ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.5;
#line 117
uniform float2 CFG_KUWAHARA_DEPTHAWARE_CURVE <
ui_type = "slider";
ui_category = "Experimental";
ui_label = "Depth-aware Curve";
ui_tooltip = "Start/end values for where the foreground will transition to the background.";
ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = float2(0.12, 0.55);
#line 125
uniform float2 CFG_KUWAHARA_DEPTHAWARE_MINRADIUS <
ui_type = "slider";
ui_category = "Experimental";
ui_label = "Minimum Radius";
ui_tooltip = "The smallest radius, to use for the foreground elements.";
ui_min = 1.2; ui_max = 5.9; ui_step = 0.1;
> = float2(2, 2);
#line 133
texture texSky { Width = 1920; Height = 1018; };
sampler sampSky { Texture = texSky; };
#line 136
float PixelAngle(float2 texcoord : TEXCOORD0)
{
float sobelX[9] = {-1, -2, -1, 0, 0, 0, 1, 2, 1};
float sobelY[9] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};
int sobelIndex = 0;
#line 142
float2 gradient = float2(0, 0);
#line 144
const float2 texelSize = PIXEL_SIZE.xy * pow(2.0, CFG_KUWAHARA_LOD);;
#line 146
for (int x = -1; x <= 1; x++)
{
for (int y = -1; y <= 1; y++)
{
const float2 offset = float2(x, y) * (texelSize * 0.5);
const float3 color = tex2Dlod(ReShade::BackBuffer, float4((texcoord + offset).xy, 0, 0)).rgb;
float value = dot(color, float3(0.3, 0.59, 0.11));
#line 154
gradient[0] += value * sobelX[sobelIndex];
gradient[1] += value * sobelY[sobelIndex];
sobelIndex++;
}
}
#line 160
return atan(gradient[1] / gradient[0]);
}
#line 163
float4 KernelMeanAndVariance(float2 origin : TEXCOORD, float4 kernelRange,
float2x2 rotation)
{
float3 mean = float3(0, 0, 0);
float3 variance = float3(0, 0, 0);
int samples = 0;
#line 170
const float4 range = kernelRange;
#line 172
const float2 texelSize = PIXEL_SIZE.xy * pow(2.0, CFG_KUWAHARA_LOD);;
#line 174
for (int u = range.x; u <= range.y; u++)
{
for (int v = kernelRange.z; (v <= kernelRange.w); v++)
{
float2 offset = 0.0;
#line 180
if (CFG_KUWAHARA_ROTATION)
{
offset = mul(float2(u, v) * texelSize, rotation);
}
else
{
offset = float2(u, v) * texelSize;
}
#line 189
float3 color = tex2Dlod(ReShade::BackBuffer, float4((origin + offset).xy, 0, 0)).rgb;
#line 191
mean += color; variance += color * color;
samples++;
}
}
#line 196
mean /= samples;
variance = variance / samples - mean * mean;
return float4(mean, variance.r + variance.g + variance.b);
}
#line 201
float3 Kuwahara(float2 texcoord, float2 radius, float2x2 rotation)
{
float4 range;
float4 meanVariance[4];
#line 206
range = float4(-radius[0], 0, -radius[1], 0);
meanVariance[0] = KernelMeanAndVariance(texcoord, range, rotation);
#line 209
range = float4(0, radius[0], -radius[1], 0);
meanVariance[1] = KernelMeanAndVariance(texcoord, range, rotation);
#line 212
range = float4(-radius[0], 0, 0, radius[1]);
meanVariance[2] = KernelMeanAndVariance(texcoord, range, rotation);
#line 215
range = float4(0, radius[0], 0, radius[1]);
meanVariance[3] = KernelMeanAndVariance(texcoord, range, rotation);
#line 218
float3 result = meanVariance[0].rgb;
float currentVariance = meanVariance[0].a;
#line 222
for (int i = 1; i < 4; i++)
{
if (meanVariance[i].a < currentVariance)
{
result = meanVariance[i].rgb;
currentVariance = meanVariance[i].a;
}
}
#line 231
return result;
#line 233
}
#line 235
float4 PS_SkyKeep(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
if (!CFG_KUWAHARA_DEPTHAWARE_EXCLUDESKY)
{
return float4(0, 0, 0, 0);
}
#line 242
float angle = 0.0;
float2x2 rotation = float2x2(0.0, 0.0, 0.0, 0.0);
#line 245
if (CFG_KUWAHARA_ROTATION)
{
angle = PixelAngle(texcoord);
rotation = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
}
#line 251
const float depth = ReShade::GetLinearizedDepth(texcoord);
#line 253
if (depth <= 0.99)
{
return float4(0, 0, 0, 0);
}
#line 258
float3 result = Kuwahara(texcoord, CFG_KUWAHARA_DEPTHAWARE_MINRADIUS, rotation).rgb;
#line 260
return float4(result, 1.0);
}
#line 263
float3 PS_SkyRestore(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 bb = tex2D(ReShade::BackBuffer, texcoord);
if (!CFG_KUWAHARA_DEPTHAWARE_EXCLUDESKY)
{
return bb.rgb;
}
#line 271
float4 sky = tex2D(sampSky, texcoord);
if (sky.a == 0)
{
return bb.rgb;
}
#line 278
const float3 lumITU = float3(0.299, 0.587, 0.114);
#line 280
const float lumBB = (bb.r * lumITU.r) + (bb.g * lumITU.g) + (bb.b * lumITU.b);
const float lumSky = (sky.r * lumITU.r) + (sky.g * lumITU.g) + (sky.b * lumITU.b);
#line 283
if (lumBB >= lumSky) {
return bb.rgb;
}
else {
float alpha;
#line 289
if (CFG_KUWAHARA_DEPTHAWARE_SKYBLEND_STYLE == 0)
{
#line 292
float magBB;
if (lumBB < 0.5)
magBB = abs(lumBB - 1.0);
else
magBB = lumBB + 0.3;
#line 298
float magSky;
if (lumSky < 0.5)
magSky = abs(lumSky - 1.0);
else
magSky = lumSky + 0.3;
#line 304
if (magBB > magSky)
alpha = 0.02;
else
alpha = 0.98;
}
else if (CFG_KUWAHARA_DEPTHAWARE_SKYBLEND_STYLE == 1)
{
if (lumBB < lumSky)
alpha = lumBB;
else
alpha = lumSky;
}
else if (CFG_KUWAHARA_DEPTHAWARE_SKYBLEND_STYLE == 2)
{
if (lumBB > lumSky)
alpha = lumBB;
else
alpha = lumSky;
}
else
{
alpha = CFG_KUWAHARA_DEPTHAWARE_SKYBLEND_STRENGTH;
}
#line 328
return lerp(bb.rgb, sky.rgb, alpha);
}
}
#line 332
float3 PS_Kuwahara(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 meanVariance[4];
#line 336
float angle = 0.0;
float2x2 rotation = float2x2(0.0, 0.0, 0.0, 0.0);
#line 339
if (CFG_KUWAHARA_ROTATION)
{
angle = PixelAngle(texcoord);
rotation = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
}
#line 345
float2 radius = CFG_KUWAHARA_RADIUS;
#line 347
if (CFG_KUWAHARA_DEPTHAWARE)
{
const float2 delta = CFG_KUWAHARA_RADIUS - CFG_KUWAHARA_DEPTHAWARE_MINRADIUS;
#line 351
const float depth = ReShade::GetLinearizedDepth(texcoord);
#line 353
const float percent = smoothstep(CFG_KUWAHARA_DEPTHAWARE_CURVE[0],
CFG_KUWAHARA_DEPTHAWARE_CURVE[1], depth);
#line 356
radius = CFG_KUWAHARA_DEPTHAWARE_MINRADIUS + (delta * percent);
}
#line 359
return Kuwahara(texcoord, radius, rotation).rgb;
}
#line 362
technique pkd_Kuwahara
{
pass SkyStore
{
VertexShader = PostProcessVS;
PixelShader = PS_SkyKeep;
RenderTarget = texSky;
}
#line 371
pass Filter
{
VertexShader = PostProcessVS;
PixelShader = PS_Kuwahara;
}
#line 377
pass SkyRestore
{
VertexShader = PostProcessVS;
PixelShader = PS_SkyRestore;
}
}

