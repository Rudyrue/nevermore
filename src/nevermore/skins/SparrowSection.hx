package nevermore.skins;

import nevermore.skins.Noteskin;
import nevermore.skins.NoteskinSection;

class SparrowSection extends NoteskinSection<String> {
	public function new(parent:Noteskin, data:Dynamic) {
		super("sparrow", parent, data.spritesheet, loadAnimsFromData(data.animations), data.scale, data.antialiasing);
	}

	public function apply(to:FlxSprite, lane:Int) {
		basicApply(to);

		for (anim in animations)
			to.animation.addByPrefix(anim.name, anim.prefixes[lane], anim.framerate, anim.looped);
		to.animation.play(animations[0].name, true);

		to.updateHitbox();
	}

	function loadFrames(path:String) {
		return Assets.sparrowAtlas(path);
	}
	function getBackupAnim():NoteskinAnim<String> {
		return {name: "", prefixes: [for (i in 0...Nevermore.keyCount) ""]};
	}
}