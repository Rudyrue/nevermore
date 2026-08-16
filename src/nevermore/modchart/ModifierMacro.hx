package nevermore.modchart;

using StringTools;

#if (macro && !NEVERMORE_NO_MODCHARTS)
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import haxe.macro.TypeTools;
import haxe.macro.ExprTools;

abstract ModifierValue(Float) from Float to Float {}

final class ModifierMacro {
	public static macro function createModifier():Array<Field> {
		var fields = Context.getBuildFields();
		var pos = Context.currentPos();

		var initField:Field = null;
		var modifiers:Array<Field> = [];
		var nonLanes:Int = 0;
		for (field in fields) {
			if (field.name == "__init__")
				initField = field;

			switch (field.kind) {
				case FVar(TPath(p), _):
					if (p.name != "ModifierValue")
						continue;

					if (field.name.contains("LANE"))
						modifiers.push(field);
					else
						modifiers.insert(nonLanes++, field);
				default: // nothin
			}
		}
		if (modifiers.length <= 0)
			return fields;

		var defaults:Array<Float> = [];
		var laneDefaults:Array<Float> = [];
		var laneNames:Array<String> = [];
		var allAliases:Array<Array<String>> = [];
		for (i => mod in modifiers) {
			var aliases:Array<String> = [];
			// var optMeta:MetadataEntry = null;
			if (mod.meta != null) {
				for (met in mod.meta) {
					/*if (met.name == ":optional")
						optMeta = met; */

					if (met.name != ":alias") continue;
					for (param in met.params) {
						switch (param.expr) {
							case EConst(CIdent(s) | CString(s)):
								aliases.push(s);
							default: // nothin
						}
					}
				}
			}
			allAliases.push(aliases);

			switch (mod.kind) {
				case FVar(_, {expr: EConst(CInt(f, s) | CFloat(f, s))}): // ACK
					defaults.push(Std.parseFloat(f));
				default:
					defaults.push(0);
			}
			if (i >= nonLanes) {
				laneDefaults.push(defaults[defaults.length - 1]);
				laneNames.push(mod.name.substring(0, mod.name.indexOf("LANE")).toLowerCase() + "LANE" + mod.name.substr(mod.name.indexOf("LANE") + 4).toLowerCase());
			}

			mod.kind = FProp("get", "never", (macro:Float));
			fields.push({
				name: "get_" + mod.name,
				access: [AInline, AExtern],
				kind: FFun({
					args: [],
					ret: (macro:Float),
					expr: macro return getValue($v{i}, parent.curField)
				}),
				pos: pos
			});
		}

		final name = Context.getLocalClass().get().name;
		var redirects:Array<Expr> = [];
		for (i => mod in modifiers) {
			final modName = i >= nonLanes ? laneNames[i - nonLanes] : mod.name.toLowerCase();
			redirects.push(macro ModchartManager.defaultRedirects.set($v{modName}, {toClass: $i{name}, index: $v{i}, lane: $v{i >= nonLanes ? 0 : -1}}));
			for (ali in allAliases[i]) {
				final aliName = i >= nonLanes ? ali.substring(0, ali.indexOf("LANE")).toLowerCase() + "LANE" + ali.substr(ali.indexOf("LANE") + 4).toLowerCase() : ali.toLowerCase();
				redirects.push(macro ModchartManager.defaultRedirects.set($v{aliName}, {toClass: $i{name}, index: $v{i}, lane: $v{i >= nonLanes ? 0 : -1}}));	
			}
		}
		fields.push({
			name: "attachToRedirects",
			access: [AStatic],
			kind: FFun({
				args: [],
				expr: macro $b{redirects}
			}),
			pos: pos
		});
		if (defaults.length > nonLanes) {
			fields.push({
				name: "getValue",
				access: [APublic, AOverride],
				kind: FFun({
					args: [{
						name: "index",
						type: (macro:Int)
					}, {
						name: "strumline",
						type: (macro:Int)
					}],
					ret: (macro:Float),
					expr: macro {
						if (index >= $v{nonLanes})
							index = $v{nonLanes} + (index - $v{nonLanes}) * parent.laneCount + parent.curLane;
						return (strumline < values.length) ? values[strumline][index] : 0;
					}
				}),
				pos: pos
			});
			fields.push({
				name: "setValue",
				access: [APublic, AOverride],
				kind: FFun({
					args: [{
						name: "index",
						type: (macro:Int)
					}, {
						name: "value",
						type: (macro:Float)
					}, {
						name: "strumline",
						type: (macro:Int)
					}],
					expr: macro {
						if (index >= $v{nonLanes})
							index = $v{nonLanes} + (index - $v{nonLanes}) * parent.laneCount + parent.curLane;

						if (strumline < 0) {
							for (i in 0...values.length) {
								values[i][index] = value;
								active[i] = isActive(values[i]);
							}
						} else if (strumline < values.length) {
							values[strumline][index] = value;
							active[strumline] = isActive(values[strumline]);
						}
					}
				}),
				pos: pos
			});

			fields.push({
				name: "addLane",
				access: [APublic, AOverride],
				kind: FFun({
					args: [],
					expr: macro {
						var curCount = Std.int((defVals.length - $v{nonLanes}) / $v{defaults.length - nonLanes});
						var curLen = defVals.length;
						var i = defVals.length;
						var laneI = $v{defaults.length - nonLanes - 1};
						while (defVals.length < curLen + defLaneVals.length) {
							defVals.insert(i, defLaneVals[laneI]);
							for (val in values)
								val.insert(i, defLaneVals[laneI]);
							for (val in cacheValues)
								val.insert(i, defLaneVals[laneI]);
							
							for (name in laneNames[laneI])
								parent.redirects.set(name.replace("LANE", Std.string(curCount)), {toInstance: this, index: $v{nonLanes} + laneI, lane: curCount});

							--laneI;
							i -= curCount;
						}
					}
				}),
				pos: pos
			});
		}

		final nonLaneVals = defaults.copy();
		nonLaneVals.splice(nonLanes, defaults.length - nonLanes);
		fields.push({
			name: "laneNames",
			access: [APrivate],
			kind: FVar(macro:Array<Array<String>>, macro $v{[for (i => name in laneNames) [name].concat(allAliases[nonLanes + i])]}),
			pos: pos
		});
		fields.push({
			name: "defVals",
			access: [APrivate],
			kind: FVar(macro:Array<Float>, macro $v{nonLaneVals}),
			pos: pos
		});
		fields.push({
			name: "defLaneVals",
			access: [APrivate],
			kind: FVar(macro:Array<Float>, macro $v{laneDefaults}),
			pos: pos
		});

		final addSetExpr = macro {
			values.push(defVals.copy());
			active.push(false);
		};
		fields.push({
			name: "addStrumlineSet",
			access: [APublic, AOverride],
			kind: FFun({
				args: [],
				expr: macro {
					values.push(defVals.copy());
					active.push(false);
				}
			}),
			pos: pos
		});
		fields.push({
			name: "isActive",
			access: [APrivate, AOverride],
			kind: FFun({
				args: [{
					name: "vals",
					type: (macro:Array<Float>)
				}],
				ret: (macro:Bool),
				expr: macro {
					for (i in 0...vals.length) {
						if (vals[i] != defVals[i])
							return true;
					}
					return false;
				}
			}),
			pos: pos
		});

		final initExtension = macro {
			ModchartManager.modifiersToAttach ??= [];
			ModchartManager.modifiersToAttach.push($i{name});
		};
		if (initField == null) {
			fields.push({
				name: "__init__",
				access: [AStatic],
				kind: FFun({
					args: [],
					expr: initExtension
				}),
				pos: pos
			});
		} // TODO: extend __init__ if it already exists

		return fields;
	}
}
#else
abstract ModifierValue(Float) from Float to Float {}
#end