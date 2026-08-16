package nevermore.modchart.mods;

class Accel extends BaseModifier {
	var boost:ModifierValue = 0;
	var brake:ModifierValue = 0;
	var wave:ModifierValue = 0;
	var wavePeriod:ModifierValue = 0;

	public function new(parent:ModchartManager) {
		super(parent);
		priority = 0;
	}

	// https://github.com/riconuts/FNF-Troll-Engine/blob/main/source/funkin/modchart/modifiers/AccelModifier.hx#L8
	override function modifiesDistance(_):Bool {return true;}
	override function adjustDistance(_, distance:Float, _, _, _, _, _, _) {
		var effectHeight = 720;
		var yAdjust:Float = 0;

		final brake = brake; // avoid regetting
		if (brake != 0) {
			final scale = distance / FlxG.height;
			final off = distance * scale;
			yAdjust += Math.min(Math.max(brake * (off - distance), -600), 600);
		}

		final boost = boost;
		if (boost != 0) {
			final off = distance * 1.5 / ((distance + effectHeight / 1.2) / FlxG.height);
			yAdjust += Math.min(Math.max(boost * (off - distance), -600), 600);
		}

		final wave = wave;
		final wavePeriod = wavePeriod;
		if (wavePeriod != -1 /**< no division by 0**/ && wave != 0) 
			yAdjust += wave * 40 * Math.sin(distance / ((114 * wavePeriod) + 114));

		return distance + yAdjust;
	}
}