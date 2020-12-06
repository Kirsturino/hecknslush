#region INIT

#region INPUTS

//Init input source
input_player_source_set(INPUT_SOURCE.KEYBOARD_AND_MOUSE);

//Init verbs
enum verbs {
	right,
	left,
	down,
	up,
	attack,
	attack2,
	dodge,
	aim
}

//Bind default keys
input_default_key(ord("A"), verbs.left);
input_default_key(ord("D"), verbs.right);
input_default_key(ord("W"), verbs.up);
input_default_key(ord("S"), verbs.down);
input_default_key(vk_space, verbs.dodge);
input_default_mouse_button(mb_left, verbs.attack, true);
input_default_mouse_button(mb_middle, verbs.attack2, true);
input_default_mouse_button(mb_right, verbs.aim, true);

#macro ATTACK_BUFFER 200
#macro DODGE_BUFFER 200

//Input jank
input_consume(verbs.attack);
input_consume(verbs.dodge);

#endregion

#region PLAYER STATES
//Set player state jank :)
state = nothing;
DoLater(1, function(data) {state = playerGrounded;},0,true);
drawFunction = nothing;
DoLater(1, function(data) {drawFunction = nothing;},0,true);

//Circular buffer for states, normalize size for different target framerates
//This will be used to add some leniency to combos and various actions
var buffSize = round(game_get_speed(gamespeed_fps) / 5);
stateBuffer = array_create(buffSize, 0);
stateBufferSize = buffSize;
stateBufferPointer = 0;

#endregion

#region MOVEMENT

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
	moving : false,
	collMask : sPlayerWallCollisionMask,
	aimSpeedModifier : 0.5
}

//Set mask
sprite_index = move.collMask;

//Sprinting variables
sprint = {
	maxSpd : 2,
	axl : 0.05,
	turnSpd : 0,
	turnAxl : 0.2,
	turnMaxSpd : 2,
	buildup : 0,
	buildupMax : 60
}

#endregion

#region COMBAT

//Combat variables
combat = {
	maxHP : 5,
	hp : 5,
	iframesMax : 144,
	iframes : 0,
	aimDir : 0,
	curAttack : 0,
	stunnable : false,
}

//This will be used a lot so here's a lil' shorthand
#macro ATK combat.curAttack

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

#endregion

#region ABILITIES

//Create generic attack structs for each of your abilities
//THIS IS WIP and some stuff is hardcoded atm
abilityAmount = 4;
for (var i = 0; i < abilityAmount; ++i) { attack[i] = new attackStruct(); }

attackSlots = array_create(abilityAmount, 0);

//Testing weapon struct idea. Data from a list of weapons would be pulled here to be used locally
attackSlots[0] = new basicSlash();

attackSlots[1] = new spinSlash();	

attackSlots[2] = new burstBlaster();
	
attackSlots[3] = new doubleWave();
	
	
#endregion

#region MISC. VARIABLES

//Variables that don't directly affect gameplay
visuals = {
	curSprite : sPlayer,
	xScale : 1,
	yScale : 1,
	rot : 0,
	recoil : 0,
	frm : 0,
	spd : 1,
}

#endregion

#endregion


#region FUNCTIONS

#region ACTIVE STATES

