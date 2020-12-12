enum weapons {
	melee,
	ranged,
	multi,
	other
}

enum recharge {
	time,
	damage,
	kill
}


//Generic structs that have stats for individual attacks/dodges/actions
function attackStruct() constructor
{
	dur = 0;
	anticipationDur = 64;
	dir = 0;
	htbxDir = 0;
	
	count = 0;
	burstCount = 0;
	cooldown = 0;
	mirror = 1;
}

function dodgeStruct() constructor
{
	dur = 0;
	spd = 0;
	dir = 0;
	cooldown = 0
}

//Player abilities
function genericweaponStruct() constructor
{
	//Info
	name =					"Generic Weapon";
	type =					weapons.ranged;
	clr =					c_red;
	htbx =					oHitbox;
	projSpr =				sProjectile;
	upgradeCount =			0;
	maxUpgradeCount =		3;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[];
	hitFunctions =			[];
	collisionFunctions =	[];
	destroyFunctions =		[];
	
	//Hitbox pattern stuff
	amount =				10;
	delay =					5;
	burstAmount =			0;
	burstDelay =			20;
	spread =				10;
	multiSpread =			0;
	
	//Hitbox movement 
	fric =					0.06;
	spd =					6;
	
	//Hitbox active start and end
	start =					2;
	length =				10;
	
	//Important values
	dmg =					4;
	life =					180;
	size =					1;
	
	//Misc. values
	destroyOnStop =			true;
	destroyOnCollision =	true;
	knockback =				0.2;
	piercing =				true;
	
	//Values that affect player while attacking
	push =					-0.2;
	aimable =				false;
	
	//Cooldowns and timing
	dur =					30;
	cooldown =				60;
	cooldownType =			recharge.time;
	
	//Melee exclusive
	reach =					12; //Ranged reach is also tied to gun sprite
	mirror =				true;
	
	//Ranged exclusive
	spr =					sGun;
	zoom =					0.4;
	
	//Enemy exclusive
	anticipationDur =		64;
	
	//FX
	attackFX =				baseMeleeFX;
	trailFX =				nothing;
	explosionFX =			nothing;
	damageFX =				baseDamageFX;
}

function basicSlash() constructor
{
	//Info
	name =					"Melee Weapon";
	type =					weapons.melee;
	clr =					c_red;
	htbx =					oHitbox;
	projSpr =				sSlash;
	upgradeCount =			0;
	maxUpgradeCount =		3;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[];
	hitFunctions =			[];
	collisionFunctions =	[];
	destroyFunctions =		[];
	
	//Hitbox pattern stuff
	amount =				1;
	delay =					0;
	burstAmount =			0;
	burstDelay =			0;
	multiSpread =			0;
	
	//Hitbox movement 
	fric =					0;
	spd =					0;
	
	//Hitbox active start and end
	start =					2;
	length =				10;
	
	//Important values
	dmg=					10;
	life =					12;
	size =					1;
	
	//Misc. values
	destroyOnStop =			false;
	destroyOnCollision =	false;
	knockback =				2;
	piercing =				true;
	
	//Values that affect player while attacking
	push =					1;
	aimable =				false;
	
	//Cooldowns and timing
	dur =					32;
	cooldown =				0;
	cooldownType =			recharge.damage;
	
	//Melee exclusive
	reach =					32; //Ranged reach is also tied to gun sprite
	mirror =				true;
	
	//Ranged exclusive
	spr =					sSlash;
	zoom =					0.4;
	spread =				0;	
	
	//FX
	attackFX =				baseMeleeFX;
	trailFX =				nothing;
	explosionFX =			nothing;
	damageFX =				baseDamageFX;
}

