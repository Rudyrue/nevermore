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

// TODO:
// figure out how to customize keybinds at runtime
// unless this way just works somehow and i don't realize it
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

	public static function addKeyboardListener(type:ListenerType, callback:KeyCode->KeyModifier -> Void) {
		switch type {
			case PRESSED:
				Application.current.window.onKeyDown.add(callback);

			case RELEASED:
				Application.current.window.onKeyUp.add(callback);
		}
	}

	public static function removeKeyboardListener(type:ListenerType, callback:KeyCode->KeyModifier -> Void) {
		switch type {
			case PRESSED:
				Application.current.window.onKeyDown.remove(callback);

			case RELEASED:
				Application.current.window.onKeyUp.remove(callback);
		}
	}

	public static function addGamepadListener(type:ListenerType, callback:GamepadButton -> Void) {
		var current:Gamepad = Gamepad.devices[0];

		switch type {
			case PRESSED:
				current.onButtonDown.add(callback);

			case RELEASED:
				current.onButtonUp.add(callback);
		}
	}

	public static function removeGamepadListener(type:ListenerType, callback:GamepadButton -> Void) {
		var current:Gamepad = Gamepad.devices[0];

		switch type {
			case PRESSED:
				current.onButtonDown.remove(callback);

			case RELEASED:
				current.onButtonUp.remove(callback);
		}
	}

	public static function init() {
		if (initialized) return;
		initialized = true;

		keyboard.bind();
		gamepad.bind();
	}
}