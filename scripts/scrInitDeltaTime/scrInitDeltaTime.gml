//Get project framerate
global.framesPerSecond = game_get_speed(gamespeed_fps);

//This doesn't really matter what it is, but will affect rate of everything. 
//Just needs some constant to measure against, I think.
#macro defaultFramesPerSecond 144

//Time that a single frame should last by default
global.targetDelta = 1 / defaultFramesPerSecond;

//Actual time that includes lag etc.
global.actualDelta = delta_time / 1000000;

//This is going to be used EVERYWHERE, so having a shorter name is convenient
//Don't use this way of creating global variables otherwise
globalvar delta;
delta = global.actualDelta / global.targetDelta;

//Additional multiplier for slowmotion and stuff
global.timeScale = 1;