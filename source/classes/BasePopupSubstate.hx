package classes;

import flixel.FlxSubState;
import flixel.util.FlxColor;

class BasePopupSubstate extends FlxSubState
{
	override public function new(mainColor:FlxColor)
	{
		super();

		mainColor.alphaFloat = 0.4;
		bgColor = mainColor;
	}
}
