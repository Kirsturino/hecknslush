atk = {
	dur : 0,
	maxDur : 0,
	dmg : 0,
	knockback : 0,
	damagedEnemies : ds_list_create(),
	hitDelay : 0,
	hitEnd : 0,
	target : parEnemy
}

//Movement variables
move = {
	hsp : 0,
	vsp : 0,
	dir : 0,
	fric : 0.05
}

visuals = {
	animSpd : 0.5,
	frm : 0,
	size : 1,
	type : weapons.melee,
	hitStop : true,
	trailFX : nothing,
	damageFX : nothing,
	explosionFX : nothing,
}

misc = {
	from : noone,
}

//Added behaviour functions
spawnFunctions =		[];
aliveFunctions =		[];
hitFunctions =			[];
collisionFunctions =	[];
destroyFunctions =		[];

function destroySelf()
{
	executeFunctionArray(destroyFunctions);
	ds_list_destroy(atk.damagedEnemies);
	visuals.explosionFX();
	instance_destroy();
}

function decreaseLifetime()
{
	//See if boi needs to be destroyed
	atk.dur = approach(atk.dur, 0, 1);
	if (atk.dur <= 0) destroySelf();
}

function htbxVisuals()
{
	//Animation
	visuals.frm = approach(visuals.frm, image_number - 1, visuals.animSpd);
	image_index = floor(visuals.frm);

	visuals.trailFX(move);
}

array_push(aliveFunctions, decreaseLifetime, htbxVisuals, depthSorting);

//Execute spawn functions after a frame has passed because jank
DoLater(1,
            function(data)
            {
                executeFunctionArray(data.array);
            },
            {
                array : spawnFunctions,
            },
            true);