#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\LinearMotionBlur.fx"
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
#line 29 "C:\Program Files\GShade\gshade-shaders\Shaders\LinearMotionBlur.fx"
#line 32
uniform float frametime < source = "frametime"; >;
#line 36
uniform float  UI_BLUR_LENGTH <
ui_type = "slider";
ui_min = 0.1; ui_max = 1.0; ui_step = 0.01;
ui_tooltip = "";
ui_label = "Blur Length";
ui_category = "Motion Blur";
> = 0.25;
#line 44
uniform int  UI_BLUR_SAMPLES_MAX <
ui_type = "slider";
ui_min = 3; ui_max = 16; ui_step = 1;
ui_tooltip = "";
ui_label = "Samples";
ui_category = "Motion Blur";
> = 5;
#line 52
uniform bool UI_HQ_SAMPLING <
ui_label = "High Quality Resampling";
ui_category = "Motion Blur";
> = false;
#line 59
texture2D texColor : COLOR;
sampler samplerColor { Texture = texColor; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Linear; };
#line 62
texture texMotionVectors          { Width = 1280;   Height = 720;   Format = RG16F; };
sampler SamplerMotionVectors2 { Texture = texMotionVectors; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
#line 67
float4 BlurPS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{
float2 velocity = tex2D(SamplerMotionVectors2, texcoord).xy;
float2 velocityTimed = velocity / frametime;
float2 blurDist = velocityTimed * 50 * UI_BLUR_LENGTH;
float2 sampleDist = blurDist / float(UI_BLUR_SAMPLES_MAX);
int halfSamples = float(UI_BLUR_SAMPLES_MAX) / 2.0;
#line 75
float4 summedSamples = 0.0;
[loop]
for(int s = 0; s < UI_BLUR_SAMPLES_MAX; s++)
summedSamples += tex2Dlod(samplerColor, float4(texcoord - sampleDist * (s - halfSamples), 0.0, 0.0)) / UI_BLUR_SAMPLES_MAX;
#line 80
return summedSamples;
}
#line 83
technique LinearMotionBlur < ui_tooltip = "This technique requires qUINT_MotionVectors to be enabled and placed before (above) it in the load order."; >
{
pass PassBlurThatShit
{
VertexShader = PostProcessVS;
PixelShader = BlurPS;
}
}

