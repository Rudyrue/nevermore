package nevermore.modchart.timeline;

#if !NEVERMORE_NO_MODCHARTS
class BaseEvent {
    public var beat:Float = 0.0;
    public var instant:Bool = false;

    public function start() {}
    public function tick(curBeat:Float) {}
    public function canFinish(curBeat:Float) {return true;}
}
#end