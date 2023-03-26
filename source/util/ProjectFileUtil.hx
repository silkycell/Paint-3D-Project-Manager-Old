package util;

import PlayState;
import openfl.display.BitmapData;
import sys.FileSystem;
import util.Util;

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
}
