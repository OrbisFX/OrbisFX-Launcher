#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_deband.fx"
#line 25
uniform float SEARCH_RADIUS <
ui_type = "slider";
ui_min = 0.0;
ui_max = 1.0;
ui_label = "Debanding Search Radius";
> = 0.5;
#line 32
uniform int BIT_DEPTH <
ui_type = "slider";
ui_min = 4; ui_max = 10;
ui_label = "Bit depth of data to be debanded";
> = 8;
#line 38
uniform bool AUTOMATE_BIT_DEPTH <
ui_label = "Automatic bit depth detection";
> = true;
#line 42
uniform int DEBAND_MODE <
ui_type = "radio";
ui_label = "Dither mode";
ui_items = "None\0Dither\0Deband\0";
> = 2;
#line 48
uniform bool SKY_ONLY <
ui_label = "Apply to sky only";
> = false;
#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_common.fxh"
#line 111
namespace qUINT
{
uniform float FRAME_TIME < source = "frametime"; >;
uniform int FRAME_COUNT < source = "framecount"; >;
#line 124
static const float2 ASPECT_RATIO 	= float2(1.0, 1280 * (1.0 / 720));
static const float2 PIXEL_SIZE 		= float2((1.0 / 1280), (1.0 / 720));
static const float2 SCREEN_SIZE 	= float2(1280, 720);
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
#line 58 "C:\Program Files\GShade\gshade-shaders\Shaders\qUINT_deband.fx"
#line 63
struct VSOUT
{
float4                  vpos        : SV_Position;
float2                  uv          : TEXCOORD0;
};
#line 69
VSOUT VSMain(in uint id : SV_VertexID)
{
VSOUT o;
PostProcessVS(id, o.vpos, o.uv); 
return o;
}
#line 84
void PSMain(in VSOUT i, out float3 o : SV_Target0)
{
o = tex2D(qUINT::sBackBufferTex, i.uv).rgb;
#line 88
const float2 magicdot = float2(0.75487766624669276, 0.569840290998);
const float3 magicadd = float3(0, 0.025, 0.0125) * dot(magicdot, 1);
float3 dither = frac(dot(i.vpos.xy, magicdot) + magicadd);
#line 92
if(SKY_ONLY)
{
if(qUINT::linear_depth(i.uv) < 0.98) return;
}
#line 97
float bit_depth = AUTOMATE_BIT_DEPTH ? 8 : BIT_DEPTH;
float lsb = rcp(exp2(bit_depth) - 1.0);
#line 100
if(DEBAND_MODE == 2)
{
float2 shift;
sincos(6.283 * 30.694 * dither.x, shift.x, shift.y);
shift = shift * sqrt(dither.y);
#line 106
float3 scatter = tex2Dlod(qUINT::sBackBufferTex, float4(i.uv + shift * 0.025 * SEARCH_RADIUS, 0, 0)).rgb;
float4 diff;
diff.rgb = abs(o.rgb - scatter);
diff.w = max(max(diff.x, diff.y), diff.z);
#line 111
o = lerp(o, scatter, diff.w <= lsb);
}
else if(DEBAND_MODE == 1)
{
o += (dither - 0.5) * lsb;
}
}
#line 123
technique Debanding
< ui_tooltip = "                     >> qUINT::Debanding <<\n\n"
"This is a simple debanding filter, which aims to hide color\n"
"quantization artifacts in games. \n"
"\nqUINT Debanding is written by Marty McFly / Pascal Gilcher"; >
{
pass
{
VertexShader = VSMain;
PixelShader  = PSMain;
}
}

