package nevermore.core;

class Util {
	public static final colors:Array<String> = ['purple', 'blue', 'green', 'red'];
	public static final directions:Array<String> = ['left', 'down', 'up', 'right'];

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
}