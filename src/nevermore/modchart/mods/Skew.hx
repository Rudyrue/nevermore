package nevermore.modchart.mods;

class Skew extends BaseModifier {
	var skewX:ModifierValue = 0;
	var skewY:ModifierValue = 0;

	public function new(parent:ModchartManager) {
		super(parent);
		priority = 4;
	}

	override function modifiesVertex(_) {return true;}
	override function adjustVertex(_, vertex:Vector3, _, _, _, _, _, _, field:Strumline, _) {
		vertex.x -= field.centerX;
		vertex.y -= FlxG.height * 0.5;

		vertex.x += vertex.y * skewX;
		vertex.y += FlxG.height * vertex.x / (field.constantSize * 4) * skewY;

		vertex.x += field.centerX;
		vertex.y += FlxG.height * 0.5;
	}
}