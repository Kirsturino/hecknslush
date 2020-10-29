//Simple movement
move.hsp = approach(move.hsp, 0, move.fric);
move.vsp = approach(move.vsp, 0, move.fric);

x += move.hsp * delta;
y += move.vsp * delta;


visual.flash = approach(visual.flash, 0, 1);
depthSorting();