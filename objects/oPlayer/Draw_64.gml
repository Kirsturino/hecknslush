if (state == playerDummy) exit;

//Draw HP rectangles
var margin = 8;
var size = 8;
var space = 32;
var c = c_white;
var thicc = 8;
var tilt = 1;
var hpMultiplier = 20;

#region
//draw_line_width_color(-1, margin, margin + combat.maxHP * space-space/2+thicc/2, margin, size*4+thicc, c_white, c_white);
//draw_line_width_color(-1, margin, margin + combat.maxHP * space-space/2, margin, size*4, c_black, c_black);

//c = c_white;
//for (var i = 0; i < combat.maxHP; ++i)
//{
//	draw_rectangle_color(margin + i * space - size-2, margin - size-2, margin + i * space + size+2, margin + size+2, c, c, c, c, true);
//}

//c = c_red;
//for (var i = 0; i < combat.hp; ++i)
//{
//    draw_rectangle_color(margin + i * space - size, margin - size, margin + i * space + size, margin + size, c, c, c, c, false);
//}
#endregion

//Draw HP bar
var txt = string(ceil(combat.hp * 10)) + "/" + string(ceil(combat.maxHP * 10));
var txtLength = string_width(txt);

draw_sprite_ext(sPixel, 0, 0, margin-thicc/4, combat.maxHP * hpMultiplier + txtLength*2 + margin, thicc*2, tilt, c, 1);
c = c_black;
draw_sprite_ext(sPixel, 0, margin + thicc/4, margin+thicc/2, combat.maxHP * hpMultiplier + thicc/4, thicc, tilt, c, 1);
c = c_red;
draw_sprite_ext(sPixel, 0, margin, margin, combat.hp * hpMultiplier, thicc, tilt, c, 1);

var drawX = margin + lengthdir_x(combat.maxHP * hpMultiplier + txtLength, tilt);
var drawY = margin + lengthdir_y(combat.maxHP * hpMultiplier + txtLength, tilt) - 2;

scribble_set_blend(c_black, 1);
scribble_draw(drawX, drawY, txt);

//Draw ability indicators
var margin = 32;
for (var i = 0; i < abilityAmount; ++i)
{
	c = c_white;
	draw_rectangle_color(margin + i * space - size-2, viewHeight - margin - size-2, margin + i * space + size+2, viewHeight - margin + size+2, c, c, c, c, true);
	
	c = c_red;
	var rectBottom = viewHeight - margin + size;
	var rectFill = size*2;
	if (attackSlots[i].cooldown != 0) rectFill *= (1 - attack[i].cooldown / attackSlots[i].cooldown);
	
	//Some extra stuff to indicate ability is fully charged
	if (attack[i].cooldown != 0) c = merge_color(c_red, c_white, wave(0, 1, 1, 0, true));
	
	draw_rectangle_color(margin + i * space - size, rectBottom - rectFill, margin + i * space + size, rectBottom, c, c, c, c, false);
}