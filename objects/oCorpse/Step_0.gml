//Simple movement
move.hsp = approach(move.hsp, 0, abs(lengthdir_x(move.fric, move.dir)));
move.vsp = approach(move.vsp, 0, abs(lengthdir_y(move.fric, move.dir)));

x += move.hsp * delta;
y += move.vsp * delta;

depthSorting();