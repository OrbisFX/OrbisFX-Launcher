//========================================================================
/*
	Copyright © Daniel Oren-Ibarra - 2025
	All Rights Reserved.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE,ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	
	
	======================================================================	
	Zenteon+: Radon - Authored by Daniel Oren-Ibarra
	
	NOTE: THIS SHADER IS AVAILABLE FOR DOWNLOAD EXCLUSIVELY THROUGH THE ZENTIENT EFFECTS DISCORD
	UNLESS YOU HAVE PERSONALLY RECIEVED THE FILE FROM FROM DISCORD USER "azenteon" AS A BETA TESTER
	
	
	If you recieved this file through any other source
	please report it and aquire the shader through ethical means:
	
	Discord: https://discord.gg/PpbcqJJs6h
	Patreon: https://patreon.com/Zenteon


*/
//========================================================================


#include "ReShade.fxh"
#include "ZenteonCommon.fxh"

#if(__RENDERER__ != 0x9000)

	#ifndef PERFORMANCE_MODE
	//============================================================================================
		#define PERFORMANCE_MODE 1
	//============================================================================================
	#endif
	
	#ifndef CHEF_MODE
	//============================================================================================
		#define CHEF_MODE 0
	//============================================================================================
	#endif
	
	#ifndef REST_SETTINGS
	//============================================================================================
		#define REST_SETTINGS 0
	//============================================================================================
	#endif

	#define WRAPSAM AddressU = BORDER; AddressV = BORDER; AddressW = BORDER;

	uniform int BLOOM_PRESET <
		ui_type = "combo";
		ui_items = "Wide\0Precise\0";
		ui_category = "Blending";
	> = 0;
	
	uniform float LOG_WHITEPOINT <
		ui_type = "drag";
		ui_label = "Log Whitepoint";
		ui_tooltip = "Sets the max brightness in the scene, higher values will make bloom wider and more pronounced";
		ui_category = "Blending";
		ui_min = 0.0;
		ui_max = 8.0;
	> = 5.0;
	
	uniform float INTENSITY <
		ui_type = "drag";
		ui_min = 0.0;
		ui_max = 1.0;
		ui_label = "Bloom Intensity";
		ui_tooltip = "Overall strength of the effect";
		ui_category = "Blending";
		ui_category_closed = true;
	> = 0.5;
	
	uniform float DIRT_INTENSITY <
		ui_type = "drag";
		ui_min = 0.0;
		ui_max = 2.0;
		ui_label = "Dirt Intensity";
		ui_tooltip = "Intensity of dirt";
		ui_category = "Blending";
		ui_category_closed = true;
	> = 0.5;
	
	uniform int SHOW_RAW_BLOOM <
		ui_label = "Debug";
		ui_type = "combo";
		ui_items = "None\0Raw Bloom Output\0";
		ui_category_closed = true;
		hidden = !CHEF_MODE;
	> = 0;
	
	#define HDRP ( 1.0 + rcp(exp(LOG_WHITEPOINT)) ), 0, 0


	uniform float CHROMA_ABBR <
		ui_type = "drag";
		ui_min = 0.0;
		ui_max = 1.0;
		ui_tooltip = "Applies chromatic abberation to bloom and dirt, without affecting the base image";
		ui_category = "Lens Effects";
		ui_category_closed = true;
		ui_label = "Bloom CA";
		hidden = !CHEF_MODE;
	> = 0.1;
	
	
	uniform float DIRT_SIZE <
		ui_type = "drag";
		ui_min = 1.0;
		ui_max = 100.0;
		ui_label = "Size";
		ui_tooltip = "Size of individual particles";
		ui_category = "Lens Dirt";
		ui_category_closed = true;
		hidden = !CHEF_MODE;
	> = 40.0;
	
	uniform float DIRT_DTSP <
		ui_type = "slider";
		ui_min = 0.5;
		ui_max = 8.0;
		ui_label = "Distribution";
		ui_tooltip = "Distribution of small-large particles";
		ui_category = "Lens Dirt";
		ui_category_closed = true;
		hidden = !CHEF_MODE;
	> = 5.0;
	
	uniform int DIRT_CT <
		ui_type = "slider";
		ui_min = 0;
		ui_max = 600;
		ui_label = "Count";
		ui_tooltip = "Amount of individual particles";
		ui_category = "Lens Dirt";
		ui_category_closed = true;
		hidden = !CHEF_MODE;
	> = 500;
	
	uniform int DIRT_SEED <
		ui_type = "slider";
		ui_min = 1;
		ui_max = 100;
		ui_label = "Seed";
		ui_tooltip = "Seed of random particles";
		ui_category = "Lens Dirt";
		ui_category_closed = true;
		hidden = !CHEF_MODE;
	> = 32;
	
	uniform float ROTATION <
		ui_type = "drag";
		ui_label = "Rotation";
		ui_tooltip = "Rotates the apeture";
		ui_category = "Other";
		ui_category_closed = true;
		ui_min = 0.0;
		ui_max = 3.14;
	> = 0.7;
	
	
	uniform float PRECISION <
		ui_type = "drag";
		ui_min = 0.0;
		ui_max = 1.0;
		ui_tooltip = "How precise the bloom streaks are";
		ui_category = "Other";
		ui_category_closed = true;
		ui_label = "Precision";
	> = 0.7;
	
	uniform float3 BLOOM_COLOR <
		ui_type = "color";
		ui_min = 0.0;
		ui_max = 1.0;
		ui_tooltip = "Tint the Bloom map before calculations";
		ui_category = "Other";
		ui_category_closed = true;
		ui_label = "Bloom Tint";
		hidden = !CHEF_MODE;
	> = float3(1.0, 1.0, 1.0);
	
	uniform int BLEND_MODE <
		ui_type = "combo";
		ui_category = "Other";
		ui_items = "Physical\0Soft Light\0Add\0Screen\0UI Preserving\0";
		ui_tooltip = "Sets the mode that is used for blending, Physical is the default, and emulates the results of an actual camera"; 
		hidden = !CHEF_MODE;
	> = 0;
	
	
	#define DIRTSET (ROTATION + DIRT_SIZE / 100.0 + DIRT_DTSP / 5.0 + DIRT_CT / 200.0 + DIRT_SEED / 100.0)
	
	#define FG_COL lerp(1.0, float4(0.7778, 0.0, 2.2223, 1.0), 0.8 * FRINGING)
	
	uniform bool REST_HDR <
		ui_label = "REST HDR Buffer Input";
		ui_tooltip = "NOTE: ONLY ENABLE IF BINDING TO AN UNBOUNDED HDR BUFFER WITH REST";
		ui_category = "Rest Settings";
		hidden = !REST_SETTINGS;
	> = 0;
	
	uniform bool REST_LINEAR <
		ui_label = "REST Force Linear Gamma";
		ui_tooltip = "NOTE: ONLY ENABLE IF BINDING TO A NONLINEAR UNBOUNDED HDR BUFFER WITH REST";
		ui_category = "Rest Settings";
		hidden = !REST_SETTINGS;
	> = 0;
	
	#if(!PERFORMANCE_MODE)
		#define NRES float2(1.5 * BUFFER_WIDTH, 1.5 * BUFFER_HEIGHT)
	#else
		#define NRES float2(0.67 * BUFFER_WIDTH, 0.67 * BUFFER_HEIGHT)
	#endif
	
	namespace QXMB
	{
		texture DirtDrawTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
		texture DirtPrenTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
		texture DirtSaveTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
		
		texture tempBufferTex {Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F;};
		texture LightMapTex {Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F;};
		
		texture downTex0 	 {Width = 0.5 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture downTex1 	 {Width = 0.25 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture downTex2 	 {Width = 0.125 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture downTex3 	 {Width = 0.0625 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture downTex4 	 {Width = 0.03125 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture downTex5 	 {Width = 0.015625 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture downTex6 	 {Width = 0.007813 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture downTex7 	 {Width = 0.0039065 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		
		//0.0039065
		texture upTex6		{Width = 0.007813 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture upTex5		{Width = 0.015625 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture upTex4		{Width = 0.03125 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture upTex3		{Width = 0.0625 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture upTex2		{Width = 0.125 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture upTex1		{Width = 0.25 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture upTex0		{Width = 0.5 * NRES.x; Height = NRES.y; Format = RGBA16F;};
		
		texture saveTex0	  {Width = NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture saveTex1	  {Width = NRES.x; Height = NRES.y; Format = RGBA16F;};
		texture saveTex2	  {Width = NRES.x; Height = NRES.y; Format = RGBA16F;};
		
		texture BloomTex	  {Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F;};
	}
	
	sampler DirtDraw { Texture = QXMB::DirtDrawTex; };
	sampler DirtPren { Texture = QXMB::DirtPrenTex; };
	sampler DirtSave { Texture = QXMB::DirtSaveTex; };
	
	sampler tempBuffer {Texture = QXMB::tempBufferTex; WRAPSAM};
	sampler LightMap {Texture = QXMB::LightMapTex; WRAPSAM};
	
	
	sampler downSam0   {Texture = QXMB::downTex0; WRAPSAM};
	sampler downSam1   {Texture = QXMB::downTex1; WRAPSAM};
	sampler downSam2   {Texture = QXMB::downTex2; WRAPSAM};
	sampler downSam3   {Texture = QXMB::downTex3; WRAPSAM};
	sampler downSam4   {Texture = QXMB::downTex4; WRAPSAM};
	sampler downSam5   {Texture = QXMB::downTex5; WRAPSAM};
	sampler downSam6   {Texture = QXMB::downTex6; WRAPSAM};
	sampler downSam7   {Texture = QXMB::downTex7; WRAPSAM};
	
	sampler upSam6 {Texture = QXMB::upTex6; WRAPSAM};
	sampler upSam5 {Texture = QXMB::upTex5; WRAPSAM};
	sampler upSam4 {Texture = QXMB::upTex4; WRAPSAM};
	sampler upSam3 {Texture = QXMB::upTex3; WRAPSAM};
	sampler upSam2 {Texture = QXMB::upTex2; WRAPSAM};
	sampler upSam1 {Texture = QXMB::upTex1; WRAPSAM};
	sampler upSam0 {Texture = QXMB::upTex0; WRAPSAM};
	
	
	sampler saveSam0   {Texture = QXMB::saveTex0;};
	sampler saveSam1   {Texture = QXMB::saveTex1;};
	sampler saveSam2   {Texture = QXMB::saveTex2;};
	
	sampler BloomSam   {Texture = QXMB::BloomTex;};

	//==============================================================================
	//Functions
	//==============================================================================
	
	float3 ZentSpect(float val)
	{
	    val *= 365.0;
	    val += 355.0;
	    val = clamp(val, 355.0, 720.0);
	    float R = saturate(0.9 - (0.01 * pow(val - 650.0, 2.0)) / (775.0 - val));	
	    float G = saturate(1.0 - (0.3 * pow(val - 550.0, 2.0)) / (2690.0 - val));
	    float B = saturate(0.95 - pow(val - 430.0, 2.0) / (0.011 * pow(val, 2.25)));
	    return float3(R, G, B);
	}
	
	float4 RGBAHash(uint pg)
	{    
	    uint state = pg * 747796405u + 2891336453u;
	    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
	    uint R = 0xFFu & word;
	    uint G = 0xFFu & word >> 8;
	    uint B = 0xFFu & word >> 16;
	    uint A = 0xFFu & word >> 24;
	    return float4(R, G, B, A) / float(0xFFu);
	}
	
	float HexSDF(float2 xy, float rad, float smth, float blur)
	{
	    rad -= smth;
	    const float3 k = float3(-0.866025404,0.5,0.577350269);
	     xy = abs(xy);
	    xy -= 2.0*min(dot(k.xy, xy),0.0)*k.xy;
	    xy -= float2(clamp(xy.x, -k.z*rad, k.z*rad), rad);
	    return 1.0 - (0.1 * dot(xy, xy)*sign(xy.y) - smth) / blur;
	}
	
	float GenBokeh(float2 xy, float angle, float radius, float smth, float blur)
	{
	    float scale = 1.0;
		xy -= 0.5;
	    xy *= float2(1.0, RES.y / RES.x);
		xy *= (RES * scale) * float2(1.0, 2.0);
		float2x2 RotationMatrix = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
		xy = mul(xy, RotationMatrix);
	    
	    float hex = HexSDF(xy, radius, smth, blur);
	    
		return saturate(hex);
	}
	
	float2 RotateCoords(float2 xy, float angle, float scale)
	{
		xy -= 0.5;
		xy *= (RES * scale) * float2(1.0, 1.6);
		float2x2 RotationMatrix = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
		xy = mul(xy, RotationMatrix) / (RES * float2(1.0, 1.6));
		return xy + 0.5;
	}
	#define OFFSET 1
	float4 DownSample(float2 xy, sampler tex, float resDiv, float weight)
	{
		float2 texRes =  float2(resDiv / RES.x, 0.0);
		float4 acc	=  weight * tex2D(tex, xy);
			   if(acc.a <= 0.001) return acc;
			   acc	+= tex2D(tex, xy + OFFSET * texRes);
			   acc	+= tex2D(tex, xy - OFFSET * texRes);
			   acc	+= tex2D(tex, xy + OFFSET * 2.0 * texRes);
			   acc	+= tex2D(tex, xy - OFFSET * 2.0 * texRes);
		return acc / (weight + 4.0);	  
	}
	
	float4 UpSample(float2 xy, sampler tex, float resDiv, float weight)
	{
		float texRes =  OFFSET * resDiv / RES.x;
		float vertof =  (1.0 - PRECISION) * resDiv / RES.y;
		float4 acc	=  weight * tex2D(tex, xy);
			   if(acc.a <= 0.001) return acc;
			   acc	+= tex2D(tex, xy + float2(texRes, vertof));
			   acc	+= tex2D(tex, xy - float2(texRes, vertof));
			   acc	+= tex2D(tex, xy + float2(texRes, -vertof));
			   acc	+= tex2D(tex, xy - float2(texRes, -vertof));
			   
		return acc / (weight + 4.0);	  
	}
	
	float4 advLerp(float4 a, float4 b, float4 c)
	{
		return float4(lerp(a.x, b.x, c.x), lerp(a.y, b.y, c.y), lerp(a.z, b.z, c.z), lerp(a.w, b.w, c.w));
	}
	
	float4 DUSample(sampler input, float2 xy, float div)//0.375 + 0.25
	{
	    float2 hp = div * rcp(RES);
	   
		float4 acc;
		
		acc += 0.03125 * tex2D(input, xy + float2(-hp.x, hp.y));
		acc += 0.0625 * tex2D(input, xy + float2(0, hp.y));
		acc += 0.03125 * tex2D(input, xy + float2(hp.x, hp.y));
		
		acc += 0.0625 * tex2D(input, xy + float2(-hp.x, 0));
		acc += 0.125 * tex2D(input, xy + float2(0, 0));
		acc += 0.0625 * tex2D(input, xy + float2(hp.x, 0));
		
		acc += 0.03125 * tex2D(input, xy + float2(-hp.x, -hp.y));
		acc += 0.0625 * tex2D(input, xy + float2(0, -hp.y));
		acc += 0.03125 * tex2D(input, xy + float2(hp.x, -hp.y));
	  
		acc += 0.125 * tex2D(input, xy + 0.5 * float2(hp.x, hp.y));
		acc += 0.125 * tex2D(input, xy + 0.5 * float2(hp.x, -hp.y));
		acc += 0.125 * tex2D(input, xy + 0.5 * float2(-hp.x, hp.y));
		acc += 0.125 * tex2D(input, xy + 0.5 * float2(-hp.x, -hp.y));
		
	    return acc;
	
	}
	
	//==============================================================================
	//DownSample Passes
	//==============================================================================
	float4 Down00(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		float2 xy = RotateCoords(texcoord, ROTATION, 1.5);
		return float4(DownSample(xy, LightMap, 2.0, 1.0));
	}
	
	float4 Down01(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		float2 xy = RotateCoords(texcoord, ROTATION + 1.047, 1.5);
		return DownSample(xy, LightMap, 2.0, 1.0);
	}
	
	float4 Down02(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		float2 xy = RotateCoords(texcoord, ROTATION + 2.094, 1.5);
		return DownSample(xy, LightMap, 2.0, 1.0);
	}
	
	float4 Down1(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		return DownSample(texcoord, downSam0, 4.0, 1.0);	}
	
	float4 Down2(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		return DownSample(texcoord, downSam1, 8.0, 1.0);	}
	
	float4 Down3(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		return DownSample(texcoord, downSam2, 16.0, 1.0);	}
	
	float4 Down4(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		return DownSample(texcoord, downSam3, 32.0, 1.0);	}
	
	float4 Down5(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		return DownSample(texcoord, downSam4, 64.0, 1.0);	}
	
	float4 Down6(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		return DownSample(texcoord, downSam5, 128.0, 1.0);	}
		
	float4 Down7(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		return DownSample(texcoord, downSam6, 256.0, 1.0);	}
	
	#define KER_A float4(0.2, 0.4, 1.0, 1.0)
	#define KER_B float4(1.0, 0.4, 0.2, 1.0)
	
	/*
	#define coef00 0.4472
	#define coef0  0.18
	#define coef1  0.1467
	#define coef2  0.099
	#define coef3  0.06
	#define coef4  0.034
	#define coef5  0.0155
	#define coef6  0.0086
	#define coef7  0.004
	#define coef8  0.005
	*/
	
	#define coef00 (BLOOM_PRESET ? 0.58641 : 0.4472)
	#define coef0  (BLOOM_PRESET ? 0.21 : 0.18)
	#define coef1  (BLOOM_PRESET ? 0.126 : 0.1467)
	#define coef2  (BLOOM_PRESET ? 0.053 : 0.099)
	#define coef3  (BLOOM_PRESET ? 0.0175 : 0.06)
	#define coef4  (BLOOM_PRESET ? 0.0052 : 0.034)
	#define coef5  (BLOOM_PRESET ? 0.0014 : 0.0155)
	#define coef6  (BLOOM_PRESET ? 0.00037 : 0.0086)
	#define coef7  (BLOOM_PRESET ? 0.00008 : 0.004)
	#define coef8  (BLOOM_PRESET ? 0.00004 : 0.005)
	
	float4 Up00(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		return coef7 * UpSample(texcoord, downSam7, 128.0, 1.0);	}
	
	float4 Up0(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		float4 cur = tex2D(downSam6, texcoord);
		return coef6 * cur + UpSample(texcoord, upSam6, 64.0, 1.0);	
	}
	
	float4 Up1(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		float4 cur = tex2D(downSam5, texcoord);
		return  coef5 * cur + UpSample(texcoord, upSam5, 32.0, 1.0);	
	}
	
	float4 Up2(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		float4 cur = tex2D(downSam4, texcoord);
		return coef4 * cur + UpSample(texcoord, upSam4, 16.0, 1.0);	
	}
	
	float4 Up3(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		float4 cur = tex2D(downSam3, texcoord);
		return  coef3 * cur + UpSample(texcoord, upSam3, 8.0, 1.0);	
	}
	
	float4 Up4(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		float4 cur = tex2D(downSam2, texcoord);
		return  coef2 * cur + UpSample(texcoord, upSam2, 4.0, 1.0);	
	}
	
	float4 Up5(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
		float4 cur = tex2D(downSam1, texcoord);
		return  coef1 * cur + UpSample(texcoord, upSam1, 2.0, 1.0);	
	}
	//==============================================================================
	//Save Passes
	//==============================================================================
	
	
	
	float4 Save0(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
	{
		float2 xy = RotateCoords(texcoord, -ROTATION, 0.6667);
		return tex2D(upSam0, xy);
	}
	
	float4 Save1(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
	{
		float2 xy = RotateCoords(texcoord, -ROTATION - 1.047, 0.6667);
	
		return tex2D(upSam0, xy);
	}
	
	float4 Save2(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
	{
		float2 xy = RotateCoords(texcoord, -ROTATION - 2.094, 0.6667);
		
		return tex2D(upSam0, xy);
	}
	//==============================================================================
	//Main
	//==============================================================================
	
	float4 DrawDirt(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
	{
		float4 col = tex2D(DirtPren, texcoord);
		
		if(distance(col.w, DIRTSET) < 0.005) return col;
		
		col = 0.0;
		
		for(int i = 1; i < DIRT_CT; i++)
		{
			float4 data = RGBAHash(uint(DIRT_SEED * i + 4));
			float4 data2 = pow(RGBAHash(uint(2.0 * DIRT_SEED * i + 8)), 2.0);
			data.w = pow(data.w, DIRT_DTSP);
	        col.rgb += data2.z * GenBokeh(texcoord + (data.xz - 0.5), 1.57 - ROTATION, 0.2 + data.w * DIRT_SIZE, data2.x * 15.0, 3.0 + data2.y * 50.0);
		}
		col.w = DIRTSET;
		col.rgb = saturate(col.rgb);
		return col;
	}
	
	float4 PrenDirt(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
	{
		float4 col = tex2D(DirtDraw, texcoord);
		col.w = DIRTSET;
		return col;
	}
	
	#define CA_SAMPLES 10
	float4 SaveDirt(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
	{
		float4 col;// = tex2D(DirtPren, texcoord);
		col.w = DIRTSET;
		
		
		float2 cPos = 2f * texcoord - 1f;
		float2 cVec = 4.0 * CHROMA_ABBR * normalize(-cPos) / float2(BUFFER_WIDTH, BUFFER_HEIGHT);
		cVec *= dot(cPos, cPos);
		for(int i; i < CA_SAMPLES; i++)
		{
			//uint randmod = pow(100 + texcoord.x * 100, 2.0) + (100 + texcoord.y * 100);
			//float4 data = RGBAHash(i + randmod);
			float3 CAC = float3(1.0, 0.9, 0.65) * 4.0 * ZentSpect(float(i + 1) / CA_SAMPLES);
			//col.rgb = data.rgb;
			col.rgb += CAC * tex2D(DirtPren, texcoord + ((i - 0.5 * CA_SAMPLES) * cVec)).rgb;
		}
		return float4(col.rgb / CA_SAMPLES, 1.0);
	}	
	
	float4 DrawTempBuffer(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
	{
		float  depth = ReShade::GetLinearizedDepth(texcoord);
		if(REST_HDR) depth = 1.0;
		
		//Luminance adjusted bloom color
		float3 BC = pow(BLOOM_COLOR, 2.2);
		
		float3 input =  GetBackBuffer(texcoord);
		input = IReinJ(input, HDRP);
		
		//float3 inLum = 0.2126 * input.r + 0.7152 * input.g + 0.0722 * input.b;
		//float3 inCol = input / inLum;
		//float3 inCol = lerp(inLum, input, BLOOM_SAT) / (inLum + 0.001);
		//input = (normalize(input + 0.001) / 0.5774) * pow((input.r + input.g + input.b) / 3.0, THRESHOLD);
		
		//input = BC * inCol * max(pow(inLum, THRESHOLD), 0.0);
		//input = ;
		
		
		
		return float4(input, 1.0);//float4(max(inLum * inCol, 0.0), 1.0);float4(bloomColCor, 1.0);
	}
	
	float4 GenLightMap(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
	{
		
		float4 col;
		float2 cPos = 2f * texcoord - 1f;
		float2 cVec = 2.5 * CHROMA_ABBR * normalize(-cPos) / float2(BUFFER_WIDTH, BUFFER_HEIGHT);
		cVec *= dot(cPos, cPos);
		
		for(int i; i < CA_SAMPLES; i++)
		{
			float3 CAC = 3.0 * ZentSpect(float(i + 1) / CA_SAMPLES);
			col += float4(CAC, 1.0) * tex2D(tempBuffer, texcoord + ((i - 0.5 * CA_SAMPLES) * cVec));
		}
		return float4(col / CA_SAMPLES);
	
	}
	
	float4 MergeBloom(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
	{
		float4 bloom0 = DUSample(saveSam0, texcoord, 1.0);
		float4 bloom1 = DUSample(saveSam1, texcoord, 1.0);
		float4 bloom2 = DUSample(saveSam2, texcoord, 1.0);
		
		return coef00 * tex2D(LightMap, texcoord) + (bloom0 + bloom1 + bloom2) / 3.0;
	}
	
	//=============================================================================
	//Blending Functions
	//=============================================================================
	
	float3 TMSoftLight(float3 a, float3 b, float level)
	{
		a = ReinJ(a, HDRP);
		b = ReinJ(b, HDRP);
		return lerp(a, (1.0-2.0*a) * b*b + 2.0*b*a, level);
	}
	
	float3 TMScreen(float3 a, float3 b, float level)
	{
		a = ReinJ(a, HDRP);
		b = ReinJ(b, HDRP);
		b = 1.0 - ((1.0 - a) * (1.0 - b));
		return lerp(a, b, level);
	}
	
	float3 TMDodge(float3 a, float3 b, float level)
	{
		a = ReinJ(a, HDRP);
		b = ReinJ(b, HDRP);
	}
	
	float3 TM_UIPres(float3 a, float3 b, float level)
	{
		return ReinJ( lerp(a,b, (pow(ReinJ(GetLuminance(a), HDRP), 0.75) + 0.01) * level), HDRP);
	}
	
	float3 Blend(float3 input, float3 bloom, float level, int mode)
	{
		if(mode == 0) return ReinJ(lerp(input, bloom, level), HDRP);
		if(mode == 1) return TMSoftLight(input, bloom, level);
		if(mode == 2) return ReinJ(input + level * bloom, HDRP);
		if(mode == 3) return TMScreen(input, bloom, level);
		if(mode == 4) return TM_UIPres(input, bloom, level);
		
		return 0;
	}
	
	float3 MatrixBloom(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
	{
		float  depth = ReShade::GetLinearizedDepth(texcoord);
		float3 input = tex2D(ReShade::BackBuffer, texcoord).rgb;
		input = IReinJ(input, HDRP);
		
		float4 bloom = tex2D(BloomSam, texcoord);
		//bloom.rgb = BLOOM_BRIGHT * pow(bloom.rgb, BLOOM_CONTRAST);
		
		float3 dirt = DIRT_INTENSITY * bloom.rgb * tex2D(DirtSave, texcoord).rgb;
		
		
		
		if(SHOW_RAW_BLOOM) return ReinJ(bloom.rgb + dirt, HDRP);
		
		input = Blend(input, bloom.rgb + dirt, 0.5 * INTENSITY, BLEND_MODE);
		return input;
	}
	
	technique ZenteonPlusRadon <
	ui_label = "Zenteon+: Radon Bloom";
		    ui_tooltip =        
		        "								   Zenteon - Radon Bloom           \n"
		        "\n================================================================================================="
		        "\n"
		        "\nRadon is an extension of Zenteon: Xenon that features a robust blur kernel and procedural dirt."
		        "\nIt uses matrixes to emulate the diffraction of a hexagonal aperture"
		        "\n"
		        "\n"
		        "\n=================================================================================================";
		>	
	{
		pass
		{
			VertexShader = PostProcessVS;
			PixelShader = DrawDirt;
			RenderTarget = QXMB::DirtDrawTex;
		}
		pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PrenDirt;
			RenderTarget = QXMB::DirtPrenTex;
		}
		pass
		{
			VertexShader = PostProcessVS;
			PixelShader = SaveDirt;
			RenderTarget = QXMB::DirtSaveTex;
		}
		pass
		{
			VertexShader = PostProcessVS;
			PixelShader = DrawTempBuffer;
			RenderTarget = QXMB::tempBufferTex;
		}
		
		pass
		{
			VertexShader = PostProcessVS;
			PixelShader = GenLightMap;
			RenderTarget = QXMB::LightMapTex;
		}
		
		pass {VertexShader = PostProcessVS; PixelShader = Down00;			RenderTarget = QXMB::downTex0;}
		pass {VertexShader = PostProcessVS; PixelShader = Down1;			 RenderTarget = QXMB::downTex1;}
		pass {VertexShader = PostProcessVS; PixelShader = Down2;			 RenderTarget = QXMB::downTex2;}
		pass {VertexShader = PostProcessVS; PixelShader = Down3;			 RenderTarget = QXMB::downTex3;}
		pass {VertexShader = PostProcessVS; PixelShader = Down4;			 RenderTarget = QXMB::downTex4;}
		pass {VertexShader = PostProcessVS; PixelShader = Down5;			 RenderTarget = QXMB::downTex5;}
		pass {VertexShader = PostProcessVS; PixelShader = Down6;			 RenderTarget = QXMB::downTex6;}
		pass {VertexShader = PostProcessVS; PixelShader = Down7;			 RenderTarget = QXMB::downTex7;}
		
		pass {VertexShader = PostProcessVS; PixelShader = Up00;			 RenderTarget = QXMB::upTex6;}
		pass {VertexShader = PostProcessVS; PixelShader = Up0;			 RenderTarget = QXMB::upTex5;}
		pass {VertexShader = PostProcessVS; PixelShader = Up1;			 RenderTarget = QXMB::upTex4;}
		pass {VertexShader = PostProcessVS; PixelShader = Up2;			 RenderTarget = QXMB::upTex3;}
		pass {VertexShader = PostProcessVS; PixelShader = Up3;			 RenderTarget = QXMB::upTex2;}
		pass {VertexShader = PostProcessVS; PixelShader = Up4;			 RenderTarget = QXMB::upTex1;}
		pass {VertexShader = PostProcessVS; PixelShader = Up5;			 RenderTarget = QXMB::upTex0;}
		
		pass {VertexShader = PostProcessVS; PixelShader = Save0;			 RenderTarget = QXMB::saveTex0;}
		
		pass {VertexShader = PostProcessVS; PixelShader = Down01;			RenderTarget = QXMB::downTex0;}
		pass {VertexShader = PostProcessVS; PixelShader = Down1;			 RenderTarget = QXMB::downTex1;}
		pass {VertexShader = PostProcessVS; PixelShader = Down2;			 RenderTarget = QXMB::downTex2;}
		pass {VertexShader = PostProcessVS; PixelShader = Down3;			 RenderTarget = QXMB::downTex3;}
		pass {VertexShader = PostProcessVS; PixelShader = Down4;			 RenderTarget = QXMB::downTex4;}
		pass {VertexShader = PostProcessVS; PixelShader = Down5;			 RenderTarget = QXMB::downTex5;}
		pass {VertexShader = PostProcessVS; PixelShader = Down6;			 RenderTarget = QXMB::downTex6;}
		pass {VertexShader = PostProcessVS; PixelShader = Down7;			 RenderTarget = QXMB::downTex7;}
		
		pass {VertexShader = PostProcessVS; PixelShader = Up00;			 RenderTarget = QXMB::upTex6;}
		pass {VertexShader = PostProcessVS; PixelShader = Up0;			 RenderTarget = QXMB::upTex5;}
		pass {VertexShader = PostProcessVS; PixelShader = Up1;			 RenderTarget = QXMB::upTex4;}
		pass {VertexShader = PostProcessVS; PixelShader = Up2;			 RenderTarget = QXMB::upTex3;}
		pass {VertexShader = PostProcessVS; PixelShader = Up3;			 RenderTarget = QXMB::upTex2;}
		pass {VertexShader = PostProcessVS; PixelShader = Up4;			 RenderTarget = QXMB::upTex1;}
		pass {VertexShader = PostProcessVS; PixelShader = Up5;			 RenderTarget = QXMB::upTex0;}
		
		pass {VertexShader = PostProcessVS; PixelShader = Save1;			 RenderTarget = QXMB::saveTex1;}
		
		pass {VertexShader = PostProcessVS; PixelShader = Down02;			RenderTarget = QXMB::downTex0;}
		pass {VertexShader = PostProcessVS; PixelShader = Down1;			 RenderTarget = QXMB::downTex1;}
		pass {VertexShader = PostProcessVS; PixelShader = Down2;			 RenderTarget = QXMB::downTex2;}
		pass {VertexShader = PostProcessVS; PixelShader = Down3;			 RenderTarget = QXMB::downTex3;}
		pass {VertexShader = PostProcessVS; PixelShader = Down4;			 RenderTarget = QXMB::downTex4;}
		pass {VertexShader = PostProcessVS; PixelShader = Down5;			 RenderTarget = QXMB::downTex5;}
		pass {VertexShader = PostProcessVS; PixelShader = Down6;			 RenderTarget = QXMB::downTex6;}
		pass {VertexShader = PostProcessVS; PixelShader = Down7;			 RenderTarget = QXMB::downTex7;}
		
		pass {VertexShader = PostProcessVS; PixelShader = Up00;			 RenderTarget = QXMB::upTex6;}
		pass {VertexShader = PostProcessVS; PixelShader = Up0;			 RenderTarget = QXMB::upTex5;}
		pass {VertexShader = PostProcessVS; PixelShader = Up1;			 RenderTarget = QXMB::upTex4;}
		pass {VertexShader = PostProcessVS; PixelShader = Up2;			 RenderTarget = QXMB::upTex3;}
		pass {VertexShader = PostProcessVS; PixelShader = Up3;			 RenderTarget = QXMB::upTex2;}
		pass {VertexShader = PostProcessVS; PixelShader = Up4;			 RenderTarget = QXMB::upTex1;}
		pass {VertexShader = PostProcessVS; PixelShader = Up5;			 RenderTarget = QXMB::upTex0;}
		
		pass {VertexShader = PostProcessVS; PixelShader = Save2;			 RenderTarget = QXMB::saveTex2;}
		
		pass
		{
			VertexShader = PostProcessVS;
			PixelShader = MergeBloom;
			RenderTarget = QXMB::BloomTex;
		}
		
		pass
		{
			VertexShader = PostProcessVS;
			PixelShader = MatrixBloom;
		}
	}
#else	
	int Dx9Warning <
		ui_type = "radio";
		ui_text = "Oops, looks like you're using DX9\n"
			"if you would like to use Zenteon Shaders in DX9 games, please use a wrapper like DXVK or dgVoodoo2";
		ui_label = " ";
		> = 0;
		
	technique ZenteonPlusRadon <
	ui_label = "Zenteon+: Radon Bloom";
		    ui_tooltip =        
		        "								   Zenteon - Radon Bloom           \n"
		        "\n================================================================================================="
		        "\n"
		        "\nRadon is an extension of Zenteon: Xenon that features a robust blur kernel and procedural dirt."
		        "\nIt uses matrixes to emulate the diffraction of a hexagonal aperture"
		        "\n"
		        "\n"
		        "\n=================================================================================================";
		>	
	{ }
#endif	