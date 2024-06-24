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
	var highlight:Proto;
	var byType:Bool;
	
	var row:Int;
	var col:Int;
	final maxRows:Int = 4;
	final maxCols:Int = 3;
	final ssPages:Int = 5;
	
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
		
		row = col = 0;
		
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
		
		highlight = new Proto(ecs.createEntity());
		highlight.createSprite(S2D, FG);
		highlight.createAnim([
			{
				name : "tl",
				frameNames : ["tl"],
				loop : false
			},
			{
				name : "tm",
				frameNames : ["tm"],
				loop : false
			},
			{
				name : "tr",
				frameNames : ["tr"],
				loop : false
			},
			{
				name : "ml",
				frameNames : ["ml"],
				loop : false
			},
			{
				name : "m",
				frameNames : ["m"],
				loop : false
			},
			{
				name : "mr",
				frameNames : ["mr"],
				loop : false
			},
			{
				name : "bl",
				frameNames : ["bl"],
				loop : false
			},
			{
				name : "bm",
				frameNames : ["bm"],
				loop : false
			},
			{
				name : "br",
				frameNames : ["br"],
				loop : false
			},
			{
				name : "lr",
				frameNames : ["lr"],
				loop : false
			},
			{
				name : "tb",
				frameNames : ["tb"],
				loop : false
			},
		], "tl");
		highlight.add(ecs);
		positionHighlight();
		
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
		highlight.remove(ecs);
	}
	
	function update() {
		
		Command.now(InputCommand.RAW_INPUT(handleInput));
	}
	
	function handleInput(si:StringMap<Input>) {
		
		final actions = si.get(InputID.MENU);
		
		if (actions.justPressed.L) {
			col--;
			while (col < 0) col += maxCols;
			positionHighlight();
		}
		
		else if (actions.justPressed.R) {
			col = (col + 1) % maxCols;
			positionHighlight();
		}
		
		if (actions.justPressed.U) {
			row--;
			while (row < 0) row += maxRows;
			positionHighlight();
		}
		
		else if (actions.justPressed.D) {
			row = (row + 1) % maxRows;
			positionHighlight();
		}
	}
	
	function positionHighlight() {
		
		highlight.sprite.x = 2 + selection.sprite.x + col * 168; highlight.sprite.y = 78 + selection.sprite.y + row * 67;
		var frame = "";
		
		if (col <= 0) {
			if (row <= 0) frame = "tl";
			else if (row >= maxRows - 1) frame = "bl";
			else frame = "ml";
		}
		
		else if (col >= maxCols - 1) {
			if (row <= 0) frame = "tr";
			else if (row >= maxRows - 1) frame = "br";
			else frame = "mr";
		}
		
		else {
			if (row <= 0) frame = "tm";
			else if (row >= maxRows - 1) frame = "bm";
			else frame = "m";
		}
		
		if (highlight.anim.isReady) highlight.anim.play(frame);
	}
}