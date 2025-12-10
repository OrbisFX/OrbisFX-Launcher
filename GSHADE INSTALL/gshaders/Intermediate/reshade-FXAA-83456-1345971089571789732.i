// FXAA_CONSOLE__PS3_EDGE_THRESHOLD=0.125
// FXAA_CONSOLE__PS3_EDGE_SHARPNESS=8.0
// FXAA_GATHER4_ALPHA=0
// FXAA_FAST_PIXEL_OFFSET=0
// FXAA_EARLY_EXIT=1
// FXAA_HLSL_4=0
// FXAA_GLSL_130=0
// FXAA_HLSL_5=0
// FXAA_PC_CONSOLE=0
// FXAA_360_OPT=0
// FXAA_360=0
// FXAA_PS3=0
// FXAA_DISCARD=0
// FXAA_GLSL_120=0
// FXAA_LINEAR_LIGHT=1
// FXAA_QUALITY__PRESET=15
// FXAA_GREEN_AS_LUMA=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXAA.fx"
#line 7
uniform float Subpix <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_tooltip = "Amount of sub-pixel aliasing removal. Higher values makes the image softer/blurrier.";
> = 0.25;
#line 13
uniform float EdgeThreshold <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Edge Detection Threshold";
ui_tooltip = "The minimum amount of local contrast required to apply algorithm.";
> = 0.125;
uniform float EdgeThresholdMin <
ui_type = "slider";
ui_min = 0.0; ui_max = 1.0;
ui_label = "Darkness Threshold";
ui_tooltip = "Pixels darker than this are not processed in order to increase performance.";
> = 0.0;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FXAA.fxh"
#line 706
float FxaaLuma(float4 rgba) { return rgba.w; }
#line 721
float4 FxaaPixelShader(
#line 725
float2 pos,
#line 731
float4 fxaaConsolePosPos,
#line 737
sampler2D tex,
#line 743
sampler2D fxaaConsole360TexExpBiasNegOne,
#line 749
sampler2D fxaaConsole360TexExpBiasNegTwo,
#line 755
float2 fxaaQualityRcpFrame,
#line 767
float4 fxaaConsoleRcpFrameOpt,
#line 776
float4 fxaaConsoleRcpFrameOpt2,
#line 785
float4 fxaaConsole360RcpFrameOpt2,
#line 797
float fxaaQualitySubpix,
#line 808
float fxaaQualityEdgeThreshold,
#line 823
float fxaaQualityEdgeThresholdMin,
#line 837
float fxaaConsoleEdgeSharpness,
#line 851
float fxaaConsoleEdgeThreshold,
#line 870
float fxaaConsoleEdgeThresholdMin,
#line 877
float4 fxaaConsole360ConstDir
) {
#line 880
float2 posM;
posM.x = pos.x;
posM.y = pos.y;
#line 909
float4 rgbyM = tex2Dlod(tex, float4(posM, 0.0, 0.0));
#line 915
float lumaS = FxaaLuma(tex2Dlod(tex, float4(posM + (float2( 0, 1) * fxaaQualityRcpFrame.xy), 0, 0)));
float lumaE = FxaaLuma(tex2Dlod(tex, float4(posM + (float2( 1, 0) * fxaaQualityRcpFrame.xy), 0, 0)));
float lumaN = FxaaLuma(tex2Dlod(tex, float4(posM + (float2( 0,-1) * fxaaQualityRcpFrame.xy), 0, 0)));
float lumaW = FxaaLuma(tex2Dlod(tex, float4(posM + (float2(-1, 0) * fxaaQualityRcpFrame.xy), 0, 0)));
#line 921
float maxSM = max(lumaS, rgbyM.w);
float minSM = min(lumaS, rgbyM.w);
float maxESM = max(lumaE, maxSM);
float minESM = min(lumaE, minSM);
float maxWN = max(lumaN, lumaW);
float minWN = min(lumaN, lumaW);
float rangeMax = max(maxWN, maxESM);
float rangeMin = min(minWN, minESM);
float rangeMaxScaled = rangeMax * fxaaQualityEdgeThreshold;
float range = rangeMax - rangeMin;
float rangeMaxClamped = max(fxaaQualityEdgeThresholdMin, rangeMaxScaled);
bool earlyExit = range < rangeMaxClamped;
#line 934
if(earlyExit)
#line 938
return rgbyM;
#line 942
float lumaNW = FxaaLuma(tex2Dlod(tex, float4(posM + (float2(-1,-1) * fxaaQualityRcpFrame.xy), 0, 0)));
float lumaSE = FxaaLuma(tex2Dlod(tex, float4(posM + (float2( 1, 1) * fxaaQualityRcpFrame.xy), 0, 0)));
float lumaNE = FxaaLuma(tex2Dlod(tex, float4(posM + (float2( 1,-1) * fxaaQualityRcpFrame.xy), 0, 0)));
float lumaSW = FxaaLuma(tex2Dlod(tex, float4(posM + (float2(-1, 1) * fxaaQualityRcpFrame.xy), 0, 0)));
#line 951
float lumaNS = lumaN + lumaS;
float lumaWE = lumaW + lumaE;
float subpixRcpRange = 1.0/range;
float subpixNSWE = lumaNS + lumaWE;
float edgeHorz1 = (-2.0 * rgbyM.w) + lumaNS;
float edgeVert1 = (-2.0 * rgbyM.w) + lumaWE;
#line 958
float lumaNESE = lumaNE + lumaSE;
float lumaNWNE = lumaNW + lumaNE;
float edgeHorz2 = (-2.0 * lumaE) + lumaNESE;
float edgeVert2 = (-2.0 * lumaN) + lumaNWNE;
#line 963
float lumaNWSW = lumaNW + lumaSW;
float lumaSWSE = lumaSW + lumaSE;
float edgeHorz4 = (abs(edgeHorz1) * 2.0) + abs(edgeHorz2);
float edgeVert4 = (abs(edgeVert1) * 2.0) + abs(edgeVert2);
float edgeHorz3 = (-2.0 * lumaW) + lumaNWSW;
float edgeVert3 = (-2.0 * lumaS) + lumaSWSE;
float edgeHorz = abs(edgeHorz3) + edgeHorz4;
float edgeVert = abs(edgeVert3) + edgeVert4;
#line 972
float subpixNWSWNESE = lumaNWSW + lumaNESE;
float lengthSign = fxaaQualityRcpFrame.x;
bool horzSpan = edgeHorz >= edgeVert;
float subpixA = subpixNSWE * 2.0 + subpixNWSWNESE;
#line 977
if(!horzSpan) lumaN = lumaW;
if(!horzSpan) lumaS = lumaE;
if(horzSpan) lengthSign = fxaaQualityRcpFrame.y;
float subpixB = (subpixA * (1.0/12.0)) - rgbyM.w;
#line 982
float gradientN = lumaN - rgbyM.w;
float gradientS = lumaS - rgbyM.w;
float lumaNN = lumaN + rgbyM.w;
float lumaSS = lumaS + rgbyM.w;
bool pairN = abs(gradientN) >= abs(gradientS);
float gradient = max(abs(gradientN), abs(gradientS));
if(pairN) lengthSign = -lengthSign;
float subpixC = saturate(abs(subpixB) * subpixRcpRange);
#line 991
float2 posB;
posB.x = posM.x;
posB.y = posM.y;
float2 offNP;
if (!horzSpan)
offNP.x = 0.0;
else
offNP.x = fxaaQualityRcpFrame.x;
if ( horzSpan)
offNP.y = 0.0;
else
offNP.y = fxaaQualityRcpFrame.y;
if(!horzSpan) posB.x += lengthSign * 0.5;
if( horzSpan) posB.y += lengthSign * 0.5;
#line 1006
float2 posN;
posN.x = posB.x - offNP.x * 1.0;
posN.y = posB.y - offNP.y * 1.0;
float2 posP;
posP.x = posB.x + offNP.x * 1.0;
posP.y = posB.y + offNP.y * 1.0;
float subpixD = ((-2.0)*subpixC) + 3.0;
float lumaEndN = FxaaLuma(tex2Dlod(tex, float4(posN, 0.0, 0.0)));
float subpixE = subpixC * subpixC;
float lumaEndP = FxaaLuma(tex2Dlod(tex, float4(posP, 0.0, 0.0)));
#line 1017
if(!pairN) lumaNN = lumaSS;
float gradientScaled = gradient * 1.0/4.0;
float lumaMM = rgbyM.w - lumaNN * 0.5;
float subpixF = subpixD * subpixE;
bool lumaMLTZero = lumaMM < 0.0;
#line 1023
lumaEndN -= lumaNN * 0.5;
lumaEndP -= lumaNN * 0.5;
bool doneN = abs(lumaEndN) >= gradientScaled;
bool doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 1.5;
if(!doneN) posN.y -= offNP.y * 1.5;
bool doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 1.5;
if(!doneP) posP.y += offNP.y * 1.5;
#line 1033
if(doneNP) {
if(!doneN) lumaEndN = FxaaLuma(tex2Dlod(tex, float4(posN.xy, 0.0, 0.0)));
if(!doneP) lumaEndP = FxaaLuma(tex2Dlod(tex, float4(posP.xy, 0.0, 0.0)));
if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
doneN = abs(lumaEndN) >= gradientScaled;
doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 2.0;
if(!doneN) posN.y -= offNP.y * 2.0;
doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 2.0;
if(!doneP) posP.y += offNP.y * 2.0;
#line 1047
if(doneNP) {
if(!doneN) lumaEndN = FxaaLuma(tex2Dlod(tex, float4(posN.xy, 0.0, 0.0)));
if(!doneP) lumaEndP = FxaaLuma(tex2Dlod(tex, float4(posP.xy, 0.0, 0.0)));
if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
doneN = abs(lumaEndN) >= gradientScaled;
doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 2.0;
if(!doneN) posN.y -= offNP.y * 2.0;
doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 2.0;
if(!doneP) posP.y += offNP.y * 2.0;
#line 1061
if(doneNP) {
if(!doneN) lumaEndN = FxaaLuma(tex2Dlod(tex, float4(posN.xy, 0.0, 0.0)));
if(!doneP) lumaEndP = FxaaLuma(tex2Dlod(tex, float4(posP.xy, 0.0, 0.0)));
if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
doneN = abs(lumaEndN) >= gradientScaled;
doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 2.0;
if(!doneN) posN.y -= offNP.y * 2.0;
doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 2.0;
if(!doneP) posP.y += offNP.y * 2.0;
#line 1075
if(doneNP) {
if(!doneN) lumaEndN = FxaaLuma(tex2Dlod(tex, float4(posN.xy, 0.0, 0.0)));
if(!doneP) lumaEndP = FxaaLuma(tex2Dlod(tex, float4(posP.xy, 0.0, 0.0)));
if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
doneN = abs(lumaEndN) >= gradientScaled;
doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 2.0;
if(!doneN) posN.y -= offNP.y * 2.0;
doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 2.0;
if(!doneP) posP.y += offNP.y * 2.0;
#line 1089
if(doneNP) {
if(!doneN) lumaEndN = FxaaLuma(tex2Dlod(tex, float4(posN.xy, 0.0, 0.0)));
if(!doneP) lumaEndP = FxaaLuma(tex2Dlod(tex, float4(posP.xy, 0.0, 0.0)));
if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
doneN = abs(lumaEndN) >= gradientScaled;
doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 4.0;
if(!doneN) posN.y -= offNP.y * 4.0;
doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 4.0;
if(!doneP) posP.y += offNP.y * 4.0;
#line 1103
if(doneNP) {
if(!doneN) lumaEndN = FxaaLuma(tex2Dlod(tex, float4(posN.xy, 0.0, 0.0)));
if(!doneP) lumaEndP = FxaaLuma(tex2Dlod(tex, float4(posP.xy, 0.0, 0.0)));
if(!doneN) lumaEndN = lumaEndN - lumaNN * 0.5;
if(!doneP) lumaEndP = lumaEndP - lumaNN * 0.5;
doneN = abs(lumaEndN) >= gradientScaled;
doneP = abs(lumaEndP) >= gradientScaled;
if(!doneN) posN.x -= offNP.x * 12.0;
if(!doneN) posN.y -= offNP.y * 12.0;
doneNP = (!doneN) || (!doneP);
if(!doneP) posP.x += offNP.x * 12.0;
if(!doneP) posP.y += offNP.y * 12.0;
#line 1201
}
#line 1204
}
#line 1207
}
#line 1210
}
#line 1213
}
#line 1216
}
#line 1218
float dstN = posM.x - posN.x;
float dstP = posP.x - posM.x;
if(!horzSpan) dstN = posM.y - posN.y;
if(!horzSpan) dstP = posP.y - posM.y;
#line 1223
bool goodSpanN = (lumaEndN < 0.0) != lumaMLTZero;
float spanLength = (dstP + dstN);
bool goodSpanP = (lumaEndP < 0.0) != lumaMLTZero;
float spanLengthRcp = 1.0/spanLength;
#line 1228
bool directionN = dstN < dstP;
float dst = min(dstN, dstP);
bool goodSpan;
if (directionN)
goodSpan = goodSpanN;
else
goodSpan = goodSpanP;
float subpixG = subpixF * subpixF;
float pixelOffset = (dst * (-spanLengthRcp)) + 0.5;
float subpixH = subpixG * fxaaQualitySubpix;
#line 1239
float pixelOffsetGood;
if (goodSpan)
pixelOffsetGood = pixelOffset;
else
pixelOffsetGood = 0.0;
float pixelOffsetSubpix = max(pixelOffsetGood, subpixH);
if(!horzSpan) posM.x += pixelOffsetSubpix * lengthSign;
if( horzSpan) posM.y += pixelOffsetSubpix * lengthSign;
#line 1250
return float4(tex2Dlod(tex, float4(posM, 0.0, 0.0)).xyz, rgbyM.w);
#line 1252
}
#line 63 "C:\Program Files\GShade\gshade-shaders\Shaders\FXAA.fx"
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
#line 64 "C:\Program Files\GShade\gshade-shaders\Shaders\FXAA.fx"
#line 67
sampler FXAATexture
{
Texture = ReShade::BackBufferTex;
MinFilter = Linear; MagFilter = Linear;
#line 72
SRGBTexture = true;
#line 74
};
#line 79
float4 FXAALumaPass(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color = tex2D(ReShade::BackBuffer, texcoord.xy);
color.a = sqrt(dot(color.rgb * color.rgb, float3(0.299, 0.587, 0.114)));
return color;
}
#line 87
float4 FXAAPixelShader(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return FxaaPixelShader(
texcoord, 
0, 
FXAATexture, 
FXAATexture, 
FXAATexture, 
float2((1.0 / 1920), (1.0 / 1018)), 
0, 
0, 
0, 
Subpix, 
EdgeThreshold, 
EdgeThresholdMin, 
0, 
0, 
0, 
0 
);
}
#line 111
technique FXAA
{
#line 114
pass
{
VertexShader = PostProcessVS;
PixelShader = FXAALumaPass;
}
#line 120
pass
{
VertexShader = PostProcessVS;
PixelShader = FXAAPixelShader;
#line 125
SRGBWriteEnable = true;
#line 127
}
}

