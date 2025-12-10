#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Compare.fx"
#line 63
uniform int ui_instructions
<
ui_category = "Instructions";
ui_type = "radio";
ui_label = " ";
ui_text =
"1. Enable 'Capture' technique first\n"
"2. Enable Effect A\n"
"3. Enable 'Restore' technique\n"
"4. Enable Effect B\n"
"5. Enable 'Compare' technique\n\n"
"The Compare technique will show the differences between Effect A and Effect B using various visualization modes.";
>;
#line 77
uniform int compare_mode
<
ui_type = "combo";
ui_label = "Mode";
ui_tooltip = "Choose a comparison mode";
ui_spacing = 2;
ui_items =
"Vertical 50/50 split\0"
"Vertical 25/50/25 split\0"
"Angled 50/50 split\0"
"Angled 25/50/25 split\0"
"Horizontal 50/50 split\0"
"Horizontal 25/50/25 split\0"
"Diagonal split\0"
"Difference blend (absolute)\0"
"Difference blend (signed)\0"
;
> = 7;
#line 96
uniform float difference_scale
<
ui_type = "slider";
ui_label = "Difference Scale";
ui_tooltip = "Multiplier for difference visibility";
ui_min = 1.0;
ui_max = 20.0;
ui_step = 0.1;
> = 5.0;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ReShade.fxh"
#line 57
namespace ReShade
{
float GetAspectRatio() { return 1280 * (1.0 / 720); }
float2 GetPixelSize() { return float2((1.0 / 1280), (1.0 / 720)); }
float2 GetScreenSize() { return float2(1280, 720); }
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
#line 111 "C:\Program Files\GShade\gshade-shaders\Shaders\Compare.fx"
#line 116
texture OriginalBuffer { Width = 1280; Height = 720; };
sampler OriginalSampler { Texture = OriginalBuffer; };
#line 119
texture EffectABuffer { Width = 1280; Height = 720; };
sampler EffectASampler { Texture = EffectABuffer; };
#line 127
float3 PS_Capture(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return tex2D(ReShade::BackBuffer, texcoord).rgb;
}
#line 133
float3 PS_Restore(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return tex2D(OriginalSampler, texcoord).rgb;
}
#line 139
float3 PS_Compare(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float3 original = tex2D(OriginalSampler, texcoord).rgb;  
const float3 effectA = tex2D(EffectASampler, texcoord).rgb;  
const float3 effectB = tex2D(ReShade::BackBuffer, texcoord).rgb;  
float3 color;
#line 147
[branch] if (compare_mode == 0)
color = (texcoord.x < 0.5) ? effectA : effectB;
#line 151
[branch] if (compare_mode == 1)
{
if (texcoord.x < 0.333)
color = effectA;
else if (texcoord.x < 0.666)
color = original;
else
color = effectB;
}
#line 162
[branch] if (compare_mode == 2)
{
float dist = ((texcoord.x - 3.0/8.0) + (texcoord.y * 0.25));
dist = saturate(dist - 0.25);
color = dist ? effectB : effectA;
}
#line 170
[branch] if (compare_mode == 3)
{
float angle = texcoord.x + texcoord.y * 0.5;
if (angle < 0.5)
color = effectA;
else if (angle < 1.0)
color = original;
else
color = effectB;
}
#line 182
[branch] if (compare_mode == 4)
color = (texcoord.y < 0.5) ? effectA : effectB;
#line 186
[branch] if (compare_mode == 5)
{
if (texcoord.y < 0.333)
color = effectA;
else if (texcoord.y < 0.666)
color = original;
else
color = effectB;
}
#line 197
[branch] if (compare_mode == 6)
{
const float dist = (texcoord.x + texcoord.y);
color = (dist < 1.0) ? effectA : effectB;
}
#line 204
[branch] if (compare_mode == 7)
{
const float3 difference = abs(effectB - effectA);
color = difference * difference_scale;
}
#line 211
[branch] if (compare_mode == 8)
{
const float3 difference = effectB - effectA;
color = (difference * difference_scale) + 0.5;
}
#line 217
return color;
}
#line 224
technique Capture
<
ui_tooltip = "Step 1: Capture original image before any effects.";
>
{
pass Capture_Original
{
VertexShader = PostProcessVS;
PixelShader = PS_Capture;
RenderTarget = OriginalBuffer;
}
}
#line 237
technique Restore
<
ui_tooltip = "Step 2: Capture Effect A and restore original image.";
>
{
pass Capture_EffectA
{
VertexShader = PostProcessVS;
PixelShader = PS_Capture;
RenderTarget = EffectABuffer;
}
#line 249
pass Restore
{
VertexShader = PostProcessVS;
PixelShader = PS_Restore;
}
}
#line 256
technique Compare
<
ui_tooltip = "Step 3: Compare Effect A and Effect B with various visualization modes.";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Compare;
}
}

