if (visual.flash > 0) {
	shader_set(shdDrawWhite);
	draw_self();
	shader_reset();
} else {
	draw_self();
}