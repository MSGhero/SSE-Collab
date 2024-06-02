package states;

import IDs.StateID;
import mono.state.StateCommand;
import ecs.Entity;
import h2d.Video;
import mono.audio.AudioCommand;
import mono.input.Input;
import haxe.ds.StringMap;
import IDs.InputID;
import mono.input.InputCommand;
import mono.timing.Timing;
import mono.timing.TimingCommand;
import proto.Proto;
import IDs.LayerID;
import IDs.ParentID;
import mono.graphics.DisplayListCommand;
import hxd.Res;
import h2d.Bitmap;
import mono.command.Command;
import mono.state.State;

class LogoState extends State {
	
	var video:Video;
	var bm:Bitmap;
	var awaitingInput:Bool;
	
	var entity:Entity;
	
	public function init() {
		
	}
	
	public function destroy() {
		
	}
	
	public function reset() {
		
	}
	
	override public function enter() {
		super.enter();
		
		trace("logo state");
		
		entity = ecs.createEntity();
		bm = new Bitmap(Res.load("logo/LOGO (FULL).png").toTile());
		
		#if js
		video = new Video();
		video.loadFile("Logo_Animation.webm", () -> {
			// play audio
			// etc
			awaitingInput = true;
		});
		
		Command.queueMany(
			ADD_TO(video, S2D, FG)
		);
		
		awaitingInput = false;
		#else
		awaitingInput = true;
		#end
		
		Command.queueMany(
			ADD_TO(bm, S2D, BG),
			ADD_UPDATER(entity, Timing.every(1 / 60, update))
		);
	}
	
	override public function exit() {
		super.exit();
		
		ecs.deleteEntity(entity);
	}
	
	function update() {
		
		if (awaitingInput) {
			Command.now(RAW_INPUT(si -> {
				final actions = si.get(MENU);
				
				if (actions.justPressed.SELECT) {
					awaitingInput = false;
					Command.queueMany(
						EXIT(PRELOAD_STATE),
						ENTER(CREATURE_STATE)
					);
				}
			}));
		}
	}
}