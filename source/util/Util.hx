package util;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import sys.FileSystem;

#if windows
@:cppFileCode('#include <stdlib.h>
#include <stdio.h>
#include <windows.h>
#include <winuser.h>
#include <dwmapi.h>
#include <strsafe.h>
#include <shellapi.h>
#include <iostream>
#include <string>

#pragma comment(lib, "Dwmapi")
#pragma comment(lib, "Shell32.lib")')
#end
class Util
{
	public static var sliceBounds = [66, 66, 132, 132];

	public static function saturatedColor(image:BitmapData):FlxColor
	{
		var h:Float = 0;
		var s:Float = 0;
		var b:Float = 0;
		var t:Float = 0;
		if (image != null)
		{
			for (x in 0...image.width)
			{
				for (y in 0...image.height)
				{
					var c:FlxColor = image.getPixel(x, y);
					h = ((t = c.saturation * c.brightness) > s) ? c.hue : h;
					s = (t > s) ? c.saturation : s;
					b = (t > s) ? c.brightness : s;
				}
			}

			if (t == 0)
			{
				return 0xFFFFFFFF;
			}
		}
		return FlxColor.fromHSB(h, s * 0.8, b);
	}

	public static function centerInRect(obj:FlxObject, rect:FlxRect)
	{
		obj.setPosition(((rect.width - obj.width) / 2) + rect.x, ((rect.height - obj.height) / 2) + rect.y);

		// prevent weeird float rounding artifacts
		obj.x = Std.int(obj.x);
		obj.y = Std.int(obj.y);

		rect.putWeak();
	}

	// IMGONNA. REDO THIS ITS MAKIN ME MAAAD
	public static function contrastColor(color:FlxColor)
	{
		return colorBrightnessCheck(FlxColor.WHITE, color);
	}

	public static function colorBrightnessCheck(color:FlxColor, bgColor:FlxColor)
	{
		var returnColor:FlxColor = color;

		if (getColorDistance(color, bgColor) < 50)
			returnColor = returnColor.getComplementHarmony();

		return returnColor;
	}

	public static function getColorDistance(color:FlxColor, bgColor:FlxColor)
	{
		var diffR:Int = color.red - bgColor.red;
		var diffG:Int = color.green - bgColor.green;
		var diffB:Int = color.blue - bgColor.blue;

		var distanceSquared:Int = diffR * diffR + diffG * diffG + diffB * diffB;

		return Math.sqrt(distanceSquared);
	}

	public static function ifEmptyCheck(value:Dynamic)
	{
		var string:String = Std.string(value);
		return (string == '' ? '(empty)' : string);
	}

	public static function getDirectorySize(path:String)
	{
		if (FileSystem.exists(path))
		{
			var size:Int = 0;

			for (file in FileSystem.readDirectory(path))
				size += FileSystem.stat(path + '\\' + file).size;

			return size;
		}
		else
		{
			return 0;
		}
	}

	public static inline function lerp(a:Float, b:Float, t:Float)
	{
		return FlxMath.lerp(a, b, FlxMath.bound(t * 60 * FlxG.elapsed, 0, 1));
	}

	#if windows
	@:functionCode('
        LPCSTR lwDesc = desc.c_str();

        res = MessageBox(
            NULL,
            lwDesc,
            NULL,
            MB_OK
        );
    ')
	#end
	static public function sendMsgBox(desc:String = "", res:Int = 0)
	{
		return res;
	}

	public static function deleteDirRecursively(path:String)
	{
		if (FileSystem.exists(path) && FileSystem.isDirectory(path))
		{
			var entries = FileSystem.readDirectory(path);
			for (entry in entries)
			{
				if (FileSystem.isDirectory(path + '/' + entry))
				{
					deleteDirRecursively(path + '/' + entry);
					FileSystem.deleteDirectory(path + '/' + entry);
				}
				else
				{
					FileSystem.deleteFile(path + '/' + entry);
				}
			}
		}
	}

	public static function getArrayDifference(arr1:Array<Dynamic>, arr2:Array<Dynamic>)
	{
		var diff:Array<Dynamic> = [];

		for (i in arr1)
		{
			if (!arr2.contains(i))
				diff.push(i);
		}

		for (i in arr2)
		{
			if (!arr1.contains(i) && !diff.contains(i))
				diff.push(i);
		}

		return diff;
	}
}
