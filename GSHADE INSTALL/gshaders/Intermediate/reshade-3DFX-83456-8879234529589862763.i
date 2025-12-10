// FILTCAP=0.04
// FILTCAPG=(FILTCAP/2)
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\3DFX.fx"
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
#line 14 "C:\Program Files\GShade\gshade-shaders\Shaders\3DFX.fx"
#line 15
uniform float DITHERAMOUNT <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Dither Amount [3DFX]";
> = 0.5;
#line 22
uniform int DITHERBIAS <
ui_type = "slider";
ui_min = -16;
ui_max = 16;
ui_label = "Dither Bias [3DFX]";
> = -1;
#line 29
uniform float LEIFX_LINES <
ui_type = "slider";
ui_min = 0.0;
ui_max = 2.0;
ui_label = "Lines Intensity [3DFX]";
> = 1.0;
#line 36
uniform float LEIFX_PIXELWIDTH <
ui_type = "slider";
ui_min = 0.0;
ui_max = 100.0;
ui_label = "Pixel Width [3DFX]";
> = 1.5;
#line 43
uniform float GAMMA_LEVEL <
ui_type = "slider";
ui_min = 0.0;
ui_max = 3.0;
ui_label = "Gamma Level [3DFX]";
> = 1.0;
#line 58
float mod2(float x, float y)
{
return x - y * floor (x/y);
}
#line 63
float fmod(float a, float b)
{
const float c = frac(abs(a/b))*abs(b);
if (a < 0)
return -c;
else
return c;
}
#line 72
float4 PS_3DFX(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 colorInput = tex2D(ReShade::BackBuffer, texcoord);
#line 76
float2 res;
res.x = float2(1280, 720).x;
res.y = float2(1280, 720).y;
#line 80
float2 ditheu = texcoord.xy * res.xy;
#line 82
ditheu.x = texcoord.x * res.x;
ditheu.y = texcoord.y * res.y;
#line 88
const int ditx = int(fmod(ditheu.x, 4.0));
const int dity = int(fmod(ditheu.y, 4.0));
const int ditdex = ditx * 4 + dity; 
float3 color;
float3 colord;
color.r = colorInput.r * 255;
color.g = colorInput.g * 255;
color.b = colorInput.b * 255;
int yeh = 0;
int ohyes = 0;
#line 99
const float erroredtable[16] = {
16,4,13,1,
8,12,5,9,
14,2,15,3,
6,10,7,11
};
#line 111
if (yeh++==ditdex) ohyes = erroredtable[0];
else if (yeh++==ditdex) ohyes = erroredtable[1];
else if (yeh++==ditdex) ohyes = erroredtable[2];
else if (yeh++==ditdex) ohyes = erroredtable[3];
else if (yeh++==ditdex) ohyes = erroredtable[4];
else if (yeh++==ditdex) ohyes = erroredtable[5];
else if (yeh++==ditdex) ohyes = erroredtable[6];
else if (yeh++==ditdex) ohyes = erroredtable[7];
else if (yeh++==ditdex) ohyes = erroredtable[8];
else if (yeh++==ditdex) ohyes = erroredtable[9];
else if (yeh++==ditdex) ohyes = erroredtable[10];
else if (yeh++==ditdex) ohyes = erroredtable[11];
else if (yeh++==ditdex) ohyes = erroredtable[12];
else if (yeh++==ditdex) ohyes = erroredtable[13];
else if (yeh++==ditdex) ohyes = erroredtable[14];
else if (yeh++==ditdex) ohyes = erroredtable[15];
#line 129
ohyes = 17 - (ohyes - 1); 
ohyes *= DITHERAMOUNT;
ohyes += DITHERBIAS;
#line 133
colord.r = color.r + ohyes;
colord.g = color.g + (float(ohyes) / 2.0);
colord.b = color.b + ohyes;
colorInput.rgb = colord.rgb * 0.003921568627451; 
#line 142
const float why = 1;
float3 reduceme = 1;
const float radooct = 32;	
#line 146
reduceme.r = pow(colorInput.r, why);
reduceme.r *= radooct;
reduceme.r = float(floor(reduceme.r));
reduceme.r /= radooct;
reduceme.r = pow(reduceme.r, why);
#line 152
reduceme.g = pow(colorInput.g, why);
reduceme.g *= radooct * 2;
reduceme.g = float(floor(reduceme.g));
reduceme.g /= radooct * 2;
reduceme.g = pow(reduceme.g, why);
#line 158
reduceme.b = pow(colorInput.b, why);
reduceme.b *= radooct;
reduceme.b = float(floor(reduceme.b));
reduceme.b /= radooct;
reduceme.b = pow(reduceme.b, why);
#line 164
colorInput.rgb = reduceme.rgb;
#line 167
{
float leifx_linegamma = (LEIFX_LINES / 10);
const float horzline1 = 	(fmod(ditheu.y, 2.0));
if (horzline1 < 1)	leifx_linegamma = 0;
#line 172
colorInput.r += leifx_linegamma;
colorInput.g += leifx_linegamma;
colorInput.b += leifx_linegamma;
}
#line 177
return colorInput;
}
#line 180
float4 PS_3DFX1(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 colorInput = tex2D(ReShade::BackBuffer, texcoord);
float2 pixel;
#line 185
pixel.x = 1 / float2(1280, 720).x;
pixel.y = 1 / float2(1280, 720).y;
#line 188
const float3 pixel1 = tex2D(ReShade::BackBuffer, texcoord + float2((pixel.x), 0)).rgb;
const float3 pixel2 = tex2D(ReShade::BackBuffer, texcoord + float2(-pixel.x, 0)).rgb;
float3 pixelblend;
#line 193
{
float3 pixeldiff;
float3 pixelmake;
float3 pixeldiffleft;
#line 198
pixelmake.rgb = 0;
pixeldiff.rgb = pixel2.rgb- colorInput.rgb;
#line 201
pixeldiffleft.rgb = pixel1.rgb - colorInput.rgb;
#line 203
if (pixeldiff.r > 0.04) 		pixeldiff.r = 0.04;
if (pixeldiff.g > (0.04/2)) 		pixeldiff.g = (0.04/2);
if (pixeldiff.b > 0.04) 		pixeldiff.b = 0.04;
#line 207
if (pixeldiff.r < -0.04) 		pixeldiff.r = -0.04;
if (pixeldiff.g < -(0.04/2)) 		pixeldiff.g = -(0.04/2);
if (pixeldiff.b < -0.04) 		pixeldiff.b = -0.04;
#line 211
if (pixeldiffleft.r > 0.04) 		pixeldiffleft.r = 0.04;
if (pixeldiffleft.g > (0.04/2)) 	pixeldiffleft.g = (0.04/2);
if (pixeldiffleft.b > 0.04) 		pixeldiffleft.b = 0.04;
#line 215
if (pixeldiffleft.r < -0.04) 	pixeldiffleft.r = -0.04;
if (pixeldiffleft.g < -(0.04/2)) 	pixeldiffleft.g = -(0.04/2);
if (pixeldiffleft.b < -0.04) 	pixeldiffleft.b = -0.04;
#line 219
pixelmake.rgb = (pixeldiff.rgb / 4) + (pixeldiffleft.rgb / 16);
colorInput.rgb = (colorInput.rgb + pixelmake.rgb);
}
#line 223
return colorInput;
}
#line 226
float4 PS_3DFX2(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 colorInput = tex2D(ReShade::BackBuffer, texcoord);
#line 230
float2 res;
res.x = float2(1280, 720).x;
res.y = float2(1280, 720).y;
#line 238
colorInput.r = pow(abs(colorInput.r), 1.0 / GAMMA_LEVEL);
colorInput.g = pow(abs(colorInput.g), 1.0 / GAMMA_LEVEL);
colorInput.b = pow(abs(colorInput.b), 1.0 / GAMMA_LEVEL);
#line 242
return colorInput;
}
#line 245
technique LeiFx_Tech
{
pass LeiFx
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX;
}
pass LeiFx1
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX1;
}
pass LeiFx2
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX1;
}
pass LeiFx3
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX1;
}
pass LeiFx4
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX1;
}
pass LeiFx5
{
VertexShader = PostProcessVS;
PixelShader = PS_3DFX2;
}
}

