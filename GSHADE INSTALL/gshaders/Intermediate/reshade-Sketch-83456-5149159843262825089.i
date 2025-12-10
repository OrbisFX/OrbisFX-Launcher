// SKETCH_DEBUG=0
// SKETCH_SMOOTH=1
// SKETCH_PATTERN_TEXTURE_SIZE=1024
// SKETCH_PATTERN_TEXTURE_NAME="Sketch_Shadow.png"
// SKETCH_USE_PATTERN_TEXTURE=0
// SKETCH_SMOOTH_SAMPLES=5
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Sketch.fx"
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
#line 45 "C:\Program Files\GShade\gshade-shaders\Shaders\Sketch.fx"
#line 78
static const int SmoothingSamples = 5;
static const float SmoothingSamplesInv = 1.0 / SmoothingSamples;
static const float SmoothingSamplesHalf = SmoothingSamples / 2;
#line 82
static const float2 ZeroOne = float2(0.0, 1.0);
#line 103
sampler SRGBBackBuffer
{
Texture = ReShade::BackBufferTex;
SRGBTexture = true;
};
#line 130
uniform float4 PatternColor
<
ui_type = "color";
ui_label = "Pattern Color";
ui_tooltip = "Default: 255 255 255 16";
> = float4(255, 255, 255, 16) / 255;
#line 137
uniform float2 PatternRange
<
ui_type = "slider";
ui_label = "Pattern Range";
ui_tooltip = "Default: 0.0 0.5";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.01;
> = float2(0.0, 0.5);
#line 147
uniform float OutlineThreshold
<
ui_type = "slider";
ui_label = "Outline Threshold";
ui_tooltip = "Default: 0.01";
ui_min = 0.001;
ui_max = 0.1;
ui_step = 0.001;
> = 0.01;
#line 157
uniform float Posterization
<
ui_type = "slider";
ui_tooltip = "Default: 5";
ui_min = 1;
ui_max = 255;
ui_step = 1;
> = 5;
#line 168
uniform float SmoothingScale
<
ui_type = "slider";
ui_label = "Smoothing Scale";
ui_tooltip = "Default: 1.0";
ui_min = 1.0;
ui_max = 10.0;
ui_step = 0.01;
> = 1.0;
#line 196
float get_depth(float2 uv)
{
return ReShade::GetLinearizedDepth(uv);
}
#line 201
float3 get_normals(float2 uv)
{
const float3 ps = float3(ReShade::GetPixelSize(), 0.0);
#line 205
float3 normals;
normals.x = get_depth(uv - ps.xz) - get_depth(uv + ps.xz);
normals.y = get_depth(uv + ps.zy) - get_depth(uv - ps.zy);
normals.z = get_depth(uv);
#line 210
normals.xy = abs(normals.xy) * 0.5 * ReShade::GetScreenSize();
normals = normalize(normals);
#line 213
return normals;
}
#line 216
float get_outline(float2 uv)
{
return step(OutlineThreshold, dot(get_normals(uv), float3(0.0, 0.0, 1.0)));
}
#line 221
float get_pattern(float2 uv)
{
#line 231
float x = uv.x + uv.y;
x = abs(x);
x %= 0.0125;
x /= 0.0125;
x = abs((x - 0.5) * 2.0);
x = step(0.5, x);
#line 238
return x;
#line 240
}
#line 242
float3 test_palette(float3 color, float2 uv)
{
const float2 bw = float2(1.0, 0.0);
uv.y = 1.0 - uv.y;
uv.y *= 20.0;
#line 248
return (uv.y < 0.333)
? uv.x * bw.xyy
: (uv.y < 0.666)
? uv.x * bw.yxy
: (uv.y < 1.0)
? uv.x * bw.yyx
: color;
}
#line 257
float3 cel_shade(float3 color, out float gray)
{
gray = dot(color, 0.333);
color -= gray;
#line 262
gray *= Posterization;
gray = round(gray);
gray /= Posterization;
#line 266
color += gray;
return color;
}
#line 272
float3 blur_old(sampler s, float2 uv, float2 dir)
{
dir *= SmoothingScale;
#line 276
uv -= SmoothingSamplesHalf * dir;
float3 color = tex2D(s, uv).rgb;
#line 279
[unroll]
for (int i = 1; i < SmoothingSamples; ++i)
{
uv += dir;
color += tex2D(s, uv).rgb;
}
#line 286
color *= SmoothingSamplesInv;
return color;
}
#line 290
float3 blur_depth_threshold(sampler s, float2 uv, float2 dir)
{
dir *= SmoothingScale;
#line 294
float depth = get_depth(uv);
#line 296
uv -= SmoothingSamplesHalf * dir;
float4 color = 0.0;
#line 299
[unroll]
for (int i = 0; i < SmoothingSamples; ++i)
{
float z = get_depth(uv);
if (abs(z - depth) < 0.001)
color += float4(tex2D(s, uv).rgb, 1.0);
#line 306
uv += dir;
}
#line 309
color.rgb /= color.a;
return color.rgb;
}
#line 313
float3 blur(sampler s, float2 uv, float2 dir)
{
dir *= SmoothingScale;
#line 317
const float3 center = tex2D(s, uv).rgb;
#line 319
uv -= SmoothingSamplesHalf * dir;
float4 color = 0.0;
#line 322
[unroll]
for (int i = 0; i < SmoothingSamples; ++i)
{
float3 pixel = tex2D(s, uv).rgb;
float delta = dot(1.0 - abs(pixel - center), 0.333);
#line 328
if (delta > 0.9		)
color += float4(pixel, 1.0);
}
#line 332
color.rgb /= color.a;
return color.rgb;
}
#line 344
float4 BlurXPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
#line 350
return float4(blur(SRGBBackBuffer, uv, float2((1.0 / 1920), 0.0)), 1.0);
#line 352
}
#line 354
float4 BlurYPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
return float4(blur(ReShade::BackBuffer, uv, float2(0.0, (1.0 / 1018))), 1.0);
}
#line 361
void MainVS(
uint id : SV_VERTEXID,
out float4 p : SV_POSITION,
out float2 uv : TEXCOORD0,
out float2 pattern_uv : TEXCOORD1)
{
PostProcessVS(id, p, uv);
#line 369
pattern_uv = uv;
pattern_uv.x *= ReShade::GetAspectRatio();
}
#line 373
float4 MainPS(
float4 p : SV_POSITION,
float2 uv : TEXCOORD0,
float2 pattern_uv : TEXCOORD1) : SV_TARGET
{
float4 color = tex2D(ReShade::BackBuffer, uv);
#line 391
float gray;
color.rgb = cel_shade(color.rgb, gray);
#line 394
float pattern = get_pattern(pattern_uv);
pattern *= 1.0 - smoothstep(PatternRange.x, PatternRange.y, gray);
pattern *= (1.0 - gray) * PatternColor.a;
color.rgb = lerp(color.rgb, PatternColor.rgb, pattern);
#line 399
float outline = get_outline(uv);
color.rgb *= outline;
#line 405
return color;
#line 407
}
#line 413
technique Sketch
{
#line 416
pass BlurX
{
VertexShader = PostProcessVS;
PixelShader = BlurXPS;
}
pass BlurY
{
VertexShader = PostProcessVS;
PixelShader = BlurYPS;
SRGBWriteEnable = true;
}
#line 428
pass Main
{
VertexShader = MainVS;
PixelShader = MainPS;
}
}

