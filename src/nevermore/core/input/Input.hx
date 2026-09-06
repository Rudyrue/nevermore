package nevermore.core.input;

import lime.ui.KeyCode;
import nevermore.core.input.Input;

class Input {
	public function new(binds:Map<Int, Array<InputType>>) {
		default_binds = binds.copy();
		this.binds = [
			for (bind in binds.keys()) {
				bind => binds[bind].copy();
			}
		];
	}

	public var default_binds(default, null):Map<Int, Array<InputType>>;
	public var binds:Map<Int, Array<InputType>>;

	public var direction:Map<InputType, Int> = [];
	public function bind() {
		direction.clear();
		for (i => list in binds) {
			for (key in list) direction.set(key, i);
		}
	}

	public inline function get(key:InputType):Int {
		return direction[key] ?? -1;
	}
}