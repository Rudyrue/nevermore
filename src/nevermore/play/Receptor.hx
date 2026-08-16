package nevermore.play;

import flixel.graphics.frames.FlxFrame;
#if !NEVERMORE_NO_MODCHARTS
import nevermore.modchart.ModchartManager;
#end

class Receptor extends flixel.FlxSprite {
	public var lane:Int;
	public var isHolding:Bool = false;
	public var parent:Strumline;
	public var quants:Bool = false;
	public function new(parent:Strumline, lane:Int) {
		super();
		this.parent = parent;
		this.lane = lane;

		animation.finishCallback = anim -> {
			if (isHolding) return;
			
			var waitForAnim = !parent.ai;

			if (waitForAnim) return;
			glow('standard');
		}
	}

	public function glow(?name:String, ?note:Note) {
		name ??= 'glow';
		quants = note != null && note.quants;
		color = quants ? note.color : FlxColor.WHITE;

		animation.play(name, true);
		centerOffsets();
		centerOrigin();
	}

	function prepareMatrix() {
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}
		_matrix.translate(camera.scroll.x * scrollFactor.x, camera.scroll.y * scrollFactor.y);
	}

	override function drawComplex(camera:flixel.FlxCamera) {
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		prepareMatrix();
		camera.drawNote(_frame, _matrix, colorTransform, blend, antialiasing, quants);
	}

	#if !NEVERMORE_NO_MODCHARTS
	public var modchartPos:Vector3 = new Vector3();
	public var modchartDist:Float = 0;
	public var oldScaleX:Float = 1;
	public var oldScaleY:Float = 1;
	public var scrollMult:Float = 1;
	public var stealth:Float = 0;
	public var stealthColor:Vector3 = new Vector3();

	public function preDrawCrazy(modchart:ModchartManager, player:Int, direction:ScrollDirection, field:Strumline) {
		modchart.curLane = lane;
		modchart.curField = player;

		oldScaleX = scale.x;
		oldScaleY = scale.y;
		final mult:Float = direction == DOWN ? -1 : 1;
		modchart.stealthColor.set(1.0, 1.0, 1.0);
		modchart.scrollMult = mult;

		modchartDist = modchart.adjustDistance(this, 0, lane, player, field, RECEPTOR);
		modchartPos.set(x + width * 0.5, y + height * 0.5 + (modchartDist * mult), 0);
		modchart.adjustPos(this, modchartPos, modchartDist, 0, lane, player, field, RECEPTOR);
		modchart.adjustScale(this, scale, modchartDist, lane, player, field, RECEPTOR);
		stealth = modchart.getStealth(this, modchartDist, 0, modchartPos, lane, player, field, RECEPTOR);
		
		scrollMult = modchart.scrollMult;
		stealthColor.copyFrom(modchart.stealthColor);
	}

	public function drawCrazy(modchart:ModchartManager, player:Int, direction:ScrollDirection, field:Strumline) {
		modchart.curLane = lane;
		modchart.curField = player;
		if (modchart.arrowPath != null)
			modchart.arrowPath.drawPath(this, player, direction, field);

		final oldX = x;
		final oldY = y;
		modchart.stealthColor.copyFrom(stealthColor);
		modchart.scrollMult = scrollMult;

		x = modchartPos.x - width * 0.5;
		y = modchartPos.y - height * 0.5;
		final layer = modchartPos.z;
		_frame.prepareMatrix(_matrix, ANGLE_0, checkFlipX(), checkFlipY());
		prepareMatrix();

		x = oldX;
		y = oldY;
		scale.set(oldScaleX, oldScaleY);

		Note.modchartVertices[0].set(_matrix.transformX(0, 0), _matrix.transformY(0, 0), modchartPos.z);
		Note.modchartVertices[1].set(_matrix.transformX(_frame.frame.width, 0), _matrix.transformY(_frame.frame.width, 0), modchartPos.z);
		Note.modchartVertices[2].set(_matrix.transformX(0, _frame.frame.height), _matrix.transformY(0, _frame.frame.height), modchartPos.z);
		Note.modchartVertices[3].set(_matrix.transformX(_frame.frame.width, _frame.frame.height), _matrix.transformY(_frame.frame.width, _frame.frame.height), modchartPos.z);
		
		final orient:Float = modchart.get("orient", player);
		if (orient != 0){
			final orientOffset: Float = modchart.get("orientoffset", player);
			final cacheX:Float = modchartPos.x;
			final cacheY:Float = modchartPos.y;
			final cacheZ:Float = modchartPos.z;
			final mult: Float = direction == DOWN ? -1 : 1;
			modchartPos.set(x + width * 0.5, y + (height * 0.5) + ((modchartDist + 2) * mult), 0);
			modchart.adjustPos(this, modchartPos, modchartDist + 2, 2, lane, player, field, RECEPTOR);

			Note.cachePoint.set(modchartPos.x - cacheX, modchartPos.y - cacheY);
			Note.cachePoint.rotateByDegrees(orientOffset);

			final diffX:Float = Note.cachePoint.x;
			final diffY:Float = Note.cachePoint.y;

			for (i => vert in Note.modchartVertices){	
				vert.x -= modchartPos.x;
				vert.y -= modchartPos.y;
				vert.z -= modchartPos.z;
				vert.rotateRads(0, 0, orient * (Math.atan2(diffY, diffX) - (Math.PI / 2)));
				vert.x += modchartPos.x;
				vert.y += modchartPos.y;
				vert.z += modchartPos.z;
			}
			modchartPos.set(cacheX, cacheY, cacheZ);
		}

		for (vert in Note.modchartVertices) {
			modchart.adjustVertex(this, vert, modchartPos, modchartDist, 0, lane, player, field, RECEPTOR);
			vert.project();
		}

		modchart.pushDraw(player, field, cameras, scrollFactor, _frame, Note.modchartVertices, colorTransform, blend, antialiasing, quants, stealth, layer, true);
	}
	#end
}