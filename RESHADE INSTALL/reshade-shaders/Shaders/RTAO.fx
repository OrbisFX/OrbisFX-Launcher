/*
        ========================================================================
        Copyright (c) Afzaal. All rights reserved.

    	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND
    	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    	TORT OR OTHERWISE,ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

        ========================================================================

        Filename   : RTAO.fx
        Version    : 2025.11.30
        Author     : Afzaal (Kaidō)
        Description: RTAO - Ray Traced Ambient Occlusion
        License    : AGNYA License
                     https://github.com/nvb-uy/AGNYA-License

        GitHub     : https://github.com/umar-afzaal/LumeniteFX
        Discord    : https://discord.gg/deXJrW2dx6
        ========================================================================
*/


#include "ReShade.fxh"

/*------------------.
| :: DEFINITIONS :: |
'------------------*/

//=== Preprocessors
#ifndef TEMPORAL_FILTER
  #define TEMPORAL_FILTER 0
#endif

//=== Core Settings
#define PI 3.14159265359
#define EPSILON 1e-6
#define FOV 60.0

//=== Ambient Occlusion
#define INITIAL_STEP_SCALE 0.9 // How small the very first step is (as a fraction of the average step size).
#define STEP_GROWTH_FACTOR 1.2
#define ATROUS_DEPTH_WEIGHT_SCALE 800.0
#define ATROUS_NORMAL_WEIGHT_SCALE 13.0
#define AO_MAX_MARCH_STEPS 15
#define AO_RADIUS 0.02

/*---------------.
| :: UNIFORMS :: |
'---------------*/
uniform int FRAME_COUNT < source = "framecount"; >;

uniform bool DEBUG_VIEW <
    ui_label = "Show AO Mask";
    ui_tooltip = "Debug view for the AO. Shows raw AO.";
> = 0;

#if TEMPORAL_FILTER
    uniform bool CHECKERBOARD_RENDERING <
        ui_label = "Half-Rate Rendering";
        ui_tooltip = "Skips half the pixels to render faster. Minor temporal lag of AO Mask.";
    > = 0;
#endif

uniform float DEPTH_BOUNDARY <
    ui_type = "slider";
    ui_min = 0.001; ui_max = 0.999; ui_step = 0.001;
    ui_label = "AO Range";
    ui_tooltip = "The Z+ range/depth in which the effect is applied.";
    hidden = false;
> = 0.6;

uniform float DEPTH_FADE_START <
    ui_type = "slider";
    ui_min = 0.1; ui_max = 1.0; ui_step = 0.01;
    ui_label = "Z+ Fade Start (%)";
    ui_tooltip = "Z+ fraction where effect starts fading out (relative to Z+ boundary)";
    hidden = true;
> = 0.75;

//=== Ambient Occlusion
uniform float AO_INTENSITY <
    ui_type = "slider";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
    ui_label = "AO Strength";
    ui_tooltip = "Controls the intensity of the ambient occlusion effect.";
> = 1.0;

/*---------------------.
| :: RENDER TARGETS :: |
'---------------------*/

texture tNormals { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
sampler sNormals { Texture = tNormals; };

texture tAO1 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R16F; };
sampler sAO1 { Texture = tAO1; AddressU = CLAMP; AddressV = CLAMP; };

texture tAO2 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R16F; };
sampler sAO2 { Texture = tAO2; AddressU = CLAMP; AddressV = CLAMP; };

#if TEMPORAL_FILTER
    texture tPrevAO { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R16F; };
    sampler sPrevAO { Texture = tPrevAO; AddressU = CLAMP; AddressV = CLAMP; };
#endif

texture tBlueNoise < source = "lumenite_bluenoise256.png"; > { Width = 256; Height = 256; Format = R8; };
sampler sBlueNoise { Texture = tBlueNoise; AddressU = REPEAT; AddressV = REPEAT; };

/*--------------.
| :: HELPERS :: |
'--------------*/

bool CheckerboardSkip(uint2 pos)
{
    return (((pos.x + pos.y) & 1) == (FRAME_COUNT & 1));
}

