package nevermore.play.note;

class MineBehavior extends NoteBehavior {
	override function setup(note:BaseNote, data:NoteData) {
		super.setup(note, data);

		note.multAlpha = 0;
		note.length = data.length = 0;
		note.ignore = true;
		note.punishable = true;
		note.missHealth = -10;
	}
}