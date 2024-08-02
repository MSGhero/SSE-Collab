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
	var videoEnded:Bool;
	
	var entity:Entity;
	
	public function init() {
		
		bm = new Bitmap(Res.load("logo/LOGO (FULL).png").toTile());
		fg = new Bitmap(Res.load("logo/BACKGROUND 4.png").toTile());
		
		bg = new Bitmap(Res.load("logo/BACKGROUND 1.png").toTile());
		bg.addShader(new UVScroll(0.1, 0));
		bg.tileWrap = true;
	}
	
	public function destroy() {
		
	}
	
	public function reset() {
		
	}
	
	override public function enter() {
		super.enter();
		
		trace("logo state");
		
		entity = ecs.createEntity();
		
		#if js
		video = new Video();
		videoEnded = false;
		video.loadFile("Logo_Animation.webm", () -> {
			
			video.setScale(1 / 2.25);
			video.onEnd = onVideoEnd; // not so sync with ecs
			
			Command.queueMany(
				ADD_TO(video, S2D, FG),
				PLAY(Res.load("sfx/LOGO.ogg").toSound(), {
					type : SFX,
					loop : false,
					volume : 0.7
				})
			);
		});
		
		awaitingInput = false;
		#else
		onVideoEnd();
		#end
	}
	
	override public function exit() {
		super.exit();
		
		ecs.deleteEntity(entity);
		bm.remove();
		fg.remove();
		bg.remove();
		
		if (video != null) {
			video.remove();
			video.dispose();
		}
		
		// add fadeout?
	}
	
	override public function update() {
		
		if (videoEnded) {
			
			if (video != null) video.remove();
			
			bg.alpha = fg.alpha = 0;
			
			final ft = new FloatTweener(0.75, 0, 1, f -> {
				bg.alpha = fg.alpha = f;
			});
			
			ft.onComplete = () -> {
				Command.queueMany(
					PLAY(Res.load("music/Save Point.ogg").toSound(), {
						type : MUSIC,
						loop : true,
						volume : 1.0
					}),
					FADE(2, 0, 1, null, "music")
				);
			};
			
			Command.queueMany(
				ADD_TO(bm, S2D, FG),
				ADD_TO(bg, S2D, BG),
				ADD_TO(fg, S2D, BG),
				ADD_UPDATER(entity, ft)
			);
			
			awaitingInput = true;
			videoEnded = false;
		}
		
		if (awaitingInput) {
			Command.now(RAW_INPUT(si -> {
				final actions = si.get(MENU);
				
				if (actions.justPressed.SELECT || actions.justPressed.MOUSE) {
					awaitingInput = false;
					Command.queueMany(
						PLAY(Res.load("sfx/START.ogg").toSound(), {
							type : SFX,
							volume : 0.7
						}),
						STOP_BY_TYPE(MUSIC),
						EXIT(LOGO_STATE),
						ENTER(SELECT_STATE),
						PLAY(Res.load("music/Trophy_Gallery.ogg").toSound(), {
							type : MUSIC,
							loop : true,
							volume : 1.0
						})
					);
				}
			}));
		}
	}
	
	function onVideoEnd() {
		// queue up handling to keep consistent with ecs timings
		videoEnded = true;
	}
}