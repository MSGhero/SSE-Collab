package input;

enum abstract Action(Int) from Int to Int {
	
	var L;
	var R;
	var U;
	var D;
	
	var SELECT;
	var DESELECT;
	var OPEN;
	var CLOSE;
	var LINK;
	
	var VOL_UP;
	var VOL_DOWN;
	var MUTE;
	
	var FULLSCREEN;
	var ESC;
	var WHEEL; // may want to allow some additional U/D scroll if a mouse wheel caused it
}