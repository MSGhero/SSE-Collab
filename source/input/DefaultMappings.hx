package input;

import mono.input.PadInput.PadButtons;
import hxd.Key;
import mono.input.Input.InputMapping;

class DefaultMappings {
	
	public static function getDefaultKB() {
		
		var mapping = new InputMapping();
		
		mapping[Action.L] = [Key.LEFT, Key.A, Key.J];
		mapping[Action.R] = [Key.RIGHT, Key.D, Key.L];
		mapping[Action.U] = [Key.UP, Key.W, Key.I];
		mapping[Action.D] = [Key.DOWN, Key.S, Key.K];
		
		mapping[Action.SELECT] = [Key.SPACE, Key.Z];
		mapping[Action.DESELECT] = [Key.X, Key.C];
		mapping[Action.LINK] = [Key.ENTER];
		
		mapping[Action.VOL_DOWN] = [Key.QWERTY_MINUS, Key.NUMBER_9];
		mapping[Action.VOL_UP] = [Key.QWERTY_EQUALS, Key.NUMBER_0];
		mapping[Action.MUTE] = [Key.M];
		
		mapping[Action.FULLSCREEN] = [Key.F];
		mapping[Action.ESC] = [Key.ESCAPE];
		
		return mapping;
	}
	
	public static function getDefaultPad() {
		
		var mapping = new InputMapping();
		
		mapping[Action.L] = [PadButtons.LEFT_DPAD, PadButtons.LEFT_L_VIRTUAL];
		mapping[Action.R] = [PadButtons.RIGHT_DPAD, PadButtons.RIGHT_L_VIRTUAL];
		mapping[Action.U] = [PadButtons.UP_DPAD, PadButtons.UP_L_VIRTUAL];
		mapping[Action.D] = [PadButtons.DOWN_DPAD, PadButtons.DOWN_L_VIRTUAL];
		
		mapping[Action.PAGE_L] = [PadButtons.LB, PadButtons.LT];
		mapping[Action.PAGE_R] = [PadButtons.RB, PadButtons.RT];
		
		mapping[Action.SELECT] = [PadButtons.A];
		mapping[Action.DESELECT] = [PadButtons.B];
		mapping[Action.LINK] = [PadButtons.Y];
		
		return mapping;
	}
	
	public static function getDefaultMouse() {
		
		var mapping = new InputMapping();
		
		mapping[Action.MOUSE] = [Key.MOUSE_LEFT];
		mapping[Action.DESELECT] = [Key.MOUSE_RIGHT];
		
		return mapping;
	}
}