function spinSlash() constructor
{
	//Info
	name =					"Spinslash";
	type =					weapons.melee;
	clr =					c_red;
	htbx =					oHitbox;
	projSpr =				sThrust;
	upgradeCount =			0;
	maxUpgradeCount =		3;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[];
	hitFunctions =			[];
	collisionFunctions =	[];
	destroyFunctions =		[];
	
	//Hitbox pattern stuff
	amount =				24;
	delay =					2;
	burstAmount =			0;
	burstDelay =			0;
	multiSpread =			720;
	
	//Hitbox movement 
	fric =					0;
	spd =					0;
	
	//Hitbox active start and end
	start =					0;
	length =				12;
	
	//Important values
	dmg=					4;
	life =					12;
	size =					1;
	
	//Misc. values
	destroyOnStop =			false;
	destroyOnCollision =	false;
	knockback =				0.2;
	piercing =				true;
	
	//Values that affect player while attacking
	push =					2;
	aimable =				false;
	
	//Cooldowns and timing
	dur =					64;
	cooldown =				240;
	cooldownType =			recharge.damage;
	
	//Melee exclusive
	reach =					48; //Ranged reach is also tied to gun sprite
	mirror =				false;
	
	//Ranged exclusive
	spr =					sThrust;
	zoom =					0.4;
	spread =				0;
	
	//FX
	attackFX =				baseMeleeFX;
	trailFX =				nothing;
	explosionFX =			nothing;
	damageFX =				baseDamageFX;
}

function burstBlaster() constructor
{
	//Info
	name =					"Ranged Weapon";
	type =					weapons.ranged;
	clr =					c_red;
	htbx =					oHitbox;
	projSpr =				sProjectile;
	upgradeCount =			0;
	maxUpgradeCount =		3;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[];
	hitFunctions =			[];
	collisionFunctions =	[];
	destroyFunctions =		[];
	
	//Hitbox pattern stuff
	amount =				3;
	delay =					10;
	burstAmount =			0;
	burstDelay =			20;
	spread =				2;
	multiSpread =			0;
	
	//Hitbox movement 
	fric =					0;
	spd =					5;
	
	//Hitbox active start and end
	start =					0;
	length =				999;
	
	//Important values
	dmg =					10;
	life =					180;
	size =					1;
	
	//Misc. values
	destroyOnStop =			true;
	destroyOnCollision =	true;
	knockback =				0.2;
	piercing =				true;
	
	//Values that affect player while attacking
	push =					-0.2;
	aimable =				true;
	
	//Cooldowns and timing
	dur =					30;
	cooldown =				180;
	cooldownType =			recharge.damage;
	
	//Melee exclusive
	reach =					12; //Ranged reach is also tied to gun sprite
	mirror =				true;
	
	//Ranged exclusive
	spr =					sGun;
	zoom =					0.4;
	
	//FX
	attackFX =				baseRangedFX;
	trailFX =				baseProjectileTrail;
	explosionFX =			baseProjectileExplosion;
	damageFX =				baseDamageFX;
}

function waveGun() constructor
{
	//Info
	name =					"Burst Wave";
	type =					weapons.ranged;
	clr =					c_red;
	htbx =					oHitbox;
	projSpr =				sProjectile;
	upgradeCount =			0;
	maxUpgradeCount =		3;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[];
	hitFunctions =			[];
	collisionFunctions =	[];
	destroyFunctions =		[];
	
	//Hitbox pattern stuff
	amount =				10;
	delay =					0;
	burstAmount =			0;
	burstDelay =			20;
	spread =				0;
	multiSpread =			90;
	
	//Hitbox movement 
	fric =					0.03;
	spd =					3;
	
	//Hitbox active start and end
	start =					0;
	length =				999;
	
	//Important values
	dmg =					15;
	life =					180;
	size =					1.5;
	
	//Misc. values
	destroyOnStop =			true;
	destroyOnCollision =	true;
	knockback =				0.2;
	piercing =				false;
	
	//Values that affect player while attacking
	push =					-0.2;
	aimable =				false;
	
	//Cooldowns and timing
	dur =					60;
	cooldown =				240;
	cooldownType =			recharge.damage;
	
	//Melee exclusive
	reach =					12; //Ranged reach is also tied to gun sprite
	mirror =				true;
	
	//Ranged exclusive
	spr =					sGun;
	zoom =					0.4;
	
	//FX
	attackFX =				baseRangedFX;
	trailFX =				baseProjectileTrail;
	explosionFX =			baseProjectileExplosion;
	damageFX =				baseDamageFX;
}
	
