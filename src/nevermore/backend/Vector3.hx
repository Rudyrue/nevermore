package nevermore.backend;

import flixel.math.FlxPoint;
import flixel.math.FlxAngle;

class Vector3 {
    public var x:Float;
    public var y:Float;
    public var z:Float;

    public function new(?x:Float = 0, ?y:Float = 0, ?z:Float = 0) set(x, y, z);

    public function set(?x:Float = 0, ?y:Float = 0, ?z:Float = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function copyFrom(vec:Vector3) {
        this.x = vec.x;
        this.y = vec.y;
        this.z = vec.z;
    }

    // these are just from troll engine, with slight modifications
	// (https://github.com/riconuts/FNF-Troll-Engine/blob/main/source/math/VectorHelpers.hx)
    static var cachePoint1 = FlxPoint.get();
    static var cachePoint2 = FlxPoint.get();

    public function project() {
        var scale = Math.abs(-1280 / (z - 1280));
		x = (x - FlxG.width * 0.5) * scale + FlxG.width * 0.5;
        y = (y - FlxG.height * 0.5) * scale + FlxG.height * 0.5;

        return this;
    }

	// thanks schmoovin' -troll_engine
	public function rotateRads(x:Float, y:Float, z:Float) {
        cachePoint1.set(this.x, this.y).rotateByRadians(z);
        cachePoint2.set(cachePoint1.x, this.z).rotateByRadians(y);

        var xSin = Math.sin(x);
        var xCos = Math.cos(x);
		if (Math.abs(xSin) < 0.001) xSin = 0;

		if (Math.abs(xCos) < 0.001) xCos = 0;

        this.x = cachePoint2.x;
        this.y = cachePoint2.y * xSin + cachePoint1.y * xCos;
        this.z = cachePoint2.y * xCos - cachePoint1.y * xSin;

        return this;
    }
	
    inline public function rotate(x:Float, y:Float, z:Float)
        return rotateRads(x * FlxAngle.TO_RAD, y * FlxAngle.TO_RAD, z * FlxAngle.TO_RAD);
}