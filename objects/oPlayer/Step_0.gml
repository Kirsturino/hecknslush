//Execute current state
state();

depthSorting();

//Things that should be done almost always
if (state == playerDummy) exit;

executeFunctionArray(extra.step);
cameraStateSwitch();
updateStateBuffer();
incrementVerbCooldowns();
incrementAnimationFrame();