package nevermore.modchart.timeline;

#if !NEVERMORE_NO_MODCHARTS
import nevermore.modchart.timeline.BaseEvent;

class ModchartTimeline {
    var curEvent:Int = 0;
    var events:Array<BaseEvent>;
    public var running:Array<BaseEvent>;

    public function new() {
        events = [];
        running = [];
    }

    public function add(event:BaseEvent) {
        // fuck it, only sort 1 thingy
        var i = events.length;
        while (i > 0 && events[i - 1].beat > event.beat) {
            --i;
		}
        events.insert(i, event);
    }

    public function update() {
        while (curEvent < events.length && events[curEvent].beat <= Conductor.beat) {
            final event = events[curEvent];
            event.start();
            if (!event.instant)
                running.push(event);
            ++curEvent;
        }

        var i = 0;
        while (i < running.length) {
			try {
            	running[i].tick(Conductor.beat);
			} catch(e:haxe.Exception) {
				trace('error in an event ${e.message}');
				running.splice(i, 1);
				continue;
			}

            if (running[i].canFinish(Conductor.beat))
                running.splice(i, 1);
            else ++i;
        }
    }
}
#end