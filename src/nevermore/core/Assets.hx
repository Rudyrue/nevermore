package nevermore.core;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.system.System;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

class Assets {
	public static var imageExt:String = 'png';
	public static var audioExt:String = 'ogg';
	public static var rootFolder:String = 'assets';

	public static var cache:AssetCache;
	public static function init() {
		cache = new AssetCache();
	}

	public static function image(key:String):FlxGraphic {
		if (key.lastIndexOf('.') < 0) key += '.$imageExt';
		var path = getPath(key);
		if (cache.exists(path)) {
			return switch cache.get(path).src {
				case Graphic(graphic): graphic;
				default: null;
			}
		}

		var bitmap:BitmapData = BitmapData.fromFile(path);
		final graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, path);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		cache.set(path, {src: Graphic(graphic)});
		return graphic;
	}

	public static function audio(key:String):Sound {
		if (key.lastIndexOf('.') < 0) key += '.$audioExt';
		var path = getPath(key);
		if (cache.exists(path)) {
			return switch cache.get(path).src {
				case Audio(sound): sound;
				default: null;
			}
		}

		// i hate that this is called sound
		// but this is function is called audio
		// and so is the enum
		var sound:Sound = Sound.fromFile(path);
		cache.set(path, {src: Audio(sound)});
		return sound;
	}

	public static function text(key:String):String {
		return sys.io.File.getContent(getPath(key));
	}

	// no need to cache something like this
	// apparently it's fast enough ????
	public static function sparrowAtlas(key:String):FlxAtlasFrames {
		var graphic = image(key);
		var xml = text(key + '.xml');
		return FlxAtlasFrames.fromSparrow(graphic, xml);
	}

	public static function multiAtlas(keys:Array<String>):FlxAtlasFrames {
		var parentFrames = sparrowAtlas(keys[0]);
		if (keys.length == 1) return parentFrames;

		if (parentFrames == null) return null;

		for (i in 1...keys.length) {
			var extraFrames = sparrowAtlas(keys[i]);
			if (extraFrames == null) continue;
			parentFrames = parentFrames.addAtlas(extraFrames);
		}
		
		return parentFrames;
	}

	public static dynamic function getPath(key:String):String {
		return '$rootFolder/$key';
	}
}

enum Asset {
	Graphic(g:FlxGraphic);
	Audio(s:Sound);
}

@:structInit
class AssetData {
	public var src:Asset;
}

class AssetCache {
	var map:Map<String, AssetData>;
	var currentlyUsed:Array<String> = [];

	public function exists(key:String) {
		return map.exists(key);
	}

	public function get(key:String):AssetData {
		return map[key];
	}

	public function set(key:String, value:AssetData):AssetData {
		if (exists(key)) return value;
		map.set(key, value);
		if (!currentlyUsed.contains(key)) currentlyUsed.push(key);

		return value;
	}

	public function clearUnused() {
		for (key => asset in map) {
			if (currentlyUsed.contains(key)) continue;	
			destroyAsset(key, asset);
		}

		System.gc();
	}

	public function clear() {
		for (key => asset in map) {
			destroyAsset(key, asset);
		}

		currentlyUsed.resize(0);
		System.gc();
	}

	function destroyAsset(key:String, ?asset:AssetData) {
		asset ??= map[key];
		if (asset == null) return;

		switch asset.src {
			case Graphic(graphic):
				FlxG.bitmap.remove(graphic);
				graphic = null;

			case Audio(audio):
				audio.close();
				audio = null;
		}

		asset = null;
		map.remove(key);
	}
	
	public function new() {
		map = new Map<String, AssetData>();
	}
}