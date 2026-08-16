package nevermore.core;

enum abstract WindowType(String) from String to String {
	var STEPMANIA = 'StepMania J4';
	var CUSTOM = 'Custom';
}

@:structInit
class Judgement {
	public static var current:Array<Judgement>;
	public static final list:Map<String, Array<Judgement>> = [
		'StepMania J4' => [
			{name: 'Marvelous', window: 22.5},
			{name: 'Perfect', window: 45},
			{name: 'Great', window: 90},
			{name: 'Good', window: 135},
			{name: 'Bad', window: 180}
		],

		'Custom' => [
			{name: 'Marvelous', window: 22.5},
			{name: 'Perfect', window: 45},
			{name: 'Great', window: 90},
			{name: 'Good', window: 135},
			{name: 'Bad', window: 180}
		]
	];

	public static var min(get, never):Judgement;
	static function get_min():Judgement return current[0];

	public static var max(get, never):Judgement;
	static function get_max():Judgement return current[current.length - 1];

	public static function register(name:String, _list:Array<Judgement>) {
		list.set(name, _list);
	}

	public static var currentType(default, set):WindowType;
	static function set_currentType(v:WindowType):WindowType {
		currentType = v;
		current = list[currentType];
		for (id => judge in current) {
			judge.id = id;
		}

		return v;
	}

	public static function reset() {
		currentType = STEPMANIA;
	}

	public static function sort() {
		current.sort((a, b) -> return Std.int(a.window - b.window));
	}

	public static function getID(deviation:Float):Int {
		for (i in 0...current.length) {
			if (Math.abs(deviation) > current[i].window) continue;
			return i;
		}

		return current.length - 1;
	}

	public static function get(deviation:Float):Judgement {
		for (judge in current) {
			if (Math.abs(deviation) > judge.window) continue;
			return judge;
		}

		return max;
	}

	// these are the ones you wanna focus on
	public var name:String = '';
	public var window:Float = 0;
	public var id:Int = 0;

	// depends on the game but these aren't necessarily used in a couple
	// like score/accuracy
	public var health:Float = 0;
	public var score:Int = 0;
	public var accuracy:Float = 0;

	
}