float GetLuminance(float3 color)
{
    return dot(color, float3(0.2126, 0.7152, 0.0722));
}

float3 GetColor(float2 uv)
{
    float3 color = tex2Dlod(ReShade::BackBuffer, float4(uv, 0, 0)).rgb;
    // Optionally, do some processing and then return
    return color;
}

float GetDepth(float2 uv)
{
	return ReShade::GetLinearizedDepth(uv);
}

//=== Vertex Shader
struct VSOUT
{
    float4 vpos              : SV_Position;
    float2 uv                : TEXCOORD0;
    float tan_half_fov_x     : TEXCOORD1;
    float tan_half_fov_y     : TEXCOORD2;
    float far_plane          : TEXCOORD3;
    float inv_tan_half_fov_x : TEXCOORD4;
    float inv_tan_half_fov_y : TEXCOORD5;
};

#define TAN_HALF_FOV_Y tan(radians(FOV * 0.5))
#define ASPECT_RATIO_X_OVER_Y ((float)BUFFER_WIDTH / (float)BUFFER_HEIGHT)
#define TAN_HALF_FOV_X TAN_HALF_FOV_Y * ASPECT_RATIO_X_OVER_Y
#define INV_TAN_HALF_FOV_X rcp(TAN_HALF_FOV_X)
#define INV_TAN_HALF_FOV_Y rcp(TAN_HALF_FOV_Y)

VSOUT VS(uint id : SV_VertexID)
{
    VSOUT o;
    o.uv.x = (id == 2) ? 2.0 : 0.0;
    o.uv.y = (id == 1) ? 2.0 : 0.0;
    o.vpos = float4(mad(o.uv.x, 2.0, -1.0), mad(o.uv.y, -2.0, 1.0), 0.0, 1.0);
    o.tan_half_fov_x = TAN_HALF_FOV_X;
    o.tan_half_fov_y = TAN_HALF_FOV_Y;
    o.inv_tan_half_fov_x = INV_TAN_HALF_FOV_X;
    o.inv_tan_half_fov_y = INV_TAN_HALF_FOV_Y;
    o.far_plane = RESHADE_DEPTH_LINEARIZATION_FAR_PLANE;
    return o;
}

//=== Projection Functions
float3 UVToViewSpace(float2 uv, float linear_depth_vs, VSOUT ps_input)
{
    float3 view_pos;
    float ndc_x = mad(uv.x, 2.0, -1.0);
    float ndc_y = mad(uv.y, -2.0, 1.0);

    view_pos.x = ndc_x * ps_input.tan_half_fov_x * linear_depth_vs;
    view_pos.y = ndc_y * ps_input.tan_half_fov_y * linear_depth_vs;
    view_pos.z = linear_depth_vs;
    return view_pos;
}

float2 ViewSpaceToUV(float3 view_pos, VSOUT ps_input)
{
    float2 ndc;
    float inv_z = rcp(view_pos.z);
    ndc.x = view_pos.x * inv_z * ps_input.inv_tan_half_fov_x;
    ndc.y = view_pos.y * inv_z * ps_input.inv_tan_half_fov_y;
    float2 uv;
    uv.x = mad(ndc.x, 0.5, 0.5);
    uv.y = mad(ndc.y, -0.5, 0.5);
    return uv;
}

//=== Hemisphere Sampling
void BuildOrthonormalBasis(float3 n, out float3 b1, out float3 b2)
{
    if (n.z < -0.9999999) {
        b1 = float3(0.0, -1.0, 0.0);
        b2 = float3(-1.0, 0.0, 0.0);
    } else {
        float a = rcp(1.0 + n.z);
        float b = -n.x * n.y * a;
        b1 = float3(mad(-n.x * n.x, a, 1.0), b, -n.x);
        b2 = float3(b, mad(-n.y * n.y, a, 1.0), -n.y);
    }
}

