//Init global player variables
global.currencyAmount = 0;

//Player stat structs
function combatStruct() constructor
{
	maxHP = 5;
	hp = 5;
	iframesMax = 144;
	iframes = 0;
	aimDir = 0;
	curAttack = 0;
	stunnable = false;
}

function moveStruct() constructor
{
	hsp = 0;
	vsp = 0;
	maxSpd = 1.2;
	curMaxSpd = 1.2;
	axl = 0.12;
	fric = 0.04;
	lastDir = 0;
	dir = 0;
	moving = false;
	collMask = sPlayerWallCollisionMask;
	aimSpeedModifier = 0.5
}

function visualsStruct() constructor
{
	curSprite = sPlayer;
	xScale = 1;
	yScale = 1;
	rot = 0;
	recoil = 0;
	frm = 0;
	spd = 1;
}

function sprintStruct() constructor
{
	maxSpd = 2;
	axl = 0.05;
	turnSpd = 0;
	turnAxl = 0.2;
	turnMaxSpd = 2;
	buildup = 0;
	buildupMax = 60
}

//This is for rtshell
function playerToDummy() {
	if (instance_exists(oPlayer)) {with (oPlayer) { toDummy(); }}
}

function playerToGrounded() {
	if (instance_exists(oPlayer)) { with (oPlayer) {toGrounded(); }}
}