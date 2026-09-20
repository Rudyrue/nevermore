package nevermore.play.note;

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

	public function new() {}
	public function setup(note:BaseNote, data:NoteData) {
		note.multAlpha = 1;
		
		note.ignore = false;
		note.hittable = true;
		note.missPadding = 25;
		note.hitHealth = 1;
		note.missHealth = -1;
		note.judgemental = true; // my feelings :(
		note.punishable = false;
	}

	public function inRange(note:BaseNote):Bool {
		var early:Bool = note.adjustedTime < note.clock.time + Judgement.max.window;
		var late:Bool = note.adjustedTime > note.clock.time - Judgement.max.window;
		return early && late;
	}

	public function isLate(note:BaseNote):Bool {
		var deviation:Float = note.adjustedTime - note.clock.time;
		return deviation < -(Judgement.max.window + note.missPadding);
	}
}