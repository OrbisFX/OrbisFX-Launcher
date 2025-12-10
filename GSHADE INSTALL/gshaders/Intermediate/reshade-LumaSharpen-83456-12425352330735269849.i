#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\LumaSharpen.fx"
#line 41
uniform float sharp_strength <
ui_type = "slider";
ui_min = 0.1; ui_max = 3.0;
ui_label = "Shapening strength";
ui_tooltip = "Strength of the sharpening";
#line 47
> = 0.65;
uniform bool inversedAttribution <
ui_label = "Inverse Attribution";
ui_tooltip = "Activate inverse attribution so that already sharp areas will get less sharpness";
> = false;
uniform float sharp_clamp <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0; ui_step = 0.005;
ui_label = "Sharpening limit";
ui_tooltip = "Limits maximum amount of sharpening a pixel receives\nThis helps avoid \"haloing\" artifacts which would otherwise occur when you raised the strength too much.";
> = 0.035;
uniform int pattern <
ui_type = "combo";
ui_items =	"Fast" "\0"
"Normal" "\0"
"Wider"	"\0"
"Pyramid shaped" "\0";
ui_label = "Sample pattern";
ui_tooltip = "Choose a sample pattern.\n"
"Fast is faster but slightly lower quality.\n"
"Normal is normal.\n"
"Wider is less sensitive to noise but also to fine details.\n"
"Pyramid has a slightly more aggresive look.";
> = 1;
uniform float offset_bias <
ui_type = "slider";
ui_min = 0.0; ui_max = 6.0;
ui_label = "Offset bias";
ui_tooltip = "Offset bias adjusts the radius of the sampling pattern. I designed the pattern for an offset bias of 1.0, but feel free to experiment.";
> = 1.0;
uniform bool show_sharpen <
ui_label = "Show sharpening pattern";
ui_tooltip = "Visualize the strength of the sharpen\nThis is useful for seeing what areas the sharpning affects the most";
> = false;
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
#line 83 "C:\Program Files\GShade\gshade-shaders\Shaders\LumaSharpen.fx"
#line 95
float3 LumaSharpenPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
#line 98
const float3 ori = tex2D(ReShade::BackBuffer, tex).rgb; 
#line 101
float3 sharp_strength_luma = (float3(0.2126, 0.7152, 0.0722) * sharp_strength); 
#line 106
float3 blur_ori;
#line 113
if (pattern == 0)
{
#line 120
blur_ori  = tex2D(ReShade::BackBuffer, tex + (float2((1.0 / 1920), (1.0 / 1018)) / 3.0) * offset_bias).rgb;  
blur_ori += tex2D(ReShade::BackBuffer, tex + (-float2((1.0 / 1920), (1.0 / 1018)) / 3.0) * offset_bias).rgb; 
#line 126
blur_ori /= 2;  
#line 128
sharp_strength_luma *= 1.5; 
}
#line 132
if (pattern == 1)
{
#line 139
blur_ori  = tex2D(ReShade::BackBuffer, tex + float2(float2((1.0 / 1920), (1.0 / 1018)).x, -float2((1.0 / 1920), (1.0 / 1018)).y) * 0.5 * offset_bias).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex - float2((1.0 / 1920), (1.0 / 1018)) * 0.5 * offset_bias).rgb;  
blur_ori += tex2D(ReShade::BackBuffer, tex + float2((1.0 / 1920), (1.0 / 1018)) * 0.5 * offset_bias).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex - float2(float2((1.0 / 1920), (1.0 / 1018)).x, -float2((1.0 / 1920), (1.0 / 1018)).y) * 0.5 * offset_bias).rgb; 
#line 144
blur_ori *= 0.25;  
}
#line 148
if (pattern == 2)
{
#line 157
blur_ori  = tex2D(ReShade::BackBuffer, tex + float2((1.0 / 1920), (1.0 / 1018)) * float2(0.4, -1.2) * offset_bias).rgb;  
blur_ori += tex2D(ReShade::BackBuffer, tex - float2((1.0 / 1920), (1.0 / 1018)) * float2(1.2, 0.4) * offset_bias).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex + float2((1.0 / 1920), (1.0 / 1018)) * float2(1.2, 0.4) * offset_bias).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex - float2((1.0 / 1920), (1.0 / 1018)) * float2(0.4, -1.2) * offset_bias).rgb; 
#line 162
blur_ori *= 0.25;  
#line 164
sharp_strength_luma *= 0.51;
}
#line 168
if (pattern == 3)
{
#line 175
blur_ori  = tex2D(ReShade::BackBuffer, tex + float2(0.5 * float2((1.0 / 1920), (1.0 / 1018)).x, -float2((1.0 / 1920), (1.0 / 1018)).y * offset_bias)).rgb;  
blur_ori += tex2D(ReShade::BackBuffer, tex + float2(offset_bias * -float2((1.0 / 1920), (1.0 / 1018)).x, 0.5 * -float2((1.0 / 1920), (1.0 / 1018)).y)).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex + float2(offset_bias * float2((1.0 / 1920), (1.0 / 1018)).x, 0.5 * float2((1.0 / 1920), (1.0 / 1018)).y)).rgb; 
blur_ori += tex2D(ReShade::BackBuffer, tex + float2(0.5 * -float2((1.0 / 1920), (1.0 / 1018)).x, float2((1.0 / 1920), (1.0 / 1018)).y * offset_bias)).rgb; 
#line 182
blur_ori /= 4.0;  
#line 184
sharp_strength_luma *= 0.666; 
}
#line 192
const float3 sharp = ori - blur_ori;  
#line 201
 
#line 203
if (inversedAttribution)
{
const float3 revert_sharp_strength = (1.01 / (abs(sharp) + 0.01)) / 30.0;
sharp_strength_luma *= revert_sharp_strength;
}
#line 210
const float4 sharp_strength_luma_clamp = float4(sharp_strength_luma * (0.5 / sharp_clamp),0.5); 
#line 213
float sharp_luma = saturate(dot(float4(sharp,1.0), sharp_strength_luma_clamp)); 
sharp_luma = (sharp_clamp * 2.0) * sharp_luma - sharp_clamp; 
#line 218
float3 outputcolor = ori + sharp_luma;    
#line 224
if (show_sharpen)
{
#line 227
outputcolor = saturate(0.5 + (sharp_luma * 4.0)).rrr;
}
#line 230
return saturate(outputcolor);
}
#line 233
technique LumaSharpen
{
pass
{
VertexShader = PostProcessVS;
PixelShader = LumaSharpenPass;
}
}

