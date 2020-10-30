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
input_default_mouse_button(mb_left, verbs.melee, true);
input_default_mouse_button(mb_right, verbs.shoot, true);

#macro meleeBufferSize 100
#macro shootBufferSize 100
#macro dodgeBufferSize 200

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
	aiming,
	shooting,
	stunned,
	dead
}

state = states.grounded;

//Circular buffer for states, normalize size for different target framerates
//This will be used to add some leniency to combos and various actions
var bufSize = round(game_get_speed(gamespeed_fps) / 5);
stateBuffer = array_create(bufSize, 0);
stateBufferSize = bufSize;
stateBufferPointer = 0;

//Movement variables and player properties
move = {
	hsp : 0,
	vsp : 0,
	maxSpd : 1.2,
	axl : 0.12,
	fric : 0.04,
	lastDir : 0,
	moving : false
}

//Player melee attack properties, most of the weapon stats will be imparted to the actual hitbox
melee = {
	dur : 0,
	combo : 0,
	comboComplete : false,
	queued : false,
	cooldown : 0,
	htbx : false
}

//Testing weapon struct idea. Data from a list of weapons would be pulled here to be used locally
curMeleeWeapon = {
	name :			"testMelee",
	type :			weapons.melee,
	htbx :			oHitbox,
	baseDmg :		1,
	comboLength :	3,
	cooldown :		30,
	spr :			[sSlash, sSlashInverse, sThrust],
	htbxStart :		[2, 2, 5],
	htbxLength :	[10, 10, 20],
	htbxSlide :		[0, 0, 0],
	htbxFric :		[0.05, 0.05, 0.1],
	reach :			[32, 32, 48],
	dmgMultiplier:	[0.8, 1, 1.5],
	dur :			[32, 32, 36],
	slide :			[1, 1, -1],
	knockback :		[1, 1, 3]
}

//Player ranged attack properties, most of the weapon stats will be imparted to the actual projectile
ranged = {
	dur : 0,
	cooldown : 0,
	shot : 0,
}

curRangedWeapon = {
	name :			"testRanged",
	type :			weapons.ranged,
	htbx :			oHitbox,
	spr :			sProjectile,
	amount :		8,
	delay :			0,
	spread :		0,
	multiSpread :	40,
	reach :			12,
	spd :			6,
	life :			180,
	destroyOnStop :	true,
	fric :			0.1,
	knockback :		0.5,
	piercing :		false,
	dmg:			0.5,
	dur :			30,
	size :			1,
	cooldown :		60
}

//Dodge properties, not sure what to put here, really, or how it will work yet
dodge = {
	dur : 0,
	spd : 0,
	dir : 0,
	cooldown : 0
}

curDodge = {
	dur : 20,
	spd : 3.5,
	iframes : 5,
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
	
	attackMovement();
	
	//Spawn hitboxes for each melee strike here
	performMelee();
	
	//Work out if player wants to keep attacking or not
	//If dur reaches zero and player hasn't pressed attack again, go back to normal state and reset combo
	//Otherwise, increment combo and start new attack 
	//If at end of combo, go back to normal state anyway
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
	
	//If we have a burst weapon (it has > 0 delay and more than 1 bullet), repeat shot
	//It resets the shot dur until max amount of bullets have been shot
	if (ranged.shot < curRangedWeapon.amount && ranged.dur < curRangedWeapon.dur - curRangedWeapon.delay) {
		performShot();
	}

	attackMovement();
	
	//State switch
	//If current weapon is full auto (aka has 0 cooldown), holding down fire button will keep firing
	if (ranged.dur <= 0 && curRangedWeapon.cooldown == 0 && input_check(verbs.shoot)) {
		resetShots();
	} else if (ranged.dur <= 0) {
		ranged.cooldown = curRangedWeapon.cooldown;
		resetShots();
		toGrounded();
	}
}

function playerDodging() {
	dodgeMovement();
	
	dodge.dur = approach(dodge.dur, 0, 1);
	if (dodge.dur <= 0) {
		move.hsp = lengthdir_x(move.maxSpd, dodge.dir);
		move.vsp = lengthdir_y(move.maxSpd, dodge.dir);
		toGrounded();
	}
}

function toDummy() {
	state = states.dummy;
}

function toGrounded() {
	state = states.grounded;
}

function toMeleeing() {
	if (!checkBufferForState(states.meleeing)) resetCombo();
		
	//Perform melee when transitioning for instant feedback
	incrementCombo(curMeleeWeapon);
	performMelee();
	
	input_consume(verbs.melee);
	state = states.meleeing;
}
	
function toShooting() {
	//Prevent melee combo cheese
	resetCombo();
	
	//Instant shot when transitioning
	performShot();
	
	if (curRangedWeapon.cooldown != 0) input_consume(verbs.shoot);
	state = states.shooting;
}

