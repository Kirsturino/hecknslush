if (state != applying) exit;

//Draw background
draw_sprite_ext(sPixel, 0, 0, 0, viewWidth, viewHeight, 0, c_black, 0.9);

scribble_set_blend(c_white, 1);

//Draw upgrade name and description
var drawX = viewWidth/2;
var drawY = viewHeight - viewHeight/8*7;
scribble_draw(drawX, drawY, upgrade.name);

drawY = viewHeight - viewHeight/4*3;
scribble_draw(drawX, drawY, upgrade.desc);

//Draw upgrade selection UI
var amount = oPlayer.abilityAmount;
for (var i = 0; i < amount; ++i)
{
	var originX = viewWidth/2;
	var originY = viewHeight - viewHeight/3;
	var space = 128;
	var radius = 32;
	var startX = originX - (amount-1)*space/2;
	var drawX = startX + i*space;
	var drawY = originY + wave(-8, 8, 4, i, true);
	if (oPlayer.attackSlots[i].type == weapons.melee)		{ var c = c_red; }
	else if (oPlayer.attackSlots[i].type == weapons.ranged) { var c = c_aqua; }
	else													{ var c = c_purple; }
	
	//Draw ability sprites
    draw_sprite(oPlayer.attackSlots[i].abilitySpr, 0, drawX, drawY);
	draw_sprite_ext(sAbilityBorder, 0, drawX, drawY, 1, 1, 0, c, 1);
	
	//Draw ability names
	var yOffset = radius * 1.5;
	drawY += yOffset;
	var txt = oPlayer.attackSlots[i].name;
	scribble_draw(drawX, drawY, txt);
	
	//Draw upgrade amounts
	txt =	string(oPlayer.attackSlots[i].upgradeCount) + "/" +
			string(oPlayer.attackSlots[i].maxUpgradeCount);
	drawY += yOffset/2;
	scribble_draw(drawX, drawY, txt);
	
}

//Draw selection indicator
yOffset = radius * 2;
drawX = startX + selected*space;
drawY = originY + wave(-8, 8, 4, selected, true) - yOffset;
selectX = lerp(selectX, drawX, 0.1);
selectY = lerp(selectY, drawY, 0.02);
if (upgrade.type == weapons.melee)			{ c = c_red; }
else if (upgrade.type == weapons.ranged)	{ c = c_aqua; }
else										{ var c = c_purple; }
	
draw_sprite_ext(sSelect, 0, selectX, selectY, wave(-1, 1, 2, 0, true), 1, 0, c, 1);