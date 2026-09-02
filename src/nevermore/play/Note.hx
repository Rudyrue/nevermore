package nevermore.play;

import lime.app.Application;
import lime.system.System;
import flixel.graphics.frames.FlxFrame;
import nevermore.core.NoteData;
import nevermore.core.Judgement;
import nevermore.core.timing.BaseClock;
import nevermore.play.Receptor;
import nevermore.play.Strumline;
#if !NEVERMORE_NO_MODCHARTS
import nevermore.modchart.ModchartManager;
#end
import nevermore.shaders.NoteShader;

// TODO:
// figure out how to make custom types with this
// NOT a major pain in the ass
// and it doesn't look like shit at the same time
//
// also by proxy maybe try and separate *some* of this ?
// so that the end user still has to do some work
// if they wanna add more functionality
// (especially stuff like types)
// but it should still be plug and play at its core
class Note extends flixel.FlxSprite {
	public static var colorShader:NoteShader = new NoteShader();

	public var receptor:Receptor;
	public var strumline:Strumline;
	public var sustain:Sustain;
	public var quants:Bool;

	public var visualTime:Float;
	public var missed:Bool;
	public var time:Float;
	public var lane:Int;
	public var player:Int;
	public var distance:Float;
	public var beat:Float;
	public var length:Float;

	// kind of unintentional but also could be
	// REALLY funny for some modcharts
	public var clock(get, default):BaseClock;
	function get_clock():BaseClock {
		clock ??= Conductor.clock;
		return clock;
	}

	public static var modchartVertices:Array<Vector3> = [
		new Vector3(),
		new Vector3(),
		new Vector3(),
		new Vector3()
	];

	// TODO: make this better ????????????
	// typeList.set(name, function(note:Note) {});
	public static var typeList:Map<String, Note -> Void> = [];

	public var type(default, set):String;
	function set_type(v:String):String {
		strumline.skin.applyNote(this);

		type = v;

		// should only run for each time a note has a type
		// instead of EVERY note
		// not the best but it's better than nothing
		if (v.length != 0) {
			if (typeList.exists(v)) typeList[v](this);
		}

		return v;
	}

	public var adjustedTime(get, never):Float;
	function get_adjustedTime():Float {
		return time + Nevermore.settings.inputOffset;
	}

	public var hittable(get, never):Bool;
	function get_hittable():Bool {
		var early:Bool = adjustedTime < clock.time + Judgement.max.window;
		var late:Bool = adjustedTime > clock.time - Judgement.max.window;

		return exists && (early && late);
	}

	public var tooLate(get, never):Bool;
	public var missPadding:Float = 25;
	function get_tooLate():Bool {
		return (adjustedTime - clock.time) < -(Judgement.max.window + missPadding);
	}

