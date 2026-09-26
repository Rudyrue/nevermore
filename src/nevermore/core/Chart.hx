package nevermore.core;

import nevermore.core.timing.ScrollVelocity;
import nevermore.core.timing.TimingPoint;
import nevermore.core.NoteData;
import nevermore.play.NoteBehavior;

@:structInit
@:publicFields
class Chart {
	var title:String = 'Unknown';
	var timingPoints:Array<TimingPoint>;
	var scrollVelocities:Array<ScrollVelocity> = [];
	var notes:Array<NoteData> = [];
	var speed:Float = 1;
	var offset:Float = 0;

	/*
		some formats (like quaver) reset quant
		on a new bpm change
		so we use this.
	*/
	var snapRelativeToChanges:Bool = true;

	function getJumpCount(?playerID:Int = 0):Int {
		return getChordCount(playerID, 2);
	}

	function getHandCount(?playerID:Int = 0):Int {
		return getChordCount(playerID, 3);
	}

	function getQuadCount(?playerID:Int = 0):Int {
		return getChordCount(playerID, 4);
	}

	// WIP
	// DOESN'T SEEM TO WORK WITH ANYTHING OTHER THAN JUMPS FOR SOME REASON
	// (and even then it's still inaccurate)
	function getChordCount(?playerID:Int = 0, ?amount:Int = 2):Int {
		var count:Int = 0;
		var chordLength:Int = 1; // at least 1 note/chord per row
		var last:NoteData = null;
		var lastChordTime:Float = 0.0;
		var i:Int = 0;

		for (_ in 0 ... notes.length) {
			var note:NoteData = notes[_];
			// skip any other strumline
			if (note.player != playerID) continue;

			if (note.type.length != 0) {
				var type = NoteBehavior.get(note.type);
				if (!type.hittable || type.punishable) continue;
			}

			// skip the first note
			if (i == 0) {
				last = note;
				i++;
				continue;
			}

			// is this note part of a chord?
			// check by comparing the last possible chord's time
			//
			// this note might also be part of another chord we've already checked,
			// which would cause a quad to appear as 2 jumps
			if (note.time == last.time && lastChordTime != last.time) {
				// seems like this is in fact a proper chord
				lastChordTime = last.time;
				chordLength++;

				// if the length of this chord is equal to what we're looking for,
				// reset the check and start again
				if (chordLength >= amount) {
					count++;
					chordLength = 1;
					last = null;
				}
			
			// either this wasn't a chord, or was part of a chord we've already checked
			} else {
				// to insure ie. a jump incrementing the count when we're checking for hands
				// or hands incrementing the count when we're checking for quads
				// etc
				chordLength = 1;
				last = note;
			}

			last ??= note;
			i++;
		}

		return count;
	}

	function getHoldCount(?playerID:Int = 0):Int {
		var count:Int = 0;
		for (i in 0 ... notes.length) {
			var data = notes[i];
			if (data.player != playerID) continue;
			if (data.length == 0) continue;

			count++;
		}

		return count;
	}

	function getTypeCount(?playerID:Int = 0, type:String = ''):Int {
		if (type.length == 0) return getNoteCount(playerID);

		var count:Int = 0;
		for (i in 0 ... notes.length) {
			var data:NoteData = notes[i];
			if (data.player != playerID) continue;
			if (data.type != type) continue;

			count++;
		}

		return count;
	}

	// counts all notes in the chart as long as the note is hittable, excluding fakes
	// includes mines as they aren't meant to be hit, but can
	function getNoteCount(?playerID:Int = 0, ?ignoreTypes:Bool = false):Int {
		var count:Int = 0;
		for (i in 0 ... notes.length) {
			var data:NoteData = notes[i];
			if (data.player != playerID) continue;
			if (!ignoreTypes && data.type.length != 0) {
				if (!NoteBehavior.get(data.type).hittable) continue;
			}

			count++;
		}

		return count;
	}

	// counts all notes in the chart are supposed to be hit, excluding fakes
	// does NOT include mines, as they aren't meant to be hit
	function getNormalizedNoteCount(?playerID:Int = 0, ?ignoreTypes:Bool = false):Int {
		var count:Int = 0;
		for (i in 0 ... notes.length) {
			var data:NoteData = notes[i];
			if (data.player != playerID) continue;

			if (!ignoreTypes && data.type.length != 0) {
				var type = NoteBehavior.get(data.type);
				if (!type.hittable || type.punishable) continue;
			}

			count++;
		}

		return count;
	}
}