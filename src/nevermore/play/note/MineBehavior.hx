package nevermore.play.note;

class MineBehavior extends NoteBehavior {
	override function setup(note:BaseNote, data:NoteData) {
		super.setup(note, data);

		note.multAlpha = 0;
		note.length = data.length = 0;
		ignore = true;
		punishable = true;
		missHealth = -10;
	}
}