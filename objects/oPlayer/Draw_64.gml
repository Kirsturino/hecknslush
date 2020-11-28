//Draw HP rectangles
var margin = 32;
var size = 8;
var space = 32;
var c = c_red;

for (var i = 0; i < combat.hp; ++i)
{
    draw_rectangle_color(margin + i * space - size, margin - size, margin + i * space + size, margin + size, c, c, c, c, false);
}