atk = {
	dur : 0,
	maxDur : 0,
	dmg : 0,
	knockback : 0,
	piercing : true,
	damagedEnemies : ds_list_create(),
	destroyOnStop : false,
	destroyOnCollision : false,
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

function htbxMovement()
{
	//Simple movement
	move.hsp = approach(move.hsp, 0, abs(lengthdir_x(move.fric, move.dir)));
	move.vsp = approach(move.vsp, 0, abs(lengthdir_y(move.fric, move.dir)));
	move.dir = point_direction(0, 0, move.hsp, move.vsp);

	if (atk.destroyOnStop && move.hsp == 0 && move.vsp == 0) destroySelf();

	x += move.hsp * delta;
	y += move.vsp * delta;
	
	if (place_meeting(x, y, parCollision)) { executeFunctionArray(collisionFunctions); }
	if (atk.destroyOnCollision && place_meeting(x, y, parCollision)) destroySelf();
}

array_push(aliveFunctions, htbxMovement);

function htbxHitDetection()
{
	//Hitbox only becomes active when delay is over
	atk.hitDelay = approach(atk.hitDelay, 0, 1);

	if (atk.hitDelay == 0 && atk.dur > atk.maxDur - atk.hitEnd)
	{
		if (atk.piercing)
		{
			getTouchingObjects(atk.damagedEnemies, atk.target, dealDamage);
		} else
		{
			var enemy = instance_place(x, y, atk.target);
			if (enemy != noone) { dealDamage(enemy); }
		}
	}
}

array_push(aliveFunctions, htbxHitDetection);

function decreaseLifetime()
{
	//See if boi needs to be destroyed
	atk.dur = approach(atk.dur, 0, 1);
	if (atk.dur <= 0) destroySelf();
}

array_push(aliveFunctions, decreaseLifetime);

function htbxVisuals()
{
	//Animation
	visuals.frm = approach(visuals.frm, image_number - 1, visuals.animSpd);
	image_index = floor(visuals.frm);

	visuals.trailFX(move);
}

array_push(aliveFunctions, htbxVisuals);

array_push(aliveFunctions, depthSorting);

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