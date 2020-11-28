//Movement
var dir = point_direction(x, y, oPlayer.x, oPlayer.y);

move.hsp = approach(move.hsp, lengthdir_x(move.spd, dir), move.axl);
move.vsp = approach(move.vsp, lengthdir_y(move.spd, dir), move.axl);
	
x += move.hsp * delta;
y += move.vsp * delta;

//Get collected
if (place_meeting(x, y, oPlayer))
{
	global.currencyAmount++;
	instance_destroy();
}

//FX
part_particles_create(global.ps, x, y, global.currencyTrail, 1);