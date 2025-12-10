// SMOOTH_BLUR_EDGES=1
// #pragma warning (disable : 3571)
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Volumetric Fog V2.0.fx"
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
#line 17 "C:\Program Files\GShade\gshade-shaders\Shaders\Volumetric Fog V2.0.fx"
#line 25
texture OGColTex { Width = 1920; Height = 1018; Format = RGBA8; };
sampler sOGColTex { Texture = OGColTex; };
#line 31
uniform float radius <
ui_label = "Radius";
ui_type = "slider";
ui_min = 0.000;
ui_max = 1.0;
ui_tooltip = "Blurriness of the fog. \n_SMOOTH_BLUR_EDGES also the affects the blur radius a little.";
> = 0.50;
#line 39
uniform float power <
ui_label = "Power";
ui_type = "slider";
ui_min = 0.000;
ui_max = 1.0;
ui_tooltip = "Visibility of the fog.";
> = 0.50;
#line 47
uniform float boost <
ui_label = "Boost";
ui_type = "slider";
ui_min = 1;
ui_max = 10;
ui_tooltip = "Brightness of the fog.";
> = 1;
#line 55
uniform float3 abscolor <
ui_label = "Absorption Color";
ui_type = "color";
> = float3(0.5,0.5,0.5);
#line 60
uniform int BM <
ui_label = "Blend Mode";
ui_type = "combo";
ui_items = "Hard Light\0Soft Light\0";
> = 0;
#line 66
uniform bool debug <>;
#line 69
uniform int Hints<
ui_text =
"\nSMOOTH_BLUR_EDGES can go from 0 to 5. values higher than 5 "
"behave the same as 5. Higher values smooth the filter and "
"increase the overall blur quality at the cost of lower performance.";
#line 75
ui_category = "PreProcessor Definitions Tooltip";
ui_category_closed = true;
ui_label = " ";
ui_type = "radio";
>;
#line 84
float4 Atrous(inout float4 color, in float2 texcoord, in float Radius)
{
float2 t, p; float DG, Depth, Determinator;
#line 88
Depth = ReShade::GetLinearizedDepth(texcoord);
Determinator = Depth-0.1;
p = float2((1.0 / 1920), (1.0 / 1018));; p *= Radius*Depth*8;
#line 92
[unroll]for(int x = -1; x <= 1; x++){
[unroll]for(int y = -1; y <= 1; y++){
t = texcoord + float2(x,y)*p;
DG = ReShade::GetLinearizedDepth(t);
if(DG > Determinator)
color += float4(tex2D(ReShade::BackBuffer, t).rgb, 1);
}}
return color;
}
#line 102
float3 HardLight( inout float3 Blend, in float3 Target)
{
if(BM == 0)
Blend = (Blend > 0.5) * (1 - (1-Target) * (1-2*(Blend-0.5))) +
(Blend <= 0.5) * (Target * (2*Blend));
#line 108
if(BM == 1)
Blend = (Blend > 0.5) * (1 - (1-Target) * (1-(Blend-0.5))) +
(Blend <= 0.5) * (Target * (Blend+0.5));;
#line 112
return Blend;
}
#line 120
void OGColTexOut(float4 vpos : SV_Position, float2 texcoord : TexCoord, out float4 OGCol : SV_Target0)
{
OGCol = tex2D(ReShade::BackBuffer, texcoord).rgba;
}
#line 125
float3 Filter00(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float4 color;
#line 129
Atrous( color, texcoord, 81*saturate(radius*1)).rgb;
return color.rgb/color.a;
}
#line 133
float3 Filter0(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float4 color;
#line 137
Atrous( color, texcoord, 27*saturate(radius*3)).rgb;
return color.rgb/color.a;
}
#line 141
float3 Filter1(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float4 color;
#line 145
Atrous( color, texcoord, 9*saturate(radius*9)).rgb;
return color.rgb/color.a;
}
#line 149
float3 Filter2(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float4 color;
#line 153
Atrous( color, texcoord, 3*saturate(radius*27)).rgb;
return color.rgb/color.a;
}
#line 157
float3 Filter3(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float4 color;
#line 161
Atrous( color, texcoord, 1*saturate(radius*81)).rgb;
return color.rgb/color.a;
}
#line 165
float3 OutColor(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
float3 Background = tex2D( sOGColTex, texcoord).rgb;
float Depth = ReShade::GetLinearizedDepth(texcoord);
#line 171
color = color / (( 1 + 1 / boost) - color);
#line 173
lerp( color, HardLight( color, abscolor), Depth*power);
#line 175
if(!debug){
return lerp( Background, color.rgb, pow(saturate(Depth), (1-power)));
} else{ return color.rgb;}
}
#line 183
technique VolumetricFogV2 <
ui_label = "Volumetric Fog V2 - alpha";
ui_tooltip = "Screen Space Indirect Volumetric Lighting - Version 2.0\n"
"                    ||By Ehsan2077||                    \n"
"SSIVL V2 uses a different technique so no need for TFAA.\n";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = OGColTexOut;
RenderTarget0 = OGColTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = Filter00;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = Filter0;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = Filter1;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = Filter2;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = Filter3;
}
#line 250
pass
{
VertexShader = PostProcessVS;
PixelShader = Filter3;
}
#line 256
pass
{
VertexShader = PostProcessVS;
PixelShader = OutColor;
}
}

