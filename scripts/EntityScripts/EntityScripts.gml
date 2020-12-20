//Collection of functions/structs most entities/actors ingame will most likely want to call at some point
#region Misc. scripts
function depthSorting()
{
	depth = -bbox_bottom;
}

function getTouchingObjects(list, object, func)
{
	//Populate list of currently colliding enemies
	var enemyList = ds_list_create();
	var enemies = instance_place_list(x, y, object, enemyList, false);
	
	//Go through list of enemies
	var i = 0;
	repeat(enemies) {
		//If enemy isn't found in the list, do something and add it to the list of things
		var enemyInList = enemyList[| i];
		
		if (ds_list_find_index(list, enemyInList) == -1) {
			ds_list_add(list, enemyInList);
			
			//Do something with object
			func(enemyInList);
		}
		
		i++;
	}
	
	//Destroy list from memory, get rekt
	ds_list_destroy(enemyList);
}

function dealDamage(enemy)
{
	//All of this is executed in the hit object to reduce the amount of object. calls
	with (enemy)
	{
		if (enemy.combat.iframes > 0) return;
		
		var htbx = other.id;
		
		//FX
		hitFX(htbx);
		
		//Hardcoded to give the player cooldowns, maybe refactor later
		//REFACTOR THIS TO BE AN ONHIT FUNCTION ADDED TO WEAPONS
		if (htbx.atk.target == parEnemy)
		{
			refreshPlayerCooldowns(htbx);
		}
		
		//Reduce hp
		takeDamage(ceil(htbx.atk.dmg));
		
		//Inflict knockback
		inflictKnockback(htbx);
		
		//Stun enemy if applicable
		if (combat.stunnable) toStunned(htbx.atk.dmg);
	}
	
	executeFunctionArray(hitFunctions);
}

function negateMomentum()
{
	move.hsp = 0;
	move.vsp = 0;
}

function staticMovement()
{
	//Simple movement
	move.hsp = approach(move.hsp, 0, abs(lengthdir_x(move.fric, move.dir)));
	horizontalCollision();
	
	move.vsp = approach(move.vsp, 0, abs(lengthdir_y(move.fric, move.dir)));
	verticalCollision();
	
	move.dir = point_direction(0, 0, move.hsp, move.vsp);

	x += move.hsp * delta;
	y += move.vsp * delta;
}

function avoidOverlap()
{
	var phys = instance_place(x, y, parPhysical);
	
	if (phys != noone) {
		var dir = point_direction(phys.x, phys.y, x, y);

		move.hsp += lengthdir_x(0.05, dir) * delta;
		move.vsp += lengthdir_y(0.05, dir) * delta;
	}
}

function moveInDirection(amount, direction)
{
	x += lengthdir_x(amount * delta, direction);
	y += lengthdir_y(amount * delta, direction);
}

function canSee(instance)
{
	var los = collision_line(x, y, instance.x, instance.y, parCollision, false, false);
	
	if (los == noone) return true;
	
	return false;
}

function refreshPlayerCooldowns(htbx)
{
	with  (oPlayer)
	{
		var length = array_length(attack);
		for (var i = 0; i < length; ++i) {
			//Check if the cooldown type matches and that an ability can't charge itself
			//Charge granted is proportional to damage inflicted
			if (attackSlots[i].cooldownType == recharge.damage && htbx.misc.from != attackSlots[i])
			{	
				attack[i].cooldown = approach(attack[i].cooldown, 0, htbx.atk.dmg * global.damageRechargeMultiplier);
			}
		}
	}
}

function inflictKnockback(htbx)
{
	if (htbx.move.hsp != 0 || htbx.move.vsp != 0)	{ var dir = htbx.move.dir; }
	else											{ var dir = htbx.image_angle; }
		
		move.hsp = lengthdir_x(htbx.atk.knockback, dir);
		move.vsp = lengthdir_y(htbx.atk.knockback, dir);
		move.dir = dir;
}

function hitFX(htbx)
{
	//Hitflash
	setFlash(htbx.atk.dmg);
	
	//Squash and stretch
	setSquash(htbx.atk.dmg);
		
	//Hitstop & camera stuff
	if (htbx.visuals.hitStop) {
		freeze(htbx.atk.dmg);
			
		//This prevents hitstop from happening when hitting multiple enemies
		htbx.visuals.hitStop = false;
	}
		
	shakeCamera(htbx.atk.dmg, htbx.atk.dmg, hitFXDur);
	pushCamera(htbx.atk.dmg, htbx.move.dir);
	zoomCamera(htbx.atk.dmg);
		
	//Particles
	htbx.visuals.damageFX(htbx.atk.dmg * global.hitFXParticleScale);
}

