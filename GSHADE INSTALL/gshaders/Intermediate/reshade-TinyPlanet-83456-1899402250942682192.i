#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\TinyPlanet.fx"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\TinyPlanet.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\RadegastShaders.Transforms.fxh"
float2x2 swirlTransform(float theta) {
const float c = cos(theta);
const float s = sin(theta);
#line 5
const float m1 = c;
const float m2 = -s;
const float m3 = s;
const float m4 = c;
#line 10
return float2x2(
m1, m2,
m3, m4
);
};
#line 16
float2x2 zigzagTransform(float theta) {
const float c = cos(theta);
return float2x2(
c, 0,
0, c
);
}
#line 24
float3x3 getrot(float3 r)
{
const float cx = cos(radians(r.x));
const float sx = sin(radians(r.x));
const float cy = cos(radians(r.y));
const float sy = sin(radians(r.y));
const float cz = cos(radians(r.z));
const float sz = sin(radians(r.z));
#line 33
const float m1 = cy * cz;
const float m2= cx * sz + sx * sy * cz;
const float m3= sx * sz - cx * sy * cz;
const float m4= -cy * sz;
const float m5= cx * cz - sx * sy * sz;
const float m6= sx * cz + cx * sy * sz;
const float m7= sy;
const float m8= -sx * cy;
const float m9= cx * cy;
#line 43
return float3x3
(
m1,m2,m3,
m4,m5,m6,
m7,m8,m9
);
};
#line 29 "C:\Program Files\GShade\gshade-shaders\Shaders\TinyPlanet.fxh"
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\RadegastShaders.Positional.fxh"
uniform bool use_mouse_point <
ui_label="Use Mouse Coordinates";
ui_category="Coordinates";
> = false;
#line 6
uniform float x_coord <
ui_type = "slider";
ui_label="X";
ui_category="Coordinates";
ui_tooltip="The X position of the center of the effect.";
ui_min = 0.0;
ui_max = 1.0;
> = 0.5;
#line 15
uniform float y_coord <
ui_type = "slider";
ui_label="Y";
ui_category="Coordinates";
ui_tooltip="The Y position of the center of the effect.";
ui_min = 0.0;
ui_max = 1.0;
> = 0.5;
#line 24
uniform float2 mouse_coordinates <
source= "mousepoint";
>;
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\TinyPlanet.fxh"
#line 33
uniform float2 offset <
ui_type = "slider";
ui_label = "Offset";
ui_tooltip = "Horizontally/Vertically offsets the center of the display by a certain amount.";
ui_category = "Properties";
ui_min = -.5;
ui_max = .5;
> = 0;
#line 42
uniform float scale <
ui_type = "slider";
ui_label = "Scale";
ui_tooltip = "Determine's the display's Z-position on the projected sphere. Use this to zoom into or zoom out of the planet if it's too small or big respectively.";
ui_category = "Properties";
ui_min = 0.0;
ui_max = 10.0;
> = 10.0;
#line 51
uniform float z_rotation <
ui_type = "slider";
ui_label = "Z-Rotation";
ui_tooltip = "Rotates the display along the z-axis. This can help you orient characters or features on your display the way you want.";
ui_category = "Properties";
ui_min = 0.0;
ui_max = 360.0;
> = 0.5;
#line 60
uniform float seam_scale <
ui_type = "slider";
ui_min = 0.5;
ui_max = 1.0;
ui_label = "Seam Blending";
ui_tooltip = "Blends the ends of the screen so that the seam is somewhat reasonably hidden.";
ui_category = "Properties";
> = 0.5;
#line 30 "C:\Program Files\GShade\gshade-shaders\Shaders\TinyPlanet.fx"
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
#line 31 "C:\Program Files\GShade\gshade-shaders\Shaders\TinyPlanet.fx"
#line 32
texture texColorBuffer : COLOR;
texture texDepthBuffer : DEPTH;
#line 36
texture TinyPlanetTarget
{
Width = 1920;
Height = 1018;
MipLevels = LINEAR;
Format = RGBA8;
};
#line 45
sampler samplerColor
{
Texture = texColorBuffer;
#line 49
AddressU = WRAP;
AddressV = WRAP;
AddressW = WRAP;
#line 53
MagFilter = LINEAR;
MinFilter = LINEAR;
MipFilter = LINEAR;
#line 57
MinLOD = 0.0f;
MaxLOD = 1000.0f;
#line 60
MipLODBias = 0.0f;
#line 62
SRGBTexture = false;
};
#line 66
float4 PreTP(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_TARGET
{
const float inv_seam = 1 - seam_scale;
float4 tc1 =  tex2D(samplerColor, texcoord + float2(inv_seam, 0.0));
float4 tc = tex2D(samplerColor, texcoord * float2(seam_scale, 1.0));
#line 72
if(texcoord.x < inv_seam){
tc.rgb = lerp(tc1.rgb, tc.rgb, 1- clamp((inv_seam-texcoord.x) * 10., 0, 1));
}
if(texcoord.x > seam_scale) tc.rgb = lerp(tc.rgb, tc1.rgb, clamp((texcoord.x-seam_scale) * 10., 0, 1));
return tc;
}
#line 79
float4 TinyPlanet(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_TARGET
{
const float ar = 1.0 * (float)1018 / (float)1920;
#line 83
const float3x3 rot = getrot(float3(lerp(0,360,x_coord),lerp(0, 360,y_coord), z_rotation));
#line 85
const float2 rads = float2(3.141592358 * 2.0 , 3.141592358);
const float2 pnt = (texcoord - 0.5 - offset).xy * float2(scale, scale*ar);
#line 89
const float x2y2 = pnt.x * pnt.x + pnt.y * pnt.y;
float3 sphere_pnt = float3(2.0 * pnt, x2y2 - 1.0) / (x2y2 + 1.0);
#line 92
sphere_pnt = mul(sphere_pnt, rot);
#line 95
const float r = length(sphere_pnt);
const float lon = atan2(sphere_pnt.y, sphere_pnt.x);
const float lat = acos(sphere_pnt.z / r);
#line 99
return tex2D(samplerColor, float2(lon, lat) / rads);
}
#line 103
technique TinyPlanet <ui_label="Tiny Planet";>
{
pass p0
{
VertexShader = PostProcessVS;
PixelShader = PreTP;
}
pass p1
{
VertexShader = PostProcessVS;
PixelShader = TinyPlanet;
}
};

