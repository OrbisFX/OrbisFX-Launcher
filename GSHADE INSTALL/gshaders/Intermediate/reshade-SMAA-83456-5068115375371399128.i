// SMAA_REPROJECTION=0
// SMAA_REPROJECTION_WEIGHT_SCALE=30.0
// SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR=2.0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\SMAA.fx"
#line 23
uniform int EdgeDetectionType <
ui_type = "combo";
ui_items = "Luminance edge detection\0Color edge detection\0Depth edge detection\0";
ui_label = "Edge Detection Type";
> = 1;
#line 30
uniform float EdgeDetectionThreshold <
ui_type = "slider";
ui_min = 0.05; ui_max = 0.20; ui_step = 0.001;
ui_tooltip = "Edge detection threshold. If SMAA misses some edges try lowering this slightly.";
ui_label = "Edge Detection Threshold";
> = 0.10;
#line 37
uniform float DepthEdgeDetectionThreshold <
ui_type = "slider";
ui_min = 0.001; ui_max = 0.10; ui_step = 0.001;
ui_tooltip = "Depth Edge detection threshold. If SMAA misses some edges try lowering this slightly.";
ui_label = "Depth Edge Detection Threshold";
> = 0.01;
#line 44
uniform int MaxSearchSteps <
ui_type = "slider";
ui_min = 0; ui_max = 112;
ui_label = "Max Search Steps";
ui_tooltip = "Determines the radius SMAA will search for aliased edges.";
> = 32;
#line 51
uniform int MaxSearchStepsDiagonal <
ui_type = "slider";
ui_min = 0; ui_max = 20;
ui_label = "Max Search Steps Diagonal";
ui_tooltip = "Determines the radius SMAA will search for diagonal aliased edges";
> = 16;
#line 58
uniform int CornerRounding <
ui_type = "slider";
ui_min = 0; ui_max = 100;
ui_label = "Corner Rounding";
ui_tooltip = "Determines the percent of anti-aliasing to apply to corners.";
> = 25;
#line 65
uniform bool PredicationEnabled <
ui_label = "Enable Predicated Thresholding";
> = false;
#line 69
uniform float PredicationThreshold <
ui_type = "slider";
ui_min = 0.005; ui_max = 1.00; ui_step = 0.01;
ui_tooltip = "Threshold to be used in the additional predication buffer.";
ui_label = "Predication Threshold";
> = 0.01;
#line 76
uniform float PredicationScale <
ui_type = "slider";
ui_min = 0; ui_max = 8;
ui_tooltip = "How much to scale the global threshold used for luma or color edge.";
ui_label = "Predication Scale";
> = 2.0;
#line 83
uniform float PredicationStrength <
ui_type = "slider";
ui_min = 0; ui_max = 4;
ui_tooltip = "How much to locally decrease the threshold.";
ui_label = "Predication Strength";
> = 0.4;
#line 91
uniform int DebugOutput <
ui_type = "combo";
ui_items = "None\0View edges\0View weights\0";
ui_label = "Debug Output";
> = false;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\SMAA.fxh"
#line 600
float3 SMAAGatherNeighbours(float2 texcoord,
float4 offset[3],
sampler tex) {
#line 606
const float P = tex2D(tex, texcoord).r;
const float Pleft = tex2D(tex, offset[0].xy).r;
const float Ptop  = tex2D(tex, offset[0].zw).r;
return float3(P, Pleft, Ptop);
#line 611
}
#line 616
float2 SMAACalculatePredicatedThreshold(float2 texcoord,
float4 offset[3],
sampler predicationTex) {
const float3 neighbours = SMAAGatherNeighbours(texcoord, offset, predicationTex);
const float2 delta = abs(neighbours.xx - neighbours.yz);
const float2 edges = step(PredicationThreshold, delta);
return PredicationScale * EdgeDetectionThreshold * (1.0 - PredicationStrength * edges);
}
#line 628
void SMAAMovc(bool2 cond, inout float2 variable, float2 value) {
[flatten] if (cond.x) variable.x = value.x;
[flatten] if (cond.y) variable.y = value.y;
}
#line 633
void SMAAMovc(bool4 cond, inout float4 variable, float4 value) {
SMAAMovc(cond.xy, variable.xy, value.xy);
SMAAMovc(cond.zw, variable.zw, value.zw);
}
#line 646
void SMAAEdgeDetectionVS(float2 texcoord,
out float4 offset[3]) {
offset[0] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4(-1.0, 0.0, 0.0, -1.0), texcoord.xyxy);
offset[1] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
offset[2] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4(-2.0, 0.0, 0.0, -2.0), texcoord.xyxy);
}
#line 656
void SMAABlendingWeightCalculationVS(float2 texcoord,
out float2 pixcoord,
out float4 offset[3]) {
pixcoord = texcoord * float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).zw;
#line 662
offset[0] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4(-0.25, -0.125,  1.25, -0.125), texcoord.xyxy);
offset[1] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4(-0.125, -0.25, -0.125,  1.25), texcoord.xyxy);
#line 666
offset[2] = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xxyy,
float4(-2.0, 2.0, -2.0, 2.0) * float(MaxSearchSteps),
float4(offset[0].xz, offset[1].yw));
}
#line 674
void SMAANeighborhoodBlendingVS(float2 texcoord,
out float4 offset) {
offset = mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
}
#line 690
float2 SMAALumaEdgeDetectionPS(float2 texcoord,
float4 offset[3],
sampler colorTex
) {
#line 695
const float2 threshold = float2(EdgeDetectionThreshold, EdgeDetectionThreshold);
#line 698
const float3 weights = float3(0.2126, 0.7152, 0.0722);
const float L = dot(tex2D(colorTex, texcoord).rgb, weights);
#line 701
const float Lleft = dot(tex2D(colorTex, offset[0].xy).rgb, weights);
const float Ltop  = dot(tex2D(colorTex, offset[0].zw).rgb, weights);
#line 705
float4 delta;
delta.xy = abs(L - float2(Lleft, Ltop));
float2 edges = step(threshold, delta.xy);
#line 710
if (dot(edges, float2(1.0, 1.0)) == 0.0)
discard;
#line 714
const float Lright = dot(tex2D(colorTex, offset[1].xy).rgb, weights);
const float Lbottom  = dot(tex2D(colorTex, offset[1].zw).rgb, weights);
delta.zw = abs(L - float2(Lright, Lbottom));
#line 719
float2 maxDelta = max(delta.xy, delta.zw);
#line 722
const float Lleftleft = dot(tex2D(colorTex, offset[2].xy).rgb, weights);
const float Ltoptop = dot(tex2D(colorTex, offset[2].zw).rgb, weights);
delta.zw = abs(float2(Lleft, Ltop) - float2(Lleftleft, Ltoptop));
#line 727
maxDelta = max(maxDelta.xy, delta.zw);
const float finalDelta = max(maxDelta.x, maxDelta.y);
#line 731
edges.xy *= step(finalDelta, 2.0 * delta.xy);
#line 733
return edges;
}
#line 736
float2 SMAALumaEdgePredicationDetectionPS(float2 texcoord,
float4 offset[3],
sampler colorTex
, sampler predicationTex
) {
#line 742
const float2 threshold = SMAACalculatePredicatedThreshold(texcoord, offset, predicationTex);
#line 745
const float3 weights = float3(0.2126, 0.7152, 0.0722);
const float L = dot(tex2D(colorTex, texcoord).rgb, weights);
#line 748
const float Lleft = dot(tex2D(colorTex, offset[0].xy).rgb, weights);
const float Ltop  = dot(tex2D(colorTex, offset[0].zw).rgb, weights);
#line 752
float4 delta;
delta.xy = abs(L - float2(Lleft, Ltop));
float2 edges = step(threshold, delta.xy);
#line 757
if (dot(edges, float2(1.0, 1.0)) == 0.0)
discard;
#line 761
const float Lright = dot(tex2D(colorTex, offset[1].xy).rgb, weights);
const float Lbottom  = dot(tex2D(colorTex, offset[1].zw).rgb, weights);
delta.zw = abs(L - float2(Lright, Lbottom));
#line 766
float2 maxDelta = max(delta.xy, delta.zw);
#line 769
const float Lleftleft = dot(tex2D(colorTex, offset[2].xy).rgb, weights);
const float Ltoptop = dot(tex2D(colorTex, offset[2].zw).rgb, weights);
delta.zw = abs(float2(Lleft, Ltop) - float2(Lleftleft, Ltoptop));
#line 774
maxDelta = max(maxDelta.xy, delta.zw);
const float finalDelta = max(maxDelta.x, maxDelta.y);
#line 778
edges.xy *= step(finalDelta, 2.0 * delta.xy);
#line 780
return edges;
}
#line 789
float2 SMAAColorEdgeDetectionPS(float2 texcoord,
float4 offset[3],
sampler colorTex
) {
#line 794
const float2 threshold = float2(EdgeDetectionThreshold, EdgeDetectionThreshold);
#line 797
float4 delta;
const float3 C = tex2D(colorTex, texcoord).rgb;
#line 800
const float3 Cleft = tex2D(colorTex, offset[0].xy).rgb;
float3 t = abs(C - Cleft);
delta.x = max(max(t.r, t.g), t.b);
#line 804
const float3 Ctop  = tex2D(colorTex, offset[0].zw).rgb;
t = abs(C - Ctop);
delta.y = max(max(t.r, t.g), t.b);
#line 809
float2 edges = step(threshold, delta.xy);
#line 812
if (dot(edges, float2(1.0, 1.0)) == 0.0)
discard;
#line 816
const float3 Cright = tex2D(colorTex, offset[1].xy).rgb;
t = abs(C - Cright);
delta.z = max(max(t.r, t.g), t.b);
#line 820
const float3 Cbottom  = tex2D(colorTex, offset[1].zw).rgb;
t = abs(C - Cbottom);
delta.w = max(max(t.r, t.g), t.b);
#line 825
float2 maxDelta = max(delta.xy, delta.zw);
#line 828
const float3 Cleftleft  = tex2D(colorTex, offset[2].xy).rgb;
t = abs(Cleft - Cleftleft);
delta.z = max(max(t.r, t.g), t.b);
#line 832
const float3 Ctoptop = tex2D(colorTex, offset[2].zw).rgb;
t = abs(Ctop - Ctoptop);
delta.w = max(max(t.r, t.g), t.b);
#line 837
maxDelta = max(maxDelta.xy, delta.zw);
const float finalDelta = max(maxDelta.x, maxDelta.y);
#line 841
edges.xy *= step(finalDelta, 2.0 * delta.xy);
#line 843
return edges;
}
#line 846
float2 SMAAColorEdgePredicationDetectionPS(float2 texcoord,
float4 offset[3],
sampler colorTex
, sampler predicationTex
) {
#line 852
const float2 threshold = SMAACalculatePredicatedThreshold(texcoord, offset, predicationTex);
#line 855
float4 delta;
const float3 C = tex2D(colorTex, texcoord).rgb;
#line 858
const float3 Cleft = tex2D(colorTex, offset[0].xy).rgb;
float3 t = abs(C - Cleft);
delta.x = max(max(t.r, t.g), t.b);
#line 862
const float3 Ctop  = tex2D(colorTex, offset[0].zw).rgb;
t = abs(C - Ctop);
delta.y = max(max(t.r, t.g), t.b);
#line 867
float2 edges = step(threshold, delta.xy);
#line 870
if (dot(edges, float2(1.0, 1.0)) == 0.0)
discard;
#line 874
const float3 Cright = tex2D(colorTex, offset[1].xy).rgb;
t = abs(C - Cright);
delta.z = max(max(t.r, t.g), t.b);
#line 878
const float3 Cbottom  = tex2D(colorTex, offset[1].zw).rgb;
t = abs(C - Cbottom);
delta.w = max(max(t.r, t.g), t.b);
#line 883
float2 maxDelta = max(delta.xy, delta.zw);
#line 886
const float3 Cleftleft  = tex2D(colorTex, offset[2].xy).rgb;
t = abs(Cleft - Cleftleft);
delta.z = max(max(t.r, t.g), t.b);
#line 890
const float3 Ctoptop = tex2D(colorTex, offset[2].zw).rgb;
t = abs(Ctop - Ctoptop);
delta.w = max(max(t.r, t.g), t.b);
#line 895
maxDelta = max(maxDelta.xy, delta.zw);
const float finalDelta = max(maxDelta.x, maxDelta.y);
#line 899
edges.xy *= step(finalDelta, 2.0 * delta.xy);
#line 901
return edges;
}
#line 907
float2 SMAADepthEdgeDetectionPS(float2 texcoord,
float4 offset[3],
sampler depthTex) {
const float3 neighbours = SMAAGatherNeighbours(texcoord, offset, depthTex);
const float2 delta = abs(neighbours.xx - float2(neighbours.y, neighbours.z));
const float2 edges = step(DepthEdgeDetectionThreshold, delta);
#line 914
if (dot(edges, float2(1.0, 1.0)) == 0.0)
discard;
#line 917
return edges;
}
#line 928
float2 SMAADecodeDiagBilinearAccess(float2 e) {
#line 942
e.r = e.r * abs(5.0 * e.r - 5.0 * 0.75);
return round(e);
}
#line 946
float4 SMAADecodeDiagBilinearAccess(float4 e) {
e.rb = e.rb * abs(5.0 * e.rb - 5.0 * 0.75);
return round(e);
}
#line 954
float2 SMAASearchDiag1(sampler edgesTex, float2 texcoord, float2 dir, out float2 e) {
float4 coord = float4(texcoord, -1.0, 1.0);
const float3 t = float3(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy, 1.0);
while (coord.z < float(MaxSearchStepsDiagonal - 1) &&
coord.w > 0.9) {
coord.xyz = mad(t, float3(dir, 1.0), coord.xyz);
e = tex2Dlod(edgesTex, float4(coord.xy, coord.xy)).rg;
coord.w = dot(e, float2(0.5, 0.5));
}
return coord.zw;
}
#line 966
float2 SMAASearchDiag2(sampler edgesTex, float2 texcoord, float2 dir, out float2 e) {
float4 coord = float4(texcoord, -1.0, 1.0);
coord.x += 0.25 * float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).x; 
const float3 t = float3(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy, 1.0);
while (coord.z < float(MaxSearchStepsDiagonal - 1) &&
coord.w > 0.9) {
coord.xyz = mad(t, float3(dir, 1.0), coord.xyz);
#line 976
e = tex2Dlod(edgesTex, float4(coord.xy, coord.xy)).rg;
e = SMAADecodeDiagBilinearAccess(e);
#line 983
coord.w = dot(e, float2(0.5, 0.5));
}
return coord.zw;
}
#line 992
float2 SMAAAreaDiag(sampler areaTex, float2 dist, float2 e, float offset) {
float2 texcoord = mad(float2(20, 20), e, dist);
#line 996
texcoord = mad((1.0 / float2(160.0, 560.0)), texcoord, 0.5 * (1.0 / float2(160.0, 560.0)));
#line 999
texcoord.x += 0.5;
#line 1002
texcoord.y += (1.0 / 7.0) * offset;
#line 1005
return tex2Dlod(areaTex, float4(texcoord, texcoord)).rg;
}
#line 1011
float2 SMAACalculateDiagWeights(sampler edgesTex, sampler areaTex, float2 texcoord, float2 e, float4 subsampleIndices) {
float2 weights = float2(0.0, 0.0);
#line 1015
float4 d;
float2 end;
if (e.r > 0.0) {
d.xz = SMAASearchDiag1(edgesTex, texcoord, float2(-1.0,  1.0), end);
d.x += float(end.y > 0.9);
} else
d.xz = float2(0.0, 0.0);
d.yw = SMAASearchDiag1(edgesTex, texcoord, float2(1.0, -1.0), end);
#line 1024
[branch]
if (d.x + d.y > 2.0) { 
#line 1027
const float4 coords = mad(float4(-d.x + 0.25, d.x, d.y, -d.y - 0.25), float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, texcoord.xyxy);
float4 c;
c.xy = tex2Dlod(edgesTex, float4(coords.xy, coords.xy), int2(-1, 0)).rg;
c.zw = tex2Dlod(edgesTex, float4(coords.zw, coords.zw), int2( 1, 0)).rg;
c.yxwz = SMAADecodeDiagBilinearAccess(c.xyzw);
#line 1042
float2 cc = mad(float2(2.0, 2.0), c.xz, c.yw);
#line 1045
SMAAMovc(bool2(step(0.9, d.zw)), cc, float2(0.0, 0.0));
#line 1048
weights += SMAAAreaDiag(areaTex, d.xy, cc, subsampleIndices.z);
}
#line 1052
d.xz = SMAASearchDiag2(edgesTex, texcoord, float2(-1.0, -1.0), end);
if (tex2Dlod(edgesTex, float4(texcoord, texcoord), int2(1, 0)).r > 0.0) {
d.yw = SMAASearchDiag2(edgesTex, texcoord, float2(1.0, 1.0), end);
d.y += float(end.y > 0.9);
} else
d.yw = float2(0.0, 0.0);
#line 1059
[branch]
if (d.x + d.y > 2.0) { 
#line 1062
const float4 coords = mad(float4(-d.x, -d.x, d.y, d.y), float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xyxy, texcoord.xyxy);
float4 c;
c.x  = tex2Dlod(edgesTex, float4(coords.xy, coords.xy), int2(-1, 0)).g;
c.y  = tex2Dlod(edgesTex, float4(coords.xy, coords.xy), int2( 0, -1)).r;
c.zw = tex2Dlod(edgesTex, float4(coords.zw, coords.zw), int2( 1, 0)).gr;
float2 cc = mad(float2(2.0, 2.0), c.xz, c.yw);
#line 1070
SMAAMovc(bool2(step(0.9, d.zw)), cc, float2(0.0, 0.0));
#line 1073
weights += SMAAAreaDiag(areaTex, d.xy, cc, subsampleIndices.w).gr;
}
#line 1076
return weights;
}
#line 1089
float SMAASearchLength(sampler searchTex, float2 e, float offset) {
#line 1092
float2 scale = float2(66.0, 33.0) * float2(0.5, -1.0);
float2 bias = float2(66.0, 33.0) * float2(offset, 1.0);
#line 1096
scale += float2(-1.0,  1.0);
bias  += float2( 0.5, -0.5);
#line 1101
scale *= 1.0 / float2(64.0, 16.0);
bias *= 1.0 / float2(64.0, 16.0);
#line 1105
return tex2Dlod(searchTex, float4(mad(scale, e, bias), mad(scale, e, bias))).r;
}
#line 1111
float SMAASearchXLeft(sampler edgesTex, sampler searchTex, float2 texcoord, float end) {
#line 1119
float2 e = float2(0.0, 1.0);
while (texcoord.x > end &&
e.g > 0.8281 && 
e.r == 0.0) { 
e = tex2Dlod(edgesTex, float4(texcoord, texcoord)).rg;
texcoord = mad(-float2(2.0, 0.0), float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy, texcoord);
}
#line 1127
const float offset = mad(-(255.0 / 127.0), SMAASearchLength(searchTex, e, 0.0), 3.25);
return mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).x, offset, texcoord.x);
#line 1141
}
#line 1143
float SMAASearchXRight(sampler edgesTex, sampler searchTex, float2 texcoord, float end) {
float2 e = float2(0.0, 1.0);
while (texcoord.x < end &&
e.g > 0.8281 && 
e.r == 0.0) { 
e = tex2Dlod(edgesTex, float4(texcoord, texcoord)).rg;
texcoord = mad(float2(2.0, 0.0), float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy, texcoord);
}
const float offset = mad(-(255.0 / 127.0), SMAASearchLength(searchTex, e, 0.5), 3.25);
return mad(-float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).x, offset, texcoord.x);
}
#line 1155
float SMAASearchYUp(sampler edgesTex, sampler searchTex, float2 texcoord, float end) {
float2 e = float2(1.0, 0.0);
while (texcoord.y > end &&
e.r > 0.8281 && 
e.g == 0.0) { 
e = tex2Dlod(edgesTex, float4(texcoord, texcoord)).rg;
texcoord = mad(-float2(0.0, 2.0), float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy, texcoord);
}
const float offset = mad(-(255.0 / 127.0), SMAASearchLength(searchTex, e.gr, 0.0), 3.25);
return mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).y, offset, texcoord.y);
}
#line 1167
float SMAASearchYDown(sampler edgesTex, sampler searchTex, float2 texcoord, float end) {
float2 e = float2(1.0, 0.0);
while (texcoord.y < end &&
e.r > 0.8281 && 
e.g == 0.0) { 
e = tex2Dlod(edgesTex, float4(texcoord, texcoord)).rg;
texcoord = mad(float2(0.0, 2.0), float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy, texcoord);
}
const float offset = mad(-(255.0 / 127.0), SMAASearchLength(searchTex, e.gr, 0.5), 3.25);
return mad(-float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).y, offset, texcoord.y);
}
#line 1183
float2 SMAAArea(sampler areaTex, float2 dist, float e1, float e2, float offset) {
#line 1185
float2 texcoord = mad(float2(16, 16), round(4.0 * float2(e1, e2)), dist);
#line 1188
texcoord = mad((1.0 / float2(160.0, 560.0)), texcoord, 0.5 * (1.0 / float2(160.0, 560.0)));
#line 1191
texcoord.y = mad((1.0 / 7.0), offset, texcoord.y);
#line 1194
return tex2Dlod(areaTex, float4(texcoord, texcoord)).rg;
}
#line 1200
void SMAADetectHorizontalCornerPattern(sampler edgesTex, inout float2 weights, float4 texcoord, float2 d) {
#line 1202
const float2 leftRight = step(d.xy, d.yx);
float2 rounding = (1.0 - (float(CornerRounding) / 100.0)) * leftRight;
#line 1205
rounding /= leftRight.x + leftRight.y; 
#line 1207
float2 factor = float2(1.0, 1.0);
factor.x -= rounding.x * tex2Dlod(edgesTex, float4(texcoord.xy, texcoord.xy), int2(0, 1)).r;
factor.x -= rounding.y * tex2Dlod(edgesTex, float4(texcoord.zw, texcoord.zw), int2(1, 1)).r;
factor.y -= rounding.x * tex2Dlod(edgesTex, float4(texcoord.xy, texcoord.xy), int2(0, -2)).r;
factor.y -= rounding.y * tex2Dlod(edgesTex, float4(texcoord.zw, texcoord.zw), int2(1, -2)).r;
#line 1213
weights *= saturate(factor);
#line 1215
}
#line 1217
void SMAADetectVerticalCornerPattern(sampler edgesTex, inout float2 weights, float4 texcoord, float2 d) {
#line 1219
const float2 leftRight = step(d.xy, d.yx);
float2 rounding = (1.0 - (float(CornerRounding) / 100.0)) * leftRight;
#line 1222
rounding /= leftRight.x + leftRight.y;
#line 1224
float2 factor = float2(1.0, 1.0);
factor.x -= rounding.x * tex2Dlod(edgesTex, float4(texcoord.xy, texcoord.xy), int2( 1, 0)).g;
factor.x -= rounding.y * tex2Dlod(edgesTex, float4(texcoord.zw, texcoord.zw), int2( 1, 1)).g;
factor.y -= rounding.x * tex2Dlod(edgesTex, float4(texcoord.xy, texcoord.xy), int2(-2, 0)).g;
factor.y -= rounding.y * tex2Dlod(edgesTex, float4(texcoord.zw, texcoord.zw), int2(-2, 1)).g;
#line 1230
weights *= saturate(factor);
#line 1232
}
#line 1237
float4 SMAABlendingWeightCalculationPS(float2 texcoord,
float2 pixcoord,
float4 offset[3],
sampler edgesTex,
sampler areaTex,
sampler searchTex,
float4 subsampleIndices) { 
float4 weights = float4(0.0, 0.0, 0.0, 0.0);
#line 1246
float2 e = tex2D(edgesTex, texcoord).rg;
#line 1248
[branch]
if (e.g > 0.0) { 
#line 1253
weights.rg = SMAACalculateDiagWeights(edgesTex, areaTex, texcoord, e, subsampleIndices);
#line 1257
[branch]
if (weights.r == -weights.g) { 
#line 1261
float2 d;
#line 1264
float3 coords;
coords.x = SMAASearchXLeft(edgesTex, searchTex, offset[0].xy, offset[2].x);
coords.y = offset[1].y; 
d.x = coords.x;
#line 1272
const float e1 = tex2Dlod(edgesTex, float4(coords.xy, coords.xy)).r;
#line 1275
coords.z = SMAASearchXRight(edgesTex, searchTex, offset[0].zw, offset[2].y);
d.y = coords.z;
#line 1280
d = abs(round(mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).zz, d, -pixcoord.xx)));
#line 1284
const float2 sqrt_d = sqrt(d);
#line 1287
const float e2 = tex2Dlod(edgesTex, float4(coords.zy, coords.zy), int2(1, 0)).r;
#line 1291
weights.rg = SMAAArea(areaTex, sqrt_d, e1, e2, subsampleIndices.y);
#line 1294
coords.y = texcoord.y;
SMAADetectHorizontalCornerPattern(edgesTex, weights.rg, coords.xyzy, d);
#line 1298
} else
e.r = 0.0; 
#line 1301
}
#line 1303
[branch]
if (e.r > 0.0) { 
float2 d;
#line 1308
float3 coords;
coords.y = SMAASearchYUp(edgesTex, searchTex, offset[1].xy, offset[2].z);
coords.x = offset[0].x; 
d.x = coords.y;
#line 1314
const float e1 = tex2Dlod(edgesTex, float4(coords.xy, coords.xy)).g;
#line 1317
coords.z = SMAASearchYDown(edgesTex, searchTex, offset[1].zw, offset[2].w);
d.y = coords.z;
#line 1321
d = abs(round(mad(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).ww, d, -pixcoord.yy)));
#line 1325
const float2 sqrt_d = sqrt(d);
#line 1328
const float e2 = tex2Dlod(edgesTex, float4(coords.xz, coords.xz), int2(0, 1)).g;
#line 1331
weights.ba = SMAAArea(areaTex, sqrt_d, e1, e2, subsampleIndices.x);
#line 1334
coords.x = texcoord.x;
SMAADetectVerticalCornerPattern(edgesTex, weights.ba, coords.xyxz, d);
}
#line 1338
return weights;
}
#line 1344
float4 SMAANeighborhoodBlendingPS(float2 texcoord,
float4 offset,
sampler colorTex,
sampler blendTex
#line 1351
) {
#line 1353
float4 a;
a.x = tex2D(blendTex, offset.xy).a; 
a.y = tex2D(blendTex, offset.zw).g; 
a.wz = tex2D(blendTex, texcoord).xz; 
#line 1359
[branch]
if (dot(a, float4(1.0, 1.0, 1.0, 1.0)) < 1e-5) {
float4 color = tex2Dlod(colorTex, float4(texcoord, texcoord));
#line 1370
return color;
} else {
bool h = max(a.x, a.z) > max(a.y, a.w); 
#line 1375
float4 blendingOffset = float4(0.0, a.y, 0.0, a.w);
float2 blendingWeight = a.yw;
SMAAMovc(bool4(h, h, h, h), blendingOffset, float4(a.x, 0.0, a.z, 0.0));
SMAAMovc(bool2(h, h), blendingWeight, a.xz);
blendingWeight /= dot(blendingWeight, float2(1.0, 1.0));
#line 1382
const float4 blendingCoord = mad(blendingOffset, float4(float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy, -float4((1.0 / 1920), (1.0 / 1018), 1920, 1018).xy), texcoord.xyxy);
#line 1386
float4 color = blendingWeight.x * tex2Dlod(colorTex, float4(blendingCoord.xy, blendingCoord.xy));
color += blendingWeight.y * tex2Dlod(colorTex, float4(blendingCoord.zw, blendingCoord.zw));
#line 1398
return color;
}
}
#line 1405
float4 SMAAResolvePS(float2 texcoord,
sampler currentColorTex,
sampler previousColorTex
#line 1411
) {
#line 1431
const float4 current = tex2D(currentColorTex, texcoord);
const float4 previous = tex2D(previousColorTex, texcoord);
return lerp(current, previous, 0.5);
#line 1435
}
#line 128 "C:\Program Files\GShade\gshade-shaders\Shaders\SMAA.fx"
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
#line 129 "C:\Program Files\GShade\gshade-shaders\Shaders\SMAA.fx"
#line 132
texture depthTex < pooled = true; >
{
Width = 1920;
Height = 1018;
Format = R16F;
};
#line 139
texture edgesTex < pooled = true; >
{
Width = 1920;
Height = 1018;
Format = RG8;
};
texture blendTex < pooled = true; >
{
Width = 1920;
Height = 1018;
Format = RGBA8;
};
#line 152
texture areaTex < source = "AreaTex.png"; >
{
Width = 160;
Height = 560;
Format = RG8;
};
texture searchTex < source = "SearchTex.png"; >
{
Width = 64;
Height = 16;
Format = R8;
};
#line 167
sampler depthLinearSampler
{
Texture = depthTex;
};
#line 172
sampler colorGammaSampler
{
Texture = ReShade::BackBufferTex;
AddressU = Clamp; AddressV = Clamp;
MipFilter = Point; MinFilter = Linear; MagFilter = Linear;
#line 178
SRGBTexture = false;
#line 180
};
sampler colorLinearSampler
{
Texture = ReShade::BackBufferTex;
AddressU = Clamp; AddressV = Clamp;
MipFilter = Point; MinFilter = Linear; MagFilter = Linear;
#line 187
SRGBTexture = true;
#line 189
};
sampler edgesSampler
{
Texture = edgesTex;
AddressU = Clamp; AddressV = Clamp;
MipFilter = Linear; MinFilter = Linear; MagFilter = Linear;
SRGBTexture = false;
};
sampler blendSampler
{
Texture = blendTex;
AddressU = Clamp; AddressV = Clamp;
MipFilter = Linear; MinFilter = Linear; MagFilter = Linear;
SRGBTexture = false;
};
sampler areaSampler
{
Texture = areaTex;
AddressU = Clamp; AddressV = Clamp; AddressW = Clamp;
MipFilter = Linear; MinFilter = Linear; MagFilter = Linear;
SRGBTexture = false;
};
sampler searchSampler
{
Texture = searchTex;
AddressU = Clamp; AddressV = Clamp; AddressW = Clamp;
MipFilter = Point; MinFilter = Point; MagFilter = Point;
SRGBTexture = false;
};
#line 221
void SMAAEdgeDetectionWrapVS(
in uint id : SV_VertexID,
out float4 position : SV_Position,
out float2 texcoord : TEXCOORD0,
out float4 offset[3] : TEXCOORD1)
{
PostProcessVS(id, position, texcoord);
SMAAEdgeDetectionVS(texcoord, offset);
}
void SMAABlendingWeightCalculationWrapVS(
in uint id : SV_VertexID,
out float4 position : SV_Position,
out float2 texcoord : TEXCOORD0,
out float2 pixcoord : TEXCOORD1,
out float4 offset[3] : TEXCOORD2)
{
PostProcessVS(id, position, texcoord);
SMAABlendingWeightCalculationVS(texcoord, pixcoord, offset);
}
void SMAANeighborhoodBlendingWrapVS(
in uint id : SV_VertexID,
out float4 position : SV_Position,
out float2 texcoord : TEXCOORD0,
out float4 offset : TEXCOORD1)
{
PostProcessVS(id, position, texcoord);
SMAANeighborhoodBlendingVS(texcoord, offset);
}
#line 252
float SMAADepthLinearizationPS(
float4 position : SV_Position,
float2 texcoord : TEXCOORD) : SV_Target
{
return ReShade::GetLinearizedDepth(texcoord);
}
#line 259
float2 SMAAEdgeDetectionWrapPS(
float4 position : SV_Position,
float2 texcoord : TEXCOORD0,
float4 offset[3] : TEXCOORD1) : SV_Target
{
if (EdgeDetectionType == 0 && PredicationEnabled == true)
return SMAALumaEdgePredicationDetectionPS(texcoord, offset, colorGammaSampler, depthLinearSampler);
else if (EdgeDetectionType == 0)
return SMAALumaEdgeDetectionPS(texcoord, offset, colorGammaSampler);
#line 269
if (EdgeDetectionType == 2)
return SMAADepthEdgeDetectionPS(texcoord, offset, depthLinearSampler);
#line 272
if (PredicationEnabled)
return SMAAColorEdgePredicationDetectionPS(texcoord, offset, colorGammaSampler, depthLinearSampler);
else
return SMAAColorEdgeDetectionPS(texcoord, offset, colorGammaSampler);
}
float4 SMAABlendingWeightCalculationWrapPS(
float4 position : SV_Position,
float2 texcoord : TEXCOORD0,
float2 pixcoord : TEXCOORD1,
float4 offset[3] : TEXCOORD2) : SV_Target
{
return SMAABlendingWeightCalculationPS(texcoord, pixcoord, offset, edgesSampler, areaSampler, searchSampler, 0.0);
}
#line 286
float4 SMAANeighborhoodBlendingWrapPS(
float4 position : SV_Position,
float2 texcoord : TEXCOORD0,
float4 offset : TEXCOORD1) : SV_Target
{
if (DebugOutput == 1)
return tex2D(edgesSampler, texcoord);
if (DebugOutput == 2)
return tex2D(blendSampler, texcoord);
#line 296
return SMAANeighborhoodBlendingPS(texcoord, offset, colorLinearSampler, blendSampler);
}
#line 301
technique SMAA
{
pass LinearizeDepthPass
{
VertexShader = PostProcessVS;
PixelShader = SMAADepthLinearizationPS;
RenderTarget = depthTex;
}
pass EdgeDetectionPass
{
VertexShader = SMAAEdgeDetectionWrapVS;
PixelShader = SMAAEdgeDetectionWrapPS;
RenderTarget = edgesTex;
ClearRenderTargets = true;
StencilEnable = true;
StencilPass = REPLACE;
StencilRef = 1;
}
pass BlendWeightCalculationPass
{
VertexShader = SMAABlendingWeightCalculationWrapVS;
PixelShader = SMAABlendingWeightCalculationWrapPS;
RenderTarget = blendTex;
ClearRenderTargets = true;
StencilEnable = true;
StencilPass = KEEP;
StencilFunc = EQUAL;
StencilRef = 1;
}
pass NeighborhoodBlendingPass
{
VertexShader = SMAANeighborhoodBlendingWrapVS;
PixelShader = SMAANeighborhoodBlendingWrapPS;
StencilEnable = false;
#line 336
SRGBWriteEnable = true;
#line 338
}
}

