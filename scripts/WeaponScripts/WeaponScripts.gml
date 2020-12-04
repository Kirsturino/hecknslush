enum weapons {
	melee,
	ranged
}

enum recharge {
	time,
	damage
}

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

//Player abilities
function genericweaponStruct() constructor
{
	//Info
	name =					"Generic Weapon";
	type =					weapons.ranged;
	clr =					c_red;
	htbx =					oHitbox;
	spr =					sGun;
	
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
	dmg =					0.4;
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
	projSpr =				sProjectile;
	zoom =					0.4;
	
	//Enemy exclusive
	anticipationDur =		64;
}

function basicSlash() constructor {
	//Info
	name =					"Melee Weapon";
	type =					weapons.melee;
	clr =					c_red;
	htbx =					oHitbox;
	spr =					sSlash;
	
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
	dmg=					1;
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
	projSpr =				sProjectile;
	zoom =					0.4;
	spread =				0;	
}

function spinSlash() constructor {
	//Info
	name =					"Spinslash";
	type =					weapons.melee;
	clr =					c_red;
	htbx =					oHitbox;
	spr =					sThrust;
	
	//Hitbox pattern stuff
	amount =				36;
	delay =					2;
	burstAmount =			0;
	burstDelay =			0;
	multiSpread =			1080;
	
	//Hitbox movement 
	fric =					0;
	spd =					0;
	
	//Hitbox active start and end
	start =					0;
	length =				12;
	
	//Important values
	dmg=					0.4;
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
	projSpr =				sProjectile;
	zoom =					0.4;
	spread =				0;
}

function burstBlaster() constructor {
	//Info
	name =					"Ranged Weapon";
	type =					weapons.ranged;
	clr =					c_red;
	htbx =					oHitbox;
	spr =					sGun;
	
	//Hitbox pattern stuff
	amount =				10;
	delay =					5;
	burstAmount =			0;
	burstDelay =			20;
	spread =				5;
	multiSpread =			0;
	
	//Hitbox movement 
	fric =					0;
	spd =					5;
	
	//Hitbox active start and end
	start =					2;
	length =				10;
	
	//Important values
	dmg=					0.6;
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
	projSpr =				sProjectile;
	zoom =					0.4;
}

function doubleWave() constructor {
	//Info
	name =					"Double Burst";
	type =					weapons.ranged;
	clr =					c_red;
	htbx =					oHitbox;
	spr =					sGun;
	
	//Hitbox pattern stuff
	amount =				10;
	delay =					0;
	burstAmount =			1;
	burstDelay =			20;
	spread =				0;
	multiSpread =			090;
	
	//Hitbox movement 
	fric =					0.03;
	spd =					3;
	
	//Hitbox active start and end
	start =					2;
	length =				10;
	
	//Important values
	dmg=					1;
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
	projSpr =				sProjectile;
	zoom =					0.4;
}
	
//Enemy abilities

function rangedEnemyWeapon() constructor {
	//Info
	name =					"Burst Blaster";
	type =					weapons.ranged;
	clr =					c_red;
	htbx =					oHitbox;
	spr =					sGun;
	
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
	start =					2;
	length =				10;
	
	//Important values
	dmg=					1;
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
	projSpr =				sProjectile;
	zoom =					0.4;
	
	//Enemy exclusive
	anticipationDur =		64;
}