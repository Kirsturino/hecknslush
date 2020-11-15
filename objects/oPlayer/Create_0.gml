//Init input source
input_player_source_set(INPUT_SOURCE.KEYBOARD_AND_MOUSE);

//Init verbs
enum verbs {
	right,
	left,
	down,
	up,
	attack,
	dodge,
	aim
}

//Bind default keys
input_default_key(ord("A"), verbs.left);
input_default_key(ord("D"), verbs.right);
input_default_key(ord("W"), verbs.up);
input_default_key(ord("S"), verbs.down);
input_default_key(ord("J"), verbs.attack);
input_default_key(ord("K"), verbs.attack);
input_default_key(vk_space, verbs.dodge);
input_default_mouse_button(mb_left, verbs.attack, true);
input_default_mouse_button(mb_right, verbs.aim, true);

#macro meleeBufferSize 100
#macro shootBufferSize 100
#macro dodgeBufferSize 200

//Input jank
input_consume(verbs.attack);
input_consume(verbs.dodge);

//Init states
enum states {
	dummy,
	grounded,
	sprinting,
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
var buffSize = round(game_get_speed(gamespeed_fps) / 5);
stateBuffer = array_create(buffSize, 0);
stateBufferSize = buffSize;
stateBufferPointer = 0;

//Movement variables and player properties
move = {
	hsp : 0,
	vsp : 0,
	maxSpd : 1.2,
	curMaxSpd : 1.2,
	axl : 0.12,
	fric : 0.04,
	lastDir : 0,
	dir : 0,
	moving : false
}

sprint = {
	maxSpd : 2,
	axl : 0.05,
	turnSpd : 0,
	turnAxl : 0.2,
	turnMaxSpd : 2,
	buildup : 0,
	buildupMax : 60
}

//Combat variables
combat = {
	hp : 5,
	iframesMax : 144,
	iframes : 0
}

//Visuals
visual = {
	
}

//Player melee attack properties, most of the weapon stats will be imparted to the actual hitbox
melee = {
	dur : 0,
	dir : 0,
	strike : 0,
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
	clr :			c_red,
	htbx :			oHitbox,
	baseDmg :		1,
	comboLength :	3,
	cooldown :		60,
	amount :		[1, 1, 3],
	delay  :		[0, 0, 5],
	multiSpread :	[0, 0, 120],
	spr :			[sSlash, sSlashInverse, sThrust],
	htbxStart :		[2, 2, 5],
	htbxLength :	[10, 10, 20],
	htbxSlide :		[0, 0, 0],
	htbxFric :		[0.05, 0.05, 0.1],
	reach :			[32, 32, 48],
	dmgMultiplier:	[1.5, 1.5, 1.25],
	dur :			[32, 32, 36],
	slide :			[1, 1, -1],
	knockback :		[1, 1, 2.5]
}

//Player ranged attack properties, most of the weapon stats will be imparted to the actual projectile
ranged = {
	dur : 0,
	cooldown : 0,
	shot : 0,
	burst : 0,
	aimDir : 0,
	recoil : 0
}

curRangedWeapon = {
	name :			"testRanged",
	type :			weapons.ranged,
	clr :			c_red,
	htbx :			oHitbox,
	spr :			sGun,
	projSpr :		sProjectile,
	amount :		10,
	delay :			5,
	burstAmount :	0,
	burstDelay :	20,
	spread :		10,
	multiSpread :	40,
	reach :			12,
	spd :			6,
	life :			180,
	destroyOnStop :	true,
	fric :			0.06,
	knockback :		0.2,
	piercing :		true,
	dmg:			0.3,
	dur :			30,
	size :			1,
	zoom :			0.4,
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
	spd : 4,
	iframes : 20,
	cooldown : 60
}

function playerGrounded() {
	groundedMovement();
	
	//State switches
	if (dodge.cooldown == 0 && input_check_press(verbs.dodge, 0, dodgeBufferSize)) toDodging();
	if (melee.cooldown == 0 && input_check_press(verbs.attack, 0, meleeBufferSize)) toMeleeing();
	if (ranged.cooldown == 0 && input_check(verbs.aim)) toAiming();
	
	//Player can sprint by holding dodge button for long enough
	if (input_check(verbs.dodge)) {
		sprint.buildup = approach(sprint.buildup, sprint.buildupMax, 1);
		
		if (sprint.buildup == sprint.buildupMax) {
			move.dir = move.lastDir;
			toSprinting();
		}
	} else {
		sprint.buildup = 0;
	}
}

function playerSprinting() {
	sprintMovement();
	
	//FX
	part_particles_create(global.ps, x, bbox_bottom, global.bulletTrail, 1);
	
	if (random(1) > 0.8) {
		part_type_speed(global.hangingDustPart, 2, 2, -0.01, 0);
		part_type_direction(global.hangingDustPart, move.dir - 20, move.dir + 20, 0, 0);
		part_particles_create(global.ps, x, bbox_bottom, global.hangingDustPart, 1);
	}
	
	part_type_direction(global.hangingDustPart, move.dir - 90, move.dir + 90, 0, 0);
	part_type_speed(global.hangingDustPart, 0.1, 0.2, -0.01, 0);
	part_particles_create(global.ps, x, bbox_bottom, global.hangingDustPart, 1);
	
	//State switches
	if (melee.cooldown == 0 && input_check_press(verbs.attack, 0, meleeBufferSize)) {
		sprint.buildup = 0;
		move.lastDir = move.dir;
		toMeleeing();
	}
	
	if (ranged.cooldown == 0 && input_check(verbs.aim)) {
		sprint.buildup = 0;
		move.lastDir = move.dir;
		toAiming();
	}
	
	if (input_check_release(verbs.dodge)) {
		sprint.buildup = 0;
		move.hsp = lengthdir_x(move.curMaxSpd, move.dir);
		move.vsp = lengthdir_y(move.curMaxSpd, move.dir);
		move.lastDir = move.dir;
		toGrounded();
	}
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
	} else if (input_check_press(verbs.attack, 0, 0) && !melee.comboComplete) {
		melee.queued = true;
	}
	
