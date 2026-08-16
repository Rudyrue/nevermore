package nevermore.modchart.timeline;

#if !NEVERMORE_NO_MODCHARTS
import nevermore.modchart.BaseModifier;
import nevermore.modchart.ModchartManager.ModRedirect;
import nevermore.modchart.timeline.BaseEvent;

class FuncEvent extends BaseEvent {
    public var length:Float;
    public var ease:Float -> Float;

    public var startVal:Float = 0;
    public var range:Float = 1;
    public var func:Float->Float->Void;

    public function new(beat:Float, length:Float, func:Float -> Float -> Void, ?ease:Float -> Float, ?startVal:Float = 0, ?endVal:Float = 1) {
        this.instant = length <= 0;

        this.beat = beat;
        this.length = length;
        this.ease = ease != null ? ease : FlxEase.linear;
        this.func = func;

        this.startVal = startVal;
        this.range = endVal - startVal;
    }

    override function start() {
        if (!instant) return;

		try {
            func(1, beat);
		} catch(e:haxe.Exception)
			trace('error in an event ${e.details()}');
    }

    override function tick(curBeat:Float) {
        var percent = Math.min((curBeat - beat) / length, 1);
        percent = ease(percent);

        func(startVal + range * percent, curBeat);
    }

    override function canFinish(curBeat:Float) {
        return curBeat - beat >= length;
    }
}
#end