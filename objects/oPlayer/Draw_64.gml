//Draw HP rectangles
var margin = 16;
var size = 8;
var space = 32;
var c = c_red;
var thicc = 1;

draw_line_width_color(-1, margin*2, margin + combat.maxHP * space-space/2+thicc/2, margin*2, size*4+thicc, c_white, c_white);
draw_line_width_color(-1, margin*2, margin + combat.maxHP * space-space/2, margin*2, size*4, c_black, c_black);

c = c_white;
for (var i = 0; i < combat.maxHP; ++i)
{
	draw_rectangle_color(margin + i * space - size-2, margin*2 - size-2, margin + i * space + size+2, margin*2 + size+2, c, c, c, c, true);
}

c = c_red;
for (var i = 0; i < combat.hp; ++i)
{
    draw_rectangle_color(margin + i * space - size, margin*2 - size, margin + i * space + size, margin*2 + size, c, c, c, c, false);
}

//Draw ability indicators