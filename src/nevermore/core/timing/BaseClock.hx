package nevermore.core.timing;

import flixel.util.FlxSignal;

class BaseClock {
	public var audioTime:Float;
	public var songTime:Float;
	public var time:Float;
	public var timingMap:TimingMap;
	
	public var usesScrollVelocities:Bool = false;

	public var active:Bool = true;
	
	public var audio:FlxSound;
	public function new(?audio:FlxSound) {
		this.audio = audio;
		timingMap = new TimingMap();

		stepHit = new FlxTypedSignal<Int -> Void>();
		beatHit = new FlxTypedSignal<Int -> Void>();
		measureHit = new FlxTypedSignal<Int -> Void>();
	}

	public var offset:Float;
	#if FLX_PITCH 
	public var rate:Float;
	#else
	public var rate(default, set):Float;
	function set_rate(_):Float {
		return rate = 1.0;
	}
	#end
	public function reset(?timingPoints:Array<TimingPoint>, ?offset:Float) {
		audioTime = songTime = time = 0.0;
		rate = 1.0;

		this.offset = offset ?? 0;
		timingMap.reset(timingPoints ?? []);

		stepHit.removeAll();
		beatHit.removeAll();
		measureHit.removeAll();
	}

	public var stepHit:FlxTypedSignal<Int -> Void>;
	public var beatHit:FlxTypedSignal<Int -> Void>;
	public var measureHit:FlxTypedSignal<Int -> Void>;
	public function update(delta:Float) {
		if (audio == null || !audio.playing) {
			audioTime += (delta * 1000) * rate;
		} else {
			@:privateAccess
			audioTime = audio._channel.position;
		}

		songTime = audioTime + offset;
		time = songTime;

		updateBeats(songTime);
	}

	public var step:Float;
	var fStep:Int;

	public var beat:Float;
	var fBeat:Int;

	public var measure:Float;
	var fMeasure:Int;

	// TODO:
	// for some reason when starting with negative time (ie positive offset)
	// beat hits at 0 just don't seem to occur at all ?
	function updateBeats(pos:Float) {
		var point:TimingPoint = null;
		
		if (timingMap.length > 1) {
			point = timingMap.getByTime(pos);
		}

		beat = timingMap.getBeat(pos, point);
		step = beat * 4;
		measure = timingMap.getMeasure(pos, point);

		var nextStep:Int = Std.int(step);
		if (nextStep != fStep) {
			stepHit.dispatch(fStep = nextStep);
		}

		var nextBeat:Int = Std.int(beat);
		if (nextBeat != fBeat) {
			beatHit.dispatch(fBeat = nextBeat);
		}

		var nextMeasure:Int = Std.int(measure);
		if (nextMeasure != fMeasure) {
			measureHit.dispatch(fMeasure = nextMeasure);
		}
	}
}