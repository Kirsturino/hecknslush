function active()
{
	var plr = collision_circle(x, y, 32, oPlayer, false, false);
	if (plr == noone) { toInactive(); }
	
	highlight();
	
	if (input_check_press(verbs.interact, 0, 0))
	{
		interact();
	}
}

function inactive()
{
	var plr = collision_circle(x, y, 32, oPlayer, false, false);
	if (plr != noone) { toActive(); }
}

state = inactive;
drawFunction = nothing;

function toActive()
{
	drawFunction = buttonPrompt;
	state = active;
}

function toInactive()
{
	drawFunction = nothing;
	state = inactive;
}

function interact()
{
	drawFunction = nothing;
	oPlayer.attackSlots[2].spread += 20;
	instance_destroy();
}

function highlight()
{
	if (random(1) > 0.9)
	{
		var xx = x + irandom_range(-6, 6);
		var yy = y + irandom_range(-6, 6);
		part_particles_create(global.ps, xx, yy, global.hangingDustPart, 1);
	}
}

function buttonPrompt()
{
	scribble_set_starting_format("fntScribble", c_white, fa_center);
	scribble_draw(x, ystart + 16, "button prompt", 0);
}