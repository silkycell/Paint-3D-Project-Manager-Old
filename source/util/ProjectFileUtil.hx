package util;

import PlayState;
import flixel.util.FlxSort;
import openfl.display.BitmapData;

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
	public static var disallowedChars:Array<String> = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];

	public static function parseProjectJson(json:Array<Dynamic>)
	{
		var projects:Array<ProjectFile> = [];

		for (project in json)
		{
			if (StringTools.contains(project.Path.toLowerCase(), 'workingfolder'))
				projects.insert(0, project);
			else
				projects.push(project);
		}

		if (projects.length == 0)
		{
			projects.push({
				"Id": "-1",
				"SourceId": "",
				"Name": "You don't have any projects!",
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

	public static function getThumbnail(project:ProjectFile)
	{
		try
		{
			if (BitmapData.fromFile(getCheckpointFolder(project) + '\\Thumbnail.png') != null)
				return BitmapData.fromFile(getCheckpointFolder(project) + '\\Thumbnail.png');
			else
				return BitmapData.fromFile('assets/images/thumbFallback.png');
		}
		catch (e)
		{
			trace("getThumbnail Error: " + e);
			return BitmapData.fromFile('assets/images/thumbFallback.png');
		}
	}

	public static function getCheckpointFolder(project:ProjectFile)
	{
		return PlayState._folderPath + '\\' + project.Path.substr(9);
	}

	public static function removeDuplicates(objects:Array<ProjectFile>)
	{
		var unique:Array<ProjectFile> = [];

		for (obj1 in objects)
		{
			var isDuplicate = false;
			for (obj2 in unique)
			{
				if (obj1.Id == obj2.Id || obj1.Path == obj2.Path)
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

	public static function sortDate(a:ProjectFile, b:ProjectFile)
	{
		if (a.DateTime > b.DateTime)
			return -1;
		else if (a.DateTime < b.DateTime)
			return 1;
		else
			return 0;
	}

	public static function sortSize(a:ProjectFile, b:ProjectFile)
	{
		var aS = Std.parseFloat(Util.getDirectorySize(getCheckpointFolder(a)));
		var bS = Std.parseFloat(Util.getDirectorySize(getCheckpointFolder(b)));

		if (aS > bS)
			return -1;
		else if (aS < bS)
			return 1;
		else
			return 0;
	}

	public static function sortAlphabetically(a:ProjectFile, b:ProjectFile)
	{
		var aN = a.Name.toUpperCase();
		var bN = b.Name.toUpperCase();

		if (aN < bN)
			return -1;
		else if (aN > bN)
			return 1;
		else
			return 0;
	}
}
