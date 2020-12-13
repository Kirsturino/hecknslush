if (state != applying) exit;

//Draw background
draw_sprite_ext(sPixel, 0, 0, 0, viewWidth, viewHeight, 0, col.black, 0.9);

scribble_set_blend(col.white, 1);


//Draw upgrade name and description
var drawX = viewWidth/2;
var drawY = viewHeight/8*1;
scribble_set_wrap(viewWidth, viewHeight, false);
scribble_draw(drawX, drawY, "[fntUpgradeTitle]" + upgrade.name);

drawY = viewHeight/8*2;
scribble_set_wrap(viewWidth/2, viewHeight, false);
scribble_draw(drawX, drawY, upgrade.desc, "desc");

//Draw upgrade selection UI
var amount = oPlayer.abilityAmount;
for (var i = 0; i < amount; ++i)
{
	var originX = viewWidth/2;
	var originY = viewHeight/16*11;
	var space = 128;
	var radius = 32;
	var startX = originX - (amount-1)*space/2;
	var drawX = startX + i*space;
	var drawY = originY + wave(-4, 4, 4, i, true);
	var c = global.abilityColors[oPlayer.attackSlots[i].type];
	
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
yOffset = radius * 1.5;
drawX = startX + selected*space;
drawY = originY + wave(-4, 4, 4, selected, true) - yOffset;
selectX = lerp(selectX, drawX, 0.1);
selectY = lerp(selectY, drawY, 0.02);

c = global.abilityColors[upgrade.type];
draw_sprite_ext(sSelect, 0, selectX, selectY, wave(-1, 1, 2, 0, true), 1, 0, c, 1);