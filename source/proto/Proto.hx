package proto;

import mono.graphics.DisplayListCommand;
import mono.animation.AnimRequest;
import IDs.SheetID;
import mono.animation.AnimCommand;
import mono.command.Command;
import mono.animation.AnimController;
import IDs.LayerID;
import IDs.ParentID;
import mono.graphics.Picture;
import ecs.Universe;
import ecs.Entity;

class Proto {
	
	public final entityID:Entity;
	public var sprite:Picture;
	public var anim:AnimController;
	
	public function new(entityID:Entity) {
		this.entityID = entityID;
	}
	
	public function createSprite(parentID:ParentID, layerID:LayerID) {
		sprite = new Picture(null, parentID, layerID);
	}
	
	public function createAnim(reqs:Array<AnimRequest>, play:String = "default") {
		
		if (anim == null) {
			anim = new AnimController();
		}
		
		Command.queue(AnimCommand.CREATE_ANIMATION(entityID, SheetID.SPRITES, reqs, play, anim));
	}
	
	public function add(ecs:Universe) {
		ecs.setComponents(entityID, sprite, anim);
		Command.queue(DisplayListCommand.ADD_TO(sprite, sprite.parentID, sprite.layerID));
	}
	
	public function remove(ecs:Universe) {
		ecs.deleteEntity(entityID);
		sprite.remove();
	}
}