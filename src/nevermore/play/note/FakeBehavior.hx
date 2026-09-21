package nevermore.play.note;

class FakeBehavior extends NoteBehavior {
	public function new() {
		super();
		ignore = true;
		hittable = false;
	}

	override function setup(note:BaseNote, data:NoteData) {
		note.multAlpha = 0.4;
		note.length = data.length = 0;
	}
}