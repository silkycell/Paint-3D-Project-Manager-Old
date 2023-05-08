package util;

import PlayState;
import classes.ProjectButton;
import flixel.FlxG;
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
			trace('Error getting ${project.Name} thumbnail: ' + e);
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

	public inline static function sortDate(Order:Int, a:ProjectButton, b:ProjectButton)
	{
		return FlxSort.byValues(Order, a.project.DateTime, b.project.DateTime);
	}

	public inline static function sortSize(Order:Int, a:ProjectButton, b:ProjectButton)
	{
		return FlxSort.byValues(Order, getProjectSize(a.project), getProjectSize(b.project));
	}

	public inline static function sortAlphabetically(Order:Int, a:ProjectButton, b:ProjectButton)
	{
		var aN = a.project.Name.toUpperCase();
		var bN = b.project.Name.toUpperCase();

		return aN > bN ? Order : -Order;
	}

	public static function generateID()
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

	public static function getProjectSize(project:ProjectFile)
	{
		if (PlayState.sizeArray[PlayState._projects.indexOf(project)] != null)
			return PlayState.sizeArray[PlayState._projects.indexOf(project)];
		else
			return PlayState.sizeArray[PlayState._projects.indexOf(project)] = Util.getDirectorySize(getCheckpointFolder(project));
	}
}
