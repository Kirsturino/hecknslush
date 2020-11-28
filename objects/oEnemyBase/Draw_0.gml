if (visuals.flash > 0) {
	shader_set(shdDrawWhite);
	draw_sprite_ext(visuals.curSprite, floor(visuals.frm), x, y, visuals.xScale, visuals.yScale, visuals.rot, c_white, 1);
	shader_reset();
} else {
	draw_sprite_ext(visuals.curSprite, floor(visuals.frm), x, y, visuals.xScale, visuals.yScale, visuals.rot, c_white, 1);
}