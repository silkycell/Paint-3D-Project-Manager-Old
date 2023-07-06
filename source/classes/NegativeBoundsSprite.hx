package classes;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;

class NegativeBoundsSprite extends FlxSprite
{
	override public function new(X:Float = 0, Y:Float = 0, SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
	}

	public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
	{ // THANK YOU NE_EO
		var doFlipX = false;
		var doFlipY = false;

		if (scale.x < 0)
		{
			doFlipX = true;
			scale.x *= -1; // flip scale
		}

		if (scale.y < 0)
		{
			doFlipY = true;
			scale.y *= -1; // flip scale
		}

		var bounds = super.getScreenBounds(newRect, camera);
		if (doFlipX)
			scale.x *= -1; // flip it again to set it back
		if (doFlipY)
			scale.y *= -1; // flip it again to set it back
		return bounds;
	}
}
