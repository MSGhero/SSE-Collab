package states;

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
			
			Pak.load(["assets.pak"], null, () -> {
				
				trace("assets loaded");
				
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
			});
		});
	}
	
	override public function exit() {
		super.exit();
		
		bm.remove();
		text.remove();
		ecs.deleteEntity(entity);
	}
	
	override public function update() {
		bm.rotation += 15 / 360 * 3.14;
	}
}