//Drawing the drawFunction script is handled by oSurfaceHandler for performance reason

//Mirror sprite on x-axis 
var scaleX = 1;
if (move.dir > 90 && move.dir < 270)	{ scaleX *= -1; }
scaleX *= visuals.xScale;
	
//Hitflash implementation
if (visuals.flash > 0) {
	shader_set(shdDrawWhite);
	draw_sprite_ext(visuals.finalSpr, floor(visuals.frm), x, y, scaleX, visuals.yScale, visuals.rot, c_white, 1);
	shader_reset();
} else {
	draw_sprite_ext(visuals.finalSpr, floor(visuals.frm), x, y, scaleX, visuals.yScale, visuals.rot, c_white, 1);
}