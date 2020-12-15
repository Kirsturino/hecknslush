var UI = self.id;

//Draw player UI
with (oPlayer)
{
	draw_set_font(fntScribble);
	draw_set_halign(fa_center);

	var margin = 8;
	var space = 32;
	var c = col.white;
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
	c = col.black;
	draw_sprite_ext(sPixel, 0, margin + thicc/4, margin+thicc/2 + barYOffset, combat.maxHP + thicc/4, thicc, tilt, c, 1);
	c = col.tan;
	draw_sprite_ext(sPixel, 0, margin, margin + barYOffset, UI.hpBar.chunkLength, thicc, tilt, c, 1);
	c = col.red;
	draw_sprite_ext(sPixel, 0, margin, margin + barYOffset, combat.hp, thicc, tilt, c, 1);

	var drawX = margin + lengthdir_x(combat.maxHP + txtLength, tilt);
	var drawY = margin + lengthdir_y(combat.maxHP + txtLength, tilt) - 2  + barYOffset;

	c = col.black;
	draw_text_color(drawX, drawY, txt, c, c, c, c, 1);

	//Draw ability indicators
	margin = 20;
	space = 32;
	tilt = -2;
	var size = 16;
	var abilityOffset = 2;
	
	//Backdrop white rectangle
	draw_sprite_ext(sPixel, 0, -space, viewHeight - margin*2, space * 5.5, space * 2, tilt*2, col.white, 1);
	
	for (var i = 0; i < abilityAmount; ++i)
	{
		margin = 8;
		var xx = margin + i*space;
		margin = 10;
		var yy = viewHeight - margin - i*tilt;
		
		//Background black rectangles
		c = col.black;
		draw_sprite_ext(sPixel, 0, xx + abilityOffset, yy + abilityOffset, size, -size, -tilt, c, 1);
	
		//Some extra stuff to indicate ability is fully charged
		c = global.abilityColors[attackSlots[i].type];
		if (attack[i].cooldown != 0) c = merge_color(global.abilityColors[attackSlots[i].type], col.tan, wave(0, 1, 1, 0, true));

		//Ability rectangles
		var yScale = size *  (1 - attack[i].cooldown / attackSlots[i].cooldown);
		if (attackSlots[i].cooldown == 0) yScale = size;
		draw_sprite_ext(sPixel, 0, xx - abilityOffset, yy - abilityOffset, size, -yScale, -tilt, c, 1);
	}
}

#region Draw currency counter WIP
var margin = 16;
var xOffset = string_width(string(global.currencyAmount));
draw_sprite_ext(sPixel, 0, viewWidth - xOffset - margin*4, viewHeight, 100 + xOffset, 100, 25, col.white, 1);

c = col.black;
draw_text_color(viewWidth - xOffset, viewHeight - margin, string(global.currencyAmount), c, c, c, c, 1);
#endregion

notification.drawFunction();