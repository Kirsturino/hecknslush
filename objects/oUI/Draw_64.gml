var UI = self.id;

//Draw player UI
with (oPlayer)
{
	var margin = 8;
	var size = 8;
	var space = 32;
	var c = c_white;
	var thicc = 8;
	var tilt = 1;
	var barYOffset = combat.maxHP * 0.02;

	//Draw HP bars
	var txt = string(combat.hp) + "/" + string(combat.maxHP);
	var txtLength = string_width(txt);
	
	//Calculate the more visual chunk part of the hp bar
	if (UI.hpBar.delay == 0)
	{
		UI.hpBar.chunkLength = lerp(UI.hpBar.chunkLength, combat.hp, 0.05);
	} else
	{
		UI.hpBar.delay = approach(UI.hpBar.delay, 0, 1);
	}

	draw_sprite_ext(sPixel, 0, 0, margin-thicc/4 + barYOffset, combat.maxHP + txtLength*2 + margin, thicc*2, tilt, c, 1);
	c = c_black;
	draw_sprite_ext(sPixel, 0, margin + thicc/4, margin+thicc/2 + barYOffset, combat.maxHP + thicc/4, thicc, tilt, c, 1);
	c = c_orange;
	draw_sprite_ext(sPixel, 0, margin, margin + barYOffset, UI.hpBar.chunkLength, thicc, tilt, c, 1);
	c = c_red;
	draw_sprite_ext(sPixel, 0, margin, margin + barYOffset, combat.hp, thicc, tilt, c, 1);

	var drawX = margin + lengthdir_x(combat.maxHP + txtLength, tilt);
	var drawY = margin + lengthdir_y(combat.maxHP + txtLength, tilt) - 2  + barYOffset;

	scribble_set_blend(c_black, 1);
	scribble_draw(drawX, drawY, txt);

	//Draw ability indicators
	margin = 20;
	tilt = -2;
	
	draw_sprite_ext(sPixel, 0, -space, viewHeight - margin*2, space * 5.5, space * 2, tilt*2, c_white, 1);
	
	for (var i = 0; i < abilityAmount; ++i)
	{
		c = c_black;
		draw_rectangle_color(margin + i * space - size-2, viewHeight - margin - size-2 - tilt*i, margin + i * space + size+2, viewHeight - margin + size+2 - tilt*i, c, c, c, c, false);
	
		c = c_red;
		var rectBottom = viewHeight - margin + size;
		var rectFill = size*2;
		if (attackSlots[i].cooldown != 0) rectFill *= (1 - attack[i].cooldown / attackSlots[i].cooldown);
	
		//Some extra stuff to indicate ability is fully charged
		if (attack[i].cooldown != 0) c = merge_color(c_red, c_orange, wave(0, 1, 1, 0, true));
	
		draw_rectangle_color(margin + i * space - size, rectBottom - rectFill - tilt*i, margin + i * space + size, rectBottom - tilt*i, c, c, c, c, false);
	}
}

#region Draw currency
var margin = 16;
var xOffset = string_width(string(global.currencyAmount));
draw_sprite_ext(sPixel, 0, viewWidth - xOffset - margin*4, viewHeight, 100 + xOffset, 100, 25, c_white, 1);

scribble_set_blend(c_black, 1);
scribble_draw(viewWidth - xOffset, viewHeight - margin, string(global.currencyAmount));
#endregion

notification.drawFunction();