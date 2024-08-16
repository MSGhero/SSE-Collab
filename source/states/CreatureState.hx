package states;

import hxd.System;
import mono.geom.Rect;
import mono.interactive.Interactive;
import mono.timing.Tweener;
import mono.timing.Updater;
import hxd.res.BitmapFont;
import haxe.DynamicAccess;
import haxe.Json;
import IDs.StateID;
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
	var delay:Updater;
	var rotate:Tweener;
	
	var trophy:Proto;
	var nameText:Text;
	var text:Text;
	var linkText:Text;
	var infoMap:StringMap<CreatureInfo>;
	
	var linkInts:Array<Interactive>;
	
	var entity:Entity;
	
	public function init() {
		
		creatures = SelectState.namesByType.filter(f -> f != null); // get rid of placeholder nulls
		
		bgL = new Bitmap(Res.load("bgs/BACKGROUND-B-1.png").toTile());
		bgR = new Bitmap(Res.load("bgs/BACKGROUND-B-2.png").toTile());
		bgR.y = 873;
		
		var fnt = Res.load("fonts/aotf.fnt").to(BitmapFont).toFont();
		
		nameText = new Text(fnt);
		nameText.text = "Test text";
		nameText.x = 1125; nameText.y = 112;
		
		var txtFnt = Res.load("fonts/aotf_heavy.fnt").to(BitmapFont).toFont();
		
		text = new Text(txtFnt);
		text.text = "Test text";
		text.x = 1125; text.y = 225;
		text.maxWidth = 675;
		
		linkText = new Text(txtFnt);
		linkText.text = "";
		linkText.x = 1125; linkText.y = 900;
		
		delay = Timing.delay(3, startRotation, false);
		delay.repetitions = 0;
		
		rotate = Timing.tween(52 / 20, f -> {
			creature.sprite.scaleX = f;
			creature.sprite.x = 596 * (1 - f);
		}, null, f -> Math.cos(2 * Math.PI * f), false);
		rotate.repetitions = 0;
		rotate.onCancel = () -> {
			creature.sprite.scaleX = 1;
			creature.sprite.x = 0;
		};
		
		linkInts = [
			{
				shape : Rect.fromTL(1125, 900, 562, 90),
				enabled : true,
				onSelect : () -> {
					final links = linkText.text.split("\n");
					if (links.length > 0) System.openURL(links[0]);
				}
			},
			{
				shape : Rect.fromTL(1125, 990, 562, 90),
				enabled : true,
				onSelect : () -> {
					final links = linkText.text.split("\n");
					System.openURL(links.length > 1 ? links[1] : links[0]);
				}
			}
		];
		
		Command.queue(REGISTER_TRIGGER("setCreature", onSetCreature));
		
		infoMap = new StringMap();
		var json:Array<DynamicAccess<Dynamic>> = Json.parse(Res.load("specs/Subspace Text.json").toText());
		for (d in json) {
			infoMap.set(d.get("image"), {
				title : d.get("title"),
				artist : d.get("artist"),
				description : d.get("description"),
				profiles : d.get("profile")
			});
		}
	}
	
	public function destroy() {
		
	}
	
	public function reset() {
		
	}
	
	override public function enter() {
		super.enter();
		
		trace("creature state");
		
		entity = ecs.createEntity();
		
		creatureIndex = 0;
		
		trophy = new Proto(ecs.createEntity());
		trophy.createSprite(S2D, FG);
		trophy.createAnim("trophy");
		trophy.add(ecs);
		trophy.sprite.x = -100; trophy.sprite.y = -50;
		
		creature = new Proto(ecs.createEntity());
		creature.createSprite(S2D, FG);
		creature.createAnim("creature", creatures[creatureIndex]);
		creature.add(ecs);
		
		Command.queueMany(
			ADD_TO(bgL, ParentID.S2D, LayerID.BG),
			ADD_TO(bgR, ParentID.S2D, LayerID.BG),
			ADD_TO(nameText, ParentID.S2D, LayerID.FG),
			ADD_TO(text, ParentID.S2D, LayerID.FG),
			ADD_TO(linkText, ParentID.S2D, LayerID.FG),
			ADD_UPDATER(entity, Timing.float(0.1, 0, 1920, f -> {
				bgL.x = f - 1920;
				bgR.x = 1920 - f;
			})),
			ADD_UPDATER(entity, delay),
			ADD_UPDATER(entity, rotate)
		);
	}
	
	override public function exit() {
		super.exit();
		
		bgL.remove();
		bgR.remove();
		nameText.remove();
		text.remove();
		linkText.remove();
		
		trophy.remove(ecs);
		creature.remove(ecs);
		
		ecs.deleteEntity(entity);
	}
	
	override public function update() {
		
		Command.now(InputCommand.RAW_INPUT(handleInput));
	}
	
	function onSetCreature(name:String) {
		
		if (name == null) return;
		
		var cr = infoMap.get(name);
		
		nameText.text = cr.title;
		text.text = cr.description;
		linkText.text = cr.profiles.join("\n");
		
		creature.anim.play(name);
		trophy.anim.play("default");
		trophy.anim.pause();
		
		creatureIndex = creatures.indexOf(name);
		
		rotate.cancel();
		delay.resetCounter();
		delay.repetitions = 1;
	}
	
	function startRotation() {
		trophy.anim.resume();
		rotate.repetitions = -1;
		rotate.resetCounter();
	}
	
	function handleInput(si:StringMap<Input>) {
		
		final actions = si.get(InputID.MENU);
		
		if (actions.justPressed.L) {
			creatureIndex--;
			while (creatureIndex < 0) creatureIndex += creatures.length;
			onSetCreature(creatures[creatureIndex]);
			Command.queue(PLAY(Res.load("sfx/NEXT.ogg").toSound(), {
				type : SFX,
				volume : 1
			}));
		}
		
		else if (actions.justPressed.R) {
			creatureIndex = (creatureIndex + 1) % creatures.length;
			onSetCreature(creatures[creatureIndex]);
			Command.queue(PLAY(Res.load("sfx/NEXT.ogg").toSound(), {
				type : SFX,
				volume : 1
			}));
		}
		
		if (actions.justPressed.DESELECT) {
			Command.queueMany(
				PLAY(Res.load("sfx/BACK.ogg").toSound(), {
					type : SFX,
					volume : 1
				}),
				EXIT(CREATURE_STATE),
				ENTER(SELECT_STATE),
				TRIGGER("fullAlpha", "")
			);
		}
	}
}

@:structInit
private class CreatureInfo {
	public final title:String;
	public final artist:String;
	public final description:String;
	public final profiles:Array<String>;
}