function playerGrounded() {
	groundedMovement();
	
	//State switches
	if (dodge.cooldown == 0 && input_check_press(verbs.dodge, 0, DODGE_BUFFER)) toDodging();
	else if (attack[0].cooldown == 0 && input_check_press(verbs.attack, 0, ATTACK_BUFFER)) { ATK = 0; toAttacking(); }
	else if (attack[1].cooldown == 0 && input_check_press(verbs.attack2, 0, ATTACK_BUFFER)) { ATK = 1; toAttacking(); }
	else if (input_check(verbs.aim)) { toAiming(); }
	
	//Player can sprint by holding dodge button for long enough
	if (input_check(verbs.dodge)) {
		sprint.buildup = approach(sprint.buildup, sprint.buildupMax, 1);
		
		if (sprint.buildup == sprint.buildupMax) {
			move.dir = move.lastDir;
			toSprinting();
		}
	} else { sprint.buildup = 0; }
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
	if (attack[0].cooldown == 0 && input_check_press(verbs.attack, 0, ATTACK_BUFFER))
	{
		sprint.buildup = 0;
		move.lastDir = move.dir;
		ATK = 0;
		toAttacking();
	} else if (attack[1].cooldown == 0 && input_check_press(verbs.attack2, 0, ATTACK_BUFFER))
	{
		sprint.buildup = 0;
		move.lastDir = move.dir;
		ATK = 1;
		toAttacking();
	}

	
	if (input_check(verbs.aim)) {
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

function playerAttacking() {
	combat.aimDir = getAttackDir();
	attack[ATK].dur = approach(attack[ATK].dur, 0, 1);
	
	attackLogic(attackSlots[ATK], attack[ATK]);

	attackMovement();
	
	//visuals
	visuals.recoil = lerp(visuals.recoil, 0, 0.1);
	
	//State switch
	if (attack[ATK].dur <= 0)
	{
		attack[ATK].cooldown = attackSlots[ATK].cooldown;
		resetAttack(attackSlots[ATK], attack[ATK]);
		
		if (input_check(verbs.aim)) { toAiming(); }
		else						{ toGrounded(); }	
	}
	
	//Make player be able to break out of attack at will
	if (dodge.cooldown == 0 && input_check_press(verbs.dodge, 0, DODGE_BUFFER)) {
		attack[ATK].cooldown = attackSlots[ATK].cooldown;
		resetAttack(attackSlots[ATK], attack[ATK]);
		toDodging();
	}
}

function playerAiming() {	
	groundedMovement();
	
	combat.aimDir = getAttackDir();
	
	//State switch
	if (input_check_release(verbs.aim)) { toGrounded(); }
	else if (dodge.cooldown == 0 && input_check_press(verbs.dodge, 0, DODGE_BUFFER)) { toDodging(); } 
	else if (attack[2].cooldown == 0 && input_check_press(verbs.attack, 0, ATTACK_BUFFER)) { ATK = 2; toAttacking(); }
	else if (attack[3].cooldown == 0 && input_check_press(verbs.attack2, 0, ATTACK_BUFFER)) { ATK = 3; toAttacking(); }
}

function playerDodging() {
	dodge.dur = approach(dodge.dur, 0, 1);
	
	dodgeMovement();
	
	//State switches
	if (dodge.dur <= 0) {
		move.hsp = lengthdir_x(move.curMaxSpd, dodge.dir);
		move.vsp = lengthdir_y(move.curMaxSpd, dodge.dir);
		dodge.cooldown = curDodge.cooldown;
		
		if (input_check(verbs.aim)) { toAiming(); }
		else						{ toGrounded(); }
	}
	
	//FX
	var offset = sprite_height / 2;
	part_type_direction(global.hangingDustPart, dodge.dir - 20, dodge.dir + 20 , 0, 0);
	part_type_speed(global.hangingDustPart, 2, 3, -0.01, 0);
	if (random(1) > 0.7) part_particles_create(global.ps, x, bbox_bottom - offset, global.hangingDustPart, 1);
	
	part_particles_create(global.ps, x, bbox_bottom - offset, global.bulletTrail, 1);
	part_particles_create(global.ps, x, y - offset, global.dodgePart, 1);
	
	part_type_direction(global.hangingDustPart, dodge.dir - 90, dodge.dir + 90, 0, 0);
	part_type_speed(global.hangingDustPart, 0.1, 0.2, -0.01, 0);
	part_particles_create(global.ps, x, bbox_bottom - offset, global.hangingDustPart, 1);
}
	
#endregion

#region STATE CHANGES

function toDummy() {
	state = playerDummy;
	drawFunction = nothing;
}

function toGrounded() {
	move.curMaxSpd = move.maxSpd;
	state = playerGrounded;
	drawFunction = nothing;
}
	
function toAttacking() {	
	//Instant attack when transitioning
	attack[ATK].dir = getAttackDir();
	performAttack(attackSlots[ATK], attack[ATK]);
	
	input_consume(verbs.attack);
	state = playerAttacking;
}

function toAiming() {
	state = playerAiming;
	drawFunction = drawAimIndicator;
}

function toDodging() {
	//Set dodge stats
	dodge.dur = curDodge.dur;
	dodge.spd = curDodge.spd;
	combat.iframes = curDodge.iframes;
	
	//Determine dodge direction
	var dir = getLastDir();
	dodge.dir = dir;
	move.dir = dir;
	
	state = playerDodging;
	drawFunction = nothing;
	
	//FX
	part_type_direction(global.hangingDustPart, dodge.dir - 220, dodge.dir - 140, 0, 0);
	part_type_speed(global.hangingDustPart, 1, 2, -0.01, 0);
	part_particles_create(global.ps, x, bbox_bottom, global.hangingDustPart, 10);
	
	part_type_direction(global.hangingDustPart, dodge.dir - 10, dodge.dir + 10, 0, 0);
	part_type_speed(global.hangingDustPart, 2, 3, -0.02, 0);
	
	part_type_direction(global.hangingDustPart, 0, 359, 0, 0);
	part_type_speed(global.hangingDustPart, 0.6, 0.8, -0.01, 0);
	part_particles_create(global.ps, x, bbox_bottom, global.hangingDustPart, 20);
	
	shakeCamera(4, 0, 4);
}

function toSprinting() {
	state = playerSprinting;
	drawFunction = nothing;
}

function toDead() {
	//Add stuff here eventually
	drawFunction = nothing;
}
	
#endregion

#region MOVEMENT

function groundedMovement() {
	//Get input and input direction
	var mv = getMovementInput();
	var dir = point_direction(0, 0, mv[0], mv[1]);
	move.dir = point_direction(0, 0, move.hsp, move.vsp);

	//If left/right is held, accelerate, if not, decelerate
	if (mv[0] != 0)
	{
		move.hsp = approach(move.hsp, lengthdir_x(move.curMaxSpd, dir), abs(lengthdir_x(move.axl, dir)));
	} else
	{
		move.hsp = approach(move.hsp, 0, move.fric);
	}
	
	horizontalCollision();

	//If up/down is held, accelerate, if not, decelerate
	if (mv[1] != 0)
	{
		move.vsp = approach(move.vsp, lengthdir_y(move.curMaxSpd, dir), abs(lengthdir_y(move.axl, dir)));
	} else
	{
		move.vsp = approach(move.vsp, 0, move.fric);
	}
	
	verticalCollision();
	
	//Set last direction player was going
	if (mv[0] != 0 || mv[1] != 0)
	{
		move.lastDir = dir;
		move.moving = true;
	} else
	{
		move.moving = false;
	}
	
	//Smooth transition between max speeds
	if (state == playerAiming)
	{
		var aimSpd = move.maxSpd * move.aimSpeedModifier;
		move.curMaxSpd = approach(move.curMaxSpd, aimSpd, move.axl);
	} else
	{
		move.curMaxSpd = approach(move.curMaxSpd, move.maxSpd, move.axl);	
	}
	
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
	move.hsp = lengthdir_x(move.curMaxSpd, move.dir);
	horizontalCollision();
	
	move.vsp = lengthdir_y(move.curMaxSpd, move.dir);
	verticalCollision();
	
	x += move.hsp * delta;
	y += move.vsp * delta;
}

function dodgeMovement() {
	move.hsp = lengthdir_x(dodge.spd, dodge.dir);
	horizontalCollision();
	
	move.vsp = lengthdir_y(dodge.spd, dodge.dir);
	verticalCollision();
	
	x += move.hsp * delta;
	y += move.vsp * delta;
}
	
#endregion

#region TOOL FUNCTIONS

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
	
#endregion

#region MISC. FUNCTIONS

function incrementVerbCooldowns() {
	//Short pause after doing verbs
	
	var length = array_length(attack);
	for (var i = 0; i < length; ++i) {
	    if (attackSlots[i].cooldownType == recharge.time) attack[i].cooldown = approach(attack[i].cooldown, 0, 1);
	}
	
	dodge.cooldown = approach(dodge.cooldown, 0, 1);
	
	//Iframes
	combat.iframes = approach(combat.iframes, 0, 1);
}

function drawAimIndicator() {
	//Third ability will determine gun visuals
	var wpn = attackSlots[2];
	var atk = attack[ATK];
	
	if (state == playerAiming) 
	{
		var dir = getAttackDir();
		
	} else if (wpn.aimable)
	{
		var dir = point_direction(x, y, mouse_x, mouse_y);
	} else if (state == playerAttacking && wpn.type == weapons.ranged && wpn.delay != 0 && wpn.multiSpread == 0 && wpn.spread == 0)
	{
		var dir = atk.htbxDir;
		if (atk.count != wpn.amount) dir += random_range(-wpn.spread, wpn.spread) * 0.2;
		
	} else if (state == playerAttacking && wpn.type == weapons.ranged)
	{
		var dir = atk.dir;
		if (atk.count != wpn.amount) dir += random_range(-wpn.spread, wpn.spread) * 0.2;
	}
	
	var offset = sprite_height / 2;
	var drawX = x + lengthdir_x(wpn.reach - visuals.recoil, dir);
	var drawY = y + lengthdir_y(wpn.reach - visuals.recoil, dir) - offset;
	
	var yScale = (dir > 90 && dir < 270) ? -1 : 1;
	
	//Currently hardcoded to always hold this slot's specific gun sprite due to ambiquity when aiming
	draw_sprite_ext(attackSlots[2].spr, 0, drawX, drawY, 1, yScale, dir, c_white, 1);
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
		
	if (combat.hp <= 0) toDead();
}

function pushEnemies() {
	with (oEnemyBase) {
		var dist = distance_to_object(oPlayer);
		
		if (dist < 128) {
			var dir = point_direction(oPlayer.x, oPlayer.y, x, y);
			var force = 3 - dist * 0.02 * combat.weight;
			
			move.hsp = lengthdir_x(force, dir);
			move.vsp = lengthdir_y(force, dir);
			move.dir = dir;
			
			toStunned(144);
		}
	}
}

#endregion

#endregion