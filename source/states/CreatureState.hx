package states;

import h2d.Text;
import mono.state.StateCommand;
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
	
	var bgL:Bitmap;
	var bgR:Bitmap;
	var creature:Proto;
	var creatures:Array<String>;
	var creatureIndex:Int;
	
	var trophy:Proto;
	var text:Text;
	
	var entity:Entity;
	
	public function init() {
		
		creatures = ["cymul"];
		
		Command.queue(REGISTER_TRIGGER("setCreature", onSetCreature));
	}
	
	public function destroy() {
		
	}
	
	public function reset() {
		
	}
	
	override public function enter() {
		super.enter();
		
		trace("creature state");
		
		entity = ecs.createEntity();
		
		bgL = new Bitmap(Res.load("bgs/BACKGROUND-B-1.png").toTile());
		bgR = new Bitmap(Res.load("bgs/BACKGROUND-B-2.png").toTile());
		bgR.y = 388;
		
		creatureIndex = 0;
		
		trophy = new Proto(ecs.createEntity());
		trophy.createSprite(S2D, FG);
		trophy.createAnim("trophy");
		trophy.add(ecs);
		trophy.sprite.x = -100; trophy.sprite.y = -50;
		
		/*
		creature = new Proto(ecs.createEntity());
		creature.createSprite(S2D, FG);
		creature.createAnim("", creatures[creatureIndex]);
		creature.add(ecs);
		creature.sprite.x = 275;
		creature.sprite.y = 90;
		*/
		
		text = new Text(hxd.res.DefaultFont.get());
		text.text = "Test text";
		
		Command.queueMany(
			ADD_TO(bgL, ParentID.S2D, LayerID.BG),
			ADD_TO(bgR, ParentID.S2D, LayerID.BG),
			ADD_TO(text, ParentID.S2D, LayerID.FG),
			ADD_UPDATER(entity, Timing.float(0.25, 0, 854, f -> {
				bgL.x = f - 854;
				bgR.x = 854 - f;
			}))
		);
	}
	
	override public function exit() {
		super.exit();
		
		bgL.remove();
		bgR.remove();
	}
	
	override public function update() {
		
		Command.now(InputCommand.RAW_INPUT(handleInput));
	}
	
	function onSetCreature(name:String) {
		text.text = name;
		// creature.anim.play(name);
	}
	
	function handleInput(si:StringMap<Input>) {
		
		final actions = si.get(InputID.MENU);
		/*
		if (actions.justPressed.L) {
			creatureIndex--;
			while (creatureIndex < 0) creatureIndex += creatures.length;
			creature.anim.play(creatures[creatureIndex]);
		}
		
		else if (actions.justPressed.R) {
			creatureIndex = (creatureIndex + 1) % creatures.length;
			creature.anim.play(creatures[creatureIndex]);
		}
		*/
	}
}