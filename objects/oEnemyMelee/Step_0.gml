state();

visuals.flash = approach(visuals.flash, 0, 1);
depthSorting();
avoidOverlap();
incrementCooldowns();
incrementAnimationFrame();