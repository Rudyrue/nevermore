package nevermore.core;

import lime.ui.KeyCode;

// TODO:
// ADD GAMEPAD SUPPORT FUCK OH MY GOD I FORGOT
// (preferably only lime so it fits the rest of the class)
//
// TODO 2:
// figure out how to customize keybinds at runtime
// unless this way just works somehow and i don't realize it
class Controls {
	public static final default_binds:Map<Int, Array<KeyCode>> = [
		0 => [KeyCode.D, KeyCode.LEFT],
		1 => [KeyCode.F, KeyCode.DOWN],
		2 => [KeyCode.J, KeyCode.UP],
		3 => [KeyCode.K, KeyCode.RIGHT]
	];

	public static var binds:Map<Int, Array<KeyCode>> = [
		for (bind in default_binds.keys()) {
			bind => default_binds[bind].copy();
		}
	];

	public static var direction:Map<KeyCode, Int> = new Map<KeyCode, Int>();
	public static function bindKeys() {
		direction.clear();
		for (i => list in binds) {
			for (key in list) direction.set(key, i);
		}
	}

	public static inline function keyID(key:KeyCode):Int {
		return direction.get(key) ?? -1;
	}
}