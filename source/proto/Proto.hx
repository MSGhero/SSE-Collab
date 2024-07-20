package proto;

import mono.interactive.Interactive;
import mono.graphics.DisplayListCommand;
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
	public var int:Interactive;
	
	public function new(entityID:Entity) {
		this.entityID = entityID;
	}
	
	public function createSprite(parentID:ParentID, layerID:LayerID) {
		sprite = new Picture(null, parentID, layerID);
	}
	
	public function createAnim(prefix:String, play:String = "default") {
		anim = new AnimController(prefix);
		anim.play(play);
	}
	
	public function createInteractive(int:Interactive) {
		this.int = int;
	}
	
	public function add(ecs:Universe) {
		if (int == null) ecs.setComponents(entityID, sprite, anim);
		else ecs.setComponents(entityID, sprite, anim, int);
		Command.queue(DisplayListCommand.ADD_TO(sprite, sprite.parentID, sprite.layerID));
	}
	
	public function remove(ecs:Universe) {
		ecs.deleteEntity(entityID);
		sprite.remove();
	}
}