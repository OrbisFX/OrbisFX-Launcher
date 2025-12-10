#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\AdaptiveFog.fx"
#line 37
uniform float3 FogColor <
ui_type= "color";
ui_tooltip = "Color of the fog, in (red , green, blue)";
> = float3(0.9,0.9,0.9);
#line 42
uniform float MaxFogFactor <
ui_type = "slider";
ui_min = 0.000; ui_max=1.000;
ui_tooltip = "The maximum fog factor. 1.0 makes distant objects completely fogged out, a lower factor will shimmer them through the fog.";
ui_step = 0.001;
> = 0.8;
#line 49
uniform float FogCurve <
ui_type = "slider";
ui_min = 0.00; ui_max=175.00;
ui_step = 0.01;
ui_tooltip = "The curve how quickly distant objects get fogged. A low value will make the fog appear just slightly. A high value will make the fog kick in rather quickly. The max value in the rage makes it very hard in general to view any objects outside fog.";
> = 1.5;
#line 56
uniform float FogStart <
ui_type = "slider";
ui_min = 0.000; ui_max=1.000;
ui_step = 0.001;
ui_tooltip = "Start of the fog. 0.0 is at the camera, 1.0 is at the horizon, 0.5 is halfway towards the horizon. Before this point no fog will appear.";
> = 0.050;
#line 63
uniform float BloomThreshold <
ui_type = "slider";
ui_min = 0.00; ui_max=50.00;
ui_step = 0.1;
ui_tooltip = "Threshold for what is a bright light (that causes bloom) and what isn't.";
> = 10.25;
#line 70
uniform float BloomPower <
ui_type = "slider";
ui_min = 0.000; ui_max=100.000;
ui_step = 0.1;
ui_tooltip = "Strength of the bloom";
> = 10.0;
#line 77
uniform float BloomWidth <
ui_type = "slider";
ui_min = 0.0000; ui_max=1.0000;
ui_tooltip = "Width of the bloom";
> = 0.2;
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
#line 84 "C:\Program Files\GShade\gshade-shaders\Shaders\AdaptiveFog.fx"
#line 92
texture   Otis_BloomTarget < pooled = true; > { Width = 1920; Height = 1018; Format = RGBA8;};
#line 97
sampler2D Otis_BloomSampler { Texture = Otis_BloomTarget; };
#line 100
void PS_Otis_AFG_PerformBloom(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment: SV_Target0)
{
float4 color = tex2D(ReShade::BackBuffer, texcoord);
float3 BlurColor2 = 0;
float3 Blurtemp = 0;
const float MaxDistance = 8*BloomWidth;
float CurDistance = 0;
const float Samplecount = 25.0;
const float2 blurtempvalue = texcoord * float2((1.0 / 1920), (1.0 / 1018)) * BloomWidth;
float2 BloomSample = float2(2.5,-2.5);
float2 BloomSampleValue;
#line 112
for(BloomSample.x = (2.5); BloomSample.x > -2.0; BloomSample.x = BloomSample.x - 1.0)
{
BloomSampleValue.x = BloomSample.x * blurtempvalue.x;
float2 distancetemp = BloomSample.x * BloomSample.x * BloomWidth;
#line 117
for(BloomSample.y = (- 2.5); BloomSample.y < 2.0; BloomSample.y = BloomSample.y + 1.0)
{
distancetemp.y = BloomSample.y * BloomSample.y;
CurDistance = (distancetemp.y * BloomWidth) + distancetemp.x;
BloomSampleValue.y = BloomSample.y * blurtempvalue.y;
Blurtemp.rgb = tex2D(ReShade::BackBuffer, float2(texcoord + BloomSampleValue)).rgb;
BlurColor2.rgb += lerp(Blurtemp.rgb,color.rgb, sqrt(CurDistance / MaxDistance));
}
}
BlurColor2.rgb = (BlurColor2.rgb / (Samplecount - (BloomPower - BloomThreshold*5)));
const float Bloomamount = (dot(color.rgb,float3(0.299f, 0.587f, 0.114f)));
const float3 BlurColor = BlurColor2.rgb * (BloomPower + 4.0);
color.rgb = lerp(color.rgb,BlurColor.rgb, Bloomamount);
fragment = saturate(color);
#line 134
}
#line 137
void PS_Otis_AFG_BlendFogWithNormalBuffer(float4 vpos: SV_Position, float2 texcoord: TEXCOORD, out float4 fragment: SV_Target0)
{
const float depth = ReShade::GetLinearizedDepth(texcoord).r;
const float fogFactor = clamp(saturate(depth - FogStart) * FogCurve, 0.0, MaxFogFactor);
fragment = lerp(tex2D(ReShade::BackBuffer, texcoord), lerp(tex2D(Otis_BloomSampler, texcoord), float4(FogColor, 1.0), fogFactor), fogFactor);
#line 145
}
#line 147
technique AdaptiveFog
{
pass Otis_AFG_PassBloom0
{
VertexShader = PostProcessVS;
PixelShader = PS_Otis_AFG_PerformBloom;
RenderTarget = Otis_BloomTarget;
}
#line 156
pass Otis_AFG_PassBlend
{
VertexShader = PostProcessVS;
PixelShader = PS_Otis_AFG_BlendFogWithNormalBuffer;
}
}

