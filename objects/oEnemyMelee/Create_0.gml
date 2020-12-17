// Inherit the parent event
event_inherited();

combat = new swarmerCombat();
move = new swarmerMove();
visuals = new swarmerVisuals();

weapon = new swarmerEnemyWeapon();
attack = setAttackStruct(weapon);

currencyArray = initCurrency(combat.currencyAmount);

initEnemy();

//CUSTOM STATES