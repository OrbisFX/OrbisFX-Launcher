#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Composition.fx"
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
#line 39 "C:\Program Files\GShade\gshade-shaders\Shaders\Composition.fx"
#line 43
uniform int UIGridType <
ui_type = "combo";
ui_label = "Grid Type";
ui_items = "Center Lines\0Thirds\0Fifths\0Golden Ratio\0Diagonals\0";
> = 0;
#line 49
uniform float4 UIGridColor <
ui_type = "color";
ui_label = "Grid Color";
> = float4(0.0, 0.0, 0.0, 1.0);
#line 54
uniform float UIGridLineWidth <
ui_type = "slider";
ui_label = "Grid Line Width";
ui_min = 0.0; ui_max = 5.0;
ui_steps = 0.01;
> = 1.0;
#line 61
struct sctpoint {
float3 color;
float2 coord;
float2 offset;
};
#line 67
sctpoint NewPoint(float3 color, float2 offset, float2 coord)
{
sctpoint p;
p.color = color;
p.offset = offset;
p.coord = coord;
return p;
}
#line 76
float3 DrawPoint(float3 texcolor, sctpoint p, float2 texcoord)
{
float2 pixelsize = float2((1.0 / 1280), (1.0 / 720)) * p.offset;
#line 80
if(p.coord.x == -1 || p.coord.y == -1)
return texcolor;
#line 83
if(texcoord.x <= p.coord.x + pixelsize.x &&
texcoord.x >= p.coord.x - pixelsize.x &&
texcoord.y <= p.coord.y + pixelsize.y &&
texcoord.y >= p.coord.y - pixelsize.y)
return p.color;
return texcolor;
}
#line 91
float3 Composition_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
const float3 background = tex2D(ReShade::BackBuffer, texcoord).rgb;
float3 result;
#line 96
switch (UIGridType)
{
#line 99
case 0:
{
sctpoint lineV1 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(0.5, texcoord.y));
sctpoint lineH1 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(texcoord.x, 0.5));
#line 104
result = DrawPoint(background, lineV1, texcoord);
result = DrawPoint(result, lineH1, texcoord);
break;
}
#line 109
case 1:
{
sctpoint lineV1 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(1.0 / 3.0, texcoord.y));
sctpoint lineV2 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(2.0 / 3.0, texcoord.y));
#line 114
sctpoint lineH1 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(texcoord.x, 1.0 / 3.0));
sctpoint lineH2 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(texcoord.x, 2.0 / 3.0));
#line 117
result = DrawPoint(background, lineV1, texcoord);
result = DrawPoint(result, lineV2, texcoord);
result = DrawPoint(result, lineH1, texcoord);
result = DrawPoint(result, lineH2, texcoord);
#line 122
break;
}
#line 125
case 2:
{
sctpoint lineV1 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(1.0 / 5.0, texcoord.y));
sctpoint lineV2 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(2.0 / 5.0, texcoord.y));
sctpoint lineV3 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(3.0 / 5.0, texcoord.y));
sctpoint lineV4 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(4.0 / 5.0, texcoord.y));
#line 132
sctpoint lineH1 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(texcoord.x, 1.0 / 5.0));
sctpoint lineH2 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(texcoord.x, 2.0 / 5.0));
sctpoint lineH3 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(texcoord.x, 3.0 / 5.0));
sctpoint lineH4 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(texcoord.x, 4.0 / 5.0));
#line 137
result = DrawPoint(background, lineV1, texcoord);
result = DrawPoint(result, lineV2, texcoord);
result = DrawPoint(result, lineV3, texcoord);
result = DrawPoint(result, lineV4, texcoord);
result = DrawPoint(result, lineH1, texcoord);
result = DrawPoint(result, lineH2, texcoord);
result = DrawPoint(result, lineH3, texcoord);
result = DrawPoint(result, lineH4, texcoord);
#line 146
break;
}
#line 149
case 3:
{
sctpoint lineV1 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(1.0 / 1.6180339887, texcoord.y));
sctpoint lineV2 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(1.0 - 1.0 / 1.6180339887, texcoord.y));
#line 154
sctpoint lineH1 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(texcoord.x, 1.0 / 1.6180339887));
sctpoint lineH2 = NewPoint(UIGridColor.rgb, UIGridLineWidth, float2(texcoord.x, 1.0 - 1.0 / 1.6180339887));
#line 157
result = DrawPoint(background, lineV1, texcoord);
result = DrawPoint(result, lineV2, texcoord);
result = DrawPoint(result, lineH1, texcoord);
result = DrawPoint(result, lineH2, texcoord);
#line 162
break;
}
#line 165
case 4:
{
float slope = (float)1280 / (float)720;
#line 169
sctpoint line1 = NewPoint(UIGridColor.rgb, UIGridLineWidth,    float2(texcoord.x, texcoord.x * slope));
sctpoint line2 = NewPoint(UIGridColor.rgb, UIGridLineWidth,  float2(texcoord.x, 1.0 - texcoord.x * slope));
sctpoint line3 = NewPoint(UIGridColor.rgb, UIGridLineWidth,   float2(texcoord.x, (1.0 - texcoord.x) * slope));
sctpoint line4 = NewPoint(UIGridColor.rgb, UIGridLineWidth,  float2(texcoord.x, texcoord.x * slope + 1.0 - slope));
#line 174
result = DrawPoint(background, line1, texcoord);
result = DrawPoint(result, line2, texcoord);
result = DrawPoint(result, line3, texcoord);
result = DrawPoint(result, line4, texcoord);
#line 179
break;
}
}
#line 183
return lerp(background, result, UIGridColor.w);
}
#line 187
technique Composition
{
pass {
VertexShader = PostProcessVS;
PixelShader = Composition_PS;
}
}

