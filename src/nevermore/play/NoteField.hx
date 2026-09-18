package nevermore.play;

import flixel.group.FlxSpriteGroup;
import nevermore.play.note.*;

class NoteField extends BaseField {
	public var strumlines:FlxTypedSpriteGroup<Strumline>;
	public var notes:FlxTypedSpriteGroup<Note>;

	override function set_scrollSpeed(v:Float):Float {
		for (line in strumlines.members) {
			line.speed = v;
		}

		return scrollSpeed = v;
	}

	override function set_scrollDirection(v:ScrollDirection):ScrollDirection {
		for (line in strumlines.members) {
			line.direction = v;
		}

		return scrollDirection = v;
	}

	public function new(?lines:Array<Strumline>, ?playerID:Int = 0) {
		strumlines = new FlxTypedSpriteGroup<Strumline>();
		notes = new FlxTypedSpriteGroup<Note>();

		for (line in lines ?? []) {
			strumlines.add(line);
		}

		super();

		this.playerID = playerID;

		add(strumlines);
		add(notes);
		notes.active = false;
	}

	var killDelay:Float = 300;
	override function update(delta:Float) {
		super.update(delta);

		for (i in 0 ... notes.length) {
			var note:Note = notes.members[i];
			if (!note.exists) continue;

			note.update(delta);
			note.move(scrollVelocities ? velocityClock : clock);

			if (note.adjustedTime < clock.time - killDelay) {
				note.kill();
			}
		}
	}

	override function getStrumline(id:Int):Strumline {
		id = FlxMath.minInt(id, strumlines.length - 1);
		return strumlines.members[id];
	}

	function addNote<T:Note>(data:NoteData, group:FlxTypedSpriteGroup<T>, cls:Class<T>):T {
		var strumline:Strumline = getStrumline(data.player);

		var note:T = group.recycle(cls);
		group.remove(note, true); // keep ordering
		group.add(cast note.setup(strumline, data));

		return note;
	}

	override function noteSpawned(data:NoteData) {
		if (data.player >= strumlines.length) return;

		var note = addNote(data, notes, Note);
/*		if (data.length > 0) {
			var sustain = addNote(data, sustains, Sustain);
			sustain.calcHeight(sustain.strumline.speed / clock.rate);

			note.sustain = sustain;
		}*/
	}

	override function pressed(direction:Int) {
		if (Nevermore.paused) return;

		inputs(direction, playerID);
	}

	// you don't have to do inputs like this
	// a simple sort and then list[0] should do the job 
	// but for something this caliber it needs to handle it a bit more accurately
	function inputs(direction:Int, ?id:Int):Note {
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
			var behavior:NoteBehavior = note.behavior;
			if (!behavior.hittable || !behavior.inRange) continue;

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
			//noteHit(strumline, noteToHit);
			//receptor.glow(null, noteToHit);

			noteToHit.kill();
		} else {
			receptor.isHolding = true;
			//receptor.glow('pressed');
		}

		return noteToHit;
	}
}