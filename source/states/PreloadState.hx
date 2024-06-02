package states;

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
			bm.x = 300;
			bm.y = 200;
			
			Command.queueMany(
				DisplayListCommand.ADD_TO(bm, ParentID.S2D, LayerID.BG),
				TimingCommand.ADD_UPDATER(entity, Timing.every(1 / 60, update))
			);
			
			Pak.load(["assets.pak"], null, () -> {
				trace("assets loaded");
				Command.queueMany(
					EXIT(PRELOAD_STATE),
					ENTER(LOGO_STATE)
				);
			});
		});
	}
	
	override public function exit() {
		super.exit();
		
		bm.remove();
		ecs.deleteEntity(entity);
	}
	
	function update() {
		bm.rotation += 4 / 180 * 3.14;
	}
}