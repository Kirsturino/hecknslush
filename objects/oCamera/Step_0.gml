//Apply effects
cameraShake();
cameraPush();
cameraRotation();
cameraZoom();

curX = camera_get_view_x(view);
curY = camera_get_view_y(view);

var spd = .1;
	
xx = clamp(oPlayer.x - viewWidth / 2, 0, room_width - viewWidth / 2);
yy = clamp(oPlayer.y - viewHeight / 2, 0, room_height - viewHeight / 2);
	
xTo = lerp(curX, xx + shakeX + pushX, spd);
yTo = lerp(curY, yy + shakeY + pushY, spd);

camera_set_view_pos(view, xTo, yTo);