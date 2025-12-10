#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\xBRv4.fx"
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
#line 36 "C:\Program Files\GShade\gshade-shaders\Shaders\xBRv4.fx"
#line 37
uniform float dilationAmount <
ui_type = "drag";
ui_min = 0.0; ui_max = 2.0;
ui_label = "Dilation amount";
ui_tooltip = "Stretches the image itself";
> = 0.25;
#line 44
uniform int xBRtype <
ui_type = "combo";
ui_label = "xBR type";
ui_items = "type A - round\0type B: semi-round\0type C: semi-square\0type D: square\0";
ui_tooltip = "Changes the edge type.";
> = 2;
#line 53
static const precise float XBR_SCALE = 4096.0;
static const float coef = 2.0;
static const float4 eq_threshold = float4(15.0, 15.0, 15.0, 15.0);
static const float3 rgbw = float3(14.352, 28.176, 5.472);
static const float3 dt = float3(1.0,1.0,1.0);
#line 59
bool4 greaterThanEqual(float4 A, float4 B){
return bool4(A.x >= B.x, A.y >= B.y, A.z >= B.z, A.w >= B.w);
}
#line 63
bool4 notEqual(float4 A, float4 B){
return bool4(A.x != B.x, A.y != B.y, A.z != B.z, A.w != B.w);
}
#line 67
bool4 lessThanEqual(float4 A, float4 B){
return bool4(A.x <= B.x, A.y <= B.y, A.z <= B.z, A.w <= B.w);
}
#line 71
bool4 lessThan(float4 A, float4 B){
return bool4(A.x < B.x, A.y < B.y, A.z < B.z, A.w < B.w);
}
#line 75
float4 noteq(float4 A, float4 B)
{
return float4(notEqual(A, B));
}
#line 80
float4 not(float4 A)
{
return float4(1.0, 1.0, 1.0, 1.0)-A;
}
#line 85
float4 df(float4 A, float4 B)
{
return abs(A-B);
}
#line 90
float4 eq(float4 A, float4 B)
{
return float4(lessThan(df(A, B),eq_threshold));
}
#line 95
float4 weighted_distance(float4 a, float4 b, float4 c, float4 d, float4 e, float4 f, float4 g, float4 h)
{
return (df(a,b) + df(a,c) + df(d,e) + df(d,f) + 4.0*df(g,h));
}
#line 100
float3 xBRv4(float4 position : SV_Position, float2 tex : TEXCOORD0) : SV_Target
{
const float2 OGLSize = float2(ReShade::GetScreenSize().x * 0.25, ReShade::GetScreenSize().y * 0.25);
const float2 OGLInvSize = float2(1.0/OGLSize.x, 1.0/OGLSize.y);
#line 105
const float2 dx         = float2( OGLInvSize.x, 0.0);
const float2 dy         = float2( 0.0, OGLInvSize.y );
#line 108
const float2 fp  = frac(tex*OGLSize);
const float2 TexCoord_0 = tex-fp*OGLInvSize + 0.5*OGLInvSize;
#line 111
float4 edr, edr_left, edr_up;                     
float4 interp_restriction_lv1, interp_restriction_lv2_left, interp_restriction_lv2_up;
float4 nc30, nc60, nc45;                          
float4 fx, fx_left, fx_up, final_fx;              
float3 res1, res2, pix1, pix2;
bool4 nc, px;
float blend1, blend2;
#line 119
const float OGLInvSizeY2 = OGLInvSize.y * 2;
const float2 x2         = float2( OGLInvSize.y, 0.0);
const float2 y2         = float2( 0.0 , OGLInvSizeY2 );
const float4 xy         = float4( OGLInvSize.x, OGLInvSize.y, -OGLInvSize.x, -OGLInvSize.y );
const float4 zw         = float4( OGLInvSize.y, OGLInvSize.y, -OGLInvSize.y, -OGLInvSizeY2 );
const float4 wz         = float4( OGLInvSize.x, OGLInvSizeY2, -OGLInvSize.x, -OGLInvSizeY2 );
#line 126
const float4 delta  = float4(1.0/XBR_SCALE, 1.0/XBR_SCALE, 1.0/XBR_SCALE, 1.0/XBR_SCALE);
const float4 deltaL = float4(0.5/XBR_SCALE, 1.0/XBR_SCALE, 0.5/XBR_SCALE, 1.0/XBR_SCALE);
const float4 deltaU = deltaL.yxwz;
#line 130
const float3 A  = tex2D(ReShade::BackBuffer, TexCoord_0 + xy.zw ).xyz;
const float3 B  = tex2D(ReShade::BackBuffer, TexCoord_0     -dy ).xyz;
const float3 C  = tex2D(ReShade::BackBuffer, TexCoord_0 + xy.xw ).xyz;
const float3 D  = tex2D(ReShade::BackBuffer, TexCoord_0 - dx    ).xyz;
const float3 E  = tex2D(ReShade::BackBuffer, TexCoord_0         ).xyz;
const float3 F  = tex2D(ReShade::BackBuffer, TexCoord_0 + dx    ).xyz;
const float3 G  = tex2D(ReShade::BackBuffer, TexCoord_0 + xy.zy ).xyz;
const float3 H  = tex2D(ReShade::BackBuffer, TexCoord_0     +dy ).xyz;
const float3 I  = tex2D(ReShade::BackBuffer, TexCoord_0 + xy.xy ).xyz;
const float3 A1 = tex2D(ReShade::BackBuffer, TexCoord_0 + wz.zw ).xyz;
const float3 C1 = tex2D(ReShade::BackBuffer, TexCoord_0 + wz.xw ).xyz;
const float3 A0 = tex2D(ReShade::BackBuffer, TexCoord_0 + zw.zw ).xyz;
const float3 G0 = tex2D(ReShade::BackBuffer, TexCoord_0 + zw.zy ).xyz;
const float3 C4 = tex2D(ReShade::BackBuffer, TexCoord_0 + zw.xw ).xyz;
const float3 I4 = tex2D(ReShade::BackBuffer, TexCoord_0 + zw.xy ).xyz;
const float3 G5 = tex2D(ReShade::BackBuffer, TexCoord_0 + wz.zy ).xyz;
const float3 I5 = tex2D(ReShade::BackBuffer, TexCoord_0 + wz.xy ).xyz;
const float3 B1 = tex2D(ReShade::BackBuffer, TexCoord_0 - y2    ).xyz;
const float3 D0 = tex2D(ReShade::BackBuffer, TexCoord_0 - x2    ).xyz;
const float3 H5 = tex2D(ReShade::BackBuffer, TexCoord_0 + y2    ).xyz;
const float3 F4 = tex2D(ReShade::BackBuffer, TexCoord_0 + x2    ).xyz;
#line 152
const float4 b  = float4(dot(B ,rgbw), dot(D ,rgbw), dot(H ,rgbw), dot(F ,rgbw));
const float4 c  = float4(dot(C ,rgbw), dot(A ,rgbw), dot(G ,rgbw), dot(I ,rgbw));
const float4 d  = b.yzwx;
const float  eV = dot(E,rgbw);
const float4 e  = float4(eV, eV, eV, eV);
const float4 f  = b.wxyz;
const float4 g  = c.zwxy;
const float4 h  = b.zwxy;
const float4 i  = c.wxyz;
const float4 i4 = float4(dot(I4,rgbw), dot(C1,rgbw), dot(A0,rgbw), dot(G5,rgbw));
const float4 i5 = float4(dot(I5,rgbw), dot(C4,rgbw), dot(A1,rgbw), dot(G0,rgbw));
const float4 h5 = float4(dot(H5,rgbw), dot(F4,rgbw), dot(B1,rgbw), dot(D0,rgbw));
const float4 f4 = h5.yzwx;
const float4 c1 = i4.yzwx;
const float4 g0 = i5.wxyz;
#line 168
const float4 Ao = float4( 1.0, -1.0, -1.0, 1.0 );
const float4 Bo = float4( 1.0,  1.0, -1.0,-1.0 );
const float4 Co = float4( 1.5,  0.5, -0.5, 0.5 );
const float4 Ax = float4( 1.0, -1.0, -1.0, 1.0 );
const float4 Bx = float4( 0.5,  2.0, -0.5,-2.0 );
const float4 Cx = float4( 1.0,  1.0, -0.5, 0.0 );
const float4 Ay = float4( 1.0, -1.0, -1.0, 1.0 );
const float4 By = float4( 2.0,  0.5, -2.0,-0.5 );
const float4 Cy = float4( 2.0,  0.0, -1.0, 0.5 );
#line 180
fx      = (Ao*fp.y+Bo*fp.x);
#line 182
fx_left = (Ax*fp.y+Bx*fp.x);
#line 184
fx_up   = (Ay*fp.y+By*fp.x);
#line 186
if (xBRtype <= 0){
interp_restriction_lv1 = sign(noteq(e,f) * noteq(e,h));
} else if (xBRtype <= 1){
interp_restriction_lv1 = sign(noteq(e,f) * noteq(e,h) * ( not(eq(f,b)) * not(eq(h,d)) + eq(e,i) * not(eq(f,i4)) * not(eq(h,i5)) + eq(e,g) + eq(e,c)));
} else if (xBRtype <= 2){
interp_restriction_lv1 = sign(noteq(e,f)*noteq(e,h)*(not(eq(f,b))* not(eq(h,d)) + eq(e,i) * not(eq(f,i4)) * not(eq(h,i5)) + eq(e,g) + eq(e,c) )  * (noteq(f,f4)* noteq(f,i) + noteq(h,h5) * noteq(h,i) + noteq(h,g) + noteq(f,c) + eq(b,c1) * eq(d,g0)));
} else {
interp_restriction_lv1 = sign(noteq(e,f) * noteq(e,h) * ( not(eq(f,b)) * not(eq(f,c)) + not(eq(h,d)) * not(eq(h,g)) + eq(e,i) * (not(eq(f,f4)) * not(eq(f,i4)) + not(eq(h,h5)) * not(eq(h,i5))) + eq(e,g) + eq(e,c)) );
}
#line 196
interp_restriction_lv2_left = float4(notEqual(e,g))*float4(notEqual(d,g));
interp_restriction_lv2_up   = float4(notEqual(e,c))*float4(notEqual(b,c));
#line 199
float4 fx45 = clamp((fx + delta -Co)/(2*delta ),0.0,1.0);
float4 fx30 = clamp((fx_left + deltaL -Cx)/(2*deltaL),0.0,1.0);
float4 fx60 = clamp((fx_up + deltaU -Cy)/(2*deltaU),0.0,1.0);
#line 203
edr      = float4(lessThan(weighted_distance( e, c, g, i, h5, f4, h, f), weighted_distance( h, d, i5, f, i4, b, e, i)))*interp_restriction_lv1;
edr_left = float4(lessThanEqual(coef*df(f,g),df(h,c)))*interp_restriction_lv2_left*edr;
edr_up   = float4(greaterThanEqual(df(f,g),coef*df(h,c)))*interp_restriction_lv2_up*edr;
#line 207
fx45 = edr*fx45;
fx30 = edr_left*fx30;
fx60 = edr_up*fx60;
#line 211
px = lessThanEqual(df(e,f),df(e,h));
const float4 maximo = max(max(fx30, fx60), fx45);
#line 214
const float3 zero  = lerp(E, lerp(H, F, float(px.x)), maximo.x).rgb;
const float3 one   = lerp(E, lerp(F, B, float(px.y)), maximo.y).rgb;
const float3 two   = lerp(E, lerp(B, D, float(px.z)), maximo.z).rgb;
const float3 three = lerp(E, lerp(D, H, float(px.w)), maximo.w).rgb;
#line 219
const float4 pixel = float4(dot(zero,rgbw),dot(one,rgbw),dot(two,rgbw),dot(three,rgbw));
#line 221
const float4 diff = df(pixel,e);
#line 223
float3 res = zero;
float mx = diff.x;
#line 226
if (diff.y > mx) {res = one; mx = diff.y;}
if (diff.z > mx) {res = two; mx = diff.z;}
if (diff.w > mx) {res = three;}
#line 230
return res;
}
#line 233
float3 dilation(float4 position : SV_Position, float2 tex : TEXCOORD0) : SV_Target
{
const float2 dz = float2( 1.0 / ReShade::GetScreenSize().x * dilationAmount,
1.0 / ReShade::GetScreenSize().y * dilationAmount);
#line 238
const float x = ReShade::GetPixelSize().x;
const float y = ReShade::GetPixelSize().y;
#line 241
const float3 B  = tex2D(ReShade::BackBuffer, tex + float2(0, -1) * dz).rgb;
const float3 D  = tex2D(ReShade::BackBuffer, tex + float2(-1, 0) * dz).rgb;
const float3 E  = tex2D(ReShade::BackBuffer, tex + float2(0, 0) * dz).rgb;
const float3 F  = tex2D(ReShade::BackBuffer, tex + float2(1, 0) * dz).rgb;
const float3 H  = tex2D(ReShade::BackBuffer, tex + float2(0, 1) * dz).rgb;
#line 247
return max(E, max(max(F, D), max(B, H)));
}
#line 250
technique xBRv4
{
pass
{
VertexShader = PostProcessVS;
PixelShader  = dilation;
}
pass
{
VertexShader = PostProcessVS;
PixelShader  = dilation;
}
pass
{
VertexShader = PostProcessVS;
PixelShader  = xBRv4;
}
}

