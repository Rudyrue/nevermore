package nevermore.modchart.mods;

// Maybe we can do Reverse seperate from a modifier??
// Reason being, for us to be accurate to ITG some modifiers need to have access to the y distance with reverse already factored in
// So it might be good for us to do reverse seperately so we can have access to how that affects the position and pass that into functions
// :shrug: who cares rn lmao we dont need to be 1000% accurate we just need to *look* accurate enough
class Reverse extends BaseModifier {
	var reverse:ModifierValue = 0;
	var reverseLANE:ModifierValue = 0;

	var cross:ModifierValue = 0;
	var split:ModifierValue = 0;
	var alternate:ModifierValue = 0;

	var centered:ModifierValue = 0;

	public function new(parent:ModchartManager) {
		super(parent);
		priority = -5;
	}

	public function getReverse(lane:Int) {
		parent.curLane = lane; // just in case
		var reverse = reverse + reverseLANE;

		if (lane >= 2)
			reverse += split;
		if (lane % 2 == 1)
			reverse += alternate;
		if (lane >= 1 && lane <= 2)
			reverse += cross;

		return reverse;
	}

	override function modifiesPosition(_):Bool {return true;}
	override function adjustPos(_, pos:Vector3, distance:Float, _, _, lane:Int, _, _, _) {
		final reverseMult = 1 - getReverse(lane) * 2;
		final centeredMult = centered;
		var curY = pos.y - FlxG.height * 0.5;

		curY *= reverseMult;
		curY *= 1 - centeredMult;

		parent.scrollMult *= reverseMult;
		curY += (distance * parent.scrollMult) * centeredMult;

		pos.y = curY + FlxG.height * 0.5;
	}
}