	//Make player be able to break out of melee at will
	if (dodge.cooldown == 0 && input_check_press(verbs.dodge, 0, dodgeBufferSize)) {
		resetCombo();
		toDodging();
	}
}

function playerShooting() {
	ranged.aimDir = getAttackDir();
	ranged.dur = approach(ranged.dur, 0, 1);
	
	//If we have a burst weapon (it has > 0 delay and more than 1 bullet), repeat shot
	//It resets the shot dur until max amount of bullets have been shot
	if (ranged.shot < curRangedWeapon.amount && ranged.dur < curRangedWeapon.dur - curRangedWeapon.delay) {
		performShot();
	} else if (ranged.shot == curRangedWeapon.amount && ranged.burst < curRangedWeapon.burstAmount) {
		//If we have multiple bursts, reset shots between bursts, increment burst counter
		ranged.shot = 0;
		ranged.burst++;
		ranged.dur = curRangedWeapon.dur + curRangedWeapon.burstDelay;
	}

	attackMovement();
	
	//Visuals
	ranged.recoil = lerp(ranged.recoil, 0, 0.1);
	
	//State switch
	//If current weapon is full auto (aka has 0 cooldown), holding down fire button will keep firing
	if (ranged.dur <= 0 && curRangedWeapon.cooldown == 0 && input_check(verbs.attack)) {
		resetShots();
	} else if (ranged.dur <= 0) {
		ranged.cooldown = curRangedWeapon.cooldown;
		resetShots();
		if (input_check(verbs.aim)) {
			toAiming();
		} else {
			toGrounded();
		}	
	}
	
	//Make player be able to break out of melee at will
	if (dodge.cooldown == 0 && input_check_press(verbs.dodge, 0, dodgeBufferSize)) {
		resetShots();
		toDodging();
	}
}

function playerDodging() {
	dodge.dur = approach(dodge.dur, 0, 1);
	
	dodgeMovement();
	
	//State switches
	if (dodge.dur <= 0) {
		move.hsp = lengthdir_x(move.curMaxSpd, dodge.dir);
		move.vsp = lengthdir_y(move.curMaxSpd, dodge.dir);
		
		if (input_check(verbs.aim)) {
			dodge.cooldown = curDodge.cooldown;
			toAiming();
		} else {
			dodge.cooldown = curDodge.cooldown;
			if (input_check(verbs.dodge)) {
				move.curMaxSpd = sprint.maxSpd;
				move.hsp = lengthdir_x(move.curMaxSpd, dodge.dir);
				move.vsp = lengthdir_y(move.curMaxSpd, dodge.dir);
			}
			toGrounded();
		}
	}
	
	//FX
	part_type_direction(global.hangingDustPart, dodge.dir - 20, dodge.dir + 20 , 0, 0);
	part_type_speed(global.hangingDustPart, 2, 3, -0.01, 0);
	if (random(1) > 0.7) part_particles_create(global.ps, x, bbox_bottom, global.hangingDustPart, 1);
	
	part_particles_create(global.ps, x, bbox_bottom, global.bulletTrail, 1);
	part_particles_create(global.ps, x, y, global.dodgePart, 1);
	
	part_type_direction(global.hangingDustPart, dodge.dir - 90, dodge.dir + 90, 0, 0);
	part_type_speed(global.hangingDustPart, 0.1, 0.2, -0.01, 0);
	part_particles_create(global.ps, x, bbox_bottom, global.hangingDustPart, 1);
}

