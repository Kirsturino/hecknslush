function piercingHitboxEnemyCollision()
{
	//Hitbox only becomes active when delay is over
	atk.hitDelay = approach(atk.hitDelay, 0, 1);

	if (atk.hitDelay == 0 && atk.dur > atk.maxDur - atk.hitEnd)
	{
		//Populate list of currently colliding enemies
		var enemyList = ds_list_create();
		var enemies = instance_place_list(x, y, atk.target, enemyList, false);
	
		//Go through list of enemies
		var i = 0;
		repeat(enemies)
		{
			//If enemy isn't found in the list, do something and add it to the list of things
			var enemyInList = enemyList[| i];
		
			if (ds_list_find_index(atk.damagedEnemies, enemyInList) == -1) {
				ds_list_add(atk.damagedEnemies, enemyInList);
			
				//Do something with object
				dealDamage(enemyInList);
			}
		
			i++;
		}
	
		//Destroy list from memory, get rekt list
		ds_list_destroy(enemyList);
	}
}

function defaultHitboxEnemyCollision()
{
	//Hitbox only becomes active when delay is over
	atk.hitDelay = approach(atk.hitDelay, 0, 1);

	if (atk.hitDelay == 0 && atk.dur > atk.maxDur - atk.hitEnd)
	{
		var enemy = instance_place(x, y, atk.target);
		if (enemy != noone)
		{
			dealDamage(enemy);
			destroySelf();
		}
	}
}

function destroyOnStop()
{
	if (move.hsp == 0 && move.vsp == 0) destroySelf();
}

function destroyOnCollision()
{
	destroySelf();
}

function defaultHitboxMovement()
{
	//Simple movement
	move.hsp = approach(move.hsp, 0, abs(lengthdir_x(move.fric, move.dir)));
	move.vsp = approach(move.vsp, 0, abs(lengthdir_y(move.fric, move.dir)));
	move.dir = point_direction(0, 0, move.hsp, move.vsp);

	x += move.hsp * delta;
	y += move.vsp * delta;
}