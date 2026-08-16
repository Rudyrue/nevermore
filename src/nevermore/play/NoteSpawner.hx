package nevermore.play;

import flixel.util.FlxSignal;
import nevermore.core.NoteData;
import nevermore.core.timing.BaseClock;

class NoteSpawner {
	var count:Int;
	public function new(?list:Array<NoteData>) {
		if (list != null) load(list);
	}

	public function load(list:Array<NoteData>) {
		this.list = list;
		list.sort((a, b) -> return Std.int(a.time - b.time));

		count = list.length;
	}

	public function destroy() {
		triggered = function(_) {}
		list.resize(0);
		index = 0;
		count = 0;
	}

	public var index:Int = 0;
	public var delay:Float = 1500;
	public var list:Array<NoteData>;

	// was originally gonna use flxsignal
	// but that caused more issues than i expected
	public dynamic function triggered(note:NoteData) {}
	public function update(clock:BaseClock) {
		while (index < count) {
			var data:NoteData = list[index];

			var adjustedTime:Float = (data.time + Nevermore.settings.inputOffset);
			var deviation:Float = adjustedTime - clock.time;
			if (deviation > delay) break;

			triggered(data);
			index++;
		}
	}
}