package nevermore.input;

import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.GamepadButton;
import lime.ui.Gamepad;

enum ListenerType {
	PRESSED;
	RELEASED;
}

class Controls {
	public static var initialized:Bool = false;

	public static var keyboard:Input = new Input([
		0 => [KeyCode.D, KeyCode.LEFT],
		1 => [KeyCode.F, KeyCode.DOWN],
		2 => [KeyCode.J, KeyCode.UP],
		3 => [KeyCode.K, KeyCode.RIGHT]
	]);

	public static var gamepad:Input = new Input([
		0 => [GamepadButton.X, GamepadButton.DPAD_LEFT],
		1 => [GamepadButton.A, GamepadButton.DPAD_DOWN],
		2 => [GamepadButton.Y, GamepadButton.DPAD_UP],
		3 => [GamepadButton.B, GamepadButton.DPAD_RIGHT]
	]);

	public static function init() {
		if (initialized) return;
		initialized = true;

		keyboard.bind();
		gamepad.bind();
	}
}