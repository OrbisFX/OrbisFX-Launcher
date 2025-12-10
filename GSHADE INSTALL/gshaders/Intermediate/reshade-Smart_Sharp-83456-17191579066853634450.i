#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Smart_Sharp.fx"
#line 60
uniform int Depth_Map <
ui_type = "combo";
ui_items = "Normal\0Reverse\0";
ui_label = "Custom Depth Map";
ui_tooltip = "Pick your Depth Map.";
ui_category = "Depth Buffer";
> = 0;
#line 68
uniform float Depth_Map_Adjust <
ui_type = "slider";
ui_min = 1.0; ui_max = 1000.0; ui_step = 0.125;
ui_label = "Depth Map Adjustment";
ui_tooltip = "Adjust the depth map and sharpness distance.";
ui_category = "Depth Buffer";
> = 250.0;
#line 76
uniform bool Depth_Map_Flip <
ui_label = "Depth Map Flip";
ui_tooltip = "Flip the depth map if it is upside down.";
ui_category = "Depth Buffer";
> = false;
#line 82
uniform bool No_Depth_Map <
ui_label = "No Depth Map";
ui_tooltip = "If you have No Depth Buffer turn this On.";
ui_category = "Depth Buffer";
> = false;
#line 88
uniform float Sharpness <
#line 92
ui_type = "slider";
#line 94
ui_label = "Sharpening Strength";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Scaled by adjusting this slider from Zero to One to increase sharpness of the image.\n"
"Zero = No Sharpening, to One = Full Sharpening, and Past One = Extra Crispy.\n"
"Number 0.625 is default.";
ui_category = "Bilateral CAS";
> = 0.625;
#line 102
uniform bool CAM_IOB <
ui_label = "CAM Ignore Overbright";
ui_tooltip = "Instead of of allowing Overbright in the mask this allows sharpening of this area.\n"
"I think it's more accurate to turn this on.";
ui_category = "Bilateral CAS";
> = false;
#line 109
uniform bool CA_Mask_Boost <
ui_label = "CAM Boost";
ui_tooltip = "This boosts the power of Contrast Adaptive Masking part of the shader.";
ui_category = "Bilateral CAS";
> = false;
#line 115
uniform bool CA_Removal <
ui_label = "CAM Removal";
ui_tooltip = "This removes Contrast Adaptive Masking part of the shader.\n"
"This is for people who like the Raw look of Bilateral Sharpen.";
ui_category = "Bilateral CAS";
> = false;
#line 122
uniform int B_Grounding <
ui_type = "combo";
ui_items = "Fine\0Medium\0Coarse\0";
ui_label = "Grounding Type";
ui_tooltip = "Like Coffee pick how rough do you want this shader to be.\n"
"Gives more control of Bilateral Filtering.";
ui_category = "Bilateral Filtering";
> = 0;
#line 131
uniform bool Slow_Mode <
ui_label = "CAS Slow Mode";
ui_tooltip = "This enables release Quality of Bilateral Sharpen that is 2X the amount of image bluring at the cost of in game FPS.\n"
"If you want this to be usable at higher resolutions go in shader and change the preprocessor M_Quality, to low.\n"
"This toggle only for accuracy.";
ui_category = "Bilateral Filtering";
> = false;
#line 139
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
#line 178
texture DepthBufferTex : DEPTH;
#line 180
sampler DepthBuffer
{
Texture = DepthBufferTex;
};
#line 185
texture BackBufferTex : COLOR;
#line 187
sampler BackBuffer
{
Texture = BackBufferTex;
};
#line 193
float Depth(in float2 texcoord : TEXCOORD0)
{
if (Depth_Map_Flip)
texcoord.y =  1 - texcoord.y;
#line 198
const float zBuffer = tex2D(DepthBuffer, texcoord).x; 
#line 202
const float Far = 1.0, Near = 0.125/Depth_Map_Adjust; 
#line 204
const float2 Z = float2( zBuffer, 1-zBuffer );
#line 206
if (Depth_Map == 0) 
return saturate(Far * Near / (Far + Z.x * (Near - Far)));
else 
return saturate(Far * Near / (Far + Z.y * (Near - Far)));
}
#line 212
float Min3(float x, float y, float z)
{
return min(x, min(y, z));
}
#line 217
float Max3(float x, float y, float z)
{
return max(x, max(y, z));
}
#line 222
float normpdf3(in float3 v, in float sigma)
{
return 0.39894*exp(-0.5*dot(v,v)/(sigma*sigma))/sigma;
}
#line 227
float3 BB(in float2 texcoord, float2 AD)
{
return tex2Dlod(BackBuffer, float4(texcoord + AD,0,0)).rgb;
}
#line 232
float LI(float3 RGB)
{
return dot(RGB,float3(0.2126, 0.7152, 0.0722));
}
#line 237
float GT()
{
if (B_Grounding == 2)
return 1.5;
else if(B_Grounding == 1)
return 1.25;
else
return 1.0;
}
#line 247
float4 CAS(float2 texcoord)
{
#line 255
const float Up = LI(BB(texcoord, float2( 0,-float2((1.0 / 1920), (1.0 / 1018)).y)));
const float Left = LI(BB(texcoord, float2(-float2((1.0 / 1920), (1.0 / 1018)).x, 0)));
const float Center = LI(BB(texcoord, 0));
const float Right = LI(BB(texcoord, float2( float2((1.0 / 1920), (1.0 / 1018)).x, 0)));
const float Down = LI(BB(texcoord, float2( 0, float2((1.0 / 1920), (1.0 / 1018)).y)));
#line 261
const float mnRGB = Min3( Min3(Left, Center, Right), Up, Down);
const float mxRGB = Max3( Max3(Left, Center, Right), Up, Down);
#line 265
const float rcpMRGB = rcp(mxRGB);
float RGB_D = saturate(min(mnRGB, 1.0 - mxRGB) * rcpMRGB);
#line 268
if( CAM_IOB )
RGB_D = saturate(min(mnRGB, 2.0 - mxRGB) * rcpMRGB);
#line 272
const int kSize = 5 * 0.5; 
#line 289
float3 final_colour, c = BB(texcoord.xy,0), cc;
const float2 RPC_WS = float2((1.0 / 1920), (1.0 / 1018)) * GT();
float Z, factor;
#line 293
[loop]
for (int i=-kSize; i <= kSize; ++i)
{
if(Slow_Mode)
{
for (int j=-kSize; j <= kSize; ++j)
{
cc = BB(texcoord.xy, float2(i,j) * RPC_WS * rcp(kSize) );
factor = normpdf3(cc-c, 0.25);
Z += factor;
final_colour += factor * cc;
}
}
else
{
cc = BB(texcoord.xy, float2( i, 1 - (i * i) * 0.5 ) * RPC_WS * rcp(kSize) );
factor = normpdf3(cc-c, 0.25);
Z += factor;
final_colour += factor * cc;
}
}
#line 316
float CAS_Mask = RGB_D;
#line 318
if(CA_Mask_Boost)
CAS_Mask = lerp(CAS_Mask,CAS_Mask * CAS_Mask,saturate(Sharpness * 0.5));
#line 321
if(CA_Removal)
CAS_Mask = 1;
#line 324
return saturate(float4(final_colour/Z,CAS_Mask));
}
#line 327
float3 Sharpen_Out(float2 texcoord)
{   const float3 Done = tex2D(BackBuffer,texcoord).rgb;
return lerp(Done,Done+(Done - CAS(texcoord).rgb)*(Sharpness*3.1), CAS(texcoord).w * saturate(Sharpness)); 
}
#line 333
float3 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float3 Sharpen = Sharpen_Out(texcoord).rgb,BB = tex2D(BackBuffer,texcoord).rgb;
float DB = Depth(texcoord).r, DBBL = Depth(float2(texcoord.x*2,texcoord.y*2-1)).r;
const float DBTL = Depth(float2(texcoord.x*2,texcoord.y*2)).r;
#line 339
if(No_Depth_Map)
{
DB = 0.0;
DBBL = 0.0;
}
#line 345
if (Debug_View == 0)
{
return lerp(Sharpen, BB, DB);
}
else if (Debug_View == 1)
{
const float3 Top_Left = lerp(float3(1.,1.,1.),CAS(float2(texcoord.x*2,texcoord.y*2)).www,1-DBTL);
#line 353
const float3 Top_Right =  Depth(float2(texcoord.x*2-1,texcoord.y*2)).rrr;
#line 355
const float3 Bottom_Left = lerp(float3(1., 0., 1.),tex2D(BackBuffer,float2(texcoord.x*2,texcoord.y*2-1)).rgb,DBBL);
#line 357
const float3 Bottom_Right = CAS(float2(texcoord.x*2-1,texcoord.y*2-1)).rgb;
#line 359
float3 VA_Top;
if (texcoord.x < 0.5)
VA_Top = Top_Left;
else
VA_Top = Top_Right;
#line 365
float3 VA_Bottom;
if (texcoord.x < 0.5)
VA_Bottom = Bottom_Left;
else
VA_Bottom = Bottom_Right;
#line 371
if (texcoord.y < 0.5)
return VA_Top;
else
return VA_Bottom;
}
else
return Depth(texcoord);
}
#line 383
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
if (id == 2)
texcoord.x = 2.0;
else
texcoord.x = 0.0;
#line 390
if (id == 1)
texcoord.y = 2.0;
else
texcoord.y = 0.0;
#line 395
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 399
technique Smart_Sharp
< ui_tooltip = "Suggestion : You Can Enable 'Performance Mode Checkbox,' in the lower bottom right of the ReShade's Main UI.\n"
"             Do this once you set your Smart Sharp settings of course."; >
{
pass UnsharpMask
{
VertexShader = PostProcessVS;
PixelShader = Out;
}
}

