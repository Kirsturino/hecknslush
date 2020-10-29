//Set up quick reference
#macro view view_camera[0]

//Init camera
#macro viewWidth 480
#macro viewHeight 270
global.windowScale = 2;

//Limit GUI draw resolution
display_set_gui_size(viewWidth, viewHeight);

function shakeCamera(panAmount, rotAmount, duration) {
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