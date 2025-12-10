#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_pastel_bug.fx"
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
#line 17 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_pastel_bug.fx"
#line 21
namespace DH_Pastel_Bug {
#line 25
uniform int iMode <
ui_label = "Mode";
ui_type = "combo";
ui_items = "Dark\0Light\0";
> = 0;
#line 31
uniform float fDarkValue <
ui_category = "Dark mode";
ui_label = "Value 1";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 40
uniform float fDarkWhiteLevel <
ui_category = "Dark mode";
ui_label = "Value 2";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.9;
#line 49
uniform float fLightValue <
ui_category = "Light mode";
ui_label = "Value 1";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.5;
#line 58
uniform float fLightWhiteLevel <
ui_category = "Light mode";
ui_label = "Value 2";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 77
void PS_PastelBug(float4 vpos : SV_Position, in float2 coords : TEXCOORD0, out float4 outPixel : SV_Target)
{
float3 color = tex2D(ReShade::BackBuffer,coords).rgb;
float brightness = max(color.r,max(color.g,color.b));
color += (1.0-brightness);
#line 83
float whiteLevel;
float blackLevel;
#line 86
if(iMode==0) {
whiteLevel = min(fDarkWhiteLevel,0.999);
blackLevel = whiteLevel+max(0.001,fDarkValue)*(1.0-whiteLevel);
} else if(iMode==1) {
whiteLevel = fLightValue+min(fLightWhiteLevel,0.999)*(1.0-fLightValue);
blackLevel = min(fLightValue,0.999);
}
#line 94
color = saturate((color-blackLevel)/(whiteLevel-blackLevel));
#line 96
outPixel = float4(color,1.0);
}
#line 101
technique DH_Pastel_Bug <
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_PastelBug;
}
}
#line 111
}

