#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Deblur.fx"
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
#line 22 "C:\Program Files\GShade\gshade-shaders\Shaders\Deblur.fx"
#line 23
static const float3  dt = float3(1.0,1.0,1.0);
#line 25
uniform float OFFSET <
ui_type = "slider";
ui_min = 0.5; ui_max = 2.0;
ui_label = "Filter Width";
ui_tooltip = "Filter Width";
> = 1.0;
#line 32
uniform float DBL <
ui_type = "slider";
ui_min = 1.0; ui_max = 9.0;
ui_label = "Deblur Strength";
ui_tooltip = "Deblur Strength";
> = 6.0;
#line 39
uniform float SMART <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Smart Deblur";
ui_tooltip = "Smart Deblur intensity";
> = 0.7;
#line 46
float3 DEB(float4 pos : SV_Position, float2 uv : TexCoord) : SV_Target
{
#line 49
const float2 inv_size = OFFSET * float2((1.0 / 1920), (1.0 / 1018));
#line 51
const float2 dx = float2(inv_size.x,0.0);
const float2 dy = float2(0.0, inv_size.y);
const float2 g1 = float2(inv_size.x,inv_size.y);
const float2 g2 = float2(-inv_size.x,inv_size.y);
#line 56
const float2 pC4 = uv;
#line 59
const float3 c00 = tex2D(ReShade::BackBuffer,pC4 - g1).rgb;
const float3 c10 = tex2D(ReShade::BackBuffer,pC4 - dy).rgb;
const float3 c20 = tex2D(ReShade::BackBuffer,pC4 - g2).rgb;
const float3 c01 = tex2D(ReShade::BackBuffer,pC4 - dx).rgb;
float3 c11 = tex2D(ReShade::BackBuffer,pC4     ).rgb;
const float3 c21 = tex2D(ReShade::BackBuffer,pC4 + dx).rgb;
const float3 c02 = tex2D(ReShade::BackBuffer,pC4 + g2).rgb;
const float3 c12 = tex2D(ReShade::BackBuffer,pC4 + dy).rgb;
const float3 c22 = tex2D(ReShade::BackBuffer,pC4 + g1).rgb;
#line 69
float3 d11 = c11;
#line 71
float3 mn1 = min (min (c00,c01),c02);
const float3 mn2 = min (min (c10,c11),c12);
const float3 mn3 = min (min (c20,c21),c22);
float3 mx1 = max (max (c00,c01),c02);
const float3 mx2 = max (max (c10,c11),c12);
const float3 mx3 = max (max (c20,c21),c22);
#line 78
mn1 = min(min(mn1,mn2),mn3);
mx1 = max(max(mx1,mx2),mx3);
float3 contrast = mx1 - mn1;
float m = max(max(contrast.r,contrast.g),contrast.b);
#line 83
float DB1 = DBL; float dif;
#line 85
float3 dif1 = abs(c11-mn1) + 0.0001; float3 df1 = pow(dif1,float3(DB1,DB1,DB1));
float3 dif2 = abs(c11-mx1) + 0.0001; float3 df2 = pow(dif2,float3(DB1,DB1,DB1));
#line 88
dif1 *= dif1*dif1;
dif2 *= dif2*dif2;
#line 91
const float3 df = df1/(df1 + df2);
const float3 ratio = abs(dif1-dif2)/(dif1+dif2);
d11 = lerp(c11, lerp(mn1,mx1,df), ratio);
#line 95
c11 = lerp(c11, d11, saturate(2.0*m-0.125));
#line 97
d11 = lerp(d11,c11,SMART);
#line 99
return d11;
}
#line 102
technique Deblur
{
pass
{
VertexShader = PostProcessVS;
PixelShader = DEB;
}
}

