package nevermore.core.timing;

class SyncClock extends BaseClock {
	override function reset(?timingPoints:Array<TimingPoint>, ?offset:Float):Void {
		super.reset(timingPoints, offset);
		_lastTime = 0;
		_timeTicks = null;
	}

	override function update(delta:Float) {
		delta *= 1000;

		if (audio == null || !audio.playing) {
			audioTime += delta * rate;
		} else {
			@:privateAccess
			audioTime = audio._channel.position;
		}

		songTime = audioTime + offset;

		if (audioTime == _lastTime) time += delta;
		else {
			if (Math.abs(songTime - time) >= delta) time = songTime;
			else time += delta;

			_lastTime = audioTime;
		}

		updateBeats(time);
	}

	// yes this is the same sync method that codename uses
	// https://github.com/CodenameCrew/CodenameEngine/blob/main/source/flixel/sound/FlxSound.hx#L894
	// yes it works
	// yes i tested the fuck out of it do NOT question it /lh
	//
	// ok this is me from later
	// it works but pausing breaks it completely
	// so uh
	// it in fact does not work
	// it's basically the same as ^ anyways
	var _lastTime:Float;
	var _timeTicks:Null<Float>;
	var _timeInterpolation:Float;
	function sync():Float @:privateAccess {
		final currentTime = audio.time;
		if (_timeTicks == null) {
			_timeTicks = FlxG.game.getTicks();
			_timeInterpolation = 1;
			return _lastTime = currentTime;
		} else {
			final interpolatedTime = _lastTime + (FlxG.game.getTicks() - _timeTicks) * _timeInterpolation;
			if (_lastTime != currentTime) {
				_timeTicks = FlxG.game.getTicks();
				if ((_timeInterpolation = 1 - Math.min(interpolatedTime - currentTime, 1) * 0.001) < 1 && _timeInterpolation > 0.9)
					return _lastTime = interpolatedTime;
				else {
					_timeInterpolation = 1;
					return _lastTime = currentTime;
				}
			}
			else return interpolatedTime;
		}
	}
}