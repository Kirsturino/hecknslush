global.upgradePool = ds_list_create();
#macro POOL_UPGRADE global.upgradePool

enum upgrades
{
	add,
	multiply,
	set,
	addBehaviour,
	removeBehaviour,
	execute
}

function applyUpgrade(weapon, upgrade)
{
	//Weapon and upgrade type need to match
	//If they don't, exit from the script
	if (weapon.type != upgrade.type && upgrade.type != weapons.multi) { return; }
	else if (weapon.upgradeCount == weapon.maxUpgradeCount)
	{
		//If weapon has max amount of upgrades, destroy upgrade and add 1 to max amount of upgrades
		var maxUpg = variable_struct_get(weapon, "maxUpgradeCount") + 1;
		variable_struct_set(weapon, "maxUpgradeCount", maxUpg);
		
		destroyUpgrade(upgrade);
		return;
	}
	
	//Get weapon variables
	var upg = variable_struct_get_names(upgrade);
	
	//See if we have matching variables
	//Loop through the upgrade variables
	var length = array_length(upg);
	for (var i = 0; i < length; ++i)
	{
		var upgradeVarName = upg[i];
		//Check for matching variable names
		var notDescriptive = (upgradeVarName != "type" && upgradeVarName != "name" && upgradeVarName != "desc" && upgradeVarName != "pool");
	    if (notDescriptive && variable_struct_exists(weapon, upgradeVarName))
		{
			//Fetch variable values from weapon and upgrade
			var weaponValue = variable_struct_get(weapon, upgradeVarName);
			var upgradeValueArray = variable_struct_get(upgrade, upgradeVarName);
			
			//Depending on upgrade type, add or multiply the weapon value with uprade value
			switch (upgradeValueArray[1])
			{
				case upgrades.add:
					var finalValue = weaponValue + upgradeValueArray[0];
				break;
				
				case upgrades.multiply:
					var finalValue = weaponValue * upgradeValueArray[0];
				break;
				
				case upgrades.set:
					var finalValue = upgradeValueArray[0];
				break;
				
				case upgrades.addBehaviour:
					var finalValue = array_create(0);
					pushArrayToArray(weaponValue, finalValue);
					array_push(finalValue, upgradeValueArray[0]);
				break;
				
				case upgrades.removeBehaviour:
					var finalValue = array_create(0);
					var length = array_length(weaponValue);
					for (var ii = 0; ii < length; ++ii) //This is essentially pushArrayToArray, but we exclude one variable when copying it over
					{
						if (weaponValue[ii] != upgradeValueArray[0])
							array_push(finalValue, weaponValue[ii]);
					}
				break;
				
				case upgrades.execute:
					upgradeValueArray[0]();
				break;
				
				default:
					show_message("upgrade broke");
				break;
			}
			
			//Finally, set weapon value with calculated value
			if (upgradeValueArray[1] != upgrades.execute) variable_struct_set(weapon, upgradeVarName, finalValue);
		}
	}
	
	//Increment upgrade counter
	var count = variable_struct_get(weapon, "upgradeCount") + 1;
	variable_struct_set(weapon, "upgradeCount", count);
	
	destroyUpgrade(upgrade);
}

function destroyUpgrade(upgrade)
{
	//Clear upgrade from upgrade pool
	var pool = upgrade.pool;
	var toDelete = ds_list_find_index(pool, upgrade);
	ds_list_delete(pool, toDelete);
	
	//Change player back to controllable
	playerToGrounded();
	
	//Destroy upgrade
	//change da world, my final message, goodbye
	instance_destroy();
}

function anarchy() constructor
{
	type =		weapons.ranged;
	name =		"Anarchy";
	desc =		"Double damage, increased spread and cooldown"
	pool =		POOL_UPGRADE;
	
	clr =		[c_purple, upgrades.set];
	spread =	[20, upgrades.add];
	dmg =		[2, upgrades.multiply];
	cooldown =	[1.5, upgrades.multiply];
}

function radialAttack() constructor
{
	type =			weapons.melee;
	name =			"Radial Strike";
	desc =			"Additional attacks around you, lower damage";
	pool =			POOL_UPGRADE;
	
	multiSpread =	[270, upgrades.set];
	amount =		[2, upgrades.add];
	dur =			[1.2, upgrades.multiply];
	dmg =			[0.5, upgrades.multiply];
	push =			[0.5, upgrades.multiply];
}

function burstifier() constructor
{
	type =			weapons.ranged;
	name =			"Burstifier";
	desc =			"Add extra shots to weapon";
	pool =			POOL_UPGRADE;
	
	amount =		[10, upgrades.add];
	delay =			[10, upgrades.add];
	cooldown =		[1.2, upgrades.multiply];
	dmg =			[0.6, upgrades.multiply];
}

