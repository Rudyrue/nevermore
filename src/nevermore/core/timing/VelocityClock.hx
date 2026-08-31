package nevermore.core.timing;

class VelocityClock extends BaseClock {
	public var map:ScrollVelocityMap;
	public function new(list:Array<ScrollVelocity>) {
		super();
		usesScrollVelocities = true;
		map = new ScrollVelocityMap(list);

		reset();
	}

	override function update(_) {}
	override function updateBeats(_) {}

	var index:Int = 0;
	var current:ScrollVelocity = {};
	public function updateSVs(clock:BaseClock) {
		var offsetedTime:Float = clock.time - Nevermore.settings.inputOffset;

		if (map.length == 0) {
			time = offsetedTime;
			return;
		}

		for (i in (index + 1)...map.length) {
			var next = map.list[i];
			if (next.time > offsetedTime) break;

			index = i;
			current = next;
		}

		time = current.toPixels(offsetedTime);
	}
}