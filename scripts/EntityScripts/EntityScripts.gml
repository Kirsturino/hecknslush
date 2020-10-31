#macro hitFlash 3

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
		//If enemy isn't found in the list, deal damage and add it to the list of damaged enemies
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
		//Reduce hp
		combat.hp -= other.atk.dmg;
		
		//Inflict knockback
		if (other.move.hsp != 0 || other.move.vsp != 0) {var dir = other.move.dir}
		else											{var dir = other.image_angle}
		
		move.hsp += lengthdir_x(other.atk.knockback, dir);
		move.vsp += lengthdir_y(other.atk.knockback, dir);
		move.dir = dir;
		
		//Visual stuff
		visual.flash = hitFlash;
		
		//Hitstop
		freeze(other.atk.dmg * 50);
		
		//Particles
		part_particles_create(global.ps, x, y, global.hitPart, other.atk.dmg * 10);

		//If enemy hp 0, kill 'em
		if (combat.hp <= 0) destroySelf();
	}
}

function negateMomentum() {
	move.hsp = 0;
	move.vsp = 0;
}