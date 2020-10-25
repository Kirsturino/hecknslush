//Set up quick reference
#macro view view_camera[0]

//Setup camera variables
camera_set_view_pos(view, 0, 0);
window_set_size(viewWidth * global.windowScale, viewHeight * global.windowScale);

//Apply camera
camera_set_view_size(view, room_width, room_height);
surface_resize(application_surface, viewWidth , viewHeight);


//Camera variables
xTo = 0;
yTo = 0;

//Camera shake variables
shakeDuration = 0;
shakeAmount = 0;
shakeX = 0;
shakeY = 0;

//Camera push variables
pushX = 0;
pushY = 0;

//Camera zoom stuff
zoomMultiplier = 1;
zoomLerpSpeed = 0.1;
zoomOffsetX = 0;
zoomOffsetY = 0;

//Camera rotation
rot = 0;

function cameraShake() {
	if (shakeDuration > 0)
	{
		var amount = irandom_range(-shakeAmount, shakeAmount);
		shakeX = amount;
		amount = irandom_range(-shakeAmount, shakeAmount);
		shakeY = amount;
	
		shakeDuration--;
	} else
	{
		shakeX = 0;
		shakeY = 0;
	}
}

function cameraPush() {
	//Smoothly reset camera push
	pushX = approach(pushX, 0, 1);
	pushY = approach(pushY, 0, 1);
}

function cameraRotation() {
	rot = lerp(rot, 0, 0.1);
	camera_set_view_angle(view, rot);
}

function cameraZoom() {
	zoomMultiplier = lerp(zoomMultiplier, 1, zoomLerpSpeed);

	zoomOffsetX = viewWidth - (viewWidth * zoomMultiplier);
	zoomOffsetY = viewHeight - (viewHeight * zoomMultiplier);

	camera_set_view_size(view, room_width * zoomMultiplier, room_height * zoomMultiplier);
}