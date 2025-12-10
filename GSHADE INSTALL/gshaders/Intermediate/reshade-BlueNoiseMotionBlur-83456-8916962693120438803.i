#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\BlueNoiseMotionBlur.fx"
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
#line 44 "C:\Program Files\GShade\gshade-shaders\Shaders\BlueNoiseMotionBlur.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\BlueNoiseDither.fxh"
#line 54
namespace BlueNoise
{
#line 59
texture BlueNoiseTex
<
source = "j_bluenoise.png";
pooled = true;
>
{
Width = 64u;
Height = 64u;
Format = RGBA8;
};
#line 70
sampler BlueNoiseTexSmp
{
Texture = BlueNoiseTex;
#line 74
AddressU = REPEAT;
AddressV = REPEAT;
};
#line 87
float dither(float gradient, uint2 pixelPos)
{
#line 90
float noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u).r;
#line 92
gradient = ceil(mad(255u, gradient, -noise)); 
#line 94
return gradient/255u;
}
float3 dither(float3 color, uint2 pixelPos)
{
#line 99
float3 noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u).rgb;
#line 101
color = ceil(mad(255u, color, -noise)); 
#line 103
return color/255u;
}
float4 dither(float4 color, uint2 pixelPos)
{
#line 108
float4 noise = tex2Dfetch(BlueNoiseTexSmp, pixelPos%64u);
#line 110
color = ceil(mad(255u, color, -noise)); 
#line 112
return color/255u;
}
}
#line 45 "C:\Program Files\GShade\gshade-shaders\Shaders\BlueNoiseMotionBlur.fx"
#line 50
uniform uint framecount < source = "framecount"; >;
#line 57
texture InterlacedTargetBuffer
{
Width = 1920;
Height = 1018;
};
sampler InterlacedBufferSampler
{
Texture = InterlacedTargetBuffer;
MagFilter = POINT;
MinFilter = POINT;
MipFilter = POINT;
#line 69
SRGBTexture = true;
};
#line 77
float4 InterlacedVS(in uint id : SV_VertexID) : SV_Position
{
#line 80
const float2 vertexPos[3] = {
float2(-1f, 1f), 
float2(-1f,-3f), 
float2( 3f, 1f)  
};
return float4(vertexPos[id], 0f, 1f);
}
#line 89
void InterlacedTargetPass(
float4 pixelPos   : SV_Position,
out float4 Target : SV_Target
)
{
#line 95
uint2 pixelCoord = uint2(pixelPos.xy);
#line 97
Target.rgb = tex2Dfetch(ReShade::BackBuffer, pixelCoord).rgb;
#line 99
uint offset = uint(4f*tex2Dfetch(BlueNoise::BlueNoiseTexSmp, pixelCoord/64u%64u).r);
offset += framecount;
#line 102
Target.a = tex2Dfetch(BlueNoise::BlueNoiseTexSmp, pixelCoord%64u)[offset%4u];
}
#line 106
float4 InterlacedPS(float4 pixelPos : SV_Position) : SV_Target
{ return tex2Dfetch(InterlacedBufferSampler, uint2(pixelPos.xy)); }
#line 113
technique BlueNoiseMotion
<
ui_label = "Blue Noise Motion Blur";
ui_tooltip =
"It generates 'fake' motion blur, by blending previous frames.\n"
"The smoothness is achieved by incorporating blue noise as a blending pattern.\n"
"\n"
"To get higher quality results, the game should be running at higher FPS.\n"
"\n"
"This effect © 2022-2023 Jakub Maksymilian Fober\n"
"Licensed under CC BY-NC-ND 3.0 +\n"
"for additional permissions see the source code.";
>
{
pass GatherFrames
{
VertexShader = InterlacedVS;
PixelShader = InterlacedTargetPass;
#line 132
RenderTarget = InterlacedTargetBuffer;
#line 134
ClearRenderTargets = false;
SRGBWriteEnable = true; 
#line 137
BlendEnable = true;
BlendOp = ADD; 
SrcBlend = SRCALPHA;
DestBlend = INVSRCALPHA;
}
pass DisplayEffect
{
VertexShader = InterlacedVS;
PixelShader = InterlacedPS;
}
}

