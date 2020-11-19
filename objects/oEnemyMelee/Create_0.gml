// Inherit the parent event
event_inherited();

combat = {
	hp : 5,
	detectionRadius : 200,
	attackRadius : 124,
	chaseRadius : 240,
	stunDur : 0,
	stunnable : true,
	weight : 1
}

dashAttack = {
	dur : 32,
	anticipationDur : 64,
	spd : 2.5,
	cooldown : 128,
	dmg : 1
}

attack = {
	dur : 0,
	anticipationDur : 64,
	spd : 0,
	dir : 0,
	cooldown : 0,
	dmg : 0,
	damaged : false
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
	collMask : sEnemyMeleeWallCollisionMask,
	dir : 0
}

visuals = {
	flash : 0,
	corpse: sEnemyMeleeCorpse,
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
	if ((distance_to_object(oPlayer) <= combat.detectionRadius && los) || move.aggroTimer != 0) toChasing();
}

function chasing() {
	var dist = distance_to_object(oPlayer);
	var lastSeenDist = distance_to_point(move.lastSeen[0], move.lastSeen[1]);
	var los = canSee(oPlayer);
	
	chaseMovement(oPlayer.x, oPlayer.y, los, dist);
	move.aggroTimer = approach(move.aggroTimer, 0, 1);
	
	if (dist <= combat.attackRadius && los && attack.cooldown == 0) { toAttacking(); }
	else if ((dist >= combat.chaseRadius || !los) && move.aggroTimer == 0 && lastSeenDist < 10) { toIdle(); }
}

function attacking() {
	//Wait a while before dashing, then initiate dash
	//When dash is over, go back to chasing player
	if (attack.anticipationDur > 0) {
		attack.anticipationDur = approach(attack.anticipationDur, 0, 1);
		if (attack.anticipationDur == 0) attack.dir = point_direction(x, y, oPlayer.x, oPlayer.y);
	} else if (attack.dur > 0) {
		sprite_index = sEnemyMeleeDashing;
		move.hsp = lengthdir_x(attack.spd, attack.dir);
		horizontalCollision(move.collMask);
			
		move.vsp = lengthdir_y(attack.spd, attack.dir);
		verticalCollision(move.collMask);
		
		attack.dur = approach(attack.dur, 0, 1);
		
		x += move.hsp * delta;
		y += move.vsp * delta;
		
		if (attack.dur == 0) {			
			attack.cooldown = dashAttack.cooldown;
			attack.damaged = false;
			
			toChasing();
		}
	}
	
	//Player hit detection
	if (attack.damaged == false && oPlayer.combat.iframes == 0 && place_meeting(x, y, oPlayer)) {
		with (oPlayer) {
			takeDamage(other.attack.dmg);
			
			if (combat.hp <= 0) toDead();
		}
		
		attack.damaged = true;
	}
}

function stunned() {
	staticMovement(move.collMask);
	
	combat.stunDur = approach(combat.stunDur, 0, 1);
	if (combat.stunDur == 0) toIdle();
}

//State switches
function toIdle() {
	sprite_index = sEnemyMelee;
	state = idle;
}

function toChasing() {
	sprite_index = sEnemyMelee;
	state = chasing;
}

function toAttacking() {
	//Impart dash attack qualities to current attack
	attack.dur = dashAttack.dur;
	attack.anticipationDur = dashAttack.anticipationDur;
	attack.spd = dashAttack.spd;
	attack.dmg = dashAttack.dmg;

	sprite_index = sEnemyMeleeAnticipation;
	state = attacking;
}

function toStunned(duration) {
	attack.cooldown = dashAttack.cooldown;
	combat.stunDur = duration;
	
	sprite_index = sEnemyMeleeStunned;
	state = stunned;
}

//Movement
function chaseMovement(xx, yy, lineOfSight, dist) {
	//Get line of sight
	if (lineOfSight && dist < combat.chaseRadius) {
		move.lastSeen[0] = xx;
		move.lastSeen[1] = yy;
	}
	
	//Placeholder movement
	var dir = point_direction(x, y, move.lastSeen[0], move.lastSeen[1]);
	var moveDir = point_direction(x, y, move.hsp, move.vsp);
	
	//Correct direction when ending attack
	if (abs(move.hsp) >  move.chaseSpd) move.hsp = approach(move.hsp, lengthdir_x(move.chaseSpd, dir), abs(lengthdir_x(move.fric, moveDir))); 
	if (abs(move.vsp) >  move.chaseSpd) move.vsp = approach(move.vsp, lengthdir_y(move.chaseSpd, dir), abs(lengthdir_y(move.fric, moveDir))); 
	
	move.hsp = approach(move.hsp, lengthdir_x(move.chaseSpd, dir), move.axl);
	horizontalCollision(move.collMask);
	
	move.vsp = approach(move.vsp, lengthdir_y(move.chaseSpd, dir), move.axl);
	verticalCollision(move.collMask);
	
	x += move.hsp * delta;
	y += move.vsp * delta;
}

//Other
function incrementCooldowns() {
	attack.cooldown = approach(attack.cooldown, 0, 1);
}