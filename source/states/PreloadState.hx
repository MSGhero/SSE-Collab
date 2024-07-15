package states;

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
			spinner.scaleToSize(36, 36);
			spinner.dx = -spinner.width / 2;
			spinner.dy = -spinner.height / 2;
			bm = new Bitmap(spinner);
			bm.x = 500;
			bm.y = 400;
			
			// text = new Text(Res.fonts.aotf.toFont());
			
			final up = Timing.every(1 / 60, update, true);
			
			Command.queueMany(
				DisplayListCommand.ADD_TO(bm, ParentID.S2D, LayerID.BG),
				// DisplayListCommand.ADD_TO(text, ParentID.S2D, LayerID.FG),
				TimingCommand.ADD_UPDATER(entity, up)
			);
			
			Pak.load(["assets.pak"], null, () -> {
				
				trace("assets loaded");
				
				up.paused = true;
				// text.remove();
				
				bm.x = bm.y = 0;
				bm.rotation = 0;
				bm.tile = Res.load("Click_Icon.png").toTile();
				
				final int:Interactive = {
					enabled : true,
					shape : Rect.fromTL(120, 65, 854 - 240, 480 - 105),
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
		ecs.deleteEntity(entity);
	}
	
	function update() {
		bm.rotation += 15 / 360 * 3.14;
		// update text...
	}
}