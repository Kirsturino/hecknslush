//Create and store currency that enemy will drop
state = nothing;
drawFunction = nothing;

function destroySelf()
{
	var corpse = instance_create_layer(x, y, "Instances", oCorpse);
	corpse.sprite_index = visuals.corpse;
	corpse.move.hsp = move.hsp;
	corpse.move.vsp = move.vsp;
	corpse.move.dir = point_direction(0, 0, move.hsp, move.vsp);
	
	spawnCurrency(currencyArray);
	
	instance_destroy();
}

function takeDamage(amount) {
	combat.hp = max(0, combat.hp - amount);
	combat.iframes = combat.iframesMax;
		
	if (combat.hp <= 0) destroySelf();
		
	if (state == idle) { move.aggroTimer = move.aggroTimerMax; }
}

function initCurrency(amount)
{
	var currencyArray = array_create(amount, 0);

	for (var i = 0; i < amount; ++i) {
	    currencyArray[i] = instance_create_layer(x, y, "Instances", oCurrency);
		instance_deactivate_object(currencyArray[i]);
	}
	
	return currencyArray;
}

function spawnCurrency(currencyArray)
{
	var length = array_length(currencyArray);
	for (var i = 0; i < length; ++i)
	{
		instance_activate_object(currencyArray[i]);
		currencyArray[i].x = x;
		currencyArray[i].y = y;
		
		currencyArray[i].move.hsp = irandom_range(-3, 3);
		currencyArray[i].move.vsp = irandom_range(-3, 3);
	}
}