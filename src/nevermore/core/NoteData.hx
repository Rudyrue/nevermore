package nevermore.core;

@:structInit
@:publicFields
class NoteData {
	var time:Float = 0.0;
	var visualTime:Float = 0.0;

	var lane:Int = 0;
	var player:Int = 0;
	var quant:Int = -1;
	var beat:Float = 0.0;
	var type:String = '';

	var visualEnd:Float = 0.0;
	var length:Float = 0.0;
}