function playerAiming() {
	attackMovement();
	
	ranged.aimDir = getAttackDir();
	
	//State switch
	if (input_check_release(verbs.aim)) {
		toGrounded();
	} else if (dodge.cooldown == 0 && input_check_press(verbs.dodge, 0, dodgeBufferSize)) {
		 toDodging();
	} else if (ranged.cooldown == 0 && input_check_press(verbs.attack, 0, shootBufferSize)) {
		toShooting();
	}
}

function toDummy() {
	state = states.dummy;
}

function toGrounded() {
	move.curMaxSpd = move.maxSpd;
	state = states.grounded;
}

function toMeleeing() {
	if (!checkBufferForState(states.meleeing)) resetCombo();
		
	//Perform melee when transitioning for instant feedback
	incrementCombo(curMeleeWeapon);
	performMelee();
	
	input_consume(verbs.attack);
	state = states.meleeing;
}
	
function toShooting() {
	//Prevent melee combo cheese
	resetCombo();
	
	//Instant shot when transitioning
	performShot();
	
	if (curRangedWeapon.cooldown != 0) input_consume(verbs.attack);
	state = states.shooting;
}

function toAiming() {
	move.fric = move.fric;
	
	state = states.aiming;
}

function toDodging() {
	//Set dodge stats
	dodge.dur = curDodge.dur;
	dodge.spd = curDodge.spd;
	combat.iframes = curDodge.iframes;
	
	//Remove combo progress on dodge
	resetCombo();
	
	//Determine dodge direction
	var dir = getLastDir();
	dodge.dir = dir;
	move.dir = dir;
	
	//input_consume(verbs.dodge);
	state = states.dodging;
	
	//FX
	part_type_direction(global.hangingDustPart, dodge.dir - 220, dodge.dir - 140, 0, 0);
	part_type_speed(global.hangingDustPart, 1, 2, -0.01, 0);
	part_particles_create(global.ps, x, bbox_bottom, global.hangingDustPart, 10);
	
	part_type_direction(global.hangingDustPart, dodge.dir - 10, dodge.dir + 10, 0, 0);
	part_type_speed(global.hangingDustPart, 2, 3, -0.02, 0);
	
	part_type_direction(global.hangingDustPart, 0, 359, 0, 0);
	part_type_speed(global.hangingDustPart, 0.6, 0.8, -0.01, 0);
	part_particles_create(global.ps, x, bbox_bottom, global.hangingDustPart, 20);
	
	shakeCamera(4, 2, 4);
}

function toSprinting() {
	state = states.sprinting;
}

function toDead() {
	
}

