package nevermore.play.note;

class FakeBehavior extends NoteBehavior {
	override function setup(note:BaseNote, data:NoteData) {
		super.setup(note, data);

		note.multAlpha = 0.4;
		note.length = data.length = 0;
		ignore = true;
		hittable = false;
	}
}