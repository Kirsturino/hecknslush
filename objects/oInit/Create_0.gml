//Init persistent delta time object
instance_create_layer(0, 0, layer, oDeltaTime);

//Init persistent surface handler
instance_create_layer(0, 0, layer, oSurfaceHandler);

//Init rt-shell
instance_create_layer(0, 0, layer, oShell);

//Init Scribble fonts
scribble_init("", "fntScribble", false);
scribble_add_font("fntScribble");
scribble_add_font("fntDebug");
scribble_set_starting_format("fntScribble", c_white, fa_center);

//Debug
//show_debug_overlay(true);
//window_set_cursor(cr_none);
//cursor_sprite = sCursor;

//Init colors

//Move to next room automatically
room_goto_next();