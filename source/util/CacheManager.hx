package util;

import flixel.util.FlxColor;
import openfl.display.BitmapData;
import util.ProjectFileUtil.ProjectFile;

enum CacheType
{
	THUMBNAIL;
	COLOR;
	SIZE;
	OBJECTCOUNT;
}

class CacheManager
{
	static var cacheMap:Map<CacheType, Map<ProjectFile, Any>> = new Map();

	public static function initialize()
	{
		cacheMap[THUMBNAIL] = new Map<ProjectFile, BitmapData>();
		cacheMap[COLOR] = new Map<ProjectFile, FlxColor>();
		cacheMap[SIZE] = new Map<ProjectFile, Float>();
		cacheMap[OBJECTCOUNT] = new Map<ProjectFile, Float>();

		ProjectFileUtil.defaultThumb = Assets.getBitmapData('assets/images/thumbFallback.png');
	}

	public static function getCachedItem(map:CacheType, key:ProjectFile):Dynamic
	{
		return cacheMap[map][key];
	}

	public static function setCachedItem(map:CacheType, key:ProjectFile, object:Dynamic):Dynamic
	{
		return cacheMap[map][key] = object;
	}

	public static function clearCachePool(map:CacheType)
	{
		if (map == THUMBNAIL)
		{
			// ACTUALLY remove the bitmaps from memory
			var funnyCache:openfl.utils.AssetCache = cast openfl.utils.Assets.cache;
			funnyCache.bitmapData = new Map<String, BitmapData>();
			cacheMap[THUMBNAIL].clear();

			// make sure fallback thumbnail isn't deleted, though.
			ProjectFileUtil.defaultThumb = Assets.getBitmapData('assets/images/thumbFallback.png');
		}
		else
		{
			cacheMap[map].clear();
		}
	}

	public static function clearAllCached()
	{
		for (i in cacheMap.keys())
			clearCachePool(i);
	}
}
