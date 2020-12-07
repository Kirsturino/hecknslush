//Enemy attack warnings get drawn to this surface
if (!surface_exists(global.enemyAttackSurf))
{
	global.enemyAttackSurf = surface_create(viewWidth, viewHeight);
} else
{
	surface_set_target(global.enemyAttackSurf);
	draw_clear_alpha(c_black, 0);
	
	gpu_set_blendmode(bm_add);
	
	with (parEnemy)
	{
		if (drawFunction == drawAttackIndicator) 
		{
			drawAttackIndicator(visuals, weapon, attack);
		}
	}
	
	surface_reset_target();
	gpu_set_blendmode(bm_normal);
	
	var camX = camera_get_view_x(view);
	var camY = camera_get_view_y(view);

	draw_surface_ext(global.enemyAttackSurf, camX, camY, 1, 1, 0, c_white, wave(0.1, 0.2, 0.3, 0, true));
}