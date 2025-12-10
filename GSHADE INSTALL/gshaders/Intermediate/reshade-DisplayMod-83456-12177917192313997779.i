#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\DisplayMod.fx"
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
#line 27 "C:\Program Files\GShade\gshade-shaders\Shaders\DisplayMod.fx"
#line 28
uniform float Display_Scale <
ui_type = "slider";
ui_label = "Scale X & Y";
ui_min = 0.001; ui_max = 5.0;
ui_step = 0.001;
> = 1.001;
#line 35
uniform float Display_ScaleX <
ui_type = "slider";
ui_label = "Scale X";
ui_min = 0.001; ui_max = 5.0;
ui_step = 0.001;
> = 1.0;
#line 42
uniform float Display_ScaleY <
ui_type = "slider";
ui_label = "Scale Y";
ui_min = 0.001; ui_max = 5.0;
ui_step = 0.001;
> = 1.0;
#line 49
uniform float Display_PosX <
ui_type = "slider";
ui_label = "Position X";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 56
uniform float Display_PosY <
ui_type = "slider";
ui_label = "Position Y";
ui_min = -2.0; ui_max = 2.0;
ui_step = 0.001;
> = 0.5;
#line 63
uniform int Display_SnapRotate <
ui_type = "combo";
ui_label = "Snap Rotation";
ui_items = "None\0"
"90 Degrees\0"
"-90 Degrees\0"
"180 Degrees\0"
"-180 Degrees\0";
ui_tooltip = "Snap rotation to a specific angle.";
> = false;
#line 74
uniform float Display_Rotate <
ui_label = "Rotate";
ui_type = "slider";
ui_min = -180.0;
ui_max = 180.0;
ui_step = 0.01;
> = 0;
#line 82
void PS_DisplayMod(in float4 position : SV_Position, in float2 texCoord : TEXCOORD, out float4 passColor : SV_Target)
{
const float3 pivot = float3(0.5, 0.5, 0.0);
const float3 mulUV = float3(texCoord.x, texCoord.y, 1);
const float2 ScaleSize = (float2(1920, 1018) * Display_Scale);
const float ScaleX =  ScaleSize.x * Display_ScaleX;
const float ScaleY =  ScaleSize.y * Display_ScaleY;
float Rotate = Display_Rotate * (3.1415926 / 180.0);
#line 91
switch(Display_SnapRotate)
{
default:
break;
case 1:
Rotate = -90.0 * (3.1415926 / 180.0);
break;
case 2:
Rotate = 90.0 * (3.1415926 / 180.0);
break;
case 3:
Rotate = 0.0;
break;
case 4:
Rotate = 180.0 * (3.1415926 / 180.0);
break;
case 5:
Rotate = -180.0 * (3.1415926 / 180.0);
break;
}
#line 112
const float3x3 positionMatrix = float3x3 (
1, 0, 0,
0, 1, 0,
-Display_PosX, -Display_PosY, 1
);
const float3x3 scaleMatrix = float3x3 (
1/ScaleX, 0, 0,
0,  1/ScaleY, 0,
0, 0, 1
);
const float3x3 rotateMatrix = float3x3 (
cos (Rotate), -sin(Rotate), 0,
sin(Rotate), cos(Rotate), 0,
0, 0, 1
);
#line 128
const float3 SumUV = mul (mul (mul (mulUV, positionMatrix) * float3(float2(1920, 1018), 1.0), rotateMatrix), scaleMatrix);
passColor = tex2D(ReShade::BackBuffer, SumUV.rg + pivot.rg) * all(SumUV + pivot == saturate(SumUV + pivot));
}
#line 132
technique DisplayMod
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_DisplayMod;
}
}

