package nevermore.core;

import nevermore.core.*;
import nevermore.play.NoteBehavior;

class Song {
	public static var parser:BaseParser = new BaseParser();
	public static function load(path:String, ?diff:String):Chart {
		if (parser == null) return dummyData();
		
		var result:Chart = parser.load(path, diff);

		var cleanedNotes = [];
		for (i => note in result.notes) {
			if (i != 0) {
				for (evilNote in cleanedNotes) {
					if (note == evilNote) continue;

					var matches:Bool = note.player == evilNote.player && note.lane == evilNote.lane;
					if (!matches || Math.abs(note.time - evilNote.time) > 2.0) continue;

					cleanedNotes.remove(evilNote);
					break;
				}
			}

			cleanedNotes.push(note);
			if (note.type.length != 0) {
				NoteBehavior.get(note.type).setupData(note);
			}
		}

		result.notes = cleanedNotes.filter(function(note:NoteData) return note != null);
		result.notes.sort((a, b) -> return Std.int(a.time - b.time));
		return result;
	}

	public static function dummyData():Chart {
		return {
			title: '',
			timingPoints: [],
			scrollVelocities: [],
			notes: [],
			speed: 1,
			offset: 0,
			snapRelativeToChanges: true
		}
	}
}