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

	public static function calculateAverageColor(image:BitmapData)
	{
		var r:Float = 0;
		var g:Float = 0;
		var b:Float = 0;
		var t:Float = 0;
		if (image != null)
		{
			if (image.transparent)
			{
				for (x in 0...image.width)
				{
					for (y in 0...image.height)
					{
						var c:FlxColor = image.getPixel32(x, y);
						r += c.redFloat * c.lightness * c.alpha;
						g += c.greenFloat * c.lightness * c.alpha;
						b += c.blueFloat * c.lightness * c.alpha;
						t += c.lightness * c.alpha;
					}
				}
			}
			else
			{
				for (x in 0...image.width)
				{
					for (y in 0...image.height)
					{
						var c:FlxColor = image.getPixel(x, y);
						r += c.redFloat * c.lightness;
						g += c.greenFloat * c.lightness;
						b += c.blueFloat * c.lightness;
						t += c.lightness;
					}
				}
			}
			if (t == 0)
			{
				return 0xFFFFFFFF;
			}
		}
		return FlxColor.fromRGBFloat(r / t, g / t, b / t);
	}

	public static function saturatedColor(image:BitmapData)
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

	public static function getDarkerColor(color:FlxColor, divAmount:Float = 2)
	{
		return FlxColor.fromRGB(Std.int(color.red / divAmount), Std.int(color.green / divAmount), Std.int(color.blue / divAmount));
	}

	// IMGONNA. REDO THIS ITS MAKIN ME MAAAD
	public static function contrastColor(color:FlxColor)
	{
		return FlxColor.WHITE;
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

	public static function colorCheck(color:FlxColor, bg:FlxColor)
	{
		var r1:Int = bg.red;
		var g1:Int = bg.green;
		var b1:Int = bg.blue;
		var r2:Int = color.red;
		var g2:Int = color.green;
		var b2:Int = color.blue;

		var diff:Float = Math.sqrt(Math.pow(r1 - r2, 2) + Math.pow(g1 - g2, 2) + Math.pow(b1 - b2, 2));

		if (diff < 75)
			color.brightness = 1 - (color.brightness / (color.brightness * 5));

		return color;
	}
}
