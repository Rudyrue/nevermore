package nevermore.core.input;

import flixel.util.typeLimit.OneOfTwo;

typedef InputType = OneOfTwo<lime.ui.KeyCode, lime.ui.GamepadButton>;

/*interface Input {
	public var binds:Map<Int, Array<InputType>>;
	public var direction:Map<InputType, Int>;

	public function bind():Void;
	public function get(id:InputType):Int;
}*/