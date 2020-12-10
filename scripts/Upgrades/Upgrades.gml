global.upgradePool = ds_list_create();
#macro POOL global.upgradePool

enum upgrades {
	add,
	multiply,
	set,
	behaviour
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
		
		destroyUpgrade(weapon, upgrade);
		return;
	}
	
	//Get struct variables
	var upg = variable_struct_get_names(upgrade);
	
	//See if we have matching variables
	//Loop through the upgrade variables
	var length = array_length(upg);
	for (var i = 0; i < length; ++i)
	{
		var upgradeVarName = upg[i];
		//Check for matching variable names
		var notDescriptive = (upgradeVarName != "type" && upgradeVarName != "name" && upgradeVarName != "desc");
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
				
				case upgrades.behaviour:
					var finalValue = array_create(0);
					pushArrayToArray(weaponValue, finalValue);
					array_push(finalValue, upgradeValueArray[0]);
				break;
				
				default:
					show_message("upgrade broke");
				break;
			}
			
			//Finally, set weapon value with calculated value
			variable_struct_set(weapon, upgradeVarName, finalValue);
		}
	}
	
	destroyUpgrade(weapon, upgrade);
}

function destroyUpgrade(weapon, upgrade)
{
	//Clear upgrade from upgrade pool
	var toDelete = ds_list_find_index(POOL, upgrade);
	ds_list_delete(POOL, toDelete);
	
	//Increment upgrade counter
	var count = variable_struct_get(weapon, "upgradeCount") + 1;
	variable_struct_set(weapon, "upgradeCount", count);
	
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
	amount =		[10, upgrades.add];
	delay =			[10, upgrades.add];
	cooldown =		[1.2, upgrades.multiply];
	dmg =			[0.6, upgrades.multiply];
}

function megaBurstifier() constructor
{
	type =			weapons.ranged;
	name =			"MEGAburstifier";
	desc =			"Turns your gun into a bullet hose. A long bullet hose";
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
	hitFunctions =	[debug, upgrades.behaviour];
}

function multiTest() constructor
{
	type =			weapons.multi;
	name =			"Multi Debugger";
	desc =			"This can be applied to any ability and only changes the color of the ability";
	clr =			[c_lime, upgrades.set];
}

//ds_list_add(POOL, new anarchy());
//ds_list_add(POOL, new radialAttack());
//ds_list_add(POOL, new burstifier());
//ds_list_add(POOL, new megaBurstifier());
//ds_list_add(POOL, new behaviourTest());
ds_list_add(POOL, new multiTest());