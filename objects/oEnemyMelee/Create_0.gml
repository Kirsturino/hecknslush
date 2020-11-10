// Inherit the parent event
event_inherited();

combat = {
	hp : 3,
	detectionRadius : 180,
	attackRadius : 64,
	stunDur : 0,
	stunnable : true,
	weight : 1
}

dashAttack = {
	dur : 32,
	anticipationDur : 64,
	spd : 3,
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
	chaseSpd: 0.8,
	idleSpd: 1,
	axl : 0.008,
	fric : 0.05,
	dir : 0
}

visual = {
	flash : 0,
	corpse: sEnemyMeleeCorpse
}


//States
function idle() {
	staticMovement();
	
	if (distance_to_object(oPlayer) <= combat.detectionRadius) toChasing();
}

function chasing() {
	chaseMovement();
	
	var dist = distance_to_object(oPlayer);
	if (dist <= combat.attackRadius && attack.cooldown == 0) { toAttacking(); }
	else if (dist >= combat.detectionRadius) { toIdle(); }
}

function attacking() {
	//Wait a while before dashing, then initiate dash
	//When dash is over, go back to chasing player
	if (attack.anticipationDur > 0) {
		attack.anticipationDur = approach(attack.anticipationDur, 0, 1);
		if (attack.anticipationDur == 0) attack.dir = point_direction(x, y, oPlayer.x, oPlayer.y);
	} else if (attack.dur > 0) {
		moveInDirection(attack.spd, attack.dir);
		
		attack.dur = approach(attack.dur, 0, 1);
		
		if (attack.dur == 0) {
			move.hsp = lengthdir_x(attack.spd, attack.dir);
			move.vsp = lengthdir_y(attack.spd, attack.dir);
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
	staticMovement();
	
	combat.stunDur = approach(combat.stunDur, 0, 1);
	if (combat.stunDur == 0) toIdle();
}

//Declare state
state = idle;

//State switches
function toIdle() {
	state = idle;
}

function toChasing() {
	state = chasing;
}

function toAttacking() {
	//Impart dash attack qualities to current attack
	attack.dur = dashAttack.dur;
	attack.anticipationDur = dashAttack.anticipationDur;
	attack.spd = dashAttack.spd;
	attack.dmg = dashAttack.dmg;

	state = attacking;
}

function toStunned(duration) {
	attack.cooldown = dashAttack.cooldown;
	combat.stunDur = duration;
	state = stunned;
}

//Movement
function chaseMovement() {
	//Placeholder movement
	var dir = point_direction(x, y, oPlayer.x, oPlayer.y);
	var moveDir = point_direction(x, y, move.hsp, move.vsp);
	
	//Correct direction when ending attack
	if (abs(move.hsp) >  move.chaseSpd) move.hsp = approach(move.hsp, lengthdir_x(move.chaseSpd, dir), abs(lengthdir_x(move.fric, moveDir))); 
	if (abs(move.vsp) >  move.chaseSpd) move.vsp = approach(move.vsp, lengthdir_y(move.chaseSpd, dir), abs(lengthdir_y(move.fric, moveDir))); 
	
	move.hsp = approach(move.hsp, lengthdir_x(move.chaseSpd, dir), move.axl);
	move.vsp = approach(move.vsp, lengthdir_y(move.chaseSpd, dir), move.axl);
	
	x += move.hsp * delta;
	y += move.vsp * delta;
}

//Other
function incrementCooldowns() {
	attack.cooldown = approach(attack.cooldown, 0, 1);
}

function damagePlayer() {
	
}