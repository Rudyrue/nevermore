package nevermore.skins;

import nevermore.play.note.BaseNote;
import flixel.graphics.frames.FlxFramesCollection;

class Noteskin {
	public static var cache:NoteskinCache = new NoteskinCache();

	public static function load(key:String) {
		cache.set(key);
	}

	public static function get(key:String, ?quants:Bool = false):Noteskin {
		quants = Nevermore.settings.quantization && quants;
		return cache.get(key, quants);
	}

	public static function clear() {
		cache.clear();
	}

	public static function basic(key:String) {
		return new Noteskin({
			receptor: {
				style: "sparrow", // this one actually isnt necessary but....
				spritesheet: key,
				animations: [
					{
						name: "standard",
						prefixes: [for (dir in Util.directions) 'arrow${dir.toUpperCase()}'],
						looped: true
					},
					{
						name: "pressed",
						prefixes: [for (dir in Util.directions) '$dir press']
					},
					{
						name: "glow",
						prefixes: [for (dir in Util.directions) '$dir confirm']
					},
				]
			},

			note: {
				style: "sparrow",
				spritesheet: key,
				animations: [{
					name: "standard",
					prefixes: [for (col in Util.colors) '${col}0'],
					looped: true
				}]
			},

			sustain: {
				style: "sparrow",
				spritesheet: key,
				animations: [
					{
						name: "piece",
						prefixes: [for (col in Util.colors) '${col} hold piece'],
						looped: true
					},
					{
						name: "tail",
						prefixes: [for (col in Util.colors) '${col} hold end'],
						looped: true
					}
				]
			}/*,

			roll: {
				style: "sparrow",
				spritesheet: key,
				animations: [
					{
						name: "piece",
						prefixes: [for (col in Util.colors) '${col} roll piece'],
						looped: true
					},
					{
						name: "tail",
						prefixes: [for (col in Util.colors) '${col} roll end'],
						looped: true
					}
				]
			}*/
		});
	}



	/**
	 * Used for sharing frame collections across secitons.
	 */
	private var frames:Map<String, FlxFramesCollection> = [];
	public var sections:Map<String, NoteskinSection<Dynamic>> = [];

	public var spacing:Float = 160 * 0.7;

	public function new(data:Dynamic) {
		var instanceFields = Type.getInstanceFields(Noteskin);
		var fields = Reflect.fields(data);

		for (field in fields) {
			var obj = Reflect.field(data, field);
			if (Reflect.isObject(obj))
				sections.set(field, NoteskinSection.create(this, obj));
			else if (instanceFields.contains(field))
				Reflect.setProperty(this, field, obj);
		}
	}

	public function apply(to:FlxSprite, lane:Int, section:String) {
		sections.get(section).apply(to, lane);
	}
	public function applyToNote(to:BaseNote, section:String) {
		inline apply(to, to.lane, section);
	}

	public function getFrames(path:String, fallback:String->FlxFramesCollection) {
		if (frames.exists(path))
			return frames.get(path);

		var newFrames = fallback(path);
		frames.set(path, newFrames);
		return newFrames;
	}
}