package input;

enum abstract Action(Int) from Int to Int {
	
	var L;
	var R;
	var U;
	var D;
	
	var PAGE_L;
	var PAGE_R;
	
	var MOUSE;
	var SELECT;
	var DESELECT;
	var LINK;
	
	var VOL_UP;
	var VOL_DOWN;
	var MUTE;
	
	var FULLSCREEN;
	var ESC;
}