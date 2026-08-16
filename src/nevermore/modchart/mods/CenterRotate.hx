package nevermore.modchart.mods;

class CenterRotate extends BaseModifier {
	var centerRotateX:ModifierValue = 0;
	var centerRotateY:ModifierValue = 0;
	var centerRotateZ:ModifierValue = 0;

	var centerRotateXLANE:ModifierValue = 0;
	var centerRotateYLANE:ModifierValue = 0;
	var centerRotateZLANE:ModifierValue = 0;

	public function new(parent:ModchartManager) {
		super(parent);
		priority = 15;
	}

	override function modifiesPosition(_):Bool {return true;}
	override function adjustPos(_, pos:Vector3, _, _, _, _, _, _, _) {
		pos.x -= FlxG.width * 0.5;
		pos.y -= FlxG.height * 0.5;

		pos.rotate(
			centerRotateX + centerRotateXLANE,
			centerRotateY + centerRotateYLANE,
			centerRotateZ + centerRotateZLANE
		);

		pos.x += FlxG.width * 0.5;
		pos.y += FlxG.height * 0.5;
	}
}