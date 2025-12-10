#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\NFAA.fx"
#line 25
uniform int AA_Adjust <
ui_type = "slider";
ui_min = 1; ui_max = 32;
ui_label = "AA Power";
ui_tooltip = "Use this to adjust the AA power.\nDefault is 16";
ui_category = "NFAA";
> = 16;
#line 33
uniform int View_Mode <
ui_type = "combo";
ui_items = "NFAA\0Mask View\0Normals\0DLSS\0";
ui_label = "View Mode";
ui_tooltip = "This is used to select the normal view output or debug view.\nNFAA Masked gives you a sharper image with applyed Normals AA.\nMasked View gives you a view of the edge detection.\nNormals gives you an view of the normals created.\nDLSS is NV_AI_DLSS Parody experiance.\nDefault is NFAA.";
ui_category = "NFAA";
> = 0;
#line 41
uniform float Mask_Adjust <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_label = "Mask Adjustment";
ui_tooltip = "Use this to adjust the Mask.\nDefault is 1.00";
ui_category = "NFAA";
> = 1.00;
#line 52
texture BackBufferTex : COLOR;
#line 54
sampler BackBuffer
{
Texture = BackBufferTex;
};
#line 61
float LI(in float3 value)
{
return dot(value.rgb,float3(0.333, 0.333, 0.333));
}
#line 66
float4 GetBB(float2 texcoord : TEXCOORD)
{
return tex2D(BackBuffer, texcoord);
}
#line 71
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 NFAA; 
float2 UV = texcoord.xy, SW = float2((1.0 / 1920), (1.0 / 1018)), n; 
float t, l, r, d;
#line 77
t = LI(GetBB( float2( UV.x , UV.y - SW.y ) ).rgb);
d = LI(GetBB( float2( UV.x , UV.y + SW.y ) ).rgb);
l = LI(GetBB( float2( UV.x - SW.x , UV.y ) ).rgb);
r = LI(GetBB( float2( UV.x + SW.x , UV.y ) ).rgb);
n = float2(t - d,-(r - l));
#line 84
float   nl = length(n), Rep = rcp(AA_Adjust);
#line 86
if(View_Mode == 3)
Rep = rcp(128);
#line 89
if (nl < Rep)
{
NFAA = GetBB(UV);
}
else
{
n *= float2((1.0 / 1920), (1.0 / 1018)) / (nl * 0.5);
#line 97
const float4   o = GetBB( UV ),
t0 = GetBB( UV + float2(n.x, -n.y)  * 0.5) * 0.9,
t1 = GetBB( UV - float2(n.x, -n.y)  * 0.5) * 0.9,
t2 = GetBB( UV + n * 0.9) * 0.75,
t3 = GetBB( UV - n * 0.9) * 0.75;
#line 103
NFAA = (o + t0 + t1 + t2 + t3) / 4.3;
}
#line 106
float Mask = nl*(2.5 * Mask_Adjust);
#line 108
if (Mask > 0.025)
Mask = 1-Mask;
else
Mask = 1;
#line 113
Mask = saturate(lerp(Mask,1,-1));
#line 116
if(View_Mode == 0)
{
NFAA = lerp(NFAA,GetBB( texcoord.xy ), Mask );
}
else if(View_Mode == 1)
{
NFAA = Mask;
}
else if (View_Mode == 2)
{
NFAA = float3(-float2(-(r - l),-(t - d)) * 0.5 + 0.5,1);
}
#line 129
return NFAA;
}
#line 135
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 142
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 147
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 151
technique Normal_Filter_Anti_Aliasing
{
pass NFAA_Fast
{
VertexShader = PostProcessVS;
PixelShader = Out;
}
}

