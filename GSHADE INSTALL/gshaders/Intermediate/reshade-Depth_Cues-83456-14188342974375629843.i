#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Depth_Cues.fx"
#line 35
uniform int Depth_Map <
ui_type = "combo";
ui_items = "Normal\0Reverse\0";
ui_label = "Custom Depth Map";
ui_tooltip = "Pick your Depth Map.";
ui_category = "Depth Buffer";
> = 0;
#line 43
uniform float Depth_Map_Adjust <
ui_type = "slider";
ui_min = 1.0; ui_max = 1000.0; ui_step = 0.125;
ui_label = "Depth Map Adjustment";
ui_tooltip = "Adjust the depth map and sharpness distance.";
ui_category = "Depth Buffer";
> = 250.0;
#line 51
uniform bool Depth_Map_Flip <
ui_label = "Depth Map Flip";
ui_tooltip = "Flip the depth map if it is upside down.";
ui_category = "Depth Buffer";
> = false;
#line 57
uniform bool DEPTH_DEBUG <
ui_label = "View Depth";
ui_tooltip = "Shows depth, you want close objects to be black and far objects to be white for things to work properly.";
ui_category = "Depth Buffer";
> = false;
#line 63
uniform bool No_Depth_Map <
ui_label = "No Depth Map";
ui_tooltip = "If you have No Depth Buffer turn this On.";
ui_category = "Depth Buffer";
> = false;
#line 69
uniform float Shade_Power <
ui_type = "slider";
ui_min = 0.25; ui_max = 1.0;
ui_label = "Shade Power";
ui_tooltip = "Adjust the Shade Power This improves AO, Shadows, & Darker Areas in game.\n"
"Number 0.625 is default.";
ui_category = "Depth Cues";
> = 0.625;
#line 78
uniform float Blur_Cues <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Blur Shade";
ui_tooltip = "Adjust the to make Shade Softer in the Image.\n"
"Number 0.5 is default.";
ui_category = "Depth Cues";
> = 0.5;
#line 87
uniform float Spread <
ui_type = "slider";
ui_min = 1.0; ui_max = 25.0; ui_step = 0.25;
ui_label = "Shade Fill";
ui_tooltip = "Adjust This to have the shade effect to fill in areas gives fakeAO effect.\n"
"This is used for gap filling.\n"
"Number 7.5 is default.";
ui_category = "Depth Cues";
> = 12.5;
#line 97
uniform bool Debug_View <
ui_label = "Depth Cues Debug";
ui_tooltip = "Depth Cues Debug output the shadeded output.";
ui_category = "Depth Cues";
> = false;
#line 123
texture DepthBufferTex : DEPTH;
#line 125
sampler DepthBuffer
{
Texture = DepthBufferTex;
};
#line 130
texture BackBufferTex : COLOR;
#line 132
sampler BackBuffer
{
Texture = BackBufferTex;
};
#line 137
texture texHB { Width = 1920  * 0.5 ; Height = 1018 * 0.5 ; Format = R8; MipLevels = 1;};
#line 139
sampler SamplerHB
{
Texture = texHB;
};
#line 144
texture texDC { Width = 1920; Height = 1018; Format = R8; MipLevels = 3;};
#line 146
sampler SamplerDC
{
Texture = texDC;
};
#line 152
float Depth(in float2 texcoord : TEXCOORD0)
{
if (Depth_Map_Flip)
texcoord.y =  1 - texcoord.y;
#line 157
float zBuffer = tex2D(DepthBuffer, texcoord).x; 
#line 161
const float Far = 1.0, Near = 0.125/Depth_Map_Adjust; 
#line 163
const float2 Z = float2( zBuffer, 1-zBuffer );
#line 165
if (Depth_Map == 0)
zBuffer = Far * Near / (Far + Z.x * (Near - Far));
else if (Depth_Map == 1)
zBuffer = Far * Near / (Far + Z.y * (Near - Far));
#line 170
return saturate(zBuffer);
}
#line 173
float3 BB(in float2 texcoord, float2 AD)
{
#line 180
return tex2Dlod(BackBuffer, float4(texcoord + AD,0,0)).rgb;
}
#line 183
float H_Blur(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float S = Spread * 1.0 * 0.125;
#line 187
float3 sum = BB(texcoord,0).rgb * 12;
#line 189
float total = 12;
#line 191
for ( int j = -12; j <= 12; ++j)
{
float W = 12;
#line 195
sum += BB(texcoord , + float2(float2((1.0 / 1920), (1.0 / 1018)).x * S,0) * j ) * W;
#line 197
total += W;
}
return dot(sum / total, float3(0.2126, 0.7152, 0.0722) ); 
}
#line 203
float DepthCues(float2 texcoord)
{
float2 S = Spread * 1.0 * 0.75f * float2((1.0 / 1920), (1.0 / 1018));
#line 207
const float M_Cues = 1;
float result = tex2Dlod(SamplerHB,float4(texcoord,0,M_Cues)).x;
result += tex2Dlod(SamplerHB,float4(texcoord + float2( 1, 0) * S ,0,M_Cues)).x;
result += tex2Dlod(SamplerHB,float4(texcoord + float2( 0, 1) * S ,0,M_Cues)).x;
result += tex2Dlod(SamplerHB,float4(texcoord + float2(-1, 0) * S ,0,M_Cues)).x;
result += tex2Dlod(SamplerHB,float4(texcoord + float2( 0,-1) * S ,0,M_Cues)).x;
S *= 0.5;
result += tex2Dlod(SamplerHB,float4(texcoord + float2( 1, 0) * S ,0,M_Cues)).x;
result += tex2Dlod(SamplerHB,float4(texcoord + float2( 0, 1) * S ,0,M_Cues)).x;
result += tex2Dlod(SamplerHB,float4(texcoord + float2(-1, 0) * S ,0,M_Cues)).x;
result += tex2Dlod(SamplerHB,float4(texcoord + float2( 0,-1) * S ,0,M_Cues)).x;
result *= rcp(9);
#line 221
const float DC = (dot(BB(texcoord,0),float3(0.2126, 0.7152, 0.0722)) / result );
return lerp(1.0f,saturate(DC),Shade_Power);
}
#line 225
float DC(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return DepthCues(texcoord); 
}
#line 230
float3 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float DCB = tex2Dlod(SamplerDC,float4(texcoord,0,Blur_Cues * 1.0)).x;
const float3 DC = DCB.xxx , BBN = tex2D(BackBuffer,texcoord).rgb;
float DB = Depth(texcoord).r;
#line 236
if(No_Depth_Map)
{
DB = 0.0;
}
#line 241
if (Debug_View)
return lerp(DC,1., DB);
#line 244
if (DEPTH_DEBUG)
return DB;
#line 247
return BBN * lerp(DC,1., DB);
}
#line 253
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 260
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 265
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 269
technique Monocular_Cues
{
#line 272
pass Blur
{
VertexShader = PostProcessVS;
PixelShader = H_Blur;
RenderTarget = texHB;
}
pass BlurDC
{
VertexShader = PostProcessVS;
PixelShader = DC;
RenderTarget = texDC;
}
pass UnsharpMask
{
VertexShader = PostProcessVS;
PixelShader = Out;
}
}

