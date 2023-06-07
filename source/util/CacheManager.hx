package util;

import flixel.util.FlxColor;
import openfl.display.BitmapData;
import util.ProjectFileUtil.ProjectFile;

class CacheManager
{
	static var cacheMap:Map<String, Map<ProjectFile, Any>> = new Map();

	public static function initialize()
	{
		cacheMap['thumbnail'] = new Map<ProjectFile, BitmapData>();
		cacheMap['color'] = new Map<ProjectFile, FlxColor>();
		cacheMap['size'] = new Map<ProjectFile, Float>();
		cacheMap['objectcount'] = new Map<ProjectFile, Float>();
	}

	public static function getCachedItem(map:String, key:ProjectFile)
	{
		return cacheMap[map][key];
	}

	public static function setCachedItem(map:String, key:ProjectFile, object:Dynamic)
	{
		return cacheMap[map][key] = object;
	}

	public static function clearCachePool(map:String)
	{
		for (i in cacheMap[map].keys())
			cacheMap[map].remove(i);
	}

	public static function clearAllCached()
	{
		for (i in cacheMap.keys())
			clearCachePool(i);
	}
}
