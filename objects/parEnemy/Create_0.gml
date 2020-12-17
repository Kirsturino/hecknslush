#region functions

function destroySelf()
{
	var corpse = instance_create_layer(x, y, "Instances", oCorpse);
	corpse.sprite_index = visuals.corpse;
	corpse.move.hsp = move.hsp;
	corpse.move.vsp = move.vsp;
	corpse.move.dir = point_direction(0, 0, move.hsp, move.vsp);
	
	spawnCurrency(currencyArray);
	
	instance_destroy();
}

function takeDamage(amount) {
	combat.hp = max(0, combat.hp - amount);
	combat.iframes = combat.iframesMax;
		
	if (combat.hp <= 0) destroySelf();
		
	if (state == states.idle) { move.aggroTimer = move.aggroTimerMax; }
}

function initCurrency(amount)
{
	var currencyArray = array_create(amount, 0);

	for (var i = 0; i < amount; ++i) {
	    currencyArray[i] = instance_create_layer(x, y, "Instances", oCurrency);
		instance_deactivate_object(currencyArray[i]);
	}
	
	return currencyArray;
}

function spawnCurrency(currencyArray)
{
	var length = array_length(currencyArray);
	for (var i = 0; i < length; ++i)
	{
		instance_activate_object(currencyArray[i]);
		currencyArray[i].x = x;
		currencyArray[i].y = y;
		
		currencyArray[i].move.hsp = irandom_range(-3, 3);
		currencyArray[i].move.vsp = irandom_range(-3, 3);
	}
}

#endregion

#region Attack indicator scripts

function drawAttackIndicator(visuals, weapon, attack)
{
	var c = col.red;
	var c2 = c_black;
	
	switch (visuals.indicatorType)
	{
		case shapes.line:
			var drawX = x + lengthdir_x(visuals.indicatorLength, attack.dir);
			var drawY = bbox_bottom + lengthdir_y(visuals.indicatorLength, attack.dir);
			
			draw_line_width_color(x, bbox_bottom, drawX, drawY, 8, c, c2);
		break;
		
		case shapes.triangle:
			var drawX = x;
			var drawY = y;
			var drawX2 = x + lengthdir_x(visuals.indicatorLength, attack.dir - weapon.spread);
			var drawY2 = y + lengthdir_y(visuals.indicatorLength, attack.dir - weapon.spread);
			var drawX3 = x + lengthdir_x(visuals.indicatorLength, attack.dir + weapon.spread);
			var drawY3 = y + lengthdir_y(visuals.indicatorLength, attack.dir + weapon.spread);
			
			draw_triangle_color(drawX, drawY, drawX2, drawY2, drawX3, drawY3, c, c2, c2, false);
		break;
	}
	
	//Generic glow/circle thing under enemy
	var xOff = sprite_width;
	var yOff = sprite_height/2;
	draw_ellipse_color(x - xOff, bbox_bottom - yOff, x + xOff, bbox_bottom + yOff, c, c2, false);
}

#endregion

#region Enemy AI stuff

function enemyIdle()
{
	staticMovement();

	var los = canSee(oPlayer);
	var closeEnough = distance_to_object(oPlayer) <= combat.detectionRadius;
	
	//If enemy can see player or has been aggroed, start chasing player
	if ((closeEnough && los) || move.aggroTimer != 0) toChasing();
}

function enemyChasing() {
	var dir = point_direction(x, y, move.lastSeen[0], move.lastSeen[1]);
	var dist = distance_to_object(oPlayer);
	var los = canSee(oPlayer);
	
	//Get line of sight
	if (los && dist < combat.chaseRadius)
	{
		move.lastSeen[0] = oPlayer.x;
		move.lastSeen[1] = oPlayer.y;
	}
	
	chaseMovement(dist, dir);
	move.aggroTimer = approach(move.aggroTimer, 0, 1);
	
	if (dist < combat.attackRadius && los && attack.cooldown == 0) { toAttacking(); }
	else if ((dist > combat.chaseRadius || !los) && move.aggroTimer == 0) { toIdle(); }
}

function enemyAttacking() {
	//Wait a while before attacking, then initiate attack
	//When attack is over, go back to repositioning
	if (visuals.curSprite != "attacking" && attack.anticipationDur == 0 && attack.count == 0) 
	{
		visuals.curSprite = "attacking";
		visuals.finalSpr = variable_struct_get(visuals.spriteStruct, visuals.curSprite);
	} else if (visuals.curSprite != "idle" && attack.count == weapon.amount) 
	{
		visuals.curSprite = "idle";
		visuals.finalSpr = variable_struct_get(visuals.spriteStruct, visuals.curSprite);
	}
		
	attackLogic(weapon, attack);
	attackMovement();
	
	//This might be baked into the attack logic at some point
	//For now, this can stay, even if it's being run every frame
	//Maybe into increment attack function?
	if (attack.count == weapon.amount) { drawFunction = nothing; }
		
	//Count down attack dur
	if (attack.dur == 0) { toChasing(); }
}

function enemyStunned() {
	staticMovement();
	
	combat.stunDur = approach(combat.stunDur, 0, 1);
	if (combat.stunDur == 0) toIdle();
}

//Init states
states =  {
	idle : enemyIdle,
	chasing : enemyChasing,
	attacking : enemyAttacking,
	stunned : enemyStunned,
}
	
#endregion

#region State switches

function toIdle() {
	visuals.curSprite = "idle";
	visuals.finalSpr = variable_struct_get(visuals.spriteStruct, visuals.curSprite);
	state = states.idle;
	drawFunction = nothing;
}

function toChasing() {
	visuals.curSprite = "moving";
	visuals.finalSpr = variable_struct_get(visuals.spriteStruct, visuals.curSprite);
	state = states.chasing;
	drawFunction = nothing;
}

function toAttacking() {
	//Set attack direction
	attack.dir = point_direction(x, y, oPlayer.x, oPlayer.y);
	move.dir = attack.dir;

	visuals.curSprite = "anticipation";
	visuals.finalSpr = variable_struct_get(visuals.spriteStruct, visuals.curSprite);
	state = states.attacking;
	drawFunction = drawAttackIndicator;
}

function toStunned(duration) {
	resetAttack(weapon, attack);
	
	combat.stunDur = duration;
	
	visuals.curSprite = "stunned";
	visuals.finalSpr = variable_struct_get(visuals.spriteStruct, visuals.curSprite);
	state = states.stunned;
	drawFunction = nothing;
}

#endregion

#region Movement

function chaseMovement(dist, dir)
{
	if (dist < combat.fleeRadius || dist > combat.attackRadius)
	{
		move.hsp = approach(move.hsp, lengthdir_x(move.chaseSpd, dir), move.axl);
		horizontalCollision();
	
		move.vsp = approach(move.vsp, lengthdir_y(move.chaseSpd, dir), move.axl);
		verticalCollision();
		
		move.dir = point_direction(0, 0, move.hsp, move.vsp);
	
		x += move.hsp * delta;
		y += move.vsp * delta;
	} else 
	{
		staticMovement();
	}
}

#endregion

//Other

function incrementCooldowns() {
	attack.cooldown = approach(attack.cooldown, 0, 1);
}
	
function initEnemy()
{
	state = nothing;
	DoLater(1, function(data) {state = states.idle;},0,true);
	drawFunction = nothing;
	
	visuals.finalSpr = variable_struct_get(visuals.spriteStruct, visuals.curSprite);

	//Set mask
	sprite_index = move.collMask;
}