package nevermore.play.note;

import nevermore.core.timing.BaseClock;
import nevermore.modchart.ModchartManager;
import flixel.graphics.frames.FlxFrame;
import lime.system.System;

// a data-driven note class that you can build off of 
// for making your own note(field) system
// no rendering/drawing is done
class BaseNote extends FlxSprite {
	var _data:NoteData;
	public var behavior:NoteBehavior;

	public var strumline:Strumline;
	public var receptor:Receptor;

	public var passedStrumline:Bool;

	public var adjustedTime(get, never):Float;
	function get_adjustedTime():Float {
		return time + Nevermore.settings.inputOffset;
	}
	
	public var visualTime:Float = 0.0;
	public var time:Float = 0.0;
	public var lane:Int = 0;
	public var player:Int = 0;
	public var length:Float = 0.0;
	public var beat:Float = 0.0;
	public var quantization:Bool = false;

	@:isVar public var type(get, set):String;
	function get_type():String return behavior.type;
	function set_type(v:String):String {
		return behavior.type = v;
	}

	// kind of unintentional but also could be
	// REALLY funny for some modcharts
	public var clock(get, default):BaseClock;
	function get_clock():BaseClock {
		clock ??= Conductor.clock;
		return clock;
	}

	public function getDeviation(?timestamp:Float = 0.0):Float {
		var result:Float = adjustedTime - clock.time;

		if (timestamp > 0) {
			// this doesn't seem to do much for lagspikes
			// but i'll take it
			result -= timestamp - System.getTimer();
		}

		// this is some schizo ass code but
		// if i don't have this i get like -6 to -8 mean consistently
		// so whatever
		//
		// (why is this required all of a sudden ????????????????)
		var framerate:Float = 1 / FlxG.elapsed;
		if (framerate > FlxG.drawFramerate) {
			result -= (1 / FlxG.drawFramerate) * 1000;
		}

		return result * -1;
	}

	public function move(clock:BaseClock):Void {}

	public function new() {
		super();
		
		_data = {};
		behavior = new NoteBehavior(this);
	}

	function prepareMatrix() {
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}
	}

	override function drawComplex(camera:flixel.FlxCamera) {
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		prepareMatrix();
		camera.drawNote(_frame, _matrix, colorTransform, blend, antialiasing, quantization);
	}

	public function drawCrazy(modchart:ModchartManager, direction:ScrollDirection) {}
}