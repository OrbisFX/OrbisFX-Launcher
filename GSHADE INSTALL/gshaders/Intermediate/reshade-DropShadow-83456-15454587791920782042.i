// DROPSHADOW_QUANTITY=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\DropShadow.fx"
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
#line 37 "C:\Program Files\GShade\gshade-shaders\Shaders\DropShadow.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\DropShadow.fxh"
#line 38 "C:\Program Files\GShade\gshade-shaders\Shaders\DropShadow.fx"
#line 39
uniform int DropShadowQuantity <
ui_type = "combo";
ui_label = "Number of Drop Shadows";
ui_tooltip = "The number of DropShadow techniques to generate. Enabling too many of these in a DirectX 9 game or on lower end hardware is a very, very bad idea.";
ui_items =  "1\0"
"2\0"
"3\0"
"4\0"
"5\0";
ui_bind = "DROPSHADOW_QUANTITY";
> = 0;
#line 55
texture DropShadow_Texture { Width = 1920; Height = 1018; Format=RGBA8; }; sampler DropShadow_Sampler { Texture = DropShadow_Texture; AddressU = CLAMP; AddressV = CLAMP; }; uniform float fTargetDepth < ui_category = "DropShadow"; ui_type = "slider"; ui_label = "Target Depth"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001; > = 0.02; uniform float4 fColor < ui_category = "DropShadow"; ui_label = "Color"; ui_type = "color"; > = float4(0, 1.0, 0, 1.0); uniform float fPosX < ui_category = "DropShadow"; ui_type = "slider"; ui_label = "Position X"; ui_min = -2.0; ui_max = 2.0; ui_step = 0.001; > = 0.505; uniform float fPosY < ui_category = "DropShadow"; ui_type = "slider"; ui_label = "Position Y"; ui_min = -2.0; ui_max = 2.0; ui_step = 0.001; > = 0.5; uniform float fPosXY < ui_category = "DropShadow"; ui_type = "slider"; ui_label = "Scale X & Y"; ui_min = 0.001; ui_max = 5.0; ui_step = 0.001; > = 1.001; uniform float fScaleX < ui_category = "DropShadow"; ui_type = "slider"; ui_label = "Scale X"; ui_min = 0.001; ui_max = 5.0; ui_step = 0.001; > = 1.0; uniform float fScaleY < ui_category = "DropShadow"; ui_type = "slider"; ui_label = "Scale Y"; ui_min = 0.001; ui_max = 5.0; ui_step = 0.001; > = 1.0; uniform float fCutoffMaxX < ui_category = "DropShadow"; ui_type = "slider"; ui_label = "X Cutoff Max"; ui_min = 0.001; ui_max = 1.0; ui_step = 0.001; > = 1.0; uniform float fCutoffMinX < ui_category = "DropShadow"; ui_type = "slider"; ui_label = "X Cutoff Min"; ui_min = 0.001; ui_max = 1.0; ui_step = 0.001; > = 0.0; uniform float fCutoffMaxY < ui_category = "DropShadow"; ui_type = "slider"; ui_label = "Y Cutoff Max"; ui_min = 0.001; ui_max = 1.0; ui_step = 0.001; > = 1.0; uniform float fCutoffMinY < ui_category = "DropShadow"; ui_type = "slider"; ui_label = "Y Cutoff Min"; ui_min = 0.001; ui_max = 1.0; ui_step = 0.001; > = 0.0; uniform int iSnapRotate < ui_category = "DropShadow"; ui_type = "combo"; ui_label = "Snap Rotation"; ui_items = "None\0" "90 Degrees\0" "-90 Degrees\0" "180 Degrees\0" "-180 Degrees\0"; ui_tooltip = "Snap rotation to a specific angle."; > = false; uniform float iRotate < ui_category = "DropShadow"; ui_label = "Rotate"; ui_type = "slider"; ui_min = -180.0; ui_max = 180.0; ui_step = 0.01; > = 0; void PS_DropShadowBack(in float4 pos : SV_Position, float2 texCoord : TEXCOORD, out float4 passColor : SV_Target) { if (ReShade::GetLinearizedDepth(texCoord) < fTargetDepth) { passColor = fColor; } else { passColor = 0.0; } } void PS_DropShadow(in float4 pos : SV_Position, float2 texCoord : TEXCOORD, out float4 passColor : SV_Target) { if (ReShade::GetLinearizedDepth(texCoord) > fTargetDepth && texCoord.x <= fCutoffMaxX && texCoord.x >= fCutoffMinX && texCoord.y <= fCutoffMaxY && texCoord.y >= fCutoffMinY) { const float3 pivot = float3(0.5, 0.5, 0.0); const float3 mulUV = float3(texCoord.x, texCoord.y, 1); const float2 ScaleSize = (float2(1920, 1018) * fPosXY); const float ScaleX = ScaleSize.x * fScaleX; const float ScaleY = ScaleSize.y * fScaleY; float Rotate = iRotate * (3.1415926 / 180.0); switch(iSnapRotate) { default: break; case 1: Rotate = -90.0 * (3.1415926 / 180.0); break; case 2: Rotate = 90.0 * (3.1415926 / 180.0); break; case 3: Rotate = 0.0; break; case 4: Rotate = 180.0 * (3.1415926 / 180.0); break; } const float3x3 positionMatrix = float3x3 ( 1, 0, 0, 0, 1, 0, -fPosX, -fPosY, 1 ); const float3x3 scaleMatrix = float3x3 ( 1/ScaleX, 0, 0, 0, 1/ScaleY, 0, 0, 0, 1 ); const float3x3 rotateMatrix = float3x3 ( cos (Rotate), -sin(Rotate), 0, sin(Rotate), cos(Rotate), 0, 0, 0, 1 ); const float3 SumUV = mul (mul (mul (mulUV, positionMatrix) * float3(float2(1920, 1018), 1.0), rotateMatrix), scaleMatrix); const float4 backColor = tex2D(ReShade::BackBuffer, texCoord); passColor = tex2D(DropShadow_Sampler, SumUV.rg + pivot.rg) * all(SumUV + pivot == saturate(SumUV + pivot)); passColor = lerp(backColor.rgb, passColor.rgb, passColor.a); } else { discard; } } technique DropShadow { pass { VertexShader = PostProcessVS; PixelShader = PS_DropShadowBack; RenderTarget = DropShadow_Texture; } pass { VertexShader = PostProcessVS; PixelShader = PS_DropShadow; } }

