package nevermore.core.timing;

@:structInit
@:publicFields
class ScrollVelocity {
	var time:Float = 0.0;
	var multiplier:Float = 0.0;
	var visualTime:Float = 0.0;

	function toPixels(noteTime:Float) {
		return visualTime + ((noteTime - time) * multiplier);
	}
}