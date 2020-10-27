// Shell scripts can be defined here
// Method names must start with sh_, but will not include that when being invoked
// For example, to invoke sh_test_method from an rt-shell, you would simply type test_method
// 
// If a method returns a string value, it will be print to the shell output

//function sh_get_bgspeed() {
//	var bgHspeed = obj_test_room.bgHspeed;
//	var bgVspeed = obj_test_room.bgVspeed;
//	return "hspeed: " + string(bgHspeed) + ", vspeed: " + string(bgVspeed);
//}

//// If you want a method to take arguments at the command line, pass in an args object here
//// args[0] will always be the function name, args[1] and onwards will be your actual arguments
//function sh_set_bg_hspeed(args) {
//	var newHspeed = args[1];
//	try {
//		obj_test_room.bgHspeed = real(newHspeed);
//	} catch (e) {
//		return e.message;
//	}
//}

//function sh_set_bg_vspeed(args) {
//	var newVspeed = args[1];
//	try {
//		obj_test_room.bgVspeed = real(newVspeed);
//	} catch (e) {
//		return e.message;
//	}
//}

// Here is an example of a shell script that takes multiple command line arguments
// See how I've assigned args[1], args[2], and args[3] into local variables for easier use
function sh_set_bg_color(args) {
	var red = args[1];
	var green = args[2];
	var blue = args[3];
	
	var backgroundId = layer_background_get_id(layer_get_id("Background"));
	layer_background_blend(backgroundId, make_color_rgb(red, green, blue));
}

function sh_test_duplicate_spawn() {
	instance_create_layer(0, 0, "Instances", oShell);
}

function sh_set_shell_width(args) {
	oShell.width = args[1];
}

function sh_set_shell_height(args) {
	oShell.height = args[1];
}

function sh_set_shell_anchor(args) {
	var newAnchor = args[1];
	if (newAnchor == "top" || newAnchor == "bottom") {
		oShell.screenAnchorPoint = newAnchor;
	} else {
		return "Invalid anchor point. Possible values: [top, bottom]";
	}
}

function activateConsole() {
	playerToDummy();
	global.timeScale = 0;
}

function closeConsole() {
	playerToGrounded();
	global.timeScale = 1;
}

//function sh_say_greeting(args) {
//	var whomToGreet = args[1];
//	return "Hello " + whomToGreet + "!";
//}

//function sh_theme_rtshell_dark() {
//	oShell.consoleAlpha = 0.9;
//	oShell.consoleColor = c_black;
//	oShell.fontColor = make_color_rgb(255, 242, 245);
//	oShell.fontColorSecondary = make_color_rgb(140, 118, 123);
//	oShell.cornerRadius = 12;
//	oShell.anchorMargin = 4;
//	oShell.promptColor = make_color_rgb(237, 0, 54);
//	oShell.prompt = "$";
//}

//function sh_theme_rtshell_light() {
//	oShell.consoleAlpha = 0.9;
//	oShell.consoleColor = make_color_rgb(235, 235, 235);
//	oShell.fontColor = make_color_rgb(40, 40, 45);
//	oShell.fontColorSecondary = make_color_rgb(120, 120, 128);
//	oShell.cornerRadius = 12;
//	oShell.anchorMargin = 4;
//	oShell.promptColor = make_color_rgb(29, 29, 196);
//	oShell.prompt = "$";
//}

//function sh_theme_ocean_blue() {
//	oShell.consoleAlpha = 1;
//	oShell.consoleColor = make_color_rgb(29, 31, 33);
//	oShell.fontColor = make_color_rgb(197, 200, 198);
//	oShell.fontColorSecondary = make_color_rgb(116, 127, 140);
//	oShell.cornerRadius = 0;
//	oShell.anchorMargin = 0;
//	oShell.promptColor = make_color_rgb(57, 113, 237);
//	oShell.prompt = "%";
//}

//function sh_theme_dracula() {
//	oShell.consoleAlpha = 1;
//	oShell.consoleColor = make_color_rgb(40, 42, 54);
//	oShell.fontColor = make_color_rgb(248, 248, 242);
//	oShell.fontColorSecondary = make_color_rgb(98, 114, 164);
//	oShell.cornerRadius = 8;
//	oShell.anchorMargin = 4;
//	oShell.promptColor = make_color_rgb(80, 250, 123);
//	oShell.prompt = "->";
//}

//function sh_theme_solarized_light() {
//	oShell.consoleAlpha = 1;
//	oShell.consoleColor = make_color_rgb(253, 246, 227);
//	oShell.fontColor = make_color_rgb(101, 123, 131);
//	oShell.fontColorSecondary = make_color_rgb(147, 161, 161);
//	oShell.cornerRadius = 2;
//	oShell.anchorMargin = 4;
//	oShell.promptColor = make_color_rgb(42, 161, 152);
//	oShell.prompt = "~";
//}

//function sh_theme_solarized_dark() {
//	oShell.consoleAlpha = 1;
//	oShell.consoleColor = make_color_rgb(0, 43, 54);
//	oShell.fontColor = make_color_rgb(131, 148, 150);
//	oShell.fontColorSecondary = make_color_rgb(88, 110, 117);
//	oShell.cornerRadius = 2;
//	oShell.anchorMargin = 4;
//	oShell.promptColor = make_color_rgb(42, 161, 152);
//	oShell.prompt = "~";
//}

//--------------------------------------------------------
//Custom rt-shell scripts
//--------------------------------------------------------

//Go to given room
//Give room name as it appears in resource tree
function sh_room_goto(args) {
	var rm = asset_get_index(args[1]);
	
	if (rm != -1) {
		room_goto(rm);
	} else {
		return "Invalid room name: " + string(args[1]);
	}
}

//Set fps of game, mainly for delta time testing
function sh_set_fps(args) {
	game_set_speed(args[1], gamespeed_fps);
}

//Quit game
function sh_room_restart() {
	room_restart();
}

function sh_game_end() {
	game_end();
}

//Execute any custom global script
function sh_script_execute(args) {
	var scr = asset_get_index(args[1]);
	
	script_execute(scr);
}

//BE CAREFUL WITH THIS! DOESN'T LIMIT WHAT YOU CAN SET THE VALUES TO AND WILL CRASH IF YOU SET A WRONG VALUE
function sh_set_global(args) {
	if (variable_global_exists(args[1])) {
		variable_global_set(args[1], args[2]);
	} else {
		return "Invalid global variable: " + string(args[1]);
	}
}