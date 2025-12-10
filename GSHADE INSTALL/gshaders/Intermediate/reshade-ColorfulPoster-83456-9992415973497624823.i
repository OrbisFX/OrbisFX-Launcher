#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorfulPoster.fx"
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
#line 39 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorfulPoster.fx"
#line 53
uniform float iUILumaLevels <
ui_type = "slider";
ui_category = "Posterization";
ui_label = "Luma Posterize Levels";
ui_min = 1.0; ui_max = 20.0;
> = 16.0;
#line 60
uniform int iUIStepType <
ui_type = "combo";
ui_category = "Posterization";
ui_label = "Curve Type";
ui_items = "Linear\0Smoothstep\0Logistic\0Sigmoid\0";
> = 2;
#line 67
uniform float fUIStepContinuity <
ui_type = "slider";
ui_category = "Posterization";
ui_label = "Continuity";
ui_tooltip = "Broken up <-> Connected";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
> = 1.0;
#line 76
uniform float fUISlope <
ui_type = "slider";
ui_category = "Posterization";
ui_label = "Slope Logistic Curve";
ui_min = 0.0; ui_max = 40.0;
ui_step = 0.1;
> = 13.0;
#line 84
uniform bool iUIDebugOverlayPosterizeLevels <
ui_category = "Posterization";
ui_label = "Show Posterization as Curve (Magenta)";
> = 0;
#line 91
uniform float fUITint <
ui_type = "slider";
ui_category = "Color";
ui_label = "Tint Strength";
ui_min = 0.0; ui_max = 1.0;
> = 1.0;
#line 100
uniform float fUIStrength <
ui_type = "slider";
ui_category = "Effect";
ui_label = "Strength";
ui_min = 0.0; ui_max = 1.0;
> = 1.0;
#line 113
float Posterize(float x, int numLevels, float continuity, float slope, int type) {
const float stepheight = 1.0 / numLevels;
const float stepnum = floor(x * numLevels);
const float frc = frac(x * numLevels);
const float step1 = floor(frc) * stepheight;
float step2;
#line 120
if(type == 1)
step2 = smoothstep(0.0, 1.0, frc) * stepheight;
else if(type == 2)
step2 = (1.0 / (1.0 + exp(-slope*(frc - 0.5)))) * stepheight;
else if(type == 3)
{
if (frc < 0.5)
step2 = (pow(frc, slope) * pow(2.0, slope) * 0.5) * stepheight;
else
step2 = (1.0 - pow(1.0 - frc, slope) * pow(2.0, slope) * 0.5) * stepheight;
}
else
step2 = frc * stepheight;
#line 134
return lerp(step1, step2, continuity) + stepheight * stepnum;
}
#line 137
float4 RGBtoCMYK(float3 color) {
const float K = 1.0 - max(color.r, max(color.g, color.b));
const float3 CMY = (1.0 - color - K) / (1.0 - K);
return float4(CMY, K);
}
#line 143
float3 CMYKtoRGB(float4 cmyk) {
return (1.0.xxx - cmyk.xyz) * (1.0 - cmyk.w);
}
#line 147
float3 DrawDebugCurve(float3 background, float2 texcoord, float value, float3 color, float curveDiv) {
const float p = exp(-(1018/curveDiv) * length(texcoord - float2(texcoord.x, 1.0 - value)));
return lerp(background, color, saturate(p));
}
#line 155
float3 ColorfulPoster_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
static const float3 LumaCoeff = float3(0.2126, 0.7151, 0.0721);
#line 160
const float3 backbuffer = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 165
const float luma = dot(backbuffer, LumaCoeff);
const float3 chroma = backbuffer - luma;
const float3 lumaPoster = Posterize(luma, iUILumaLevels, fUIStepContinuity, fUISlope, iUIStepType).rrr;
#line 172
float3 mask, image, colorLayer;
#line 175
float4 backbufferCMYK = RGBtoCMYK(backbuffer);
backbufferCMYK.xyz += float3(0.2, -0.1, -0.2);
backbufferCMYK.w = 0.0;
#line 180
const mask = CMYKtoRGB(saturate(backbufferCMYK));
#line 183
const image = chroma + lumaPoster;
#line 186
colorLayer = lerp(2*image*mask, 1.0 - 2.0 * (1.0 - image) * (1.0 - mask), step(0.5, luma.r));
colorLayer = lerp(image, colorLayer, fUITint);
#line 192
float3 result = lerp(backbuffer, colorLayer, fUIStrength);
#line 194
if(iUIDebugOverlayPosterizeLevels == 1) {
const float value = Posterize(texcoord.x, iUILumaLevels, fUIStepContinuity, fUISlope, iUIStepType);
result = DrawDebugCurve(result, texcoord, value, float3(1.0, 0.0, 1.0), 1.0);
}
#line 205
return result;
#line 207
}
#line 209
technique ColorfulPoster
{
pass {
VertexShader = PostProcessVS;
PixelShader = ColorfulPoster_PS;
}
}