float3 GenerateHemisphereDirection(float3 normal, float2 rand, float3 tangent, float3 bitangent)
{
    float phi = rand.x * 6.28318530718; // 2.0 * PI as constant
    float sinPhi, cosPhi;
    sincos(phi, sinPhi, cosPhi);
    float cosTheta = sqrt(1.0 - rand.y);
    float sinTheta = sqrt(rand.y);
    float3 result = normal * cosTheta;
    result = mad(bitangent, sinTheta * sinPhi, result);
    result = mad(tangent, sinTheta * cosPhi, result);
    return result;
}

//=== Core Settings
float CalculateDepthFade(float depth)
{
    float fadeStartDepth = DEPTH_BOUNDARY * DEPTH_FADE_START;
    float fadeRange = DEPTH_BOUNDARY - fadeStartDepth;
    return 1.0 - saturate((depth - fadeStartDepth) / fadeRange);
}

//=== ATROUS Filter helpers
float ComputeATrousWeight(float centerDepth, float3 centerNormal, float sampleDepth, float3 sampleNormal)
{
    float depthDiff = abs(centerDepth - sampleDepth);
    float depthWeight = exp(-depthDiff * ATROUS_DEPTH_WEIGHT_SCALE);
    float normalDot = saturate(dot(centerNormal, sampleNormal));
    float normalWeight = pow(normalDot, ATROUS_NORMAL_WEIGHT_SCALE);
    return depthWeight * normalWeight;
}

float ATrousStep(float2 uv, sampler SourceSampler, int Dilation)
{
    float4 gbuffer = tex2D(sNormals, uv);
    float3 centerNormal = gbuffer.rgb;
    float centerDepth = gbuffer.a;
    if (centerDepth == 0 || centerDepth >= DEPTH_BOUNDARY) discard;

    float centerAO = tex2Dlod(SourceSampler, float4(uv, 0, 0)).r;
    float sum = centerAO;
    float totalWeight = 1.0;

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 sampleUV = uv + float2(x, y) * Dilation * ReShade::PixelSize;
            float sampleAO = tex2Dlod(SourceSampler, float4(sampleUV, 0, 0)).r;
            gbuffer = tex2Dlod(sNormals, float4(sampleUV, 0, 0));
            float3 sampleNormal = gbuffer.rgb;
            float sampleDepth = gbuffer.a;
            float weight = ComputeATrousWeight(centerDepth, centerNormal, sampleDepth, sampleNormal);
            sum += sampleAO * weight;
            totalWeight += weight;
        }
    }
    return sum / (totalWeight + EPSILON);
}

/*--------------------.
| :: PIXEL SHADERS :: |
'--------------------*/

//=== Normals
float4 PS_ReconstructNormals(VSOUT input) : SV_Target
{
    #if TEMPORAL_FILTER
        if (CHECKERBOARD_RENDERING)
            if(CheckerboardSkip(uint2(input.vpos.xy))) discard;
    #endif

    float depthC = ReShade::GetLinearizedDepth(input.uv);

    const float2 offset_x = float2(ReShade::PixelSize.x, 0);
    const float2 offset_y = float2(0, ReShade::PixelSize.y);

    float3 pC = UVToViewSpace(input.uv, depthC, input);
    float3 pL = UVToViewSpace(input.uv - offset_x, ReShade::GetLinearizedDepth(input.uv - offset_x), input);
    float3 pR = UVToViewSpace(input.uv + offset_x, ReShade::GetLinearizedDepth(input.uv + offset_x), input);
    float3 pT = UVToViewSpace(input.uv - offset_y, ReShade::GetLinearizedDepth(input.uv - offset_y), input);
    float3 pB = UVToViewSpace(input.uv + offset_y, ReShade::GetLinearizedDepth(input.uv + offset_y), input);

    float3 diff_x2 = pR - pC;
    float3 diff_x1 = pC - pL;
    float3 diff_y2 = pB - pC;
    float3 diff_y1 = pC - pT;

    float len_sq_x2 = dot(diff_x2, diff_x2);
    float len_sq_x1 = dot(diff_x1, diff_x1);
    float len_sq_y2 = dot(diff_y2, diff_y2);
    float len_sq_y1 = dot(diff_y1, diff_y1);

    float3 ddx = len_sq_x2 < len_sq_x1 ? diff_x2 : diff_x1;
    float3 ddy = len_sq_y2 < len_sq_y1 ? diff_y2 : diff_y1;

    float3 geoNormal = normalize(cross(ddx, ddy));
    return float4(geoNormal, depthC);
}

