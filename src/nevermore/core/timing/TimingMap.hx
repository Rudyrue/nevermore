package nevermore.core.timing;

class TimingMap {
	public var list(default, null):Array<TimingPoint> = [];

	public var length(get, never):Int;
	function get_length():Int return list.length;

	public var tempo:Float;
	public var beatsPerMeasure:Int;

	public function new() {}

	public function reset(points:Array<TimingPoint>):TimingMap {
		if (points.length == 0) points.push({});
		points.sort((a, b) -> return Std.int(a.time - b.time));

		list.resize(0);
        list = points.copy();

		tempo = list[0].tempo;
		beatsPerMeasure = list[0].beatsPerMeasure;

		// no need to do beat calculation for one point
		if (length == 1) return this;

		// pre-calculate all of the beats now
		// so we don't have to do it later
		var beat:Float = 0;
		var measure:Float = 0;
		var crotchet:Float = Util.crotchet(tempo);
		var beatsPerMeasure:Int = beatsPerMeasure;
		var lastTime:Float = 0;
		var lastBeat:Float = 0;

		for (point in list) {
			beat += (point.time - lastTime) / crotchet;
			measure += (beat - lastBeat) / beatsPerMeasure;

			lastTime = point.time;
			lastBeat = beat;
			crotchet = Util.crotchet(point.tempo);
			beatsPerMeasure = point.beatsPerMeasure;

			point.beat = beat;
			point.measure = measure;
		}

		return this;
	}

	@:pure public function getByTime(pos:Float):TimingPoint {
        var last:TimingPoint = list[0];

        for (point in list) {
            if (pos >= point.time) last = point;
            else break;
        }

		return last;
	}

	// these could be grouped into eachother
	// but for debugging sake im keeping them separated
	@:pure public function getBeat(pos:Float, ?point:TimingPoint):Float {
		if (length <= 1) return pos / (60000 / tempo);
		point ??= getByTime(pos);

		var crotchet:Float = 60000 / point.tempo;
		var distance:Float = (pos - point.time) / crotchet;
		return point.beat + distance;
	}

	@:pure public function getMeasure(pos:Float, ?point:TimingPoint):Float {
		if (length <= 1) return (pos / (60000 / tempo)) / 4;
		point ??= getByTime(pos);

		var crotchet:Float = 60000 / point.tempo;
		var distance:Float = (pos - point.time) / crotchet;
		return point.measure + (distance / point.beatsPerMeasure);
	}
}