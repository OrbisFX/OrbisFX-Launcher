#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicBloom.fx"
#line 23
uniform float BlurRadius <
ui_type = "slider";
ui_label = "Blur radius";
ui_min = 0.0; ui_max = 32.0; ui_step = 0.2;
> = 6.0;
#line 29
uniform int BlurSamples <
ui_type = "slider";
ui_label = "Blur samples";
ui_min = 2; ui_max = 32;
> = 6;
#line 43
float get_weight(float progress)
{
float bottom = min(progress, 0.5);
float top = max(progress, 0.5);
return 2.0 *(bottom*bottom +top +top -top*top) -1.5;
}
#line 50
float get_2D_weight(float2 position)
{ return get_weight( min(length(position), 1.0) ); }
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
#line 59 "C:\Program Files\GShade\gshade-shaders\Shaders\FilmicBloom.fx"
#line 64
void FilmicBloomPS(float4 vpos : SV_Position, float2 tex_coord : TEXCOORD, out float3 softened : SV_Target)
{
softened = 0.0;
#line 68
float total_weight = 0.0;
#line 70
for(int y=0; y<BlurSamples; y++)
for(int x=0; x<BlurSamples; x++)
{
float2 current_position = float2(x,y)/BlurSamples;
#line 75
float current_weight = get_2D_weight(1.0-current_position);
#line 77
float2 current_offset = float2((1.0 / 1920), (1.0 / 1018))*BlurRadius*current_position*(1.0-current_weight);
#line 79
total_weight += current_weight;
#line 81
softened += (
tex2Dlod(ReShade::BackBuffer, float4(tex_coord+current_offset, 0.0, 0.0) ).rgb+
tex2Dlod(ReShade::BackBuffer, float4(tex_coord-current_offset, 0.0, 0.0) ).rgb+
tex2Dlod(ReShade::BackBuffer, float4(tex_coord+float2(current_offset.x, -current_offset.y), 0.0, 0.0) ).rgb+
tex2Dlod(ReShade::BackBuffer, float4(tex_coord-float2(current_offset.x, -current_offset.y), 0.0, 0.0) ).rgb
) *current_weight;
}
softened /= total_weight*4.0;
#line 93
}
#line 99
technique FilmicBloom
<
ui_label = "Filmic Bloom";
ui_tooltip = "Simulates organic look of film to digital content";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = FilmicBloomPS;
}
}

