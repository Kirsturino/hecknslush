//WIP upgrade randomization
var size = ds_list_size(POOL_BUFF);
var bf = irandom(size-1);
if (size != 0)	{ buff = POOL_BUFF[| bf]; }
else			{ instance_destroy(); }

//Some graphics variables
selected = 0;
selectX = 0;
selectY = 0;

function active()
{
	var plr = collision_circle(x, y, 32, oPlayer, false, false);
	if (plr == noone) { toInactive(); }
	
	highlight();
	
	if (input_check_press(verbs.interact, 0, 0))
	{
		applyBuff(buff);
	}
}

function inactive()
{
	highlight();
	
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


function highlight()
{
	var xx = x + irandom_range(-6, 6);
	var yy = y + irandom_range(-6, 6);
	part_particles_create(global.ps, xx, yy, global.hangingDustPart, 1);
}

function buttonPrompt()
{
	scribble_set_blend(col.white, 1);
	var wav = wave(-5, 5, 4, 0, true);
	scribble_draw(x, ystart + 16 + wav, "button prompt", 0);
	scribble_draw(x, ystart - 32 + wav, buff.name, 0);
}