package classes;

import flixel.FlxG;
import flixel.FlxSprite;

class CallbackButton extends FlxSprite
{
	public var ClickCallback:CallbackButton->Void;
	public var HoverCallback:CallbackButton->Void;
	public var UnhoverCallback:CallbackButton->Void;

	override public function new(ClickCallback:CallbackButton->Void, X:Float = 0, Y:Float = 0, ?SimpleGraphic:flixel.system.FlxAssets.FlxGraphicAsset)
	{
		this.ClickCallback = ClickCallback;
		super(X, Y, SimpleGraphic);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.overlaps(this))
		{
			if (HoverCallback != null)
				HoverCallback(this);

			if (FlxG.mouse.justReleased)
				ClickCallback(this);
		}
		else
		{
			if (UnhoverCallback != null)
				UnhoverCallback(this);
		}
	}
}
