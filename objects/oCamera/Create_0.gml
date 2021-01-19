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
surface_resize(application_surface, viewWidth, viewHeight);

//Limit GUI draw resolution
display_set_gui_size(viewWidth, viewHeight);

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

//Camera rotation
rot = 0;
rotTo = 0;

//Cull
cullDistance = 128;
cullX = -9999;
cullY = -9999;
cullAmount = 0;

function cameraShake() {
	if (shakeDuration > 0) {
		var amount = irandom_range(-shakeAmount, shakeAmount);
		shakeX = amount;
		amount = irandom_range(-shakeAmount, shakeAmount);
		shakeY = amount;
	} else {
		shakeX = 0;
		shakeY = 0;
		shakeAmount = 0;
	}
	
	shakeAmount = approach(shakeAmount, 0, 2);
	shakeDuration = approach(shakeDuration, 0, 1);
}

function cameraPush() {
	//Smoothly reset camera push
	pushX = approach(pushX, 0, 1);
	pushY = approach(pushY, 0, 1);
}

function cameraRotation() {
	rot = lerp(rot, rotTo, 0.1 * delta);
	rotTo = approach(rotTo, 0, 1);
}

function cameraZoom() {
	zoomMultiplier = lerp(zoomMultiplier, 1, zoomLerpSpeed * delta);
}

function followPlayer() {
	var spd = .05;
	var finalWidth = viewWidth * zoomMultiplier;
	var finalHeight = viewHeight * zoomMultiplier;
	
	var posX = oPlayer.x  - finalWidth / 2;
	var posY = oPlayer.y - finalHeight / 2;
	
	xx = clamp(posX, 0, room_width - finalWidth);
	yy = clamp(posY, 0, room_height - finalHeight);
	
	applyCameraPos(spd, finalWidth, finalHeight);
}

function followPlayerAim() {
	var spd = .05;
	var finalWidth = viewWidth * zoomMultiplier;
	var finalHeight = viewHeight * zoomMultiplier;
	
	var playerGun = oPlayer.attackSlots[oPlayer.combat.curAttack];
	var playerAim = oPlayer.combat.aimDir;
	var dist = min(point_distance(oPlayer.x, oPlayer.y, mouse_x, mouse_y) * playerGun.zoom, 100);
	var posX = oPlayer.x  - finalWidth / 2 + lengthdir_x(dist, playerAim);
	var posY = oPlayer.y - finalHeight / 2 + lengthdir_y(dist, playerAim);
	
	xx = clamp(posX, 0, room_width - finalWidth);
	yy = clamp(posY, 0, room_height - finalHeight);
	
	applyCameraPos(spd, finalWidth, finalHeight);
}

function applyCameraPos(spd, width, height) {
	curX = camera_get_view_x(view);
	curY = camera_get_view_y(view);
	
	xTo = lerp(curX, xx + shakeX + pushX, spd);
	yTo = lerp(curY, yy + shakeY + pushY, spd);

	camera_set_view_pos(view, xTo, yTo);
	camera_set_view_angle(view, rot);
	camera_set_view_size(view, width, height);
}

function cull(obj)
{
	var camX = curX;
	var camY = curY;
	
	var shouldCull =	camX > cullX + cullDistance || camX < cullX - cullDistance ||
						camY > cullY + cullDistance || camY < cullY - cullDistance;
	if (shouldCull)
	{
		cullAmount++;
		show_debug_message("culling: " + string(cullAmount));
		cullX = curX;
		cullY = curY;
		
		with (obj)
		{
			var offscreen =	(x < camX - other.cullDistance|| x > camX + viewWidth + other.cullDistance) ||
							(y < camY - other.cullDistance || y > camY + viewHeight + other.cullDistance);
						
			if	(offscreen)	{visible = false;}
			else			{visible = true;}
		}
	}
}

