//See if boi needs to be destroyed
dur = approach(dur, 0, 1);
if (dur <= 0) instance_destroy();

//Movement
move.hsp = approach(move.hsp, 0, move.fric);
move.vsp = approach(move.vsp, 0, move.fric);

x += move.hsp * delta;
y += move.vsp * delta;