//Simple movement
move.hsp = approach(move.hsp, 0, move.fric);
move.vsp = approach(move.vsp, 0, move.fric);
move.dir = point_direction(0, 0, move.hsp, move.vsp);

if (destroyOnStop && move.hsp == 0 && move.vsp == 0) destroySelf();

x += move.hsp * delta;
y += move.vsp * delta;

if (piercing) {
	getTouchingObjects(atk.damagedEnemies, oEnemyBase, dealDamage);
} else {
	var enemy = instance_place(x, y, oEnemyBase);
	if (enemy != noone) {
		dealDamage(enemy);
		destroySelf();
	}
}

depthSorting();

//See if boi needs to be destroyed
atk.dur = approach(atk.dur, 0, 1);
if (atk.dur <= 0) destroySelf();