//Enemy attack indicator types
enum indicator
{
	line,
	triangle,
	circle,
	rectangle
}

function freeze(amount)
{
	DoLater(1,
            function(data)
            {
                loopEmpty(data.time);
            },
            {
                time : hitFreeze + amount * global.freezeScale
            },
            true);
}

function loopEmpty(amount)
{
	var time = current_time;
	var dur = amount;

	while (current_time < time + dur)
	{
	
	}
	
	delta = defaultFramesPerSecond / game_get_speed(gamespeed_fps);
}

function shakeCamera(panAmount, rotAmount, duration) {
	oCamera.shakeAmount = hitShake + panAmount * global.cameraShakeMultiplier;
	oCamera.shakeDuration = hitFXDur + duration * global.cameraShakeDurMultiplier;
	oCamera.rotTo = hitRot + choose(rotAmount, -rotAmount) * global.cameraRotMultiplier;
}

function pushCamera(amount, direction) {
	oCamera.pushX = lengthdir_x(hitPush + amount * global.cameraPushMultiplier, direction);
	oCamera.pushY = lengthdir_y(hitPush + amount * global.cameraPushMultiplier, direction);
}

function zoomCamera(amount) {
	oCamera.zoomMultiplier = 1 - (hitZoom + amount * global.cameraZoomMultiplier);
}