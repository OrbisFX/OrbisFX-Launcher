// UiShadowNumBlurs=2
// UiShadowNumDilations=1
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\UIShadow.fx"
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
#line 12 "C:\Program Files\GShade\gshade-shaders\Shaders\UIShadow.fx"
#line 18
uniform int iUIShadowNumDialations <
ui_type = "slider";
ui_label = "Shadow Radius";
ui_min = 0;
ui_max = 2;
ui_tooltip = "Expands and contracts the shadow radius.";
ui_bind = "UiShadowNumDilations";
> = 1;
#line 33
uniform int iUIShadowNumBlurs <
ui_type = "slider";
ui_label = "Blur Strength";
ui_min = 0;
ui_max = 3;
ui_tooltip = "Adjusts the blur strength.";
ui_bind = "UiShadowNumBlurs";
> = 2;
#line 62
texture2D shadowTex < pooled = true; > { Width = 1280; Height = 720; Format = R8; };
texture2D shadowTexPong { Width = 1280; Height = 720; Format = R8; };
#line 65
sampler2D texNearest
{
Texture = ReShade::BackBufferTex;
AddressU = CLAMP;
AddressV = CLAMP;
AddressW = CLAMP;
MagFilter = POINT;
MinFilter = POINT;
MipFilter = POINT;
MinLOD = 0.0f;
MaxLOD = 1000.0f;
MipLODBias = 0.0f;
SRGBTexture = false;
};
#line 80
sampler2D shadowSampler
{
Texture = shadowTex;
AddressU = CLAMP;
AddressV = CLAMP;
AddressW = CLAMP;
MagFilter = LINEAR;
MinFilter = LINEAR;
MipFilter = LINEAR;
MinLOD = 0.0f;
MaxLOD = 1000.0f;
MipLODBias = 0.0f;
SRGBTexture = false;
};
#line 95
sampler2D shadowPongSampler
{
Texture = shadowTexPong;
AddressU = CLAMP;
AddressV = CLAMP;
AddressW = CLAMP;
MagFilter = LINEAR;
MinFilter = LINEAR;
MipFilter = LINEAR;
MinLOD = 0.0f;
MaxLOD = 1000.0f;
MipLODBias = 0.0f;
SRGBTexture = false;
};
#line 128
float calcUIBorder(float2 texcoord) {
const int2 pixelCoord = texcoord * float2(1280, 720);
#line 132
const float4 ul = float4(tex2DgatherA(ReShade::BackBuffer, texcoord - 0.5 * float2((1.0 / 1280), (1.0 / 720))).rba, tex2Dfetch(ReShade::BackBuffer, pixelCoord + int2(-1, 1)).a);
const float4 lr = float4(tex2DgatherA(ReShade::BackBuffer, texcoord + 0.5 * float2((1.0 / 1280), (1.0 / 720))).rgb, tex2Dfetch(ReShade::BackBuffer, pixelCoord + int2( 1,-1)).a);
#line 136
float brd = max(max(ul.r, ul.g), max(ul.b, ul.a));
brd = max(max(max(lr.r, lr.g), max(lr.b, lr.a)), brd);
#line 140
return float((tex2Dfetch(texNearest, pixelCoord).a < 1) && (brd >= 1));
}
#line 144
float4 PS_UISH(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return float4(calcUIBorder(texcoord), 0, 0, 0);
}
#line 149
float4 PS_SHSH(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float s = 1.0 - tex2D(shadowPongSampler, texcoord).r; 
const float4 c = tex2D(texNearest, texcoord);
return float4 (lerp(s*c.rgb, c.rgb, c.a), c.a); 
}
#line 157
float4 PS_DilateShadowA(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 tmp = tex2DgatherR(shadowSampler, texcoord - 0.5 * float2((1.0 / 1280), (1.0 / 720)));
float output = max(max(tmp.r, tmp.g), max(tmp.b, tmp.a));
tmp = tex2DgatherR(shadowSampler, texcoord + 0.5 * float2((1.0 / 1280), (1.0 / 720)));
output = max(max(max(tmp.r, tmp.g), max(tmp.b, tmp.a)), output);
tmp = tex2DgatherR(shadowSampler, texcoord + float2(0.5, -0.5) * float2((1.0 / 1280), (1.0 / 720)));
output = max(max(max(tmp.r, tmp.g), max(tmp.b, tmp.a)), output);
tmp = tex2DgatherR(shadowSampler, texcoord + float2(-0.5, 0.5) * float2((1.0 / 1280), (1.0 / 720)));
output = max(max(max(tmp.r, tmp.g), max(tmp.b, tmp.a)), output);
#line 168
return float4(output, 0, 0, 0);
}
#line 171
float4 PS_DilateShadowB(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 tmp = tex2DgatherR(shadowPongSampler, texcoord - 0.5 * float2((1.0 / 1280), (1.0 / 720)));
float output = max(max(tmp.r, tmp.g), max(tmp.b, tmp.a));
tmp = tex2DgatherR(shadowPongSampler, texcoord + 0.5 * float2((1.0 / 1280), (1.0 / 720)));
output = max(max(max(tmp.r, tmp.g), max(tmp.b, tmp.a)), output);
tmp = tex2DgatherR(shadowPongSampler, texcoord + float2(0.5, -0.5) * float2((1.0 / 1280), (1.0 / 720)));
output = max(max(max(tmp.r, tmp.g), max(tmp.b, tmp.a)), output);
tmp = tex2DgatherR(shadowPongSampler, texcoord + float2(-0.5, 0.5) * float2((1.0 / 1280), (1.0 / 720)));
output = max(max(max(tmp.r, tmp.g), max(tmp.b, tmp.a)), output);
#line 182
return float4(output, 0, 0, 0);
}
#line 189
float4 PS_BlurA(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float output = dot(tex2DgatherR(shadowPongSampler, texcoord - 0.5 * float2((1.0 / 1280), (1.0 / 720))), float4(1,1,1,1));
output += dot(tex2DgatherR(shadowPongSampler, texcoord + 0.5 * float2((1.0 / 1280), (1.0 / 720))), float4(1,1,1,1));
output += dot(tex2DgatherR(shadowPongSampler, texcoord + float2(0.5, -0.5) * float2((1.0 / 1280), (1.0 / 720))), float4(1,1,1,1));
output += dot(tex2DgatherR(shadowPongSampler, texcoord + float2(-0.5, 0.5) * float2((1.0 / 1280), (1.0 / 720))), float4(1,1,1,1));
#line 196
return float4(output * 0.0625, 0, 0, 0);
}
#line 200
float4 PS_BlurB(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float output = dot(tex2DgatherR(shadowSampler, texcoord - 0.5 * float2((1.0 / 1280), (1.0 / 720))), float4(1,1,1,1));
output += dot(tex2DgatherR(shadowSampler, texcoord + 0.5 * float2((1.0 / 1280), (1.0 / 720))), float4(1,1,1,1));
output += dot(tex2DgatherR(shadowSampler, texcoord + float2(0.5, -0.5) * float2((1.0 / 1280), (1.0 / 720))), float4(1,1,1,1));
output += dot(tex2DgatherR(shadowSampler, texcoord + float2(-0.5, 0.5) * float2((1.0 / 1280), (1.0 / 720))), float4(1,1,1,1));
#line 207
return float4(output * 0.0625, 0, 0, 0);
}
#line 210
technique UIShadowShader
{
pass FindUIEdge
{
VertexShader = PostProcessVS;
PixelShader = PS_UISH;
RenderTarget = shadowTex;
}
#line 219
pass DilateShadow
{
VertexShader = PostProcessVS;
PixelShader = PS_DilateShadowA;
RenderTarget = shadowTexPong;
}
#line 235
pass BlurShadow1
{
VertexShader = PostProcessVS;
PixelShader = PS_BlurA;
RenderTarget = shadowTex;
}
#line 243
pass BlurShadow2
{
VertexShader = PostProcessVS;
PixelShader = PS_BlurB;
RenderTarget = shadowTexPong;
}
#line 258
pass AddUIShadow
{
VertexShader = PostProcessVS;
PixelShader = PS_SHSH;
}
}

