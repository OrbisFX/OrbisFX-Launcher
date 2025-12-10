// CENSOR_QUANTITY=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Censor.fx"
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
#line 27 "C:\Program Files\GShade\gshade-shaders\Shaders\Censor.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Censor.fxh"
#line 28 "C:\Program Files\GShade\gshade-shaders\Shaders\Censor.fx"
#line 29
uniform int Censor_Quantity <
ui_type = "combo";
ui_label = "Number of Censors";
ui_tooltip = "The number of Censor techniques to generate. Enabling too many of these in a DirectX 9 game or on lower end hardware is a very, very bad idea.";
ui_items =  "1\0"
"2\0"
"3\0"
"4\0"
"5\0"
"6\0"
"7\0"
"8\0"
"9\0"
"10\0"
"11\0"
"12\0"
"13\0"
"14\0"
"15\0"
"16\0"
"17\0"
"18\0"
"19\0"
"20\0";
ui_bind = "CENSOR_QUANTITY";
> = 0;
#line 60
uniform float Censor_Opacity < ui_category = "Censor 1"; ui_category_closed = true; ui_label = "Opacity"; ui_tooltip = "The transparency of the censor."; ui_type = "slider"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.002; > = 1.0; uniform float Censor_Depth < ui_category = "Censor 1"; ui_type = "slider"; ui_min = 0.0; ui_max = 1.0; ui_label = "Depth"; > = 0.97; uniform int Censor_Cell_Size < ui_category = "Censor 1"; ui_type = "slider"; ui_min = 2; ui_max = 48; ui_label = "Cell Size"; > = 4; uniform float Censor_Smoothness_Average < ui_category = "Censor 1"; ui_type = "slider"; ui_min = 0.0; ui_max = 1.0; ui_label = "Smoothness"; > = 0.333; uniform float Censor_Scale < ui_category = "Censor 1"; ui_type = "slider"; ui_label = "Scale X & Y"; ui_min = 0.001; ui_max = 5.0; ui_step = 0.001; > = 1.001; uniform float Censor_ScaleX < ui_category = "Censor 1"; ui_type = "slider"; ui_label = "Scale X"; ui_min = 0.001; ui_max = 5.0; ui_step = 0.001; > = 1.0; uniform float Censor_ScaleY < ui_category = "Censor 1"; ui_type = "slider"; ui_label = "Scale Y"; ui_min = 0.001; ui_max = 5.0; ui_step = 0.001; > = 1.0; uniform float Censor_PosX < ui_category = "Censor 1"; ui_type = "slider"; ui_label = "Position X"; ui_min = -2.0; ui_max = 2.0; ui_step = 0.001; > = 0.5; uniform float Censor_PosY < ui_category = "Censor 1"; ui_type = "slider"; ui_label = "Position Y"; ui_min = -2.0; ui_max = 2.0; ui_step = 0.001; > = 0.5; uniform int Censor_SnapRotate < ui_category = "Censor 1"; ui_type = "combo"; ui_label = "Snap Rotation"; ui_items = "None\0" "90 Degrees\0" "-90 Degrees\0" "180 Degrees\0" "-180 Degrees\0"; ui_tooltip = "Snap rotation to a specific angle."; > = false; uniform float Censor_Rotate < ui_category = "Censor 1"; ui_label = "Rotate"; ui_type = "slider"; ui_min = -180.0; ui_max = 180.0; ui_step = 0.01; > = 0; uniform bool Censor_InvertDepth < ui_category = "Censor 1"; ui_label = "Invert Depth"; ui_tooltip = "Inverts the depth buffer so that the censor is applied to the foreground instead."; > = false; void PS_Censor(in float4 position : SV_Position, in float2 texCoord : TEXCOORD, out float4 passColor : SV_Target) { const float depth = Censor_InvertDepth ? ReShade::GetLinearizedDepth(texCoord).r : 1 - ReShade::GetLinearizedDepth(texCoord).r; if (depth < Censor_Depth) { const float3 backColor = tex2D(ReShade::BackBuffer, texCoord).rgb; const float3 pivot = float3(0.5, 0.5, 0.0); const float3 mulUV = float3(texCoord.x, texCoord.y, 1); const float2 ScaleSize = (float2(1920, 1018) * Censor_Scale); const float ScaleX = ScaleSize.x * Censor_ScaleX; const float ScaleY = ScaleSize.y * Censor_ScaleY; float Rotate = Censor_Rotate * (3.1415926 / 180.0); const int2 pixcoord = floor((float2(1920, 1018) * texCoord) / Censor_Cell_Size) * Censor_Cell_Size; passColor = tex2D(ReShade::BackBuffer, ((pixcoord) + 0.5) * float2((1.0 / 1920), (1.0 / 1018))); if(Censor_Smoothness_Average > 0.1) { const float step = Censor_Cell_Size * 0.25; float4 avg_color = 0.0; [unroll] for( int x = 0 ; x < 4 ; ++x ) [unroll] for( int y = 0 ; y < 4 ; ++y ) avg_color += tex2Dlod(ReShade::BackBuffer, float4((float2(pixcoord.x + (x * step), pixcoord.y + (y * step)) + 0.5) * float2((1.0 / 1920), (1.0 / 1018)), 0.0, 0.0)); avg_color *= 0.0625; passColor = (avg_color * Censor_Smoothness_Average) + (passColor * (1.0 - Censor_Smoothness_Average)); } switch(Censor_SnapRotate) { default: break; case 1: Rotate = -90.0 * (3.1415926 / 180.0); break; case 2: Rotate = 90.0 * (3.1415926 / 180.0); break; case 3: Rotate = 0.0; break; case 4: Rotate = 180.0 * (3.1415926 / 180.0); break; } const float3x3 positionMatrix = float3x3 ( 1, 0, 0, 0, 1, 0, -Censor_PosX, -Censor_PosY, 1 ); const float3x3 scaleMatrix = float3x3 ( 1/ScaleX, 0, 0, 0, 1/ScaleY, 0, 0, 0, 1 ); const float3x3 rotateMatrix = float3x3 ( cos (Rotate), -sin(Rotate), 0, sin(Rotate), cos(Rotate), 0, 0, 0, 1 ); const float3 SumUV = mul (mul (mul (mulUV, positionMatrix) * float3(float2(1920, 1018), 1.0), rotateMatrix), scaleMatrix); passColor *= all(SumUV + pivot == saturate(SumUV + pivot)); passColor.rgb = lerp(backColor, passColor.rgb, passColor.a * Censor_Opacity); } else { passColor = tex2D(ReShade::BackBuffer, texCoord); } } technique Censor { pass { VertexShader = PostProcessVS; PixelShader = PS_Censor; } }

