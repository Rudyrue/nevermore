package nevermore.skins;

class NoteskinCache {
	var list:Map<String, Noteskin> = [];
	public function new() {}

	public function exists(key:String):Bool {
		return list.exists(key);
	}

	public function clear() {
		list.clear();
	}

	public function get(key:String, ?quants:Bool = false) {
		set(key, quants);
		return list.get(key);
	}

	public function set(key:String, ?quants:Bool = false) {
		if (exists(key)) return;

		var data = getData(key, quants);
		if (data == null) return;

		list.set(key, data);
	}

	public function create(key:String, quants:Bool):Noteskin {
		return getData(key, quants);
	}

	// this is what you wanna override if you have your own asset system
	// (for example like fnf's)
	public function getData(key:String, quants:Bool):Noteskin {
		var preferQuants = quants;

		inline function getLoadKey()
			return #if !NEVERMORE_NO_QUANTIZATION quants ? key + '-quant' : #end key;

		var attempts = quants ? 2 : 1;
		for (i in 0...attempts) {
			var loadKey = getLoadKey();
			var jsonPath = Assets.getPath(loadKey + ".json");
			if (sys.FileSystem.exists(jsonPath)) {
				try {
					var json = haxe.Json.parse(Assets.text(jsonPath));
					return new Noteskin(json);
				} catch (e) {
					quants = false;
				}
			} else
				quants = false;
		}

		quants = preferQuants;
		for (i in 0...attempts) {
			var loadKey = getLoadKey();
			if (sys.FileSystem.exists(Assets.getPath(loadKey + ".xml")))
				return Noteskin.basic(loadKey);
			else
				quants = false;
		}

		return null;
	}
}