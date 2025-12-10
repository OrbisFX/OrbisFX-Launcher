// SMOOTH_NORMALS=2
// #pragma warning (disable : 3571)
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\NiceGuy_Lamps.fx"
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
#line 10 "C:\Program Files\GShade\gshade-shaders\Shaders\NiceGuy_Lamps.fx"
#line 14
uniform float Frame < source = "framecount"; >;
#line 19
static const float fov = 60;
#line 53
texture TexColor : COLOR;
sampler sTexColor {Texture = TexColor; };
#line 56
texture LampIcon <source = "NGLamp-Lamp-Icon.jpg";>{ Width = 814; Height = 814; Format = R8; MipLevels = 6; };
sampler sLampIcon { Texture = LampIcon; AddressU = CLAMP; AddressV = CLAMP; };
#line 59
texture NormTex  { Width = 1920; Height = 1018; Format = RGBA16f; };
sampler sNormTex { Texture = NormTex; };
#line 62
texture NormTex1  { Width = 1920; Height = 1018; Format = RGBA16f; };
sampler sNormTex1 { Texture = NormTex1; };
#line 65
texture VarianceTex { Width = 1920; Height = 1018; Format = R16f;};
sampler sVarianceTex {Texture = VarianceTex;};
#line 68
texture ShadowTex { Width = 1920; Height = 1018; Format = R16f;};
sampler sShadowTex {Texture = ShadowTex;};
#line 71
texture BGColorTex { Width = 1920; Height = 1018; Format = RGBA16f;};
sampler sBGColorTex {Texture = BGColorTex;};
#line 74
texture LightingTex { Width = 1920; Height = 1018; Format = RGBA16f;};
sampler sLightingTex {Texture = LightingTex;};
#line 77
texture BlendedTex { Width = 1920; Height = 1018; Format = RGBA16f;};
sampler sBlendedTex {Texture = BlendedTex;};
#line 80
texture LitHistTex { Width = 1920; Height = 1018; Format = RGBA16f;};
sampler sLitHistTex {Texture = LitHistTex;};
#line 83
texture NGLa_BlueNoise <source="BlueNoise-64frames128x128.png";> { Width = 1024; Height = 1024; Format = RGBA8;};
sampler sNGLa_BlueNoise { Texture = NGLa_BlueNoise; AddressU = REPEAT; AddressV = REPEAT; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
#line 86
texture texMotionVectors { Width = 1920; Height = 1018; Format = RG16F; };
sampler SamplerMotionVectors { Texture = texMotionVectors; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
#line 92
uniform int Hints<
ui_text = "This shader lacks an internal denoiser at the moment.\n"
"Use either FXAA or TFAA and set the denoiser option accordingly."
"Bump mapping may break the look. I'm trying to solve it tho.";
#line 97
ui_category = "Hints - Please Read for good results.";
ui_category_closed = true;
ui_label = " ";
ui_type = "radio";
>;
#line 103
uniform bool debug <
ui_label = "Debug";
ui_category = "General";
> = 0;
#line 108
uniform bool ShowIcon <
ui_label = "Show lamp icons";
ui_category = "General";
> = 1;
#line 113
uniform bool LimitPos <
ui_label = "Limit lamp to depth";
ui_tooltip = "Limit lamp position to the wall behind them";
ui_category = "General";
> = 0;
#line 119
uniform float OGLighting <
ui_label = "Original lighting";
ui_type = "slider";
ui_category = "General";
> = 1;
#line 125
uniform float BUMP <
ui_label = "Bump mapping";
ui_type = "slider";
ui_category = "General";
ui_min = 0.0;
ui_max = 1;
> = 0;
#line 133
uniform int Shadow_Quality <
ui_label = "Shadow quality";
ui_type = "combo";
ui_items = "Low (16 steps)\0Medium (48 steps)\0High (256 steps)\0";
ui_category = "Shadows";
> = 0;
#line 140
uniform float Shadow_Depth <
ui_label = "Surface Depth";
ui_type = "drag";
ui_tooltip = "Depth buffer doesn't have information\n"
"about the depth of each object. Thus\n"
"we have to take this number as that.";
ui_category = "Shadows";
ui_max = 10;
ui_min = 0;
ui_step = 0.01;
> = 3;
#line 152
uniform float UI_FOG_DENSITY <
ui_type = "slider";
ui_label = "Fog Density";
ui_category = "Fog";
ui_max = 1;
> = 0.2;
#line 160
uniform float3 UI_FOG_COLOR <
ui_type = "color";
ui_label = "Fog Color";
ui_category = "Fog";
> = 1;
#line 166
uniform bool UI_FOG_DEPTH_MASK <
ui_type = "radio";
ui_label = "Mask Fog with depth";
ui_tooltip = "Uses depth to mask the fog,\n"
"faking volumetric shadows to make to fog appear behind objects";
ui_category = "Fog";
> = 0;
#line 174
uniform float roughness <
ui_type = "slider";
ui_category = "Reflections";
ui_label = "Roughness";
ui_tooltip = "How wide it should search for variation in roughness?\n"
"Low = Detailed\nHigh = Soft";
ui_max = 1;
> = 1;
#line 183
uniform float specular <
ui_type = "slider";
ui_category = "Reflections";
ui_min = 0;
ui_max = 1;
> = 0.1;
#line 195
uniform bool L1 <
ui_label = "Enable Lamp 1";
ui_category = "Lamp 1";
ui_category_closed = true;
> = 1;
#line 201
uniform bool UI_FOG1 <
ui_label = "Enable fog";
ui_category = "Lamp 1";
ui_category_closed = true;
> = 1;
#line 207
uniform bool UI_S_ENABLE1 <
ui_label = "Enable Shadows";
ui_category = "Lamp 1";
ui_category_closed = true;
> = 1;
#line 213
uniform float3 UI_LAMP1 <
ui_type = "slider";
ui_label= "Position";
ui_category = "Lamp 1";
ui_category_closed = true;
> = float3(0.5, 0.5, 0.03125);
#line 220
uniform float3 UI_LAMP1_PRECISE <
ui_type = "slider";
ui_label= "Precise Position";
ui_max =  0.02;
ui_min = -0.02;
ui_category = "Lamp 1";
ui_category_closed = true;
> = float3(0, 0, 0);
#line 229
uniform float3 UI_COLOR1 <
ui_type = "color";
ui_label= "Color";
ui_category = "Lamp 1";
ui_category_closed = true;
> = 1;
#line 236
uniform float UI_POWER1 <
ui_type = "slider";
ui_label= "Power";
ui_max  = 10;
ui_category = "Lamp 1";
ui_category_closed = true;
> = 5;
#line 244
uniform float UI_SOFT_S1 <
ui_type = "slider";
ui_label= "Shadow Softness";
ui_max  = 10;
ui_category = "Lamp 1";
ui_category_closed = true;
> = 0;
#line 256
uniform bool L2 <
ui_label = "Enable Lamp 2";
ui_category = "Lamp 2";
ui_category_closed = true;
> = 0;
#line 262
uniform bool UI_FOG2 <
ui_label = "Enable fog";
ui_category = "Lamp 2";
ui_category_closed = true;
> = 1;
#line 268
uniform bool UI_S_ENABLE2 <
ui_label = "Enable Shadows";
ui_category = "Lamp 2";
ui_category_closed = true;
> = 1;
#line 274
uniform float3 UI_LAMP2 <
ui_type = "slider";
ui_label= "Position";
ui_category = "Lamp 2";
ui_category_closed = true;
> = float3(0.5, 0.25, 0.03125);
#line 281
uniform float3 UI_LAMP2_PRECISE <
ui_type = "slider";
ui_label= "Precise Position";
ui_max =  0.02;
ui_min = -0.02;
ui_category = "Lamp 2";
ui_category_closed = true;
> = float3(0, 0, 0);
#line 290
uniform float3 UI_COLOR2 <
ui_type = "color";
ui_label= "Color";
ui_category = "Lamp 2";
ui_category_closed = true;
> = 1;
#line 297
uniform float UI_POWER2 <
ui_type = "slider";
ui_label= "Power";
ui_max  = 10;
ui_category = "Lamp 2";
ui_category_closed = true;
> = 5;
#line 305
uniform float UI_SOFT_S2 <
ui_type = "slider";
ui_label= "Shadow Softness";
ui_max  = 10;
ui_category = "Lamp 2";
ui_category_closed = true;
> = 0;
#line 317
uniform bool L3 <
ui_label = "Enable Lamp 3";
ui_category = "Lamp 3";
ui_category_closed = true;
> = 0;
#line 323
uniform bool UI_FOG3 <
ui_label = "Enable fog";
ui_category = "Lamp 3";
ui_category_closed = true;
> = 1;
#line 329
uniform bool UI_S_ENABLE3 <
ui_label = "Enable Shadows";
ui_category = "Lamp 3";
ui_category_closed = true;
> = 1;
#line 335
uniform float3 UI_LAMP3 <
ui_type = "slider";
ui_label= "Position";
ui_category = "Lamp 3";
ui_category_closed = true;
> = float3(0.5, 0.75, 0.03125);
#line 342
uniform float3 UI_LAMP3_PRECISE <
ui_type = "slider";
ui_label= "Precise Position";
ui_max =  0.02;
ui_min = -0.02;
ui_category = "Lamp 3";
ui_category_closed = true;
> = float3(0, 0, 0);
#line 351
uniform float3 UI_COLOR3 <
ui_type = "color";
ui_label= "Color";
ui_category = "Lamp 3";
ui_category_closed = true;
> = 1;
#line 358
uniform float UI_POWER3 <
ui_type = "slider";
ui_label= "Power";
ui_max  = 10;
ui_category = "Lamp 3";
ui_category_closed = true;
> = 5;
#line 366
uniform float UI_SOFT_S3 <
ui_type = "slider";
ui_label= "Shadow Softness";
ui_max  = 10;
ui_category = "Lamp 3";
ui_category_closed = true;
> = 0;
#line 378
uniform bool L4 <
ui_label = "Enable Lamp 4";
ui_category = "Lamp 4";
ui_category_closed = true;
> = 0;
#line 384
uniform bool UI_FOG4 <
ui_label = "Enable fog";
ui_category = "Lamp 4";
ui_category_closed = true;
> = 1;
#line 390
uniform bool UI_S_ENABLE4 <
ui_label = "Enable Shadows";
ui_category = "Lamp 4";
ui_category_closed = true;
> = 1;
#line 396
uniform float3 UI_LAMP4 <
ui_type = "slider";
ui_label= "Position";
ui_category = "Lamp 4";
ui_category_closed = true;
> = float3(0.25, 0.5, 0.03125);
#line 403
uniform float3 UI_LAMP4_PRECISE <
ui_type = "slider";
ui_label= "Precise Position";
ui_max =  0.02;
ui_min = -0.02;
ui_category = "Lamp 4";
ui_category_closed = true;
> = float3(0, 0, 0);
#line 412
uniform float3 UI_COLOR4 <
ui_type = "color";
ui_label= "Color";
ui_category = "Lamp 4";
ui_category_closed = true;
> = 1;
#line 419
uniform float UI_POWER4 <
ui_type = "slider";
ui_label= "Power";
ui_max  = 10;
ui_category = "Lamp 4";
ui_category_closed = true;
> = 5;
#line 427
uniform float UI_SOFT_S4 <
ui_type = "slider";
ui_label= "Shadow Softness";
ui_max  = 10;
ui_category = "Lamp 4";
ui_category_closed = true;
> = 0;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\NGLamps-GGX.fxh"
#line 7
float NDF_GGX(float NdotH, float alpha)
{
alpha *= alpha;
float denominator = (NdotH * alpha - NdotH) * NdotH + 1.0;
return alpha / (3.1415927 * denominator * denominator);
}
#line 15
float Lambda_Smith(float NdotX, float alpha)
{
float alpha_sqr = alpha * alpha;
float NdotX_sqr = NdotX * NdotX;
return (-1.0 + sqrt(alpha_sqr * (1.0 - NdotX_sqr) / NdotX_sqr + 1.0)) * 0.5;
}
#line 23
float G2_Smith(float NdotL, float NdotV, float alpha)
{
float lambdaV = Lambda_Smith(NdotV, alpha);
float lambdaL = Lambda_Smith(NdotL, alpha);
#line 28
return 1.0 / (1.0 + lambdaV + lambdaL);
}
#line 32
float3 sample_ggx_ndf(float2 Xi, float alpha)
{
float alpha_sqr = alpha * alpha;
#line 36
float phi = 2.0 * 3.1415927 * Xi.x;
#line 38
float cos_theta = sqrt((1.0 - Xi.y) / (1.0 + (alpha_sqr - 1.0) * Xi.y));
float sin_theta = sqrt(1.0 - cos_theta * cos_theta);
#line 42
float3 H;
{
H.x = sin_theta * cos(phi);
H.y = sin_theta * sin(phi);
H.z = cos_theta;
}
return H;
}
#line 52
float3 ggx_smith_brdf(float NdotL, float NdotV, float NdotH, float VdotH, float3 F0, float alpha, float2 texcoord)
{
#line 55
float NDF = NDF_GGX(NdotH, alpha);
#line 58
float G2 = G2_Smith(NdotL, NdotV, alpha);
#line 61
float3 F = F0 + (1.0 - F0) * pow(1.0 - VdotH, 5.0);
#line 64
float3 numerator = NDF * G2 * F;
#line 67
float denominator = max(4.0 * NdotL * NdotV, 1e-8);
#line 70
return numerator / denominator;
}
#line 73
float3 hammon(float LdotV, float NdotH, float NdotL, float NdotV, float alpha, float3 diffusecolor)
{
float facing = 0.5 + 0.5 * LdotV;
#line 77
float rough = facing * (0.9 - 0.4 * facing) * ((0.5 + NdotH) / NdotH);
float smooth = 1.05 * (1.0 - pow(1.0-NdotL, 5.0)) * (1.0-pow(1.0-NdotV, 5.0));
float single = lerp(smooth, rough, alpha) / 3.1415927;
float multi = 0.1159 * alpha;
return diffusecolor * (single + diffusecolor * multi);
}
#line 441 "C:\Program Files\GShade\gshade-shaders\Shaders\NiceGuy_Lamps.fx"
#line 442
float noise(float2 co)
{
return frac(sin(dot(co.xy ,float2(1.0,73))) * 437580.5453);
}
#line 447
float IGN(float2 n) {
float f = 0.06711056 * n.x + 0.00583715 * n.y;
return frac(52.9829189 * frac(f));
}
#line 453
float3 noise3dts(float2 co, float s, float frame)
{
co += sin(frame/120.347668756453546);
co += s/16.3542625435332254;
return float3( noise(co), noise(co+0.6432168421), noise(co+0.19216811));
}
#line 460
float3 BN3dts(float2 texcoord)
{
texcoord *= float2(1920, 1018); 
#line 464
texcoord = texcoord%128; 
#line 466
float frame = Frame%64; 
int2 F;
F.x = frame%8; 
F.y = floor(frame/8)%8; 
F *= 128; 
texcoord += F;
texcoord /= 1024; 
float3 Tex = tex2D(sNGLa_BlueNoise, texcoord).rgb;
return Tex;
}
#line 477
float3 UVtoPos(float2 texcoord)
{
float3 scrncoord = float3(texcoord.xy*2-1, ReShade::GetLinearizedDepth(texcoord) * 1000.0);
scrncoord.xy *= scrncoord.z * ((fov*0.5/360)*2*3.1415927);
scrncoord.x *= (1920 * (1.0 / 1018));
#line 483
return scrncoord.xyz;
}
#line 486
float3 UVtoPos(float2 texcoord, float depth)
{
float3 scrncoord = float3(texcoord.xy*2-1, depth * 1000.0);
scrncoord.xy *= scrncoord.z * ((fov*0.5/360)*2*3.1415927);
scrncoord.x *= (1920 * (1.0 / 1018));
#line 492
return scrncoord.xyz;
}
#line 495
float2 PostoUV(float3 position)
{
float2 scrnpos = position.xy;
scrnpos.x /= (1920 * (1.0 / 1018));
scrnpos /= position.z*(fov/2/360)*2*3.1415927;
#line 501
return scrnpos/2 + 0.5;
}
#line 504
float3 Normal(float2 texcoord)
{
float2 p = float2((1.0 / 1920), (1.0 / 1018));;
float3 u,d,l,r,u2,d2,l2,r2;
#line 509
u = UVtoPos( texcoord + float2( 0, p.y));
d = UVtoPos( texcoord - float2( 0, p.y));
l = UVtoPos( texcoord + float2( p.x, 0));
r = UVtoPos( texcoord - float2( p.x, 0));
#line 514
p *= 2;
#line 516
u2 = UVtoPos( texcoord + float2( 0, p.y));
d2 = UVtoPos( texcoord - float2( 0, p.y));
l2 = UVtoPos( texcoord + float2( p.x, 0));
r2 = UVtoPos( texcoord - float2( p.x, 0));
#line 521
u2 = u + (u - u2);
d2 = d + (d - d2);
l2 = l + (l - l2);
r2 = r + (r - r2);
#line 526
float3 c = UVtoPos( texcoord);
#line 528
float3 v = u-c; float3 h = r-c;
#line 530
if( abs(d2.z-c.z) < abs(u2.z-c.z) ) v = c-d;
if( abs(l2.z-c.z) < abs(r2.z-c.z) ) h = c-l;
#line 533
return normalize(cross( v, h));
}
#line 537
float3 Tonemapper(float3 color)
{
return color.rgb / (1.0 + color);
}
#line 542
float InvTonemapper(float color)
{
return color / (1.0 - color);
}
#line 547
float3 InvTonemapper(float3 color)
{
return color / (1.001 - color);
}
#line 552
float lum(in float3 color)
{
return 0.333333 * (color.r + color.g + color.b);
}
#line 558
float3 Bump(float2 texcoord, float height)
{
float2 p = float2((1.0 / 1920), (1.0 / 1018));;
#line 562
float3 s[3];
s[0] = tex2D(sTexColor, texcoord + float2(p.x, 0)).rgb;
s[1] = tex2D(sTexColor, texcoord + float2(0, p.y)).rgb;
s[2] = tex2D(sTexColor, texcoord).rgb;
float LC = rcp(lum(s[0]+s[1]+s[2])) * height;
LC = min(LC, 4);
s[0] *= LC; s[1] *= LC; s[2] *= LC;
float d[3];
d[0] = ReShade::GetLinearizedDepth(texcoord + float2(p.x, 0));
d[1] = ReShade::GetLinearizedDepth(texcoord + float2(0, p.y));
d[2] = ReShade::GetLinearizedDepth(texcoord);
#line 577
float3 XB = s[2]-s[0];
float3 YB = s[2]-s[1];
#line 580
float3 bump = float3(lum(XB)*saturate(1-abs(d[0] - d[2])*1000), lum(YB)*saturate(1-abs(d[1] - d[2])*1000), 1);
bump = normalize(bump);
return bump;
}
#line 585
float3 blend_normals(float3 n1, float3 n2)
{
n1 += float3( 0, 0, 1);
n2 *= float3(-1, -1, 1);
return n1*dot(n1, n2)/n1.z - n2;
}
#line 592
bool is_saturated(float2 uv)
{
return uv.x>1||uv.y>1||uv.x<0||uv.y<0;
}
#line 600
float3 toYCC(float3 rgb)
{
float Y  =  .299 * rgb.x + .587 * rgb.y + .114 * rgb.z; 
float Cb = -.169 * rgb.x - .331 * rgb.y + .500 * rgb.z; 
float Cr =  .500 * rgb.x - .419 * rgb.y - .081 * rgb.z; 
return float3(Y,Cb + 128./255.,Cr + 128./255.);
}
#line 611
struct i
{
float4 vpos : SV_Position;
float2 texcoord : TexCoord0;
};
#line 617
float3 GetRoughTex(float2 texcoord, float4 normal)
{
float2 p = float2((1.0 / 1920), (1.0 / 1018));;
#line 622
const float Threshold = 0.00003;
float facing = dot(normal.rgb, normalize(UVtoPos(texcoord, normal.a)));
facing *= facing;
#line 627
float roughfac; float2 fromrough, torough;
roughfac = (1 - roughness);
fromrough.x = lerp(0, 0.1, saturate(roughness*10));
fromrough.y = 0.8;
torough = float2(0, pow(roughness, roughfac));
#line 633
float3 center = toYCC(tex2D(sTexColor, texcoord).rgb);
float depth = ReShade::GetLinearizedDepth(texcoord);
#line 636
float Roughness;
#line 638
float2 offsets[4] = {float2(p.x,0), float2(-p.x,0),float2( 0,-p.y),float2(0,p.y)};
[unroll]for(int x; x < 4; x++)
{
float2 SampleCoord = texcoord + offsets[x];
float  SampleDepth = ReShade::GetLinearizedDepth(SampleCoord);
if(abs(SampleDepth - depth)*facing < Threshold)
{
float3 SampleColor = toYCC(tex2D( sTexColor, SampleCoord).rgb);
SampleColor = min(abs(center.g - SampleColor.g), 0.25);
Roughness += SampleColor.r;
}
}
#line 651
Roughness = pow( Roughness, roughfac*0.66);
Roughness = clamp(Roughness, fromrough.x, fromrough.y);
Roughness = (Roughness - fromrough.x) / ( 1 - fromrough.x );
Roughness = Roughness / fromrough.y;
Roughness = clamp(Roughness, torough.x, torough.y);
#line 657
return saturate(Roughness);
}
#line 660
void GBuffer1(i i, out float4 normal : SV_Target) 
{
normal.rgb = Normal(i.texcoord.xy);
normal.a   = ReShade::GetLinearizedDepth(i.texcoord.xy);
#line 668
}
#line 670
float4 SNH(i i) : SV_Target
{
float4 color = tex2D(sNormTex, i.texcoord);
float4 s, s1; float sc;
#line 675
float2 p = float2((1.0 / 1920), (1.0 / 1018));; p*=2.5;
float T = 0.5 * saturate(2*(1-color.a)); T = rcp(max(T, 0.0001));
for (int x = -3; x <= 3; x++)
{
s = tex2D(sNormTex, float2(i.texcoord.xy + float2(x*p.x, 0)));
float diff = dot(0.333, abs(s.rgb - color.rgb)) + abs(s.a - color.a)*1000.0*0.5;
diff = 1-saturate(diff*T);
s1 += s*diff;
sc += diff;
}
#line 688
return s1.rgba/sc;
}
#line 691
float4 SNV(i i) : SV_Target
{
float4 color = tex2Dlod(sNormTex1, float4(i.texcoord, 0, 0));
float4 s, s1; float sc;
#line 696
float2 p = float2((1.0 / 1920), (1.0 / 1018));; p*=2.5;
float T = 0.5 * saturate(2*(1-color.a)); T = rcp(max(T, 0.0001));
for (int x = -3; x <= 3; x++)
{
s = tex2D(sNormTex1, float2(i.texcoord + float2(0, x*p.y)));
float diff = dot(0.333, abs(s.rgb - color.rgb)) + abs(s.a - color.a)*1000.0*0.5;
diff = 1-saturate(diff*T*2);
s1 += s*diff;
sc += diff;
}
#line 709
s1.rgba = s1.rgba/sc;
s1.rgb = blend_normals( Bump(i.texcoord, BUMP), s1.rgb);
return
float4
(
s1.rgb,
GetRoughTex
(
i.texcoord,
float4(Normal(i.texcoord).rgb, s1.a)
).r
);
}
#line 727
float GetShadows(float3 position, float3 lamppos, float2 texcoord, float penumbra)
{
#line 730
float i; float Check; float a;
#line 732
int STEPCOUNT_Selector[3] = {16, 48, 256};
int STEPCOUNT = STEPCOUNT_Selector[Shadow_Quality];
#line 735
float3 BlueNoise  = BN3dts(texcoord);
const float penum_mult = 3000/(1000.0);
float3 lamppos_soft;
lamppos_soft = lamppos + (BlueNoise-0.5)*penumbra*penum_mult*0.1;
#line 740
if(ReShade::GetLinearizedDepth(PostoUV(lamppos.xyz))>=lamppos.z)
lamppos_soft.z = min(lamppos_soft.z, ReShade::GetLinearizedDepth(texcoord));
#line 743
float3 raydir = normalize(lamppos_soft - position);
raydir *= min(1 * 1000.0, distance(position, lamppos_soft))/STEPCOUNT;
#line 746
float3 raypos = position + raydir * (1 + BlueNoise.x * 1);
#line 748
[loop]for( i; i < STEPCOUNT; i++)
{
Check = ReShade::GetLinearizedDepth(PostoUV(raypos)) * 1000.0 - raypos.z;
if(Check < 0 && Check > -Shadow_Depth)
{a = 1; break;}
#line 754
raypos += raydir;
}
return 1-a;
}
#line 759
float3 GetLampPos(float3 UI_LAMP)
{
float3 sspos = UI_LAMP - float3(0.5, 0.5, 0);
sspos.y = -sspos.y;
sspos.x *= (1920 * (1.0 / 1018));
sspos.xy *= 1.047;
sspos.y = sspos.y/2;
sspos.xy *= sspos.z;
#line 768
return sspos * 1000.0;
}
#line 772
float3 GetLighting(
inout float3 FinalColor, inout float spr, inout float3 Specular, inout float3 fog, inout float ShadowOnly,
float alpha, float3 position, float3 normal, float3 eyedir, float NdotV, float F0, float2 texcoord, float2 sprite,
float3 UI_LAMP, float3 UI_LAMP_PRECISE, float3 UI_COLOR, float UI_POWER, float UI_SOFT_S, float UI_S_ENABLE, bool UI_FOG)
{
float3 lamppos, lamp, lampdir, light; float2 icopos; float DepthLimit, AngFalloff, backfacing, sprtex, Shadow;
#line 780
UI_POWER *= 1000.0;
#line 782
lamppos = GetLampPos(UI_LAMP + UI_LAMP_PRECISE);
if(LimitPos)
{
DepthLimit = ReShade::GetLinearizedDepth(PostoUV(lamppos.xyz));
lamppos.z  = min(lamppos.z, DepthLimit*1000.0-5);
}
lamp       = 1/pow(distance(position, lamppos), 2);
lampdir    = normalize(lamppos - position);
#line 792
float3 H    = normalize(lampdir + eyedir);
float NdotH = dot(normal, H);
float VdotH = dot(eyedir, H);
float NdotL = dot(normal, lampdir);
float LdotV = dot(lampdir, eyedir);
backfacing = dot(-lampdir, normal);
#line 800
Shadow = 1;
if(UI_S_ENABLE&&backfacing>0)Shadow = GetShadows(position, lamppos, texcoord, UI_SOFT_S);
#line 804
AngFalloff = dot(lampdir, normal);
float DisFalloff = 1/pow(distance(position, lamppos), 2);
light = lamp*UI_POWER*UI_COLOR*(1-AngFalloff);
#line 809
FinalColor+= lerp( 0, light, backfacing>0) * Shadow;
#line 811
float3 ThisSpecular = ggx_smith_brdf(NdotL, NdotV, NdotH, VdotH, F0, alpha, texcoord) * NdotL;
ThisSpecular *= DisFalloff;
ThisSpecular *= UI_POWER*UI_COLOR*Shadow;
Specular += ThisSpecular;
#line 816
icopos = sprite - (PostoUV(lamppos) * 2 - 1)*float2(1.7778, 2);
icopos *= sqrt(max(1,lamppos.z))/(16*0.02);
icopos = icopos * 0.5 + 0.5;
sprtex = 1-(tex2D(sLampIcon, icopos).r);
if(lamppos.z>position.z)sprtex *= 0.1; 
if(is_saturated(icopos))sprtex = 0;
spr += sprtex;
#line 825
if(UI_FOG)
{
float3 ThisFog = UI_POWER * UI_COLOR * UI_FOG_DENSITY/3000 * 1000.0 * 0.1;
ThisFog *= (UI_FOG_DEPTH_MASK?saturate((position.z - lamppos.z + 1)/16):1);
float d = length(icopos-0.5);
ThisFog /= (d*d);
fog += ThisFog;
}
#line 834
ShadowOnly += Shadow;
#line 836
return 0;
}
#line 839
void Lighting(i i, out float3 FinalColor : SV_Target0, out float4 Fog : SV_Target1, out float ShadowOnly : SV_Target2)
{
FinalColor = 0; ShadowOnly = 0;
float3 raypos, Check; float2 UVraypos; float a; bool hit; 
float3 lamppos, lamp, lampdir, light, fog, Specular,K,R; float2 icopos; float AngFalloff, backfacing, sprtex, spr; 
#line 845
float3 diffusecolor = tex2D(sTexColor, i.texcoord).rgb;
#line 847
float2 sprite = i.texcoord;
sprite = sprite * 2 - 1; 
sprite.x *= (1920 * (1.0 / 1018)); 
#line 851
float3 position  = UVtoPos(i.texcoord);
float4 GBuff     = tex2D(sNormTex, i.texcoord);
float3 normal    = GBuff.rgb;
float  roughness = GBuff.a;
float3 eyedir    = -normalize(position); 
float  NdotV     = dot(normal, eyedir);
float  F0        = specular*0.08; 
float  alpha     = roughness * roughness; 
#line 860
if(L1)
GetLighting(
FinalColor, spr, Specular, fog, ShadowOnly,
alpha, position, normal, eyedir, NdotV, F0, i.texcoord, sprite,
UI_LAMP1, UI_LAMP1_PRECISE, UI_COLOR1, UI_POWER1, UI_SOFT_S1, UI_S_ENABLE1, UI_FOG1);
#line 866
if(L2)
GetLighting(
FinalColor, spr, Specular, fog, ShadowOnly,
alpha, position, normal, eyedir, NdotV, F0, i.texcoord, sprite,
UI_LAMP2, UI_LAMP2_PRECISE, UI_COLOR2, UI_POWER2, UI_SOFT_S2, UI_S_ENABLE2, UI_FOG2);
#line 872
if(L3)
GetLighting(
FinalColor, spr, Specular, fog, ShadowOnly,
alpha, position, normal, eyedir, NdotV, F0, i.texcoord, sprite,
UI_LAMP3, UI_LAMP3_PRECISE, UI_COLOR3, UI_POWER3, UI_SOFT_S3, UI_S_ENABLE3, UI_FOG3);
#line 878
if(L4)
GetLighting(
FinalColor, spr, Specular, fog, ShadowOnly,
alpha, position, normal, eyedir, NdotV, F0, i.texcoord, sprite,
UI_LAMP4, UI_LAMP4_PRECISE, UI_COLOR4, UI_POWER4, UI_SOFT_S4, UI_S_ENABLE4, UI_FOG4);
#line 888
FinalColor += -min(Specular*specular, 0);
FinalColor = Tonemapper(FinalColor);
#line 891
Fog.a = spr * ShowIcon;
Fog.rgb = fog*UI_FOG_COLOR;
ShadowOnly /= (L1+L2+L3+L4);
}
#line 896
float add4comp(in float4 input){ return input.x+input.y+input.z+input.w;}
float add2comp(in float2 input){ return input.x+input.y;}
#line 899
void GetVariance(i i, out float Var : SV_Target0)
{
float2 p = float2((1.0 / 1920), (1.0 / 1018));;
float PreSqr, PostSqr; int x,y;
#line 913
 
float4 sGather;
#line 916
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2(-3,-3) * p);
PostSqr += add4comp(sGather);
PreSqr  += add4comp(sGather * sGather);
#line 920
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2(-1,-3) * p);
PostSqr += add4comp(sGather);
PreSqr  += add4comp(sGather * sGather);
#line 924
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2( 1,-3) * p);
PostSqr += add4comp(sGather);
PreSqr  += add4comp(sGather * sGather);
#line 928
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2( 3,-3) * p);
PostSqr += add2comp(sGather.xw);
PreSqr  += add2comp(sGather.xw * sGather.xw);
#line 933
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2(-3,-1) * p);
PostSqr += add4comp(sGather);
PreSqr  += add4comp(sGather * sGather);
#line 937
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2(-1,-1) * p);
PostSqr += add4comp(sGather);
PreSqr  += add4comp(sGather * sGather);
#line 941
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2( 1,-1) * p);
PostSqr += add4comp(sGather);
PreSqr  += add4comp(sGather * sGather);
#line 945
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2( 3,-1) * p);
PostSqr += add2comp(sGather.xw);
PreSqr  += add2comp(sGather.xw * sGather.xw);
#line 950
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2(-3, 1) * p);
PostSqr += add4comp(sGather);
PreSqr  += add4comp(sGather * sGather);
#line 954
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2(-1, 1) * p);
PostSqr += add4comp(sGather);
PreSqr  += add4comp(sGather * sGather);
#line 958
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2( 1, 1) * p);
PostSqr += add4comp(sGather);
PreSqr  += add4comp(sGather * sGather);
#line 962
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2( 3, 1) * p);
PostSqr += add2comp(sGather.xw);
PreSqr  += add2comp(sGather.xw * sGather.xw);
#line 967
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2(-3, 3) * p);
PostSqr += add2comp(sGather.zw);
PreSqr  += add2comp(sGather.zw * sGather.zw);
#line 971
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2(-1, 3) * p);
PostSqr += add2comp(sGather.zw);
PreSqr  += add2comp(sGather.zw * sGather.zw);
#line 975
sGather = tex2DgatherR(sShadowTex, i.texcoord + float2( 1, 3) * p);
PostSqr += add2comp(sGather.zw);
PreSqr  += add2comp(sGather.zw * sGather.zw);
#line 979
sGather = tex2D(sShadowTex, i.texcoord + float2( 3, 3) * p).x;
PostSqr += sGather.x;
PreSqr += sGather.x * sGather.x;
#line 986
PostSqr /= 49;
PreSqr  /= 49;
#line 989
PostSqr *= PostSqr;
#line 991
Var = sqrt(abs(PostSqr - PreSqr));
}
#line 994
void Filter(i i, out float3 FinalColor : SV_Target0)
{
float2 p = float2((1.0 / 1920), (1.0 / 1018));;
float Var  = tex2D(sVarianceTex, i.texcoord + float2( 0.5, 0.5) * p).r;
float3 Current = tex2D(sLightingTex, i.texcoord).rgb;
FinalColor = Current;
#line 1002
if(Var > 0.01)
{
float2 MV = tex2D(SamplerMotionVectors, i.texcoord).xy;
float3 History = tex2D(sLitHistTex, i.texcoord + MV).rgb;
#line 1007
float3 S,
PreSqr = Current * Current, PostSqr = Current,
Min = 1000000, Max = -1000000;
int x,y;
#line 1012
for(x = -1; x <= 1; x++){
for(y = -1; y <= 1; y++)
{
if(x==0&&y==0)continue;
S = tex2Dlod(sLightingTex, float4(i.texcoord + float2(x,y) * p, 0, 0)).rgb;
PreSqr += S * S;
PostSqr += S;
Min = min(S, Min);
Max = max(S, Max);
}}
PostSqr /= 9;
PreSqr /= 9;
float3 mean = PreSqr;
#line 1026
PostSqr *= PostSqr;
float3 SD = sqrt(abs(PostSqr - PreSqr));
#line 1029
FinalColor = lerp(Current, History, clamp(Var*8, 0, 0.9));
FinalColor = lerp(clamp(FinalColor, Current-SD, Current+SD), FinalColor, clamp(Var*8, 0, 1));
}
}
#line 1034
float3 CopyBuffer(i i) : SV_Target0
{ return tex2D(sBlendedTex, i.texcoord).rgb;}
#line 1037
float3 OutColor(i i) : SV_Target0
{
float3 Lighting      = tex2D(sBlendedTex, i.texcoord).rgb;
float4 Fog           = tex2D(sBGColorTex, i.texcoord).rgba;
float3 DiffuseAlbedo = tex2D(sTexColor, i.texcoord).rgb;
#line 1043
Lighting = InvTonemapper(Lighting);
Lighting *= debug?1:DiffuseAlbedo;
DiffuseAlbedo = InvTonemapper(DiffuseAlbedo);
DiffuseAlbedo  = Tonemapper(Lighting + DiffuseAlbedo * OGLighting * !debug + Fog.rgb) + Fog.a;
#line 1048
return DiffuseAlbedo;
}
#line 1054
technique NGLamps<
ui_label   = "NiceGuy Lamps";
ui_tooltip = "NiceGuy Lamps 1.1 Beta\n"
"    ||By Ehsan2077||  \n";
>
{
pass GBuffer
{
VertexShader  = PostProcessVS;
PixelShader   = GBuffer1;
RenderTarget0 = NormTex;
}
#line 1067
pass SmoothNormalHpass
{
VertexShader = PostProcessVS;
PixelShader = SNH;
RenderTarget = NormTex1;
}
pass SmoothNormalVpass
{
VertexShader = PostProcessVS;
PixelShader = SNV;
RenderTarget = NormTex;
}
#line 1080
pass
{
VertexShader = PostProcessVS;
PixelShader = Lighting;
RenderTarget0 = LightingTex;
RenderTarget1 = BGColorTex;
RenderTarget2 = ShadowTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = GetVariance;
RenderTarget = VarianceTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = Filter;
RenderTarget = BlendedTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = CopyBuffer;
RenderTarget = LitHistTex;
}
pass
{
VertexShader = PostProcessVS;
PixelShader = OutColor;
}
}

