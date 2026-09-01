package nevermore.play;

import lime.app.Application;
import lime.ui.KeyCode;
import flixel.group.FlxSpriteGroup;
import flixel.FlxCamera;
import nevermore.core.chart.Chart;
import nevermore.core.timing.BaseClock;
import nevermore.core.timing.VelocityClock;
import nevermore.core.timing.TimingPoint;
import nevermore.play.NoteSpawner;
import nevermore.play.Sustain;
#if !NEVERMORE_NO_MODCHARTS
import nevermore.modchart.ModchartManager;
#end

// TODO:
// maybe separate inputs into its own class ???
// not really a priority since it's just to make
// playfield (this class) look smaller
class PlayField extends flixel.group.FlxGroup {
	public dynamic function noteMissed(strumline:Strumline, note:Note) {}
	public dynamic function noteHit(strumline:Strumline, note:Note) {}
	public dynamic function ghostTap(direction:Int) {}
	public dynamic function sustainHit(strumline:Strumline, sustain:Sustain, mostRecent:Bool) {}

	public var strumlines:FlxTypedSpriteGroup<Strumline>;
	public var player:Strumline;
	#if !NEVERMORE_NO_MODCHARTS
	public var modchart:ModchartManager;
	#end
	public var sustains:FlxTypedSpriteGroup<Sustain>;
	public var notes:FlxTypedSpriteGroup<Note>;
	public var spawner:NoteSpawner;

	// the note count corresponding to each strumline
	// for example `noteCount[playerID]`
	// or `noteCount[0]` is the strumline with an id of 0
	public var noteCount:Array<Int> = [];

	public var modifiers:GameplayModifiers;
	public var mirrorInputs:Array<Int> = []; // A list of strumlines to mirror input to

	var held:Array<Bool> = [for (i in 0...Nevermore.keyCount) false];
	var killDelay:Float = 300;

	public var playerID(default, set):Int;
	function set_playerID(value:Int):Int {
		value = Std.int(Math.min(value, strumlines.length - 1));

		for (i => line in strumlines.members) {
			line.ai = (value == i) ? false : true;
		}

		player = getStrumline(value);
		return playerID = value;
	}

	@:isVar public var botplay(get, set):Bool;
	function get_botplay():Bool {
		return player.ai;
	}
	function set_botplay(v:Bool):Bool {
		return player.ai = v;
	}

	public var scrollSpeed(default, set):Float;
	function set_scrollSpeed(v:Float):Float {
		for (line in strumlines.members) {
			line.speed = v;
		}

		for (sustain in sustains.members) {
			sustain.forceHeightRecalc = true;
			sustain.calcHeight(v / clock.rate);
		}

		return scrollSpeed = v;
	}

	public var scrollDirection(default, set):ScrollDirection;
	function set_scrollDirection(v:ScrollDirection):ScrollDirection {
		for (line in strumlines.members) {
			line.direction = v;
		}

		return scrollDirection = v;
	}

	public var clock(get, default):BaseClock;
	function get_clock():BaseClock {
		clock ??= Conductor.clock;
		return clock;
	}

	public var scrollVelocities:VelocityClock;

	public var unspawnedNotes(get, never):Array<NoteData>;
	function get_unspawnedNotes():Array<NoteData> return spawner?.list ?? [];

