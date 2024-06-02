package states;

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

class CreatureState extends State {
	
	var bg:Bitmap;
	var creature:Proto;
	var creatures:Array<String>;
	var creatureIndex:Int;
	
	public function init() {
		
		creatures = ["cymul", "buckot"];
	}
	
	public function destroy() {
		
	}
	
	public function reset() {
		
	}
	
	override public function enter() {
		super.enter();
		
		trace("creature state");
		
		bg = new Bitmap(Res.load("bgs/bg.png").toTile());
		
		creatureIndex = 0;
		
		creature = new Proto(ecs.createEntity());
		creature.createSprite(S2D, FG);
		creature.createAnim([
			{
				name : "cymul",
				frameNames : ["cymul"],
				loop : false
			},
			{
				name : "buckot",
				frameNames : ["buckot"],
				loop : false
			},
		], creatures[creatureIndex]);
		creature.add(ecs);
		creature.sprite.scale(0.5);
		
		Command.queueMany(
			DisplayListCommand.ADD_TO(bg, ParentID.S2D, LayerID.BG),
			TimingCommand.ADD_UPDATER(ecs.createEntity(), Timing.every(1 / 60, update)),
			/*
			AudioCommand.PLAY(Res.load("music/Trophy_Gallery.ogg").toSound(), {
				type : MUSIC,
				loop : true
			})
			*/
		);
	}
	
	override public function exit() {
		super.exit();
		
	}
	
	function update() {
		
		Command.now(InputCommand.RAW_INPUT(handleInput));
	}
	
	function handleInput(si:StringMap<Input>) {
		
		final actions = si.get(InputID.MENU);
		
		if (actions.justPressed.L) {
			creatureIndex--;
			while (creatureIndex < 0) creatureIndex += creatures.length;
			creature.anim.play(creatures[creatureIndex]);
		}
		
		else if (actions.justPressed.R) {
			creatureIndex = (creatureIndex + 1) % creatures.length;
			creature.anim.play(creatures[creatureIndex]);
		}
	}
}