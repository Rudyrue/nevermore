package nevermore.backend;

import sys.io.Process;

class Git {
	public static var commit(get, never):String;
	static inline function get_commit() {
		return __getCommit();
	}
	static macro function __getCommit() {
		return macro $v{gitProcess(['rev-parse', '--short', 'HEAD']) ?? '???'};
	}

	public static var commitLong(get, never):String;
	static inline function get_commitLong() {
		return __getCommitLong();
	}
	static macro function __getCommitLong() {
		return macro $v{gitProcess(['rev-parse', 'HEAD']) ?? '???'};
	}

	public static var commitNumber(get, never):Int;
	static inline function get_commitNumber() {
		return Std.parseInt(__getCommitNumber());
	}
	static macro function __getCommitNumber() {
		return macro $v{gitProcess(['rev-list', '--count', 'HEAD']) ?? ''};
	}

	public static var branch(get, never):String;
	static inline function get_branch() {
		return __getBranch();
	}
	static macro function __getBranch() {
		return macro $v{gitProcess(['branch', '--show-current']) ?? '???'};
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
			Sys.println('failed process "$name" with $args: $e');
			return null;
		}
	}
}