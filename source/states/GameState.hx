package states;

import h3d.Engine;
import mono.audio.AudioCommand;
import mono.timing.FloatTweener;
import h3d.shader.UVScroll;
import IDs.StateID;
import mono.state.StateCommand;
import ecs.Entity;
import h2d.Video;
import IDs.InputID;
import mono.input.InputCommand;
import mono.timing.Timing;
import mono.timing.TimingCommand;
import IDs.LayerID;
import IDs.ParentID;
import mono.graphics.DisplayListCommand;
import hxd.Res;
import h2d.Bitmap;
import mono.command.Command;
import mono.state.State;

class GameState extends State {
	
	var entity:Entity;
	
	public function init() {
		entity = ecs.createEntity();
	}
	
	public function destroy() {
		
	}
	
	public function reset() {
		
	}
	
	override public function enter() {
		super.enter();
		
		trace("game state");
		
		Command.queueMany(
			ADD_UPDATER(entity, Timing.every(1 / 60, update))
		);
	}
	
	override public function exit() {
		super.exit();
		
	}
	
	function update() {
		
		Command.now(RAW_INPUT(si -> {
			final actions = si.get(MENU);
			
			if (actions.justPressed.FULLSCREEN) {
				Engine.getCurrent().fullScreen = !Engine.getCurrent().fullScreen;
			}
		}));
	}
}