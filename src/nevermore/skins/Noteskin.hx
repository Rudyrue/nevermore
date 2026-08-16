package nevermore.skins;

import flixel.graphics.frames.FlxAtlasFrames;
import nevermore.play.Receptor;
import nevermore.play.Note;
import nevermore.play.Sustain;

// TODO:
// this entire fucking system probably lmfao
// it feels super over-complicated at times
// and it doesn't really allow for extending
// for custom skin types like scripts/grids
class Noteskin {
	public static function load(key:String) {
		cache.set(key);
	}

	public static function get(key:String, ?quants:Bool = false):Noteskin {
		if (!Nevermore.settings.quantization) quants = false;

		var data = cache.create(key, quants);
		var skin:Noteskin = switch data.type {
			case SPARROW: new SparrowNoteskin();
			default: new Noteskin();
		}

		skin.frames = data.frames;
		return skin;
	}

	public static function clear() {
		cache.clear();
	}

	public static var cache:NoteskinCache = new NoteskinCache();

	public var frames:FlxAtlasFrames;
	public var data:SkinData = null;
	public var type:NoteskinType;

	public function new(?type:NoteskinType) {
		this.type = type;
		data = dummyData();
	}

	public function dummyData():SkinData {
		return {
			standard: {list: [], framerate: 24},
			press: {list: [], framerate: 24},
			glow: {list: [], framerate: 24},

			note: {
				standard: {list: [], framerate: 24}
			},

			sustain: {
				piece: {list: [], framerate: 24},
				tail: {list: [], framerate: 24}
			}
		}
	}

	public function applyReceptor(receptor:Receptor) {}
	public function applyNote(note:Note, ?reloadFrames:Bool = false) {}
	public function applySustain(sustain:Sustain, ?reloadFrames:Bool = false) {}
}