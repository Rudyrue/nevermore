package nevermore.backend;

import sys.io.Process;

class Git {
	public static var commitHash(get, never):String;
	static inline function get_commitHash() {
		return __getCommitHash();
	}
	static macro function __getCommitHash() {
		return macro $v{gitProcess(['rev-parse', '--short', 'HEAD'])};
	}

	public static var commitNumber(get, never):Int;
	static inline function get_commitNumber() {
		return Std.parseInt(__getCommitNumber());
	}
	static macro function __getCommitNumber() {
		return macro $v{gitProcess(['rev-list', '--count', 'HEAD'])};
	}

	public static var commitDate(get, never):Date;
	static inline function get_commitDate() {
		var fuck:String = __getCommitDate();
		return Date.fromString(fuck.substr(0, 19)); // exclude the "-0700" thing i forgot the name
	}
	static macro function __getCommitDate() {
		return macro $v{gitProcess(['log', '-1', '--format=%ci'])};
	}

	// haxe i should kill you for running all macros in the project folder
	// and not where the macro originates
	static function gitProcess(args:Array<String>) {
		var lastWd:String = Sys.getCwd();

		Sys.setCwd(runProcess('haxelib', ['path', 'nevermore']));
		var result = runProcess('git', args);
		Sys.setCwd(lastWd);

		return result;
	}

	static function runProcess(name:String, ?args:Array<String>) {
		args ??= [];

		try {
			var process = new Process(name, args, false);
			var result:String = process.stdout.readLine().toString();
			process.close();
			return result;
		} catch (e:haxe.Exception) {
			Sys.println('macro process "$name" with args $args failed: $e');
			return '';
		}
	}
}