package nevermore.play.note;

class MineBehavior extends NoteBehavior {
	public function new() {
		super();

		ignore = true;
		punishable = true;
		missHealth = -10;
	}

	override function setupData(data:NoteData) {
		data.length = 0;
	}

	override function setup(note:BaseNote) {
		note.multAlpha = 0;
		//note.frames = Noteskin.get('mine'); AGH
	}
}