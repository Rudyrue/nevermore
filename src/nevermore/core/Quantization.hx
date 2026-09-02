package nevermore.core;

import nevermore.core.timing.TimingMap;

#if !NEVERMORE_NO_QUANTIZATION
enum abstract QuantType(String) from String to String {
	var STEPMANIA = 'StepMania';
	var ARROWVORTEX = 'ArrowVortex';
	var CUSTOM = 'Custom';
}

class Quantization {
	public static final RED:FlxColor = 0xFFFF2B32;
	public static final BLUE:FlxColor = 0xFF0861FF;
	public static final PURPLE:FlxColor = 0xFFC228FF;
	public static final YELLOW:FlxColor = 0xFFFFE900;
	public static final MAGENTA:FlxColor = 0xFFFF00CB;
	public static final PINK:FlxColor = 0xFFFF91FF;
	public static final ORANGE:FlxColor = 0xFFFF831E;
	public static final TEAL:FlxColor = 0xFF00EDFF;
	public static final GREEN:FlxColor = 0xFF3FFF3F;
	public static final GRAY:FlxColor = 0xFF878787;

	public static var current:Array<Int>;
	public static final list:Map<String, Array<FlxColor>> = [
		'StepMania' => [
			RED,     // 4th
			BLUE,    // 8th
			GREEN,   // 12th
			YELLOW,  // 16th
			GRAY,    // 20th
			PURPLE,  // 24th
			TEAL,    // 32nd
			MAGENTA, // 48th
			GRAY,    // 64th
			GRAY,    // 96th
			GRAY     // 192nd
		],

		'ArrowVortex' => [
			RED,     // 4th
			BLUE,    // 8th
			PURPLE,  // 12th
			YELLOW,  // 16th
			GRAY,    // 20th 
			PINK,    // 24th
			ORANGE,  // 32nd
			TEAL,    // 48th
			GREEN,   // 64th
			GRAY,    // 96th
			GRAY     // 192nd
		],

		'Custom' => [
			0xFFFFFFFF, // 4th
			0xFFFFFFFF, // 8th
			0xFFFFFFFF, // 12th
			0xFFFFFFFF, // 16th
			0xFFFFFFFF, // 20th 
			0xFFFFFFFF, // 24th
			0xFFFFFFFF, // 32nd
			0xFFFFFFFF, // 48th
			0xFFFFFFFF, // 64th
			0xFFFFFFFF, // 96th
			0xFFFFFFFF  // 192nd
		]
	];

	// `current` should be the same length as this
	static var _quants:Array<Int> = [
		4,
		8,
		12,
		16,
		20,
		24,
		32,
		48,
		64,
		96,
		192
	];

	public static var currentType(default, set):QuantType;
	static function set_currentType(v:QuantType):QuantType {
		currentType = v;
		current = list[currentType];
		return v;
	}

	public static function reset() {
		currentType = STEPMANIA;
	}

	@:pure public static function getID(timeAt:Float, ?map:TimingMap, ?pointRelative:Bool = true):Int {
		map ??= Conductor.timingMap;

		var row:Int = 0;
		if (pointRelative) {
			row = Math.round(map.getBeat(timeAt) * 48);
		} else {
			var point = map.getByTime(timeAt);

			var pos = timeAt - point.time;
			var crot = Util.crotchet(point.tempo);

			row = Math.round((pos / crot) * 48);
		}

		for (i in 0..._quants.length) {
			if (row % (192 / _quants[i]) == 0) // 192 rows per measure (48 * 4)
				return i;
		}

		return _quants.length - 1;
	}
}
#else
class Quantization {}
#end