gpu_set_blendmode(bm_add);
draw_set_alpha(wave(0.05, 0.1, 0.3, 0, true));
with (parEnemy)
{
	if (drawFunction == attackIndicator) 
	{
		attackIndicator();
	}
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

with (parPhysical)
{
	//Dropshadow implementation
	var xOff = sprite_width/3;
	var yOff = sprite_height/6;
	draw_ellipse_color(x - xOff, bbox_bottom - yOff, x + xOff, bbox_bottom + yOff, c_black, c_black, false);
}