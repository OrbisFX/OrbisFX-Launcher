#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FastSharp.fx"
#line 11
texture TexColor : COLOR;
sampler sTexColor {Texture = TexColor; SRGBTexture = false;};
#line 17
uniform float amount <
ui_type = "slider";
ui_label = "Sharpness intensity";
> = 0.3;
#line 22
uniform float mask_amount <
ui_type = "slider";
ui_label = "halo removal power";
> = 0.5;
#line 27
uniform int size <
ui_type = "combo";
ui_label = "filter";
ui_tooltip = "cross only sharpens the most tiny details, while wide catches coarse details too";
ui_items = "narrow\0wide\0";
> = 1;
#line 39
void VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 49
float3 PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 color = tex2D(sTexColor, texcoord).rgb;
#line 53
float3 s = color;
#line 61
s += tex2D(sTexColor, (float2(texcoord)), int2( 1, 0)).rgb;
s += tex2D(sTexColor, (float2(texcoord)), int2(-1, 0)).rgb;
s += tex2D(sTexColor, (float2(texcoord)), int2( 0, -1)).rgb;
s += tex2D(sTexColor, (float2(texcoord)), int2( 0, 1)).rgb;
#line 66
float3 cross = s;
float3 wide;
if ( size == 1 )
{
s += (tex2D(sTexColor, (float2(texcoord)), int2( 1, 1)).rgb)/2;
s += (tex2D(sTexColor, (float2(texcoord)), int2(-1, 1)).rgb)/2;
s += (tex2D(sTexColor, (float2(texcoord)), int2( 1, -1)).rgb)/2;
s += (tex2D(sTexColor, (float2(texcoord)), int2(-1, -1)).rgb)/2;
#line 75
s += (tex2D(sTexColor, (float2(texcoord)), int2( 0, -2)).rgb)/3;
s += (tex2D(sTexColor, (float2(texcoord)), int2( 0, 2)).rgb)/3;
s += (tex2D(sTexColor, (float2(texcoord)), int2( 2, 0)).rgb)/3;
s += (tex2D(sTexColor, (float2(texcoord)), int2(-2, 0)).rgb)/3;
#line 80
wide = s/8.3333333333333;
}
#line 84
float3 sharpness = color-wide;
#line 86
float3 csharpness = color-(cross/5);
#line 88
float3 sharp = color+(amount*5*sharpness);
#line 90
float3 csharp = color + (amount*5*csharpness);
#line 92
float3 mask = saturate(abs(csharpness*mask_amount*16));
#line 96
if ( size == 1 )
{return lerp(sharp, color, mask);}
else
{return lerp(csharp, color, mask);}
}
#line 105
technique FastSharp
< ui_label = "Fast Sharp";
ui_tooltip = "Fast Adaptive Sharpening Filter."
"        ||By Ehsan2077||        ";>
{
pass MJEhsan_FastSharp
{
VertexShader = VS;
PixelShader = PS;
}
}

