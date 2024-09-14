package states;

import IDs.ParentID;
import IDs.LayerID;
import mono.graphics.DisplayListCommand;
import h2d.Tile;
import h2d.Bitmap;
import mono.geom.Rect;
import proto.Proto;
import h3d.Engine;
import mono.audio.AudioCommand;
import IDs.InputID;
import mono.input.InputCommand;
import mono.timing.Timing;
import mono.timing.TimingCommand;
import mono.command.Command;
import mono.state.State;

class GameState extends State {
	
	var volDown:Proto;
	var volUp:Proto;
	var vol:Proto;
	var volLevel:Int;
	final volLevels:Array<String> = ["mute", "low", "medium", "high"];
	var oldLevel:Int;
	
	public static var BLACK:Bitmap;
		
	public function init() {
		
		oldLevel = 3;
		volLevel = 3;
		
		volDown = new Proto(ecs.createEntity());
		volDown.createSprite(S2D, UI);
		volDown.createAnim("volDown");
		volDown.createInteractive({
			shape : Rect.fromTL(37, 72, 33, 31),
			enabled : true,
			onSelect : volumeDown
		});
		
		volUp = new Proto(ecs.createEntity());
		volUp.createSprite(S2D, UI);
		volUp.createAnim("volUp");
		volUp.createInteractive({
			shape : Rect.fromTL(164, 65, 32, 31),
			enabled : true,
			onSelect : volumeUp
		});
		
		vol = new Proto(ecs.createEntity());
		vol.createSprite(S2D, UI);
		vol.createAnim("vol", "high");
		vol.createInteractive({
			shape : Rect.fromTL(70, 38, 94, 85),
			enabled : true,
			onSelect : toggleMute
		});
		
		BLACK = new Bitmap(Tile.fromColor(0x0, 1920, 1080, 1));
		BLACK.alpha = 0;
		
		Command.queue(ADD_TO(BLACK, S2D, UI));
		
		active = true;
	}
	
	public function destroy() {
		
	}
	
	public function reset() {
		
	}
	
	override public function enter() {
		// super.enter(); // always active
		
		volDown.add(ecs);
		volUp.add(ecs);
		vol.add(ecs);
	}
	
	override public function exit() {
		// super.exit(); // always active
		
		volDown.remove(ecs);
		volUp.remove(ecs);
		vol.remove(ecs);
	}
	
	override public function update() {
		
		Command.now(RAW_INPUT(si -> {
			final actions = si.get(MENU);
			
			if (actions.justPressed.FULLSCREEN) {
				Engine.getCurrent().fullScreen = !Engine.getCurrent().fullScreen;
			}
			
			if (actions.justPressed.VOL_DOWN) {
				volumeDown();
			}
			
			else if (actions.justPressed.VOL_UP) {
				volumeUp();
			}
			
			if (actions.justPressed.MUTE) {
				toggleMute();
			}
		}));
	}
	
	function volumeDown() {
		
		if (volLevel > 0) {
			
			volLevel--;
			oldLevel = volLevel <= 0 ? 1 : volLevel;
			vol.anim.play(volLevels[volLevel]);
			
			Command.queue(AudioCommand.SET_VOLUME(volLevel * 0.3333, null));
		}
	}
	
	function volumeUp() {
		
		if (volLevel < 3) {
			
			volLevel++;
			oldLevel = volLevel;
			vol.anim.play(volLevels[volLevel]);
			
			Command.queue(AudioCommand.SET_VOLUME(volLevel * 0.3333, null));
		}
	}
	
	function toggleMute() {
		Command.queue(MUTE_TOGGLE(muted -> {
			
			if (muted) {
				volLevel = 0;
				vol.anim.play(volLevels[volLevel]);
			}
			else {
				volLevel = oldLevel;
				vol.anim.play(volLevels[volLevel]);
			}
			
			Command.queue(AudioCommand.SET_VOLUME(volLevel * 0.3333, null));
		}));
	}
}