	public function getStrumline(id:Int):Strumline {
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

	public function new(?lines:Array<Strumline>, ?playerID:Int) {
		super();

		add(sustains = new FlxTypedSpriteGroup<Sustain>());
		add(strumlines = new FlxTypedSpriteGroup<Strumline>());
		add(notes = new FlxTypedSpriteGroup<Note>());
		spawner = new NoteSpawner();

		for (line in lines ?? []) strumlines.add(line);
		this.playerID = playerID ?? 0;
		scrollSpeed = 1;
		scrollDirection = UP;

		Application.current.window.onKeyDown.add(keyPressed);
		Application.current.window.onKeyUp.add(keyReleased);
	}

	override function update(delta:Float):Void {
		// no need to update if there isn't even any players
		if (strumlines.length <= 0) return;

		if (modifiers.scrollVelocities) {
			scrollVelocities.updateSVs(clock);
		}

		#if !NEVERMORE_NO_MODCHARTS
		if (modchart != null) modchart.update();
		#end

		strumlines.update(delta);
		spawner.update(clock);
		
		for (i in 0...notes.length) {
			var note:Note = notes.members[i];
			if (!note.exists) continue;

			note.move(modifiers.scrollVelocities ? scrollVelocities : clock);
			if (note.strumline.ai) aiInputs(note);
			else if (!note.missed && note.tooLate) {
				note.missed = true; 
				noteMissed(note.strumline, note);
			}

			if (note.adjustedTime < clock.time - killDelay) {
				note.kill();
			}
		}

		for (i in 0...sustains.length) {
			var sustain:Sustain = sustains.members[i];
			if (!sustain.exists) continue;

			sustainInputs(sustain);
			sustain.move(modifiers.scrollVelocities ? scrollVelocities : clock);
			sustain.calcHeight(sustain.strumline.speed / clock.rate);

			if (sustain.adjustedTime + sustain.length < clock.time - killDelay) {
				sustain.kill();
			}
		}
	}

	override function destroy():Void {
		super.destroy();
		spawner.destroy();
		spawner = null;

		Application.current.window.onKeyDown.remove(keyPressed);
		Application.current.window.onKeyUp.remove(keyReleased);
	}

	public function load(chart:Chart #if !NEVERMORE_NO_PLAY_MODIFIERS , ?modifiers:GameplayModifiers #end) {
		#if !NEVERMORE_NO_PLAY_MODIFIERS
		modifiers ??= {};
		this.modifiers = modifiers;
		#else
		this.modifiers = {};
		#end

		if (chart.scrollVelocities.length == 0) {
			modifiers.scrollVelocities = false;
		}

		if (modifiers.scrollVelocities) {
			scrollVelocities = new VelocityClock(chart.scrollVelocities);
		}
		noteCount.resize(strumlines.length);

		clock.reset(chart.timingPoints, chart.offset);

		applyModifiers(chart, modifiers);

		var list:Array<NoteData> = [];
		for (i => note in chart.notes) {
			noteCount[note.player]++;
			note.beat = clock.timingMap.getBeat(note.time);

			if (i != 0) {
				clearStackedNotes(list, note);
			}

			list.push(note);
		}
		
		spawner.load(list);
		spawner.triggered = noteSpawned;
	}

	function applyModifiers(chart:Chart, modifiers:GameplayModifiers) {
		var lanes:Array<Int> = modifiers.mirroredNotes ? [3, 2, 1, 0] : [0, 1, 2, 3];
		if (modifiers.randomizedNotes) FlxG.random.shuffle(lanes);

		for (note in chart.notes) {
			note.lane = lanes[note.lane];
			if (!modifiers.sustains) note.length = 0;
			if (!modifiers.scrollVelocities) continue;

			note.visualTime = scrollVelocities.map.getPosition(note.time);
			if (note.length > 0) {
				var endTime = note.time + note.length;
				note.visualEnd = scrollVelocities.map.getPosition(endTime);
			}
		}
	}

	// TODO:
	// find a better way to do this ????
	// this feels clunky/hacky
	function clearStackedNotes(list:Array<NoteData>, note:NoteData) {
		for (evilNote in list) {
			var matches:Bool = note.lane == evilNote.lane && note.player == evilNote.player;
			if (!matches || Math.abs(note.time - evilNote.time) > 2.0) continue;

			list.remove(evilNote);
			evilNote.length = 0;
		}
	}

	function aiInputs(note:Note) {
		if (note.adjustedTime > clock.time) return;

		note.kill();
		if (note.sustain != null)
			note.sustain.wasHit = true;

		note.receptor.glow(null, note);
		note.receptor.isHolding = note.sustain != null;
		noteHit(note.strumline, note);
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
		for (i in 0...notes.length) {
			var note:Note = notes.members[i];
			if (!note.exists) continue;

			if (note.player != id || note.lane != direction || !note.hittable) continue;

			var distance:Float = Math.abs(note.adjustedTime - clock.time);
			if (distance >= closestDistance) continue;

			closestDistance = distance;
			noteToHit = note;
		}

		if (noteToHit != null) {
			noteHit(strumline, noteToHit);
			receptor.glow(null, noteToHit);

			noteToHit.kill();
			if (noteToHit.sustain != null) {
				noteToHit.sustain.wasHit = true;
			}
		} else {
			receptor.isHolding = true;
			receptor.glow('pressed');
		}

		return noteToHit;
	}

	var sustainInterval:Float = 0.12;
	function sustainInputs(sustain:Sustain) {
		if (!sustain.wasHit) return;

		var strumline:Strumline = sustain.strumline;
		var receptor:Receptor = sustain.receptor;

		var held:Bool = held[sustain.lane];
		var playerHeld:Bool = (held || sustain.regrabTimer > 0);
		var heldKey:Bool = (!strumline.ai && playerHeld) || (strumline.ai && sustain.adjustedTime <= clock.time);

		final coyoteLim = Judgement.max.window / 1000;
		if (sustain.regrabTimer < coyoteLim && held) {
			receptor.glow('standard');
		}

		sustain.regrabTimer = held ? coyoteLim : sustain.regrabTimer - FlxG.elapsed;
		sustain.regrabAlpha = strumline.ai ? 1 : 0.6 + 0.4 * (sustain.regrabTimer / coyoteLim);

		final curHolds = strumline.curHolds;
		if (!heldKey) {
			if (!strumline.ai) {
				curHolds.remove(sustain);
				sustain.regrabAlpha = 0.2;
				sustain.wasHit = false;
				noteMissed(sustain.strumline, sustain);
			}

			return;
		}

		// only clip if it's past the sustain
		if (!modifiers.scrollVelocities)
			sustain.timeOffset = -Math.min(sustain.adjustedTime - clock.time, 0);
		else if (clock.time >= sustain.adjustedTime)
			sustain.timeOffset = scrollVelocities.time - sustain.visualTime;
		
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
				receptor.glow('standard');
				receptor.isHolding = false;
			}
			sustain.untilTick = 0; // Hit it one last time, to make sure
		}

