//This is where we do the infinite particle stuff
global.ps = part_system_create();

global.bulletTrail = part_type_create();
var p = global.bulletTrail;
part_type_shape(p, pt_shape_disk);
part_type_life(p, 30, 60);
part_type_size(p, 0.1, 0.2, -0.01, 0);
part_type_orientation(p, 0, 0, 0, 0, true);

global.shootPart = part_type_create();
var p = global.shootPart;
part_type_shape(p, pt_shape_disk);
part_type_life(p, 60, 80);
part_type_size(p, 0.1, 0.2, -0.005, 0);
part_type_speed(p, 2, 4, -0.05, 0);
part_type_gravity(p, 0.05, 90);
part_type_orientation(p, 0, 0, 0, 0, true);

global.muzzleFlashPart = part_type_create();
var p = global.muzzleFlashPart;
part_type_shape(p, pt_shape_disk);
part_type_life(p, 4, 4);
part_type_size(p, 0.3, 0.4, 0, 0);
part_type_orientation(p, 0, 0, 0, 0, true);

global.hitPart = part_type_create();
var p = global.hitPart;
part_type_shape(p, pt_shape_disk);
part_type_life(p, 20, 40);
part_type_size(p, 0.1, 0.2, -0.01, 0);
part_type_direction(p, 0, 359, 0, 0);
part_type_orientation(p, 0, 0, 0, 0, true);
part_type_speed(p, 6, 8, -0.5, 0);

global.hitPart2 = part_type_create();
var p = global.hitPart2;
part_type_shape(p, pt_shape_disk);
part_type_scale(p, 1, 0.05);
part_type_life(p, 10, 20);
part_type_size(p, 2, 2, -0.2, 0);
part_type_direction(p, 0, 359, 0, 0);
part_type_orientation(p, 0, 359, 0, 0, true);

global.hangingDustPart = part_type_create();
var p = global.hangingDustPart;
part_type_shape(p, pt_shape_disk);
part_type_life(p, 180, 360);
part_type_size(p, 0.05, 0.1, -0.0005, 0);
part_type_speed(p, 2, 3, -0.02, 0);
part_type_orientation(p, 0, 0, 0, 0, true);
part_type_gravity(p, 0.01, 90);