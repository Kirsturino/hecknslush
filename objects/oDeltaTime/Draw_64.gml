//Debug
var margin = 16;
var space = 16;

draw_text(margin, margin, "FPS: " + string(fps));
draw_text(margin, margin + space, "DELTA MULTIPLIER: " + string(delta));
draw_text(margin, margin + space * 2, "DELTA: " + string(delta_time));