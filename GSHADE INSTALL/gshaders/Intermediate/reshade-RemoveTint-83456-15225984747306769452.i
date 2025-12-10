// REMOVE_TINT_MIPLEVEL_EXP2=16
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\RemoveTint.fx"
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
#line 38 "C:\Program Files\GShade\gshade-shaders\Shaders\RemoveTint.fx"
#line 43
uniform float fUISpeed <
ui_type = "slider";
ui_label = "Adaptions Speed";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
> = 0.1;
#line 50
uniform bool bUIUseExcludeColor <
ui_spacing = 5;
ui_tooltip = "Enable this to exclude a certain color from being used in the min/max-RGB calculation. Can reduce the impact of the game UI.";
ui_type = "radio";
ui_label = "Enable Exclude Color";
> = false;
#line 57
uniform float3 fUIExcludeColor <
ui_type = "color";
ui_label = "Exclude Color";
> = float3(1.0, 1.0, 1.0);
#line 62
uniform float fUIExcludeColorStrength <
ui_type = "slider";
ui_label = "Strength";
ui_min = 1.0; ui_max = 4.0;
> = 3.0;
#line 68
uniform int cUIDebug <
ui_type = "combo";
ui_label = "Debug";
ui_items = "Off\0Show Diff To Avg. RGB\0";
> = 0;
#line 74
uniform float fUIStrength <
ui_spacing = 5;
ui_type = "slider";
ui_label = "Strength";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.01;
> = 1.0;
#line 82
uniform float frametime < source = "frametime"; >;
#line 84
namespace RemoveTint {
#line 90
texture2D texBackBuffer { Width = 1920/16; Height = 1018/16; Format = RGBA16F; };
sampler2D samplerBackBuffer { Texture = texBackBuffer; };
#line 93
texture2D texMinRGB { Width = 1; Height = 1; Format = RGBA16F; };
sampler2D samplerMinRGB { Texture = texMinRGB; };
texture2D texMaxRGB { Width = 1; Height = 1; Format = RGBA16F; };
sampler2D samplerMaxRGB { Texture = texMaxRGB; };
#line 98
texture2D texMinRGBLastFrame { Width = 1; Height = 1; Format = RGBA16F; };
sampler2D samplerMinRGBLastFrame { Texture = texMinRGBLastFrame; };
texture2D texMaxRGBLastFrame { Width = 1; Height = 1; Format = RGBA16F; };
sampler2D samplerMaxRGBLastFrame { Texture = texMaxRGBLastFrame; };
#line 103
float LerpValue(float luma, float2 values) {
return ((smoothstep(0.0, 1.0, 4.0 * luma - ((1.0 - values.x) *2.0 - 1.0)) + (1.0 - smoothstep(0.0, 1.0, 4.0 * luma - (2.0 + (values.y)*2.0)))) * 0.5 - 0.5) * 2.0;
}
#line 107
void BackBuffer_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord, out float4 backbuffer : SV_Target0) {
backbuffer = tex2Dfetch(ReShade::BackBuffer, int2(vpos.xy * 16), 0);
}
#line 111
void MinMaxRGB_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord, out float4 resultMinRGB : SV_Target0, out float4 resultMaxRGB : SV_Target1) {
float diff;
float brightnessFilter;
float luma;
float lerpValue;
float3 color;
float4 currentMinRGB = 1.0.rrrr;
float4 currentMaxRGB = 0.0.rrrr;
#line 120
const int2 size = float2(1920, 1018) / 16;
#line 122
for(int y = 0; y < size.y; y++) {
for(int x = 0; x < size.x; x++) {
color = tex2Dfetch(RemoveTint::samplerBackBuffer, int2(x, y), 0).rgb;
luma = dot(color, float3(0.2126, 0.7151, 0.0721));
diff = saturate(pow(abs(dot(color, fUIExcludeColor)), fUIExcludeColorStrength));
if (bUIUseExcludeColor)
lerpValue = 1.0 - diff;
else
lerpValue = 1.0;
#line 132
currentMaxRGB.r = lerp(currentMaxRGB.r, color.r, min(step(currentMaxRGB.r, color.r), lerpValue));
currentMaxRGB.g = lerp(currentMaxRGB.g, color.g, min(step(currentMaxRGB.g, color.g), lerpValue));
currentMaxRGB.b = lerp(currentMaxRGB.b, color.b, min(step(currentMaxRGB.b, color.b), lerpValue));
#line 136
currentMinRGB.r = lerp(currentMinRGB.r, color.r, min(step(color.r, currentMinRGB.r), lerpValue));
currentMinRGB.g = lerp(currentMinRGB.g, color.g, min(step(color.g, currentMinRGB.g), lerpValue));
currentMinRGB.b = lerp(currentMinRGB.b, color.b, min(step(color.b, currentMinRGB.b), lerpValue));
}
}
#line 142
const float4 lastMinRGB = tex2Dfetch(RemoveTint::samplerMinRGBLastFrame, int2(0, 0), 0);
const float4 lastMaxRGB = tex2Dfetch(RemoveTint::samplerMaxRGBLastFrame, int2(0, 0), 0);
#line 145
resultMinRGB = saturate(lerp(lastMinRGB, currentMinRGB, saturate(fUISpeed * frametime * 0.01)));
resultMaxRGB = saturate(lerp(lastMaxRGB, currentMaxRGB, saturate(fUISpeed * frametime * 0.01)));
resultMinRGB.a = 1.0;
resultMaxRGB.a = 1.0;
}
#line 151
void MinMaxRGBBackup_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord, out float4 currentMinRGB : SV_Target0, out float4 currentMaxRGB : SV_Target1) {
currentMinRGB = tex2Dfetch(RemoveTint::samplerMinRGB, int2(0, 0), 0);
currentMaxRGB = tex2Dfetch(RemoveTint::samplerMaxRGB, int2(0, 0), 0);
}
#line 156
float4 Apply_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float3 MinRGB = tex2Dfetch(RemoveTint::samplerMinRGB, int2(0, 0), 0).rgb;
const float3 MaxRGB = tex2Dfetch(RemoveTint::samplerMaxRGB, int2(0, 0), 0).rgb;
const float3 colorNormalize = (color - MinRGB) / (MaxRGB-MinRGB);
float3 tintRemoved = colorNormalize;
#line 163
tintRemoved = normalize(tintRemoved) * length(color).rrr;
#line 165
tintRemoved = lerp(tintRemoved, color, saturate(pow(abs(dot(color, fUIExcludeColor)), fUIExcludeColorStrength)));
#line 171
return float4(saturate(lerp(color, tintRemoved, fUIStrength)).rgb, 1.0);
#line 173
}
}
#line 176
technique RemoveTint
{
pass {
VertexShader = PostProcessVS;
PixelShader = RemoveTint::BackBuffer_PS;
RenderTarget = RemoveTint::texBackBuffer;
}
pass {
VertexShader = PostProcessVS;
PixelShader = RemoveTint::MinMaxRGB_PS;
RenderTarget0 = RemoveTint::texMinRGB;
RenderTarget1 = RemoveTint::texMaxRGB;
}
pass {
VertexShader = PostProcessVS;
PixelShader = RemoveTint::MinMaxRGBBackup_PS;
RenderTarget0 = RemoveTint::texMinRGBLastFrame;
RenderTarget1 = RemoveTint::texMaxRGBLastFrame;
}
pass {
VertexShader = PostProcessVS;
PixelShader = RemoveTint::Apply_PS;
#line 199
}
}

