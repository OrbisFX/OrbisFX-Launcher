#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\FSR1_2X.fx"
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
#line 35 "C:\Program Files\GShade\gshade-shaders\Shaders\FSR1_2X.fx"
#line 36
uniform float sharpness <
ui_min = 0.0;
ui_max = 2.0;
ui_type = "slider";
> = 1.75;
#line 56
float AF1_x(float a){return float(a);}
float2 AF2_x(float a){return float2(a,a);}
float3 AF3_x(float a){return float3(a,a,a);}
float4 AF4_x(float a){return float4(a,a,a,a);}
#line 64
uint AU1_x(uint a){return uint(a);}
#line 66
float AMax3F1(float x,float y,float z){return max(x,max(y,z));}
float3 AMax3F3(float3 x,float3 y,float3 z){return max(x,max(y,z));}
float AMin3F1(float x,float y,float z){return min(x,min(y,z));}
float3 AMin3F3(float3 x,float3 y,float3 z){return min(x,min(y,z));}
float ARcpF1(float x){return rcp(x);}
float ASatF1(float x){return saturate(x);}
float3 ASatF3(float3 x){return saturate(x);}
uint ABfe(uint src,uint off,uint bits){uint mask=(1u<<bits)-1;return (src>>off)&mask;}
uint ABfiM(uint src,uint ins,uint bits){uint mask=(1u<<bits)-1;return (ins&mask)|(src&(~mask));}
uint2 ARmp8x8(uint a){return uint2(ABfe(a,1u,3u),ABfiM(ABfe(a,3u,3u),a,1u));}
float APrxLoRcpF1(float a){return asfloat(uint(AU1_x(uint(0x7ef07ebb))-asuint(float(a))));}
float APrxMedRcpF1(float a){float b=asfloat(uint(AU1_x(uint(0x7ef19fff))-asuint(float(a))));return b*(-b*a+AF1_x(float(2.0)));}
float APrxLoRsqF1(float a){return asfloat(uint(AU1_x(uint(0x5f347d74))-(asuint(float(a))>>AU1_x(uint(1)))));}
#line 82
texture2D texColorBuffer : COLOR;
sampler2D samplerColor
{
Texture = texColorBuffer;
};
#line 88
texture2D texFSR2x
{
Width   = 2 * 1920;
Height  = 2 * 1018;
Format  = RGBA16;
};
#line 95
sampler2D samplerFSR2x
{
Texture = texFSR2x;
};
#line 100
storage2D storageFSR2x
{
Texture = texFSR2x;
};
#line 105
texture2D texFSR1L
{
Width   = 1920;
Height  = 1018;
Format  = RGBA16;
};
#line 112
sampler2D samplerFSR1L
{
Texture = texFSR1L;
};
#line 117
storage2D storageFSR1L
{
Texture = texFSR1L;
};
#line 122
texture2D texFSRC
{
Width   = 1920;
Height  = 1018;
Format  = RGBA16;
};
#line 129
sampler2D samplerFSRC
{
Texture = texFSRC;
};
#line 134
storage2D storageFSRC
{
Texture = texFSRC;
};
#line 139
void FsrEasuSet(inout float2 dir, inout float len, float2 pp,
bool biS, bool biT, bool biU, bool biV,
float lA, float lB, float lC, float lD, float lE)
{
float w      = AF1_x(float(0.0));
if (biS) w = (AF1_x(float(1.0)) - pp.x) * (AF1_x(float(1.0)) - pp.y);
if (biT) w =              pp.x  * (AF1_x(float(1.0)) - pp.y);
if (biU) w = (AF1_x(float(1.0)) - pp.x) *              pp.y;
if (biV) w =              pp.x  *              pp.y;
float dc     = lD - lC;
float cb     = lC - lB;
float lenX   = max(abs(dc), abs(cb));
lenX       = APrxLoRcpF1(lenX);
float dirX   = lD - lB;
dir.x     += dirX * w;
lenX       = ASatF1(abs(dirX) * lenX);
lenX      *= lenX;
len       += lenX * w;
float ec     = lE - lC;
float ca     = lC - lA;
float lenY   = max(abs(ec), abs(ca));
lenY       = APrxLoRcpF1(lenY);
float dirY   = lE - lA;
dir.y     += dirY * w;
lenY       = ASatF1(abs(dirY) * lenY);
lenY      *= lenY;
len       += lenY * w;
}
#line 168
void FsrEasuTap(inout float3 aC, inout float aW, float2 off, float2 dir, float2 len, float lob,
float clp, float3 c)
{
float2 v;
v.x    = (off.x * ( dir.x)) + (off.y * dir.y);
v.y    = (off.x * (-dir.y)) + (off.y * dir.x);
v     *= len;
float d2 = v.x * v.x + v.y * v.y;
d2     = min(d2, clp);
float wB = AF1_x(float(2.0 / 5.0)) * d2 + AF1_x(float(-1.0));
float wA = lob * d2 + AF1_x(float(-1.0));
wB    *= wB;
wA    *= wA;
wB     = AF1_x(float(25.0 / 16.0)) * wB + AF1_x(float(-(25.0 / 16.0 - 1.0)));
float w  = wB * wA;
aC    += c * w;
aW    += w;
}
#line 187
void FsrEasu(out float3 pix, uint2 ip)
{
float4 con0, con1, con2, con3;
con0[0]     = 1920 * ARcpF1((2 * 1920));
con0[1]     = 1018 * ARcpF1((2 * 1018));
con0[2]     = AF1_x(float(0.5)) * 1920 * ARcpF1((2 * 1920)) - AF1_x(float(0.5));
con0[3]     = AF1_x(float(0.5)) * 1018 * ARcpF1((2 * 1018)) - AF1_x(float(0.5));
con1[0]     = ARcpF1(1920);
con1[1]     = ARcpF1(1018);
con1[2]     = AF1_x(float(1.0)) * ARcpF1(1920);
con1[3]     = AF1_x(float(-1.0)) * ARcpF1(1018);
con2[0]     = AF1_x(float(-1.0)) * ARcpF1(1920);
con2[1]     = AF1_x(float(2.0)) * ARcpF1(1018);
con2[2]     = AF1_x(float(1.0)) * ARcpF1(1920);
con2[3]     = AF1_x(float(2.0)) * ARcpF1(1018);
con3[0]     = AF1_x(float(0.0)) * ARcpF1(1920);
con3[1]     = AF1_x(float(4.0)) * ARcpF1(1018);
float2 pp      = float2(ip) * con0.xy + con0.zw;
float2 fp      = floor(pp);
pp         -= fp;
float2 p0      = fp * con1.xy + con1.zw;
float2 p1      = p0 + con2.xy;
float2 p2      = p0 + con2.zw;
float2 p3      = p0 + con3.xy;
float4 bczzR   = tex2DgatherR(samplerColor, p0);
float4 bczzG   = tex2DgatherG(samplerColor, p0);
float4 bczzB   = tex2DgatherB(samplerColor, p0);
float4 ijfeR   = tex2DgatherR(samplerColor, p1);
float4 ijfeG   = tex2DgatherG(samplerColor, p1);
float4 ijfeB   = tex2DgatherB(samplerColor, p1);
float4 klhgR   = tex2DgatherR(samplerColor, p2);
float4 klhgG   = tex2DgatherG(samplerColor, p2);
float4 klhgB   = tex2DgatherB(samplerColor, p2);
float4 zzonR   = tex2DgatherR(samplerColor, p3);
float4 zzonG   = tex2DgatherG(samplerColor, p3);
float4 zzonB   = tex2DgatherB(samplerColor, p3);
float4 bczzL   = bczzB * AF4_x(float(0.5)) + (bczzR * AF4_x(float(0.5)) + bczzG);
float4 ijfeL   = ijfeB * AF4_x(float(0.5)) + (ijfeR * AF4_x(float(0.5)) + ijfeG);
float4 klhgL   = klhgB * AF4_x(float(0.5)) + (klhgR * AF4_x(float(0.5)) + klhgG);
float4 zzonL   = zzonB * AF4_x(float(0.5)) + (zzonR * AF4_x(float(0.5)) + zzonG);
float bL      = bczzL.x;
float cL      = bczzL.y;
float iL      = ijfeL.x;
float jL      = ijfeL.y;
float fL      = ijfeL.z;
float eL      = ijfeL.w;
float kL      = klhgL.x;
float lL      = klhgL.y;
float hL      = klhgL.z;
float gL      = klhgL.w;
float oL      = zzonL.z;
float nL      = zzonL.w;
float2 dir     = AF2_x(float(0.0));
float len     = AF1_x(float(0.0));
FsrEasuSet(dir, len, pp, true,  false, false, false, bL, eL, fL, gL, jL);
FsrEasuSet(dir, len, pp, false, true,  false, false, cL, fL, gL, hL, kL);
FsrEasuSet(dir, len, pp, false, false, true,  false, fL, iL, jL, kL, nL);
FsrEasuSet(dir, len, pp, false, false, false, true,  gL, jL, kL, lL, oL);
float2 dir2    = dir * dir;
float dirR    = dir2.x + dir2.y;
bool zro     = dirR<AF1_x(float(1.0 / 32768.0));
dirR        = APrxLoRsqF1(dirR);
dirR        = zro ? AF1_x(float(1.0)) : dirR;
dir.x       = zro ? AF1_x(float(1.0)) : dir.x;
dir        *= AF2_x(float(dirR));
len         = len * AF1_x(float(0.5));
len        *= len;
float stretch = (dir.x * dir.x + dir.y * dir.y) * APrxLoRcpF1(max(abs(dir.x), abs(dir.y)));
float2 len2    = float2(AF1_x(float(1.0)) + (stretch - AF1_x(float(1.0))) * len, AF1_x(float(1.0)) + AF1_x(float(-0.5)) * len);
float lob     = AF1_x(float(0.5)) + AF1_x(float((1.0 / 4.0 - 0.04) - 0.5)) * len;
float clp     = APrxLoRcpF1(lob);
float3 min4    = min(AMin3F3(float3(ijfeR.z, ijfeG.z, ijfeB.z), float3(klhgR.w, klhgG.w, klhgB.w),
float3(ijfeR.y, ijfeG.y, ijfeB.y)), float3(klhgR.x, klhgG.x, klhgB.x));
float3 max4    = max(AMax3F3(float3(ijfeR.z, ijfeG.z, ijfeB.z), float3(klhgR.w, klhgG.w, klhgB.w),
float3(ijfeR.y, ijfeG.y, ijfeB.y)), float3(klhgR.x, klhgG.x, klhgB.x));
float3 aC      = AF3_x(float(0.0));
float aW      = AF1_x(float(0.0));
FsrEasuTap(aC, aW, float2( 0.0,-1.0) - pp, dir, len2, lob, clp, float3(bczzR.x, bczzG.x, bczzB.x));
FsrEasuTap(aC, aW, float2( 1.0,-1.0) - pp, dir, len2, lob, clp, float3(bczzR.y, bczzG.y, bczzB.y));
FsrEasuTap(aC, aW, float2(-1.0, 1.0) - pp, dir, len2, lob, clp, float3(ijfeR.x, ijfeG.x, ijfeB.x));
FsrEasuTap(aC, aW, float2( 0.0, 1.0) - pp, dir, len2, lob, clp, float3(ijfeR.y, ijfeG.y, ijfeB.y));
FsrEasuTap(aC, aW, float2( 0.0, 0.0) - pp, dir, len2, lob, clp, float3(ijfeR.z, ijfeG.z, ijfeB.z));
FsrEasuTap(aC, aW, float2(-1.0, 0.0) - pp, dir, len2, lob, clp, float3(ijfeR.w, ijfeG.w, ijfeB.w));
FsrEasuTap(aC, aW, float2( 1.0, 1.0) - pp, dir, len2, lob, clp, float3(klhgR.x, klhgG.x, klhgB.x));
FsrEasuTap(aC, aW, float2( 2.0, 1.0) - pp, dir, len2, lob, clp, float3(klhgR.y, klhgG.y, klhgB.y));
FsrEasuTap(aC, aW, float2( 2.0, 0.0) - pp, dir, len2, lob, clp, float3(klhgR.z, klhgG.z, klhgB.z));
FsrEasuTap(aC, aW, float2( 1.0, 0.0) - pp, dir, len2, lob, clp, float3(klhgR.w, klhgG.w, klhgB.w));
FsrEasuTap(aC, aW, float2( 1.0, 2.0) - pp, dir, len2, lob, clp, float3(zzonR.z, zzonG.z, zzonB.z));
FsrEasuTap(aC, aW, float2( 0.0, 2.0) - pp, dir, len2, lob, clp, float3(zzonR.w, zzonG.w, zzonB.w));
pix         = min(max4, max(min4, aC * AF3_x(float(ARcpF1(aW)))));
}
#line 279
void mainCS(uint3 LocalThreadId : SV_GroupThreadID, uint3 WorkGroupId : SV_GroupID)
{
uint2 gxy = ARmp8x8(LocalThreadId.x) + uint2(WorkGroupId.x << 3u, WorkGroupId.y << 3u);
float3 c;
FsrEasu(c, gxy);
tex2Dstore(storageFSR2x, gxy, float4(c, 1.0));
}
#line 287
void dlFilter(out float3 pix, uint2 ip)
{
ip *= 2;
float3 a = tex2Dfetch(samplerFSR2x, ip).rgb;
ip.x++;
float3 b = tex2Dfetch(samplerFSR2x, ip).rgb;
ip.y++;
float3 c = tex2Dfetch(samplerFSR2x, ip).rgb;
ip.x--;
float3 d = tex2Dfetch(samplerFSR2x, ip).rgb;
pix      = (a+b+c+d)*0.25;
pix      = (pix > 0.04045) ? pow((pix + 0.055) * (1.0 / 1.055), 2.4) : (pix * (1.0 / 12.92));
}
#line 301
void main2CS(uint3 LocalThreadId : SV_GroupThreadID, uint3 WorkGroupId : SV_GroupID)
{
uint2 gxy = ARmp8x8(LocalThreadId.x) + uint2(WorkGroupId.x << 4u, WorkGroupId.y << 4u);
#line 305
float3 c;
dlFilter(c, gxy);
tex2Dstore(storageFSR1L, gxy, float4(c, 1.0));
gxy.x  += 8u;
#line 310
dlFilter(c, gxy);
tex2Dstore(storageFSR1L, gxy, float4(c, 1.0));
gxy.y  += 8u;
#line 314
dlFilter(c, gxy);
tex2Dstore(storageFSR1L, gxy, float4(c, 1.0));
gxy.x  -= 8u;
#line 318
dlFilter(c, gxy);
tex2Dstore(storageFSR1L, gxy, float4(c, 1.0));
}
#line 322
void FsrRcas(out float pixR, out float pixG, out float pixB, uint2 ip)
{
int2 sp     = int2(ip);
float3 b       = tex2Dfetch(samplerFSR1L, sp + int2( 0,-1)).rgb;
float3 d       = tex2Dfetch(samplerFSR1L, sp + int2(-1, 0)).rgb;
float3 e       = tex2Dfetch(samplerFSR1L, sp).rgb;
float3 f       = tex2Dfetch(samplerFSR1L, sp + int2( 1, 0)).rgb;
float3 h       = tex2Dfetch(samplerFSR1L, sp + int2( 0, 1)).rgb;
float bR      = b.r;
float bG      = b.g;
float bB      = b.b;
float dR      = d.r;
float dG      = d.g;
float dB      = d.b;
float eR      = e.r;
float eG      = e.g;
float eB      = e.b;
float fR      = f.r;
float fG      = f.g;
float fB      = f.b;
float hR      = h.r;
float hG      = h.g;
float hB      = h.b;
float bL      = bB * AF1_x(float(0.5)) + (bR * AF1_x(float(0.5)) + bG);
float dL      = dB * AF1_x(float(0.5)) + (dR * AF1_x(float(0.5)) + dG);
float eL      = eB * AF1_x(float(0.5)) + (eR * AF1_x(float(0.5)) + eG);
float fL      = fB * AF1_x(float(0.5)) + (fR * AF1_x(float(0.5)) + fG);
float hL      = hB * AF1_x(float(0.5)) + (hR * AF1_x(float(0.5)) + hG);
#line 354
float mn4R    = min(AMin3F1(bR, dR, fR), hR);
float mn4G    = min(AMin3F1(bG, dG, fG), hG);
float mn4B    = min(AMin3F1(bB, dB, fB), hB);
float mx4R    = max(AMax3F1(bR, dR, fR), hR);
float mx4G    = max(AMax3F1(bG, dG, fG), hG);
float mx4B    = max(AMax3F1(bB, dB, fB), hB);
float2 peakC   = float2(1.0, -1.0 * 4.0);
float hitMinR = mn4R * ARcpF1(AF1_x(float(4.0)) * mx4R);
float hitMinG = mn4G * ARcpF1(AF1_x(float(4.0)) * mx4G);
float hitMinB = mn4B * ARcpF1(AF1_x(float(4.0)) * mx4B);
float hitMaxR = (peakC.x - mx4R) * ARcpF1(AF1_x(float(4.0)) * mn4R + peakC.y);
float hitMaxG = (peakC.x - mx4G) * ARcpF1(AF1_x(float(4.0)) * mn4G + peakC.y);
float hitMaxB = (peakC.x - mx4B) * ARcpF1(AF1_x(float(4.0)) * mn4B + peakC.y);
float lobeR   = max(-hitMinR, hitMaxR);
float lobeG   = max(-hitMinG, hitMaxG);
float lobeB   = max(-hitMinB, hitMaxB);
float lobe    = max(AF1_x(float(-(0.25-(1.0/16.0)))),
min(AMax3F1(lobeR, lobeG, lobeB), AF1_x(float(0.0)))) * exp2(float(-(2.0 - sharpness)));
#line 373
float rcpL    = APrxMedRcpF1(AF1_x(float(4.0)) * lobe + AF1_x(float(1.0)));
pixR        = (lobe * bR + lobe * dR + lobe * hR + lobe * fR + eR) * rcpL;
pixG        = (lobe * bG + lobe * dG + lobe * hG + lobe * fG + eG) * rcpL;
pixB        = (lobe * bB + lobe * dB + lobe * hB + lobe * fB + eB) * rcpL;
}
#line 379
void main3CS(uint3 LocalThreadId : SV_GroupThreadID, uint3 WorkGroupId : SV_GroupID)
{
uint2 gxy = ARmp8x8(LocalThreadId.x) + uint2(WorkGroupId.x << 3u, WorkGroupId.y << 3u);
float3 c;
FsrRcas(c.r, c.g, c.b, gxy);
c       = (c > 0.0031308) ? (1.055 * pow(c, 1.0 / 2.4) - 0.055) : (12.92 * c);
tex2Dstore(storageFSRC, gxy, float4(c, 1.0));
}
#line 388
float4 copyPS(float4 vpos : SV_Position) : SV_Target
{
return tex2Dfetch(samplerFSRC, vpos.xy);
}
#line 393
technique FSR1_2X < ui_label = "FSR 1.0 2X"; ui_tooltip = "Fake supersampling using AMD's FSR 1.0 algorithm."; >
{
pass
{
ComputeShader = mainCS< 64, 1 >;
DispatchSizeX = (2 * 1920  + 7) / 8;
DispatchSizeY = (2 * 1018 + 7) / 8;
}
#line 402
pass
{
ComputeShader = main2CS< 64, 1 >;
DispatchSizeX = (1920  + 15) / 16;
DispatchSizeY = (1018 + 15) / 16;
}
#line 409
pass
{
ComputeShader = main3CS< 64, 1 >;
DispatchSizeX = (1920  + 7) / 8;
DispatchSizeY = (1018 + 7) / 8;
}
#line 416
pass
{
VertexShader  = PostProcessVS;
PixelShader   = copyPS;
}
}

