package classes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import sys.io.File;
import util.ProjectFileUtil;
import util.Util;

class SideBarButton extends FlxSpriteGroup
{
	public var bg:FlxSprite;
	public var text:FlxText;
	public var defaultColor:FlxColor;
	public var callback:Void->Void;

	var instance:PlayState;

	public function new(x:Float = 0, y:Float = 0, width:Float = 1, height:Float = 1, str:String = '', col:FlxColor = FlxColor.WHITE, instance:PlayState)
	{
		super();
		bg = new FlxUI9SliceSprite(0, 0, 'assets/images/roundedUi.png', new Rectangle(0, 0, width, height), Util.sliceBounds);

		text = new FlxText(0, 0, width, str);
		text.setFormat('assets/fonts/comic.ttf', 40, FlxColor.WHITE, FlxTextAlign.CENTER);
		text.updateHitbox();
		Util.centerInRect(text, FlxRect.weak(bg.x, bg.y, bg.width, bg.height));

		add(bg);
		add(text);

		this.x = x;
		this.y = y;
		this.instance = instance;

		defaultColor = col;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.overlaps(this))
		{
			bg.color = Util.getDarkerColor(defaultColor, 1.2);

			if (FlxG.mouse.justReleased && instance.canInteract)
				callback();
		}
		else
		{
			bg.color = defaultColor;
		}
	}
}
