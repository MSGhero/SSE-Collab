package states;

import io.newgrounds.NGLite.LoginOutcome;
import io.newgrounds.NG;
import mono.animation.AnimCommand;
import IDs.SheetID;
import mono.animation.Spritesheet;
import mono.timing.Updater;
import hxd.res.BitmapFont;
import mono.geom.Rect;
import mono.interactive.Interactive;
import h2d.Text;
import ecs.Entity;
import mono.timing.Timing;
import mono.timing.TimingCommand;
import hxd.Res;
import IDs.LayerID;
import IDs.ParentID;
import mono.graphics.DisplayListCommand;
import h2d.Bitmap;
import utils.Pak;
import mono.command.Command;
import mono.state.State;
import mono.state.StateCommand;
import IDs.StateID;

class PreloadState extends State {
	
	var bm:Bitmap;
	var text:Text;
	var entity:Entity;
	
	var textUp:Updater;
	
	public function init() {
		
	}
	
	public function destroy() {
		
	}
	
	public function reset() {
		
	}
	
	override public function enter() {
		super.enter();
		
		entity = ecs.createEntity();
		
		Pak.load(["preloader.pak"], null, () -> {
			
			trace("preloader loaded");
			
			var spinner = Res.load("Subspace Logo.png").toTile();
			spinner.scaleToSize(80, 80);
			spinner.dx = -spinner.width / 2;
			spinner.dy = -spinner.height / 2;
			bm = new Bitmap(spinner);
			bm.x = 1125;
			bm.y = 900;
			
			text = new Text(Res.load("fonts/aotf_heavy.fnt").to(BitmapFont).toFont());
			text.text = "NOW LOADING.";
			text.x = 1210;
			text.y = 860;
			
			textUp = Timing.every(0.5, -1, () -> {
				text.text = switch (text.text.length) {
					case 12: "NOW LOADING..";
					case 13: "NOW LOADING...";
					case 14: "NOW LOADING....";
					case _: "NOW LOADING.";
				};
			});
			
			Command.queueMany(
				DisplayListCommand.ADD_TO(bm, ParentID.S2D, LayerID.BG),
				DisplayListCommand.ADD_TO(text, ParentID.S2D, LayerID.FG),
				TimingCommand.ADD_UPDATER(entity, textUp)
			);
			
			Pak.load(["ngapi.pak"], null, () -> {
				
				final ng = Res.load("ngapi.txt").toText().split("\r\n");
				final appid = StringTools.trim(ng[0]);
				final key = StringTools.trim(ng[1]);
				
				NG.createAndCheckSession(appid, onLogin);
				ecs.setResources(NG.core);
				NG.core.setupEncryption(key);
				
				if (!NG.core.loggedIn && !NG.core.attemptingLogin) {
					NG.core.requestLogin(onLogin);
				}
				
				Pak.load(["assets.pak"], null, () -> {
					
					trace("assets loaded");
					
					var sprites = new Spritesheet();
					sprites.loadTexturePackerData(Res.load("sprites/sprites.png").toImage(), Res.load("sprites/sprites.txt").toText());
					
					// i hate this but it keeps the preloader going
					Command.queueMany(
						ADD_UPDATER(entity, Timing.delay(0.01, () -> {
							sprites.loadTexturePackerData(Res.load("sprites/creatures-0.png").toImage(), Res.load("sprites/creatures-0.txt").toText());
						}, true)),
						ADD_UPDATER(entity, Timing.delay(0.02, () -> {
							sprites.loadTexturePackerData(Res.load("sprites/creatures-1.png").toImage(), Res.load("sprites/creatures-1.txt").toText());
						}, true)),
						ADD_UPDATER(entity, Timing.delay(0.03, () -> {
							for (i in 1...6) sprites.loadSingle(Res.load('ui/preview/Subspace Page $i.png').toImage(), 'Subspace Page $i');
						}, true)),
						ADD_UPDATER(entity, Timing.delay(0.04, () -> {
							for (i in 1...8) sprites.loadSingle(Res.load('ui/preview/Type Page $i.png').toImage(), 'Type Page $i');
						}, true)),
						ADD_UPDATER(entity, Timing.delay(0.05, () -> {
							onAssetsCrunch();
						}, true)),
						ADD_SHEET(sprites, SheetID.SPRITES)
					);
				});
			});
		});
	}
	
	override public function exit() {
		super.exit();
		
		bm.remove();
		text.remove();
		ecs.deleteEntity(entity);
	}
	
	function onLogin(lo:LoginOutcome) {
		
		switch (lo) {
			case SUCCESS:
				trace("logged in");
				NG.core.requestMedals(o -> {
					switch (o) {
						case SUCCESS:
							final medal = NG.core.medals.getById(79389);
							if (!medal.unlocked) medal.sendUnlock();
						case FAIL(error):
							trace(error);
					}
				});
			case FAIL(error):
				trace(error);
		}
	}
	
	function onAssetsCrunch() {
		
		active = false;
		
		text.remove();
		text.text = "";
		
		textUp.paused = true;
		textUp.dispose();
		
		bm.x = bm.y = 0;
		bm.rotation = 0;
		bm.tile = Res.load("Click_Icon.png").toTile();
		
		final int:Interactive = {
			enabled : true,
			shape : Rect.fromTL(270, 146, 1920 - 540, 1080 - 292),
			onOver : () -> {
				bm.tile = Res.load("Click_Icon_2.png").toTile();
			},
			onOut : () -> {
				bm.tile = Res.load("Click_Icon.png").toTile();
			},
			onSelect : () -> {
				Command.queueMany(
					EXIT(PRELOAD_STATE)
				);
			}
		};
		
		ecs.setComponents(entity, int);
	}
	
	override public function update() {
		if (bm != null) bm.rotation += 15 / 360 * 3.14;
	}
}