if (combat.iframes == 0 || combat.iframes mod 40 < 10) {
	draw_sprite_ext(visuals.curSprite, 0, x, y, visuals.xScale, visuals.yScale, visuals.rot, c_white, 1);
}

switch (state) {
	case states.grounded:
		
	break;
	
	case states.sprinting:
		
	break;
	
	case states.dummy:
		
	break;
	
	case states.meleeing:
		
	break;
	
	case states.shooting:
		drawAimIndicator();
	break;
	
	case states.dodging:

	break;
	
	case states.aiming:
		drawAimIndicator();
	break;
	
	default:
		show_message("Hey, idiot. Your state machine broke");
	break;
}