//Init input source
input_player_source_set(INPUT_SOURCE.KEYBOARD_AND_MOUSE);

//Init verbs
enum verb {
	right,
	left,
	down,
	up
}

//Bind default keys
input_default_key(ord("A"), verb.left);
input_default_key(ord("D"), verb.right);
input_default_key(ord("W"), verb.up);
input_default_key(ord("S"), verb.down);

//Init states
enum states {
	grounded,
	dummy,
	dashing,
	attacking,
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

function playerGrounded() {
	groundedMovement();
}

function playerDummy() {
	//Do nothing, lol
}

function toDummy() {
	state = states.dummy;
}

function toGrounded() {
	state = states.grounded;
}

function groundedMovement() {
	//Basic movement & input
	var hMove = input_check(verb.right) - input_check(verb.left);
	var vMove = input_check(verb.down) - input_check(verb.up);

	if (hMove != 0) {
		move.hsp = approach(move.hsp, move.maxSpd * hMove, move.axl * delta);
	} else {
		move.hsp = approach(move.hsp, 0, move.fric * delta);
	}

	if (vMove != 0) {
		move.vsp = approach(move.vsp, move.maxSpd * vMove, move.axl * delta);
	} else {
		move.vsp = approach(move.vsp, 0, move.fric * delta);
	}
	
	x += move.hsp * delta;
	y += move.vsp * delta;
}