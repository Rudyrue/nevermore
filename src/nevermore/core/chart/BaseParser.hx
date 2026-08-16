package nevermore.core.chart;

// TODO:
// maybe make a small fnf parser just so people don't 
// either have to write a parser themselves
// or setup a moonchart implementation
// just to test this out ?
//
// or maybe just embed moonchart support into here ????
// IDK
class BaseParser {
	public function new() {}

	public function load(path:String, ?diff:String):Chart {
		return Song.dummyData();
	}
}