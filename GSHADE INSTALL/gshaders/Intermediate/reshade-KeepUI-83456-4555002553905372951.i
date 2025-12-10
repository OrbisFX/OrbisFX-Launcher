// KeepUIType=0
// KeepUIDebug=0
#line 1 "unknown"

#line 1 "C:\Program Files\GShade\gshade-shaders\Shaders\KeepUI.fx"
#line 50
uniform int bKeepUIForceType <
ui_type = "combo";
ui_category = "Options";
ui_label = "UI Detection Type Override";
#line 63
ui_tooltip = "Manually enable a specific UI detection type for unsupported games.";
#line 67
ui_items = "Disabled\0Alpha\0Shared Depth\0Dedicated Depth\0";
#line 69
ui_bind = "KeepUIType";
#line 77
> = 0;
#line 241
technique FFKeepUI <
ui_label = "KeepUI";
#line 244
ui_tooltip = "Place this at the top of your Technique list to save the UI into a texture for restoration with FFRestoreUI.\n"
"To use this Technique, you must also enable \"FFRestoreUI\".\n";
#line 249
>
{
#line 266
}
#line 268
technique FFRestoreUI <
ui_label = "RestoreUI";
#line 271
ui_tooltip = "Place this at the bottom of your Technique list to restore the UI texture saved by FFKeepUI.\n"
"To use this Technique, you must also enable \"FFKeepUI\".\n";
#line 279
>
{
#line 288
}