function groundedMovement() {
	//Get input and input direction
	var mv = getMovementInput();
	var dir = point_direction(0, 0, mv[0], mv[1]);
	move.dir = point_direction(0, 0, move.hsp, move.vsp);

	//If left/right is held, accelerate, if not, decelerate
	if (mv[0] != 0) {
		move.hsp = approach(move.hsp, lengthdir_x(move.curMaxSpd, dir), abs(lengthdir_x(move.axl, dir)));
	} else {
		move.hsp = approach(move.hsp, 0, move.fric);
	}

	//If up/down is held, accelerate, if not, decelerate
	if (mv[1] != 0) {
		move.vsp = approach(move.vsp, lengthdir_y(move.curMaxSpd, dir), abs(lengthdir_y(move.axl, dir)));
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
	
	//Smooth transition between max speeds
	move.curMaxSpd = approach(move.curMaxSpd, move.maxSpd, move.axl);		
	
	//FX
	if (move.moving && random(1) > 0.9) {
		part_type_direction(global.hangingDustPart, move.dir - 90, move.dir + 90, 0, 0);
		part_type_speed(global.hangingDustPart, 0.1, 0.2, -0.01, 0);
		part_particles_create(global.ps, x, bbox_bottom, global.hangingDustPart, 1);
	}
	
	//Apply momentum
	x += move.hsp * delta;
	y += move.vsp * delta;
}

function sprintMovement() {
	//Smooth transition between max speeds
	move.curMaxSpd = approach(move.curMaxSpd, sprint.maxSpd, sprint.axl);
	
	//Smooth turning
	var mv = getMovementInput();
	var pd = point_direction(0, 0, mv[0], mv[1]);
	var dd = angle_difference(move.dir, pd);
	
	if (mv[0] != 0 || mv[1] != 0) {
		sprint.turnSpd = approach(sprint.turnSpd, sprint.turnMaxSpd, sprint.turnAxl);
	} else {
		//sprint.turnSpd = approach(sprint.turnSpd, 0, sprint.turnFric);
		sprint.turnSpd = 0;
	}
	
	move.dir -= min(abs(dd), sprint.turnSpd) * sign(dd);
	
	//Apply momentum
	moveInDirection(move.curMaxSpd, move.dir);
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
	ranged.burst = 0;
}

function performMelee() {
	if (!melee.htbx) {
		setAttackMovement(curMeleeWeapon.slide[melee.combo - 1]);
		var dir = melee.dir;
		
		if (curMeleeWeapon.amount[melee.combo - 1] > 1) {
			//If delay is 0, deal all strikes simultaneously
			if (curMeleeWeapon.delay[melee.combo - 1] == 0) {
				repeat(curMeleeWeapon.amount[melee.combo - 1]) {
					if (curMeleeWeapon.multiSpread[melee.combo - 1] > 0) {
						dir = melee.dir + (curMeleeWeapon.multiSpread[melee.combo - 1] / (curMeleeWeapon.amount[melee.combo - 1] - 1) * melee.strike) - curMeleeWeapon.multiSpread[melee.combo - 1] * .5;
					}
					
					spawnHitbox(curMeleeWeapon, dir);
					melee.strike++;
				}
				melee.htbx = true;
			} else {
				//If delay is over 0, spawn hitboxes in succession
				if (curMeleeWeapon.multiSpread[melee.combo - 1] > 0) {
					dir = melee.dir + (curMeleeWeapon.multiSpread[melee.combo - 1] / (curMeleeWeapon.amount[melee.combo - 1] - 1) * melee.strike) - curMeleeWeapon.multiSpread[melee.combo - 1] * .5;
				}
				
				if (melee.strike < curMeleeWeapon.amount[melee.combo - 1] && melee.dur < curMeleeWeapon.dur[melee.combo - 1] - curMeleeWeapon.delay[melee.combo - 1]) {
					spawnHitbox(curMeleeWeapon, dir);
					melee.strike++;
					melee.dur = curMeleeWeapon.dur[melee.combo - 1];
				} else if (melee.strike == curMeleeWeapon.amount[melee.combo - 1]) {
					melee.htbx = true;
				}
			}
		} else {
			spawnHitbox(curMeleeWeapon, melee.dir);
			melee.htbx = true;
		}
	}
}

function performShot() {
	//If delay is 0, it shoots multiple bullets per dur cycle
	//Bullets in burst can have multispread
	if (curRangedWeapon.delay == 0) {
		//Loop through all the bullets in the burst
		repeat (curRangedWeapon.amount) {
			var dir = getAttackDir();
			
			//If weapon has multispread, do some directional calculation for each projectile based on the multispread variable
			if (curRangedWeapon.multiSpread > 0) {
				dir += (curRangedWeapon.multiSpread / (curRangedWeapon.amount - 1) * ranged.shot) - curRangedWeapon.multiSpread * .5;
			}
		
			spawnHitbox(curRangedWeapon, dir);
			incrementShot(curRangedWeapon);
		}
		
		setAttackMovement(-curRangedWeapon.knockback * curRangedWeapon.amount);
	} else { 
		//This is where we go if we only shoot 1 bullet per frame, aka delay > 0
		//Just shoot bullet in the direction, no directional shenanigans
		var dir = getAttackDir();
		spawnHitbox(curRangedWeapon, dir);
		incrementShot(curRangedWeapon);
		setAttackMovement(-curRangedWeapon.knockback);
	}
}

function incrementCombo(meleeStruct) {
	melee.dur = meleeStruct.dur[melee.combo] - meleeStruct.delay[melee.combo];
	melee.dir = getAttackDir();
	
	//Increment combo counter
	melee.combo++;
	
	melee.queued = false;
	melee.htbx = false;
	melee.strike = 0;
			
	//Check if this was final hit of combo
	if (melee.combo >= meleeStruct.comboLength) {
		melee.comboComplete = true;
		input_consume(verbs.attack);
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
	
	//Iframes
	combat.iframes = approach(combat.iframes, 0, 1);
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
			htbx.visuals.type = weapons.melee;
			htbx.image_blend = struct.clr;
		
			//All melee weapons can cleave and persist
			htbx.atk.destroyOnStop = false;
			htbx.atk.piercing = true;
			
			//FX
			shakeCamera(curRangedWeapon.dmg * 20, 2, 4);
			pushCamera(curRangedWeapon.dmg * 150, dir);
			
			if (struct.multiSpread[melee.combo - 1] == 0) {
				var sprd = 40;
			} else {
				var sprd = struct.multiSpread[melee.combo - 1] * .5;
			}
			
			part_type_direction(global.shootPart, dir - sprd, dir + sprd, 0, 0);
			part_particles_create(global.ps, spawnX, spawnY, global.shootPart, 5);
		break;
		
		case weapons.ranged:	
			var spawnX = x + lengthdir_x(struct.reach + sprite_get_width(struct.spr), dir);
			var spawnY = y + lengthdir_y(struct.reach + sprite_get_width(struct.spr), dir);
		
			//Apply random spread
			dir += irandom_range(-struct.spread, struct.spread);
	
			//Impart weapon stats to hitbox
			var htbx = instance_create_layer(spawnX, spawnY, "Instances", struct.htbx);
			htbx.sprite_index = struct.projSpr;
			htbx.image_angle = dir;
			htbx.visuals.size = struct.size;
	
			htbx.move.hsp = lengthdir_x(struct.spd, dir);
			htbx.move.vsp = lengthdir_y(struct.spd, dir);
			htbx.move.fric = struct.fric;
	
			htbx.atk.dur = struct.life;	
			htbx.atk.dmg = struct.dmg;
			htbx.atk.knockback = struct.knockback;
			htbx.atk.piercing = struct.piercing;
			htbx.atk.destroyOnStop = struct.destroyOnStop;
			htbx.visuals.type = weapons.ranged;
			htbx.image_blend = struct.clr;
			
			//FX
			shakeCamera(curRangedWeapon.dmg * 60, 2, 4);
			pushCamera(curRangedWeapon.dmg * 50, dir + 180);
			ranged.recoil = curRangedWeapon.dmg * 10;
			
			part_particles_create(global.ps, spawnX, spawnY, global.muzzleFlashPart, 1);
			part_type_direction(global.shootPart, dir - struct.spread * 2, dir + struct.spread * 2, 0, 0);
			part_particles_create(global.ps, spawnX, spawnY, global.shootPart, 10);
		break;
	}
}

function attackMovement() {
	move.hsp = approach(move.hsp, 0, abs(lengthdir_x(move.fric, move.dir)));
	move.vsp = approach(move.vsp, 0, abs(lengthdir_y(move.fric, move.dir)));
	
	x += move.hsp * delta;
	y += move.vsp * delta;
}

function setAttackMovement(amount) {
	if (input_player_source_get(0) == INPUT_SOURCE.KEYBOARD_AND_MOUSE) {
		move.dir = point_direction(x, y, mouse_x, mouse_y);
	} else if (!isHoldingDirection()) {
		move.dir = move.lastDir;
	} else {
		move.dir = getMovementInputDirection();
	}
	
	part_particles_create(global.ps, x, bbox_bottom, global.bulletTrail, 1);
	
	move.hsp = lengthdir_x(amount, move.dir);
	move.vsp = lengthdir_y(amount, move.dir);
}

function drawAimIndicator() {
	var dir = getAttackDir();
	var drawX = x + lengthdir_x(curRangedWeapon.reach - ranged.recoil, dir);
	var drawY = y + lengthdir_y(curRangedWeapon.reach - ranged.recoil, dir);
	//if (dir < 180) { var yScale = 1; } else { var yScale = -1; }
	
	var yScale = (dir > 90 && dir < 270) ? -1 : 1;
	
	draw_sprite_ext(curRangedWeapon.spr, 0, drawX, drawY, 1, yScale, dir, c_white, 1);
}

function cameraStateSwitch() {
	if (input_check(verbs.aim)) {
		oCamera.state = cameraStates.aim;
	} else {
		oCamera.state = cameraStates.follow;
	}
}

function takeDamage(amount) {
	combat.hp -= amount;
	combat.iframes = combat.iframesMax;
	
	freeze(200);
	pushEnemies();
}

function pushEnemies() {
	with (oEnemyBase) {
		var dist = distance_to_object(oPlayer);
		
		if (dist < 128) {
			var dir = point_direction(oPlayer.x, oPlayer.y, x, y);
			var force = 4 - dist * 0.02 * combat.weight;
			
			move.hsp = lengthdir_x(force, dir);
			move.vsp = lengthdir_y(force, dir);
			move.dir = dir;
			
			toStunned(144);
		}
	}
}