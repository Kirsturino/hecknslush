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
	anticipationDur = 0;
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

function setAttackStruct(weapon)
{
	var struct = new attackStruct();
	struct.dur = weapon.dur;
	struct.anticipationDur = weapon.anticipationDur;
	
	return struct;
}

//Player abilities
function genericweaponStruct() constructor
{
	//Info
	name =					"Generic Weapon";
	type =					weapons.ranged;
	clr =					col.red;
	htbx =					oHitbox;
	projSpr =				sProjectile;
	abilitySpr =			sAbility;
	upgradeCount =			0;
	maxUpgradeCount =		3;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[defaultHitboxEnemyCollision];
	hitFunctions =			[];
	collisionFunctions =	[destroyOnCollision];
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
	knockback =				0.2;
	
	//Values that affect player while attacking
	push =					-0.2;
	aimable =				false;
	
	//Cooldowns and timing
	dur =					30;
	anticipationDur =		0;
	cooldown =				60;
	cooldownType =			recharge.time;
	
	//Melee exclusive
	reach =					12; //Ranged reach is also tied to gun sprite
	mirror =				true;
	
	//Ranged exclusive
	spr =					sGun;
	zoom =					0.4;
	
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
	clr =					col.red;
	htbx =					oHitbox;
	projSpr =				sSlash;
	abilitySpr =			sAbility;
	upgradeCount =			0;
	maxUpgradeCount =		3;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[piercingHitboxEnemyCollision, defaultHitboxMovement];
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
	knockback =				2;
	
	//Values that affect player while attacking
	push =					1;
	aimable =				false;
	
	//Cooldowns and timing
	dur =					32;
	anticipationDur =		0;
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
	clr =					col.red;
	htbx =					oHitbox;
	projSpr =				sThrust;
	abilitySpr =			sAbility;
	upgradeCount =			0;
	maxUpgradeCount =		3;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[piercingHitboxEnemyCollision, defaultHitboxMovement];
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
	size =					0.8;
	
	//Misc. values
	knockback =				0.2;
	
	//Values that affect player while attacking
	push =					2;
	aimable =				false;
	
	//Cooldowns and timing
	dur =					64;
	anticipationDur =		0;
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
	clr =					col.blue;
	htbx =					oHitbox;
	projSpr =				sProjectile;
	abilitySpr =			sAbility;
	upgradeCount =			0;
	maxUpgradeCount =		3;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[piercingHitboxEnemyCollision, defaultHitboxMovement];
	hitFunctions =			[];
	collisionFunctions =	[destroyOnCollision];
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
	knockback =				0.2;
	
	//Values that affect player while attacking
	push =					-0.2;
	aimable =				true;
	
	//Cooldowns and timing
	dur =					30;
	anticipationDur =		0;
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
	clr =					col.blue;
	htbx =					oHitbox;
	projSpr =				sProjectile;
	abilitySpr =			sAbility;
	upgradeCount =			0;
	maxUpgradeCount =		3;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[defaultHitboxEnemyCollision, destroyOnStop, defaultHitboxMovement];
	hitFunctions =			[];
	collisionFunctions =	[destroyOnCollision];
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
	knockback =				0.2;
	
	//Values that affect player while attacking
	push =					-0.2;
	aimable =				false;
	
	//Cooldowns and timing
	dur =					60;
	anticipationDur =		0;
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
	clr =					col.blue;
	htbx =					oHitbox;
	projSpr =				sProjectile;
	abilitySpr =			sAbility;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[defaultHitboxMovement, defaultHitboxEnemyCollision];
	hitFunctions =			[];
	collisionFunctions =	[destroyOnCollision];
	destroyFunctions =		[];
	
	//Hitbox pattern stuff
	amount =				5;
	delay =					5;
	burstAmount =			0;
	burstDelay =			20;
	spread =				10;
	multiSpread =			0;
	
	//Hitbox movement 
	fric =					0.015;
	spd =					2.5;
	
	//Hitbox active start and end
	start =					0;
	length =				9999;
	
	//Important values
	dmg =					10;
	life =					180;
	size =					1;
	
	//Misc. values
	knockback =				0.2;
	
	//Values that affect player while attacking
	push =					0.4;
	aimable =				false;
	
	//Cooldowns and timing
	dur =					30;
	anticipationDur =		64;
	cooldown =				120;
	cooldownType =			recharge.time;
	
	//Melee exclusive
	reach =					12; //Ranged reach is also tied to gun sprite
	mirror =				true;
	
	//Ranged exclusive
	zoom =					0.4;
	spr =					sGun;
	
	//FX
	attackFX =				nothing;
	trailFX =				baseProjectileTrail;
	explosionFX =			baseProjectileExplosion;
	damageFX =				baseDamageFX;
}

