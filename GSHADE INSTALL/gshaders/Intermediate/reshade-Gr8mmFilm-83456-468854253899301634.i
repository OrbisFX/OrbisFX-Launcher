#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Gr8mmFilm.fx"
#line 33
uniform float Gr8mmFilmVignettePower <
ui_type = "slider";
ui_min = 0; ui_max = 2;
ui_step = 0.01;
ui_tooltip = "Strength of the effect at the edges";
ui_label = "Vignette strength";
> = 1.0;
#line 41
uniform float Gr8mmFilmPower <
ui_type = "slider";
ui_min = 0; ui_max = 1;
ui_step = 0.01;
ui_tooltip = "Overall intensity of the effect";
ui_label = "Overall strength";
> = 1.0;
#line 49
uniform float Gr8mmFilmAlphaPower <
ui_type = "slider";
ui_min = 0; ui_max = 2;
ui_step = 0.01;
ui_tooltip = "Takes gradients into account (white => transparent)";
ui_label = "Alpha";
> = 1.0;
#line 68
uniform float2 filmroll < source = "pingpong"; min = 0.0f; max = (7.0-1); step = float2(1.0f, 2.0f); >;
#line 71
texture Gr8mmFilmTex < source = "CFX_Gr8mmFilm.png"; > { Width = 1280; Height = 5040; Format = RGBA8; };
sampler	Gr8mmFilmColor 	{ Texture = Gr8mmFilmTex; };
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
#line 75 "C:\Program Files\GShade\gshade-shaders\Shaders\Gr8mmFilm.fx"
#line 76
float4 PS_Gr8mmFilm(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
const float4 singleGr8mmFilm = tex2D(Gr8mmFilmColor, float2(texcoord.x, texcoord.y/7.0 + (5040/7.0/5040)*
#line 82
trunc(filmroll.x)
#line 84
));
const float alpha = saturate(saturate(max(abs(texcoord.x-0.5f),abs(texcoord.y-0.5f))*Gr8mmFilmVignettePower + 0.75f - (singleGr8mmFilm.x+singleGr8mmFilm.y+singleGr8mmFilm.z)*Gr8mmFilmAlphaPower/3f));
return lerp(tex2D(ReShade::BackBuffer, texcoord), singleGr8mmFilm, Gr8mmFilmPower*(alpha*alpha));
}
#line 89
technique Gr8mmFilm
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Gr8mmFilm;
}
}

