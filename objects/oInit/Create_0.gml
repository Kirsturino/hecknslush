//Init persistent delta time object
instance_create_layer(0, 0, layer, oDeltaTime);

//Init persistent surface handler
instance_create_layer(0, 0, layer, oSurfaceHandler);

//Init rt-shell
instance_create_layer(0, 0, layer, oShell);

//Init UI
instance_create_layer(0, 0, layer, oUI);

//Init Scribble fonts
scribble_init("", "fntScribble", false);
scribble_add_font("fntScribble");
scribble_add_font("fntUpgradeTitle");
scribble_set_starting_format("fntScribble", c_white, fa_center);

//Debug
//show_debug_overlay(true);
//window_set_cursor(cr_none);
//cursor_sprite = sCursor;

//Init colors
global.palette = {
	enemy : other.enemyColor,
	enemyDeep : other.enemyColorDeep,
	white : other.white,
	black : other.black,
	tan : other.tan1,
	blue : other.blue,
	green : other.green,
}
#macro col global.palette

global.abilityColors = [
	col.enemy,
	col.blue,
	col.green
]

//Init particles
particleInit();

//Move to next room automatically
room_goto_next();