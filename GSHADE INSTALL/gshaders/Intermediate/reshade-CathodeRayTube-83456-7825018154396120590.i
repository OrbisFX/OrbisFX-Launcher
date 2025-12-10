#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\CathodeRayTube.fx"
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
#line 8 "C:\Program Files\GShade\gshade-shaders\Shaders\CathodeRayTube.fx"
#line 9
uniform int mask <
ui_label = "Type";
ui_type  = "combo";
ui_items = "Aperture Grille\0Slot Mask\0Shadow Mask\0Bigger Shadow Mask\0";
> = 0;
#line 15
uniform bool blurToggle <
ui_label = "Blur";
> = true;
#line 19
texture AGSUt { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler AGSUs { Texture = AGSUt; AddressU = BORDER; AddressV = BORDER; };
#line 22
texture AGt { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler AGs { Texture = AGt; AddressU = BORDER; AddressV = BORDER; };
#line 25
texture SMSUt { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler SMSUs { Texture = SMSUt; AddressU = BORDER; AddressV = BORDER; };
#line 28
texture SMt { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler SMs { Texture = SMt; AddressU = BORDER; AddressV = BORDER; };
#line 31
texture ShMt { Width = 1920; Height = 1018; Format = RGBA16F; };
sampler ShMs { Texture = ShMt; AddressU = BORDER; AddressV = BORDER; };
#line 34
float3 blur(int radius, float2 texcoord1)
{
int divisor = 0;
float3 blur = float3(0.0, 0.0, 0.0);
#line 39
for(int x = -radius; x <= radius; x++)
{
for(int y = -floor(sqrt(radius * (radius + 1) - x * x)); y <= floor(sqrt(radius * (radius + 1) - x * x)); y++)
{
blur += tex2Dlod(ReShade::BackBuffer, float4(texcoord1.x + ((1.0 / 1920) * x), texcoord1.y + ((1.0 / 1018) * y), 0.0, 0.0)).rgb;
divisor++;
}
}
#line 48
return blur / divisor;
}
#line 51
float3 ApertureGrilleSetUp(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
if((pos.x + 2) % 3 <= 1)
{
if(blurToggle)
{
return blur(2, texcoord);
}
else
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
}
#line 65
return 0;
}
#line 68
float3 ApertureGrille(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float3 color = tex2D(AGSUs, texcoord).rgb
+ tex2D(AGSUs, float2(texcoord.x + (1.0 / 1920), texcoord.y)).rgb
+ tex2D(AGSUs, float2(texcoord.x - (1.0 / 1920), texcoord.y)).rgb;
#line 74
if(pos.x % 3 <= 1 && pos.y % 3 <= 1)
{
return color *= float3(1.0, 0.0, 0.0);
}
if((pos.x + 2) % 3 <= 1 && pos.y % 3 <= 1)
{
return color *= float3(0.0, 1.0, 0.0);
}
if((pos.x + 1) % 3 <= 1 && pos.y % 3 <= 1)
{
return color *= float3(0.0, 0.0, 1.0);
}
#line 87
return 0;
}
#line 90
float3 SlotMaskSetUp(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
if((pos.x + 3) % 4 <= 1)
{
if(blurToggle)
{
return blur(2, texcoord);
}
else
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
}
#line 104
return 0;
}
#line 107
float3 SlotMask(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float3 color = tex2D(SMSUs, texcoord).rgb
+ tex2D(SMSUs, float2(texcoord.x + (1.0 / 1920), texcoord.y)).rgb
+ tex2D(SMSUs, float2(texcoord.x - (1.0 / 1920), texcoord.y)).rgb;
#line 113
if(pos.x % 8 <= 1 && pos.y % 4 <= 1)
{
return color *= float3(1.0, 0.0, 0.0);
}
if((pos.x + 7) % 8 <= 1 && pos.y % 4 <= 1)
{
return color *= float3(0.0, 1.0, 0.0);
}
if((pos.x + 6) % 8 <= 1 && pos.y % 4 <= 1)
{
return color *= float3(0.0, 0.0, 1.0);
}
if((pos.x + 4) % 8 <= 1 && (pos.y + 2) % 4 <= 1)
{
return color *= float3(1.0, 0.0, 0.0);
}
if((pos.x + 11) % 8 <= 1 && (pos.y + 2) % 4 <= 1)
{
return color *= float3(0.0, 1.0, 0.0);
}
if((pos.x + 10) % 8 <= 1 && (pos.y + 2) % 4 <= 1)
{
return color *= float3(0.0, 0.0, 1.0);
}
#line 138
return 0;
}
#line 141
float3 ShadowMask(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float3 color;
#line 145
if(mask == 2)
{
if(blurToggle)
{
color = blur(2, texcoord);
}
else
{
color = tex2D(ReShade::BackBuffer, texcoord).rgb;
}
}
if(mask == 3)
{
if(blurToggle)
{
color = blur(4, texcoord);
}
else
{
color = tex2D(ReShade::BackBuffer, texcoord).rgb;
}
}
#line 168
if(mask == 2)
{
if(pos.x % 6 <= 1 && pos.y % 4 <= 1)
{
return color *= float3(1.0, 0.0, 0.0);
}
if((pos.x + 4) % 6 <= 1 && pos.y % 4 <= 1)
{
return color *= float3(0.0, 1.0, 0.0);
}
if((pos.x + 2) % 6 <= 1 && pos.y % 4 <= 1)
{
return color *= float3(0.0, 0.0, 1.0);
}
if((pos.x + 3) % 6 <= 1 && (pos.y + 2) % 4 <= 1)
{
return color *= float3(1.0, 0.0, 0.0);
}
if((pos.x + 7) % 6 <= 1 && (pos.y + 2) % 4 <= 1)
{
return color *= float3(0.0, 1.0, 0.0);
}
if((pos.x + 5) % 6 <= 1 && (pos.y + 2) % 4 <= 1)
{
return color *= float3(0.0, 0.0, 1.0);
}
}
else if(mask == 3)
{
if(pos.x % 12 <= 1 && pos.y % 6 <= 1)
{
return color *= float3(1.0, 0.0, 0.0);
}
if((pos.x + 8) % 12 <= 1 && pos.y % 6 <= 1)
{
return color *= float3(0.0, 1.0, 0.0);
}
if((pos.x + 4) % 12 <= 1 && pos.y % 6 <= 1)
{
return color *= float3(0.0, 0.0, 1.0);
}
if((pos.x + 6) % 12 <= 1 && (pos.y + 3) % 6 <= 1)
{
return color *= float3(1.0, 0.0, 0.0);
}
if((pos.x + 14) % 12 <= 1 && (pos.y + 3) % 6 <= 1)
{
return color *= float3(0.0, 1.0, 0.0);
}
if((pos.x + 10) % 12 <= 1 && (pos.y + 3) % 6 <= 1)
{
return color *= float3(0.0, 0.0, 1.0);
}
}
#line 223
return 0;
}
#line 226
float3 main(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 230
if(mask == 0)
{
return tex2D(AGs, texcoord).rgb
+ tex2D(AGs, float2(texcoord.x, texcoord.y + (1.0 / 1018))).rgb
+ tex2D(AGs, float2(texcoord.x, texcoord.y - (1.0 / 1018))).rgb;
}
else if(mask == 1)
{
return tex2D(SMs, texcoord).rgb
+ tex2D(SMs, float2(texcoord.x, texcoord.y + (1.0 / 1018))).rgb
+ tex2D(SMs, float2(texcoord.x, texcoord.y - (1.0 / 1018))).rgb;
}
else
{
if(mask == 2)
{
return tex2D(ShMs, texcoord).rgb;
}
else
{
return tex2D(ShMs, texcoord).rgb
+ tex2D(ShMs, float2(texcoord.x + (1.0 / 1920), texcoord.y)).rgb
+ tex2D(ShMs, float2(texcoord.x - (1.0 / 1920), texcoord.y)).rgb
+ tex2D(ShMs, float2(texcoord.x, texcoord.y + (1.0 / 1018))).rgb
+ tex2D(ShMs, float2(texcoord.x, texcoord.y - (1.0 / 1018))).rgb
+ tex2D(ShMs, float2(texcoord.x - ((1.0 / 1920) * 2), texcoord.y)).rgb
+ tex2D(ShMs, float2(texcoord.x, texcoord.y - ((1.0 / 1018) * 2))).rgb
+ tex2D(ShMs, float2(texcoord.x + (1.0 / 1920), texcoord.y - (1.0 / 1018))).rgb
+ tex2D(ShMs, float2(texcoord.x - (1.0 / 1920), texcoord.y + (1.0 / 1018))).rgb
+ tex2D(ShMs, float2(texcoord.x - (1.0 / 1920), texcoord.y - (1.0 / 1018))).rgb
+ tex2D(ShMs, float2(texcoord.x - (1.0 / 1920), texcoord.y - ((1.0 / 1018) * 2))).rgb
+ tex2D(ShMs, float2(texcoord.x - ((1.0 / 1920) * 2), texcoord.y - (1.0 / 1018))).rgb;
}
}
#line 265
return 0;
}
#line 268
technique CathodeRayTube
{
pass pass0
{
VertexShader = PostProcessVS;
PixelShader = ApertureGrilleSetUp;
RenderTarget = AGSUt;
}
pass pass1
{
VertexShader = PostProcessVS;
PixelShader = ApertureGrille;
RenderTarget = AGt;
}
pass pass2
{
VertexShader = PostProcessVS;
PixelShader = SlotMaskSetUp;
RenderTarget = SMSUt;
}
pass pass3
{
VertexShader = PostProcessVS;
PixelShader = SlotMask;
RenderTarget = SMt;
}
pass pass4
{
VertexShader = PostProcessVS;
PixelShader = ShadowMask;
RenderTarget = ShMt;
}
pass pass5
{
VertexShader = PostProcessVS;
PixelShader = main;
}
}

