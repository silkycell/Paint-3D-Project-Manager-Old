package;

#if debug
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import util.Util;

using StringTools;

class ColorDebugState extends FlxState
{
	public var currentColor:FlxColor = FlxColor.WHITE;

	var bg:FlxSprite;
	var text:FlxText;
	var debugText:FlxText;

	override public function create()
	{
		super.create();

		bg = new FlxSprite().makeGraphic(1, 1);
		bg.scale.set(500, 300);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		text = new FlxText(0, 0, 500, 'Welcome to the color debug thing idk\nyour MOM. okay buddy');
		text.setFormat('assets/fonts/comic.ttf', 40, FlxColor.WHITE, FlxTextAlign.CENTER);
		text.updateHitbox();
		Util.centerInRect(text, FlxRect.weak(bg.x, bg.y, bg.width, bg.height));
		add(text);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		currentColor.red += (FlxG.keys.pressed.Q ? 1 : 0);
		currentColor.red -= (FlxG.keys.pressed.A ? 1 : 0);

		currentColor.green += (FlxG.keys.pressed.W ? 1 : 0);
		currentColor.green -= (FlxG.keys.pressed.S ? 1 : 0);

		currentColor.blue += (FlxG.keys.pressed.E ? 1 : 0);
		currentColor.blue -= (FlxG.keys.pressed.D ? 1 : 0);

		updateColors();
	}

	function updateColors()
	{
		bgColor = currentColor.getDarkened(0.4);
		bg.color = currentColor;
		text.color = Util.contrastColor(currentColor);
	}
}
#end
