package nevermore.modchart.timeline;

#if !NEVERMORE_NO_MODCHARTS
import nevermore.modchart.BaseModifier;
import nevermore.modchart.ModchartManager.ModRedirect;
import nevermore.modchart.timeline.BaseEvent;

class ModEvent extends BaseEvent {
	public var length:Float;
	public var ease:Float->Float;

	public var mod:BaseModifier;
	public var lane:Int = -1;
	public var index:Int = 0;
	public var startValue:Array<Float> = null;
	public var endValue:Float;
	public var strumline:Int = -1;

	public function new(beat:Float, length:Float, redirect:ModRedirect, value:Float, ?ease:Float->Float, ?strumline:Int = -1, ?startVal: Float) {
		this.instant = false;

		this.beat = beat;
		this.length = length;
		this.ease = ease != null ? ease : FlxEase.linear;
		
		this.mod = redirect.toInstance;
		this.endValue = value;
		this.lane = redirect.lane;
		this.index = redirect.index;
		this.strumline = strumline;
		this.startValue = startVal != null ? [startVal] : null;
	}

	override function start() {
		inline function getVal(plr:Int)
			return startValue == null ? mod.getValue(index, plr) : startValue[0];

		mod.parent.curLane = lane;
		var newStarts = (strumline < 0) ? [
			for (plr in 0...mod.values.length)
				getVal(plr)
		] : [getVal(strumline)];
		startValue = newStarts;

		if (length <= 0)
			mod.setValue(index, endValue, strumline);
	}

	override function tick(curBeat:Float) {
		mod.parent.curLane = lane;
		if (length <= 0) {
			mod.setValue(index, endValue, strumline);
		} else {
			var percent: Float = Math.min((curBeat - beat) / length, 1);
			percent = ease(percent);

			if (strumline < 0) {
				for (plr in 0...startValue.length)
					mod.setValue(index, FlxMath.lerp(startValue[plr], endValue, percent), plr);
			} else
				mod.setValue(index, FlxMath.lerp(startValue[0], endValue, percent), strumline);
		}
	}

	override function canFinish(curBeat:Float) {
		return length <= 0 || curBeat - beat >= length;
	}
}
#end