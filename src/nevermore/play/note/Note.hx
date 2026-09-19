package nevermore.play.note;

import nevermore.shaders.NoteShader;
import nevermore.core.timing.BaseClock;

class Note extends BaseNote {
	public static var colorShader:NoteShader = new NoteShader();

	public static var modchartVertices:Array<Vector3> = [
		new Vector3(),
		new Vector3(),
		new Vector3(),
		new Vector3()
	];

	public var sustain:Sustain;

	override function set_type(v:String):String {
		strumline.skin.applyNote(this);

		switch v {
			// TODO:
			// find some way to make this a texture ??
			// nevermore doesn't have textures built-in
			case 'Mine':
				multAlpha = 0;

			case 'Fake':
				multAlpha = 0.4;
		}

		return super.set_type(v);
	}

	public var multAlpha:Float;
	public var distance:Float;

	public function setup(strumline:Strumline, data:NoteData):Note {
		this.strumline = strumline;
		this._data = data;

		sustain = null;

		multAlpha = 1;
		behavior.reset(this);
		
		visualTime = data.visualTime;
		time = data.time;
		lane = data.lane;
		player = data.player;
		beat = data.beat;
		length = data.length;
		
		this.receptor = strumline.members[lane];
		if (!strumline.quantization) quantization = false;
		else quantization = Nevermore.settings.quantization;

		color = quantization ? Quantization.current[data.quant] : FlxColor.WHITE;

		type = data.type;

		return this;
	}

	override function move(clock:BaseClock):Void {
		alpha = receptor.alpha * multAlpha;

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

	@:allow(nevermore.play.Receptor)
	static var cachePoint = FlxPoint.get();
	public var modchartPos:Vector3 = new Vector3();
	public var stealth:Float = 0;
}