//=== Ambient Occlusion
float PS_TraceRTAO(VSOUT input) : SV_Target
{
    #if TEMPORAL_FILTER
        if (CHECKERBOARD_RENDERING)
            if(CheckerboardSkip(uint2(input.vpos.xy))) discard;
    #endif

    float4 gbuffer = tex2D(sNormals, input.uv);
    float3 normal = gbuffer.rgb;
    float depth = gbuffer.a;

    if (depth == 0 || depth >= DEPTH_BOUNDARY) discard;

    float3 startPos = UVToViewSpace(input.uv, depth, input);
    float3 tangent, bitangent;
    BuildOrthonormalBasis(normal, tangent, bitangent);
    float2 screenPos = input.uv * float2(BUFFER_WIDTH, BUFFER_HEIGHT);
    float2 rand = float2(
        tex2Dlod(sBlueNoise, float4(frac(screenPos / 256.0), 0, 0)).r,
        tex2Dlod(sBlueNoise, float4(frac((screenPos + float2(127.5, 127.5)) / 256.0), 0, 0)).r
    );
    float3 rayDir = GenerateHemisphereDirection(normal, rand, tangent, bitangent);
    float invDepth = rcp(depth);
    float totalRayLength = AO_RADIUS * depth;
    float initialStepScale = INITIAL_STEP_SCALE * rcp((float)AO_MAX_MARCH_STEPS);
    float stepSize = totalRayLength * initialStepScale;
    float3 rayPos = mad(rayDir, stepSize * 0.5, startPos);
    float occlusion = 0.0;

    [loop]
    for (int step = 0; step < AO_MAX_MARCH_STEPS; step++) {
        float2 sampleUV = ViewSpaceToUV(rayPos, input);
        float sceneDepth = ReShade::GetLinearizedDepth(sampleUV);
        float depthDiff = rayPos.z - sceneDepth;
        [branch]
        if (depthDiff > 0.0 && depthDiff < rayPos.z) {
            float3 scenePos = UVToViewSpace(sampleUV, sceneDepth, input);
            float hitDistance = length(scenePos - startPos);
            float normalizedDistance = hitDistance * invDepth;
            occlusion = exp(-normalizedDistance * 15.0);
            break;
        }
        stepSize *= STEP_GROWTH_FACTOR;
        rayPos = mad(rayDir, stepSize, rayPos);
    }

    float aoFactor = 1.0 - saturate(occlusion * AO_INTENSITY);
    return aoFactor;
}

//=== Atrous filtering
float PS_ATrous_Pass1(VSOUT input) : SV_Target
{
    return ATrousStep(input.uv, sAO1, 1);
}

float PS_ATrous_Pass2(VSOUT input) : SV_Target
{
    return ATrousStep(input.uv, sAO2, 2);
}

//=== Composition
#if TEMPORAL_FILTER
    #include "./include/CoarseFlow.fxh"

    float PS_Blend(VSOUT input) : SV_Target
    {
        float depth = tex2D(sNormals, input.uv).a;
        if (depth == 0 || depth >= DEPTH_BOUNDARY) discard;
        float ao = ATrousStep(input.uv, sAO1, 4);
        float2 flow = tex2D(sCoarseFlowL0_B, input.uv).xy;
        float confidence = tex2D(sFlowConfidence, input.uv).x;
        float rawHistory = tex2D(sPrevAO, input.uv + flow).r; // History stores "1.0 - AO". 0.0 (Black Texture) -> Reads as 1.0 (White).
        float prevAO = 1.0 - rawHistory;
        float blendVal = (rawHistory == 0.0) ? 0.0 : (confidence * 0.95);
        ao = lerp(ao, prevAO, blendVal);
        // Use max(..., 0.001) to ensure we NEVER write exactly 0.0 again.
        // This tells the next frame "I contain data".
        return max(1.0 - ao, 0.001);
    }

    float4 PS_Display(VSOUT input) : SV_Target
    {
        float depth = tex2D(sNormals, input.uv).a;
        if (depth == 0 || depth >= DEPTH_BOUNDARY) {
            if (DEBUG_VIEW) return float4(0.0, 0.0, 0.0, 1.0);
            discard;
        }
        float occlusion = tex2D(sAO2, input.uv).r;
        float ao = 1.0 - occlusion;
        float depthFade = CalculateDepthFade(depth);
        float displayAO = lerp(1.0, ao, depthFade);
        if (DEBUG_VIEW) return float4(displayAO.xxx * depthFade, 1.0);
        float3 base = GetColor(input.uv);
        base *= displayAO;
        return float4(base, 1.0);
    }

    float PS_StoreAO(VSOUT input) : SV_Target
    {
        return tex2D(sAO2, input.uv).r;
    }

