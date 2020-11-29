enum weapons {
	melee,
	ranged
}

function createAttackStruct() constructor
{
	dur = 0;
	dir = 0;
	htbxDir = 0;
	count = 0;
	burstCount = 0;
	queued = false;
	cooldown = 0;
}