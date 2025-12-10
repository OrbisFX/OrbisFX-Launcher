// MAX_MIPSLEVELS_=2
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\VolumetricFog.fx"
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
#line 11 "C:\Program Files\GShade\gshade-shaders\Shaders\VolumetricFog.fx"
#line 23
uniform float Timer < source = "timer"; >;
#line 28
texture2D TexColor : COLOR;
sampler  sTexColor {Texture = TexColor; };
#line 31
texture2D FogTex { Width = 1920;   Height = 1018;   Format = RGBA8;};
sampler2D sFogTex { Texture = FogTex;};
#line 34
texture2D BlurTex 	{ Width = 1920;   Height = 1018;   Format = RGBA8; MipLevels = 2+1; };
sampler2D sBlurTex	{ Texture = BlurTex;	};
#line 40
uniform float radius <
ui_type = "slider";
ui_max = 200;
ui_label = "Blur Radius";
ui_tooltip = "Increase it along with Intensity\n"
"if you want a denser fog.";
ui_category = "Blurring";
> = 100;
#line 49
uniform int SampleCount <
ui_label = "Blur Quality";
ui_tooltip = "Increase it to reduce noise.\n"
"Also look at Temporal Accumulation or Denoiser\n"
"Cuz this option is a performance killer";
ui_max = 8;
ui_min = 1;
ui_type = "slider";
ui_category = "Blurring";
> = 2;
#line 60
uniform bool TemporalAccum <
ui_type = "radio";
ui_label = "Temporal Accumulation";
ui_tooltip = "If you are using (TFAA) from jak0b,\n"
"use this option to improve blur quality for free";
ui_category = "Blurring";
> = 1;
#line 68
uniform float Intensity <
ui_max = 8;
ui_min = 0;
ui_type = "slider";
ui_tooltip = "Overall power of fog.";
ui_category = "Blending";
> = 1;
#line 76
uniform float MaxIntensity <
ui_type = "slider";
ui_label = "Maximum Intensity";
ui_max = 1;
ui_tooltip = "Intensity of fog is relative to depth\n"
"Objects further away will be affected more than near ones\n"
"You can use this option to avoid fading distant objects completely.";
ui_category = "Blending";
> = 0.8;
#line 86
uniform float Exposure <
ui_type = "slider";
ui_max = 2;
ui_category = "Blending";
> = 1;
#line 92
uniform float Gamma <
ui_type = "slider";
ui_max = 2;
ui_category = "Blending";
> = 1;
#line 105
float noise(float2 co)
{
return frac(sin(dot(co.xy ,float2(1.0,73))) * 43758.5453);
}
#line 110
float3 noise3dts(float2 co, int s, bool t)
{
co += sin(Timer/64)*t;
co += frac(s/3.1415926535);
return float3( noise(co), noise(co+0.6432168421), noise(co+0.19216811));
}
#line 122
float3 Fog( float4 Postion : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
float depth = ReShade::GetLinearizedDepth(texcoord);
float2 p = float2((1.0 / 1920), (1.0 / 1018));;
#line 127
float4 color = float4(tex2D(sTexColor, texcoord).rgb,1);
float4 S = color;
float Radius = sqrt(depth)*radius;
uint iteration = Radius*SampleCount/8;
#line 132
for (int i = 1; i <= iteration; i++)
{
float2 seed = noise3dts( texcoord.xy, i, TemporalAccum).rg;
#line 136
float distance = seed.x;
#line 138
float ang = ((i + seed.y) / iteration) * 3.14159265 * 2;
#line 140
float2 offset; sincos(ang, offset.y, offset.x);
offset *= sqrt(distance);
offset *= p.xy * Radius;
#line 144
float Jdepth =  ReShade::GetLinearizedDepth(texcoord + offset).r;
if( Jdepth >= depth -0.01)
{
S += float4( tex2Dlod( sTexColor, float4(texcoord + offset,0,0)).rgb, 1);
}
}
#line 151
S.rgb /= S.a;
#line 153
float coeff = min( depth*Intensity, MaxIntensity);
#line 156
return S.rgb;
}
#line 159
float3 Blur( float4 Postion : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
float depth = ReShade::GetLinearizedDepth(texcoord);
float2 p = float2((1.0 / 1920), (1.0 / 1018));;
#line 164
float4 color = float4(tex2D(sFogTex, texcoord).rgb,1);
float4 S = color;
#line 167
float Radius = radius/16;
uint iteration = max(SampleCount, 2); 
#line 170
for (int i = 1; i <= iteration; i++)
{
float2 seed = noise3dts( texcoord.xy + 0.33463545721, i, TemporalAccum).rg;
#line 174
float distance = seed.x;
float ang = ((i + seed.y) / iteration) * 3.14159265 * 2;
#line 177
float2 offset; sincos(ang, offset.y, offset.x);
offset *= sqrt(distance);
offset *= p.xy * Radius;
#line 181
float Jdepth =  ReShade::GetLinearizedDepth(texcoord + offset).r;
if( Jdepth >= depth -0.01)
{
S += float4( tex2Dlod( sFogTex, float4(texcoord + offset,0,0)).rgb, 1);
}
}
#line 188
S.rgb /= S.a;
S = pow( abs(S), Gamma)*Exposure;
return S.rgb;
}
#line 193
float3 Blend( float4 Postion : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
float depth = ReShade::GetLinearizedDepth(texcoord);
float2 p = float2((1.0 / 1920), (1.0 / 1018));; p *= pow(2, 2);
#line 198
float4 fog; fog.a = 1; fog.rgb = tex2Dlod(sBlurTex, float4(texcoord,0,2)).rgb;
#line 200
float2 offset[8] =
{
float2(  0, p.y), float2( p.x,  0), float2(   0, -p.y), float2(-p.x,    0),
float2(p.x, p.y), float2(-p.x,p.y), float2(-p.x, -p.y), float2( p.x, -p.y)
};
#line 207
if( 2 != 0)
{
float4 FogSample; FogSample.a = 1;
float3 DepthSample;
for(int i; i<8; i++)
{
FogSample.rgb = tex2Dlod(sBlurTex, float4(texcoord + offset[i]/2, 0, 2)).rgb;
DepthSample = ReShade::GetLinearizedDepth(texcoord + offset[i]*1.5);
if( abs( DepthSample.x - depth.x) < 0.01) fog += FogSample;
}
fog /= fog.a;
}
#line 220
float3 back= tex2D(sTexColor, texcoord).rgb;
#line 222
float coeff = min( depth * Intensity, MaxIntensity);
#line 224
return lerp( back, fog.rgb, coeff);
}
#line 230
technique VolumetricFog <
ui_label = "Volumetric Fog";
ui_tooltip = "Screen  Space  Indirect  Volumetric  Lighting.\n"
"              ||By Ehsan2077||                \n"
"Recommended to use with TFAA for more quality.";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = Fog;
RenderTarget = FogTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = Blur;
RenderTarget = BlurTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = Blend;
}
}

