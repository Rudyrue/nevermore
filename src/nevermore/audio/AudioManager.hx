package nevermore.audio;

import openfl.events.Event;

// ok so the idea is
// FlxG.plugins.add(new AudioManager());
// since plugins update RIGHT after sounds do
// so it basically wouldn't be any different
// than FlxG.sound
class AudioManager extends flixel.FlxBasic {
	public static var list:Array<Audio> = [];

	public static var volume(default, set):Float = 1.0;
	static function set_volume(v:Float):Float {
		for (audio in list) audio.volume = v;
		return volume = v;
	}

	public static var rate(default, set):Float = 1.0;
	static function set_rate(v:Float):Float {
		for (audio in list) audio.rate = v;
		return rate = v;
	}

	public static function pause() {}
	public static function resume() {}
	public static function stop() {}

	public static function clear() {}

	public static function init() {
		FlxG.stage.addEventListener(Event.DEACTIVATE, focusLost);
		FlxG.stage.addEventListener(Event.ACTIVATE, focusGained);
	}

	public dynamic static function focusLost(event:Event) {}
	public dynamic static function focusGained(event:Event) {}

	public static function load(path:String):Audio {
		return new Audio(path);
	}

	override function update(delta:Float) {}
}