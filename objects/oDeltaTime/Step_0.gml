//Keep track of frame delta
global.actualDelta = delta_time / 1000000;

//Calculate multiplier based on frame time, affected by manual timescale A.K.A. slowmotion
//When game is running smoothly and without slow motion effects, this will equal 1
delta = global.actualDelta / global.targetDelta * global.timeScale;

//Limit delta time, so intentional lagging won't break things
//This is would be equal to someone having around 15 FPS
delta = min(delta, maxDelta);