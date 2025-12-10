#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\BIAA.fx"
#line 20
uniform float AA_Power <
ui_type = "slider";
ui_min = 0.5; ui_max = 1;
ui_label = "AA Power";
ui_tooltip = "Use this to adjust the AA power.\n"
"Default is 0.75";
ui_category = "BIAA";
> = 0.75;
#line 29
uniform int View_Mode <
ui_type = "combo";
ui_items = "BIAA\0Mask View\0";
ui_label = "View Mode";
ui_tooltip = "This is used to select the normal view output or debug view.\n"
"Masked View gives you a view of the edge detection.\n"
"Default is BIAA.";
ui_category = "BIAA";
> = 0;
#line 39
uniform float Mask_Adjust <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Mask Adjustment";
ui_tooltip = "Use this to adjust the Mask.\n"
"Default is 0.5";
ui_category = "BIAA";
> = 0.375;
#line 58
texture BackBufferTex : COLOR;
#line 60
sampler BackBuffer
{
Texture = BackBufferTex;
};
#line 67
float LI(in float4 value)
{
return dot(value.rgb,float3(0.333, 0.333, 0.333));
}
#line 72
float2 EdgeDetection(float2 TC, float2 offset)
{
const float2 X = float2(offset.x,0), Y = float2(0,offset.y);
#line 77
const float Left = LI( tex2D(BackBuffer, TC-X ) ) + LI( tex2D(BackBuffer, TC-X ) );
const float Right = LI( tex2D(BackBuffer, TC+X ) ) + LI( tex2D(BackBuffer, TC+X ) );
#line 80
const float Up = LI( tex2D(BackBuffer, TC-Y ) ) + LI( tex2D(BackBuffer, TC-Y ) );
const float Down = LI( tex2D(BackBuffer, TC+Y ) ) + LI( tex2D(BackBuffer, TC+Y ) );
#line 83
return float2(Down-Up,Right-Left) * 0.5;
}
#line 86
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 Done = float4(tex2D(BackBuffer, texcoord).rgb,1.0);
float3 result = tex2D(BackBuffer, texcoord).rgb * (1.0-AA_Power);
const float2 Offset = float2((1.0 / 1920), (1.0 / 1018));
const float2 X = float2(float2((1.0 / 1920), (1.0 / 1018)).x, 0.0), Y = float2(0.0, float2((1.0 / 1920), (1.0 / 1018)).y);
#line 94
float2 Edge = EdgeDetection(texcoord, Offset);
#line 97
float2 N = float2(Edge.x,-Edge.y);
#line 100
Edge += EdgeDetection( texcoord -X, Offset);
Edge += EdgeDetection( texcoord +X, Offset);
Edge += EdgeDetection( texcoord -Y, Offset);
Edge += EdgeDetection( texcoord +Y, Offset);
Edge += EdgeDetection( texcoord -X -Y, Offset);
Edge += EdgeDetection( texcoord -X +Y, Offset);
Edge += EdgeDetection( texcoord +X -Y, Offset);
Edge += EdgeDetection( texcoord +X +Y, Offset);
#line 110
const float Mask = length(N) < pow(0.002, Mask_Adjust);
#line 113
if ( Mask )
{
result = tex2D(BackBuffer, texcoord).rgb;
}
else
{
#line 121
N = float2(Edge.x,-Edge.y);
#line 125
const float AA_Adjust = AA_Power * rcp(6);
result += tex2D(BackBuffer, texcoord+(N * 0.5)*Offset).rgb * AA_Adjust;
result += tex2D(BackBuffer, texcoord-(N * 0.5)*Offset).rgb * AA_Adjust;
result += tex2D(BackBuffer, texcoord+(N * 0.25)*Offset).rgb * AA_Adjust;
result += tex2D(BackBuffer, texcoord-(N * 0.25)*Offset).rgb * AA_Adjust;
result += tex2D(BackBuffer, texcoord+N*Offset).rgb * AA_Adjust;
result += tex2D(BackBuffer, texcoord-N*Offset).rgb * AA_Adjust;
}
#line 135
if (View_Mode == 0)
Done = float4(result,1.0);
else
Done = lerp(float4(1.0,0.0,1.0,1.0),Done,saturate(Mask));
#line 140
return Done;
}
#line 146
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 153
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 158
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 162
technique Bilinear_Interpolation_Anti_Aliasing
{
pass BIAA
{
VertexShader = PostProcessVS;
PixelShader = Out;
}
}

