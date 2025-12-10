// TOTAL_RAY_LODS=3
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\ZN_GI.fx"
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
#line 9 "C:\Program Files\GShade\gshade-shaders\Shaders\ZN_GI.fx"
#line 23
uniform float FOV <
ui_type = "slider";
ui_min = 0.0;
ui_max = 110.0;
ui_label = "FOV";
ui_tooltip = "Adjust to match ingame FOV";
ui_category = "Depth Buffer Settings";
ui_step = 1;
> = 70;
#line 35
uniform float NearPlane <
ui_type = "slider";
ui_min = 0.05;
ui_max = 10.0;
ui_label = "Near Plane";
ui_tooltip = "Adjust min depth for depth buffer, increase slightly if dark lines are visible";
ui_category = "Depth Buffer Settings";
> = 0.7;
#line 45
uniform float Intensity <
ui_type = "slider";
ui_min = 0.01;
ui_max = 1.0;
ui_label = "Intensity";
ui_tooltip = "Intensity of the effect";
ui_category = "Display";
> = 0.25;
#line 54
uniform int BlendMode <
ui_type = "slider";
ui_min = 0;
ui_max = 1;
ui_label = "Blend Mode";
ui_tooltip = "Switch between hybrid and additive blending modes";
ui_category = "Display";
> = 0;
#line 63
uniform float AmbientNeg <
ui_type = "slider";
ui_min = 0;
ui_max = 0.5;
ui_label = "Ambient light offset";
ui_tooltip = "Removes ambient light before applying GI (Only applies to blend mode 1)";
ui_category = "Display";
> = 0.1;
#line 72
uniform float LightEx <
ui_type = "slider";
ui_min = 1.0;
ui_max = 2.2;
ui_label = "LightEx";
ui_tooltip = "Converts lightmap to linear, lower slightly if you see extra banding when enabling the effect";
ui_category = "Display";
> = 2.2;
#line 81
uniform float distMask <
ui_type = "slider";
ui_label = "Distance Mask";
ui_tooltip = "Prevents washing out of clouds, and reduces artifacts from fog";
ui_category = "Display";
> = 0.0;
#line 88
uniform bool addR <
ui_label = "Additive Casting";
ui_tooltip = "Stacks samples linearly as instead or resetting them\n"
"Increases ray range and significantly improves shading quality || Moderate Performance impact";
ui_category = "Sampling";
> = 0;
#line 95
uniform bool doDenoising <
ui_label = "Denoising";
ui_tooltip = "Runs a gaussian denoising pass || Moderate Performance impact";
ui_category = "Sampling";
> = 1;
#line 101
uniform int sLod <
ui_type = "slider";
ui_min = 0;
ui_max = 2;
ui_label = "Starting LOD";
ui_tooltip = "Changes the starting LOD value, increases sample range at the cose of fine details \n"
"Aliasing artifacts can be very noticable || Moderate Performance impact";
ui_category = "Sampling";
> = 0;
#line 112
uniform float LigM <
ui_type = "slider";
ui_min = 0;
ui_max = 1.0;
ui_label = "Brightness power";
ui_tooltip = "Exponent of light sources. Recommended to decrease when increasing 'Ray Range'|| No Performance impact";
ui_category = "Sampling";
> = 1.0;
#line 121
uniform float disD <
ui_type = "slider";
ui_min = 0;
ui_max = 2.0;
ui_label = "Distance Power";
ui_tooltip = "Modifies the laws of physics, 2 is physically accurate || No Performance impact";
ui_category = "Sampling";
> = 2.0;
#line 130
uniform float disM <
ui_type = "slider";
ui_min = 0;
ui_max = 1.0;
ui_label = "Distance Scale";
ui_tooltip = "Scale of the world distance calculations are made";
ui_category = "Sampling";
> = 0.25;
#line 139
uniform float sampR <
ui_type = "slider";
ui_min = 0;
ui_max = 20.0;
ui_label = "Ray Range";
ui_tooltip = "Increases GI range without detail loss, may create noise at higher levels || Low Performance impact";
ui_category = "Sampling";
> = 7.0;
#line 148
uniform bool debug <
ui_label = "Debug";
ui_tooltip = "Displays GI";
> = 0;
#line 157
texture GIBlueNoiseTex < source = "ZNbluenoise512.png"; >
{
Width  = 512.0;
Height = 512.0;
Format = RGBA8;
};
texture GINorTex{Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 1;};
texture GIBufTex{Width = 1920 / 2; Height = 1018 / 2; Format = R16; MipLevels = 7;};
texture GILumTex{Width = 1920 / 4; Height = 1018 / 4; Format = RGBA8; MipLevels = 6;};
texture GIHalfTex{Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 2;};
texture GIBlurTex1{Width = 1920; Height = 1018; Format = RGBA8; MipLevels = 2;};
#line 171
sampler NormalSam{Texture = GINorTex;};
sampler BufferSam{Texture = GIBufTex;};
sampler LightSam{Texture = GILumTex;};
sampler NoiseSam{Texture = GIBlueNoiseTex;};
sampler HalfSam{Texture = GIHalfTex;};
sampler BlurSam1{Texture = GIBlurTex1;};
#line 183
float4 LightMap(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float p = LightEx;
float3 te = tex2D(ReShade::BackBuffer, texcoord).rgb;
return float4(pow(te, p), 1.0);
}
#line 191
float LinearBuffer(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float f = 1000.0;
float n = NearPlane;
float depth = ReShade::GetLinearizedDepth(texcoord);
depth = lerp(n, f, depth);
return depth / (f - n);
}
#line 201
float4 NormalBuffer(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float2 uvd = float2(1920, 1018);
float vc =  ReShade::GetLinearizedDepth(texcoord);
#line 206
float vx;
float vxl = vc - ReShade::GetLinearizedDepth(texcoord + float2(-1, 0) / uvd);
float vxl2 = vc - ReShade::GetLinearizedDepth(texcoord + float2(-2, 0) / uvd);
float exlC = lerp(vxl2, vxl, 2.0);
#line 211
float vxr = vc - ReShade::GetLinearizedDepth(texcoord + float2(1, 0) / uvd);
float vxr2 = vc - ReShade::GetLinearizedDepth(texcoord + float2(2, 0) / uvd);
float exrC = lerp(vxr2, vxr, 2.0);
#line 215
if(abs(exlC - vc) > abs(exrC - vc)) {vx = -vxl;}
else {vx = vxr;}
#line 218
float vy;
float vyl = vc - ReShade::GetLinearizedDepth(texcoord + float2(0, -1) / uvd);
float vyl2 = vc - ReShade::GetLinearizedDepth(texcoord + float2(0, -2) / uvd);
float eylC = lerp(vyl2, vyl, 2.0);
#line 223
float vyr = vc - ReShade::GetLinearizedDepth(texcoord + float2(0, 1) / uvd);
float vyr2 = vc - ReShade::GetLinearizedDepth(texcoord + float2(0, 2) / uvd);
float eyrC = lerp(vyr2, vyr, 2.0);
#line 227
if(abs(eylC - vc) > abs(eyrC - vc)) {vy = -vyl;}
else {vy = vyr;}
#line 230
return float4(0.5 + 0.5 * normalize(float3(vx, vy, vc / 1000.0)), 1.0);
}
#line 237
float3 eyePos(float2 xy, float z, float2 pw)
{
float fn = 1000.0 - NearPlane;
float2 nxy = 2.0 * xy - 1.0;
float3 eyp = float3(nxy * pw * z, fn * z);
return eyp;
}
#line 245
float3 sampGI(float2 coord, float3 offset, float2 pw)
{
float2 res = float2(1920, 1018);
float fn = 1000.0 - NearPlane;
#line 250
float2 dir[8]; 
dir[0] = normalize(float2(-1, -1) + 1.0*offset.xy);
dir[1] = normalize(float2(-1, 0) + 1.0*offset.xz);
dir[2] = normalize(float2(-1, 1) + 1.0*offset.yx);
dir[3] = normalize(float2(0, -1) + 1.0*offset.yz);
dir[4] = normalize(float2(0, 1) + 1.0*offset.xy);
dir[5] = normalize(float2(1, -1) + 1.0*offset.xz);
dir[6] = normalize(float2(1, 0) + 1.0*offset.yx);
dir[7] = normalize(float2(1, 1) + 1.0*offset.yz);
#line 260
float rayS;
float3 ac;
float3 map;
#line 264
float trueDepth = ReShade::GetLinearizedDepth(coord);
if(trueDepth == 1.0) {return AmbientNeg;}
float3 surfN = normalize(1.0 - 2.0 * tex2D(NormalSam, coord).rgb);
#line 268
for(int i = 0; i < 8; i++)
{
#line 272
float depth = trueDepth;
float minDep = trueDepth;
float3 rayP = float3(coord, depth);
for(rayS = sLod; rayS <= (3 + sLod); rayS++)
{
#line 278
float ld = min(rayS - 1, 0);
float ll = min(rayS - 2, 0);
#line 281
float2 moDir = float2(dir[i].x, dir[i].y);
if(addR == 0) {rayP = float3(coord, depth);}
rayP += sampR * (offset.r + 1.5) * pow(2.0, rayS) * normalize(float3(moDir, 0)) / float3(res, 1.0);
#line 285
depth = tex2Dlod(BufferSam, float4(rayP.xy, ld, ld)).r;
minDep = min(minDep, depth);
#line 288
map = tex2Dlod(LightSam, float4(rayP.xy, ll, ll)).rgb;
map = -map / (map - 1.1);
map *= 1.0 + pow(distance(eyePos(rayP.xy, rayP.z, pw), 0.0), disD) / fn;
#line 293
float pd = 1.0 + disM * distance(eyePos(rayP.xy, rayP.z, pw), eyePos(coord, depth, pw));
map /= pow(pd, disD);
#line 296
float3 rayD = float3(coord, trueDepth) - rayP;
rayD = normalize(rayD);
#line 300
float3 amb = 0.5 + 0.5 * dot(surfN, -rayD);
#line 302
float comp = ceil(depth - minDep);
ac += amb * map * comp;
#line 305
}
#line 307
}
ac /= 8 * 3;
ac =pow(ac,  LigM);
#line 311
return pow((ac * sqrt(3)), 1.0 / 2.2);
}
#line 318
float3 Denoise(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
if(doDenoising == 0) {return tex2D(HalfSam, texcoord).rgb;}
int gaussianK[25] =
{1,4,7,4,1,
4,16,26,16,4,
7,26,41,26,7,
4,16,26,16,4,
1,4,7,4,1};
#line 328
float fn = 1000.0 - NearPlane;
float2 res = float2(1920, 1018);
float3 col;
float gd = ReShade::GetLinearizedDepth(texcoord);
for(int i = 0; i < 5; i++)
{
for(int ii = 0; ii < 5; ii++)
{
int s = (i) + (ii);
float g = float(gaussianK[s]);
float2 c = ((texcoord * res)-3.0 + float2(i, ii)) / res;
float d = ReShade::GetLinearizedDepth(c);
float3 sam = g * tex2D(HalfSam, c).rgb;
sam /= 1.0 + disM * pow(distance(eyePos(c, d, 1000.0), eyePos(texcoord, gd, 1000.0)), disD) / fn;
col += sam;
}
}
return 1.5 * col / 273.0;
}
#line 350
float4 GlobalPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float2 aspectPos= float2(1920, 1018);
float3 noise = tex2D(NoiseSam, frac(texcoord * (aspectPos / 512))).rgb;
float2 PW = 2.0 * tan(FOV * 0.00875) * (1000.0 - NearPlane); 
PW.y *= aspectPos.x / aspectPos.y;
#line 357
float3 input = sampGI(texcoord, (0.5 - noise), PW);
return float4(saturate(input), 1.0);
}
#line 361
float3 ZN_Stylize_FXmain(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
float2 bxy= float2(1920, 1018);
#line 365
float3 input = tex2D(ReShade::BackBuffer, texcoord).rgb;
float3 noise = tex2D(NoiseSam, frac(0.5 + texcoord * (bxy / 512))).rgb;
float3 light = tex2D(LightSam, texcoord).rgb;
float depth = tex2D(BufferSam, texcoord).r;
#line 370
float lightG = light.r * 0.2126 + light.g * 0.7152 + light.b * 0.0722;
#line 372
float3 GI = tex2Dlod(BlurSam1, float4(texcoord, 1,1)).rgb;
GI *= 1.0 - pow(depth, 1.0 - distMask);
#line 375
if(BlendMode == 0){
input = input * abs(debug - 1.0)
+ pow(Intensity, abs(debug - 1.0))
* (clamp(GI - noise * 0.05 - lightG, 0.0, 1.0)
- AmbientNeg * abs(debug - 1.0));
}
#line 382
else{
input = abs(debug - 1.0) * input + pow(Intensity, abs(debug - 1.0)) * GI;
}
return saturate(input);
}
#line 388
technique ZN_SDIL
<
ui_label = "ZN_SDIL";
ui_tooltip =
"             Zentient - Screen Space Directional Indirect Lighting             \n"
"\n"
"\n"
"A relatively lightweight Screen Space Global Illumination implementation that samples LODS\n"
"\n"
"\n";
>
{
pass
{
VertexShader = PostProcessVS;
PixelShader = LightMap;
RenderTarget = GILumTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = LinearBuffer;
RenderTarget = GIBufTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = NormalBuffer;
RenderTarget = GINorTex;
}
#line 419
pass
{
VertexShader = PostProcessVS;
PixelShader = GlobalPass;
RenderTarget = GIHalfTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = Denoise;
RenderTarget = GIBlurTex1;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = ZN_Stylize_FXmain;
}
}

