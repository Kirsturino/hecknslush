shapeTick();

if (keyboard_check_pressed(ord("J")))
{
	vectorShapeCall(oPlayer.x, oPlayer.y, shapes.rectangle, 32, -0.2, 4, irandom(360), 144, col.white, false);
}