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
for (var i = 0; i < abilityAmount; ++i)
{
	c = c_white;
	draw_rectangle_color(margin + i * space - size-2, viewHeight - margin*2 - size-2, margin + i * space + size+2, viewHeight - margin*2 + size+2, c, c, c, c, true);
	
	c = c_red;
	var rectBottom = viewHeight - margin*2 + size;
	var rectFill = size*2;
	if (attackSlots[i].cooldown != 0) rectFill *= (1 - attack[i].cooldown / attackSlots[i].cooldown);
	
	//Some extra stuff to indicate ability is fully charged
	if (attack[i].cooldown != 0) c = merge_color(c_red, c_white, wave(0, 1, 1, 0, true));
	
	draw_rectangle_color(margin + i * space - size, rectBottom - rectFill, margin + i * space + size, rectBottom, c, c, c, c, false);
}