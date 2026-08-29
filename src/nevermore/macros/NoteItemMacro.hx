package nevermore.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class NoteItemMacro {
	public static macro function attachNoteType():Array<Field> {
		var fields = Context.getBuildFields();

		fields.push({
			name: "NOTE",
			kind: FVar(null),
			pos: Context.currentPos()
		});

		return fields;
	}
	public static macro function attachNoteItem():Array<Field> {
		var fields = Context.getBuildFields();
		var pos = Context.currentPos();

		for (field in fields) {
			if (field.name != "clearDrawStack") continue;

			switch (field.kind) {
				case FFun({expr: {expr: EBlock(exprs)}}):
					exprs.push(macro {
						var currNote:flixel.graphics.tile.FlxDrawNoteItem = _headNote;
						var newNoteHead:flixel.graphics.tile.FlxDrawNoteItem;
				
						while (currNote != null) {
							newNoteHead = currNote.nextTyped;
							currNote.reset();
							currNote.nextTyped = _storageNoteHead;
							_storageNoteHead = currNote;
							currNote = newNoteHead;
						}
						_headNote = null;
					});
				default: //nothin
			}
			break;
		}

		fields.push({
			name: "_headNote",
			kind: FVar(macro:flixel.graphics.tile.FlxDrawNoteItem),
			pos: pos
		});
		fields.push({
			name: "_storageNoteHead",
			access: [AStatic],
			kind: FVar(macro:flixel.graphics.tile.FlxDrawNoteItem),
			pos: pos
		});

		fields.push({
			name: "startNoteBatch",
			access: [APublic],
			meta: [{name: ":noCompletion", pos: pos}],
			pos: pos,
			kind: FFun({
				args: [
					{name: "graphic", type: macro:FlxGraphic},
					{name: "blend", opt: true, type: macro:BlendMode},
					{name: "smooth", opt: true, type: macro:Bool, value: macro false},
					{name: "customColoring", opt: true, type: macro:Bool, value: macro false}
				],
				ret: macro:flixel.graphics.tile.FlxDrawNoteItem,
				expr: macro {
					// `blending` is said to be depricated, and i believe it's not used for a good while even before deprication.
					if (_currentDrawItem != null
						&& _currentDrawItem.type == NOTE
						&& _headNote.graphics == graphic
						&& _headNote.colored == customColoring
						&& _headNote.blend == blend
						&& _headNote.antialiasing == smooth
					)
						return _headNote;
			
					var item = _storageNoteHead;
					if (item != null) {
						_storageNoteHead = item.nextTyped;
						item.reset();
					} else
						item = new flixel.graphics.tile.FlxDrawNoteItem();
			
					item.graphics = graphic;
					item.antialiasing = smooth;
					item.colored = customColoring;
					item.blend = blend;
			
					item.nextTyped = _headNote;
					_headNote = item;
			
					if (_headOfDrawStack == null)
						_headOfDrawStack = item;
					if (_currentDrawItem != null)
						_currentDrawItem.next = item;

					_currentDrawItem = item;
			
					return item;
				}
			})
		});

		fields.push({
			name: "drawNote",
			access: [APublic],
			pos: pos,
			kind: FFun({
				args: [
					{name: "frame", type: macro:FlxFrame},
					{name: "matrix", type: macro:FlxMatrix},
					{name: "transform", opt: true, type: macro:ColorTransform},
					{name: "blend", opt: true, type: macro:BlendMode},
					{name: "smoothing", opt: true, type: macro:Bool, value: macro false},
					{name: "customColoring", opt: true, type: macro:Bool, value: macro false}
				],
				expr: macro {
					if (FlxG.renderBlit) // don't feel like adding support for this
						return;
			
					var drawItem = startNoteBatch(frame.parent, blend, smoothing, customColoring);
					drawItem.addQuad(frame, matrix, transform);
				}
			})
		});
		fields.push({
			name: "drawNoteVertices",
			access: [APublic],
			pos: pos,
			kind: FFun({
				args: [
					{name: "frame", type: macro:FlxFrame},
					{name: "vertices", type: macro:Array<Float>},
					{name: "transform", opt: true, type: macro:ColorTransform},
					{name: "blend", opt: true, type: macro:BlendMode},
					{name: "smoothing", opt: true, type: macro:Bool, value: macro false},
					{name: "customColoring", opt: true, type: macro:Bool, value: macro false},
					{name: "stealth", opt: true, type: macro:Float},
					{name: "alpha", opt: true, type: macro:Float},
					{name: "stealthCol", opt: true, type: macro:nevermore.backend.Vector3},
				],
				expr: macro {
					if (FlxG.renderBlit) // don't feel like adding support for this
						return;
			
					var drawItem = startNoteBatch(frame.parent, blend, smoothing, customColoring);
					drawItem.addVertices(frame, vertices, transform, stealth, alpha, stealthCol);
				}
			})
		});

		return fields;
	}
}
#end