// UIMASK_TEXTURE="UIMask.png"
// UIMASK_MULTICHANNEL=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\UIMask.fx"
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
#line 104 "C:\Program Files\GShade\gshade-shaders\Shaders\UIMask.fx"
#line 121
namespace UIMask
{
#line 126
uniform int _Help
<
ui_label = " ";
ui_text =
"For more detailed instructions, see the text at the top of this "
"effect's shader file (UIMask.fx).\n"
"\n"
"Available preprocessor definitions:\n"
"  UIMASK_MULTICHANNEL:\n"
"    If set to 1, each of the RGB color channels in the texture is "
"treated as a separate mask.\n"
"\n"
"How to create a mask:\n"
"\n"
"1. Take a screenshot with the game's UI appearing.\n"
"2. Open the screenshot in an image editor, GIMP or Photoshop are "
"recommended.\n"
"3. Create a new layer over the screenshot layer, fill it with black.\n"
"4. Reduce the layer opacity so you can see the screenshot layer "
"below.\n"
"5. Cover the UI with white to mask it from effects. The stronger the "
"mask white color, the more opaque the mask will be.\n"
"6. Set the mask layer opacity back to 100%.\n"
"7. Save the image in one of your texture folders, making sure to "
"use a unique name such as: \"MyUIMask.png\"\n"
"8. Set the preprocessor definition UIMASK_TEXTURE to the name of "
"your image, with quotes: \"MyUIMask.png\"\n"
;
ui_category = "Help";
ui_category_closed = true;
ui_type = "radio";
>;
#line 159
uniform float fMask_Intensity
<
ui_type = "slider";
ui_label = "Mask Intensity";
ui_tooltip =
"How much to mask effects from affecting the original image.\n"
"\nDefault: 1.0";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 171
uniform bool bDisplayMask <
ui_label = "Display Mask";
ui_tooltip =
"Display the mask texture.\n"
"Useful for testing multiple channels or simply the mask itself.\n"
"\nDefault: Off";
> = false;
#line 208
texture BackupTex
{
Width = 1280;
Height = 720;
};
sampler Backup
{
Texture = BackupTex;
};
#line 218
texture MaskTex <source="UIMask.png";>
{
Width = 1280;
Height = 720;
Format = R8;
};
sampler Mask
{
Texture = MaskTex;
};
#line 233
float4 BackupPS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target {
return tex2D(ReShade::BackBuffer, uv);
}
#line 237
float4 MainPS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target {
float4 color = tex2D(ReShade::BackBuffer, uv);
const float4 backup = tex2D(Backup, uv);
#line 242
const float mask = tex2D(Mask, uv).r;
#line 253
color = lerp(color, backup, mask * fMask_Intensity);
color = bDisplayMask ? mask : color;
#line 256
return color;
}
#line 263
technique UIMask_Top
<
ui_tooltip = "Place this *above* the effects to be masked.";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = BackupPS;
RenderTarget = BackupTex;
}
}
#line 276
technique UIMask_Bottom
<
ui_tooltip =
"Place this *below* the effects to be masked.\n"
"If you want to add a toggle key for the effect, set it to this one.";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = MainPS;
}
}
#line 292
} 

