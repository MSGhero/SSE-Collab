package states;

import io.newgrounds.NG;
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
	var arrows:Bitmap;
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
	var larrowInt:Interactive;
	var rarrowInt:Interactive;
	
	var l0Ent:Entity;
	var l1Ent:Entity;
	var larrowEnt:Entity;
	var rarrowEnt:Entity;
	
	var entity:Entity;
	
	public function init() {
		
		creatures = SelectState.namesByType.filter(f -> f != null); // get rid of placeholder nulls
		
		bgL = new Bitmap(Res.load("bgs/BACKGROUND-B-1.png").toTile());
		bgR = new Bitmap(Res.load("bgs/BACKGROUND-B-2.png").toTile());
		bgR.y = 873;
		arrows = new Bitmap(Res.load("ui/selection/Green Arrows.png").toTile());
		
		var fnt = Res.load("fonts/aotf.fnt").to(BitmapFont).toFont();
		
		nameText = new Text(fnt);
		nameText.text = "Test text";
		nameText.x = 1000; nameText.y = 82;
		nameText.maxWidth = 600;
		nameText.textAlign = Center;
		
		var txtFnt = Res.load("fonts/aotf_heavy_48.fnt").to(BitmapFont).toFont();
		
		text = new Text(txtFnt);
		text.text = "Test text";
		text.x = 1000; text.y = 225;
		text.maxWidth = 600;
		
		linkText = new Text(txtFnt);
		linkText.text = "";
		linkText.x = 1000; linkText.y = 890;
		
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
				shape : Rect.fromTL(1000, 890, 250, 48),
				enabled : true,
				onSelect : () -> {
					final cr = infoMap.get(creatures[creatureIndex]);
					final links = cr.profiles;
					if (links.length > 0) {
						System.openURL(links[0]);
						cr.linkViewed = true;
						checkLinksViewed();
					}
				}
			},
			{
				shape : Rect.fromTL(1000, 890 + 48, 250, 48),
				enabled : true,
				onSelect : () -> {
					final cr = infoMap.get(creatures[creatureIndex]);
					final links = cr.profiles;
					if (links.length > 1) {
						System.openURL(links[1]);
						cr.linkViewed = true;
						checkLinksViewed();
					}
				}
			}
		];
		
		larrowInt = {
			shape : Rect.fromTL(986, 90, 59, 63),
			enabled : true,
			onSelect : onLeft
		};
		
		rarrowInt = {
			shape : Rect.fromTL(1526, 90, 59, 63),
			enabled : true,
			onSelect : onRight
		};
		
		Command.queue(REGISTER_TRIGGER("setCreature", onSetCreature));
		
		infoMap = new StringMap();
		var json:Array<DynamicAccess<Dynamic>> = Json.parse(Res.load("specs/Subspace Text.json").toText());
		for (d in json) {
			infoMap.set(d.get("image"), {
				title : d.get("title"),
				artist : d.get("artist"),
				description : d.get("description"),
				profiles : d.get("profile"),
				viewed : false,
				linkViewed : false
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
		
		l0Ent = ecs.createEntity();
		l1Ent = ecs.createEntity();
		larrowEnt = ecs.createEntity();
		rarrowEnt = ecs.createEntity();
		
		ecs.setComponents(l0Ent, linkInts[0]);
		ecs.setComponents(l1Ent, linkInts[1]);
		ecs.setComponents(larrowEnt, larrowInt);
		ecs.setComponents(rarrowEnt, rarrowInt);
		
		creatureIndex = 0;
		
		trophy = new Proto(ecs.createEntity());
		trophy.createSprite(S2D, FG);
		trophy.createAnim("trophy");
		trophy.add(ecs);
		trophy.sprite.x = -120; trophy.sprite.y = 0;
		trophy.sprite.setScale(2);
		
		creature = new Proto(ecs.createEntity());
		creature.createSprite(S2D, FG);
		creature.createAnim("creature", creatures[creatureIndex]);
		creature.add(ecs);
		
		Command.queueMany(
			ADD_TO(bgL, ParentID.S2D, LayerID.BG),
			ADD_TO(bgR, ParentID.S2D, LayerID.BG),
			ADD_TO(arrows, ParentID.S2D, LayerID.BG),
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
		arrows.remove();
		nameText.remove();
		text.remove();
		linkText.remove();
		
		trophy.remove(ecs);
		creature.remove(ecs);
		
		ecs.deleteEntity(entity);
		ecs.deleteEntity(l0Ent);
		ecs.deleteEntity(l1Ent);
		ecs.deleteEntity(larrowEnt);
		ecs.deleteEntity(rarrowEnt);
	}
	
	override public function update() {
		
		Command.now(InputCommand.RAW_INPUT(handleInput));
	}
	
	function onSetCreature(name:String) {
		
		if (name == null) return;
		
		var cr = infoMap.get(name);
		
		nameText.text = cr.title;
		text.text = cr.description;
		linkText.text = cr.artist;
		
		linkInts[1].enabled = cr.profiles.length > 1;
		
		creature.anim.play(name);
		trophy.anim.play("default");
		trophy.anim.pause();
		
		creatureIndex = creatures.indexOf(name);
		
		cr.viewed = true;
		checkViewed();
		
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
			onLeft();
		}
		
		else if (actions.justPressed.R) {
			onRight();
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
	
	function onLeft() {
		
		creatureIndex--;
		while (creatureIndex < 0) creatureIndex += creatures.length;
		onSetCreature(creatures[creatureIndex]);
		Command.queue(PLAY(Res.load("sfx/NEXT.ogg").toSound(), {
			type : SFX,
			volume : 1
		}));
	}
	
	function onRight() {
		
		creatureIndex = (creatureIndex + 1) % creatures.length;
		onSetCreature(creatures[creatureIndex]);
		Command.queue(PLAY(Res.load("sfx/NEXT.ogg").toSound(), {
			type : SFX,
			volume : 1
		}));
	}
	
	function checkLinksViewed() {
		
		if (NG.core?.loggedIn) {
			
			final medal = NG.core.medals.getById(79391);
			
			if (!medal.unlocked) {
				
				var b = true;
				for (v in infoMap) {
					if (!v.linkViewed) {
						b = false;
						break;
					}
				}
				
				if (b) medal.sendUnlock();
			}
		}
	}
	
	function checkViewed() {
		
		if (NG.core?.loggedIn) {
			
			final medal = NG.core.medals.getById(79390);
			
			if (!medal.unlocked) {
				
				var b = true;
				for (v in infoMap) {
					if (!v.viewed) {
						b = false;
						break;
					}
				}
				
				if (b) medal.sendUnlock();
			}
		}
	}
}

@:structInit
private class CreatureInfo {
	public final title:String;
	public final artist:String;
	public final description:String;
	public final profiles:Array<String>;
	public var viewed:Bool;
	public var linkViewed:Bool;
}