function swarmerEnemyWeapon() constructor
{
	//Info
	name =					"Spinslash";
	type =					weapons.melee;
	clr =					col.red;
	htbx =					oHitbox;
	projSpr =				sThrust;
	abilitySpr =			sAbility;
	upgradeCount =			0;
	maxUpgradeCount =		3;
	
	//Added behaviour functions
	spawnFunctions =		[];
	aliveFunctions =		[piercingHitboxEnemyCollision, defaultHitboxMovement];
	hitFunctions =			[];
	collisionFunctions =	[];
	destroyFunctions =		[];
	
	//Hitbox pattern stuff
	amount =				14;
	delay =					4;
	burstAmount =			0;
	burstDelay =			0;
	multiSpread =			0;
	
	//Hitbox movement 
	fric =					0;
	spd =					0;
	
	//Hitbox active start and end
	start =					0;
	length =				12;
	
	//Important values
	dmg =					5;
	life =					12;
	size =					0.5;
	
	//Misc. values
	knockback =				0.2;
	
	//Values that affect player while attacking
	push =					2;
	aimable =				false;
	
	//Cooldowns and timing
	dur =					128;
	anticipationDur =		64;
	cooldown =				64;
	cooldownType =			recharge.time;
	
	//Melee exclusive
	reach =					24; //Ranged reach is also tied to gun sprite
	mirror =				false;
	
	//Ranged exclusive
	spr =					sThrust;
	zoom =					0.4;
	spread =				0;
	
	//FX
	attackFX =				nothing;
	trailFX =				nothing;
	explosionFX =			nothing;
	damageFX =				baseDamageFX;
}
	
//Weapon FX
function baseMeleeFX(weapon, attack, xx, yy)
{
	shakeCamera(weapon.dmg, 2, 40);
	pushCamera(weapon.dmg, attack.htbxDir);
			
	var sprd = max(40, weapon.spread);
			
	part_type_direction(global.shootPart, attack.htbxDir - sprd, attack.htbxDir + sprd, 0, 0);
	part_particles_create(global.ps, xx, yy, global.shootPart, weapon.dmg);
}

function baseRangedFX(weapon, attack, xx, yy)
{
	shakeCamera(weapon.dmg, 2, 4);
	pushCamera(weapon.dmg, attack.htbxDir + 180);
			
	part_particles_create(global.ps, xx, yy, global.muzzleFlashPart, 1);
	part_type_direction(global.shootPart, attack.htbxDir - weapon.spread * 2, attack.htbxDir + weapon.spread * 2, 0, 0);
	part_particles_create(global.ps, xx, yy, global.shootPart, weapon.dmg);
}

function baseProjectileTrail(move)
{
	part_type_direction(global.bulletTrail, move.dir - 10, move.dir + 10, 0, 0);
	part_particles_create(global.ps, other.x, other.y, global.bulletTrail, 1);
}

function baseProjectileExplosion(amount)
{
	part_particles_create(global.ps, other.x, other.y, global.hitPart, amount);
}
	
function baseDamageFX(amount)
{
	part_particles_create(global.ps, other.x, other.y, global.hitPart, amount);
		
	part_type_size(global.hitPart2, amount * 2, amount * 2, -amount, 0);
	part_particles_create(global.ps, other.x, other.y, global.hitPart2, 1);
}