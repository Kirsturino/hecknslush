//Set up quick reference
#macro view view_camera[0]

//Init camera
#macro viewWidth 640
#macro viewHeight 360
global.windowScale = 2;

enum cameraStates {
	follow,
	aim,
	scripted
}