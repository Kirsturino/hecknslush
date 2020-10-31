//Draw cooldown status
var space = 16;
var margin = 8;
var width = 12;
var barXOffset = string_width("CD: ");
var barYOffset = string_height("CD: ") / 2;
var barLength = ranged.cooldown;

scribble_draw(margin, margin, "CD:");
draw_line_width(margin + barXOffset, margin + barYOffset, margin + barXOffset + barLength, margin + barYOffset, width);

barLength = melee.cooldown;
scribble_draw(margin, margin + space, "CD:");
draw_line_width(margin + barXOffset, margin + space + barYOffset, margin + barXOffset + barLength, margin + space + barYOffset, width);

////This is player state debugging and just bad, but oh well, it's just debugging, I guess
//if (!global.debugPlayer) exit;

switch (state) {
	case states.grounded:
		var txt = "grounded";
	break;
	
	case states.dummy:
		var txt = "dummy";
	break;
	
	case states.meleeing:
		var txt = "meleeing";
	break;
	
	case states.shooting:
		var txt = "shooting";
	break;
	
	case states.dodging:
		var txt = "dodging";
	break;
	
	case states.aiming:
		var txt = "aiming";
	break;
	
	default:
		show_message("Hey, idiot. Your state machine broke");
	break;
}

scribble_draw(8, space * 3, txt);
//scribble_draw(8, space * 2, "combo: " + string(melee.combo));
//scribble_draw(8, space * 3, "comboLength: " + string(curMeleeWeapon.comboLength));
//scribble_draw(8, space * 4, "comboComplete: " + string(melee.comboComplete));
//scribble_draw(8, space * 5, "meleeCooldown: " + string(melee.cooldown));
//scribble_draw(8, space * 6, "comboBuffered: " + string(checkBufferForState(states.meleeing)));
//scribble_draw(8, space * 7, "verb.shoot: " + string(input_check(verbs.shoot)));