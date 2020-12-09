//WIP upgrade randomization
var size = ds_list_size(global.upgradePool);
var upg = irandom(size);
upgrade = global.upgradePool[| upg];
ds_list_delete(global.upgradePool, upg);

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
		toApplying();
	}
}

function inactive()
{
	var plr = collision_circle(x, y, 32, oPlayer, false, false);
	if (plr != noone) { toActive(); }
}

function applying()
{
	if (input_check_press(verbs.right))
	{
		if (selected != oPlayer.abilityAmount - 1)	{ selected++; }
	} else if (input_check_press(verbs.left))
	{
		if (selected != 0)	{ selected--; }
	} else if (input_check_press(verbs.interact))
	{
		applyUpgrade(oPlayer.attackSlots[selected], upgrade);
	}
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

function toApplying()
{
	drawFunction = nothing;
	state = applying;
	playerToDummy();
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
	scribble_set_starting_format("fntScribble", c_red, fa_center);
	var wav = wave(-5, 5, 4, 0, true);
	scribble_draw(x, ystart + 16 + wav, "button prompt", 0);
	scribble_draw(x, ystart - 32 + wav, upgrade.name, 0);
}