package nevermore.core.timing;

class ScrollVelocityMap {
	public var list:Array<ScrollVelocity>;
	public var length:Int = 0;

	public function new(list:Array<ScrollVelocity>) {
		length = list.length;
		list.sort((a, b) -> return Std.int(a.time - b.time));

		for (i in 1...list.length) {
			list[i].visualTime = list[i - 1].toPixels(list[i].time);
		}

		this.list = list;
	}

	public function get(time:Float):ScrollVelocity {
		if (length == 0) return {};
		var last:ScrollVelocity = list[0];

		for (i in 0...list.length) {
			var point = list[i];

			if (time >= point.time) last = point;
			else break;
		}

		return last;
	}

	public function getPosition(time:Float):Float {
		if (length == 0) return time;
		return get(time).toPixels(time);
	}
}