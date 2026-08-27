package nevermore.backend;

import sys.io.Process;

@:structInit
@:publicFields
class Commit {
	var short:String = '';
	var long:String = '';
	var count:Int = 0;
}

class Git {
	public static var commit(get, never):Commit;
	static function get_commit():Commit {
		return {
			short: getShort(),
			long: getLong(),
			count: getCommitCount()
		}
	}

	public static var branch(get, never):String;
	static function get_branch():String {
		return getBranch();
	}

	static macro function getShort() {
		return macro $v{gitProcess(['rev-parse', '--short', 'HEAD']) ?? '???'};
	}

	static macro function getLong() {
		return macro $v{gitProcess(['rev-parse', 'HEAD']) ?? '???'};
	}

	static macro function getCommitCount() {
		return macro $v{Std.parseInt(gitProcess(['rev-list', '--count', 'HEAD']) ?? '0')};
	}

	static macro function getBranch() {
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