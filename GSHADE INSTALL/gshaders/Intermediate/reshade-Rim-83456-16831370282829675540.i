#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Rim.fx"
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
#line 11 "C:\Program Files\GShade\gshade-shaders\Shaders\Rim.fx"
#line 23
texture TexColor : COLOR;
sampler sTexColor {Texture = TexColor; SRGBTexture = false;};
#line 26
texture TexDepth : DEPTH;
sampler sTexDepth {Texture = TexDepth; SRGBTexture = false;};
#line 29
texture TexRim { Width = 1920; Height = 1018; Format = RGBA16f; };
sampler sTexRim {Texture = TexRim; SRGBTexture = false;};
#line 32
texture TexHBlur { Width = 1920; Height = 1018; Format = RGBA16f; };
sampler sTexHBlur {Texture = TexHBlur; SRGBTexture = false;};
#line 38
uniform int Blend <
ui_label = "Blend Mode";
ui_type = "combo";
ui_items = "Add\0Color Dodge\0";
> = 0;
#line 44
uniform float smooth <
ui_label = "Rim Width";
ui_type = "slider";
ui_tooltip = "Higher values limits the rim to a tighter area";
ui_category = "Rim";
ui_min = 1;
ui_max = 10;
> = 5;
#line 53
uniform float Rim <
ui_label = "Rim Intensity";
ui_type = "slider";
ui_category = "Rim";
ui_tooltip = "Exposure of the rim";
ui_min = 0;
ui_max = 100;
> = 1;
#line 62
uniform float3 light <
ui_label = "Rim Light Color";
ui_category = "Rim";
ui_type = "color";
> = 1;
#line 69
uniform int BLUR_ITERATION_ <
ui_label = "Bloom Width";
ui_type = "slider";
ui_category = "Bloom";
ui_min = 1;
ui_max = 16;
> = 4;
#line 81
uniform float bloom <
ui_label = "Bloom Intensity";
ui_type = "slider";
ui_category = "Bloom";
ui_min = 0;
ui_max = 10;
> = 1;
#line 89
uniform float MaxDepth <
ui_label = "Max Depth";
ui_tooltip = "Depth Masking End Clipping";
ui_category = "Masking";
ui_type = "slider";
> = 1;
#line 96
uniform float MinDepth <
ui_label = "Min Depth";
ui_category = "Masking";
ui_tooltip = "Depth Masking Start Clipping";
ui_type = "slider";
> = 0;
#line 108
float3 Depth(float2 texcoord)
{
return ReShade::GetLinearizedDepth(texcoord);
}
#line 113
float3 GetNormal(float2 texcoord)
{
float3 offset = float3(float2((1.0 / 1920), (1.0 / 1018)), 0.0);
float2 posCenter = texcoord.xy;
float2 posNorth  = posCenter - offset.zy;
float2 posEast   = posCenter + offset.xz;
#line 120
float3 vertCenter = float3(posCenter - 0.5, 1) * Depth(posCenter);
float3 vertNorth  = float3(posNorth  - 0.5, 1) * Depth(posNorth);
float3 vertEast   = float3(posEast   - 0.5, 1) * Depth(posEast);
#line 124
return normalize(cross(vertCenter - vertNorth, vertCenter - vertEast)) * 0.5 + 0.5;
}
#line 127
float3 GetNormalHQ(float2 texcoord)
{
float3 p = float3(float2((1.0 / 1920), (1.0 / 1018)), 0.0);
float3 h;
float3 v;
#line 135
float3 Sample[6];
Sample[1] = Depth(texcoord + p.zy);
Sample[2] = Depth(texcoord - p.xz);
Sample[3] = Depth(texcoord - p.zy);
Sample[4] = Depth(texcoord + p.xz);
Sample[5] = Depth(texcoord       );
#line 142
h = Sample[5] - Sample[3];
if( dot( 0.333, abs(Sample[5] - Sample[2])) < dot( 0.333, abs(Sample[5] - Sample[3])))
h = Sample[2] - Sample[5];
#line 146
v = Sample[5] - Sample[4];
if( dot( 0.333, abs(Sample[5] - Sample[1])) < dot( 0.333, abs(Sample[5] - Sample[4])))
v = Sample[1] - Sample[5];
#line 151
return float3(h.x,v.x,10) * 0.5 + 0.5;
}
#line 158
float3 rim(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float2 p = float2((1.0 / 1920), (1.0 / 1018));;
float3 normal; normal = GetNormal( texcoord ).z;
#line 165
float3 color = tex2D(sTexColor, texcoord).rgb;
#line 167
normal = 1-normal;
normal = pow(abs(normal), smooth);
normal *= Rim;
#line 171
color = normal * color * (light);
color = color/(color+1);
return color;
}
#line 176
float3 HBlur(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float2 p = float2((1.0 / 1920), (1.0 / 1018));;
float3 Color = 0;
#line 181
for (int i = -BLUR_ITERATION_; i <= BLUR_ITERATION_; i++)
{
int x = abs(i);
Color += (BLUR_ITERATION_ - x)*tex2D( sTexRim, texcoord + float2(( p.r * ( ( 2 * i ) + 0.5 )), 0)).rgb;
}
return Color/((BLUR_ITERATION_*BLUR_ITERATION_));
}
#line 189
float3 VBlur(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float2 p = float2((1.0 / 1920), (1.0 / 1018));;
float3 Color;
float3 Bloom;
float3 Background = tex2D(sTexColor, texcoord).rgb;
float Depth = ReShade::GetLinearizedDepth(texcoord);
#line 197
for (int i = -BLUR_ITERATION_; i <= BLUR_ITERATION_; i++)
{
int x = abs(i);
Color += (BLUR_ITERATION_ - x)*tex2D( sTexHBlur, texcoord + float2(0,( p.g * ( ( 2 * i ) + 0.5 )))).rgb;
}
Bloom = Color/((BLUR_ITERATION_*BLUR_ITERATION_));
#line 204
Bloom *= bloom;
Bloom += tex2D( sTexRim, texcoord).rgb;
Bloom = saturate(Bloom);
float3 Mixed;
if(Blend == 0) Mixed = Bloom + Background;
if(Blend == 1) Mixed = Background / ( 1 - Bloom );
#line 211
Mixed = lerp(Background, Mixed, bool ( Depth < MaxDepth && Depth > MinDepth ));
return Mixed;
#line 214
}
#line 218
technique Rim <
ui_tooltip = "               Rim Light Effect               \n"
"               ||By Ehsan2077||               \n"
"Add an AO shader after this for a better look.";
#line 223
>
{
pass Rim
{
VertexShader = PostProcessVS;
PixelShader = rim;
RenderTarget = TexRim;
}
pass HBlur
{
VertexShader = PostProcessVS;
PixelShader = HBlur;
RenderTarget = TexHBlur;
}
pass VBlur
{
VertexShader = PostProcessVS;
PixelShader = VBlur;
#line 242
}
}

