if (combat.iframes == 0 || combat.iframes mod 40 < 10) {
	var offset = sprite_height / 2;
	draw_sprite_ext(visuals.curSprite, 0, x, y - offset, visuals.xScale, visuals.yScale, visuals.rot, c_white, 1);
}

drawFunction();