function toDodging() {
	//Set dodge stats
	dodge.dur = curDodge.dur;
	dodge.spd = curDodge.spd;
	dodge.cooldown = curDodge.cooldown;
	
	//Remove combo progress on dodge
	resetCombo();
	
	//Determine dodge direction
	dodge.dir = getLastDir();
	
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

function getLastDir() {
	if (!isHoldingDirection()) {
		return move.lastDir;
	} else {
		var dir = getMovementInputDirection();
		return dir;
	}
}

function getAttackDir() {
	//Get direction melee hitbox should move in
	if (input_player_source_get(0) == INPUT_SOURCE.KEYBOARD_AND_MOUSE) {
		var dir = point_direction(x, y, mouse_x, mouse_y);
	} else if (!isHoldingDirection()) {
		var dir = move.lastDir;
	} else {
		var dir = getMovementInputDirection();
	}
	
	return dir;
}

function resetCombo() {
	melee.combo = 0;
	melee.comboComplete = false;
	melee.queued = false;
	melee.htbx = false;
}

function resetShots() {
	ranged.shot = 0;
}

function performMelee() {
	var dir = getAttackDir();
	if (!melee.htbx) spawnHitbox(curMeleeWeapon, dir);
	setAttackMovement(struct.slide[melee.combo - 1]);
}

function performShot() {
	//If delay is 0, it shoots multiple bullets per dur cycle
	//Bullets in burst can have multispread
	if (curRangedWeapon.delay == 0) {
		//Loop through all the bullets in the burst
		repeat (curRangedWeapon.amount) {
			var dir = getAttackDir();
			
			//If weapon has multispread, do some directional calculation based on the multispread variable
			if (curRangedWeapon.multiSpread > 0) {
				dir += (curRangedWeapon.multiSpread / (curRangedWeapon.amount - 1) * ranged.shot) - curRangedWeapon.multiSpread * .5;
			}
		
			spawnHitbox(curRangedWeapon, dir);
			incrementShot(curRangedWeapon);
		}
	} else { 
		//This is where we go if we only shoot 1 bullet per frame, aka delay > 0
		//Just shoot bullet in the direction, no directional shenanigans
		var dir = getAttackDir();
		spawnHitbox(curRangedWeapon, dir);
		incrementShot(curRangedWeapon);
		setAttackMovement(-curRangedWeapon.knockback);
	}
	
	spawnHitbox(curRangedWeapon, dir);
	incrementShot(curRangedWeapon);
}

function incrementCombo(meleeStruct) {
	melee.dur = meleeStruct.dur[melee.combo];
	
	//Increment combo counter
	melee.combo++;
	
	melee.queued = false;
	melee.htbx = false;
			
	//Check if this was final hit of combo
	if (melee.combo >= meleeStruct.comboLength) {
		melee.comboComplete = true;
		input_consume(verbs.melee);
	}
}

function incrementShot(rangedStruct) {
	//Increment shot count for burst weapons
	ranged.shot++;
		
	//Set time before player is able to move again
	ranged.dur = rangedStruct.dur;
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

function incrementVerbCooldowns() {
	//Short pause after doing verbs
	dodge.cooldown = approach(dodge.cooldown, 0, 1);
	melee.cooldown = approach(melee.cooldown, 0, 1);
	ranged.cooldown = approach(ranged.cooldown, 0, 1);
}

function spawnHitbox(struct, dir) {
switch (struct.type) {
		case weapons.melee:
			var spawnX = x + lengthdir_x(struct.reach[melee.combo - 1], dir);
			var spawnY = y + lengthdir_y(struct.reach[melee.combo - 1], dir);
	
			//Impart weapon stats to hitbox
			var htbx = instance_create_layer(spawnX, spawnY, "Instances", struct.htbx);
			htbx.sprite_index = struct.spr[melee.combo - 1];
			htbx.image_angle = dir;
	
			htbx.move.hsp = lengthdir_x(struct.htbxSlide[melee.combo - 1], dir);
			htbx.move.vsp = lengthdir_y(struct.htbxSlide[melee.combo - 1], dir);
			htbx.move.fric = struct.htbxFric[melee.combo - 1];
	
			htbx.atk.dur = struct.htbxLength[melee.combo - 1];	
			htbx.atk.dmg = struct.baseDmg * struct.dmgMultiplier[melee.combo - 1];
			htbx.atk.knockback = struct.knockback[melee.combo - 1];
			htbx.atk.delay = struct.htbxStart[melee.combo - 1];
		
			//All melee weapons can cleave and persist
			htbx.atk.destroyOnStop = false;
			htbx.atk.piercing = true;
		
			melee.htbx = true;
		break;
		
		case weapons.ranged:	
			var spawnX = x + lengthdir_x(struct.reach, dir);
			var spawnY = y + lengthdir_y(struct.reach, dir);
		
			//Apply random spread
			dir += irandom_range(-struct.spread, struct.spread);
	
			//Impart weapon stats to hitbox
			var htbx = instance_create_layer(spawnX, spawnY, "Instances", struct.htbx);
			htbx.sprite_index = struct.spr;
			htbx.image_angle = dir;
			htbx.image_xscale = struct.size;
			htbx.image_yscale = struct.size;
	
			htbx.move.hsp = lengthdir_x(struct.spd, dir);
			htbx.move.vsp = lengthdir_y(struct.spd, dir);
			htbx.move.fric = struct.fric;
	
			htbx.atk.dur = struct.life;	
			htbx.atk.dmg = struct.dmg;
			htbx.atk.knockback = struct.knockback;
			htbx.atk.piercing = struct.piercing;
			htbx.atk.destroyOnStop = struct.destroyOnStop;
		break;
	}
}

function attackMovement() {
	move.hsp = approach(move.hsp, 0, move.fric);
	move.vsp = approach(move.vsp, 0, move.fric);
	
	x += move.hsp * delta;
	y += move.vsp * delta;
}

function setAttackMovement(amount) {
	if (input_player_source_get(0) == INPUT_SOURCE.KEYBOARD_AND_MOUSE) {
		var dir = point_direction(x, y, mouse_x, mouse_y);
	} else if (!isHoldingDirection()) {
		var dir = move.lastDir;
	} else {
		var dir = getMovementInputDirection();
	}
	
	move.hsp = lengthdir_x(amount, dir);
	move.vsp = lengthdir_y(amount, dir);
}