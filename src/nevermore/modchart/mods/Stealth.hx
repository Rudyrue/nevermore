package nevermore.modchart.mods;

class Stealth extends BaseModifier {
	var stealth:ModifierValue = 0;
	var dark:ModifierValue = 0;
	var hidden:ModifierValue = 0;
	var sudden:ModifierValue = 0;
	var hiddenOffset:ModifierValue = 0;
	var suddenOffset:ModifierValue = 0;
	
	var stealthLANE:ModifierValue = 0;
	var darkLANE:ModifierValue = 0;

	@:alias(stealthgr) var stealthGlowRed:ModifierValue = 1;
	@:alias(stealthgg) var stealthGlowGreen:ModifierValue = 1;
	@:alias(stealthgb) var stealthGlowBlue:ModifierValue = 1;

	@:alias(stealthgrLANE) var stealthGlowRedLANE:ModifierValue = 1;
	@:alias(stealthggLANE) var stealthGlowGreenLANE:ModifierValue = 1;
	@:alias(stealthgbLANE) var stealthGlowBlueLANE:ModifierValue = 1;
	
	var stealthType:ModifierValue;

	public function new(parent:ModchartManager) {
		super(parent);
		priority = 0;
	}

	override function modifiesStealth(_):Bool {return true;}
	override function getStealth(_, stealth:Float, distance:Float, unadjustedDistance:Float, pos:Vector3, _, _, _, _, type:ObjectType) {
		final hidden = hidden;
		final hiddenOff = 160 * hiddenOffset; // i went to openitg to get this value what am i doing
		final sudden = sudden;
		final suddenOff = 160 * suddenOffset;
		final regionMult = Math.max((hidden + sudden) - 1.0, 0.0);

		if (type != RECEPTOR) {
			final usedDistance = switch (Math.floor(stealthType)) {
				case 0: (pos.y - FlxG.height * 0.5) * (parent.scrollMult > 0 ? 1 : -1) + FlxG.height * 0.5;
				case 2: unadjustedDistance;
				default: distance;
			}

			stealth += Math.min(Math.max(FlxMath.remapToRange(
				usedDistance,
				FlxG.height * (0.45 - 0.25 * regionMult) + hiddenOff,
				FlxG.height * (0.55 - 0.25 * regionMult) + hiddenOff,
				1,
				0
			), 0.0), 1.0) * hidden;
			stealth += Math.min(Math.max(FlxMath.remapToRange(
				usedDistance,
				FlxG.height * (0.45 + 0.15 * regionMult) + suddenOff,
				FlxG.height * (0.55 + 0.15 * regionMult) + suddenOff,
				0,
				1
			), 0.0), 1.0) * sudden;
			stealth += this.stealth + stealthLANE;
		} else
			stealth += dark + darkLANE;

		parent.stealthColor.x = stealthGlowRed * stealthGlowRedLANE;
		parent.stealthColor.y = stealthGlowGreen * stealthGlowGreenLANE;
		parent.stealthColor.z = stealthGlowBlue * stealthGlowBlueLANE;

		return stealth;
	}
}