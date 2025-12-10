#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\GTU.fx"
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
#line 9 "C:\Program Files\GShade\gshade-shaders\Shaders\GTU.fx"
#line 14
uniform float texture_sizeX <
ui_type = "slider";
ui_min = 1.0;
ui_max = 1920;
ui_label = "Screen Width (GTU)";
> = 320.0;
#line 21
uniform float texture_sizeY <
ui_type = "slider";
ui_min = 1.0;
ui_max = 1018;
ui_label = "Screen Height (GTU)";
> = 240.0;
#line 28
uniform float video_sizeX <
ui_type = "slider";
ui_min = 1.0;
ui_max = 1920;
ui_label = "Frame Width (GTU)";
ui_tooltip = "This should be sized according to the video data in the texture (If you're using emulators, set this to the Emu video frame size, otherwise, keep it the same as Screen Width/Height or Fullscreen res.)";
> = 320.0;
#line 36
uniform float video_sizeY <
ui_type = "slider";
ui_min = 1.0;
ui_max = 1018;
ui_label = "Frame Height (GTU)";
ui_tooltip = "This should be sized according to the video data in the texture (If you're using emulators, set this to the Emu video frame size, otherwise, keep it the same as Screen Width/Height or Fullscreen res.)";
> = 240.0;
#line 44
uniform bool compositeConnection <
ui_label = "Enables Composite Connection (GTU)";
> = 0;
#line 48
uniform bool noScanlines <
ui_label = "Disables Scanlines (GTU)";
> = 0;
#line 52
uniform float signalResolution <
ui_type = "slider";
ui_min = 16.0; ui_max = 1024.0;
ui_tooltip = "Signal Resolution Y (GTU)";
ui_step = 16.0;
> = 256.0;
#line 59
uniform float signalResolutionI <
ui_type = "slider";
ui_min = 1.0; ui_max = 350.0;
ui_tooltip = "Signal Resolution I (GTU)";
ui_step = 2.0;
> = 83.0;
#line 66
uniform float signalResolutionQ <
ui_type = "slider";
ui_min = 1.0; ui_max = 350.0;
ui_tooltip = "Signal Resolution Q (GTU)";
ui_step = 2.0;
> = 25.0;
#line 73
uniform float tvVerticalResolution <
ui_type = "slider";
ui_min = 20.0; ui_max = 1000.0;
ui_tooltip = "TV Vertical Resolution (GTU)";
ui_step = 10.0;
> = 250.0;
#line 80
uniform float blackLevel <
ui_type = "slider";
ui_min = -0.30; ui_max = 0.30;
ui_tooltip = "Black Level (GTU)";
ui_step = 0.01;
> = 0.07;
#line 87
uniform float contrast <
ui_type = "slider";
ui_min = 0.0; ui_max = 2.0;
ui_tooltip = "Constrast (GTU)";
ui_step = 0.1;
> = 1.0;
#line 94
texture target0_gtu
{
Width = 1920;
Height = 1018;
Format = RGBA32F;
};
sampler s0 { Texture = target0_gtu; };
#line 112
float normalGaussIntegral(float x)
{
const float t = 1.0 / (1.0 + 0.3326700 * abs(x));
return (0.5 - ((exp(-(x) * (x) * 0.5)) / sqrt(2.0 * 3.14159265358)) * (t * (0.4361836 + t * (-0.1201676 + 0.9372980 * t)))) * sign(x);
}
#line 118
float3 scanlines( float x , float3 c)
{
const float temp = sqrt(2 * 3.14159265358) * (tvVerticalResolution / texture_sizeY);
#line 122
const float rrr = 0.5 * (texture_sizeY / ReShade::GetScreenSize().y);
const float x1 = (x + rrr) * temp;
const float x2 = (x - rrr) * temp;
c.r = (c.r * (normalGaussIntegral(x1) - normalGaussIntegral(x2)));
c.g = (c.g * (normalGaussIntegral(x1) - normalGaussIntegral(x2)));
c.b = (c.b * (normalGaussIntegral(x1) - normalGaussIntegral(x2)));
c *= (ReShade::GetScreenSize().y / texture_sizeY);
return c;
}
#line 132
float4 PS_GTU1(float4 vpos : SV_Position, float2 tex : TexCoord) : SV_Target
{
float4 c = tex2D(ReShade::BackBuffer, tex);
if(compositeConnection)
{
c.rgb = mul(transpose(float3x3( 0.299 , 0.595716 , 0.211456 , 0.587 , -0.274453 , -0.522591 , 0.114 , -0.321263 , 0.311135 )), c.rgb);
}
return c;
}
#line 142
float4 PS_GTU2(float4 vpos : SV_Position, float2 tex : TexCoord) : SV_Target
{
const float offset   = frac((tex.x * float2(texture_sizeX, texture_sizeY).x) - 0.5);
float3 tempColor = float3(0.0,0.0,0.0);
float X;
float3 c;
float range;
if (compositeConnection)
{
range = ceil(0.5 + float2(video_sizeX, video_sizeY).x / min(min(signalResolution,signalResolutionI),signalResolutionQ));
}
else
{
range = ceil(0.5 + float2(video_sizeX, video_sizeY).x / signalResolution);
}
#line 158
float i;
if(compositeConnection)
{
for (i = -range; i < range + 2.0; i++)
{
X = (offset - i);
c = tex2Dlod(s0, float4(float2(tex.x - X / float2(texture_sizeX, texture_sizeY).x, tex.y), 0.0, 0.0)).rgb;
tempColor += float3((c.x * (((3.14159265358 * (signalResolution / float2(video_sizeX, video_sizeY).x) * min(abs(X) + 0.5, 1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x))) + sin((3.14159265358 * (signalResolution / float2(video_sizeX, video_sizeY).x) * min(abs(X) + 0.5, 1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x)))) - (3.14159265358 * (signalResolution / float2(video_sizeX, video_sizeY).x) * min(max(abs(X) - 0.5, -1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x)), 1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x))) - sin((3.14159265358 * (signalResolution / float2(video_sizeX, video_sizeY).x) * min(max(abs(X) - 0.5, -1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x)), 1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x))))) / (2.0 * 3.14159265358))), (c.y * (((3.14159265358 * (signalResolutionI / float2(video_sizeX, video_sizeY).x) * min(abs(X) + 0.5, 1.0 / (signalResolutionI / float2(video_sizeX, video_sizeY).x))) + sin((3.14159265358 * (signalResolutionI / float2(video_sizeX, video_sizeY).x) * min(abs(X) + 0.5, 1.0 / (signalResolutionI / float2(video_sizeX, video_sizeY).x)))) - (3.14159265358 * (signalResolutionI / float2(video_sizeX, video_sizeY).x) * min(max(abs(X) - 0.5, -1.0 / (signalResolutionI / float2(video_sizeX, video_sizeY).x)), 1.0 / (signalResolutionI / float2(video_sizeX, video_sizeY).x))) - sin((3.14159265358 * (signalResolutionI / float2(video_sizeX, video_sizeY).x) * min(max(abs(X) - 0.5, -1.0 / (signalResolutionI / float2(video_sizeX, video_sizeY).x)), 1.0 / (signalResolutionI / float2(video_sizeX, video_sizeY).x))))) / (2.0 * 3.14159265358))), c.z * (((3.14159265358 * (signalResolutionQ / float2(video_sizeX, video_sizeY).x) * min(abs(X) + 0.5, 1.0 / (signalResolutionQ / float2(video_sizeX, video_sizeY).x))) + sin((3.14159265358 * (signalResolutionQ / float2(video_sizeX, video_sizeY).x) * min(abs(X) + 0.5, 1.0 / (signalResolutionQ / float2(video_sizeX, video_sizeY).x)))) - (3.14159265358 * (signalResolutionQ / float2(video_sizeX, video_sizeY).x) * min(max(abs(X) - 0.5, -1.0 / (signalResolutionQ / float2(video_sizeX, video_sizeY).x)), 1.0 / (signalResolutionQ / float2(video_sizeX, video_sizeY).x))) - sin((3.14159265358 * (signalResolutionQ / float2(video_sizeX, video_sizeY).x) * min(max(abs(X) - 0.5, -1.0 / (signalResolutionQ / float2(video_sizeX, video_sizeY).x)), 1.0 / (signalResolutionQ / float2(video_sizeX, video_sizeY).x))))) / (2.0 * 3.14159265358)));
}
}
else
{
for (i = -range; i < range + 2.0; i++)
{
X = (offset - i);
c = tex2Dlod(s0, float4(float2(tex.x - X / float2(texture_sizeX, texture_sizeY).x, tex.y), 0.0, 0.0)).rgb;
tempColor += c * (((3.14159265358 * (signalResolution / float2(video_sizeX, video_sizeY).x) * min(abs(X) + 0.5, 1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x))) + sin((3.14159265358 * (signalResolution / float2(video_sizeX, video_sizeY).x) * min(abs(X) + 0.5, 1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x)))) - (3.14159265358 * (signalResolution / float2(video_sizeX, video_sizeY).x) * min(max(abs(X) - 0.5, -1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x)), 1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x))) - sin((3.14159265358 * (signalResolution / float2(video_sizeX, video_sizeY).x) * min(max(abs(X) - 0.5, -1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x)), 1.0 / (signalResolution / float2(video_sizeX, video_sizeY).x))))) / (2.0 * 3.14159265358));
}
}
if(compositeConnection)
{
tempColor = clamp(mul(transpose(float3x3(1.0 , 1.0  , 1.0 , 0.9563 , -0.2721 , -1.1070 , 0.6210 , -0.6474 , 1.7046)), tempColor), 0.0, 1.0);
}
else
{
tempColor = clamp(tempColor, 0.0, 1.0);
}
#line 189
return float4(tempColor, 1.0);
#line 191
}
#line 193
float4 PS_GTU3(float4 vpos : SV_Position, float2 tex : TexCoord) : SV_Target
{
const float2 offset = frac((tex.xy * float2(texture_sizeX, texture_sizeY)) - 0.5);
float3 tempColor = float3(0.0, 0.0, 0.0);
#line 198
const float range = ceil(0.5 + float2(video_sizeX, video_sizeY).y / tvVerticalResolution);
#line 200
float i;
#line 202
if (noScanlines)
{
for (i =- range; i < range + 2.0; i++)
{
tempColor += ((tex2Dlod(ReShade::BackBuffer, float4(float2(tex.x, tex.y - (offset.y - (i)) / float2(texture_sizeX, texture_sizeY).y), 0.0, 0.0)).xyz) * (((3.14159265358 * (tvVerticalResolution / float2(video_sizeX, video_sizeY).y) * min(abs((frac((tex.xy * float2(texture_sizeX, texture_sizeY)) - 0.5).y - (i))) + 0.5, 1.0 / (tvVerticalResolution / float2(video_sizeX, video_sizeY).y))) + sin((3.14159265358 * (tvVerticalResolution / float2(video_sizeX, video_sizeY).y) * min(abs((frac((tex.xy * float2(texture_sizeX, texture_sizeY)) - 0.5).y - (i))) + 0.5, 1.0 / (tvVerticalResolution / float2(video_sizeX, video_sizeY).y)))) - (3.14159265358 * (tvVerticalResolution / float2(video_sizeX, video_sizeY).y) * min(max(abs((frac((tex.xy * float2(texture_sizeX, texture_sizeY)) - 0.5).y - (i))) - 0.5, -1.0 / (tvVerticalResolution / float2(video_sizeX, video_sizeY).y)), 1.0 / (tvVerticalResolution / float2(video_sizeX, video_sizeY).y))) - sin((3.14159265358 * (tvVerticalResolution / float2(video_sizeX, video_sizeY).y) * min(max(abs((frac((tex.xy * float2(texture_sizeX, texture_sizeY)) - 0.5).y - (i))) - 0.5, -1.0 / (tvVerticalResolution / float2(video_sizeX, video_sizeY).y)), 1.0 / (tvVerticalResolution / float2(video_sizeX, video_sizeY).y))))) / (2.0 * 3.14159265358)));
}
}
else
{
for (i = -range; i < range + 2.0; i++)
{
tempColor += scanlines((offset.y - (i)), tex2Dlod(ReShade::BackBuffer, float4(float2(tex.x, tex.y - (offset.y - (i)) / float2(texture_sizeX, texture_sizeY).y), 0.0, 0.0)).xyz);
}
}
#line 217
tempColor -= float3(blackLevel, blackLevel, blackLevel);
tempColor *= (contrast / float3(1.0 - blackLevel, 1.0 - blackLevel, 1.0 - blackLevel));
#line 222
return float4(tempColor, 1.0);
#line 224
}
#line 226
technique GTUV50 {
pass GTU1
{
RenderTarget = target0_gtu;
#line 231
VertexShader = PostProcessVS;
PixelShader = PS_GTU1;
}
#line 235
pass p2
{
VertexShader = PostProcessVS;
PixelShader = PS_GTU2;
}
#line 241
pass p3
{
VertexShader = PostProcessVS;
PixelShader = PS_GTU3;
}
}

