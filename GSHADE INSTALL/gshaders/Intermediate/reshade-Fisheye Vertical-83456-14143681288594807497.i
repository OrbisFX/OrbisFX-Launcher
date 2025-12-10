#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Fisheye Vertical.fx"
#line 9
uniform float fFisheyeZoom <
ui_type = "slider";
ui_min = 0.5; ui_max = 1.0;
ui_label = "Fish Eye Zoom";
ui_tooltip = "Lens zoom to hide bugged edges due to texcoord modification";
> = 0.55;
uniform float fFisheyeDistortion <
ui_type = "slider";
ui_min = -0.300; ui_max = 0.300;
ui_label = "Fisheye Distortion";
ui_tooltip = "Distortion of image";
> = 0.01;
uniform float fFisheyeDistortionCubic <
ui_type = "slider";
ui_min = -0.300; ui_max = 0.300;
ui_label = "Fisheye Distortion Cubic";
ui_tooltip = "Distortion of image, cube based";
> = 0.7;
uniform float fFisheyeColorshift <
ui_type = "slider";
ui_min = -0.10; ui_max = 0.10;
ui_label = "Colorshift";
ui_tooltip = "Amount of color shifting";
> = 0.002;
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
#line 35 "C:\Program Files\GShade\gshade-shaders\Shaders\Fisheye Vertical.fx"
#line 40
float3 FISHEYE_CAPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 44
float4 coord=0.0;
coord.xy=texcoord.xy;
coord.w=0.0;
#line 48
color.rgb = 0.0;
#line 50
float3 eta = float3(1.0+fFisheyeColorshift*0.9,1.0+fFisheyeColorshift*0.6,1.0+fFisheyeColorshift*0.3);
float2 center;
center.x = coord.x-0.5;
center.y = coord.y-0.5;
float LensZoom = 1.0/fFisheyeZoom;
#line 56
float r2 = (texcoord.x-0.5) * (texcoord.x-0.5);
float f = 0;
#line 59
if( fFisheyeDistortionCubic == 0.0){
f = 1 + r2 * fFisheyeDistortion;
}else{
f = 1 + r2 * (fFisheyeDistortion + fFisheyeDistortionCubic * sqrt(r2));
};
#line 65
float x = f*LensZoom*(coord.x-0.5)+0.5;
float y = f*LensZoom*(coord.y-0.5)+0.5;
float2 rCoords = (f*eta.r)*LensZoom*(center.xy*0.5)+0.5;
float2 gCoords = (f*eta.g)*LensZoom*(center.xy*0.5)+0.5;
float2 bCoords = (f*eta.b)*LensZoom*(center.xy*0.5)+0.5;
#line 71
color.x = tex2D(ReShade::BackBuffer,rCoords).r;
color.y = tex2D(ReShade::BackBuffer,gCoords).g;
color.z = tex2D(ReShade::BackBuffer,bCoords).b;
#line 78
return color;
#line 80
}
#line 83
technique FISHEYE_CA_VERTICAL
{
pass
{
VertexShader = PostProcessVS;
PixelShader = FISHEYE_CAPass;
}
}

