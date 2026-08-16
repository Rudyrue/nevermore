package nevermore.modchart.mods;

class OpponentSwap extends BaseModifier {
	var opponentSwap:ModifierValue = 0;

	public function new(parent:ModchartManager) {
		super(parent);
		priority = 10;
	}

	override function modifiesPosition(_):Bool {return true;}
	override function adjustPos(_, pos:Vector3, _, _, _, _, _, field:Strumline, _) {
		pos.x += ((FlxG.width - field.centerX) - field.centerX) * opponentSwap;
	}
}