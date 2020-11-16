//I don't want to run a switch statement every frame, but can't come up with a better solution
switch (state) {
	case states.grounded:
		playerGrounded();
	break;
	
	case states.sprinting:
		playerSprinting();
	break;
	
	case states.dummy:
		playerDummy();
	break;
	
	case states.meleeing:
		playerMeleeing();
	break;
	
	case states.shooting:
		playerShooting();
	break;
	
	case states.dodging:
		playerDodging();
	break;
	
	case states.aiming:
		playerAiming();
	break;
	
	default:
		show_message("Hey, idiot. Your state machine broke");
	break;
}

depth = -y - sprite_height / 2;

//Things that should be done almost always
if (state == states.dummy || state == states.dead) exit;
cameraStateSwitch();
updateStateBuffer();
incrementVerbCooldowns();