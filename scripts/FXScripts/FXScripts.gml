//Default hitflash duration
#macro hitFlash 14

global.enemyAttackSurf = 0;
global.freezeScale = 0.1;
global.hitFXScale = 0.1;

//Enemy attack indicator types
enum indicator
{
	line,
	triangle,
	circle,
	rectangle
}

function freeze(amount) {
	var time = current_time;
	var dur = amount * global.freezeScale;

	while (current_time < time + dur)
	{
	
	}
	
	delta = defaultFramesPerSecond / game_get_speed(gamespeed_fps);
}