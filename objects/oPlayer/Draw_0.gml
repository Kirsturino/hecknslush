draw_self();

//This is player state debugging and just bad, but oh well, it's just debugging, I guess
if (!global.debugPlayer) exit;

switch (state) {
	case states.grounded:
		var txt = "grounded"
	break;
	
	case states.dummy:
		var txt = "dummy"
	break;
	
	case states.meleeing:
		var txt = "meleeing"
	break;
	
	case states.shooting:
		var txt = "shooting"
	break;
	
	case states.dodging:
		var txt = "dodging"
	break;
	
	default:
		show_message("Hey, idiot. Your state machine broke");
	break;
}

scribble_draw(8, 8, txt);
scribble_draw(8, 24, "hsp: " + string(move.hsp));
scribble_draw(8, 40, "vsp: " + string(move.vsp));