gpu_set_blendmode(bm_add);
draw_set_alpha(wave(0.05, 0.1, 0.3, 0, true));
with (parEnemy)
{
	if (drawFunction == drawAttackIndicator) 
	{
		drawAttackIndicator(visuals, weapon, attack);
	}
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);