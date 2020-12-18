function approach(value, to, amount) {
	if (value < to)
	{
	    value += amount * delta;
	    if (value > to) return to;
	} else
	{
	    value -= amount * delta;
	    if (value < to) return to;
	}
	return value;
}

function wave(from, to, duration, offset, sine) {
	var a4 = (to - from) * 0.5;

	//Ternary operator stuff
	var waveType = sine		?	sin((((current_time * 0.001) + duration + offset) / duration) * (pi*2))
							:	cos((((current_time * 0.001) + duration + offset) / duration) * (pi*2));
	
	return from + a4 + waveType * a4;
}

function isOutsideRoom(objectID) {
	with (objectID) {	
		if (x < -sprite_width || x > room_width + sprite_width)			{ return true; }
		else if (y < -sprite_height || y > room_height + sprite_height) { return true; }
		else															{ return false; }
	}
}

function nothing()
{
	
}

function debug()
{
	show_debug_message("This code is being run.");
}

function executeFunctionArray(array)
{
	//Run through functions in an array
	var length = array_length(array);
	for (var i = 0; i < length; ++i) { array[i](); }
}

function startNotification(txt_string)
{
	with (oUI.notification)
	{
		y = yInactiveTarget;
		time = timeMax;
		txt = txt_string;
		yTarget = yActiveTarget;
		alpha = 1;
		state = active;
		drawFunction = drawNotification;
	}
}

/// smoothstep(a,b,x)
//
//  Returns 0 when (x < a), 1 when (x >= b), a smooth transition
//  from 0 to 1 otherwise, or (-1) on error (a == b).
//
//      a           upper bound, real
//      b           lower bound, real
//      x           value, real
//
/// GMLscripts.com/license
function smoothstep(from, to, timer)
{
    var p;
    if (timer < from) return 0;
    if (timer >= to) return 1;
    if (from == to) return -1;
    p = (timer - from) / (to - from);
    return (p * p * (3 - 2 * p));
}