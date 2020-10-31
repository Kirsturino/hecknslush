//This is where we do the infinite particle stuff
global.ps = part_system_create();

global.bulletTrail = part_type_create();
var p = global.bulletTrail;
part_type_shape(p, pt_shape_disk);
part_type_life(p, 30, 60);
part_type_size(p, 0.1, 0.2, -0.01, 0);
part_type_orientation(p, 0, 0, 0, 0, true);

global.hitPart = part_type_create();
var p = global.hitPart;
part_type_shape(p, pt_shape_disk);
part_type_life(p, 30, 60);
part_type_size(p, 0.1, 0.2, -0.01, 0);
part_type_direction(p, 0, 359, 0, 0);
part_type_orientation(p, 0, 0, 0, 0, true);
part_type_speed(p, 1, 2, -0.01, 0);