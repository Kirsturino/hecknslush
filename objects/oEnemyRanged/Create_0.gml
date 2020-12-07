// Inherit the parent event
event_inherited();

combat = new rangedCombat();
move = new rangedMove();
visuals = new rangedVisuals();

attack = new attackStruct();
weapon = new rangedEnemyWeapon();

currencyArray = initCurrency(combat.currencyAmount);

//Set mask
sprite_index = move.collMask;

//Declare state
state = nothing;
DoLater(1, function(data) {state = idle;},0,true);
drawFunction = nothing;

//States
function idle() {
	staticMovement();

	var los = canSee(oPlayer);
	if ((distance_to_object(oPlayer) <= combat.detectionRadius && los) || move.aggroTimer != 0) toRepositioning();
}

function repositioning() {
	var dist = distance_to_object(oPlayer);
	var los = canSee(oPlayer);
	
	//Get line of sight
	if (los && dist < combat.chaseRadius) {
		move.lastSeen[0] = oPlayer.x;
		move.lastSeen[1] = oPlayer.y;
	}
	
	//Get direction, if player too close, reverse direction
	var dir = point_direction(x, y, move.lastSeen[0], move.lastSeen[1]);
	if (dist < combat.fleeRadius && los) dir += 180;
	
	repositioningMovement(dist, dir);
	move.aggroTimer = approach(move.aggroTimer, 0, 1);
	
	if (dist <= combat.attackRadius && los && attack.cooldown == 0) { toAttacking(); }
	else if ((dist >= combat.chaseRadius || !los) && move.aggroTimer == 0) { toIdle(); }
}

function attacking() {
	//Wait a while before attacking, then initiate attack
	//When attack is over, go back to repositioning
	if (attack.anticipationDur > 0)
	{
		attack.anticipationDur = approach(attack.anticipationDur, 0, 1);
	} else if (attack.dur > 0)
	{
		visuals.curSprite = sEnemyRangedShooting;
		drawFunction = nothing;
		
		attackLogic(weapon, attack);
		attackMovement();
		
		//Count down attack dur
		attack.dur = approach(attack.dur, 0, 1);
		if (attack.dur == 0)
		{			
			attack.cooldown = weapon.cooldown;
			resetAttack(weapon, attack);
			toRepositioning();
		}
	}
}

function stunned() {
	staticMovement();
	
	combat.stunDur = approach(combat.stunDur, 0, 1);
	if (combat.stunDur == 0) toIdle();
}

//State switches
function toIdle() {
	visuals.curSprite = sEnemyRanged;
	state = idle;
	drawFunction = nothing;
}

function toRepositioning() {
	visuals.curSprite = sEnemyRanged;
	state = repositioning;
	drawFunction = nothing;
}

function toAttacking() {
	//Impart attack qualities to current attack
	attack.dur = weapon.dur;
	attack.anticipationDur = weapon.anticipationDur;
	attack.spd = weapon.spd;
	attack.dmg = weapon.dmg;
	
	//Set attack direction
	attack.dir = point_direction(x, y, oPlayer.x, oPlayer.y);

	visuals.curSprite = sEnemyRangedAnticipation;
	state = attacking;
	drawFunction = drawAttackIndicator;
}

function toStunned(duration) {
	attack.cooldown = weapon.cooldown;
	combat.stunDur = duration;
	
	visuals.curSprite = sEnemyRangedStunned;
	state = stunned;
	drawFunction = nothing;
}

//Movement
function repositioningMovement(dist, dir) {
	if (dist < combat.fleeRadius || dist > combat.attackRadius)
	{
		move.hsp = approach(move.hsp, lengthdir_x(move.chaseSpd, dir), move.axl);
		horizontalCollision();
	
		move.vsp = approach(move.vsp, lengthdir_y(move.chaseSpd, dir), move.axl);
		verticalCollision();
	
		x += move.hsp * delta;
		y += move.vsp * delta;
	} else 
	{
		staticMovement();
	}
}

//Other
function incrementCooldowns() {
	attack.cooldown = approach(attack.cooldown, 0, 1);
}