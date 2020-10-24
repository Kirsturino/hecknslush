//Init persistent delta time object
instance_create_layer(0, 0, layer, oDeltaTime);

//Init rt-shell
instance_create_layer(0, 0, layer, oShell);

//Init Scribble fonts
scribble_init("", "fntScribble", false);
scribble_add_font("fntScribble");

//Move to next room automatically
room_goto_next();