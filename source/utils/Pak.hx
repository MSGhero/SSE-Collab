package utils;

import hxd.net.BinaryLoader;
import hxd.fmt.pak.FileSystem;
import hxd.Res;
import hxd.res.Loader;

class Pak {
	
	static var __pakFS:FileSystem;
	#if js
	static var __bLoader:BinaryLoader;
	#end
	
	public static function init() {
		
		__pakFS = new FileSystem();
		Res.loader = new Loader(__pakFS);
		
		#if js
		__bLoader = new BinaryLoader(null);
		__bLoader.onError = msg -> {
			throw msg;
		};
		#end
	}
	
	public static function load(pakPaths:Array<String>, onProgress:(progress:Float)->Void, onComplete:()->Void) {
		
		if (__pakFS == null) throw "Call utils.Pak.init() first";
		
		#if js
		var loadCount = 0;
		@:privateAccess __bLoader.url = pakPaths[loadCount]; // doesn't allow for multiple paks at once
		
		if (onProgress != null)
			__bLoader.onProgress = (cur, max) -> {
				onProgress(cur / max / pakPaths.length);
			};
		
		__bLoader.onLoaded = data -> {
			
			__pakFS.addPak(new FileInput(data));
			loadCount++;
			
			if (loadCount == pakPaths.length) {
				if (onComplete != null) onComplete();
			}
			
			else {
				@:privateAccess __bLoader.url = pakPaths[loadCount];
				__bLoader.load();
			}
		};
		
		__bLoader.load();
		
		#else
		for (path in pakPaths) {
			__pakFS.loadPak(path);
		}
		
		if (onProgress != null) onProgress(1);
		if (onComplete != null) onComplete();
		#end
	}
}