function incrementAnimationFrame()
{
	visuals.frm += visuals.spd * delta;
	
	//Reset squash
	visuals.xScale = lerp(visuals.xScale, 1, 0.1 * delta);
	visuals.yScale = lerp(visuals.yScale, 1, 0.1 * delta);
	
	//THIS IS WIP, PLAYER WILL USE THIS SAME SYSTEM LATER WHEN IT GETS ART
	if (object_index != oPlayer)
	{
		var maxFrames = sprite_get_number(visuals.finalSpr);
		if (visuals.frm > maxFrames) { visuals.frm = frac(visuals.frm); }
		
		//Decide whether to use up or down sprite
		//Current implementation tries to minimze struct calls, but is a little unclean
		//This could be replaced by a simple local var in the draw event that gets redefined every frame
		//Performance implications are unknown, needs testing
		if (move.dir < 180 &&  move.dir != 0 && visuals.spriteStruct != visuals.up)
		{
			visuals.spriteStruct = visuals.up;
			visuals.finalSpr = variable_struct_get(visuals.spriteStruct, visuals.curSprite);
		}
		else if (move.dir > 180 && visuals.spriteStruct != visuals.down)
		{
			visuals.spriteStruct = visuals.down;
			visuals.finalSpr = variable_struct_get(visuals.spriteStruct, visuals.curSprite);
		}
	} else
	{
		if (visuals.frm > image_number) { visuals.frm = frac(visuals.frm); }
	}
}

function pushEntities(xx, yy, force, radius, objToPush, shouldStun)
{
	with (objToPush)
	{
		var dist = distance_to_point(xx, yy);
		
		if (dist < radius)
		{
			var dir = point_direction(xx, yy, x, y);
			var pushAmount = force - dist * 0.02 * combat.weight;
			
			move.hsp = lengthdir_x(pushAmount, dir);
			move.vsp = lengthdir_y(pushAmount, dir);
			move.dir = dir;
			
			if (shouldStun) toStunned(144);
		}
	}
}

function setSquash(amount)
{
	visuals.yScale = 1 + (hitSquash + amount * global.hitFXSquashScale);
	visuals.xScale = 1 - (hitSquash + amount * global.hitFXSquashScale);
}

function setFlash(amount)
{
	visuals.flash = hitFlash + amount * global.hitFXFlashScale;
}
#endregion

#region ATTACKING

function spawnHitbox(weapon, attack)
{
	var spawnX = x + lengthdir_x(weapon.reach, attack.htbxDir);
	var spawnY = y + lengthdir_y(weapon.reach, attack.htbxDir);
	
	if (weapon.type = weapons.ranged)
	{
		//Ranged hitboxes spawn at the end of the gun sprite
		spawnX += lengthdir_x(sprite_get_width(weapon.spr), attack.htbxDir);
		spawnY += lengthdir_y(sprite_get_width(weapon.spr), attack.htbxDir);
	}
	
	//Impart weapon stats to hitbox
	var htbx = instance_create_layer(spawnX, spawnY, "Instances", weapon.htbx);
	
	//Hitbox qualities that are shared
	
	//Miscellaneous stuff
	htbx.misc.from = weapon;
	
	//Visual stuff
	htbx.sprite_index = weapon.projSpr;
	htbx.image_angle = attack.htbxDir;
	htbx.visuals.size = weapon.size * global.projectileSizeMultiplier;
	htbx.image_xscale = weapon.size * global.projectileSizeMultiplier;
	htbx.image_yscale = weapon.size * global.projectileSizeMultiplier;
	if (weapon.mirror) htbx.image_yscale = attack.mirror;
	htbx.image_blend = weapon.clr;
	htbx.visuals.type = weapon.type;
	
	//Determine effects
	weapon.attackFX(weapon, attack, spawnX, spawnY);
	htbx.visuals.trailFX = weapon.trailFX;
	htbx.visuals.explosionFX = weapon.explosionFX;
	htbx.visuals.damageFX = weapon.damageFX;
	visuals.recoil = weapon.dmg;
	
	//Movement
	htbx.move.hsp = lengthdir_x(weapon.spd * (1 + random(weapon.spread) * 0.01) * global.projectileSpeedMultiplier, attack.htbxDir);
	htbx.move.vsp = lengthdir_y(weapon.spd * (1 + random(weapon.spread) * 0.01) * global.projectileSpeedMultiplier, attack.htbxDir);
	htbx.move.fric = weapon.fric;
	
	//Combat stuff
	htbx.atk.dur = weapon.life;
	htbx.atk.maxDur = weapon.life;	
	htbx.atk.dmg = weapon.dmg * global.damageMultiplier;
	htbx.atk.knockback = weapon.knockback * global.projectileKnockbackMultiplier;
	htbx.atk.hitDelay = weapon.start;
	htbx.atk.hitEnd = weapon.length;
	
	//Pass extra behaviour functions
	pushArrayToArray(weapon.spawnFunctions, htbx.spawnFunctions);
	pushArrayToArray(weapon.aliveFunctions, htbx.aliveFunctions);
	pushArrayToArray(weapon.hitFunctions, htbx.hitFunctions);
	pushArrayToArray(weapon.collisionFunctions, htbx.collisionFunctions);
	pushArrayToArray(weapon.destroyFunctions, htbx.destroyFunctions);
	
	//Determine if this should hit enemies or player
	if (object_index == oPlayer)	{ htbx.atk.target = parEnemy; }
	else							{ htbx.atk.target = oPlayer; }
}

