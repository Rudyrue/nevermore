package nevermore.modchart.mods;

class Swaps extends BaseModifier {
	var flip:ModifierValue = 0;
	var invert:ModifierValue = 0;

	public function new(parent:ModchartManager) {
		super(parent);
		priority = 0;
	}

	override function modifiesPosition(_) {return true;}
	override function adjustPos(_, pos:Vector3, _, _, _, lane:Int, player:Int, field:Strumline, _) {
		/*var newLane = lane + (1 - ((lane % 2) * 2)) * getValue(INVERT_INDEX, player);
		newLane += ((1.5 - newLane) * 2) * getValue(FLIP_INDEX, player);
		pos.x += field.constantSize * (newLane - lane);*/
		
		// vv closer to how Stepmania/ITG works
		pos.x += field.constantSize * ((lane % 2 == 0) ? 1 : -1) * invert;
		pos.x += field.constantSize * 2 * ((parent.laneCount - 1) * 0.5 - lane) * flip;
	}
}