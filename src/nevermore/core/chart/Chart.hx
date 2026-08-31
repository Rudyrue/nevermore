package nevermore.core.chart;

import nevermore.core.timing.ScrollVelocity;
import nevermore.core.timing.TimingPoint;
import nevermore.core.NoteData;

@:structInit
@:publicFields
class Chart {
	var title:String;
	var timingPoints:Array<TimingPoint>;
	var scrollVelocities:Array<ScrollVelocity>;
	var notes:Array<NoteData>;
	var speed:Float;
	var offset:Float;
}