function swarmerCombat() constructor
{
	detectionRadius = 200;
	attackRadius = 124;
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
	dir = 0;
}

function swarmerVisuals() constructor
{
	flash = 0;
	frm = 0;
	spd = 1;
	xScale = 1;
	yScale = 1;
	rot = 0;
	indicatorLength = 128;
	indicatorType = shapes.line;
	
	//Sprites
	curSprite = sEnemyMelee;
	idle = sEnemyMelee;
	anticipation  = sEnemyMeleeAnticipation;
	attacking = sEnemyMeleeDashing;
	stunned = sEnemyMeleeStunned;
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
	dir = 0;
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
	curSprite = sEnemyRanged;
	idle = sEnemyRanged;;
	anticipation  = sEnemyRangedAnticipation;
	attacking = sEnemyRangedShooting;
	stunned = sEnemyRangedStunned;
	corpse = sEnemyCorpse;
}