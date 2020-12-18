// Inherit the parent event
event_inherited();

combat = new rangedCombat();
move = new rangedMove();
visuals = new rangedVisuals();

weapon = new rangedEnemyWeapon();
attack = setAttackStruct(weapon);

currencyArray = initCurrency(combat.currencyAmount);

initEnemy();

//CUSTOM STATES
