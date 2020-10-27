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

#macro meleeBufferSize 200
#macro shootBufferSize 200
#macro dodgeBufferSize 500

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

state = states.grounded;

//Circular buffer for states, normalize size for different target framerates
//This will be used to add some leniency to combos and various actions
var size = round(game_get_speed(gamespeed_fps) / 4);
stateBuffer = array_create(size, 0);
stateBufferSize = size;
stateBufferPointer = 0;

//Movement variables and player properties
move = {
	hsp : 0,
	vsp : 0,
	maxSpd : 1.2,
	axl : 0.15,
	fric : 0.05
}

//Player attack properties. These will change on a per-attack basis, probably
melee = {
	dmg : 0,
	dur : 0,
	combo : 0,
	comboComplete : false,
	queued : false,
	cooldown : 0
}

//Testing weapon struct idea. Data from a list of weapons would be pulled here to be used locally
curMeleeWeapon = {
	dmg : 0,
	comboLength : 3,
	dur : [36, 36, 60],
	cooldown : 30
}

//Player attack properties (will probably be manipulated by current ranged weapon)
ranged = {
	dur : 0,
	combo : 0,
	cooldown : 0
}

curRangedWeapon = {
	projectile : oProjectile,
	dmg: 0,
	dur : 60,
	cooldown : 30
}

//Dodge properties, not sure what to put here, really, or how it will work yet
dodge = {
	dur : 0,
	spd : 0,
	dir : 0,
	cooldown : 0
}

curDodge = {
	dur : 14,
	spd : 6,
	cooldown : 60
}

function playerGrounded() {
	groundedMovement();
	
	//State switches
	if (dodge.cooldown == 0 && input_check_press(verbs.dodge, 0, dodgeBufferSize)) toDodging(curDodge);
	if (melee.cooldown == 0 && input_check_press(verbs.melee, 0, meleeBufferSize)) toMeleeing(curMeleeWeapon);
	if (ranged.cooldown == 0 && input_check_press(verbs.shoot, 0, shootBufferSize)) toShooting(curRangedWeapon);
}

function playerDummy() {
	//Do nothing, lol
}

function playerMeleeing() {
	melee.dur = approach(melee.dur, 0, 1);
	
	if (melee.dur <= 0) {
		if (melee.queued) {
			incrementCombo(curMeleeWeapon);
		} else {
			if (melee.comboComplete) {
				melee.cooldown = curMeleeWeapon.cooldown;
				resetCombo();
			}
			toGrounded();
		}
	} else if (input_check_press(verbs.melee, 0, 0) && !melee.comboComplete) {
		melee.queued = true;
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
	if (!checkBufferForState(states.meleeing)) resetCombo();
		
	//Put melee weapon info into player melee struct here, maybe?
	incrementCombo(curMeleeWeapon);
	
	input_consume(verbs.melee);
	negateMomentum();
	state = states.meleeing;
}
	
function toShooting(rangedStruct) {
	//Put ranged weapon info into player melee struct here, maybe?
	ranged.dur = rangedStruct.dur;
	ranged.cooldown = rangedStruct.cooldown;
	
	//Shoot projectile
	launchProjectile(rangedStruct);
	
	input_consume(verbs.shoot);
	negateMomentum();
	state = states.shooting;
}

function toDodging(dodgeStruct) {
	dodge.dur = dodgeStruct.dur;
	dodge.spd = dodgeStruct.spd;
	dodge.cooldown = dodgeStruct.cooldown;
	
	//Determine dodge direction
	var dodgeDir = getMovementInput();
	dodge.dir = point_direction(0, 0, dodgeDir[0], dodgeDir[1]);
	
	input_consume(verbs.dodge);
	state = states.dodging;
}

function groundedMovement() {
	//Get input and input direction
	var mv = getMovementInput();
	var dir = getMovementInputDirection();

	//If left/right is held, accelerate, if not, decelerate
	if (mv[0] != 0) {
		move.hsp = approach(move.hsp, lengthdir_x(move.maxSpd, dir), abs(lengthdir_x(move.axl, dir)));
	} else {
		move.hsp = approach(move.hsp, 0, move.fric);
	}

	//If up/down is held, accelerate, if not, decelerate
	if (mv[1] != 0) {
		move.vsp = approach(move.vsp, lengthdir_y(move.maxSpd, dir), abs(lengthdir_y(move.axl, dir)));
	} else {
		move.vsp = approach(move.vsp, 0, move.fric);
	}
	
	//Apply momentum
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

function resetCombo() {
	melee.combo = 0;
	melee.comboComplete = false;
	melee.queued = false;
}

function incrementCombo(meleeStruct) {
	melee.dur = meleeStruct.dur[melee.combo];
	melee.combo++;
	melee.queued = false;
			
	//Check if this was final hit of combo
	if (melee.combo >= meleeStruct.comboLength) {
		melee.comboComplete = true;
		input_consume(verbs.melee);
	}
}

function updateStateBuffer() {
	stateBuffer[stateBufferPointer] = state;
	
	stateBufferPointer++;
	if (stateBufferPointer >= stateBufferSize) stateBufferPointer = 0;
}

function checkBufferForState(state) {
	var i = 0;
	repeat (stateBufferSize) {
		if (stateBuffer[i] == state) return true;
		i++;
	}
	
	return false;
}

function launchProjectile(rangedStruct) {
	var proj = instance_create_layer(x, y, "Instances", rangedStruct.projectile);
	proj.move.dir = getMovementInputDirection();
	proj.attack.dmg = rangedStruct.dmg;
}

function incrementVerbCooldowns() {
	//Short pause after doing verbs
	dodge.cooldown = approach(dodge.cooldown, 0, 1);
	melee.cooldown = approach(melee.cooldown, 0, 1);
	ranged.cooldown = approach(ranged.cooldown, 0, 1);
}