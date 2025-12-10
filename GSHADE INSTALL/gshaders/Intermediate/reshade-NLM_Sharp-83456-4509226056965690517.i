#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\NLM_Sharp.fx"
#line 54
uniform int Depth_Map <
ui_type = "combo";
ui_items = "Normal\0Reverse\0";
ui_label = "Custom Depth Map";
ui_tooltip = "Pick your Depth Map.";
ui_category = "Depth Buffer";
> = 0;
#line 62
uniform float Depth_Map_Adjust <
ui_type = "slider";
ui_min = 1.0; ui_max = 1000.0; ui_step = 0.125;
ui_label = "Depth Map Adjustment";
ui_tooltip = "Adjust the depth map and sharpness distance.";
ui_category = "Depth Buffer";
> = 250.0;
#line 70
uniform bool Depth_Map_Flip <
ui_label = "Depth Map Flip";
ui_tooltip = "Flip the depth map if it is upside down.";
ui_category = "Depth Buffer";
> = false;
#line 76
uniform bool No_Depth_Map <
ui_label = "No Depth Map";
ui_tooltip = "If you have No Depth Buffer turn this On.";
ui_category = "Depth Buffer";
> = false;
#line 82
uniform float Sharpness <
ui_type = "slider";
ui_label = "Sharpening Strength";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Scaled by adjusting this slider from Zero to One to increase sharpness of the image.\n"
"Zero = No Sharpening, to One = Full Sharpening, and Past One = Extra Crispy.\n"
"Number 0.625 is default.";
ui_category = "Non-Local Means CAS";
> = 0.625;
#line 92
uniform bool CAM_IOB <
ui_label = "CAM Ignore Overbright";
ui_tooltip = "Instead of of allowing Overbright in the mask this allows sharpening of this area.\n"
"I think it's more accurate to turn this on.";
ui_category = "Non-Local Means CAS";
> = false;
#line 99
uniform bool CA_Mask_Boost <
ui_label = "CAM Boost";
ui_tooltip = "This boosts the power of Contrast Adaptive Masking part of the shader.";
ui_category = "Non-Local Means CAS";
> = false;
#line 105
uniform bool CA_Removal <
ui_label = "CAM Removal";
ui_tooltip = "This removes Contrast Adaptive Masking part of the shader.\n"
"This is for people who like the Raw look of Non-Local Means Sharpen.";
ui_category = "Non-Local Means CAS";
> = false;
#line 113
uniform int NLM_Grounding <
ui_type = "combo";
ui_items = "Fine\0Medium\0Coarse\0";
ui_label = "Grounding Type";
ui_tooltip = "Like Coffee pick how rough do you want this shader to be.\n"
"Gives more control of Non-Local Means Sharpen.";
ui_category = "Non-Local Means Filtering";
> = 0;
#line 122
uniform bool Debug_View <
ui_label = "View Mode";
ui_tooltip = "This is used to select the normal view output or debug view.\n"
"Used to see what the shaderis changing in the image.\n"
"Normal gives you the normal out put of this shader.\n"
"Sharp is the full Debug for NLM Sharp.\n"
"Depth Cues is the Shaded output.\n"
"Default is Normal View.";
ui_category = "Debug";
> = 0;
#line 136
texture DepthBufferTex : DEPTH;
#line 138
sampler DepthBuffer
{
Texture = DepthBufferTex;
};
#line 143
texture BackBufferTex : COLOR;
#line 145
sampler BackBuffer
{
Texture = BackBufferTex;
};
#line 151
float Depth(in float2 texcoord : TEXCOORD0)
{
if (Depth_Map_Flip)
texcoord.y =  1 - texcoord.y;
#line 156
float zBuffer = tex2D(DepthBuffer, texcoord).x; 
#line 160
const float Far = 1.0, Near = 0.125/Depth_Map_Adjust; 
#line 162
const float2 Z = float2( zBuffer, 1-zBuffer );
#line 164
if (Depth_Map == 0)
zBuffer = Far * Near / (Far + Z.x * (Near - Far));
else if (Depth_Map == 1)
zBuffer = Far * Near / (Far + Z.y * (Near - Far));
#line 169
return saturate(zBuffer);
}
#line 172
float Min3(float x, float y, float z)
{
return min(x, min(y, z));
}
#line 177
float Max3(float x, float y, float z)
{
return max(x, max(y, z));
}
#line 182
float normaL2(float4 RGB)
{
return pow(RGB.r, 2) + pow(RGB.g, 2) + pow(RGB.b, 2) + pow(RGB.a, 2);
}
#line 187
float4 BB(in float2 texcoord, float2 AD)
{
return tex2Dlod(BackBuffer, float4(texcoord + AD,0,0));
}
#line 192
float LI(float3 RGB)
{
return dot(RGB,float3(0.2126, 0.7152, 0.0722));
}
#line 197
float GT()
{
if (NLM_Grounding == 2)
return 1.5;
else if(NLM_Grounding == 1)
return 1.25;
else
return 1.0;
}
#line 217
float4 CAS(float2 texcoord)
{
#line 225
const float Up = LI(BB(texcoord, float2( 0,-float2((1.0 / 1920), (1.0 / 1018)).y)).rgb);
const float Left = LI(BB(texcoord, float2(-float2((1.0 / 1920), (1.0 / 1018)).x, 0)).rgb);
const float Center = LI(BB(texcoord, 0).rgb);
const float Right = LI(BB(texcoord, float2( float2((1.0 / 1920), (1.0 / 1018)).x, 0)).rgb);
const float Down = LI(BB(texcoord, float2( 0, float2((1.0 / 1920), (1.0 / 1018)).y)).rgb);
#line 231
const float mnRGB = Min3( Min3(Left, Center, Right), Up, Down);
const float mxRGB = Max3( Max3(Left, Center, Right), Up, Down);
#line 235
const float rcpMRGB = rcp(mxRGB);
float RGB_D = saturate(min(mnRGB, 1.0 - mxRGB) * rcpMRGB);
#line 238
if( CAM_IOB )
RGB_D = saturate(min(mnRGB, 2.0 - mxRGB) * rcpMRGB);
#line 242
float sum2;
const float2 RPC_WS = float2((1.0 / 1920), (1.0 / 1018)) * GT();
float4 sum1;
#line 246
for(float y = -1; y <= 1; ++y)
{
for(float x = -1; x <= 1; ++x)
{ 
float dist = 0;
#line 253
for(float ty = -0.5; ty <= 0.5; ++ty)
{
for(float tx = -0.5; tx <= 0.5; ++tx)
{  
const float4 bv = saturate(  BB(texcoord, float2(x + tx, y + ty) * RPC_WS) );
#line 259
const float4 av = saturate(  BB(texcoord, float2(tx, ty) * RPC_WS) );
#line 261
dist += normaL2(av - bv);
}
}
#line 265
float window = exp(dist *  -rcp(10 * 10 * 4) * 500 + (pow(x, 2) + pow(y, 2)) *  -rcp(2 * 1 + 1 * 2 * 1 + 1));
#line 267
sum1 +=  window * saturate( BB(texcoord, float2(x, y) * RPC_WS) ); 
sum2 += window; 
}
}
#line 272
float CAS_Mask = RGB_D;
#line 274
if(CA_Mask_Boost)
CAS_Mask = lerp(CAS_Mask,CAS_Mask * CAS_Mask,saturate(Sharpness * 0.5));
#line 277
if(CA_Removal)
CAS_Mask = 1;
#line 280
return saturate(float4(sum1.rgb / sum2,CAS_Mask));
}
#line 283
float3 Sharpen_Out(float2 texcoord)
{   const float3 Done = tex2D(BackBuffer,texcoord).rgb;
return lerp(Done,Done+(Done - CAS(texcoord).rgb)*(Sharpness*3.1), CAS(texcoord).w * saturate(Sharpness)); 
}
#line 289
float3 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float3 Sharpen = Sharpen_Out(texcoord).rgb,BB = tex2D(BackBuffer,texcoord).rgb;
float DB = Depth(texcoord).r, DBBL = Depth(float2(texcoord.x*2,texcoord.y*2-1)).r;
const float DBTL = Depth(float2(texcoord.x*2,texcoord.y*2)).r;
#line 295
if(No_Depth_Map)
{
DB = 0.0;
DBBL = 0.0;
}
#line 301
if (Debug_View == 0)
return lerp(Sharpen, BB, DB);
else
{
const float3 Top_Left = lerp(float3(1.,1.,1.),CAS(float2(texcoord.x*2,texcoord.y*2)).www,1-DBTL);
#line 307
const float3 Top_Right =  Depth(float2(texcoord.x*2-1,texcoord.y*2)).rrr;
#line 309
const float3 Bottom_Left = lerp(float3(1., 0., 1.),tex2D(BackBuffer,float2(texcoord.x*2,texcoord.y*2-1)).rgb,DBBL);
#line 311
const float3 Bottom_Right = CAS(float2(texcoord.x*2-1,texcoord.y*2-1)).rgb;
#line 313
float3 VA_Top;
if (texcoord.x < 0.5)
VA_Top = Top_Left;
else
VA_Top = Top_Right;
#line 319
float3 VA_Bottom;
if (texcoord.x < 0.5)
VA_Bottom = Bottom_Left;
else
VA_Bottom = Bottom_Right;
#line 325
if (texcoord.y < 0.5)
return VA_Top;
else
return VA_Bottom;
}
}
#line 335
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 342
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 347
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 351
technique NLM_Sharp
< ui_tooltip = "Suggestion : You Can Enable 'Performance Mode Checkbox,' in the lower bottom right of the ReShade's Main UI.\n"
"             Do this once you set your Smart Sharp settings of course."; >
{
pass UnsharpMask
{
VertexShader = PostProcessVS;
PixelShader = Out;
}
}

