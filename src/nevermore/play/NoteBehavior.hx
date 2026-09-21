package nevermore.play;

import nevermore.play.note.BaseNote;

class NoteBehavior {
	static var _list:Map<String, NoteBehavior> = [];
	
	// because map access on EVERY note instead of unique ones
	// sounds like an extremely bad idea
	static var base:NoteBehavior = new NoteBehavior();

	public static function register(name:String, cls:Class<NoteBehavior>) {
		_list.set(name, Type.createInstance(cls, []));
	}

	public static function get(name:String):NoteBehavior {
		if (!_list.exists(name)) return base;
		return _list[name];
	}

	public var ignore:Bool;
	public var hittable:Bool;
	public var missPadding:Float;
	public var hitHealth:Float;
	public var missHealth:Float;
	public var judgemental:Bool; // my feelings :(
	public var punishable:Bool;

	public function new() {}
	public function setup(note:BaseNote, data:NoteData) {
		ignore = false;
		hittable = true;
		missPadding = 25;
		hitHealth = 1;
		missHealth = -1;
		judgemental = true;
		punishable = false;
	}

	public function inRange(note:BaseNote):Bool {
		var early:Bool = note.adjustedTime < note.clock.time + Judgement.max.window;
		var late:Bool = note.adjustedTime > note.clock.time - Judgement.max.window;
		return early && late;
	}

	public function isLate(note:BaseNote):Bool {
		var deviation:Float = note.adjustedTime - note.clock.time;
		return deviation < -(Judgement.max.window + missPadding);
	}
}