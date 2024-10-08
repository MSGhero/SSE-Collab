enum abstract BatchID(String) to String {
	var SPRITE_BATCH;
	var UI_BATCH;
}

@:transitive
enum abstract LayerID(Int) to Int {
	// most rear to most front
	var NONE = -1;
	var BG;
	var FG;
	var UI;
}

enum abstract SheetID(String) to String {
	var SPRITES;
}

@:transitive
enum abstract ParentID(String) to String {
	var NONE;
	var S2D;
}

enum abstract InputID(String) to String {
	var MENU;
}

enum abstract StateID(Int) to Int {
	var GAME_STATE;
	var PRELOAD_STATE;
	var CREATURE_STATE;
	var SELECT_STATE;
	var LOGO_STATE;
}