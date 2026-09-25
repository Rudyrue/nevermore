package nevermore.core;

import nevermore.core.*;

class Song {
	public static var parser:BaseParser = new BaseParser();
	public static function load(path:String, ?diff:String):Chart {
		if (parser == null) return dummyData();
		
		var result:Chart = parser.load(path, diff);

/*		for (i => note in result.notes) {
			if (i == 0) continue; // ignore the first note in the chart
			var prevNote:NoteData = result.notes[i - 1];

			var matches:Bool = prevNote.player == note.player && prevNote.lane == note.lane;
			var overlapping:Bool = Math.abs(note.time - prevNote.time) <= 2;

			if (matches) {
				trace(note.time, prevNote.time);
				trace(overlapping);
			}

			if (!matches || !overlapping) continue;

			note = null;
		}*/

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
		}

		result.notes = cleanedNotes.filter(function(note:NoteData) return note != null);
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
			quantsRelativeToChanges: true
		}
	}
}