function megaBurstifier() constructor
{
	type =			weapons.ranged;
	name =			"Megaurstifier";
	desc =			"Turns your gun into a bullet hose. A long bullet hose";
	pool =			POOL_UPGRADE;
	
	amount =		[50, upgrades.add];
	delay =			[5, upgrades.set];
	cooldown =		[2, upgrades.multiply];
	dmg =			[0.5, upgrades.multiply];
}

function behaviourTest() constructor
{
	type =			weapons.melee;
	name =			"Hit Debugger";
	desc =			"Prints debug messages when hitting enemies";
	pool =			POOL_UPGRADE;
	
	hitFunctions =	[debug, upgrades.addBehaviour];
}

function multiTest() constructor
{
	type =			weapons.multi;
	name =			"Multi Debugger";
	desc =			"This can be applied to any ability and only changes the color of the ability for debugging purposes";
	pool =			POOL_UPGRADE;
	clr =			[c_lime, upgrades.set];
}

function explodingBullets() constructor
{
	type =			weapons.ranged;
	name =			"Exploding Bullets";
	desc =			"Halved damage. Bullets create explosions that damage and push nearby enemies";
	pool =			POOL_UPGRADE;
	
	dmg =			[0.5, upgrades.multiply];
	knockback =		[1.5, upgrades.multiply];
	
	destroyFunctions = [function explosion()
	{
		var htbx = other.id;
		var enemyList = ds_list_create();
		//Maybe change radius to be dynamic at some point???
		var radius = 64;
		
		collision_circle_list(htbx.x, htbx.y, radius, parEnemy, false, false, enemyList, false);
		var size = ds_list_size(enemyList);
		
		//Cycle through all the enemies hit by explosion
		for (var i = 0; i < size; ++i)
		{
		    with (enemyList[| i])
			{
				//Reduce hp
				takeDamage(htbx.atk.dmg);
		
				//Inflict knockback
				var dist = distance_to_point(htbx.x, htbx.y);
				var dir = point_direction(htbx.x, htbx.y, x, y);
				var force = htbx.atk.knockback * 4 - dist * 0.02 * combat.weight;
			
				move.hsp = lengthdir_x(force, dir);
				move.vsp = lengthdir_y(force, dir);
				move.dir = dir;
			}
		}
		
		ds_list_destroy(enemyList);
		
		//Explosion particle
		vectorShapeCall(htbx.x, htbx.y, shapes.circle, radius, -1, 4, 0, 12, col.white, false);
		
		//Make those explosions feel meaty
		freeze(htbx.atk.dmg * 10);
		shakeCamera(htbx.atk.dmg * 200, 2, 200);
	}
	, upgrades.addBehaviour];
	
	aliveFunctions = [piercingHitboxEnemyCollision, upgrades.removeBehaviour];
	aliveFunctions = [defaultHitboxEnemyCollision, upgrades.addBehaviour];

}

function implodingBullets() constructor
{
	type =			weapons.ranged;
	name =			"Imploding Bullets";
	desc =			"Halved damage. Bullets create explosions that damage and pull nearby enemies";
	pool =			POOL_UPGRADE;
	
	dmg =			[0.5, upgrades.multiply];
	knockback =		[1.5, upgrades.multiply];
	
	destroyFunctions = [function implosion()
	{
		var htbx = other.id;
		var enemyList = ds_list_create();
		//Maybe change radius to be dynamic at some point???
		var radius = 64;
		
		collision_circle_list(htbx.x, htbx.y, radius, parEnemy, false, false, enemyList, false);
		var size = ds_list_size(enemyList);
		
		//Cycle through all the enemies hit by explosion
		for (var i = 0; i < size; ++i)
		{
		    with (enemyList[| i])
			{
				//Reduce hp
				takeDamage(htbx.atk.dmg);
		
				//Inflict knockback
				var dist = distance_to_point(htbx.x, htbx.y);
		
				var dir = point_direction(x, y, htbx.x, htbx.y);
				var force = htbx.atk.knockback * 4 - dist * 0.02 * combat.weight;
			
				move.hsp = lengthdir_x(force, dir);
				move.vsp = lengthdir_y(force, dir);
				move.dir = dir;
			}
		}
		
		ds_list_destroy(enemyList);
		
		//Explosion particle
		vectorShapeCall(htbx.x, htbx.y, shapes.circle, radius, -1, 4, 0, 12, col.white, false);
		
		//Make those explosions feel meaty
		freeze(htbx.atk.dmg);
		shakeCamera(htbx.atk.dmg * 200, 2, 200);
	}
	, upgrades.addBehaviour];
	aliveFunctions = [piercingHitboxEnemyCollision, upgrades.removeBehaviour];
	aliveFunctions = [defaultHitboxEnemyCollision, upgrades.addBehaviour];

}

