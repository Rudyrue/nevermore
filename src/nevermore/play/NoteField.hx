package nevermore.play;

import flixel.group.FlxSpriteGroup;
import flixel.FlxCamera;
import nevermore.play.note.*;

class NoteField extends BaseField {
	public var sustains:FlxTypedSpriteGroup<Sustain>;
	public var strumlines:FlxTypedSpriteGroup<Strumline>;
	public var notes:FlxTypedSpriteGroup<Note>;

	public dynamic function noteHit(strumline:Strumline, note:Note):Void {}
	public dynamic function noteMiss(strumline:Strumline, note:Note):Void {}
	public dynamic function sustainHit(strumline:Strumline, sustain:Sustain, mostRecent:Bool):Void {}
	public dynamic function sustainDropped(strumline:Strumline, sustain:Sustain):Void {}
	public dynamic function ghostTap(strumline:Strumline, dir:Int):Void {}

	override function set_playerID(v:Int):Int {
		v = FlxMath.minInt(v, strumlines.length - 1);

		for (i => line in strumlines.members) {
			line.ai = (v == i) ? autoplay : true;
		}

		return playerID = v;
	}

	override function set_autoplay(v:Bool):Bool {
		return autoplay = getStrumline(playerID).ai = v;
	}

	override function set_scrollSpeed(v:Float):Float {
		for (line in strumlines.members) {
			line.speed = v;
		}

		for (sustain in sustains.members) {
			sustain.forceHeightRecalc = true;

			var speed:Float = v / clock.rate;
			var longHolds:Float = modchart == null ? 1 : (modchart.get('longholds', sustain.player) + 1);
			sustain.calcHeight(speed * longHolds);
		}

		return scrollSpeed = v;
	}

	override function set_scrollDirection(v:ScrollDirection):ScrollDirection {
		for (line in strumlines.members) {
			line.direction = v;
		}

		return scrollDirection = v;
	}

	public var assistTicks:Bool = false;
	public var tickSound:FlxSound;

	public function new(?lines:Array<Strumline>, ?playerID:Int = 0) {
		sustains = new FlxTypedSpriteGroup<Sustain>();
		sustains.active = false;

		strumlines = new FlxTypedSpriteGroup<Strumline>();

		notes = new FlxTypedSpriteGroup<Note>();
		notes.active = false;

		for (line in lines ?? []) {
			strumlines.add(line);
		}

		super();

		this.playerID = playerID;

		add(sustains);
		add(strumlines);
		add(notes);
	}

	var killDelay:Float = 300;
	override function update(delta:Float) {
		super.update(delta);

		for (i in 0 ... notes.length) {
			var note:Note = notes.members[i];

			if (!note.passedStrumline) checkAssistTick(note);
			if (!note.exists) continue;

			if (note.active) note.update(delta);
			note.move(scrollVelocities ? velocityClock : clock);

			// should probably move this to a separate function later
			if (note.strumline.ai) {
				if (note.adjustedTime - clock.time <= 0) {
					note.kill();
					if (note.sustain != null) {
						note.sustain.wasHit = true;
					}

					noteHit(note.strumline, note);
				}
			} else if (!note.missed && !note.behavior.ignore && note.late) {
				note.missed = true;
				noteMiss(note.strumline, note);
			}

			if (note.adjustedTime < clock.time - killDelay) {
				note.kill();
			}
		}

		for (i in 0 ... sustains.length) {
			var sustain:Sustain = sustains.members[i];
			if (!sustain.exists) continue;

			if (sustain.active) sustain.update(delta);

			holdInputs(sustain);
			sustain.move(scrollVelocities ? velocityClock : clock);
			sustain.calcHeight(sustain.strumline.speed / clock.rate);

			if (sustain.adjustedTime + sustain.length < clock.time - killDelay) {
				sustain.kill();
			}
		}
	}

	function checkAssistTick(note:Note) {
		if (note.time - clock.time > 0) return;
		note.passedStrumline = true;

		if (note.player != playerID) return;
		if (!note.behavior.hittable || note.behavior.punishable) return;

		if (tickSound == null || !assistTicks) return;
		tickSound.play(true);
	}

	override function getStrumline(id:Int):Strumline {
		id = FlxMath.minInt(id, strumlines.length - 1);
		return strumlines.members[id];
	}

	function addNote<T:Note>(data:NoteData, group:FlxTypedSpriteGroup<T>, cls:Class<T>):T {
		var obj:T = group.recycle(cls);
		group.remove(obj, true); // keep ordering
		group.add(cast obj.setup(getStrumline(data.player), data));

		return obj;
	}

	override function noteSpawned(data:NoteData) {
		if (data.player >= strumlines.length) return;

		var note = addNote(data, notes, Note);
		if (data.length > 0) {
			var sustain = addNote(data, sustains, Sustain);

			var speed:Float = sustain.strumline.speed / clock.rate;
			var longHolds:Float = modchart == null ? 1 : (modchart.get('longholds', data.player) + 1);
			sustain.calcHeight(speed * longHolds);

			note.sustain = sustain;
		}
	}

	var held:Array<Bool> = [for (i in 0...Nevermore.keyCount) false];
	var mirrorInputs:Array<Int> = [];
	override function pressed(direction:Int) {
		if (autoplay || Nevermore.paused) return;

		if (held[direction]) return;
		held[direction] = true;

		var note:Note = tapInputs(direction, playerID);
		if (note == null) {
			ghostTap(getStrumline(playerID), direction);
		} else {
			noteHit(note.strumline, note);
		}

		for (i in mirrorInputs) tapInputs(direction, i);
	}

