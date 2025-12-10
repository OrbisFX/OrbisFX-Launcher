// temporal_dither=0
// fast_luma=1
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Colourfulness.fx"
#line 28
uniform float colourfulness <
ui_type = "slider";
ui_min = -1.0; ui_max = 2.0;
ui_tooltip = "Degree of colourfulness, 0 = neutral";
ui_step = 0.01;
> = 0.4;
#line 35
uniform float lim_luma <
ui_type = "slider";
ui_min = 0.1; ui_max = 1.0;
ui_tooltip = "Lower values allows for more change near clipping";
ui_step = 0.01;
> = 0.7;
#line 42
uniform bool enable_dither <
ui_tooltip = "Enables dithering, avoids introducing banding in gradients";
ui_category = "Dither";
> = false;
#line 47
uniform bool col_noise <
ui_tooltip = "Coloured dither noise, lower subjective noise level";
ui_category = "Dither";
> = false;
#line 52
uniform float backbuffer_bits <
ui_min = 1.0; ui_max = 32.0;
ui_tooltip = "Backbuffer bith depth, most likely 8 or 10 bits";
ui_category = "Dither";
> = 8.0;
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
#line 69 "C:\Program Files\GShade\gshade-shaders\Shaders\Colourfulness.fx"
#line 91
float3 Colourfulness(float4 vpos : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
#line 94
float3 c0  = tex2D(ReShade::BackBuffer, tex).rgb;
const float luma = sqrt(dot(saturate(c0*abs(c0)), float3(0.2558, 0.6511, 0.0931)));
c0 = saturate(c0);
#line 103
const float3 diff_luma = c0 - luma;
float3 c_diff = diff_luma*(colourfulness + 1) - diff_luma;
#line 106
if (colourfulness > 0.0)
{
#line 109
const float3 rlc_diff = clamp((c_diff*1.2) + c0, -0.0001, 1.0001) - c0;
#line 112
const float poslim = (1.0002 - luma)/(abs(( max((diff_luma).r, max((diff_luma).g, (diff_luma).b)) )) + 0.0001);
const float neglim = (luma + 0.0002)/(abs(( min((diff_luma).r, min((diff_luma).g, (diff_luma).b)) )) + 0.0001);
#line 115
const float3 diffmax = diff_luma*min(min(poslim, neglim), 32) - diff_luma;
#line 118
c_diff = ( (c_diff*max(( ((abs(lim_luma)*sqrt(abs(diffmax)) + abs(1-lim_luma)*sqrt(abs(rlc_diff)))*2) ), 1e-6))*rcp(sqrt(max(( ((abs(lim_luma)*sqrt(abs(diffmax)) + abs(1-lim_luma)*sqrt(abs(rlc_diff)))*2) ), 1e-6)*max(( ((abs(lim_luma)*sqrt(abs(diffmax)) + abs(1-lim_luma)*sqrt(abs(rlc_diff)))*2) ), 1e-6) + c_diff*c_diff)) );
}
#line 121
if (enable_dither == true)
{
#line 124
const float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
#line 128
const float xy_magic = vpos.x*magic.x + vpos.y*magic.y;
#line 130
const float noise = (frac(magic.z*frac(xy_magic)) - 0.5)/(exp2(backbuffer_bits) - 1);
if (col_noise == true)
c_diff += float3(-noise, noise, -noise);
else
c_diff += noise;
}
#line 141
return saturate(c0 + c_diff);
#line 143
}
#line 145
technique Colourfulness
{
pass
{
VertexShader = PostProcessVS;
PixelShader  = Colourfulness;
}
}

