//Debug
var margin = 8;
var space = 16;

scribble_draw(margin, margin, "FPS: " + string(fps));
scribble_draw(margin, margin + space, "DELTA MULTIPLIER: " + string(delta));
scribble_draw(margin, margin + space * 2, "DELTA: " + string(delta_time));