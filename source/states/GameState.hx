package states;

import proto.Proto;
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
	
	var volDown:Proto;
	var volUp:Proto;
	var vol:Proto;
		
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
		
		volDown = new Proto(ecs.createEntity());
		volDown.createSprite(S2D, FG);
		volDown.createAnim([{
			name : "default",
			frameNames : ["VOL_DOWN"],
			loop : false
		}]);
		volDown.add(ecs);
		volDown.sprite.x = 500; volDown.sprite.y = 450;
		
		volUp = new Proto(ecs.createEntity());
		volUp.createSprite(S2D, FG);
		volUp.createAnim([{
			name : "default",
			frameNames : ["VOL_UP"],
			loop : false
		}]);
		volUp.add(ecs);
		volUp.sprite.x = 750; volUp.sprite.y = 450;
		
		vol = new Proto(ecs.createEntity());
		vol.createSprite(S2D, FG);
		vol.createAnim([
			{
				name : "high",
				frameNames : ["VOL_HIGH"],
				loop : false
			},
			{
				name : "medium",
				frameNames : ["VOL_HIGH"],
				loop : false
			},
			{
				name : "low",
				frameNames : ["VOL_HIGH"],
				loop : false
			},
			{
				name : "mute",
				frameNames : ["VOL_MUTE"],
				loop : false
			}
		], "high");
		vol.add(ecs);
		vol.sprite.x = 570; vol.sprite.y = 400;
		
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
			
			if (actions.justPressed.VOL_DOWN) {
				Command.queue(AudioCommand.ADJUST_VOLUME(-0.25, vol -> {
					if (vol < 0.1) Command.queue(MUTE(true));
				}));
			}
			
			else if (actions.justPressed.VOL_UP) {
				Command.queue(AudioCommand.ADJUST_VOLUME(0.25, vol -> {
					if (vol > 0) Command.queue(MUTE(false));
				}));
			}
		}));
	}
}