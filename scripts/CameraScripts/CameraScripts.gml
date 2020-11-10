//Set up quick reference
#macro view view_camera[0]

//Init camera
#macro viewWidth 640
#macro viewHeight 360
global.windowScale = 2;

//Limit GUI draw resolution
display_set_gui_size(viewWidth, viewHeight);

enum cameraStates {
	follow,
	aim,
	scripted
}

function shakeCamera(panAmount, rotAmount, duration) {
	oCamera.shakeAmount = panAmount;
	oCamera.shakeDuration = duration;
	oCamera.rotTo = choose(rotAmount, -rotAmount);
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