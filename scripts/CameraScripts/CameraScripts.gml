//Set up quick reference
#macro view view_camera[0]

//Init camera
#macro viewWidth 480
#macro viewHeight 270
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
	oCamera.rot = lerp(oCamera.rot, oCamera.rot + rotAmount, 0.5);
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