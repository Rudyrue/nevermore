package nevermore.core;

import nevermore.core.chart.*;

class Song {
	public static var parser:BaseParser = new BaseParser();
	public static function load(path:String, ?diff:String):Chart {
		if (parser == null) return dummyData();
		return parser.load(path, diff);
	}

	public static function dummyData():Chart {
		return {
			title: '',
			timingPoints: [],
			scrollVelocities: [],
			notes: [],
			speed: 1,
			offset: 0
		}
	}
}