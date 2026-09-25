package nevermore.core;

import nevermore.core.timing.ScrollVelocity;
import nevermore.core.timing.TimingPoint;
import nevermore.core.NoteData;

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
	var quantsRelativeToChanges:Bool = true;

	function getNoteCount(?playerID:Int = 0):Int {
		var count:Int = 0;
		for (i in 0 ... notes.length) {
			if (notes[i].player != playerID) continue;
			count++;
		}

		return count;
	}
}