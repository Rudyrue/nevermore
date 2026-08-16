package nevermore.play;

import flixel.group.FlxSpriteGroup;
import nevermore.skins.Noteskin;
import nevermore.play.Strumline;

class Strumline extends FlxTypedSpriteGroup<Receptor> {
	public var keyCount(default, set):Int = Nevermore.keyCount;
	function set_keyCount(v:Int):Int {
		keyCount = v;
		regen();
		return v;
	}

	public var size(default, set):Float = 1;
	function set_size(v:Float):Float {
		size = v;
		regen();
		return v;
	}

	public var centerX:Float;
	public var skin(default, set):Noteskin;
	function set_skin(v:Noteskin):Noteskin {
		skin = v;
		regen();
		return v;
	}

	public var curHolds:Array<Sustain> = [];

	// for similar properties between Strumline and ProxyField. as said, only for modcharts.
	public var modchartX:Float = 0;
	public var modchartY:Float = 0;
	public var modchartAlpha:Float = 1;

	public function setModchartOffset(?x:Float = 0, ?y:Float = 0) {
		this.modchartX = x;
		this.modchartY = y;
	}

	// TODO:
	// figure out a way to separate the 0.65 ?
	// because fnf has a size of 0.7 and what not
	public var constantSize(get, never):Float;
	function get_constantSize():Float {
		return 160 * 0.65 * size;
	}

	// not static in case someone wants to override it
	public var pixelsPerMS(get, never):Float;
	function get_pixelsPerMS():Float {
		return (FlxG.height / 160) / 10;
	}

	public var direction:ScrollDirection;
	public var speed:Float;
	public var ai:Bool;
	public function new(?x:Float, ?y:Float, ?skin:Noteskin) {
		this.moves = false;
		super(x, y);
		this.skin = skin;

		// center the strumline on the x position we gave it
		// instead of basing the x position on the left side of the x axis
		this.x = x - (width * 0.5);
		centerX = x;
	}

	override function set_x(v:Float):Float {
		centerX += v - x;
		return super.set_x(v);
	}

	function regen() {
		clear();

		var receptor:Receptor = null;
		for (i in 0...keyCount) {
			add(receptor = new Receptor(this, i));
			if (skin != null) skin.applyReceptor(receptor);

			receptor.x += constantSize * i;
			receptor.y += (constantSize - receptor.height) * 0.5;
		}

		receptor = null;
	}
}