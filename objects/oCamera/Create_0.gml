//Center window
DoLater(1,
            function()
            {
                window_center();
            },
            0,
            true);
			
state = cameraStates.follow;

//Setup camera variables
camera_set_view_pos(view, 0, 0);
window_set_size(viewWidth * global.windowScale, viewHeight * global.windowScale);

//Apply camera
camera_set_view_size(view, viewWidth, viewHeight);
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

//TO-DO: ADD ROTATIONAL SHAKE
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

//TO-DO: REDO THIS LATER
function cameraZoom() {
	zoomMultiplier = lerp(zoomMultiplier, 1, zoomLerpSpeed);

	zoomOffsetX = viewWidth - (viewWidth * zoomMultiplier);
	zoomOffsetY = viewHeight - (viewHeight * zoomMultiplier);

	//camera_set_view_size(view, zoomMultiplier, zoomMultiplier);
}

function followPlayer() {
	//Apply effects
	cameraShake();
	cameraPush();
	cameraRotation();
	cameraZoom();

	curX = camera_get_view_x(view);
	curY = camera_get_view_y(view);

	var spd = .1;
	
	var posX = oPlayer.x  - viewWidth / 2;
	var posY = oPlayer.y - viewHeight / 2;
	
	xx = clamp(posX, 0, room_width - viewWidth / 2);
	yy = clamp(posY, 0, room_height - viewHeight / 2);
	
	xTo = lerp(curX, xx + shakeX + pushX, spd);
	yTo = lerp(curY, yy + shakeY + pushY, spd);

	camera_set_view_pos(view, xTo, yTo);
}

function followPlayerAim() {
	//Apply effects
	cameraShake();
	cameraPush();
	cameraRotation();
	cameraZoom();

	curX = camera_get_view_x(view);
	curY = camera_get_view_y(view);

	var spd = .1;
	var multiplier = 10;
	
	var dist = min(oPlayer.curRangedWeapon.spd * multiplier, point_distance(oPlayer.x, oPlayer.y, mouse_x, mouse_y));
	var posX = oPlayer.x  - viewWidth / 2 + lengthdir_x(dist, oPlayer.ranged.aimDir);
	var posY = oPlayer.y - viewHeight / 2 + lengthdir_y(dist, oPlayer.ranged.aimDir);
	
	xx = clamp(posX, 0, room_width - viewWidth / 2);
	yy = clamp(posY, 0, room_height - viewHeight / 2);
	
	xTo = lerp(curX, xx + shakeX + pushX, spd);
	yTo = lerp(curY, yy + shakeY + pushY, spd);

	camera_set_view_pos(view, xTo, yTo);
}