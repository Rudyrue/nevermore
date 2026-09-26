package nevermore.skins;

import nevermore.play.note.BaseNote;
import flixel.graphics.frames.FlxFramesCollection;

@:structInit
@:publicFields
class NoteskinAnim<T> {
	var name:String;
	var prefixes:Array<T>;
	var framerate:Float = 24;
	var looped:Bool = false;
}
typedef NoteskinAnimStruct<T> = {
	var ?name:String;
	var ?prefixes:Array<T>;
	var ?framerate:Float;
	var ?looped:Bool;
}

abstract class NoteskinSection<T> {
	static var _list:Map<String, Class<NoteskinSection<Any>>> = [];

	public static function register(name:String, cls:Class<NoteskinSection<Any>>) {
		_list.set(name, cls);
	}

	public static function create(parent:Noteskin, data:Dynamic) {
		var style:String = data.style ?? "sparrow";
		style = style.toLowerCase();
		
		var cls:Class<NoteskinSection<Any>> = SparrowSection;
		if (_list.exists(style))
			cls = _list.get(style);

		return Type.createInstance(cls, [parent, data]);
	}

	/**
	 * To be given in `NoteskinSection.new` (and preferably only there), a reference to the Noteskin instance holding this section.
	 */
	private var parent:Noteskin = null;
	/**
	 * To be loaded in `NoteskinSection.new`, a reference to the frames used for this section.
	 */
	private var frames:FlxFramesCollection = null;

	/**
	 * Since NoteskinSection is abstract, this variable determines which extension to use.
	 *
	 * Typically "sparrow", but allows potential for other animation styles such as "grid".
	 */
	var style:String = "sparrow";
	var spritesheet:String;
	var animations:Array<NoteskinAnim<T>>;
	var scale:Float = 0.7;
	var antialiasing:Bool = true;

	abstract public function apply(to:FlxSprite, lane:Int):Void;

	abstract function loadFrames(path:String):FlxFramesCollection;
	abstract function getBackupAnim():NoteskinAnim<T>;

	function basicApply(to:FlxSprite) {
		if (to.frames != frames)
			to.frames = frames;
		to.antialiasing = antialiasing;
		to.scale.set(scale, scale);
	}

	function loadAnimsFromData(data:Array<Dynamic>):Array<NoteskinAnim<T>> {
		var result:Array<NoteskinAnim<T>> = [];

		for (a in data) {
			var anim:NoteskinAnimStruct<T> = a;
			if (anim.name == null || anim.prefixes == null)
				continue;

			result.push({
				name: anim.name,
				prefixes: anim.prefixes,
				framerate: anim.framerate ?? 24,
				looped: anim.looped ?? false
			});
		}

		if (result.length == 0)
			result.push(getBackupAnim());
		return result;
	}

	public function new(style:String, parent:Noteskin, spritesheet:String, animations:Array<NoteskinAnim<T>>, ?scale:Float = 0.7, ?antialiasing:Bool = true) {
		this.style = spritesheet;
		this.spritesheet = spritesheet;
		this.animations = animations;
		this.scale = scale;
		this.antialiasing = antialiasing;

		this.frames = parent.getFrames(spritesheet, loadFrames);
	}
}