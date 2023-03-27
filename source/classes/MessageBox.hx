package classes;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;
import util.Util;

class MessageBox extends FlxSubState
{
	var box:FlxSpriteGroup = new FlxSpriteGroup();

	public var oneCallback:Void->Void;
	public var twoCallback:Void->Void;

	var mainColor:FlxColor;

	var bg:FlxUI9SliceSprite;

	public var text:FlxText;
	public var buttons:Array<FlxSpriteGroup> = [];

	public function new(mainColor:FlxColor, messageText:String, optionOne:String, ?optionTwo:String, ?countdown:Int, oneCallback:Void->Void,
			?twoCallback:Void->Void, BGColor:FlxColor = FlxColor.TRANSPARENT)
	{
		super(BGColor);

		this.mainColor = mainColor;
		this.oneCallback = oneCallback;
		this.twoCallback = twoCallback;

		bg = new FlxUI9SliceSprite(0, 0, 'assets/images/button.png', new Rectangle(0, 0, 700, 400), [33, 33, (33 * 2), (33 * 2)]);
		bg.color = mainColor;
		bg.screenCenter();
		box.add(bg);

		text = new FlxText(0, 0, bg.width / 1.15, messageText);
		text.setFormat('assets/fonts/comic.ttf', 25, Util.getDarkerColor(mainColor, 1.4), FlxTextAlign.CENTER);
		text.updateHitbox();
		text.screenCenter();
		text.y -= 60;

		box.add(text);

		for (i in 0...(optionTwo != null ? 2 : 1))
		{
			var button = new FlxSpriteGroup();
			buttons.push(button);

			var buttonBg = new FlxUI9SliceSprite(0, 0, 'assets/images/button.png', new Rectangle(0, 0, 200, 100), [33, 33, (33 * 2), (33 * 2)]);
			buttonBg.color = mainColor;
			buttonBg.screenCenter();
			buttonBg.y += 100;

			if (optionTwo != null)
				buttonBg.x += ((buttonBg.width / 2) + 10) * (i == 0 ? -1 : 1);

			text = new FlxText(0, 0, 0, (i == 0 ? optionOne : optionTwo));
			text.setFormat('assets/fonts/comic.ttf', 40, Util.getDarkerColor(mainColor, 1.4), FlxTextAlign.CENTER);

			text.updateHitbox();

			text.setPosition(buttonBg.x
				+ (buttonBg.width / 2)
				- (text.textField.width / 2), buttonBg.y
				+ (buttonBg.height / 2)
				- (text.textField.height / 2));

			button.add(buttonBg);
			button.add(text);

			box.add(button);

			add(box);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (button in buttons)
		{
			if (FlxG.mouse.overlaps(button))
			{
				getTypeFromGroup(button, FlxUI9SliceSprite).color = Util.getDarkerColor(mainColor, 1.2);

				if (FlxG.mouse.justPressed)
				{
					for (button in buttons)
						button.visible = false;

					(buttons.indexOf(button) == 0 ? oneCallback() : twoCallback());
					closeAnim();
				}
			}
			else
			{
				getTypeFromGroup(button, FlxUI9SliceSprite).color = mainColor;
			}
		}
	}

	public function closeAnim()
	{
		FlxTween.tween(box, {"scale.x": 2, "scale.y": 0}, 0.3, {
			ease: FlxEase.cubeOut,
			onComplete: function(twn:FlxTween)
			{
				close();
			}
		});
	}

	function getTypeFromGroup(group:FlxSpriteGroup, object:Dynamic)
	{
		for (item in group)
		{
			if (Std.isOfType(item, object))
				return item;
		}

		return group.getFirstExisting();
	}
}
