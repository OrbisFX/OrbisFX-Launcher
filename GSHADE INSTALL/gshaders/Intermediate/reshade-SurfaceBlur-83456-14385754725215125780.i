#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\SurfaceBlur.fx"
#line 12
uniform int BlurRadius
<
ui_type = "slider";
ui_min = 1; ui_max = 4;
ui_tooltip = "1 = 3x3 mask, 2 = 5x5 mask, 3 = 7x7 mask, 4 = 9x9 mask. For more blurring add SurfaceBlurIterations=2 or SurfaceBlurIterations=3 to Preprocessor Definitions";
> = 1;
#line 19
uniform float BlurOffset
<
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Additional adjustment for the blur radius. Values less than 1.00 will reduce the blur radius.";
> = 1.000;
#line 26
uniform float BlurEdge
<
ui_type = "slider";
ui_min = 0.000; ui_max = 10.000;
ui_tooltip = "Adjusts the strength of edge detection. Lower values will exclude finer edges from blurring";
> = 0.500;
#line 33
uniform float BlurStrength
<
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Adjusts the strength of the effect";
> = 1.00;
#line 40
uniform int DebugMode
<
ui_type = "combo";
ui_items = "\None\0EdgeChannel\0BlurChannel\0";
ui_tooltip = "Helpful for adjusting settings";
> = 0;
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
#line 48 "C:\Program Files\GShade\gshade-shaders\Shaders\SurfaceBlur.fx"
#line 77
float4 SurfaceBlurFinal(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 92
const float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
const float3 orig = color;
#line 96
float Z;
float3 final_color;
#line 99
if (BlurRadius == 1)
{
static const float sampleOffsetsX[5] = {  0.0, float2((1.0 / 1920), (1.0 / 1018)).x, 		   0, 	 float2((1.0 / 1920), (1.0 / 1018)).x,     float2((1.0 / 1920), (1.0 / 1018)).x};
static const float sampleOffsetsY[5] = {  0.0,      	0, float2((1.0 / 1920), (1.0 / 1018)).y, 	 float2((1.0 / 1920), (1.0 / 1018)).y,    -float2((1.0 / 1920), (1.0 / 1018)).y};
static const float sampleWeights[5] = { 0.225806, 0.150538, 0.150538, 0.0430108, 0.0430108 };
#line 105
final_color = color * 0.225806;
Z = 0.225806;
#line 108
[unroll]
for(int i = 1; i < 5; ++i) {
#line 111
const float2 coord = float2(sampleOffsetsX[i], sampleOffsetsY[i]) * BlurOffset;
#line 113
const float3 colorA = tex2Dlod(ReShade::BackBuffer, float4(texcoord + coord, 0.0, 0.0)).rgb;
const float3 diffA = (orig-colorA);
float factorA = (dot(diffA,diffA));
factorA = 1+(factorA/((BlurEdge)));
factorA = sampleWeights[i]*rcp(factorA*factorA*factorA*factorA*factorA);
#line 119
const float3 colorB = tex2Dlod(ReShade::BackBuffer, float4(texcoord - coord, 0.0, 0.0)).rgb;
const float3 diffB = (orig-colorB);
float factorB = (dot(diffB,diffB));
factorB = 1+(factorB/((BlurEdge)));
factorB = sampleWeights[i]*rcp(factorB*factorB*factorB*factorB*factorB);
#line 125
Z += factorA;
final_color += factorA*colorA;
Z += factorB;
final_color += factorB*colorB;
}
}
else
{
if (BlurRadius == 2)
{
static const float sampleOffsetsX[13] = {  0.0, 	   float2((1.0 / 1920), (1.0 / 1018)).x, 	  0, 	 float2((1.0 / 1920), (1.0 / 1018)).x,     float2((1.0 / 1920), (1.0 / 1018)).x,     2.0*float2((1.0 / 1920), (1.0 / 1018)).x,     0,     2.0*float2((1.0 / 1920), (1.0 / 1018)).x,     2.0*float2((1.0 / 1920), (1.0 / 1018)).x,     float2((1.0 / 1920), (1.0 / 1018)).x,    float2((1.0 / 1920), (1.0 / 1018)).x,     2.0*float2((1.0 / 1920), (1.0 / 1018)).x,     2.0*float2((1.0 / 1920), (1.0 / 1018)).x };
static const float sampleOffsetsY[13] = {  0.0,     0, 	  float2((1.0 / 1920), (1.0 / 1018)).y, 	 float2((1.0 / 1920), (1.0 / 1018)).y,    -float2((1.0 / 1920), (1.0 / 1018)).y,     0,     2.0*float2((1.0 / 1920), (1.0 / 1018)).y,     float2((1.0 / 1920), (1.0 / 1018)).y,    -float2((1.0 / 1920), (1.0 / 1018)).y,     2.0*float2((1.0 / 1920), (1.0 / 1018)).y,     -2.0*float2((1.0 / 1920), (1.0 / 1018)).y,     2.0*float2((1.0 / 1920), (1.0 / 1018)).y,    -2.0*float2((1.0 / 1920), (1.0 / 1018)).y};
static const float sampleWeights[13] = { 0.1509985387665926499, 0.1132489040749444874, 0.1132489040749444874, 0.0273989284225933369, 0.0273989284225933369, 0.0452995616018920668, 0.0452995616018920668, 0.0109595713409516066, 0.0109595713409516066, 0.0109595713409516066, 0.0109595713409516066, 0.0043838285270187332, 0.0043838285270187332 };
#line 139
final_color = color * 0.1509985387665926499;
Z = 0.1509985387665926499;
#line 142
[loop]
for(int i = 1; i < 13; ++i) {
#line 145
const float2 coord = float2(sampleOffsetsX[i], sampleOffsetsY[i]) * BlurOffset;
#line 147
const float3 colorA = tex2Dlod(ReShade::BackBuffer, float4(texcoord + coord, 0.0, 0.0)).rgb;
const float3 diffA = (orig-colorA);
float factorA = dot(diffA,diffA);
factorA = 1+(factorA/((BlurEdge)));
factorA = (sampleWeights[i]/(factorA*factorA*factorA*factorA*factorA));
#line 153
const float3 colorB = tex2Dlod(ReShade::BackBuffer, float4(texcoord - coord, 0.0, 0.0)).rgb;
const float3 diffB = (orig-colorB);
float factorB = dot(diffB,diffB);
factorB = 1+(factorB/((BlurEdge)));
factorB = (sampleWeights[i]/(factorB*factorB*factorB*factorB*factorB));
#line 159
Z += factorA;
final_color += factorA*colorA;
Z += factorB;
final_color += factorB*colorB;
}
}
else
{
if (BlurRadius == 3)
{
static const float sampleOffsetsX[13] = { 				  0.0, 			    1.3846153846*float2((1.0 / 1920), (1.0 / 1018)).x, 			 			  0, 	 		  1.3846153846*float2((1.0 / 1920), (1.0 / 1018)).x,     	   	 1.3846153846*float2((1.0 / 1920), (1.0 / 1018)).x,     		    3.2307692308*float2((1.0 / 1920), (1.0 / 1018)).x,     		  			  0,     		 3.2307692308*float2((1.0 / 1920), (1.0 / 1018)).x,     		   3.2307692308*float2((1.0 / 1920), (1.0 / 1018)).x,     		 1.3846153846*float2((1.0 / 1920), (1.0 / 1018)).x,    		   1.3846153846*float2((1.0 / 1920), (1.0 / 1018)).x,     		  3.2307692308*float2((1.0 / 1920), (1.0 / 1018)).x,     		  3.2307692308*float2((1.0 / 1920), (1.0 / 1018)).x };
static const float sampleOffsetsY[13] = {  				  0.0,   					   0, 	  		   1.3846153846*float2((1.0 / 1920), (1.0 / 1018)).y, 	 		  1.3846153846*float2((1.0 / 1920), (1.0 / 1018)).y,     		-1.3846153846*float2((1.0 / 1920), (1.0 / 1018)).y,     					   0,     		   3.2307692308*float2((1.0 / 1920), (1.0 / 1018)).y,     		 1.3846153846*float2((1.0 / 1920), (1.0 / 1018)).y,    		  -1.3846153846*float2((1.0 / 1920), (1.0 / 1018)).y,     		 3.2307692308*float2((1.0 / 1920), (1.0 / 1018)).y,   		  -3.2307692308*float2((1.0 / 1920), (1.0 / 1018)).y,     		  3.2307692308*float2((1.0 / 1920), (1.0 / 1018)).y,    		     -3.2307692308*float2((1.0 / 1920), (1.0 / 1018)).y };
static const float sampleWeights[13] = { 0.0957733978977875942, 0.1333986613666725565, 0.1333986613666725565, 0.0421828199486419528, 0.0421828199486419528, 0.0296441469844336464, 0.0296441469844336464, 0.0093739599979617454, 0.0093739599979617454, 0.0093739599979617454, 0.0093739599979617454, 0.0020831022264565991,  0.0020831022264565991 };
#line 173
final_color = color * 0.0957733978977875942;
Z = 0.0957733978977875942;
#line 176
[loop]
for(int i = 1; i < 13; ++i) {
const float2 coord = float2(sampleOffsetsX[i], sampleOffsetsY[i]) * BlurOffset;
#line 180
const float3 colorA = tex2Dlod(ReShade::BackBuffer, float4(texcoord + coord, 0.0, 0.0)).rgb;
const float3 diffA = (orig-colorA);
float factorA = dot(diffA,diffA);
factorA = 1+(factorA/((BlurEdge)));
factorA = (sampleWeights[i]/(factorA*factorA*factorA*factorA*factorA));
#line 186
const float3 colorB = tex2Dlod(ReShade::BackBuffer, float4(texcoord - coord, 0.0, 0.0)).rgb;
const float3 diffB = (orig-colorB);
float factorB = dot(diffB,diffB);
factorB = 1+(factorB/((BlurEdge)));
factorB = (sampleWeights[i]/(factorB*factorB*factorB*factorB*factorB));
#line 192
Z += factorA;
final_color += factorA*colorA;
Z += factorB;
final_color += factorB*colorB;
}
}
else
{
if (BlurRadius >= 4)
{
static const float sampleOffsetsX[25] = {0.0, 1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).x, 0, 1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).x, 1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).x, 3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).x, 0, 3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).x, 3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).x, 1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).x, 1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).x, 3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).x, 3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).x, 5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).x, 0.0, 5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).x, 5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).x, 5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).x, 5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).x, 1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).x, 1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).x, 3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).x, 3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).x, 5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).x, 5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).x};
static const float sampleOffsetsY[25] = {0.0, 0, 1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).y, 1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).y, -1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).y, 0, 3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).y, 1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).y, -1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).y, 3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).y, -3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).y, 3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).y, -3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).y, 0.0, 5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).y, 1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).y, -1.4584295168*float2((1.0 / 1920), (1.0 / 1018)).y, 3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).y, -3.4039848067*float2((1.0 / 1920), (1.0 / 1018)).y, 5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).y, -5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).y, 5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).y, -5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).y, 5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).y, -5.3518057801*float2((1.0 / 1920), (1.0 / 1018)).y};
static const float sampleWeights[25] = {0.05299184990795840687999609498603, 0.09256069846035847440860469965371, 0.09256069846035847440860469965371, 0.02149960564023589832299078385165, 0.02149960564023589832299078385165, 0.05392678246987847562647201766774, 0.05392678246987847562647201766774, 0.01252588384627371007425549277902, 0.01252588384627371007425549277902, 0.01252588384627371007425549277902, 0.01252588384627371007425549277902, 0.00729770438775005041467389567467, 0.00729770438775005041467389567467, 0.02038530184304811960185734706054,	0.02038530184304811960185734706054,	0.00473501127359426108157733854484,	0.00473501127359426108157733854484,	0.00275866461027743062478492361799,	0.00275866461027743062478492361799,	0.00473501127359426108157733854484, 0.00473501127359426108157733854484,	0.00275866461027743062478492361799,	0.00275866461027743062478492361799, 0.00104282525148620420024312363461, 0.00104282525148620420024312363461};
#line 206
final_color = color * 0.05299184990795840687999609498603;
Z = 0.05299184990795840687999609498603;
#line 209
[loop]
for(int i = 1; i < 25; ++i) {
const float2 coord = float2(sampleOffsetsX[i], sampleOffsetsY[i]) * BlurOffset;
#line 213
const float3 colorA = tex2Dlod(ReShade::BackBuffer, float4(texcoord + coord, 0.0, 0.0)).rgb;
const float3 diffA = (orig-colorA);
float factorA = dot(diffA,diffA);
factorA = 1+(factorA/((BlurEdge)));
factorA = (sampleWeights[i]/(factorA*factorA*factorA*factorA*factorA));
#line 219
const float3 colorB = tex2Dlod(ReShade::BackBuffer, float4(texcoord - coord, 0.0, 0.0)).rgb;
const float3 diffB = (orig-colorB);
float factorB = dot(diffB,diffB);
factorB = 1+(factorB/((BlurEdge)));
factorB = (sampleWeights[i]/(factorB*factorB*factorB*factorB*factorB));
#line 225
Z += factorA;
final_color += factorA*colorA;
Z += factorB;
final_color += factorB*colorB;
}
}
}
}
}
#line 235
if(DebugMode == 1)
{
return float4(Z,Z,Z,0);
}
#line 240
if(DebugMode == 2)
{
return float4(final_color/Z,0);
}
#line 245
return float4(saturate(lerp(orig.rgb, final_color/Z, BlurStrength)),0.0);
}
#line 546
technique SurfaceBlur
{
#line 566
pass BlurFinal
{
VertexShader = PostProcessVS;
PixelShader = SurfaceBlurFinal;
}
#line 572
}

