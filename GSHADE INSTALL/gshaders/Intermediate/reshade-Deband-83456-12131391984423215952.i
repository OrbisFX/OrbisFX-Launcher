#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Deband.fx"
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
#line 61 "C:\Program Files\GShade\gshade-shaders\Shaders\Deband.fx"
#line 62
uniform bool enable_weber <
ui_category = "Banding analysis";
ui_label = "Weber ratio";
ui_tooltip = "Weber ratio analysis that calculates the ratio of the each local pixel's intensity to average background intensity of all the local pixels.";
ui_type = "radio";
> = true;
#line 69
uniform bool enable_sdeviation <
ui_category = "Banding analysis";
ui_label = "Standard deviation";
ui_tooltip = "Modified standard deviation analysis that calculates nearby pixels' intensity deviation from the current pixel instead of the mean.";
ui_type = "radio";
> = true;
#line 76
uniform bool enable_depthbuffer <
ui_category = "Banding analysis";
ui_label = "Depth detection";
ui_tooltip = "Allows depth information to be used when analysing banding, pixels will only be analysed if they are in a certain depth. (e.g. debanding only the sky)";
ui_type = "radio";
> = false;
#line 83
uniform float t1 <
ui_category = "Banding analysis";
ui_label = "Standard deviation threshold";
ui_max = 0.5;
ui_min = 0.0;
ui_step = 0.001;
ui_tooltip = "Standard deviations lower than this threshold will be flagged as flat regions with potential banding.";
ui_type = "slider";
> = 0.007;
#line 93
uniform float t2 <
ui_category = "Banding analysis";
ui_label = "Weber ratio threshold";
ui_max = 2.0;
ui_min = 0.0;
ui_step = 0.01;
ui_tooltip = "Weber ratios lower than this threshold will be flagged as flat regions with potential banding.";
ui_type = "slider";
> = 0.04;
#line 103
uniform float banding_depth <
ui_category = "Banding analysis";
ui_label = "Banding depth";
ui_max = 1.0;
ui_min = 0.0;
ui_step = 0.001;
ui_tooltip = "Pixels under this depth threshold will not be processed and returned as they are.";
ui_type = "slider";
> = 1.0;
#line 113
uniform float range <
ui_category = "Banding detection & removal";
ui_label = "Radius";
ui_max = 32.0;
ui_min = 1.0;
ui_step = 1.0;
ui_tooltip = "The radius increases linearly for each iteration. A higher radius will find more gradients, but a lower radius will smooth more aggressively.";
ui_type = "slider";
> = 24.0;
#line 123
uniform int iterations <
ui_category = "Banding detection & removal";
ui_label = "Iterations";
ui_max = 4;
ui_min = 1;
ui_tooltip = "The number of debanding steps to perform per sample. Each step reduces a bit more banding, but takes time to compute.";
ui_type = "slider";
> = 1;
#line 132
uniform int debug_output <
ui_category = "Debug";
ui_items = "None\0Blurred (LPF) image\0Banding map\0";
ui_label = "Debug view";
ui_tooltip = "Blurred (LPF) image: Useful when tweaking radius and iterations to make sure all banding regions are blurred enough.\nBanding map: Useful when tweaking analysis parameters, continuous green regions indicate flat (i.e. banding) regions.";
ui_type = "combo";
> = 0;
#line 141
uniform int drandom < source = "random"; min = 0; max = 32767; >;
#line 143
float rand(float x)
{
return frac(x / 41.0);
}
#line 148
float permute(float x)
{
return ((34.0 * x + 1.0) * x) % 289.0;
}
#line 153
float3 PS_Deband(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 ori = tex2Dlod(ReShade::BackBuffer, float4(texcoord, 0.0, 0.0)).rgb;
#line 157
if (enable_depthbuffer && (ReShade::GetLinearizedDepth(texcoord) < banding_depth))
return ori;
#line 161
const float3 m = float3(texcoord + 1.0, (drandom / 32767.0) + 1.0);
float h = permute(permute(permute(m.x) + m.y) + m.z);
#line 165
const float dir  = rand(permute(h)) * 6.2831853;
float2 o;
sincos(dir, o.y, o.x);
#line 170
float2 pt;
float dist;
#line 173
[loop]
for (int i = 1; i <= iterations; ++i) {
dist = rand(h) * range * i;
pt = dist * float2((1.0 / 1920), (1.0 / 1018));
#line 178
h = permute(h);
}
#line 182
const float3 ref[4] = {
tex2Dlod(ReShade::BackBuffer, float4(mad(pt,                  o, texcoord), 0.0, 0.0)).rgb, 
tex2Dlod(ReShade::BackBuffer, float4(mad(pt,                 -o, texcoord), 0.0, 0.0)).rgb, 
tex2Dlod(ReShade::BackBuffer, float4(mad(pt, float2(-o.y,  o.x), texcoord), 0.0, 0.0)).rgb, 
tex2Dlod(ReShade::BackBuffer, float4(mad(pt, float2( o.y, -o.x), texcoord), 0.0, 0.0)).rgb  
};
#line 190
const float3 mean = (ori + ref[0] + ref[1] + ref[2] + ref[3]) * 0.2;
float3 k = abs(ori - mean);
for (int j = 0; j < 4; ++j) {
k += abs(ref[j] - mean);
}
#line 196
k = k * 0.2 / mean;
#line 199
float3 sd = 0.0;
#line 201
for (int j = 0; j < 4; ++j) {
sd += pow(ref[j] - ori, 2);
}
#line 205
sd = sqrt(sd * 0.25);
#line 208
float3 output;
#line 210
if (debug_output == 2)
output = float3(0.0, 1.0, 0.0);
else
output = (ref[0] + ref[1] + ref[2] + ref[3]) * 0.25;
#line 216
bool3 banding_map = true;
#line 218
if (debug_output != 1) {
if (enable_weber)
banding_map = banding_map && k <= t2 * iterations;
#line 222
if (enable_sdeviation)
banding_map = banding_map && sd <= t1 * iterations;
}
#line 226
if (banding_map.x && banding_map.y && banding_map.z) {
#line 231
const float grid_position = frac(dot(texcoord, (float2(1920, 1018) * float2(1.0 / 16.0, 10.0 / 36.0)) + 0.25));
#line 234
const float dither_shift = 0.25 * (1.0 / (pow(2, 8) - 1.0));
#line 237
float3 dither_shift_RGB = float3(dither_shift, -dither_shift, dither_shift); 
#line 240
dither_shift_RGB = lerp(2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position); 
#line 242
return output + dither_shift_RGB;
}
else {
return ori;
}
}
#line 249
technique Deband <
ui_tooltip = "Alleviates color banding by trying to approximate original color values.";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Deband;
}
}

