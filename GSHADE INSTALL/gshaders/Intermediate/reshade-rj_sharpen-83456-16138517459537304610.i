// OVERRIDE_COLOR_SPACE=0
// HDR_WHITELEVEL=203
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\rj_sharpen.fx"
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
#line 59 "C:\Program Files\GShade\gshade-shaders\Shaders\rj_sharpen.fx"
#line 60
namespace rj_sharpen {
#line 66
static const bool fast_color_space_conversion=true;
#line 69
static const float max_sharp_diff = 0.1;
#line 107
uniform float sharp_strength <
ui_type = "slider";
ui_category = "rj_sharpen";
ui_min = 0; ui_max = 2; ui_step = .05;
ui_label = "Sharpen strength";
> = 0.75;
#line 114
uniform bool edge_detect_sharpen <
ui_category = "rj_sharpen";
ui_label = "Sharpen jagged edges less";
ui_tooltip = "If enabled, the sharpen effect is reduced on jagged edges. \n\nIf this is disabled the image will be a bit sharper. However, without this option sharpenning can partially reintroduce jaggies that had been smoothed by anti-aliasing.";
ui_type = "radio";
> = true;
#line 122
uniform int big_sharpen <
ui_category = "rj_sharpen";
ui_type = "combo";
ui_label = "Kernel size";
ui_items = "3x3\0"
"5x5\0";
ui_tooltip = "Selecting 5x5 makes the effect bigger but may be less accurate for fine details. \n\n5x5 mode only actually samples 17 of the 25 pixels. 5x5 is just as fast as 3x3, but might be lower quality than competing algorithms with 5x5 kernels";
> = 0;
#line 132
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
texcoord.x = (id == 2) ? 2.0 : 0.0;
texcoord.y = (id == 1) ? 2.0 : 0.0;
position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 146
float3 sRGBtoLinearAccurate(float3 r) {
return (r<=.04045) ? (r/12.92) : pow(abs(r+.055)/1.055, 2.4);
}
#line 150
float3 sRGBtoLinearFastApproximation(float3 r) {
#line 152
return max(r/12.92, r*r);
}
#line 155
float3 sRGBtoLinear(float3 r) {
if(fast_color_space_conversion==1) r = sRGBtoLinearFastApproximation(r);
else if(fast_color_space_conversion==0) r = sRGBtoLinearAccurate(r);
return r;
}
#line 161
float3 linearToSRGBAccurate(float3 r) {
return (r<=.0031308) ? (r*12.92) : (1.055*pow(abs(r), 1.0/2.4) - .055);
}
#line 165
float3 linearToSRGBFastApproximation(float3 r) {
#line 167
return min(r*12.92, sqrt(r));
}
#line 171
float3 linearToSRGB(float3 r) {
if(fast_color_space_conversion==1) r = linearToSRGBFastApproximation(r);
else if(fast_color_space_conversion==0) r = linearToSRGBAccurate(r);
#line 175
return r;
}
#line 179
float3 PQtoLinearAccurate(float3 r) {
#line 181
const float m1 = 1305.0/8192.0;
const float m2 = 2523.0/32.0;
const float c1 = 107.0/128.0;
const float c2 = 2413.0/128.0;
const float c3 = 2392.0/128.0;
#line 187
float3 powr = pow(max(r,0),1.0/m2);
r = pow(max( max(powr-c1, 0) / ( c2 - c3*powr ), 0) , 1.0/m1);
#line 190
return r * 10000.0/203;	
}
#line 193
float3 PQtoLinearFastApproximation(float3 r) {
#line 196
const float3 square = r*r;
const float3 quad = square*square;
const float3 oct = quad*quad;
r= max(max(square/340.0, quad/6.0), oct);
#line 201
return r * 10000.0/203;	
}
#line 204
float3 PQtoLinear(float3 r) {
if(fast_color_space_conversion) r = PQtoLinearFastApproximation(r);
else r = PQtoLinearAccurate(r);
return r;
}
#line 210
float3 linearToPQAccurate(float3 r) {
#line 212
const float m1 = 1305.0/8192.0;
const float m2 = 2523.0/32.0;
const float c1 = 107.0/128.0;
const float c2 = 2413.0/128.0;
const float c3 = 2392.0/128.0;
#line 219
r = r*(203/10000.0);
#line 222
const float3 powr = pow(max(r,0),m1);
r = pow(max( ( c1 + c2*powr ) / ( 1 + c3*powr ), 0 ), m2);
return r;
}
#line 227
float3 linearToPQFastApproximation(float3 r) {
#line 232
r = r*(203/10000.0);
#line 234
const float3 squareroot = sqrt(r);
const float3 quadroot = sqrt(squareroot);
const float3 octroot = sqrt(quadroot);
r = min(octroot, min(sqrt(sqrt(6.0))*quadroot, sqrt(340.0)*squareroot ) );
return r;
}
#line 241
float3 linearToPQ(float3 r) {
if(fast_color_space_conversion) r = linearToPQFastApproximation(r);
else r = linearToPQAccurate(r);
return r;
}
#line 250
float3 linearToHLG(float3 r) {
r = r*203/1000;
const float a = 0.17883277;
const float b = 0.28466892; 
const float c = 0.55991073; 
const float3 s=sqrt(3*r);
return (s<.5) ? s : ( log(12*r - b)*a+c);
}
#line 259
float3 HLGtoLinear(float3 r) {
const float a = 0.17883277;
const float b = 0.28466892; 
const float c = 0.55991073; 
r = (r<.5) ? r*r/3.0 : ( ( exp( (r - c)/a) + b) /12.0);
return r * 1000/203;
#line 266
}
#line 269
float3 toLinearColorspace(float3 r) {
if(1 == 2) r = r*(80.0/203);
else if(1 == 3) r = PQtoLinear(r);
else if(1 == 4) r = HLGtoLinear(r);
else r= sRGBtoLinear(r);
#line 275
return r;
}
#line 278
float3 toOutputColorspace(float3 r) {
if(1 == 2) r=r*(203/80.0); 
else if(1 == 3) r = linearToPQ(r);
else if(1 == 4) r = linearToHLG(r);
else r= linearToSRGB(r);
#line 284
return r;
}
#line 287
float getMaxColour()
{
float m = 1;
if(1>=2) m = 10000.0/203;
if(1==4) m = 1000.0/203;
return m;
}
#line 300
sampler2D samplerColor
{
#line 303
Texture = ReShade::BackBufferTex;
#line 307
SRGBTexture = true;
#line 309
};
#line 312
float4 getBackBufferLinear(float2 texcoord) {
#line 314
float4 c = tex2D( samplerColor, texcoord);
c.rgb = toLinearColorspace(c.rgb);
return c;
}
#line 321
float3 rj_sharpen_PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
#line 324
static const float3 luma = float3(0.2126, 0.7152, 0.0722);
#line 327
float3 c = getBackBufferLinear(texcoord).rgb;
#line 330
const float offset = big_sharpen ? 1.4 : .5;
const float3 ne = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*float2(offset,offset)).rgb;
const float3 sw = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*float2(-offset,-offset)).rgb;
const float3 se = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*float2(offset,-offset)).rgb;
const float3 nw = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*float2(-offset,offset)).rgb;
#line 337
const float3 smoothed = ((ne+nw)+(se+sw))*.25;
#line 340
const float dy = dot(luma,abs((ne+nw)-(se+sw)));
const float dx = dot(luma,abs((ne+se)-(nw+sw)));
const bool horiz =  dy > dx;
#line 346
float3 n2=horiz ? ne+nw : ne+se;
float3 s2=horiz ? se+sw : nw+sw;
if(big_sharpen) {
n2*=.5;
s2*=.5;
}
else
{
n2-=c;
s2-=c;
}
#line 360
float ratio=0;
if(edge_detect_sharpen) {
#line 363
const float dist = 3.5;
const float2 wwpos = horiz ? float2(-dist, 0) : float2(0, +dist) ;
const float2 eepos = horiz ? float2(+dist, 0) : float2(0, -dist) ;
#line 367
const float3 ww = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*wwpos).rgb;
const float3 ee = getBackBufferLinear( texcoord + float2((1.0 / 1920), (1.0 / 1018))*eepos).rgb;
#line 376
const float3 d1 = abs((ww-n2)-(ee-s2));
const float3 d2 = abs((ee-n2)-(ww-s2));
#line 380
const float fxaa_bias = 0.020;
#line 384
const float3 total_diff = (d1+d2) + .00004;
const float3 max_diff = max(d1,d2) + .00001 - fxaa_bias*sqrt(smoothed);
#line 388
const float score = dot(luma,(max_diff/total_diff)) ;
#line 392
ratio = max( 2*score-1, 0);
}
#line 398
float3 sharp_diff = 2*c+(ne+nw+se+sw) - 3*(max(max(ne,nw),max(se,sw)) + min(min(ne,nw),min(se,sw)));
#line 401
sharp_diff = dot(luma,sharp_diff);
#line 404
float3 max_sharp=min(smoothed,c);
#line 407
max_sharp = min(max_sharp,getMaxColour()-max(smoothed,c));
#line 411
max_sharp = clamp(max_sharp, 0.00001, max_sharp_diff );
#line 414
sharp_diff = sharp_diff / ( rcp(sharp_strength) +abs(sharp_diff)/(max_sharp));
#line 417
if(edge_detect_sharpen) sharp_diff *= (1-ratio);
#line 420
c+=sharp_diff;
#line 422
c = toOutputColorspace(c);
#line 424
return c;
}
#line 428
technique rj_sharpen
{
pass rj_sharpen
{
VertexShader = PostProcessVS;
PixelShader = rj_sharpen_PS;
#line 439
SRGBWriteEnable = true;
#line 441
}
#line 443
}
#line 449
}

