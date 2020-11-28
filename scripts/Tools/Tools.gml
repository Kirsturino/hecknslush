function approach(value, to, amount) {
	if (value < to)
	{
	    value += amount * delta;
	    if (value > to) return to;
	}
	else
	{
	    value -= amount * delta;
	    if (value < to) return to;
	}
	return value;
}

function wave(from, to, duration, offset, sine) {
	var a4 = (to - from) * 0.5;

	//Ternary operator stuff
	var waveType = sine		?	sin((((current_time * 0.001) + duration * offset) / duration) * (pi*2))
							:	cos((((current_time * 0.001) + duration * offset) / duration) * (pi*2));
	
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