global.upgradePool = ds_list_create();
#macro POOL global.upgradePool

enum upgrades {
	add,
	multiply,
	set
}

function applyUpgrade(weapon, upgrade)
{
	//Weapon and upgrade type need to match
	//If they don't, exit from the script
	if (weapon.type != upgrade.type || weapon.upgradeCount == weapon.maxUpgradeCount) return;
	
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
				
				default:
					show_message("upgrade broke");
				break;
			}
			
			//Finally, set weapon value with calculated value
			variable_struct_set(weapon, upgradeVarName, finalValue);
		}
	}
	
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

ds_list_add(POOL, new anarchy());

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

ds_list_add(POOL, new radialAttack());