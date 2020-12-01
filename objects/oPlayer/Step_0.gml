//Execute current state
state();

depthSorting();

//Things that should be done almost always
if (state == playerDummy) exit;

cameraStateSwitch();
updateStateBuffer();
incrementVerbCooldowns();