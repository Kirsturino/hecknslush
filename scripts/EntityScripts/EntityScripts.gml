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
		if (state == idle) {
			move.aggroTimer = move.aggroTimerMax;
			toChasing();
		}
		
		//Reduce hp
		combat.hp -= other.atk.dmg;
		
		//Inflict knockback
		if (other.move.hsp != 0 || other.move.vsp != 0) { var dir = other.move.dir }
		else											{ var dir = other.image_angle }
		
		move.hsp += lengthdir_x(other.atk.knockback, dir);
		move.vsp += lengthdir_y(other.atk.knockback, dir);
		move.dir = dir;
		
		//Stun enemy if applicable
		if (combat.stunnable && other.visuals.type == weapons.melee) toStunned(other.atk.dmg * 40);
		
		//Visual stuff
		visual.flash = hitFlash;
		image_yscale += other.atk.dmg;
		image_xscale -= other.atk.dmg;
		
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

		//If enemy hp 0, kill 'em
		if (combat.hp <= 0) {
			image_yscale = 4;
			image_xscale = 0.25;
			destroySelf(visual.corpse);
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
	horizontalCollision(mask_index);
	
	move.vsp = approach(move.vsp, 0, move.fric);
	verticalCollision(mask_index);

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