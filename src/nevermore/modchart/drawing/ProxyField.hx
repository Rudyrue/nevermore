package nevermore.modchart.drawing;

#if !NEVERMORE_NO_MODCHARTS
import flixel.FlxCamera;

@:allow(nevermore.modchart.ModchartManager)
class ProxyField {
	public var targetIdx:Int = 0;

	// These 3 behave more as offsets.
	public var x:Float = 0;
	public var y:Float = 0;
	public var layer:Float = 0;

	public var scaleX:Float = 1;
	public var scaleY:Float = 1;

	public var scrollX:Float = 1;
	public var scrollY:Float = 1;

	public var visible:Bool = true;
	public var alpha:Float = 1;

	public var camera(get, set):FlxCamera;
	public var cameras(get, set):Array<FlxCamera>;
	var _cameras:Array<FlxCamera>;

	public function new(target:Int, ?x:Float = 0, ?y:Float = 0) {
		this.targetIdx = target;
		this.x = x;
		this.y = y;
	}

	public function setPosition(?x:Float = 0, ?y:Float = 0) {
		this.x = x;
		this.y = y;
	}

	public function setScale(?x:Float = 1, ?y:Float) {
		this.scaleX = x;
		this.scaleY = (y != null) ? y : x;
	}

	public function setScroll(?x:Float = 1, ?y:Float) {
		this.scrollX = x;
		this.scrollY = (y != null) ? y : x;
	}

	function get_camera() {
		@:privateAccess return (_cameras == null || _cameras.length == 0) ? FlxCamera._defaultCameras[0] : _cameras[0];
	}

	function set_camera(to:FlxCamera) {
		if (_cameras == null)
			_cameras = [to];
		else
			_cameras[0] = to;
		return to;
	}

	function get_cameras() {
		@:privateAccess return (_cameras == null) ? FlxCamera._defaultCameras : _cameras;
	}

	function set_cameras(to:Array<FlxCamera>) {
		return _cameras = to;
	}
}
#end