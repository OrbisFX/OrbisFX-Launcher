// DH_ANIME_RENDER_SCALE=2
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_anime.fx"
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
#line 16 "C:\Program Files\GShade\gshade-shaders\Shaders\dh_anime.fx"
#line 31
namespace DHAnime13 {
#line 34
uniform int framecount < source = "framecount"; >;
#line 62
uniform float3 cBlackLineColor <
ui_category = "Black lines";
ui_label = "Color";
ui_type = "color";
> = 0;
uniform float fBlackLineMultiply <
ui_category= "Black lines";
ui_label = "Color intensity";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 1.0;
#line 76
uniform bool bDepthBlackLine <
ui_category = "Black lines";
ui_label = "Depth based";
> = true;
uniform int iDepthBlackLineThickness <
ui_category = "Black lines";
ui_label = "Thickness (depth)";
ui_type = "slider";
ui_min = 0;
ui_max = 16;
ui_step = 1;
> = 2;
uniform float fDepthBlackLineThreshold <
ui_category = "Black lines";
ui_label = "Threshold (depth)";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.995;
#line 97
uniform bool bColorBlackLine <
ui_category = "Black lines";
ui_label = "Color based";
> = true;
uniform int iColorBlackLineThickness <
ui_category = "Black lines";
ui_label = "Thickness (color)";
ui_type = "slider";
ui_min = 0;
ui_max = 16;
ui_step = 1;
> = 2;
uniform float fColorBlackLineThreshold <
ui_category = "Black lines";
ui_label = "Threshold (color)";
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.935;
#line 118
uniform float iSurfaceBlur <
ui_category = "Colors";
ui_label = "Surface blur";
ui_type = "slider";
ui_min = 0;
ui_max = 16;
ui_step = 1;
> = 3;
#line 127
uniform float fSaturation <
ui_category = "Colors";
ui_label = "Saturation multiplier";
ui_type = "slider";
ui_min = 0.0;
ui_max = 5.0;
ui_step = 0.01;
> = 1.75;
#line 136
uniform float iShadingSteps <
ui_category = "Colors";
ui_label = "Shading steps";
ui_type = "slider";
ui_min = 1;
ui_max = 255;
ui_step = 1;
> = 16;
#line 145
uniform float fShadingRamp <
ui_category = "Colors";
ui_label = "Shading Ramp";
ui_type = "slider";
ui_min = 0;
ui_max = 6;
ui_step = 0.1;
> = 1.0;
#line 154
uniform bool bDithering <
ui_category = "Colors";
ui_label = "Dithering";
> = false;
#line 159
uniform bool bHueFilter <
ui_category = "Hue filter";
ui_label = "Enabled";
> = false;
uniform float fHueFilter <
ui_category = "Hue filter";
ui_label = "Selected hue";
ui_type = "slider";
ui_min = 0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.0;
uniform float fHueFilterRange <
ui_category = "Hue filter";
ui_label = "Range";
ui_type = "slider";
ui_min = 0;
ui_max = 1.0;
ui_step = 0.001;
> = 0.0;
#line 180
uniform int iToneMode <
ui_category= "Half-tone";
ui_type = "combo";
ui_label = "Half-tone mode";
ui_items = "Disable\0Greyscale\0Full color\0RGB dots (CRT Shadow mask)\0CMY dots (substractive print)\0";
> = 0;
#line 187
uniform int iToneEffect <
ui_category= "Half-tone";
ui_type = "combo";
ui_label = "Effect";
ui_items = "Size\0Brightness\0";
> = 0;
#line 194
uniform bool bToneRotateColors <
ui_category= "Half-tone";
ui_label = "RGB/CMY rotate colors (DLP rainbow effect)";
> = false;
#line 199
uniform float fToneDotSpacing <
ui_category = "Half-tone";
ui_label = "Dot spacing";
ui_type = "slider";
ui_min = 1;
ui_max = 32;
ui_step = 1;
> = 5;
#line 208
uniform float fToneDotRamp <
ui_category = "Half-tone";
ui_label = "Shading Ramp";
ui_type = "slider";
ui_min = 0;
ui_max = 6;
ui_step = 0.1;
> = 1.5;
#line 218
texture blueNoiseTex < source ="dh_rt_noise.png" ; > { Width = 512; Height = 512; MipLevels = 1; Format = RGBA8; };
sampler blueNoiseSampler { Texture = blueNoiseTex;  AddressU = REPEAT;	AddressV = REPEAT;	AddressW = REPEAT;};
#line 221
texture normalTex { Width = 1920; Height = 1018; };
sampler normalSampler { Texture = normalTex; };
#line 224
texture blurTex { Width = 1920; Height = 1018; };
sampler blurSampler { Texture = blurTex; };
#line 228
texture linesTex { Width = 1920*2; Height = 1018*2; };
sampler linesSampler { Texture = linesTex; };
#line 232
texture halftonesTex { Width = 1920*2; Height = 1018*2; };
sampler halftonesSampler { Texture = halftonesTex; };
#line 235
texture scaledTex { Width = 1920*2; Height = 1018*2; Format = RGBA8; MipLevels = 6; };
sampler scaledSampler { Texture = scaledTex; MinLOD = 0.0f; MaxLOD = 5.0f;};
#line 242
float3 RGBtoHSV(float3 c) {
float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
#line 247
float d = q.x - min(q.w, q.y);
float e = 1.0e-10;
return float3(float(abs(q.z + (q.w - q.y))) / (6.0 * d + e), d / (q.x + e), q.x);
}
#line 252
float3 HSVtoRGB(float3 c) {
float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
#line 258
float RGBCVtoHUE(in float3 RGB, in float C, in float V) {
float3 Delta = (V - RGB) / C;
Delta.rgb -= Delta.brg;
Delta.rgb += float3(2,4,6);
Delta.brg = step(V, RGB) * Delta.brg;
float H;
H = max(Delta.r, max(Delta.g, Delta.b));
return frac(H / 6);
}
#line 270
float3 normal(float2 texcoord)
{
float3 offset = float3(ReShade::GetPixelSize().xy, 0.0);
float2 posCenter = texcoord.xy;
float2 posNorth  = posCenter - offset.zy;
float2 posEast   = posCenter + offset.xz;
#line 277
float3 vertCenter = float3(posCenter - 0.5, 1) * ReShade::GetLinearizedDepth(posCenter)*1000.0;
float3 vertNorth  = float3(posNorth - 0.5,  1) * ReShade::GetLinearizedDepth(posNorth)*1000.0;
float3 vertEast   = float3(posEast - 0.5,   1) * ReShade::GetLinearizedDepth(posEast)*1000.0;
#line 281
return normalize(cross(vertCenter - vertNorth, vertCenter - vertEast));
}
#line 284
float mirrorSmoothstep(float v,float coef) {
if(v<0.5) {
return pow(max(v*2.0,0.0),1.0/coef)*0.5;
} else {
return pow(max((v-0.5)*2,0.0),coef)*0.5+0.5;
}
}
#line 292
bool inScreen(float2 coords) {
return coords.x>=0.0 && coords.x<=1.0
&& coords.y>=0.0 && coords.y<=1.0;
}
#line 298
void saveNormal(in float3 normal, out float4 outNormal)
{
outNormal = float4(normal*0.5+0.5,1.0);
}
#line 303
float3 loadNormal(in float2 coords) {
return (tex2Dlod(normalSampler,float4((coords).xy,0,0)).xyz-0.5)*2.0;
}
#line 310
void PS_Input(float4 vpos : SV_Position, in float2 coords : TEXCOORD0, out float4 outNormal : SV_Target, out float4 outBlur : SV_Target1)
{
float3 normal = normal(coords);
saveNormal(normal,outNormal);
#line 315
float3 color;
#line 317
if(iSurfaceBlur>0) {
float3 sum;
int count;
#line 321
int maxDistance = iSurfaceBlur*iSurfaceBlur;
float depth = ReShade::GetLinearizedDepth(coords)*1000.0;
#line 324
int2 delta;
for(delta.x=-iSurfaceBlur;delta.x<=iSurfaceBlur;delta.x++) {
for(delta.y=-iSurfaceBlur;delta.y<=iSurfaceBlur;delta.y++) {
int d = dot(delta,delta);
if(d<=maxDistance) {
float2 searchCoords = coords+ReShade::GetPixelSize()*delta;
float searchDepth = ReShade::GetLinearizedDepth(searchCoords)*1000.0;
float dRatio = depth/searchDepth;
#line 333
if(dRatio>=0.95 && dRatio<=1.05) {
float3 c = tex2Dlod(ReShade::BackBuffer,float4(searchCoords,0.0,0.0)).rgb;
float3 cHsv = RGBtoHSV(c);
cHsv.z = mirrorSmoothstep(cHsv.z,fShadingRamp);
c = HSVtoRGB(cHsv);
sum += c;
count++;
}
}
}
}
color = sum/count;
} else {
color = tex2Dlod(ReShade::BackBuffer,float4(coords,0.0,0.0)).rgb;
float3 cHsv = RGBtoHSV(color);
cHsv.z = mirrorSmoothstep(cHsv.z,fShadingRamp);
color = HSVtoRGB(cHsv);
}
#line 352
float3 hsv = RGBtoHSV(color);
#line 355
float stepSize = 1.0/iShadingSteps;
if(bDithering) {
int2 coordsNoise = int2(coords*int2(1920,1018))%512;
float noise = tex2Dfetch(blueNoiseSampler,coordsNoise).r;
#line 360
hsv.z = round((0.5*(noise-0.5)/iShadingSteps+hsv.z)/stepSize)/iShadingSteps;
} else {
hsv.z = round(hsv.z/stepSize)/iShadingSteps;
}
#line 366
hsv.y = saturate(hsv.y*fSaturation);
if(bHueFilter) {
#line 369
float hueDist = (fHueFilter<hsv.x
? min(hsv.x-fHueFilter,1+fHueFilter-hsv.x)
: min(fHueFilter-hsv.x,1-fHueFilter+hsv.x)
)*16;
#line 374
hueDist = smoothstep(0,1,saturate(hueDist));
#line 376
hsv.y *= 1.0-saturate(hueDist*(1.0-fHueFilterRange));
}
#line 380
color = HSVtoRGB(hsv);
#line 382
outBlur = float4(color,1);
}
#line 385
void PS_LinePass(float4 vpos : SV_Position, in float2 coords : TEXCOORD0, out float4 outPixel : SV_Target) {
if(!bColorBlackLine || iDepthBlackLineThickness<1) discard;
#line 388
float refDepth = ReShade::GetLinearizedDepth(coords)*1000.0;
float3 refColor = tex2Dlod(ReShade::BackBuffer,float4(coords,0.0,0.0)).rgb;
#line 391
float roughness = 0.0;
float ws = 0;
#line 394
float3 previousX = refColor;
float3 previousY = refColor;
#line 397
float threshold = 1.0-saturate(fColorBlackLineThreshold);
[loop]
for(int d = 1;d<=iColorBlackLineThickness;d++) {
float w = 1.0/pow(max(d,0.0),0.5);
#line 402
float3 color = tex2Dlod(ReShade::BackBuffer,float4(float2(coords.x+ReShade::GetPixelSize().x*d,coords.y),0.0,0.0)).rgb;
float3 diff = abs(previousX-color);
roughness += max(max(diff.x,diff.y),diff.z)*w>threshold ? 1 : 0;
ws += w;
previousX = color;
#line 408
color = tex2Dlod(ReShade::BackBuffer,float4(float2(coords.x,coords.y+ReShade::GetPixelSize().y*d),0.0,0.0)).rgb;
diff = abs(previousY-color);
roughness += max(max(diff.x,diff.y),diff.z)*w>threshold ? 1 : 0;
ws += w;
previousY = color;
}
#line 415
previousX = refColor;
previousY = refColor;
#line 418
[loop]
for(int d = 1;d<=iColorBlackLineThickness;d++) {
float w = 1.0/pow(max(d,0.0),0.5);
#line 422
float3 color = tex2Dlod(ReShade::BackBuffer,float4(float2(coords.x-ReShade::GetPixelSize().x*d,coords.y),0.0,0.0)).rgb;
float3 diff = abs(previousX-color);
roughness += max(max(diff.x,diff.y),diff.z)*w>threshold ? 1 : 0;
ws += w;
previousX = color;
#line 428
color = tex2Dlod(ReShade::BackBuffer,float4(float2(coords.x,coords.y-ReShade::GetPixelSize().y*d),0.0,0.0)).rgb;
diff = abs(previousY-color);
roughness += max(max(diff.x,diff.y),diff.z)*w>threshold ? 1 : 0;
ws += w;
previousY = color;
}
#line 435
float refB = max(max(refColor.x,refColor.y),refColor.z);
roughness *= pow(max(refB,0.0),0.5);
roughness *= pow(max(1.0-refB,0.0),2.0);
#line 440
float3 r = 1.0-roughness;
outPixel = float4(r,1);
}
#line 445
float getDotSpacing(float b) {
float result = fToneDotSpacing;
return ceil(result);
}
#line 450
bool isEvenLine(float2 coordsInt,float toneDotSpacing) {
float lineHeight = toneDotSpacing-1;
float topLine = floor(coordsInt.y/lineHeight);
float bottomLine = ceil(coordsInt.y/lineHeight);
#line 455
float dTop = coordsInt.y-topLine*lineHeight;
float dBottom = bottomLine*lineHeight-coordsInt.y;
#line 458
return (dTop<=dBottom && topLine%2==0) || (dTop>=dBottom && bottomLine%2==0);
}
#line 461
int2 getLineColumn(float2 coordsInt,float toneDotSpacing) {
float lineHeight = toneDotSpacing-1;
float topLine = floor(coordsInt.y/lineHeight);
float bottomLine = ceil(coordsInt.y/lineHeight);
#line 466
float dTop = coordsInt.y-topLine*lineHeight;
float dBottom = bottomLine*lineHeight-coordsInt.y;
#line 469
int2 result = 0;
#line 472
result.y = dTop<=dBottom ? topLine : bottomLine;
#line 474
float leftLine = floor(coordsInt.x/toneDotSpacing);
float rightLine = ceil(coordsInt.x/toneDotSpacing);
#line 477
float dLeft = abs(coordsInt.x-leftLine*toneDotSpacing);
float dRight = abs(coordsInt.x-rightLine*toneDotSpacing);
#line 480
result.x = dLeft<=dRight ? leftLine : rightLine;
#line 482
return result;
}
#line 485
float2 getDotCenter(float2 coordsInt,float toneDotSpacing) {
float lineHeight = toneDotSpacing-1;
float topLine = floor(coordsInt.y/lineHeight);
float bottomLine = ceil(coordsInt.y/lineHeight);
#line 490
float dTop = coordsInt.y-topLine*lineHeight;
float dBottom = bottomLine*lineHeight-coordsInt.y;
#line 493
bool evenLine = (dTop<=dBottom && topLine%2==0) || (dTop>=dBottom && bottomLine%2==0);
#line 495
float leftLine = floor(coordsInt.x/toneDotSpacing);
float rightLine = ceil(coordsInt.x/toneDotSpacing);
#line 498
float2 result = 0;
result.y = (dTop<=dBottom ? topLine : bottomLine)*lineHeight;
#line 501
if(evenLine) {
float leftLine2 = leftLine-0.5;
float leftLine = leftLine+0.5;
float rightLine2 = rightLine-0.5;
float rightLine = rightLine+0.5;
#line 507
float dLeft = abs(coordsInt.x-leftLine*toneDotSpacing);
float dRight = abs(coordsInt.x-rightLine*toneDotSpacing);
float dLeft2 = abs(coordsInt.x-leftLine2*toneDotSpacing);
float dRight2 = abs(coordsInt.x-rightLine2*toneDotSpacing);
#line 512
float minD = min(min(dLeft,dLeft2),min(dRight,dRight2));
#line 514
if(minD==dLeft) {
result.x = leftLine*toneDotSpacing;
} else if(minD==dRight) {
result.x = rightLine*toneDotSpacing;
} else if(minD==dLeft2) {
result.x = leftLine2*toneDotSpacing;
} else if(minD==dRight2) {
result.x = rightLine2*toneDotSpacing;
}
} else {
float dLeft = abs(coordsInt.x-leftLine*toneDotSpacing);
float dRight = abs(coordsInt.x-rightLine*toneDotSpacing);
result.x = (dLeft<=dRight ? leftLine : rightLine)*toneDotSpacing;
}
#line 530
return result;
}
#line 533
bool isComponents() {
return iToneMode==3 || iToneMode==4;
}
#line 537
float3 getDotBrightness(float brightness,float3 color, float2 coordsInt,float2 dotInt,float toneDotSpacing) {
#line 539
float dotMaxRadius = toneDotSpacing/2;
#line 541
float3 dotColor;
#line 543
if(iToneEffect==0) { 
float3 dotRadius = (dotMaxRadius-1)*(iToneMode!=1 ? brightness : 1.0-brightness);
#line 546
float3 dotCenterDistance = distance(dotInt,coordsInt);
#line 548
dotColor = lerp(0,1,saturate(dotCenterDistance-dotRadius));
#line 550
if(iToneMode>1) {
float3 hsv = RGBtoHSV(color);
hsv.z = saturate(mirrorSmoothstep(hsv.z,fToneDotRamp)*2);
color = HSVtoRGB(hsv);
dotColor = (1.0-dotColor)*color;
}
} else if(iToneEffect==1) { 
float3 dotRadius = max(1,dotMaxRadius-1);
#line 559
float3 dotCenterDistance = distance(dotInt,coordsInt);
#line 561
dotColor = lerp(0,1,saturate(dotCenterDistance-dotRadius));
#line 563
float3 hsv = RGBtoHSV(color);
hsv.z = saturate(mirrorSmoothstep(hsv.z,fToneDotRamp)*2);
if(iToneMode==1) {
color = hsv.z;
dotColor = hsv.z+dotColor-0.5;
} else {
color = HSVtoRGB(hsv);
dotColor = (1.0-dotColor)*color;
dotColor *= hsv.z;
}
}
#line 575
return dotColor;
}
#line 579
void PS_Halftone(float4 vpos : SV_Position, in float2 coords : TEXCOORD0, out float4 outPixel : SV_Target) {
if(iToneMode==0) discard;
#line 582
float2 coordsInt = coords*int2(1920,1018);
float3 color = tex2Dlod(blurSampler,float4((coords).xy,0,0)).rgb;
float brightness = mirrorSmoothstep(RGBtoHSV(color).z,fToneDotRamp);
#line 586
float depth = ReShade::GetLinearizedDepth(coords)*1000.0;
float toneDotSpacing = getDotSpacing(brightness);
float2 dotCenter = getDotCenter(coordsInt,toneDotSpacing);
#line 591
float3 finalColor = getDotBrightness(brightness,color,coordsInt,dotCenter,toneDotSpacing);
#line 593
for(int i=0;i<6;i++) {
float2 delta = 0;
if(i==0) {
delta.x -= toneDotSpacing;
} else if(i==1) {
delta.x += toneDotSpacing;
} else if(i==2 || i==3) {
delta.x -= 0.5*toneDotSpacing;
} else {
delta.x += 0.5*toneDotSpacing;
}
if(i==0 || i==1) {
} else if(i==2 || i==4) {
delta.y -= toneDotSpacing-1;
} else {
delta.y += toneDotSpacing-1;
}
#line 611
if(iToneMode>1) {
finalColor = max(finalColor,getDotBrightness(brightness,color,coordsInt,dotCenter+delta,toneDotSpacing));
#line 614
int2 lc = getLineColumn(dotCenter,toneDotSpacing);
int yOffset = isEvenLine(coordsInt,toneDotSpacing);
int dotIndex = (lc.y*1.5+lc.x)%3;
if(bToneRotateColors) dotIndex = (dotIndex+framecount%3)%3;
#line 619
if(iToneMode==3) {
if(dotIndex==0) {
finalColor *= float3(1,0,0);
} else if(dotIndex==1) {
finalColor *= float3(0,1,0);
} else if(dotIndex==2) {
finalColor *= float3(0,0,1);
}
#line 628
} else if(iToneMode==4) {
if(dotIndex==0) {
finalColor *= float3(0,1,1);
} else if(dotIndex==1) {
finalColor *= float3(1,0,1);
} else if(dotIndex==2) {
finalColor *= float3(1,1,0);
}
}
#line 639
} else {
finalColor = min(finalColor,getDotBrightness(brightness,color,coordsInt,dotCenter+delta,toneDotSpacing));
}
#line 643
}
#line 645
outPixel = float4(saturate(finalColor),1);
}
#line 648
void PS_Result(float4 vpos : SV_Position, in float2 coords : TEXCOORD0, out float4 outPixel : SV_Target)
{
float3 color = iToneMode>0 ? tex2Dlod(halftonesSampler,float4((coords).xy,0,0)).rgb : tex2Dlod(blurSampler,float4(coords,0.0,0.0)).rgb;
float3 refColor = color;
#line 653
if(bDepthBlackLine && iDepthBlackLineThickness>0) {
float depthLineMul = 1;
int maxDistance = iDepthBlackLineThickness*iDepthBlackLineThickness;
float depth = ReShade::GetLinearizedDepth(coords)*1000.0;
float3 normal = loadNormal(coords);
#line 659
int2 delta;
for(delta.x=-iDepthBlackLineThickness;depthLineMul>0 && delta.x<=iDepthBlackLineThickness;delta.x++) {
for(delta.y=-iDepthBlackLineThickness;depthLineMul>0 && delta.y<=iDepthBlackLineThickness;delta.y++) {
int d = dot(delta,delta);
if(d<=maxDistance) {
float2 searchCoords = coords+ReShade::GetPixelSize()*delta;
float searchDepth = ReShade::GetLinearizedDepth(searchCoords)*1000.0;
float3 searchNormal = loadNormal(searchCoords);
#line 668
if(depth/searchDepth<=fDepthBlackLineThreshold && (abs(normal.x-searchNormal.x)>0.1 || abs(normal.y-searchNormal.y)>0.1 || abs(normal.z-searchNormal.z)>0.1)) {
depthLineMul = 0;
}
}
}
}
color *= depthLineMul;
color += (1.0-depthLineMul)*cBlackLineColor;
}
#line 679
if(bColorBlackLine && iDepthBlackLineThickness>0) {
float lines = tex2D(linesSampler,coords).r;
color *= pow(max(lines,0.0),iDepthBlackLineThickness);
color += (1.0-lines)*cBlackLineColor;
}
#line 686
if(fBlackLineMultiply<1) {
color = lerp(refColor,color,fBlackLineMultiply);
}
#line 690
outPixel = float4(color,1.0);
#line 692
}
#line 694
void PS_Rescale(float4 vpos : SV_Position, in float2 coords : TEXCOORD0, out float4 outPixel : SV_Target)
{
if(2<=1) {
outPixel = tex2Dlod(scaledSampler,float4((coords).xy,0,0));
} else {
float2 delta;
float radius = ceil(2*0.5);
float2 pixelSize = ReShade::GetPixelSize()/float(2);
#line 703
float3 sum = 0;
float3 maxC = 0;
float count = 0;
#line 707
for(delta.x=-2;delta.x<=2;delta.x++) {
for(delta.x=-2;delta.x<=2;delta.x++) {
float2 currentCoords = coords+delta*pixelSize;
if(!inScreen(currentCoords)) continue;
float3 c = tex2Dlod(scaledSampler,float4((currentCoords).xy,0,0)).rgb;
count += 1;
sum += c;
maxC = max(maxC,c);
}
}
outPixel = float4(sum/count,1.0);
}
}
#line 723
technique DH_Anime_13 <
ui_label = "DH_Anime 1.3";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Input;
RenderTarget = normalTex;
RenderTarget1 = blurTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_LinePass;
RenderTarget = linesTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Halftone;
RenderTarget = halftonesTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Result;
RenderTarget = scaledTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_Rescale;
}
}
#line 759
}

