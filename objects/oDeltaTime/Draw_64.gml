if (!global.debugDelta) exit;

//Debug
var margin = 8;
var space = 16;

scribble_set_starting_format("fntDebug", c_white, fa_left);
scribble_draw(margin, margin, "FPS: " + string(fps));
scribble_draw(margin, margin + space, "DELTA MULTIPLIER: " + string(delta));
scribble_draw(margin, margin + space * 2, "DELTA: " + string(delta_time));
scribble_draw(margin, margin + space * 3, "TIMESCALE: " + string(global.timeScale));