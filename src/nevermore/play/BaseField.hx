package nevermore.play;

import flixel.group.FlxSpriteGroup;
import nevermore.core.timing.BaseClock;
import nevermore.core.timing.VelocityClock;
import nevermore.core.timing.TimingMap;
import nevermore.modchart.ModchartManager;
import nevermore.core.chart.Chart;

// a base class for any fields for you to build off of
// gives you mostly everything you'd need to make your own notefield
class BaseField extends FlxSpriteGroup {
	public var clock(get, default):BaseClock;
	function get_clock():BaseClock {
		clock ??= Conductor.clock;
		return clock;
	}

	public var playerID:Int = 0;

	public var scrollSpeed(default, set):Float;
	function set_scrollSpeed(v:Float):Float {
		return scrollSpeed = v;
	}

	public var scrollDirection(default, set):ScrollDirection;
	function set_scrollDirection(v:ScrollDirection):ScrollDirection {
		return scrollDirection = v;
	}

	public var autoplay:Bool = false;
	public var scrollVelocities:Bool = true;

	public var spawner:NoteSpawner;
	public var velocityClock:VelocityClock;
	public var modchart:ModchartManager;

	public var director:InputDirector;

	public function getStrumline(id:Int):Strumline {
		return null;
	}

	public var unspawnedNotes(get, never):Array<NoteData>;
	function get_unspawnedNotes():Array<NoteData> return spawner.list;

	public function new() {
		super();

		director = new InputDirector();
		spawner = new NoteSpawner();
		velocityClock = new VelocityClock();

		director.onPress.add(pressed);
		director.onRelease.add(released);

		scrollSpeed = 1.0;
		scrollDirection = UP;
	}

	override function update(delta:Float) {
		super.update(delta);

		if (scrollVelocities) velocityClock.updateSVs(clock);
		if (modchart != null) modchart.update();

		spawner.update(clock);
	}

	override function destroy():Void {
		super.destroy();

		director.destroy();
		spawner.destroy();
		velocityClock.destroy();

		spawner = null;
		director = null;
		velocityClock = null;
	}

	public function load(chart:Chart, ?modifiers:GameplayModifiers) {
		modifiers ??= {};
		if (chart.scrollVelocities.length <= 1) {
			scrollVelocities = false;
		}

		var map:TimingMap = clock.timingMap;
		clock.offset = chart.offset;

		var list:Array<NoteData> = [];
		for (i => note in chart.notes) {
			//noteCount[note.player]++;
			note.beat = map.getBeat(note.time);
			note.quant = Quantization.getID(note.time, map, chart.quantsRelativeToChanges);

			if (i != 0) {
				clearStackedNotes(list, note);
			}

			list.push(note);
		}
		
		spawner.load(list);
		spawner.triggered = noteSpawned;
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

	function noteSpawned(data:NoteData) {}

	function pressed(direction:Int) {}
	function released(direction:Int) {}
}