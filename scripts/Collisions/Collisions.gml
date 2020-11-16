function horizontalCollision(mask) {
	if (move.hsp == 0) exit;
	
	//Set separate collision mask
	var msk = mask_index;
	mask_index = mask;
	
	//See if we would collide with anything next frame with our current speed
	var coll = place_meeting(x + move.hsp, y, parCollision);
	
	//If we're about to collide, move object flush to object and set speed to zero
	//This is bad, but it's fast to make, so idk. Might refactor later
	if (coll) {
		while (!place_meeting(x + sign(move.hsp), y, parCollision)) {
			x += sign(move.hsp);
		}
		
		move.hsp = 0;
	}
	
	mask_index = msk;
}

function verticalCollision(mask) {
	if (move.vsp == 0) exit;
	
	//Set separate collision mask
	var msk = mask_index;
	mask_index = mask;
	
	//See if we would collide with anything next frame with our current speed
	var coll = place_meeting(x, y + move.vsp, parCollision);
	
	//If we're about to collide, move object flush to object and set speed to zero
	//This is bad, but it's fast to make, so idk. Might refactor later
	if (coll) {
		while (!place_meeting(x, y + sign(move.vsp), parCollision)) {
			y += sign(move.vsp);
		}
		
		move.vsp = 0;
	}
	
	mask_index = msk;
}