//Collection of functions most entities/actors ingame will most likely want to call at some point

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
			script_execute(func, enemyInList);
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
		var htbx = other.id;
		
		if (enemy.combat.iframes <= 0)
		{
			//Hardcoded to give the player cooldowns, maybe refactor later
			if (htbx.atk.target == oEnemyBase)
			{
				refreshPlayerCooldowns(htbx.atk.dmg);
			}
		
			//Reduce hp
			takeDamage(htbx.atk.dmg);
		
			//Inflict knockback
			inflictKnockback(htbx);
		
			//FX
			hitFX(htbx);
		}
	}
	
	//Destroy projectile if it's not piercing
	if (!atk.piercing) destroySelf();
}

function negateMomentum()
{
	move.hsp = 0;
	move.vsp = 0;
}

function staticMovement()
{
	//Simple movement
	move.hsp = approach(move.hsp, 0, move.fric);
	horizontalCollision();
	
	move.vsp = approach(move.vsp, 0, move.fric);
	verticalCollision();

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

function refreshPlayerCooldowns(amount)
{
	with  (oPlayer)
	{
		var length = array_length(attack);
		for (var i = 0; i < length; ++i) {
			if (attackSlots[i].cooldownType == recharge.damage) attack[i].cooldown = approach(attack[i].cooldown, 0, amount * global.damageRechargeMultiplier);
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
	visuals.flash = max(hitFlash, hitFlash * htbx.atk.dmg);
	
	//Squash and stretch
	visuals.yScale += htbx.atk.dmg;
	visuals.xScale -= htbx.atk.dmg;
		
	//Hitstop & camera stuff
	if (htbx.visuals.hitStop) {
		freeze(min(htbx.atk.dmg * 40, 200));
			
		//This prevents hitstop from happening when hitting multiple enemies
		htbx.visuals.hitStop = false;
	}
		
	shakeCamera(htbx.atk.dmg * 40, htbx.atk.dmg * 2, 4);
	pushCamera(htbx.atk.dmg * 20, htbx.move.dir);
	zoomCamera(1 - htbx.atk.dmg * 0.05);
		
	//Particles
	htbx.visuals.damageFX(htbx.atk.dmg);

	//Stun enemy if applicable
	if (combat.stunnable) toStunned(htbx.atk.dmg * 40);
}

function incrementAnimationFrame()
{
	visuals.frm += visuals.spd * delta;
	
	if (visuals.frm > image_number) {
		visuals.frm = frac(visuals.frm);
	}
	
	//Reset squash
	visuals.xScale = lerp(visuals.xScale, 1, 0.1 * delta);
	visuals.yScale = lerp(visuals.yScale, 1, 0.1 * delta);
}

//Enemy functions
function drawAttackIndicator(visuals, weapon, attack)
{
	var camX = camera_get_view_x(view);
	var camY = camera_get_view_y(view);
	var c = c_red;
	var c2 = c_black;
	
	switch (visuals.indicatorType)
	{
		case indicator.line:
			var drawX = x + lengthdir_x(visuals.indicatorLength, attack.dir) - camX;
			var drawY = y + lengthdir_y(visuals.indicatorLength, attack.dir) - camY;
			
			draw_line_width_color(x - camX, y - camY, drawX, drawY, 10, c, c2);
		break;
		
		case indicator.triangle:
			var drawX = x - camX;
			var drawY = y - camY;
			var drawX2 = x + lengthdir_x(visuals.indicatorLength, attack.dir - weapon.spread) - camX;
			var drawY2 = y + lengthdir_y(visuals.indicatorLength, attack.dir - weapon.spread) - camY;
			var drawX3 = x + lengthdir_x(visuals.indicatorLength, attack.dir + weapon.spread) - camX;
			var drawY3 = y + lengthdir_y(visuals.indicatorLength, attack.dir + weapon.spread) - camY;
			
			draw_triangle_color(drawX, drawY, drawX2, drawY2, drawX3, drawY3, c, c2, c2, false);
		break;
	}
}

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
	
	//Visual stuff
	htbx.sprite_index = weapon.projSpr;
	htbx.image_angle = attack.htbxDir;
	htbx.visuals.size = weapon.size;
	htbx.image_xscale = weapon.size;
	htbx.image_yscale = weapon.size;
	if (weapon.mirror) htbx.image_yscale = attack.mirror;
	htbx.image_blend = weapon.clr;
	visuals.recoil = weapon.dmg * 20;
	htbx.visuals.type = weapon.type;
	
	//Determine effects
	weapon.attackFX(weapon, attack, spawnX, spawnY);
	htbx.visuals.trailFX = weapon.trailFX;
	htbx.visuals.explosionFX = weapon.explosionFX;
	htbx.visuals.damageFX = weapon.damageFX;
	
	//Movement
	htbx.move.hsp = lengthdir_x(weapon.spd * (1 + random(weapon.spread) * 0.01), attack.htbxDir);
	htbx.move.vsp = lengthdir_y(weapon.spd * (1 + random(weapon.spread) * 0.01), attack.htbxDir);
	htbx.move.fric = weapon.fric;
	
	//Combat stuff
	htbx.atk.dur = weapon.life;
	htbx.atk.maxDur = weapon.life;	
	htbx.atk.dmg = weapon.dmg;
	htbx.atk.knockback = weapon.knockback;
	htbx.atk.hitDelay = weapon.start;
	htbx.atk.hitEnd = weapon.length;
	htbx.atk.piercing = weapon.piercing;
	htbx.atk.destroyOnStop = weapon.destroyOnStop;
	htbx.atk.destroyOnCollision = weapon.destroyOnCollision;
	
	//Determine if this should hit enemies or player
	if (object_index == oPlayer)	{ htbx.atk.target = oEnemyBase; }
	else							{ htbx.atk.target = oPlayer; }
}

function attackLogic(weapon, attack)
{
	if (attack.count < weapon.amount && attack.dur < weapon.dur - weapon.delay)
	{
		if (weapon.aimable) attack.dir = getAttackDir();
		performAttack(weapon, attack);
	} else if (attack.count == weapon.amount && attack.burstCount < weapon.burstAmount)
	{
		//If we have multiple bursts, reset attacks between bursts, increment burst counter and start new burst
		attack.count = 0;
		attack.burstCount++;
		attack.dur = weapon.dur + weapon.burstDelay;
	}
}

function performAttack(weapon, attack) {
	//If delay is 0, it shoots multiple bullets per dur cycle
	//Bullets in burst can have multispread
	if (weapon.delay == 0)
	{
		//Loop through all the bullets in the burst
		repeat (weapon.amount)
		{
			attack.htbxDir = attack.dir;
			
			//If weapon has multispread, do some directional calculation for each projectile based on the multispread variable
			if (weapon.multiSpread > 0)
			{
				attack.htbxDir += (weapon.multiSpread / (weapon.amount - 1) * attack.count) - weapon.multiSpread * .5;
			}
			
			attack.htbxDir += irandom_range(-weapon.spread, weapon.spread);
		
			spawnHitbox(weapon, attack);
			incrementAttack(weapon, attack);
		}
		
		setAttackMovement(weapon.push * weapon.amount, weapon, attack);
	} else
	{ 
		//This is where we go if we only shoot 1 bullet per frame, aka delay > 0
		//Just shoot bullet in the direction, no directional shenanigans
		attack.htbxDir = attack.dir;
		
		if (weapon.multiSpread > 0)
		{
			attack.htbxDir = attack.dir + (weapon.multiSpread / (weapon.amount - 1) * attack.count) - weapon.multiSpread * .5;
		}
		
		attack.htbxDir += irandom_range(-weapon.spread, weapon.spread);
				
		spawnHitbox(weapon, attack);
		incrementAttack(weapon, attack);
		setAttackMovement(weapon.push, weapon, attack);
	}
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
	
			part_particles_create(global.ps, x, bbox_bottom, global.bulletTrail, 1);
		break;
		
		case oEnemyBase:
			//Soon
		break;
	}
	
	move.hsp = lengthdir_x(amount, move.dir);
	move.vsp = lengthdir_y(amount, move.dir);
}

#endregion