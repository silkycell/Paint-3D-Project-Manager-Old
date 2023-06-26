package;

#if debug
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;

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
		text.setFormat(Util.curFont, 40, FlxColor.WHITE, FlxTextAlign.CENTER);
		text.updateHitbox();
		Util.centerInRect(text, FlxRect.weak(bg.x, bg.y, bg.width, bg.height));
		add(text);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		currentColor.hue += (FlxG.keys.pressed.Q ? elapsed * 3 : 0);
		currentColor.hue -= (FlxG.keys.pressed.A ? elapsed * 3 : 0);

		currentColor.saturation += (FlxG.keys.pressed.W ? elapsed * 0.2 : 0);
		currentColor.saturation -= (FlxG.keys.pressed.S ? elapsed * 0.2 : 0);

		currentColor.lightness += (FlxG.keys.pressed.E ? elapsed * 0.2 : 0);
		currentColor.lightness -= (FlxG.keys.pressed.D ? elapsed * 0.2 : 0);

		if (FlxG.keys.justPressed.R)
			currentColor = FlxColor.RED;

		updateColors();
	}

	function updateColors()
	{
		bgColor = currentColor.getDarkened(0.4);
		bg.color = currentColor;
		text.color = Util.contrastColor(currentColor);
		text.text = currentColor.getColorInfo();
	}
}
#end
