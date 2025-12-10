#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Retro_Neon.fx"
#line 24
uniform float GLOW_COLOR <
ui_type = "slider";
ui_label = "Glow Color";
ui_min = 0.0;
ui_max = 1.0;
> = 0.567;
#line 31
uniform bool USE_PING
<
ui_label = "Use Radar Ping Effect";
> = true;
#line 36
uniform float LENS_DISTORT <
ui_type = "slider";
ui_label = "Lens Distortion Intensity";
ui_min = 0.0;
ui_max = 1.0;
> = 0.2;
#line 43
uniform float CHROMA_SHIFT <
ui_type = "slider";
ui_label = "Chromatic Aberration Intensity";
ui_min = -1.0;
ui_max = 1.0;
> = 0.5;
#line 50
uniform float EDGES_AMT <
ui_type = "slider";
ui_label = "Edge Amount";
ui_min = 0.0;
ui_max = 1.0;
> = 0.1;
#line 65
uniform bool DEBUG_CHEAT_MASK = false;
uniform bool DEBUG_LINE_MODE = false;
uniform bool DEBUG_FADE_MULT = 0.0;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_common.fxh"
#line 111
namespace qUINT
{
uniform float FRAME_TIME < source = "frametime"; >;
uniform int FRAME_COUNT < source = "framecount"; >;
#line 124
static const float2 ASPECT_RATIO 	= float2(1.0, 1920 * (1.0 / 1018));
static const float2 PIXEL_SIZE 		= float2((1.0 / 1920), (1.0 / 1018));
static const float2 SCREEN_SIZE 	= float2(1920, 1018);
#line 130
texture BackBufferTex : COLOR;
texture DepthBufferTex : DEPTH;
#line 133
sampler sBackBufferTex 	{ Texture = BackBufferTex; 	};
sampler sDepthBufferTex { Texture = DepthBufferTex; };
#line 136
float2 depthtex_uv(float2 uv)
{
#line 141
uv.x /= 1;
uv.y /= 1;
#line 145
 
uv.x -= 0 / 2.000000001;
#line 151
uv.y += 0 / 2.000000001;
#line 153
return uv;
}
#line 156
float get_depth(float2 uv)
{
float depth = tex2Dlod(sDepthBufferTex, float4(depthtex_uv(uv), 0, 0)).x;
return depth;
}
#line 162
float linearize_depth(float depth)
{
depth *= 1;
#line 176
const float N = 1.0;
depth /= 1000.0 - depth * (1000.0 - N);
#line 179
return saturate(depth);
}
#line 183
float linear_depth(float2 uv)
{
float depth = get_depth(uv);
depth = linearize_depth(depth);
return depth;
}
}
#line 192
void PostProcessVS(in uint id : SV_VertexID, out float4 vpos : SV_Position, out float2 uv : TEXCOORD)
{
uv.x = (id == 2) ? 2.0 : 0.0;
uv.y = (id == 1) ? 2.0 : 0.0;
vpos = float4(uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
#line 75 "C:\Program Files\GShade\gshade-shaders\Shaders\Retro_Neon.fx"
uniform float timer < source = "timer"; >;
#line 78
texture2D TempTex0 	{ Width = 1920;   Height = 1018;   Format = RGBA16F; };
texture2D TempTex1 	{ Width = 1920;   Height = 1018;   Format = RGBA16F; };
#line 81
sampler2D sTempTex0	{ Texture = TempTex0;	};
sampler2D sTempTex1	{ Texture = TempTex1;	};
#line 84
texture2D GlowTex0 	{ Width = 1920/2;   Height = 1018/2;   Format = RGBA16F; };
texture2D GlowTex1 	{ Width = 1920/4;   Height = 1018/4;   Format = RGBA16F; };
texture2D GlowTex2 	{ Width = 1920/8;   Height = 1018/8;   Format = RGBA16F; };
texture2D GlowTex3 	{ Width = 1920/16;   Height = 1018/16;   Format = RGBA16F; };
texture2D GlowTex4 	{ Width = 1920/32;   Height = 1018/32;   Format = RGBA16F; };
#line 90
sampler2D sGlowTex0	{ Texture = GlowTex0;	};
sampler2D sGlowTex1	{ Texture = GlowTex1;	};
sampler2D sGlowTex2	{ Texture = GlowTex2;	};
sampler2D sGlowTex3	{ Texture = GlowTex3;	};
sampler2D sGlowTex4	{ Texture = GlowTex4;	};
#line 100
struct VSOUT
{
float4                  vpos        : SV_Position;
float2                  uv          : TEXCOORD0;
nointerpolation float3  uvtoviewADD : TEXCOORD2;
nointerpolation float3  uvtoviewMUL : TEXCOORD3;
};
#line 108
VSOUT VSMain(in uint id : SV_VertexID)
{
VSOUT o;
#line 112
if (id == 2)
o.uv.x = 2.0;
else
o.uv.x = 0.0;
if (id == 1)
o.uv.y = 2.0;
else
o.uv.y = 0.0;
#line 121
o.vpos = float4(o.uv.xy * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
#line 123
o.uvtoviewADD = float3(-1.0,-1.0,1.0);
o.uvtoviewMUL = float3(2.0,2.0,0.0);
#line 126
return o;
}
#line 133
float depth_to_distance(in float depth)
{
return depth * 1000.0 + 1;
}
#line 138
float3 get_position_from_uv(in VSOUT i)
{
return (i.uv.xyx * i.uvtoviewMUL + i.uvtoviewADD) * depth_to_distance(qUINT::linear_depth(i.uv.xy));
}
#line 143
float3 get_position_from_uv(in VSOUT i, in float2 uv)
{
return (uv.xyx * i.uvtoviewMUL + i.uvtoviewADD) * depth_to_distance(qUINT::linear_depth(uv));
}
#line 148
float4 gaussian_1D(in VSOUT i, in sampler input_tex, int kernel_size, float2 axis)
{
float4 sum = tex2D(input_tex, i.uv);
float weightsum = 1;
#line 153
[unroll]
for(float j = 1; j <= kernel_size; j++)
{
float w = exp(-2 * j * j / (kernel_size * kernel_size));
sum += tex2Dlod(input_tex, float4(i.uv + qUINT::PIXEL_SIZE * axis * (j * 2 - 0.5), 0, 0)) * w;
sum += tex2Dlod(input_tex, float4(i.uv - qUINT::PIXEL_SIZE * axis * (j * 2 - 0.5), 0, 0)) * w;
weightsum += w * 2;
}
return sum / weightsum;
}
#line 164
float4 downsample(sampler2D tex, float2 tex_size, float2 uv)
{
float4 offset_uv = 0;
#line 168
const float2 kernel_small_offsets = float2(2.0,2.0) / tex_size;
const float2 kernel_large_offsets = float2(4.0,4.0) / tex_size;
#line 171
const float4 kernel_center = tex2D(tex, uv);
#line 173
float4 kernel_small = 0;
#line 175
offset_uv.xy = uv + kernel_small_offsets;
kernel_small += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x - kernel_small_offsets.x;
kernel_small += tex2Dlod(tex, offset_uv); 
offset_uv.y = uv.y - kernel_small_offsets.y;
kernel_small += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x + kernel_small_offsets.x;
kernel_small += tex2Dlod(tex, offset_uv); 
#line 184
float4 kernel_large_1 = 0;
#line 186
offset_uv.xy = uv + kernel_large_offsets;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x - kernel_large_offsets.x;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
offset_uv.y = uv.y - kernel_large_offsets.y;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x + kernel_large_offsets.x;
kernel_large_1 += tex2Dlod(tex, offset_uv); 
#line 195
float4 kernel_large_2 = 0;
#line 197
offset_uv.xy = uv;
offset_uv.x += kernel_large_offsets.x;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
offset_uv.x -= kernel_large_offsets.x * 2.0;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
offset_uv.x = uv.x;
offset_uv.y += kernel_large_offsets.y;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
offset_uv.y -= kernel_large_offsets.y * 2.0;
kernel_large_2 += tex2Dlod(tex, offset_uv); 
#line 208
return kernel_center * 0.5 / 4.0
+ kernel_small  * 0.5 / 4.0
+ kernel_large_1 * 0.125 / 4.0
+ kernel_large_2 * 0.25 / 4.0;
}
#line 214
float3 hue_to_rgb(float hue)
{
return saturate(float3(abs(hue * 6.0 - 3.0) - 1.0,
2.0 - abs(hue * 6.0 - 2.0),
2.0 - abs(hue * 6.0 - 4.0)));
}
#line 225
void PrepareInput(in VSOUT i, out float4 o : SV_Target0)
{
float4 A, B, C, D, E, F, G, H, I;
#line 229
float3 offsets = float3(1, 0, -1);
#line 237
A.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.zz * qUINT::PIXEL_SIZE).rgb;
B.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.yz * qUINT::PIXEL_SIZE).rgb;
C.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.xz * qUINT::PIXEL_SIZE).rgb;
D.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.zy * qUINT::PIXEL_SIZE).rgb;
E.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.yy * qUINT::PIXEL_SIZE).rgb;
F.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.xy * qUINT::PIXEL_SIZE).rgb;
G.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.zx * qUINT::PIXEL_SIZE).rgb;
H.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.yx * qUINT::PIXEL_SIZE).rgb;
I.rgb = tex2D(qUINT::sBackBufferTex, i.uv + offsets.xx * qUINT::PIXEL_SIZE).rgb;
#line 247
A.w = qUINT::linear_depth(i.uv + offsets.zz * qUINT::PIXEL_SIZE);
B.w = qUINT::linear_depth(i.uv + offsets.yz * qUINT::PIXEL_SIZE);
C.w = qUINT::linear_depth(i.uv + offsets.xz * qUINT::PIXEL_SIZE);
D.w = qUINT::linear_depth(i.uv + offsets.zy * qUINT::PIXEL_SIZE);
E.w = qUINT::linear_depth(i.uv + offsets.yy * qUINT::PIXEL_SIZE);
F.w = qUINT::linear_depth(i.uv + offsets.xy * qUINT::PIXEL_SIZE);
G.w = qUINT::linear_depth(i.uv + offsets.zx * qUINT::PIXEL_SIZE);
H.w = qUINT::linear_depth(i.uv + offsets.yx * qUINT::PIXEL_SIZE);
I.w = qUINT::linear_depth(i.uv + offsets.xx * qUINT::PIXEL_SIZE);
#line 257
float3 color_edge;
{
const float3 corners = (A.rgb + C.rgb) + (G.rgb + I.rgb);
const float3 neighbours = (B.rgb + D.rgb) + (F.rgb + H.rgb);
const float3 center = E.rgb;
#line 263
color_edge = corners + 2.0 * neighbours - 12.0 * center;
#line 265
}
#line 267
const float depth_delta_x1 = D.w - E.w;
const float depth_delta_x2 = E.w - F.w;
#line 270
float depth_edge_x;
if (abs(depth_delta_x1) < abs(depth_delta_x2))
depth_edge_x = depth_delta_x1;
else
depth_edge_x = depth_delta_x2;
#line 277
const float depth_delta_y1 = B.w - E.w;
const float depth_delta_y2 = E.w - H.w;
#line 280
float depth_edge_y;
if (abs(depth_delta_y1) < abs(depth_delta_y2))
depth_edge_y = depth_delta_y1;
else
depth_edge_y = depth_delta_y2;
#line 286
o.xyz = normalize(float3(depth_edge_x, depth_edge_y, 0.000001));
o.w = smoothstep(0.15, 0.25, sqrt(dot(color_edge, color_edge))); 
}
#line 290
void Filter_Input_A(in VSOUT i, out float4 o : SV_Target0)
{
o = gaussian_1D(i, sTempTex0, 1, float2(0, 1));
}
#line 295
void Filter_Input_B(in VSOUT i, out float4 o : SV_Target0)
{
o = gaussian_1D(i, sTempTex1, 1, float2(1, 0));
}
#line 300
void GenerateEdges(in VSOUT i, out float4 o : SV_Target0)
{
if(DEBUG_LINE_MODE)
{
float3 blurred = 0;
#line 306
[unroll]
for(int x = -2; x<=2; x++)
[unroll]
for(int y = -2; y<=2; y++)
{
blurred += tex2D(sTempTex0, i.uv, int2(x, y)).xyz;
}
#line 314
o = dot(normalize(blurred), tex2D(sTempTex0, i.uv).xyz);
o = smoothstep(1, 0.7 * EDGES_AMT, o);
#line 317
}else{
#line 319
float3x3 sobel = float3x3(1, 2, 1, 0, 0, 0, -1, -2, -1);
#line 321
float3 sobelx = 0, sobely = 0;
#line 323
[unroll]
for(int x = 0; x < 3; x++)
[unroll]
for(int y = 0; y < 3; y++)
{
float3 n = tex2D(sTempTex0, i.uv, int2(x - 1, y - 1)).xyz;
sobelx += n * sobel[x][y];
sobely += n * sobel[y][x];
}
#line 333
o = pow(abs(EDGES_AMT * 0.2 * (dot(sobelx, sobelx) + dot(sobely, sobely))), 1.5);
}
#line 336
o *= smoothstep(0.5,0.48, max(abs(i.uv.x-0.5), abs(i.uv.y-0.5))); 
o.w = tex2D(sTempTex0, i.uv).w; 
}
#line 340
void Downsample0(in VSOUT i, out float4 o : SV_Target0)
{
o = downsample(sTempTex1, qUINT::SCREEN_SIZE, i.uv);
#line 345
o *= saturate(1.0 - qUINT::linear_depth(i.uv) * 40.0 * DEBUG_FADE_MULT);
}
void Downsample1(in VSOUT i, out float4 o : SV_Target0)
{
o = downsample(sGlowTex0, qUINT::SCREEN_SIZE/2, i.uv);
}
void Downsample2(in VSOUT i, out float4 o : SV_Target0)
{
o = downsample(sGlowTex1, qUINT::SCREEN_SIZE/4, i.uv);
}
void Downsample3(in VSOUT i, out float4 o : SV_Target0)
{
o = downsample(sGlowTex2, qUINT::SCREEN_SIZE/8, i.uv);
}
void Downsample4(in VSOUT i, out float4 o : SV_Target0)
{
o = downsample(sGlowTex3, qUINT::SCREEN_SIZE/16, i.uv);
}
#line 364
void Combine(in VSOUT i, out float4 o : SV_Target0)
{
o = 0;
#line 368
const float depth = qUINT::linear_depth(i.uv);
#line 370
const float lines = tex2D(sTempTex1, i.uv).x * 0.63;
#line 372
const float glow = tex2D(sGlowTex0, i.uv).x * 0.07
+ tex2D(sGlowTex1, i.uv).x * 1.08
+ tex2D(sGlowTex2, i.uv).x * 0.92
+ tex2D(sGlowTex3, i.uv).x * 0.95
+ tex2D(sGlowTex4, i.uv).x * 0.5;
#line 378
float wave = frac(sqrt(length(get_position_from_uv(i)))*0.09 - (timer % 100000)* 0.003*0.1);
wave = wave*wave*wave*wave*wave*0.8;
#line 384
wave *= saturate(1.0 - depth * 50.0 * DEBUG_FADE_MULT);
#line 386
if(!USE_PING) wave = 0;
#line 388
o.rgb = lines + (lines + glow + wave) * hue_to_rgb(GLOW_COLOR);
#line 390
if(DEBUG_CHEAT_MASK) o.rgb *= tex2D(sGlowTex2, i.uv).w * 2.0;
o.w = 1;
}
#line 394
void PostFX(in VSOUT i, out float4 o : SV_Target0)
{
#line 404
o = 0;
#line 406
float3 offsets[5] =
{
float3(1.5, 0.5,4),
float3(-1.5, -0.5,4),
float3(-0.5, 1.5,4),
float3(0.5, -1.5,4),
float3(0,0,1)
};
#line 415
for(int j = 0; j < 5; j++)
{
const float2 uv = i.uv.xy - 0.5;
const float distort = 1 + dot(uv, uv) * 0 + dot(uv, uv) * dot(uv, uv) * -(LENS_DISTORT * 0.9 + 0.5);
o.x += tex2D(qUINT::sBackBufferTex, (i.uv.xy-0.5) * (1 - 0.008 * CHROMA_SHIFT) * distort + 0.5 + offsets[j].xy * qUINT::PIXEL_SIZE).x * offsets[j].z;
o.y += tex2D(qUINT::sBackBufferTex, (i.uv.xy-0.5) * (1       )  * distort + 0.5 + offsets[j].xy * qUINT::PIXEL_SIZE).y * offsets[j].z;
o.z += tex2D(qUINT::sBackBufferTex, (i.uv.xy-0.5) * (1 + 0.008 * CHROMA_SHIFT) * distort + 0.5 + offsets[j].xy * qUINT::PIXEL_SIZE).z * offsets[j].z;
o.w += offsets[j].z;
}
#line 425
o /= o.w;
}
#line 432
technique TRON
{
pass
{
VertexShader = VSMain;
PixelShader  = PrepareInput;
RenderTarget = TempTex0;
}
pass
{
VertexShader = VSMain;
PixelShader  = Filter_Input_A;
RenderTarget = TempTex1;
}
pass
{
VertexShader = VSMain;
PixelShader  = Filter_Input_B;
RenderTarget = TempTex0;
}
pass
{
VertexShader = VSMain;
PixelShader  = GenerateEdges;
RenderTarget = TempTex1;
}
pass
{
VertexShader = VSMain;
PixelShader  = Downsample0;
RenderTarget = GlowTex0;
}
pass
{
VertexShader = VSMain;
PixelShader  = Downsample1;
RenderTarget = GlowTex1;
}
pass
{
VertexShader = VSMain;
PixelShader  = Downsample2;
RenderTarget = GlowTex2;
}
pass
{
VertexShader = VSMain;
PixelShader  = Downsample3;
RenderTarget = GlowTex3;
}
pass
{
VertexShader = VSMain;
PixelShader  = Downsample4;
RenderTarget = GlowTex4;
}
pass
{
VertexShader = VSMain;
PixelShader  = Combine;
}
pass
{
VertexShader = VSMain;
PixelShader  = PostFX;
}
}

