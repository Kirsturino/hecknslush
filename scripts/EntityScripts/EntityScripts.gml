//Collection of functions most entities/actors ingame will most likely want to call at some point

function depthSorting() {
	depth = -bbox_bottom;
}

function getTouchingObjects(list, object, func) {
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

function dealDamage(enemy) {
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
				horizontalCollision();
				move.vsp += lengthdir_y(other.atk.knockback, dir);
				verticalCollision();
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

function negateMomentum() {
	move.hsp = 0;
	move.vsp = 0;
}

function staticMovement() {
	//Simple movement
	move.hsp = approach(move.hsp, 0, move.fric);
	horizontalCollision();
	
	move.vsp = approach(move.vsp, 0, move.fric);
	verticalCollision();

	x += move.hsp * delta;
	y += move.vsp * delta;
}

function avoidOverlap() {
	var phys = instance_place(x, y, parPhysical);
	
	if (phys != noone) {
		var dir = point_direction(phys.x, phys.y, x, y);

		move.hsp += lengthdir_x(0.05, dir) * delta;
		move.vsp += lengthdir_y(0.05, dir) * delta;
	}
}

function moveInDirection(amount, direction) {
	x += lengthdir_x(amount * delta, direction);
	y += lengthdir_y(amount * delta, direction);
}

function canSee(instance) {
	var los = collision_line(x, y, instance.x, instance.y, parCollision, false, false);
	
	if (los == noone) return true;
	
	return false;
}

function spawnHitbox(struct, dir, applyScreenFX, target) {
switch (struct.type) {
		case weapons.melee:
			var spawnX = x + lengthdir_x(struct.reach[melee.combo - 1], dir);
			var spawnY = y + lengthdir_y(struct.reach[melee.combo - 1], dir);
	
			//Impart weapon stats to hitbox
			var htbx = instance_create_layer(spawnX, spawnY, "Instances", struct.htbx);
			htbx.sprite_index = struct.spr[melee.combo - 1];
			htbx.image_angle = dir;
	
			htbx.move.hsp = lengthdir_x(struct.htbxSlide[melee.combo - 1], dir);
			htbx.move.vsp = lengthdir_y(struct.htbxSlide[melee.combo - 1], dir);
			htbx.move.fric = struct.htbxFric[melee.combo - 1];
	
			htbx.atk.dur = struct.htbxLength[melee.combo - 1];	
			htbx.atk.dmg = struct.baseDmg * struct.dmgMultiplier[melee.combo - 1];
			htbx.atk.knockback = struct.knockback[melee.combo - 1];
			htbx.atk.delay = struct.htbxStart[melee.combo - 1];
			htbx.visuals.type = weapons.melee;
			htbx.image_blend = struct.clr;
		
			//All melee weapons can cleave and persist
			htbx.atk.destroyOnStop = false;
			htbx.atk.piercing = true;
			
			if (applyScreenFX) {
				//FX
				shakeCamera(curRangedWeapon.dmg * 20, 2, 4);
				pushCamera(curRangedWeapon.dmg * 100, dir);
			}
			
			if (struct.multiSpread[melee.combo - 1] == 0) {
				var sprd = 40;
			} else {
				var sprd = struct.multiSpread[melee.combo - 1] * .5;
			}
			
			part_type_direction(global.shootPart, dir - sprd, dir + sprd, 0, 0);
			part_particles_create(global.ps, spawnX, spawnY, global.shootPart, 5);
		break;
		
		case weapons.ranged:	
			var spawnX = x + lengthdir_x(struct.reach + sprite_get_width(struct.spr), dir);
			var spawnY = y + lengthdir_y(struct.reach + sprite_get_width(struct.spr), dir);
		
			//Apply random spread
			dir += irandom_range(-struct.spread, struct.spread);
	
			//Impart weapon stats to hitbox
			var htbx = instance_create_layer(spawnX, spawnY, "Instances", struct.htbx);
			htbx.sprite_index = struct.projSpr;
			htbx.image_angle = dir;
			htbx.visuals.size = struct.size;
	
			htbx.move.hsp = lengthdir_x(struct.spd, dir);
			htbx.move.vsp = lengthdir_y(struct.spd, dir);
			htbx.move.fric = struct.fric;
	
			htbx.atk.dur = struct.life;	
			htbx.atk.dmg = struct.dmg;
			htbx.atk.knockback = struct.knockback;
			htbx.atk.piercing = struct.piercing;
			htbx.atk.destroyOnStop = struct.destroyOnStop;
			htbx.atk.destroyOnCollision = struct.destroyOnCollision;
			htbx.visuals.type = weapons.ranged;
			htbx.image_blend = struct.clr;
			
			if (applyScreenFX) {
				//FX
				shakeCamera(curRangedWeapon.dmg * 60, 2, 4);
				pushCamera(curRangedWeapon.dmg * 50, dir + 180);
				ranged.recoil = curRangedWeapon.dmg * 10;
			}
			
			part_particles_create(global.ps, spawnX, spawnY, global.muzzleFlashPart, 1);
			part_type_direction(global.shootPart, dir - struct.spread * 2, dir + struct.spread * 2, 0, 0);
			part_particles_create(global.ps, spawnX, spawnY, global.shootPart, 10);
		break;
	}
	
	htbx.atk.target = target;
}