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

var space = 16;
scribble_draw(8, space, txt);
scribble_draw(8, space * 2, "combo: " + string(melee.combo));
scribble_draw(8, space * 3, "comboLength: " + string(curMeleeWeapon.comboLength));
scribble_draw(8, space * 4, "comboComplete: " + string(melee.comboComplete));
scribble_draw(8, space * 5, "meleeCooldown: " + string(melee.cooldown));
scribble_draw(8, space * 6, "comboBuffered: " + string(checkBufferForState(states.meleeing)));