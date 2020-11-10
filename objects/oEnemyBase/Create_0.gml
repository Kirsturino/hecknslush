combat = {
	hp : 3,
}

move = {
	hsp : 0,
	vsp : 0,
	fric : 0.05,
	dir : 0
}

visual = {
	flash : 0,
	corpse: sEnemyCorpse
}

function destroySelf(corpseSprite) {
	var corpse = instance_create_layer(x, y, "Instances", oCorpse);
	corpse.sprite_index = corpseSprite;
	corpse.move.hsp = move.hsp;
	corpse.move.vsp = move.vsp;
	corpse.move.dir = point_direction(0, 0, move.hsp, move.vsp);
	
	instance_destroy();
}