#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\HoleFiller.fx"
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
#line 11 "C:\Program Files\GShade\gshade-shaders\Shaders\HoleFiller.fx"
#line 17
texture2D TexColor : COLOR;
sampler  sTexColor {Texture = TexColor; };
#line 20
texture2D TexDDepth { Width = 1920; Height = 1018; Format = R16f;};
sampler  sTexDDepth {Texture = TexDDepth; };
#line 23
texture2D TexCColor { Width = 1920; Height = 1018; Format = RGBA8;};
sampler  sTexCColor {Texture = TexCColor; };
#line 29
uniform float T <
ui_label = "Depth Threshold";
ui_Tooltip = "Increase to prevent depth shifting";
ui_type = "slider";
> = 0.1;
#line 35
uniform bool Thin <
ui_label = "Keep Edges";
ui_type = "radio";
> = 1;
#line 42
float3 Color( in float2 texcoord)
{
return tex2D(sTexColor, texcoord).rgb;
}
#line 47
float Depth( in float2 texcoord)
{
return ReShade::GetLinearizedDepth(texcoord);
}
#line 57
float3 Fuck( float4 Postion : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
float2 p = float2((1.0 / 1920), (1.0 / 1018));;
float3 o = float3(-1, 0, 1);
#line 62
float3 sColor[5];
float  sDepth[5];
#line 71
sColor[0] = Color(texcoord + o.yz*p);
sColor[1] = Color(texcoord + o.xy*p);
sColor[2] = Color(texcoord + o.yy*p);
sColor[3] = Color(texcoord + o.zy*p);
sColor[4] = Color(texcoord + o.yx*p);
#line 77
sDepth[0] = Depth(texcoord + o.yz*p);
sDepth[1] = Depth(texcoord + o.xy*p);
sDepth[2] = Depth(texcoord + o.yy*p);
sDepth[3] = Depth(texcoord + o.zy*p);
sDepth[4] = Depth(texcoord + o.yx*p);
#line 83
float Weight;
float3 C = sColor[3];
#line 86
if( sDepth[2] > sDepth[0]+T ) {Weight += 1; C += sColor[0];}
if( sDepth[2] > sDepth[1]+T ) {Weight += 1; C += sColor[1];}
if( sDepth[2] > sDepth[3]+T ) {Weight += 1; C += sColor[3];}
if( sDepth[2] > sDepth[4]+T ) {Weight += 1; C += sColor[4];}
#line 91
float W = Weight; if(Thin) if(Weight <= 1) W = 0;
#line 93
C = lerp(sColor[2], C/(Weight+1), W/4);
#line 95
return C;
}
#line 101
technique HoleFiller
{
pass
{
VertexShader = PostProcessVS;
PixelShader =  Fuck;
}
}

