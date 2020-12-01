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
	with (enemy) {
		switch (other.atk.target) {
			case oEnemyBase:
				if (state == idle) {
					move.aggroTimer = move.aggroTimerMax;
				}
		
				//Reduce hp
				combat.hp -= other.atk.dmg;
		
				//Inflict knockback
				if (other.move.hsp != 0 || other.move.vsp != 0) { var dir = other.move.dir; }
				else											{ var dir = other.image_angle; }
		
				move.hsp += lengthdir_x(other.atk.knockback, dir);
				move.vsp += lengthdir_y(other.atk.knockback, dir);
				move.dir = dir;
		
				//visuals stuff
				visuals.flash = max(hitFlash ,hitFlash * other.atk.dmg);
				visuals.yScale += other.atk.dmg;
				visuals.xScale -= other.atk.dmg;
		
				//Hitstop & camera stuff
				if (other.visuals.hitStop) {
					freeze(other.atk.dmg * 40);
					other.visuals.hitStop = false;
				}
		
				shakeCamera(other.atk.dmg * 40, other.atk.dmg * 2, 4);
				pushCamera(other.atk.dmg * 20, dir);
				zoomCamera(1 - other.atk.dmg * 0.03);
		
				//Particles
				part_particles_create(global.ps, x, y, global.hitPart, other.atk.dmg * 10);
		
				part_type_size(global.hitPart2, other.atk.dmg * 3.2, other.atk.dmg * 3.4, -other.atk.dmg * 0.3, 0);
				part_particles_create(global.ps, x, y, global.hitPart2, 1);

				//Stun enemy if applicable
				if (combat.stunnable && other.visuals.type == weapons.melee) toStunned(other.atk.dmg * 40);
		
				//If enemy hp 0, kill 'em
				if (combat.hp <= 0) {
					destroySelf(visuals.corpse);
				}
				
				with (other) {
					if (!atk.piercing) destroySelf();
				}
			break;
		
			case oPlayer:
				if (oPlayer.combat.iframes == 0) {
					takeDamage(other.atk.dmg);
					with (other) destroySelf();
					if (combat.hp <= 0) toDead();
				}
			break;
		}
	}
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

#region ATTACKING

