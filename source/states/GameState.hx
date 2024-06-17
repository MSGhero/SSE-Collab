package states;

import mono.geom.Rect;
import proto.Proto;
import h3d.Engine;
import mono.audio.AudioCommand;
import ecs.Entity;
import IDs.InputID;
import mono.input.InputCommand;
import mono.timing.Timing;
import mono.timing.TimingCommand;
import mono.command.Command;
import mono.state.State;

class GameState extends State {
	
	var entity:Entity;
	
	var volDown:Proto;
	var volUp:Proto;
	var vol:Proto;
	var volLevel:Int;
	final volLevels:Array<String> = ["mute", "low", "medium", "high"];
	var oldLevel:Int;
		
	public function init() {
		entity = ecs.createEntity();
		oldLevel = 3;
		volLevel = 3;
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
		volDown.createInteractive({
			shape : Rect.fromTL(500, 450, 50, 50),
			enabled : true,
			onSelect : volumeDown
		});
		volDown.add(ecs);
		volDown.sprite.x = 500; volDown.sprite.y = 450;
		
		volUp = new Proto(ecs.createEntity());
		volUp.createSprite(S2D, FG);
		volUp.createAnim([{
			name : "default",
			frameNames : ["VOL_UP"],
			loop : false
		}]);
		volUp.createInteractive({
			shape : Rect.fromTL(750, 450, 50, 50),
			enabled : true,
			onSelect : volumeUp
		});
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
				frameNames : ["VOL_MEDIUM"],
				loop : false
			},
			{
				name : "low",
				frameNames : ["VOL_LOW"],
				loop : false
			},
			{
				name : "mute",
				frameNames : ["VOL_MUTE"],
				loop : false
			}
		], "high");
		vol.createInteractive({
			shape : Rect.fromTL(570, 400, 157, 145),
			enabled : true,
			onSelect : toggleMute
		});
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