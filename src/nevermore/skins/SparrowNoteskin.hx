package nevermore.skins;

import nevermore.play.*;

class SparrowNoteskin extends Noteskin implements INoteskin {
	public function new() {
		super(SPARROW);
	}

	override function dummyData():SkinData {
		return {
			standard: {
				list: [for (dir in Util.directions) 'arrow${dir.toUpperCase()}'],
				framerate: 24
			},
			press: {
				list: [for (dir in Util.directions) '$dir press'],
				framerate: 24
			},
			glow: {
				list: [for (dir in Util.directions) '$dir confirm'],
				framerate: 48
			},

			note: {
				standard: {
					list: [for (col in Util.colors) '${col}0'],
					framerate: 24
				}
			},

			sustain: {
				piece: {
					list: [for (col in Util.colors) '${col} hold piece'],
					framerate: 24
				},

				tail: {
					list: [for (col in Util.colors) '${col} hold end'],
					framerate: 24
				}
			}
		}
	}

	public var scale:Float = 0.65;
	public var antialiasing:Bool = true;

	override function applyReceptor(receptor:Receptor) {
		receptor.frames = frames;
		receptor.antialiasing = antialiasing;

		var standardPrefix:String = data.standard.list[receptor.lane];
		var standardFramerate:Float = data.standard.framerate;

		var pressPrefix:String = data.press.list[receptor.lane];
		var pressFramerate:Float = data.press.framerate;

		var glowPrefix:String = data.glow.list[receptor.lane];
		var glowFramerate:Float = data.glow.framerate;

		receptor.animation.addByPrefix('standard', standardPrefix, standardFramerate);
		receptor.animation.addByPrefix('pressed', pressPrefix, pressFramerate, false);
		receptor.animation.addByPrefix('glow', glowPrefix, glowFramerate, false);
		receptor.glow('standard');

		receptor.scale.set(scale, scale);
		receptor.updateHitbox();
	}

	override function applyNote(note:Note, ?reloadFrames:Bool = false) {
		if (note.frames == null || reloadFrames) note.frames = frames;
		note.antialiasing = antialiasing;

		var frameData = data.note;

		note.animation.addByPrefix('standard', frameData.standard.list[note.lane], frameData.standard.framerate);
		note.animation.play('standard');

		note.scale.set(scale, scale);
		note.updateHitbox();
	}

	override function applySustain(sustain:Sustain, ?reloadFrames:Bool = false) {
		if (sustain.frames == null || reloadFrames) sustain.frames = frames;
		sustain.antialiasing = antialiasing;

		var frameData = data.sustain;

		sustain.animation.addByPrefix('piece', frameData.piece.list[sustain.lane], frameData.piece.framerate);
		sustain.animation.addByPrefix('tail', frameData.tail.list[sustain.lane], frameData.tail.framerate);

		sustain.scale.set(scale, scale);
		sustain.updateHitbox();
	}
}