enum HUD {
	all,
	minimal,
	hidden,
	upgrade
}

hpBar = {
	delay : 0,
	delayMax : 200,
	chunkLength : 0,
}

function initUI() constructor
{
	y = 0;
	yTarget = 0;
	yActiveTarget = viewHeight/4;
	yInactiveTarget = -viewHeight/4;
	txt = "";
	time = 0;
	timeMax = 500;
	alpha = 1;
	
	function toFading()
	{
		state = fading;
	}
	
	function toInactive()
	{
		drawFunction = nothing;
		state = nothing;
	}
	
	function active()
	{
		y = lerp(y, yTarget, 0.05);
		
		time = approach(time, 0, 1);
		if (time == 0) { toFading(); }
	}
	
	function drawNotification()
	{
		var width = string_width(txt)*1.5;
		var height = string_height(txt)*1.5;
		draw_sprite_ext(sPixel, 0, viewWidth/2 - width/2, y + height, width, -height*1.5, -2, c_white, alpha);
		
		scribble_set_blend(c_black, alpha);
		scribble_draw(viewWidth/2, y, txt);
	}
	
	function fading()
	{
		alpha = approach(alpha, 0, 0.01);
		if (alpha == 0) { toInactive(); }
	}
	
	state = nothing;
	drawFunction = nothing;
}

notification = new initUI();