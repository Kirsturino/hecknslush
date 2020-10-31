switch (state) {
	case cameraStates.follow:
		followPlayer();
	break;
	
	case cameraStates.aim:
		followPlayerAim();
	break;
}