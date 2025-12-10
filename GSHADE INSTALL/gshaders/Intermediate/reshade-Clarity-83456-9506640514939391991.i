#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\Clarity.fx"
#line 7
uniform int ClarityRadius
<
ui_type = "slider";
ui_min = 0; ui_max = 4;
ui_tooltip = "[0|1|2|3|4] Higher values will increase the radius of the effect.";
ui_step = 1.00;
> = 3;
#line 15
uniform float ClarityOffset
<
ui_type = "slider";
ui_min = 1.00; ui_max = 5.00;
ui_tooltip = "Additional adjustment for the blur radius. Increasing the value will increase the radius.";
ui_step = 1.00;
> = 2.00;
#line 23
uniform int ClarityBlendMode
<
ui_type = "combo";
ui_items = "\Soft Light\0Overlay\0Hard Light\0Multiply\0Vivid Light\0Linear Light\0Addition";
ui_tooltip = "Blend modes determine how the clarity mask is applied to the original image";
> = 2;
#line 30
uniform int ClarityBlendIfDark
<
ui_type = "slider";
ui_min = 0; ui_max = 255;
ui_tooltip = "Any pixels below this value will be excluded from the effect. Set to 50 to target mid-tones.";
ui_step = 5;
> = 50;
#line 38
uniform int ClarityBlendIfLight
<
ui_type = "slider";
ui_min = 0; ui_max = 255;
ui_tooltip = "Any pixels above this value will be excluded from the effect. Set to 205 to target mid-tones.";
ui_step = 5;
> = 205;
#line 46
uniform bool ClarityViewBlendIfMask
<
ui_tooltip = "The mask used for BlendIf settings. The effect will not be applied to areas covered in black";
> = false;
#line 51
uniform float ClarityStrength
<
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Adjusts the strength of the effect";
> = 0.400;
#line 58
uniform float ClarityDarkIntensity
<
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Adjusts the strength of dark halos.";
> = 0.400;
#line 65
uniform float ClarityLightIntensity
<
ui_type = "slider";
ui_min = 0.00; ui_max = 1.00;
ui_tooltip = "Adjusts the strength of light halos.";
> = 0.000;
#line 72
uniform bool ClarityViewMask
<
ui_tooltip = "The mask is what creates the effect. View it when making adjustments to get a better idea of how your changes will affect the image.";
> = false;
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
#line 78 "C:\Program Files\GShade\gshade-shaders\Shaders\Clarity.fx"
#line 79
texture ClarityTex < pooled = true; > { Width = 1920 * 0.5; Height = 1018 * 0.5; Format = R8; };
texture ClarityTex2 { Width = 1920 * 0.5; Height = 1018 * 0.5; Format = R8; };
texture ClarityTex3 < pooled = true; > { Width = 1920 * 0.25; Height = 1018 * 0.25; Format = R8; };
#line 83
sampler ClaritySampler { Texture = ClarityTex;};
sampler ClaritySampler2 { Texture = ClarityTex2;};
sampler ClaritySampler3 { Texture = ClarityTex3;};
#line 87
float3 ClarityFinal(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
#line 90
float color = tex2D(ClaritySampler3, texcoord).r;
#line 92
if(ClarityRadius == 0)
{
const float offset[4] = { 0.0, 1.1824255238, 3.0293122308, 5.0040701377 };
const float weight[4] = { 0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842 };
#line 97
color *= weight[0];
#line 99
[loop]
for(int i = 1; i < 4; ++i)
{
color += tex2Dlod(ClaritySampler3, float4(texcoord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r * weight[i];
color += tex2Dlod(ClaritySampler3, float4(texcoord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r * weight[i];
}
}
#line 107
if(ClarityRadius == 1)
{
const float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 112
color *= weight[0];
#line 114
[loop]
for(int i = 1; i < 6; ++i)
{
color += tex2Dlod(ClaritySampler3, float4(texcoord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r * weight[i];
color += tex2Dlod(ClaritySampler3, float4(texcoord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r * weight[i];
}
}
#line 122
if(ClarityRadius == 2)
{
const float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
const float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 127
color *= weight[0];
#line 129
[loop]
for(int i = 1; i < 11; ++i)
{
color += tex2Dlod(ClaritySampler3, float4(texcoord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r * weight[i];
color += tex2Dlod(ClaritySampler3, float4(texcoord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r * weight[i];
}
}
#line 137
if(ClarityRadius == 3)
{
const float offset[15] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4401038149, 21.43402885, 23.4279736431, 25.4219399344, 27.4159294386 };
const float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
#line 142
color *= weight[0];
#line 144
[loop]
for(int i = 1; i < 15; ++i)
{
color += tex2Dlod(ClaritySampler3, float4(texcoord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r * weight[i];
color += tex2Dlod(ClaritySampler3, float4(texcoord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r * weight[i];
}
}
#line 152
if(ClarityRadius == 4)
{
const float offset[18] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4661974725, 21.4627427973, 23.4592916956, 25.455844494, 27.4524015179, 29.4489630909, 31.445529535, 33.4421011704 };
const float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
#line 157
color *= weight[0];
#line 159
[loop]
for(int i = 1; i < 18; ++i)
{
color += tex2Dlod(ClaritySampler3, float4(texcoord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r * weight[i];
color += tex2Dlod(ClaritySampler3, float4(texcoord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r * weight[i];
}
}
#line 167
float3 orig = tex2D(ReShade::BackBuffer, texcoord).rgb; 
float luma = dot(orig.rgb,float3(0.32786885,0.655737705,0.0163934436));
float3 chroma = orig.rgb/luma;
#line 171
float sharp = 1-color;
sharp = (luma+sharp)*0.5;
#line 174
float sharpMin = lerp(0.0,1.0,smoothstep(0.0,1.0,sharp));
float sharpMax = sharpMin;
sharpMin = lerp(sharp,sharpMin,ClarityDarkIntensity);
sharpMax = lerp(sharp,sharpMax,ClarityLightIntensity);
sharp = lerp(sharpMin,sharpMax,step(0.5,sharp));
#line 180
if(ClarityViewMask)
{
orig.rgb = sharp;
luma = sharp;
chroma = 1.0;
}
else
{
if(ClarityBlendMode == 0)
{
#line 191
sharp = lerp(2*luma*sharp + luma*luma*(1.0-2*sharp), 2*luma*(1.0-sharp)+pow(luma,0.5)*(2*sharp-1.0), step(0.49,sharp));
}
#line 194
if(ClarityBlendMode == 1)
{
#line 197
sharp = lerp(2*luma*sharp, 1.0 - 2*(1.0-luma)*(1.0-sharp), step(0.50,luma));
}
#line 200
if(ClarityBlendMode == 2)
{
#line 203
sharp = lerp(2*luma*sharp, 1.0 - 2*(1.0-luma)*(1.0-sharp), step(0.50,sharp));
}
#line 206
if(ClarityBlendMode == 3)
{
#line 209
sharp = saturate(2 * luma * sharp);
}
#line 212
if(ClarityBlendMode == 4)
{
#line 215
sharp = lerp(2*luma*sharp, luma/(2*(1-sharp)), step(0.5,sharp));
}
#line 218
if(ClarityBlendMode == 5)
{
#line 221
sharp = luma + 2.0*sharp-1.0;
}
#line 224
if(ClarityBlendMode == 6)
{
#line 227
sharp = saturate(luma + (sharp - 0.5));
}
}
#line 231
if( ClarityBlendIfDark > 0 || ClarityBlendIfLight < 255 || ClarityViewBlendIfMask)
{
const float ClarityBlendIfD = (ClarityBlendIfDark/255.0)+0.0001;
const float ClarityBlendIfL = (ClarityBlendIfLight/255.0)-0.0001;
const float mix = dot(orig.rgb, 0.333333);
float mask = 1.0;
#line 238
if(ClarityBlendIfDark > 0)
{
mask = lerp(0.0,1.0,smoothstep(ClarityBlendIfD-(ClarityBlendIfD*0.2),ClarityBlendIfD+(ClarityBlendIfD*0.2),mix));
}
#line 243
if(ClarityBlendIfLight < 255)
{
mask = lerp(mask,0.0,smoothstep(ClarityBlendIfL-(ClarityBlendIfL*0.2),ClarityBlendIfL+(ClarityBlendIfL*0.2),mix));
}
#line 248
sharp = lerp(luma,sharp,mask);
#line 250
if (ClarityViewBlendIfMask)
{
sharp = mask;
luma = mask;
chroma = 1.0;
}
}
#line 258
orig.rgb = lerp(luma, sharp, ClarityStrength);
orig.rgb *= chroma;
#line 261
return saturate(orig);
}
#line 264
float Clarity1(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 268
if(ClarityRadius == 0)
{
const float offset[4] = { 0.0, 1.1824255238, 3.0293122308, 5.0040701377 };
const float weight[4] = { 0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842 };
#line 273
color *= weight[0];
#line 275
[loop]
for(int i = 1; i < 4; ++i)
{
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).rgb * weight[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).rgb * weight[i];
}
}
#line 283
if(ClarityRadius == 1)
{
const float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 288
color *= weight[0];
#line 290
[loop]
for(int i = 1; i < 6; ++i)
{
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).rgb * weight[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).rgb * weight[i];
}
}
#line 298
if(ClarityRadius == 2)
{
const float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
const float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 303
color *= weight[0];
#line 305
[loop]
for(int i = 1; i < 11; ++i)
{
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).rgb * weight[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).rgb * weight[i];
}
}
#line 313
if(ClarityRadius == 3)
{
const float offset[15] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4401038149, 21.43402885, 23.4279736431, 25.4219399344, 27.4159294386 };
const float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
#line 318
color *= weight[0];
#line 320
[loop]
for(int i = 1; i < 15; ++i)
{
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).rgb * weight[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).rgb * weight[i];
}
}
#line 328
if(ClarityRadius == 4)
{
const float offset[18] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4661974725, 21.4627427973, 23.4592916956, 25.455844494, 27.4524015179, 29.4489630909, 31.445529535, 33.4421011704 };
const float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
#line 333
color *= weight[0];
#line 335
[loop]
for(int i = 1; i < 18; ++i)
{
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).rgb * weight[i];
color += tex2Dlod(ReShade::BackBuffer, float4(texcoord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).rgb * weight[i];
}
}
#line 343
return dot(color.rgb,float3(0.32786885,0.655737705,0.0163934436));
}
#line 346
float Clarity2(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float color = tex2D(ClaritySampler, texcoord).r;
#line 350
if(ClarityRadius == 0)
{
const float offset[4] = { 0.0, 1.1824255238, 3.0293122308, 5.0040701377 };
const float weight[4] = { 0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842 };
#line 355
color *= weight[0];
#line 357
[loop]
for(int i = 1; i < 4; ++i)
{
color += tex2Dlod(ClaritySampler, float4(texcoord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r* weight[i];
color += tex2Dlod(ClaritySampler, float4(texcoord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r* weight[i];
}
}
#line 365
if(ClarityRadius == 1)
{
const float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 370
color *= weight[0];
#line 372
[loop]
for(int i = 1; i < 6; ++i)
{
color += tex2Dlod(ClaritySampler, float4(texcoord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r* weight[i];
color += tex2Dlod(ClaritySampler, float4(texcoord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r* weight[i];
}
}
#line 380
if(ClarityRadius == 2)
{
const float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
const float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 385
color *= weight[0];
#line 387
[loop]
for(int i = 1; i < 11; ++i)
{
color += tex2Dlod(ClaritySampler, float4(texcoord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r* weight[i];
color += tex2Dlod(ClaritySampler, float4(texcoord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r* weight[i];
}
}
#line 395
if(ClarityRadius == 3)
{
const float offset[15] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4401038149, 21.43402885, 23.4279736431, 25.4219399344, 27.4159294386 };
const float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
#line 400
color *= weight[0];
#line 402
[loop]
for(int i = 1; i < 15; ++i)
{
color += tex2Dlod(ClaritySampler, float4(texcoord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r* weight[i];
color += tex2Dlod(ClaritySampler, float4(texcoord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r* weight[i];
}
}
#line 410
if(ClarityRadius == 4)
{
const float offset[18] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4661974725, 21.4627427973, 23.4592916956, 25.455844494, 27.4524015179, 29.4489630909, 31.445529535, 33.4421011704 };
const float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
#line 415
color *= weight[0];
#line 417
[loop]
for(int i = 1; i < 18; ++i)
{
color += tex2Dlod(ClaritySampler, float4(texcoord + float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r* weight[i];
color += tex2Dlod(ClaritySampler, float4(texcoord - float2(0.0, offset[i] * float2((1.0 / 1920), (1.0 / 1018)).y) * ClarityOffset, 0.0, 0.0)).r* weight[i];
}
}
#line 425
return color;
}
#line 428
float Clarity3(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
float color = tex2D(ClaritySampler2, texcoord).r;
#line 432
if(ClarityRadius == 0)
{
const float offset[4] = { 0.0, 1.1824255238, 3.0293122308, 5.0040701377 };
const float weight[4] = { 0.39894, 0.2959599993, 0.0045656525, 0.00000149278686458842 };
#line 437
color *= weight[0];
#line 439
[loop]
for(int i = 1; i < 4; ++i)
{
color += tex2Dlod(ClaritySampler2, float4(texcoord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).r* weight[i];
color += tex2Dlod(ClaritySampler2, float4(texcoord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).r* weight[i];
}
}
#line 447
if(ClarityRadius == 1)
{
const float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
const float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
#line 452
color *= weight[0];
#line 454
[loop]
for(int i = 1; i < 6; ++i)
{
color += tex2Dlod(ClaritySampler2, float4(texcoord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).r* weight[i];
color += tex2Dlod(ClaritySampler2, float4(texcoord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).r* weight[i];
}
}
#line 462
if(ClarityRadius == 2)
{
const float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
const float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
#line 467
color *= weight[0];
#line 469
[loop]
for(int i = 1; i < 11; ++i)
{
color += tex2Dlod(ClaritySampler2, float4(texcoord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).r* weight[i];
color += tex2Dlod(ClaritySampler2, float4(texcoord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).r* weight[i];
}
}
#line 477
if(ClarityRadius == 3)
{
const float offset[15] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4401038149, 21.43402885, 23.4279736431, 25.4219399344, 27.4159294386 };
const float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
#line 482
color *= weight[0];
#line 484
[loop]
for(int i = 1; i < 15; ++i)
{
color += tex2Dlod(ClaritySampler2, float4(texcoord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).r* weight[i];
color += tex2Dlod(ClaritySampler2, float4(texcoord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).r* weight[i];
}
}
#line 492
if(ClarityRadius == 4)
{
const float offset[18] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4661974725, 21.4627427973, 23.4592916956, 25.455844494, 27.4524015179, 29.4489630909, 31.445529535, 33.4421011704 };
const float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
#line 497
color *= weight[0];
#line 499
[loop]
for(int i = 1; i < 18; ++i)
{
color += tex2Dlod(ClaritySampler2, float4(texcoord + float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).r* weight[i];
color += tex2Dlod(ClaritySampler2, float4(texcoord - float2(offset[i] * float2((1.0 / 1920), (1.0 / 1018)).x, 0.0) * ClarityOffset, 0.0, 0.0)).r* weight[i];
}
}
#line 507
return color;
}
#line 510
technique Clarity
{
pass Clarity1
{
VertexShader = PostProcessVS;
PixelShader = Clarity1;
RenderTarget = ClarityTex;
}
#line 519
pass Clarity2
{
VertexShader = PostProcessVS;
PixelShader = Clarity2;
RenderTarget = ClarityTex2;
}
#line 526
pass Clarity3
{
VertexShader = PostProcessVS;
PixelShader = Clarity3;
RenderTarget = ClarityTex3;
}
#line 533
pass ClarityFinal
{
VertexShader = PostProcessVS;
PixelShader = ClarityFinal;
}
}