function pushArrayToArray(arrayFrom, arrayTo)
{
	var length = array_length(arrayFrom);
	for (var i = 0; i < length; ++i)
		{ array_push(arrayTo, arrayFrom[i]); }
}

function attackLogic(weapon, attack)
{
	if (attack.anticipationDur > 0)
	{
		attack.anticipationDur = approach(attack.anticipationDur, 0, 1);
		attack.dur = weapon.dur;
	} else if (attack.count < weapon.amount && attack.dur < weapon.dur - weapon.delay)
	{
		if (weapon.aimable) { attack.dir = getAttackDir(); }
		performAttack(weapon, attack);
	} else if (attack.count == weapon.amount && attack.burstCount < weapon.burstAmount)
	{
		//If we have multiple bursts, reset attacks between bursts, increment burst counter and start new burst
		attack.count = 0;
		attack.burstCount++;
		attack.dur = weapon.dur + weapon.burstDelay;
	}
	
	//Count attack duration down
	if (attack.anticipationDur == 0) attack.dur = approach(attack.dur, 0, 1);
	
	//Set cooldowns and reset attack variables if we're transitioning out of attack
	if (attack.dur <= 0) { resetAttack(weapon, attack); }
}

function performAttack(weapon, attack) {
	//If delay is 0, it shoots multiple bullets per dur cycle
	//Bullets in burst can have multispread
	if (weapon.delay == 0)
	{
		//Loop through all the bullets in the burst
		repeat (weapon.amount)
		{
			calculateHtbxDir(weapon, attack);
			spawnHitbox(weapon, attack);
			incrementAttack(weapon, attack);
		}
		
		setAttackMovement(weapon.push * weapon.amount, weapon, attack);
	} else
	{ 
		//This is where we go if we only shoot 1 bullet per frame, aka delay > 0
		calculateHtbxDir(weapon, attack);		
		spawnHitbox(weapon, attack);
		incrementAttack(weapon, attack);
		setAttackMovement(weapon.push, weapon, attack);
	}
}

function calculateHtbxDir(weapon, attack)
{
	attack.htbxDir = attack.dir;
			
	//If weapon has multispread, do some directional calculation for each projectile based on the multispread variable
	if (weapon.multiSpread > 0)
	{
		var bulletDir = (weapon.multiSpread / (weapon.amount - 1) * attack.count) - weapon.multiSpread * .5;
		attack.htbxDir = attack.dir + attack.mirror * bulletDir;
	}
			
	attack.htbxDir += irandom_range(-weapon.spread, weapon.spread);
}

function incrementAttack(weapon, attack) {
	//Increment shot count for burst weapons
	attack.count++;
		
	//Set time before player is able to move again
	attack.dur = weapon.dur;
}

function resetAttack(weapon, attack) {
	//Reset individual attack values
	attack.count = 0;
	attack.burstCount = 0;
	attack.cooldown = weapon.cooldown;
	attack.anticipationDur = weapon.anticipationDur;
		
	if (weapon.mirror) attack.mirror *= -1;
}
	
function attackMovement() {
	move.hsp = approach(move.hsp, 0, abs(lengthdir_x(move.fric, move.dir)));
	horizontalCollision();
	
	move.vsp = approach(move.vsp, 0, abs(lengthdir_y(move.fric, move.dir)));
	verticalCollision();
	
	x += move.hsp * delta;
	y += move.vsp * delta;
}
	
function setAttackMovement(amount, weapon, attack) {
	switch (object_index)
	{
		case oPlayer:
			//if (input_player_source_get(0) == INPUT_SOURCE.KEYBOARD_AND_MOUSE)	{ move.dir = point_direction(x, y, mouse_x, mouse_y); }
			//else if (!isHoldingDirection())										{ move.dir = move.lastDir; }
			//else																	{ move.dir = getMovementInputDirection(); }
			
			if (!weapon.aimable)	{ move.dir = attack.dir; }
			else					{ move.dir = point_direction(x, y, mouse_x, mouse_y); }
		break;
		
		case parEnemy:
			move.dir = attack.dir;
		break;
	}
	
	//Set entity speed to attack speed
	move.hsp = lengthdir_x(amount, move.dir);
	move.vsp = lengthdir_y(amount, move.dir);
}

#endregion