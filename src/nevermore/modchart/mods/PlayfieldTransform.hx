package nevermore.modchart.mods;

class PlayfieldTransform extends BaseModifier {
	@:alias(fieldpitch) var pitch:ModifierValue = 0;
	@:alias(fieldyaw) var yaw:ModifierValue = 0;
	@:alias(fieldroll) var roll:ModifierValue = 0;

	var fieldX:ModifierValue = 0;
	var fieldY:ModifierValue = 0;
	var fieldZ:ModifierValue = 0;

	@:alias(rotationx) var localPitch:ModifierValue = 0;
	@:alias(rotationy) var localYaw:ModifierValue = 0;
	@:alias(rotationz) var localRoll:ModifierValue = 0;

	public function new(parent:ModchartManager) {
		super(parent);
		priority = 999;
	}

	override function modifiesVertex(_) {return true;}

	// should we change these to work like nITG?? We'll keep it as degrees for now but
	// maybe we should add a mod to make these act like ITG rotations (similar to how stealthtype exists in nITG and pathtype exists here)
	override function adjustVertex(_, vertex:Vector3, _, _, _, _, _, _, field:Strumline, _) {
		vertex.x += fieldX - FlxG.width * 0.5;
		vertex.y += fieldY - FlxG.height * 0.5;
		vertex.z += fieldZ;

		vertex.rotate(pitch, yaw, roll);

		vertex.x += FlxG.width * 0.5;
		vertex.y += FlxG.height * 0.5;

		// local pitch
		vertex.x -= field.centerX;
		vertex.y -= field.y;

		vertex.rotate(localPitch, localYaw, localRoll);

		vertex.x += field.centerX;
		vertex.y += field.y;	
	}
}