#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MotionFocus.fx"
#line 5
uniform bool mfDebug <
ui_type = "slider";
ui_items = "Off\0On";
ui_tooltip = "Activates debug mode of MF";
> = false;
#line 11
uniform float mfFocusStrength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "The intensity with which the camera will follow motion";
> = 1.0;
#line 17
uniform float mfZoomStrength <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "The intensity of camera zoom to objects in motion";
> = 0.60;
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
#line 28 "C:\Program Files\GShade\gshade-shaders\Shaders\MotionFocus.fx"
#line 43
texture2D Ganossa_MF_NormTex { Width = 1920/2; Height = 1018/2; Format = RGBA8; };
texture2D Ganossa_MF_PrevTex { Width = 1920/2; Height = 1018/2; Format = RGBA8; };
texture2D Ganossa_MF_QuadFullTex { Width = 1920/2; Height = 1018/2; Format = RGBA8; };
texture2D Ganossa_MF_QuadFullPrevTex { Width = 1920/2; Height = 1018/2; Format = RGBA8; };
texture2D Ganossa_MF_QuadTex { Width = 1920/2; Height = 1018/2; Format = RGBA16F; };
#line 49
sampler2D Ganossa_MF_NormColor { Texture = Ganossa_MF_NormTex; };
sampler2D Ganossa_MF_PrevColor { Texture = Ganossa_MF_PrevTex; };
sampler2D Ganossa_MF_QuadFullColor { Texture = Ganossa_MF_QuadFullTex; };
sampler2D Ganossa_MF_QuadFullPrevColor { Texture = Ganossa_MF_QuadFullPrevTex; };
sampler2D Ganossa_MF_QuadColor { Texture = Ganossa_MF_QuadTex; };
#line 62
void PS_MotionFocusNorm(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 normR : SV_Target0)
{
normR = tex2D(ReShade::BackBuffer, texcoord);
}
#line 67
void PS_MotionFocusQuadFull(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 quadFullR : SV_Target0)
{
const float3 orig = tex2D(Ganossa_MF_NormColor, texcoord).rgb;
const float3 prev = tex2D(Ganossa_MF_PrevColor, texcoord).rgb;
const float diff = (abs(orig.r-prev.r)+abs(orig.g-prev.g)+abs(orig.b-prev.b))/3f;
#line 73
const float3 quadFullPrev = tex2D(Ganossa_MF_QuadFullPrevColor,texcoord).rgb;
#line 75
const float3 quadFull = 0.968*quadFullPrev + float3(diff,diff,diff);
#line 77
const float3 quadFulldiff = float3(abs(quadFull.r-quadFullPrev.r),abs(quadFull.g-quadFullPrev.g),abs(quadFull.b-quadFullPrev.b));
#line 79
quadFullR = float4((0.978-0.2*max(1.0f-pow(1.0f-quadFulldiff,2)*100000f,0))*quadFullPrev + float3(diff,diff,diff),1);
#line 81
}
#line 83
void PS_MotionFocusStorage(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 prevR : SV_Target0, out float4 prevQuadFullR : SV_Target1)
{
prevR = tex2D(Ganossa_MF_NormColor, texcoord);
prevQuadFullR = tex2D(Ganossa_MF_QuadFullColor, texcoord);
}
#line 89
void PS_MotionFocus(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 quadR : SV_Target0)
{
quadR = float4(0,0,0,0);
#line 93
if (!(texcoord.x <= (1.0 / 1920)*2 && texcoord.y <= (1.0 / 1018)*2))
discard;
#line 96
float2 coord = float2(0.0,0.0);
#line 98
for (float i = 2.0f; i < 1920/2; i=i+1920/192f)
{
coord.x = (1.0 / 1920)*i*2;
#line 102
[unroll]
for (float j = 2.0f; j < 1018/2; j=j+1018/108f )
{
coord.y = (1.0 / 1018)*j*2;
float3 quadFull = tex2Dlod(Ganossa_MF_QuadFullColor, float4(coord, 0.0, 0.0)).xyz;
float quadFullPow = quadFull.x+quadFull.y+quadFull.z;
#line 109
if(i < 1920/2/2 && j < 1018/2/2)
quadR.x += quadFullPow;
else if(i > 1920/2/2 && j < 1018/2/2)
quadR.y += quadFullPow;
else if(i < 1920/2/2 && j > 1018/2/2)
quadR.z += quadFullPow;
else
quadR.w += quadFullPow;
}
}
quadR.xyzw /= 5184f;
}
#line 122
float4 PS_MotionFocusDisplay(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 Ganossa_MF_Quad = saturate(tex2D(Ganossa_MF_QuadColor, float2((1.0 / 1920), (1.0 / 1018)))-0.1f);
#line 126
if (mfDebug)
{
#line 129
if(texcoord.y < 0.01f) if(texcoord.x > Ganossa_MF_Quad.x-0.01f && texcoord.x < Ganossa_MF_Quad.x+0.01f) return float4(1,0,0,0);
if(texcoord.y > 0.01f && texcoord.y < 0.02f) if(texcoord.x > Ganossa_MF_Quad.y-0.01f && texcoord.x < Ganossa_MF_Quad.y+0.01f) return float4(0,1,0,0);
if(texcoord.y > 0.02f && texcoord.y < 0.03f) if(texcoord.x > Ganossa_MF_Quad.z-0.01f && texcoord.x < Ganossa_MF_Quad.z+0.01f) return float4(0,0,1,0);
if(texcoord.y > 0.03f && texcoord.y < 0.04f) if(texcoord.x > Ganossa_MF_Quad.w-0.01f && texcoord.x < Ganossa_MF_Quad.w+0.01f) return float4(1,1,0,0);
#line 134
}
#line 136
float2 focus = 0.5f + float2(max(min(0.5,(Ganossa_MF_Quad.y + Ganossa_MF_Quad.w - Ganossa_MF_Quad.x - Ganossa_MF_Quad.z)/2f),-1.0),max(min(0.5,(Ganossa_MF_Quad.z + Ganossa_MF_Quad.w - Ganossa_MF_Quad.x - Ganossa_MF_Quad.y)/2f),-0.5));
#line 138
float focusPow = max(Ganossa_MF_Quad.x,max(Ganossa_MF_Quad.y,max(Ganossa_MF_Quad.z,Ganossa_MF_Quad.w)));
#line 140
float focusPowDiff = 1.0f;
if (focusPow == Ganossa_MF_Quad.x) focusPowDiff += Ganossa_MF_Quad.x-(Ganossa_MF_Quad.y + Ganossa_MF_Quad.z + Ganossa_MF_Quad.w)/3f;
else if(focusPow == Ganossa_MF_Quad.y) focusPowDiff += Ganossa_MF_Quad.y-(Ganossa_MF_Quad.x + Ganossa_MF_Quad.z + Ganossa_MF_Quad.w)/3f;
else if(focusPow == Ganossa_MF_Quad.z) focusPowDiff += Ganossa_MF_Quad.z-(Ganossa_MF_Quad.x + Ganossa_MF_Quad.y + Ganossa_MF_Quad.w)/3f;
else focusPowDiff += Ganossa_MF_Quad.w-(Ganossa_MF_Quad.y + Ganossa_MF_Quad.z + Ganossa_MF_Quad.x)/3f;
#line 146
float focusPowFull = 0.5f*max(1.0f,min(2.0f - pow((Ganossa_MF_Quad.x + Ganossa_MF_Quad.y + Ganossa_MF_Quad.z + Ganossa_MF_Quad.w)/4f,3),1.0f));
#line 148
if (mfDebug)
{
#line 151
if(texcoord.x < 0.5025f && texcoord.x > 0.4975f && texcoord.y < 0.505f && texcoord.y > 0.495f) return float4(0,1,0,0);
if(texcoord.x > pow(focus.x,2)+0.25f-0.0025f && texcoord.x < pow(focus.x,2)+0.25f+0.0025f && texcoord.y > pow(focus.y,2)+0.25f-0.005f && texcoord.y < pow(focus.y,2)+0.25f+0.005f) return float4(1,0,0,0);
#line 154
}
const float2 finalZoom = focusPow*focusPowDiff*focusPowFull*mfZoomStrength;
const float2 finalFocus = focus*focusPow*pow(focusPowDiff,3)*focusPowFull*mfFocusStrength;
#line 158
const float2 focusCorrection = min(0,float2(1,1)-(float2(1,1)*(1.0f-finalZoom)+finalFocus*min(0.55,0.6*mfZoomStrength)));
#line 160
return tex2D(ReShade::BackBuffer, texcoord*(1.0f-finalZoom)+finalFocus*min(0.55,0.6*mfZoomStrength)+focusCorrection);
}
#line 163
technique GanossaMotionFocus
{
pass MotionFocusNormPass
{
VertexShader = PostProcessVS;
PixelShader = PS_MotionFocusNorm;
RenderTarget0 = Ganossa_MF_NormTex;
}
#line 172
pass MotionFocusQuadFullPass
{
VertexShader = PostProcessVS;
PixelShader = PS_MotionFocusQuadFull;
RenderTarget0 = Ganossa_MF_QuadFullTex;
}
#line 179
pass MotionFocusPass
{
VertexShader = PostProcessVS;
PixelShader = PS_MotionFocus;
RenderTarget0 = Ganossa_MF_QuadTex;
}
#line 186
pass MotionFocusDisplayPass
{
VertexShader = PostProcessVS;
PixelShader = PS_MotionFocusDisplay;
}
#line 192
pass MotionFocusStoragePass
{
VertexShader = PostProcessVS;
PixelShader = PS_MotionFocusStorage;
RenderTarget0 = Ganossa_MF_PrevTex;
RenderTarget1 = Ganossa_MF_QuadFullPrevTex;
}
}

