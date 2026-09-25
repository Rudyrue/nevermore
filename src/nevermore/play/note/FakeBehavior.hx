package nevermore.play.note;

class FakeBehavior extends NoteBehavior {
	public function new() {
		super();
		ignore = true;
		hittable = false;
	}

	override function setupData(data:NoteData) {
		data.length = 0;
	}

	override function setup(note:BaseNote) {
		note.multAlpha = 0.4;
	}
}