//Init input source
input_player_source_set(INPUT_SOURCE.KEYBOARD_AND_MOUSE);

//Init verbs
enum verbs {
	right,
	left,
	down,
	up,
	melee,
	shoot,
	dodge
}

//Bind default keys
input_default_key(ord("A"), verbs.left);
input_default_key(ord("D"), verbs.right);
input_default_key(ord("W"), verbs.up);
input_default_key(ord("S"), verbs.down);
input_default_key(ord("J"), verbs.melee);
input_default_key(ord("K"), verbs.shoot);
input_default_key(vk_space, verbs.dodge);

//Input jank
input_consume(verbs.melee);
input_consume(verbs.shoot);
input_consume(verbs.dodge);

//Init states
enum states {
	dummy,
	grounded,
	dodging,
	meleeing,
	shooting,
	stunned
}

//Jank
state = states.grounded;

//Movement variables and player properties
move = {
	hsp : 0,
	vsp : 0,
	maxSpd : 1.2,
	axl : 0.2,
	fric : 0.05
}

//Player attack properties. These will change on a per-attack basis, probably
melee = {
	dmg : 0,
	dur : 0,
	combo : 0
}

//Testing weapon struct idea. Data from a list of weapons would be pulled here to be used locally
curMeleeWeapon = {
	dmg : 0,
	dur : [24, 24, 48]
}

//Player attack properties (will probably be manipulated by current ranged weapon)
ranged = {
	dmg : 0,
	dur : 0,
	combo : 0
}

curRangedWeapon = {
	projectile : oProjectile,
	dmg: 0,
	dur : 12
}

//Dodge properties, not sure what to put here, really, or how it will work yet
dodge = {
	dur : 0,
	spd : 0,
	dir : 0
}

curDodge = {
	dur : 14,
	spd : 6
}

function playerGrounded() {
	groundedMovement();
	
	//State switches
	if (input_check_press(verbs.dodge, 0, 24)) toDodging(curDodge);
	if (input_check_press(verbs.melee, 0, 24)) toMeleeing(curMeleeWeapon);
	if (input_check_press(verbs.shoot, 0, 24)) toShooting(curRangedWeapon);
}

function playerDummy() {
	//Do nothing, lol
}

function playerMeleeing() {
	melee.dur = approach(melee.dur, 0, 1);
	if (melee.dur <= 0) {
		melee.combo = 0;
		toGrounded();
	}
}

function playerShooting() {
	ranged.dur = approach(ranged.dur, 0, 1);
	if (ranged.dur <= 0) toGrounded();
}

function playerDodging() {
	dodgeMovement();
	
	dodge.dur = approach(dodge.dur, 0, 1);
	if (dodge.dur <= 0) toGrounded();
}

function toDummy() {
	state = states.dummy;
}

function toGrounded() {
	state = states.grounded;
}

function toMeleeing(meleeStruct) {	
	//Put melee weapon info into player melee struct here, maybe?
	melee.dur = meleeStruct.dur[melee.combo];
	melee.combo++;
	
	input_consume(verbs.melee);
	negateMomentum();
	state = states.meleeing;
}
	
function toShooting(rangedStruct) {
	//Put ranged weapon info into player melee struct here, maybe?
	ranged.dur = rangedStruct.dur;
	
	var proj = instance_create_layer(x, y, "Instances", rangedStruct.projectile);
	proj.movement.dir = getMovementInputDirection();
	
	input_consume(verbs.shoot);
	negateMomentum();
	state = states.shooting;
}

function toDodging(dodgeStruct) {
	dodge.dur = dodgeStruct.dur;
	dodge.spd = dodgeStruct.spd;
	
	//Determine dodge direction
	var dodgeDir = getMovementInput();
	dodge.dir = point_direction(0, 0, dodgeDir[0], dodgeDir[1]);
	
	input_consume(verbs.dodge);
	state = states.dodging;
}

//DIAGONAL MOVEMENT IS SCUFFED AF RN BECAUSE I HAVE BETTER THINGS TO DO
function groundedMovement() {
	//Basic movement & input
	var mv = getMovementInput();

	if (mv[0] != 0) {
		move.hsp = approach(move.hsp, move.maxSpd * mv[0], move.axl);
	} else {
		move.hsp = approach(move.hsp, 0, move.fric);
	}

	if (mv[1] != 0) {
		move.vsp = approach(move.vsp, move.maxSpd * mv[1], move.axl);
	} else {
		move.vsp = approach(move.vsp, 0, move.fric);
	}
	
	x += move.hsp * delta;
	y += move.vsp * delta;
}

function dodgeMovement() {
	moveInDirection(dodge.spd, dodge.dir);
}

function getMovementInput() {
	var hMove = input_check(verbs.right) - input_check(verbs.left);
	var vMove = input_check(verbs.down) - input_check(verbs.up);
	
	//Return player's held horizontal and vertical directions separately
	return [hMove, vMove];
}

function getMovementInputDirection() {
	var hMove = input_check(verbs.right) - input_check(verbs.left);
	var vMove = input_check(verbs.down) - input_check(verbs.up);
	
	//Return player's held direction
	return point_direction(0, 0, hMove, vMove);
}

function negateMomentum() {
	move.hsp = 0;
	move.vsp = 0;
}