//Set up quick reference
#macro view view_camera[0]

//Init camera
#macro viewWidth 640
#macro viewHeight 360
global.windowScale = 2;

//FX scaling
global.cameraFXMultiplier = 0.1;

enum cameraStates {
	follow,
	aim,
	scripted
}

function shakeCamera(panAmount, rotAmount, duration) {
	oCamera.shakeAmount = panAmount * global.cameraFXMultiplier;
	oCamera.shakeDuration = duration;
	oCamera.rotTo = choose(rotAmount, -rotAmount) * global.cameraFXMultiplier;
}

function pushCamera(amount, direction) {
	oCamera.pushX = lengthdir_x(amount * global.cameraFXMultiplier, direction);
	oCamera.pushY = lengthdir_y(amount * global.cameraFXMultiplier, direction);
}

function rotateCamera(amount, randomized) {
	var setRot = amount * global.cameraFXMultiplier;
	
	if (randomized) setRot *= choose(-1, 1);

	oCamera.rot = setRot;
}

function zoomCamera(amount) {
	oCamera.zoomMultiplier = 1 - amount * global.cameraFXMultiplier;
}