// CMAA2_MLAA_EDGE_DETECTION=0
// g_CMAA2_DebugEdges=0
// CMAA2_EXTRA_SHARPNESS=0
// CMAA2_STATIC_QUALITY_PRESET=2
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\CMAA_2.fx"
#line 89
static const uint c_maxLineLength = 128;
#line 144
static const float c_symmetryCorrectionOffset = float( 0.22 );
#line 148
static const float c_dampeningEffect          = float( 0.15 );
#line 153
uniform int UIHELP <
ui_type = "radio";
ui_category = "Help";
ui_label = "    ";
ui_text =  "CMAA2_EXTRA_SHARPNESS - This settings makes the effect of the AA more sharp overall \n"
"Can be either 0 or 1. (0 (off) by default) \n\n"
"CMAA2_STATIC_QUALITY_PRESET - This setting ranges from 0 to 4, and adjusts the strength "
"of the edge detection, higher settings come at a performance cost \n"
"0 - LOW, 1 - MEDIUM, 2 - HIGH, 3 - ULTRA, 4 - SUFFER (default of 2)";
>;
#line 179
uniform bool bSharp <
ui_label = "Extra Sharpness";
ui_category = "General Settings";
ui_tooltip = "This settings makes the effect of the AA more sharp overall.";
ui_bind = "CMAA2_EXTRA_SHARPNESS";
> = 0;
#line 186
uniform int iPreset <
ui_type = "slider";
ui_min = 0;
ui_max = 4;
ui_label = "Strength";
ui_category = "General Settings";
ui_tooltip = "This setting adjusts the strength of the edge detection, higher "
"settings come at a performance cost. \n"
"0 - LOW, 1 - MEDIUM, 2 - HIGH, 3 - ULTRA, 4 - SUFFER (default of 2)";
ui_bind = "CMAA2_STATIC_QUALITY_PRESET";
> = 2;
#line 208
uniform bool bDebugEdges <
ui_label = "Debug Edges";
ui_category = "Debugging";
ui_tooltip = "This setting enables an overlay showing the edges detected "
"by the shader.";
ui_bind = "g_CMAA2_DebugEdges";
> = false;
#line 220
namespace CMAA_2
{
texture2D ZShapes <pooled = true;>{Width = 1920; Height = 1018; Format = RGBA8;};
texture2D BackBuffer : COLOR;
texture2D Edges <pooled = true;>{Width = 1920; Height = 1018; Format = R8;};
texture2D ProcessedCandidates <pooled = true;>{Width = 1920; Height = 1018; Format = RGBA16f;};
#line 227
sampler2D sZShapes {Texture = ZShapes;};
sampler2D sBackBuffer {Texture = BackBuffer;};
sampler2D sEdges {Texture = Edges;};
sampler2D sProcessedCandidates{Texture = ProcessedCandidates;};
#line 256
texture Sum {Width = uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x; Height = uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).y; Format = RG8;};
texture StackAlloc {Width = uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x; Height = uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).y; Format = R32f;};
texture ZShapeCoords {Width = 1920; Height = (((1018) + (48) - 1) / (48)); Format = R32f;};
#line 260
sampler sSum {Texture = Sum;};
sampler sStackAlloc {Texture = StackAlloc;};
sampler sZShapeCoords {Texture = ZShapeCoords;};
#line 264
storage wSum {Texture = Sum;};
storage wStackAlloc {Texture = StackAlloc;};
storage wZShapeCoords {Texture = ZShapeCoords;};
storage wZShapes {Texture = ZShapes;};
storage wProcessedCandidates {Texture = ProcessedCandidates;};
#line 289
float PackEdges( float4 edges, bool isCandidate )   
{
return (dot( edges, float4( 1, 2, 4, 8 )) + 16 * isCandidate)  / 255;
}
#line 294
uint4 UnpackEdges( uint value )
{
uint4 ret;
#line 303
ret.x = (value & 0x1) != 0;
ret.y = (value & 0x2) != 0;
ret.z = (value & 0x4) != 0;
ret.w = (value & 0x8) != 0;
#line 308
return ret;
}
#line 311
float4 UnpackEdgesFlt( uint value )
{
return float4(UnpackEdges(value));
}
#line 316
float4 packZ(bool horizontal, bool invertedZ, float shapeQualityScore, float lineLengthLeft, float lineLengthRight)
{
#line 319
float4 temp = float4(
lineLengthLeft,
lineLengthRight,
shapeQualityScore,
horizontal * 2 + invertedZ + 4);
return temp / 255;
}
#line 327
void unpackZ(float4 packedZ, out bool horizontal, out bool invertedZ, out float shapeQualityScore, out float lineLengthLeft, out float lineLengthRight)
{
uint4 temp = packedZ * 255.5;
horizontal = temp.w / 2 % 2;
invertedZ = temp.w % 2;
shapeQualityScore = temp.z;
lineLengthLeft = temp.x;
lineLengthRight = temp.y;
}
#line 338
float2 packSum(uint value)
{
float2 temp;
temp.x = (value & 0xFF00) >> 8;
temp.y = (value & 0xFF);
return (temp) / 255;
}
#line 346
uint unpackSum(float2 value)
{
uint2 temp = value * 255.5;
return ((temp.x << 8) | temp.y);
}
#line 357
float3 LoadSourceColor( uint2 pixelPos )
{
float3 color = tex2Dfetch(sBackBuffer, pixelPos).rgb;
return color;
}
#line 363
float3 LoadSourceColor( uint2 pixelPos, int2 offset )
{
return LoadSourceColor(pixelPos + offset);
}
#line 373
float EdgeDetectColorCalcDiff( float3 colorA, float3 colorB )
{
const float3 LumWeights = float3( 0.299, 0.587, 0.114 );
float3 diff = abs( (colorA.rgb - colorB.rgb) );
return dot( diff.rgb, LumWeights.rgb );
}
#line 381
float4 PSComputeEdge(float3 pixelColor,float3 pixelColorRight,float3 pixelColorBottom, float3 pixelColorLeft, float3 pixelColorTop)
{
float4 temp = float4(
EdgeDetectColorCalcDiff(pixelColor, pixelColorRight),
EdgeDetectColorCalcDiff(pixelColor, pixelColorBottom),
EdgeDetectColorCalcDiff(pixelColor, pixelColorLeft),
EdgeDetectColorCalcDiff(pixelColor, pixelColorTop));
return temp;    
}
#line 392
float PSComputeLocalContrast(float leftTop, float rightTop, float leftBottom, float rightBottom, float localContrastAdaptationAmount)
{
return max(max(max(rightTop, rightBottom), leftTop), leftBottom) * localContrastAdaptationAmount;
}
#line 397
float PSComputeLocalContrast(float leftTop, float rightTop, float leftBottom, float rightBottom)
{
return PSComputeLocalContrast( leftTop, rightTop, leftBottom, rightBottom, float(0.10));
}
#line 404
float4 ComputeSimpleShapeBlendValues( float4 edges, float4 edgesLeft, float4 edgesRight, float4 edgesTop, float4 edgesBottom, const bool dontTestShapeValidity )
{
#line 408
float fromRight = edges.r;
float fromBelow = edges.g;
float fromLeft  = edges.b;
float fromAbove = edges.a;
#line 413
float blurCoeff = float( float(0.10) );
#line 415
float numberOfEdges = dot( edges, float4( 1, 1, 1, 1 ) );
#line 417
float numberOfEdgesAllAround = dot(edgesLeft.bga + edgesRight.rga + edgesTop.rba + edgesBottom.rgb, float3( 1, 1, 1 ) );
#line 420
if( !dontTestShapeValidity )
{
#line 423
if( numberOfEdges == 1 )
blurCoeff = 0;
#line 427
if( numberOfEdges == 2 )
blurCoeff *= ( ( float(1.0) - fromBelow * fromAbove ) * ( float(1.0) - fromRight * fromLeft ) );
}
#line 433
if( numberOfEdges == 2 )
{
blurCoeff *= 0.75;
#line 437
float k = 0.9f;
fromRight += k * (edges.g * edgesTop.r    * (1.0-edgesLeft.g)   + edges.a * edgesBottom.r * (1.0-edgesLeft.a)  );
fromBelow += k * (edges.b * edgesRight.g  * (1.0-edgesTop.b)    + edges.r * edgesLeft.g   * (1.0-edgesTop.r)   );
fromLeft  += k * (edges.a * edgesBottom.b * (1.0-edgesRight.a)  + edges.g * edgesTop.b    * (1.0-edgesRight.g) );
fromAbove += k * (edges.r * edgesLeft.a   * (1.0-edgesBottom.r) + edges.b * edgesRight.a  * (1.0-edgesBottom.b));
}
#line 451
blurCoeff *= saturate( 1.30 - numberOfEdgesAllAround / 10.0 );
#line 454
return float4( fromLeft, fromAbove, fromRight, fromBelow ) * blurCoeff;
}
#line 457
uint LoadEdge(int2 pixelPos)
{
uint edge   = uint(tex2Dfetch(sEdges, pixelPos).x * 255.5);
return edge;
}
#line 463
uint LoadEdge(int2 pixelPos, int2 offset)
{
return LoadEdge(pixelPos + offset);
}
#line 474
uint4 GatherEdge(float2 texcoord)
{
uint4 edges = uint4(tex2DgatherR(sEdges, texcoord) * 255.5);
return edges;
}
#line 480
uint4 GatherEdge(float2 texcoord, int2 offset)
{
uint4 edges = uint4(tex2DgatherR(sEdges, texcoord, offset) * 255.5);
return edges;
}
#line 493
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 510
static const float g_CMAA2_MLAAMaxLumaSurround = 0.5;
#line 512
void EdgesPS(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float output : SV_TARGET0)
{
int2 coord = position.xy;
float3 a = tex2Dfetch(sBackBuffer, coord + int2(-1, -1)).rgb;
float3 b = tex2Dfetch(sBackBuffer, coord + int2( 0, -1)).rgb;
float3 c = tex2Dfetch(sBackBuffer, coord + int2( 1, -1)).rgb;
float3 d = tex2Dfetch(sBackBuffer, coord + int2(-1,  0)).rgb;
float3 e = tex2Dfetch(sBackBuffer, coord + int2( 0,  0)).rgb;
float3 f = tex2Dfetch(sBackBuffer, coord + int2( 1,  0)).rgb;
float3 g = tex2Dfetch(sBackBuffer, coord + int2(-1,  1)).rgb;
float3 h = tex2Dfetch(sBackBuffer, coord + int2( 0,  1)).rgb;
float3 i = tex2Dfetch(sBackBuffer, coord + int2( 1,  1)).rgb;
#line 525
float4 edges = PSComputeEdge(e.rgb, f.rgb, h.rgb, d.rgb, b.rgb);
#line 532
float ab = EdgeDetectColorCalcDiff(a.rgb, b.rgb);
float bc = EdgeDetectColorCalcDiff(b.rgb, c.rgb);
float de = EdgeDetectColorCalcDiff(d.rgb, e.rgb);
float gh = EdgeDetectColorCalcDiff(g.rgb, h.rgb);
float hi = EdgeDetectColorCalcDiff(h.rgb, i.rgb);
#line 538
float4 localContrast;
localContrast.x = PSComputeLocalContrast(de, edges.y, gh, hi);
localContrast.z = PSComputeLocalContrast(ab, bc, de, edges.y);
#line 543
float ad = EdgeDetectColorCalcDiff(a.rgb, d.rgb);
float be = EdgeDetectColorCalcDiff(b.rgb, e.rgb);
float dg = EdgeDetectColorCalcDiff(d.rgb, g.rgb);
float cf = EdgeDetectColorCalcDiff(c.rgb, f.rgb);
float fi = EdgeDetectColorCalcDiff(f.rgb, i.rgb);
#line 549
localContrast.y = PSComputeLocalContrast(be, cf, edges.x, fi);
localContrast.w = PSComputeLocalContrast(ad, be, dg, edges.x);
edges -= localContrast;
#line 555
edges = (edges > float(0.07)) ? float4(1, 1, 1, 1) : float4(0, 0, 0, 0);
#line 558
bool isCandidate = ( edges.x * edges.y + edges.y * edges.z + edges.z * edges.w + edges.w * edges.x ) != 0;
#line 560
output = PackEdges(edges, isCandidate);
#line 562
}
#line 564
void FindZLineLengths( out float lineLengthLeft, out float lineLengthRight, uint2 screenPos, bool horizontal, bool invertedZShape, const float2 stepRight)
{
#line 570
uint maskLeft, bitsContinueLeft, maskRight, bitsContinueRight;
{
#line 577
uint maskTraceLeft, maskTraceRight;
#line 581
if( horizontal )
{
maskTraceLeft = 0x08; 
maskTraceRight = 0x02; 
#line 589
}
else
{
maskTraceLeft = 0x04; 
maskTraceRight = 0x01; 
#line 598
}
if( invertedZShape )
{
uint temp = maskTraceLeft;
maskTraceLeft = maskTraceRight;
maskTraceRight = temp;
}
maskLeft = maskTraceLeft;
bitsContinueLeft = maskTraceLeft;
maskRight = maskTraceRight;
#line 612
bitsContinueRight = maskTraceRight;
}
#line 616
bool continueLeft = true;
bool continueRight = true;
float maxLR;
lineLengthLeft = 1;
lineLengthRight = 1;
[loop]
while(true)
{
uint edgeLeft  = LoadEdge( screenPos.xy, -stepRight *   lineLengthLeft       );
uint edgeRight = LoadEdge( screenPos.xy,  stepRight * ( lineLengthRight + 1 ));
#line 632
continueLeft   = continueLeft  && ( edgeLeft & maskLeft );
continueRight  = continueRight && ( edgeRight & maskRight );
#line 636
lineLengthLeft  += continueLeft;
lineLengthRight += continueRight;
#line 640
maxLR = ( !continueLeft && !continueRight ) ?
(float)c_maxLineLength : max( lineLengthRight, lineLengthLeft );
#line 648
if( maxLR >= min( (float)c_maxLineLength, (1.25 * min( lineLengthRight, lineLengthLeft ) - 0.25) ) )
#line 650
break;
}
}
#line 654
void DetectZsHorizontal( in float4 edges, in float4 edgesM1P0, in float4 edgesP1P0, in float4 edgesP2P0, out float invertedZScore, out float normalZScore )
{
#line 660
{
invertedZScore  = edges.r * edges.g *                edgesP1P0.a;
invertedZScore  *= 2.0 + (edgesM1P0.g + edgesP2P0.a) - (edges.a + edgesP1P0.g) - 0.7 * (edgesP2P0.g + edgesM1P0.a + edges.b + edgesP1P0.r);
}
#line 669
{
normalZScore    = edges.r * edges.a *                edgesP1P0.g;
normalZScore    *= 2.0 + (edgesM1P0.a + edgesP2P0.g) - (edges.g + edgesP1P0.a) - 0.7 * (edgesP2P0.a + edgesM1P0.g + edges.b + edgesP1P0.r);
}
}
#line 675
float4 BlendSimpleShape(uint2 coord, float4 edges, float4 edgesLeft, float4 edgesRight, float4 edgesBottom, float4 edgesTop)
{
float4 blendVal = ComputeSimpleShapeBlendValues(edges, edgesLeft, edgesRight, edgesTop, edgesBottom, true);
#line 679
const float fourWeightSum = dot(blendVal, 1);
const float centerWeight = 1 - fourWeightSum;
#line 682
float3 outColor = LoadSourceColor(coord, int2(0, 0)).rgb * centerWeight;
#line 684
float3 pixel;
#line 687
pixel = LoadSourceColor(coord, int2(-1, 0)).rgb;
outColor.rgb += (blendVal.x > 0) ? blendVal.x * pixel : 0;
#line 691
pixel = LoadSourceColor(coord, int2(0, -1)).rgb;
outColor.rgb += (blendVal.y > 0) ? blendVal.y * pixel : 0;
#line 695
pixel = LoadSourceColor(coord, int2(1, 0)).rgb;
outColor.rgb += (blendVal.z > 0) ? blendVal.z * pixel : 0;
#line 699
pixel = LoadSourceColor(coord, int2(0, 1)).rgb;
outColor.rgb += (blendVal.w > 0) ? blendVal.w * pixel : 0;
#line 702
return float4(outColor.rgb, 1);
}
#line 705
float4 DetectComplexShapes(uint2 coord, float4 edges, float4 edgesLeft, float4 edgesRight, float4 edgesBottom, float4 edgesTop)
{
float invertedZScore = 0;
float normalZScore = 0;
float maxScore = 0;
bool horizontal = true;
bool invertedZ = false;
#line 716
{
float4 edgesM1P0 = edgesLeft;
float4 edgesP1P0 = edgesRight;
float4 edgesP2P0 = UnpackEdgesFlt( LoadEdge(coord, int2(  2, 0 )) );
#line 721
DetectZsHorizontal( edges, edgesM1P0, edgesP1P0, edgesP2P0, invertedZScore, normalZScore );
maxScore = max( invertedZScore, normalZScore );
#line 724
if( maxScore > 0 )
{
invertedZ = invertedZScore > normalZScore;
}
}
#line 733
{
#line 741
float4 edgesM1P0 = edgesBottom;
float4 edgesP1P0 = edgesTop;
float4 edgesP2P0 =  UnpackEdgesFlt( LoadEdge(coord, int2( 0, -2 )) );
#line 745
DetectZsHorizontal( edges.argb, edgesM1P0.argb, edgesP1P0.argb, edgesP2P0.argb, invertedZScore, normalZScore );
float vertScore = max( invertedZScore, normalZScore );
#line 748
if( vertScore > maxScore )
{
maxScore = vertScore;
horizontal = false;
invertedZ = invertedZScore > normalZScore;
}
}
#line 757
if( maxScore > 0 )
{
#line 762
float shapeQualityScore = floor( clamp(4.0 - maxScore, 0.0, 3.0) );    
#line 765
const float2 stepRight = ( horizontal ) ? ( float2( 1, 0 ) ) : ( float2( 0, -1 ) );
float lineLengthLeft, lineLengthRight;
FindZLineLengths( lineLengthLeft, lineLengthRight, coord, horizontal, invertedZ, stepRight);
#line 769
lineLengthLeft  -= shapeQualityScore;
lineLengthRight -= shapeQualityScore;
if( ( lineLengthLeft + lineLengthRight ) >= (5.0) )
{
return packZ(horizontal, invertedZ, shapeQualityScore, lineLengthLeft, lineLengthRight);
}
}
return float4(0.0, 0.0, 0.0, 0.0);
#line 778
}
#line 897
groupshared uint g_count;
groupshared uint g_work[uint2(uint2(16, 16).x * uint2(1, 2).x, uint2(16, 16).y * uint2(1, 2).y).x * uint2(uint2(16, 16).x * uint2(1, 2).x, uint2(16, 16).y * uint2(1, 2).y).y];
groupshared uint count;
void ProcessEdgesCS(uint3 id : SV_DispatchThreadID, uint gIndex : SV_GroupIndex, uint3 gid : SV_GroupID, uint3 gtid : SV_GroupThreadID)
{
uint2 coord = id.xy * uint2(1, 2);
if(gIndex == 0) g_count = 0;
barrier();
[unroll]
for(uint i = 0; i < uint2(1, 2).x; i++)
{
[unroll]
for(uint j = 0; j < uint2(1, 2).y; j++)
{
uint center = LoadEdge(coord, int2(i, j));
#line 914
if(center > 16)
{
uint workerId = atomicAdd(g_count, 1u);
g_work[workerId] =  (coord.x + i) << 18 | (coord.y + j) << 4 | (center & 0xF);
}
}
}
barrier();
#line 923
uint threadIndex = gIndex;
uint count = g_count;
#line 926
while(threadIndex < count)
{
uint center = g_work[threadIndex];
coord = float2(uint(center >> 18), uint((center >> 4) & 0x3FFF));
center = center;
float4 edges = UnpackEdgesFlt(center);
float4 edgesLeft = UnpackEdgesFlt(LoadEdge(coord, int2(-1, 0)));
float4 edgesRight = UnpackEdgesFlt(LoadEdge(coord, int2(1, 0)));
float4 edgesBottom = UnpackEdgesFlt(LoadEdge(coord, int2(0, 1)));
float4 edgesTop = UnpackEdgesFlt(LoadEdge(coord, int2(0, -1)));
#line 937
tex2Dstore(wProcessedCandidates, coord, BlendSimpleShape(coord, edges, edgesLeft, edgesRight, edgesBottom, edgesTop));
#line 939
float4 complexShape = DetectComplexShapes(coord, edges, edgesLeft, edgesRight, edgesBottom, edgesTop);
if(any(complexShape > 0))
tex2Dstore(wZShapes, coord, complexShape);
#line 943
threadIndex += uint2(16, 16).x * uint2(16, 16).y;
}
}
#line 947
void SumCS(uint3 id : SV_DispatchThreadID, uint3 gid : SV_GroupID, uint3 gtid : SV_GroupThreadID)
{
if(all(gtid.xy == 0))
count = 0;
barrier();
#line 953
uint2 coord = id.xy * 2;
float4 values = tex2DgatherA(sZShapes, float2(coord + 1) / float2(1920, 1018));
float4 candidates = (values > (3.9f / 255.0f)) ? float4(1, 1, 1, 1) : float4(0, 0, 0, 0);
uint localSum = dot(candidates, 1);
atomicAdd(count, localSum);
barrier();
#line 960
if(all(gtid.xy == 0))
{
tex2Dstore(wSum, gid.xy, packSum(count).xyxx);
}
}
#line 966
void StackAllocCS(uint3 id : SV_DispatchThreadID, uint3 gid : SV_GroupID, uint3 gtid : SV_GroupThreadID)
{
if(all(gtid.xy == 0))
count = 0;
barrier();
uint index = id.x * (((((uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x * uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).y)) + ((1024)) - 1) / ((1024))));
uint localPrefixSum[(((((uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x * uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).y)) + ((1024)) - 1) / ((1024))))];
localPrefixSum[0] = unpackSum(tex2Dfetch(sSum, uint2(index % uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x, index / uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x)).xy);
[unroll]
for(int i = 1; i < (((((uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x * uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).y)) + ((1024)) - 1) / ((1024)))); i++)
{
uint2 sampleCoord = uint2((index + i) % uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x, (index + i) / uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x);
localPrefixSum[i] = unpackSum(tex2Dfetch(sSum, sampleCoord).xy) + localPrefixSum[i - 1];
}
#line 981
uint baseCount = atomicAdd(count, localPrefixSum[(((((uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x * uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).y)) + ((1024)) - 1) / ((1024)))) - 1]);
#line 983
tex2Dstore(wStackAlloc, uint2(index % uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x, index / uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x), asfloat(baseCount).xxxx);
[unroll]
for(int i = 1; i < (((((uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x * uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).y)) + ((1024)) - 1) / ((1024)))); i++)
{
uint2 sampleCoord = uint2((index + i) % uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x, (index + i) / uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x);
tex2Dstore(wStackAlloc, sampleCoord, asfloat(baseCount + localPrefixSum[i - 1]).xxxx);
}
}
#line 992
void StackInsertionCS(uint3 id : SV_DispatchThreadID, uint3 gid : SV_GroupID, uint3 gtid : SV_GroupThreadID)
{
if(all(gtid.xy == 0))
count = 0;
barrier();
#line 998
uint writeAddress = asuint(tex2Dfetch(sStackAlloc, gid.xy).x);
#line 1000
uint2 coord = id.xy * 2;
float4 values = tex2DgatherA(sZShapes, float2(coord + 1) / float2(1920, 1018));
float4 candidates = (values > (3.9f / 255.0f)) ? float4(1, 1, 1, 1) : float4(0, 0, 0, 0);
uint localSum = dot(candidates, 1);
uint localOffset = atomicAdd(count, localSum);
uint j = 0;
[unroll]
for(int i = 0; i < 4; i++)
{
if(bool(candidates[i]))
{
uint address = writeAddress + localOffset + j;
uint2 currCoord = (i == 0) ? uint2(coord.x, coord.y + 1) :
(i == 1) ? uint2(coord.x + 1, coord.y + 1) :
(i == 2) ? uint2(coord.x + 1, coord.y) : coord;
uint packedCoord = (currCoord.x << 16 | currCoord.y);
tex2Dstore(wZShapeCoords, uint2(address % 1920, address / 1920), asfloat(packedCoord).xxxx);
j++;
}
}
}
#line 1023
void LongEdgeVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0, out float4 data : TANGENT0)
{
#line 1026
uint packedCoord = asuint(tex2Dfetch(sZShapeCoords, uint2((id / 2) % 1920, (id / 2) / 1920))).x;
uint2 coord = uint2((packedCoord >> 16), (packedCoord & 0xFFFF));
#line 1053
data = tex2Dfetch(sZShapes, coord);
#line 1056
if(!(data.w > (3.9f / 255.0f)))
{
position = -10;
texcoord = -10;
}
else
{
bool horizontal;
bool invertedZ;
float shapeQualityScore;
float lineLengthLeft;
float lineLengthRight;
unpackZ(data, horizontal, invertedZ, shapeQualityScore, lineLengthLeft, lineLengthRight);
float loopFrom = -floor( ( lineLengthLeft + 1 ) / 2 ) + 1.0;
float loopTo = floor( ( lineLengthRight + 1 ) / 2 );
const float2 stepRight = ( horizontal ) ? float2( 1, 0 ) : float2( 0, -1 );
float2 offset = (id % 2) ? stepRight * loopTo : stepRight * loopFrom;
texcoord = (float2(coord + offset) + 0.5) / float2(1920, 1018);
position = float4(texcoord.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
texcoord = (id % 2) ? loopTo : loopFrom;
}
}
#line 1080
void LongEdgePS(float4 position : SV_Position, float2 texcoord : TEXCOORD0, float4 info : TANGENT0, out float4 output : SV_TARGET0)
{
output = 1;
bool horizontal;
bool invertedZShape;
float shapeQualityScore;
float lineLengthLeft;
float lineLengthRight;
unpackZ(info, horizontal, invertedZShape, shapeQualityScore, lineLengthLeft, lineLengthRight);
float2 blendDir = ( horizontal ) ? float2( 0, -1 ) : float2( -1, 0 );
float i = ( horizontal ) ? texcoord.x : texcoord.y;
if( invertedZShape )
blendDir = -blendDir;
#line 1094
float leftOdd = c_symmetryCorrectionOffset * float( lineLengthLeft % 2 );
float rightOdd = c_symmetryCorrectionOffset * float( lineLengthRight % 2 );
#line 1097
float dampenEffect = saturate( float(lineLengthLeft + lineLengthRight - shapeQualityScore) * c_dampeningEffect ) ;
#line 1099
float loopFrom = -floor( ( lineLengthLeft + 1 ) / 2 ) + 1.0;
float loopTo = floor( ( lineLengthRight + 1 ) / 2 );
#line 1102
float totalLength = float(loopTo - loopFrom) + 1 - leftOdd - rightOdd;
float lerpStep = float(1.0) / totalLength;
#line 1105
float lerpFromK = (0.5 - leftOdd - loopFrom) * lerpStep;
#line 1107
float lerpVal = mad(lerpStep, i, lerpFromK);
#line 1109
bool  secondPart = (i > 0);
float srcOffset = 1.0 - (secondPart * 2.0);
#line 1112
float lerpK = lerpVal * srcOffset + secondPart;
lerpK *= dampenEffect;
#line 1115
output.rgb = tex2D(sBackBuffer, (position.xy + float2(0.0, 0.0) + blendDir * float(srcOffset).xx * lerpK) * float2((1.0 / 1920), (1.0 / 1018))).rgb;
output = output * 2.25;
}
#line 1120
void ApplyPS(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 output : SV_TARGET)
{
float2 coord = position.xy;
output = tex2Dfetch(sProcessedCandidates, coord);
#line 1131
if(output.a <= 0.5)
discard;
#line 1134
output.rgb /= output.a;
}
#line 1138
void ClearVS(in uint id : SV_VertexID, out float4 position : SV_Position)
{
position = -3;
}
#line 1143
void ClearPS(float4 position : SV_Position, out float4 output0 : SV_TARGET0)
{
output0 = 0;
discard;
}
#line 1151
technique CMAA_2 < ui_tooltip = "A port of Intel's CMAA 2.0 (Conservative Morphological Anti-Aliasing) to ReShade\n\n"
"Ported to ReShade by: Lord Of Lunacy";>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = EdgesPS;
RenderTarget0 = Edges;
}
#line 1170
pass
{
VertexShader = ClearVS;
PixelShader = ClearPS;
RenderTarget0 = ZShapeCoords;
ClearRenderTargets = true;
PrimitiveTopology = POINTLIST;
VertexCount = 1;
}
#line 1180
pass
{
VertexShader = ClearVS;
PixelShader = ClearPS;
RenderTarget0 = ProcessedCandidates;
RenderTarget1 = ZShapes;
ClearRenderTargets = true;
PrimitiveTopology = POINTLIST;
VertexCount = 1;
}
#line 1191
pass
{
ComputeShader = ProcessEdgesCS<uint2(16, 16).x, uint2(16, 16).y>;
DispatchSizeX = uint2((((1920) + (uint2(uint2(16, 16).x * uint2(1, 2).x, uint2(16, 16).y * uint2(1, 2).y).x) - 1) / (uint2(uint2(16, 16).x * uint2(1, 2).x, uint2(16, 16).y * uint2(1, 2).y).x)), (((1018) + (uint2(uint2(16, 16).x * uint2(1, 2).x, uint2(16, 16).y * uint2(1, 2).y).y) - 1) / (uint2(uint2(16, 16).x * uint2(1, 2).x, uint2(16, 16).y * uint2(1, 2).y).y))).x;
DispatchSizeY = uint2((((1920) + (uint2(uint2(16, 16).x * uint2(1, 2).x, uint2(16, 16).y * uint2(1, 2).y).x) - 1) / (uint2(uint2(16, 16).x * uint2(1, 2).x, uint2(16, 16).y * uint2(1, 2).y).x)), (((1018) + (uint2(uint2(16, 16).x * uint2(1, 2).x, uint2(16, 16).y * uint2(1, 2).y).y) - 1) / (uint2(uint2(16, 16).x * uint2(1, 2).x, uint2(16, 16).y * uint2(1, 2).y).y))).y;
}
#line 1198
pass
{
ComputeShader = SumCS<uint2(32, 32).x, uint2(32, 32).y>;
DispatchSizeX = uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x;
DispatchSizeY = uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).y;
}
#line 1205
pass
{
ComputeShader = StackAllocCS<(1024), 1>;
DispatchSizeX = 1;
DispatchSizeY = 1;
}
#line 1212
pass
{
ComputeShader = StackInsertionCS<uint2(32, 32).x, uint2(32, 32).y>;
DispatchSizeX = uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).x;
DispatchSizeY = uint2((((1920) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).x)), (((1018) + (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y) - 1) / (uint2(uint2(32, 32).x * uint2(2, 2).x, uint2(32, 32).y * uint2(2, 2).y).y))).y;
}
#line 1220
pass
{
VertexShader = LongEdgeVS;
PixelShader = LongEdgePS;
PrimitiveTopology = LINELIST;
#line 1226
VertexCount = (1920 * (((1018) + (48) - 1) / (48)) * 2);
#line 1232
ClearRenderTargets = false;
#line 1234
BlendEnable = true;
#line 1236
BlendOp = ADD;
BlendOpAlpha = ADD;
#line 1239
SrcBlend = ONE;
SrcBlendAlpha = ONE;
DestBlend = ONE;
DestBlendAlpha = ONE;
#line 1244
RenderTarget = ProcessedCandidates;
}
#line 1247
pass
{
VertexShader = PostProcessVS;
PixelShader = ApplyPS;
#line 1252
BlendEnable = true;
#line 1254
BlendOp = ADD;
BlendOpAlpha = ADD;
#line 1257
SrcBlend = SRCALPHA;
DestBlend = INVSRCALPHA;
}
}
}

