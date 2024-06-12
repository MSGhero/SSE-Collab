package states;

import mono.animation.AnimRangeParser;
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
import ecs.Entity;

class CreatureState extends State {
	
	var bg:Bitmap;
	var bgL:Bitmap;
	var bgR:Bitmap;
	var creature:Proto;
	var creatures:Array<String>;
	var creatureIndex:Int;
	
	var trophy:Proto;
	
	var entity:Entity;
	
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
		
		entity = ecs.createEntity();
		
		bg = new Bitmap(Res.load("bgs/BACKGROUND-A.png").toTile());
		bgL = new Bitmap(Res.load("bgs/BACKGROUND-B-1.png").toTile());
		bgR = new Bitmap(Res.load("bgs/BACKGROUND-B-2.png").toTile());
		bgR.y = 388;
		
		creatureIndex = 0;
		
		trophy = new Proto(ecs.createEntity());
		trophy.createSprite(S2D, FG);
		trophy.createAnim([
			{
				name : "default",
				frameNames : AnimRangeParser.parseRanges(["trophy01-52"]),
				loop : true,
				fps : 10
			}
		]);
		trophy.add(ecs);
		
		/*
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
		creature.sprite.x = 275;
		creature.sprite.y = 90;
		*/
		
		Command.queueMany(
			ADD_TO(bg, ParentID.S2D, LayerID.BG),
			ADD_TO(bgL, ParentID.S2D, LayerID.BG),
			ADD_TO(bgR, ParentID.S2D, LayerID.BG),
			ADD_UPDATER(entity, Timing.every(1 / 60, update)),
			ADD_UPDATER(entity, Timing.float(0.75, 0, 854, f -> {
				bgL.x = f - 854;
				bgR.x = 854 - f;
			})),
			PLAY(Res.load("music/Trophy_Gallery.ogg").toSound(), {
				type : MUSIC,
				loop : true,
				volume : 1.0
			})
		);
	}
	
	override public function exit() {
		super.exit();
		
		bg.remove();
		bgL.remove();
		bgR.remove();
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