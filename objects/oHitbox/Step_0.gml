//Simple movement
move.hsp = approach(move.hsp, 0, abs(lengthdir_x(move.fric, move.dir)));
move.vsp = approach(move.vsp, 0, abs(lengthdir_y(move.fric, move.dir)));
move.dir = point_direction(0, 0, move.hsp, move.vsp);

if (atk.destroyOnStop && move.hsp == 0 && move.vsp == 0) destroySelf();
if (atk.destroyOnCollision && place_meeting(x, y, parCollision)) destroySelf();

x += move.hsp * delta;
y += move.vsp * delta;

//Hitbox only becomes active when delay is over
atk.delay = approach(atk.delay, 0, 1);

if (atk.delay == 0) {
	if (atk.piercing) {
		getTouchingObjects(atk.damagedEnemies, atk.target, dealDamage);
	} else {
		var enemy = instance_place(x, y, atk.target);
		if (enemy != noone) {
			dealDamage(enemy);
		}
	}
}

depthSorting();

//See if boi needs to be destroyed
atk.dur = approach(atk.dur, 0, 1);
if (atk.dur <= 0) destroySelf();

//Animation
visuals.frm = approach(visuals.frm, image_number - 1, visuals.animSpd);
image_index = floor(visuals.frm);

if (atk.destroyOnStop) {
	var size = (abs(move.hsp) + abs(move.vsp))/4;
	image_xscale = size;
}

//Particles
if (visuals.type = weapons.ranged) {
	part_type_direction(global.bulletTrail, move.dir - 10, move.dir + 10, 0, 0);
	part_particles_create(global.ps, x, y, global.bulletTrail, 1);
}