function defaultDodge() constructor
{
	dur = 20;
	spd = 4;
	iframes = 20;
	cooldown = 60;
}
	
//Enemy abilities

function rangedEnemyWeapon() constructor
{
	//Info
	name =					"Burst Blaster";
	type =					weapons.ranged;
	clr =					c_red;
	htbx =					oHitbox;
	projSpr =				sProjectile;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[];
	hitFunctions =			[];
	collisionFunctions =	[];
	destroyFunctions =		[];
	
	//Hitbox pattern stuff
	amount =				5;
	delay =					5;
	burstAmount =			0;
	burstDelay =			20;
	spread =				10;
	multiSpread =			0;
	
	//Hitbox movement 
	fric =					0.02;
	spd =					3;
	
	//Hitbox active start and end
	start =					0;
	length =				9999;
	
	//Important values
	dmg =					10;
	life =					180;
	size =					1;
	
	//Misc. values
	destroyOnStop =			true;
	destroyOnCollision =	true;
	knockback =				0.2;
	piercing =				true;
	
	//Values that affect player while attacking
	push =					0.4;
	aimable =				false;
	
	//Cooldowns and timing
	dur =					30;
	cooldown =				60;
	cooldownType =			recharge.time;
	
	//Melee exclusive
	reach =					12; //Ranged reach is also tied to gun sprite
	mirror =				true;
	
	//Ranged exclusive
	zoom =					0.4;
	spr =					sGun;
	
	//Enemy exclusive
	anticipationDur =		64;
	
	//FX
	attackFX =				nothing;
	trailFX =				baseProjectileTrail;
	explosionFX =			baseProjectileExplosion;
	damageFX =				baseDamageFX;
}
	
//Weapon FX
function baseMeleeFX(weapon, attack, xx, yy)
{
	shakeCamera(weapon.dmg * 20, 2, 4);
	pushCamera(weapon.dmg * 20, attack.htbxDir);
			
	if (weapon.multiSpread == 0) {
		var sprd = 40;
	} else {
		var sprd = weapon.multiSpread * .5;
	}
			
	part_type_direction(global.shootPart, attack.htbxDir - sprd, attack.htbxDir + sprd, 0, 0);
	part_particles_create(global.ps, xx, yy, global.shootPart, 5);
}

function baseRangedFX(weapon, attack, xx, yy)
{
	shakeCamera(weapon.dmg * 60, 2, 4);
	pushCamera(weapon.dmg * 50, attack.htbxDir + 180);
			
	part_particles_create(global.ps, xx, yy, global.muzzleFlashPart, 1);
	part_type_direction(global.shootPart, attack.htbxDir - weapon.spread * 2, attack.htbxDir + weapon.spread * 2, 0, 0);
	part_particles_create(global.ps, xx, yy, global.shootPart, 10);
}

function baseProjectileTrail(move)
{
	part_type_direction(global.bulletTrail, move.dir - 10, move.dir + 10, 0, 0);
	part_particles_create(global.ps, other.x, other.y, global.bulletTrail, 1);
}

function baseProjectileExplosion()
{
	part_particles_create(global.ps, other.x, other.y, global.hitPart, 10);
}
	
function baseDamageFX(amount)
{
	part_particles_create(global.ps, other.x, other.y, global.hitPart, amount * 10);
		
	part_type_size(global.hitPart2, amount * 3.2, amount * 3.4, -amount * 0.3, 0);
	part_particles_create(global.ps, other.x, other.y, global.hitPart2, 1);
}