	override function released(direction:Int) {
		if (autoplay) return;

		held[direction] = false;
	}

	// you don't have to do inputs like this
	// a simple sort and then list[0] should do the job 
	// but for something this caliber it needs to handle it a bit more accurately
	function tapInputs(direction:Int, ?id:Int):Note {
		id ??= playerID;

		var strumline = getStrumline(id);
		var receptor:Receptor = strumline.members[direction];

		var closestDistance:Float = Math.POSITIVE_INFINITY;
		var noteToHit:Note = null;
		for (i in 0 ... notes.length) {
			var note:Note = notes.members[i];
			if (!note.exists) continue;

			// is it on the player's strumline?
			// is it in the correct lane?
			if (note.player != id || note.lane != direction) continue;

			// is the note hittable in general?
			// is it within range?
			if (!note.behavior.hittable || !note.inRange) continue;

			// checks if the note is the closest to the judgement line
			// rather than the first available note
			// possibility of being slightly slower
			// but might be closer to the actual note you meant to hit
			var distance:Float = Math.abs(note.adjustedTime - clock.time);
			if (distance >= closestDistance) continue;

			closestDistance = distance;
			noteToHit = note;
		}

		if (noteToHit != null) {
			//receptor.glow(null, noteToHit);

			noteToHit.kill();
			if (noteToHit.sustain != null) {
				noteToHit.sustain.wasHit = true;
			}
		} else {
			receptor.isHolding = true;
			//receptor.glow('pressed');
		}

		return noteToHit;
	}

	var sustainInterval:Float = 0.12;
	function holdInputs(sustain:Sustain) {
		if (!sustain.wasHit) return;

		var strumline:Strumline = sustain.strumline;
		var receptor:Receptor = sustain.receptor;

		var held:Bool = held[sustain.lane];
		var playerHeld:Bool = (held || sustain.regrabTimer > 0);
		var heldKey:Bool = (!strumline.ai && playerHeld) || (strumline.ai && sustain.adjustedTime <= clock.time);

		final regrabLimit = Judgement.max.window / 1000;
		if (sustain.regrabTimer < regrabLimit && held) {
			//receptor.glow('standard');
		}

		sustain.regrabTimer = held ? regrabLimit : sustain.regrabTimer - FlxG.elapsed;
		sustain.regrabAlpha = strumline.ai ? 1 : 0.6 + 0.4 * (sustain.regrabTimer / regrabLimit);

		final curHolds = strumline.curHolds;
		if (!heldKey) {
			if (!strumline.ai) {
				curHolds.remove(sustain);
				sustain.regrabAlpha = 0.2;
				sustain.wasHit = false;
				sustainDropped(sustain.strumline, sustain);
			}

			return;
		}

		// only clip if it's past the sustain
		if (!scrollVelocities)
			sustain.timeOffset = -Math.min(sustain.adjustedTime - clock.time, 0);
		else if (clock.time >= sustain.adjustedTime)
			sustain.timeOffset = velocityClock.time - sustain.visualTime;
		
		sustain.forceHeightRecalc = true;
		receptor.isHolding = true;

		if (!curHolds.contains(sustain)) {
			// we want the most recent, but we also dont wanna prioritize super short sustains
			final idx = sustain.length >= 250 ? curHolds.length : 0;
			curHolds.insert(idx, sustain);
		} else if (sustain.adjustedTime + sustain.length <= clock.time) {
			curHolds.remove(sustain);
			sustain.kill();
			receptor.isHolding = held;
			if (strumline.ai) {
				//receptor.glow('standard');
				receptor.isHolding = false;
			}
			sustain.untilTick = 0; // Hit it one last time, to make sure
		}

		sustain.untilTick -= FlxG.elapsed;
		if (sustain.untilTick > 0) return;

		sustain.untilTick = sustainInterval;
/*		if (strumline.ai || held)
			receptor.glow(null, sustain);*/

		sustainHit(strumline, sustain, curHolds[curHolds.length - 1] == sustain);
	}

	override function draw():Void {
		if (modchart == null) {
			super.draw();
			return;
		}

		modchart.prepare();

		var oldDefaultCameras = null;
		@:privateAccess {
			oldDefaultCameras = FlxCamera._defaultCameras;
			if (cameras != null)
				FlxCamera._defaultCameras = cameras;
		}

		for (i => strumline in strumlines.members) {
			if (!strumline.visible) continue;

			for (strum in strumline.members) {
				if (!strum.visible) continue;
				strum.preDrawCrazy(modchart, i, strumline.direction);
			}
		}

		for (sustain in sustains.members) {
			if (!sustain.exists || !sustain.visible) continue;

			sustain.drawCrazy(modchart, sustain.strumline.direction);
		}

		for (i => strumline in strumlines.members) {
			if (!strumline.visible) continue;

			for (strum in strumline.members) {
				if (!strum.visible) continue;
				strum.drawCrazy(modchart, i, strumline.direction);
			}
		}

		for (note in notes.members) {
			if (!note.exists || !note.visible) continue;

			note.drawCrazy(modchart, note.strumline.direction);
		}

		modchart.drawQueues();
		@:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
	}
}