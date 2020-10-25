//Init input source
input_player_source_set(INPUT_SOURCE.KEYBOARD_AND_MOUSE);

//Init verbs
enum verb
{
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

//Movement variables and player properties
move = {
	hsp : 0,
	vsp : 0,
	maxSpd : 1,
	axl : 0.4,
	fric : 0.05
}