#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Glitch.fx"
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
#line 2 "C:\Program Files\GShade\gshade-shaders\Shaders\Glitch.fx"
#line 10
uniform float  Timer < source = "timer"; >;
#line 12
uniform float Amount <
ui_type = "slider";
ui_min = 0.0;
ui_max = 10.0;
ui_tooltip = "Glitch Amount [Glitch B]";
> = 1.0;
#line 19
uniform bool bUseUV <
ui_type = "combo";
ui_tooltip = "Use UV for Glitch [Glitch B]";
> = false;
#line 24
float fmod(float a, float b) {
float c = frac(abs(a / b)) * abs(b);
if (a < 0)
return -c;
else
return c;
}
float2 fmod(float2 a, float2 b) {
float2 c = frac(abs(a / b)) * abs(b);
if (a.r < 0 && a.g < 0)
return -c;
else
return c;
}
#line 39
float3 rgb2hsv(float3 c)
{
const float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
const float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
const float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
#line 45
const float d = q.x - min(q.w, q.y);
const float e = 1.0e-10;
return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
#line 50
float3 hsv2rgb(float3 c)
{
const float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
const float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
#line 57
float3 posterize(float3 color, float steps)
{
return floor(color * steps) / steps;
}
#line 62
float quantize(float n, float steps)
{
return floor(n * steps) / steps;
}
#line 67
float4 downsample(sampler2D samp, float2 uv, float pixelSize)
{
return tex2D(samp, uv - fmod(uv, float2(pixelSize,pixelSize) / float2(1920, 1018)));
}
#line 72
float rand(float n)
{
return frac(sin(n) * 43758.5453123);
}
#line 77
float noise(float p)
{
const float fl = floor(p);
const float fc = frac(p);
return lerp(rand(fl), rand(fl + 1.0), fc);
}
#line 84
float rand(float2 n)
{
return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453);
}
#line 89
float noise(float2 p)
{
const float2 ip = floor(p);
float2 u = frac(p);
u = u * u * (3.0 - 2.0 * u);
#line 95
const float res = lerp(
lerp(rand(ip), rand(ip + float2(1.0, 0.0)), u.x),
lerp(rand(ip + float2(0.0,1.0)), rand(ip + float2(1.0,1.0)), u.x), u.y);
return res * res;
}
#line 101
float3 edge(sampler2D samp, float2 uv, float sampleSize)
{
const float dx = sampleSize * (1.0 / 1920);
const float dy = sampleSize * (1.0 / 1018);
return (
lerp(downsample(samp, uv - float2(dx, 0.0), sampleSize), downsample(samp, uv + float2(dx, 0.0), sampleSize), fmod(uv.x, dx) / dx) +
lerp(downsample(samp, uv - float2(0.0, dy), sampleSize), downsample(samp, uv + float2(0.0, dy), sampleSize), fmod(uv.y, dy) / dy)
).rgb / 2.0 - tex2D(samp, uv).rgb;
}
#line 111
float3 distort(sampler2D samp, float2 uv, float edgeSize)
{
const float2 pixel = float2((1.0 / 1920), (1.0 / 1018));
const float3 field = rgb2hsv(edge(samp, uv, edgeSize));
const float2 distort = pixel * sin((field.rb) * 3.1415926535897932 * 2.0);
const float shiftx = noise(float2(quantize(uv.y + 31.5, 1018 / 16.0) * Timer*0.001, frac(Timer*0.001) * 300.0));
const float shifty = noise(float2(quantize(uv.x + 11.5, 1920 / 16.0) * Timer*0.001, frac(Timer*0.001) * 100.0));
const float3 rgb = tex2D(samp, uv + (distort + (pixel - pixel / 2.0) * float2(shiftx, shifty) * (50.0 + 100.0 * Amount)) * Amount).rgb;
float3 hsv = rgb2hsv(rgb);
hsv.y = fmod(hsv.y + shifty * (Amount * Amount * Amount * Amount * Amount) * 0.25, 1.0);
return posterize(hsv2rgb(hsv), floor(lerp(256.0, pow(1.0 - hsv.z - 0.5, 2.0) * 64.0 * shiftx + 4.0, 1.0 - pow(1.0 - Amount, 5.0))));
}
#line 124
float4 PS_Glitch ( float4 pos : SV_Position, float2 fragCoord : TEXCOORD) : SV_Target
{
float4 fragColor;
float wow;
float Amount;
#line 130
const float2 texcoord = fragCoord * float2(1920, 1018); 
const float2 uv = texcoord.xy / float2(1920, 1018);
if (bUseUV) {
Amount = uv.x; 
}
wow = clamp(fmod(noise(Timer*0.001 + uv.y), 1.0), 0.0, 1.0) * 2.0 - 1.0;
float3 finalColor;
finalColor += distort(ReShade::BackBuffer, uv, 8.0);
#line 141
return float4(finalColor, 1.0);
#line 143
}
#line 145
technique GlitchB {
pass GlitchB {
VertexShader=PostProcessVS;
PixelShader=PS_Glitch;
}
}

