package classes;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.geom.Rectangle;

class MessageBox extends BasePopupSubstate
{
	var mainColor:FlxColor;

	var messageCam:FlxCamera;
	var bg:FlxSprite;
	var box:FlxSpriteGroup = new FlxSpriteGroup();

	var text:FlxText;

	var buttons:Array<FlxSpriteGroup> = [];
	var oneCallback:Void->Void;
	var twoCallback:Void->Void;

	public function new(mainColor:FlxColor, headerMessage:String, messageText:String, itemArray:Array<String>, optionOne:String, ?optionTwo:String,
			oneCallback:Void->Void, ?twoCallback:Void->Void)
	{
		super(mainColor);

		this.mainColor = mainColor;
		this.oneCallback = oneCallback;
		this.twoCallback = twoCallback;

		messageCam = new FlxCamera();
		FlxG.cameras.add(messageCam);

		bg = new FlxSprite();
		Util.createRoundedRect(bg, 700, 400, 60);
		bg.screenCenter();
		bg.color = mainColor;
		box.add(bg);

		text = new FlxText(0, 0, bg.width / 1.30, messageText);
		text.setFormat(Util.curFont, 25, Util.contrastColor(mainColor), FlxTextAlign.CENTER);
		text.updateHitbox();
		text.screenCenter();
		text.y -= (itemArray != null ? 150 : 60);

		box.add(text);

		if (itemArray != null)
		{
			var testText = new FlxText(0, 0, bg.width, itemArray.join('\n'));
			testText.setFormat(Util.curFont, 25, Util.contrastColor(mainColor), FlxTextAlign.CENTER);
			testText.updateHitbox();
			testText.screenCenter();
			box.add(testText);
		}

		// if the popup has no buttons
		if (optionOne == '')
		{
			add(box);
			text.screenCenter();
			return;
		}

		for (i in 0...(optionTwo != null ? 2 : 1))
		{
			var button = new FlxSpriteGroup();
			buttons.push(button);

			var buttonBg = new FlxSprite();
			Util.createRoundedRect(buttonBg, 200, 130, 25);
			buttonBg.color = mainColor.getDarkened(0.2);
			buttonBg.screenCenter();
			buttonBg.y += 100;

			if (optionTwo != null)
				buttonBg.x += ((buttonBg.width / 2) + 10) * (i == 0 ? -1 : 1);

			text = new FlxText(0, 0, 0, (i == 0 ? optionOne : optionTwo));
			text.setFormat(Util.curFont, 40, Util.contrastColor(mainColor), FlxTextAlign.CENTER);

			text.updateHitbox();

			text.setPosition(buttonBg.x + (buttonBg.width / 2) - (text.width / 2), buttonBg.y + (buttonBg.height / 2) - (text.height / 2));

			button.add(buttonBg);
			button.add(text);

			box.add(button);
		}

		add(box);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (button in buttons)
		{
			if (FlxG.mouse.overlaps(button))
			{
				getTypeFromGroup(button, FlxSprite).color = mainColor.getDarkened(0.4);

				if (FlxG.mouse.justReleased)
				{
					for (button in buttons)
						button.visible = false;

					var funcLol:Void->Void = (buttons.indexOf(button) == 0 ? oneCallback : twoCallback);
					if (funcLol != null)
						funcLol();
					closeAnim();
				}
			}
			else
			{
				getTypeFromGroup(button, FlxSprite).color = mainColor.getDarkened(0.2);
			}
		}
	}

	public function closeAnim()
	{
		FlxTween.num(bgColor.alphaFloat, 0, 0.3, {ease: FlxEase.cubeOut}, function(num:Float)
		{
			var areYouKiddingMe = bgColor;
			areYouKiddingMe.alphaFloat = num;
			bgColor = areYouKiddingMe;
		});

		FlxTween.tween(box, {"scale.x": 2, "scale.y": 0}, 0.3, {
			ease: FlxEase.cubeOut,
			onComplete: function(twn:FlxTween)
			{
				close();
			}
		});
	}

	function getTypeFromGroup(group:FlxSpriteGroup, object:Dynamic):Dynamic
	{
		for (item in group)
		{
			if (Std.isOfType(item, object))
				return item;
		}

		return group.getFirstExisting();
	}
}
