//When using this collision, make sure that the origin on collision masks is set to middle center
//This is to be used with objects that WILL NOT ROTATE

function horizontalCollision() 
{
	if (move.hsp == 0) return;
	
	//See if we would collide with anything next frame with our current speed
	var coll = instance_place(x + move.hsp * delta, y, parCollision);
	
	//If we're about to collide, move object flush to object and set speed to zero
	//This is bad, but it's fast to make, so idk. Might refactor later
	if (coll != noone) 
	{
		if (sign(move.hsp) == 1)
		{
			x = coll.bbox_left - sprite_width / 2;
		} else if (sign(move.hsp) == -1)
		{
			x = coll.bbox_right + sprite_width / 2 + 1;
		}
		
		move.hsp = 0;
	}
}

function verticalCollision() 
{
	if (move.vsp == 0) return;
	
	//See if we would collide with anything next frame with our current speed
	var coll = instance_place(x, y + move.vsp * delta, parCollision);
	
	//If we're about to collide, move object flush to object and set speed to zero
	//This is bad, but it's fast to make, so idk. Might refactor later
	if (coll != noone)
	{
		if (sign(move.vsp) == 1)
		{
			y = coll.bbox_top - sprite_height / 2;
		} else if (sign(move.vsp) == -1)
		{
			y = coll.bbox_bottom + sprite_height / 2 + 1;
		}
		
		move.vsp = 0;
	}
}