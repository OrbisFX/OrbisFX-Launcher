#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\SmartDeNoise.fx"
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
#line 28 "C:\Program Files\GShade\gshade-shaders\Shaders\SmartDeNoise.fx"
#line 29
uniform float uSigma <
ui_label = "Standard Deviation Sigma Radius";
ui_tooltip = "Standard Deviation Sigma Radius * K Factor Sigma Coefficient = Radius of the circular kernel.";
ui_type = "slider";
ui_min = 0.001;
ui_max = 8.0;
ui_step = 0.001;
> = 1.25;
uniform float uThreshold <
ui_label = "Edge Sharpening Threshold";
ui_type = "slider";
ui_min = 0.001;
ui_max = 0.25;
ui_step = 0.001;
> = 0.05;
uniform float uKSigma <
ui_label = "K Factor Sigma Coefficient";
ui_tooltip = "Standard Deviation Sigma Radius * K Factor Sigma Coefficient = Radius of the circular kernel.";
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
ui_step = 0.001;
> = 1.5;
#line 65
void PS_SmartDeNoise (in float4 pos : SV_Position, float2 uv : TEXCOORD, out float4 color : SV_Target)
{
const float radius = round(uKSigma * uSigma);
const float radQ = radius * radius;
#line 70
const float invSigmaQx2 = .5 / (uSigma * uSigma);      
const float invSigmaQx2PI = 0.31830988618379067153776752674503 * invSigmaQx2;    
#line 73
const float invThresholdSqx2 = .5 / (uThreshold * uThreshold);     
const float invThresholdSqrt2PI = 0.39894228040143267793994605993439 / uThreshold;   
#line 76
const float4 centrPx = tex2D(ReShade::BackBuffer, uv);
#line 78
float zBuff = 0.0;
float4 aBuff = float4(0.0, 0.0, 0.0, 0.0);
const float2 size = ReShade::GetScreenSize();
#line 82
float2 d;
for (d.x =- radius; d.x <= radius; d.x++) {
float pt = sqrt(radQ - d.x * d.x);       
for (d.y =- pt; d.y <= pt; d.y++) {
float4 walkPx =  tex2Dlod(ReShade::BackBuffer, float4(uv + d / size, 0.0, 0.0));
float4 dC = walkPx - centrPx;
float deltaFactor = exp(-dot(dC, dC) * invThresholdSqx2) * invThresholdSqrt2PI * (exp(-dot(d , d) * invSigmaQx2) * invSigmaQx2PI);
#line 90
zBuff += deltaFactor;
aBuff += deltaFactor * walkPx;
}
}
color = aBuff / zBuff;
}
#line 165
technique SmartDeNoise {
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_SmartDeNoise;
}
}

