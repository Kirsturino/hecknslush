function swarmerCombat() constructor
{
	detectionRadius = 200;
	attackRadius = 80;
	chaseRadius = 240;
	fleeRadius = 0;
	
	hp = 20;
	stunDur = 0;
	stunnable = true;
	weight = 1;
	iframes = 0;
	iframesMax = 0;
	indicatorLength = 128;
	indicatorType = shapes.line;
	currencyAmount = 10;
}

function swarmerMove() constructor
{
	hsp = 0;
	vsp = 0;
	chaseSpd= 0.6;
	idleSpd= 1;
	lastSeen = [0, 0];
	aggroTimerMax = 180;
	aggroTimer = 0;
	axl = 0.02;
	fric = 0.05;
	collMask = sEnemyMeleeWallCollisionMask;
	dir = 270;
}

function swarmerVisuals() constructor
{
	flash = 0;
	frm = 0;
	spd = 0.02;
	xScale = 1;
	yScale = 1;
	rot = 0;
	indicatorLength = 128;
	indicatorType = shapes.line;
	
	//Sprites
	down = {
		idle : sEnemyMelee,
		moving : sEnemyMeleeMoving,
		anticipation  : sEnemyMeleeAnticipation,
		attacking : sEnemyMeleeDashing,
		stunned : sEnemyMeleeStunned,
	}
	
	up = {
		idle : sEnemyMeleeUp,
		moving : sEnemyMeleeMovingUp,
		anticipation  : sEnemyMeleeAnticipationUp,
		attacking : sEnemyMeleeDashingUp,
		stunned : sEnemyMeleeStunnedUp,
	}
	
	curSprite = "idle";
	finalSpr = sEnemyMelee;
	spriteStruct = down;
	
	corpse = sEnemyMeleeCorpse;
}

function rangedCombat() constructor
{
	detectionRadius = 280;
	attackRadius = 220;
	chaseRadius = 320;
	fleeRadius = 160;
	
	hp = 30;
	stunDur = 0;
	stunnable = true;
	weight = 1;
	iframes = 0;
	iframesMax = 0;
	currencyAmount = 10;
}

function rangedMove() constructor
{
	hsp = 0;
	vsp = 0;
	chaseSpd= 0.6;
	idleSpd= 1;
	lastSeen = [0, 0];
	aggroTimerMax = 180;
	aggroTimer = 0;
	axl = 0.02;
	fric = 0.05;
	collMask = sEnemyRangedWallCollisionMask;
	dir = 270;
}

function rangedVisuals() constructor
{
	flash = 0;
	frm = 0;
	spd = 1;
	xScale = 1;
	yScale = 1;
	rot = 0;
	indicatorLength = 240;
	indicatorType = shapes.triangle;
	
	
	//Sprites
	down = {
		idle : sEnemyRanged,
		moving : sEnemyRanged,
		anticipation  : sEnemyRangedAnticipation,
		attacking : sEnemyRangedShooting,
		stunned : sEnemyRangedStunned,
	}
	
	up = {
		idle : sEnemyRanged,
		moving : sEnemyRanged,
		anticipation  : sEnemyRangedAnticipation,
		attacking : sEnemyRangedShooting,
		stunned : sEnemyRangedStunned,
	}
	
	curSprite = "idle";
	finalSpr = sEnemyRanged;
	spriteStruct = down;
	
	corpse = sEnemyCorpse;
}