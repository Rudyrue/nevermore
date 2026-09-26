package nevermore.core;

enum abstract HitWindowType(String) from String to String {
	var STEPMANIA_J1 = 'StepMania J1';
	var STEPMANIA_J2 = 'StepMania J2';
	var STEPMANIA_J3 = 'StepMania J3';
	var STEPMANIA_J4 = 'StepMania J4';
	var STEPMANIA_J5 = 'StepMania J5';
	var STEPMANIA_J6 = 'StepMania J6';
	var STEPMANIA_J7 = 'StepMania J7';
	var STEPMANIA_J8 = 'StepMania J8';
	var STEPMANIA_JUSTICE = 'StepMania Justice';

	var OSU_MANIA_OD1 = 'osu!mania OD1';
	var OSU_MANIA_OD2 = 'osu!mania OD2';
	var OSU_MANIA_OD3 = 'osu!mania OD3';
	var OSU_MANIA_OD4 = 'osu!mania OD4';
	var OSU_MANIA_OD5 = 'osu!mania OD5';
	var OSU_MANIA_OD6 = 'osu!mania OD6';
	var OSU_MANIA_OD7 = 'osu!mania OD7';
	var OSU_MANIA_OD8 = 'osu!mania OD8';
	var OSU_MANIA_OD9 = 'osu!mania OD9';
	var OSU_MANIA_OD10 = 'osu!mania OD10';

	var DDR = 'DanceDanceRevolution';
	var ITG = 'In The Groove';
}

class HitWindows {
	public static var list:Map<String, Array<Float>> = [
		// etterna limits the bad/boo window to 180 for anything above j4
		// but for the sake of it being stepmania im not doing that
		'StepMania J1' => [33.75, 67.5, 135, 202.5, 270],
		'StepMania J2' => [29.925, 59.85, 119.7, 179.55, 239.4],
		'StepMania J3' => [26.1, 52.2, 104.4, 156.6, 208.8],
		'StepMania J4' => [22.5, 45, 90, 135, 180],
		'StepMania J5' => [18.9, 37.8, 75.6, 113.4, 151.2],
		'StepMania J6' => [14.85, 29.7, 90, 59.4, 118.8],
		'StepMania J7' => [11.25, 22.5, 45, 67.5, 90],
		'StepMania J8' => [7.425, 14.85, 29.7, 44.55, 59.4],
		'StepMania Justice' => [4.5, 9, 13.5, 18, 36],

		'osu!mania OD1' => [16, 61, 94, 124, 148, 185],
		'osu!mania OD2' => [16, 58, 91, 121, 145, 182],
		'osu!mania OD3' => [16, 55, 88, 118, 142, 179],
		'osu!mania OD4' => [16, 52, 85, 115, 139, 176],
		'osu!mania OD5' => [16, 49, 82, 112, 136, 173],
		'osu!mania OD6' => [16, 46, 79, 109, 133, 170],
		'osu!mania OD7' => [16, 43, 76, 106, 130, 167],
		'osu!mania OD8' => [16, 40, 73, 103, 127, 164],
		'osu!mania OD9' => [16, 37, 70, 100, 124, 161],
		'osu!mania OD10' => [16, 33, 66, 97, 121, 158],

		"Friday Night Funkin' (Legacy)" => [33.34, 125, 150, 166.67],
		"Friday Night Funkin' (Week 7)" => [33.34, 91.69, 133.34, 166.67],
		"Friday Night Funkin'" => [/* 12.5, */45, 90, 135, 160],

		// these i got from project outfox
		// as i really don't have a concrete way of getting these (tmk)
		'DanceDanceRevolution' => [17, 34, 84, 124, 160],
		'In The Groove' => [23, 44.5, 103.5, 136.5, 181.2]
	];

	public static var min(get, never):Float;
	static function get_min():Float return current[0];

	public static var max(get, never):Float;
	static function get_max():Float return current[current.length - 1];

	public static function register(name:String, windows:Array<Float>) {
		list.set(name, windows);
	}

	public static function getID(deviation:Float):Int {
		for (i in 0 ... current.length) {
			if (Math.abs(deviation) > current[i]) continue;
			return i;
		}

		return current.length - 1;
	}

	public static function get(deviation:Float):Float {
		for (window in current) {
			if (Math.abs(deviation) > window) continue;
			return window;
		}

		return max;
	}

	public static var current:Array<Float>;
	public static var type(default, set):HitWindowType;
	static function set_type(v:HitWindowType):HitWindowType {
		current = list[v];
		return type = v;
	}

	public static function reset() {
		type = STEPMANIA_J4;
	}
}