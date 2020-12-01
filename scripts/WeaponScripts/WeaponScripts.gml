enum weapons {
	melee,
	ranged
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

function weaponStruct() constructor
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
	
	//Cooldowns and timing
	dur =					30;
	cooldown =				60;
	
	//Melee exclusive
	reach =					12; //Ranged reach is also tied to gun sprite
	mirror =				true;
	
	//Ranged exclusive
	projSpr =				sProjectile;
	zoom =					0.4;
	
	//Enemy exclusive
	anticipationDur =		64;
}