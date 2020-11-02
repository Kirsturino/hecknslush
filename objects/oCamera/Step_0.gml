//Apply effects
cameraShake();
cameraPush();
cameraRotation();
cameraZoom();

switch (state) {
	case cameraStates.follow:
		followPlayer();
	break;
	
	case cameraStates.aim:
		followPlayerAim();
	break;
}