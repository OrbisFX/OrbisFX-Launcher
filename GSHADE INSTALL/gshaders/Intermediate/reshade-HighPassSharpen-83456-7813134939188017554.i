#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\HighPassSharpen.fx"
#line 7
uniform int HighPassSharpRadius <
ui_type = "slider";
ui_min = 1; ui_max = 3;
ui_tooltip = "1 = 3x3 mask, 2 = 5x5 mask, 3 = 7x7 mask.";
> = 1;
#line 13
uniform float HighPassSharpOffset <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Additional adjustment for the blur radius. Values less than 1.00 will reduce the radius limiting the sharpening to finer details.";
> = 1.00;
#line 19
uniform int HighPassBlendMode <
ui_type = "combo";
ui_items = "Soft Light\0Overlay\0Mulitply\0Hard Light\0Vivid Light\0Screen\0Linear Light\0Addition";
ui_tooltip = "Blend modes determine how the sharp mask is applied to the original image";
> = 1;
#line 25
uniform int HighPassBlendIfDark <
ui_type = "slider";
ui_min = 0; ui_max = 255;
ui_tooltip = "Any pixels below this value will be excluded from the effect. Set to 50 to target mid-tones.";
> = 0;
#line 31
uniform int HighPassBlendIfLight <
ui_type = "slider";
ui_min = 0; ui_max = 255;
ui_tooltip = "Any pixels above this value will be excluded from the effect. Set to 205 to target mid-tones.";
> = 255;
#line 37
uniform bool HighPassViewBlendIfMask <
ui_tooltip = "Displays the BlendIfMask. The effect will not be applied to areas covered in black";
> = false;
#line 41
uniform float HighPassSharpStrength <
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Adjusts the strength of the effect";
> = 0.400;
#line 47
uniform float HighPassDarkIntensity <
ui_type = "slider";
ui_min = 0.00; ui_max = 5.00;
ui_tooltip = "Adjusts the strength of dark halos.";
> = 1.0;
#line 53
uniform float HighPassLightIntensity <
ui_type = "slider";
ui_min = 0.00; ui_max = 5.00;
ui_tooltip = "Adjusts the strength of light halos.";
> = 1.0;
#line 59
uniform bool HighPassViewSharpMask <
ui_tooltip = "Displays the SharpMask. Useful when adjusting settings";
> = false;
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
#line 64 "C:\Program Files\GShade\gshade-shaders\Shaders\HighPassSharpen.fx"
#line 65
float3 SharpBlurFinal(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 68
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
float3 orig = color;
float luma = dot(color.rgb,float3(0.32786885,0.655737705,0.0163934436));
float3 chroma = orig.rgb/luma;
#line 73
if (HighPassSharpRadius == 1)
{
const int sampleOffsetsX[25] = {  0.0, 	 1, 	  0, 	 1,     1,     2,     0,     2,     2,     1,      1,     2,     2,     3,     0,     3,     3,     1,    -1, 3, 3, 2, 2, 3, 3 };
const int sampleOffsetsY[25] = {  0.0,     0, 	  1, 	 1,    -1,     0,     2,     1,    -1,     2,     -2,     2,    -2,     0,     3,     1,    -1,     3,     3, 2, -2, 3, -3, 3, -3};
const float sampleWeights[5] = { 0.225806, 0.150538, 0.150538, 0.0430108, 0.0430108 };
#line 79
color *= sampleWeights[0];
#line 81
[loop]
for(int i = 1; i < 5; ++i) {
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(sampleOffsetsX[i] * (1.0 / 1920), sampleOffsetsY[i] * (1.0 / 1018)) * HighPassSharpOffset, 0.0, 0.0)).rgb * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(sampleOffsetsX[i] * (1.0 / 1920), sampleOffsetsY[i] * (1.0 / 1018)) * HighPassSharpOffset, 0.0, 0.0)).rgb * sampleWeights[i];
}
}
#line 88
if (HighPassSharpRadius == 2)
{
const int sampleOffsetsX[13] = {  0.0, 	   1, 	  0, 	 1,     1,     2,     0,     2,     2,     1,    1,     2,     2 };
const int sampleOffsetsY[13] = {  0.0,     0, 	  1, 	 1,    -1,     0,     2,     1,    -1,     2,     -2,     2,    -2};
float sampleWeights[13] = { 0.1509985387665926499, 0.1132489040749444874, 0.1132489040749444874, 0.0273989284225933369, 0.0273989284225933369, 0.0452995616018920668, 0.0452995616018920668, 0.0109595713409516066, 0.0109595713409516066, 0.0109595713409516066, 0.0109595713409516066, 0.0043838285270187332, 0.0043838285270187332 };
#line 94
color *= sampleWeights[0];
#line 96
[loop]
for(int i = 1; i < 13; ++i) {
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(sampleOffsetsX[i] * (1.0 / 1920), sampleOffsetsY[i] * (1.0 / 1018)) * HighPassSharpOffset, 0.0, 0.0)).rgb * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(sampleOffsetsX[i] * (1.0 / 1920), sampleOffsetsY[i] * (1.0 / 1018)) * HighPassSharpOffset, 0.0, 0.0)).rgb * sampleWeights[i];
}
}
#line 103
if (HighPassSharpRadius == 3)
{
static const float sampleOffsetsX[13] = { 				  0.0, 			    1.3846153846, 			 			  0, 	 		  1.3846153846,     	   	 1.3846153846,     		    3.2307692308,     		  			  0,     		 3.2307692308,     		   3.2307692308,     		 1.3846153846,    		   1.3846153846,     		  3.2307692308,     		  3.2307692308 };
static const float sampleOffsetsY[13] = {  				  0.0,   					   0, 	  		   1.3846153846, 	 		  1.3846153846,     		-1.3846153846,     					   0,     		   3.2307692308,     		 1.3846153846,    		  -1.3846153846,     		 3.2307692308,   		  -3.2307692308,     		  3.2307692308,    		     -3.2307692308 };
float sampleWeights[13] = { 0.0957733978977875942, 0.1333986613666725565, 0.1333986613666725565, 0.0421828199486419528, 0.0421828199486419528, 0.0296441469844336464, 0.0296441469844336464, 0.0093739599979617454, 0.0093739599979617454, 0.0093739599979617454, 0.0093739599979617454, 0.0020831022264565991,  0.0020831022264565991 };
#line 109
color *= sampleWeights[0];
#line 111
[loop]
for(int i = 1; i < 13; ++i) {
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(sampleOffsetsX[i] * (1.0 / 1920), sampleOffsetsY[i] * (1.0 / 1018)) * HighPassSharpOffset, 0.0, 0.0)).rgb * sampleWeights[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(sampleOffsetsX[i] * (1.0 / 1920), sampleOffsetsY[i] * (1.0 / 1018)) * HighPassSharpOffset, 0.0, 0.0)).rgb * sampleWeights[i];
}
}
#line 118
float sharp = dot(color.rgb,float3(0.32786885,0.655737705,0.0163934436));
sharp = 1.0 - sharp;
sharp = (luma+sharp)*0.5;
#line 122
float sharpMin = lerp(0,1,smoothstep(0,1,sharp));
float sharpMax = sharpMin;
sharpMin = lerp(sharp,sharpMin,HighPassDarkIntensity);
sharpMax = lerp(sharp,sharpMax,HighPassLightIntensity);
sharp = lerp(sharpMin,sharpMax,step(0.5,sharp));
#line 128
if(HighPassViewSharpMask)
{
#line 131
orig.rgb = sharp;
luma = sharp;
chroma = 1.0;
}
else
{
if(HighPassBlendMode == 0)
{
#line 140
sharp = lerp(2*luma*sharp + luma*luma*(1.0-2*sharp), 2*luma*(1.0-sharp)+pow(luma,0.5)*(2*sharp-1.0), step(0.49,sharp));
}
#line 143
if(HighPassBlendMode == 1)
{
#line 146
sharp = lerp(2*luma*sharp, 1.0 - 2*(1.0-luma)*(1.0-sharp), step(0.50,luma));
}
#line 149
if(HighPassBlendMode == 2)
{
#line 152
sharp = lerp(2*luma*sharp, 1.0 - 2*(1.0-luma)*(1.0-sharp), step(0.50,sharp));
}
#line 155
if(HighPassBlendMode == 3)
{
#line 158
sharp = saturate(2 * luma * sharp);
}
#line 161
if(HighPassBlendMode == 4)
{
#line 164
sharp = lerp(2*luma*sharp, luma/(2*(1-sharp)), step(0.5,sharp));
}
#line 167
if(HighPassBlendMode == 5)
{
#line 170
sharp = luma + 2.0*sharp-1.0;
}
#line 173
if(HighPassBlendMode == 6)
{
#line 176
sharp = 1.0 - (2*(1.0-luma)*(1.0-sharp));
}
#line 179
if(HighPassBlendMode == 7)
{
#line 182
sharp = saturate(luma + (sharp - 0.5));
}
}
#line 186
if( HighPassBlendIfDark > 0 || HighPassBlendIfLight < 255 || HighPassViewBlendIfMask)
{
float BlendIfD = (HighPassBlendIfDark/255.0)+0.0001;
float BlendIfL = (HighPassBlendIfLight/255.0)-0.0001;
float mix = dot(orig.rgb, 0.333333);
float mask = 1.0;
#line 193
if(HighPassBlendIfDark > 0)
{
mask = lerp(0.0,1.0,smoothstep(BlendIfD-(BlendIfD*0.2),BlendIfD+(BlendIfD*0.2),mix));
}
#line 198
if(HighPassBlendIfLight < 255)
{
mask = lerp(mask,0.0,smoothstep(BlendIfL-(BlendIfL*0.2),BlendIfL+(BlendIfL*0.2),mix));
}
#line 203
sharp = lerp(luma,sharp,mask);
if (HighPassViewBlendIfMask)
{
sharp = mask;
luma = mask;
chroma = 1.0;
}
}
#line 212
luma = lerp(luma, sharp, HighPassSharpStrength);
orig.rgb = luma*chroma;
#line 215
return saturate(orig);
}
#line 218
technique HighPassSharp
{
pass Sharp
{
VertexShader = PostProcessVS;
PixelShader = SharpBlurFinal;
}
}

