package nevermore.input;

import lime.app.Application;
import lime.app.Event;
import lime.ui.Gamepad;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
import lime.system.System;

// combines keyboard/gamepad input into one callback
// and converts the input into a 0 - keyCount integer
class InputDirector {
	public var onPress:Event<Int -> Void>;
	public var onRelease:Event<Int -> Void>;
	public var timestamp:Int = 0;

	public function new() {
		onPress = new Event<Int -> Void>();
		onRelease = new Event<Int -> Void>();

		Gamepad.onConnect.add(_onConnectGamepad);
		_addGamepad(Gamepad.devices[0]);

		Application.current.window.onKeyDown.add(keyPressed);
		Application.current.window.onKeyUp.add(keyReleased);
	}

	function _onConnectGamepad(gamepad:Gamepad) {
		if (gamepad.id != 0) return;
		_addGamepad(gamepad);
	}

	function _addGamepad(gamepad:Gamepad) {
		if (gamepad == null) return;

		gamepad.onButtonDown.add(buttonPressed);
		gamepad.onButtonUp.add(buttonReleased);
	}

	public function destroy() {
		Application.current.window.onKeyDown.remove(keyPressed);
		Application.current.window.onKeyUp.remove(keyReleased);
		Gamepad.onConnect.remove(_onConnectGamepad);

		var gamepad:Gamepad = Gamepad.devices[0];
		if (gamepad == null) return;

		gamepad.onButtonDown.remove(buttonPressed);
		gamepad.onButtonUp.remove(buttonReleased);
	}

	inline function keyPressed(key:KeyCode, _) {
		var direction:Int = Controls.keyboard.get(key);
		if (direction == -1) return;

		#if (lime >= version("8.4.0"))
		timestamp = Application.current.window.onKeyDown.timestamp;
		#else
		timestamp = System.getTimer();
		#end

		onPress.dispatch(direction);
	}

	inline function keyReleased(key:KeyCode, _) {
		var direction:Int = Controls.keyboard.get(key);
		if (direction == -1) return;

		onRelease.dispatch(direction);
	}

	inline function buttonPressed(button:GamepadButton) {
		var direction:Int = Controls.gamepad.get(button);
		if (direction == -1) return;

		#if (lime >= version("8.4.0"))
		var gamepad:Gamepad = Gamepad.devices[0];
		timestamp = gamepad.onButtonDown.timestamp;
		#else
		timestamp = System.getTimer();
		#end

		onPress.dispatch(direction);
	}

	inline function buttonReleased(button:GamepadButton) {
		var direction:Int = Controls.gamepad.get(button);
		if (direction == -1) return;

		onRelease.dispatch(direction);
	}
}