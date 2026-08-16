package nevermore.modchart.drawing;

#if !NEVERMORE_NO_MODCHARTS
import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;
import openfl.geom.ColorTransform;
import openfl.display.BlendMode;

@:structInit class QueuedDraw {
    public var layer:Float;

    public var luminColors:Bool;
    public var blend:BlendMode;
    public var antialiasing:Bool;

    public var scrollX:Float;
    public var scrollY:Float;

    public var cameras:Array<FlxCamera>;
    public var frame:FlxFrame;
    public var verts:Array<Float>;

    public var red:Float;
    public var green:Float;
    public var blue:Float;
    public var alpha:Float;
    public var stealth:Float;
    public var stealthGR:Float;
    public var stealthGG:Float;
    public var stealthGB:Float;
}
#end