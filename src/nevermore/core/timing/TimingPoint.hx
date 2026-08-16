package nevermore.core.timing;

@:structInit
class TimingPoint {
	public var time:Float = 0;
	public var tempo:Float = 120;
	public var beatsPerMeasure:Int = 4;

	// don't worry about these
	public var beat:Float = 0;
	public var measure:Float = 0;

	function toString():String {
		return 'Time: ${time}ms | Tempo: $tempo';
	}
}