//I don't want to run a switch statement every frame, but can't come up with a better solution
switch (state) {
	case states.grounded:
		playerGrounded();
	break;
	
	case states.dummy:
		playerDummy();
	break;
}