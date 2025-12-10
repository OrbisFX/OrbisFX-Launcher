// cLayerCCTex="cLayerCCA.png"
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorChart.fx"
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
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\ColorChart.fx"
#line 42
uniform int cLayerCC_Mode <
ui_type = "combo";
ui_label = "Mode";
ui_items =
"Standard\0"
"with Gray Chart\0"
"Simple\0";
> = false;
#line 51
uniform float cLayerCC_Scale <
ui_type = "slider";
ui_spacing = 1;
ui_label = "Scale";
ui_min = 0.5; ui_max = 1.0;
ui_step = 0.001;
> = 0.770;
#line 60
uniform float cLayerCC_PosX <
ui_type = "slider";
ui_label = "Position X";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.100;
#line 67
uniform float cLayerCC_PosY <
ui_type = "slider";
ui_label = "Position Y";
ui_min = 0.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.500;
#line 74
uniform float Color_Chart_Brightness <
ui_type = "slider";
ui_label = "Brightness";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.00;
#line 81
uniform float Color_Chart_Saturation <
ui_type = "slider";
ui_label = "Saturation";
ui_min = -1.0; ui_max = 1.0;
ui_step = 0.001;
> = 0.00;
#line 99
texture Color_Chart_Texture <
source = "color_chart_afternov2014_d50_srgb.png";
> {
Width = 1920;
Height = 1018;
Format = RGBA8;
};
#line 107
texture Color_Chart_BG_S_Texture <
source = "color_chart_afternov2014_d50_srgb_bg_s.png";
> {
Width = 1920;
Height = 1018;
Format = RGBA8;
};
#line 115
texture Gray_Chart_Texture <
source = "color_chart_gray_chart_2_line.png";
> {
Width = 1920;
Height = 1018;
Format = RGBA8;
};
#line 123
texture Color_Chart_BG_Texture <
source = "color_chart_afternov2014_d50_srgb_bg.png";
> {
Width = 1920;
Height = 1018;
Format = RGBA8;
};
#line 132
sampler Color_Chart_Sampler {
Texture = Color_Chart_Texture;
AddressU = CLAMP;
AddressV = CLAMP;
};
#line 138
sampler Color_Chart_BG_Sampler {
Texture = Color_Chart_BG_Texture;
AddressU = CLAMP;
AddressV = CLAMP;
};
#line 145
sampler Gray_Chart_Sampler {
Texture = Gray_Chart_Texture;
AddressU = CLAMP;
AddressV = CLAMP;
};
#line 152
sampler Color_Chart_BG_S_Sampler {
Texture = Color_Chart_BG_S_Texture;
AddressU = CLAMP;
AddressV = CLAMP;
};
#line 163
float getLum( in float3 x )
{
return dot( x, float3( 0.212656, 0.715158, 0.072186 ));
}
#line 168
float3 bri(float3 Tex1, float x)
{
#line 171
const float3 c = 1.0f - ( 1.0f - Tex1.rgb ) * ( 1.0f - Tex1.rgb );
if (x < 0.0f) {
x = x * 0.5f;
}
return saturate( lerp( Tex1.rgb, c.rgb, x ));
}
#line 178
float3 sat( float3 Tex1, float x )
{
return saturate(lerp(getLum(Tex1.rgb), Tex1.rgb, x + 1.0 ));
}
#line 185
void PS_cLayerCC(in float4 pos : SV_Position, float2 texCoord : TEXCOORD, out float4 passColor : SV_Target) {
const float3 pivot = float3(0.5, 0.5, 0.0);
const float3 mulUV = float3(texCoord.x, texCoord.y, 1);
const float2 ScaleSize = (float2(600.0, 400.0) * cLayerCC_Scale / float2(1920, 1018));
const float ScaleX =  ScaleSize.x *  cLayerCC_Scale;
const float ScaleY =  ScaleSize.y *  cLayerCC_Scale;
#line 193
const float3x3 positionMatrix = float3x3 (
1, 0, 0,
0, 1, 0,
-cLayerCC_PosX, -cLayerCC_PosY, 1
);
#line 200
const float3x3 scaleMatrix = float3x3 (
1/ScaleX, 0, 0,
0,  1/ScaleY, 0,
0, 0, 1
);
#line 207
const float3 SumUV = mul (mul (mulUV, positionMatrix), scaleMatrix);
const float4 backColor = tex2D(ReShade::BackBuffer, texCoord);
float4 Tex1 = tex2D(Color_Chart_Sampler, SumUV.rg + pivot.rg) * all(SumUV + pivot == saturate(SumUV + pivot));
if (Color_Chart_Brightness != 0.0f) {
Tex1.rgb = bri(Tex1.rgb, Color_Chart_Brightness);
}
if (Color_Chart_Saturation != 0.0f) {
Tex1.rgb = sat(Tex1.rgb, Color_Chart_Saturation);
}
const float4 Tex2 = tex2D(Color_Chart_BG_Sampler, SumUV.rg + pivot.rg) * all(SumUV + pivot == saturate(SumUV + pivot));
switch(cLayerCC_Mode)
{
default:
const float4 Tex3 = tex2D(Color_Chart_BG_S_Sampler, SumUV.rg + pivot.rg).r * all(SumUV + pivot == saturate(SumUV + pivot));
passColor = lerp(backColor.rgb, Tex3.rgb, Tex3.a);
passColor = lerp(passColor.rgb, Tex1.rgb, Tex1.a);
break;
case 1:
passColor = lerp(backColor.rgb, Tex2.rgb, Tex2.a);
passColor = lerp(passColor.rgb, Tex1.rgb, Tex1.a);
const float4 Tex4 = tex2D(Gray_Chart_Sampler, SumUV.rg + pivot.rg) * all(SumUV + pivot == saturate(SumUV + pivot));
passColor = lerp(passColor.rgb, Tex4.rgb, Tex4.a);
break;
case 2:
passColor = lerp(backColor.rgb, Tex1.rgb, Tex1.a);
break;
}
passColor = float4(lerp(backColor.rgb, passColor.rgb, Tex2.a).rgb, backColor.a);
}
#line 241
technique Color_Chart < ui_label = "Color Chart (Hidden In Screenshots)";
ui_tooltip = "     Display a color chart like used for\n"
"     color grading work in video/cinema production.\n"
"     Can be useful to see effect that\n"
"     presets and shaders affect on to colors.\n\n"
"     This technique WILL NOT be shown in screenshots.";
enabled_in_screenshot = false; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_cLayerCC;
}
}
#line 256
technique Color_Chart_S < ui_label = "Color Chart (Visible In Screenshots)";
ui_tooltip = "     Display a color chart like used for\n"
"     color grading work in video/cinema production.\n"
"     Can be useful to see effect that\n"
"     presets and shaders affect on to colors.\n\n"
"     This technique WILL be shown in screenshots.";
enabled_in_screenshot = true; >
{
pass
{
VertexShader = PostProcessVS;
PixelShader  = PS_cLayerCC;
}
}

