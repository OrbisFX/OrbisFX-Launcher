#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\CRT.fx"
#line 13
uniform float Amount <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Amount of CRT effect you want";
> = 1.00;
uniform float Resolution <
ui_type = "slider";
ui_min = 1.0; ui_max = 8.0;
ui_tooltip = "Input size coefficient (low values gives the 'low - res retro look').";
> = 1.15;
uniform float Gamma <
ui_type = "slider";
ui_min = 0.0; ui_max = 4.0;
ui_tooltip = "Gamma of simulated CRT";
> = 2.4;
uniform float MonitorGamma <
ui_type = "slider";
ui_min = 0.0; ui_max = 4.0;
ui_tooltip = "Gamma of display monitor";
> = 2.2;
uniform float Brightness <
ui_type = "slider";
ui_min = 0.0; ui_max = 3.0;
ui_tooltip = "Used to boost brightness a little.";
> = 0.9;
#line 39
uniform int ScanlineIntensity <
ui_type = "slider";
ui_min = 2; ui_max = 4;
ui_label = "Scanline Intensity";
> = 2;
uniform bool ScanlineGaussian <
ui_label = "Scanline Bloom Effect";
ui_tooltip = "Use the new nongaussian scanlines bloom effect.";
> = true;
#line 49
uniform bool Curvature <
ui_tooltip = "Barrel effect";
> = false;
uniform float CurvatureRadius <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_label = "Curvature Radius";
> = 1.5;
uniform float CornerSize <
ui_type = "slider";
ui_min = 0.00; ui_max = 0.02; ui_step = 0.001;
ui_label = "Corner Size";
ui_tooltip = "Higher values => more rounded corner";
> = 0.0100;
uniform float ViewerDistance <
ui_type = "slider";
ui_min = 0.0; ui_max = 4.0;
ui_Label = "Viewer Distance";
ui_tooltip = "Simulated distance from viewer to monitor";
> = 2.00;
uniform float2 Angle <
ui_type = "slider";
ui_min = -0.2; ui_max = 0.2;
ui_tooltip = "Tilt angle in radians";
> = 0.00;
#line 75
uniform float Overscan <
ui_type = "slider";
ui_min = 1.0; ui_max = 1.10; ui_step = 0.01;
ui_tooltip = "Overscan (e.g. 1.02 for 2% overscan).";
> = 1.01;
uniform bool Oversample <
ui_tooltip = "Enable 3x oversampling of the beam profile (warning : performance hit)";
> = true;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 57
namespace ReShade
{
float GetAspectRatio() { return 1280 * (1.0 / 720); }
float2 GetPixelSize() { return float2((1.0 / 1280), (1.0 / 720)); }
float2 GetScreenSize() { return float2(1280, 720); }
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
#line 85 "C:\Program Files\GShade\gshade-shaders\Shaders\CRT.fx"
#line 115
float intersect(float2 xy)
{
const float A = dot(xy,xy) + (ViewerDistance * ViewerDistance);
const float B = 2.0 * (CurvatureRadius * (dot(xy, sin(Angle)) - ViewerDistance * cos(Angle).x * cos(Angle).y) - ViewerDistance * ViewerDistance);
const float C = ViewerDistance * ViewerDistance + 2.0 * CurvatureRadius * ViewerDistance * cos(Angle).x * cos(Angle).y; 
return (-B - sqrt(B * B -4.0 * A * C)) / (2.0 * A);
}
#line 123
float2 bkwtrans(float2 xy)
{
const float c = intersect(xy);
float2 _point = float2(c, c) * xy;
_point -= float2(-CurvatureRadius, -CurvatureRadius) * sin(Angle);
_point /= float2(CurvatureRadius, CurvatureRadius);
const float2 tang = sin(Angle) / cos(Angle);
const float2 poc = _point / cos(Angle);
const float A = dot(tang, tang) + 1.0;
const float B = -2.0 * dot(poc, tang);
const float C = dot(poc, poc) - 1.0;
const float a = (-B + sqrt(B * B -4.0 * A * C)) / (2.0 * A);
const float2 uv = (_point - a * sin(Angle)) / cos(Angle);
const float r = CurvatureRadius * acos(a);
return uv * r / sin(r / CurvatureRadius);
}
float2 fwtrans(float2 uv)
{
const float r = max(abs(sqrt(dot(uv, uv))), 1e-5);;
uv *= sin(r / CurvatureRadius) / r;
const float x = 1.0 - cos(r / CurvatureRadius);
const float D = ViewerDistance / CurvatureRadius + x * cos(Angle).x * cos(Angle).y + dot(uv, sin(Angle));
return ViewerDistance * (uv * cos(Angle) - x * sin(Angle)) / D;
}
#line 148
float3 maxscale()
{
const float2 c = bkwtrans(-CurvatureRadius * sin(Angle) / (1.0 + CurvatureRadius / ViewerDistance * cos(Angle).x * cos(Angle).y));
const float2 a = float2(0.5, 0.5) * float2(1.0, 0.75);
const float2 lo = float2(fwtrans(float2(-a.x, c.y)).x, fwtrans(float2(c.x,-a.y)).y) / float2(1.0, 0.75);
const float2 hi = float2(fwtrans(float2(+a.x, c.y)).x, fwtrans(float2(c.x, +a.y)).y) / float2(1.0, 0.75);
return float3((hi + lo) * float2(1.0, 0.75) * 0.5, max(hi.x - lo.x, hi.y - lo.y));
}
#line 157
float2 transform(float2 coord, float2 textureSize, float2 inputSize)
{
coord *= textureSize / inputSize;
coord = (coord - 0.5) * float2(1.0, 0.75) * maxscale().z + maxscale().xy;
return (bkwtrans(coord) / float2(Overscan, Overscan) / float2(1.0, 0.75) + 0.5) * inputSize / textureSize;
}
#line 164
float corner(float2 coord, float2 textureSize, float2 inputSize)
{
coord *= textureSize / inputSize;
coord = (coord - 0.5) * float2(Overscan, Overscan) + 0.5;
coord = min(coord, 1.0 - coord) * float2(1.0, 0.75);
const float2 cdist = float2(CornerSize, CornerSize);
coord = (cdist - min(coord, cdist));
const float dist = sqrt(dot(coord, coord));
return clamp((cdist.x-dist) * 1000.0, 0.0, 1.0);
}
#line 181
float4 scanlineWeights(float distance, float4 color)
{
#line 193
if (!ScanlineGaussian)
{
const float4 wid = 0.3 + 0.1 * (color * color * color);
const float4 weights = float4(distance / wid);
return 0.4 * exp(-weights * weights) / wid;
}
else
{
const float4 wid = 2.0 * pow(abs(color), 4.0) + 2.0;
const float4 weights = (distance / 0.3).xxxx;
return 1.4 * exp(-pow(abs(weights * rsqrt(0.5 * wid)), abs(wid))) / (0.2 * wid + 0.6);
}
}
#line 207
float3 AdvancedCRTPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
#line 230
const float  Input_ratio = ceil(256 * Resolution);
const float2 Resolution = float2(Input_ratio, Input_ratio);
const float2 rubyTextureSize = Resolution;
const float2 rubyInputSize = Resolution;
const float2 rubyOutputSize = float2(1280, 720);
#line 236
float2 orig_xy;
if (Curvature)
orig_xy = transform(tex, rubyTextureSize, rubyInputSize);
else
orig_xy = tex;
const float cval = corner(orig_xy, rubyTextureSize, rubyInputSize);
#line 245
const float2 ratio_scale = orig_xy * rubyTextureSize - 0.5;
#line 247
const float filter = fwidth(ratio_scale.y);
float2 uv_ratio = frac(ratio_scale);
#line 251
const float2 xy = (floor(ratio_scale) + 0.5) / rubyTextureSize;
#line 256
float4 coeffs = 3.1415926535897932 * float4(1.0 + uv_ratio.x, uv_ratio.x, 1.0 - uv_ratio.x, 2.0 - uv_ratio.x);
#line 259
coeffs = max(abs(coeffs), 1e-5);;
#line 262
coeffs = 2.0 * sin(coeffs) * sin(coeffs / 2.0) / (coeffs * coeffs);
#line 265
coeffs /= dot(coeffs, 1.0);
#line 270
float4 col  = clamp(mul(coeffs, float4x4(
tex2D(ReShade::BackBuffer, (xy + float2(-1.0 / rubyTextureSize.x, 0.0))),
tex2D(ReShade::BackBuffer, (xy)),
tex2D(ReShade::BackBuffer, (xy + float2(1.0 / rubyTextureSize.x, 0.0))),
tex2D(ReShade::BackBuffer, (xy + float2(2.0 * 1.0 / rubyTextureSize.x, 0.0))))),
0.0, 1.0);
float4 col2 = clamp(mul(coeffs, float4x4(
tex2D(ReShade::BackBuffer, (xy + float2(-1.0 / rubyTextureSize.x, 1.0 / rubyTextureSize.y))),
tex2D(ReShade::BackBuffer, (xy + float2(0.0, 1.0 / rubyTextureSize.y))),
tex2D(ReShade::BackBuffer, (xy + 1.0 / rubyTextureSize)),
tex2D(ReShade::BackBuffer, (xy + float2(2.0 * 1.0 / rubyTextureSize.x, 1.0 / rubyTextureSize.y))))),
0.0, 1.0);
#line 284
col  = pow(abs(col) , Gamma);
col2 = pow(abs(col2), Gamma);
#line 290
float4 weights  = scanlineWeights(uv_ratio.y, col);
float4 weights2 = scanlineWeights(1.0 - uv_ratio.y, col2);
#line 296
if (Oversample)
{
uv_ratio.y = uv_ratio.y + 1.0 / 3.0 * filter;
weights = (weights + scanlineWeights(uv_ratio.y, col)) / 3.0;
weights2 = (weights2 + scanlineWeights(abs(1.0 - uv_ratio.y), col2)) / 3.0;
uv_ratio.y = uv_ratio.y - 2.0 / 3.0 * filter;
weights = weights + scanlineWeights(abs(uv_ratio.y), col) / 3.0;
weights2 = weights2 + scanlineWeights(abs(1.0 - uv_ratio.y), col2) / 3.0;
}
#line 306
float3 mul_res = (col * weights + col2 * weights2).rgb * cval.xxx;
#line 310
const float3 dotMaskWeights = lerp(float3(1.0, 0.7, 1.0), float3(0.7, 1.0, 0.7), floor(tex.x * rubyTextureSize.x * rubyOutputSize.x / rubyInputSize.x % ScanlineIntensity));
mul_res *= dotMaskWeights * float3(0.83, 0.83, 1.0) * Brightness;
#line 314
mul_res = pow(abs(mul_res), 1.0 / MonitorGamma);
#line 316
const float3 color = tex2D(ReShade::BackBuffer, (orig_xy)).rgb * cval.xxx;
#line 322
return saturate(lerp(color, mul_res, Amount));
#line 324
}
#line 326
technique AdvancedCRT
{
pass
{
VertexShader = PostProcessVS;
PixelShader = AdvancedCRTPass;
}
}