	public var deviation(get, never):Float;
	function get_deviation():Float {
		var result:Float = adjustedTime - clock.time;

		#if (lime >= version("8.4.0"))
		// this doesn't seem to do much for lagspikes
		// but i'll take it
		var timestamp:Int = Application.current.window.onKeyDown.timestamp;
		result -= timestamp - System.getTimer();
		#end

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

	public function new() {
		super();
		active = false;
		moves = false;
	}

	public function setup(strumline:Strumline, data:NoteData):Note {
		this.strumline = strumline;

		sustain = null;
		missed = false;
		#if !NEVERMORE_NO_QUANTIZATION
		quants = Nevermore.settings.quantization;
		#end

		length = data.length;

		visualTime = data.visualTime;
		time = data.time;
		lane = data.lane;
		player = data.player;
		beat = data.beat;
		type = data.type;

		#if !NEVERMORE_NO_QUANTIZATION
		if (quants) color = Quantization.current[data.quant];
		#end

		receptor = strumline.members[lane];
		return this;
	}

	public function move(clock:BaseClock):Void {
		alpha = receptor.alpha;
		visible = receptor.visible;

		var adjustedTime:Float = clock.usesScrollVelocities ? visualTime : adjustedTime;

		var deviation:Float = (adjustedTime - clock.time) + Nevermore.settings.visualOffset;
		var adjustedSpeed:Float = (strumline.speed * strumline.pixelsPerMS);

		distance = deviation * (adjustedSpeed / clock.rate);

		this.x = switch strumline.direction {
			//case TAIKO: receptor.x + distance;
			default: receptor.x;
		}

		this.y = switch strumline.direction {
			case UP: receptor.y + distance;
			case DOWN: receptor.y + (distance * -1);
			default: receptor.y;
			//case TAIKO: receptor.y;
		}
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
		camera.drawNote(_frame, _matrix, colorTransform, blend, antialiasing, quants);
	}

	#if !NEVERMORE_NO_MODCHARTS
	@:allow(nevermore.play.Receptor)
	static var cachePoint = FlxPoint.get();
	public var stealth:Float = 0;
	public var modchartPos:Vector3 = new Vector3();
	public function drawCrazy(modchart:ModchartManager, direction:ScrollDirection, field:Strumline) {
		final mult = direction == DOWN ? -1 : 1;
		modchart.stealthColor.set(1.0, 1.0, 1.0);
		modchart.scrollMult = mult;

		modchart.curLane = lane;
		modchart.curField = player;
		
		final oldX = x;
		final oldY = y;
		final oldScaleX = scale.x;
		final oldScaleY = scale.y;

		var newDistance:Float = modchart.adjustDistance(this, distance * mult, lane, player, field, NOTE);
		
		var rawY:Float = y - distance;
		modchartPos.set(x + width * 0.5, (rawY + (newDistance * mult)) + height * 0.5, 0);

		modchart.adjustPos(this, modchartPos, newDistance, distance * mult, lane, player, field, NOTE);
		modchart.adjustScale(this, scale, newDistance, lane, player, field, NOTE); // TODO: add newDistance to the args of this and getStealth
		stealth = modchart.getStealth(this, newDistance, distance * mult, modchartPos, lane, player, field, NOTE);

		x = modchartPos.x - width * 0.5;
		y = modchartPos.y - height * 0.5;
		final layer = modchartPos.z;
		_frame.prepareMatrix(_matrix, ANGLE_0, checkFlipX(), checkFlipY());
		prepareMatrix();
		_matrix.translate(cameras[0].scroll.x * scrollFactor.x, cameras[0].scroll.y * scrollFactor.y);
		x = oldX;
		y = oldY;
		scale.set(oldScaleX, oldScaleY);

		modchartVertices[0].set(_matrix.transformX(0, 0), _matrix.transformY(0, 0), modchartPos.z);
		modchartVertices[1].set(_matrix.transformX(_frame.frame.width, 0), _matrix.transformY(_frame.frame.width, 0), modchartPos.z);
		modchartVertices[2].set(_matrix.transformX(0, _frame.frame.height), _matrix.transformY(0, _frame.frame.height), modchartPos.z);
		modchartVertices[3].set(_matrix.transformX(_frame.frame.width, _frame.frame.height), _matrix.transformY(_frame.frame.width, _frame.frame.height), modchartPos.z);

		final orient:Float = modchart.get("orient", player);
		if (orient != 0){
			final orientOffset: Float = modchart.get("orientoffset", player);
			final cacheX:Float = modchartPos.x;
			final cacheY:Float = modchartPos.y;
			final cacheZ:Float = modchartPos.z;
			modchartPos.set(x + width * 0.5, (rawY + ((newDistance + 2) * mult)) + height * 0.5, 0);
			modchart.adjustPos(this, modchartPos, newDistance + 2, (distance * mult) + 2, lane, player, field, NOTE);

			cachePoint.set(modchartPos.x - cacheX, modchartPos.y - cacheY);
			cachePoint.rotateByDegrees(orientOffset);

			final diffX:Float = cachePoint.x;
			final diffY:Float = cachePoint.y;

			for (i => vert in modchartVertices) {	
				vert.x -= modchartPos.x;
				vert.y -= modchartPos.y;
				vert.z -= modchartPos.z;
				vert.rotateRads(0, 0, orient * (Math.atan2(diffY, diffX) - (Math.PI / 2)));
				vert.x += modchartPos.x;
				vert.y += modchartPos.y;
				vert.z += modchartPos.z;
			}
			modchartPos.set(cacheX, cacheY, cacheZ);
		}

		for (i => vert in modchartVertices) {
			modchart.adjustVertex(this, vert, modchartPos, newDistance, distance * mult, lane, player, field, NOTE);
			vert.project();
		}

		modchart.pushDraw(player, field, cameras, scrollFactor, _frame, modchartVertices, colorTransform, blend, antialiasing, quants, stealth, layer);
	}
	#end
}