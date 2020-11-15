if (visual.flash > 0) {
	shader_set(shdDrawWhite);
	draw_sprite_ext(sprite_index, floor(visual.frm), x, y, image_xscale, image_yscale, image_angle, c_white, 1);
	shader_reset();
} else {
	draw_sprite_ext(sprite_index, floor(visual.frm), x, y, image_xscale, image_yscale, image_angle, c_white, 1);
}