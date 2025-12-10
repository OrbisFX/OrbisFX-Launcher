#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\M_Sharp.fx"
#line 47
uniform int Depth_Map <
ui_type = "combo";
ui_items = "Normal\0Reverse\0";
ui_label = "Custom Depth Map";
ui_tooltip = "Pick your Depth Map.";
ui_category = "Depth Buffer";
> = 0;
#line 55
uniform float Depth_Map_Adjust <
ui_type = "slider";
ui_min = 1.0; ui_max = 1000.0; ui_step = 0.125;
ui_label = "Depth Map Adjustment";
ui_tooltip = "Adjust the depth map and sharpness distance.";
ui_category = "Depth Buffer";
> = 250.0;
#line 63
uniform bool Depth_Map_Flip <
ui_label = "Depth Map Flip";
ui_tooltip = "Flip the depth map if it is upside down.";
ui_category = "Depth Buffer";
> = false;
#line 69
uniform bool No_Depth_Map <
ui_label = "No Depth Map";
ui_tooltip = "If you have No Depth Buffer turn this On.";
ui_category = "Depth Buffer";
> = false;
#line 75
uniform float Sharpness <
ui_type = "slider";
ui_label = "Sharpening Strength";
ui_min = 0.0; ui_max = 1.25;
ui_tooltip = "Scaled by adjusting this slider from Zero to One to increase sharpness of the image.\n"
"Zero = No Sharpening, to One = Full Sharpening, and Past One = Extra Crispy.\n"
"Number 0.625 is default.";
ui_category = "Median CAS";
> = 0.625;
#line 85
uniform bool CA_Mask_Boost <
ui_label = "CAM Boost";
ui_tooltip = "This boosts the power of Contrast Adaptive Masking part of the shader.";
ui_category = "Median CAS";
> = false;
#line 91
uniform int Debug_View <
ui_type = "combo";
ui_items = "Normal View\0Sharp Debug\0Z-Buffer Debug\0";
ui_label = "View Mode";
ui_tooltip = "This is used to select the normal view output or debug view.\n"
"Used to see what the shaderis changing in the image.\n"
"Normal gives you the normal out put of this shader.\n"
"Sharp is the full Debug for Smart sharp.\n"
"Depth Cues is the Shaded output.\n"
"Z-Buffer id Depth Buffer only.\n"
"Default is Normal View.";
ui_category = "Debug";
> = 0;
#line 108
texture DepthBufferTex : DEPTH;
#line 110
sampler DepthBuffer
{
Texture = DepthBufferTex;
};
#line 115
texture BackBufferTex : COLOR;
#line 117
sampler BackBuffer
{
Texture = BackBufferTex;
};
#line 123
float Depth(in float2 texcoord : TEXCOORD0)
{
if (Depth_Map_Flip)
texcoord.y =  1 - texcoord.y;
#line 128
float zBuffer = tex2D(DepthBuffer, texcoord).x; 
#line 132
const float Far = 1.0, Near = 0.125/Depth_Map_Adjust; 
#line 134
const float2 Z = float2( zBuffer, 1-zBuffer );
#line 136
if (Depth_Map == 0)
zBuffer = Far * Near / (Far + Z.x * (Near - Far));
else if (Depth_Map == 1)
zBuffer = Far * Near / (Far + Z.y * (Near - Far));
#line 141
return saturate(zBuffer);
}
#line 144
float3 BB(in float2 texcoord, float2 AD)
{
return tex2Dlod(BackBuffer, float4(texcoord + AD,0,0)).rgb;
}
#line 158
float4 MCAS(float2 texcoord)
{
const float2 ScreenCal = float2((1.0 / 1920), (1.0 / 1018));
#line 163
const float2 FinCal = ScreenCal*0.6;
#line 165
float3 v[9];
#line 167
[unroll]
for(int i = -1; i <= 1; ++i)
{
[unroll]
for(int j = -1; j <= 1; ++j)
{
const float2 offset = float2(i, j);
#line 175
v[(i + 1) * 3 + (j + 1)] = BB( texcoord , offset * FinCal);
}
}
#line 179
float3 temp;
#line 181
temp = v[0]; v[0] = min(v[0], v[3]); v[3] = max(temp, v[3]);; temp = v[1]; v[1] = min(v[1], v[4]); v[4] = max(temp, v[4]);; temp = v[2]; v[2] = min(v[2], v[5]); v[5] = max(temp, v[5]);; temp = v[0]; v[0] = min(v[0], v[1]); v[1] = max(temp, v[1]);; temp = v[0]; v[0] = min(v[0], v[2]); v[2] = max(temp, v[2]);;; temp = v[4]; v[4] = min(v[4], v[5]); v[5] = max(temp, v[5]);; temp = v[3]; v[3] = min(v[3], v[5]); v[5] = max(temp, v[5]);;;;
temp = v[1]; v[1] = min(v[1], v[2]); v[2] = max(temp, v[2]);; temp = v[3]; v[3] = min(v[3], v[4]); v[4] = max(temp, v[4]);; temp = v[1]; v[1] = min(v[1], v[3]); v[3] = max(temp, v[3]);; temp = v[1]; v[1] = min(v[1], v[6]); v[6] = max(temp, v[6]);;; temp = v[4]; v[4] = min(v[4], v[6]); v[6] = max(temp, v[6]);; temp = v[2]; v[2] = min(v[2], v[6]); v[6] = max(temp, v[6]);;;;
temp = v[2]; v[2] = min(v[2], v[3]); v[3] = max(temp, v[3]);; temp = v[4]; v[4] = min(v[4], v[7]); v[7] = max(temp, v[7]);; temp = v[2]; v[2] = min(v[2], v[4]); v[4] = max(temp, v[4]);; temp = v[3]; v[3] = min(v[3], v[7]); v[7] = max(temp, v[7]);;;
temp = v[4]; v[4] = min(v[4], v[8]); v[8] = max(temp, v[8]);; temp = v[3]; v[3] = min(v[3], v[8]); v[8] = max(temp, v[8]);;; temp = v[3]; v[3] = min(v[3], v[4]); v[4] = max(temp, v[4]);;;
#line 186
const float3 rcpMRGB = abs(v[0] - BB( texcoord ,0));
float3 ampRGB = saturate(rcpMRGB);
#line 190
ampRGB = sqrt(ampRGB);
#line 192
float CAS_Mask = 1-length(ampRGB);
#line 194
if(CA_Mask_Boost)
CAS_Mask = lerp(CAS_Mask,CAS_Mask * CAS_Mask,saturate(Sharpness * 0.5));
#line 197
return saturate(float4(v[4],CAS_Mask));
}
#line 200
float3 Sharpen_Out(float2 texcoord)
{   const float3 Done = BB(texcoord ,0);
return lerp(Done,Done+(Done - MCAS(texcoord).rgb)*(Sharpness*3.), MCAS(texcoord).w * saturate(Sharpness)); 
}
#line 206
float3 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float3 Sharpen = Sharpen_Out(texcoord).rgb,BB = tex2D(BackBuffer,texcoord).rgb;
float DB = Depth(texcoord).r, DBBL = Depth(float2(texcoord.x*2,texcoord.y*2-1)).r;
const float DBTL = Depth(float2(texcoord.x*2,texcoord.y*2)).r;
#line 212
if(No_Depth_Map)
{
DB = 0.0;
DBBL = 0.0;
}
#line 218
if (Debug_View == 0)
{
return lerp(Sharpen, BB, DB);
}
else if (Debug_View == 1)
{
const float3 Top_Left = lerp(float3(1.,1.,1.),MCAS(float2(texcoord.x*2,texcoord.y*2)).www,1-DBTL);
#line 226
const float3 Top_Right =  Depth(float2(texcoord.x*2-1,texcoord.y*2)).rrr;
#line 228
const float3 Bottom_Left = lerp(float3(1., 0., 1.),tex2D(BackBuffer,float2(texcoord.x*2,texcoord.y*2-1)).rgb,DBBL);
#line 230
const float3 Bottom_Right = MCAS(float2(texcoord.x*2-1,texcoord.y*2-1)).rgb;
#line 232
float3 VA_Top;
if (texcoord.x < 0.5)
VA_Top = Top_Left;
else
VA_Top = Top_Right;
#line 238
float3 VA_Bottom;
if (texcoord.x < 0.5)
VA_Bottom = Bottom_Left;
else
VA_Bottom = Bottom_Right;
#line 244
if (texcoord.y < 0.5)
return VA_Top;
else
return VA_Bottom;
}
else
return Depth(texcoord);
}
#line 256
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 263
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 268
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 272
technique Median_Sharp
{
pass UnsharpMask
{
VertexShader = PostProcessVS;
PixelShader = Out;
}
}

