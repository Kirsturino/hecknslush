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

//Debug
show_debug_overlay(true);

//Init colors
globalvar transparent;
transparent = thisIsNothing;

//Move to next room automatically
room_goto_next();