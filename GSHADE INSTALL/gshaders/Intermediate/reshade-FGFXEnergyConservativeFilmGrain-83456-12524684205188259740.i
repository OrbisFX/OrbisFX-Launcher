#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FGFXEnergyConservativeFilmGrain.fx"
#line 33
uniform int ___ABOUT <
ui_type = "radio";
ui_label = " ";
ui_category = "About";
ui_category_closed = true;
ui_text =
"+------------------------------------------------------------------------+\n"
"|-=[ FGFX::Energy-Conservative Film Grain ]=-|\n"
"+------------------------------------------------------------------------+\n"
"\n"
#line 44
"The Energy-Conservative Film Grain is a post-processing effect that aims "
"at injecting random noise in the frame to achieve a film grain / digital "
"sensor noise effect.\n"
"\n"
#line 49
"However, it tries to achieve that while not introducing undesired "
"luminance offsets in the image by staying neutral to 0 (the noise "
"averages to 0 if integrated both in time and / or space).\n"
"\n"
#line 54
"This property makes it energy-conservative and it mimics how real "
"devices integrate noise in their output signal.\n"
"\n"
#line 58
"* Where is this effect best placed? *\n"
"\n"
#line 61
"Since the effect addresses film / sensor defects, it's best to place "
"it after all effects (especially after any form of sharpening).\n";
>;
#line 65
uniform float Intensity <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Intensity";
ui_tooltip = "Film grain global intensity.";
> = 0.15;
#line 73
uniform float HighlightIntensity <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Highlight Intensity";
ui_tooltip = "Intensity of the grain in highlights.";
> = 0.25;
#line 81
uniform float LuminanceExponent <
ui_type = "slider";
ui_min = 0.1;
ui_max = 4.0;
ui_label = "Luminance Exponent";
ui_tooltip = "Exponent to which the luminance is raised before used as modulator.";
> = 1.5;
#line 91
uniform float FrameTime <source = "frametime";>;
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
#line 96 "C:\Program Files\GShade\gshade-shaders\Shaders\FGFXEnergyConservativeFilmGrain.fx"
#line 99
sampler2D ReShadeBackBufferSRGBSampler {
Texture = ReShade::BackBufferTex;
};
#line 105
float3 Hash33(in float3 p3) {
p3 = frac(p3 * float3(0.1031, 0.1030, 0.0973));
p3 += dot(p3, p3.yxz + 33.33);
return frac((p3.xxy + p3.yxx) * p3.zyx);
}
#line 111
float3 Hash32UV(in float2 uv, in float step) {
return Hash33(float3(uv * 14353.45646, (FrameTime % 100.0) * step));
}
#line 117
float3 MainPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
#line 119
float2 screenUV = texcoord.xy;
float3 color = tex2D(ReShadeBackBufferSRGBSampler, screenUV).rgb;
#line 123
float3 grain = Hash32UV(texcoord, 0.6457);
#line 126
grain = pow(max(grain, 0.0), 2.2);
#line 129
grain -= 0.5;
#line 132
float luminance = dot(color, 0.333333333333); 
luminance = pow(max(luminance, 0.0), LuminanceExponent); 
float luminanceModulator = lerp(1.0, HighlightIntensity, luminance); 
#line 137
grain *= luminanceModulator;
#line 140
grain *= Intensity;
#line 143
color += grain;
#line 146
return color.rgb;
}
#line 149
technique FilmGrain <
ui_label = "FGFX::Energy-Conservative Film Grain";
ui_tooltip =
"+------------------------------------------------------------------------+\n"
"|-=[ FGFX::Energy-Conservative Film Grain ]=-|\n"
"+------------------------------------------------------------------------+\n"
"\n"
#line 157
"The Energy-Conservative Film Grain is a post-processing effect that aims\n"
"at injecting random noise in the frame to achieve a film grain effect.\n"
"\n"
#line 161
"The Energy-Conservative Film Grain is written by\n"
"Alex Tuduran.\n";
> {
pass {
VertexShader = PostProcessVS;
PixelShader = MainPass;
}
}

