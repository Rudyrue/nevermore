package nevermore.core;

import nevermore.core.timing.TimingMap;
import nevermore.core.timing.TimingPoint;

class Util {
	public static final colors:Array<String> = ['purple', 'blue', 'green', 'red'];
	public static final directions:Array<String> = ['left', 'down', 'up', 'right'];

	public static var snaps:Array<Int> = [
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

	public static var rowsPerBeat:Int = 48;

	public static function swapDirection(direction:ScrollDirection):ScrollDirection {
		return switch direction {
			case DOWN: UP;
			case UP: DOWN;
			default: NONE;
		}
	}

	public static function crotchet(tempo:Float):Float {
		return 60000 / tempo;
		//return (60 / tempo) * 1000;
	}

	// i have no idea how any of this works or how to explain it
	public static function cosClip(rads:Float, _clip:Float):Float {
		return clip(Math.cos(rads), _clip);
	}

	public static function sinClip(rads:Float, _clip:Float):Float {
		return clip(Math.sin(rads), _clip);
	}

	public static function clip(value:Float, clip:Float):Float {
		var absValue:Float = Math.abs(value);
		var absClip:Float = Math.abs(clip);
		var sign:Float = value / absValue;

		if (absValue > absClip) {
			return absClip * sign;
		}

		return value;
	}

	public static function getSnap(timeAt:Float, ?map:TimingMap, ?pointRelative:Bool = true):Int {
		return snaps[getSnapID(timeAt, map, pointRelative)];
	}

	@:pure public static function getSnapID(timeAt:Float, ?map:TimingMap, ?pointRelative:Bool = true):Int {
		map ??= Conductor.timingMap;

		var row:Int = 0;
		if (pointRelative) row = map.getRow(timeAt);
		else {
			var point:TimingPoint = map.getByTime(timeAt);
			var distance:Float = timeAt - point.time;
			var crotchet:Float = crotchet(point.tempo);

			row = Math.round((distance / crotchet) * rowsPerBeat);
		}

		for (i in 0 ... snaps.length) {
			if (row % (192 / snaps[i]) == 0) // 192 rows per measure (48 * 4)
				return i;
		}

		return snaps.length - 1;
	}
}