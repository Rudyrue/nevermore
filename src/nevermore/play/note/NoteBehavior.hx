package nevermore.play.note;

class NoteBehavior {
	public var ignore:Bool;
	public var hittable:Bool;
	public var missPadding:Float;
	public var hitHealth:Float;
	public var missHealth:Float;
	public var judgemental:Bool; // my feelings :(

	var _parent:BaseNote;

	public function new(parent:BaseNote) {
		reset(parent);
	}

	public function reset(parent:BaseNote) {
		_parent = parent;

		judgemental = true;
		missHealth = -1;
		hitHealth = 1;
		missPadding = 25;
		hittable = true;
		ignore = false;

		type = '';
	}

	public var type(default, set):String = '';
	public function set_type(v:String):String {
		switch v {
			case 'Mine':
				ignore = true;
				missHealth = 0;
				hitHealth = -10;

			case 'Fake':
				ignore = true;
				hittable = false;
		}

		return type = v;
	}

	public var inRange(get, never):Bool;
	function get_inRange():Bool {
		var early:Bool = _parent.adjustedTime < _parent.clock.time + Judgement.max.window;
		var late:Bool = _parent.adjustedTime > _parent.clock.time - Judgement.max.window;
		return early && late;
	}

	public var late(get, never):Bool;
	function get_late():Bool {
		var deviation:Float = _parent.adjustedTime - _parent.clock.time;
		return deviation < -(Judgement.max.window + missPadding);
	}
}