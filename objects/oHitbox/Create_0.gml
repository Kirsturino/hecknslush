//Probably will need to get passed damage and stuff from player weapon
//Then needs to disappear after a set amount of time

atk = {
	dur : 0,
	dmg : 0,
	knockback : 0,
	piercing : true,
	damagedEnemies : ds_list_create(),
	destroyOnStop : false,
	delay : 0
}

//Movement variables
move = {
	hsp : 0,
	vsp : 0,
	dir : 0,
	fric : 0.05
}

visuals = {
	animSpd : 0.5,
	frm : 0,
	size : 1
}

image_xscale = visuals.size;
image_yscale = visuals.size;


function destroySelf() {
	ds_list_destroy(atk.damagedEnemies);
	instance_destroy();
}