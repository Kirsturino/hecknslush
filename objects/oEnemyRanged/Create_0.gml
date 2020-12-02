// Inherit the parent event
event_inherited();

combat = {
	hp : 3,
	detectionRadius : 280,
	attackRadius : 220,
	chaseRadius : 320,
	fleeRadius : 160,
	stunDur : 0,
	stunnable : true,
	weight : 1
}

weapon = {
	//Info
	name :					"Burst Blaster",
	type :					weapons.ranged,
	clr :					c_red,
	htbx :					oHitbox,
	spr :					sGun,
	
	//Hitbox pattern stuff
	amount :				5,
	delay :					5,
	burstAmount :			0,
	burstDelay :			20,
	spread :				10,
	multiSpread :			0,
	
	//Hitbox movement 
	fric :					0.02,
	spd :					3,
	
	//Hitbox active start and end
	start :					2,
	length :				10,
	
	//Important values
	dmg:					0.4,
	life :					180,
	size :					1,
	
	//Misc. values
	destroyOnStop :			true,
	destroyOnCollision :	true,
	knockback :				0.2,
	piercing :				true,
	
	//Values that affect player while attacking
	push :					0.4,
	
	//Cooldowns and timing
	dur :					30,
	cooldown :				60,
	
	//Melee exclusive
	reach :					12, //Ranged reach is also tied to gun sprite
	mirror :				true,
	
	//Ranged exclusive
	projSpr :				sProjectile,
	zoom :					0.4,
	
	//Enemy exclusive
	anticipationDur :		64,
}

attack = new attackStruct();

move = {
	hsp : 0,
	vsp : 0,
	chaseSpd: 0.6,
	idleSpd: 1,
	lastSeen : [0, 0],
	aggroTimerMax : 180,
	aggroTimer : 0,
	axl : 0.02,
	fric : 0.05,
	collMask : sEnemyRangedWallCollisionMask,
	dir : 0
}

visuals.curSprite = sEnemyRanged;
visuals.corpse = sEnemyCorpse;

//Set mask
sprite_index = move.collMask;

//Declare state
state = nothing;
DoLater(1, function(data) {state = idle;},0,true);
drawFunction = nothing;

//States
function idle() {
	staticMovement();

	var los = canSee(oPlayer);
	if ((distance_to_object(oPlayer) <= combat.detectionRadius && los) || move.aggroTimer != 0) toRepositioning();
}

function repositioning() {
	var dist = distance_to_object(oPlayer);
	var los = canSee(oPlayer);
	
	//Get line of sight
	if (los && dist < combat.chaseRadius) {
		move.lastSeen[0] = oPlayer.x;
		move.lastSeen[1] = oPlayer.y;
	}
	
	//Get direction, if player too close, reverse direction
	var dir = point_direction(x, y, move.lastSeen[0], move.lastSeen[1]);
	if (dist < combat.fleeRadius && los) dir += 180;
	
	repositioningMovement(dist, dir);
	move.aggroTimer = approach(move.aggroTimer, 0, 1);
	
	if (dist <= combat.attackRadius && los && attack.cooldown == 0) { toAttacking(); }
	else if ((dist >= combat.chaseRadius || !los) && move.aggroTimer == 0) { toIdle(); }
}

function attacking() {
	//Wait a while before attacking, then initiate attack
	//When attack is over, go back to repositioning
	if (attack.anticipationDur > 0)
	{
		attack.anticipationDur = approach(attack.anticipationDur, 0, 1);
	} else if (attack.dur > 0)
	{
		visuals.curSprite = sEnemyRangedShooting;
		drawFunction = nothing;
		
		attackLogic(weapon, attack);
		attackMovement();
		
		//Count down attack dur
		attack.dur = approach(attack.dur, 0, 1);
		if (attack.dur == 0)
		{			
			attack.cooldown = weapon.cooldown;
			resetAttack(weapon, attack);
			toRepositioning();
		}
	}
}

function stunned() {
	staticMovement();
	
	combat.stunDur = approach(combat.stunDur, 0, 1);
	if (combat.stunDur == 0) toIdle();
}

//State switches
function toIdle() {
	visuals.curSprite = sEnemyRanged;
	state = idle;
	drawFunction = nothing;
}

function toRepositioning() {
	visuals.curSprite = sEnemyRanged;
	state = repositioning;
	drawFunction = nothing;
}

function toAttacking() {
	//Impart attack qualities to current attack
	attack.dur = weapon.dur;
	attack.anticipationDur = weapon.anticipationDur;
	attack.spd = weapon.spd;
	attack.dmg = weapon.dmg;
	
	//Set attack direction
	attack.dir = point_direction(x, y, oPlayer.x, oPlayer.y);

	visuals.curSprite = sEnemyRangedAnticipation;
	state = attacking;
	drawFunction = drawAttackIndicator;
}

function toStunned(duration) {
	attack.cooldown = weapon.cooldown;
	combat.stunDur = duration;
	
	visuals.curSprite = sEnemyRangedStunned;
	state = stunned;
	drawFunction = nothing;
}

//Movement
function repositioningMovement(dist, dir) {
	if (dist < combat.fleeRadius || dist > combat.attackRadius)
	{
		move.hsp = approach(move.hsp, lengthdir_x(move.chaseSpd, dir), move.axl);
		horizontalCollision();
	
		move.vsp = approach(move.vsp, lengthdir_y(move.chaseSpd, dir), move.axl);
		verticalCollision();
	
		x += move.hsp * delta;
		y += move.vsp * delta;
	} else 
	{
		staticMovement();
	}
}

//Other
function incrementCooldowns() {
	attack.cooldown = approach(attack.cooldown, 0, 1);
}

function drawAttackIndicator()
{
	var drawX = x + lengthdir_x(128, attack.dir);
	var drawY = y + lengthdir_y(128, attack.dir);
	var c = make_color_hsv(0, 255, 50);
	draw_line_width_color(x, y, drawX, drawY, 10, c, c);
}