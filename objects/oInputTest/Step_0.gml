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