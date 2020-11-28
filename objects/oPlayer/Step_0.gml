state();

depth = -y - sprite_height / 2;

//Things that should be done almost always
if (state == playerDummy()) exit;
cameraStateSwitch();
updateStateBuffer();
incrementVerbCooldowns();