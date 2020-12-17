// Inherit the parent event
event_inherited();

combat = new rangedCombat();
move = new rangedMove();
visuals = new rangedVisuals();

weapon = new rangedEnemyWeapon();
attack = setAttackStruct(weapon);

currencyArray = initCurrency(combat.currencyAmount);

initEnemy();

//CUSTOM STATES

states.chasing = function enemyChasing() {
	var dir = point_direction(x, y, move.lastSeen[0], move.lastSeen[1]);
	var dist = distance_to_object(oPlayer);
	var los = canSee(oPlayer);
	
	//Get line of sight
	if (los && dist < combat.chaseRadius)
	{
		move.lastSeen[0] = oPlayer.x;
		move.lastSeen[1] = oPlayer.y;
	}
	
	//Get direction, if player too close, reverse direction
	if (dist < combat.fleeRadius && los) dir += 180;
	
	chaseMovement(dist, dir);
	move.aggroTimer = approach(move.aggroTimer, 0, 1);
	
	if (dist < combat.attackRadius && los && attack.cooldown == 0) { toAttacking(); }
	else if ((dist > combat.chaseRadius || !los) && move.aggroTimer == 0) { toIdle(); }
}