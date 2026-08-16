package nevermore.play;

@:structInit
@:publicFields
class GameplayModifiers {
	#if !NEVERMORE_NO_MODIFIERS

	var sustains:Bool = true;
	var randomizedNotes:Bool = false;
	var mirroredNotes:Bool = false;

	#else

	var sustains:Bool = true;
	var randomizedNotes:Bool = false;
	var mirroredNotes:Bool = false;
	
	#end
}