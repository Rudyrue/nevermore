package nevermore.modchart;

#if !NEVERMORE_NO_MODCHARTS
import nevermore.modchart.ModchartManager;

class AuxModifier extends nevermore.modchart.BaseModifier {
    public var defaultValue:Float;

    public function new(parent:ModchartManager, defaultValue:Float) {
        priority = 0;

        this.defaultValue = defaultValue;
        super(parent);
    }

    override public function addStrumlineSet() {
        super.addStrumlineSet();
        values.push([defaultValue]);
    }

    override function isActive(vals:Array<Float>) {
        return vals[0] != defaultValue;
    }
}
#end