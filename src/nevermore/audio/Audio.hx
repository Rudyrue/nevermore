package nevermore.audio;

class Audio {
	// acts as FlxSound._channel
	// or Conductor.clock/BaseClock
	// or basically where the actual work lies
	// with streaming and what not
	var _data:AudioData;

	@:isVar public var time(get, set):Float;
	function get_time():Float {
		//return _data.time;
		return 0.0;
	}
	function set_time(v:Float):Float {
		//return _data.time = v;
		return 0.0;
	}

	@:isVar public var volume(get, set):Float;
	function get_volume():Float {
		//return _data.volume;
		return 1.0;
	}
	function set_volume(v:Float):Float {
		//return _data.volume = v;
		return 1.0;
	}

	@:isVar public var rate(get, set):Float;
	function get_rate():Float {
		//return _data.rate;
		return 1.0;
	}
	function set_rate(v:Float):Float {
		//return _data.rate = v;
		return 1.0;
	}

	public var paused:Bool;
	public var playing:Bool;

	public function new(?path:String) {
		paused = false;
		playing = false;

		if (path != null) load(path);
	}
	public function load(path:String) {}
	public function destroy() {}

	public function start() {}
	public function stop() {}

	public function resume() {}
	public function pause() {}
}