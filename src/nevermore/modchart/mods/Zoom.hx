package nevermore.modchart.mods;

class Zoom extends BaseModifier {
	var zoom:ModifierValue = 1;
	var zoomX:ModifierValue = 1;
	var zoomY:ModifierValue = 1;
	var mini:ModifierValue = 0;

	public function new(parent:ModchartManager) {
		super(parent);
		priority = 6;
	}

	override function modifiesPosition(_) {return true;}
	override function adjustPos(_, pos:Vector3, _, _, _, _, _, field:Strumline, _) {
		pos.x -= field.centerX;
		pos.y -= FlxG.height * 0.5;

		final mainZoom = zoom - mini * 0.5;
		pos.x *= mainZoom * zoomX;
		pos.y *= mainZoom * zoomY;

		pos.x += field.centerX;
		pos.y += FlxG.height * 0.5;
	}

	override function modifiesScale(_) {return true;}
	override function adjustScale(_, scale:FlxPoint, _, _, _, _, _, _) {
		final mainZoom = zoom - mini * 0.5;
		scale.x *= mainZoom * zoomX;
		scale.y *= mainZoom * zoomY;
	}
}