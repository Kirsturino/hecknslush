//Init camera
#macro viewWidth 320
#macro viewHeight 180
global.windowScale = 3;

function shakeCamera(amount, duration) {
	oCamera.shakeAmount = amount;
	oCamera.shakeDuration = duration;
}

function pushCamera(amount, direction) {
	oCamera.pushX = lengthdir_x(amount, direction);
	oCamera.pushY = lengthdir_y(amount, direction);
}

function rotateCamera(amount, randomized) {
	var setRot = amount;
	var rand = randomized;
	
	if (rand) setRot *= choose(-1, 1);

	oCamera.rot = setRot;
}

function zoomCamera(amount) {
	oCamera.zoomMultiplier = amount;
}