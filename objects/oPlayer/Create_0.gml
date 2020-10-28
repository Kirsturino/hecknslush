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
#macro dodgeBufferSize 400

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
	stunned,
	dead
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
	fric : 0.05,
	lastDir : 0,
	moving : false
}

//Player attack properties. These will change on a per-attack basis, probably
melee = {
	dmg : 0,
	dur : 0,
	combo : 0,
	comboComplete : false,
	queued : false,
	cooldown : 0,
	htbx : false
}

//Testing weapon struct idea. Data from a list of weapons would be pulled here to be used locally
curMeleeWeapon = {
	name : "testMelee",
	spr : sTestMelee,
	htbx : sTestMeleeHitbox,
	htbxStart : [2, 2, 5],
	htbxLength : [20, 20, 40],
	htbxSlide : [2, 2, 1],
	reach : [48, 48, 64],
	baseDmg : 1,
	comboLength : 3,
	dmgMultiplier: [0.8, 1, 1.5],
	dur : [36, 36, 60],
	slide : [1, 1, -1],
	cooldown : 30
}

//Player attack properties (will probably be manipulated by current ranged weapon)
ranged = {
	dur : 0,
	combo : 0,
	cooldown : 0
}

curRangedWeapon = {
	name : "testRanged",
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
	if (dodge.cooldown == 0 && input_check_press(verbs.dodge, 0, dodgeBufferSize)) toDodging();
	if (melee.cooldown == 0 && input_check_press(verbs.melee, 0, meleeBufferSize)) toMeleeing();
	if (ranged.cooldown == 0 && input_check_press(verbs.shoot, 0, shootBufferSize)) toShooting();
}

function playerDummy() {
	//Do nothing, lol
}

function playerMeleeing() {
	melee.dur = approach(melee.dur, 0, 1);
	
	//Spawn hitboxes for each melee strike here
	if (!melee.htbx && melee.dur >= curMeleeWeapon.htbxStart[melee.combo - 1]) spawnHitbox();
	
	//Work out if player wants to keep attacking or not
	//If dur reaches zero and player hasn't pressed attack again, go back to normal state and reset combo
	//Otherwise, increment combo and start new attack, if at end of combo, go back to normal state anyway
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
	
	meleeMovement();
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

function toMeleeing() {
	if (!checkBufferForState(states.meleeing)) resetCombo();
		
	//Put melee weapon info into player melee struct here, maybe?
	incrementCombo(curMeleeWeapon);
	
	input_consume(verbs.melee);
	state = states.meleeing;
}
	
function toShooting() {
	//Put ranged weapon info into player melee struct here, maybe?
	ranged.dur = curRangedWeapon.dur;
	ranged.cooldown = curRangedWeapon.cooldown;
	
	//Shoot projectile
	launchProjectile(curRangedWeapon);
	
	input_consume(verbs.shoot);
	negateMomentum();
	state = states.shooting;
}

function toDodging() {
	dodge.dur = curDodge.dur;
	dodge.spd = curDodge.spd;
	dodge.cooldown = curDodge.cooldown;
	
	//Remove combo progress on dodge
	resetCombo();
	
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
	
	//Set last direction player was going
	if (mv[0] != 0 || mv[1] != 0) {
		move.lastDir = dir;
		move.moving = true;
	} else {
		move.moving = false;
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

function isHoldingDirection() {
	var mv = getMovementInput();
	
	if (mv[0] != 0 || mv[1] != 0) {
		return true;
	} else {
		return false;
	}
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
	melee.htbx = false;
}

function incrementCombo(meleeStruct) {
	setMeleeMovement();
	melee.dur = meleeStruct.dur[melee.combo];
	melee.combo++;
	melee.queued = false;
	melee.htbx = false;
			
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

function spawnHitbox() {
	if (!isHoldingDirection()) {
		var dir = move.lastDir;
	} else {
		var dir = getMovementInputDirection();
	}
	
	var spawnX = x + lengthdir_x(curMeleeWeapon.reach[melee.combo - 1], dir);
	var spawnY = y + lengthdir_y(curMeleeWeapon.reach[melee.combo - 1], dir);
	
	var htbx = instance_create_layer(spawnX, spawnY, "Instances", oHitbox);
	htbx.sprite_index = curMeleeWeapon.spr;
	htbx.image_index = melee.combo - 1;
	htbx.image_angle = dir;
	htbx.mask_index = curMeleeWeapon.htbx;
	htbx.depth = depth;
	htbx.dur = curMeleeWeapon.htbxLength[melee.combo - 1];	
	htbx.move.hsp = lengthdir_x(curMeleeWeapon.htbxSlide[melee.combo - 1], dir);
	htbx.move.vsp = lengthdir_y(curMeleeWeapon.htbxSlide[melee.combo - 1], dir);
	
	melee.htbx = true;
}

function meleeMovement() {
	move.hsp = approach(move.hsp, 0, move.fric);
	move.vsp = approach(move.vsp, 0, move.fric);
	
	x += move.hsp * delta;
	y += move.vsp * delta;
}

function setMeleeMovement() {
	if (!isHoldingDirection()) {
		var dir = move.lastDir;
	} else {
		var dir = getMovementInputDirection();
	}
	
	move.hsp = lengthdir_x(curMeleeWeapon.slide[melee.combo], dir);
	move.vsp = lengthdir_y(curMeleeWeapon.slide[melee.combo], dir);
}