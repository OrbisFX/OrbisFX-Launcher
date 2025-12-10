// ASPECT_RATIO_SUITE_VALUES=9/16., 1, 4/3., 16/9., 64/27., 32/9.
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\AspectRatioSuite.fx"
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
#line 34 "C:\Program Files\GShade\gshade-shaders\Shaders\AspectRatioSuite.fx"
#line 47
struct Mask
{
float value, is_horizontal;
};
#line 52
struct Rect
{
float2 pos, size;
};
#line 57
Rect Rect_new(float4 value)
{
Rect r;
r.pos = value.xy;
r.size = value.zw;
#line 63
return r;
}
#line 66
Rect Rect_new(float2 pos, float2 size)
{
return Rect_new(float4(pos, size));
}
#line 71
Rect Rect_new(float x, float y, float width, float height)
{
return Rect_new(float4(x, y, width, height));
}
#line 76
float4 Rect_values(Rect r)
{
return float4(r.pos, r.size);
}
#line 81
float Rect_contains(Rect r, float2 p)
{
return
step(r.pos.x, p.x) * step(r.pos.y, p.y) *
step(p.x, r.pos.x + r.size.x) * step(p.y, r.pos.y + r.size.y);
}
#line 92
static const float ASPECT_RATIOS[] = {9/16., 1, 4/3., 16/9., 64/27., 32/9., 0.0};
#line 98
uniform int Mode
<
ui_type = "radio";
ui_text =
"Set the mode you want to use and it's appropriate parameters:\n"
" - Letterbox: Displays bars on the image to 'correct' aspect ratio.\n"
" - Test Box: Displays a box in the center of the screen representing "
"the selected aspect ratio.\n"
" - Multi-Test Box: Same as Test Box but shows multiple boxes from "
"aspect ratios defined in the ASPECT_RATIO_SUITE_VALUES macro.\n"
"\nThe macro for Multi-Test Box mode is defined as a comma-separated "
"list of aspect ratios, which can be defined as the division of two "
"decimal numbers.\n"
"\nFor example, '4.0 / 3.0, 16.0 / 9.0, 1.0', would tell the effect "
"to display boxes for 4:3, 16:9 and 1:1 aspect ratios.\n"
"\nFor short-handing, you could also define the same values as "
"'4/3., 16/9., 1', since you only need one of the numbers in the "
"division to be decimal and it's decimal places can be omitted.\n"
"\nRemember you can also pass the mouse cursor over a parameter's name "
"to see a more detailed description and it's default value.\n"
"\n";
ui_label = "Mode";
ui_tooltip = "Default: Letterbox";
ui_items = "Letterbox\0Test Box\0Multi-Test Box\0";
> = 0;
#line 124
uniform float2 ARSAspectRatio
<
ui_type = "drag";
ui_label = "Aspect Ratio";
ui_tooltip =
"The aspect ratio to calculate the border/box from.\n"
"Unused for Multi-Test mode, which uses the "
"ASPECT_RATIO_SUITE_VALUES macro.\n"
"\nDefault: 4.0 3.0";
ui_min = 1;
ui_max = 100;
ui_step = 0.01;
> = float2(4.0, 3.0);
#line 138
uniform float4 LetterBoxColor
<
ui_type = "color";
ui_label = "Letterbox Color";
ui_tooltip =
"Color of the bars that appear in Letterbox mode.\n"
"\nDefault: 0 0 0 255";
> = float4(0.0, 0.0, 0.0, 1.0);
#line 147
uniform float4 BackgroundColor
<
ui_type = "color";
ui_label = "Background Color";
ui_tooltip =
"Background color applied in either test mode.\n"
"To disable, simply set the alpha value to zero.\n"
"\nDefault: 0 0 0 0";
> = float4(0.0, 0.0, 0.0, 0.0);
#line 157
uniform float TestBoxSize
<
ui_type = "slider";
ui_label = "Test Box Size";
ui_tooltip =
"Size of the box(es) that appear in either test mode.\n"
"1.0: full screen size\n"
"0.5: half screen size\n"
"0.0: hidden\n"
"\nDefault: 0.5";
ui_min = 0.0;
ui_max = 1.0;
> = 1.0;
#line 171
uniform float4 TestBoxColor
<
ui_type = "color";
ui_label = "Test Box Color";
ui_tooltip =
"Color of the Test Box mode's aspect ratio box.\n"
"The alpha value is used for transparency in Multi-Test Box mode.\n"
"\nDefault: 255 0 0 255";
> = float4(1.0, 0.0, 1.0, 1.0);
#line 188
float2 scale_uv(float2 uv, float2 scale, float2 pivot)
{
return (uv - pivot) * scale + pivot;
}
#line 196
float3 hsv_to_rgb(float3 hsv)
{
float4 k = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
float3 p = abs(frac(hsv.xxx + k.xyz) * 6.0 - k.www);
return hsv.z * lerp(k.xxx, saturate(p - k.xxx), hsv.y);
}
#line 206
float inside(float x, float a, float b)
{
return step(a, x) * step(x, b);
}
#line 215
Mask calc_mask(float ar)
{
Mask mask;
mask.is_horizontal = step(ReShade::GetAspectRatio(), ar);
#line 220
const float ratio = lerp(
ar / ReShade::GetAspectRatio(),
ReShade::GetAspectRatio() / ar,
mask.is_horizontal
);
mask.value = (1.0 - ratio) * 0.5;
#line 227
return mask;
}
#line 235
float calc_border(float2 uv, Mask mask)
{
#line 239
const float pos = lerp(uv.x, uv.y, mask.is_horizontal);
#line 241
return step(mask.value, pos) * step(pos, 1.0 - mask.value);
}
#line 249
float calc_box(float2 uv, Mask m, float scale)
{
float4 uv_ps = float4(uv, ReShade::GetPixelSize());
uv_ps = lerp(uv_ps, uv_ps.yxwz, m.is_horizontal);
#line 254
m.value = lerp(0.5, m.value, scale);
#line 256
Rect r = Rect_new(
m.value,
0.5 - scale * 0.5,
1.0 - (2.0 * m.value),
scale
);
#line 263
return
Rect_contains(r, uv_ps.xy) !=
Rect_contains(
Rect_new(r.pos + uv_ps.zw, r.size - uv_ps.zw * 2.0),
uv_ps.xy
);
}
#line 275
float4 MainPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
float4 color = tex2D(ReShade::BackBuffer, uv);
#line 279
switch (Mode)
{
case 0: 
{
const Mask mask = calc_mask(ARSAspectRatio.x / ARSAspectRatio.y);
const float border = calc_border(uv, mask);
#line 286
color.rgb = lerp(
LetterBoxColor.rgb,
color.rgb,
lerp(1.0, border, LetterBoxColor.a)
);
} break;
case 1: 
{
color.rgb = lerp(color.rgb, BackgroundColor.rgb, BackgroundColor.a);
#line 296
const Mask mask = calc_mask(ARSAspectRatio.x / ARSAspectRatio.y);
#line 298
float box = calc_box(uv, mask, TestBoxSize);
box *= TestBoxColor.a;
#line 301
color.rgb = lerp(color.rgb, TestBoxColor.rgb, box);
} break;
case 2: 
{
color.rgb = lerp(color.rgb, BackgroundColor.rgb, BackgroundColor.a);
#line 307
for (int i = 0; ASPECT_RATIOS[i] != 0.0; ++i)
{
const float3 ratio_color = hsv_to_rgb(float3(i / 10.0, 1.0, 1.0));
#line 311
const Mask mask = calc_mask(ASPECT_RATIOS[i]);
#line 313
float box = calc_box(uv, mask, TestBoxSize);
box *= TestBoxColor.a;
#line 316
color.rgb = lerp(color.rgb, ratio_color, box);
}
} break;
}
#line 321
return color;
}
#line 324
technique AspectRatioSuite
{
pass
{
VertexShader = PostProcessVS;
PixelShader = MainPS;
}
}

