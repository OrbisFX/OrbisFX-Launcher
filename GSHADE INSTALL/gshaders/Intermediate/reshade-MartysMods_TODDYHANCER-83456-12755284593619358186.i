#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_TODDYHANCER.fx"
#line 121
texture ColorInputTex : COLOR;
sampler ColorInput 	{ Texture = ColorInputTex;  };
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods/mmx_global.fxh"
#line 47
static const float2 BUFFER_PIXEL_SIZE = float2((1.0 / 1920), (1.0 / 1018));
static const uint2 BUFFER_SCREEN_SIZE = uint2(1920, 1018);
static const float2 BUFFER_ASPECT_RATIO = float2(1.0, 1920 * (1.0 / 1018));
#line 81
static const float2 BUFFER_PIXEL_SIZE_DLSS   = float2((1.0 / 1920), (1.0 / 1018));
static const uint2 BUFFER_SCREEN_SIZE_DLSS   = uint2(1920, 1018);
static const float2 BUFFER_ASPECT_RATIO_DLSS = float2(1.0, 1920 * (1.0 / 1018));
#line 85
void FullscreenTriangleVS(in uint id : SV_VertexID, out float4 vpos : SV_Position, out float2 uv : TEXCOORD)
{
uv = id.xx == uint2(2, 1) ? 2.0.xx : 0.0.xx;
vpos = float4(uv * float2(2, -2) + float2(-1, 1), 0, 1);
}
#line 91
struct PSOUT1
{
float4 t0 : SV_Target0;
};
struct PSOUT2
{
float4 t0 : SV_Target0,
t1 : SV_Target1;
};
struct PSOUT3
{
float4 t0 : SV_Target0,
t1 : SV_Target1,
t2 : SV_Target2;
};
struct PSOUT4
{
float4 t0 : SV_Target0,
t1 : SV_Target1,
t2 : SV_Target2,
t3 : SV_Target3;
};
#line 132
float max3(float a, float b, float c){ return max(max(a, b), c);}float2 max3(float2 a, float2 b, float2 c){ return max(max(a, b), c);}float3 max3(float3 a, float3 b, float3 c){ return max(max(a, b), c);}float4 max3(float4 a, float4 b, float4 c){ return max(max(a, b), c);}int max3(int a, int b, int c){ return max(max(a, b), c);}int2 max3(int2 a, int2 b, int2 c){ return max(max(a, b), c);}int3 max3(int3 a, int3 b, int3 c){ return max(max(a, b), c);}int4 max3(int4 a, int4 b, int4 c){ return max(max(a, b), c);}
float max4(float a, float b, float c, float d){ return max(max(a, b), max(c, d));}float2 max4(float2 a, float2 b, float2 c, float2 d){ return max(max(a, b), max(c, d));}float3 max4(float3 a, float3 b, float3 c, float3 d){ return max(max(a, b), max(c, d));}float4 max4(float4 a, float4 b, float4 c, float4 d){ return max(max(a, b), max(c, d));}int max4(int a, int b, int c, int d){ return max(max(a, b), max(c, d));}int2 max4(int2 a, int2 b, int2 c, int2 d){ return max(max(a, b), max(c, d));}int3 max4(int3 a, int3 b, int3 c, int3 d){ return max(max(a, b), max(c, d));}int4 max4(int4 a, int4 b, int4 c, int4 d){ return max(max(a, b), max(c, d));}
float min3(float a, float b, float c){ return min(min(a, b), c);}float2 min3(float2 a, float2 b, float2 c){ return min(min(a, b), c);}float3 min3(float3 a, float3 b, float3 c){ return min(min(a, b), c);}float4 min3(float4 a, float4 b, float4 c){ return min(min(a, b), c);}int min3(int a, int b, int c){ return min(min(a, b), c);}int2 min3(int2 a, int2 b, int2 c){ return min(min(a, b), c);}int3 min3(int3 a, int3 b, int3 c){ return min(min(a, b), c);}int4 min3(int4 a, int4 b, int4 c){ return min(min(a, b), c);}
float min4(float a, float b, float c, float d){ return min(min(a, b), min(c, d));}float2 min4(float2 a, float2 b, float2 c, float2 d){ return min(min(a, b), min(c, d));}float3 min4(float3 a, float3 b, float3 c, float3 d){ return min(min(a, b), min(c, d));}float4 min4(float4 a, float4 b, float4 c, float4 d){ return min(min(a, b), min(c, d));}int min4(int a, int b, int c, int d){ return min(min(a, b), min(c, d));}int2 min4(int2 a, int2 b, int2 c, int2 d){ return min(min(a, b), min(c, d));}int3 min4(int3 a, int3 b, int3 c, int3 d){ return min(min(a, b), min(c, d));}int4 min4(int4 a, int4 b, int4 c, int4 d){ return min(min(a, b), min(c, d));}
float med3(float a, float b, float c) { return clamp(a, min(b, c), max(b, c));}int med3(int a, int b, int c) { return clamp(a, min(b, c), max(b, c));}
#line 144
float maxc(float  t) {return t;}
float maxc(float2 t) {return max(t.x, t.y);}
float maxc(float3 t) {return max3(t.x, t.y, t.z);}
float maxc(float4 t) {return max4(t.x, t.y, t.z, t.w);}
float minc(float  t) {return t;}
float minc(float2 t) {return min(t.x, t.y);}
float minc(float3 t) {return min3(t.x, t.y, t.z);}
float minc(float4 t) {return min4(t.x, t.y, t.z, t.w);}
float medc(float3 t) {return med3(t.x, t.y, t.z);}
#line 154
float4 tex2Dlod(sampler s, float2 uv, float mip)
{
return tex2Dlod(s, float4(uv, 0, mip));
}
#line 125 "C:\Program Files\GShade\gshade-shaders\Shaders\MartysMods_TODDYHANCER.fx"
#line 126
struct VSOUT
{
float4                  vpos        : SV_Position;
float2                  uv          : TEXCOORD0;
};
#line 136
static const float3x3 RGB = float3x3
(
2.67147117265996,-1.26723605786241,-0.410995602172227,
-1.02510702934664,1.98409116241089,0.0439502493584124,
0.0610009456429445,-0.223670750812863,1.15902104167061
);
#line 143
static const float3x3 XYZ = float3x3
(
0.500303383543316,0.338097573222739,0.164589779545857,
0.257968894274758,0.676195259144706,0.0658358459823868,
0.0234517888692628,0.1126992737203,0.866839673124201
);
#line 150
float4 DPXPass(float4 InputColor)
{
#line 153
float DPXContrast = 0.1;
#line 155
float DPXGamma = 1.0;
#line 157
float RedCurve = 8.0;
float GreenCurve = 8.0;
float BlueCurve = 8.0;
#line 161
float3 RGB_Curve = float3(8.0,8.0,8.0);
float3 RGB_C = float3(0.34,0.30,0.30);
#line 164
float3 B = InputColor.rgb;
#line 167
B = pow(abs(B), 1.0/DPXGamma);
#line 169
B = B * (1.0 - DPXContrast) + (0.5 * DPXContrast);
#line 174
float3 Btemp = (1.0 / (1.0 + exp(RGB_Curve / 2.0)));
B = ((1.0 / (1.0 + exp(-RGB_Curve * (B - RGB_C)))) / (-2.0 * Btemp + 1.0)) + (-Btemp / (-2.0 * Btemp + 1.0));
#line 179
float value = max(max(B.r, B.g), B.b);
float3 color = B / value;
#line 182
color = pow(abs(color), 1.0/2.5);
#line 184
float3 c0 = color * value;
#line 186
c0 = mul(XYZ, c0);
#line 188
float luma = dot(c0, float3(0.30, 0.59, 0.11)); 
#line 192
c0 = (1.0 - 2.0) * luma + 2.0 * c0;
#line 194
c0 = mul(RGB, c0);
#line 196
InputColor.rgb = lerp(InputColor.rgb, c0, 0.2);
#line 198
return InputColor;
}
#line 201
float4 TonemapPass( float4 colorInput )
{
float3 color = colorInput.rgb;
#line 205
color = saturate(color - 0.00 * float3(0.00, 0.50, 0.15)); 
#line 207
color *= pow(2.0f,  -2.60); 
#line 209
color = pow(color, .38);    
#line 215
float3 lumCoeff = float3(0.2126, 0.7152, 0.0722);
float lum = dot(lumCoeff, color.rgb);
#line 218
float3 blend = lum.rrr; 
#line 220
float L = saturate( 10.0 * (lum - 0.45) );
#line 222
float3 result1 = 2.0f * color.rgb * blend;
float3 result2 = 1.0f - 2.0f * (1.0f - blend) * (1.0f - color.rgb);
#line 225
float3 newColor = lerp(result1, result2, L);
#line 227
float3 A2 = .9 * color.rgb; 
float3 mixRGB = A2 * newColor;
#line 230
color.rgb += ((1.0f - A2) * mixRGB);
#line 233
float3 middlegray = dot(color,(1.0/3.0)); 
#line 235
float3 diffcolor = color - middlegray; 
colorInput.rgb = (color + diffcolor * .50)/(1+(diffcolor*.50)); 
#line 238
return colorInput;
}
#line 242
float4 VibrancePass( float4 colorInput )
{
#line 250
float4 color = colorInput; 
float3 lumCoeff = float3(0.212656, 0.715158, 0.072186);  
#line 253
float luma = dot(lumCoeff, color.rgb); 
#line 256
float max_color = max(colorInput.r, max(colorInput.g,colorInput.b)); 
float min_color = min(colorInput.r, min(colorInput.g,colorInput.b)); 
#line 259
float color_saturation = max_color - min_color; 
#line 293
color.rgb = lerp(luma, color.rgb, (1.0 + (float3(float3(1.00, 1.00, 1.00) * 0.20) * (1.0 - (sign(float3(float3(1.00, 1.00, 1.00) * 0.20)) * color_saturation))))); 
#line 297
return color; 
#line 299
}
#line 303
float4 CurvesPass( float4 colorInput )
{
float3 lumCoeff = float3(0.2126, 0.7152, 0.0722);  
float Curves_contrast_blend = 1.2;
#line 329
float3 x = colorInput.rgb; 
#line 343
x = sin(3.1415927 * 0.5 * x); 
x *= x;
#line 526
float3 color = x;  
colorInput.rgb = lerp(colorInput.rgb, color, Curves_contrast_blend); 
#line 541
return colorInput;
}
#line 545
float4 SepiaPass( float4 colorInput )
{
float3 sepia = colorInput.rgb;
#line 550
float grey = dot(sepia, float3(0.2126, 0.7152, 0.0722));
#line 552
sepia *= float3(1.1, 1.00, 1.0);
#line 554
float3 blend2 = (grey * 0.40) + (colorInput.rgb / (0.40 + 1));
#line 556
colorInput.rgb = lerp(blend2, sepia, 0.40);
#line 559
return colorInput;
}
#line 566
VSOUT MainVS(in uint id : SV_VertexID)
{
VSOUT o;
FullscreenTriangleVS(id, o.vpos, o.uv);
return o;
}
#line 573
void MainPS(in VSOUT i, out float3 o : SV_Target0)
{
float3 ori = tex2D(ColorInput, i.uv).rgb;
float3 sharp_strength_luma = (float3(0.2126, 0.7152, 0.0722) * 2.07);
#line 579
float3 blur_ori = tex2D(ColorInput, i.uv + BUFFER_PIXEL_SIZE *  float2(0.5,-1.7)).rgb;  
blur_ori += tex2D(ColorInput, i.uv + BUFFER_PIXEL_SIZE *        float2(-1.7,-0.5)).rgb; 
blur_ori += tex2D(ColorInput, i.uv + BUFFER_PIXEL_SIZE *        float2(1.7,0.5)).rgb; 
blur_ori += tex2D(ColorInput, i.uv + BUFFER_PIXEL_SIZE *        float2(-0.5, 1.7)).rgb; 
blur_ori *= 0.25;
sharp_strength_luma *= 0.666;
#line 586
float3 sharp = ori - blur_ori;
float4 sharp_strength_luma_clamp = float4(sharp_strength_luma * (0.5 / 0.048),0.5);
float sharp_luma = saturate(dot(float4(sharp,1.0), sharp_strength_luma_clamp)); 
sharp_luma = (0.048 * 2.0) * sharp_luma - 0.048;
#line 591
o = ori + sharp_luma;
#line 594
o = saturate(((o) - (10.0/255.0)) * rcp((1.0) - (10.0/255.0))); 
#line 596
o = DPXPass(o.xyzz).xyz;
o = TonemapPass(o.xyzz).xyz;
o = VibrancePass(o.xyzz).xyz;
o = CurvesPass(o.xyzz).xyz;
o = SepiaPass(o.xyzz).xyz;
}
#line 608
technique MartysMods_Toddyhancer
<
ui_label = "METEOR: ToddyHancer";
ui_tooltip =
"                            MartysMods - ToddyHancer                          \n"
"                   Marty's Extra Effects for ReShade (METEOR)                 \n"
"______________________________________________________________________________\n"
"\n"
#line 617
"This is a direct port of the ToddyHancer 'mod' that became popular in 2017 but\n"
"was never released. I found the original files and it's essentially a SweetFX \n"
"preset.                                                                       \n"
"\n"
"\n"
"Visit https://martysmods.com for more information.                            \n"
"\n"
"______________________________________________________________________________";
>
{
pass
{
VertexShader = MainVS;
PixelShader  = MainPS;
}
}

