package util;

import PlayState;
import openfl.display.BitmapData;
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
			{
				return BitmapData.fromFile(getCheckpointFolder(project) + '\\Thumbnail.png');
			}
			else
			{
				trace("getThumbnail Error: " + getCheckpointFolder(project) + '\\Thumbnail.png' + ' is null!');
				return BitmapData.fromFile('assets/images/thumbFallback.png');
			}
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
}
