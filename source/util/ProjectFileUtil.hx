package util;

import PlayState;
import classes.ProjectButton;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import openfl.display.BitmapData;
import sys.FileSystem;

typedef ProjectFile =
{
	Id:String,
	SourceId:String,
	Name:String,
	URI:String,
	DateTime:Float,
	Path:String,
	SourceFilePath:String,
	Version:Float,
	IsRecovered:Bool,
	IsPreviouslySaved:Bool
}

class ProjectFileUtil
{
	public static var disallowedChars:Array<String> = ['\\', '/', ':', '*', '?', '"', '<', '>', '|', '"'];
	public static var defaultThumb:BitmapData;

	public static function parseProjectJson(json:Array<Dynamic>):Array<ProjectFile>
	{
		var projects:Array<ProjectFile> = [];

		for (project in json)
			projects.push(project);

		if (projects.length == 0)
		{
			projects.push({
				"Id": "-1",
				"SourceId": "",
				"Name": "No Projects Found!",
				"URI": "",
				"DateTime": 0,
				"Path": "",
				"SourceFilePath": "",
				"Version": 0.21,
				"IsRecovered": false,
				"IsPreviouslySaved": false
			});
		}

		return projects;
	}

	public static function removeDuplicates(objects:Array<ProjectFile>):Array<ProjectFile>
	{
		var unique:Array<ProjectFile> = [];

		for (obj1 in objects)
		{
			var isDuplicate = false;
			for (obj2 in unique)
			{
				if (obj1.Path == obj2.Path)
				{
					isDuplicate = true;
					break;
				}
			}

			if (!isDuplicate)
				unique.push(obj1);
		}

		return unique;
	}

	public static function generateID():String
	{
		var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		var result = '{';

		for (i in 0...8)
			result += chars.charAt(FlxG.random.int(0, chars.length));

		for (i in 1...3)
		{
			result += '-';

			for (i in 0...4)
				result += chars.charAt(FlxG.random.int(0, chars.length));
		}

		result += '-';

		for (i in 0...12)
			result += chars.charAt(FlxG.random.int(0, chars.length));

		result += '}';

		return result;
	}

	public inline static function sortDate(Order:Int, a:ProjectButton, b:ProjectButton):Int
	{
		return FlxSort.byValues(Order, a.project.DateTime, b.project.DateTime);
	}

	public inline static function sortHue(Order:Int, a:ProjectButton, b:ProjectButton):Int
	{
		return FlxSort.byValues(Order, a.defaultColor.hue, b.defaultColor.hue);
	}

	public inline static function sortSize(Order:Int, a:ProjectButton, b:ProjectButton):Int
	{
		return FlxSort.byValues(Order, getProjectSize(a.project), getProjectSize(b.project));
	}

	public inline static function sortObjectCount(Order:Int, a:ProjectButton, b:ProjectButton):Int
	{
		return FlxSort.byValues(Order, getObjectCount(a.project), getObjectCount(b.project));
	}

	public inline static function sortAlphabetically(Order:Int, a:ProjectButton, b:ProjectButton):Int
	{
		var aN = a.project.Name.toUpperCase();
		var bN = b.project.Name.toUpperCase();

		return aN < bN ? Order : -Order;
	}

	public static function getThumbnail(project:ProjectFile):BitmapData
	{
		if (CacheManager.getCachedItem(THUMBNAIL, project) == null)
			CacheManager.setCachedItem(THUMBNAIL, project, getThumbnailData(project));

		return CacheManager.getCachedItem(THUMBNAIL, project);
	}

	public static function getProjectSize(project:ProjectFile):Int
	{
		if (CacheManager.getCachedItem(SIZE, project) == null)
			CacheManager.setCachedItem(SIZE, project, Util.getDirectorySize(getCheckpointFolder(project)));

		return CacheManager.getCachedItem(SIZE, project);
	}

	public static function getProjectColor(cur:ProjectFile):FlxColor
	{
		if (FlxG.save.data.darkModeEnabled)
			return 0x2F2D31;

		if (CacheManager.getCachedItem(COLOR, cur) == null)
			CacheManager.setCachedItem(COLOR, cur, Util.saturatedColor(ProjectFileUtil.getThumbnail(cur)));
		return CacheManager.getCachedItem(COLOR, cur);
	}

	public static function getObjectCount(project:ProjectFile):Int
	{
		if (CacheManager.getCachedItem(OBJECTCOUNT, project) == null)
		{
			if (FileSystem.readDirectory(getCheckpointFolder(project)) == null)
				return 0;

			var objectList:Array<String> = [];

			for (file in FileSystem.readDirectory(getCheckpointFolder(project)))
			{
				if (StringTools.contains(file.toLowerCase(), 'nodes_'))
				{
					if (!objectList.contains(file.split('_')[1]))
						objectList.push(file.split('_')[1]);
				}
			}

			CacheManager.setCachedItem(OBJECTCOUNT, project, objectList.length);
		}

		return CacheManager.getCachedItem(OBJECTCOUNT, project);
	}

	// hi guys its me razzytism
	public static inline function getProjectDate(time:Float):String
	{
		if (time <= 0)
			return '(empty)';
		else
		{
			var date:Date = Date.fromTime((time - 116444736000000000) / 10000);
			return DateTools.format(date, '%D\n%r');
		}
	}

	public static function getCheckpointFolder(project:ProjectFile):String
	{
		return PlayState._folderPath + '\\' + project.Path.substr(9);
	}

	public static function getThumbnailData(project:ProjectFile):BitmapData
	{
		if (project == null)
		{
			trace('project is null, returning default thumbnail...');
			return defaultThumb;
		}
		try
		{
			if (BitmapData.fromFile(getCheckpointFolder(project) + '\\Thumbnail.png') != null)
				return BitmapData.fromFile(getCheckpointFolder(project) + '\\Thumbnail.png');
			else
				return defaultThumb;
		}
		catch (e)
		{
			trace('Error getting ${project.Name} thumbnail: ' + e);
			return defaultThumb;
		}
	}
}
