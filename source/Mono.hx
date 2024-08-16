package;

import states.SelectState;
import states.GameState;
import states.LogoState;
import states.CreatureState;
import utils.Pak;
import hxd.Res;
import mono.app.AMono;
import mono.app.Stage;
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
		
		final ecs = ecsRef = Universe.create({
			entities : 100,
			phases : [
				{
					name : "update",
					enabled : false,
					systems : [
						InteractiveSystem, // leave this before inputsys to correctly handle touch inputs
						InputSystem,
						MouseSystem,
						RenderSystem,
						AnimSystem,
						TimingSystem,
						AudioSystem,
						CommandSystem,
						StateSystem,
					]
				}
			]
		});
		
		ecs.getPhase("update").enable();
		
		stage.s2d.scaleMode = LetterBox(1920, 1080);
		
		ecs.setResources(stage.s2d);
		
		var input = new Input();
		var kmap = DefaultMappings.getDefaultKB();
		input.addDevice(new KeyboardInput(kmap));
		var pmap = DefaultMappings.getDefaultPad();
		input.addDevice(new PadInput(pmap));
		var mmap = DefaultMappings.getDefaultMouse();
		input.addDevice(new MouseInput(mmap));
		
		var preload = new PreloadState(ecs);
		
		Command.queueMany(
			ADD_PARENT(stage.s2d, S2D),
			ADD_INPUT(input, MENU),
			REGISTER_INPUT(ecs.createEntity(), MENU),
			REGISTER_STATE(preload, PRELOAD_STATE),
			REGISTER_EXIT(PRELOAD_STATE, postPreload),
			ENTER(PRELOAD_STATE),
		);
		
		loadedIn = true;
	}
	
	function postPreload() {
		
		var sprites = new Spritesheet();
		sprites.loadTexturePackerData(Res.load("sprites/sprites.png").toImage(), Res.load("sprites/sprites.txt").toText());
		sprites.loadTexturePackerData(Res.load("sprites/creatures.png").toImage(), Res.load("sprites/creatures.txt").toText());
		for (i in 1...6) sprites.loadSingle(Res.load('ui/preview/Subspace Page $i.png').toImage(), 'Subspace Page $i');
		for (i in 1...8) sprites.loadSingle(Res.load('ui/preview/Type Page $i.png').toImage(), 'Type Page $i');
		
		if (ngMedals) ecsRef.setResources(NG.core);
		
		var game = new GameState(ecsRef);
		var logo = new LogoState(ecsRef);
		var creature = new CreatureState(ecsRef);
		var select = new SelectState(ecsRef);
		
		Command.queueMany(
			ADD_SHEET(sprites, SheetID.SPRITES),
			PARSE_ANIMS(["specs/ui.txt", "specs/creatures.txt"], SPRITES),
			REGISTER_STATE(game, GAME_STATE),
			REGISTER_STATE(creature, CREATURE_STATE),
			REGISTER_STATE(select, SELECT_STATE),
			REGISTER_STATE(logo, LOGO_STATE),
			ENTER(LOGO_STATE),
			ENTER(GAME_STATE)
		);
	}
}