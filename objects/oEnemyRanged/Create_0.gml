// Inherit the parent event
event_inherited();

combat = {
	hp : 3,
	detectionRadius : 280,
	attackRadius : 220,
	chaseRadius : 320,
	fleeRadius : 160,
	stunDur : 0,
	stunnable : true,
	weight : 1
}

rangedAttack = {
	name :					"Burst Blaster",
	type :					weapons.ranged,
	clr :					c_red,
	htbx :					oHitbox,
	spr :					sGun,
	projSpr :				sProjectile,
	amount :				10,
	delay :					5,
	burstAmount :			0,
	burstDelay :			20,
	spread :				20,
	multiSpread :			40,
	reach :					4,
	spd :					1.5,
	life :					180,
	destroyOnStop :			true,
	destroyOnCollision :	true,
	fric :					0,
	knockback :				0.2,
	piercing :				false,
	dmg:					1,
	dur :					32,
	anticipationDur :		128,
	size :					1,
	zoom :					0.4,
	aimSpeedModifier :		0.5,	
	cooldown :				128
}

attack = {
	dur : 0,
	anticipationDur : 64,
	spd : 0,
	dir : 0,
	cooldown : 0,
	dmg : 0,
	shot : 0,
	burst : 0
}

move = {
	hsp : 0,
	vsp : 0,
	chaseSpd: 0.6,
	idleSpd: 1,
	lastSeen : [0, 0],
	aggroTimerMax : 180,
	aggroTimer : 0,
	axl : 0.02,
	fric : 0.05,
	collMask : sEnemyRangedWallCollisionMask,
	dir : 0
}

visuals = {
	flash : 0,
	corpse: sEnemyCorpse,
	frm : 0,
	spd : 0.01
}

//Declare state
state = 0;
DoLater(1,
            function(data)
            {
                state = idle;
            },
            0,
            true);


//States
function idle() {
	staticMovement(move.collMask);

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
	if (attack.anticipationDur > 0) {
		attack.anticipationDur = approach(attack.anticipationDur, 0, 1);
		if (attack.anticipationDur == 0) attack.dir = point_direction(x, y, oPlayer.x, oPlayer.y);
	} else if (attack.dur > 0) {
		sprite_index = sEnemyRangedShooting;

		if (attack.shot < rangedAttack.amount && attack.dur < rangedAttack.dur - rangedAttack.delay) {
			performShot(rangedAttack, attack);
		} else if (attack.shot == rangedAttack.amount && attack.burst < rangedAttack.burstAmount) {
			//If we have multiple bursts, reset shots between bursts, increment burst counter
			attack.shot = 0;
			attack.burst++;
			attack.dur = rangedAttack.dur + rangedAttack.burstDelay;
		}
		
		attack.dur = approach(attack.dur, 0, 1);
		
		if (attack.dur == 0) {			
			attack.cooldown = rangedAttack.cooldown;
			attack.damaged = false;
			resetShots(attack);
			
			toRepositioning();
		}
	}
}

function stunned() {
	staticMovement(move.collMask);
	
	combat.stunDur = approach(combat.stunDur, 0, 1);
	if (combat.stunDur == 0) toIdle();
}

//State switches
function toIdle() {
	sprite_index = sEnemyRanged;
	state = idle;
}

function toRepositioning() {
	sprite_index = sEnemyRanged;
	state = repositioning;
}

function toAttacking() {
	//Impart dash attack qualities to current attack
	attack.dur = rangedAttack.dur;
	attack.anticipationDur = rangedAttack.anticipationDur;
	attack.spd = rangedAttack.spd;
	attack.dmg = rangedAttack.dmg;

	sprite_index = sEnemyRangedAnticipation;
	state = attacking;
}

function toStunned(duration) {
	attack.cooldown = rangedAttack.cooldown;
	combat.stunDur = duration;
	
	sprite_index = sEnemyRangedStunned;
	state = stunned;
}

//Movement
function repositioningMovement(dist, dir) {
	if (dist < combat.fleeRadius || dist > combat.attackRadius) {
	move.hsp = approach(move.hsp, lengthdir_x(move.chaseSpd, dir), move.axl);
	horizontalCollision(move.collMask);
	
	move.vsp = approach(move.vsp, lengthdir_y(move.chaseSpd, dir), move.axl);
	verticalCollision(move.collMask);
	
	x += move.hsp * delta;
	y += move.vsp * delta;
	} else {
		staticMovement(move.collMask);
	}
}

//Other
function incrementCooldowns() {
	attack.cooldown = approach(attack.cooldown, 0, 1);
}

function performShot(weaponStruct, attackStruct) {
	//If delay is 0, it shoots multiple bullets per dur cycle
	//Bullets in burst can have multispread
	if (weaponStruct.delay == 0) {
		//Loop through all the bullets in the burst
		repeat (weaponStruct.amount) {
			var dir = point_direction(x, y, oPlayer.x, oPlayer.y);
			
			//If weapon has multispread, do some directional calculation for each projectile based on the multispread variable
			if (weaponStruct.multiSpread > 0) {
				dir += (weaponStruct.multiSpread / (weaponStruct.amount - 1) * attackStruct.shot) - weaponStruct.multiSpread * .5;
			}
		
			spawnHitbox(weaponStruct, dir, false, oPlayer);
			incrementShot(weaponStruct, attackStruct);
		}
		
	} else { 
		//This is where we go if we only shoot 1 bullet per frame, aka delay > 0
		//Just shoot bullet in the direction, no directional shenanigans
		var dir = point_direction(x, y, oPlayer.x, oPlayer.y);
		spawnHitbox(weaponStruct, dir, false, oPlayer);
		incrementShot(weaponStruct, attackStruct);
	}
}

function incrementShot(rangedStruct, attackStruct) {
	//Increment shot count for burst weapons
	attackStruct.shot++;
		
	//Set time before player is able to move again
	attackStruct.dur = rangedStruct.dur;
}

function resetShots(attackStruct) {
	attackStruct.shot = 0;
	attackStruct.burst = 0;
}