package;

import states.GameState;
import states.LogoState;
import states.CreatureState;
import utils.Pak;
import hxd.Res;
import mono.app.AMono;
import mono.app.Stage;
import IDs.LayerID;
import IDs.BatchID;
import mono.graphics.RenderCommand;
import states.PreloadState;
import mono.command.Command;
import mono.input.KeyboardInput;
import mono.input.PadInput;
import mono.input.MouseInput;
import input.DefaultMappings;
import mono.input.Input;
import mono.animation.Spritesheet;
import io.newgrounds.NG;
import ecs.Universe;
import ecs.Phase;
import mono.input.InputSystem;
import mono.state.StateSystem;
import mono.graphics.RenderSystem;
import mono.animation.AnimSystem;
import mono.timing.TimingSystem;
import mono.audio.AudioSystem;
import mono.command.CommandSystem;
import IDs.ParentID;
import IDs.SheetID;
import IDs.InputID;
import mono.graphics.DisplayListCommand;
import mono.input.InputCommand;
import mono.animation.AnimCommand;
import mono.state.StateCommand;
import IDs.StateID;
import mono.interactive.InteractiveSystem;
import mono.input.MouseSystem;

class Mono extends AMono {
	
	var loadedIn:Bool;
	
	var ngMedals:Bool; // how should this fit into ecs? NG.core as a resource makes sense, but login occurs before ecs init
	
	public function new(stage:Stage) {
		Pak.init();
		super(stage);
	}
	
	function prepECS() {
		
		stage.engine.backgroundColor = 0xff000000;
		
		// possible that this should go before the preloader
		final ecs = ecsRef = Universe.create({
			entities : 400,
			phases : [
				{
					name : "update",
					enabled : false,
					systems : [
						InteractiveSystem, // leave this before inputsys to correctly handle touch inputs
						InputSystem,
						MouseSystem,
						StateSystem,
						RenderSystem,
						AnimSystem,
						TimingSystem,
						AudioSystem,
						CommandSystem // we usually want this to be the final system
					]
				}
			]
		});
		
		ecs.getPhase("update").enable();
		
		stage.s2d.scaleMode = LetterBox(854, 480);
		
		ecs.setResources(stage.s2d);
		
		var input = new Input();
		var kmap = DefaultMappings.getDefaultKB();
		input.addDevice(new KeyboardInput(kmap));
		var pmap = DefaultMappings.getDefaultPad();
		input.addDevice(new PadInput(pmap));
		var mmap = DefaultMappings.getDefaultMouse();
		input.addDevice(new MouseInput(mmap));
		
		var game = new GameState(ecs);
		var preload = new PreloadState(ecs);
		var logo = new LogoState(ecs);
		var creature = new CreatureState(ecs);
		
		Command.queueMany(
			ADD_PARENT(stage.s2d, S2D),
			ADD_INPUT(input, MENU),
			REGISTER_INPUT(ecs.createEntity(), MENU),
			REGISTER_STATE(game, GAME_STATE),
			REGISTER_STATE(preload, PRELOAD_STATE),
			REGISTER_EXIT(PRELOAD_STATE, postInit),
			REGISTER_STATE(creature, CREATURE_STATE),
			REGISTER_STATE(logo, LOGO_STATE),
			ENTER(GAME_STATE),
			ENTER(PRELOAD_STATE),
		);
		
		loadedIn = true;
	}
	
	function postInit() {
		
		var sprites = new Spritesheet();
		sprites.loadSingle(Res.load("sprites/Cymul.png").toImage(), "cymul"); // iterate json or something
		sprites.loadSingle(Res.load("sprites/Buckot.png").toImage(), "buckot");
		sprites.loadTexturePackerData(Res.load("sprites/sprites.png").toImage(), Res.load("sprites/sprites.txt").toText());
		
		if (ngMedals) ecsRef.setResources(NG.core);
		
		Command.queueMany(
			ADD_SHEET(sprites, SheetID.SPRITES)
		);
	}
}