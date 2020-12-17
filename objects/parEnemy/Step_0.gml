state();

//Things that should probably always be run
//This could/should be cleaned later
visuals.flash = approach(visuals.flash, 0, 1);
depthSorting();
avoidOverlap();
incrementCooldowns();
incrementAnimationFrame();
event_inherited();