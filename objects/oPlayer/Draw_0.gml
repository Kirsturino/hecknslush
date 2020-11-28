if (combat.iframes == 0 || combat.iframes mod 40 < 10) {
	draw_sprite_ext(visuals.curSprite, 0, x, y, visuals.xScale, visuals.yScale, visuals.rot, c_white, 1);
}

drawFunction();