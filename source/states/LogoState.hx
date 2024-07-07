package states;

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

class LogoState extends State {
	
	var video:Video;
	var bm:Bitmap;
	var fg:Bitmap;
	var bg:Bitmap;
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
		fg = new Bitmap(Res.load("logo/BACKGROUND 4.png").toTile());
		bg = new Bitmap(Res.load("logo/BACKGROUND 1.png").toTile());
		bg.addShader(new UVScroll(0.1, 0));
		bg.tileWrap = true;
		
		#if js
		video = new Video();
		video.loadFile("Logo_Animation.webm", () -> {
			
			video.setScale(1 / 2.25);
			video.onEnd = onVideoEnd; // not so sync with ecs
			
			Command.queueMany(
				ADD_TO(video, S2D, FG),
				PLAY(Res.load("sfx/LOGO.ogg").toSound(), {
					type : SFX,
					loop : false
				})
			);
		});
		
		awaitingInput = false;
		#else
		onVideoEnd();
		#end
		
		Command.queueMany(
			ADD_UPDATER(entity, Timing.every(1 / 60, update))
		);
	}
	
	override public function exit() {
		super.exit();
		
		ecs.deleteEntity(entity);
		bm.remove();
		fg.remove();
		bg.remove();
		if (video != null) video.remove();
	}
	
	function update() {
		
		if (awaitingInput) {
			Command.now(RAW_INPUT(si -> {
				final actions = si.get(MENU);
				
				if (actions.justPressed.SELECT) {
					awaitingInput = false;
					Command.queueMany(
						EXIT(LOGO_STATE),
						ENTER(SELECT_STATE)
					);
				}
			}));
		}
	}
	
	function onVideoEnd() {
		
		if (video != null) video.remove();
		
		bg.alpha = fg.alpha = 0;
		
		Command.queueMany(
			ADD_TO(bm, S2D, FG),
			ADD_TO(bg, S2D, BG),
			ADD_TO(fg, S2D, BG),
			ADD_UPDATER(entity, new FloatTweener(0.75, 0, 1, f -> {
				bg.alpha = fg.alpha = f;
			}))
		);
		
		awaitingInput = true;
	}
}