function spawnHitbox(weapon, attack)
{
	switch (weapon.type) {
		case weapons.melee:
		#region
			var spawnX = x + lengthdir_x(weapon.reach, attack.htbxDir);
			var spawnY = y + lengthdir_y(weapon.reach, attack.htbxDir);
	
			//Impart weapon stats to hitbox
			var htbx = instance_create_layer(spawnX, spawnY, "Instances", weapon.htbx);
			htbx.sprite_index = weapon.spr;
			htbx.image_angle = attack.htbxDir;
			if (weapon.mirror) htbx.image_yscale = attack.mirror;
	
			htbx.move.hsp = lengthdir_x(weapon.spd, attack.htbxDir);
			htbx.move.vsp = lengthdir_y(weapon.spd, attack.htbxDir);
			htbx.move.fric = weapon.fric;
	
			htbx.atk.dur = weapon.life;
			htbx.atk.maxDur = weapon.life;	
			htbx.atk.dmg = weapon.dmg;
			htbx.atk.knockback = weapon.knockback;
			htbx.atk.hitDelay = weapon.start;
			htbx.atk.hitEnd = weapon.length;
			
			//Visuals
			htbx.visuals.type = weapons.melee;
			htbx.image_blend = weapon.clr;
		
			//All melee weapons can cleave and persist
			htbx.atk.destroyOnStop = false;
			htbx.atk.piercing = true;
			
			//FX
			if (object_index == oPlayer)
			{
				shakeCamera(weapon.dmg * 20, 2, 4);
				pushCamera(weapon.dmg * 20, attack.htbxDir);
			}
			
			if (weapon.multiSpread == 0) {
				var sprd = 40;
			} else {
				var sprd = weapon.multiSpread * .5;
			}
			
			part_type_direction(global.shootPart, attack.htbxDir - sprd, attack.htbxDir + sprd, 0, 0);
			part_particles_create(global.ps, spawnX, spawnY, global.shootPart, 5);
			#endregion
		break;
		
		case weapons.ranged:	
		#region
			var spawnX = x + lengthdir_x(weapon.reach + sprite_get_width(weapon.spr), attack.htbxDir);
			var spawnY = y + lengthdir_y(weapon.reach + sprite_get_width(weapon.spr), attack.htbxDir);
		
			//Apply random spread
			attack.htbxDir += irandom_range(-weapon.spread, weapon.spread);
	
			//Impart weapon stats to hitbox
			var htbx = instance_create_layer(spawnX, spawnY, "Instances", weapon.htbx);
			htbx.sprite_index = weapon.projSpr;
			htbx.image_angle = attack.htbxDir;
			htbx.visuals.size = weapon.size;
	
			//Movement
			htbx.move.hsp = lengthdir_x(weapon.spd, attack.htbxDir);
			htbx.move.vsp = lengthdir_y(weapon.spd, attack.htbxDir);
			htbx.move.fric = weapon.fric + random(weapon.spread) * 0.001;
	
			//Combat stuff
			htbx.atk.dur = weapon.life;	
			htbx.atk.dmg = weapon.dmg;
			htbx.atk.knockback = weapon.knockback;
			htbx.atk.piercing = weapon.piercing;
			htbx.atk.destroyOnStop = weapon.destroyOnStop;
			htbx.atk.destroyOnCollision = weapon.destroyOnCollision;
			htbx.visuals.type = weapons.ranged;
			htbx.image_blend = weapon.clr;
			
			//FX
			if (object_index == oPlayer) 
			{
				shakeCamera(weapon.dmg * 60, 2, 4);
				pushCamera(weapon.dmg * 50, attack.htbxDir + 180);
				visuals.recoil = weapon.dmg * 20;
			}
			
			part_particles_create(global.ps, spawnX, spawnY, global.muzzleFlashPart, 1);
			part_type_direction(global.shootPart, attack.htbxDir - weapon.spread * 2, attack.htbxDir + weapon.spread * 2, 0, 0);
			part_particles_create(global.ps, spawnX, spawnY, global.shootPart, 10);
			#endregion
		break;
	}
	
	//Determine if this should hit enemies or player
	if (object_index == oPlayer)	{ htbx.atk.target = oEnemyBase; }
	else							{ htbx.atk.target = oPlayer; }
}

function attackLogic(weapon, attack)
{
	if (attack.count < weapon.amount && attack.dur < weapon.dur - weapon.delay)
	{
		performAttack(weapon, attack);
	} else if (attack.count == weapon.amount && attack.burstCount < weapon.burstAmount)
	{
		//If we have multiple bursts, reset attacks between bursts, increment burst counter and start new burst
		attack.count = 0;
		attack.dir = getAttackDir();
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
		
			spawnHitbox(weapon, attack);
			incrementAttack(weapon, attack);
		}
		
		setAttackMovement(weapon.push * weapon.amount);
	} else
	{ 
		//This is where we go if we only shoot 1 bullet per frame, aka delay > 0
		//Just shoot bullet in the direction, no directional shenanigans
		attack.htbxDir = attack.dir;
		
		if (weapon.multiSpread > 0)
		{
			attack.htbxDir = attack.dir + (weapon.multiSpread / (weapon.amount - 1) * attack.count) - weapon.multiSpread * .5;
		}
				
		spawnHitbox(weapon, attack);
		incrementAttack(weapon, attack);
		setAttackMovement(weapon.push);
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
	
function setAttackMovement(amount) {
	switch (object_index)
	{
		case oPlayer:
			if (input_player_source_get(0) == INPUT_SOURCE.KEYBOARD_AND_MOUSE)	{ move.dir = point_direction(x, y, mouse_x, mouse_y); }
			else if (!isHoldingDirection())										{ move.dir = move.lastDir; }
			else																{ move.dir = getMovementInputDirection(); }
	
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