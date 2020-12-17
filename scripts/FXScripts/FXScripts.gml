//Enemy attack indicator types
enum shapes
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

//Vector-based FX call system
function makeCircle(x, y, radius, incr_size, wiggle, life, color, outline) constructor
{
	xx = x;
	yy = y;
	
	size = radius;
	sizeChange = incr_size;
	sizeWiggle = wiggle;
	
	dur = life;
	clr = color;
	border = outline;
	
	function drawShape()
	{
		var wig = random_range(-sizeWiggle, sizeWiggle);
		var finalRadius = size + wig;
		draw_circle_color(xx, yy, finalRadius, clr, clr, border);
	}
}

function makeTriangle(x, y, radius, incr_size, wiggle, rot, life, color, outline) constructor
{
	xx = x;
	yy = y;
	
	size = radius;
	sizeChange = incr_size;
	sizeWiggle = wiggle;
	angle = rot;
	
	dur = life;
	clr = color;
	border = outline;
	
	function drawShape()
	{
		var wig = random_range(-sizeWiggle, sizeWiggle);
		
		var x1 = xx + lengthdir_x(size + wig, angle);
		var y1 = yy + lengthdir_y(size + wig, angle);
		var x2 = xx + lengthdir_x(size + wig, angle + 120);
		var y2 = yy + lengthdir_y(size + wig, angle + 120);
		var x3 = xx + lengthdir_x(size + wig, angle + 240);
		var y3 = yy + lengthdir_y(size + wig, angle + 240);
		
		draw_triangle_color(x1, y1, x2, y2, x3, y3, clr, clr, clr, border);
	}
}

function makeRectangle(x, y, radius, incr_size, wiggle, life, color, outline) constructor
{
	xx = x;
	yy = y;
	
	size = radius;
	sizeChange = incr_size;
	sizeWiggle = wiggle;
	
	dur = life;
	clr = color;
	border = outline;
	
	function drawShape()
	{
		var wig = random_range(-sizeWiggle, sizeWiggle);
		var x1 = xx - size + wig;
		var y1 = yy - size + wig;
		var x2 = xx + size + wig;
		var y2 = yy + size + wig;
		
		draw_rectangle_color(x1, y1, x2, y2, clr, clr, clr, clr, border);
	}
}

function vectorShapeCall(x, y, shape, size, incr_size, wiggle, rot, life, color, outline)
{
	var effect;
	switch (shape)
	{	
		case shapes.triangle:
			effect = new makeTriangle(x, y, size, incr_size, wiggle, rot, life, color, outline);
		break;
		
		case shapes.circle:
			effect = new makeCircle(x, y, size, incr_size, wiggle, life, color, outline);
		break;
		
		case shapes.rectangle:
		effect = new makeRectangle(x, y, size, incr_size, wiggle, life, color, outline);
		break;
	}
	
	variable_struct_set(oFXDrawer.vectorCalls, string(oFXDrawer.vectorIndex), effect);
	oFXDrawer.vectorIndex++;
}