#else
    float4 PS_Blend(VSOUT input) : SV_Target
    {
        float depth = tex2D(sNormals, input.uv).a;
        if (depth == 0 || depth >= DEPTH_BOUNDARY) {
            if (DEBUG_VIEW) return float4(0.0, 0.0, 0.0, 1.0);  // Black for out-of-range
            discard;
        }
        float depthFade = CalculateDepthFade(depth);
        float ao = ATrousStep(input.uv, sAO1, 4);
        ao = lerp(1.0, ao, depthFade);
        if (DEBUG_VIEW) return float4(ao.xxx * depthFade, 1.0);
        float3 base = GetColor(input.uv);
        base *= ao;
        return float4(base, 1.0);
    }
#endif

/*----------------.
| :: TECHNIQUE :: |
'----------------*/
technique Lumenite_RTAO <
    ui_label = "Lumenite: RTAO";
    ui_tooltip = "Ray Traced Ambient Occlusion.";
>
{
    pass { VertexShader = VS; PixelShader = PS_ReconstructNormals; RenderTarget = tNormals; }
    pass { VertexShader = VS; PixelShader = PS_TraceRTAO; RenderTarget = tAO1; }
    pass { VertexShader = VS; PixelShader = PS_ATrous_Pass1; RenderTarget = tAO2; }
    pass { VertexShader = VS; PixelShader = PS_ATrous_Pass2; RenderTarget = tAO1; }
    #if TEMPORAL_FILTER
        pass { VertexShader = PostProcessVS; PixelShader = PS_CurrLuma; RenderTarget = tCurrLuma; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_CoarseFlowL4; RenderTarget = tCoarseFlowL4; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_CoarseFlowL3; RenderTarget = tCoarseFlowL3_A; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_SpatialFilterL3; RenderTarget = tCoarseFlowL3_B; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_CoarseFlowL2; RenderTarget = tCoarseFlowL2_A; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_SpatialFilterL2; RenderTarget = tCoarseFlowL2_B; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_CoarseFlowL1; RenderTarget = tCoarseFlowL1_A; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_SpatialFilterL1; RenderTarget = tCoarseFlowL1_B; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_CoarseFlowL0; RenderTarget = tCoarseFlowL0_A; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_SpatialFilterL0; RenderTarget = tCoarseFlowL0_B; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_FinalFlow; RenderTarget = tCoarseFlowL0_A; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_SpatialFilterFinal; RenderTarget = tCoarseFlowL0_B; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_GlobalFlow; RenderTarget = tGlobalFlow; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_ComputeConfidence; RenderTarget = tFlowConfidence; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_CopyFinalFlowToHistory; RenderTarget = tPrevCoarseFlow; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_CopyCurrLumaAsPrev; RenderTarget = tPrevLuma; }
        pass { VertexShader = PostProcessVS; PixelShader = PS_CopyCurrColorAsPrev; RenderTarget = tPrevBackBuffer; }

        pass { VertexShader = VS; PixelShader = PS_Blend; RenderTarget = tAO2; }
        pass { VertexShader = VS; PixelShader = PS_Display; }
        pass { VertexShader = VS; PixelShader = PS_StoreAO; RenderTarget = tPrevAO; }
    #else
        pass { VertexShader = VS; PixelShader = PS_Blend; }
    #endif
}
