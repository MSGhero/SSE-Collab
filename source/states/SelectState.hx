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

class SelectState extends State {
	
	var bg:Bitmap;
	
	var selection:Proto;
	var byType:Bool;
	
	var entity:Entity;
	
	public function init() {
		
	}
	
	public function destroy() {
		
	}
	
	public function reset() {
		
	}
	
	override public function enter() {
		super.enter();
		
		trace("select state");
		
		entity = ecs.createEntity();
		
		bg = new Bitmap(Res.load("bgs/BACKGROUND-A.png").toTile());
		
		selection = new Proto(ecs.createEntity());
		selection.createSprite(S2D, FG);
		selection.createAnim([
			{
				name : "0",
				frameNames : ["Subspace Page 1"],
				loop : false
			},
			{
				name : "1",
				frameNames : ["Subspace Page 2"],
				loop : false
			},
			{
				name : "2",
				frameNames : ["Subspace Page 3"],
				loop : false
			},
			{
				name : "3",
				frameNames : ["Subspace Page 4"],
				loop : false
			},
			{
				name : "4",
				frameNames : ["Subspace Page 5"],
				loop : false
			},/*
			{
				name : "5",
				frameNames : ["Type Page 1"],
				loop : false
			},
			{
				name : "6",
				frameNames : ["Type Page 2"],
				loop : false
			},
			{
				name : "7",
				frameNames : ["Type Page 3"],
				loop : false
			},
			{
				name : "8",
				frameNames : ["Type Page 4"],
				loop : false
			},
			{
				name : "9",
				frameNames : ["Type Page 5"],
				loop : false
			},
			{
				name : "10",
				frameNames : ["Type Page 6"],
				loop : false
			},
			{
				name : "11",
				frameNames : ["Type Page 7"],
				loop : false
			},*/
		], "0");
		selection.add(ecs);
		selection.sprite.x = 158; selection.sprite.y = 42;
		
		byType = false;
		
		Command.queueMany(
			ADD_TO(bg, ParentID.S2D, LayerID.BG),
			ADD_UPDATER(entity, Timing.every(1 / 60, update)),
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
		selection.remove(ecs);
	}
	
	function update() {
		
		Command.now(InputCommand.RAW_INPUT(handleInput));
	}
	
	function handleInput(si:StringMap<Input>) {
		
		final actions = si.get(InputID.MENU);
		
		if (actions.justPressed.L) {
			var frame = Std.parseInt(selection.anim.name) - 1;
			while (frame < 0) frame += 5;
			selection.anim.play(Std.string(frame));
		}
		
		else if (actions.justPressed.R) {
			var frame = Std.parseInt(selection.anim.name) + 1;
			while (frame >= 5) frame -= 5;
			selection.anim.play(Std.string(frame));
		}
	}
}