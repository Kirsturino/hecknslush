//WIP upgrade randomization
var size = ds_list_size(global.upgradePool);
var upg = irandom(size-1);
if (size != 0)	{ upgrade = global.upgradePool[| upg]; }
else			{ instance_destroy(); }

//Some graphics variables
selected = 0;
selectX = viewWidth/4;
selectY = viewHeight;

uiEaseInTimer = 1.5;
uiEaseLerp = 2;

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
	highlight();
	
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
	
	//Ease UI elements in
	uiEaseInTimer = approach(uiEaseInTimer, 1, 0.01);
	uiEaseLerp = lerp(uiEaseLerp, uiEaseInTimer, 0.05);
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
	var txt = upgrade.desc;
	scribble_cache(txt, "desc", true, false);
	scribble_autotype_fade_in(txt, 1, 1, false, "desc");
	
	drawFunction = nothing;
	state = applying;
	playerToDummy();
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
	scribble_draw(x, ystart - 32 + wav, upgrade.name, 0);
}