package nevermore.skins;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

class NoteskinCache {
	var list:Map<String, FlxAtlasFrames> = [];
	public function new() {}

	public function exists(key:String):Bool {
		return list.exists(key);
	}

	public function clear() {
		list.clear();
	}

	public function set(key:String, ?quants:Bool = false) {
		if (exists(key)) return;

		var data = getData(key, quants);
		if (data.frames == null) return;

		list.set(key, data.frames);
	}

	public function create(key:String, quants:Bool):{type:NoteskinType, frames:FlxAtlasFrames} {
		return getData(key, quants);
	}

	// this is what you wanna override if you have your own asset system
	// (for example like fnf's)
	public function getData(key:String, quants:Bool):{type:NoteskinType, frames:FlxAtlasFrames} {
		#if !NEVERMORE_NO_QUANTIZATION
		if (quants) key += '-quant';
		#end

		var sparrow:FlxAtlasFrames = Assets.sparrowAtlas(key);
		if (sparrow != null) {
			return {
				type: SPARROW,
				frames: sparrow
			};
		}

		return {
			type: CUSTOM,
			frames: null
		};
	}
}