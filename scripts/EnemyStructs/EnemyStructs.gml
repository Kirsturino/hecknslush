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
	indicatorFunction = drawAttackLine;
	
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
	indicatorFunction = drawAttackTriangle;
	
	
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

#region Attack indicator scripts

function drawAttackLine()
{
	var c = col.red;
	var c2 = c_black;
	var drawX = x + lengthdir_x(visuals.indicatorLength, attack.dir);
	var drawY = bbox_bottom + lengthdir_y(visuals.indicatorLength, attack.dir);
			
	draw_line_width_color(x, bbox_bottom, drawX, drawY, 8, c, c2);
	
	genericAttackWarning();
}

function drawAttackTriangle()
{
	var c = col.red;
	var c2 = c_black;
	var drawX = x;
	var drawY = y;
	var drawX2 = x + lengthdir_x(visuals.indicatorLength, attack.dir - weapon.spread);
	var drawY2 = y + lengthdir_y(visuals.indicatorLength, attack.dir - weapon.spread);
	var drawX3 = x + lengthdir_x(visuals.indicatorLength, attack.dir + weapon.spread);
	var drawY3 = y + lengthdir_y(visuals.indicatorLength, attack.dir + weapon.spread);
			
	draw_triangle_color(drawX, drawY, drawX2, drawY2, drawX3, drawY3, c, c2, c2, false);
	
	genericAttackWarning();
}

function drawAttackCircle(xx, yy)
{
	var c = col.red;
	var c2 = c_black;
	
	var xOff = visuals.indicatorLength;
	var yOff = visuals.indicatorLength/2;
	draw_ellipse_color(xx - xOff, yy- yOff, xx + xOff, yy+ yOff, c, c2, false);
	
	genericAttackWarning();
}

function genericAttackWarning()
{
	var c = col.red;
	var c2 = c_black;
	
	//Generic glow/circle thing under enemy
	var xOff = sprite_width;
	var yOff = sprite_height/2;
	draw_ellipse_color(x - xOff, bbox_bottom - yOff, x + xOff, bbox_bottom + yOff, c, c2, false);
}

#endregion