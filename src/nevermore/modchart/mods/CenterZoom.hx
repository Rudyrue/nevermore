package nevermore.modchart.mods;

class CenterZoom extends BaseModifier {
	var centerZoom:ModifierValue = 1;
	var centerZoomX:ModifierValue = 1;
	var centerZoomY:ModifierValue = 1;
	var centerMini:ModifierValue = 0;

	public function new(parent:ModchartManager) {
		super(parent);
		priority = 16;
	}

	override function modifiesPosition(_) {return true;}
	override function adjustPos(_, pos:Vector3, _, _, _, _, _, _, _) {
		pos.x -= FlxG.width * 0.5;
		pos.y -= FlxG.height * 0.5;

		final mainZoom = centerZoom - centerMini * 0.5;
		pos.x *= mainZoom * centerZoomX;
		pos.y *= mainZoom * centerZoomY;

		pos.x += FlxG.width * 0.5;
		pos.y += FlxG.height * 0.5;
	}

	override function modifiesScale(_) {return true;}
	override function adjustScale(_, scale:FlxPoint, _, _, _, _, _, _) {
		final mainZoom = centerZoom - centerMini * 0.5;
		scale.x *= mainZoom * centerZoomX;
		scale.y *= mainZoom * centerZoomY;
	}
}