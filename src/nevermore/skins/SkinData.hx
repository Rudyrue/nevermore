package nevermore.skins;

@:structInit
@:publicFields
class SkinData {
	var standard:SkinFrameData = {};
	var press:SkinFrameData = {};
	var glow:SkinFrameData = {};

	var note:NoteFrameData = {};
	var sustain:SustainFrameData = {};
}

@:structInit
@:publicFields
class NoteFrameData {
	var standard:SkinFrameData = {};
}

@:structInit
@:publicFields
class SustainFrameData {
	var piece:SkinFrameData = {};
	var tail:SkinFrameData = {};
}

@:structInit
@:publicFields
class SkinFrameData {
	var list:Array<String> = [];
	var framerate:Float = 24;
}