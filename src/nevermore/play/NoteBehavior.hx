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
		if (name.length == 0 || !_list.exists(name)) {
			return base;
		}
		
		return _list[name];
	}

	public var ignore:Bool = false;
	public var hittable:Bool = true;
	public var missPadding:Float = 25;
	public var hitHealth:Float = 1;
	public var missHealth:Float = -1;
	public var judgemental:Bool = true; // my feelings :(
	public var punishable:Bool = false;

	public function new() {}
	public function setup(note:BaseNote, data:NoteData) {}

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