function fracturedBlade() constructor
{
	type =			weapons.melee;
	name =			"Fractured Blade";
	desc =			"Increased damage, but attacks vanish when hitting walls";
	pool =			POOL_UPGRADE;
	
	dmg =			[20, upgrades.add];
	collisionFunctions = [destroyOnCollision, upgrades.addBehaviour];
}

function upgradedDamage() constructor
{
	type =			weapons.multi;
	name =			"Upgraded Damage";
	desc =			"Damage increases with each upgrade this ability has";
	pool =			POOL_UPGRADE;
	
	function moreDamagePerUpgrade()
	{
		atk.dmg *= (1 + misc.from.upgradeCount/10);
	}
	
	spawnFunctions = [moreDamagePerUpgrade, upgrades.addBehaviour];
	
}

function bouncyBullets() constructor
{
	type =			weapons.ranged;
	name =			"Bouncy Bullets";
	desc =			"Projectiles bounce when hitting a wall";
	pool =			POOL_UPGRADE;
	
	dur =			[1.5, upgrades.multiply];
	
	collisionFunctions = [destroyOnCollision, upgrades.removeBehaviour];
	collisionFunctions = [function bouncy()
	{
		
		var left = collision_point(other.bbox_left, other.y, parCollision, false, false);
		var right = collision_point(other.bbox_right, other.y, parCollision, false, false);
		var up = collision_point(other.x, other.bbox_top, parCollision, false, false);
		var down = collision_point(other.x, other.bbox_bottom, parCollision, false, false);
		
		if (left != noone || right != noone)
		{ other.move.hsp *= -1; }
		
		if (up != noone || down != noone)
		{ other.move.vsp *= -1; }
		
	}, upgrades.addBehaviour];
}

ds_list_add(POOL_UPGRADE,	
							//new anarchy(),
							//new radialAttack(),
							//new burstifier(),
							//new megaBurstifier(),
							//new behaviourTest(),
							//new multiTest(),
							//new explodingBullets(),
							//new implodingBullets(),
							//new fracturedBlade(),
							//new upgradedDamage(),
							new bouncyBullets()
							);

//-------------------------------------------------------------------------------------------

global.buffPool = ds_list_create();
#macro POOL_BUFF global.buffPool

function applyBuff(buff)
{
	buff.buffFunction();
	
	//Pop up ui informing player that they picked up a buff
	var txt = "[fntUpgradeTitle]" + buff.name + "\n\n[fntScribble]" + buff.desc;
	startNotification(txt);
	
	destroyUpgrade(buff);
}

function rally() constructor
{
	name =			"Rally";
	desc =			"Regain HP by damaging enemies after getting hit";
	pool =			POOL_BUFF;
	
	
	function buffFunction()
	{
		//Add rally variables to player
		oPlayer.extra.structs.rallyStruct = {
			healTime : 0,
			healTimeMax : 200,
			healMax : 0,
			healMultiplier : 0.1,
		}
		
		//Create heal function for weapons
		function rallyHeal()
		{
			if (oPlayer.extra.structs.rallyStruct.healTime > 0)
			{
				oPlayer.combat.hp = min(oPlayer.extra.structs.rallyStruct.healMax, oPlayer.combat.hp + ceil(atk.dmg * oPlayer.extra.structs.rallyStruct.healMultiplier));
			}
		}
		
		//Add heal function to all weapon onhit arrays
		var length = array_length(oPlayer.attackSlots);
		for (var i = 0; i < length; ++i)
			{ array_push(oPlayer.attackSlots[i].hitFunctions, rallyHeal); }
		
		//Extra functions to make rally effect work
		//These get pushed to player arrays that contain extra functions gained from buffs
		function rallyLogic()
			{ extra.structs.rallyStruct.healTime = approach(extra.structs.rallyStruct.healTime, 0, 1); }
		array_push(oPlayer.extra.step, rallyLogic);
	
		function resetRallyTimer()
		{
			extra.structs.rallyStruct.healTime = extra.structs.rallyStruct.healTimeMax;
			extra.structs.rallyStruct.healMax = combat.hp;
		}
		array_push(oPlayer.extra.onDamageTaken, resetRallyTimer);
		
		//Set UI hp bar movement to match with rally mechanic
		oUI.hpBar.delayMax = oPlayer.extra.structs.rallyStruct.healTimeMax;
	}
}

function longHands() constructor
{
	name =			"LONG LONG MAAAAAAN";
	desc =			"Increases reach of all abilities";
	pool =			POOL_BUFF;
	
	function buffFunction() 
	{
		//Increase reach of all abilities
		var length = array_length(oPlayer.attackSlots);
		for (var i = 0; i < length; ++i)
			{ oPlayer.attackSlots[i].reach *= 2; }
	}
}

ds_list_add(POOL_BUFF,	new rally(),
						new longHands());