#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Posterize.fx"
#line 23
uniform float ZEBRA_INTENSITY <
ui_type = "slider";
ui_label = "Zebra Lines Intensity";
ui_min = 0.0;
ui_max = 1.0;
> = 0.0;
#line 30
uniform float3 PALETTE_COLOR_1 <
ui_type = "color";
ui_label = "Color 1";
> = float3(1/255.0, 48/255.0, 74/255.0);
#line 35
uniform float3 PALETTE_COLOR_2 <
ui_type = "color";
ui_label = "Color 2";
> = float3(219/255.0, 33/255.0, 38/255.0);
#line 40
uniform float3 PALETTE_COLOR_3 <
ui_type = "color";
ui_label = "Color 3";
> = float3(113/255.0, 153/255.0, 165/255.0);
#line 45
uniform float3 PALETTE_COLOR_4 <
ui_type = "color";
ui_label = "Color 4";
> = float3(255/255.0, 250/255.0, 182/255.0);
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_common.fxh"
#line 111
namespace qUINT
{
uniform float FRAME_TIME < source = "frametime"; >;
uniform int FRAME_COUNT < source = "framecount"; >;
#line 124
static const float2 ASPECT_RATIO 	= float2(1.0, 1920 * (1.0 / 1018));
static const float2 PIXEL_SIZE 		= float2((1.0 / 1920), (1.0 / 1018));
static const float2 SCREEN_SIZE 	= float2(1920, 1018);
#line 130
texture BackBufferTex : COLOR;
texture DepthBufferTex : DEPTH;
#line 133
sampler sBackBufferTex 	{ Texture = BackBufferTex; 	};
sampler sDepthBufferTex { Texture = DepthBufferTex; };
#line 136
float2 depthtex_uv(float2 uv)
{
#line 141
uv.x /= 1;
uv.y /= 1;
#line 145
 
uv.x -= 0 / 2.000000001;
#line 151
uv.y += 0 / 2.000000001;
#line 153
return uv;
}
#line 156
float get_depth(float2 uv)
{
float depth = tex2Dlod(sDepthBufferTex, float4(depthtex_uv(uv), 0, 0)).x;
return depth;
}
#line 162
float linearize_depth(float depth)
{
depth *= 1;
#line 176
const float N = 1.0;
depth /= 1000.0 - depth * (1000.0 - N);
#line 179
return saturate(depth);
}
#line 183
float linear_depth(float2 uv)
{
float depth = get_depth(uv);
depth = linearize_depth(depth);
return depth;
}
}
#line 192
void PostProcessVS(in uint id : SV_VertexID, out float4 vpos : SV_Position, out float2 uv : TEXCOORD)
{
uv.x = (id == 2) ? 2.0 : 0.0;
uv.y = (id == 1) ? 2.0 : 0.0;
vpos = float4(uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 56 "C:\Program Files\GShade\gshade-shaders\Shaders\Posterize.fx"
#line 61
struct VSOUT
{
float4   vpos        : SV_Position;
float2   uv          : TEXCOORD0;
};
#line 67
VSOUT VS_Paint(in uint id : SV_VertexID)
{
VSOUT o;
if (id == 2)
o.uv.x = 2.0;
else
o.uv.x = 0.0;
if (id == 1)
o.uv.y = 2.0;
else
o.uv.y = 0.0;
o.vpos = float4(o.uv.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
return o;
}
#line 86
float3 paint_filter(in VSOUT i, in float pass_id)
{
float3 least_divergent = 0;
float3 total_sum = 0;
float min_divergence = 1e10;
#line 92
[loop]
for(int j = 0; j < 5; j++)
{
float2 dir; sincos(radians(180.0 * (j + pass_id / 4) / 5), dir.y, dir.x);
#line 97
float3 col_avg_per_dir = 0;
float curr_divergence = 0;
#line 100
float3 col_prev = tex2Dlod(qUINT::sBackBufferTex, float4(i.uv.xy - dir * 4 * qUINT::PIXEL_SIZE, 0, 0)).rgb;
#line 102
for(int k = -4 + 1; k <= 4; k++)
{
float3 col_curr = tex2Dlod(qUINT::sBackBufferTex, float4(i.uv.xy + dir * k * qUINT::PIXEL_SIZE, 0, 0)).rgb;
col_avg_per_dir += col_curr;
#line 107
const float3 color_diff = abs(col_curr - col_prev);
#line 109
curr_divergence += max(max(color_diff.x, color_diff.y), color_diff.z);
col_prev = col_curr;
}
#line 113
[flatten]
if(curr_divergence < min_divergence)
{
least_divergent = col_avg_per_dir;
min_divergence = curr_divergence;
}
#line 120
total_sum += col_avg_per_dir;
}
#line 123
least_divergent /= 2 * 4;
total_sum /= 2 * 4 * 5;
min_divergence /= 2 * 4;
#line 127
float lumasharpen = dot(least_divergent - total_sum, 0.333);
least_divergent += lumasharpen * 0.7;
#line 130
least_divergent *= saturate(1 - min_divergence * 0);
return least_divergent;
}
#line 138
void PS_Paint_1(in VSOUT i, out float4 o : SV_Target0)
{
o.rgb = paint_filter(i, 1);
o.w = 1;
}
#line 144
void PS_Paint_2(in VSOUT i, out float4 o : SV_Target0)
{
o.rgb = paint_filter(i, 2);
o.w = 1;
}
#line 150
void PS_Paint_3(in VSOUT i, out float4 o : SV_Target0)
{
o.rgb = paint_filter(i, 3);
o.w = 1;
}
#line 156
void PS_Paint_4(in VSOUT i, out float4 o : SV_Target0)
{
o.rgb = paint_filter(i, 4);
o.w = 1;
}
#line 162
void PS_Paint_5(in VSOUT i, out float4 o : SV_Target0)
{
o.rgb = paint_filter(i, 5);
o.w = 1;
}
#line 168
void PS_Posterize(in VSOUT i, out float4 o : SV_Target0)
{
const bool zebra = frac(i.vpos.y * 0.125) > 0.5;
#line 172
int posterized = round(dot(tex2D(qUINT::sBackBufferTex, i.uv).rgb, float3(0.3, 0.59, 0.11)) * 3 + (zebra - 0.5) * ZEBRA_INTENSITY * 0.2);
posterized = clamp(posterized, 0, 3);
#line 175
const float3 palette[4] =
{
PALETTE_COLOR_1,
PALETTE_COLOR_2,
PALETTE_COLOR_3,
PALETTE_COLOR_4
};
#line 183
o = palette[posterized];
#line 186
}
#line 192
technique Posterize
{
pass
{
VertexShader = VS_Paint;
PixelShader  = PS_Paint_1;
}
pass
{
VertexShader = VS_Paint;
PixelShader  = PS_Paint_2;
}
pass
{
VertexShader = VS_Paint;
PixelShader  = PS_Paint_3;
}
pass
{
VertexShader = VS_Paint;
PixelShader  = PS_Paint_4;
}
pass
{
VertexShader = VS_Paint;
PixelShader  = PS_Posterize;
}
}

