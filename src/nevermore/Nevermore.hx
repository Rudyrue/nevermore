package nevermore;

#if !NEVERMORE_NO_MODCHARTS
import nevermore.modchart.ModchartManager;
#end

enum abstract ScrollDirection(String) from String to String {
	var UP = 'Up';
	var DOWN = 'Down';
	var NONE = 'None';
	//var TAIKO = 'Taiko no Tatsujin';
}

@:structInit
@:publicFields
class NevermoreSettings {
	/*
	 * Shifts the time of all notes forward or backward.
	 * Moves where a hit is considered 0 milliseconds, relative to the audio.
	 * Lower values mean notes will spawn earlier, so you have to hit earlier, and vice versa.
	*/
	var inputOffset:Float = 0;

	/*
	 * Otherwise known as moving the "judgement line".
	 * Moves where a hit is considered 0 milliseconds relative to the receptors, and not the audio.
	 * Lower values moves the line to be "after" the receptors.
	*/                                     
	var visualOffset:Float = 0;

	#if !NEVERMORE_NO_QUANTIZATION
	/*
	 * Changes note colours to resemble what beat they are snapped at.
	 * Uses StepMania's noteskin colours by default.
	 * (see core/Quantization.hx)
	*/
	var quantization:Bool = false;
	#end

	/*
	 * How many times the game will compress sustain vertices.
	 * Higher values will stretch the hold graphic for more performance.
	 * Recommended to be at lower values if you're playing modcharts,
	 * but otherwise higher values for casual play.
	*/
	var holdGrain:Int = 5;
}

class Nevermore {
	public static final version:String = '1.0.0';

	public static var settings:NevermoreSettings = null;
	public static var keyCount:Int = 4;
	
	// why does flixel not have a variable for this
	public static var paused(get, never):Bool;
	static function get_paused():Bool {
		return !FlxG.state.persistentUpdate && FlxG.state.subState != null;
	}

	public static var initialized:Bool = false;

	public static var commit(get, never):String;
	static function get_commit():String {
		return Git.commit;
	}

	public static var commitLong(get, never):String;
	static function get_commitLong():String {
		return Git.commitLong;
	}

	public static var commitNumber(get, never):Int;
	static function get_commitNumber():Int {
		return Git.commitNumber;
	}

	public static var branch(get, never):String;
	static function get_branch():String {
		return Git.branch;
	}

	public static function init() {
		if (initialized) return;
		initialized = true;

		FlxG.plugins.add(new Conductor());
		Assets.init();
		Controls.bindKeys();
		Judgement.reset();

		#if !NEVERMORE_NO_QUANTIZATION 
		Quantization.reset(); 
		#end

		#if !NEVERMORE_NO_MODCHARTS 
		ModchartManager.setupRedirects();
		#end

		FlxG.signals.postStateSwitch.add(() -> {
			Assets.cache.clearUnused();
		});

		settings = {};
	}
}