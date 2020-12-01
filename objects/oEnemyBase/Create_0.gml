combat = {
	hp : 3,
}

//Create and store currency that enemy will drop
currency = 10;
currencyArray = array_create(currency, 0);

for (var i = 0; i < currency; ++i) {
    currencyArray[i] = instance_create_layer(x, y, "Instances", oCurrency);
	instance_deactivate_object(currencyArray[i]);
}

move = {
	hsp : 0,
	vsp : 0,
	fric : 0.05,
	dir : 0
}

visuals = {
	flash : 0,
	curSprite : sEnemy,
	corpse: sEnemyMeleeCorpse,
	frm : 0,
	spd : 1,
	xScale : 1,
	yScale : 1,
	rot : 0
}

state = 0;
drawFunction = nothing;

function destroySelf(corpseSprite)
{
	var corpse = instance_create_layer(x, y, "Instances", oCorpse);
	corpse.sprite_index = corpseSprite;
	corpse.move.hsp = move.hsp;
	corpse.move.vsp = move.vsp;
	corpse.move.dir = point_direction(0, 0, move.hsp, move.vsp);
	
	for (var i = 0; i < currency; ++i)
	{
		instance_activate_object(currencyArray[i]);
		currencyArray[i].x = x;
		currencyArray[i].y = y;
		
		currencyArray[i].move.hsp = irandom_range(-3, 3);
		currencyArray[i].move.vsp = irandom_range(-3, 3);
	}
	
	instance_destroy();
}

function incrementAnimationFrame()
{
	visuals.frm += visuals.spd * delta;
	
	if (visuals.frm > image_number) {
		visuals.frm = frac(visuals.frm);
	}
	
	//Reset squash
	visuals.xScale = lerp(visuals.xScale, 1, 0.1 * delta);
	visuals.yScale = lerp(visuals.yScale, 1, 0.1 * delta);
}