#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Halftone.fx"
#line 17
texture BackBuffer:COLOR;
#line 20
sampler sBackBuffer{Texture = BackBuffer;};
#line 22
uniform float Strength<
ui_type = "slider";
ui_label = "Strength";
ui_tooltip = "Changes how much of the color is from the dots vs. the original image.";
ui_min = 0; ui_max = 1;
ui_step = 0.001;
> = 1;
#line 30
uniform float KStrength<
ui_type = "slider";
ui_label = "K-Strength";
ui_tooltip = "Changes how much K is used to subtract from the color dots";
ui_min = 0; ui_max = 1;
ui_step = 0.001;
> = 0.5;
#line 38
uniform float3 PaperColor<
ui_type = "color";
ui_label = "Paper Color";
ui_min = 0; ui_max = 1;
> = 1;
#line 44
uniform float Angle<
ui_type = "slider";
ui_label = "Angle";
ui_tooltip = "Changles the angle that the dots are laid out in, helps with aliasing patterns.";
ui_min = 0; ui_max = 1;
ui_step = 0.001;
> = 0.33;
#line 52
uniform float Scale<
ui_type = "slider";
ui_label = "Scale";
ui_tooltip = "Changes the size of the dots in the halftone pattern.";
ui_min = 1; ui_max = 9;
ui_step = 1;
> = 3;
#line 60
uniform bool SuperSample = true;
#line 65
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 72
float2x2 rotationMatrix(float angle)
{
float2 trig;
sincos(angle, trig.x, trig.y);
#line 77
return float2x2(float2(trig.x, -trig.y), float2(trig.y, trig.x));
}
#line 80
float2 scaledTexcoord(float2 texcoord, float angle, float scale)
{
float2x2 rot = rotationMatrix(angle);
#line 85
float2 scaledTexcoord = mul((texcoord) * float2(float(1920) / float(1018), 1), rot);
scaledTexcoord = (round(scaledTexcoord / scale)) * scale;
scaledTexcoord = mul(scaledTexcoord, transpose(rot)) / float2(float(1920) / float(1018), 1);
#line 89
return scaledTexcoord;
}
#line 92
float4 sRGBToCMYK(float3 sRGB)
{
float4 cmyk;
cmyk.xyz = saturate(PaperColor - sRGB);
cmyk.w = (min(min(cmyk.x, cmyk.y), cmyk.z)) * KStrength;
cmyk.xyz = (PaperColor - sRGB - cmyk.w) / (1 - cmyk.w);
return saturate(cmyk);
}
#line 101
float coveragePercent(float2 dotCenter, float2 pixelCenter, float tonalValue, float scale)
{
#line 104
float radius = (scale * tonalValue * 0.5) / 0.7;
#line 106
float2 fromCenter = (pixelCenter - dotCenter) * float2(float(1920) / float(1018), 1);
#line 108
float dist = length(fromCenter);
#line 110
float wd = fwidth(dist) * sqrt(0.5);
#line 112
return smoothstep(radius+wd, radius-wd, dist);
}
#line 115
float4 CMYKSample(const float2 texcoord, const float scale)
{
float4 output;
#line 119
float2 coord;
float4 value;
#line 122
output = 0;
float2 rotatedCoord = mul(texcoord * float2(float(1920) / float(1018), 1), rotationMatrix(3.14159265/4)) / float2(float(1920) / float(1018), 1);
coord = scaledTexcoord(texcoord.xy, 0 + Angle, scale);
value = sRGBToCMYK(tex2D(sBackBuffer, coord).rgb);
output.z = coveragePercent(coord, texcoord, value.z, scale);
#line 128
coord = scaledTexcoord(texcoord.xy, 3.14159265/12 + Angle, scale);
value = sRGBToCMYK(tex2D(sBackBuffer, coord).rgb);
output.x = coveragePercent(coord, texcoord, value.x, scale);
#line 132
coord = scaledTexcoord(texcoord.xy, 3.14159265/4 + Angle, scale);
value = sRGBToCMYK(tex2D(sBackBuffer, coord).rgb);
output.w = coveragePercent(coord, texcoord, value.w, scale);
#line 136
coord = scaledTexcoord(texcoord.xy, (5*3.14159265)/12 + Angle, scale);
value = sRGBToCMYK(tex2D(sBackBuffer, coord).rgb);
output.y = coveragePercent(coord, texcoord, value.y, scale);
#line 140
return output;
}
#line 143
void OutputPS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD, out float4 output : SV_TARGET0)
{
float scale = (1 / (1018 / Scale));
#line 147
output = 0;
#line 149
float4 values[4];
float2 coords[4];
#line 153
for(int i = 0; i < 4; i++)
{
values[i] = sqrt(values[i]);
}
if(SuperSample)
{
#line 160
[unroll]
for(int i = 1; i <= 2; i++)
{
[unroll]
for(int j = 1; j <= 2; j++)
{
float2 offset = (float2(i, j) / 3.0) - 0.5;
offset *= float2((1.0 / 1920), (1.0 / 1018));
output += CMYKSample(texcoord + offset, scale);
}
}
output /= 4;
}
else
{
#line 176
output += CMYKSample(texcoord, scale);
}
#line 179
float4 value = sRGBToCMYK(tex2D(sBackBuffer, texcoord).rgb);
#line 181
output.xyz = (output.w > 0.99) ? 0 : output.xyz;
output = lerp(value, output, Strength);
#line 184
output.rgb = ((1 - output.xyz) * (1 - output.w));
output.rgb = (output.rgb - (1 - PaperColor));
output.a = 1;
#line 188
}
#line 190
technique Halftone <ui_tooltip = "This shader emulates the CMYK halftoning commonly found in offset printing, \n"
"to give the image a printer-like effect.\n\n"
"Part of Insane Shaders\n"
"By: Lord Of Lunacy";>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = OutputPS;
}
}

