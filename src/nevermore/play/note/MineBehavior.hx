package nevermore.play.note;

class MineBehavior extends NoteBehavior {
	public function new() {
		super();

		ignore = true;
		punishable = true;
		missHealth = -10;
	}

	override function setup(note:BaseNote, data:NoteData) {
		note.multAlpha = 0;
		note.length = data.length = 0;
	}
}