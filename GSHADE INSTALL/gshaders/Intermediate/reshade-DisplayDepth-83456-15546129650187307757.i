#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\DisplayDepth.fx"
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
#line 10 "C:\Program Files\GShade\gshade-shaders\Shaders\DisplayDepth.fx"
#line 36
uniform int iUIPresentType <
ui_label = "Present type";
ui_label_ja_jp = "画面効果";
ui_type = "combo";
ui_items = "Depth map\0Normal map\0Show both (Vertical 50/50)\0";
ui_items_ja_jp = "深度マップ\0法線マップ\0両方を表示 (左右分割)\0";
ui_text =
"The right settings need to be set in the dialog that opens after clicking the \"Edit global preprocessor definitions\" button above.\n"
"\n"
"RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN is currently set to " "0" ".\n"
"If the Depth map is shown upside down set it to " "1" ".\n"
"\n"
"RESHADE_DEPTH_INPUT_IS_REVERSED is currently set to " "0" ".\n"
"If close objects in the Depth map are bright and far ones are dark set it to " "1" ".\n"
"Also try this if you can see the normals, but the depth view is all black.\n"
"\n"
"RESHADE_DEPTH_INPUT_IS_LOGARITHMIC is currently set to " "0" ".\n"
"If the Normal map has banding artifacts (extra stripes) set it to " "1" ".";
ui_text_ja_jp =
#line 60
"調節が終わったら、上の'プリプロセッサの定義を編集'ボタンをクリックした後に開くダイアログに入力する必要があります。\n"
"\n"
"RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWNは現在" "0" "に設定されています。\n"
"深度マップが上下逆さまに表示されている場合は" "1" "に変更して下さい。\n"
"\n"
"RESHADE_DEPTH_INPUT_IS_REVERSEDは現在" "0" "に設定されています。\n"
"画面効果が深度マップのとき、近くの形状がより白く、遠くの形状がより黒い場合は" "1" "に変更して下さい。\n"
"また、法線マップで形が判別出来るが、深度マップが真っ暗に見えるという場合も、この設定の変更を試して下さい。\n"
"\n"
"RESHADE_DEPTH_INPUT_IS_LOGARITHMICは現在" "0" "に設定されています。\n"
"画面効果に実際のレンダリングと合致しない縞模様がある場合は" "1" "に変更して下さい。";
#line 72
ui_tooltip_ja_jp =
"'深度マップ'は、形状の遠近を白黒で表現します。正しい見え方では、近くの形状ほど黒く、遠くの形状ほど白くなります。\n"
"'法線マップ'は、形状を滑らかに表現します。正しい見え方では、全体的に青緑風で、地平線を見たときに地面が緑掛かった色合いになります。\n"
"'両方を表示 (左右分割)'が選択された場合は、左に法線マップ、右に深度マップを表示します。";
> = 2;
#line 78
uniform bool bUIShowOffset <
ui_label = "Blend Depth map into the image (to help with finding the right offset)";
ui_label_ja_jp = "透かし比較";
ui_tooltip_ja_jp = "補正作業を支援するために、画面効果を半透過で適用します。";
> = false;
#line 84
uniform bool bUIUseLivePreview <
ui_category = "Preview settings";
ui_category_ja_jp = "基本的な補正";
#line 88
ui_category_toggle = true;
#line 90
ui_label = "Show live preview and ignore preprocessor definitions";
ui_label_ja_jp = "プリプロセッサの定義を無視 (補正プレビューをオン)";
ui_tooltip = "Enable this to preview with the current preset settings instead of the global preprocessor settings.";
ui_tooltip_ja_jp =
"共通設定に保存されたプリプロセッサの定義ではなく、これより下のプレビュー設定を使用するには、これを有効にします。\n"
#line 98
"設定の準備が出来たら、上の'プリプロセッサの定義を編集'ボタンをクリックした後に開くダイアログに入力して下さい。"
#line 100
"\n\n"
"プレビューをオンにした場合と比較して画面効果がまったく同じになれば、正しく設定が反映されています。";
> = false;
#line 104
uniform bool iUIUpsideDown <
ui_category = "Preview settings";
ui_label = "Upside Down";
ui_label_ja_jp = "深度バッファの上下反転を修正";
ui_text_ja_jp =
"\n"
#line 113
"項目にカーソルを合わせると、設定が必要な状況の説明と、プリプロセッサの定義が表示されます。"
#line 115
;
ui_tooltip_ja_jp =
"深度マップが上下逆さまに表示されている場合は変更して下さい。"
#line 119
"\n\n"
"定義名は次の通りです。文字は完全に一致する必要があり、半角大文字の英字とアンダーバーを用いなければなりません。\n"
"RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN=値\n"
"定義値は次の通りです。オンの場合は1、オフの場合は0を指定して下さい。\n"
"RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN=1\n"
"RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN=0"
#line 126
;
> = 0;
#line 129
uniform bool iUIReversed <
ui_category = "Preview settings";
ui_label = "Reversed";
ui_label_ja_jp = "深度バッファの奥行反転を修正";
ui_tooltip_ja_jp =
"画面効果が深度マップのとき、近くの形状が明るく、遠くの形状が暗い場合は変更して下さい。\n"
"また、法線マップで形が判別出来るが、深度マップが真っ暗に見えるという場合も、この設定の変更を試して下さい。"
#line 137
"\n\n"
"定義名は次の通りです。文字は完全に一致する必要があり、半角大文字の英字とアンダーバーを用いなければなりません。\n"
"RESHADE_DEPTH_INPUT_IS_REVERSED=値\n"
"定義値は次の通りです。オンの場合は1、オフの場合は0を指定して下さい。\n"
"RESHADE_DEPTH_INPUT_IS_REVERSED=1\n"
"RESHADE_DEPTH_INPUT_IS_REVERSED=0"
#line 144
;
> = 0;
#line 147
uniform bool iUILogarithmic <
ui_category = "Preview settings";
ui_label = "Logarithmic";
ui_label_ja_jp = "深度バッファを対数分布として扱うように修正";
ui_tooltip = "Change this setting if the displayed surface normals have stripes in them.";
ui_tooltip_ja_jp =
"画面効果に実際のゲーム画面と合致しない縞模様がある場合は変更して下さい。"
#line 155
"\n\n"
"定義名は次の通りです。文字は完全に一致する必要があり、半角大文字の英字とアンダーバーを用いなければなりません。\n"
"RESHADE_DEPTH_INPUT_IS_LOGARITHMIC=値\n"
"定義値は次の通りです。オンの場合は1、オフの場合は0を指定して下さい。\n"
"RESHADE_DEPTH_INPUT_IS_LOGARITHMIC=1\n"
"RESHADE_DEPTH_INPUT_IS_LOGARITHMIC=0"
#line 162
;
> = 0;
#line 167
uniform float2 fUIScale <
ui_category = "Preview settings";
ui_label = "Scale";
ui_label_ja_jp = "拡大率";
ui_type = "drag";
ui_text =
"\n"
" * Advanced options\n"
"\n"
"The following settings also need to be set using \"Edit global preprocessor definitions\" above in order to take effect.\n"
"You can preview how they will affect the Depth map using the controls below.\n"
"\n"
"It is rarely necessary to change these though, as their defaults fit almost all games.\n\n";
ui_text_ja_jp =
"\n"
" * その他の補正 (不定形またはその他)\n"
"\n"
"これより下は、深度バッファが不定形など、特別なケース向けの設定です。\n"
"通常はこれより上の'基本的な補正'のみでほとんどのゲームに適合します。\n"
"また、これらの設定は画質の向上にはまったく役に立ちません。\n\n";
ui_tooltip =
"Best use 'Present type'->'Depth map' and enable 'Offset' in the options below to set the scale.\n"
"Use these values for:\nRESHADE_DEPTH_INPUT_X_SCALE=<left value>\nRESHADE_DEPTH_INPUT_Y_SCALE=<right value>\n"
"\n"
"If you know the right resolution of the games depth buffer then this scale value is simply the ratio\n"
"between the correct resolution and the resolution Reshade thinks it is.\n"
"For example:\n"
"If it thinks the resolution is 1920 x 1080, but it's really 1280 x 720 then the right scale is (1.5 , 1.5)\n"
"because 1920 / 1280 is 1.5 and 1080 / 720 is also 1.5, so 1.5 is the right scale for both the x and the y";
ui_tooltip_ja_jp =
"深度バッファの解像度がクライアント解像度と異なる場合に変更して下さい。\n"
"このスケール値は、深度バッファの解像度とクライアント解像度との単純な比率になります。\n"
"深度バッファの解像度が1280×720でクライアント解像度が1920×1080の場合、横の比率が1920÷1280、縦の比率が1080÷720となります。\n"
"計算した結果を設定すると、値はそれぞれX_SCALE=1.5、Y_SCALE=1.5となります。"
#line 202
"\n\n"
"定義名は次の通りです。文字は完全に一致する必要があり、半角大文字の英字とアンダーバーを用いなければなりません。\n"
"RESHADE_DEPTH_INPUT_X_SCALE=横の値\n"
"RESHADE_DEPTH_INPUT_Y_SCALE=縦の値\n"
"定義値は次の通りです。横の値はX_SCALE、縦の値はY_SCALEに指定して下さい。\n"
"RESHADE_DEPTH_INPUT_X_SCALE=1.0\n"
"RESHADE_DEPTH_INPUT_Y_SCALE=1.0"
#line 210
;
ui_min = 0.0; ui_max = 2.0;
ui_step = 0.001;
> = float2(1, 1);
#line 215
uniform int2 iUIOffset <
ui_category = "Preview settings";
ui_label = "Offset";
ui_label_ja_jp = "位置オフセット";
ui_type = "slider";
ui_tooltip =
"Best use 'Present type'->'Depth map' and enable 'Offset' in the options below to set the offset in pixels.\n"
"Use these values for:\nRESHADE_DEPTH_INPUT_X_PIXEL_OFFSET=<left value>\nRESHADE_DEPTH_INPUT_Y_PIXEL_OFFSET=<right value>";
ui_tooltip_ja_jp =
"深度バッファにレンダリングされた物体の形状が画面効果と重なり合っていない場合に変更して下さい。\n"
"この値は、ピクセル単位で指定します。"
#line 227
"\n\n"
"定義名は次の通りです。文字は完全に一致する必要があり、半角大文字の英字とアンダーバーを用いなければなりません。\n"
"RESHADE_DEPTH_INPUT_X_PIXEL_OFFSET=横の値\n"
"RESHADE_DEPTH_INPUT_Y_PIXEL_OFFSET=縦の値\n"
"定義値は次の通りです。横の値はX_PIXEL_OFFSET、縦の値はY_PIXEL_OFFSETに指定して下さい。\n"
"RESHADE_DEPTH_INPUT_X_PIXEL_OFFSET=0.0\n"
"RESHADE_DEPTH_INPUT_Y_PIXEL_OFFSET=0.0"
#line 235
;
ui_min = -float2(1920, 1018);
ui_max = float2(1920, 1018);
ui_step = 1;
> = int2(0, 0);
#line 241
uniform float fUIFarPlane <
ui_category = "Preview settings";
ui_label = "Far Plane";
ui_label_ja_jp = "遠点距離";
ui_type = "drag";
ui_tooltip =
"RESHADE_DEPTH_LINEARIZATION_FAR_PLANE=<value>\n"
"Changing this value is not necessary in most cases.";
ui_tooltip_ja_jp =
"深度マップの色合いが距離感と合致しない、法線マップの表面が平面に見える、などの場合に変更して下さい。\n"
"遠点距離を1000に設定すると、ゲームの描画距離が1000メートルであると見なします。\n\n"
"このプレビュー画面はあくまでプレビューであり、ほとんどの場合、深度バッファは深度マップの色数より遥かに高い精度で表現されています。\n"
"例えば、10m前後の距離の形状が純粋な黒に見えるからという理由で値を変更しないで下さい。"
#line 255
"\n\n"
"定義名は次の通りです。文字は完全に一致する必要があり、半角大文字の英字とアンダーバーを用いなければなりません。\n"
"RESHADE_DEPTH_LINEARIZATION_FAR_PLANE=値\n"
"定義値は次の通りです。\n"
"RESHADE_DEPTH_LINEARIZATION_FAR_PLANE=1000.0"
#line 261
;
ui_min = 0.0; ui_max = 1000.0;
ui_step = 0.1;
> = 1000.0;
#line 266
uniform float fUIDepthMultiplier <
ui_category = "Preview settings";
ui_label = "Multiplier";
ui_label_ja_jp = "深度乗数";
ui_type = "drag";
ui_tooltip = "RESHADE_DEPTH_MULTIPLIER=<value>";
ui_tooltip_ja_jp =
"特定のエミュレータソフトウェアにおける深度バッファを修正するため、特別に追加された変数です。\n"
"この値は僅かな変更でも計算式を破壊するため、設定すべき値を知らない場合は変更しないで下さい。"
#line 276
"\n\n"
"定義名は次の通りです。文字は完全に一致する必要があり、半角大文字の英字とアンダーバーを用いなければなりません。\n"
"RESHADE_DEPTH_MULTIPLIER=値\n"
"定義値は次の通りです。\n"
"RESHADE_DEPTH_MULTIPLIER=1.0"
#line 282
;
ui_min = 0.0; ui_max = 1000.0;
ui_step = 0.001;
> = 1;
#line 287
float GetLinearizedDepth(float2 texcoord)
{
if (!bUIUseLivePreview)
{
return ReShade::GetLinearizedDepth(texcoord);
}
else
{
if (iUIUpsideDown) 
texcoord.y = 1.0 - texcoord.y;
#line 298
texcoord.x /= fUIScale.x; 
texcoord.y /= fUIScale.y; 
texcoord.x -= iUIOffset.x * (1.0 / 1920); 
texcoord.y += iUIOffset.y * (1.0 / 1018); 
#line 303
float depth = tex2Dlod(ReShade::DepthBuffer, float4(texcoord, 0, 0)).x * fUIDepthMultiplier;
#line 305
const float C = 0.01;
if (iUILogarithmic) 
depth = (exp(depth * log(C + 1.0)) - 1.0) / C;
#line 309
if (iUIReversed) 
depth = 1.0 - depth;
#line 312
const float N = 1.0;
depth /= fUIFarPlane - depth * (fUIFarPlane - N);
#line 315
return depth;
}
}
#line 319
float3 GetScreenSpaceNormal(float2 texcoord)
{
float3 offset = float3(float2((1.0 / 1920), (1.0 / 1018)), 0.0);
float2 posCenter = texcoord.xy;
float2 posNorth  = posCenter - offset.zy;
float2 posEast   = posCenter + offset.xz;
#line 326
float3 vertCenter = float3(posCenter - 0.5, 1) * GetLinearizedDepth(posCenter);
float3 vertNorth  = float3(posNorth - 0.5,  1) * GetLinearizedDepth(posNorth);
float3 vertEast   = float3(posEast - 0.5,   1) * GetLinearizedDepth(posEast);
#line 330
return normalize(cross(vertCenter - vertNorth, vertCenter - vertEast)) * 0.5 + 0.5;
}
#line 333
void PS_DisplayDepth(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float3 color : SV_Target)
{
float3 depth = GetLinearizedDepth(texcoord).xxx;
float3 normal = GetScreenSpaceNormal(texcoord);
#line 340
const float dither_bit = 8.0; 
#line 342
float grid_position = frac(dot(texcoord, (float2(1920, 1018) * float2(1.0 / 16.0, 10.0 / 36.0)) + 0.25));
#line 344
float dither_shift = 0.25 * (1.0 / (pow(2, dither_bit) - 1.0));
#line 346
float3 dither_shift_RGB = float3(dither_shift, -dither_shift, dither_shift); 
#line 348
dither_shift_RGB = lerp(2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position);
depth += dither_shift_RGB;
#line 352
color = depth;
if (iUIPresentType == 1)
color = normal;
if (iUIPresentType == 2)
color = lerp(normal, depth, step(1920 * 0.5, position.x));
#line 358
if (bUIShowOffset)
{
float3 color_orig = tex2D(ReShade::BackBuffer, texcoord).rgb;
#line 363
color = lerp(2 * color * color_orig, 1.0 - 2.0 * (1.0 - color) * (1.0 - color_orig), max(color.r, max(color.g, color.b)) < 0.5 ? 0.0 : 1.0);
}
}
#line 367
technique DisplayDepth <
ui_tooltip =
"This shader helps you set the right preprocessor settings for depth input.\n"
"To set the settings click on 'Edit global preprocessor definitions' and set them there - not in this shader.\n"
"The settings will then take effect for all shaders, including this one.\n"
"\n"
"By default calculated normals and depth are shown side by side.\n"
"Normals (on the left) should look smooth and the ground should be greenish when looking at the horizon.\n"
"Depth (on the right) should show close objects as dark and use gradually brighter shades the further away objects are.\n";
ui_tooltip_ja_jp =
"これは、深度バッファの入力をReShade側の計算式に合わせる調節をするための、設定作業の支援に特化した特殊な扱いのエフェクトです。\n"
"初期状態では「両方を表示」が選択されており、左に法線マップ、右に深度マップが表示されます。\n"
"\n"
"法線マップ(左側)は、形状を滑らかに表現します。正しい設定では、全体的に青緑風で、地平線を見たときに地面が緑を帯びた色になります。\n"
"深度マップ(右側)は、形状の遠近を白黒で表現します。正しい設定では、近くの形状ほど黒く、遠くの形状ほど白くなります。\n"
"\n"
#line 386
"設定を完了するには、エフェクト変数の編集画面にある'プリプロセッサの定義を編集'ボタンをクリックした後に開くダイアログに入力して下さい。\n"
#line 388
"すると、インストール先のゲームに対して共通の設定として保存され、他のプリセットでも正しく表示されるようになります。";
>
#line 391
{
pass
{
VertexShader = PostProcessVS;
PixelShader = PS_DisplayDepth;
}
}

