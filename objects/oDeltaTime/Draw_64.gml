//Debug
var margin = 8;
var space = 16;

if (!global.debugDelta) exit;

scribble_set_starting_format("fntDebug", c_white, fa_left);
scribble_draw(margin, margin, "FPS: " + string(fps));
scribble_draw(margin, margin + space, "DELTA MULTIPLIER: " + string(delta));
scribble_draw(margin, margin + space * 2, "DELTA: " + string(delta_time));