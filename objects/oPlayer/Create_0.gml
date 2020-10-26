//Init input source
input_player_source_set(INPUT_SOURCE.KEYBOARD_AND_MOUSE);

//Init verbs
enum verb {
	right,
	left,
	down,
	up,
	melee,
	shoot,
	dodge
}

//Bind default keys
input_default_key(ord("A"), verb.left);
input_default_key(ord("D"), verb.right);
input_default_key(ord("W"), verb.up);
input_default_key(ord("S"), verb.down);
input_default_key(ord("J"), verb.melee);
input_default_key(ord("K"), verb.shoot);
input_default_key(vk_space, verb.dodge);

//Init states
enum states {
	dummy,
	grounded,
	dodging,
	meleeing,
	shooting,
	stunned
}

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
	htbx : [0, 0]
}

//Testing weapon struct idea. Data from a list of weapons would be pulled here to be used locally
curMeleeWeapon = {
	dmg : 0,
	dur : 24,
	htbx : [0, 0]
}

//Player attack properties (will probably be manipulated by current ranged weapon)
ranged = {
	dmg : 0,
	dur : 0,
	htbx : [0, 0],
}

curRangedWeapon = {
	dmg : 0,
	dur : 12,
	htbx : [0, 0]
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
	if (input_check_press(verb.dodge, 0, 24)) toDodging(curDodge);
	if (input_check_press(verb.melee, 0, 24)) toMeleeing(curMeleeWeapon);
	if (input_check_press(verb.shoot, 0, 24)) toShooting(curRangedWeapon);
}

function playerDummy() {
	//Do nothing, lol
}

function playerMeleeing() {
	melee.dur = approach(melee.dur, 0, 1);
	if (melee.dur <= 0) toGrounded();
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
	state = states.meleeing;
	
	//Put melee weapon info into player melee struct here, maybe?
	melee.dur = meleeStruct.dur;
}
	
function toShooting(rangedStruct) {
	state = states.shooting;
	
	//Put ranged weapon info into player melee struct here, maybe?
	ranged.dur = rangedStruct.dur;
}

function toDodging(dodgeStruct) {
	state = states.dodging;
	
	dodge.dur = dodgeStruct.dur;
	dodge.spd = dodgeStruct.spd;
	
	//Determine dodge direction
	var dodgeDir = getInputDirection();
	dodge.dir = point_direction(0, 0, dodgeDir[0], dodgeDir[1]);
}

function groundedMovement() {
	//Basic movement & input
	var movement = getInputDirection();

	if (movement[0] != 0) {
		move.hsp = approach(move.hsp, move.maxSpd * movement[0], move.axl);
	} else {
		move.hsp = approach(move.hsp, 0, move.fric);
	}

	if (movement[1] != 0) {
		move.vsp = approach(move.vsp, move.maxSpd * movement[1], move.axl);
	} else {
		move.vsp = approach(move.vsp, 0, move.fric);
	}
	
	x += move.hsp * delta;
	y += move.vsp * delta;
}

function dodgeMovement() {
	moveInDirection(dodge.spd, dodge.dir);
}

function getInputDirection() {
	var hMove = input_check(verb.right) - input_check(verb.left);
	var vMove = input_check(verb.down) - input_check(verb.up);
	
	//Return player's held horizontal and vertical directions separately
	return [hMove, vMove];
}