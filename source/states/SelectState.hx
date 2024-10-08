package states;

import mono.timing.TimingCommand;
import mono.timing.FloatTweener;
import mono.geom.Rect;
import mono.interactive.Interactive;
import IDs.StateID;
import mono.state.StateCommand;
import mono.audio.AudioCommand;
import mono.input.Input;
import haxe.ds.StringMap;
import IDs.InputID;
import mono.input.InputCommand;
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
	var buttons:Array<Interactive>;
	var byType:Bool;
	
	var row:Int;
	var col:Int;
	final maxRows:Int = 4;
	final maxCols:Int = 3;
	
	var oldType:Bool;
	var oldRow:Int;
	var oldCol:Int;
	var oldPage:String;
	
	var ready:Bool;
	
	final selectionX:Int = 360;
	final selectionY:Int = 94;
	
	var entity:Entity;
	
	public static final namesBySubspace:Array<String> = [
		"primid", "sword primid", "boom primid",
		"scope primid", "big primid", "metal primid",
		"fire primid", "glire", "glice",
		"glunder", "poppant", "bytan",
		
		"roader", "bombed", "greap",
		"bucculus", "towtow", "floow",
		"auroros", "buckot", "jyx",
		"gamyga", "feyesh", "trowlon",
		
		"roturret", "spaak", "puppit",
		"shaydas", "mites", "shellpod",
		"nagagog", "cymul", "ticken",
		"armight", "borboras", "autolance",
		
		"armank", "rob sentry", "rob launcher",
		"rob blaster", "mizzo", "goomba",
		"koopa troopa", "koopa paratroopa", "hammer bros",
		"bullet bill", "giant goomba", "galleom",
		
		"duon", "tabuu", "master hand",
		"crazy hand", "petey piranha", "rayquaza",
		"porky", "porky statue", "ridley",
		"meta ridley", "ancient minister", null
	];
	
	public static final namesByType:Array<String> = [
		"primid", "sword primid", "boom primid",
		"scope primid", "big primid", "metal primid",
		"fire primid", null, null,
		null, null, null,
		
		"glire", "glice", "glunder",
		"poppant", "bytan",	"roader",
		"bombed", "greap", "bucculus",
		"towtow", "floow", "auroros",
		
		"buckot", "jyx", "gamyga",
		"feyesh", "trowlon", "roturret",
		"spaak", "puppit", "shaydas",
		"mites", "shellpod", "nagagog",
		
		"cymul", "ticken", "armight",
		"borboras", "autolance", "armank",
		"mizzo", null, null,
		null, null, null,
		
		"rob sentry", "rob launcher", "rob blaster",
		"ancient minister", null, null,
		null, null, null,
		null, null, null,
		
		"goomba", "koopa troopa", "koopa paratroopa",
		"hammer bros", "bullet bill", "giant goomba",
		null, null, null,
		null, null, null,
		
		"galleom", "duon", "tabuu",
		"master hand", "crazy hand", "petey piranha",
		"rayquaza", "porky", "porky statue",
		"ridley", "meta ridley", null
	];
	
	public function init() {
		
		bg = new Bitmap(Res.load("bgs/BACKGROUND-A.png").toTile());
		
		buttons = [];
		
		for (i in 0...12) {
			var int:Interactive = {
				shape : Rect.fromTL(39 + selectionX + (i % maxCols) * 378, 206 + selectionY + Std.int(i / maxCols) * 151, 366, 141),
				enabled : false,
				onOver : () -> {
					row = Std.int(i / maxCols);
					col = i % maxCols;
					positionHighlight();
				},
				onSelect : select
			};
			ecs.setComponents(ecs.createEntity(), int);
			buttons.push(int);
		}
		
		var int:Interactive = {
			shape : Rect.fromTL(selectionX, selectionY, 450, 72),
			enabled : false,
			onSelect : () -> {
				if (byType) {
					byType = false;
					selection.anim.play(byType ? "5" : "0");
					positionHighlight();
				}
			}
		};
		
		ecs.setComponents(ecs.createEntity(), int);
		buttons.push(int);
		
		int = {
			shape : Rect.fromTL(selectionX + 450, selectionY, 450, 72),
			enabled : false,
			onSelect : () -> {
				if (!byType) {
					byType = true;
					selection.anim.play(byType ? "5" : "0");
					positionHighlight();
				}
			}
		};
		
		ecs.setComponents(ecs.createEntity(), int);
		buttons.push(int);
		
		int = {
			shape : Rect.fromTL(selectionX + 198, selectionY + 828, 40, 40),
			enabled : false,
			onSelect : () -> {
				setColumn(col - maxCols);
				positionHighlight();
			}
		};
		
		ecs.setComponents(ecs.createEntity(), int);
		buttons.push(int);
		
		int = {
			shape : Rect.fromTL(selectionX + 972, selectionY + 828, 40, 40),
			enabled : false,
			onSelect : () -> {
				setColumn(col + maxCols);
				positionHighlight();
			}
		};
		
		ecs.setComponents(ecs.createEntity(), int);
		buttons.push(int);
		
		oldType = false;
		oldRow = oldCol = 0;
		oldPage = "0";
		
		Command.queueMany(
			REGISTER_TRIGGER("selFadeIn", onFadeIn),
			REGISTER_TRIGGER("fullAlpha", s -> {
				row = oldRow;
				col = oldCol;
				byType = oldType;
				selection.anim.play(oldPage);
				positionHighlight();
			})
		);
	}
	
	public function destroy() {
		
	}
	
	public function reset() {
		
	}
	
	override public function enter() {
		super.enter();
		
		trace("select state");
		
		entity = ecs.createEntity();
		
		row = col = 0;
		
		selection = new Proto(ecs.createEntity());
		selection.createSprite(S2D, FG);
		selection.createAnim("selection", "0");
		selection.add(ecs);
		// selection.sprite.x = selectionX; selection.sprite.y = selectionY;
		
		highlight = new Proto(ecs.createEntity());
		highlight.createSprite(S2D, FG);
		highlight.createAnim("highlight", "tl");
		highlight.add(ecs);
		positionHighlight();
		
		byType = false;
		
		for (b in buttons) b.enabled = true;
		
		Command.queueMany(
			ADD_TO(bg, ParentID.S2D, LayerID.BG)
		);
	}
	
	override public function exit() {
		super.exit();
		
		selection.remove(ecs);
		highlight.remove(ecs);
		ecs.deleteEntity(entity);
		
		for (b in buttons) b.enabled = false;
	}
	
	override public function update() {
		
		Command.now(InputCommand.RAW_INPUT(handleInput));
	}
	
	function handleInput(si:StringMap<Input>) {
		
		if (!ready) return;
		
		final actions = si.get(InputID.MENU);
		
		if (actions.justPressed.L) {
			setColumn(col - 1);
			positionHighlight();
		}
		
		else if (actions.justPressed.R) {
			setColumn(col + 1);
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
		
		if (actions.justPressed.PAGE_L || actions.justPressed.PAGE_R) {
			byType = !byType;
			selection.anim.play(byType ? "5" : "0");
			positionHighlight();
			Command.queue(
				PLAY(Res.load("sfx/NEXT.ogg").toSound(), {
					type : SFX,
					volume : 1
				})
			);
		}
		
		if (actions.justPressed.SELECT) {
			select();
		}
		
		else if (actions.justPressed.DESELECT) {
			
			ready = false;
			
			final ft = new FloatTweener(0.25, 0, 1, f -> {
				GameState.BLACK.alpha = f;
			});
			
			ft.onComplete = () -> {
				bg.remove();
				Command.queueMany(
					STOP_BY_TYPE(MUSIC),
					EXIT(SELECT_STATE),
					EXIT(GAME_STATE),
					ENTER(LOGO_STATE)
				);
			};
			
			Command.queueMany(
				PLAY(Res.load("sfx/BACK.ogg").toSound(), {
					type : SFX,
					volume : 1
				}),
				ADD_UPDATER(entity, ft)
			);
		}
	}
	
	function onFadeIn(_) {
		
		final ft = new FloatTweener(0.25, 1, 0, f -> {
			GameState.BLACK.alpha = f;
		});
		
		ft.onComplete = () -> ready = true;
		
		Command.queue(ADD_UPDATER(entity, ft));
	}
	
	function setColumn(value:Int) {
		
		col = value;
		
		if (col < 0) {
			col += maxCols;
			selection.anim.play(
				switch (selection.anim.name) {
					case "0": "4";
					case "1": "0";
					case "2": "1";
					case "3": "2";
					case "4": "3";
					case "5": "11";
					case "6": "5";
					case "7": "6";
					case "8": "7";
					case "9": "8";
					case "10": "9";
					case "11": "10";
					default: "0";
				}
			);
		}
		
		else if (col >= maxCols) {
			col -= maxCols;
			selection.anim.play(
				switch (selection.anim.name) {
					case "0": "1";
					case "1": "2";
					case "2": "3";
					case "3": "4";
					case "4": "0";
					case "5": "6";
					case "6": "7";
					case "7": "8";
					case "8": "9";
					case "9": "10";
					case "10": "11";
					case "11": "5";
					default: "0";
				}
			);
		}
	}
	
	function positionHighlight() {
		
		final name = byType ? namesByType[(Std.parseInt(selection.anim.name) - 5) * maxRows * maxCols + row * maxCols + col] : namesBySubspace[Std.parseInt(selection.anim.name) * maxRows * maxCols + row * maxCols + col];
		if (name == null) return;
		
		highlight.sprite.x = 4 + selectionX + col * 378; highlight.sprite.y = 176 + selectionY + row * 151;
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
		
		Command.queue(
			PLAY(Res.load("sfx/NEXT.ogg").toSound(), {
				type : SFX,
				volume : 1
			})
		);
	}
	
	function select() {
		
		final name = byType ? namesByType[(Std.parseInt(selection.anim.name) - 5) * maxRows * maxCols + row * maxCols + col] : namesBySubspace[Std.parseInt(selection.anim.name) * maxRows * maxCols + row * maxCols + col];
		
		if (name != null) {
			oldRow = row;
			oldCol = col;
			oldType = byType;
			oldPage = selection.anim.name;
			Command.queueMany(
				PLAY(Res.load("sfx/SELECT.ogg").toSound(), {
					type : SFX,
					volume : 1
				}),
				EXIT(SELECT_STATE),
				ENTER(CREATURE_STATE),
				TRIGGER("setCreature", name)
			);
		}
	}
}