		sustain.untilTick -= FlxG.elapsed;
		if (sustain.untilTick > 0) return;

		sustain.untilTick = sustainInterval;
		if (strumline.ai || held)
			receptor.glow(null, sustain);

		sustainHit(strumline, sustain, curHolds[curHolds.length - 1] == sustain);
	}

	inline function keyPressed(key:KeyCode, _) {
		if (strumlines.length <= 0 || Nevermore.paused) return;
		if (player.ai) return;

		var direction:Int = Controls.keyID(key);
		if (direction == -1 || held[direction]) return;
		held[direction] = true;

		if (inputs(direction) != null) ghostTap(direction);

		for (strumline in mirrorInputs) {
			inputs(direction, strumline);
		}
	}

	inline function keyReleased(key:KeyCode, _) {
		if (strumlines.length <= 0) return;
		if (player.ai) return;

		var direction:Int = Controls.keyID(key);
		if (direction == -1) return;
		held[direction] = false;

		function releaseReceptor(direction:Int, ?strumline:Int) {
			strumline ??= playerID;

			var receptor = getStrumline(strumline).members[direction];
			receptor.isHolding = false;
			receptor.glow('standard');
		}

		releaseReceptor(direction);
		for (strumline in mirrorInputs) {
			releaseReceptor(direction, strumline);
		}
	}

	function noteSpawned(data:NoteData) {
		if (data.player >= strumlines.length) return;

		var note = addNote(data, notes, Note);
		if (data.length > 0) {
			note.sustain = addNote(data, sustains, Sustain);
			note.sustain.calcHeight(getStrumline(data.player).speed / clock.rate);
		}
	}

	#if !NEVERMORE_NO_MODCHARTS
	override function draw() {
		if (modchart == null) {
			super.draw();
			return;
		}

		modchart.parent = this;
		modchart.prepare();

		var oldDefaultCameras = null;
		@:privateAccess {
			oldDefaultCameras = FlxCamera._defaultCameras;
			if (cameras != null)
				FlxCamera._defaultCameras = cameras;
		}

		for (i => strumline in strumlines.members) {
			if (!strumline.visible) continue;

			for (receptor in strumline.members) {
				if (!receptor.visible) continue;
				receptor.preDrawCrazy(modchart, i, scrollDirection, strumline);
			}
		}

		for (sustain in sustains.members) {
			if (!sustain.exists || !sustain.visible) continue;
			sustain.drawCrazy(modchart, scrollDirection, sustain.strumline);
		}

		for (i => strumline in strumlines.members) {
			if (!strumline.visible) continue;

			for (receptor in strumline.members) {
				if (!receptor.visible) continue;
				receptor.drawCrazy(modchart, i, scrollDirection, strumline);
			}
		}

		for (note in notes.members) {
			if (!note.exists || !note.visible) continue;
			note.drawCrazy(modchart, scrollDirection, note.strumline);
		}

		modchart.drawQueues();

		@:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
	}
	#end
}