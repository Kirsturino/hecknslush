state();


visual.flash = approach(visual.flash, 0, 1);
depthSorting();
avoidOverlap();
incrementCooldowns();
incrementAnimationFrame();